From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 08/10] bpf, x86: add support for constant blinding
Date: Fri, 13 May 2016 19:08:33 +0200
Message-ID: <3dd23ead374c4f5ca5cfa6dfd6902538144b8df9.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, elena.reshetova@intel.com,
	zlim.lnx@gmail.com, yang.shi@linaro.org,
	holzheu@linux.vnet.ibm.com, tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41898 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbcEMRJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 13:09:04 -0400
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds recently added constant blinding helpers into the
x86 eBPF JIT. In the bpf_int_jit_compile() path, requirements are
to utilize bpf_jit_blind_constants()/bpf_jit_prog_release_other()
pair for rewriting the program into a blinded one, and to map the
BPF_REG_AX register to a CPU register. The mapping of BPF_REG_AX
is at non-callee saved register r10, and thus shared with cached
skb->data used for ld_abs/ind and not in every program type needed.
When blinding is not used, there's zero additional overhead in the
generated image.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 arch/x86/net/bpf_jit_comp.c | 66 ++++++++++++++++++++++++++++++++++++---------
 1 file changed, 53 insertions(+), 13 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 6b2d23e..fe04a04 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -110,11 +110,16 @@ static void bpf_flush_icache(void *start, void *end)
 	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
 
 /* pick a register outside of BPF range for JIT internal work */
-#define AUX_REG (MAX_BPF_REG + 1)
+#define AUX_REG (MAX_BPF_JIT_REG + 1)
 
-/* the following table maps BPF registers to x64 registers.
- * x64 register r12 is unused, since if used as base address register
- * in load/store instructions, it always needs an extra byte of encoding
+/* The following table maps BPF registers to x64 registers.
+ *
+ * x64 register r12 is unused, since if used as base address
+ * register in load/store instructions, it always needs an
+ * extra byte of encoding and is callee saved.
+ *
+ *  r9 caches skb->len - skb->data_len
+ * r10 caches skb->data, and used for blinding (if enabled)
  */
 static const int reg2hex[] = {
 	[BPF_REG_0] = 0,  /* rax */
@@ -128,6 +133,7 @@ static const int reg2hex[] = {
 	[BPF_REG_8] = 6,  /* r14 callee saved */
 	[BPF_REG_9] = 7,  /* r15 callee saved */
 	[BPF_REG_FP] = 5, /* rbp readonly */
+	[BPF_REG_AX] = 2, /* r10 temp register */
 	[AUX_REG] = 3,    /* r11 temp register */
 };
 
@@ -141,7 +147,8 @@ static bool is_ereg(u32 reg)
 			     BIT(AUX_REG) |
 			     BIT(BPF_REG_7) |
 			     BIT(BPF_REG_8) |
-			     BIT(BPF_REG_9));
+			     BIT(BPF_REG_9) |
+			     BIT(BPF_REG_AX));
 }
 
 /* add modifiers if 'reg' maps to x64 registers r8..r15 */
@@ -182,6 +189,7 @@ static void jit_fill_hole(void *area, unsigned int size)
 struct jit_context {
 	int cleanup_addr; /* epilogue code offset */
 	bool seen_ld_abs;
+	bool seen_ax_reg;
 };
 
 /* maximum number of bytes emitted while JITing one eBPF insn */
@@ -345,6 +353,7 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 	struct bpf_insn *insn = bpf_prog->insnsi;
 	int insn_cnt = bpf_prog->len;
 	bool seen_ld_abs = ctx->seen_ld_abs | (oldproglen == 0);
+	bool seen_ax_reg = ctx->seen_ax_reg | (oldproglen == 0);
 	bool seen_exit = false;
 	u8 temp[BPF_MAX_INSN_SIZE + BPF_INSN_SAFETY];
 	int i, cnt = 0;
@@ -367,6 +376,9 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 		int ilen;
 		u8 *func;
 
+		if (dst_reg == BPF_REG_AX || src_reg == BPF_REG_AX)
+			ctx->seen_ax_reg = seen_ax_reg = true;
+
 		switch (insn->code) {
 			/* ALU */
 		case BPF_ALU | BPF_ADD | BPF_X:
@@ -1002,6 +1014,10 @@ common_load:
 			 * sk_load_* helpers also use %r10 and %r9d.
 			 * See bpf_jit.S
 			 */
+			if (seen_ax_reg)
+				/* r10 = skb->data, mov %r10, off32(%rbx) */
+				EMIT3_off32(0x4c, 0x8b, 0x93,
+					    offsetof(struct sk_buff, data));
 			EMIT1_off32(0xE8, jmp_offset); /* call */
 			break;
 
@@ -1076,19 +1092,34 @@ void bpf_jit_compile(struct bpf_prog *prog)
 struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 {
 	struct bpf_binary_header *header = NULL;
+	struct bpf_prog *tmp, *orig_prog = prog;
 	int proglen, oldproglen = 0;
 	struct jit_context ctx = {};
+	bool tmp_blinded = false;
 	u8 *image = NULL;
 	int *addrs;
 	int pass;
 	int i;
 
 	if (!bpf_jit_enable)
-		return prog;
+		return orig_prog;
+
+	tmp = bpf_jit_blind_constants(prog);
+	/* If blinding was requested and we failed during blinding,
+	 * we must fall back to the interpreter.
+	 */
+	if (IS_ERR(tmp))
+		return orig_prog;
+	if (tmp != prog) {
+		tmp_blinded = true;
+		prog = tmp;
+	}
 
 	addrs = kmalloc(prog->len * sizeof(*addrs), GFP_KERNEL);
-	if (!addrs)
-		return prog;
+	if (!addrs) {
+		prog = orig_prog;
+		goto out;
+	}
 
 	/* Before first pass, make a rough estimation of addrs[]
 	 * each bpf instruction is translated to less than 64 bytes
@@ -1110,21 +1141,25 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 			image = NULL;
 			if (header)
 				bpf_jit_binary_free(header);
-			goto out;
+			prog = orig_prog;
+			goto out_addrs;
 		}
 		if (image) {
 			if (proglen != oldproglen) {
 				pr_err("bpf_jit: proglen=%d != oldproglen=%d\n",
 				       proglen, oldproglen);
-				goto out;
+				prog = orig_prog;
+				goto out_addrs;
 			}
 			break;
 		}
 		if (proglen == oldproglen) {
 			header = bpf_jit_binary_alloc(proglen, &image,
 						      1, jit_fill_hole);
-			if (!header)
-				goto out;
+			if (!header) {
+				prog = orig_prog;
+				goto out_addrs;
+			}
 		}
 		oldproglen = proglen;
 	}
@@ -1138,8 +1173,13 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 		prog->bpf_func = (void *)image;
 		prog->jited = 1;
 	}
-out:
+
+out_addrs:
 	kfree(addrs);
+out:
+	if (tmp_blinded)
+		bpf_jit_prog_release_other(prog, prog == orig_prog ?
+					   tmp : orig_prog);
 	return prog;
 }
 
-- 
1.9.3
