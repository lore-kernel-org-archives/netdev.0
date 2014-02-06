From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [RFC PATCH v2 tip 0/7] 64-bit BPF insn set and tracing filters
Date: Wed,  5 Feb 2014 17:10:39 -0800
Message-ID: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

this patch set addresses main sticking points of the previous discussion:
http://thread.gmane.org/gmane.linux.kernel/1605783

Main difference:
. all components are now in one place
  tools/bpf/llvm - standalone LLVM backend for extended BPF instruction set

. regs.si, regs.di accessors are replaced with arg1, arg2

. compiler enforces presence of 'license' string in source C code
  kernel enforces GPL compatibility of BPF program

Why bother with it?
Current 32-bit BPF is safe, but limited.
kernel modules are 'all-goes', but not-safe.
Extended 64-bit BPF provides safe and restricted kernel modules.

Just like the first two, extended BPF can be used for all sorts of things.
Initially for tracing/debugging/[ks]tap-like without vmlinux around,
then for networking, security, etc

To make exising kernel modules safe the x86 disassembler and code analyzer
are needed. We've tried to follow that path. Disassembler was straight forward,
but x86 analyzer was becoming unbearably complex due to variety of addressing
modes, so we started to hack GCC to reduce output x86 insns and facing
the headache of redoing disasm/analyzer for arm and other arhcs.
Plus there is old 32-bit bpf insn set already.
On one side extended BPF is a 64-bit extension to current BPF.
On the other side it's a common subset of x86-64/aarch64/... ISAs:
a generic 64-bit insn set that can be JITed to native HW one to one.

Tested on x86-64 and i386.
BPF core was tested on arm-v7.

V2 vs V1 details:
0001-Extended-BPF-core-framework:
  no difference to instruction set
  new bpf image format to include license string and enforcement during load

0002-Extended-BPF-JIT-for-x86-64: no changes

0003-Extended-BPF-64-bit-BPF-design-document: no changes

0004-Revert-x86-ptrace-Remove-unused-regs_get_argument:
  restoring Masami's get_Nth_argument accessor to simplify kprobe filters

0005-use-BPF-in-tracing-filters: minor changes to switch from si/di to argN

0006-LLVM-BPF-backend: standalone BPF backend for LLVM
  requires: apt-get install llvm-3.2-dev clang
  compiles in 7 seconds, links with the rest of llvm infra
  compatible with llvm 3.2, 3.3 and just released 3.4
  Written in llvm coding style and llvm license, so it can be
  upstreamed into llvm tree

0007-tracing-filter-examples-in-BPF:
  tools/bpf/filter_check: userspace pre-checker of BPF filter
  runs the same bpf_check() code as kernel does

  tools/bpf/examples/netif_rcv.c:
-----
#define DESC(NAME) __attribute__((section(NAME), used))
void my_filter(struct bpf_context *ctx)
{
        char devname[4] = "lo";
        struct net_device *dev;
        struct sk_buff *skb = 0;

        /*
         * for tracepoints arg1 is the 1st arg of TP_ARGS() macro
         * defined in include/trace/events/.h
         * for kprobe events arg1 is the 1st arg of probed function
         */
        skb = (struct sk_buff *)ctx->arg1;

        dev = bpf_load_pointer(&skb->dev);
        if (bpf_memcmp(dev->name, devname, 2) == 0) {
                char fmt[] = "skb %p dev %p \n";
                bpf_trace_printk(fmt, sizeof(fmt), (long)skb, (long)dev, 0);
        }
}
/* filter code license: */
char license[] DESC("license") = "GPL";
-----

$cd tools/bpf/examples
$make
  compile it using clang+llvm_bpf
$make check
  check safety
$make try
  attach this filter to net:netif_receive_skb and kprobe __netif_receive_skb
  and try ping

dropmon.c is a demo of faster version of net_dropmonitor:
-----
/* attaches to /sys/kernel/debug/tracing/events/skb/kfree_skb */
void dropmon(struct bpf_context *ctx)
{
        void *loc;
        uint64_t *drop_cnt;

        /*
         * skb:kfree_skb is defined as:
         * TRACE_EVENT(kfree_skb,
         *         TP_PROTO(struct sk_buff *skb, void *location),
         * so ctx->arg2 is 'location'
         */
        loc = (void *)ctx->arg2;

        drop_cnt = bpf_table_lookup(ctx, 0, &loc);
        if (drop_cnt) {
                __sync_fetch_and_add(drop_cnt, 1);
        } else {
                uint64_t init = 0;
                bpf_table_update(ctx, 0, &loc, &init);
        }
}
struct bpf_table t[] DESC("bpftables") = {
        {BPF_TABLE_HASH, sizeof(void *), sizeof(uint64_t), 4096, 0}
};
/* filter code license: */
char l[] DESC("license") = "GPL v2";
-----
It's not fully functional yet. Minimal work remaining to implement
bpf_table_lookup()/bpf_table_update() in kernel
and userspace access to filter's table.

