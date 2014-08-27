From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v8 net-next 0/2] load imm64 insn and uapi/linux/bpf.h
Date: Wed, 27 Aug 2014 13:37:11 -0700
Message-ID: <1409171833-6979-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

I've been thinking on the minimum first patch set.
Came up with the following two:

1st patch adds 'load 64-bit immediate' instruction which by itself
is harmless and used to load constants only. In the future we may
add pseudo variants of this insn, so user space can request
internal kernel pointer. More detailed explanation in the commit log.

2nd patch exposed eBPF ISA to user space. It moves 55 lines from
filter.h into uapi/linux/bpf.h
Though there is no way currently to load eBPF programs from user
space, this patch shows the intent that eventually it will be possible.
The main goal here is to unblock LLVM upstreaming process.
Once these two are in, I can start posting LLVM RFCs to llvmdev list
and getting compiler bits in, so by the time bpf syscall and verifier
are in, we may have LLVM backend upstreamed as well.
LLVM wouldn't care what eBPF is used for, whether syscall is used
or some other mechanism. It just compiles C into eBPF ISA.
So these two patches are sufficient to start LLVM upstreaming.

All,
why do we need all of these?
Same reason why we're still using classic BPF and keep trying to extend it.
There are places in kernel where safe dynamic programs are mandatory.
network traffic capture needs in-kernel filtering,
seccomp needs safe mini programs to sandbox applications,
tracing needs them to filter events and so on.

Few LWN articles that explain things way better than my commit logs:
http://lwn.net/Articles/599755/
http://lwn.net/Articles/603983/
http://lwn.net/Articles/606089/
http://lwn.net/Articles/575531/

The first target for eBPF is to have dtrace equivalent that can be
used in _production_. Safety of programs is paramount.
Just like performance. eBPF programs in tracing should not affect 
performance of production severs, so huge effort on optimizing last bit.

ebpf+tracing, ebpf+seccomp, ebpf+sockets are the most obvious use cases.
ebpf+ovs is the one we use in large kvm hypervisors.
40Gbps of traffic are going through these programs, so performance
and safety are vital. Performance implications ruling out run-time checks
in critical path, so verifier is large mainly because it needs to do
all the checks during static analysis.

I think next patch set will include syscall shell with minimal functionality,
syscall doc and simple test.

Alexei Starovoitov (2):
  net: filter: add "load 64-bit immediate" eBPF instruction
  net: filter: split filter.h and expose eBPF to user space

 Documentation/networking/filter.txt |    8 +++-
 arch/x86/net/bpf_jit_comp.c         |   17 ++++++++
 include/linux/filter.h              |   74 +++++++++--------------------------
 include/uapi/linux/Kbuild           |    1 +
 include/uapi/linux/bpf.h            |   65 ++++++++++++++++++++++++++++++
 kernel/bpf/core.c                   |    5 +++
 lib/test_bpf.c                      |   21 ++++++++++
 7 files changed, 135 insertions(+), 56 deletions(-)
 create mode 100644 include/uapi/linux/bpf.h

-- 
1.7.9.5
