From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv6 net-next 12/15] nfp: bpf: add packet marking support
Date: Sun, 18 Sep 2016 16:09:22 +0100
Message-ID: <1474211365-20088-13-git-send-email-jakub.kicinski@netronome.com>
References: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35168 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754132AbcIRPJ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 11:09:58 -0400
Received: by mail-wm0-f46.google.com with SMTP id l132so112199223wmf.0
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 08:09:58 -0700 (PDT)
In-Reply-To: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing ABI defines and eBPF instructions to allow
mark to be passed on and extend prepend parsing on the
RX path to pick it up from packet metadata.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
v3:
 - change metadata format.
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf.h       |  2 +
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c   | 19 +++++
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  2 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 91 +++++++++++++++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  7 ++
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |  2 +-
 6 files changed, 101 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
index 3726421e353f..2adb1d80c7b7 100644
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
index cfbf53607fc9..368381f0357f 100644
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
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 13c6a9001b4d..ed824e11a1e3 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -269,6 +269,8 @@ struct nfp_net_rx_desc {
 	};
 };
 
+#define NFP_NET_META_FIELD_MASK GENMASK(NFP_NET_META_FIELD_SIZE - 1, 0)
+
 struct nfp_net_rx_hash {
 	__be32 hash_type;
 	__be32 hash;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index f091eb758ca2..415691edcaa5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1293,38 +1293,72 @@ static void nfp_net_rx_csum(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 	}
 }
 
-/**
- * nfp_net_set_hash() - Set SKB hash data
- * @netdev: adapter's net_device structure
- * @skb:   SKB to set the hash data on
- * @rxd:   RX descriptor
- *
- * The RSS hash and hash-type are pre-pended to the packet data.
- * Extract and decode it and set the skb fields.
- */
 static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
-			     struct nfp_net_rx_desc *rxd)
+			     unsigned int type, __be32 *hash)
 {
-	struct nfp_net_rx_hash *rx_hash;
-
-	if (!(rxd->rxd.flags & PCIE_DESC_RX_RSS) ||
-	    !(netdev->features & NETIF_F_RXHASH))
+	if (!(netdev->features & NETIF_F_RXHASH))
 		return;
 
-	rx_hash = (struct nfp_net_rx_hash *)(skb->data - sizeof(*rx_hash));
-
-	switch (be32_to_cpu(rx_hash->hash_type)) {
+	switch (type) {
 	case NFP_NET_RSS_IPV4:
 	case NFP_NET_RSS_IPV6:
 	case NFP_NET_RSS_IPV6_EX:
-		skb_set_hash(skb, be32_to_cpu(rx_hash->hash), PKT_HASH_TYPE_L3);
+		skb_set_hash(skb, get_unaligned_be32(hash), PKT_HASH_TYPE_L3);
 		break;
 	default:
-		skb_set_hash(skb, be32_to_cpu(rx_hash->hash), PKT_HASH_TYPE_L4);
+		skb_set_hash(skb, get_unaligned_be32(hash), PKT_HASH_TYPE_L4);
 		break;
 	}
 }
 
+static void
+nfp_net_set_hash_desc(struct net_device *netdev, struct sk_buff *skb,
+		      struct nfp_net_rx_desc *rxd)
+{
+	struct nfp_net_rx_hash *rx_hash;
+
+	if (!(rxd->rxd.flags & PCIE_DESC_RX_RSS))
+		return;
+
+	rx_hash = (struct nfp_net_rx_hash *)(skb->data - sizeof(*rx_hash));
+
+	nfp_net_set_hash(netdev, skb, get_unaligned_be32(&rx_hash->hash_type),
+			 &rx_hash->hash);
+}
+
+static void *
+nfp_net_parse_meta(struct net_device *netdev, struct sk_buff *skb,
+		   int meta_len)
+{
+	u8 *data = skb->data - meta_len;
+	u32 meta_info;
+
+	meta_info = get_unaligned_be32(data);
+	data += 4;
+
+	while (meta_info) {
+		switch (meta_info & NFP_NET_META_FIELD_MASK) {
+		case NFP_NET_META_HASH:
+			meta_info >>= NFP_NET_META_FIELD_SIZE;
+			nfp_net_set_hash(netdev, skb,
+					 meta_info & NFP_NET_META_FIELD_MASK,
+					 (__be32 *)data);
+			data += 4;
+			break;
+		case NFP_NET_META_MARK:
+			skb->mark = get_unaligned_be32(data);
+			data += 4;
+			break;
+		default:
+			return NULL;
+		}
+
+		meta_info >>= NFP_NET_META_FIELD_SIZE;
+	}
+
+	return data;
+}
+
 /**
  * nfp_net_rx() - receive up to @budget packets on @rx_ring
  * @rx_ring:   RX ring to receive from
@@ -1439,14 +1473,29 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			skb_reserve(skb, nn->rx_offset);
 		skb_put(skb, data_len - meta_len);
 
-		nfp_net_set_hash(nn->netdev, skb, rxd);
-
 		/* Stats update */
 		u64_stats_update_begin(&r_vec->rx_sync);
 		r_vec->rx_pkts++;
 		r_vec->rx_bytes += skb->len;
 		u64_stats_update_end(&r_vec->rx_sync);
 
+		if (nn->fw_ver.major <= 3) {
+			nfp_net_set_hash_desc(nn->netdev, skb, rxd);
+		} else if (meta_len) {
+			void *end;
+
+			end = nfp_net_parse_meta(nn->netdev, skb, meta_len);
+			if (unlikely(end != skb->data)) {
+				u64_stats_update_begin(&r_vec->rx_sync);
+				r_vec->rx_drops++;
+				u64_stats_update_end(&r_vec->rx_sync);
+
+				dev_kfree_skb_any(skb);
+				nn_warn_ratelimit(nn, "invalid RX packet metadata\n");
+				continue;
+			}
+		}
+
 		skb_record_rx_queue(skb, rx_ring->idx);
 		skb->protocol = eth_type_trans(skb, nn->netdev);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index 7aa11f3c5ef0..93b10b441acb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -66,6 +66,13 @@
 #define NFP_NET_LSO_MAX_HDR_SZ		255
 
 /**
+ * Prepend field types
+ */
+#define NFP_NET_META_FIELD_SIZE		4
+#define NFP_NET_META_HASH		1 /* next field carries hash type */
+#define NFP_NET_META_MARK		2
+
+/**
  * Hash type pre-pended when a RSS hash was computed
  */
 #define NFP_NET_RSS_NONE                0
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
index f7062cb648e1..2800bbf65a89 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
@@ -148,7 +148,7 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 		dev_warn(&pdev->dev, "OBSOLETE Firmware detected - VF isolation not available\n");
 	} else {
 		switch (fw_ver.major) {
-		case 1 ... 3:
+		case 1 ... 4:
 			if (is_nfp3200) {
 				stride = 2;
 				tx_bar_no = NFP_NET_Q0_BAR;
-- 
1.9.1
