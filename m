From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v4 net-next 09/26] bpf: verifier (add docs)
Date: Wed, 13 Aug 2014 00:57:20 -0700
Message-ID: <1407916658-8731-10-git-send-email-ast@plumgrid.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
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

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 Documentation/networking/filter.txt |  230 +++++++++++++++++++++++++++++++++++
 include/linux/bpf.h                 |    2 +
 kernel/bpf/Makefile                 |    2 +-
 kernel/bpf/syscall.c                |    2 +-
 kernel/bpf/verifier.c               |  151 +++++++++++++++++++++++
 5 files changed, 385 insertions(+), 2 deletions(-)
 create mode 100644 kernel/bpf/verifier.c

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 27a0a6c6acb4..b121b01c3af4 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -1001,6 +1001,105 @@ instruction that loads 64-bit immediate value into a dst_reg.
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
+Classic BPF register X is mapped to eBPF register R7 inside sk_convert_filter(),
+so that its state is preserved across calls.
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
+At the start R1 contains pointer to ctx and R1 type is PTR_TO_CTX.
+ctx is generic. verifier is configured to known what context is for particular
+class of bpf programs. For example, context == skb (for socket filters) and
+ctx == seccomp_data for seccomp filters.
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
+from security point of view. The verifier will guarantee that the function is
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
@@ -1072,6 +1171,137 @@ size. It will not let programs pass junk values to bpf_map_*_elem() functions,
 so these functions (implemented in C inside kernel) can safely access
 the pointers in all cases.
 
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
index ac6320f44812..d818e473d12c 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -82,5 +82,7 @@ struct bpf_prog;
 
 void bpf_prog_put(struct bpf_prog *prog);
 struct bpf_prog *bpf_prog_get(u32 ufd);
