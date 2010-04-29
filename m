From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 01/13] KS8851: Fix ks8851 snl transmit problem
Date: Fri, 30 Apr 2010 00:16:22 +0100
Message-ID: <20100429231739.509103394@fluff.org.uk>
References: <20100429231621.015936077@fluff.org.uk>
Cc: tristram.ha@micrel.com, support@tincantools.com,
	Tristram Ha <Tristram.Ha@micrel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:27351 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932733Ab0D3Vsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 17:48:35 -0400
Content-Disposition: inline; filename=thirdparty/micrel/ks8851-tx-fix.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tristram Ha <Tristram.Ha@micrel.com>

This fixes a transmit problem of the ks8851 snl network driver.

Under heavy TCP traffic the device will stop transmitting. Turning off
the transmit interrupt avoids this issue.  A new workqueue was
implemented to replace the functionality of the transmit interrupt processing.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>

---
---
 drivers/net/ks8851.c |   38 ++++++++++++++++++++------------------
 1 file changed, 20 insertions(+), 18 deletions(-)

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2010-04-20 18:13:58.000000000 +0100
+++ b/drivers/net/ks8851.c	2010-04-20 18:38:18.000000000 +0100
@@ -111,11 +111,13 @@ struct ks8851_net {
 	struct mii_if_info	mii;
 	struct ks8851_rxctrl	rxctrl;
 
+	struct work_struct	tx_check;
 	struct work_struct	tx_work;
 	struct work_struct	irq_work;
 	struct work_struct	rxctrl_work;
 
 	struct sk_buff_head	txq;
+	int			tx_len;
 
 	struct spi_message	spi_msg1;
 	struct spi_message	spi_msg2;
@@ -573,19 +575,6 @@ static void ks8851_irq_work(struct work_
 	if (status & IRQ_RXPSI)
 		handled |= IRQ_RXPSI;
 
-	if (status & IRQ_TXI) {
-		handled |= IRQ_TXI;
-
-		/* no lock here, tx queue should have been stopped */
-
-		/* update our idea of how much tx space is available to the
-		 * system */
-		ks->tx_space = ks8851_rdreg16(ks, KS_TXMIR);
-
-		if (netif_msg_intr(ks))
-			ks_dbg(ks, "%s: txspace %d\n", __func__, ks->tx_space);
-	}
-
 	if (status & IRQ_RXI)
 		handled |= IRQ_RXI;
 
@@ -623,9 +612,6 @@ static void ks8851_irq_work(struct work_
 
 	mutex_unlock(&ks->lock);
 
-	if (status & IRQ_TXI)
-		netif_wake_queue(ks->netdev);
-
 	enable_irq(ks->netdev->irq);
 }
 
@@ -703,6 +689,17 @@ static void ks8851_done_tx(struct ks8851
 	dev_kfree_skb(txb);
 }
 
+static void ks8851_tx_check(struct work_struct *work)
+{
+	struct ks8851_net *ks = container_of(work, struct ks8851_net, tx_check);
+
+	ks->tx_space = ks8851_rdreg16(ks, KS_TXMIR);
+	if (ks->tx_space > ks->tx_len)
+		netif_wake_queue(ks->netdev);
+	else
+		schedule_work(&ks->tx_check);
+}
+
 /**
  * ks8851_tx_work - process tx packet(s)
  * @work: The work strucutre what was scheduled.
@@ -814,7 +811,6 @@ static int ks8851_net_open(struct net_de
 	/* clear then enable interrupts */
 
 #define STD_IRQ (IRQ_LCI |	/* Link Change */	\
-		 IRQ_TXI |	/* TX done */		\
 		 IRQ_RXI |	/* RX done */		\
 		 IRQ_SPIBEI |	/* SPI bus error */	\
 		 IRQ_TXPSI |	/* TX process stop */	\
@@ -830,6 +826,7 @@ static int ks8851_net_open(struct net_de
 		ks_dbg(ks, "network device %s up\n", dev->name);
 
 	mutex_unlock(&ks->lock);
+	ks8851_write_mac_addr(dev);
 	return 0;
 }
 
@@ -854,6 +851,7 @@ static int ks8851_net_stop(struct net_de
 
 	/* stop any outstanding work */
 	flush_work(&ks->irq_work);
+	flush_work(&ks->tx_check);
 	flush_work(&ks->tx_work);
 	flush_work(&ks->rxctrl_work);
 
@@ -912,14 +910,16 @@ static netdev_tx_t ks8851_start_xmit(str
 
 	if (needed > ks->tx_space) {
 		netif_stop_queue(dev);
+		ks->tx_len = needed;
+		schedule_work(&ks->tx_check);
 		ret = NETDEV_TX_BUSY;
 	} else {
 		ks->tx_space -= needed;
 		skb_queue_tail(&ks->txq, skb);
+		schedule_work(&ks->tx_work);
 	}
 
 	spin_unlock(&ks->statelock);
-	schedule_work(&ks->tx_work);
 
 	return ret;
 }
@@ -1227,6 +1227,7 @@ static int __devinit ks8851_probe(struct
 	mutex_init(&ks->lock);
 	spin_lock_init(&ks->statelock);
 
+	INIT_WORK(&ks->tx_check, ks8851_tx_check);
 	INIT_WORK(&ks->tx_work, ks8851_tx_work);
 	INIT_WORK(&ks->irq_work, ks8851_irq_work);
 	INIT_WORK(&ks->rxctrl_work, ks8851_rxctrl_work);
@@ -1279,6 +1280,7 @@ static int __devinit ks8851_probe(struct
 
 	ks8851_read_selftest(ks);
 	ks8851_init_mac(ks);
+	ks->tx_space = ks8851_rdreg16(ks, KS_TXMIR);
 
 	ret = request_irq(spi->irq, ks8851_irq, IRQF_TRIGGER_LOW,
 			  ndev->name, ks);

