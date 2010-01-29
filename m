From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/13] tulip/dmfe.c: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:20 -0800
Message-ID: <d33f3bb2ce30ca816a5e4d18a34b5fb3a7ce651e.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1584 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753903Ab0A2G7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:31 -0500
In-Reply-To: <cover.1264747118.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert printks to dev_<level> where a dev is available
Convert printks to pr_<level> where not
Coalesce format strings
Change print formats with %d.dx to %0dx
Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove 'DRV_NAME ": ' from logging messages
Convert commented out printks to pr_debug

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/dmfe.c |   67 +++++++++++++++++++++------------------------
 1 files changed, 31 insertions(+), 36 deletions(-)

diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 2d9f09c..5fc61c1 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -61,6 +61,8 @@
     Test and make sure PCI latency is now correct for all cases.
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRV_NAME	"dmfe"
 #define DRV_VERSION	"1.36.4"
 #define DRV_RELDATE	"2002-01-17"
@@ -149,16 +151,17 @@
 #define DMFE_TX_TIMEOUT ((3*HZ)/2)	/* tx packet time-out time 1.5 s" */
 #define DMFE_TX_KICK 	(HZ/2)	/* tx packet Kick-out time 0.5 s" */
 
-#define DMFE_DBUG(dbug_now, msg, value) \
-	do { \
- 		if (dmfe_debug || (dbug_now)) \
-			printk(KERN_ERR DRV_NAME ": %s %lx\n",\
- 				(msg), (long) (value)); \
+#define DMFE_DBUG(dbug_now, msg, value)			\
+	do {						\
+		if (dmfe_debug || (dbug_now))		\
+			pr_err("%s %lx\n",		\
+			       (msg), (long) (value));	\
 	} while (0)
 
-#define SHOW_MEDIA_TYPE(mode) \
-	printk (KERN_INFO DRV_NAME ": Change Speed to %sMhz %s duplex\n" , \
-		(mode & 1) ? "100":"10", (mode & 4) ? "full":"half");
+#define SHOW_MEDIA_TYPE(mode)				\
+	pr_info("Change Speed to %sMhz %s duplex\n" ,	\
+		(mode & 1) ? "100":"10",		\
+		(mode & 4) ? "full":"half");
 
 
 /* CR9 definition: SROM/MII */
@@ -391,8 +394,7 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 		struct device_node *dp = pci_device_to_OF_node(pdev);
 
 		if (dp && of_get_property(dp, "local-mac-address", NULL)) {
-			printk(KERN_INFO DRV_NAME
-			       ": skipping on-board DM910x (use tulip)\n");
+			pr_info("skipping on-board DM910x (use tulip)\n");
 			return -ENODEV;
 		}
 	}
@@ -405,8 +407,7 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		printk(KERN_WARNING DRV_NAME
-			": 32-bit PCI DMA not available.\n");
+		pr_warning("32-bit PCI DMA not available\n");
 		err = -ENODEV;
 		goto err_out_free;
 	}
@@ -417,13 +418,13 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 		goto err_out_free;
 
 	if (!pci_resource_start(pdev, 0)) {
-		printk(KERN_ERR DRV_NAME ": I/O base is zero\n");
+		pr_err("I/O base is zero\n");
 		err = -ENODEV;
 		goto err_out_disable;
 	}
 
 	if (pci_resource_len(pdev, 0) < (CHK_IO_SIZE(pdev)) ) {
-		printk(KERN_ERR DRV_NAME ": Allocated I/O size too small\n");
+		pr_err("Allocated I/O size too small\n");
 		err = -ENODEV;
 		goto err_out_disable;
 	}
@@ -438,7 +439,7 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 #endif
 
 	if (pci_request_regions(pdev, DRV_NAME)) {
-		printk(KERN_ERR DRV_NAME ": Failed to request PCI regions\n");
+		pr_err("Failed to request PCI regions\n");
 		err = -ENODEV;
 		goto err_out_disable;
 	}
@@ -497,12 +498,9 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	if (err)
 		goto err_out_free_buf;
 
-	printk(KERN_INFO "%s: Davicom DM%04lx at pci%s, %pM, irq %d.\n",
-	       dev->name,
-	       ent->driver_data >> 16,
-	       pci_name(pdev),
-	       dev->dev_addr,
-	       dev->irq);
+	dev_info(&dev->dev, "Davicom DM%04lx at pci%s, %pM, irq %d\n",
+		 ent->driver_data >> 16,
+		 pci_name(pdev), dev->dev_addr, dev->irq);
 
 	pci_set_master(pdev);
 
