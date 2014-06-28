From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC net-next 00/14] BPF syscall, maps, verifier, samples
Date: Fri, 27 Jun 2014 17:05:52 -0700
Message-ID: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

this patch set demonstrates the potential of eBPF.

First patch "net: filter: split filter.c into two files" splits eBPF interpreter
out of networking into kernel/bpf/. The goal for BPF subsystem is to be usable
in NET-less configuration. Though the whole set is marked is RFC, the 1st patch
is good to go. Similar version of the patch that was posted few weeks ago, but
was deferred. I'm assuming due to lack of forward visibility. I hope that this
patch set shows what eBPF is capable of and where it's heading.

Other patches expose eBPF instruction set to user space and introduce concepts
of maps and programs accessible via syscall.

'maps' is a generic storage of different types for sharing data between kernel
and userspace. Maps are referrenced by global id. Root can create multiple
maps of different types where key/value are opaque bytes of data. It's up to
user space and eBPF program to decide what they store in the maps.

eBPF programs are similar to kernel modules. They live in global space and
have unique prog_id. Each program is a safe run-to-completion set of
instructions. eBPF verifier statically determines that the program terminates
and safe to execute. During verification the program takes a hold of maps
that it intends to use, so selected maps cannot be removed until program is
unloaded. The program can be attached to different events. These events can
be packets, tracepoint events and other types in the future. New event triggers
execution of the program which may store information about the event in the maps.
Beyond storing data the programs may call into in-kernel helper functions
which may, for example, dump stack, do trace_printk or other forms of live
kernel debugging. Same program can be attached to multiple events. Different
programs can access the same map:

  tracepoint  tracepoint  tracepoint    sk_buff    sk_buff
   event A     event B     event C      on eth0    on eth1
    |             |          |            |          |
    |             |          |            |          |
    --> tracing <--      tracing       socket      socket
         prog_1           prog_2       prog_3      prog_4
         |  |               |            |
      |---  -----|  |-------|           map_3
    map_1       map_2

User space (via syscall) and eBPF programs access maps concurrently.

Last two patches are sample code. 1st demonstrates stateful packet inspection.
It counts tcp and udp packets on eth0. Should be easy to see how this eBPF
framework can be used for network analytics.
2nd sample does simple 'drop monitor'. It attaches to kfree_skb tracepoint
event and counts number of packet drops at particular $pc location.
User space periodically summarizes what eBPF programs recorded.
In these two samples the eBPF programs are tiny and written in 'assembler'
with macroses. More complex programs can be written C (llvm backend is not
part of this diff to reduce 'huge' perception).
Since eBPF is fully JITed on x64, the cost of running eBPF program is very
small even for high frequency events. Here are the numbers comparing
flow_dissector in C vs eBPF:
  x86_64 skb_flow_dissect() same skb (all cached)         -  42 nsec per call
  x86_64 skb_flow_dissect() different skbs (cache misses) - 141 nsec per call
eBPF+jit skb_flow_dissect() same skb (all cached)         -  51 nsec per call
eBPF+jit skb_flow_dissect() different skbs (cache misses) - 135 nsec per call

Detailed explanation on eBPF verifier and safety is in patch 08/14

Thanks
Alexei

minor todo: rename 'struct sock_filter_int' into 'struct bpf_insn'. It's not
part of this diff to reduce size.
  
------

