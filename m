From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 08/12] nfp: bpf: fix context accesses
Date: Thu, 12 Oct 2017 10:34:14 -0700
Message-ID: <20171012173418.4029-9-jakub.kicinski@netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:45112 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752836AbdJLRez (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:34:55 -0400
Received: by mail-pf0-f173.google.com with SMTP id d28so5857816pfe.2
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:34:55 -0700 (PDT)
In-Reply-To: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sizes of fields in struct xdp_md/xdp_buff and some in sk_buff depend
on target architecture.  Take that into account and use struct xdp_buff,
not struct xdp_md.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 49 ++++++++++++++++------------
 1 file changed, 29 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 5e8a6b766790..4b62f5497728 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -1070,47 +1070,56 @@ static int data_ind_ld4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 				     meta->insn.src_reg * 2, true, 4);
 }
 
-static int mem_ldx4_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+static int mem_ldx_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
+		       u8 size)
 {
-	if (meta->insn.off == offsetof(struct sk_buff, len))
+	switch (meta->insn.off) {
+	case offsetof(struct sk_buff, len):
+		if (size != FIELD_SIZEOF(struct sk_buff, len))
+			return -EOPNOTSUPP;
 		wrp_mov(nfp_prog,
 			reg_both(meta->insn.dst_reg * 2), plen_reg(nfp_prog));
-	else
+		break;
+	default:
 		return -EOPNOTSUPP;
+	}
+
+	wrp_immed(nfp_prog, reg_both(meta->insn.dst_reg * 2 + 1), 0);
 
 	return 0;
 }
 
-static int mem_ldx4_xdp(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+static int mem_ldx_xdp(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
+		       u8 size)
 {
 	swreg dst = reg_both(meta->insn.dst_reg * 2);
 
-	if (meta->insn.off != offsetof(struct xdp_md, data) &&
-	    meta->insn.off != offsetof(struct xdp_md, data_end))
-		return -EOPNOTSUPP;
-
-	wrp_mov(nfp_prog, dst, pptr_reg(nfp_prog));
+	if (size != sizeof(void *))
+		return -EINVAL;
 
-	if (meta->insn.off == offsetof(struct xdp_md, data))
-		return 0;
+	switch (meta->insn.off) {
+	case offsetof(struct xdp_buff, data):
+		wrp_mov(nfp_prog, dst, pptr_reg(nfp_prog));
+		break;
+	case offsetof(struct xdp_buff, data_end):
+		emit_alu(nfp_prog, dst,
+			 plen_reg(nfp_prog), ALU_OP_ADD, pptr_reg(nfp_prog));
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
 
-	emit_alu(nfp_prog, dst,	dst, ALU_OP_ADD, plen_reg(nfp_prog));
+	wrp_immed(nfp_prog, reg_both(meta->insn.dst_reg * 2 + 1), 0);
 
 	return 0;
 }
 
 static int mem_ldx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	int ret;
-
 	if (nfp_prog->act == NN_ACT_XDP)
-		ret = mem_ldx4_xdp(nfp_prog, meta);
+		return mem_ldx_xdp(nfp_prog, meta, 4);
 	else
-		ret = mem_ldx4_skb(nfp_prog, meta);
-
-	wrp_immed(nfp_prog, reg_both(meta->insn.dst_reg * 2 + 1), 0);
-
-	return ret;
+		return mem_ldx_skb(nfp_prog, meta, 4);
 }
 
 static int mem_stx4_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
-- 
2.14.1
