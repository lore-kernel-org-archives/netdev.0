From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] net: filter: mention eBPF terminology as well
Date: Tue, 10 Jun 2014 17:44:06 +0200
Message-ID: <1402415047-13535-2-git-send-email-dborkman@redhat.com>
References: <1402415047-13535-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11313 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798AbaFJPoN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 11:44:13 -0400
In-Reply-To: <1402415047-13535-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>

Since the term eBPF is used anyway on mailing list discussions, lets
also document that in the main BPF documentation file and replace a
couple of occurrences with eBPF terminology to be more clear.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Documentation/networking/filter.txt | 85 +++++++++++++++++++------------------
 1 file changed, 43 insertions(+), 42 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 9f49b86..1c7fc6b 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -561,42 +561,43 @@ toolchain for developing and testing the kernel's JIT compiler.
 
 BPF kernel internals
 --------------------
-Internally, for the kernel interpreter, a different BPF instruction set
+Internally, for the kernel interpreter, a different instruction set
 format with similar underlying principles from BPF described in previous
 paragraphs is being used. However, the instruction set format is modelled
 closer to the underlying architecture to mimic native instruction sets, so
-that a better performance can be achieved (more details later).
+that a better performance can be achieved (more details later). This new
+ISA is called 'eBPF' or 'internal BPF' interchangeably. (Note: eBPF which
+originates from [e]xtended BPF is not the same as BPF extensions! While
+eBPF is an ISA, BPF extensions date back to classic BPF's 'overloading'
+of BPF_LD | BPF_{B,H,W} | BPF_ABS instruction.)
 
 It is designed to be JITed with one to one mapping, which can also open up
-the possibility for GCC/LLVM compilers to generate optimized BPF code through
-a BPF backend that performs almost as fast as natively compiled code.
+the possibility for GCC/LLVM compilers to generate optimized eBPF code through
+an eBPF backend that performs almost as fast as natively compiled code.
 
 The new instruction set was originally designed with the possible goal in
-mind to write programs in "restricted C" and compile into BPF with a optional
+mind to write programs in "restricted C" and compile into eBPF with a optional
 GCC/LLVM backend, so that it can just-in-time map to modern 64-bit CPUs with
-minimal performance overhead over two steps, that is, C -> BPF -> native code.
+minimal performance overhead over two steps, that is, C -> eBPF -> native code.
 
 Currently, the new format is being used for running user BPF programs, which
 includes seccomp BPF, classic socket filters, cls_bpf traffic classifier,
 team driver's classifier for its load-balancing mode, netfilter's xt_bpf
 extension, PTP dissector/classifier, and much more. They are all internally
 converted by the kernel into the new instruction set representation and run
-in the extended interpreter. For in-kernel handlers, this all works
-transparently by using sk_unattached_filter_create() for setting up the
-filter, resp. sk_unattached_filter_destroy() for destroying it. The macro
-SK_RUN_FILTER(filter, ctx) transparently invokes the right BPF function to
-run the filter. 'filter' is a pointer to struct sk_filter that we got from
-sk_unattached_filter_create(), and 'ctx' the given context (e.g. skb pointer).
-All constraints and restrictions from sk_chk_filter() apply before a
-conversion to the new layout is being done behind the scenes!
-
-Currently, for JITing, the user BPF format is being used and current BPF JIT
-compilers reused whenever possible. In other words, we do not (yet!) perform
-a JIT compilation in the new layout, however, future work will successively
-migrate traditional JIT compilers into the new instruction format as well, so
-that they will profit from the very same benefits. Thus, when speaking about
-JIT in the following, a JIT compiler (TBD) for the new instruction format is
-meant in this context.
+in the eBPF interpreter. For in-kernel handlers, this all works transparently
+by using sk_unattached_filter_create() for setting up the filter, resp.
+sk_unattached_filter_destroy() for destroying it. The macro
+SK_RUN_FILTER(filter, ctx) transparently invokes eBPF interpreter or JITed
+code to run the filter. 'filter' is a pointer to struct sk_filter that we
+got from sk_unattached_filter_create(), and 'ctx' the given context (e.g.
+skb pointer). All constraints and restrictions from sk_chk_filter() apply
+before a conversion to the new layout is being done behind the scenes!
+
+Currently, the classic BPF format is being used for JITing on most of the
+architectures. Only x86-64 performs JIT compilation from eBPF instruction set,
+however, future work will migrate other JIT compilers as well, so that they
+will profit from the very same benefits.
 
 Some core changes of the new internal format:
 
@@ -605,35 +606,35 @@ Some core changes of the new internal format:
   The old format had two registers A and X, and a hidden frame pointer. The
   new layout extends this to be 10 internal registers and a read-only frame
   pointer. Since 64-bit CPUs are passing arguments to functions via registers
-  the number of args from BPF program to in-kernel function is restricted
+  the number of args from eBPF program to in-kernel function is restricted
   to 5 and one register is used to accept return value from an in-kernel
   function. Natively, x86_64 passes first 6 arguments in registers, aarch64/
   sparcv9/mips64 have 7 - 8 registers for arguments; x86_64 has 6 callee saved
   registers, and aarch64/sparcv9/mips64 have 11 or more callee saved registers.
 
