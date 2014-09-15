From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v12 net-next 06/11] bpf: verifier (add docs)
Date: Mon, 15 Sep 2014 12:18:36 -0700
Message-ID: <1410808721-27493-7-git-send-email-ast@plumgrid.com>
References: <1410808721-27493-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1410808721-27493-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

this patch adds all of eBPF verfier documentation and empty bpf_check()

The end goal for the verifier is to statically check safety of the program.

Verifier will catch:
- loops
- out of range jumps
- unreachable instructions
- invalid instructions
- uninitialized register access
- uninitialized stack access
- misaligned stack access
- out of range stack access
- invalid calling convention

More details in Documentation/networking/filter.txt

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 Documentation/networking/filter.txt |  224 +++++++++++++++++++++++++++++++++++
 include/linux/bpf.h                 |    2 +
 kernel/bpf/Makefile                 |    2 +-
 kernel/bpf/syscall.c                |    2 +-
 kernel/bpf/verifier.c               |  133 +++++++++++++++++++++
 5 files changed, 361 insertions(+), 2 deletions(-)
 create mode 100644 kernel/bpf/verifier.c

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 1900d29518f1..f1c90967f748 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -1001,6 +1001,99 @@ instruction that loads 64-bit immediate value into a dst_reg.
 Classic BPF has similar instruction: BPF_LD | BPF_W | BPF_IMM which loads
 32-bit immediate value into a register.
 
