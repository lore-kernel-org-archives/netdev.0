From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 9/9] nfp: bpf: optimize mov64 a little
Date: Mon, 23 Oct 2017 11:58:14 -0700
Message-ID: <20171023185814.4797-10-jakub.kicinski@netronome.com>
References: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:44841 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751823AbdJWS6e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:58:34 -0400
Received: by mail-pf0-f196.google.com with SMTP id x7so17789019pfa.1
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 11:58:34 -0700 (PDT)
In-Reply-To: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Loading 64bit constants require up to 4 load immediates, since
we can only load 16 bits at a time.  If the 32bit halves of
the 64bit constant are the same, however, we can save a cycle
by doing a register move instead of two loads of 16 bits.

Note that we don't optimize the normal ALU64 load because even
though it's a 64 bit load the upper half of the register is
a coming from sign extension so we can load it in one cycle
anyway.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index d84f00b80aac..e7eeb7a07f81 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -1384,19 +1384,28 @@ static int end_reg32(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 
 static int imm_ld8_part2(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	wrp_immed(nfp_prog, reg_both(nfp_meta_prev(meta)->insn.dst_reg * 2 + 1),
-		  meta->insn.imm);
+	struct nfp_insn_meta *prev = nfp_meta_prev(meta);
+	u32 imm_lo, imm_hi;
+	u8 dst;
+
+	dst = prev->insn.dst_reg * 2;
+	imm_lo = prev->insn.imm;
+	imm_hi = meta->insn.imm;
+
+	wrp_immed(nfp_prog, reg_both(dst), imm_lo);
+
+	/* mov is always 1 insn, load imm may be two, so try to use mov */
+	if (imm_hi == imm_lo)
+		wrp_mov(nfp_prog, reg_both(dst + 1), reg_a(dst));
+	else
+		wrp_immed(nfp_prog, reg_both(dst + 1), imm_hi);
 
 	return 0;
 }
 
 static int imm_ld8(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	const struct bpf_insn *insn = &meta->insn;
-
 	meta->double_cb = imm_ld8_part2;
-	wrp_immed(nfp_prog, reg_both(insn->dst_reg * 2), insn->imm);
-
 	return 0;
 }
 
-- 
2.14.1
