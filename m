From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 2/4] x86: bpf_jit: implement bpf_tail_call() helper
Date: Tue, 19 May 2015 16:59:04 -0700
Message-ID: <1432079946-9878-3-git-send-email-ast@plumgrid.com>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Zi Shen Lim <zlim.lnx@gmail.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34808 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbbESX7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 19:59:23 -0400
Received: by pdbnk13 with SMTP id nk13so45658328pdb.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 16:59:22 -0700 (PDT)
In-Reply-To: <1432079946-9878-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bpf_tail_call() arguments:
ctx - context pointer
jmp_table - one of BPF_MAP_TYPE_PROG_ARRAY maps used as the jump table
index - index in the jump table

In this implementation x64 JIT bypasses stack unwind and jumps into the
callee program after prologue, so the callee program reuses the same stack.

The logic can be roughly expressed in C like:

u32 tail_call_cnt;

void *jumptable[2] = { &&label1, &&label2 };

int bpf_prog1(void *ctx)
{
label1:
    ...
}

int bpf_prog2(void *ctx)
{
label2:
    ...
}

int bpf_prog1(void *ctx)
{
    ...
    if (tail_call_cnt++ < MAX_TAIL_CALL_CNT)
        goto *jumptable[index]; ... and pass my 'ctx' to callee ...

    ... fall through if no entry in jumptable ...
}

Note that 'skip current program epilogue and next program prologue' is
an optimization. Other JITs don't have to do it the same way.
>From safety point of view it's valid as well, since programs always
initialize the stack before use, so any residue in the stack left by
the current program is not going be read. The same verifier checks are
done for the calls from the kernel into all bpf programs.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/x86/net/bpf_jit_comp.c |  150 ++++++++++++++++++++++++++++++++++++-------
 1 file changed, 126 insertions(+), 24 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 99f76103c6b7..2ca777635d8e 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -12,6 +12,7 @@
 #include <linux/filter.h>
 #include <linux/if_vlan.h>
 #include <asm/cacheflush.h>
+#include <linux/bpf.h>
 
 int bpf_jit_enable __read_mostly;
 
@@ -37,7 +38,8 @@ static u8 *emit_code(u8 *ptr, u32 bytes, unsigned int len)
 	return ptr + len;
 }
 
-#define EMIT(bytes, len)	do { prog = emit_code(prog, bytes, len); } while (0)
+#define EMIT(bytes, len) \
+	do { prog = emit_code(prog, bytes, len); cnt += len; } while (0)
 
 #define EMIT1(b1)		EMIT(b1, 1)
 #define EMIT2(b1, b2)		EMIT((b1) + ((b2) << 8), 2)
