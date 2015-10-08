From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v2 net-next 0/3] bpf: unprivileged
Date: Wed,  7 Oct 2015 22:23:20 -0700
Message-ID: <1444281803-24274-1-git-send-email-ast@plumgrid.com>
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

v1-v2:
- this set logically depends on cb patch
  "bpf: fix cb access in socket filter programs":
  http://patchwork.ozlabs.org/patch/527391/
  which is must have to allow unprivileged programs.
  Thanks Daniel for finding that issue.
- refactored sysctl to be similar to 'modules_disabled'
- dropped bpf_trace_printk
- split tests into separate patch and added more tests
  based on discussion

v1 cover letter:
I think it is time to liberate eBPF from CAP_SYS_ADMIN.
As was discussed when eBPF was first introduced two years ago
the only piece missing in eBPF verifier is 'pointer leak detection'
to make it available to non-root users.
Patch 1 adds this pointer analysis.
The eBPF programs, obviously, need to see and operate on kernel addresses,
but with these extra checks they won't be able to pass these addresses
to user space.
Patch 2 adds accounting of kernel memory used by programs and maps.
It changes behavoir for existing root users, but I think it needs
to be done consistently for both root and non-root, since today
programs and maps are only limited by number of open FDs (RLIMIT_NOFILE).
Patch 2 accounts program's and map's kernel memory as RLIMIT_MEMLOCK.

Unprivileged eBPF is only meaningful for 'socket filter'-like programs.
eBPF programs for tracing and TC classifiers/actions will stay root only.

In parallel the bpf fuzzing effort is ongoing and so far
we've found only one verifier bug and that was already fixed.
The 'constant blinding' pass also being worked on.
It will obfuscate constant-like values that are part of eBPF ISA
to make jit spraying attacks even harder.

Alexei Starovoitov (3):
  bpf: enable non-root eBPF programs
  bpf: charge user for creation of BPF maps and programs
  bpf: add unprivileged bpf tests

 include/linux/bpf.h         |    5 +
 include/linux/sched.h       |    2 +-
 kernel/bpf/arraymap.c       |    2 +-
 kernel/bpf/hashtab.c        |    4 +
 kernel/bpf/syscall.c        |   74 ++++++++-
 kernel/bpf/verifier.c       |  106 +++++++++++--
 kernel/sysctl.c             |   13 ++
 net/core/filter.c           |    3 +-
 samples/bpf/libbpf.h        |    8 +
 samples/bpf/test_verifier.c |  357 +++++++++++++++++++++++++++++++++++++++++--
 10 files changed, 547 insertions(+), 27 deletions(-)

-- 
1.7.9.5
