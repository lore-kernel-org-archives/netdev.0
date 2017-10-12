From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 12/12] nfp: bpf: support direct packet access in TC
Date: Thu, 12 Oct 2017 10:34:18 -0700
Message-ID: <20171012173418.4029-13-jakub.kicinski@netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:43264 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751849AbdJLRe7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:34:59 -0400
Received: by mail-pf0-f171.google.com with SMTP id a8so5395720pfc.0
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:34:59 -0700 (PDT)
In-Reply-To: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for direct packet access in TC, note that because
writing the packet will cause the verifier to generate a csum
fixup prologue we won't be able to offload packet writes from
TC, just yet, only the reads will work.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 139a4ebdc774..23fb11a41cc4 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -1135,12 +1135,25 @@ static int data_ind_ld4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 static int mem_ldx_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 		       u8 size)
 {
+	swreg dst = reg_both(meta->insn.dst_reg * 2);
+
 	switch (meta->insn.off) {
 	case offsetof(struct sk_buff, len):
 		if (size != FIELD_SIZEOF(struct sk_buff, len))
 			return -EOPNOTSUPP;
-		wrp_mov(nfp_prog,
-			reg_both(meta->insn.dst_reg * 2), plen_reg(nfp_prog));
+		wrp_mov(nfp_prog, dst, plen_reg(nfp_prog));
+		break;
+	case offsetof(struct sk_buff, data):
+		if (size != sizeof(void *))
+			return -EOPNOTSUPP;
+		wrp_mov(nfp_prog, dst, pptr_reg(nfp_prog));
+		break;
+	case offsetof(struct sk_buff, cb) +
+	     offsetof(struct bpf_skb_data_end, data_end):
+		if (size != sizeof(void *))
+			return -EOPNOTSUPP;
+		emit_alu(nfp_prog, dst,
+			 plen_reg(nfp_prog), ALU_OP_ADD, pptr_reg(nfp_prog));
 		break;
 	default:
 		return -EOPNOTSUPP;
-- 
2.14.1
