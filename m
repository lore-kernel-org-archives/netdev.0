From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [RFC PATCH 0/2] bpf: enable/disable events stored in PERF_EVENT_ARRAY maps trace data output when perf sampling
Date: Mon, 12 Oct 2015 09:02:41 +0000
Message-ID: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xiakaixu@huawei.com>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: <ast@plumgrid.com>, <davem@davemloft.net>, <acme@kernel.org>,
	<mingo@redhat.com>, <a.p.zijlstra@chello.nl>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In some scenarios we don't want to output trace data when perf sampling
in order to reduce overhead. For example, perf can be run as daemon to
dump trace data when necessary, such as the system performance goes down.

This patchset adds the helpers bpf_perf_event_sample_enable/disable() to
implement this function. By applying these helpers, we can enable/disable
events stored in PERF_EVENT_ARRAY maps trace data output and get the
samples we are most interested in.

We also need to make the perf user side can adds the normal PMU events
from perf cmdline to PERF_EVENT_ARRAY maps. My colleague He Kuang is doing
this work. In the following example, the cycles will be stored in the
PERF_EVENT_ARRAY maps.

Before this patch,
   $ ./perf record -e cycles -a sleep 1
   $ ./perf report --stdio
	# To display the perf.data header info, please use --header/--header-only option
	#
	#
	# Total Lost Samples: 0
	#
	# Samples: 655  of event 'cycles'
	# Event count (approx.): 129323548
	...

After this patch,
   $ ./perf record -e pmux=cycles --event perf-bpf.o/my_cycles_map=pmux/ -a sleep 1
   $ ./perf report --stdio
	# To display the perf.data header info, please use --header/--header-only option
	#
	#
	# Total Lost Samples: 0
	#
	# Samples: 23  of event 'cycles'
	# Event count (approx.): 2064170
	...

The bpf program example:

  struct bpf_map_def SEC("maps") my_cycles_map = {
          .type = BPF_MAP_TYPE_PERF_EVENT_ARRAY,
          .key_size = sizeof(int),
          .value_size = sizeof(u32),
          .max_entries = 32, 
  };

  SEC("enter=sys_write")
  int bpf_prog_1(struct pt_regs *ctx)
  {
          bpf_perf_event_sample_enable(&my_cycles_map);
          return 0;
  }

  SEC("exit=sys_write%return")
  int bpf_prog_2(struct pt_regs *ctx)
  {
          bpf_perf_event_sample_disable(&my_cycles_map);
          return 0;
  }


Kaixu Xia (2):
  perf: Add the flag sample_disable not to output data on samples
  bpf: Implement bpf_perf_event_sample_enable/disable() helpers

 include/linux/bpf.h        |  3 +++
 include/linux/perf_event.h |  2 ++
 include/uapi/linux/bpf.h   |  2 ++
 kernel/bpf/arraymap.c      |  5 +++++
 kernel/bpf/verifier.c      |  4 +++-
 kernel/events/core.c       |  3 +++
 kernel/trace/bpf_trace.c   | 34 ++++++++++++++++++++++++++++++++++
 7 files changed, 52 insertions(+), 1 deletion(-)

-- 
1.8.3.4
