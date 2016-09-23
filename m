From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH 3/3] bpf powerpc: add support for bpf constant blinding
Date: Sat, 24 Sep 2016 02:05:02 +0530
Message-ID: <0ecead168c80b1c3d8a8101595e689ff7c7a735f.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
References: <40b65ab2bb3a48837ab047a70887de3ccd70c56b.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: "Alexei Starovoitov" <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>,
        "Ananth N Mavinakayanahalli" <ananth@in.ibm.com>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, "Michael Ellerman" <mpe@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:53668 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1761066AbcIWUfp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 16:35:45 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8NKXmbg088640
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 16:35:39 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25mqb60uuk-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 16:35:39 -0400
Received: from localhost
        by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
        Sat, 24 Sep 2016 06:35:36 +1000
In-Reply-To: <40b65ab2bb3a48837ab047a70887de3ccd70c56b.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
In-Reply-To: <40b65ab2bb3a48837ab047a70887de3ccd70c56b.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
References: <40b65ab2bb3a48837ab047a70887de3ccd70c56b.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In line with similar support for other architectures by Daniel Borkmann.

'MOD Default X' from test_bpf without constant blinding:
84 bytes emitted from JIT compiler (pass:3, flen:7)
d0000000058a4688 + <x>:
   0:	nop
   4:	nop
   8:	std     r27,-40(r1)
   c:	std     r28,-32(r1)
  10:	xor     r8,r8,r8
  14:	xor     r28,r28,r28
  18:	mr      r27,r3
  1c:	li      r8,66
  20:	cmpwi   r28,0
  24:	bne     0x0000000000000030
  28:	li      r8,0
  2c:	b       0x0000000000000044
  30:	divwu   r9,r8,r28
  34:	mullw   r9,r28,r9
  38:	subf    r8,r9,r8
  3c:	rotlwi  r8,r8,0
  40:	li      r8,66
  44:	ld      r27,-40(r1)
  48:	ld      r28,-32(r1)
  4c:	mr      r3,r8
  50:	blr

... and with constant blinding:
140 bytes emitted from JIT compiler (pass:3, flen:11)
d00000000bd6ab24 + <x>:
   0:	nop
   4:	nop
   8:	std     r27,-40(r1)
   c:	std     r28,-32(r1)
  10:	xor     r8,r8,r8
  14:	xor     r28,r28,r28
  18:	mr      r27,r3
  1c:	lis     r2,-22834
  20:	ori     r2,r2,36083
  24:	rotlwi  r2,r2,0
  28:	xori    r2,r2,36017
  2c:	xoris   r2,r2,42702
  30:	rotlwi  r2,r2,0
  34:	mr      r8,r2
  38:	rotlwi  r8,r8,0
  3c:	cmpwi   r28,0
  40:	bne     0x000000000000004c
  44:	li      r8,0
  48:	b       0x000000000000007c
  4c:	divwu   r9,r8,r28
  50:	mullw   r9,r28,r9
  54:	subf    r8,r9,r8
  58:	rotlwi  r8,r8,0
  5c:	lis     r2,-17137
  60:	ori     r2,r2,39065
  64:	rotlwi  r2,r2,0
  68:	xori    r2,r2,39131
  6c:	xoris   r2,r2,48399
  70:	rotlwi  r2,r2,0
  74:	mr      r8,r2
  78:	rotlwi  r8,r8,0
  7c:	ld      r27,-40(r1)
  80:	ld      r28,-32(r1)
  84:	mr      r3,r8
  88:	blr

Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 arch/powerpc/net/bpf_jit64.h      |  9 +++++----
 arch/powerpc/net/bpf_jit_comp64.c | 36 +++++++++++++++++++++++++++++-------
 2 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit64.h b/arch/powerpc/net/bpf_jit64.h
index 038e00b..62fa758 100644
--- a/arch/powerpc/net/bpf_jit64.h
+++ b/arch/powerpc/net/bpf_jit64.h
@@ -39,10 +39,10 @@
 #ifndef __ASSEMBLY__
 
 /* BPF register usage */
-#define SKB_HLEN_REG	(MAX_BPF_REG + 0)
-#define SKB_DATA_REG	(MAX_BPF_REG + 1)
-#define TMP_REG_1	(MAX_BPF_REG + 2)
-#define TMP_REG_2	(MAX_BPF_REG + 3)
+#define SKB_HLEN_REG	(MAX_BPF_JIT_REG + 0)
+#define SKB_DATA_REG	(MAX_BPF_JIT_REG + 1)
+#define TMP_REG_1	(MAX_BPF_JIT_REG + 2)
+#define TMP_REG_2	(MAX_BPF_JIT_REG + 3)
 
 /* BPF to ppc register mappings */
 static const int b2p[] = {
@@ -62,6 +62,7 @@ static const int b2p[] = {
 	/* frame pointer aka BPF_REG_10 */
 	[BPF_REG_FP] = 31,
 	/* eBPF jit internal registers */
+	[BPF_REG_AX] = 2,
 	[SKB_HLEN_REG] = 25,
 	[SKB_DATA_REG] = 26,
 	[TMP_REG_1] = 9,
diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index 3ec29d6..0fe98a5 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -974,21 +974,37 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 	int pass;
 	int flen;
 	struct bpf_binary_header *bpf_hdr;
+	struct bpf_prog *org_fp = fp;
+	struct bpf_prog *tmp_fp;
+	bool bpf_blinded = false;
 
 	if (!bpf_jit_enable)
-		return fp;
+		return org_fp;
+
+	tmp_fp = bpf_jit_blind_constants(org_fp);
+	if (IS_ERR(tmp_fp))
+		return org_fp;
+
+	if (tmp_fp != org_fp) {
+		bpf_blinded = true;
+		fp = tmp_fp;
+	}
 
 	flen = fp->len;
 	addrs = kzalloc((flen+1) * sizeof(*addrs), GFP_KERNEL);
-	if (addrs == NULL)
-		return fp;
+	if (addrs == NULL) {
+		fp = org_fp;
+		goto out;
+	}
+
+	memset(&cgctx, 0, sizeof(struct codegen_context));
 
-	cgctx.idx = 0;
-	cgctx.seen = 0;
 	/* Scouting faux-generate pass 0 */
-	if (bpf_jit_build_body(fp, 0, &cgctx, addrs))
+	if (bpf_jit_build_body(fp, 0, &cgctx, addrs)) {
 		/* We hit something illegal or unsupported. */
+		fp = org_fp;
 		goto out;
+	}
 
 	/*
 	 * Pretend to build prologue, given the features we've seen.  This will
@@ -1003,8 +1019,10 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 
 	bpf_hdr = bpf_jit_binary_alloc(alloclen, &image, 4,
 			bpf_jit_fill_ill_insns);
-	if (!bpf_hdr)
+	if (!bpf_hdr) {
+		fp = org_fp;
 		goto out;
+	}
 
 	code_base = (u32 *)(image + FUNCTION_DESCR_SIZE);
 
@@ -1041,6 +1059,10 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 
 out:
 	kfree(addrs);
+
+	if (bpf_blinded)
+		bpf_jit_prog_release_other(fp, fp == org_fp ? tmp_fp : org_fp);
+
 	return fp;
 }
 
-- 
2.9.3
