From: Felipe Balbi <balbi@ti.com>
Subject: [PATCH] net: ks8851: convert to threaded IRQ
Date: Tue, 29 Jan 2013 09:16:30 +0200
Message-ID: <1359443790-8562-1-git-send-email-balbi@ti.com>
References: <20130128.223157.1855971357181002973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <sboyd@codeaurora.org>, <mjr@cs.wisc.edu>,
	<netdev@vger.kernel.org>, Felipe Balbi <balbi@ti.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:41010 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642Ab3A2HQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 02:16:59 -0500
In-Reply-To: <20130128.223157.1855971357181002973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

just as it should have been. It also helps
removing the, now unnecessary, workqueue.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/ethernet/micrel/ks8851.c | 43 ++++++++++--------------------------
 1 file changed, 12 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 286816a..e29ad2e 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -69,7 +69,6 @@ union ks8851_tx_hdr {
  * @mii: The MII state information for the mii calls.
  * @rxctrl: RX settings for @rxctrl_work.
  * @tx_work: Work queue for tx packets
- * @irq_work: Work queue for servicing interrupts
  * @rxctrl_work: Work queue for updating RX mode and multicast lists
  * @txq: Queue of packets for transmission.
  * @spi_msg1: pre-setup SPI transfer with one message, @spi_xfer1.
@@ -121,7 +120,6 @@ struct ks8851_net {
 	struct ks8851_rxctrl	rxctrl;
 
 	struct work_struct	tx_work;
-	struct work_struct	irq_work;
 	struct work_struct	rxctrl_work;
 
 	struct sk_buff_head	txq;
@@ -444,23 +442,6 @@ static void ks8851_init_mac(struct ks8851_net *ks)
 }
 
 /**
- * ks8851_irq - device interrupt handler
- * @irq: Interrupt number passed from the IRQ handler.
- * @pw: The private word passed to register_irq(), our struct ks8851_net.
- *
- * Disable the interrupt from happening again until we've processed the
- * current status by scheduling ks8851_irq_work().
- */
-static irqreturn_t ks8851_irq(int irq, void *pw)
-{
-	struct ks8851_net *ks = pw;
-
-	disable_irq_nosync(irq);
-	schedule_work(&ks->irq_work);
-	return IRQ_HANDLED;
-}
-
-/**
  * ks8851_rdfifo - read data from the receive fifo
  * @ks: The device state.
  * @buff: The buffer address
@@ -595,19 +576,20 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 }
 
 /**
- * ks8851_irq_work - work queue handler for dealing with interrupt requests
- * @work: The work structure that was scheduled by schedule_work()
+ * ks8851_irq - IRQ handler for dealing with interrupt requests
+ * @irq: IRQ number
+ * @_ks: cookie
  *
- * This is the handler invoked when the ks8851_irq() is called to find out
- * what happened, as we cannot allow ourselves to sleep whilst waiting for
- * anything other process has the chip's lock.
+ * This handler is invoked when the IRQ line asserts to find out what happened.
+ * As we cannot allow ourselves to sleep in HARDIRQ context, this handler runs
+ * in thread context.
  *
  * Read the interrupt status, work out what needs to be done and then clear
  * any of the interrupts that are not needed.
  */
-static void ks8851_irq_work(struct work_struct *work)
+static irqreturn_t ks8851_irq(int irq, void *_ks)
 {
-	struct ks8851_net *ks = container_of(work, struct ks8851_net, irq_work);
+	struct ks8851_net *ks = _ks;
 	unsigned status;
 	unsigned handled = 0;
 
@@ -688,7 +670,7 @@ static void ks8851_irq_work(struct work_struct *work)
 	if (status & IRQ_TXI)
 		netif_wake_queue(ks->netdev);
 
-	enable_irq(ks->netdev->irq);
+	return IRQ_HANDLED;
 }
 
 /**
@@ -896,7 +878,6 @@ static int ks8851_net_stop(struct net_device *dev)
 	mutex_unlock(&ks->lock);
 
 	/* stop any outstanding work */
-	flush_work(&ks->irq_work);
 	flush_work(&ks->tx_work);
 	flush_work(&ks->rxctrl_work);
 
@@ -1438,7 +1419,6 @@ static int ks8851_probe(struct spi_device *spi)
 	spin_lock_init(&ks->statelock);
 
 	INIT_WORK(&ks->tx_work, ks8851_tx_work);
-	INIT_WORK(&ks->irq_work, ks8851_irq_work);
 	INIT_WORK(&ks->rxctrl_work, ks8851_rxctrl_work);
 
 	/* initialise pre-made spi transfer messages */
@@ -1505,8 +1485,9 @@ static int ks8851_probe(struct spi_device *spi)
 	ks8851_read_selftest(ks);
 	ks8851_init_mac(ks);
 
-	ret = request_irq(spi->irq, ks8851_irq, IRQF_TRIGGER_LOW,
-			  ndev->name, ks);
+	ret = request_threaded_irq(spi->irq, NULL, ks8851_irq,
+				   IRQF_TRIGGER_LOW | IRQF_ONESHOT,
+				   ndev->name, ks);
 	if (ret < 0) {
 		dev_err(&spi->dev, "failed to get irq\n");
 		goto err_irq;
-- 
1.8.1.rc1.5.g7e0651a
