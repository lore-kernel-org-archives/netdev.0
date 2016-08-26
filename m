From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFCv2 13/16] nfp: bpf: add packet marking support
Date: Fri, 26 Aug 2016 19:06:12 +0100
Message-ID: <1472234775-29453-14-git-send-email-jakub.kicinski@netronome.com>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38496 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751556AbcHZSI4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:08:56 -0400
Received: by mail-wm0-f46.google.com with SMTP id o80so3284857wme.1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 11:08:02 -0700 (PDT)
In-Reply-To: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing ABI defines and eBPF instructions to allow
mark to be passed on and extend prepend parsing on the
RX path to pick it up from packet metadata.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf.h       |  2 ++
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c   | 19 +++++++++++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 38 ++++++++++++++++++----
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  8 +++++
 4 files changed, 60 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
index f4265f88db23..85b258a70b18 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
@@ -91,6 +91,8 @@ enum nfp_bpf_reg_type {
 #define imm_both(np)	reg_both((np)->regs_per_thread - STATIC_REG_IMM)
 
 #define NFP_BPF_ABI_FLAGS	reg_nnr(0)
+#define   NFP_BPF_ABI_FLAG_MARK	1
+#define NFP_BPF_ABI_MARK	reg_nnr(1)
 #define NFP_BPF_ABI_PKT		reg_nnr(2)
 #define NFP_BPF_ABI_LEN		reg_nnr(3)
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
index 09ed1627ae20..ca73be6fcc3d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
@@ -674,6 +674,16 @@ static int construct_data_ld(struct nfp_prog *nfp_prog, u16 offset, u8 size)
 	return construct_data_ind_ld(nfp_prog, offset, 0, false, size);
 }
 
+static int wrp_set_mark(struct nfp_prog *nfp_prog, u8 src)
+{
+	emit_alu(nfp_prog, NFP_BPF_ABI_MARK,
+		 reg_none(), ALU_OP_NONE, reg_b(src));
+	emit_alu(nfp_prog, NFP_BPF_ABI_FLAGS,
+		 NFP_BPF_ABI_FLAGS, ALU_OP_OR, reg_imm(NFP_BPF_ABI_FLAG_MARK));
+
+	return 0;
+}
+
 static void
 wrp_alu_imm(struct nfp_prog *nfp_prog, u8 dst, enum alu_op alu_op, u32 imm)
 {
@@ -1117,6 +1127,14 @@ static int mem_ldx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	return 0;
 }
 
+static int mem_stx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	if (meta->insn.off == offsetof(struct sk_buff, mark))
+		return wrp_set_mark(nfp_prog, meta->insn.src_reg * 2);
+
+	return -ENOTSUPP;
+}
+
 static int jump(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	if (meta->insn.off < 0) /* TODO */
@@ -1306,6 +1324,7 @@ static const instr_cb_t instr_cb[256] = {
 	[BPF_LD | BPF_IND | BPF_H] =	data_ind_ld2,
 	[BPF_LD | BPF_IND | BPF_W] =	data_ind_ld4,
 	[BPF_LDX | BPF_MEM | BPF_W] =	mem_ldx4,
+	[BPF_STX | BPF_MEM | BPF_W] =	mem_stx4,
 	[BPF_JMP | BPF_JA | BPF_K] =	jump,
 	[BPF_JMP | BPF_JEQ | BPF_K] =	jeq_imm,
 	[BPF_JMP | BPF_JGT | BPF_K] =	jgt_imm,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 053bda8a0fbd..739dd13dc18e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1298,23 +1298,20 @@ static void nfp_net_rx_csum(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
  * nfp_net_set_hash() - Set SKB hash data
  * @netdev: adapter's net_device structure
  * @skb:   SKB to set the hash data on
- * @rxd:   RX descriptor
  *
  * The RSS hash and hash-type are pre-pended to the packet data.
  * Extract and decode it and set the skb fields.
  */
-static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
-			     struct nfp_net_rx_desc *rxd)
+static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb)
 {
 	struct nfp_net_rx_hash *rx_hash;
 
-	if (!(rxd->rxd.flags & PCIE_DESC_RX_RSS) ||
-	    !(netdev->features & NETIF_F_RXHASH))
+	if (!(netdev->features & NETIF_F_RXHASH))
 		return;
 
 	rx_hash = (struct nfp_net_rx_hash *)(skb->data - sizeof(*rx_hash));
 
-	switch (be32_to_cpu(rx_hash->hash_type)) {
+	switch (be32_to_cpu(rx_hash->hash_type) & NPF_NET_META_FIELD_HASH) {
 	case NFP_NET_RSS_IPV4:
 	case NFP_NET_RSS_IPV6:
 	case NFP_NET_RSS_IPV6_EX:
@@ -1326,6 +1323,33 @@ static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
 	}
 }
 
+static void
+nfp_net_parse_meta(struct net_device *netdev, struct sk_buff *skb,
+		   struct nfp_net_rx_desc *rxd, int meta_len)
+{
+	u32 meta_info;
+	u8 *data = skb->data - 4;
+
+	if (rxd->rxd.flags & PCIE_DESC_RX_RSS) {
+		data -= 4;
+		nfp_net_set_hash(netdev, skb);
+	}
+
+	meta_info = get_unaligned_be32(data) >> 8;
+	data -= 4;
+
+	while (meta_info) {
+		switch (meta_info & GENMASK(NFP_NET_META_FIELD_SIZE, 0)) {
+		case NFP_NET_META_MARK:
+			skb->mark = get_unaligned_be32(data);
+			data -= 4;
+			break;
+		}
+
+		meta_info >>= NFP_NET_META_FIELD_SIZE;
+	}
+}
+
 /**
  * nfp_net_rx() - receive up to @budget packets on @rx_ring
  * @rx_ring:   RX ring to receive from
@@ -1440,7 +1464,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			skb_reserve(skb, nn->rx_offset);
 		skb_put(skb, data_len - meta_len);
 
-		nfp_net_set_hash(nn->netdev, skb, rxd);
+		nfp_net_parse_meta(nn->netdev, skb, rxd, meta_len);
 
 		/* Pad small frames to minimum */
 		if (skb_put_padto(skb, 60))
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index a4b0ef11a09c..4c30439d3fcb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -80,6 +80,14 @@
 #define NFP_NET_RSS_IPV6_EX_UDP         9
 
 /**
+ * Prepend field types
+ */
+#define NPF_NET_META_FIELD_HASH		0xff
+
+#define NFP_NET_META_FIELD_SIZE		4
+#define NFP_NET_META_MARK		1
+
+/**
  * @NFP_NET_TXR_MAX:         Maximum number of TX rings
  * @NFP_NET_RXR_MAX:         Maximum number of RX rings
  */
-- 
1.9.1
