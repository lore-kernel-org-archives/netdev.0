From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 07/15] nfp: bpf: remove packet marking support
Date: Sun,  8 Oct 2017 21:04:09 -0700
Message-ID: <20171009040417.22172-8-jakub.kicinski@netronome.com>
References: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:45869 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751343AbdJIEFx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:05:53 -0400
Received: by mail-pf0-f182.google.com with SMTP id z84so12536279pfi.2
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:05:52 -0700 (PDT)
In-Reply-To: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Temporarily drop support for skb->mark.  We are primarily focusing
on XDP offload, and implementing skb->mark on the new datapath has
lower priority.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c  | 13 -------------
 drivers/net/ethernet/netronome/nfp/bpf/main.h |  3 +--
 2 files changed, 1 insertion(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 469dc8a055f2..4fa220f710d2 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -542,16 +542,6 @@ static int construct_data_ld(struct nfp_prog *nfp_prog, u16 offset, u8 size)
 	return construct_data_ind_ld(nfp_prog, offset, 0, false, size);
 }
 
-static int wrp_set_mark(struct nfp_prog *nfp_prog, u8 src)
-{
-	emit_alu(nfp_prog, NFP_BPF_ABI_MARK,
-		 reg_none(), ALU_OP_NONE, reg_b(src));
-	emit_alu(nfp_prog, NFP_BPF_ABI_FLAGS,
-		 NFP_BPF_ABI_FLAGS, ALU_OP_OR, reg_imm(NFP_BPF_ABI_FLAG_MARK));
-
-	return 0;
-}
-
 static void
 wrp_alu_imm(struct nfp_prog *nfp_prog, u8 dst, enum alu_op alu_op, u32 imm)
 {
@@ -1053,9 +1043,6 @@ static int mem_ldx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 
 static int mem_stx4_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	if (meta->insn.off == offsetof(struct sk_buff, mark))
-		return wrp_set_mark(nfp_prog, meta->insn.src_reg * 2);
-
 	return -EOPNOTSUPP;
 }
 
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index ccc3dbea25f6..7d959757a51a 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -71,9 +71,8 @@ enum nfp_bpf_action_type {
 #define imm_b(np)	reg_b((np)->regs_per_thread - STATIC_REG_IMM)
 #define imm_both(np)	reg_both((np)->regs_per_thread - STATIC_REG_IMM)
 
-#define NFP_BPF_ABI_FLAGS	reg_nnr(0)
+#define NFP_BPF_ABI_FLAGS	reg_imm(0)
 #define   NFP_BPF_ABI_FLAG_MARK	1
-#define NFP_BPF_ABI_MARK	reg_nnr(1)
 #define NFP_BPF_ABI_PKT		reg_nnr(2)
 #define NFP_BPF_ABI_LEN		reg_nnr(3)
 
-- 
2.14.1