-  Therefore, BPF calling convention is defined as:
+  Therefore, eBPF calling convention is defined as:
 
-    * R0	- return value from in-kernel function, and exit value for BPF program
-    * R1 - R5	- arguments from BPF program to in-kernel function
+    * R0	- return value from in-kernel function, and exit value for eBPF program
+    * R1 - R5	- arguments from eBPF program to in-kernel function
     * R6 - R9	- callee saved registers that in-kernel function will preserve
     * R10	- read-only frame pointer to access stack
 
-  Thus, all BPF registers map one to one to HW registers on x86_64, aarch64,
-  etc, and BPF calling convention maps directly to ABIs used by the kernel on
+  Thus, all eBPF registers map one to one to HW registers on x86_64, aarch64,
+  etc, and eBPF calling convention maps directly to ABIs used by the kernel on
   64-bit architectures.
 
   On 32-bit architectures JIT may map programs that use only 32-bit arithmetic
   and may let more complex programs to be interpreted.
 
-  R0 - R5 are scratch registers and BPF program needs spill/fill them if
-  necessary across calls. Note that there is only one BPF program (== one BPF
-  main routine) and it cannot call other BPF functions, it can only call
-  predefined in-kernel functions, though.
+  R0 - R5 are scratch registers and eBPF program needs spill/fill them if
+  necessary across calls. Note that there is only one eBPF program (== one
+  eBPF main routine) and it cannot call other eBPF functions, it can only
+  call predefined in-kernel functions, though.
 
 - Register width increases from 32-bit to 64-bit:
 
   Still, the semantics of the original 32-bit ALU operations are preserved
-  via 32-bit subregisters. All BPF registers are 64-bit with 32-bit lower
+  via 32-bit subregisters. All eBPF registers are 64-bit with 32-bit lower
   subregisters that zero-extend into 64-bit if they are being written to.
   That behavior maps directly to x86_64 and arm64 subregister definition, but
   makes other JITs more difficult.
@@ -644,8 +645,8 @@ Some core changes of the new internal format:
 
   Operation is 64-bit, because on 64-bit architectures, pointers are also
   64-bit wide, and we want to pass 64-bit values in/out of kernel functions,
-  so 32-bit BPF registers would otherwise require to define register-pair
-  ABI, thus, there won't be able to use a direct BPF register to HW register
+  so 32-bit eBPF registers would otherwise require to define register-pair
+  ABI, thus, there won't be able to use a direct eBPF register to HW register
   mapping and JIT would need to do combine/split/move operations for every
   register in and out of the function, which is complex, bug prone and slow.
   Another reason is the use of atomic 64-bit counters.
@@ -690,7 +691,7 @@ Some core changes of the new internal format:
     subq %rsi, %rax
     ret
 
-  Function f2 in BPF may look like:
+  Function f2 in eBPF may look like:
 
   f2:
     bpf_mov R2, R1
@@ -702,7 +703,7 @@ Some core changes of the new internal format:
   returns will be seamless. Without JIT, __sk_run_filter() interpreter needs to
   be used to call into f2.
 
-  For practical reasons all BPF programs have only one argument 'ctx' which is
+  For practical reasons all eBPF programs have only one argument 'ctx' which is
   already placed into R1 (e.g. on __sk_run_filter() startup) and the programs
   can call kernel functions with up to 5 arguments. Calls with 6 or more arguments
   are currently not supported, but these restrictions can be lifted if necessary
@@ -779,9 +780,9 @@ Some core changes of the new internal format:
 
   In-kernel functions foo() and bar() with prototype: u64 (*)(u64 arg1, u64
   arg2, u64 arg3, u64 arg4, u64 arg5); will receive arguments in proper
-  registers and place their return value into '%rax' which is R0 in BPF.
+  registers and place their return value into '%rax' which is R0 in eBPF.
   Prologue and epilogue are emitted by JIT and are implicit in the
-  interpreter. R0-R5 are scratch registers, so BPF program needs to preserve
+  interpreter. R0-R5 are scratch registers, so eBPF program needs to preserve
   them across the calls as defined by calling convention.
 
   For example the following program is invalid:
@@ -792,12 +793,12 @@ Some core changes of the new internal format:
     bpf_exit
 
   After the call the registers R1-R5 contain junk values and cannot be read.
-  In the future a BPF verifier can be used to validate internal BPF programs.
+  In the future an eBPF verifier can be used to validate internal BPF programs.
 
-Also in the new design, BPF is limited to 4096 insns, which means that any
+Also in the new design, eBPF is limited to 4096 insns, which means that any
 program will terminate quickly and will only call a fixed number of kernel
 functions. Original BPF and the new format are two operand instructions,
-which helps to do one-to-one mapping between BPF insn and x86 insn during JIT.
+which helps to do one-to-one mapping between eBPF insn and x86 insn during JIT.
 
 The input context pointer for invoking the interpreter function is generic,
 its content is defined by a specific use case. For seccomp register R1 points
-- 
1.7.11.7
