From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v5 net-next 00/29] BPF syscall, maps, verifier, samples, llvm
Date: Sun, 24 Aug 2014 13:21:01 -0700
Message-ID: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
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

Hi All,

enough RFCs, let's finalize it...

Andy, Kees, please take a look at verifier and syscall API once again.
I hope I addressed all of your comments.

Peter, I played with 'lea [%rip+off]' tricks in JIT as suggested by Andy, but
there was no performance gain and JIT main loop got quite complicated, so
I left it as-is with movabsq. I hope you're ok for now. Let's revisit it later.

Steven, Namhyung, please review the way it attaches to tracing
(tracepoint, syscalls, kprobe)

Brendan, I've added example#3 which is heavily influenced by your heatmap graphs
and ACM paper. It measures disk IO latency and prints heatmap in text terminal
using shades of gray. Looks cool. I've wasted a day trying to make heatmap
be as fancy as on your slides, but I guess my SSDs are too predicatable :)

Fully tested on x64 and i386.
Build/boot tested on arm/sparc with NET and NET-less configs.
(There are warning regarding unimplemented syscall, of course)

V4->V5:
- while playing with tracing examples Brendan noticed that x64 JIT missed
  'shift by register' support. fixed and added to testsuite (patch 0001)
- fixed BPF_LD_IMM64 encoding (as suggested by Andy) (patch 0002)
  and added verifier tests for this insn (patch 0024)
- enabled bpf syscall on i386 as well (patch 0005)
- added more comments to verifier around bounds checking,
  since the logic was confusing to Kees earlier (patch 0014)
- split eBPF out of NET via hidden CONFIG_BPF (patch 0017)
- added bpf_ktime_get_ns() and tracing example#3 (as suggested by Brendan)
  (patch 0021 and 0029)
- added a bunch more verifier tests. 42 tests so far (patch 0024)
- dropped ebpf+sockets patch and examples, there was not enough public
  discussions on it whereas ebpf+tracing got a lot of mileage

I still owe Brendan better strings support and map[stack()]++ so that
'flame graphs' can work :)
Right now I'd like to focus on getting the current set in, since it's
very useful for performance analysis already.

Steven, if you don't like access to trace_printk() from eBPF programs,
I can drop patch 0019 for now, but we'd need to think of a way to print
things from programs and trace_printk() looks like the best fit.

Netdev folks, this patch doesn't affect any networking bits, but
obviously I would like to apply the technology in the networking space.
Where and how, is tbd. We're still discussing ovs+bpf.

All, most of the diff is LLVM backend (patch 0025), I think it makes
sense to keep it in kernel tree for now. Once backend is upstreamed
we can remove it from here.

IMO this is pretty solid base for all sorts of things.

previous V4 discussion:
https://lkml.org/lkml/2014/8/13/111

V3->V4:
- introduced 'load 64-bit immediate' eBPF instruction
- use BPF_LD_IMM64 in LLVM, verifier, programs
- got rid of 'fixup' section in eBPF programs
- got rid of map IDR and internal map_id
- split verifier into 6 patches and added verifier testsuite
- add verifier check for reserved instruction fields
- fixed bug in LLVM eBPF backend (it was miscompiling __builtin_expect)
- fixed race condition in htab_map_update_elem()
- tracing filters can now attach to tracepoint, syscall, kprobe events
- improved C examples 

V2->V3:
- fixed verifier register range bug and addressed other comments (Thanks Kees!)
- re-added LLVM eBPF backend
- added two examples in C
- user space ELF parser and loader example

V1->V2:
- got rid of global id, everything now FD based (Thanks Andy!)
- split type enum in verifier (as suggested by Andy and Namhyung)
- switched gpl enforcement to be kmod like (as suggested by Andy and David)
- addressed feedback from Namhyung, Chema, Joe
- added more comments to verifier
- renamed sock_filter_int -> bpf_insn
- rebased on net-next

