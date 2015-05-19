From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 0/4] bpf: introduce bpf_tail_call() helper
Date: Tue, 19 May 2015 16:59:02 -0700
Message-ID: <1432079946-9878-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Zi Shen Lim <zlim.lnx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

introduce bpf_tail_call(ctx, &jmp_table, index) helper function
which can be used from BPF programs like:
int bpf_prog(struct pt_regs *ctx)
{
  ...
  bpf_tail_call(ctx, &jmp_table, index);
  ...
}
that is roughly equivalent to:
int bpf_prog(struct pt_regs *ctx)
{
  ...
  if (jmp_table[index])
    return (*jmp_table[index])(ctx);
  ...
}
The important detail that it's not a normal call, but a tail call.
The kernel stack is precious, so this helper reuses the current
stack frame and jumps into another BPF program without adding
extra call frame.
It's trivially done in interpreter and a bit trickier in JITs.

Use cases:
- simplify complex programs
- dispatch into other programs
  (for example: index in jump table can be syscall number or network protocol)
- build dynamic chains of programs

The chain of tail calls can form unpredictable dynamic loops therefore
tail_call_cnt is used to limit the number of calls and currently is set to 32.

patch 1 - support bpf_tail_call() in interpreter
patch 2 - support in x64 JIT
We've discussed what's neccessary to support it in arm64/s390 JITs
and it looks fine.
patch 3 - sample example for tracing
patch 4 - sample example for networking

More details in every patch.

This set went through several iterations of reviews/fixes and older
attempts can be seen:
https://git.kernel.org/cgit/linux/kernel/git/ast/bpf.git/log/?h=tail_call_v[123456]
- tail_call_v1 does it without touching JITs but introduces overhead
  for all programs that don't use this helper function.
- tail_call_v2 still has some overhead and x64 JIT does full stack
  unwind (prologue skipping optimization wasn't there)
- tail_call_v3 reuses 'call' instruction encoding and has interpreter
  overhead for every normal call
- tail_call_v4 fixes above architectural shortcomings and v5,v6 fix few
  more bugs

This last tail_call_v6 approach seems to be the best.

Alexei Starovoitov (4):
  bpf: allow bpf programs to tail-call other bpf programs
  x86: bpf_jit: implement bpf_tail_call() helper
  samples/bpf: bpf_tail_call example for tracing
  samples/bpf: bpf_tail_call example for networking

 arch/x86/net/bpf_jit_comp.c |  150 +++++++++++++++++----
 include/linux/bpf.h         |   22 ++++
 include/linux/filter.h      |    2 +-
 include/uapi/linux/bpf.h    |   10 ++
 kernel/bpf/arraymap.c       |  113 +++++++++++++++-
 kernel/bpf/core.c           |   73 ++++++++++-
 kernel/bpf/syscall.c        |   23 +++-
 kernel/bpf/verifier.c       |   17 +++
 kernel/trace/bpf_trace.c    |    2 +
 net/core/filter.c           |    2 +
 samples/bpf/Makefile        |    8 ++
 samples/bpf/bpf_helpers.h   |    4 +
 samples/bpf/bpf_load.c      |   57 ++++++--
 samples/bpf/sockex3_kern.c  |  303 +++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/sockex3_user.c  |   66 ++++++++++
 samples/bpf/tracex5_kern.c  |   75 +++++++++++
 samples/bpf/tracex5_user.c  |   46 +++++++
 17 files changed, 928 insertions(+), 45 deletions(-)
 create mode 100644 samples/bpf/sockex3_kern.c
 create mode 100644 samples/bpf/sockex3_user.c
 create mode 100644 samples/bpf/tracex5_kern.c
 create mode 100644 samples/bpf/tracex5_user.c

-- 
1.7.9.5
