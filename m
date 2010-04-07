From: Manfred Rudigier <Manfred.Rudigier@omicron.at>
Subject: [RFC PATCH net-next 4/4] gianfar: Added raw hardware transmit time
 stamp generation
Date: Wed, 7 Apr 2010 11:46:49 +0200
Message-ID: <95DC1AA8EC908B48939B72CF375AA5E311A9F4E2@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linuxppc-dev@lists.ozlabs.org'" <linuxppc-dev@lists.ozlabs.org>
To: "'sandeep.kumar@freescale.com'" <sandeep.kumar@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:60232 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757831Ab0DGKY1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 06:24:27 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch configures the eTSEC to time stamps outgoing packets that have
the skb_shared_tx->hardware flag set. The eTSEC is configured to write the
time stamps back to memory after the frame is transmitted. During the
clean_tx_ring operation these time stamps will be extracted and copied
into the skb_shared_hwtstamps struct of the skb if required.

Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
---
 drivers/net/gianfar.c |  108 ++++++++++++++++++++++++++++++++++++++++---------
 drivers/net/gianfar.h |    2 +-
 2 files changed, 90 insertions(+), 20 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 9119879..becc3f3 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -803,7 +803,7 @@ static int gfar_hwtstamp_ioctl(struct net_device *netdev,
 		if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER))
 			return -ERANGE;
 		priv->hwts_tx_en = 1;
-		return -ERANGE;
+		break;
 	default:
 		return -ERANGE;
 	}
@@ -1982,23 +1982,29 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct netdev_queue *txq;
 	struct gfar __iomem *regs = NULL;
 	struct txfcb *fcb = NULL;
-	struct txbd8 *txbdp, *txbdp_start, *base;
+	struct txbd8 *txbdp, *txbdp_start, *base, *txbdp_tstamp = NULL;
 	u32 lstatus;
-	int i, rq = 0;
+	int i, rq = 0, do_tstamp = 0;
 	u32 bufaddr;
 	unsigned long flags;
-	unsigned int nr_frags, length;
-
+	unsigned int nr_frags, nr_txbds, length;
+	union skb_shared_tx *shtx;
 
 	rq = skb->queue_mapping;
 	tx_queue = priv->tx_queue[rq];
 	txq = netdev_get_tx_queue(dev, rq);
 	base = tx_queue->tx_bd_base;
 	regs = tx_queue->grp->regs;
