From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next] drivers/net/ks*: Use netdev_<level>,
 netif_<level> and pr_<level>
Date: Sat, 27 Feb 2010 16:43:51 -0800
Message-ID: <1267317831.30706.26.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tristram Ha <Tristram.Ha@micrel.com>, Ben Dooks <ben@simtec.co.uk>,
	"David J. Choi" <david.choi@micrel.com>,
	Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors.ext@mocean-labs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1224 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030979Ab0B1Anz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 19:43:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure this is correct.

It changes logging macros from:
	dev_<level>(&ks->spidev->dev,
to
	netdev_<level>(ks->netdev,

Comments?

Use netdev_<level>
Use netif_<level>
Use pr_<level>
Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Add missing line to message in ks8851_remove
Change kmalloc/memset(,0) to kzalloc
Remove ks_<level> macros
Consolidation code into set_media_state
---
 drivers/net/ks8842.c     |    8 ++--
 drivers/net/ks8851.c     |   88 ++++++++++++++++++++-------------------------
 drivers/net/ks8851_mll.c |   50 ++++++++++----------------
 drivers/net/ksz884x.c    |   65 ++++++++++++++-------------------
 4 files changed, 91 insertions(+), 120 deletions(-)

diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 5c45cb5..b91492f 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -20,6 +20,8 @@
  * The Micrel KS8842 behind the timberdale FPGA
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
@@ -525,8 +527,7 @@ static int ks8842_open(struct net_device *netdev)
 	err = request_irq(adapter->irq, ks8842_irq, IRQF_SHARED, DRV_NAME,
 		adapter);
 	if (err) {
-		printk(KERN_ERR "Failed to request IRQ: %d: %d\n",
-			adapter->irq, err);
+		pr_err("Failed to request IRQ: %d: %d\n", adapter->irq, err);
 		return err;
 	}
 
@@ -668,8 +669,7 @@ static int __devinit ks8842_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, netdev);
 
-	printk(KERN_INFO DRV_NAME
-		" Found chip, family: 0x%x, id: 0x%x, rev: 0x%x\n",
+	pr_info("Found chip, family: 0x%x, id: 0x%x, rev: 0x%x\n",
 		(id >> 8) & 0xff, (id >> 4) & 0xf, (id >> 1) & 0x7);
 
 	return 0;
diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index b5219cc..9cfb7cb 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -9,6 +9,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DEBUG
 
 #include <linux/module.h>
@@ -125,11 +127,6 @@ struct ks8851_net {
 
 static int msg_enable;
 
-#define ks_info(_ks, _msg...) dev_info(&(_ks)->spidev->dev, _msg)
-#define ks_warn(_ks, _msg...) dev_warn(&(_ks)->spidev->dev, _msg)
-#define ks_dbg(_ks, _msg...) dev_dbg(&(_ks)->spidev->dev, _msg)
-#define ks_err(_ks, _msg...) dev_err(&(_ks)->spidev->dev, _msg)
-
 /* shift for byte-enable data */
 #define BYTE_EN(_x)	((_x) << 2)
 
@@ -167,7 +164,7 @@ static void ks8851_wrreg16(struct ks8851_net *ks, unsigned reg, unsigned val)
 
 	ret = spi_sync(ks->spidev, msg);
 	if (ret < 0)
-		ks_err(ks, "spi_sync() failed\n");
+		netdev_err(ks->netdev, "spi_sync() failed\n");
 }
 
 /**
@@ -197,7 +194,7 @@ static void ks8851_wrreg8(struct ks8851_net *ks, unsigned reg, unsigned val)
 
 	ret = spi_sync(ks->spidev, msg);
 	if (ret < 0)
-		ks_err(ks, "spi_sync() failed\n");
+		netdev_err(ks->netdev, "spi_sync() failed\n");
 }
 
 /**
@@ -263,7 +260,7 @@ static void ks8851_rdreg(struct ks8851_net *ks, unsigned op,
 
 	ret = spi_sync(ks->spidev, msg);
 	if (ret < 0)
-		ks_err(ks, "read: spi_sync() failed\n");
+		netdev_err(ks->netdev, "read: spi_sync() failed\n");
 	else if (ks8851_rx_1msg(ks))
 		memcpy(rxb, trx + 2, rxl);
 	else
@@ -417,8 +414,8 @@ static void ks8851_rdfifo(struct ks8851_net *ks, u8 *buff, unsigned len)
 	u8 txb[1];
 	int ret;
 
-	if (netif_msg_rx_status(ks))
-		ks_dbg(ks, "%s: %d@%p\n", __func__, len, buff);
+	netif_dbg(ks, rx_status, ks->netdev,
+		  "%s: %d@%p\n", __func__, len, buff);
 
 	/* set the operation we're issuing */
 	txb[0] = KS_SPIOP_RXFIFO;
@@ -434,7 +431,7 @@ static void ks8851_rdfifo(struct ks8851_net *ks, u8 *buff, unsigned len)
 
 	ret = spi_sync(ks->spidev, msg);
 	if (ret < 0)
-		ks_err(ks, "%s: spi_sync() failed\n", __func__);
+		netdev_err(ks->netdev, "%s: spi_sync() failed\n", __func__);
 }
 
 /**
@@ -446,10 +443,11 @@ static void ks8851_rdfifo(struct ks8851_net *ks, u8 *buff, unsigned len)
 */
 static void ks8851_dbg_dumpkkt(struct ks8851_net *ks, u8 *rxpkt)
 {
-	ks_dbg(ks, "pkt %02x%02x%02x%02x %02x%02x%02x%02x %02x%02x%02x%02x\n",
-	       rxpkt[4], rxpkt[5], rxpkt[6], rxpkt[7],
-	       rxpkt[8], rxpkt[9], rxpkt[10], rxpkt[11],
-	       rxpkt[12], rxpkt[13], rxpkt[14], rxpkt[15]);
+	netdev_dbg(ks->netdev,
+		   "pkt %02x%02x%02x%02x %02x%02x%02x%02x %02x%02x%02x%02x\n",
+		   rxpkt[4], rxpkt[5], rxpkt[6], rxpkt[7],
+		   rxpkt[8], rxpkt[9], rxpkt[10], rxpkt[11],
+		   rxpkt[12], rxpkt[13], rxpkt[14], rxpkt[15]);
 }
 
 /**
@@ -471,8 +469,8 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 
 	rxfc = ks8851_rdreg8(ks, KS_RXFC);
 
-	if (netif_msg_rx_status(ks))
-		ks_dbg(ks, "%s: %d packets\n", __func__, rxfc);
+	netif_dbg(ks, rx_status, ks->netdev,
+		  "%s: %d packets\n", __func__, rxfc);
 
 	/* Currently we're issuing a read per packet, but we could possibly
 	 * improve the code by issuing a single read, getting the receive
@@ -489,9 +487,8 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 		rxstat = rxh & 0xffff;
 		rxlen = rxh >> 16;
 
-		if (netif_msg_rx_status(ks))
-			ks_dbg(ks, "rx: stat 0x%04x, len 0x%04x\n",
-				rxstat, rxlen);
+		netif_dbg(ks, rx_status, ks->netdev,
+			  "rx: stat 0x%04x, len 0x%04x\n", rxstat, rxlen);
 
 		/* the length of the packet includes the 32bit CRC */
 
@@ -553,9 +550,8 @@ static void ks8851_irq_work(struct work_struct *work)
 
 	status = ks8851_rdreg16(ks, KS_ISR);
 
-	if (netif_msg_intr(ks))
-		dev_dbg(&ks->spidev->dev, "%s: status 0x%04x\n",
-			__func__, status);
+	netif_dbg(ks, intr, ks->netdev,
+		  "%s: status 0x%04x\n", __func__, status);
 
 	if (status & IRQ_LCI) {
 		/* should do something about checking link status */
@@ -582,8 +578,8 @@ static void ks8851_irq_work(struct work_struct *work)
 		 * system */
 		ks->tx_space = ks8851_rdreg16(ks, KS_TXMIR);
 
-		if (netif_msg_intr(ks))
-			ks_dbg(ks, "%s: txspace %d\n", __func__, ks->tx_space);
+		netif_dbg(ks, intr, ks->netdev,
+			  "%s: txspace %d\n", __func__, ks->tx_space);
 	}
 
 	if (status & IRQ_RXI)
@@ -659,9 +655,8 @@ static void ks8851_wrpkt(struct ks8851_net *ks, struct sk_buff *txp, bool irq)
 	unsigned fid = 0;
 	int ret;
 
-	if (netif_msg_tx_queued(ks))
-		dev_dbg(&ks->spidev->dev, "%s: skb %p, %d@%p, irq %d\n",
-			__func__, txp, txp->len, txp->data, irq);
+	netif_dbg(ks, tx_queued, ks->netdev, "%s: skb %p, %d@%p, irq %d\n",
+		  __func__, txp, txp->len, txp->data, irq);
 
 	fid = ks->fid++;
 	fid &= TXFR_TXFID_MASK;
@@ -685,7 +680,7 @@ static void ks8851_wrpkt(struct ks8851_net *ks, struct sk_buff *txp, bool irq)
 
 	ret = spi_sync(ks->spidev, msg);
 	if (ret < 0)
-		ks_err(ks, "%s: spi_sync() failed\n", __func__);
+		netdev_err(ks->netdev, "%s: spi_sync() failed\n", __func__);
 }
 
 /**
@@ -744,8 +739,7 @@ static void ks8851_set_powermode(struct ks8851_net *ks, unsigned pwrmode)
 {
 	unsigned pmecr;
 
-	if (netif_msg_hw(ks))
-		ks_dbg(ks, "setting power mode %d\n", pwrmode);
+	netif_dbg(ks, hw, ks->netdev, "setting power mode %d\n", pwrmode);
 
 	pmecr = ks8851_rdreg16(ks, KS_PMECR);
 	pmecr &= ~PMECR_PM_MASK;
@@ -769,8 +763,7 @@ static int ks8851_net_open(struct net_device *dev)
 	 * else at the moment */
 	mutex_lock(&ks->lock);
 
