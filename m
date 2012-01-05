From: Manfred Rudigier <manfred.rudigier@omicron.at>
Subject: [PATCH] gianfar: Fix invalid TX frames returned on error queue when time stamping.
Date: Thu, 5 Jan 2012 15:50:21 +0100
Message-ID: <1325775021-23049-1-git-send-email-manfred.rudigier@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <afleming@freescale.com>,
	<avorontsov@mvista.com>,
	Manfred Rudigier <manfred.rudigier@omicron.at>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:34743 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753438Ab2AEO6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jan 2012 09:58:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When TX time stamping for PTP messages is enabled on a socket, a time
stamp is returned on the socket error queue to the user space application
after the frame was transmitted. The transmitted frame is also returned on
the error queue so that an application knows to which frame the time stamp
belongs.

In the current implementation the TxFCB is immediately followed by the
frame. Since the eTSEC inserts the TX time stamp 8 bytes after the TxFCB,
parts of the frame have been overwritten and an invalid frame was returned
on the socket error queue.

This patch fixes the described problem by adding additional 16 padding
bytes between the TxFCB and the frame for all messages sent from a time
stamping enabled socket (other sockets are not affected).

Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
---
 drivers/net/ethernet/freescale/gianfar.c |   33 ++++++++++++++++++++---------
 drivers/net/ethernet/freescale/gianfar.h |    3 ++
 2 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 83199fd..3a14eab 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1984,7 +1984,8 @@ static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
 	return fcb;
 }
 
-static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb)
+static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb,
+		int fcb_length)
 {
 	u8 flags = 0;
 
@@ -2006,7 +2007,7 @@ static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb)
 	 * frame (skb->data) and the start of the IP hdr.
 	 * l4os is the distance between the start of the
 	 * l3 hdr and the l4 hdr */
-	fcb->l3os = (u16)(skb_network_offset(skb) - GMAC_FCB_LEN);
+	fcb->l3os = (u16)(skb_network_offset(skb) - fcb_length);
 	fcb->l4os = skb_network_header_len(skb);
 
 	fcb->flags = flags;
@@ -2046,7 +2047,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int i, rq = 0, do_tstamp = 0;
 	u32 bufaddr;
 	unsigned long flags;
-	unsigned int nr_frags, nr_txbds, length;
+	unsigned int nr_frags, nr_txbds, length, fcb_length = GMAC_FCB_LEN;
 
 	/*
 	 * TOE=1 frames larger than 2500 bytes may see excess delays
@@ -2070,22 +2071,27 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* check if time stamp should be generated */
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
-		     priv->hwts_tx_en))
+			priv->hwts_tx_en)) {
 		do_tstamp = 1;
+		fcb_length = GMAC_FCB_LEN + GMAC_TXPAL_LEN;
+	}
 
 	/* make space for additional header when fcb is needed */
 	if (((skb->ip_summed == CHECKSUM_PARTIAL) ||
 			vlan_tx_tag_present(skb) ||
 			unlikely(do_tstamp)) &&
-			(skb_headroom(skb) < GMAC_FCB_LEN)) {
+			(skb_headroom(skb) < fcb_length)) {
 		struct sk_buff *skb_new;
 
-		skb_new = skb_realloc_headroom(skb, GMAC_FCB_LEN);
+		skb_new = skb_realloc_headroom(skb, fcb_length);
 		if (!skb_new) {
 			dev->stats.tx_errors++;
 			kfree_skb(skb);
 			return NETDEV_TX_OK;
 		}
+
+		/* Keep sock if we must return a time stamp on the err queue */
+		skb_new->sk = skb->sk;
 		kfree_skb(skb);
 		skb = skb_new;
 	}
@@ -2154,6 +2160,12 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		lstatus = txbdp_start->lstatus;
 	}
 
+	/* Add TxPAL between FCB and frame if required */
+	if (unlikely(do_tstamp)) {
+		skb_push(skb, GMAC_TXPAL_LEN);
+		memset(skb->data, 0, GMAC_TXPAL_LEN);
+	}
+
 	/* Set up checksumming */
 	if (CHECKSUM_PARTIAL == skb->ip_summed) {
 		fcb = gfar_add_fcb(skb);
@@ -2164,7 +2176,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb_checksum_help(skb);
 		} else {
 			lstatus |= BD_LFLAG(TXBD_TOE);
-			gfar_tx_checksum(skb, fcb);
+			gfar_tx_checksum(skb, fcb, fcb_length);
 		}
 	}
 
@@ -2196,9 +2208,9 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * the full frame length.
 	 */
 	if (unlikely(do_tstamp)) {
-		txbdp_tstamp->bufPtr = txbdp_start->bufPtr + GMAC_FCB_LEN;
+		txbdp_tstamp->bufPtr = txbdp_start->bufPtr + fcb_length;
 		txbdp_tstamp->lstatus |= BD_LFLAG(TXBD_READY) |
-				(skb_headlen(skb) - GMAC_FCB_LEN);
+				(skb_headlen(skb) - fcb_length);
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | GMAC_FCB_LEN;
 	} else {
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | skb_headlen(skb);
@@ -2490,7 +2502,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
 			next = next_txbd(bdp, base, tx_ring_size);
-			buflen = next->length + GMAC_FCB_LEN;
+			buflen = next->length + GMAC_FCB_LEN + GMAC_TXPAL_LEN;
 		} else
 			buflen = bdp->length;
 
@@ -2502,6 +2514,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 			u64 *ns = (u64*) (((u32)skb->data + 0x10) & ~0x7);
 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
 			shhwtstamps.hwtstamp = ns_to_ktime(*ns);
+			skb_pull(skb, GMAC_FCB_LEN + GMAC_TXPAL_LEN);
 			skb_tstamp_tx(skb, &shhwtstamps);
 			bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
 			bdp = next;
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 9aa4377..9fd5999 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -63,6 +63,9 @@ struct ethtool_rx_list {
 /* Length for FCB */
 #define GMAC_FCB_LEN 8
 
+/* Length for TxPAL */
+#define GMAC_TXPAL_LEN 16
+
 /* Default padding amount */
 #define DEFAULT_PADDING 2
 
-- 
1.7.0.4
