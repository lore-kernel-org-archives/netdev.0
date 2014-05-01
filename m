From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] net: filter: doc: expand and improve BPF documentation
Date: Thu,  1 May 2014 08:16:03 -0700
Message-ID: <1398957363-17829-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:46668 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755324AbaEAPQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 11:16:11 -0400
Received: by mail-pa0-f43.google.com with SMTP id rd3so3800518pab.16
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 08:16:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In particular, this patch tries to clarify internal BPF calling
convention and adds internal BPF examples, JIT guide, use cases.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Documentation/networking/filter.txt |  158 ++++++++++++++++++++++++++++++++++-
 1 file changed, 154 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 82e1cb0b3da8..748fd385535d 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -613,7 +613,7 @@ Some core changes of the new internal format:
 
   Therefore, BPF calling convention is defined as:
 
-    * R0	- return value from in-kernel function
+    * R0	- return value from in-kernel function, and exit value for BPF program
     * R1 - R5	- arguments from BPF program to in-kernel function
     * R6 - R9	- callee saved registers that in-kernel function will preserve
     * R10	- read-only frame pointer to access stack
@@ -659,9 +659,140 @@ Some core changes of the new internal format:
 - Introduces bpf_call insn and register passing convention for zero overhead
   calls from/to other kernel functions:
 
-  After a kernel function call, R1 - R5 are reset to unreadable and R0 has a
-  return type of the function. Since R6 - R9 are callee saved, their state is
-  preserved across the call.
+  Before an in-kernel function call, the internal BPF program needs to
+  place function arguments into R1 to R5 registers to satisfy calling
+  convention, then the interpreter will take them from registers and pass
+  to in-kernel function. If R1 - R5 registers are mapped to CPU registers
+  that are used for argument passing on given architecture, the JIT compiler
+  doesn't need to emit extra moves. Function arguments will be in the correct
+  registers and BPF_CALL instruction will be JITed as single 'call' HW
+  instruction. This calling convention was picked to cover common call
+  situations without performance penalty.
+
+  After an in-kernel function call, R1 - R5 are reset to unreadable and R0 has
+  a return value of the function. Since R6 - R9 are callee saved, their state
+  is preserved across the call.
+
+  For example, consider three C functions:
+
+  u64 f1() { return (*_f2)(1); }
+  u64 f2(u64 a) { return f3(a + 1, a); }
+  u64 f3(u64 a, u64 b) { return a - b; }
+
+  GCC can compile f1, f3 into x86_64:
+
+  f1:
+    movl $1, %edi
+    movq _f2(%rip), %rax
+    jmp  *%rax
+  f3:
+    movq %rdi, %rax
+    subq %rsi, %rax
+    ret
+
+  Function f2 in BPF may look like:
+
+  f2:
+    bpf_mov R2, R1
+    bpf_add R1, 1
+    bpf_call f3
+    bpf_exit
+
+  If f2 is JITed and the pointer stored to '_f2'. The calls f1 -> f2 -> f3 and
+  returns will be seamless. Without JIT, __sk_run_filter() interpreter needs to
+  be used to call into f2.
+
+  For practical reasons all BPF programs have only one argument 'ctx' which is
+  already placed into R1 (e.g. on __sk_run_filter() startup) and the programs
+  can call kernel functions with up to 5 arguments. Calls with 6 or more arguments
+  are currently not supported, but these restrictions can be lifted if necessary
+  in the future.
+
+  On 64-bit architectures all register map to HW registers one to one. For
+  example, x86_64 JIT compiler can map them as ...
+
+    R0 - rax
+    R1 - rdi
+    R2 - rsi
+    R3 - rdx
+    R4 - rcx
+    R5 - r8
+    R6 - rbx
+    R7 - r13
+    R8 - r14
+    R9 - r15
+    R10 - rbp
+
+  ... since x86_64 ABI mandates rdi, rsi, rdx, rcx, r8, r9 for argument passing
+  and rbx, r12 - r15 are callee saved.
+
+  Then the following internal BPF pseudo-program:
+
+    bpf_mov R6, R1 /* save ctx */
+    bpf_mov R2, 2
+    bpf_mov R3, 3
+    bpf_mov R4, 4
+    bpf_mov R5, 5
+    bpf_call foo
+    bpf_mov R7, R0 /* save foo() return value */
+    bpf_mov R1, R6 /* restore ctx for next call */
+    bpf_mov R2, 6
+    bpf_mov R3, 7
+    bpf_mov R4, 8
+    bpf_mov R5, 9
+    bpf_call bar
+    bpf_add R0, R7
+    bpf_exit
+
+  After JIT to x86_64 may look like:
+
+    push %rbp
+    mov %rsp,%rbp
+    sub $0x228,%rsp
+    mov %rbx,-0x228(%rbp)
+    mov %r13,-0x220(%rbp)
+    mov %rdi,%rbx
+    mov $0x2,%esi
+    mov $0x3,%edx
+    mov $0x4,%ecx
+    mov $0x5,%r8d
+    callq foo
+    mov %rax,%r13
+    mov %rbx,%rdi
+    mov $0x2,%esi
+    mov $0x3,%edx
+    mov $0x4,%ecx
+    mov $0x5,%r8d
+    callq bar
+    add %r13,%rax
+    mov -0x228(%rbp),%rbx
+    mov -0x220(%rbp),%r13
+    leaveq
+    retq
+
+  Which is in this example equivalent in C to:
+
+    u64 bpf_filter(u64 ctx)
+    {
+        return foo(ctx, 2, 3, 4, 5) + bar(ctx, 6, 7, 8, 9);
+    }
+
+  In-kernel functions foo() and bar() with prototype: u64 (*)(u64 arg1, u64
+  arg2, u64 arg3, u64 arg4, u64 arg5); will receive arguments in proper
+  registers and place their return value into '%rax' which is R0 in BPF.
+  Prologue and epilogue are emitted by JIT and are implicit in the
+  interpreter. R0-R5 are scratch registers, so BPF program needs to preserve
+  them across the calls as defined by calling convention.
+
+  For example the following program is invalid:
+
+    bpf_mov R1, 1
+    bpf_call foo
+    bpf_mov R0, R1
+    bpf_exit
+
+  After the call the registers R1-R5 contain junk values and cannot be read.
+  In the future a BPF verifier can be used to validate internal BPF programs.
 
 Also in the new design, BPF is limited to 4096 insns, which means that any
 program will terminate quickly and will only call a fixed number of kernel