-	if (netif_msg_ifup(ks))
-		ks_dbg(ks, "opening %s\n", dev->name);
+	netif_dbg(ks, ifup, ks->netdev, "opening\n");
 
 	/* bring chip out of any power saving mode it was in */
 	ks8851_set_powermode(ks, PMECR_PM_NORMAL);
@@ -826,8 +819,7 @@ static int ks8851_net_open(struct net_device *dev)
 
 	netif_start_queue(ks->netdev);
 
-	if (netif_msg_ifup(ks))
-		ks_dbg(ks, "network device %s up\n", dev->name);
+	netif_dbg(ks, ifup, ks->netdev, "network device up\n");
 
 	mutex_unlock(&ks->lock);
 	return 0;
@@ -845,8 +837,7 @@ static int ks8851_net_stop(struct net_device *dev)
 {
 	struct ks8851_net *ks = netdev_priv(dev);
 
-	if (netif_msg_ifdown(ks))
-		ks_info(ks, "%s: shutting down\n", dev->name);
+	netif_info(ks, ifdown, dev, "shutting down\n");
 
 	netif_stop_queue(dev);
 
@@ -874,8 +865,8 @@ static int ks8851_net_stop(struct net_device *dev)
 	while (!skb_queue_empty(&ks->txq)) {
 		struct sk_buff *txb = skb_dequeue(&ks->txq);
 
-		if (netif_msg_ifdown(ks))
-			ks_dbg(ks, "%s: freeing txb %p\n", __func__, txb);
+		netif_dbg(ks, ifdown, ks->netdev,
+			  "%s: freeing txb %p\n", __func__, txb);
 
 		dev_kfree_skb(txb);
 	}
@@ -904,9 +895,8 @@ static netdev_tx_t ks8851_start_xmit(struct sk_buff *skb,
 	unsigned needed = calc_txlen(skb->len);
 	netdev_tx_t ret = NETDEV_TX_OK;
 
-	if (netif_msg_tx_queued(ks))
-		ks_dbg(ks, "%s: skb %p, %d@%p\n", __func__,
-		       skb, skb->len, skb->data);
+	netif_dbg(ks, tx_queued, ks->netdev,
+		  "%s: skb %p, %d@%p\n", __func__, skb, skb->len, skb->data);
 
 	spin_lock(&ks->statelock);
 
@@ -1186,17 +1176,17 @@ static int ks8851_read_selftest(struct ks8851_net *ks)
 	rd = ks8851_rdreg16(ks, KS_MBIR);
 
 	if ((rd & both_done) != both_done) {
-		ks_warn(ks, "Memory selftest not finished\n");
+		netdev_warn(ks->netdev, "Memory selftest not finished\n");
 		return 0;
 	}
 
 	if (rd & MBIR_TXMBFA) {
-		ks_err(ks, "TX memory selftest fail\n");
+		netdev_err(ks->netdev, "TX memory selftest fail\n");
 		ret |= 1;
 	}
 
 	if (rd & MBIR_RXMBFA) {
-		ks_err(ks, "RX memory selftest fail\n");
+		netdev_err(ks->netdev, "RX memory selftest fail\n");
 		ret |= 2;
 	}
 
@@ -1294,9 +1284,9 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 		goto err_netdev;
 	}
 
-	dev_info(&spi->dev, "revision %d, MAC %pM, IRQ %d\n",
-		 CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
-		 ndev->dev_addr, ndev->irq);
+	netdev_info(ndev, "revision %d, MAC %pM, IRQ %d\n",
+		    CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
+		    ndev->dev_addr, ndev->irq);
 
 	return 0;
 
@@ -1315,7 +1305,7 @@ static int __devexit ks8851_remove(struct spi_device *spi)
 	struct ks8851_net *priv = dev_get_drvdata(&spi->dev);
 
 	if (netif_msg_drv(priv))
-		dev_info(&spi->dev, "remove");
+		dev_info(&spi->dev, "remove\n");
 
 	unregister_netdev(priv->netdev);
 	free_irq(spi->irq, priv);
diff --git a/drivers/net/ks8851_mll.c b/drivers/net/ks8851_mll.c
index 84b0e15..d3c6a77 100644
--- a/drivers/net/ks8851_mll.c
+++ b/drivers/net/ks8851_mll.c
@@ -21,6 +21,8 @@
  * KS8851 16bit MLL chip from Micrel Inc.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
@@ -458,11 +460,6 @@ struct ks_net {
 
 static int msg_enable;
 
-#define ks_info(_ks, _msg...) dev_info(&(_ks)->pdev->dev, _msg)
-#define ks_warn(_ks, _msg...) dev_warn(&(_ks)->pdev->dev, _msg)
-#define ks_dbg(_ks, _msg...) dev_dbg(&(_ks)->pdev->dev, _msg)
-#define ks_err(_ks, _msg...) dev_err(&(_ks)->pdev->dev, _msg)
-
 #define BE3             0x8000      /* Byte Enable 3 */
 #define BE2             0x4000      /* Byte Enable 2 */
 #define BE1             0x2000      /* Byte Enable 1 */
@@ -624,8 +621,7 @@ static void ks_set_powermode(struct ks_net *ks, unsigned pwrmode)
 {
 	unsigned pmecr;
 
-	if (netif_msg_hw(ks))
-		ks_dbg(ks, "setting power mode %d\n", pwrmode);
+	netif_dbg(ks, hw, ks->netdev, "setting power mode %d\n", pwrmode);
 
 	ks_rdreg16(ks, KS_GRR);
 	pmecr = ks_rdreg16(ks, KS_PMECR);
@@ -809,7 +805,7 @@ static void ks_rcv(struct ks_net *ks, struct net_device *netdev)
 			skb->protocol = eth_type_trans(skb, netdev);
 			netif_rx(skb);
 		} else {
-			printk(KERN_ERR "%s: err:skb alloc\n", __func__);
+			pr_err("%s: err:skb alloc\n", __func__);
 			ks_wrreg16(ks, KS_RXQCR, (ks->rc_rxqcr | RXQCR_RRXEF));
 			if (skb)
 				dev_kfree_skb_irq(skb);
@@ -836,9 +832,8 @@ static void ks_update_link_status(struct net_device *netdev, struct ks_net *ks)
 		netif_carrier_off(netdev);
 		link_up_status = false;
 	}
-	if (netif_msg_link(ks))
-		ks_dbg(ks, "%s: %s\n",
-			__func__, link_up_status ? "UP" : "DOWN");
+	netif_dbg(ks, link, ks->netdev,
+		  "%s: %s\n", __func__, link_up_status ? "UP" : "DOWN");
 }
 
 /**
@@ -908,15 +903,13 @@ static int ks_net_open(struct net_device *netdev)
 	 * else at the moment.
 	 */
 
-	if (netif_msg_ifup(ks))
-		ks_dbg(ks, "%s - entry\n", __func__);
+	netif_dbg(ks, ifup, ks->netdev, "%s - entry\n", __func__);
 
 	/* reset the HW */
 	err = request_irq(ks->irq, ks_irq, KS_INT_FLAGS, DRV_NAME, netdev);
 
 	if (err) {
-		printk(KERN_ERR "Failed to request IRQ: %d: %d\n",
-			ks->irq, err);
+		pr_err("Failed to request IRQ: %d: %d\n", ks->irq, err);
 		return err;
 	}
 
@@ -929,8 +922,7 @@ static int ks_net_open(struct net_device *netdev)
 	ks_enable_qmu(ks);
 	netif_start_queue(ks->netdev);
 
-	if (netif_msg_ifup(ks))
-		ks_dbg(ks, "network device %s up\n", netdev->name);
+	netif_dbg(ks, ifup, ks->netdev, "network device up\n");
 
 	return 0;
 }
