From: Tom Herbert <therbert@google.com>
Subject: [PATCH] bnx2x: cleanup skb_set_hash
Date: Thu, 19 Dec 2013 08:59:08 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312190856320.8092@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:35765 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035Ab3LSQ7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 11:59:11 -0500
Received: by mail-vc0-f202.google.com with SMTP id hu19so27511vcb.3
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 08:59:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save pkt_hash_types in tpa structure.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 23 +++++++++++------------
 2 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index a1f66e2..a6d8406 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -472,7 +472,7 @@ struct bnx2x_agg_info {
 	u16			vlan_tag;
 	u16			len_on_bd;
 	u32			rxhash;
-	bool			l4_rxhash;
+	enum pkt_hash_types	rxhash_type;
 	u16			gro_size;
 	u16			full_page;
 };
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 787fef6..37b203b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -354,7 +354,7 @@ static inline void bnx2x_update_sge_prod(struct bnx2x_fastpath *fp,
  */
 static u32 bnx2x_get_rxhash(const struct bnx2x *bp,
 			    const struct eth_fast_path_rx_cqe *cqe,
-			    bool *l4_rxhash)
+			    enum pkt_hash_types *rxhash_type)
 {
 	/* Get Toeplitz hash from CQE */
 	if ((bp->dev->features & NETIF_F_RXHASH) &&
@@ -362,11 +362,13 @@ static u32 bnx2x_get_rxhash(const struct bnx2x *bp,
 		enum eth_rss_hash_type htype;
 
 		htype = cqe->status_flags & ETH_FAST_PATH_RX_CQE_RSS_HASH_TYPE;
-		*l4_rxhash = (htype == TCP_IPV4_HASH_TYPE) ||
-			     (htype == TCP_IPV6_HASH_TYPE);
+		*rxhash_type = ((htype == TCP_IPV4_HASH_TYPE) ||
+				(htype == TCP_IPV6_HASH_TYPE)) ?
+			       PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3;
+
 		return le32_to_cpu(cqe->rss_hash_result);
 	}
-	*l4_rxhash = false;
+	*rxhash_type = PKT_HASH_TYPE_NONE;
 	return 0;
 }
 
@@ -420,7 +422,7 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
 	tpa_info->tpa_state = BNX2X_TPA_START;
 	tpa_info->len_on_bd = le16_to_cpu(cqe->len_on_bd);
 	tpa_info->placement_offset = cqe->placement_offset;
-	tpa_info->rxhash = bnx2x_get_rxhash(bp, cqe, &tpa_info->l4_rxhash);
+	tpa_info->rxhash = bnx2x_get_rxhash(bp, cqe, &tpa_info->rxhash_type);
 	if (fp->mode == TPA_MODE_GRO) {
 		u16 gro_size = le16_to_cpu(cqe->pkt_len_or_gro_seg_len);
 		tpa_info->full_page = SGE_PAGES / gro_size * gro_size;
@@ -728,9 +730,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		skb_reserve(skb, pad + NET_SKB_PAD);
 		skb_put(skb, len);
-		skb_set_hash(skb, tpa_info->rxhash,
-			     tpa_info->l4_rxhash ?
-			     PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
+		skb_set_hash(skb, tpa_info->rxhash, tpa_info->rxhash_type);
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -848,7 +848,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		u16 len, pad, queue;
 		u8 *data;
 		u32 rxhash;
-		bool l4_rxhash;
+		enum pkt_hash_types rxhash_type;
 
 #ifdef BNX2X_STOP_ON_ERROR
 		if (unlikely(bp->panic))
@@ -989,9 +989,8 @@ reuse_rx:
 		skb->protocol = eth_type_trans(skb, bp->dev);
 
 		/* Set Toeplitz hash for a none-LRO skb */
-		rxhash = bnx2x_get_rxhash(bp, cqe_fp, &l4_rxhash);
-		skb_set_hash(skb, rxhash,
-			     l4_rxhash ? PKT_HASH_TYPE_L4 : PKT_HASH_TYPE_L3);
+		rxhash = bnx2x_get_rxhash(bp, cqe_fp, &rxhash_type);
+		skb_set_hash(skb, rxhash, rxhash_type);
 
 		skb_checksum_none_assert(skb);
 
-- 
1.8.5.1