+	shtx = skb_tx(skb);
+
+	/* check if time stamp should be generated */
+	if (unlikely(shtx->hardware && priv->hwts_tx_en))
+		do_tstamp = 1;
 
 	/* make space for additional header when fcb is needed */
 	if (((skb->ip_summed == CHECKSUM_PARTIAL) ||
-			(priv->vlgrp && vlan_tx_tag_present(skb))) &&
+			(priv->vlgrp && vlan_tx_tag_present(skb)) ||
+			unlikely(do_tstamp)) &&
 			(skb_headroom(skb) < GMAC_FCB_LEN)) {
 		struct sk_buff *skb_new;
 
@@ -2015,8 +2021,14 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* total number of fragments in the SKB */
 	nr_frags = skb_shinfo(skb)->nr_frags;
 
+	/* calculate the required number of TxBDs for this skb */
+	if (unlikely(do_tstamp))
+		nr_txbds = nr_frags + 2;
+	else
+		nr_txbds = nr_frags + 1;
+
 	/* check if there is space to queue this packet */
-	if ((nr_frags+1) > tx_queue->num_txbdfree) {
+	if (nr_txbds > tx_queue->num_txbdfree) {
 		/* no space, stop the queue */
 		netif_tx_stop_queue(txq);
 		dev->stats.tx_fifo_errors++;
@@ -2028,9 +2040,19 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	txq->tx_packets ++;
 
 	txbdp = txbdp_start = tx_queue->cur_tx;
+	lstatus = txbdp->lstatus;
+
+	/* Time stamp insertion requires one additional TxBD */
+	if (unlikely(do_tstamp))
+		txbdp_tstamp = txbdp = next_txbd(txbdp, base,
+				tx_queue->tx_ring_size);
 
 	if (nr_frags == 0) {
-		lstatus = txbdp->lstatus | BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
+		if (unlikely(do_tstamp))
+			txbdp_tstamp->lstatus |= BD_LFLAG(TXBD_LAST |
+					TXBD_INTERRUPT);
+		else
+			lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
 	} else {
 		/* Place the fragment addresses and lengths into the TxBDs */
 		for (i = 0; i < nr_frags; i++) {
@@ -2076,11 +2098,32 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		gfar_tx_vlan(skb, fcb);
 	}
 
-	/* setup the TxBD length and buffer pointer for the first BD */
+	/* Setup tx hardware time stamping if requested */
+	if (unlikely(do_tstamp)) {
+		shtx->in_progress = 1;
+		if (fcb == NULL)
+			fcb = gfar_add_fcb(skb);
+		fcb->ptp = 1;
+		lstatus |= BD_LFLAG(TXBD_TOE);
+	}
+
 	txbdp_start->bufPtr = dma_map_single(&priv->ofdev->dev, skb->data,
 			skb_headlen(skb), DMA_TO_DEVICE);
 
-	lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | skb_headlen(skb);
+	/*
+	 * If time stamping is requested one additional TxBD must be set up. The
+	 * first TxBD points to the FCB and must have a data length of
+	 * GMAC_FCB_LEN. The second TxBD points to the actual frame data with
+	 * the full frame length.
+	 */
+	if (unlikely(do_tstamp)) {
+		txbdp_tstamp->bufPtr = txbdp_start->bufPtr + GMAC_FCB_LEN;
+		txbdp_tstamp->lstatus |= BD_LFLAG(TXBD_READY) |
+				(skb_headlen(skb) - GMAC_FCB_LEN);
+		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | GMAC_FCB_LEN;
+	} else {
+		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | skb_headlen(skb);
+	}
 
 	/*
 	 * We can work in parallel with gfar_clean_tx_ring(), except
@@ -2120,7 +2163,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_queue->cur_tx = next_txbd(txbdp, base, tx_queue->tx_ring_size);
 
 	/* reduce TxBD free count */
-	tx_queue->num_txbdfree -= (nr_frags + 1);
+	tx_queue->num_txbdfree -= (nr_txbds);
 
 	dev->trans_start = jiffies;
 
@@ -2311,16 +2354,18 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	struct net_device *dev = tx_queue->dev;
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar_priv_rx_q *rx_queue = NULL;
-	struct txbd8 *bdp;
+	struct txbd8 *bdp, *next = NULL;
 	struct txbd8 *lbdp = NULL;
 	struct txbd8 *base = tx_queue->tx_bd_base;
 	struct sk_buff *skb;
 	int skb_dirtytx;
 	int tx_ring_size = tx_queue->tx_ring_size;
-	int frags = 0;
+	int frags = 0, nr_txbds = 0;
 	int i;
 	int howmany = 0;
 	u32 lstatus;
+	size_t buflen;
+	union skb_shared_tx *shtx;
 
 	rx_queue = priv->rx_queue[tx_queue->qindex];
 	bdp = tx_queue->dirty_tx;
@@ -2330,7 +2375,18 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 		unsigned long flags;
 
 		frags = skb_shinfo(skb)->nr_frags;
-		lbdp = skip_txbd(bdp, frags, base, tx_ring_size);
+
+		/*
+		 * When time stamping, one additional TxBD must be freed.
+		 * Also, we need to dma_unmap_single() the TxPAL.
+		 */
+		shtx = skb_tx(skb);
+		if (unlikely(shtx->in_progress))
+			nr_txbds = frags + 2;
+		else
+			nr_txbds = frags + 1;
+
+		lbdp = skip_txbd(bdp, nr_txbds - 1, base, tx_ring_size);
 
 		lstatus = lbdp->lstatus;
 
@@ -2339,10 +2395,24 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 				(lstatus & BD_LENGTH_MASK))
 			break;
 
-		dma_unmap_single(&priv->ofdev->dev,
-				bdp->bufPtr,
-				bdp->length,
-				DMA_TO_DEVICE);
+		if (unlikely(shtx->in_progress)) {
+			next = next_txbd(bdp, base, tx_ring_size);
+			buflen = next->length + GMAC_FCB_LEN;
+		} else
+			buflen = bdp->length;
+
+		dma_unmap_single(&priv->ofdev->dev, bdp->bufPtr,
+				buflen, DMA_TO_DEVICE);
+
+		if (unlikely(shtx->in_progress)) {
+			struct skb_shared_hwtstamps shhwtstamps;
+			u64 *ns = (u64*) (((u32)skb->data + 0x10) & ~0x7);
+			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+			shhwtstamps.hwtstamp = ns_to_ktime(*ns);
+			skb_tstamp_tx(skb, &shhwtstamps);
+			bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
+			bdp = next;
+		}
 
 		bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
 		bdp = next_txbd(bdp, base, tx_ring_size);
@@ -2374,7 +2444,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 
 		howmany++;
 		spin_lock_irqsave(&tx_queue->txlock, flags);
-		tx_queue->num_txbdfree += frags + 1;
+		tx_queue->num_txbdfree += nr_txbds;
 		spin_unlock_irqrestore(&tx_queue->txlock, flags);
 	}
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index cba2756..baed05c 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -540,7 +540,7 @@ struct txbd8
 
 struct txfcb {
 	u8	flags;
-	u8	reserved;
+	u8	ptp;    /* Flag to enable tx timestamping */
 	u8	l4os;	/* Level 4 Header Offset */
 	u8	l3os; 	/* Level 3 Header Offset */
 	u16	phcs;	/* Pseudo-header Checksum */
-- 
1.6.3.3
