From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 07/12] nfp: add skb mark support to the bpf offload
Date: Wed,  1 Jun 2016 17:50:09 +0100
Message-ID: <1464799814-4453-8-git-send-email-jakub.kicinski@netronome.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35255 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932666AbcFAQv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:51:56 -0400
Received: by mail-wm0-f42.google.com with SMTP id a136so191957836wme.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:51:55 -0700 (PDT)
In-Reply-To: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Skb marking should be set in designated register, FW will
prepend it to the packet for us.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c    | 20 ++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net.h        |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c |  8 +++++++-
 3 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
index d7eecfceba5c..b31e673a6fe8 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
@@ -46,6 +46,8 @@
 
 #define REG_IMM0_N	30 /* Bank AB */
 #define REG_QNUM	29 /* Bank AB */
+#define REG_MARK	28 /* Bank A */
+#define REG_MARK_STS	28 /* Bank B */
 
 /* --- NFP prog --- */
 /* Foreach "multiple" entries macros provide pos and next<n> pointers.
@@ -416,6 +418,15 @@ static int construct_data_ld(struct nfp_prog *nfp_prog, u16 offset, u8 size)
 	return construct_data_ind_ld(nfp_prog, offset, 0, false, size);
 }
 
+static int wrp_skb_mark(struct nfp_prog *nfp_prog, u16 src)
+{
+	__emit_alu(nfp_prog, REG_MARK, ALU_DST_A, REG_NONE, ALU_OP_NONE, src,
+		   false, false);
+	__emit_immed(nfp_prog, REG_MARK_STS, ALU_DST_B, 1, false);
+
+	return 0;
+}
+
 static int
 construct_br_imm(struct nfp_prog *nfp_prog, u32 imm, u16 dst, u8 br, u16 off,
 		 enum alu_op alu_op, bool sw)
@@ -538,6 +549,14 @@ static int imm_ld8(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	return 0;
 }
 
+static int mem_stx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	if (meta->insn.off == offsetof(struct sk_buff, mark))
+		return wrp_skb_mark(nfp_prog, meta->insn.src_reg * 2);
+
+	return -ENOTSUPP;
+}
+
 static int and_immX(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	const struct bpf_insn *insn = &meta->insn;
@@ -660,6 +679,7 @@ static const instr_cb_t instr_cb[256] = {
 	[BPF_LD | BPF_IND | BPF_B] =	data_ind_ld1,
 	[BPF_LD | BPF_IND | BPF_H] =	data_ind_ld2,
 	[BPF_LD | BPF_IND | BPF_W] =	data_ind_ld4,
+	[BPF_STX | BPF_MEM | BPF_W] =	mem_stx4,
 	[BPF_JMP | BPF_JA | BPF_K] =	ja_imm,
 	[BPF_JMP | BPF_JEQ | BPF_K] =	jeq_imm,
 	[BPF_JMP | BPF_JGT | BPF_K] =	jgt_imm,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 784287e9ccaa..5df713b8f7c5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -220,7 +220,7 @@ struct nfp_net_tx_ring {
 #define PCIE_DESC_RX_I_TCP_CSUM_OK	cpu_to_le16(BIT(11))
 #define PCIE_DESC_RX_I_UDP_CSUM		cpu_to_le16(BIT(10))
 #define PCIE_DESC_RX_I_UDP_CSUM_OK	cpu_to_le16(BIT(9))
-#define PCIE_DESC_RX_SPARE		cpu_to_le16(BIT(8))
+#define PCIE_DESC_RX_BPF		cpu_to_le16(BIT(8))
 #define PCIE_DESC_RX_EOP		cpu_to_le16(BIT(7))
 #define PCIE_DESC_RX_IP4_CSUM		cpu_to_le16(BIT(6))
 #define PCIE_DESC_RX_IP4_CSUM_OK	cpu_to_le16(BIT(5))
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index c5acdf703b7f..706927b94e28 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1307,12 +1307,18 @@ static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
 			     struct nfp_net_rx_desc *rxd)
 {
 	struct nfp_net_rx_hash *rx_hash;
+	void *data = skb->data;
+
+	if (rxd->rxd.flags & PCIE_DESC_RX_BPF) {
+		skb->mark = get_unaligned_be32(data - 4);
+		data -= 4;
+	}
 
 	if (!(rxd->rxd.flags & PCIE_DESC_RX_RSS) ||
 	    !(netdev->features & NETIF_F_RXHASH))
 		return;
 
-	rx_hash = (struct nfp_net_rx_hash *)(skb->data - sizeof(*rx_hash));
+	rx_hash = (struct nfp_net_rx_hash *)(data - sizeof(*rx_hash));
 
 	switch (be32_to_cpu(rx_hash->hash_type)) {
 	case NFP_NET_RSS_IPV4:
-- 
1.9.1
