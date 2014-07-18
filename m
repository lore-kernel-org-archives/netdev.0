From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v2 net-next 10/16] bpf: add eBPF verifier
Date: Thu, 17 Jul 2014 21:20:00 -0700
Message-ID: <1405657206-12060-11-git-send-email-ast@plumgrid.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
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
In-Reply-To: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Safety of eBPF programs is statically determined by the verifier, which detects:
- loops
- out of range jumps
- unreachable instructions
- invalid instructions
- uninitialized register access
- uninitialized stack access
- misaligned stack access
- out of range stack access
- invalid calling convention

It checks that
- R1-R5 registers statisfy function prototype
- program terminates
- BPF_LD_ABS|IND instructions are only used in socket filters

It is configured with:

- bool (*is_valid_access)(int off, int size, enum bpf_access_type type);
  that provides information to the verifer which fields of 'ctx'
  are accessible (remember 'ctx' is the first argument to eBPF program)

- const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
  reports argument types of kernel helper functions that eBPF program
  may call, so that verifier can checks that R1-R5 types match prototype

More details in Documentation/networking/filter.txt

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 Documentation/networking/filter.txt |  233 ++++++
 include/linux/bpf.h                 |   49 ++
 include/uapi/linux/bpf.h            |    1 +
 kernel/bpf/Makefile                 |    2 +-
 kernel/bpf/syscall.c                |    2 +-
 kernel/bpf/verifier.c               | 1520 +++++++++++++++++++++++++++++++++++
 6 files changed, 1805 insertions(+), 2 deletions(-)
 create mode 100644 kernel/bpf/verifier.c

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index e14e486f69cd..778f763fce10 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -995,6 +995,108 @@ BPF_XADD | BPF_DW | BPF_STX: lock xadd *(u64 *)(dst_reg + off16) += src_reg
 Where size is one of: BPF_B or BPF_H or BPF_W or BPF_DW. Note that 1 and
 2 byte atomic increments are not supported.
 
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
+If R1=PTR_TO_CTX and insn is R2=R1+R1, then R2=INVALID_PTR,
+since addition of two valid pointers makes invalid pointer.
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
+are PTR_TO_CTX, PTR_TO_MAP, PTR_TO_STACK. They are bounds and alignment checked.
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
+If R6=PTR_TO_STACK, then access should be aligned and be within
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
+Though R10 is correct read-only register and has type PTR_TO_STACK
+and R10 - 4 is within stack bounds, there were no stores into that location.
+
+Pointer register spill/fill is tracked as well, since four (R6-R9)
+callee saved registers may not be enough for some programs.
+
+Allowed function calls are customized with bpf_verifier_ops->get_func_proto()
+For example, skb_get_nlattr() function has the following definition:
+  struct bpf_func_proto proto = {RET_INTEGER, PTR_TO_CTX};
+and eBPF verifier will check that this function is always called with first
+argument being 'ctx'. In other words R1 must have type PTR_TO_CTX
+at the time of bpf_call insn.
+After the call register R0 will be set to readable state, so that
+program can access it.
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
@@ -1064,6 +1166,137 @@ size. It will not let programs pass junk values as 'key' and 'value' to
 bpf_map_*_elem() functions, so these functions (implemented in C inside kernel)
 can safely access the pointers in all cases.
 
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
+  BPF_ALU64_REG(BPF_MOV, BPF_REG_0, BPF_REG_2),
+  BPF_EXIT_INSN(),
+Error:
+  0: (bf) r0 = r2
+  R2 !read_ok
+
+Program that doesn't initialize R0 before exiting:
+  BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_1),
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
+  BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+  BPF_ALU64_IMM(BPF_MOV, BPF_REG_1, 1),
+  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+  BPF_EXIT_INSN(),
+Error:
+  0: (bf) r2 = r10
+  1: (07) r2 += -8
+  2: (b7) r1 = 1
+  3: (85) call 1
+  invalid indirect read from stack off -8+0 size 8
+
+Program that uses invalid map_id=2 while calling to map_lookup_elem() function:
+  BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+  BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+  BPF_ALU64_IMM(BPF_MOV, BPF_REG_1, 2),
+  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+  BPF_EXIT_INSN(),
+Error:
+  0: (7a) *(u64 *)(r10 -8) = 0
+  1: (bf) r2 = r10
+  2: (07) r2 += -8
+  3: (b7) r1 = 2
+  4: (85) call 1
+  invalid access to map_id=2
+
+Program that doesn't check return value of map_lookup_elem() before accessing
+map element:
+  BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+  BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+  BPF_ALU64_IMM(BPF_MOV, BPF_REG_1, 1),
+  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+  BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
+  BPF_EXIT_INSN(),
+Error:
+  0: (7a) *(u64 *)(r10 -8) = 0
+  1: (bf) r2 = r10
+  2: (07) r2 += -8
+  3: (b7) r1 = 1
+  4: (85) call 1
+  5: (7a) *(u64 *)(r0 +0) = 0
+  R0 invalid mem access 'map_value_or_null'
+
+Program that correctly checks map_lookup_elem() returned value for NULL, but
+accesses the memory with incorrect alignment:
+  BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+  BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+  BPF_ALU64_IMM(BPF_MOV, BPF_REG_1, 1),
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
+   R0=map_value1 R10=fp
+  6: (7a) *(u64 *)(r0 +4) = 0
+  misaligned access off 4 size 8
+
+Program that correctly checks map_lookup_elem() returned value for NULL and
+accesses memory with correct alignment in one side of 'if' branch, but fails
+to do so in the other side of 'if' branch:
+  BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+  BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+  BPF_ALU64_IMM(BPF_MOV, BPF_REG_1, 1),
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
+   R0=map_value1 R10=fp
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
index 4967619595cc..b5e90efddfcf 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -46,6 +46,31 @@ struct bpf_map_type_list {
 void bpf_register_map_type(struct bpf_map_type_list *tl);
 struct bpf_map *bpf_map_get(u32 map_id);
 
+/* function argument constraints */
+enum bpf_arg_type {
+	ARG_ANYTHING = 0,	/* any argument is ok */
+
+	/* the following constraints used to prototype
+	 * bpf_map_lookup/update/delete_elem() functions
+	 */
+	ARG_CONST_MAP_ID,	/* int const argument used as map_id */
+	ARG_PTR_TO_MAP_KEY,	/* pointer to stack used as map key */
+	ARG_PTR_TO_MAP_VALUE,	/* pointer to stack used as map value */
+
+	/* the following constraints used to prototype bpf_memcmp() and other
+	 * functions that access data on eBPF program stack
+	 */
+	ARG_PTR_TO_STACK,	/* any pointer to eBPF program stack */
+	ARG_CONST_STACK_SIZE,	/* number of bytes accessed from stack */
+};
+
+/* type of values returned from helper functions */
+enum bpf_return_type {
+	RET_INTEGER,		/* function returns integer */
+	RET_VOID,		/* function doesn't return anything */
+	RET_PTR_TO_MAP_OR_NULL,	/* function returns a pointer to map elem value or NULL */
+};
+
 /* eBPF function prototype used by verifier to allow BPF_CALLs from eBPF programs
  * to in-kernel helper functions and for adjusting imm32 field in BPF_CALL
  * instructions after verifying
@@ -53,11 +78,33 @@ struct bpf_map *bpf_map_get(u32 map_id);
 struct bpf_func_proto {
 	u64 (*func)(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 	bool gpl_only;
+	enum bpf_return_type ret_type;
+	enum bpf_arg_type arg1_type;
+	enum bpf_arg_type arg2_type;
+	enum bpf_arg_type arg3_type;
+	enum bpf_arg_type arg4_type;
+	enum bpf_arg_type arg5_type;
+};
+
+/* bpf_context is intentionally undefined structure. Pointer to bpf_context is
+ * the first argument to eBPF programs.
+ * For socket filters: 'struct bpf_context *' == 'struct sk_buff *'
+ */
+struct bpf_context;
+
+enum bpf_access_type {
+	BPF_READ = 1,
+	BPF_WRITE = 2
 };
 
 struct bpf_verifier_ops {
 	/* return eBPF function prototype for verification */
 	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
+
+	/* return true if 'size' wide access at offset 'off' within bpf_context
+	 * with 'type' (read or write) is allowed
+	 */
+	bool (*is_valid_access)(int off, int size, enum bpf_access_type type);
 };
 
 struct bpf_prog_type_list {
@@ -78,5 +125,7 @@ struct bpf_prog_info {
 
 void free_bpf_prog_info(struct bpf_prog_info *info);
 struct sk_filter *bpf_prog_get(u32 ufd);
+/* verify correctness of eBPF program */
+int bpf_check(struct sk_filter *fp);
 
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 06ba71b49f64..3f288e1d08f1 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -369,6 +369,7 @@ enum bpf_prog_attributes {
 
 enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
+	BPF_PROG_TYPE_SOCKET_FILTER,
 };
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index 558e12712ebc..95a9035e0f29 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1 +1 @@
-obj-y := core.o syscall.o hashtab.o
+obj-y := core.o syscall.o hashtab.o verifier.o
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 9e45ca6b6937..9d441f17548e 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -634,7 +634,7 @@ static int bpf_prog_load(enum bpf_prog_type type, struct nlattr __user *uattr,
 	mutex_lock(&bpf_map_lock);
 
 	/* run eBPF verifier */
-	/* err = bpf_check(prog); */
+	err = bpf_check(prog);
 
 	if (err == 0 && prog->info->used_maps) {
 		/* program passed verifier and it's using some maps,
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
new file mode 100644
index 000000000000..0fce771632b4
--- /dev/null
+++ b/kernel/bpf/verifier.c
@@ -0,0 +1,1520 @@
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
+#include <linux/capability.h>
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
+ * PTR_TO_MAP, PTR_TO_CTX, FRAME_PTR. These are three pointer types recognized
+ * by check_mem_access() function.
+ *
+ * PTR_TO_MAP means that this register is pointing to 'map element value'
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
+ *   .ret_type = RET_PTR_TO_MAP_OR_NULL,
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
+ * .ret_type which is RET_PTR_TO_MAP_OR_NULL, so it sets
+ * R0->type = PTR_TO_MAP_OR_NULL which means bpf_map_lookup_elem() function
+ * returns ether pointer to map value or NULL.
+ *
+ * When type PTR_TO_MAP_OR_NULL passes through 'if (reg != 0) goto +off' insn,
+ * the register holding that pointer in the true branch changes state to
+ * PTR_TO_MAP and the same register changes state to CONST_IMM in the false
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
+ * is ok, if dest_reg->type == PTR_TO_MAP and
+ * 8 + sizeof(u16) <= map_info->value_size
+ *
+ * load/store to bpf_context are checked against known fields
+ */
+
+#define _(OP) ({ int ret = OP; if (ret < 0) return ret; })
+
+/* types of values stored in eBPF registers */
+enum bpf_reg_type {
+	NOT_INIT = 0,		/* nothing was written into register */
+	UNKNOWN_VALUE,		/* reg doesn't contain a valid pointer */
+	PTR_TO_CTX,		/* reg points to bpf_context */
+	PTR_TO_MAP,		/* reg points to map element value */
+	PTR_TO_MAP_OR_NULL,	/* points to map element value or NULL */
+	FRAME_PTR,		/* reg == frame_pointer */
+	PTR_TO_STACK,		/* reg == frame_pointer + imm */
+	CONST_IMM,		/* constant integer value */
+};
+
+struct reg_state {
+	enum bpf_reg_type type;
+	int imm;
+};
+
+enum bpf_stack_slot_type {
+	STACK_INVALID,    /* nothing was stored in this stack slot */
+	STACK_SPILL,      /* 1st byte of register spilled into stack */
+	STACK_SPILL_PART, /* other 7 bytes of register spill */
+	STACK_MISC	  /* BPF program wrote some data into this slot */
+};
+
+struct bpf_stack_slot {
+	enum bpf_stack_slot_type stype;
+	enum bpf_reg_type type;
+	int imm;
+};
+
+/* state of the program:
+ * type of all registers and stack info
+ */
+struct verifier_state {
+	struct reg_state regs[MAX_BPF_REG];
+	struct bpf_stack_slot stack[MAX_BPF_STACK];
+};
+
+/* linked list of verifier states used to prune search */
+struct verifier_state_list {
+	struct verifier_state state;
+	struct verifier_state_list *next;
+};
+
+/* verifier_state + insn_idx are pushed to stack when branch is encountered */
+struct verifier_stack_elem {
+	/* verifer state is 'st'
+	 * before processing instruction 'insn_idx'
+	 * and after processing instruction 'prev_insn_idx'
+	 */
+	struct verifier_state st;
+	int insn_idx;
+	int prev_insn_idx;
+	struct verifier_stack_elem *next;
+};
+
+#define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
+
+/* single container for all structs
+ * one verifier_env per bpf_check() call
+ */
+struct verifier_env {
+	struct sk_filter *prog;		/* eBPF program being verified */
+	struct verifier_stack_elem *head; /* stack of verifier states to be processed */
+	int stack_size;			/* number of states to be processed */
+	struct verifier_state cur_state; /* current verifier state */
+	struct verifier_state_list **branch_landing; /* search prunning optimization */
+	u32 used_maps[MAX_USED_MAPS];	/* array of map_id's used by eBPF program */
+	u32 used_map_cnt;		/* number of used maps */
+};
+
+/* verbose verifier prints what it's seeing
+ * bpf_check() is called under map lock, so no race to access this global var
+ */
+static bool verbose_on;
+
+/* when verifier rejects eBPF program, it does a second path with verbose on
+ * to dump the verification trace to the log, so the user can figure out what's
+ * wrong with the program
+ */
+static int verbose(const char *fmt, ...)
+{
+	va_list args;
+	int ret;
+
+	if (!verbose_on)
+		return 0;
+
+	va_start(args, fmt);
+	ret = vprintk(fmt, args);
+	va_end(args);
+	return ret;
+}
+
+/* string representation of 'enum bpf_reg_type' */
+static const char * const reg_type_str[] = {
+	[NOT_INIT] = "?",
+	[UNKNOWN_VALUE] = "inv",
+	[PTR_TO_CTX] = "ctx",
+	[PTR_TO_MAP] = "map_value",
+	[PTR_TO_MAP_OR_NULL] = "map_value_or_null",
+	[FRAME_PTR] = "fp",
+	[PTR_TO_STACK] = "fp",
+	[CONST_IMM] = "imm",
+};
+
+static void pr_cont_verifier_state(struct verifier_env *env)
+{
+	enum bpf_reg_type t;
+	int i;
+
+	for (i = 0; i < MAX_BPF_REG; i++) {
+		t = env->cur_state.regs[i].type;
+		if (t == NOT_INIT)
+			continue;
+		pr_cont(" R%d=%s", i, reg_type_str[t]);
+		if (t == CONST_IMM ||
+		    t == PTR_TO_STACK ||
+		    t == PTR_TO_MAP_OR_NULL ||
+		    t == PTR_TO_MAP)
+			pr_cont("%d", env->cur_state.regs[i].imm);
+	}
+	for (i = 0; i < MAX_BPF_STACK; i++) {
+		if (env->cur_state.stack[i].stype == STACK_SPILL)
+			pr_cont(" fp%d=%s", -MAX_BPF_STACK + i,
+				reg_type_str[env->cur_state.stack[i].type]);
+	}
+	pr_cont("\n");
+}
+
+static const char *const bpf_class_string[] = {
+	"ld", "ldx", "st", "stx", "alu", "jmp", "BUG", "alu64"
+};
+
+static const char *const bpf_alu_string[] = {
+	"+=", "-=", "*=", "/=", "|=", "&=", "<<=", ">>=", "neg",
+	"%=", "^=", "=", "s>>=", "endian", "BUG", "BUG"
+};
+
+static const char *const bpf_ldst_string[] = {
+	"u32", "u16", "u8", "u64"
+};
+
+static const char *const bpf_jmp_string[] = {
+	"jmp", "==", ">", ">=", "&", "!=", "s>", "s>=", "call", "exit"
+};
+
+static void pr_cont_bpf_insn(struct bpf_insn *insn)
+{
+	u8 class = BPF_CLASS(insn->code);
+
+	if (class == BPF_ALU || class == BPF_ALU64) {
+		if (BPF_SRC(insn->code) == BPF_X)
+			pr_cont("(%02x) %sr%d %s %sr%d\n",
+				insn->code, class == BPF_ALU ? "(u32) " : "",
+				insn->dst_reg,
+				bpf_alu_string[BPF_OP(insn->code) >> 4],
+				class == BPF_ALU ? "(u32) " : "",
+				insn->src_reg);
+		else
+			pr_cont("(%02x) %sr%d %s %s%d\n",
+				insn->code, class == BPF_ALU ? "(u32) " : "",
+				insn->dst_reg,
+				bpf_alu_string[BPF_OP(insn->code) >> 4],
+				class == BPF_ALU ? "(u32) " : "",
+				insn->imm);
+	} else if (class == BPF_STX) {
+		if (BPF_MODE(insn->code) == BPF_MEM)
+			pr_cont("(%02x) *(%s *)(r%d %+d) = r%d\n",
+				insn->code,
+				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				insn->dst_reg,
+				insn->off, insn->src_reg);
+		else if (BPF_MODE(insn->code) == BPF_XADD)
+			pr_cont("(%02x) lock *(%s *)(r%d %+d) += r%d\n",
+				insn->code,
+				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				insn->dst_reg, insn->off,
+				insn->src_reg);
+		else
+			pr_cont("BUG_%02x\n", insn->code);
+	} else if (class == BPF_ST) {
+		if (BPF_MODE(insn->code) != BPF_MEM) {
+			pr_cont("BUG_st_%02x\n", insn->code);
+			return;
+		}
+		pr_cont("(%02x) *(%s *)(r%d %+d) = %d\n",
+			insn->code,
+			bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+			insn->dst_reg,
+			insn->off, insn->imm);
+	} else if (class == BPF_LDX) {
+		if (BPF_MODE(insn->code) != BPF_MEM) {
+			pr_cont("BUG_ldx_%02x\n", insn->code);
+			return;
+		}
+		pr_cont("(%02x) r%d = *(%s *)(r%d %+d)\n",
+			insn->code, insn->dst_reg,
+			bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+			insn->src_reg, insn->off);
+	} else if (class == BPF_LD) {
+		if (BPF_MODE(insn->code) == BPF_ABS) {
+			pr_cont("(%02x) r0 = *(%s *)skb[%d]\n",
+				insn->code,
+				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				insn->imm);
+		} else if (BPF_MODE(insn->code) == BPF_IND) {
+			pr_cont("(%02x) r0 = *(%s *)skb[r%d + %d]\n",
+				insn->code,
+				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				insn->src_reg, insn->imm);
+		} else {
+			pr_cont("BUG_ld_%02x\n", insn->code);
+			return;
+		}
+	} else if (class == BPF_JMP) {
+		u8 opcode = BPF_OP(insn->code);
+
+		if (opcode == BPF_CALL) {
+			pr_cont("(%02x) call %d\n", insn->code, insn->imm);
+		} else if (insn->code == (BPF_JMP | BPF_JA)) {
+			pr_cont("(%02x) goto pc%+d\n",
+				insn->code, insn->off);
+		} else if (insn->code == (BPF_JMP | BPF_EXIT)) {
+			pr_cont("(%02x) exit\n", insn->code);
+		} else if (BPF_SRC(insn->code) == BPF_X) {
+			pr_cont("(%02x) if r%d %s r%d goto pc%+d\n",
+				insn->code, insn->dst_reg,
+				bpf_jmp_string[BPF_OP(insn->code) >> 4],
+				insn->src_reg, insn->off);
+		} else {
+			pr_cont("(%02x) if r%d %s 0x%x goto pc%+d\n",
+				insn->code, insn->dst_reg,
+				bpf_jmp_string[BPF_OP(insn->code) >> 4],
+				insn->imm, insn->off);
+		}
+	} else {
+		pr_cont("(%02x) %s\n", insn->code, bpf_class_string[class]);
+	}
+}
+
+static int pop_stack(struct verifier_env *env, int *prev_insn_idx)
+{
+	struct verifier_stack_elem *elem;
+	int insn_idx;
+
+	if (env->head == NULL)
+		return -1;
+
+	memcpy(&env->cur_state, &env->head->st, sizeof(env->cur_state));
+	insn_idx = env->head->insn_idx;
+	if (prev_insn_idx)
+		*prev_insn_idx = env->head->prev_insn_idx;
+	elem = env->head->next;
+	kfree(env->head);
+	env->head = elem;
+	env->stack_size--;
+	return insn_idx;
+}
+
+static struct verifier_state *push_stack(struct verifier_env *env, int insn_idx,
+					 int prev_insn_idx)
+{
+	struct verifier_stack_elem *elem;
+
+	elem = kmalloc(sizeof(struct verifier_stack_elem), GFP_KERNEL);
+	if (!elem)
+		goto err;
+
+	memcpy(&elem->st, &env->cur_state, sizeof(env->cur_state));
+	elem->insn_idx = insn_idx;
+	elem->prev_insn_idx = prev_insn_idx;
+	elem->next = env->head;
+	env->head = elem;
+	env->stack_size++;
+	if (env->stack_size > 1024) {
+		verbose("BPF program is too complex\n");
+		goto err;
+	}
+	return &elem->st;
+err:
+	/* pop all elements and return */
+	while (pop_stack(env, NULL) >= 0);
+	return NULL;
+}
+
+#define CALLER_SAVED_REGS 6
+static const int caller_saved[CALLER_SAVED_REGS] = {
+	BPF_REG_0, BPF_REG_1, BPF_REG_2, BPF_REG_3, BPF_REG_4, BPF_REG_5
+};
+
+static void init_reg_state(struct reg_state *regs)
+{
+	int i;
+
+	for (i = 0; i < MAX_BPF_REG; i++) {
+		regs[i].type = NOT_INIT;
+		regs[i].imm = 0;
+	}
+
+	/* frame pointer */
+	regs[BPF_REG_FP].type = FRAME_PTR;
+
+	/* 1st arg to a function */
+	regs[BPF_REG_1].type = PTR_TO_CTX;
+}
+
+static void mark_reg_unknown_value(struct reg_state *regs, int regno)
+{
+	regs[regno].type = UNKNOWN_VALUE;
+	regs[regno].imm = 0;
+}
+
+static int check_reg_arg(struct reg_state *regs, int regno, bool is_src)
+{
+	if (is_src) {
+		if (regs[regno].type == NOT_INIT) {
+			verbose("R%d !read_ok\n", regno);
+			return -EACCES;
+		}
+	} else {
+		if (regno == BPF_REG_FP)
+			/* frame pointer is read only */
+			return -EACCES;
+		mark_reg_unknown_value(regs, regno);
+	}
+	return 0;
+}
+
+static int bpf_size_to_bytes(int bpf_size)
+{
+	if (bpf_size == BPF_W)
+		return 4;
+	else if (bpf_size == BPF_H)
+		return 2;
+	else if (bpf_size == BPF_B)
+		return 1;
+	else if (bpf_size == BPF_DW)
+		return 8;
+	else
+		return -EACCES;
+}
+
+static int check_stack_write(struct verifier_state *state, int off, int size,
+			     int value_regno)
+{
+	struct bpf_stack_slot *slot;
+	int i;
+
+	if (value_regno >= 0 &&
+	    (state->regs[value_regno].type == PTR_TO_MAP ||
+	     state->regs[value_regno].type == PTR_TO_STACK ||
+	     state->regs[value_regno].type == PTR_TO_CTX)) {
+
+		/* register containing pointer is being spilled into stack */
+		if (size != 8) {
+			verbose("invalid size of register spill\n");
+			return -EACCES;
+		}
+
+		slot = &state->stack[MAX_BPF_STACK + off];
+		slot->stype = STACK_SPILL;
+		/* save register state */
+		slot->type = state->regs[value_regno].type;
+		slot->imm = state->regs[value_regno].imm;
+		for (i = 1; i < 8; i++) {
+			slot = &state->stack[MAX_BPF_STACK + off + i];
+			slot->stype = STACK_SPILL_PART;
+			slot->type = UNKNOWN_VALUE;
+			slot->imm = 0;
+		}
+	} else {
+
+		/* regular write of data into stack */
+		for (i = 0; i < size; i++) {
+			slot = &state->stack[MAX_BPF_STACK + off + i];
+			slot->stype = STACK_MISC;
+			slot->type = UNKNOWN_VALUE;
+			slot->imm = 0;
+		}
+	}
+	return 0;
+}
+
+static int check_stack_read(struct verifier_state *state, int off, int size,
+			    int value_regno)
+{
+	int i;
+	struct bpf_stack_slot *slot;
+
+	slot = &state->stack[MAX_BPF_STACK + off];
+
+	if (slot->stype == STACK_SPILL) {
+		if (size != 8) {
+			verbose("invalid size of register spill\n");
+			return -EACCES;
+		}
+		for (i = 1; i < 8; i++) {
+			if (state->stack[MAX_BPF_STACK + off + i].stype !=
+			    STACK_SPILL_PART) {
+				verbose("corrupted spill memory\n");
+				return -EACCES;
+			}
+		}
+
+		/* restore register state from stack */
+		state->regs[value_regno].type = slot->type;
+		state->regs[value_regno].imm = slot->imm;
+		return 0;
+	} else {
+		for (i = 0; i < size; i++) {
+			if (state->stack[MAX_BPF_STACK + off + i].stype !=
+			    STACK_MISC) {
+				verbose("invalid read from stack off %d+%d size %d\n",
+					off, i, size);
+				return -EACCES;
+			}
+		}
+		/* have read misc data from the stack */
+		mark_reg_unknown_value(state->regs, value_regno);
+		return 0;
+	}
+}
+
+static int remember_map_id(struct verifier_env *env, u32 map_id)
+{
+	int i;
+
+	/* check whether we recorded this map_id already */
+	for (i = 0; i < env->used_map_cnt; i++)
+		if (env->used_maps[i] == map_id)
+			return 0;
+
+	if (env->used_map_cnt >= MAX_USED_MAPS)
+		return -E2BIG;
+
+	/* remember this map_id */
+	env->used_maps[env->used_map_cnt++] = map_id;
+	return 0;
+}
+
+static int get_map_info(struct verifier_env *env, u32 map_id,
+			struct bpf_map **map)
+{
+	/* if BPF program contains bpf_map_lookup_elem(map_id, key)
+	 * the incorrect map_id will be caught here
+	 */
+	*map = bpf_map_get(map_id);
+	if (!*map) {
+		verbose("invalid access to map_id=%d\n", map_id);
+		return -EACCES;
+	}
+
+	_(remember_map_id(env, map_id));
+
+	return 0;
+}
+
+/* check read/write into map element returned by bpf_map_lookup_elem() */
+static int check_map_access(struct verifier_env *env, int regno, int off,
+			    int size)
+{
+	struct bpf_map *map;
+	int map_id = env->cur_state.regs[regno].imm;
+
+	_(get_map_info(env, map_id, &map));
+
+	if (off < 0 || off + size > map->value_size) {
+		verbose("invalid access to map_id=%d leaf_size=%d off=%d size=%d\n",
+			map_id, map->value_size, off, size);
+		return -EACCES;
+	}
+	return 0;
+}
+
+/* check access to 'struct bpf_context' fields */
+static int check_ctx_access(struct verifier_env *env, int off, int size,
+			    enum bpf_access_type t)
+{
+	if (env->prog->info->ops->is_valid_access &&
+	    env->prog->info->ops->is_valid_access(off, size, t))
+		return 0;
+
+	verbose("invalid bpf_context access off=%d size=%d\n", off, size);
+	return -EACCES;
+}
+
+static int check_mem_access(struct verifier_env *env, int regno, int off,
+			    int bpf_size, enum bpf_access_type t,
+			    int value_regno)
+{
+	struct verifier_state *state = &env->cur_state;
+	int size;
+
+	_(size = bpf_size_to_bytes(bpf_size));
+
+	if (off % size != 0) {
+		verbose("misaligned access off %d size %d\n", off, size);
+		return -EACCES;
+	}
+
+	if (state->regs[regno].type == PTR_TO_MAP) {
+		_(check_map_access(env, regno, off, size));
+		if (t == BPF_READ)
+			mark_reg_unknown_value(state->regs, value_regno);
+	} else if (state->regs[regno].type == PTR_TO_CTX) {
+		_(check_ctx_access(env, off, size, t));
+		if (t == BPF_READ)
+			mark_reg_unknown_value(state->regs, value_regno);
+	} else if (state->regs[regno].type == FRAME_PTR) {
+		if (off >= 0 || off < -MAX_BPF_STACK) {
+			verbose("invalid stack off=%d size=%d\n", off, size);
+			return -EACCES;
+		}
+		if (t == BPF_WRITE)
+			_(check_stack_write(state, off, size, value_regno));
+		else
+			_(check_stack_read(state, off, size, value_regno));
+	} else {
+		verbose("R%d invalid mem access '%s'\n",
+			regno, reg_type_str[state->regs[regno].type]);
+		return -EACCES;
+	}
+	return 0;
+}
+
+/* when register 'regno' is passed into function that will read 'access_size'
+ * bytes from that pointer, make sure that it's within stack boundary
+ * and all elements of stack are initialized
+ */
+static int check_stack_boundary(struct verifier_env *env,
+				int regno, int access_size)
+{
+	struct verifier_state *state = &env->cur_state;
+	struct reg_state *regs = state->regs;
+	int off, i;
+
+	if (regs[regno].type != PTR_TO_STACK)
+		return -EACCES;
+
+	off = regs[regno].imm;
+	if (off >= 0 || off < -MAX_BPF_STACK || off + access_size > 0 ||
+	    access_size <= 0) {
+		verbose("invalid stack type R%d off=%d access_size=%d\n",
+			regno, off, access_size);
+		return -EACCES;
+	}
+
+	for (i = 0; i < access_size; i++) {
+		if (state->stack[MAX_BPF_STACK + off + i].stype != STACK_MISC) {
+			verbose("invalid indirect read from stack off %d+%d size %d\n",
+				off, i, access_size);
+			return -EACCES;
+		}
+	}
+	return 0;
+}
+
+static int check_func_arg(struct verifier_env *env, int regno,
+			  enum bpf_arg_type arg_type, int *map_id,
+			  struct bpf_map **mapp)
+{
+	struct reg_state *reg = env->cur_state.regs + regno;
+	enum bpf_reg_type expected_type;
+
+	if (arg_type == ARG_ANYTHING)
+		return 0;
+
+	if (reg->type == NOT_INIT) {
+		verbose("R%d !read_ok\n", regno);
+		return -EACCES;
+	}
+
+	if (arg_type == ARG_PTR_TO_MAP_KEY || arg_type == ARG_PTR_TO_MAP_VALUE) {
+		expected_type = PTR_TO_STACK;
+	} else if (arg_type == ARG_CONST_MAP_ID || arg_type == ARG_CONST_STACK_SIZE) {
+		expected_type = CONST_IMM;
+	} else {
+		verbose("unsupported arg_type %d\n", arg_type);
+		return -EFAULT;
+	}
+
+	if (reg->type != expected_type) {
+		verbose("R%d type=%s expected=%s\n", regno,
+			reg_type_str[reg->type], reg_type_str[expected_type]);
+		return -EACCES;
+	}
+
+	if (arg_type == ARG_CONST_MAP_ID) {
+		/* bpf_map_xxx(map_id) call: check that map_id is valid */
+		*map_id = reg->imm;
+		_(get_map_info(env, reg->imm, mapp));
+	} else if (arg_type == ARG_PTR_TO_MAP_KEY) {
+		/*
+		 * bpf_map_xxx(..., map_id, ..., key) call:
+		 * check that [key, key + map->key_size) are within
+		 * stack limits and initialized
+		 */
+		if (!*mapp) {
+			/*
+			 * in function declaration map_id must come before
+			 * map_key or map_elem, so that it's verified
+			 * and known before we have to check map_key here
+			 */
+			verbose("invalid map_id to access map->key\n");
+			return -EACCES;
+		}
+		_(check_stack_boundary(env, regno, (*mapp)->key_size));
+	} else if (arg_type == ARG_PTR_TO_MAP_VALUE) {
+		/*
+		 * bpf_map_xxx(..., map_id, ..., value) call:
+		 * check [value, value + map->value_size) validity
+		 */
+		if (!*mapp) {
+			verbose("invalid map_id to access map->elem\n");
+			return -EACCES;
+		}
+		_(check_stack_boundary(env, regno, (*mapp)->value_size));
+	} else if (arg_type == ARG_CONST_STACK_SIZE) {
+		/*
+		 * bpf_xxx(..., buf, len) call will access 'len' bytes
+		 * from stack pointer 'buf'. Check it
+		 * note: regno == len, regno - 1 == buf
+		 */
+		_(check_stack_boundary(env, regno - 1, reg->imm));
+	}
+
+	return 0;
+}
+
+static int check_call(struct verifier_env *env, int func_id)
+{
+	struct verifier_state *state = &env->cur_state;
+	const struct bpf_func_proto *fn = NULL;
+	struct reg_state *regs = state->regs;
+	struct bpf_map *map = NULL;
+	struct reg_state *reg;
+	int map_id = -1;
+	int i;
+
+	/* find function prototype */
+	if (func_id <= 0 || func_id >= __BPF_FUNC_MAX_ID) {
+		verbose("invalid func %d\n", func_id);
+		return -EINVAL;
+	}
+
+	if (env->prog->info->ops->get_func_proto)
+		fn = env->prog->info->ops->get_func_proto(func_id);
+
+	if (!fn) {
+		verbose("unknown func %d\n", func_id);
+		return -EINVAL;
+	}
+
+	/* eBPF programs must be GPL compatible to use GPL-ed functions */
+	if (!env->prog->info->is_gpl_compatible && fn->gpl_only) {
+		verbose("cannot call GPL only function from proprietary program\n");
+		return -EINVAL;
+	}
+
+	/* check args */
+	_(check_func_arg(env, BPF_REG_1, fn->arg1_type, &map_id, &map));
+	_(check_func_arg(env, BPF_REG_2, fn->arg2_type, &map_id, &map));
+	_(check_func_arg(env, BPF_REG_3, fn->arg3_type, &map_id, &map));
+	_(check_func_arg(env, BPF_REG_4, fn->arg4_type, &map_id, &map));
+	_(check_func_arg(env, BPF_REG_5, fn->arg5_type, &map_id, &map));
+
+	/* reset caller saved regs */
+	for (i = 0; i < CALLER_SAVED_REGS; i++) {
+		reg = regs + caller_saved[i];
+		reg->type = NOT_INIT;
+		reg->imm = 0;
+	}
+
+	/* update return register */
+	if (fn->ret_type == RET_INTEGER) {
+		regs[BPF_REG_0].type = UNKNOWN_VALUE;
+	} else if (fn->ret_type == RET_VOID) {
+		regs[BPF_REG_0].type = NOT_INIT;
+	} else if (fn->ret_type == RET_PTR_TO_MAP_OR_NULL) {
+		regs[BPF_REG_0].type = PTR_TO_MAP_OR_NULL;
+		/*
+		 * remember map_id, so that check_map_access()
+		 * can check 'value_size' boundary of memory access
+		 * to map element returned from bpf_map_lookup_elem()
+		 */
+		regs[BPF_REG_0].imm = map_id;
+	} else {
+		verbose("unknown return type %d of func %d\n",
+			fn->ret_type, func_id);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/* check validity of 32-bit and 64-bit arithmetic operations */
+static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
+{
+	u8 opcode = BPF_OP(insn->code);
+
+	if (opcode == BPF_END || opcode == BPF_NEG) {
+		if (BPF_SRC(insn->code) != BPF_X)
+			return -EINVAL;
+		/* check src operand */
+		_(check_reg_arg(regs, insn->dst_reg, 1));
+
+		/* check dest operand */
+		_(check_reg_arg(regs, insn->dst_reg, 0));
+
+	} else if (opcode == BPF_MOV) {
+
+		if (BPF_SRC(insn->code) == BPF_X)
+			/* check src operand */
+			_(check_reg_arg(regs, insn->src_reg, 1));
+
+		/* check dest operand */
+		_(check_reg_arg(regs, insn->dst_reg, 0));
+
+		if (BPF_SRC(insn->code) == BPF_X) {
+			if (BPF_CLASS(insn->code) == BPF_ALU64) {
+				/* case: R1 = R2
+				 * copy register state to dest reg
+				 */
+				regs[insn->dst_reg].type = regs[insn->src_reg].type;
+				regs[insn->dst_reg].imm = regs[insn->src_reg].imm;
+			} else {
+				regs[insn->dst_reg].type = UNKNOWN_VALUE;
+				regs[insn->dst_reg].imm = 0;
+			}
+		} else {
+			/* case: R = imm
+			 * remember the value we stored into this reg
+			 */
+			regs[insn->dst_reg].type = CONST_IMM;
+			regs[insn->dst_reg].imm = insn->imm;
+		}
+
+	} else {	/* all other ALU ops: and, sub, xor, add, ... */
+
+		int stack_relative = 0;
+
+		if (BPF_SRC(insn->code) == BPF_X)
+			/* check src1 operand */
+			_(check_reg_arg(regs, insn->src_reg, 1));
+
+		/* check src2 operand */
+		_(check_reg_arg(regs, insn->dst_reg, 1));
+
+		if ((opcode == BPF_MOD || opcode == BPF_DIV) &&
+		    BPF_SRC(insn->code) == BPF_K && insn->imm == 0) {
+			verbose("div by zero\n");
+			return -EINVAL;
+		}
+
+		if (opcode == BPF_ADD && BPF_CLASS(insn->code) == BPF_ALU64 &&
+		    regs[insn->dst_reg].type == FRAME_PTR &&
+		    BPF_SRC(insn->code) == BPF_K)
+			stack_relative = 1;
+
+		/* check dest operand */
+		_(check_reg_arg(regs, insn->dst_reg, 0));
+
+		if (stack_relative) {
+			regs[insn->dst_reg].type = PTR_TO_STACK;
+			regs[insn->dst_reg].imm = insn->imm;
+		}
+	}
+
+	return 0;
+}
+
+static int check_cond_jmp_op(struct verifier_env *env,
+			     struct bpf_insn *insn, int *insn_idx)
+{
+	struct reg_state *regs = env->cur_state.regs;
+	struct verifier_state *other_branch;
+	u8 opcode = BPF_OP(insn->code);
+
+	if (BPF_SRC(insn->code) == BPF_X)
+		/* check src1 operand */
+		_(check_reg_arg(regs, insn->src_reg, 1));
+
+	/* check src2 operand */
+	_(check_reg_arg(regs, insn->dst_reg, 1));
+
+	/* detect if R == 0 where R was initialized to zero earlier */
+	if (BPF_SRC(insn->code) == BPF_K &&
+	    (opcode == BPF_JEQ || opcode == BPF_JNE) &&
+	    regs[insn->dst_reg].type == CONST_IMM &&
+	    regs[insn->dst_reg].imm == insn->imm) {
+		if (opcode == BPF_JEQ) {
+			/* if (imm == imm) goto pc+off;
+			 * only follow the goto, ignore fall-through
+			 */
+			*insn_idx += insn->off;
+			return 0;
+		} else {
+			/* if (imm != imm) goto pc+off;
+			 * only follow fall-through branch, since
+			 * that's where the program will go
+			 */
+			return 0;
+		}
+	}
+
+	other_branch = push_stack(env, *insn_idx + insn->off + 1, *insn_idx);
+	if (!other_branch)
+		return -EFAULT;
+
+	/* detect if R == 0 where R is returned value from bpf_map_lookup_elem() */
+	if (BPF_SRC(insn->code) == BPF_K &&
+	    insn->imm == 0 && (opcode == BPF_JEQ ||
+			       opcode == BPF_JNE) &&
+	    regs[insn->dst_reg].type == PTR_TO_MAP_OR_NULL) {
+		if (opcode == BPF_JEQ) {
+			/* next fallthrough insn can access memory via
+			 * this register
+			 */
+			regs[insn->dst_reg].type = PTR_TO_MAP;
+			/* branch targer cannot access it, since reg == 0 */
+			other_branch->regs[insn->dst_reg].type = CONST_IMM;
+			other_branch->regs[insn->dst_reg].imm = 0;
+		} else {
+			other_branch->regs[insn->dst_reg].type = PTR_TO_MAP;
+			regs[insn->dst_reg].type = CONST_IMM;
+			regs[insn->dst_reg].imm = 0;
+		}
+	} else if (BPF_SRC(insn->code) == BPF_K &&
+		   (opcode == BPF_JEQ || opcode == BPF_JNE)) {
+
+		if (opcode == BPF_JEQ) {
+			/* detect if (R == imm) goto
+			 * and in the target state recognize that R = imm
+			 */
+			other_branch->regs[insn->dst_reg].type = CONST_IMM;
+			other_branch->regs[insn->dst_reg].imm = insn->imm;
+		} else {
+			/* detect if (R != imm) goto
+			 * and in the fall-through state recognize that R = imm
+			 */
+			regs[insn->dst_reg].type = CONST_IMM;
+			regs[insn->dst_reg].imm = insn->imm;
+		}
+	}
+	if (verbose_on)
+		pr_cont_verifier_state(env);
+	return 0;
+}
+
+/* verify safety of LD_ABS|LD_IND instructions:
+ * - they can only appear in the programs where ctx == skb
+ * - since they are wrappers of function calls, they scratch R1-R5 registers,
+ *   preserve R6-R9, and store return value into R0
+ *
+ * Implicit input:
+ *   ctx == skb == R6 == CTX
+ *
+ * Explicit input:
+ *   SRC == any register
+ *   IMM == 32-bit immediate
+ *
+ * Output:
+ *   R0 - 8/16/32-bit skb data converted to cpu endianness
+ */
+
+static int check_ld_abs(struct verifier_env *env, struct bpf_insn *insn)
+{
+	struct reg_state *regs = env->cur_state.regs;
+	u8 mode = BPF_MODE(insn->code);
+	struct reg_state *reg;
+	int i;
+
+	if (mode != BPF_ABS && mode != BPF_IND)
+		return -EINVAL;
+
+	if (env->prog->info->prog_type != BPF_PROG_TYPE_SOCKET_FILTER) {
+		verbose("BPF_LD_ABS|IND instructions are only allowed in socket filters\n");
+		return -EINVAL;
+	}
+
+	/* check whether implicit source operand (register R6) is readable */
+	_(check_reg_arg(regs, BPF_REG_6, 1));
+
+	if (regs[BPF_REG_6].type != PTR_TO_CTX) {
+		verbose("at the time of BPF_LD_ABS|IND R6 != pointer to skb\n");
+		return -EINVAL;
+	}
+
+	if (mode == BPF_IND)
+		/* check explicit source operand */
+		_(check_reg_arg(regs, insn->src_reg, 1));
+
+	/* reset caller saved regs to unreadable */
+	for (i = 0; i < CALLER_SAVED_REGS; i++) {
+		reg = regs + caller_saved[i];
+		reg->type = NOT_INIT;
+		reg->imm = 0;
+	}
+
+	/* mark destination R0 register as readable, since it contains
+	 * the value fetched from the packet
+	 */
+	regs[BPF_REG_0].type = UNKNOWN_VALUE;
+	return 0;
+}
+
+/* non-recursive DFS pseudo code
+ * 1  procedure DFS-iterative(G,v):
+ * 2      label v as discovered
+ * 3      let S be a stack
+ * 4      S.push(v)
+ * 5      while S is not empty
+ * 6            t <- S.pop()
+ * 7            if t is what we're looking for:
+ * 8                return t
+ * 9            for all edges e in G.adjacentEdges(t) do
+ * 10               if edge e is already labelled
+ * 11                   continue with the next edge
+ * 12               w <- G.adjacentVertex(t,e)
+ * 13               if vertex w is not discovered and not explored
+ * 14                   label e as tree-edge
+ * 15                   label w as discovered
+ * 16                   S.push(w)
+ * 17                   continue at 5
+ * 18               else if vertex w is discovered
+ * 19                   label e as back-edge
+ * 20               else
+ * 21                   // vertex w is explored
+ * 22                   label e as forward- or cross-edge
+ * 23           label t as explored
+ * 24           S.pop()
+ *
+ * convention:
+ * 1 - discovered
+ * 2 - discovered and 1st branch labelled
+ * 3 - discovered and 1st and 2nd branch labelled
+ * 4 - explored
+ */
+
+#define STATE_END ((struct verifier_state_list *)-1)
+
+#define PUSH_INT(I) \
+	do { \
+		if (cur_stack >= insn_cnt) { \
+			ret = -E2BIG; \
+			goto free_st; \
+		} \
+		stack[cur_stack++] = I; \
+	} while (0)
+
+#define PEEK_INT() \
+	({ \
+		int _ret; \
+		if (cur_stack == 0) \
+			_ret = -1; \
+		else \
+			_ret = stack[cur_stack - 1]; \
+		_ret; \
+	 })
+
+#define POP_INT() \
+	({ \
+		int _ret; \
+		if (cur_stack == 0) \
+			_ret = -1; \
+		else \
+			_ret = stack[--cur_stack]; \
+		_ret; \
+	 })
+
+#define PUSH_INSN(T, W, E) \
+	do { \
+		int w = W; \
+		if (E == 1 && st[T] >= 2) \
+			break; \
+		if (E == 2 && st[T] >= 3) \
+			break; \
+		if (w >= insn_cnt) { \
+			ret = -EACCES; \
+			goto free_st; \
+		} \
+		if (E == 2) \
+			/* mark branch target for state pruning */ \
+			env->branch_landing[w] = STATE_END; \
+		if (st[w] == 0) { \
+			/* tree-edge */ \
+			st[T] = 1 + E; \
+			st[w] = 1; /* discovered */ \
+			PUSH_INT(w); \
+			goto peak_stack; \
+		} else if (st[w] == 1 || st[w] == 2 || st[w] == 3) { \
+			verbose("back-edge from insn %d to %d\n", t, w); \
+			ret = -EINVAL; \
+			goto free_st; \
+		} else if (st[w] == 4) { \
+			/* forward- or cross-edge */ \
+			st[T] = 1 + E; \
+		} else { \
+			verbose("insn state internal bug\n"); \
+			ret = -EFAULT; \
+			goto free_st; \
+		} \
+	} while (0)
+
+/* non-recursive depth-first-search to detect loops in BPF program
+ * loop == back-edge in directed graph
+ */
+static int check_cfg(struct verifier_env *env)
+{
+	struct bpf_insn *insns = env->prog->insnsi;
+	int insn_cnt = env->prog->len;
+	int cur_stack = 0;
+	int *stack;
+	int ret = 0;
+	int *st;
+	int i, t;
+
+	if (insns[insn_cnt - 1].code != (BPF_JMP | BPF_EXIT)) {
+		verbose("last insn is not a 'ret'\n");
+		return -EINVAL;
+	}
+
+	st = kzalloc(sizeof(int) * insn_cnt, GFP_KERNEL);
+	if (!st)
+		return -ENOMEM;
+
+	stack = kzalloc(sizeof(int) * insn_cnt, GFP_KERNEL);
+	if (!stack) {
+		kfree(st);
+		return -ENOMEM;
+	}
+
+	st[0] = 1; /* mark 1st insn as discovered */
+	PUSH_INT(0);
+
+peak_stack:
+	while ((t = PEEK_INT()) != -1) {
+		if (insns[t].code == (BPF_JMP | BPF_EXIT))
+			goto mark_explored;
+
+		if (BPF_CLASS(insns[t].code) == BPF_JMP) {
+			u8 opcode = BPF_OP(insns[t].code);
+
+			if (opcode == BPF_CALL) {
+				PUSH_INSN(t, t + 1, 1);
+			} else if (opcode == BPF_JA) {
+				if (BPF_SRC(insns[t].code) != BPF_X) {
+					ret = -EINVAL;
+					goto free_st;
+				}
+				PUSH_INSN(t, t + insns[t].off + 1, 1);
+			} else {
+				PUSH_INSN(t, t + 1, 1);
+				PUSH_INSN(t, t + insns[t].off + 1, 2);
+			}
+			/* tell verifier to check for equivalent verifier states
+			 * after every call and jump
+			 */
+			env->branch_landing[t + 1] = STATE_END;
+		} else {
+			PUSH_INSN(t, t + 1, 1);
+		}
+
+mark_explored:
+		st[t] = 4; /* explored */
+		if (POP_INT() == -1) {
+			verbose("pop_int internal bug\n");
+			ret = -EFAULT;
+			goto free_st;
+		}
+	}
+
+
+	for (i = 0; i < insn_cnt; i++) {
+		if (st[i] != 4) {
+			verbose("unreachable insn %d\n", i);
+			ret = -EINVAL;
+			goto free_st;
+		}
+	}
+
+free_st:
+	kfree(st);
+	kfree(stack);
+	return ret;
+}
+
+/* compare two verifier states
+ *
+ * all states stored in state_list are known to be valid, since
+ * verifier reached 'bpf_exit' instruction through them
+ *
+ * this function is called when verifier exploring different branches of
+ * execution popped from the state stack. If it sees an old state that has
+ * more strict register state and more strict stack state then this execution
+ * branch doesn't need to be explored further, since verifier already
+ * concluded that more strict state leads to valid finish.
+ *
+ * Therefore two states are equivalent if register state is more conservative
+ * and explored stack state is more conservative than the current one.
+ * Example:
+ *       explored                   current
+ * (slot1=INV slot2=MISC) == (slot1=MISC slot2=MISC)
+ * (slot1=MISC slot2=MISC) != (slot1=INV slot2=MISC)
+ *
+ * In other words if current stack state (one being explored) has more
+ * valid slots than old one that already passed validation, it means
+ * the verifier can stop exploring and conclude that current state is valid too
+ *
+ * Similarly with registers. If explored state has register type as invalid
+ * whereas register type in current state is meaningful, it means that
+ * the current state will reach 'bpf_exit' instruction safely
+ */
+static bool states_equal(struct verifier_state *old, struct verifier_state *cur)
+{
+	int i;
+
+	for (i = 0; i < MAX_BPF_REG; i++) {
+		if (memcmp(&old->regs[i], &cur->regs[i],
+			   sizeof(old->regs[0])) != 0) {
+			if (old->regs[i].type == NOT_INIT ||
+			    old->regs[i].type == UNKNOWN_VALUE)
+				continue;
+			return false;
+		}
+	}
+
+	for (i = 0; i < MAX_BPF_STACK; i++) {
+		if (memcmp(&old->stack[i], &cur->stack[i],
+			   sizeof(old->stack[0])) != 0) {
+			if (old->stack[i].stype == STACK_INVALID)
+				continue;
+			return false;
+		}
+	}
+	return true;
+}
+
+static int is_state_visited(struct verifier_env *env, int insn_idx)
+{
+	struct verifier_state_list *new_sl;
+	struct verifier_state_list *sl;
+
+	sl = env->branch_landing[insn_idx];
+	if (!sl)
+		/* no branch jump to this insn, ignore it */
+		return 0;
+
+	while (sl != STATE_END) {
+		if (states_equal(&sl->state, &env->cur_state))
+			/* reached equivalent register/stack state,
+			 * prune the search
+			 */
+			return 1;
+		sl = sl->next;
+	}
+	new_sl = kmalloc(sizeof(struct verifier_state_list), GFP_KERNEL);
+
+	if (!new_sl)
+		/* ignore ENOMEM, it doesn't affect correctness */
+		return 0;
+
+	/* add new state to the head of linked list */
+	memcpy(&new_sl->state, &env->cur_state, sizeof(env->cur_state));
+	new_sl->next = env->branch_landing[insn_idx];
+	env->branch_landing[insn_idx] = new_sl;
+	return 0;
+}
+
+static int do_check(struct verifier_env *env)
+{
+	struct verifier_state *state = &env->cur_state;
+	struct bpf_insn *insns = env->prog->insnsi;
+	struct reg_state *regs = state->regs;
+	int insn_cnt = env->prog->len;
+	int insn_idx, prev_insn_idx = 0;
+	int insn_processed = 0;
+	bool do_print_state = false;
+
+	init_reg_state(regs);
+	insn_idx = 0;
+	for (;;) {
+		struct bpf_insn *insn;
+		u8 class;
+
+		if (insn_idx >= insn_cnt) {
+			verbose("invalid insn idx %d insn_cnt %d\n",
+				insn_idx, insn_cnt);
+			return -EFAULT;
+		}
+
+		insn = &insns[insn_idx];
+		class = BPF_CLASS(insn->code);
+
+		if (++insn_processed > 32768) {
+			verbose("BPF program is too large. Proccessed %d insn\n",
+				insn_processed);
+			return -E2BIG;
+		}
+
+		if (is_state_visited(env, insn_idx)) {
+			if (verbose_on) {
+				if (do_print_state)
+					pr_cont("\nfrom %d to %d: safe\n",
+						prev_insn_idx, insn_idx);
+				else
+					pr_cont("%d: safe\n", insn_idx);
+			}
+			goto process_bpf_exit;
+		}
+
+		if (verbose_on && do_print_state) {
+			pr_cont("\nfrom %d to %d:", prev_insn_idx, insn_idx);
+			pr_cont_verifier_state(env);
+			do_print_state = false;
+		}
+
+		if (verbose_on) {
+			pr_cont("%d: ", insn_idx);
+			pr_cont_bpf_insn(insn);
+		}
+
+		if (class == BPF_ALU || class == BPF_ALU64) {
+			_(check_alu_op(regs, insn));
+
+		} else if (class == BPF_LDX) {
+			if (BPF_MODE(insn->code) != BPF_MEM)
+				return -EINVAL;
+
+			/* check src operand */
+			_(check_reg_arg(regs, insn->src_reg, 1));
+
+			_(check_mem_access(env, insn->src_reg, insn->off,
+					   BPF_SIZE(insn->code), BPF_READ,
+					   insn->dst_reg));
+
+			/* dest reg state will be updated by mem_access */
+
+		} else if (class == BPF_STX) {
+			/* check src1 operand */
+			_(check_reg_arg(regs, insn->src_reg, 1));
+			/* check src2 operand */
+			_(check_reg_arg(regs, insn->dst_reg, 1));
+			_(check_mem_access(env, insn->dst_reg, insn->off,
+					   BPF_SIZE(insn->code), BPF_WRITE,
+					   insn->src_reg));
+
+		} else if (class == BPF_ST) {
+			if (BPF_MODE(insn->code) != BPF_MEM)
+				return -EINVAL;
+			/* check src operand */
+			_(check_reg_arg(regs, insn->dst_reg, 1));
+			_(check_mem_access(env, insn->dst_reg, insn->off,
+					   BPF_SIZE(insn->code), BPF_WRITE,
+					   -1));
+
+		} else if (class == BPF_JMP) {
+			u8 opcode = BPF_OP(insn->code);
+
+			if (opcode == BPF_CALL) {
+				_(check_call(env, insn->imm));
+			} else if (opcode == BPF_JA) {
+				if (BPF_SRC(insn->code) != BPF_X)
+					return -EINVAL;
+				insn_idx += insn->off + 1;
+				continue;
+			} else if (opcode == BPF_EXIT) {
+				/* eBPF calling convetion is such that R0 is used
+				 * to return the value from eBPF program.
+				 * Make sure that it's readable at this time
+				 * of bpf_exit, which means that program wrote
+				 * something into it earlier
+				 */
+				_(check_reg_arg(regs, BPF_REG_0, 1));
+process_bpf_exit:
+				insn_idx = pop_stack(env, &prev_insn_idx);
+				if (insn_idx < 0) {
+					break;
+				} else {
+					do_print_state = true;
+					continue;
+				}
+			} else {
+				_(check_cond_jmp_op(env, insn, &insn_idx));
+			}
+		} else if (class == BPF_LD) {
+			_(check_ld_abs(env, insn));
+		} else {
+			verbose("unknown insn class %d\n", class);
+			return -EINVAL;
+		}
+
+		insn_idx++;
+	}
+
+	return 0;
+}
+
+static void free_states(struct verifier_env *env, int insn_cnt)
+{
+	struct verifier_state_list *sl, *sln;
+	int i;
+
+	for (i = 0; i < insn_cnt; i++) {
+		sl = env->branch_landing[i];
+
+		if (sl)
+			while (sl != STATE_END) {
+				sln = sl->next;
+				kfree(sl);
+				sl = sln;
+			}
+	}
+
+	kfree(env->branch_landing);
+}
+
+int bpf_check(struct sk_filter *prog)
+{
+	struct verifier_env *env;
+	int ret;
+
+	if (prog->len <= 0 || prog->len > BPF_MAXINSNS)
+		return -E2BIG;
+
+	env = kzalloc(sizeof(struct verifier_env), GFP_KERNEL);
+	if (!env)
+		return -ENOMEM;
+
+	verbose_on = false;
+retry:
+	env->prog = prog;
+	env->branch_landing = kcalloc(prog->len,
+				      sizeof(struct verifier_state_list *),
+				      GFP_KERNEL);
+
+	if (!env->branch_landing) {
+		kfree(env);
+		return -ENOMEM;
+	}
+
+	ret = check_cfg(env);
+	if (ret < 0)
+		goto free_env;
+
+	ret = do_check(env);
+
+free_env:
+	while (pop_stack(env, NULL) >= 0);
+	free_states(env, prog->len);
+
+	if (ret < 0 && !verbose_on && capable(CAP_SYS_ADMIN)) {
+		/* verification failed, redo it with verbose on */
+		memset(env, 0, sizeof(struct verifier_env));
+		verbose_on = true;
+		goto retry;
+	}
+
+	if (ret == 0 && env->used_map_cnt) {
+		/* if program passed verifier, update used_maps in bpf_prog_info */
+		prog->info->used_maps = kmalloc_array(env->used_map_cnt,
+						      sizeof(u32), GFP_KERNEL);
+		if (!prog->info->used_maps) {
+			kfree(env);
+			return -ENOMEM;
+		}
+		memcpy(prog->info->used_maps, env->used_maps,
+		       sizeof(u32) * env->used_map_cnt);
+		prog->info->used_map_cnt = env->used_map_cnt;
+	}
+
+	kfree(env);
+	return ret;
+}
-- 
1.7.9.5