@@ -696,7 +694,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 
 	/* Too large packet check */
 	if (skb->len > MAX_PACKET_SIZE) {
-		printk(KERN_ERR DRV_NAME ": big packet = %d\n", (u16)skb->len);
+		pr_err("big packet = %d\n", (u16)skb->len);
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
@@ -706,8 +704,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 	/* No Tx resource check, it never happen nromally */
 	if (db->tx_queue_cnt >= TX_FREE_DESC_CNT) {
 		spin_unlock_irqrestore(&db->lock, flags);
-		printk(KERN_ERR DRV_NAME ": No Tx resource %ld\n",
-		       db->tx_queue_cnt);
+		pr_err("No Tx resource %ld\n", db->tx_queue_cnt);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -779,12 +776,11 @@ static int dmfe_stop(struct DEVICE *dev)
 
 #if 0
 	/* show statistic counter */
-	printk(DRV_NAME ": FU:%lx EC:%lx LC:%lx NC:%lx"
-		" LOC:%lx TXJT:%lx RESET:%lx RCR8:%lx FAL:%lx TT:%lx\n",
-		db->tx_fifo_underrun, db->tx_excessive_collision,
-		db->tx_late_collision, db->tx_no_carrier, db->tx_loss_carrier,
-		db->tx_jabber_timeout, db->reset_count, db->reset_cr8,
-		db->reset_fatal, db->reset_TXtimeout);
+	printk("FU:%lx EC:%lx LC:%lx NC:%lx LOC:%lx TXJT:%lx RESET:%lx RCR8:%lx FAL:%lx TT:%lx\n",
+	       db->tx_fifo_underrun, db->tx_excessive_collision,
+	       db->tx_late_collision, db->tx_no_carrier, db->tx_loss_carrier,
+	       db->tx_jabber_timeout, db->reset_count, db->reset_cr8,
+	       db->reset_fatal, db->reset_TXtimeout);
 #endif
 
 	return 0;
@@ -885,7 +881,7 @@ static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_board_info * db)
 	txptr = db->tx_remove_ptr;
 	while(db->tx_packet_cnt) {
 		tdes0 = le32_to_cpu(txptr->tdes0);
-		/* printk(DRV_NAME ": tdes0=%x\n", tdes0); */
+		pr_debug("tdes0=%x\n", tdes0);
 		if (tdes0 & 0x80000000)
 			break;
 
@@ -895,7 +891,7 @@ static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_board_info * db)
 
 		/* Transmit statistic counter */
 		if ( tdes0 != 0x7fffffff ) {
-			/* printk(DRV_NAME ": tdes0=%x\n", tdes0); */
+			pr_debug("tdes0=%x\n", tdes0);
 			dev->stats.collisions += (tdes0 >> 3) & 0xf;
 			dev->stats.tx_bytes += le32_to_cpu(txptr->tdes1) & 0x7ff;
 			if (tdes0 & TDES0_ERR_MASK) {
@@ -992,7 +988,7 @@ static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
 			/* error summary bit check */
 			if (rdes0 & 0x8000) {
 				/* This is a error packet */
-				//printk(DRV_NAME ": rdes0: %lx\n", rdes0);
+				pr_debug("rdes0: %x\n", rdes0);
 				dev->stats.rx_errors++;
 				if (rdes0 & 1)
 					dev->stats.rx_fifo_errors++;
@@ -1191,8 +1187,7 @@ static void dmfe_timer(unsigned long data)
 		if ( time_after(jiffies, dev->trans_start + DMFE_TX_TIMEOUT) ) {
 			db->reset_TXtimeout++;
 			db->wait_reset = 1;
-			printk(KERN_WARNING "%s: Tx timeout - resetting\n",
-			       dev->name);
+			dev_warn(&dev->dev, "Tx timeout - resetting\n");
 		}
 	}
 
@@ -1646,7 +1641,7 @@ static u8 dmfe_sense_speed(struct dmfe_board_info * db)
 		else 				/* DM9102/DM9102A */
 			phy_mode = phy_read(db->ioaddr,
 				    db->phy_addr, 17, db->chip_id) & 0xf000;
-		/* printk(DRV_NAME ": Phy_mode %x ",phy_mode); */
+		pr_debug("Phy_mode %x\n", phy_mode);
 		switch (phy_mode) {
 		case 0x1000: db->op_mode = DMFE_10MHF; break;
 		case 0x2000: db->op_mode = DMFE_10MFD; break;
-- 
1.6.6.rc0.57.gad7a

