From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 1/2] Blackfin EMAC Driver: code cleanup
Date: Fri, 25 Apr 2008 11:53:10 +0800
Message-ID: <1209095591-20920-2-git-send-email-cooloney@kernel.org>
References: <1209095591-20920-1-git-send-email-cooloney@kernel.org>
Cc: Bryan Wu <cooloney@kernel.org>
To: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:33643 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184AbYDYDxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 23:53:34 -0400
In-Reply-To: <1209095591-20920-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 - replace specific "bf537" function or data structure name to "bfin_mac"
 - cleanup bfin_mac_probe with error checking
 - punt set_pin_mux function, call peripheral request/free list functions directly

Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/bfin_mac.c |  249 ++++++++++++++++++++++++------------------------
 drivers/net/bfin_mac.h |    2 +-
 2 files changed, 124 insertions(+), 127 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 717dcc1..fdd361c 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -42,7 +42,7 @@
 #define DRV_NAME	"bfin_mac"
 #define DRV_VERSION	"1.1"
 #define DRV_AUTHOR	"Bryan Wu, Luke Yang"
-#define DRV_DESC	"Blackfin BF53[67] BF527 on-chip Ethernet MAC driver"
+#define DRV_DESC	"Blackfin on-chip Ethernet MAC driver"
 
 MODULE_AUTHOR(DRV_AUTHOR);
 MODULE_LICENSE("GPL");
@@ -72,8 +72,14 @@ static struct net_dma_desc_tx *current_tx_ptr;
 static struct net_dma_desc_tx *tx_desc;
 static struct net_dma_desc_rx *rx_desc;
 
-static void bf537mac_disable(void);
-static void bf537mac_enable(void);
+#if defined(CONFIG_BFIN_MAC_RMII)
+static u16 pin_req[] = P_RMII0;
+#else
+static u16 pin_req[] = P_MII0;
+#endif
+
+static void bfin_mac_disable(void);
+static void bfin_mac_enable(void);
 
 static void desc_list_free(void)
 {
@@ -242,27 +248,6 @@ init_error:
 
 /*---PHY CONTROL AND CONFIGURATION-----------------------------------------*/
 
-/* Set FER regs to MUX in Ethernet pins */
-static int setup_pin_mux(int action)
-{
-#if defined(CONFIG_BFIN_MAC_RMII)
-	u16 pin_req[] = P_RMII0;
-#else
-	u16 pin_req[] = P_MII0;
-#endif
-
-	if (action) {
-		if (peripheral_request_list(pin_req, DRV_NAME)) {
-			printk(KERN_ERR DRV_NAME
-			": Requesting Peripherals failed\n");
-			return -EFAULT;
-		}
-	} else
-		peripheral_free_list(pin_req);
-
-	return 0;
-}
-
 /*
  * MII operations
  */
@@ -321,9 +306,9 @@ static int mdiobus_reset(struct mii_bus *bus)
 	return 0;
 }
 
