From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 10/10] bpf, s390: add support for constant blinding
Date: Fri, 13 May 2016 19:08:35 +0200
Message-ID: <f73f01f19050dcc2900db0c8f1f77c883ca08cc7.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, elena.reshetova@intel.com,
	zlim.lnx@gmail.com, yang.shi@linaro.org,
	holzheu@linux.vnet.ibm.com, tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41916 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbcEMRJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 13:09:05 -0400
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds recently added constant blinding helpers into the
s390 eBPF JIT. In the bpf_int_jit_compile() path, requirements are
to utilize bpf_jit_blind_constants()/bpf_jit_prog_release_other()
pair for rewriting the program into a blinded one, and to map the
BPF_REG_AX register to a CPU register. The mapping of BPF_REG_AX
is at r12 and similarly like in x86 case performs reloading when
ld_abs/ind is used. When blinding is not used, there's no additional
overhead in the generated image.

When BPF_REG_AX is used, we don't need to emit skb->data reload when
helper function changed skb->data, as this will be reloaded later
on anyway from stack on ld_abs/ind, where skb->data is needed. s390
allows for this w/o much additional complexity unlike f.e. x86.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
---
 arch/s390/net/bpf_jit_comp.c | 73 +++++++++++++++++++++++++++++++++-----------
 1 file changed, 56 insertions(+), 17 deletions(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index fcf301a..9133b0e 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -54,16 +54,17 @@ struct bpf_jit {
 #define SEEN_FUNC	16	/* calls C functions */
 #define SEEN_TAIL_CALL	32	/* code uses tail calls */
 #define SEEN_SKB_CHANGE	64	/* code changes skb data */
+#define SEEN_REG_AX	128	/* code uses constant blinding */
 #define SEEN_STACK	(SEEN_FUNC | SEEN_MEM | SEEN_SKB)
 
 /*
  * s390 registers
  */
-#define REG_W0		(__MAX_BPF_REG+0)	/* Work register 1 (even) */
-#define REG_W1		(__MAX_BPF_REG+1)	/* Work register 2 (odd) */
-#define REG_SKB_DATA	(__MAX_BPF_REG+2)	/* SKB data register */
-#define REG_L		(__MAX_BPF_REG+3)	/* Literal pool register */
-#define REG_15		(__MAX_BPF_REG+4)	/* Register 15 */
+#define REG_W0		(MAX_BPF_JIT_REG + 0)	/* Work register 1 (even) */
+#define REG_W1		(MAX_BPF_JIT_REG + 1)	/* Work register 2 (odd) */
+#define REG_SKB_DATA	(MAX_BPF_JIT_REG + 2)	/* SKB data register */
+#define REG_L		(MAX_BPF_JIT_REG + 3)	/* Literal pool register */
+#define REG_15		(MAX_BPF_JIT_REG + 4)	/* Register 15 */
 #define REG_0		REG_W0			/* Register 0 */
 #define REG_1		REG_W1			/* Register 1 */
 #define REG_2		BPF_REG_1		/* Register 2 */
@@ -88,6 +89,8 @@ static const int reg2hex[] = {
 	[BPF_REG_9]	= 10,
 	/* BPF stack pointer */
 	[BPF_REG_FP]	= 13,
+	/* Register for blinding (shared with REG_SKB_DATA) */
+	[BPF_REG_AX]	= 12,
 	/* SKB data pointer */
 	[REG_SKB_DATA]	= 12,
 	/* Work registers for s390x backend */
@@ -385,7 +388,7 @@ static void save_restore_regs(struct bpf_jit *jit, int op)
 /*
  * For SKB access %b1 contains the SKB pointer. For "bpf_jit.S"
  * we store the SKB header length on the stack and the SKB data
- * pointer in REG_SKB_DATA.
+ * pointer in REG_SKB_DATA if BPF_REG_AX is not used.
  */
 static void emit_load_skb_data_hlen(struct bpf_jit *jit)
 {
@@ -397,9 +400,10 @@ static void emit_load_skb_data_hlen(struct bpf_jit *jit)
 		   offsetof(struct sk_buff, data_len));
 	/* stg %w1,ST_OFF_HLEN(%r0,%r15) */
 	EMIT6_DISP_LH(0xe3000000, 0x0024, REG_W1, REG_0, REG_15, STK_OFF_HLEN);
-	/* lg %skb_data,data_off(%b1) */
-	EMIT6_DISP_LH(0xe3000000, 0x0004, REG_SKB_DATA, REG_0,
-		      BPF_REG_1, offsetof(struct sk_buff, data));
+	if (!(jit->seen & SEEN_REG_AX))
+		/* lg %skb_data,data_off(%b1) */
+		EMIT6_DISP_LH(0xe3000000, 0x0004, REG_SKB_DATA, REG_0,
+			      BPF_REG_1, offsetof(struct sk_buff, data));
 }
 
 /*
@@ -487,6 +491,8 @@ static noinline int bpf_jit_insn(struct bpf_jit *jit, struct bpf_prog *fp, int i
 	s32 imm = insn->imm;
 	s16 off = insn->off;
 
+	if (dst_reg == BPF_REG_AX || src_reg == BPF_REG_AX)
+		jit->seen |= SEEN_REG_AX;
 	switch (insn->code) {
 	/*
 	 * BPF_MOV
@@ -1188,7 +1194,7 @@ call_fn:
 		/*
 		 * Implicit input:
 		 *  BPF_REG_6	 (R7) : skb pointer
-		 *  REG_SKB_DATA (R12): skb data pointer
+		 *  REG_SKB_DATA (R12): skb data pointer (if no BPF_REG_AX)
 		 *
 		 * Calculated input:
 		 *  BPF_REG_2	 (R3) : offset of byte(s) to fetch in skb
@@ -1209,6 +1215,11 @@ call_fn:
 			/* agfr %b2,%src (%src is s32 here) */
 			EMIT4(0xb9180000, BPF_REG_2, src_reg);
 
+		/* Reload REG_SKB_DATA if BPF_REG_AX is used */
+		if (jit->seen & SEEN_REG_AX)
+			/* lg %skb_data,data_off(%b6) */
+			EMIT6_DISP_LH(0xe3000000, 0x0004, REG_SKB_DATA, REG_0,
+				      BPF_REG_6, offsetof(struct sk_buff, data));
 		/* basr %b5,%w1 (%b5 is call saved) */
 		EMIT2(0x0d00, BPF_REG_5, REG_W1);
 
@@ -1264,36 +1275,60 @@ void bpf_jit_compile(struct bpf_prog *fp)
  */
 struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 {
+	struct bpf_prog *tmp, *orig_fp = fp;
 	struct bpf_binary_header *header;
+	bool tmp_blinded = false;
 	struct bpf_jit jit;
 	int pass;
 
 	if (!bpf_jit_enable)
-		return fp;
+		return orig_fp;
+
+	tmp = bpf_jit_blind_constants(fp);
+	/*
+	 * If blinding was requested and we failed during blinding,
+	 * we must fall back to the interpreter.
+	 */
+	if (IS_ERR(tmp))
+		return orig_fp;
+	if (tmp != fp) {
+		tmp_blinded = true;
+		fp = tmp;
+	}
 
 	memset(&jit, 0, sizeof(jit));
 	jit.addrs = kcalloc(fp->len + 1, sizeof(*jit.addrs), GFP_KERNEL);
-	if (jit.addrs == NULL)
-		return fp;
+	if (jit.addrs == NULL) {
+		fp = orig_fp;
+		goto out;
+	}
 	/*
 	 * Three initial passes:
 	 *   - 1/2: Determine clobbered registers
 	 *   - 3:   Calculate program size and addrs arrray
 	 */
 	for (pass = 1; pass <= 3; pass++) {
-		if (bpf_jit_prog(&jit, fp))
+		if (bpf_jit_prog(&jit, fp)) {
+			fp = orig_fp;
 			goto free_addrs;
+		}
 	}
 	/*
 	 * Final pass: Allocate and generate program
 	 */
-	if (jit.size >= BPF_SIZE_MAX)
+	if (jit.size >= BPF_SIZE_MAX) {
+		fp = orig_fp;
 		goto free_addrs;
+	}
 	header = bpf_jit_binary_alloc(jit.size, &jit.prg_buf, 2, jit_fill_hole);
-	if (!header)
+	if (!header) {
+		fp = orig_fp;
 		goto free_addrs;
-	if (bpf_jit_prog(&jit, fp))
+	}
+	if (bpf_jit_prog(&jit, fp)) {
+		fp = orig_fp;
 		goto free_addrs;
+	}
 	if (bpf_jit_enable > 1) {
 		bpf_jit_dump(fp->len, jit.size, pass, jit.prg_buf);
 		if (jit.prg_buf)
@@ -1306,6 +1341,10 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 	}
 free_addrs:
 	kfree(jit.addrs);
+out:
+	if (tmp_blinded)
+		bpf_jit_prog_release_other(fp, fp == orig_fp ?
+					   tmp : orig_fp);
 	return fp;
 }
 
-- 
1.9.3
