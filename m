From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 35/40] net: fec: rename dirty_tx to pending_tx
Date: Thu, 28 Jan 2016 14:25:59 -0700
Message-ID: <1454016364-30985-36-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36643 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967702AbcA1V3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:29:07 -0500
Received: by mail-pf0-f177.google.com with SMTP id n128so29539499pfn.3
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:29:07 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dirty_tx always pointed to the last entry that was
trasmitted. pending_tx always points to the next entry
to be transmitted. This should be a little more efficient.

This will allow 1 more entry in the queue to be used.
That is, ring_size -1 entries instead of ring_size -2.

This also allows the removal of fec_enet_get_prevdesc.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec.h      | 14 +++++-------
 drivers/net/ethernet/freescale/fec_main.c | 38 ++++++++++---------------------
 2 files changed, 18 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index d2ca2e2..a16e47e 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -440,6 +440,10 @@ struct bufdesc_prop {
 	unsigned char dsize_log2;
 };
 
+/* bd.cur points to the currently available buffer.
+ * pending_tx tracks the current buffer that is being sent by the
+ * controller.  When bd.cur and pending_tx are equal, nothing is pending.
+ */
 struct fec_enet_priv_tx_q {
 	struct bufdesc_prop bd;
 	unsigned char *tx_bounce[TX_RING_SIZE];
@@ -448,7 +452,7 @@ struct fec_enet_priv_tx_q {
 	unsigned short tx_stop_threshold;
 	unsigned short tx_wake_threshold;
 
-	struct bufdesc	*dirty_tx;
+	struct bufdesc	*pending_tx;
 	char *tso_hdrs;
 	dma_addr_t tso_hdrs_dma;
 };
@@ -458,13 +462,7 @@ struct fec_enet_priv_rx_q {
 	struct  sk_buff *rx_skbuff[RX_RING_SIZE];
 };
 
-/* The FEC buffer descriptors track the ring buffers.  The rx_bd_base and
- * tx_bd_base always point to the base of the buffer descriptors.  The
- * cur_rx and cur_tx point to the currently available buffer.
- * The dirty_tx tracks the current buffer that is being sent by the
- * controller.  The cur_tx and dirty_tx are equal under both completely
- * empty and completely full conditions.  The empty/ready indicator in
- * the buffer descriptor determines the actual condition.
+/* The FEC buffer descriptors track the ring buffers.
  */
 struct fec_enet_private {
 	/* Hardware registers of the FEC device */
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 8dea600..9db645d 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -226,13 +226,6 @@ static struct bufdesc *fec_enet_get_nextdesc(struct bufdesc *bdp,
 			: (struct bufdesc *)(((unsigned)bdp) + bd->dsize);
 }
 
-static struct bufdesc *fec_enet_get_prevdesc(struct bufdesc *bdp,
-					     struct bufdesc_prop *bd)
-{
-	return (bdp <= bd->base) ? bd->last
-			: (struct bufdesc *)(((unsigned)bdp) - bd->dsize);
-}
-
 static int fec_enet_get_bd_index(struct bufdesc *bdp,
 				 struct bufdesc_prop *bd)
 {
@@ -243,7 +236,7 @@ static int fec_enet_get_free_txdesc_num(struct fec_enet_priv_tx_q *txq)
 {
 	int entries;
 
-	entries = (((const char *)txq->dirty_tx -
+	entries = (((const char *)txq->pending_tx -
 			(const char *)txq->bd.cur) >> txq->bd.dsize_log2) - 1;
 
 	return entries >= 0 ? entries : entries + txq->bd.ring_size;
@@ -288,7 +281,7 @@ static void fec_dump(struct net_device *ndev)
 			pr_info("%3u %c%c 0x%04x 0x%08lx %4u %p\n",
 				index,
 				bdp == txq->bd.cur ? 'S' : ' ',
-				bdp == txq->dirty_tx ? 'H' : ' ',
+				bdp == txq->pending_tx ? 'H' : ' ',
 				bdp->cbd_sc, bdp->cbd_bufaddr, bdp->cbd_datlen,
 				txq->tx_skbuff[index]);
 			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
@@ -802,6 +795,7 @@ static void fec_enet_bd_init(struct net_device *dev)
 		txq = fep->tx_queue[q];
 		bdp = txq->bd.base;
 		txq->bd.cur = bdp;
+		txq->pending_tx = bdp;
 
 		for (i = 0; i < txq->bd.ring_size; i++) {
 			/* Initialize the BD for every fragment in the page. */
@@ -820,8 +814,6 @@ static void fec_enet_bd_init(struct net_device *dev)
 			bdp->cbd_sc = (bdp == txq->bd.last) ? BD_SC_WRAP : 0;
 			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 		}
-		bdp = fec_enet_get_prevdesc(bdp, &txq->bd);
-		txq->dirty_tx = bdp;
 	}
 }
 
@@ -1134,11 +1126,8 @@ fec_timeout(struct net_device *ndev)
 		int index;
 		struct sk_buff *skb = NULL;
 
-		bdp = txq->dirty_tx;
-		while (1) {
-			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
-			if (bdp == txq->bd.cur)
-				break;
+		bdp = txq->pending_tx;
+		while (bdp != txq->bd.cur) {
 			index = fec_enet_get_bd_index(bdp, &txq->bd);
 			skb = txq->tx_skbuff[index];
 			if (skb) {
@@ -1147,6 +1136,7 @@ fec_timeout(struct net_device *ndev)
 					events |= txint_flags[i];
 				break;
 			}
+			bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
 		}
 	}
 	if (events) {
@@ -1208,12 +1198,8 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
 	int	index = 0;
 	int	entries_free;
 
-	/* get next bdp of dirty_tx */
 	nq = netdev_get_tx_queue(ndev, txq->bd.qid);
-	bdp = txq->dirty_tx;
-
-	/* get next bdp of dirty_tx */
-	bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
+	bdp = txq->pending_tx;
 
 	while (bdp != READ_ONCE(txq->bd.cur)) {
 		/* Order the load of bd.cur and cbd_sc */
@@ -1277,14 +1263,14 @@ static void fec_txq(struct net_device *ndev, struct fec_enet_private *fep,
 		/* Free the sk buffer associated with this last transmit */
 		dev_kfree_skb_any(skb);
 skb_done:
+		/* Update pointer to next buffer descriptor to be transmitted */
+		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
+
 		/* Make sure the update to bdp and tx_skbuff are performed
-		 * before dirty_tx
+		 * before pending_tx
 		 */
 		wmb();
-		txq->dirty_tx = bdp;
-
-		/* Update pointer to next buffer descriptor to be transmitted */
-		bdp = fec_enet_get_nextdesc(bdp, &txq->bd);
+		txq->pending_tx = bdp;
 
 		/* Since we have freed up a buffer, the ring is no longer full
 		 */
-- 
2.5.0