@@ -676,6 +807,25 @@ A program, that is translated internally consists of the following elements:
 
   op:16, jt:8, jf:8, k:32    ==>    op:8, a_reg:4, x_reg:4, off:16, imm:32
 
+So far 87 internal BPF instructions were implemented. 8-bit 'op' opcode field
+has room for new instructions. Some of them may use 16/24/32 byte encoding. New
+instructions must be multiple of 8 bytes to preserve backward compatibility.
+
+Internal BPF is a general purpose RISC instruction set. Not every register and
+every instruction are used during translation from original BPF to new format.
+For example, socket filters are not using 'exclusive add' instruction, but
+tracing filters may do to maintain counters of events, for example. Register R9
+is not used by socket filters either, but more complex filters may be running
+out of registers and would have to resort to spill/fill to stack.
+
+Internal BPF can used as generic assembler for last step performance
+optimizations, socket filters and seccomp are using it as assembler. Tracing
+filters may use it as assembler to generate code from kernel. In kernel usage
+may not be bounded by security considerations, since generated internal BPF code
+may be optimizing internal code path and not being exposed to the user space.
+Safety of internal BPF can come from a verifier (TBD). In such use cases as
+described, it may be used as safe instruction set.
+
 Just like the original BPF, the new format runs within a controlled environment,
 is deterministic and the kernel can easily prove that. The safety of the program
 can be determined in two steps: first step does depth-first-search to disallow
-- 
1.7.9.5
