From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH V2 0/2] bpf: enable/disable events stored in PERF_EVENT_ARRAY maps trace data output when perf sampling
Date: Wed, 14 Oct 2015 12:37:55 +0000
Message-ID: <1444826277-94060-1-git-send-email-xiakaixu@huawei.com>
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

Previous RFC patch url:
https://lkml.org/lkml/2015/10/12/135

changes in V2:
 - rebase the whole patch set to net-next tree(4b418bf);
 - remove the added flag perf_sample_disable in bpf_map;
 - move the added fields in structure perf_event to proper place
   to avoid cacheline miss;
 - use counter based flag instead of 0/1 switcher in considering
   of reentering events;
 - use a single helper bpf_perf_event_sample_control() to enable/
   disable events;
 - implement a light-weight solution to control the trace data
   output on current cpu;
 - create a new ioctl PERF_EVENT_IOC_SET_ENABLER to enable/disable
   a set of events;

Before this patch,
   $ ./perf record -e cycles -a sleep 1
   $ ./perf report --stdio
	# To display the perf.data header info, please use --header/--header-only option
	#
	#
	# Total Lost Samples: 0
	#
	# Samples: 643  of event 'cycles'
	# Event count (approx.): 128313904
	...

After this patch,
   $ ./perf record -e pmux=cycles --event perf-bpf.o/my_cycles_map=pmux/ -a sleep 1
   $ ./perf report --stdio
	# To display the perf.data header info, please use --header/--header-only option
	#
	#
	# Total Lost Samples: 0
	#
	# Samples: 25  of event 'cycles'
	# Event count (approx.): 5788400
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
          bpf_perf_event_sample_control(&my_cycles_map, 32, 0); 
          return 0;
  }

  SEC("exit=sys_write%return")
  int bpf_prog_2(struct pt_regs *ctx)
  {
          bpf_perf_event_sample_control(&my_cycles_map, 32, 1); 
          return 0;
  }

Consider control sampling in function level, if we don't use the
PERF_EVENT_IOC_SET_ENABLER ioctl in perf user side, we must set
a high sample frequency to dump trace data.

Kaixu Xia (2):
  bpf: control the trace data output on current cpu when perf sampling
  bpf: control a set of perf events by creating a new ioctl
    PERF_EVENT_IOC_SET_ENABLER

 include/linux/perf_event.h      |  2 ++
 include/uapi/linux/bpf.h        |  5 ++++
 include/uapi/linux/perf_event.h |  4 +++-
 kernel/bpf/verifier.c           |  3 ++-
 kernel/events/core.c            | 53 +++++++++++++++++++++++++++++++++++++++++
 kernel/trace/bpf_trace.c        | 35 +++++++++++++++++++++++++++
 6 files changed, 100 insertions(+), 2 deletions(-)

-- 
1.8.3.4
