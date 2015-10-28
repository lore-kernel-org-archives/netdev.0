From: Wang Nan <wangnan0@huawei.com>
Subject: [RFC PATCH net-next 0/4] perf tools: Support receiving output through BPF programs
Date: Wed, 28 Oct 2015 10:55:01 +0000
Message-ID: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <lizefan@huawei.com>, <pi3orama@163.com>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Wang Nan <wangnan0@huawei.com>
To: <acme@kernel.org>, <ast@kernel.org>, <brendan.d.gregg@gmail.com>,
	<jolsa@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexei provided a patchset to allow BPF programs output data to ring
buffer using helper bpf_perf_event_output() [1].  and have been merged
into net-next as commit a43eec304259a6c637f4014a6d4767159b6a3aa3 (bpf:
introduce bpf_perf_event_output() helper).

This patchset introduces perf side code to utilize that helper,

This patchset only supports output data to CTF. It is enough for me
because my workflow is 'perf record' -> 'convert to CTF' -> 'python'.
However, I know some people heavily rely on 'perf script' to parse
trace in perf.data. Here I'd like discuss the way to show output data
using 'perf script'. Currently the only way to watch the output data
using perf script is to use '-D'.

[1] http://lkml.kernel.org/r/1445396556-4854-1-git-send-email-ast@kernel.org

Example:

############ BPF program #############
  struct bpf_map_def SEC("maps") map_channel = {
      .type = BPF_MAP_TYPE_PERF_EVENT_ARRAY,
      .key_size = sizeof(int),
      .value_size = sizeof(u32),
      .max_entries = __NR_CPUS__,
  };

  SEC("func_write=sys_write")
  int func_write(void *ctx)
  {
      struct {
          u64 ktime;
          int cpuid;
      } __attribute__((packed)) output_data;
      char error_data[] = "Error: failed to output\n";

      output_data.cpuid = bpf_get_smp_processor_id();
      output_data.ktime = bpf_ktime_get_ns();
      int err = perf_event_output(ctx, &map_channel,
                                  bpf_get_smp_processor_id(),
                                  &output_data, sizeof(output_data));
      if (err)
          bpf_trace_printk(error_data, sizeof(error_data));
      return 0;
  }
  char _license[] SEC("license") = "GPL";
  int _version SEC("version") = 0x40300;

############ cmdline ############
 # perf record -g -e evt=bpf-output/no-inherit/ \
                  -e ./test_bpf_output.c/maps.map_channel.event=evt/ -a ls
 # perf data convert --to-ctf ./out.ctf
 # babeltrace ./out.ctf
 [06:34:00.288671496] (+?.?????????) evt=bpf-output/no-inherit/: { cpu_id = 0 }, { perf_ip = 0xFFFFFFFF811ED5F1, perf_tid = 4469, perf_pid = 4469, perf_id = 3685, raw_len = 3, raw_data = [ [0] = 0xB163D948, [1] = 0x19E6E, [2] = 0x0 ] }
 [06:34:00.288677551] (+0.000006055) evt=bpf-output/no-inherit/: { cpu_id = 0 }, { perf_ip = 0xFFFFFFFF811ED5F1, perf_tid = 4469, perf_pid = 4469, perf_id = 3685, raw_len = 3, raw_data = [ [0] = 0xB163F289, [1] = 0x19E6E, [2] = 0x0 ] }

########### python script #######
 from babeltrace import TraceCollection

 tc = TraceCollection(
 tc.add_trace('./out.ctf', 'ctf')

 for event in tc.events:
     if not event.name.startswith('evt='):
         continue
     raw_data = event['raw_data']
     print(raw_data[0] + raw_data[1] << 32, raw_data[2]));

Wang Nan (4):
  perf tools: Enable pre-event inherit setting by config terms
  perf tools: Introduce bpf-output event
  perf data: Add u32_hex data type
  perf data: Support converting data from bpf_perf_event_output()

 tools/perf/util/data-convert-bt.c | 117 +++++++++++++++++++++++++++++++++++++-
 tools/perf/util/evsel.c           |  15 +++++
 tools/perf/util/evsel.h           |   2 +
 tools/perf/util/parse-events.c    |  18 ++++++
 tools/perf/util/parse-events.h    |   2 +
 tools/perf/util/parse-events.l    |   3 +
 6 files changed, 156 insertions(+), 1 deletion(-)

-- 
1.8.3.4