@@ -947,8 +939,7 @@ static int ks_net_stop(struct net_device *netdev)
 {
 	struct ks_net *ks = netdev_priv(netdev);
 
-	if (netif_msg_ifdown(ks))
-		ks_info(ks, "%s: shutting down\n", netdev->name);
+	netif_info(ks, ifdown, netdev, "shutting down\n");
 
 	netif_stop_queue(netdev);
 
@@ -1429,21 +1420,21 @@ static int ks_read_selftest(struct ks_net *ks)
 	rd = ks_rdreg16(ks, KS_MBIR);
 
 	if ((rd & both_done) != both_done) {
-		ks_warn(ks, "Memory selftest not finished\n");
+		netdev_warn(ks->netdev, "Memory selftest not finished\n");
 		return 0;
 	}
 
 	if (rd & MBIR_TXMBFA) {
-		ks_err(ks, "TX memory selftest fails\n");
+		netdev_err(ks->netdev, "TX memory selftest fails\n");
 		ret |= 1;
 	}
 
 	if (rd & MBIR_RXMBFA) {
-		ks_err(ks, "RX memory selftest fails\n");
+		netdev_err(ks->netdev, "RX memory selftest fails\n");
 		ret |= 2;
 	}
 
-	ks_info(ks, "the selftest passes\n");
+	netdev_info(ks->netdev, "the selftest passes\n");
 	return ret;
 }
 
