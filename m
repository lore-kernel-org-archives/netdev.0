From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (19/23) sk98: more cleanups
Date: Thu, 11 Nov 2004 16:07:20 -0800
Message-ID: <20041111160720.4ad4c51a@zqx3.pdx.osdl.net>
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

Make sure and set flags on both ports correctly.
Set address before register_netdev so if any protocols want
to pickup mac address they see correct value.
Fix memory leak on remove (my bad from patch 15).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-08 13:10:37 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-08 13:10:37 -08:00
@@ -184,7 +184,8 @@
 static void 	sk98lin_remove_device(struct pci_dev *pdev);
 static void	FreeResources(struct net_device *dev);
 static int	SkGeBoardInit(struct net_device *dev, SK_AC *pAC);
-static void	SkGeDevInit(struct net_device *dev, struct pci_dev *pdev);
+static void	SkGeDevInit(struct net_device *dev, struct pci_dev *pdev,
+			    const SK_AC *pAC);
 static SK_BOOL	BoardAllocMem(SK_AC *pAC);
 static void	BoardFreeMem(SK_AC *pAC);
 static void	BoardInitMem(SK_AC *pAC);
@@ -338,7 +339,6 @@
 	DEV_NET			*pNet = NULL;
 	struct net_device	*dev = NULL;
 	static int boards_found = 0;
-	int pci_using_dac  = 0;
 	int error = -ENODEV;
 
 	error = pci_enable_device(pdev);
@@ -348,9 +348,8 @@
 	}
  
 	/* Configure DMA attributes. */
-	if (!(error = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) 
-		pci_using_dac = 1;
-	else if ((error = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
+	if ((error = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
+	    (error = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
 		printk(KERN_ERR "sk98lin: cannot set PCI dma mask\n");
 		goto out_disable_device;
 	}
@@ -393,23 +392,12 @@
 		goto out_free_adapter;
 	}
 
-	SkGeDevInit(dev, pdev);
-	if (pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
-
 	pAC->Index = boards_found++;
 
 	if (SkGeBoardInit(dev, pAC))
-		goto out_free_adapter;
+		goto out_free_resources;
 
-#ifdef SK_ZEROCOPY
-#ifdef USE_SK_TX_CHECKSUM
-	if (pAC->ChipsetType)
-		/* Use only if yukon hardware */
-		/* SK and ZEROCOPY - fly baby... */
-		dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
-#endif
-#endif
+	SkGeDevInit(dev, pdev, pAC);
 
 	/* Register net device */
 	strcpy(dev->name, "eth%d");
@@ -419,6 +407,7 @@
 	}
 
 	SkGeProcCreate(dev);
+	memcpy(&dev->dev_addr, &pAC->Addr.Net[0].CurrentMacAddress, 6);
 
 	/* Print adapter specific string from vpd */
 	PrintProductStr(dev->name, pAC);
@@ -434,8 +423,6 @@
 
 	SkGeYellowLED(pAC, pAC->IoBase, 1);
 
-	memcpy(&dev->dev_addr, &pAC->Addr.Net[0].CurrentMacAddress, 6);
-
 	/* More then one port found */
 	if ((pAC->GIni.GIMacsFound == 2 ) && (pAC->RlmtNets == 2)) {
 		if ((dev = alloc_etherdev(sizeof(DEV_NET))) == 0) {
@@ -450,22 +437,9 @@
 		pNet->NetNr   = 1;
 		pNet->pAC     = pAC;
 		
-		memcpy(&dev->dev_addr,
-		       &pAC->Addr.Net[1].CurrentMacAddress, 6);
-
-		SkGeDevInit(dev, pdev);
+		memcpy(&dev->dev_addr, &pAC->Addr.Net[1].CurrentMacAddress, 6);
 
-		if (pci_using_dac)
-			dev->features |= NETIF_F_HIGHDMA;
-
-#ifdef SK_ZEROCOPY
-#ifdef USE_SK_TX_CHECKSUM
-		if (pAC->ChipsetType)
-			/* Use only if yukon hardware */
-			/* SK and ZEROCOPY - fly baby... */
-			dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
-#endif
-#endif
+		SkGeDevInit(dev, pdev, pAC);
 
 		if (register_netdev(dev)) {
 			printk(KERN_ERR "SKGE: Could not register device.\n");
@@ -504,7 +478,8 @@
 	return error;
 }
 
-static void SkGeDevInit(struct net_device *dev, struct pci_dev *pdev)
+static void SkGeDevInit(struct net_device *dev, struct pci_dev *pdev, 
+			const SK_AC *pAC)
 {
 	SET_MODULE_OWNER(dev);
 	dev->open =		&SkGeOpen;
@@ -523,6 +498,16 @@
 
 	dev->flags &= ~IFF_RUNNING;
 	dev->features |= NETIF_F_LLTX;
+
+	if (pdev->dma_mask == DMA_64BIT_MASK)
+		dev->features |= NETIF_F_HIGHDMA;
+
+	if (pAC->GIni.GIChipId != CHIP_ID_GENESIS) {
+		dev->features |= NETIF_F_SG;
+#ifdef USE_SK_TX_CHECKSUM
+		dev->features |= NETIF_F_IP_CSUM;
+#endif
+	}
 }
 /*****************************************************************************
  *
@@ -768,6 +753,7 @@
 	}
 
 	FreeResources(dev);
+	kfree(pAC);
 
 	if (dev1 != dev)
 		free_netdev(dev1);