@@ -186,31 +188,31 @@ struct jit_context {
 #define BPF_MAX_INSN_SIZE	128
 #define BPF_INSN_SAFETY		64
 
-static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
-		  int oldproglen, struct jit_context *ctx)
+#define STACKSIZE \
+	(MAX_BPF_STACK + \
+	 32 /* space for rbx, r13, r14, r15 */ + \
+	 8 /* space for skb_copy_bits() buffer */)
+
+#define PROLOGUE_SIZE 51
+
+/* emit x64 prologue code for BPF program and check it's size.
+ * bpf_tail_call helper will skip it while jumping into another program
+ */
+static void emit_prologue(u8 **pprog)
 {
-	struct bpf_insn *insn = bpf_prog->insnsi;
-	int insn_cnt = bpf_prog->len;
-	bool seen_ld_abs = ctx->seen_ld_abs | (oldproglen == 0);
-	bool seen_exit = false;
-	u8 temp[BPF_MAX_INSN_SIZE + BPF_INSN_SAFETY];
-	int i;
-	int proglen = 0;
-	u8 *prog = temp;
-	int stacksize = MAX_BPF_STACK +
-		32 /* space for rbx, r13, r14, r15 */ +
-		8 /* space for skb_copy_bits() buffer */;
+	u8 *prog = *pprog;
+	int cnt = 0;
 
 	EMIT1(0x55); /* push rbp */
 	EMIT3(0x48, 0x89, 0xE5); /* mov rbp,rsp */
 
-	/* sub rsp, stacksize */
-	EMIT3_off32(0x48, 0x81, 0xEC, stacksize);
+	/* sub rsp, STACKSIZE */
+	EMIT3_off32(0x48, 0x81, 0xEC, STACKSIZE);
 
 	/* all classic BPF filters use R6(rbx) save it */
 
 	/* mov qword ptr [rbp-X],rbx */
-	EMIT3_off32(0x48, 0x89, 0x9D, -stacksize);
+	EMIT3_off32(0x48, 0x89, 0x9D, -STACKSIZE);
 
 	/* bpf_convert_filter() maps classic BPF register X to R7 and uses R8
 	 * as temporary, so all tcpdump filters need to spill/fill R7(r13) and
@@ -221,16 +223,112 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 	 */
 
 	/* mov qword ptr [rbp-X],r13 */
-	EMIT3_off32(0x4C, 0x89, 0xAD, -stacksize + 8);
+	EMIT3_off32(0x4C, 0x89, 0xAD, -STACKSIZE + 8);
 	/* mov qword ptr [rbp-X],r14 */
-	EMIT3_off32(0x4C, 0x89, 0xB5, -stacksize + 16);
+	EMIT3_off32(0x4C, 0x89, 0xB5, -STACKSIZE + 16);
 	/* mov qword ptr [rbp-X],r15 */
-	EMIT3_off32(0x4C, 0x89, 0xBD, -stacksize + 24);
+	EMIT3_off32(0x4C, 0x89, 0xBD, -STACKSIZE + 24);
 
 	/* clear A and X registers */
 	EMIT2(0x31, 0xc0); /* xor eax, eax */
 	EMIT3(0x4D, 0x31, 0xED); /* xor r13, r13 */
 
+	/* clear tail_cnt: mov qword ptr [rbp-X], rax */
+	EMIT3_off32(0x48, 0x89, 0x85, -STACKSIZE + 32);
+
+	BUILD_BUG_ON(cnt != PROLOGUE_SIZE);
+	*pprog = prog;
+}
+
+/* generate the following code:
+ * ... bpf_tail_call(void *ctx, struct bpf_array *array, u64 index) ...
+ *   if (index >= array->map.max_entries)
+ *     goto out;
+ *   if (++tail_call_cnt > MAX_TAIL_CALL_CNT)
+ *     goto out;
+ *   prog = array->prog[index];
+ *   if (prog == NULL)
+ *     goto out;
+ *   goto *(prog->bpf_func + prologue_size);
+ * out:
+ */
+static void emit_bpf_tail_call(u8 **pprog)
+{
+	u8 *prog = *pprog;
+	int label1, label2, label3;
+	int cnt = 0;
+
+	/* rdi - pointer to ctx
+	 * rsi - pointer to bpf_array
+	 * rdx - index in bpf_array
+	 */
+
+	/* if (index >= array->map.max_entries)
+	 *   goto out;
+	 */
+	EMIT4(0x48, 0x8B, 0x46,                   /* mov rax, qword ptr [rsi + 16] */
+	      offsetof(struct bpf_array, map.max_entries));
+	EMIT3(0x48, 0x39, 0xD0);                  /* cmp rax, rdx */
+#define OFFSET1 44 /* number of bytes to jump */
+	EMIT2(X86_JBE, OFFSET1);                  /* jbe out */
+	label1 = cnt;
+
+	/* if (tail_call_cnt > MAX_TAIL_CALL_CNT)
+	 *   goto out;
+	 */
+	EMIT2_off32(0x8B, 0x85, -STACKSIZE + 36); /* mov eax, dword ptr [rbp - 516] */
+	EMIT3(0x83, 0xF8, MAX_TAIL_CALL_CNT);     /* cmp eax, MAX_TAIL_CALL_CNT */
+#define OFFSET2 33
+	EMIT2(X86_JA, OFFSET2);                   /* ja out */
+	label2 = cnt;
+	EMIT3(0x83, 0xC0, 0x01);                  /* add eax, 1 */
+	EMIT2_off32(0x89, 0x85, -STACKSIZE + 36); /* mov dword ptr [rbp - 516], eax */
+
+	/* prog = array->prog[index]; */
+	EMIT4(0x48, 0x8D, 0x44, 0xD6);            /* lea rax, [rsi + rdx * 8 + 0x50] */
+	EMIT1(offsetof(struct bpf_array, prog));
+	EMIT3(0x48, 0x8B, 0x00);                  /* mov rax, qword ptr [rax] */
+
+	/* if (prog == NULL)
+	 *   goto out;
+	 */
+	EMIT4(0x48, 0x83, 0xF8, 0x00);            /* cmp rax, 0 */
+#define OFFSET3 10
+	EMIT2(X86_JE, OFFSET3);                   /* je out */
+	label3 = cnt;
+
+	/* goto *(prog->bpf_func + prologue_size); */
+	EMIT4(0x48, 0x8B, 0x40,                   /* mov rax, qword ptr [rax + 32] */
+	      offsetof(struct bpf_prog, bpf_func));
+	EMIT4(0x48, 0x83, 0xC0, PROLOGUE_SIZE);   /* add rax, prologue_size */
+
+	/* now we're ready to jump into next BPF program
+	 * rdi == ctx (1st arg)
+	 * rax == prog->bpf_func + prologue_size
+	 */
+	EMIT2(0xFF, 0xE0);                        /* jmp rax */
+
+	/* out: */
+	BUILD_BUG_ON(cnt - label1 != OFFSET1);
+	BUILD_BUG_ON(cnt - label2 != OFFSET2);
+	BUILD_BUG_ON(cnt - label3 != OFFSET3);
+	*pprog = prog;
+}
+
+static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
+		  int oldproglen, struct jit_context *ctx)
+{
+	struct bpf_insn *insn = bpf_prog->insnsi;
+	int insn_cnt = bpf_prog->len;
+	bool seen_ld_abs = ctx->seen_ld_abs | (oldproglen == 0);
+	bool seen_exit = false;
+	u8 temp[BPF_MAX_INSN_SIZE + BPF_INSN_SAFETY];
+	int i, cnt = 0;
+	int proglen = 0;
+	u8 *prog = temp;
+
+	emit_prologue(&prog);
+
 	if (seen_ld_abs) {
 		/* r9d : skb->len - skb->data_len (headlen)
 		 * r10 : skb->data
@@ -739,6 +837,10 @@ xadd:			if (is_imm8(insn->off))
 			}
 			break;
 
+		case BPF_JMP | BPF_CALL | BPF_X:
+			emit_bpf_tail_call(&prog);
+			break;
+
 			/* cond jump */
 		case BPF_JMP | BPF_JEQ | BPF_X:
 		case BPF_JMP | BPF_JNE | BPF_X:
@@ -891,13 +993,13 @@ common_load:
 			/* update cleanup_addr */
 			ctx->cleanup_addr = proglen;
 			/* mov rbx, qword ptr [rbp-X] */
-			EMIT3_off32(0x48, 0x8B, 0x9D, -stacksize);
+			EMIT3_off32(0x48, 0x8B, 0x9D, -STACKSIZE);
 			/* mov r13, qword ptr [rbp-X] */
-			EMIT3_off32(0x4C, 0x8B, 0xAD, -stacksize + 8);
+			EMIT3_off32(0x4C, 0x8B, 0xAD, -STACKSIZE + 8);
 			/* mov r14, qword ptr [rbp-X] */
-			EMIT3_off32(0x4C, 0x8B, 0xB5, -stacksize + 16);
+			EMIT3_off32(0x4C, 0x8B, 0xB5, -STACKSIZE + 16);
 			/* mov r15, qword ptr [rbp-X] */
-			EMIT3_off32(0x4C, 0x8B, 0xBD, -stacksize + 24);
+			EMIT3_off32(0x4C, 0x8B, 0xBD, -STACKSIZE + 24);
 
 			EMIT1(0xC9); /* leave */
 			EMIT1(0xC3); /* ret */
-- 
1.7.9.5
