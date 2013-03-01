From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH v2 1/1 net-next] fec: net: put tx to napi poll function to fix dead lock
Date: Fri, 1 Mar 2013 11:37:14 +0800
Message-ID: <1362109034-25805-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <s.hauer@pengutronix.de>, Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:30818
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751660Ab3CAElK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 23:41:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

up stack ndo_start_xmit already hold lock.
fec_enet_start_xmit needn't spin lock.
stat_xmit just update fep->cur_tx
fec_enet_tx just update fep->dirty_tx

Reserve a empty bdb to check full or empty
cur_tx == dirty_tx    means full
cur_tx == dirty_tx +1 means empty

So needn't is_full variable.

Fix spin lock deadlock
=================================
[ INFO: inconsistent lock state ]
3.8.0-rc5+ #107 Not tainted
---------------------------------
inconsistent {HARDIRQ-ON-W} -> {IN-HARDIRQ-W} usage.
ptp4l/615 [HC1[1]:SC0[0]:HE0:SE1] takes:
 (&(&list->lock)->rlock#3){?.-...}, at: [<8042c3c4>] skb_queue_tail+0x20/0x50
 {HARDIRQ-ON-W} state was registered at:
 [<80067250>] mark_lock+0x154/0x4e8
 [<800676f4>] mark_irqflags+0x110/0x1a4
 [<80069208>] __lock_acquire+0x494/0x9c0
 [<80069ce8>] lock_acquire+0x90/0xa4
 [<80527ad0>] _raw_spin_lock_bh+0x44/0x54
 [<804877e0>] first_packet_length+0x38/0x1f0
 [<804879e4>] udp_poll+0x4c/0x5c
 [<804231f8>] sock_poll+0x24/0x28
 [<800d27f0>] do_poll.isra.10+0x120/0x254
 [<800d36e4>] do_sys_poll+0x15c/0x1e8
 [<800d3828>] sys_poll+0x60/0xc8
 [<8000e780>] ret_fast_syscall+0x0/0x3c

 *** DEADLOCK ***

 1 lock held by ptp4l/615:
  #0:  (&(&fep->hw_lock)->rlock){-.-...}, at: [<80355f9c>] fec_enet_tx+0x24/0x268
  stack backtrace:
  Backtrace:
  [<800121e0>] (dump_backtrace+0x0/0x10c) from [<80516210>] (dump_stack+0x18/0x1c)
  r6:8063b1fc r5:bf38b2f8 r4:bf38b000 r3:bf38b000
  [<805161f8>] (dump_stack+0x0/0x1c) from [<805189d0>] (print_usage_bug.part.34+0x164/0x1a4)
  [<8051886c>] (print_usage_bug.part.34+0x0/0x1a4) from [<80518a88>] (print_usage_bug+0x78/0x88)
  r8:80065664 r7:bf38b2f8 r6:00000002 r5:00000000 r4:bf38b000
  [<80518a10>] (print_usage_bug+0x0/0x88) from [<80518b58>] (mark_lock_irq+0xc0/0x270)
  r7:bf38b000 r6:00000002 r5:bf38b2f8 r4:00000000
  [<80518a98>] (mark_lock_irq+0x0/0x270) from [<80067270>] (mark_lock+0x174/0x4e8)
  [<800670fc>] (mark_lock+0x0/0x4e8) from [<80067744>] (mark_irqflags+0x160/0x1a4)
  [<800675e4>] (mark_irqflags+0x0/0x1a4) from [<80069208>] (__lock_acquire+0x494/0x9c0)
  r5:00000002 r4:bf38b2f8
  [<80068d74>] (__lock_acquire+0x0/0x9c0) from [<80069ce8>] (lock_acquire+0x90/0xa4)
  [<80069c58>] (lock_acquire+0x0/0xa4) from [<805278d8>] (_raw_spin_lock_irqsave+0x4c/0x60)
  [<8052788c>] (_raw_spin_lock_irqsave+0x0/0x60) from [<8042c3c4>] (skb_queue_tail+0x20/0x50)
  r6:bfbb2180 r5:bf1d0190 r4:bf1d0184
  [<8042c3a4>] (skb_queue_tail+0x0/0x50) from [<8042c4cc>] (sock_queue_err_skb+0xd8/0x188)
  r6:00000056 r5:bfbb2180 r4:bf1d0000 r3:00000000
  [<8042c3f4>] (sock_queue_err_skb+0x0/0x188) from [<8042d15c>] (skb_tstamp_tx+0x70/0xa0)
  r6:bf0dddb0 r5:bf1d0000 r4:bfbb2180 r3:00000004
  [<8042d0ec>] (skb_tstamp_tx+0x0/0xa0) from [<803561d0>] (fec_enet_tx+0x258/0x268)
  r6:c089d260 r5:00001c00 r4:bfbd0000
  [<80355f78>] (fec_enet_tx+0x0/0x268) from [<803562cc>] (fec_enet_interrupt+0xec/0xf8)
  [<803561e0>] (fec_enet_interrupt+0x0/0xf8) from [<8007d5b0>] (handle_irq_event_percpu+0x54/0x1a0)
  [<8007d55c>] (handle_irq_event_percpu+0x0/0x1a0) from [<8007d740>] (handle_irq_event+0x44/0x64)
  [<8007d6fc>] (handle_irq_event+0x0/0x64) from [<80080690>] (handle_fasteoi_irq+0xc4/0x15c)
  r6:bf0dc000 r5:bf811290 r4:bf811240 r3:00000000
  [<800805cc>] (handle_fasteoi_irq+0x0/0x15c) from [<8007ceec>] (generic_handle_irq+0x28/0x38)
  r5:807130c8 r4:00000096
  [<8007cec4>] (generic_handle_irq+0x0/0x38) from [<8000f16c>] (handle_IRQ+0x54/0xb4)
  r4:8071d280 r3:00000180
  [<8000f118>] (handle_IRQ+0x0/0xb4) from [<80008544>] (gic_handle_irq+0x30/0x64)
  r8:8000e924 r7:f4000100 r6:bf0ddef8 r5:8071c974 r4:f400010c
  r3:00000000
  [<80008514>] (gic_handle_irq+0x0/0x64) from [<8000e2e4>] (__irq_svc+0x44/0x5c)
  Exception stack(0xbf0ddef8 to 0xbf0ddf40)

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
Change from v1 to v2
 * ignore TX package count in poll function

 drivers/net/ethernet/freescale/fec.c |   92 +++++++++++++++++----------------
 drivers/net/ethernet/freescale/fec.h |    3 -
 2 files changed, 47 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 0fe68c4..267685b 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -246,14 +246,13 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	struct bufdesc *bdp;
 	void *bufaddr;
 	unsigned short	status;
-	unsigned long flags;
+	unsigned int index;
 
 	if (!fep->link) {
 		/* Link is down or autonegotiation is in progress. */
 		return NETDEV_TX_BUSY;
 	}
 
-	spin_lock_irqsave(&fep->hw_lock, flags);
 	/* Fill in a Tx ring entry */
 	bdp = fep->cur_tx;
 
@@ -264,7 +263,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		 * This should not happen, since ndev->tbusy should be set.
 		 */
 		printk("%s: tx queue full!.\n", ndev->name);
-		spin_unlock_irqrestore(&fep->hw_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -280,13 +278,13 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	 * 4-byte boundaries. Use bounce buffers to copy data
 	 * and get it aligned. Ugh.
 	 */
+	if (fep->bufdesc_ex)
+		index = (struct bufdesc_ex *)bdp -
+			(struct bufdesc_ex *)fep->tx_bd_base;
+	else
+		index = bdp - fep->tx_bd_base;
+
 	if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
-		unsigned int index;
-		if (fep->bufdesc_ex)
-			index = (struct bufdesc_ex *)bdp -
-				(struct bufdesc_ex *)fep->tx_bd_base;
-		else
-			index = bdp - fep->tx_bd_base;
 		memcpy(fep->tx_bounce[index], skb->data, skb->len);
 		bufaddr = fep->tx_bounce[index];
 	}
@@ -300,10 +298,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		swap_buffer(bufaddr, skb->len);
 
 	/* Save skb pointer */
-	fep->tx_skbuff[fep->skb_cur] = skb;
-
-	ndev->stats.tx_bytes += skb->len;
-	fep->skb_cur = (fep->skb_cur+1) & TX_RING_MOD_MASK;
+	fep->tx_skbuff[index] = skb;
 
 	/* Push the data cache so the CPM does not get stale memory
 	 * data.
@@ -331,26 +326,22 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 			ebdp->cbd_esc = BD_ENET_TX_INT;
 		}
 	}
-	/* Trigger transmission start */
-	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
-
 	/* If this was the last BD in the ring, start at the beginning again. */
 	if (status & BD_ENET_TX_WRAP)
 		bdp = fep->tx_bd_base;
 	else
 		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
 
-	if (bdp == fep->dirty_tx) {
-		fep->tx_full = 1;
+	fep->cur_tx = bdp;
+
+	if (fep->cur_tx == fep->dirty_tx)
 		netif_stop_queue(ndev);
-	}
 
-	fep->cur_tx = bdp;
+	/* Trigger transmission start */
+	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
 
 	skb_tx_timestamp(skb);
 
-	spin_unlock_irqrestore(&fep->hw_lock, flags);
-
 	return NETDEV_TX_OK;
 }
 
