From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Quick patch for ucc_geth, add copybreak and move TX processing to
	soft IRQ
Date: Wed, 02 Apr 2008 13:48:35 +0200
Message-ID: <1207136915.9675.55.camel@gentoo-jocke.transmode.se>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: 'linuxppc-dev Development' <linuxppc-dev@ozlabs.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:11705 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752880AbYDBLsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 07:48:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a quick hack to make ucc_geth handle a
ping -f -l 10 gracefully. Without it, the CPU will lockup during the ping flood.

I don't have time ATM to clean it up, but if anyone wants to he is welcome :)
Commenst on the geleral approach is wanted though, why do I need to move TX
processing to soft IRQ to make the system response under heavy load?

Kernel 2.6.23

 Jocke
---
 drivers/net/ucc_geth.c |   85 +++++++++++++++++++++++++++++++++--------------
 1 files changed, 59 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 038ec75..b74b298 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -73,6 +73,11 @@ static struct {
 module_param_named(debug, debug.msg_enable, int, 0);
 MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 0xffff=all)");
 
+#define COPYBREAK_DEFAULT 256
+static unsigned int copybreak __read_mostly = COPYBREAK_DEFAULT;
+MODULE_PARM_DESC(copybreak,
+	"Maximum size of packet that is copied to a new buffer on receive");
+
 static struct ucc_geth_info ugeth_primary_info = {
 	.uf_info = {
 		    .bd_mem_part = MEM_PART_MURAM,
@@ -3380,14 +3385,12 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 #ifdef CONFIG_UGETH_TX_ON_DEMAND
 	struct ucc_fast_private *uccf;
 #endif
-	u8 *bd;			/* BD pointer */
+	u8 *bd, *bd_ptr;		/* BD pointer */
 	u32 bd_status;
 	u8 txQ = 0;
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
-	spin_lock_irq(&ugeth->lock);
-
 	ugeth->stats.tx_bytes += skb->len;
 
 	/* Start from the next BD that should be filled */
@@ -3401,16 +3404,18 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	    (ugeth->skb_curtx[txQ] +
 	     1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
 
-	/* set up the buffer descriptor */
-	out_be32(&((struct qe_bd *)bd)->buf,
-		      dma_map_single(NULL, skb->data, skb->len, DMA_TO_DEVICE));
+	bd_ptr = dma_map_single(NULL, skb->data, skb->len, DMA_TO_DEVICE);
 
 	/* printk(KERN_DEBUG"skb->data is 0x%x\n",skb->data); */
 
 	bd_status = (bd_status & T_W) | T_R | T_I | T_L | skb->len;
 
+	spin_lock_irq(&ugeth->lock);
+	/* set up the buffer descriptor */
+	out_be32(&((struct qe_bd *)bd)->buf, bd_ptr);
 	/* set bd status and length */
 	out_be32((u32 *)bd, bd_status);
+	spin_unlock_irq(&ugeth->lock);
 
 	dev->trans_start = jiffies;
 
@@ -3427,8 +3432,6 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_stop_queue(dev);
 	}
 
-	ugeth->txBd[txQ] = bd;
-
 	if (ugeth->p_scheduler) {
 		ugeth->cpucount[txQ]++;
 		/* Indicate to QE that there are more Tx bds ready for
@@ -3442,7 +3445,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	uccf = ugeth->uccf;
 	out_be16(uccf->p_utodr, UCC_FAST_TOD);
 #endif
-	spin_unlock_irq(&ugeth->lock);
+	ugeth->txBd[txQ] = bd;
 
 	return 0;
 }
@@ -3454,6 +3457,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 	u16 length, howmany = 0;
 	u32 bd_status;
 	u8 *bdBuffer;
+	struct sk_buff *new_skb;
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
@@ -3467,6 +3471,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		bdBuffer = (u8 *) in_be32(&((struct qe_bd *)bd)->buf);
 		length = (u16) ((bd_status & BD_LENGTH_MASK) - 4);
 		skb = ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]];
+		new_skb = NULL;
 
 		/* determine whether buffer is first, last, first and last
 		(single buffer frame) or middle (not first and not last) */
@@ -3484,6 +3489,21 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		} else {
 			ugeth->stats.rx_packets++;
 			howmany++;
+			if (length < copybreak) {
+				new_skb =
+					netdev_alloc_skb(ugeth->dev, length + NET_IP_ALIGN);
+				if (new_skb) {
+					skb_reserve(new_skb, NET_IP_ALIGN);
+					skb_copy_to_linear_data_offset(new_skb,
+								       -NET_IP_ALIGN,
+								       (skb->data -
+									NET_IP_ALIGN),
+								       (length +
+									NET_IP_ALIGN));
+					skb = new_skb;
+					out_be32((u32 *)bd, (R_E | R_I | (in_be32((u32 *)bd) & R_W)));
+				}
+			}
 
 			/* Prep the skb for the packet */
 			skb_put(skb, length);
@@ -3502,16 +3522,17 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 
 		ugeth->dev->last_rx = jiffies;
 
-		skb = get_new_skb(ugeth, bd);
-		if (!skb) {
-			if (netif_msg_rx_err(ugeth))
-				ugeth_warn("%s: No Rx Data Buffer", __FUNCTION__);
-			ugeth->stats.rx_dropped++;
-			break;
-		}
-
-		ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]] = skb;
+		if (!new_skb) {
+			skb = get_new_skb(ugeth, bd);
+			if (!skb) {
+				if (netif_msg_rx_err(ugeth))
+					ugeth_warn("%s: No Rx Data Buffer", __FUNCTION__);
+				ugeth->stats.rx_dropped++;
+				break;
+			}
 
+			ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]] = skb;
+		}
 		/* update to point at the next skb */
 		ugeth->skb_currx[rxQ] =
 		    (ugeth->skb_currx[rxQ] +
@@ -3535,6 +3556,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 	u8 *bd;			/* BD pointer */
 	u32 bd_status;
+	int howmany = 0;
 
 	bd = ugeth->confBd[txQ];
 	bd_status = in_be32((u32 *)bd);
@@ -3547,12 +3569,17 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 
 		if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
 			break;
-
+		howmany++;
 		ugeth->stats.tx_packets++;
 
 		/* Free the sk buffer associated with this TxBD */
+#ifdef CONFIG_UGETH_NAPI
+		dev_kfree_skb(ugeth->
+				  tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]]);
+#else
 		dev_kfree_skb_irq(ugeth->
 				  tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]]);
