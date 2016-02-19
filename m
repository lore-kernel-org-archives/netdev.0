From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 1/3] gianfar: Map head TxBD first to skip a wmb()
Date: Fri, 19 Feb 2016 12:47:32 +0200
Message-ID: <1455878854-28290-2-git-send-email-claudiu.manoil@freescale.com>
References: <1455878854-28290-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0111.outbound.protection.outlook.com ([157.56.110.111]:8736
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S2992928AbcBSLJm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 06:09:42 -0500
In-Reply-To: <1455878854-28290-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the mapping of the head BD before the mapping of fragments.
As a result, the TOE (h/w offload) decision logic block can be
also moved up (as the TOE flag belongs to the head BD), resulting
in more localized code (TOE logic vs BD mapping code blocks).
The main point of this change is to update the buffer pointer of
the first BD way before the status field is updated, so that a
wmb() between these two operations is no longer needed. Note that,
for this controller, the R (status) bit for the head BD of a S/G
frame needs to be written last for a reliable transmission.
For the fragmented skb case, a local variable is used to temporarily
store the status info of the first BD, replacing a BD status read.
A natural merge of 2 if(do_tstamp) blocks was also possible.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 98 ++++++++++++++++----------------
 1 file changed, 48 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2aa7b40..43fbded 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2389,6 +2389,47 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	txbdp = txbdp_start = tx_queue->cur_tx;
 	lstatus = be32_to_cpu(txbdp->lstatus);
 
+	/* Add TxPAL between FCB and frame if required */
+	if (unlikely(do_tstamp)) {
+		skb_push(skb, GMAC_TXPAL_LEN);
+		memset(skb->data, 0, GMAC_TXPAL_LEN);
+	}
+
+	/* Add TxFCB if required */
+	if (fcb_len) {
+		fcb = gfar_add_fcb(skb);
+		lstatus |= BD_LFLAG(TXBD_TOE);
+	}
+
+	/* Set up checksumming */
+	if (do_csum) {
+		gfar_tx_checksum(skb, fcb, fcb_len);
+
+		if (unlikely(gfar_csum_errata_12(priv, (unsigned long)fcb)) ||
+		    unlikely(gfar_csum_errata_76(priv, skb->len))) {
+			__skb_pull(skb, GMAC_FCB_LEN);
+			skb_checksum_help(skb);
+			if (do_vlan || do_tstamp) {
+				/* put back a new fcb for vlan/tstamp TOE */
+				fcb = gfar_add_fcb(skb);
+			} else {
+				/* Tx TOE not used */
+				lstatus &= ~(BD_LFLAG(TXBD_TOE));
+				fcb = NULL;
+			}
+		}
+	}
+
+	if (do_vlan)
+		gfar_tx_vlan(skb, fcb);
+
+	bufaddr = dma_map_single(priv->dev, skb->data, skb_headlen(skb),
+				 DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(priv->dev, bufaddr)))
+		goto dma_map_err;
+
+	txbdp_start->bufPtr = cpu_to_be32(bufaddr);
+
 	/* Time stamp insertion requires one additional TxBD */
 	if (unlikely(do_tstamp))
 		txbdp_tstamp = txbdp = next_txbd(txbdp, base,
@@ -2404,6 +2445,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
 		}
 	} else {
+		u32 lstatus_start = lstatus;
+
 		/* Place the fragment addresses and lengths into the TxBDs */
 		for (i = 0; i < nr_frags; i++) {
 			unsigned int frag_len;
@@ -2432,56 +2475,9 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			txbdp->lstatus = cpu_to_be32(lstatus);
 		}
 
-		lstatus = be32_to_cpu(txbdp_start->lstatus);
+		lstatus = lstatus_start;
 	}
 
-	/* Add TxPAL between FCB and frame if required */
-	if (unlikely(do_tstamp)) {
-		skb_push(skb, GMAC_TXPAL_LEN);
-		memset(skb->data, 0, GMAC_TXPAL_LEN);
-	}
-
-	/* Add TxFCB if required */
-	if (fcb_len) {
-		fcb = gfar_add_fcb(skb);
-		lstatus |= BD_LFLAG(TXBD_TOE);
-	}
-
-	/* Set up checksumming */
-	if (do_csum) {
-		gfar_tx_checksum(skb, fcb, fcb_len);
-
-		if (unlikely(gfar_csum_errata_12(priv, (unsigned long)fcb)) ||
-		    unlikely(gfar_csum_errata_76(priv, skb->len))) {
-			__skb_pull(skb, GMAC_FCB_LEN);
-			skb_checksum_help(skb);
-			if (do_vlan || do_tstamp) {
-				/* put back a new fcb for vlan/tstamp TOE */
-				fcb = gfar_add_fcb(skb);
-			} else {
-				/* Tx TOE not used */
-				lstatus &= ~(BD_LFLAG(TXBD_TOE));
-				fcb = NULL;
-			}
-		}
-	}
-
-	if (do_vlan)
-		gfar_tx_vlan(skb, fcb);
-
-	/* Setup tx hardware time stamping if requested */
-	if (unlikely(do_tstamp)) {
-		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
-		fcb->ptp = 1;
-	}
-
-	bufaddr = dma_map_single(priv->dev, skb->data, skb_headlen(skb),
-				 DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(priv->dev, bufaddr)))
-		goto dma_map_err;
-
-	txbdp_start->bufPtr = cpu_to_be32(bufaddr);
-
 	/* If time stamping is requested one additional TxBD must be set up. The
 	 * first TxBD points to the FCB and must have a data length of
 	 * GMAC_FCB_LEN. The second TxBD points to the actual frame data with
@@ -2498,14 +2494,16 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		txbdp_tstamp->bufPtr = cpu_to_be32(bufaddr);
 		txbdp_tstamp->lstatus = cpu_to_be32(lstatus_ts);
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | GMAC_FCB_LEN;
+
+		/* Setup tx hardware time stamping */
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		fcb->ptp = 1;
 	} else {
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | skb_headlen(skb);
 	}
 
 	netdev_tx_sent_queue(txq, bytes_sent);
 
-	gfar_wmb();
-
 	txbdp_start->lstatus = cpu_to_be32(lstatus);
 
 	gfar_wmb(); /* force lstatus write before tx_skbuff */
-- 
1.7.11.7