@@ -406,11 +397,8 @@ fec_restart(struct net_device *ndev, int duplex)
 		writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc)
 			* RX_RING_SIZE,	fep->hwp + FEC_X_DES_START);
 
-	fep->dirty_tx = fep->cur_tx = fep->tx_bd_base;
 	fep->cur_rx = fep->rx_bd_base;
 
-	/* Reset SKB transmit buffers. */
-	fep->skb_cur = fep->skb_dirty = 0;
 	for (i = 0; i <= TX_RING_MOD_MASK; i++) {
 		if (fep->tx_skbuff[i]) {
 			dev_kfree_skb_any(fep->tx_skbuff[i]);
@@ -566,27 +554,47 @@ fec_timeout(struct net_device *ndev)
 	netif_wake_queue(ndev);
 }
 
-static void
+static int
 fec_enet_tx(struct net_device *ndev)
 {
 	struct	fec_enet_private *fep;
 	struct bufdesc *bdp;
 	unsigned short status;
 	struct	sk_buff	*skb;
+	int	pkts = 0;
+	int	index = 0;
+
+	if (IS_ERR(ndev))
+		return 0;
 
 	fep = netdev_priv(ndev);
-	spin_lock(&fep->hw_lock);
 	bdp = fep->dirty_tx;
 
+	/* get next bdp of dirty_tx */
+	if (bdp->cbd_sc & BD_ENET_TX_WRAP)
+		bdp = fep->tx_bd_base;
+	else
+		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
+
 	while (((status = bdp->cbd_sc) & BD_ENET_TX_READY) == 0) {
-		if (bdp == fep->cur_tx && fep->tx_full == 0)
+
+		/* current queue is empty */
+		if (bdp == fep->cur_tx)
 			break;
+		pkts++;
+
+		if (fep->bufdesc_ex)
+			index = (struct bufdesc_ex *)bdp -
+				(struct bufdesc_ex *)fep->tx_bd_base;
+		else
+			index = bdp - fep->tx_bd_base;
 
 		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
 				FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
 		bdp->cbd_bufaddr = 0;
 
-		skb = fep->tx_skbuff[fep->skb_dirty];
+		skb = fep->tx_skbuff[index];
+
 		/* Check for errors. */
 		if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC |
 				   BD_ENET_TX_RL | BD_ENET_TX_UN |
@@ -631,8 +639,9 @@ fec_enet_tx(struct net_device *ndev)
 
 		/* Free the sk buffer associated with this last transmit */
 		dev_kfree_skb_any(skb);
-		fep->tx_skbuff[fep->skb_dirty] = NULL;
-		fep->skb_dirty = (fep->skb_dirty + 1) & TX_RING_MOD_MASK;
+		fep->tx_skbuff[index] = NULL;
+
+		fep->dirty_tx = bdp;
 
 		/* Update pointer to next buffer descriptor to be transmitted */
 		if (status & BD_ENET_TX_WRAP)
@@ -642,14 +651,12 @@ fec_enet_tx(struct net_device *ndev)
 
 		/* Since we have freed up a buffer, the ring is no longer full
 		 */
-		if (fep->tx_full) {
-			fep->tx_full = 0;
+		if (fep->dirty_tx != fep->cur_tx) {
 			if (netif_queue_stopped(ndev))
 				netif_wake_queue(ndev);
 		}
 	}
-	fep->dirty_tx = bdp;
-	spin_unlock(&fep->hw_lock);
+	return pkts;
 }
 
 
@@ -816,7 +823,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 		int_events = readl(fep->hwp + FEC_IEVENT);
 		writel(int_events, fep->hwp + FEC_IEVENT);
 
-		if (int_events & FEC_ENET_RXF) {
+		if (int_events & (FEC_ENET_RXF | FEC_ENET_TXF)) {
 			ret = IRQ_HANDLED;
 
 			/* Disable the RX interrupt */
@@ -827,15 +834,6 @@ fec_enet_interrupt(int irq, void *dev_id)
 			}
 		}
 
-		/* Transmit OK, or non-fatal error. Update the buffer
-		 * descriptors. FEC handles all errors, we just discover
-		 * them as part of the transmit process.
-		 */
-		if (int_events & FEC_ENET_TXF) {
-			ret = IRQ_HANDLED;
-			fec_enet_tx(ndev);
-		}
-
 		if (int_events & FEC_ENET_MII) {
 			ret = IRQ_HANDLED;
 			complete(&fep->mdio_done);
@@ -851,6 +849,8 @@ static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
 	int pkts = fec_enet_rx(ndev, budget);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	fec_enet_tx(ndev);
+
 	if (pkts < budget) {
 		napi_complete(napi);
 		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
@@ -1646,6 +1646,7 @@ static int fec_enet_init(struct net_device *ndev)
 
 	/* ...and the same for transmit */
 	bdp = fep->tx_bd_base;
+	fep->cur_tx = bdp;
 	for (i = 0; i < TX_RING_SIZE; i++) {
 
 		/* Initialize the BD for every fragment in the page. */
@@ -1657,6 +1658,7 @@ static int fec_enet_init(struct net_device *ndev)
 	/* Set the last buffer to wrap */
 	bdp = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
 	bdp->cbd_sc |= BD_SC_WRAP;
+	fep->dirty_tx = bdp;
 
 	fec_restart(ndev, 0);
 
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 01579b8..c0f63be 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -214,8 +214,6 @@ struct fec_enet_private {
 	unsigned char *tx_bounce[TX_RING_SIZE];
 	struct	sk_buff *tx_skbuff[TX_RING_SIZE];
 	struct	sk_buff *rx_skbuff[RX_RING_SIZE];
-	ushort	skb_cur;
-	ushort	skb_dirty;
 
 	/* CPM dual port RAM relative addresses */
 	dma_addr_t	bd_dma;
@@ -227,7 +225,6 @@ struct fec_enet_private {
 	/* The ring entries to be free()ed */
 	struct bufdesc	*dirty_tx;
 
-	uint	tx_full;
 	/* hold while accessing the HW like ringbuffer for tx/rx but not MAC */
 	spinlock_t hw_lock;
 
-- 
1.7.1
