defmodule ExqBenchmarkTest do
  use ExUnit.Case

  def benchmark(parallel) do
    Benchee.run(
      %{
        "poolboy enqueuer" => fn _ ->
          {:ok, _} = ExqBenchmark.Enqueuer.poolboy_enqueue()
        end,
        "gproc enqueuer" => fn _ ->
          ExqBenchmark.Enqueuer.gproc_enqueue()
        end,
        "named enqueuer" => fn _ ->
          ExqBenchmark.Enqueuer.named_enqueue()
        end
      },
      warmup: 1,
      time: 4,
      parallel: parallel,
      formatters: [
        {Benchee.Formatters.HTML, file: "output/#{parallel}parallel.html", auto_open: false},
        Benchee.Formatters.Console
      ],
      before_scenario: fn _ ->
        Redix.command(:redix, ["DEL", "exq:queue:benchmark_queue"])
      end,
      after_scenario: fn _ ->
        Redix.command(:redix, ["DEL", "exq:queue:benchmark_queue"])
      end
    )
  end

  test "enqueuer throughput benchmarks 1", do: benchmark(1)
  test "enqueuer throughput benchmarks 6", do: benchmark(6)
  test "enqueuer throughput benchmarks 12", do: benchmark(12)
  test "enqueuer throughput benchmarks 24", do: benchmark(24)
  test "enqueuer throughput benchmarks 48", do: benchmark(48)
end