The following changes since commit c1c27fb9b3040a2559d4d3e1183afa8c106bc94a:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next (2014-06-27 12:59:38 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/ast/bpf master

for you to fetch changes up to 4c8da0f21220087e38894c69339cddc64c1220f9:

  samples: bpf: example of tracing filters with eBPF (2014-06-27 15:22:07 -0700)

----------------------------------------------------------------
Alexei Starovoitov (14):
      net: filter: split filter.c into two files
      net: filter: split filter.h and expose eBPF to user space
      bpf: introduce syscall(BPF, ...) and BPF maps
      bpf: update MAINTAINERS entry
      bpf: add lookup/update/delete/iterate methods to BPF maps
      bpf: add hashtable type of BPF maps
      bpf: expand BPF syscall with program load/unload
      bpf: add eBPF verifier
      bpf: allow eBPF programs to use maps
      net: sock: allow eBPF programs to be attached to sockets
      tracing: allow eBPF programs to be attached to events
      samples: bpf: add mini eBPF library to manipulate maps and programs
      samples: bpf: example of stateful socket filtering
      samples: bpf: example of tracing filters with eBPF

 Documentation/networking/filter.txt    |  302 +++++++
 MAINTAINERS                            |    9 +
 arch/alpha/include/uapi/asm/socket.h   |    2 +
 arch/avr32/include/uapi/asm/socket.h   |    2 +
 arch/cris/include/uapi/asm/socket.h    |    2 +
 arch/frv/include/uapi/asm/socket.h     |    2 +
 arch/ia64/include/uapi/asm/socket.h    |    2 +
 arch/m32r/include/uapi/asm/socket.h    |    2 +
 arch/mips/include/uapi/asm/socket.h    |    2 +
 arch/mn10300/include/uapi/asm/socket.h |    2 +
 arch/parisc/include/uapi/asm/socket.h  |    2 +
 arch/powerpc/include/uapi/asm/socket.h |    2 +
 arch/s390/include/uapi/asm/socket.h    |    2 +
 arch/sparc/include/uapi/asm/socket.h   |    2 +
 arch/x86/syscalls/syscall_64.tbl       |    1 +
 arch/xtensa/include/uapi/asm/socket.h  |    2 +
 include/linux/bpf.h                    |  135 +++
 include/linux/filter.h                 |  304 +------
 include/linux/ftrace_event.h           |    5 +
 include/linux/syscalls.h               |    2 +
 include/trace/bpf_trace.h              |   29 +
 include/trace/ftrace.h                 |   10 +
 include/uapi/asm-generic/socket.h      |    2 +
 include/uapi/asm-generic/unistd.h      |    4 +-
 include/uapi/linux/Kbuild              |    1 +
 include/uapi/linux/bpf.h               |  403 +++++++++
 kernel/Makefile                        |    1 +
 kernel/bpf/Makefile                    |    1 +
 kernel/bpf/core.c                      |  548 ++++++++++++
 kernel/bpf/hashtab.c                   |  371 +++++++++
 kernel/bpf/syscall.c                   |  778 +++++++++++++++++
 kernel/bpf/verifier.c                  | 1431 ++++++++++++++++++++++++++++++++
 kernel/sys_ni.c                        |    3 +
 kernel/trace/Kconfig                   |    1 +
 kernel/trace/Makefile                  |    1 +
 kernel/trace/bpf_trace.c               |  217 +++++
 kernel/trace/trace.h                   |    3 +
 kernel/trace/trace_events.c            |    7 +
 kernel/trace/trace_events_filter.c     |   72 +-
 net/core/filter.c                      |  646 +++-----------
 net/core/sock.c                        |   13 +
 samples/bpf/.gitignore                 |    1 +
 samples/bpf/Makefile                   |   15 +
 samples/bpf/dropmon.c                  |  127 +++
 samples/bpf/libbpf.c                   |  114 +++
 samples/bpf/libbpf.h                   |   18 +
 samples/bpf/sock_example.c             |  160 ++++
 47 files changed, 4941 insertions(+), 820 deletions(-)
 create mode 100644 include/linux/bpf.h
 create mode 100644 include/trace/bpf_trace.h
 create mode 100644 include/uapi/linux/bpf.h
 create mode 100644 kernel/bpf/Makefile
 create mode 100644 kernel/bpf/core.c
 create mode 100644 kernel/bpf/hashtab.c
 create mode 100644 kernel/bpf/syscall.c
 create mode 100644 kernel/bpf/verifier.c
 create mode 100644 kernel/trace/bpf_trace.c
 create mode 100644 samples/bpf/.gitignore
 create mode 100644 samples/bpf/Makefile
 create mode 100644 samples/bpf/dropmon.c
 create mode 100644 samples/bpf/libbpf.c
 create mode 100644 samples/bpf/libbpf.h
 create mode 100644 samples/bpf/sock_example.c

-- 
1.7.9.5