-static void bf537_adjust_link(struct net_device *dev)
+static void bfin_mac_adjust_link(struct net_device *dev)
 {
-	struct bf537mac_local *lp = netdev_priv(dev);
+	struct bfin_mac_local *lp = netdev_priv(dev);
 	struct phy_device *phydev = lp->phydev;
 	unsigned long flags;
 	int new_state = 0;
@@ -394,7 +379,7 @@ static void bf537_adjust_link(struct net_device *dev)
 
 static int mii_probe(struct net_device *dev)
 {
-	struct bf537mac_local *lp = netdev_priv(dev);
+	struct bfin_mac_local *lp = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
 	unsigned short sysctl;
 	int i;
@@ -430,10 +415,10 @@ static int mii_probe(struct net_device *dev)
 	}
 
 #if defined(CONFIG_BFIN_MAC_RMII)
-	phydev = phy_connect(dev, phydev->dev.bus_id, &bf537_adjust_link, 0,
+	phydev = phy_connect(dev, phydev->dev.bus_id, &bfin_mac_adjust_link, 0,
 			PHY_INTERFACE_MODE_RMII);
 #else
-	phydev = phy_connect(dev, phydev->dev.bus_id, &bf537_adjust_link, 0,
+	phydev = phy_connect(dev, phydev->dev.bus_id, &bfin_mac_adjust_link, 0,
 			PHY_INTERFACE_MODE_MII);
 #endif
 
@@ -510,7 +495,7 @@ static void setup_mac_addr(u8 *mac_addr)
 	bfin_write_EMAC_ADDRHI(addr_hi);
 }
 
-static int bf537mac_set_mac_address(struct net_device *dev, void *p)
+static int bfin_mac_set_mac_address(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 	if (netif_running(dev))
@@ -572,7 +557,7 @@ adjust_head:
 
 }
 
-static int bf537mac_hard_start_xmit(struct sk_buff *skb,
+static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
 	unsigned int data;
@@ -630,7 +615,7 @@ out:
 	return 0;
 }
 
-static void bf537mac_rx(struct net_device *dev)
+static void bfin_mac_rx(struct net_device *dev)
 {
 	struct sk_buff *skb, *new_skb;
 	unsigned short len;
@@ -679,7 +664,7 @@ out:
 }
 
 /* interrupt routine to handle rx and error signal */
-static irqreturn_t bf537mac_interrupt(int irq, void *dev_id)
+static irqreturn_t bfin_mac_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	int number = 0;
@@ -699,21 +684,21 @@ get_one_packet:
 	}
 
 real_rx:
-	bf537mac_rx(dev);
+	bfin_mac_rx(dev);
 	number++;
 	goto get_one_packet;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static void bf537mac_poll(struct net_device *dev)
+static void bfin_mac_poll(struct net_device *dev)
 {
 	disable_irq(IRQ_MAC_RX);
-	bf537mac_interrupt(IRQ_MAC_RX, dev);
+	bfin_mac_interrupt(IRQ_MAC_RX, dev);
 	enable_irq(IRQ_MAC_RX);
 }
 #endif				/* CONFIG_NET_POLL_CONTROLLER */
 
-static void bf537mac_disable(void)
+static void bfin_mac_disable(void)
 {
 	unsigned int opmode;
 
@@ -727,7 +712,7 @@ static void bf537mac_disable(void)
 /*
  * Enable Interrupts, Receive, and Transmit
  */
-static void bf537mac_enable(void)
+static void bfin_mac_enable(void)
 {
 	u32 opmode;
 
@@ -765,23 +750,23 @@ static void bf537mac_enable(void)
 }
 
 /* Our watchdog timed out. Called by the networking layer */
-static void bf537mac_timeout(struct net_device *dev)
+static void bfin_mac_timeout(struct net_device *dev)
 {
 	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
 
-	bf537mac_disable();
+	bfin_mac_disable();
 
 	/* reset tx queue */
 	tx_list_tail = tx_list_head->next;
 
-	bf537mac_enable();
+	bfin_mac_enable();
 
 	/* We can accept TX packets again */
 	dev->trans_start = jiffies;
 	netif_wake_queue(dev);
 }
 
-static void bf537mac_multicast_hash(struct net_device *dev)
+static void bfin_mac_multicast_hash(struct net_device *dev)
 {
 	u32 emac_hashhi, emac_hashlo;
 	struct dev_mc_list *dmi = dev->mc_list;
@@ -820,7 +805,7 @@ static void bf537mac_multicast_hash(struct net_device *dev)
  * promiscuous mode (for TCPDUMP and cousins) or accept
  * a select set of multicast packets
  */
-static void bf537mac_set_multicast_list(struct net_device *dev)
+static void bfin_mac_set_multicast_list(struct net_device *dev)
 {
 	u32 sysctl;
 
@@ -839,7 +824,7 @@ static void bf537mac_set_multicast_list(struct net_device *dev)
 		sysctl = bfin_read_EMAC_OPMODE();
 		sysctl |= HM;
 		bfin_write_EMAC_OPMODE(sysctl);
-		bf537mac_multicast_hash(dev);
+		bfin_mac_multicast_hash(dev);
 	} else {
 		/* clear promisc or multicast mode */
 		sysctl = bfin_read_EMAC_OPMODE();
@@ -851,7 +836,7 @@ static void bf537mac_set_multicast_list(struct net_device *dev)
 /*
  * this puts the device in an inactive state
  */
-static void bf537mac_shutdown(struct net_device *dev)
+static void bfin_mac_shutdown(struct net_device *dev)
 {
 	/* Turn off the EMAC */
 	bfin_write_EMAC_OPMODE(0x00000000);
@@ -865,9 +850,9 @@ static void bf537mac_shutdown(struct net_device *dev)
  *
  * Set up everything, reset the card, etc..
  */
-static int bf537mac_open(struct net_device *dev)
+static int bfin_mac_open(struct net_device *dev)
 {
-	struct bf537mac_local *lp = netdev_priv(dev);
+	struct bfin_mac_local *lp = netdev_priv(dev);
 	int retval;
 	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
 
@@ -890,8 +875,8 @@ static int bf537mac_open(struct net_device *dev)
 	phy_start(lp->phydev);
 	phy_write(lp->phydev, MII_BMCR, BMCR_RESET);
 	setup_system_regs(dev);
-	bf537mac_disable();
-	bf537mac_enable();
+	bfin_mac_disable();
+	bfin_mac_enable();
 	pr_debug("hardware init finished\n");
 	netif_start_queue(dev);
 	netif_carrier_on(dev);
@@ -905,9 +890,9 @@ static int bf537mac_open(struct net_device *dev)
  * and not talk to the outside world.   Caused by
  * an 'ifconfig ethX down'
  */
-static int bf537mac_close(struct net_device *dev)
+static int bfin_mac_close(struct net_device *dev)
 {
-	struct bf537mac_local *lp = netdev_priv(dev);
+	struct bfin_mac_local *lp = netdev_priv(dev);
 	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
 
 	netif_stop_queue(dev);
@@ -917,7 +902,7 @@ static int bf537mac_close(struct net_device *dev)
 	phy_write(lp->phydev, MII_BMCR, BMCR_PDOWN);
 
 	/* clear everything */
-	bf537mac_shutdown(dev);
+	bfin_mac_shutdown(dev);
 
 	/* free the rx/tx buffers */
 	desc_list_free();
@@ -925,46 +910,59 @@ static int bf537mac_close(struct net_device *dev)
 	return 0;
 }
 
-static int __init bf537mac_probe(struct net_device *dev)
+static int __init bfin_mac_probe(struct platform_device *pdev)
 {
-	struct bf537mac_local *lp = netdev_priv(dev);
-	int retval;
-	int i;
+	struct net_device *ndev;
+	struct bfin_mac_local *lp;
+	int rc, i;
+
+	ndev = alloc_etherdev(sizeof(struct bfin_mac_local));
+	if (!ndev) {
+		dev_err(&pdev->dev, "Cannot allocate net device!\n");
+		return -ENOMEM;
+	}
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+	platform_set_drvdata(pdev, ndev);
+	lp = netdev_priv(ndev);
 
 	/* Grab the MAC address in the MAC */
-	*(__le32 *) (&(dev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
-	*(__le16 *) (&(dev->dev_addr[4])) = cpu_to_le16((u16) bfin_read_EMAC_ADDRHI());
+	*(__le32 *) (&(ndev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
+	*(__le16 *) (&(ndev->dev_addr[4])) = cpu_to_le16((u16) bfin_read_EMAC_ADDRHI());
 
 	/* probe mac */
 	/*todo: how to proble? which is revision_register */
 	bfin_write_EMAC_ADDRLO(0x12345678);
 	if (bfin_read_EMAC_ADDRLO() != 0x12345678) {
-		pr_debug("can't detect bf537 mac!\n");
-		retval = -ENODEV;
-		goto err_out;
+		dev_err(&pdev->dev, "Cannot detect Blackfin on-chip ethernet MAC controller!\n");
+		rc = -ENODEV;
+		goto out_err_probe_mac;
 	}
 
 	/* set the GPIO pins to Ethernet mode */
-	retval = setup_pin_mux(1);
-	if (retval)
-		return retval;
-
-	/*Is it valid? (Did bootloader initialize it?) */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		/* Grab the MAC from the board somehow - this is done in the
-		   arch/blackfin/mach-bf537/boards/eth_mac.c */
-		bfin_get_ether_addr(dev->dev_addr);
+	rc = peripheral_request_list(pin_req, DRV_NAME);
+	if (rc) {
+		dev_err(&pdev->dev, "Requesting peripherals failed!\n");
+		rc = -EFAULT;
+		goto out_err_setup_pin_mux;
 	}
 
+	/*
+	 * Is it valid? (Did bootloader initialize it?)
+	 * Grab the MAC from the board somehow
+	 * this is done in the arch/blackfin/mach-bfxxx/boards/eth_mac.c
+	 */
+	if (!is_valid_ether_addr(ndev->dev_addr))
+		bfin_get_ether_addr(ndev->dev_addr);
+
 	/* If still not valid, get a random one */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		random_ether_addr(dev->dev_addr);
-	}
+	if (!is_valid_ether_addr(ndev->dev_addr))
+		random_ether_addr(ndev->dev_addr);
 
-	setup_mac_addr(dev->dev_addr);
+	setup_mac_addr(ndev->dev_addr);
 
 	/* MDIO bus initial */
-	lp->mii_bus.priv = dev;
+	lp->mii_bus.priv = ndev;
 	lp->mii_bus.read = mdiobus_read;
 	lp->mii_bus.write = mdiobus_write;
 	lp->mii_bus.reset = mdiobus_reset;
@@ -974,86 +972,85 @@ static int __init bf537mac_probe(struct net_device *dev)
 	for (i = 0; i < PHY_MAX_ADDR; ++i)
 		lp->mii_bus.irq[i] = PHY_POLL;
 
-	mdiobus_register(&lp->mii_bus);
+	rc = mdiobus_register(&lp->mii_bus);
+	if (rc) {
+		dev_err(&pdev->dev, "Cannot register MDIO bus!\n");
+		goto out_err_mdiobus_register;
+	}
 
-	retval = mii_probe(dev);
-	if (retval)
-		return retval;
+	rc = mii_probe(ndev);
+	if (rc) {
+		dev_err(&pdev->dev, "MII Probe failed!\n");
+		goto out_err_mii_probe;
+	}
 
 	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(dev);
-
-	dev->open = bf537mac_open;
-	dev->stop = bf537mac_close;
-	dev->hard_start_xmit = bf537mac_hard_start_xmit;
-	dev->set_mac_address = bf537mac_set_mac_address;
-	dev->tx_timeout = bf537mac_timeout;
-	dev->set_multicast_list = bf537mac_set_multicast_list;
+	ether_setup(ndev);
+
+	ndev->open = bfin_mac_open;
+	ndev->stop = bfin_mac_close;
+	ndev->hard_start_xmit = bfin_mac_hard_start_xmit;
+	ndev->set_mac_address = bfin_mac_set_mac_address;
+	ndev->tx_timeout = bfin_mac_timeout;
+	ndev->set_multicast_list = bfin_mac_set_multicast_list;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = bf537mac_poll;
+	ndev->poll_controller = bfin_mac_poll;
 #endif
 
 	spin_lock_init(&lp->lock);
 
 	/* now, enable interrupts */
 	/* register irq handler */
-	if (request_irq
-	    (IRQ_MAC_RX, bf537mac_interrupt, IRQF_DISABLED | IRQF_SHARED,
-	     "EMAC_RX", dev)) {
-		printk(KERN_WARNING DRV_NAME
-		       ": Unable to attach BlackFin MAC RX interrupt\n");
-		return -EBUSY;
+	rc = request_irq(IRQ_MAC_RX, bfin_mac_interrupt,
+			IRQF_DISABLED | IRQF_SHARED, "EMAC_RX", ndev);
+	if (rc) {
+		dev_err(&pdev->dev, "Cannot request Blackfin MAC RX IRQ!\n");
+		rc = -EBUSY;
+		goto out_err_request_irq;
 	}
 
-
-	retval = register_netdev(dev);
-	if (retval == 0) {
-		/* now, print out the card info, in a short format.. */
-		printk(KERN_INFO "%s: Version %s, %s\n",
-			 DRV_NAME, DRV_VERSION, DRV_DESC);
-	}
-
-err_out:
-	return retval;
-}
-
-static int bfin_mac_probe(struct platform_device *pdev)
-{
-	struct net_device *ndev;
-
-	ndev = alloc_etherdev(sizeof(struct bf537mac_local));
-	if (!ndev) {
-		printk(KERN_WARNING DRV_NAME ": could not allocate device\n");
-		return -ENOMEM;
+	rc = register_netdev(ndev);
+	if (rc) {
+		dev_err(&pdev->dev, "Cannot register net device!\n");
+		goto out_err_reg_ndev;
 	}
 
-	SET_NETDEV_DEV(ndev, &pdev->dev);
+	/* now, print out the card info, in a short format.. */
+	dev_info(&pdev->dev, "%s, Version %s\n", DRV_DESC, DRV_VERSION);
 
-	platform_set_drvdata(pdev, ndev);
+	return 0;
 
-	if (bf537mac_probe(ndev) != 0) {
-		platform_set_drvdata(pdev, NULL);
-		free_netdev(ndev);
-		printk(KERN_WARNING DRV_NAME ": not found\n");
-		return -ENODEV;
-	}
+out_err_reg_ndev:
+	free_irq(IRQ_MAC_RX, ndev);
+out_err_request_irq:
+out_err_mii_probe:
+	mdiobus_unregister(&lp->mii_bus);
+out_err_mdiobus_register:
+	peripheral_free_list(pin_req);
+out_err_setup_pin_mux:
+out_err_probe_mac:
+	platform_set_drvdata(pdev, NULL);
+	free_netdev(ndev);
 
-	return 0;
+	return rc;
 }
 
 static int bfin_mac_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct bfin_mac_local *lp = netdev_priv(ndev);
 
 	platform_set_drvdata(pdev, NULL);
 
+	mdiobus_unregister(&lp->mii_bus);
+
 	unregister_netdev(ndev);
 
 	free_irq(IRQ_MAC_RX, ndev);
 
 	free_netdev(ndev);
 
-	setup_pin_mux(0);
+	peripheral_free_list(pin_req);
 
 	return 0;
 }
@@ -1064,7 +1061,7 @@ static int bfin_mac_suspend(struct platform_device *pdev, pm_message_t mesg)
 	struct net_device *net_dev = platform_get_drvdata(pdev);
 
 	if (netif_running(net_dev))
-		bf537mac_close(net_dev);
+		bfin_mac_close(net_dev);
 
 	return 0;
 }
@@ -1074,7 +1071,7 @@ static int bfin_mac_resume(struct platform_device *pdev)
 	struct net_device *net_dev = platform_get_drvdata(pdev);
 
 	if (netif_running(net_dev))
-		bf537mac_open(net_dev);
+		bfin_mac_open(net_dev);
 
 	return 0;
 }
diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index f774d5a..beff510 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -49,7 +49,7 @@ struct net_dma_desc_tx {
 	struct status_area_tx status;
 };
 
-struct bf537mac_local {
+struct bfin_mac_local {
 	/*
 	 * these are things that the kernel wants me to keep, so users
 	 * can find out semi-useless statistics of how well the card is
-- 
1.5.5