+#endif
 		ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]] = NULL;
 		ugeth->skb_dirtytx[txQ] =
 		    (ugeth->skb_dirtytx[txQ] +
@@ -3570,7 +3597,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 		bd_status = in_be32((u32 *)bd);
 	}
 	ugeth->confBd[txQ] = bd;
-	return 0;
+	return howmany;
 }
 
 #ifdef CONFIG_UGETH_NAPI
@@ -3596,6 +3623,12 @@ static int ucc_geth_poll(struct net_device *dev, int *budget)
 		howmany += ucc_geth_rx(ugeth, i, rx_work_limit);
 	}
 
+	spin_lock(&ugeth->lock);
+	for (i = 0; i < ug_info->numQueuesTx; i++) {
+		ucc_geth_tx(dev, i);
+	}
+	spin_unlock(&ugeth->lock);
+
 	dev->quota -= howmany;
 	rx_work_limit -= howmany;
 	*budget -= howmany;
@@ -3604,7 +3637,7 @@ static int ucc_geth_poll(struct net_device *dev, int *budget)
 		netif_rx_complete(dev);
 		uccf = ugeth->uccf;
 		uccm = in_be32(uccf->p_uccm);
-		uccm |= UCCE_RX_EVENTS;
+		uccm |= UCCE_RX_EVENTS | UCCE_TX_EVENTS;
 		out_be32(uccf->p_uccm, uccm);
 	}
 
@@ -3641,10 +3674,10 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	out_be32(uccf->p_ucce, ucce);
 
 	/* check for receive events that require processing */
-	if (ucce & UCCE_RX_EVENTS) {
+	if (ucce & (UCCE_RX_EVENTS | UCCE_TX_EVENTS)) {
 #ifdef CONFIG_UGETH_NAPI
 		if (netif_rx_schedule_prep(dev)) {
-		uccm &= ~UCCE_RX_EVENTS;
+			uccm &= ~(UCCE_RX_EVENTS | UCCE_TX_EVENTS);
 			out_be32(uccf->p_uccm, uccm);
 			__netif_rx_schedule(dev);
 		}
@@ -3658,7 +3691,7 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 		}
 #endif /* CONFIG_UGETH_NAPI */
 	}
-
+#ifndef CONFIG_UGETH_NAPI
 	/* Tx event processing */
 	if (ucce & UCCE_TX_EVENTS) {
 		spin_lock(&ugeth->lock);
@@ -3671,7 +3704,7 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 		}
 		spin_unlock(&ugeth->lock);
 	}
-
+#endif
 	/* Errors and other events */
 	if (ucce & UCCE_OTHER) {
 		if (ucce & UCCE_BSY) {
@@ -3959,7 +3992,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	dev->watchdog_timeo = TX_TIMEOUT;
 #ifdef CONFIG_UGETH_NAPI
 	dev->poll = ucc_geth_poll;
-	dev->weight = UCC_GETH_DEV_WEIGHT;
+	dev->weight = UCC_GETH_DEV_WEIGHT*2;
 #endif				/* CONFIG_UGETH_NAPI */
 	dev->stop = ucc_geth_close;
 	dev->get_stats = ucc_geth_get_stats;
-- 
1.5.4.3


