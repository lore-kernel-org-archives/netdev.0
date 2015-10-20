From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH V5 0/1] bpf: control events stored in PERF_EVENT_ARRAY maps trace data output when perf sampling
Date: Tue, 20 Oct 2015 07:22:14 +0000
Message-ID: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com>
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

Previous patch V4 url:
https://lkml.org/lkml/2015/10/19/247

This patchset introduces the new perf_event_attr attribute 
'soft_disable'. The already existed 'disabled' flag doesn't
meet the requirements. The cpu_function_call is too much 
to do from bpf program and we control the perf_event stored in 
maps like soft_disable, so if the 'disabled' flag is set to
true, we can't enable/disable the perf event by bpf programs.

changes in V5:
 - move the bpf helper parameter 'flags' defination to bpf_trace.c
   and document the flags bits in uapi header.

changes in V4:
 - make the naming more proper;
 - fix the initial value set of attr->soft_disable bug;
 - add unlikely() to the check of event->soft_enable;
 - squash the 2ed patch into 1st patch;

changes in V3:
 - make the flag name and condition check consistent;
 - check the bpf helper flag only bit 0 and check all other bits are
   reserved;
 - use atomic_dec_if_positive() and atomic_inc_unless_negative();
 - make bpf_perf_event_dump_control_proto be static;
 - remove the ioctl PERF_EVENT_IOC_SET_ENABLER and 'enabler' event;
 - implement the function that controlling all the perf events
   stored in PERF_EVENT_ARRAY maps by setting the parameter 'index'
   to maps max_entries;

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
	# Samples: 527  of event 'cycles'
	# Event count (approx.): 87824857
	...

After this patch,
   $ ./perf record -e pmux=cycles --event perf-bpf.o/my_cycles_map=pmux/ -a sleep 1
   $ ./perf report --stdio
	# To display the perf.data header info, please use --header/--header-only option
	#
	#
	# Total Lost Samples: 0
	#
	# Samples: 22  of event 'cycles'
	# Event count (approx.): 4213922
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
          bpf_perf_event_control(&my_cycles_map, 0, 3); 
          return 0;
  }

  SEC("exit=sys_write%return")
  int bpf_prog_2(struct pt_regs *ctx)
  {
          bpf_perf_event_control(&my_cycles_map, 0, 2); 
          return 0;
  }

Consider control sampling in function level, we have to set
a high sample frequency to dump trace data when enable/disable
the perf event on current cpu.

Kaixu Xia (1):
  bpf: control events stored in PERF_EVENT_ARRAY maps trace data output
    when perf sampling

 include/linux/perf_event.h      |  1 +
 include/uapi/linux/bpf.h        | 11 ++++++++
 include/uapi/linux/perf_event.h |  3 +-
 kernel/bpf/verifier.c           |  3 +-
 kernel/events/core.c            | 13 +++++++++
 kernel/trace/bpf_trace.c        | 62 +++++++++++++++++++++++++++++++++++++++++
 6 files changed, 91 insertions(+), 2 deletions(-)

-- 
1.8.3.4
