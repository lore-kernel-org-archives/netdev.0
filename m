From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (18/25) sk98: lockless transmit
Date: Mon, 15 Nov 2004 15:46:46 -0800
Message-ID: <20041115154646.5697055a@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sk transmit path has it's own locking so doesn't need locking in
device queueing layer. Move net device initiailzation that was done 
twice (once for each port), to a common place.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 14:00:29 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 14:00:29 -08:00
@@ -1349,6 +1349,7 @@
  * Returns:
  *	0 (NETDEV_TX_OK) 	if everything is ok
  *	1 (NETDEV_TX_BUSY) 	if ring is full
+ * 	-1(NETDEV_TX_LOCKED)	lock collision
  */
 int SkGeXmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -1363,7 +1364,12 @@
 	else
 		pTxPort = &pAC->TxPort[pAC->ActivePort][TX_PRIO_LOW];
  
-	spin_lock_irqsave(&pTxPort->TxDesRingLock, flags);
+ 	local_irq_save(flags); 
+ 	if (!spin_trylock(&pTxPort->TxDesRingLock)) {
+ 		/* Collision - tell upper layer to requeue */ 
+ 		local_irq_restore(flags); 
+ 		return NETDEV_TX_LOCKED; 
+ 	} 
 
 	if ((!skb_shinfo(skb)->nr_frags) ||
 	    (pAC->GIni.GIChipId == CHIP_ID_GENESIS)) 
@@ -4746,6 +4752,42 @@
 
 #endif
 
+static void __devinit SkGeNetDevInit(struct net_device *dev, 
+				     struct pci_dev *pdev, 
+				     const SK_AC *pAC)
+{
+	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	SET_ETHTOOL_OPS(dev, &SkGeEthtoolOps);
+
+	dev->open =		SkGeOpen;
+	dev->stop =		SkGeClose;
+	dev->hard_start_xmit =	SkGeXmit;
+	dev->get_stats =	SkGeStats;
+	dev->set_multicast_list = SkGeSetRxMode;
+	dev->set_mac_address =	SkGeSetMacAddr;
+	dev->do_ioctl =		SkGeIoctl;
+	dev->change_mtu =	SkGeChangeMtu;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller =	SkGePollController;
+#endif
+	dev->flags &= 		~IFF_RUNNING;
+	dev->features |= NETIF_F_LLTX;
+
+	if (pdev->dma_mask == DMA_64BIT_MASK)
+		dev->features |= NETIF_F_HIGHDMA;
+
+	if (pAC->GIni.GIChipId != CHIP_ID_GENESIS) {
+#ifdef SK_ZEROCOPY
+		dev->features |= NETIF_F_SG;
+#endif
+#ifdef USE_SK_TX_CHECKSUM
+		dev->features |= NETIF_F_IP_CSUM;
+#endif
+	}
+}
+
+
 static int __devinit skge_probe_one(struct pci_dev *pdev,
 		const struct pci_device_id *ent)
 {
@@ -4792,38 +4834,14 @@
 	if (error) 
 		goto out_free_netdev;
 
-	SET_MODULE_OWNER(dev);
-	dev->open =		&SkGeOpen;
-	dev->stop =		&SkGeClose;
-	dev->hard_start_xmit =	&SkGeXmit;
-	dev->get_stats =	&SkGeStats;
-	dev->set_multicast_list = &SkGeSetRxMode;
-	dev->set_mac_address =	&SkGeSetMacAddr;
-	dev->do_ioctl =		&SkGeIoctl;
-	dev->change_mtu =	&SkGeChangeMtu;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller =	&SkGePollController;
-#endif
-	dev->flags &= 		~IFF_RUNNING;
-	SET_NETDEV_DEV(dev, &pdev->dev);
-	SET_ETHTOOL_OPS(dev, &SkGeEthtoolOps);
-
-#ifdef SK_ZEROCOPY
-#ifdef USE_SK_TX_CHECKSUM
-	if (pAC->ChipsetType) {
-		/* Use only if yukon hardware */
-		/* SK and ZEROCOPY - fly baby... */
-		dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
-	}
-#endif
-#endif
-
 	pAC->Index = boards_found++;
 
 	error = SkGeBoardInit(dev, pAC);
 	if (error)
 		goto out_free_netdev;
 
+	SkGeNetDevInit(dev, pdev, pAC);
+
 	/* Register net device */
 	strcpy(dev->name, "eth%d");
 	error = register_netdev(dev);
@@ -4866,26 +4884,7 @@
 		pNet->NetNr   = 1;
 		pNet->pAC     = pAC;
 
-		dev->open               = &SkGeOpen;
-		dev->stop               = &SkGeClose;
-		dev->hard_start_xmit    = &SkGeXmit;
-		dev->get_stats          = &SkGeStats;
-		dev->set_multicast_list = &SkGeSetRxMode;
-		dev->set_mac_address    = &SkGeSetMacAddr;
-		dev->do_ioctl           = &SkGeIoctl;
-		dev->change_mtu         = &SkGeChangeMtu;
-		dev->flags             &= ~IFF_RUNNING;
-		SET_NETDEV_DEV(dev, &pdev->dev);
-		SET_ETHTOOL_OPS(dev, &SkGeEthtoolOps);
-
-#ifdef SK_ZEROCOPY
-#ifdef USE_SK_TX_CHECKSUM
-		if (pAC->ChipsetType) {
-			/* SG and ZEROCOPY - fly baby... */
-			dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
-		}
-#endif
-#endif
+		SkGeNetDevInit(dev, pdev, pAC);
 
 		if (register_netdev(dev)) {
 			printk(KERN_WARNING "sk98lin: could not register device for second port.\n");