This example demonstrates that some interesting events don't have to be
always fed into userspace, but can be pre-processed in kernel.
tools/perf/scripts/python/net_dropmonitor.py would need to read bpf table
from kernel (via debugfs or netlink) and print it in a nice format.

Same as in V1 BPF filters are called before tracepoints store the TP_STRUCT
fields, since performance advantage is significant.

TODO:

- complete 'dropmonitor': finish bpf hashtable and userspace access to it

- add multi-probe support, so that one C program can specify multiple
  functions for different probe points (similar to [ks]tap)

- add 'lsmod' like facility to list all loaded BPF filters

- add -m32 flag to llvm, so that C pointers are 32-bit,
  but emitted BPF is still 64-bit.
  Useful for kernel struct walking in BPF program on 32-bit archs

- finish testing on arm

- teach llvm to store line numbers in BPF image, so that bpf_check()
  can print nice errors when program is not safe

- allow read-only "strings" in C code
  today analyzer can only verify safety of: char s[] = "string"; bpf_print(s);
  but bpf_print("string"); cannot be proven yet

- write JIT from BPF to aarch64

- refactor openvswitch + BPF proposal

If direction is ok, I would like to commit this part to a branch of tip tree
or staging tree and continue working there.
Future deltas will be easier to review.

Thanks