+/* verify correctness of eBPF program */
+int bpf_check(struct bpf_prog *fp, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1]);
 
 #endif /* _LINUX_BPF_H */
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index 558e12712ebc..95a9035e0f29 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1 +1 @@
-obj-y := core.o syscall.o hashtab.o
+obj-y := core.o syscall.o hashtab.o verifier.o
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 5a336af61858..a3581646ee11 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -514,7 +514,7 @@ static int bpf_prog_load(enum bpf_prog_type type, struct nlattr __user *uattr,
 		goto free_prog_info;
 
 	/* run eBPF verifier */
-	/* err = bpf_check(prog, tb); */
+	err = bpf_check(prog, tb);
 
 	if (err < 0)
 		goto free_prog_info;
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
new file mode 100644
index 000000000000..cf8a0131cd91
--- /dev/null
+++ b/kernel/bpf/verifier.c
@@ -0,0 +1,151 @@
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
+
+/* bpf_check() is a static code analyzer that walks eBPF program
+ * instruction by instruction and updates register/stack state.
+ * All paths of conditional branches are analyzed until 'bpf_exit' insn.
+ *
+ * At the first pass depth-first-search verifies that the BPF program is a DAG.
+ * It rejects the following programs:
+ * - larger than BPF_MAXINSNS insns
+ * - if loop is present (detected via back-edge)
+ * - unreachable insns exist (shouldn't be a forest. program = one function)
+ * - out of bounds or malformed jumps
+ * The second pass is all possible path descent from the 1st insn.
+ * Conditional branch target insns keep a link list of verifier states.
+ * If the state already visited, this path can be pruned.
+ * If it wasn't a DAG, such state prunning would be incorrect, since it would
+ * skip cycles. Since it's analyzing all pathes through the program,
+ * the length of the analysis is limited to 32k insn, which may be hit even
+ * if insn_cnt < 4K, but there are too many branches that change stack/regs.
+ * Number of 'branches to be analyzed' is limited to 1k
+ *
+ * On entry to each instruction, each register has a type, and the instruction
+ * changes the types of the registers depending on instruction semantics.
+ * If instruction is BPF_MOV64_REG(BPF_REG_1, BPF_REG_5), then type of R5 is
+ * copied to R1.
+ *
+ * All registers are 64-bit (even on 32-bit arch)
+ * R0 - return register
+ * R1-R5 argument passing registers
+ * R6-R9 callee saved registers
+ * R10 - frame pointer read-only
+ *
+ * At the start of BPF program the register R1 contains a pointer to bpf_context
+ * and has type PTR_TO_CTX.
+ *
+ * Most of the time the registers have UNKNOWN_VALUE type, which
+ * means the register has some value, but it's not a valid pointer.
+ * Verifier doesn't attemp to track all arithmetic operations on pointers.
+ * The only special case is the sequence:
+ *    BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+ *    BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -20),
+ * 1st insn copies R10 (which has FRAME_PTR) type into R1
+ * and 2nd arithmetic instruction is pattern matched to recognize
+ * that it wants to construct a pointer to some element within stack.
+ * So after 2nd insn, the register R1 has type PTR_TO_STACK
+ * (and -20 constant is saved for further stack bounds checking).
+ * Meaning that this reg is a pointer to stack plus known immediate constant.
+ *
+ * When program is doing load or store insns the type of base register can be:
+ * PTR_TO_MAP_VALUE, PTR_TO_CTX, FRAME_PTR. These are three pointer types recognized
+ * by check_mem_access() function.
+ *
+ * PTR_TO_MAP_VALUE means that this register is pointing to 'map element value'
+ * and the range of [ptr, ptr + map's value_size) is accessible.
+ *
+ * registers used to pass pointers to function calls are verified against
+ * function prototypes
+ *
+ * ARG_PTR_TO_MAP_KEY is a function argument constraint.
+ * It means that the register type passed to this function must be
+ * PTR_TO_STACK and it will be used inside the function as
+ * 'pointer to map element key'
+ *
+ * For example the argument constraints for bpf_map_lookup_elem():
+ *   .ret_type = RET_PTR_TO_MAP_VALUE_OR_NULL,
+ *   .arg1_type = ARG_CONST_MAP_ID,
+ *   .arg2_type = ARG_PTR_TO_MAP_KEY,
+ *
+ * ret_type says that this function returns 'pointer to map elem value or null'
+ * 1st argument is a 'const immediate' value which must be one of valid map_ids.
+ * 2nd argument is a pointer to stack, which will be used inside the function as
+ * a pointer to map element key.
+ *
+ * On the kernel side the helper function looks like:
+ * u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+ * {
+ *    struct bpf_map *map;
+ *    int map_id = r1;
+ *    void *key = (void *) (unsigned long) r2;
+ *    void *value;
+ *
+ *    here kernel can access 'key' pointer safely, knowing that
+ *    [key, key + map->key_size) bytes are valid and were initialized on
+ *    the stack of eBPF program.
+ * }
+ *
+ * Corresponding eBPF program looked like:
+ *    BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),  // after this insn R2 type is FRAME_PTR
+ *    BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4), // after this insn R2 type is PTR_TO_STACK
+ *    BPF_MOV64_IMM(BPF_REG_1, MAP_ID),      // after this insn R1 type is CONST_ARG
+ *    BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+ * here verifier looks a prototype of map_lookup_elem and sees:
+ * .arg1_type == ARG_CONST_MAP_ID and R1->type == CONST_ARG, which is ok so far,
+ * then it goes and finds a map with map_id equal to R1->imm value.
+ * Now verifier knows that this map has key of key_size bytes
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
+ *
+ * load/store alignment is checked:
+ *    BPF_STX_MEM(BPF_DW, dest_reg, src_reg, 3)
+ * is rejected, because it's misaligned
+ *
+ * load/store to stack are bounds checked and register spill is tracked
+ *    BPF_STX_MEM(BPF_B, BPF_REG_10, src_reg, 0)
+ * is rejected, because it's out of bounds
+ *
+ * load/store to map are bounds checked:
+ *    BPF_STX_MEM(BPF_H, dest_reg, src_reg, 8)
+ * is ok, if dest_reg->type == PTR_TO_MAP_VALUE and
+ * 8 + sizeof(u16) <= map_info->value_size
+ *
+ * load/store to bpf_context are checked against known fields
+ */
+
+int bpf_check(struct bpf_prog *prog, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1])
+{
+	int ret = -EINVAL;
+
+	return ret;
+}
-- 
1.7.9.5