@@ -1514,7 +1505,7 @@ static int ks_hw_init(struct ks_net *ks)
 	ks->frame_head_info = (struct type_frame_head *) \
 		kmalloc(MHEADER_SIZE, GFP_KERNEL);
 	if (!ks->frame_head_info) {
-		printk(KERN_ERR "Error: Fail to allocate frame memory\n");
+		pr_err("Error: Fail to allocate frame memory\n");
 		return false;
 	}
 
@@ -1580,7 +1571,7 @@ static int __devinit ks8851_probe(struct platform_device *pdev)
 	ks->mii.mdio_read       = ks_phy_read;
 	ks->mii.mdio_write      = ks_phy_write;
 
-	ks_info(ks, "message enable is %d\n", msg_enable);
+	netdev_info(netdev, "message enable is %d\n", msg_enable);
 	/* set the default message enable */
 	ks->msg_enable = netif_msg_init(msg_enable, (NETIF_MSG_DRV |
 						     NETIF_MSG_PROBE |
@@ -1589,13 +1580,13 @@ static int __devinit ks8851_probe(struct platform_device *pdev)
 
 	/* simple check for a valid chip being connected to the bus */
 	if ((ks_rdreg16(ks, KS_CIDER) & ~CIDER_REV_MASK) != CIDER_ID) {
-		ks_err(ks, "failed to read device ID\n");
+		netdev_err(netdev, "failed to read device ID\n");
 		err = -ENODEV;
 		goto err_register;
 	}
 
 	if (ks_read_selftest(ks)) {
-		ks_err(ks, "failed to read device ID\n");
+		netdev_err(netdev, "failed to read device ID\n");
 		err = -ENODEV;
 		goto err_register;
 	}
@@ -1626,9 +1617,8 @@ static int __devinit ks8851_probe(struct platform_device *pdev)
 
 	id = ks_rdreg16(ks, KS_CIDER);
 
-	printk(KERN_INFO DRV_NAME
-		" Found chip, family: 0x%x, id: 0x%x, rev: 0x%x\n",
-		(id >> 8) & 0xff, (id >> 4) & 0xf, (id >> 1) & 0x7);
+	netdev_info(netdev, "Found chip, family: 0x%x, id: 0x%x, rev: 0x%x\n",
+		    (id >> 8) & 0xff, (id >> 4) & 0xf, (id >> 1) & 0x7);
 	return 0;
 
 err_register:
diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 7264a3e..682e87f 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -14,6 +14,8 @@
  * GNU General Public License for more details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -1483,11 +1485,6 @@ struct dev_priv {
 	int promiscuous;
 };
 
-#define ks_info(_ks, _msg...) dev_info(&(_ks)->pdev->dev, _msg)
-#define ks_warn(_ks, _msg...) dev_warn(&(_ks)->pdev->dev, _msg)
-#define ks_dbg(_ks, _msg...) dev_dbg(&(_ks)->pdev->dev, _msg)
-#define ks_err(_ks, _msg...) dev_err(&(_ks)->pdev->dev, _msg)
-
 #define DRV_NAME		"KSZ884X PCI"
 #define DEVICE_NAME		"KSZ884x PCI"
 #define DRV_VERSION		"1.0.0"
@@ -3834,7 +3831,7 @@ static void ksz_check_desc_num(struct ksz_desc_info *info)
 		alloc >>= 1;
 	}
 	if (alloc != 1 || shift < MIN_DESC_SHIFT) {
-		printk(KERN_ALERT "Hardware descriptor numbers not right!\n");
+		pr_alert("Hardware descriptor numbers not right!\n");
 		while (alloc) {
 			shift++;
 			alloc >>= 1;
@@ -4545,8 +4542,7 @@ static int ksz_alloc_mem(struct dev_info *adapter)
 		(((sizeof(struct ksz_hw_desc) + DESC_ALIGNMENT - 1) /
 		DESC_ALIGNMENT) * DESC_ALIGNMENT);
 	if (hw->rx_desc_info.size != sizeof(struct ksz_hw_desc))
-		printk(KERN_ALERT
-			"Hardware descriptor size not right!\n");
+		pr_alert("Hardware descriptor size not right!\n");
 	ksz_check_desc_num(&hw->rx_desc_info);
 	ksz_check_desc_num(&hw->tx_desc_info);
 
@@ -5317,10 +5313,10 @@ static irqreturn_t netdev_intr(int irq, void *dev_id)
 			u32 data;
 
 			hw->intr_mask &= ~KS884X_INT_TX_STOPPED;
-			printk(KERN_INFO "Tx stopped\n");
+			pr_info("Tx stopped\n");
 			data = readl(hw->io + KS_DMA_TX_CTRL);
 			if (!(data & DMA_TX_ENABLE))
-				printk(KERN_INFO "Tx disabled\n");
+				pr_info("Tx disabled\n");
 			break;
 		}
 	} while (0);
@@ -5493,6 +5489,18 @@ static int prepare_hardware(struct net_device *dev)
 	return 0;
 }
 