As always all patches are available at:

  git://git.kernel.org/pub/scm/linux/kernel/git/ast/bpf master

------

Alexei Starovoitov (29):
  bpf: x86: add missing 'shift by register' instructions to x64 eBPF
    JIT
  net: filter: add "load 64-bit immediate" eBPF instruction
  net: filter: split filter.h and expose eBPF to user space
  bpf: introduce syscall(BPF, ...) and BPF maps
  bpf: enable bpf syscall on x64 and i386
  bpf: add lookup/update/delete/iterate methods to BPF maps
  bpf: add hashtable type of BPF maps
  bpf: expand BPF syscall with program load/unload
  bpf: handle pseudo BPF_CALL insn
  bpf: verifier (add docs)
  bpf: verifier (add ability to receive verification log)
  bpf: handle pseudo BPF_LD_IMM64 insn
  bpf: verifier (add branch/goto checks)
  bpf: verifier (add verifier core)
  bpf: verifier (add state prunning optimization)
  bpf: allow eBPF programs to use maps
  bpf: split eBPF out of NET
  tracing: allow eBPF programs to be attached to events
  tracing: allow eBPF programs call printk()
  tracing: allow eBPF programs to be attached to kprobe/kretprobe
  tracing: allow eBPF programs to call ktime_get_ns() and get_current()
  samples: bpf: add mini eBPF library to manipulate maps and programs
  samples: bpf: example of tracing filters with eBPF
  bpf: verifier test
  bpf: llvm backend
  samples: bpf: elf file loader
  samples: bpf: eBPF example in C
  samples: bpf: counting eBPF example in C
  samples: bpf: IO latency analysis (iosnoop/heatmap)

 Documentation/networking/filter.txt                |  309 +++-
 arch/Kconfig                                       |    4 +
 arch/x86/net/bpf_jit_comp.c                        |   59 +
 arch/x86/syscalls/syscall_32.tbl                   |    1 +
 arch/x86/syscalls/syscall_64.tbl                   |    1 +
 fs/btrfs/super.c                                   |    3 +
 include/linux/bpf.h                                |  140 ++
 include/linux/filter.h                             |  303 +---
 include/linux/ftrace_event.h                       |    5 +
 include/linux/syscalls.h                           |    3 +-
 include/trace/bpf_trace.h                          |   23 +
 include/trace/ftrace.h                             |   25 +
 include/uapi/asm-generic/unistd.h                  |    4 +-
 include/uapi/linux/Kbuild                          |    1 +
 include/uapi/linux/bpf.h                           |  424 +++++
 kernel/Makefile                                    |    2 +-
 kernel/bpf/Makefile                                |    2 +-
 kernel/bpf/core.c                                  |   17 +
 kernel/bpf/hashtab.c                               |  372 ++++
 kernel/bpf/syscall.c                               |  658 +++++++
 kernel/bpf/verifier.c                              | 1911 ++++++++++++++++++++
 kernel/sys_ni.c                                    |    3 +
 kernel/trace/Kconfig                               |    1 +
 kernel/trace/Makefile                              |    1 +
 kernel/trace/bpf_trace.c                           |  264 +++
 kernel/trace/trace.h                               |    3 +
 kernel/trace/trace_events.c                        |   41 +-
 kernel/trace/trace_events_filter.c                 |   72 +-
 kernel/trace/trace_kprobe.c                        |   28 +
 kernel/trace/trace_syscalls.c                      |   32 +
 lib/test_bpf.c                                     |   59 +
 net/Kconfig                                        |    1 +
 net/core/filter.c                                  |    2 +
 samples/bpf/Makefile                               |   28 +
 samples/bpf/bpf_helpers.h                          |   27 +
 samples/bpf/bpf_load.c                             |  234 +++
 samples/bpf/bpf_load.h                             |   26 +
 samples/bpf/dropmon.c                              |  122 ++
 samples/bpf/ex1_kern.c                             |   27 +
 samples/bpf/ex1_user.c                             |   24 +
 samples/bpf/ex2_kern.c                             |   73 +
 samples/bpf/ex2_user.c                             |   94 +
 samples/bpf/ex3_kern.c                             |  104 ++
 samples/bpf/ex3_user.c                             |  149 ++
 samples/bpf/libbpf.c                               |  138 ++
 samples/bpf/libbpf.h                               |   21 +
 samples/bpf/test_verifier.c                        |  599 ++++++
 tools/bpf/llvm/.gitignore                          |   54 +
 tools/bpf/llvm/LICENSE.TXT                         |   70 +
 tools/bpf/llvm/Makefile.rules                      |  641 +++++++
 tools/bpf/llvm/README.txt                          |   23 +
 tools/bpf/llvm/bld/Makefile                        |   27 +
 tools/bpf/llvm/bld/Makefile.common                 |   14 +
 tools/bpf/llvm/bld/Makefile.config                 |  124 ++
 .../llvm/bld/include/llvm/Config/AsmParsers.def    |    8 +
 .../llvm/bld/include/llvm/Config/AsmPrinters.def   |    9 +
 .../llvm/bld/include/llvm/Config/Disassemblers.def |    8 +
 tools/bpf/llvm/bld/include/llvm/Config/Targets.def |    9 +
 .../bpf/llvm/bld/include/llvm/Support/DataTypes.h  |   96 +
 tools/bpf/llvm/bld/lib/Makefile                    |   11 +
 .../llvm/bld/lib/Target/BPF/InstPrinter/Makefile   |   10 +
 .../llvm/bld/lib/Target/BPF/MCTargetDesc/Makefile  |   11 +
 tools/bpf/llvm/bld/lib/Target/BPF/Makefile         |   17 +
 .../llvm/bld/lib/Target/BPF/TargetInfo/Makefile    |   10 +
 tools/bpf/llvm/bld/lib/Target/Makefile             |   11 +
 tools/bpf/llvm/bld/tools/Makefile                  |   12 +
 tools/bpf/llvm/bld/tools/llc/Makefile              |   15 +
 tools/bpf/llvm/lib/Target/BPF/BPF.h                |   28 +
 tools/bpf/llvm/lib/Target/BPF/BPF.td               |   29 +
 tools/bpf/llvm/lib/Target/BPF/BPFAsmPrinter.cpp    |  100 +
 tools/bpf/llvm/lib/Target/BPF/BPFCallingConv.td    |   24 +
 tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.cpp |   36 +
 tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.h   |   35 +
 tools/bpf/llvm/lib/Target/BPF/BPFISelDAGToDAG.cpp  |  182 ++
 tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.cpp  |  683 +++++++
 tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.h    |  105 ++
 tools/bpf/llvm/lib/Target/BPF/BPFInstrFormats.td   |   29 +
 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.cpp     |  162 ++
 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.h       |   53 +
 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.td      |  498 +++++
 tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.cpp   |   77 +
 tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.h     |   40 +
 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.cpp  |  122 ++
 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.h    |   65 +
 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.td   |   39 +
 tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.cpp     |   23 +
 tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.h       |   33 +
 tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.cpp |   66 +
 tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.h   |   69 +
 .../lib/Target/BPF/InstPrinter/BPFInstPrinter.cpp  |   81 +
 .../lib/Target/BPF/InstPrinter/BPFInstPrinter.h    |   34 +
 .../lib/Target/BPF/MCTargetDesc/BPFAsmBackend.cpp  |   89 +
 .../llvm/lib/Target/BPF/MCTargetDesc/BPFBaseInfo.h |   33 +
 .../Target/BPF/MCTargetDesc/BPFELFObjectWriter.cpp |   56 +
 .../lib/Target/BPF/MCTargetDesc/BPFMCAsmInfo.h     |   34 +
 .../Target/BPF/MCTargetDesc/BPFMCCodeEmitter.cpp   |  167 ++
 .../Target/BPF/MCTargetDesc/BPFMCTargetDesc.cpp    |  115 ++
 .../lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.h  |   56 +
 .../lib/Target/BPF/TargetInfo/BPFTargetInfo.cpp    |   13 +
 tools/bpf/llvm/tools/llc/llc.cpp                   |  381 ++++
 100 files changed, 10875 insertions(+), 302 deletions(-)
 create mode 100644 include/linux/bpf.h
 create mode 100644 include/trace/bpf_trace.h
 create mode 100644 include/uapi/linux/bpf.h
 create mode 100644 kernel/bpf/hashtab.c
 create mode 100644 kernel/bpf/syscall.c
 create mode 100644 kernel/bpf/verifier.c
 create mode 100644 kernel/trace/bpf_trace.c
 create mode 100644 samples/bpf/Makefile
 create mode 100644 samples/bpf/bpf_helpers.h
 create mode 100644 samples/bpf/bpf_load.c
 create mode 100644 samples/bpf/bpf_load.h
 create mode 100644 samples/bpf/dropmon.c
 create mode 100644 samples/bpf/ex1_kern.c
 create mode 100644 samples/bpf/ex1_user.c
 create mode 100644 samples/bpf/ex2_kern.c
 create mode 100644 samples/bpf/ex2_user.c
 create mode 100644 samples/bpf/ex3_kern.c
 create mode 100644 samples/bpf/ex3_user.c
 create mode 100644 samples/bpf/libbpf.c
 create mode 100644 samples/bpf/libbpf.h
 create mode 100644 samples/bpf/test_verifier.c
 create mode 100644 tools/bpf/llvm/.gitignore
 create mode 100644 tools/bpf/llvm/LICENSE.TXT
 create mode 100644 tools/bpf/llvm/Makefile.rules
 create mode 100644 tools/bpf/llvm/README.txt
 create mode 100644 tools/bpf/llvm/bld/Makefile
 create mode 100644 tools/bpf/llvm/bld/Makefile.common
 create mode 100644 tools/bpf/llvm/bld/Makefile.config
 create mode 100644 tools/bpf/llvm/bld/include/llvm/Config/AsmParsers.def
 create mode 100644 tools/bpf/llvm/bld/include/llvm/Config/AsmPrinters.def
 create mode 100644 tools/bpf/llvm/bld/include/llvm/Config/Disassemblers.def
 create mode 100644 tools/bpf/llvm/bld/include/llvm/Config/Targets.def
 create mode 100644 tools/bpf/llvm/bld/include/llvm/Support/DataTypes.h
 create mode 100644 tools/bpf/llvm/bld/lib/Makefile
 create mode 100644 tools/bpf/llvm/bld/lib/Target/BPF/InstPrinter/Makefile
 create mode 100644 tools/bpf/llvm/bld/lib/Target/BPF/MCTargetDesc/Makefile
 create mode 100644 tools/bpf/llvm/bld/lib/Target/BPF/Makefile
 create mode 100644 tools/bpf/llvm/bld/lib/Target/BPF/TargetInfo/Makefile
 create mode 100644 tools/bpf/llvm/bld/lib/Target/Makefile
 create mode 100644 tools/bpf/llvm/bld/tools/Makefile
 create mode 100644 tools/bpf/llvm/bld/tools/llc/Makefile
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPF.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPF.td
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFAsmPrinter.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFCallingConv.td
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFISelDAGToDAG.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFInstrFormats.td
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.td
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.td
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/InstPrinter/BPFInstPrinter.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/InstPrinter/BPFInstPrinter.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFAsmBackend.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFBaseInfo.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFELFObjectWriter.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCAsmInfo.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCCodeEmitter.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/TargetInfo/BPFTargetInfo.cpp
 create mode 100644 tools/bpf/llvm/tools/llc/llc.cpp

-- 
1.7.9.5