Alexei Starovoitov (7):
  Extended BPF core framework
  Extended BPF JIT for x86-64
  Extended BPF (64-bit BPF) design document
  Revert "x86/ptrace: Remove unused regs_get_argument_nth API"
  use BPF in tracing filters
  LLVM BPF backend
  tracing filter examples in BPF

 Documentation/bpf_jit.txt                          |  204 ++++
 arch/x86/Kconfig                                   |    1 +
 arch/x86/include/asm/ptrace.h                      |    3 +
 arch/x86/kernel/ptrace.c                           |   24 +
 arch/x86/net/Makefile                              |    1 +
 arch/x86/net/bpf64_jit_comp.c                      |  625 ++++++++++++
 arch/x86/net/bpf_jit_comp.c                        |   23 +-
 arch/x86/net/bpf_jit_comp.h                        |   35 +
 include/linux/bpf.h                                |  149 +++
 include/linux/bpf_jit.h                            |  134 +++
 include/linux/ftrace_event.h                       |    5 +
 include/trace/bpf_trace.h                          |   41 +
 include/trace/ftrace.h                             |   17 +
 kernel/Makefile                                    |    1 +
 kernel/bpf_jit/Makefile                            |    3 +
 kernel/bpf_jit/bpf_check.c                         | 1054 ++++++++++++++++++++
 kernel/bpf_jit/bpf_run.c                           |  511 ++++++++++
 kernel/trace/Kconfig                               |    1 +
 kernel/trace/Makefile                              |    1 +
 kernel/trace/bpf_trace_callbacks.c                 |  193 ++++
 kernel/trace/trace.c                               |    7 +
 kernel/trace/trace.h                               |   11 +-
 kernel/trace/trace_events.c                        |    9 +-
 kernel/trace/trace_events_filter.c                 |   61 +-
 kernel/trace/trace_kprobe.c                        |   15 +-
 lib/Kconfig.debug                                  |   15 +
 tools/bpf/examples/Makefile                        |   71 ++
 tools/bpf/examples/README.txt                      |   59 ++
 tools/bpf/examples/dropmon.c                       |   40 +
 tools/bpf/examples/netif_rcv.c                     |   34 +
 tools/bpf/filter_check/Makefile                    |   32 +
 tools/bpf/filter_check/README.txt                  |    3 +
 tools/bpf/filter_check/trace_filter_check.c        |  115 +++
 tools/bpf/llvm/LICENSE.TXT                         |   70 ++
 tools/bpf/llvm/Makefile.rules                      |  641 ++++++++++++
 tools/bpf/llvm/README.txt                          |   23 +
 tools/bpf/llvm/bld/.gitignore                      |    2 +
 tools/bpf/llvm/bld/Makefile                        |   27 +
 tools/bpf/llvm/bld/Makefile.common                 |   14 +
 tools/bpf/llvm/bld/Makefile.config                 |  124 +++
 .../llvm/bld/include/llvm/Config/AsmParsers.def    |    8 +
 .../llvm/bld/include/llvm/Config/AsmPrinters.def   |    9 +
 .../llvm/bld/include/llvm/Config/Disassemblers.def |    8 +
 tools/bpf/llvm/bld/include/llvm/Config/Targets.def |    9 +
 .../bpf/llvm/bld/include/llvm/Support/DataTypes.h  |   96 ++
 tools/bpf/llvm/bld/lib/Makefile                    |   11 +
 .../llvm/bld/lib/Target/BPF/InstPrinter/Makefile   |   10 +
 .../llvm/bld/lib/Target/BPF/MCTargetDesc/Makefile  |   11 +
 tools/bpf/llvm/bld/lib/Target/BPF/Makefile         |   17 +
 .../llvm/bld/lib/Target/BPF/TargetInfo/Makefile    |   10 +
 tools/bpf/llvm/bld/lib/Target/Makefile             |   11 +
 tools/bpf/llvm/bld/tools/Makefile                  |   12 +
 tools/bpf/llvm/bld/tools/llc/Makefile              |   15 +
 tools/bpf/llvm/lib/Target/BPF/BPF.h                |   30 +
 tools/bpf/llvm/lib/Target/BPF/BPF.td               |   29 +
 tools/bpf/llvm/lib/Target/BPF/BPFAsmPrinter.cpp    |  100 ++
 tools/bpf/llvm/lib/Target/BPF/BPFCFGFixup.cpp      |   62 ++
 tools/bpf/llvm/lib/Target/BPF/BPFCallingConv.td    |   24 +
 tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.cpp |   36 +
 tools/bpf/llvm/lib/Target/BPF/BPFFrameLowering.h   |   35 +
 tools/bpf/llvm/lib/Target/BPF/BPFISelDAGToDAG.cpp  |  182 ++++
 tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.cpp  |  676 +++++++++++++
 tools/bpf/llvm/lib/Target/BPF/BPFISelLowering.h    |  105 ++
 tools/bpf/llvm/lib/Target/BPF/BPFInstrFormats.td   |   29 +
 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.cpp     |  162 +++
 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.h       |   53 +
 tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.td      |  455 +++++++++
 tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.cpp   |   77 ++
 tools/bpf/llvm/lib/Target/BPF/BPFMCInstLower.h     |   40 +
 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.cpp  |  122 +++
 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.h    |   65 ++
 tools/bpf/llvm/lib/Target/BPF/BPFRegisterInfo.td   |   39 +
 tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.cpp     |   23 +
 tools/bpf/llvm/lib/Target/BPF/BPFSubtarget.h       |   33 +
 tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.cpp |   72 ++
 tools/bpf/llvm/lib/Target/BPF/BPFTargetMachine.h   |   69 ++
 .../lib/Target/BPF/InstPrinter/BPFInstPrinter.cpp  |   79 ++
 .../lib/Target/BPF/InstPrinter/BPFInstPrinter.h    |   34 +
 .../lib/Target/BPF/MCTargetDesc/BPFAsmBackend.cpp  |   85 ++
 .../llvm/lib/Target/BPF/MCTargetDesc/BPFBaseInfo.h |   33 +
 .../Target/BPF/MCTargetDesc/BPFELFObjectWriter.cpp |  119 +++
 .../lib/Target/BPF/MCTargetDesc/BPFMCAsmInfo.h     |   34 +
 .../Target/BPF/MCTargetDesc/BPFMCCodeEmitter.cpp   |  120 +++
 .../lib/Target/BPF/MCTargetDesc/BPFMCCodeEmitter.h |   67 ++
 .../Target/BPF/MCTargetDesc/BPFMCTargetDesc.cpp    |  115 +++
 .../lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.h  |   56 ++
 .../lib/Target/BPF/TargetInfo/BPFTargetInfo.cpp    |   13 +
 tools/bpf/llvm/tools/llc/llc.cpp                   |  381 +++++++
 88 files changed, 8255 insertions(+), 25 deletions(-)
 create mode 100644 Documentation/bpf_jit.txt
 create mode 100644 arch/x86/net/bpf64_jit_comp.c
 create mode 100644 arch/x86/net/bpf_jit_comp.h
 create mode 100644 include/linux/bpf.h
 create mode 100644 include/linux/bpf_jit.h
 create mode 100644 include/trace/bpf_trace.h
 create mode 100644 kernel/bpf_jit/Makefile
 create mode 100644 kernel/bpf_jit/bpf_check.c
 create mode 100644 kernel/bpf_jit/bpf_run.c
 create mode 100644 kernel/trace/bpf_trace_callbacks.c
 create mode 100644 tools/bpf/examples/Makefile
 create mode 100644 tools/bpf/examples/README.txt
 create mode 100644 tools/bpf/examples/dropmon.c
 create mode 100644 tools/bpf/examples/netif_rcv.c
 create mode 100644 tools/bpf/filter_check/Makefile
 create mode 100644 tools/bpf/filter_check/README.txt
 create mode 100644 tools/bpf/filter_check/trace_filter_check.c
 create mode 100644 tools/bpf/llvm/LICENSE.TXT
 create mode 100644 tools/bpf/llvm/Makefile.rules
 create mode 100644 tools/bpf/llvm/README.txt
 create mode 100644 tools/bpf/llvm/bld/.gitignore
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
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/BPFCFGFixup.cpp
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
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCCodeEmitter.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.cpp
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/MCTargetDesc/BPFMCTargetDesc.h
 create mode 100644 tools/bpf/llvm/lib/Target/BPF/TargetInfo/BPFTargetInfo.cpp
 create mode 100644 tools/bpf/llvm/tools/llc/llc.cpp

-- 
1.7.9.5
