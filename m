From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/8] allow bpf attach to tracepoints
Date: Mon, 4 Apr 2016 21:52:46 -0700
Message-ID: <1459831974-2891931-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40754 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754694AbcDEEw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 00:52:58 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u354mt0S007390
	for <netdev@vger.kernel.org>; Mon, 4 Apr 2016 21:52:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 222xhcb93d-3
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 21:52:56 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 42932646faea11e58b050002c9dfb610-f7f23f0 for <netdev@vger.kernel.org>;	Mon,
 04 Apr 2016 21:52:55 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steven, Peter,

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

Patch 1 and 2 are simple changes in perf core side, please review.
I'd like to take the whole set via net-next tree, since the rest of
the patches might conflict with other bpf work going on in net-next
and we want to avoid cross-tree merge conflicts.
Patch 7 is an example of access to tracepoint fields from bpf prog.
Patch 8 is a micro benchmark for bpf+kprobe vs bpf+tracepoint.

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

Alexei Starovoitov (8):
  perf: optimize perf_fetch_caller_regs
  perf, bpf: allow bpf programs attach to tracepoints
  bpf: register BPF_PROG_TYPE_TRACEPOINT program type
  bpf: support bpf_get_stackid() and bpf_perf_event_output() in
    tracepoint programs
  bpf: sanitize bpf tracepoint access
  samples/bpf: add tracepoint support to bpf loader
  samples/bpf: tracepoint example
  samples/bpf: add tracepoint vs kprobe performance tests

 include/linux/bpf.h                     |   2 +
 include/linux/perf_event.h              |   2 -
 include/linux/trace_events.h            |   1 +
 include/trace/perf.h                    |  18 +++-
 include/uapi/linux/bpf.h                |   1 +
 kernel/bpf/stackmap.c                   |   2 +-
 kernel/bpf/verifier.c                   |   6 +-
 kernel/events/core.c                    |  21 ++++-
 kernel/trace/bpf_trace.c                |  85 ++++++++++++++++-
 kernel/trace/trace_event_perf.c         |   4 +
 kernel/trace/trace_events.c             |  18 ++++
 samples/bpf/Makefile                    |   5 +
 samples/bpf/bpf_load.c                  |  26 +++++-
 samples/bpf/offwaketime_kern.c          |  26 +++++-
 samples/bpf/test_overhead_kprobe_kern.c |  41 ++++++++
 samples/bpf/test_overhead_tp_kern.c     |  36 +++++++
 samples/bpf/test_overhead_user.c        | 161 ++++++++++++++++++++++++++++++++
 17 files changed, 432 insertions(+), 23 deletions(-)
 create mode 100644 samples/bpf/test_overhead_kprobe_kern.c
 create mode 100644 samples/bpf/test_overhead_tp_kern.c
 create mode 100644 samples/bpf/test_overhead_user.c

-- 
2.8.0
