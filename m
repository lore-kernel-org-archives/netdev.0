From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 00/10] allow bpf attach to tracepoints
Date: Wed, 6 Apr 2016 18:43:21 -0700
Message-ID: <1459993411-2754735-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Steven, Peter,

v1->v2: addressed Peter's comments:
- fixed wording in patch 1, added ack
- refactored 2nd patch into 3:
2/10 remove unused __perf_addr macro which frees up
an argument in perf_trace_buf_submit
3/10 split perf_trace_buf_prepare into alloc and update parts, so that bpf
programs don't have to pay performance penalty for update of struct trace_entry
which is not going to be accessed by bpf
4/10 actual addition of bpf filter to perf tracepoint handler is now trivial
and bpf prog can be used as proper filter of tracepoints

v1 cover:
last time we discussed bpf+tracepoints it was a year ago [1] and the reason
we didn't proceed with that approach was that bpf would make arguments
arg1, arg2 to trace_xx(arg1, arg2) call to be exposed to bpf program
and that was considered unnecessary extension of abi. Back then I wanted
to avoid the cost of buffer alloc and field assign part in all
of the tracepoints, but looks like when optimized the cost is acceptable.
So this new apporach doesn't expose any new abi to bpf program.
The program is looking at tracepoint fields after they were copied
by perf_trace_xx() and described in /sys/kernel/debug/tracing/events/xxx/format
We made a tool [2] that takes arguments from /sys/.../format and works as:
$ tplist.py -v random:urandom_read
    int got_bits;
    int pool_left;
    int input_left;
Then these fields can be copy-pasted into bpf program like:
struct urandom_read {
    __u64 hidden_pad;
    int got_bits;
    int pool_left;
    int input_left;
};
and the program can use it:
SEC("tracepoint/random/urandom_read")
int bpf_prog(struct urandom_read *ctx)
{
    return ctx->pool_left > 0 ? 1 : 0;
}
This way the program can access tracepoint fields faster than
equivalent bpf+kprobe program, which is the main goal of these patches.

Patch 1-4 are simple changes in perf core side, please review.
I'd like to take the whole set via net-next tree, since the rest of
the patches might conflict with other bpf work going on in net-next
and we want to avoid cross-tree merge conflicts.
Alternatively we can put patches 1-4 into both tip and net-next.

Patch 9 is an example of access to tracepoint fields from bpf prog.
Patch 10 is a micro benchmark for bpf+kprobe vs bpf+tracepoint.

Note that for actual tracing tools the user doesn't need to
run tplist.py and copy-paste fields manually. The tools do it
automatically. Like argdist tool [3] can be used as:
$ argdist -H 't:block:block_rq_complete():u32:nr_sector'
where 'nr_sector' is name of tracepoint field taken from
/sys/kernel/debug/tracing/events/block/block_rq_complete/format
and appropriate bpf program is generated on the fly.

[1] http://thread.gmane.org/gmane.linux.kernel.api/8127/focus=8165
[2] https://github.com/iovisor/bcc/blob/master/tools/tplist.py
[3] https://github.com/iovisor/bcc/blob/master/tools/argdist.py

Alexei Starovoitov (10):
  perf: optimize perf_fetch_caller_regs
  perf: remove unused __addr variable
  perf: split perf_trace_buf_prepare into alloc and update parts
  perf, bpf: allow bpf programs attach to tracepoints
  bpf: register BPF_PROG_TYPE_TRACEPOINT program type
  bpf: support bpf_get_stackid() and bpf_perf_event_output() in
    tracepoint programs
  bpf: sanitize bpf tracepoint access
  samples/bpf: add tracepoint support to bpf loader
  samples/bpf: tracepoint example
  samples/bpf: add tracepoint vs kprobe performance tests

 include/linux/bpf.h                     |   2 +
 include/linux/perf_event.h              |   4 +-
 include/linux/trace_events.h            |   9 +-
 include/trace/perf.h                    |  23 +++--
 include/trace/trace_events.h            |   3 -
 include/uapi/linux/bpf.h                |   1 +
 kernel/bpf/stackmap.c                   |   2 +-
 kernel/bpf/verifier.c                   |   6 +-
 kernel/events/core.c                    |  27 ++++--
 kernel/trace/bpf_trace.c                |  85 ++++++++++++++++-
 kernel/trace/trace_event_perf.c         |  40 ++++----
 kernel/trace/trace_events.c             |  18 ++++
 kernel/trace/trace_kprobe.c             |  10 +-
 kernel/trace/trace_syscalls.c           |  13 +--
 kernel/trace/trace_uprobe.c             |   5 +-
 samples/bpf/Makefile                    |   5 +
 samples/bpf/bpf_load.c                  |  26 ++++-
 samples/bpf/offwaketime_kern.c          |  26 ++++-
 samples/bpf/test_overhead_kprobe_kern.c |  41 ++++++++
 samples/bpf/test_overhead_tp_kern.c     |  36 +++++++
 samples/bpf/test_overhead_user.c        | 162 ++++++++++++++++++++++++++++++++
 21 files changed, 475 insertions(+), 69 deletions(-)
 create mode 100644 samples/bpf/test_overhead_kprobe_kern.c
 create mode 100644 samples/bpf/test_overhead_tp_kern.c
 create mode 100644 samples/bpf/test_overhead_user.c

-- 
2.8.0
