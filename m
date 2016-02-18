From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 0/3] bpf_get_stackid() and stack_trace map
Date: Wed, 17 Feb 2016 19:58:56 -0800
Message-ID: <1455767939-2700534-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:1149 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1424948AbcBRD7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 22:59:03 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1I3st17024602
	for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 19:59:02 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2151u3gwwx-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 19:59:02 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 f131ce4ed5f311e5b6fb0002c9521c9e-a1ffc270 for <netdev@vger.kernel.org>;	Wed,
 17 Feb 2016 19:59:00 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set introduces new map type to store stack traces and
corresponding bpf_get_stackid() helper.
BPF programs already can walk the stack via unrolled loop
of bpf_probe_read()s which is ok for simple analysis, but it's
not efficient and limited to <30 frames after that the programs
don't fit into MAX_BPF_STACK. With bpf_get_stackid() helper
the programs can collect up to PERF_MAX_STACK_DEPTH both
user and kernel frames.
Using stack traces as a key in a map turned out to be very useful
for generating flame graphs, off-cpu graphs, waker and chain graphs.
Patch 3 is a simplified version of 'offwaketime' tool which is
described in detail here:
http://brendangregg.com/blog/2016-02-01/linux-wakeup-offwake-profiling.html

Earlier version of this patch were using save_stack_trace() helper,
but 'unreliable' frames add to much noise and two equiavlent
stack traces produce different 'stackid's.
Using lockdep style of storing frames with MAX_STACK_TRACE_ENTRIES is
great for lockdep, but not acceptable for bpf, since the stack_trace
map needs to be freed when user Ctrl-C the tool.
The ftrace style with per_cpu(struct ftrace_stack) is great, but it's
tightly coupled with ftrace ring buffer and has the same 'unreliable'
noise. perf_event's perf_callchain() mechanism is also very efficient
and it only needed minor generalization which is done in patch 1
to be used by bpf stack_trace maps.
Peter, please take a look at patch 1.
If you're ok with it, I'd like to take the whole set via net-next.

Patch 1 - generalization of perf_callchain()
Patch 2 - stack_trace map done as lock-less hashtable without link list
  to avoid spinlock on insertion which is critical path when
  bpf_get_stackid() helper is called for every task switch event
Patch 3 - offwaketime example

After the patch the 'perf report' for artificial 'sched_bench'
benchmark that doing pthread_cond_wait/signal and 'offwaketime'
example is running in the background:
 16.35%  swapper      [kernel.vmlinux]    [k] intel_idle
  2.18%  sched_bench  [kernel.vmlinux]    [k] __switch_to
  2.18%  sched_bench  libpthread-2.12.so  [.] pthread_cond_signal@@GLIBC_2.3.2
  1.72%  sched_bench  libpthread-2.12.so  [.] pthread_mutex_unlock
  1.53%  sched_bench  [kernel.vmlinux]    [k] bpf_get_stackid
  1.44%  sched_bench  [kernel.vmlinux]    [k] entry_SYSCALL_64
  1.39%  sched_bench  [kernel.vmlinux]    [k] __call_rcu.constprop.73
  1.13%  sched_bench  libpthread-2.12.so  [.] pthread_mutex_lock
  1.07%  sched_bench  libpthread-2.12.so  [.] pthread_cond_wait@@GLIBC_2.3.2
  1.07%  sched_bench  [kernel.vmlinux]    [k] hash_futex
  1.05%  sched_bench  [kernel.vmlinux]    [k] do_futex
  1.05%  sched_bench  [kernel.vmlinux]    [k] get_futex_key_refs.isra.13

The hotest part of bpf_get_stackid() is inlined jhash2, so we may consider
using some faster hash in the future, but it's good enough for now.

Alexei Starovoitov (3):
  perf: generalize perf_callchain
  bpf: introduce BPF_MAP_TYPE_STACK_TRACE
  samples/bpf: offwaketime example

 arch/x86/include/asm/stacktrace.h |   2 +-
 arch/x86/kernel/cpu/perf_event.c  |   4 +-
 arch/x86/kernel/dumpstack.c       |   6 +-
 arch/x86/kernel/stacktrace.c      |  18 +--
 arch/x86/oprofile/backtrace.c     |   3 +-
 include/linux/bpf.h               |   1 +
 include/linux/perf_event.h        |  13 ++-
 include/uapi/linux/bpf.h          |  21 ++++
 kernel/bpf/Makefile               |   3 +
 kernel/bpf/stackmap.c             | 237 ++++++++++++++++++++++++++++++++++++++
 kernel/bpf/verifier.c             |   6 +-
 kernel/events/callchain.c         |  32 +++--
 kernel/events/internal.h          |   2 -
 kernel/trace/bpf_trace.c          |   2 +
 samples/bpf/Makefile              |   4 +
 samples/bpf/bpf_helpers.h         |   2 +
 samples/bpf/offwaketime_kern.c    | 131 +++++++++++++++++++++
 samples/bpf/offwaketime_user.c    | 185 +++++++++++++++++++++++++++++
 18 files changed, 642 insertions(+), 30 deletions(-)
 create mode 100644 kernel/bpf/stackmap.c
 create mode 100644 samples/bpf/offwaketime_kern.c
 create mode 100644 samples/bpf/offwaketime_user.c

-- 
2.4.6
