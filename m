From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (17/23) sk98: use lockless transmit
Date: Thu, 11 Nov 2004 16:03:29 -0800
Message-ID: <20041111160329.6d3092f6@zqx3.pdx.osdl.net>
References: <4192C60A.1050205@designassembly.de>
	<20041111154225.5cf85567@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner
 <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041111154225.5cf85567@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This driver lends it self to the new lockless transmit hook in 2.6.
Also, flag that driver can do 64 bit DMA, if it is successful in
setting the bigger mask.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-03 18:57:15 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-03 18:57:15 -08:00
@@ -323,6 +323,7 @@
 	DEV_NET			*pNet = NULL;
 	struct net_device	*dev = NULL;
 	static int boards_found = 0;
+	int pci_using_dac  = 0;
 	int error = -ENODEV;
 
 	error = pci_enable_device(pdev);
@@ -332,8 +333,9 @@
 	}
  
 	/* Configure DMA attributes. */
-	if ((error = pci_set_dma_mask(pdev, (u64) 0xffffffffffffffffULL)) ||
-	    (error = pci_set_dma_mask(pdev, (u64) 0xffffffff))) {
+	if (!(error = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) 
+		pci_using_dac = 1;
+	else if ((error = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
 		printk(KERN_ERR "sk98lin: cannot set PCI dma mask\n");
 		goto out_disable_device;
 	}
@@ -375,6 +377,8 @@
 	}
 
 	SkGeDevInit(dev, pdev);
+	if (pci_using_dac)
+		dev->features |= NETIF_F_HIGHDMA;
 
 	pAC->Index = boards_found++;
 
@@ -438,6 +442,9 @@
 
 		SkGeDevInit(dev, pdev);
 
+		if (pci_using_dac)
+			dev->features |= NETIF_F_HIGHDMA;
+
 #ifdef SK_ZEROCOPY
 #ifdef USE_SK_TX_CHECKSUM
 		if (pAC->ChipsetType)
@@ -447,7 +454,6 @@
 #endif
 #endif
 
-
 		if (register_netdev(dev)) {
 			printk(KERN_ERR "SKGE: Could not register device.\n");
 			free_netdev(dev);
@@ -501,9 +507,10 @@
 #endif
 	SET_ETHTOOL_OPS(dev, &SkGeEthtoolOps);
 	SET_NETDEV_DEV(dev, &pdev->dev);
-}
-
 
+	dev->flags &= ~IFF_RUNNING;
+	dev->features |= NETIF_F_LLTX;
+}
 /*****************************************************************************
  *
  * 	SkGeInitPCI - Init the PCI resources
@@ -1707,7 +1714,13 @@
 	else
 		pTxPort = &pAC->TxPort[pAC->ActivePort][TX_PRIO_LOW];
 
-	spin_lock_irqsave(&pTxPort->TxDesRingLock, flags);
+ 	local_irq_save(flags); 
+ 	if (!spin_trylock(&pTxPort->TxDesRingLock)) {
+ 		/* Collision - tell upper layer to requeue */ 
+ 		local_irq_restore(flags); 
+ 		return NETDEV_TX_LOCKED; 
+ 	} 
+
 	if ((!skb_shinfo(skb)->nr_frags) ||
 		(pAC->GIni.GIChipId == CHIP_ID_GENESIS)) {
 		/* Don't activate scatter-gather and hardware checksum */
