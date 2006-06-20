From: Andrew Victor <andrew@sanpeople.com>
Subject: [PATCH 2.6.17] AT91RM9200 Ethernet #3: Cleanup
Date: 20 Jun 2006 12:10:57 +0200
Message-ID: <1150798257.15614.352.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sanpeople.com ([196.41.13.122]:41227 "EHLO
	za-gw.sanpeople.com") by vger.kernel.org with ESMTP
	id S1030218AbWFTKQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 06:16:10 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Moved global ether_clk variable into controller data structure.
Patch from David Brownell.

Davicom 9161 PHY was being incorrectly displayed as "9196".
Patch from Brian Stafford.

clk_get() doesn't return NULL on error, so the return value needs to be
tested with IS_ERR().

Whitespace cleanup.


Signed-off-by: Andrew Victor <andrew@sanpeople.com>


diff -urN linux-2.6.17-rmk.orig/drivers/net/arm/at91_ether.c linux-2.6.17-rmk/drivers/net/arm/at91_ether.c
--- linux-2.6.17-rmk.orig/drivers/net/arm/at91_ether.c	Tue Jun 20 11:08:36 2006
+++ linux-2.6.17-rmk/drivers/net/arm/at91_ether.c	Tue Jun 20 11:11:41 2006
@@ -43,7 +43,6 @@
 #define DRV_VERSION	"1.0"
 
 static struct net_device *at91_dev;
-static struct clk *ether_clk;
 
 static struct timer_list check_timer;
 #define LINK_POLL_INTERVAL	(HZ)
@@ -519,7 +518,7 @@
 		hash_index |= (bitval << j);
 	}
 
-        return hash_index;
+	return hash_index;
 }
 
 /*
@@ -575,10 +574,8 @@
 	at91_emac_write(AT91_EMAC_CFG, cfg);
 }
 
-
 /* ......................... ETHTOOL SUPPORT ........................... */
 
-
 static int mdio_read(struct net_device *dev, int phy_id, int location)
 {
 	unsigned int value;
@@ -719,10 +716,10 @@
 	struct at91_private *lp = (struct at91_private *) dev->priv;
 	unsigned long ctl;
 
-        if (!is_valid_ether_addr(dev->dev_addr))
-        	return -EADDRNOTAVAIL;
+	if (!is_valid_ether_addr(dev->dev_addr))
+		return -EADDRNOTAVAIL;
 
-	clk_enable(ether_clk);			/* Re-enable Peripheral clock */
+	clk_enable(lp->ether_clk);		/* Re-enable Peripheral clock */
 
 	/* Clear internal statistics */
 	ctl = at91_emac_read(AT91_EMAC_CTL);
@@ -756,6 +753,7 @@
  */
 static int at91ether_close(struct net_device *dev)
 {
+	struct at91_private *lp = (struct at91_private *) dev->priv;
 	unsigned long ctl;
 
 	/* Disable Receiver and Transmitter */
@@ -772,7 +770,7 @@
 
 	netif_stop_queue(dev);
 
-	clk_disable(ether_clk);			/* Disable Peripheral clock */
+	clk_disable(lp->ether_clk);		/* Disable Peripheral clock */
 
 	return 0;
 }
@@ -904,7 +902,7 @@
 	if (intstatus & AT91_EMAC_RCOM)		/* Receive complete */
 		at91ether_rx(dev);
 
-	if (intstatus & AT91_EMAC_TCOM) {		/* Transmit complete */
+	if (intstatus & AT91_EMAC_TCOM) {	/* Transmit complete */
 		/* The TCOM bit is set even if the transmission failed. */
 		if (intstatus & (AT91_EMAC_TUND | AT91_EMAC_RTRY))
 			lp->stats.tx_errors += 1;
@@ -933,7 +931,8 @@
 /*
  * Initialize the ethernet interface
  */
-static int __init at91ether_setup(unsigned long phy_type, unsigned short phy_address, struct platform_device *pdev)
+static int __init at91ether_setup(unsigned long phy_type, unsigned short phy_address,
+			struct platform_device *pdev, struct clk *ether_clk)
 {
 	struct at91_eth_data *board_data = pdev->dev.platform_data;
 	struct net_device *dev;
@@ -967,6 +966,7 @@
 		return -ENOMEM;
 	}
 	lp->board_data = *board_data;
+	lp->ether_clk = ether_clk;
 	platform_set_drvdata(pdev, dev);
 
 	spin_lock_init(&lp->lock);
@@ -1050,7 +1050,7 @@
 		dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
 		dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
 	if ((phy_type == MII_DM9161_ID) || (lp->phy_type == MII_DM9161A_ID))
-		printk(KERN_INFO "%s: Davicom 9196 PHY %s\n", dev->name, (lp->phy_media == PORT_FIBRE) ? "(Fiber)" : "(Copper)");
+		printk(KERN_INFO "%s: Davicom 9161 PHY %s\n", dev->name, (lp->phy_media == PORT_FIBRE) ? "(Fiber)" : "(Copper)");
 	else if (phy_type == MII_LXT971A_ID)
 		printk(KERN_INFO "%s: Intel LXT971A PHY\n", dev->name);
 	else if (phy_type == MII_RTL8201_ID)
@@ -1076,9 +1076,10 @@
 	int detected = -1;
 	unsigned long phy_id;
 	unsigned short phy_address = 0;
+	struct clk *ether_clk;
 
 	ether_clk = clk_get(&pdev->dev, "ether_clk");
-	if (!ether_clk) {
+	if (IS_ERR(ether_clk)) {
 		printk(KERN_ERR "at91_ether: no clock defined\n");
 		return -ENODEV;
 	}
@@ -1101,7 +1102,7 @@
 			case MII_DP83847_ID:		/* National Semiconductor DP83847:  */
 			case MII_AC101L_ID:		/* Altima AC101L: PHY_ID1 = 0x22, PHY_ID2 = 0x5520 */
 			case MII_KS8721_ID:		/* Micrel KS8721: PHY_ID1 = 0x22, PHY_ID2 = 0x1610 */
-				detected = at91ether_setup(phy_id, phy_address, pdev);
+				detected = at91ether_setup(phy_id, phy_address, pdev, ether_clk);
 				break;
 		}
 
@@ -1120,7 +1121,7 @@
 	unregister_netdev(at91_dev);
 	free_irq(at91_dev->irq, at91_dev);
 	dma_free_coherent(NULL, sizeof(struct recv_desc_bufs), lp->dlist, (dma_addr_t)lp->dlist_phys);
-	clk_put(ether_clk);
+	clk_put(lp->ether_clk);
 
 	free_netdev(at91_dev);
 	at91_dev = NULL;
diff -urN linux-2.6.17-rmk.orig/drivers/net/arm/at91_ether.h linux-2.6.17-rmk/drivers/net/arm/at91_ether.h
--- linux-2.6.17-rmk.orig/drivers/net/arm/at91_ether.h	Tue Jun 20 08:53:55 2006
+++ linux-2.6.17-rmk/drivers/net/arm/at91_ether.h	Tue Jun 20 11:10:45 2006
@@ -80,6 +80,7 @@
 	struct net_device_stats stats;
 	struct mii_if_info mii;			/* ethtool support */
 	struct at91_eth_data board_data;	/* board-specific configuration */
+	struct clk *ether_clk;			/* clock */
 
 	/* PHY */
 	unsigned long phy_type;			/* type of PHY (PHY_ID) */