+eBPF verifier
+-------------
+The safety of the eBPF program is determined in two steps.
+
+First step does DAG check to disallow loops and other CFG validation.
+In particular it will detect programs that have unreachable instructions.
+(though classic BPF checker allows them)
+
+Second step starts from the first insn and descends all possible paths.
+It simulates execution of every insn and observes the state change of
+registers and stack.
+
+At the start of the program the register R1 contains a pointer to context
+and has type PTR_TO_CTX.
+If verifier sees an insn that does R2=R1, then R2 has now type
+PTR_TO_CTX as well and can be used on the right hand side of expression.
+If R1=PTR_TO_CTX and insn is R2=R1+R1, then R2=UNKNOWN_VALUE,
+since addition of two valid pointers makes invalid pointer.
+(In 'secure' mode verifier will reject any type of pointer arithmetic to make
+sure that kernel addresses don't leak to unprivileged users)
+
+If register was never written to, it's not readable:
+  bpf_mov R0 = R2
+  bpf_exit
+will be rejected, since R2 is unreadable at the start of the program.
+
+After kernel function call, R1-R5 are reset to unreadable and
+R0 has a return type of the function.
+
+Since R6-R9 are callee saved, their state is preserved across the call.
+  bpf_mov R6 = 1
+  bpf_call foo
+  bpf_mov R0 = R6
+  bpf_exit
+is a correct program. If there was R1 instead of R6, it would have
+been rejected.
+
+load/store instructions are allowed only with registers of valid types, which
+are PTR_TO_CTX, PTR_TO_MAP, FRAME_PTR. They are bounds and alignment checked.
+For example:
+ bpf_mov R1 = 1
+ bpf_mov R2 = 2
+ bpf_xadd *(u32 *)(R1 + 3) += R2
+ bpf_exit
+will be rejected, since R1 doesn't have a valid pointer type at the time of
+execution of instruction bpf_xadd.
+
+At the start R1 type is PTR_TO_CTX (a pointer to generic 'struct bpf_context')
+A callback is used to customize verifier to restrict eBPF program access to only
+certain fields within ctx structure with specified size and alignment.
+
+For example, the following insn:
+  bpf_ld R0 = *(u32 *)(R6 + 8)
+intends to load a word from address R6 + 8 and store it into R0
+If R6=PTR_TO_CTX, via is_valid_access() callback the verifier will know
+that offset 8 of size 4 bytes can be accessed for reading, otherwise
+the verifier will reject the program.
+If R6=FRAME_PTR, then access should be aligned and be within
+stack bounds, which are [-MAX_BPF_STACK, 0). In this example offset is 8,
+so it will fail verification, since it's out of bounds.
+
+The verifier will allow eBPF program to read data from stack only after
+it wrote into it.
+Classic BPF verifier does similar check with M[0-15] memory slots.
+For example:
+  bpf_ld R0 = *(u32 *)(R10 - 4)
+  bpf_exit
+is invalid program.
+Though R10 is correct read-only register and has type FRAME_PTR
+and R10 - 4 is within stack bounds, there were no stores into that location.
+
+Pointer register spill/fill is tracked as well, since four (R6-R9)
+callee saved registers may not be enough for some programs.
+
+Allowed function calls are customized with bpf_verifier_ops->get_func_proto()
+The eBPF verifier will check that registers match argument constraints.
+After the call register R0 will be set to return type of the function.
+
+Function calls is a main mechanism to extend functionality of eBPF programs.
+Socket filters may let programs to call one set of functions, whereas tracing
+filters may allow completely different set.
+
+If a function made accessible to eBPF program, it needs to be thought through
+from safety point of view. The verifier will guarantee that the function is
+called with valid arguments.
+
+seccomp vs socket filters have different security restrictions for classic BPF.
+Seccomp solves this by two stage verifier: classic BPF verifier is followed
+by seccomp verifier. In case of eBPF one configurable verifier is shared for
+all use cases.
+
+See details of eBPF verifier in kernel/bpf/verifier.c
+
 eBPF maps
 ---------
 'maps' is a generic storage of different types for sharing data between kernel
@@ -1040,6 +1133,137 @@ The map is defined by:
   . key size in bytes
   . value size in bytes
 
+Understanding eBPF verifier messages
+------------------------------------
+
+The following are few examples of invalid eBPF programs and verifier error
+messages as seen in the log:
+
+Program with unreachable instructions:
+static struct bpf_insn prog[] = {
+  BPF_EXIT_INSN(),
+  BPF_EXIT_INSN(),
+};
+Error:
+  unreachable insn 1
+
+Program that reads uninitialized register:
+  BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+  BPF_EXIT_INSN(),
+Error:
+  0: (bf) r0 = r2
+  R2 !read_ok
+
+Program that doesn't initialize R0 before exiting:
+  BPF_MOV64_REG(BPF_REG_2, BPF_REG_1),
+  BPF_EXIT_INSN(),
+Error:
+  0: (bf) r2 = r1
+  1: (95) exit
+  R0 !read_ok
+
+Program that accesses stack out of bounds:
+  BPF_ST_MEM(BPF_DW, BPF_REG_10, 8, 0),
+  BPF_EXIT_INSN(),
+Error:
+  0: (7a) *(u64 *)(r10 +8) = 0
+  invalid stack off=8 size=8
+
+Program that doesn't initialize stack before passing its address into function:
+  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+  BPF_LD_MAP_FD(BPF_REG_1, 0),
+  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+  BPF_EXIT_INSN(),
+Error:
+  0: (bf) r2 = r10
+  1: (07) r2 += -8
+  2: (b7) r1 = 0x0
+  3: (85) call 1
+  invalid indirect read from stack off -8+0 size 8
+
+Program that uses invalid map_fd=0 while calling to map_lookup_elem() function:
+  BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+  BPF_LD_MAP_FD(BPF_REG_1, 0),
+  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+  BPF_EXIT_INSN(),
+Error:
+  0: (7a) *(u64 *)(r10 -8) = 0
+  1: (bf) r2 = r10
+  2: (07) r2 += -8
+  3: (b7) r1 = 0x0
+  4: (85) call 1
+  fd 0 is not pointing to valid bpf_map
+
+Program that doesn't check return value of map_lookup_elem() before accessing
+map element:
+  BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+  BPF_LD_MAP_FD(BPF_REG_1, 0),
+  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+  BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
+  BPF_EXIT_INSN(),
+Error:
+  0: (7a) *(u64 *)(r10 -8) = 0
+  1: (bf) r2 = r10
+  2: (07) r2 += -8
+  3: (b7) r1 = 0x0
+  4: (85) call 1
+  5: (7a) *(u64 *)(r0 +0) = 0
+  R0 invalid mem access 'map_value_or_null'
+
+Program that correctly checks map_lookup_elem() returned value for NULL, but
+accesses the memory with incorrect alignment:
+  BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+  BPF_LD_MAP_FD(BPF_REG_1, 0),
+  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+  BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+  BPF_ST_MEM(BPF_DW, BPF_REG_0, 4, 0),
+  BPF_EXIT_INSN(),
+Error:
+  0: (7a) *(u64 *)(r10 -8) = 0
+  1: (bf) r2 = r10
+  2: (07) r2 += -8
+  3: (b7) r1 = 1
+  4: (85) call 1
+  5: (15) if r0 == 0x0 goto pc+1
+   R0=map_ptr R10=fp
+  6: (7a) *(u64 *)(r0 +4) = 0
+  misaligned access off 4 size 8
+
+Program that correctly checks map_lookup_elem() returned value for NULL and
+accesses memory with correct alignment in one side of 'if' branch, but fails
+to do so in the other side of 'if' branch:
+  BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+  BPF_LD_MAP_FD(BPF_REG_1, 0),
+  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+  BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+  BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
+  BPF_EXIT_INSN(),
+  BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 1),
+  BPF_EXIT_INSN(),
+Error:
+  0: (7a) *(u64 *)(r10 -8) = 0
+  1: (bf) r2 = r10
+  2: (07) r2 += -8
+  3: (b7) r1 = 1
+  4: (85) call 1
+  5: (15) if r0 == 0x0 goto pc+2
+   R0=map_ptr R10=fp
+  6: (7a) *(u64 *)(r0 +0) = 0
+  7: (95) exit
+
+  from 5 to 8: R0=imm0 R10=fp
+  8: (7a) *(u64 *)(r0 +0) = 1
+  R0 invalid mem access 'imm'
+
 Testing
 -------
 
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 92979182be81..9dfeb36f8971 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -83,5 +83,7 @@ struct bpf_prog_aux {
 
 void bpf_prog_put(struct bpf_prog *prog);
 struct bpf_prog *bpf_prog_get(u32 ufd);
+/* verify correctness of eBPF program */
+int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
 
 #endif /* _LINUX_BPF_H */
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index e9f7334ed07a..3c726b0995b7 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1 +1 @@
-obj-y := core.o syscall.o
+obj-y := core.o syscall.o verifier.o
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 158d3aca29e4..10a50453d101 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -500,7 +500,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 		goto free_prog;
 
 	/* run eBPF verifier */
-	/* err = bpf_check(prog, tb); */
+	err = bpf_check(prog, attr);
 
 	if (err < 0)
 		goto free_used_maps;
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
new file mode 100644
index 000000000000..d6f9c3d6b4d7
--- /dev/null
+++ b/kernel/bpf/verifier.c
@@ -0,0 +1,133 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/bpf.h>
+#include <linux/filter.h>
+#include <net/netlink.h>
+#include <linux/file.h>
+#include <linux/vmalloc.h>
+
+/* bpf_check() is a static code analyzer that walks eBPF program
+ * instruction by instruction and updates register/stack state.
+ * All paths of conditional branches are analyzed until 'bpf_exit' insn.
+ *
+ * The first pass is depth-first-search to check that the program is a DAG.
+ * It rejects the following programs:
+ * - larger than BPF_MAXINSNS insns
+ * - if loop is present (detected via back-edge)
+ * - unreachable insns exist (shouldn't be a forest. program = one function)
+ * - out of bounds or malformed jumps
+ * The second pass is all possible path descent from the 1st insn.
+ * Since it's analyzing all pathes through the program, the length of the
+ * analysis is limited to 32k insn, which may be hit even if total number of
+ * insn is less then 4K, but there are too many branches that change stack/regs.
+ * Number of 'branches to be analyzed' is limited to 1k
+ *
+ * On entry to each instruction, each register has a type, and the instruction
+ * changes the types of the registers depending on instruction semantics.
+ * If instruction is BPF_MOV64_REG(BPF_REG_1, BPF_REG_5), then type of R5 is
+ * copied to R1.
+ *
+ * All registers are 64-bit.
+ * R0 - return register
+ * R1-R5 argument passing registers
+ * R6-R9 callee saved registers
+ * R10 - frame pointer read-only
+ *
+ * At the start of BPF program the register R1 contains a pointer to bpf_context
+ * and has type PTR_TO_CTX.
+ *
+ * Verifier tracks arithmetic operations on pointers in case:
+ *    BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+ *    BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -20),
+ * 1st insn copies R10 (which has FRAME_PTR) type into R1
+ * and 2nd arithmetic instruction is pattern matched to recognize
+ * that it wants to construct a pointer to some element within stack.
+ * So after 2nd insn, the register R1 has type PTR_TO_STACK
+ * (and -20 constant is saved for further stack bounds checking).
+ * Meaning that this reg is a pointer to stack plus known immediate constant.
+ *
+ * Most of the time the registers have UNKNOWN_VALUE type, which
+ * means the register has some value, but it's not a valid pointer.
+ * (like pointer plus pointer becomes UNKNOWN_VALUE type)
+ *
+ * When verifier sees load or store instructions the type of base register
+ * can be: PTR_TO_MAP_VALUE, PTR_TO_CTX, FRAME_PTR. These are three pointer
+ * types recognized by check_mem_access() function.
+ *
+ * PTR_TO_MAP_VALUE means that this register is pointing to 'map element value'
+ * and the range of [ptr, ptr + map's value_size) is accessible.
+ *
+ * registers used to pass values to function calls are checked against
+ * function argument constraints.
+ *
+ * ARG_PTR_TO_MAP_KEY is one of such argument constraints.
+ * It means that the register type passed to this function must be
+ * PTR_TO_STACK and it will be used inside the function as
+ * 'pointer to map element key'
+ *
+ * For example the argument constraints for bpf_map_lookup_elem():
+ *   .ret_type = RET_PTR_TO_MAP_VALUE_OR_NULL,
+ *   .arg1_type = ARG_CONST_MAP_PTR,
+ *   .arg2_type = ARG_PTR_TO_MAP_KEY,
+ *
+ * ret_type says that this function returns 'pointer to map elem value or null'
+ * function expects 1st argument to be a const pointer to 'struct bpf_map' and
+ * 2nd argument should be a pointer to stack, which will be used inside
+ * the helper function as a pointer to map element key.
+ *
+ * On the kernel side the helper function looks like:
+ * u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+ * {
+ *    struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
+ *    void *key = (void *) (unsigned long) r2;
+ *    void *value;
+ *
+ *    here kernel can access 'key' and 'map' pointers safely, knowing that
+ *    [key, key + map->key_size) bytes are valid and were initialized on
+ *    the stack of eBPF program.
+ * }
+ *
+ * Corresponding eBPF program may look like:
+ *    BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),  // after this insn R2 type is FRAME_PTR
+ *    BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4), // after this insn R2 type is PTR_TO_STACK
+ *    BPF_LD_MAP_FD(BPF_REG_1, map_fd),      // after this insn R1 type is CONST_PTR_TO_MAP
+ *    BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+ * here verifier looks at prototype of map_lookup_elem() and sees:
+ * .arg1_type == ARG_CONST_MAP_PTR and R1->type == CONST_PTR_TO_MAP, which is ok,
+ * Now verifier knows that this map has key of R1->map_ptr->key_size bytes
+ *
+ * Then .arg2_type == ARG_PTR_TO_MAP_KEY and R2->type == PTR_TO_STACK, ok so far,
+ * Now verifier checks that [R2, R2 + map's key_size) are within stack limits
+ * and were initialized prior to this call.
+ * If it's ok, then verifier allows this BPF_CALL insn and looks at
+ * .ret_type which is RET_PTR_TO_MAP_VALUE_OR_NULL, so it sets
+ * R0->type = PTR_TO_MAP_VALUE_OR_NULL which means bpf_map_lookup_elem() function
+ * returns ether pointer to map value or NULL.
+ *
+ * When type PTR_TO_MAP_VALUE_OR_NULL passes through 'if (reg != 0) goto +off'
+ * insn, the register holding that pointer in the true branch changes state to
+ * PTR_TO_MAP_VALUE and the same register changes state to CONST_IMM in the false
+ * branch. See check_cond_jmp_op().
+ *
+ * After the call R0 is set to return type of the function and registers R1-R5
+ * are set to NOT_INIT to indicate that they are no longer readable.
+ */
+
+int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
+{
+	int ret = -EINVAL;
+
+	return ret;
+}
-- 
1.7.9.5
