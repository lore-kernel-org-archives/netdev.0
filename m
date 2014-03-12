From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v10 net-next 3/3] doc: filter: add Extended BPF documentation
Date: Wed, 12 Mar 2014 14:43:34 -0700
Message-ID: <1394660614-4436-4-git-send-email-ast@plumgrid.com>
References: <1394660614-4436-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394660614-4436-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
---
 Documentation/networking/filter.txt |  181 +++++++++++++++++++++++++++++++++++
 1 file changed, 181 insertions(+)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index a06b48d2f5cc..6a0e29583a30 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -546,6 +546,186 @@ ffffffffa0069c8f + <x>:
 For BPF JIT developers, bpf_jit_disasm, bpf_asm and bpf_dbg provides a useful
 toolchain for developing and testing the kernel's JIT compiler.
 
+Extended BPF
+------------
+Extended BPF extends BPF in the following ways:
+- from 2 to 10 registers
+  Original BPF has two registers (A and X) and hidden frame pointer.
+  Extended BPF has ten registers and read-only frame pointer.
+- from 32-bit registers to 64-bit registers
+  semantics of old 32-bit ALU operations are preserved via 32-bit
+  subregisters
+- if (cond) jump_true; else jump_false;
+  old BPF insns are replaced with:
+  if (cond) jump_true; /* else fallthrough */
+- adds signed > and >= insns
+- 16 4-byte stack slots for register spill-fill replaced with
+  up to 512 bytes of multi-use stack space
+- introduces bpf_call insn and register passing convention for zero
+  overhead calls from/to other kernel functions (not part of this patch)
+- adds arithmetic right shift insn
+- adds swab32/swab64 insns
+- adds atomic_add insn
+- old tax/txa insns are replaced with 'mov dst,src' insn
+
+Extended BPF is designed to be JITed with one to one mapping, which
+allows GCC/LLVM compilers to generate optimized BPF code that performs
+almost as fast as natively compiled code
+
+sysctl net.core.bpf_ext_enable=1
+controls whether filters attached to sockets will be automatically
+converted to extended BPF or not.
+
+BPF is safe dynamically loadable program that can call fixed set
+of kernel functions and takes a pointer to data as an input,
+where data is skb, seccomp_data, kprobe function arguments or else.
+
+Extended Instruction Set was designed with these goals:
+- write programs in restricted C and compile into BPF with GCC/LLVM
+- just-in-time map to modern 64-bit CPU with minimal performance overhead
+  over two steps: C -> BPF -> native code
+- guarantee termination and safety of BPF program in kernel
+  with simple algorithm
+
+GCC/LLVM-bpf backend is optional.
+Extended BPF can be coded with macroses from filter.h just like original BPF,
+though the same filter done in C is easier to understand.
+sk_convert_filter() remaps original BPF insns into extended.
+
+Minimal performance overhead is achieved by having one to one mapping
+between BPF insns and native insns, and one to one mapping between BPF
+registers and native registers on 64-bit CPUs
+
+Extended BPF may allow jump forward and backward for two reasons:
+to reduce branch mispredict penalty compiler moves cold basic blocks out of
+fall-through path and to reduce code duplication that would be hard to avoid
+if only jump forward was available.
+To guarantee termination simple non-recursive depth-first-search verifies
+that there are no back-edges (no loops in the program), program is a DAG
+with root at the first insn, all branches end at the last RET insn and
+all instructions are reachable.
+Original BPF actually allows unreachable insns. Though it's safe, it will be
+fixed when extended BPF replaces BPF completely.
+
+Original BPF has two registers (A and X) and hidden frame pointer.
+Extended BPF has ten registers and read-only frame pointer.
+Since 64-bit CPUs are passing arguments to the functions via registers
+the number of args from BPF program to in-kernel function is restricted to 5
+and one register is used to accept return value from in-kernel function.
+x86_64 passes first 6 arguments in registers.
+aarch64/sparcv9/mips64 have 7-8 registers for arguments.
+x86_64 has 6 callee saved registers.
+aarch64/sparcv9/mips64 have 11 or more callee saved registers.
+
+Therefore extended BPF calling convention is defined as:
+R0 - return value from in-kernel function
+R1-R5 - arguments from BPF program to in-kernel function
+R6-R9 - callee saved registers that in-kernel function will preserve
+R10 - read-only frame pointer to access stack
+
+so that all BPF registers map one to one to HW registers on x86_64,aarch64,etc
+and BPF calling convention maps directly to ABIs used by kernel on 64-bit
+architectures.
+On 32-bit architectures JIT may map programs that use only 32-bit arithmetic
+and let more complex programs to be interpreted.
+
+R0-R5 are scratch registers and BPF program needs spill/fill them if necessary
+across calls.
+Note that there is only one BPF program == one BPF function and it cannot call
+other BPF functions. It can only call predefined in-kernel functions.
+
+All BPF registers are 64-bit with 32-bit lower subregister that zero-extends
+into 64-bit if written to. That behavior maps directly to x86_64 and arm64
+subregister defintion, but makes other JITs more difficult.
+
+Original BPF and extended BPF are two operand instructions, which helps
+to do one-to-one mapping between BPF insn and x86 insn during JIT.
+
+Extended BPF doesn't have pre-defined endianness not to favor one
+architecture vs another. Therefore bswap insn is available.
+Original BPF doesn't have such insn and does bswap as part of sk_load_word call
+which is often unnecessary if we want to compare the value with the constant.
+Restricted C code might be written differently depending on endianness
+and GCC/LLVM-bpf will take an endianness flag.
+
+32-bit architectures run 64-bit extended BPF programs via interpreter.
+Their JITs may convert BPF programs that only use 32-bit subregs into native
+instruction set and let the rest being interpreted.
+
+Extended BPF is 64-bit, because on 64-bit architectures, pointers are 64-bit
+and we want to pass 64-bit values in/out kernel functions, so 32-bit BPF
+registers would require to define register-pair ABI, there won't be a direct
+BPF register to HW register mapping and JIT would need to do
+combine/split/move operations for every register in and out of the function,
+which is complex, bug prone and slow.
+Another reason is atomic 64-bit counters
+
+Just like original BPF, extended BPF is safe, deterministic and kernel can
+easily prove that. The safety of the program is determined in two steps.
+First step does depth-first-search to disallow loops and other CFG validation.
+Second step starts from the first insn and descends all possible paths.
+It simulates execution of every insn and observes the state change of
+registers and stack.
+At the start of the program the register R1 contains a pointer to context
+and has type PTR_TO_CTX. If checker sees an insn that does R2=R1, then R2 has
+now type PTR_TO_CTX as well and can be used on right hand side of expression.
+If R1=PTR_TO_CTX and insn is R2=R1+1, then R2=INVALID_PTR and it is readable.
+If register was never written to, it's not readable.
+After kernel function call, R1-R5 are reset to unreadable and R0 has a return
+type of the function. Since R6-R9 are callee saved, their state is preserved
+across the call.
+load/store instructions are allowed only with registers of valid types, which
+are PTR_TO_CTX, PTR_TO_TABLE, PTR_TO_STACK. They are bounds and alginment
+checked.
+
+Input context pointer is generic. Its contents are defined by specific use case.
+For seccomp R1 points to seccomp_data
+For converted BPF filters R1 points to skb
+Through get_context_access callback BPF checker is customized, so that BPF
+program can only access certain fields of input context with specified size
+and alignment.
+For example, the following insn:
+  BPF_INSN_LD(BPF_W, R0, R6, 8)
+intends to load word from address R6 + 8 and store it into R0
+If R6=PTR_TO_CTX, then get_context_access callback should let the checker know
+that offset 8 of size 4 bytes can be accessed for reading, otherwise the checker
+will reject the program.
+
+If R6=PTR_TO_STACK, then access should be aligned and be within stack bounds,
+which are hard coded to [-512, 0]. In this example offset is 8, so it will fail
+verification.
+The checker will allow BPF program to read data from stack only after it wrote
+into it.
+Pointer register spill/fill is tracked as well, since four (R6-R9) callee saved
+registers may not be enough for some programs.
+
+Allowed function calls are customized via get_func_proto callback.
+
+One of the useful functions that can be made available to BPF program
+are bpf_table_lookup/bpf_table_update.
+They can help tracing filters collect different types of statistics.
+Example: pc addresses for drop_monitor filter
+
+In seccomp and socket filter use cases extended BPF program consists
+of intructions only, but for tracing filters case BPF program may contain
+BPF tables as well.
+There are no special instructions to access BPF tables. The access is done
+via function calls.
+
+BPF program identifies the table by table_id and accesses it in C like:
+elem = bpf_table_lookup(ctx, table_id, key);
+
+BPF checker matches 'table_id' against known tables, verifies that 'key' points
+to stack and table->key_size bytes are initialized.
+bpf_table_lookup() is a normal kernel function. It needs to do a lookup and
+return either valid pointer to the element or NULL.
+BPF checker will verify that the program accesses the pointer only
+after comparing it to NULL.
+It's up to implementation to decide how lookup is done and meaning of the key.
+
+Just like original, extended BPF is limited to 4096 insns, which means that any
+program will terminate quickly and will call fixed number of kernel functions.
+
 Misc
 ----
 
@@ -561,3 +741,4 @@ the underlying architecture.
 
 Jay Schulist <jschlst@samba.org>
 Daniel Borkmann <dborkman@redhat.com>
+Alexei Starovoitov <ast@plumgrid.com>
-- 
1.7.9.5
