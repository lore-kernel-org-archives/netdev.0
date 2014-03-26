From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 9/9] doc: filter: extend BPF documentation to document new internals
Date: Wed, 26 Mar 2014 22:06:10 +0100
Message-ID: <1395867970-1338-10-git-send-email-dborkman@redhat.com>
References: <1395867970-1338-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39109 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756270AbaCZVGj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 17:06:39 -0400
In-Reply-To: <1395867970-1338-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>

Further extend the current BPF documentation to document new BPF
engine internals. Joint work with Daniel Borkmann.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Documentation/networking/filter.txt | 143 ++++++++++++++++++++++++++++++++++++
 1 file changed, 143 insertions(+)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index a06b48d..dbc6383 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -546,6 +546,148 @@ ffffffffa0069c8f + <x>:
 For BPF JIT developers, bpf_jit_disasm, bpf_asm and bpf_dbg provides a useful
 toolchain for developing and testing the kernel's JIT compiler.
 
+BPF kernel internals
+--------------------
+Internally, for the kernel interpreter, a different BPF instruction set
+format with similar underlying principles from BPF described in previous
+paragraphs is being used. However, the instruction set format is modelled
+closer to the underlying architecture to mimic native instruction sets, so
+that a better performance can be achieved (more details later).
+
+It is designed to be JITed with one to one mapping, which can also open up
+the possibility for GCC/LLVM compilers to generate optimized BPF code through
+a BPF backend that performs almost as fast as natively compiled code.
+
+The new instruction set was originally designed with the possible goal in
+mind to write programs in "restricted C" and compile into BPF with a optional
+GCC/LLVM backend, so that it can just-in-time map to modern 64-bit CPUs with
+minimal performance overhead over two steps, that is, C -> BPF -> native code.
+
+Currently, the new format is being used for running user BPF programs, which
+includes seccomp BPF, classic socket filters, cls_bpf traffic classifier,
+team driver's classifier for its load-balancing mode, netfilter's xt_bpf
+extension, PTP dissector/classifier, and much more. They are all internally
+converted by the kernel into the new instruction set representation and run
+in the extended interpreter. For in-kernel handlers, this all works
+transparently by using sk_unattached_filter_create() for setting up the
+filter, resp. sk_unattached_filter_destroy() for destroying it. The macro
+SK_RUN_FILTER(filter, ctx) transparently invokes the right BPF function to
+run the filter. 'filter' is a pointer to struct sk_filter that we got from
+sk_unattached_filter_create(), and 'ctx' the given context (e.g. skb pointer).
+All constraints and restrictions from sk_chk_filter() apply before a
+conversion to the new layout is being done behind the scenes!
+
+Currently, for JITing, the user BPF format is being used and current BPF JIT
+compilers reused whenever possible. In other words, we do not (yet!) perform
+a JIT compilation in the new layout, however, future work will successively
+migrate traditional JIT compilers into the new instruction format as well, so
+that they will profit from the very same benefits. Thus, when speaking about
+JIT in the following, a JIT compiler (TBD) for the new instruction format is
+meant in this context.
+
+The internal format extends BPF in the following way:
+
+- Number of registers increase from 2 to 10:
+
+  The old format had two registers A and X, and a hidden frame pointer. The
+  new layout extends this to be 10 internal registers and a read-only frame
+  pointer. Since 64-bit CPUs are passing arguments to functions via registers
+  the number of args from BPF program to in-kernel function is restricted
+  to 5 and one register is used to accept return value from an in-kernel
+  function. Natively, x86_64 passes first 6 arguments in registers, aarch64/
+  sparcv9/mips64 have 7 - 8 registers for arguments; x86_64 has 6 callee saved
+  registers, and aarch64/sparcv9/mips64 have 11 or more callee saved registers.
+
+  Therefore, BPF calling convention is defined as:
+
+    * R0	- return value from in-kernel function
+    * R1 - R5	- arguments from BPF program to in-kernel function
+    * R6 - R9	- callee saved registers that in-kernel function will preserve
+    * R10	- read-only frame pointer to access stack
+
+  Thus, all BPF registers map one to one to HW registers on x86_64, aarch64,
+  etc, and BPF calling convention maps directly to ABIs used by the kernel on
+  64-bit architectures.
+
+  On 32-bit architectures JIT may map programs that use only 32-bit arithmetic
+  and may let more complex programs to be interpreted.
+
+  R0 - R5 are scratch registers and BPF program needs spill/fill them if
+  necessary across calls. Note that there is only one BPF program (== one BPF
+  main routine) and it cannot call other BPF functions, it can only call
+  predefined in-kernel functions, though.
+
+- Register width increases from 32-bit to 64-bit:
+
+  Still, the semantics of the original 32-bit ALU operations are preserved
+  via 32-bit subregisters. All BPF registers are 64-bit with 32-bit lower
+  subregisters that zero-extend into 64-bit if they are being written to.
+  That behavior maps directly to x86_64 and arm64 subregister definition, but
+  makes other JITs more difficult.
+
+  32-bit architectures run 64-bit internal BPF programs via interpreter.
+  Their JITs may convert BPF programs that only use 32-bit subregisters into
+  native instruction set and let the rest being interpreted.
+
+  Operation is 64-bit, because on 64-bit architectures, pointers are also
+  64-bit wide, and we want to pass 64-bit values in/out of kernel functions,
+  so 32-bit BPF registers would otherwise require to define register-pair
+  ABI, thus, there won't be able to use a direct BPF register to HW register
+  mapping and JIT would need to do combine/split/move operations for every
+  register in and out of the function, which is complex, bug prone and slow.
+  Another reason is the use of atomic 64-bit counters.
+
+- Conditional jt/jf targets replaced with jt/fall-through:
+
+  While the original design has constructs such as "if (cond) jump_true;
+  else jump_false;", they are being replaced into alternative constructs like
+  "if (cond) jump_true; /* else fall-through */".
+
+- Adds signed > and >= insns
+
+- 16 4-byte stack slots for register spill-fill replaced with up to 512 bytes
+  of multi-use stack space
+
+- Introduces bpf_call insn and register passing convention for zero overhead
+  calls from/to other kernel functions:
+
+  After a kernel function call, R1 - R5 are reset to unreadable and R0 has a
+  return type of the function. Since R6 - R9 are callee saved, their state is
+  preserved across the call.
+
+- Adds arithmetic right shift insn
+
+- Adds swab insns for 32/64-bit
+
+  The new BPF format doesn't have pre-defined endianness not to favor one
+  architecture vs another. Therefore, bswap insn is available. Original BPF
+  doesn't have such insn and does bswap as part of sk_load_word call which is
+  often unnecessary, if we want to compare a value with a constant.
+
+- Adds atomic_add insn
+
+- Old tax/txa insns are replaced with 'mov dst,src' insn
+
+Also in the new design, BPF is limited to 4096 insns, which means that any
+program will terminate quickly and will only call a fixed number of kernel
+functions. Original BPF and the new format are two operand instructions,
+which helps to do one-to-one mapping between BPF insn and x86 insn during JIT.
+
+The input context pointer for invoking the interpreter function is generic,
+its content is defined by a specific use case. For seccomp register R1 points
+to seccomp_data, for converted BPF filters R1 points to a skb.
+
+A program, that is translated internally consists of the following elements:
+
+  op:16, jt:8, jf:8, k:32    ==>    op:8, a_reg:4, x_reg:4, off:16, imm:32
+
+Just like the original BPF, the new format runs within a controlled environment,
+is deterministic and the kernel can easily prove that. The safety of the program
+can be determined in two steps: first step does depth-first-search to disallow
+loops and other CFG validation; second step starts from the first insn and
+descends all possible paths. It simulates execution of every insn and observes
+the state change of registers and stack.
+
 Misc
 ----
 
@@ -561,3 +703,4 @@ the underlying architecture.
 
 Jay Schulist <jschlst@samba.org>
 Daniel Borkmann <dborkman@redhat.com>
+Alexei Starovoitov <ast@plumgrid.com>
-- 
1.7.11.7
