From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 2/2][net-next] gianfar: Cleanup TxFCB insertion on xmit
Date: Mon, 5 Aug 2013 17:20:10 +0300
Message-ID: <1375712410-11760-3-git-send-email-claudiu.manoil@freescale.com>
References: <1375712410-11760-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:57828
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753672Ab3HEOUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 10:20:44 -0400
In-Reply-To: <1375712410-11760-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup gfar_start_xmit()'s fast path by factoring out "redundant"
FCB insertion code (repeated gfar_add_fcb() calls and related)
and by reducing the number of if() clauses (i.e. if(fcb) checks).
Improve maintainability (e.g. there's less code and easier to read)
also by introducing do_csum and do_vlan to mark the other 2 Tx TOE
functionalities, following the same model as do_tstamp.
fcb_len may also be 0 now, to mark that Tx FCB insertion conditions
(do_csum, do_vlan, do_tstamp) have not been met.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 62 +++++++++++++++++---------------
 1 file changed, 33 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 3a543f7..d4f22c6 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2084,10 +2084,11 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct txfcb *fcb = NULL;
 	struct txbd8 *txbdp, *txbdp_start, *base, *txbdp_tstamp = NULL;
 	u32 lstatus;
-	int i, rq = 0, do_tstamp = 0;
+	int i, rq = 0;
+	int do_tstamp, do_csum, do_vlan;
 	u32 bufaddr;
 	unsigned long flags;
-	unsigned int nr_frags, nr_txbds, length, fcb_length = GMAC_FCB_LEN;
+	unsigned int nr_frags, nr_txbds, length, fcb_len = 0;
 
 	rq = skb->queue_mapping;
 	tx_queue = priv->tx_queue[rq];
@@ -2095,21 +2096,23 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	base = tx_queue->tx_bd_base;
 	regs = tx_queue->grp->regs;
 
+	do_csum = (CHECKSUM_PARTIAL == skb->ip_summed);
+	do_vlan = vlan_tx_tag_present(skb);
+	do_tstamp = (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+		    priv->hwts_tx_en;
+
+	if (do_csum || do_vlan)
+		fcb_len = GMAC_FCB_LEN;
+
 	/* check if time stamp should be generated */
-	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
-		     priv->hwts_tx_en)) {
-		do_tstamp = 1;
-		fcb_length = GMAC_FCB_LEN + GMAC_TXPAL_LEN;
-	}
+	if (unlikely(do_tstamp))
+		fcb_len = GMAC_FCB_LEN + GMAC_TXPAL_LEN;
 
 	/* make space for additional header when fcb is needed */
-	if (((skb->ip_summed == CHECKSUM_PARTIAL) ||
-	     vlan_tx_tag_present(skb) ||
-	     unlikely(do_tstamp)) &&
-	    (skb_headroom(skb) < fcb_length)) {
+	if (fcb_len && unlikely(skb_headroom(skb) < fcb_len)) {
 		struct sk_buff *skb_new;
 
-		skb_new = skb_realloc_headroom(skb, fcb_length);
+		skb_new = skb_realloc_headroom(skb, fcb_len);
 		if (!skb_new) {
 			dev->stats.tx_errors++;
 			kfree_skb(skb);
@@ -2192,37 +2195,38 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		memset(skb->data, 0, GMAC_TXPAL_LEN);
 	}
 
-	/* Set up checksumming */
-	if (CHECKSUM_PARTIAL == skb->ip_summed) {
+	/* Add TxFCB if required */
+	if (fcb_len) {
 		fcb = gfar_add_fcb(skb);
 		lstatus |= BD_LFLAG(TXBD_TOE);
-		gfar_tx_checksum(skb, fcb, fcb_length);
+	}
+
+	/* Set up checksumming */
+	if (do_csum) {
+		gfar_tx_checksum(skb, fcb, fcb_len);
 
 		if (unlikely(gfar_csum_errata_12(priv, (unsigned long)fcb)) ||
 		    unlikely(gfar_csum_errata_76(priv, skb->len))) {
 			__skb_pull(skb, GMAC_FCB_LEN);
 			skb_checksum_help(skb);
-			lstatus &= ~(BD_LFLAG(TXBD_TOE));
-			fcb = NULL;
+			if (do_vlan || do_tstamp) {
+				/* put back a new fcb for vlan/tstamp TOE */
+				fcb = gfar_add_fcb(skb);
+			} else {
+				/* Tx TOE not used */
+				lstatus &= ~(BD_LFLAG(TXBD_TOE));
+				fcb = NULL;
+			}
 		}
 	}
 
-	if (vlan_tx_tag_present(skb)) {
-		if (unlikely(NULL == fcb)) {
-			fcb = gfar_add_fcb(skb);
-			lstatus |= BD_LFLAG(TXBD_TOE);
-		}
-
+	if (do_vlan)
 		gfar_tx_vlan(skb, fcb);
-	}
 
 	/* Setup tx hardware time stamping if requested */
 	if (unlikely(do_tstamp)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
-		if (fcb == NULL)
-			fcb = gfar_add_fcb(skb);
 		fcb->ptp = 1;
-		lstatus |= BD_LFLAG(TXBD_TOE);
 	}
 
 	txbdp_start->bufPtr = dma_map_single(priv->dev, skb->data,
@@ -2234,9 +2238,9 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * the full frame length.
 	 */
 	if (unlikely(do_tstamp)) {
-		txbdp_tstamp->bufPtr = txbdp_start->bufPtr + fcb_length;
+		txbdp_tstamp->bufPtr = txbdp_start->bufPtr + fcb_len;
 		txbdp_tstamp->lstatus |= BD_LFLAG(TXBD_READY) |
-					 (skb_headlen(skb) - fcb_length);
+					 (skb_headlen(skb) - fcb_len);
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | GMAC_FCB_LEN;
 	} else {
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | skb_headlen(skb);
-- 
1.7.11.7
