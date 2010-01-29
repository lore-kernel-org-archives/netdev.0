From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/13] tulip/uli526x.c: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:27 -0800
Message-ID: <c0233ff5b830b0b050529dd1a750fad6154d0fe5.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1596 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754274Ab0A2G7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:32 -0500
In-Reply-To: <cover.1264747118.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert printks to dev_<level> where a dev is available
Convert printks to pr_<level> where not
Coalesce format strings
Change print formats with %d.dx to %0dx
Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove DRV_NAME from logging messages
Add do {} while(0) to ULI526X_DBUG macro
Make SHOW_MEDIA_TYPE macro more readable

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/uli526x.c |   46 +++++++++++++++++++++++++-----------------
 1 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index d549042..dc3335d 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -12,6 +12,8 @@
 
 */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRV_NAME	"uli526x"
 #define DRV_VERSION	"0.9.3"
 #define DRV_RELDATE	"2005-7-29"
@@ -82,9 +84,16 @@
 #define ULI526X_TX_TIMEOUT ((16*HZ)/2)	/* tx packet time-out time 8 s" */
 #define ULI526X_TX_KICK 	(4*HZ/2)	/* tx packet Kick-out time 2 s" */
 
-#define ULI526X_DBUG(dbug_now, msg, value) if (uli526x_debug || (dbug_now)) printk(KERN_ERR DRV_NAME ": %s %lx\n", (msg), (long) (value))
+#define ULI526X_DBUG(dbug_now, msg, value)			\
+do {								\
+	if (uli526x_debug || (dbug_now))			\
+		pr_err("%s %lx\n", (msg), (long) (value));	\
+} while (0)
 
-#define SHOW_MEDIA_TYPE(mode) printk(KERN_ERR DRV_NAME ": Change Speed to %sMhz %s duplex\n",mode & 1 ?"100":"10", mode & 4 ? "full":"half");
+#define SHOW_MEDIA_TYPE(mode)					\
+	pr_err("Change Speed to %sMhz %s duplex\n",		\
+	       mode & 1 ? "100" : "10",				\
+	       mode & 4 ? "full" : "half");
 
 
 /* CR9 definition: SROM/MII */
@@ -284,7 +293,7 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		printk(KERN_WARNING DRV_NAME ": 32-bit PCI DMA not available.\n");
+		pr_warning("32-bit PCI DMA not available\n");
 		err = -ENODEV;
 		goto err_out_free;
 	}
@@ -295,19 +304,19 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 		goto err_out_free;
 
 	if (!pci_resource_start(pdev, 0)) {
-		printk(KERN_ERR DRV_NAME ": I/O base is zero\n");
+		pr_err("I/O base is zero\n");
 		err = -ENODEV;
 		goto err_out_disable;
 	}
 
 	if (pci_resource_len(pdev, 0) < (ULI526X_IO_SIZE) ) {
-		printk(KERN_ERR DRV_NAME ": Allocated I/O size too small\n");
+		pr_err("Allocated I/O size too small\n");
 		err = -ENODEV;
 		goto err_out_disable;
 	}
 
 	if (pci_request_regions(pdev, DRV_NAME)) {
-		printk(KERN_ERR DRV_NAME ": Failed to request PCI regions\n");
+		pr_err("Failed to request PCI regions\n");
 		err = -ENODEV;
 		goto err_out_disable;
 	}
@@ -382,9 +391,9 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	if (err)
 		goto err_out_res;
 
-	printk(KERN_INFO "%s: ULi M%04lx at pci%s, %pM, irq %d.\n",
-	       dev->name,ent->driver_data >> 16,pci_name(pdev),
-	       dev->dev_addr, dev->irq);
+	dev_info(&dev->dev, "ULi M%04lx at pci%s, %pM, irq %d\n",
+		 ent->driver_data >> 16, pci_name(pdev),
+		 dev->dev_addr, dev->irq);
 
 	pci_set_master(pdev);
 
@@ -516,7 +525,7 @@ static void uli526x_init(struct net_device *dev)
 		}
 	}
 	if(phy_tmp == 32)
-		printk(KERN_WARNING "Can not find the phy address!!!");
+		pr_warning("Can not find the phy address!!!");
 	/* Parser SROM and media mode */
 	db->media_mode = uli526x_media_mode;
 
@@ -582,7 +591,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 
 	/* Too large packet check */
 	if (skb->len > MAX_PACKET_SIZE) {
-		printk(KERN_ERR DRV_NAME ": big packet = %d\n", (u16)skb->len);
+		pr_err("big packet = %d\n", (u16)skb->len);
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
@@ -592,7 +601,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 	/* No Tx resource check, it never happen nromally */
 	if (db->tx_packet_cnt >= TX_FREE_DESC_CNT) {
 		spin_unlock_irqrestore(&db->lock, flags);
-		printk(KERN_ERR DRV_NAME ": No Tx resource %ld\n", db->tx_packet_cnt);
+		pr_err("No Tx resource %ld\n", db->tx_packet_cnt);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1058,7 +1067,7 @@ static void uli526x_timer(unsigned long data)
 		/* Link Failed */
 		ULI526X_DBUG(0, "Link Failed", tmp_cr12);
 		netif_carrier_off(dev);
-		printk(KERN_INFO "uli526x: %s NIC Link is Down\n",dev->name);
+		pr_info("%s NIC Link is Down\n",dev->name);
 		db->link_failed = 1;
 
 		/* For Force 10/100M Half/Full mode: Enable Auto-Nego mode */
@@ -1090,11 +1099,11 @@ static void uli526x_timer(unsigned long data)
 				}
 				if(db->op_mode==ULI526X_10MFD || db->op_mode==ULI526X_100MFD)
 				{
-					printk(KERN_INFO "uli526x: %s NIC Link is Up %d Mbps Full duplex\n",dev->name,TmpSpeed);
+					pr_info("%s NIC Link is Up %d Mbps Full duplex\n",dev->name,TmpSpeed);
 				}
 				else
 				{
-					printk(KERN_INFO "uli526x: %s NIC Link is Up %d Mbps Half duplex\n",dev->name,TmpSpeed);
+					pr_info("%s NIC Link is Up %d Mbps Half duplex\n",dev->name,TmpSpeed);
 				}
 				netif_carrier_on(dev);
 			}
@@ -1104,7 +1113,7 @@ static void uli526x_timer(unsigned long data)
 		{
 			if(db->init==1)
 			{
-				printk(KERN_INFO "uli526x: %s NIC Link is Down\n",dev->name);
+				pr_info("%s NIC Link is Down\n",dev->name);
 				netif_carrier_off(dev);
 			}
 		}
@@ -1230,8 +1239,7 @@ static int uli526x_resume(struct pci_dev *pdev)
 
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err) {
-		printk(KERN_WARNING "%s: Could not put device into D0\n",
-			dev->name);
+		dev_warn(&dev->dev, "Could not put device into D0\n");
 		return err;
 	}
 
@@ -1432,7 +1440,7 @@ static void send_filter_frame(struct net_device *dev, int mc_cnt)
 		update_cr6(db->cr6_data, dev->base_addr);
 		dev->trans_start = jiffies;
 	} else
-		printk(KERN_ERR DRV_NAME ": No Tx resource - Send_filter_frame!\n");
+		pr_err("No Tx resource - Send_filter_frame!\n");
 }
 
 
-- 
1.6.6.rc0.57.gad7a

