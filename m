From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: populate skb->l4_rxhash
Date: Mon, 09 Jul 2012 18:02:24 +0200
Message-ID: <1341849744.3265.3219.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42357 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082Ab2GIQC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 12:02:29 -0400
Received: by eaak11 with SMTP id k11so4394551eaa.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 09:02:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

l4_rxhash is set on skb when rxhash is obtained from canonical 4-tuple
over transport ports/addresses.

We can set skb->l4_rxhash for all incoming TCP packets on bnx2x for
free, as cqe status contains a hash type information.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     |    1 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   19 +++++++++++---
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 362d16f..d2dc420 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -454,6 +454,7 @@ struct bnx2x_agg_info {
 	u16			vlan_tag;
 	u16			len_on_bd;
 	u32			rxhash;
+	bool			l4_rxhash;
 	u16			gro_size;
 	u16			full_page;
 };
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 00951b3..5aeb034 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -295,12 +295,20 @@ static inline void bnx2x_update_sge_prod(struct bnx2x_fastpath *fp,
  * CQE (calculated by HW).
  */
 static u32 bnx2x_get_rxhash(const struct bnx2x *bp,
-			    const struct eth_fast_path_rx_cqe *cqe)
+			    const struct eth_fast_path_rx_cqe *cqe,
+			    bool *l4_rxhash)
 {
 	/* Set Toeplitz hash from CQE */
 	if ((bp->dev->features & NETIF_F_RXHASH) &&
-	    (cqe->status_flags & ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG))
+	    (cqe->status_flags & ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG)) {
+		enum eth_rss_hash_type htype;
+
+		htype = cqe->status_flags & ETH_FAST_PATH_RX_CQE_RSS_HASH_TYPE;
+		*l4_rxhash = (htype == TCP_IPV4_HASH_TYPE) ||
+			     (htype == TCP_IPV6_HASH_TYPE);
 		return le32_to_cpu(cqe->rss_hash_result);
+	}
+	*l4_rxhash = false;
 	return 0;
 }
 
@@ -354,7 +362,7 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
 	tpa_info->tpa_state = BNX2X_TPA_START;
 	tpa_info->len_on_bd = le16_to_cpu(cqe->len_on_bd);
 	tpa_info->placement_offset = cqe->placement_offset;
-	tpa_info->rxhash = bnx2x_get_rxhash(bp, cqe);
+	tpa_info->rxhash = bnx2x_get_rxhash(bp, cqe, &tpa_info->l4_rxhash);
 	if (fp->mode == TPA_MODE_GRO) {
 		u16 gro_size = le16_to_cpu(cqe->pkt_len_or_gro_seg_len);
 		tpa_info->full_page =
@@ -589,6 +597,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		skb_reserve(skb, pad + NET_SKB_PAD);
 		skb_put(skb, len);
 		skb->rxhash = tpa_info->rxhash;
+		skb->l4_rxhash = tpa_info->l4_rxhash;
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -712,6 +721,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		enum eth_rx_cqe_type cqe_fp_type;
 		u16 len, pad, queue;
 		u8 *data;
+		bool l4_rxhash;
 
 #ifdef BNX2X_STOP_ON_ERROR
 		if (unlikely(bp->panic))
@@ -855,7 +865,8 @@ reuse_rx:
 		skb->protocol = eth_type_trans(skb, bp->dev);
 
 		/* Set Toeplitz hash for a none-LRO skb */
-		skb->rxhash = bnx2x_get_rxhash(bp, cqe_fp);
+		skb->rxhash = bnx2x_get_rxhash(bp, cqe_fp, &l4_rxhash);
+		skb->l4_rxhash = l4_rxhash;
 
 		skb_checksum_none_assert(skb);
 
