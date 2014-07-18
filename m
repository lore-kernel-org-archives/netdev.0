From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH RFC v2 net-next 00/16] BPF syscall, maps, verifier, samples
Date: Thu, 17 Jul 2014 21:19:50 -0700
Message-ID: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi All,

changes V1->V2:
- got rid of global id, everything now FD based (Thanks Andy!)
- split type enum in verifier (as suggested by Andy and Namhyung)
- switched gpl enforcement to be kmod like (as suggested by Andy and David)
- addressed feedback from Namhyung, Chema, Joe
- added more comments to verifier
- renamed sock_filter_int -> bpf_insn
- rebased on net-next

FD approach made eBPF user interface much cleaner for sockets/seccomp/tracing
use cases. Now socket and tracing examples (patch 15 and 16) can be Ctrl-C in
the middle and kernel will auto cleanup everything including tracing filters.
Small downside is eBPF programs need to include 'map fixup' section to use maps,
which is similar to traditional elf relocation sections, but much simpler.

First 11 patches are eBPF core which I think is ready for prime time.

Patch 12 (sockets+bpf) is very useful already and it's trivial to expose more
features for sockets in the future (like packet rewrite or calling flow_dissect)

Patch 13 (tracing+bpf) needs more work to become dtrace like. It's a first step

Todo:
- manpage for new syscall
- detect and reject address leaking in non-root programs

----

Fixed V1 cover letter:

'maps' is a generic storage of different types for sharing data between kernel
and userspace. Maps are referrenced by file descriptor. Root process can create
multiple maps of different types where key/value are opaque bytes of data.
It's up to user space and eBPF program to decide what they store in the maps.

eBPF programs are similar to kernel modules. They are loaded by the user space
program and unload on closing of fd. Each program is a safe run-to-completion
set of instructions. eBPF verifier statically determines that the program
terminates and safe to execute. During verification the program takes a hold of
maps that it intends to use, so selected maps cannot be removed until program is
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
part of this diff and will be upstreamed after this patchset is accepted)
Since eBPF is fully JITed on x64, the cost of running eBPF program is very
small even for high frequency events. Here are the numbers comparing
flow_dissector in C vs eBPF:
  x86_64 skb_flow_dissect() same skb (all cached)         -  42 nsec per call
  x86_64 skb_flow_dissect() different skbs (cache misses) - 141 nsec per call
eBPF+jit skb_flow_dissect() same skb (all cached)         -  51 nsec per call
eBPF+jit skb_flow_dissect() different skbs (cache misses) - 135 nsec per call

Thanks
Alexei

------
The following changes since commit da388973d4a15e71cada1219d625b5393c90e5ae:

  iw_cxgb4: fix for 64-bit integer division (2014-07-17 16:52:08 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/ast/bpf master

for you to fetch changes up to e8c12b5d78f612a7651db9648c45999bd6fd3c1c:

  samples: bpf: example of tracing filters with eBPF (2014-07-17 20:08:17 -0700)

----------------------------------------------------------------
Alexei Starovoitov (16):
      net: filter: split filter.c into two files
      bpf: update MAINTAINERS entry
      net: filter: rename struct sock_filter_int into bpf_insn
      net: filter: split filter.h and expose eBPF to user space
      bpf: introduce syscall(BPF, ...) and BPF maps
      bpf: enable bpf syscall on x64
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
 MAINTAINERS                            |    7 +
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
 arch/x86/net/bpf_jit_comp.c            |    2 +-
 arch/x86/syscalls/syscall_64.tbl       |    1 +
 arch/xtensa/include/uapi/asm/socket.h  |    2 +
 include/linux/bpf.h                    |  136 +++
 include/linux/filter.h                 |  310 +------
 include/linux/ftrace_event.h           |    5 +
 include/linux/syscalls.h               |    2 +
 include/trace/bpf_trace.h              |   29 +
 include/trace/ftrace.h                 |   10 +
 include/uapi/asm-generic/socket.h      |    2 +
 include/uapi/asm-generic/unistd.h      |    4 +-
 include/uapi/linux/Kbuild              |    1 +
 include/uapi/linux/bpf.h               |  391 ++++++++
 kernel/Makefile                        |    1 +
 kernel/bpf/Makefile                    |    1 +
 kernel/bpf/core.c                      |  539 +++++++++++
 kernel/bpf/hashtab.c                   |  371 ++++++++
 kernel/bpf/syscall.c                   |  828 +++++++++++++++++
 kernel/bpf/verifier.c                  | 1520 ++++++++++++++++++++++++++++++++
 kernel/seccomp.c                       |    2 +-
 kernel/sys_ni.c                        |    3 +
 kernel/trace/Kconfig                   |    1 +
 kernel/trace/Makefile                  |    1 +
 kernel/trace/bpf_trace.c               |  212 +++++
 kernel/trace/trace.h                   |    3 +
 kernel/trace/trace_events.c            |   36 +-
 kernel/trace/trace_events_filter.c     |   72 +-
 lib/test_bpf.c                         |    4 +-
 net/core/filter.c                      |  650 +++-----------
 net/core/sock.c                        |   13 +
 samples/bpf/.gitignore                 |    1 +
 samples/bpf/Makefile                   |   15 +
 samples/bpf/dropmon.c                  |  134 +++
 samples/bpf/libbpf.c                   |  109 +++
 samples/bpf/libbpf.h                   |   22 +
 samples/bpf/sock_example.c             |  161 ++++
 50 files changed, 5099 insertions(+), 828 deletions(-)
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
