From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net] gianfar: Fix dma check map error when DMA_API_DEBUG is enabled
Date: Tue, 9 Dec 2014 16:24:35 +0200
Message-ID: <1418135075-17349-1-git-send-email-claudiu.manoil@freescale.com>
References: <1417775874-17775-1-git-send-email-asolokha@kb.kras.ru>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Kevin Hao <haokexin@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0117.outbound.protection.outlook.com ([65.55.169.117]:22720
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751940AbaLIO3F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:29:05 -0500
In-Reply-To: <1417775874-17775-1-git-send-email-asolokha@kb.kras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Hao <haokexin@gmail.com>

We need to use dma_mapping_error() to check the dma address returned
by dma_map_single/page(). Otherwise we would get warning like this:
  WARNING: at lib/dma-debug.c:1140
  Modules linked in:
  CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.18.0-rc2-next-20141029 #196
  task: c0834300 ti: effe6000 task.ti: c0874000
  NIP: c02b2c98 LR: c02b2c98 CTR: c030abc4
  REGS: effe7d70 TRAP: 0700   Not tainted  (3.18.0-rc2-next-20141029)
  MSR: 00021000 <CE,ME>  CR: 22044022  XER: 20000000

  GPR00: c02b2c98 effe7e20 c0834300 00000098 00021000 00000000 c030b898 00000003
  GPR08: 00000001 00000000 00000001 749eec9d 22044022 1001abe0 00000020 ef278678
  GPR16: ef278670 ef278668 ef278660 070a8040 c087f99c c08cdc60 00029000 c0840d44
  GPR24: c08be6e8 c0840000 effe7e78 ef041340 00000600 ef114e10 00000000 c08be6e0
  NIP [c02b2c98] check_unmap+0x51c/0x9e4
  LR [c02b2c98] check_unmap+0x51c/0x9e4
  Call Trace:
  [effe7e20] [c02b2c98] check_unmap+0x51c/0x9e4 (unreliable)
  [effe7e70] [c02b31d8] debug_dma_unmap_page+0x78/0x8c
  [effe7ed0] [c03d1640] gfar_clean_rx_ring+0x208/0x488
  [effe7f40] [c03d1a9c] gfar_poll_rx_sq+0x3c/0xa8
  [effe7f60] [c04f8714] net_rx_action+0xc0/0x178
  [effe7f90] [c00435a0] __do_softirq+0x100/0x1fc
  [effe7fe0] [c0043958] irq_exit+0xa4/0xc8
  [effe7ff0] [c000d14c] call_do_irq+0x24/0x3c
  [c0875e90] [c00048a0] do_IRQ+0x8c/0xf8
  [c0875eb0] [c000ed10] ret_from_except+0x0/0x18

For TX, we need to unmap the pages which has already been mapped and
free the skb before return. For RX, just let the rxbdp as unempty.
We can retry to initialize it to empty in next round.

Signed-off-by: Kevin Hao <haokexin@gmail.com>
Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 58 ++++++++++++++++++++++++++------
 1 file changed, 47 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4fdf0aa..0253402 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -117,8 +117,8 @@ static void gfar_reset_task(struct work_struct *work);
 static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
 struct sk_buff *gfar_new_skb(struct net_device *dev);
-static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
-			   struct sk_buff *skb);
+static int gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
+			  struct sk_buff *skb);
 static int gfar_set_mac_address(struct net_device *dev);
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t gfar_error(int irq, void *dev_id);
@@ -219,9 +219,13 @@ static int gfar_init_bds(struct net_device *ndev)
 					netdev_err(ndev, "Can't allocate RX buffers\n");
 					return -ENOMEM;
 				}
-				rx_queue->rx_skbuff[j] = skb;
 
-				gfar_new_rxbdp(rx_queue, rxbdp, skb);
+				if (gfar_new_rxbdp(rx_queue, rxbdp, skb)) {
+					dev_kfree_skb_any(skb);
+					skb = NULL;
+				}
+
+				rx_queue->rx_skbuff[j] = skb;
 			}
 
 			rxbdp++;
@@ -2290,6 +2294,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 						   0,
 						   frag_len,
 						   DMA_TO_DEVICE);
+			if (unlikely(dma_mapping_error(priv->dev, bufaddr)))
+				goto dma_map_err;
 
 			/* set the TxBD length and buffer pointer */
 			txbdp->bufPtr = bufaddr;
@@ -2339,8 +2345,12 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		fcb->ptp = 1;
 	}
 
-	txbdp_start->bufPtr = dma_map_single(priv->dev, skb->data,
-					     skb_headlen(skb), DMA_TO_DEVICE);
+	bufaddr = dma_map_single(priv->dev, skb->data, skb_headlen(skb),
+				 DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(priv->dev, bufaddr)))
+		goto dma_map_err;
+
+	txbdp_start->bufPtr = bufaddr;
 
 	/* If time stamping is requested one additional TxBD must be set up. The
 	 * first TxBD points to the FCB and must have a data length of
@@ -2406,6 +2416,25 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&tx_queue->txlock, flags);
 
 	return NETDEV_TX_OK;
+
+dma_map_err:
+	txbdp = next_txbd(txbdp_start, base, tx_queue->tx_ring_size);
+	if (do_tstamp)
+		txbdp = next_txbd(txbdp, base, tx_queue->tx_ring_size);
+	for (i = 0; i < nr_frags; i++) {
+		lstatus = txbdp->lstatus;
+		if (!(lstatus & BD_LFLAG(TXBD_READY)))
+			break;
+
+		txbdp->lstatus = lstatus & ~BD_LFLAG(TXBD_READY);
+		bufaddr = txbdp->bufPtr;
+		dma_unmap_page(priv->dev, bufaddr, txbdp->length,
+			       DMA_TO_DEVICE);
+		txbdp = next_txbd(txbdp, base, tx_queue->tx_ring_size);
+	}
+	gfar_wmb();
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
 }
 
 /* Stops the kernel queue, and halts the controller */
@@ -2606,8 +2635,8 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	netdev_tx_completed_queue(txq, howmany, bytes_sent);
 }
 
-static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
-			   struct sk_buff *skb)
+static int gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
+			  struct sk_buff *skb)
 {
 	struct net_device *dev = rx_queue->dev;
 	struct gfar_private *priv = netdev_priv(dev);
@@ -2615,7 +2644,11 @@ static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 
 	buf = dma_map_single(priv->dev, skb->data,
 			     priv->rx_buffer_size, DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(priv->dev, buf)))
+		return -1;
+
 	gfar_init_rxbdp(rx_queue, bdp, buf);
+	return 0;
 }
 
 static struct sk_buff *gfar_alloc_skb(struct net_device *dev)
@@ -2851,10 +2884,13 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 
 		}
 
-		rx_queue->rx_skbuff[rx_queue->skb_currx] = newskb;
-
 		/* Setup the new bdp */
-		gfar_new_rxbdp(rx_queue, bdp, newskb);
+		if (unlikely(gfar_new_rxbdp(rx_queue, bdp, newskb))) {
+			dev_kfree_skb_any(newskb);
+			newskb = NULL;
+		}
+
+		rx_queue->rx_skbuff[rx_queue->skb_currx] = newskb;
 
 		/* Update to the next pointer */
 		bdp = next_bd(bdp, base, rx_queue->rx_ring_size);
-- 
1.7.11.7
