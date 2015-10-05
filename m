From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 0/2] bpf: unprivileged
Date: Mon,  5 Oct 2015 13:48:19 -0700
Message-ID: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
Cc: Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Alexei Starovoitov (2):
  bpf: enable non-root eBPF programs
  bpf: charge user for creation of BPF maps and programs

 include/linux/bpf.h         |    6 ++
 include/linux/sched.h       |    2 +-
 kernel/bpf/arraymap.c       |    2 +-
 kernel/bpf/hashtab.c        |    4 +
 kernel/bpf/syscall.c        |   74 +++++++++++++-
 kernel/bpf/verifier.c       |  114 +++++++++++++++++++--
 kernel/sysctl.c             |   10 ++
 kernel/trace/bpf_trace.c    |    3 +
 samples/bpf/libbpf.h        |    8 ++
 samples/bpf/test_verifier.c |  239 ++++++++++++++++++++++++++++++++++++++++++-
 10 files changed, 443 insertions(+), 19 deletions(-)

-- 
1.7.9.5