+static void set_media_state(struct net_device *dev, int media_state)
+{
+	struct dev_priv *priv = netdev_priv(dev);
+
+	if (media_state == priv->media_state)
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
+	netif_info(priv, link, dev, "link %s\n",
+		   media_state == priv->media_state ? "on" : "off");
+}
+
 /**
  * netdev_open - open network device
  * @dev:	Network device.
@@ -5582,15 +5590,7 @@ static int netdev_open(struct net_device *dev)
 
 	priv->media_state = port->linked->state;
 
-	if (media_connected == priv->media_state)
-		netif_carrier_on(dev);
-	else
-		netif_carrier_off(dev);
-	if (netif_msg_link(priv))
-		printk(KERN_INFO "%s link %s\n", dev->name,
-			(media_connected == priv->media_state ?
-			"on" : "off"));
-
+	set_media_state(dev, media_connected);
 	netif_start_queue(dev);
 
 	return 0;
@@ -6680,16 +6680,8 @@ static void update_link(struct net_device *dev, struct dev_priv *priv,
 {
 	if (priv->media_state != port->linked->state) {
 		priv->media_state = port->linked->state;
-		if (netif_running(dev)) {
-			if (media_connected == priv->media_state)
-				netif_carrier_on(dev);
-			else
-				netif_carrier_off(dev);
-			if (netif_msg_link(priv))
-				printk(KERN_INFO "%s link %s\n", dev->name,
-					(media_connected == priv->media_state ?
-					"on" : "off"));
-		}
+		if (netif_running(dev))
+			set_media_state(dev, media_connected);
 	}
 }
 
@@ -6983,7 +6975,7 @@ static int __init pcidev_init(struct pci_dev *pdev,
 	int pi;
 	int port_count;
 	int result;
-	char banner[80];
+	char banner[sizeof(version)];
 	struct ksz_switch *sw = NULL;
 
 	result = pci_enable_device(pdev);
@@ -7007,10 +6999,9 @@ static int __init pcidev_init(struct pci_dev *pdev,
 
 	result = -ENOMEM;
 
-	info = kmalloc(sizeof(struct platform_info), GFP_KERNEL);
+	info = kzalloc(sizeof(struct platform_info), GFP_KERNEL);
 	if (!info)
 		goto pcidev_init_dev_err;
-	memset(info, 0, sizeof(struct platform_info));
 
 	hw_priv = &info->dev_info;
 	hw_priv->pdev = pdev;
@@ -7024,15 +7015,15 @@ static int __init pcidev_init(struct pci_dev *pdev,
 	cnt = hw_init(hw);
 	if (!cnt) {
 		if (msg_enable & NETIF_MSG_PROBE)
-			printk(KERN_ALERT "chip not detected\n");
+			pr_alert("chip not detected\n");
 		result = -ENODEV;
 		goto pcidev_init_alloc_err;
 	}
 
-	sprintf(banner,	"%s\n", version);
-	banner[13] = cnt + '0';
-	ks_info(hw_priv, "%s", banner);
-	ks_dbg(hw_priv, "Mem = %p; IRQ = %d\n", hw->io, pdev->irq);
+	snprintf(banner, sizeof(banner), "%s", version);
+	banner[13] = cnt + '0';		/* Replace x in "Micrel KSZ884x" */
+	dev_info(&hw_priv->pdev->dev, "%s\n", banner);
+	dev_dbg(&hw_priv->pdev->dev, "Mem = %p; IRQ = %d\n", hw->io, pdev->irq);
 
 	/* Assume device is KSZ8841. */
 	hw->dev_count = 1;


