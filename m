From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (15/23) sk98: rearrange initialization
Date: Thu, 11 Nov 2004 16:01:13 -0800
Message-ID: <20041111160113.15a356cd@zqx3.pdx.osdl.net>
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

The code in the latest SysKonnect driver is arranged differently,
this aligns the two versions to allow for easier comparisons.
Also:
	Don't enable the pci device twice.
	Add common SkGeDevInit for common code used to setup both ports

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-05 16:54:01 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-05 16:54:01 -08:00
@@ -111,6 +111,7 @@
 #include	<linux/module.h>
 #include	<linux/moduleparam.h>
 #include	<linux/init.h>
+#include	<linux/ethtool.h>
 #include 	<linux/proc_fs.h>
 
 #include	"h/skdrv1st.h"
@@ -179,8 +180,11 @@
  *
  ******************************************************************************/
 
+static int 	sk98lin_init_device(struct pci_dev *pdev, const struct pci_device_id *ent);
+static void 	sk98lin_remove_device(struct pci_dev *pdev);
 static void	FreeResources(struct net_device *dev);
 static int	SkGeBoardInit(struct net_device *dev, SK_AC *pAC);
+static void	SkGeDevInit(struct net_device *dev, struct pci_dev *pdev);
 static SK_BOOL	BoardAllocMem(SK_AC *pAC);
 static void	BoardFreeMem(SK_AC *pAC);
 static void	BoardInitMem(SK_AC *pAC);
@@ -251,6 +255,7 @@
 extern void SkDimStartModerationTimer(SK_AC *pAC);
 extern void SkDimModerate(SK_AC *pAC);
 extern void SkGeBlinkTimer(unsigned long data);
+extern struct ethtool_ops SkGeEthtoolOps;
 
 #ifdef DEBUG
 static void	DumpMsg(struct sk_buff*, char*);
@@ -260,12 +265,237 @@
 
 /* global variables *********************************************************/
 static SK_BOOL DoPrintInterfaceChange = SK_TRUE;
-extern  struct ethtool_ops SkGeEthtoolOps;
+static const char *BootString = BOOT_STRING;
 
 /* local variables **********************************************************/
 static uintptr_t TxQueueAddr[SK_MAX_MACS][2] = {{0x680, 0x600},{0x780, 0x700}};
 static uintptr_t RxQueueAddr[SK_MAX_MACS] = {0x400, 0x480};
 
+
+static struct pci_device_id sk98lin_pci_tbl[] = {
+	{ PCI_VENDOR_ID_3COM, 0x1700, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VENDOR_ID_3COM, 0x80eb, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VENDOR_ID_SYSKONNECT, 0x4300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VENDOR_ID_SYSKONNECT, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VENDOR_ID_DLINK, 0x4c00, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VENDOR_ID_MARVELL, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+#if 0	/* don't handle Yukon2 cards at the moment -- mlindner@syskonnect.de */
+	{ PCI_VENDOR_ID_MARVELL, 0x4360, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VENDOR_ID_MARVELL, 0x4361, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+#endif
+	{ PCI_VENDOR_ID_MARVELL, 0x5005, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VENDOR_ID_CNET, 0x434e, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VENDOR_ID_LINKSYS, 0x1032, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VENDOR_ID_LINKSYS, 0x1064, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ 0, }
+};
+
+static struct pci_driver skge_driver = {
+	.name		= DRIVER_FILE_NAME,
+	.id_table	= sk98lin_pci_tbl,
+	.probe		= sk98lin_init_device,
+	.remove		= __devexit_p(sk98lin_remove_device),
+};
+
+/*****************************************************************************
+ *
+ * 	sk98lin_init_device - initialize the adapter
+ *
+ * Description:
+ *	This function initializes the adapter. Resources for
+ *	the adapter are allocated and the adapter is brought into Init 1
+ *	state.
+ *
+ * Returns:
+ *	0, if everything is ok
+ *	!=0, on error
+ */
+static int __devinit sk98lin_init_device(struct pci_dev *pdev,
+					 const struct pci_device_id *ent)
+{
+	SK_AC			*pAC;
+	DEV_NET			*pNet = NULL;
+	struct net_device	*dev = NULL;
+	static int boards_found = 0;
+	int error = -ENODEV;
+
+	error = pci_enable_device(pdev);
+	if (error) {
+		printk(KERN_ERR "sk98lin: cannot enable PCI device, aborting\n");
+		goto out;
+	}
+ 
+	/* Configure DMA attributes. */
+	if ((error = pci_set_dma_mask(pdev, (u64) 0xffffffffffffffffULL)) ||
+	    (error = pci_set_dma_mask(pdev, (u64) 0xffffffff))) {
+		printk(KERN_ERR "sk98lin: cannot set PCI dma mask\n");
+		goto out_disable_device;
+	}
+
+	/* Allocate both structures for first port, 
+	   and only one for second port. */
+	dev = alloc_etherdev(sizeof(DEV_NET));
+	if (!dev) {
+		printk(KERN_ERR "sk98lin: unable to allocate etherdev structure!\n");
+		error = -ENOMEM;
+		goto out_disable_device;
+	}
+
+	pNet = netdev_priv(dev);
+	pNet->pAC = kmalloc(sizeof(SK_AC), GFP_KERNEL);
+	if (pNet->pAC == NULL){
+		printk(KERN_ERR "sk98lin: unable to allocate adapter structure!\n");
+		error = -ENOMEM;
+		goto out_free_netdev;
+	}
+
+	if (BootString) {
+		printk("%s\n", BootString);
+		BootString = NULL;
+	}
+
+	memset(pNet->pAC, 0, sizeof(SK_AC));
+	pAC = pNet->pAC;
+	pAC->PciDev = pdev;
+	pAC->dev[0] = dev;
+	pAC->dev[1] = dev;
+	pAC->CheckQueue = SK_FALSE;
+
+	dev->irq = pdev->irq;
+
+	strcpy(dev->name, pci_name(pdev)); /* use PCI for early messages */
+	error = SkGeInitPCI(pAC);
+	if (error) {
+		printk("SKGE: PCI setup failed: %i\n", error);
+		goto out_free_adapter;
+	}
+
+	SkGeDevInit(dev, pdev);
+
+	pAC->Index = boards_found++;
+
+	if (SkGeBoardInit(dev, pAC))
+		goto out_free_adapter;
+
+#ifdef SK_ZEROCOPY
+#ifdef USE_SK_TX_CHECKSUM
+	if (pAC->ChipsetType)
+		/* Use only if yukon hardware */
+		/* SK and ZEROCOPY - fly baby... */
+		dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
+#endif
+#endif
+
+	/* Register net device */
+	strcpy(dev->name, "eth%d");
+	if (register_netdev(dev)) {
+		printk(KERN_ERR "SKGE: Could not register device.\n");
+		goto out_free_resources;
+	}
+
+	SkGeProcCreate(dev);
+
+	/* Print adapter specific string from vpd */
+	PrintProductStr(dev->name, pAC);
+
+	/* Print configuration settings */
+	printk("      PrefPort:%c  RlmtMode:%s\n",
+		'A' + pAC->Rlmt.Net[0].Port[pAC->Rlmt.Net[0].PrefPort]->PortNumber,
+		(pAC->RlmtMode==0)  ? "Check Link State" :
+		((pAC->RlmtMode==1) ? "Check Link State" :
+		((pAC->RlmtMode==3) ? "Check Local Port" :
+		((pAC->RlmtMode==7) ? "Check Segmentation" :
+		((pAC->RlmtMode==17) ? "Dual Check Link State" :"Error")))));
+
+	SkGeYellowLED(pAC, pAC->IoBase, 1);
+
+	memcpy(&dev->dev_addr, &pAC->Addr.Net[0].CurrentMacAddress, 6);
+
+	/* More then one port found */
+	if ((pAC->GIni.GIMacsFound == 2 ) && (pAC->RlmtNets == 2)) {
+		if ((dev = alloc_etherdev(sizeof(DEV_NET))) == 0) {
+			printk(KERN_ERR "Unable to allocate etherdev "
+				"structure!\n");
+			goto out;
+		}
+
+		pAC->dev[1]   = dev;
+		pNet          = netdev_priv(dev);
+		pNet->PortNr  = 1;
+		pNet->NetNr   = 1;
+		pNet->pAC     = pAC;
+		
+		memcpy(&dev->dev_addr,
+		       &pAC->Addr.Net[1].CurrentMacAddress, 6);
+
+		SkGeDevInit(dev, pdev);
+
+#ifdef SK_ZEROCOPY
+#ifdef USE_SK_TX_CHECKSUM
+		if (pAC->ChipsetType)
+			/* Use only if yukon hardware */
+			/* SK and ZEROCOPY - fly baby... */
+			dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
+#endif
+#endif
+
+
+		if (register_netdev(dev)) {
+			printk(KERN_ERR "SKGE: Could not register device.\n");
+			free_netdev(dev);
+			pAC->dev[1] = pAC->dev[0];
+		} else {
+			SkGeProcCreate(dev);
+			PrintProductStr(dev->name, pAC);
+			printk("      PrefPort:B  RlmtMode:Dual Check Link State\n");
+		}
+	}
+
+	/* Save the hardware revision */
+	pAC->HWRevision = (((pAC->GIni.GIPciHwRev >> 4) & 0x0F)*10) +
+		(pAC->GIni.GIPciHwRev & 0x0F);
+
+	/* Set driver globals */
+	pAC->Pnmi.pDriverFileName    = DRIVER_FILE_NAME;
+	pAC->Pnmi.pDriverReleaseDate = DRIVER_REL_DATE;
+
+	memset(&pAC->PnmiBackup, 0, sizeof(SK_PNMI_STRUCT_DATA));
+	memcpy(&pAC->PnmiBackup, &pAC->PnmiStruct, sizeof(SK_PNMI_STRUCT_DATA));
+
+	pci_set_drvdata(pdev, dev);
+	return 0;
+
+ out_free_resources:
+	FreeResources(dev);
+ out_free_adapter:
+	kfree(pAC);
+ out_free_netdev:
+	free_netdev(dev);
+ out_disable_device:
+	pci_disable_device(pdev);
+ out:
+	return error;
+}
+
+static void SkGeDevInit(struct net_device *dev, struct pci_dev *pdev)
+{
+	SET_MODULE_OWNER(dev);
+	dev->open =		&SkGeOpen;
+	dev->stop =		&SkGeClose;
+	dev->hard_start_xmit =	&SkGeXmit;
+	dev->get_stats =	&SkGeStats;
+	dev->set_multicast_list = &SkGeSetRxMode;
+	dev->set_mac_address =	&SkGeSetMacAddr;
+	dev->do_ioctl =		&SkGeIoctl;
+	dev->change_mtu =	&SkGeChangeMtu;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller =	&SkGePollController;
+#endif
+	SET_ETHTOOL_OPS(dev, &SkGeEthtoolOps);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+}
+
+
 /*****************************************************************************
  *
  * 	SkGeInitPCI - Init the PCI resources
@@ -276,16 +506,12 @@
  * Returns: N/A
  *	
  */
-int SkGeInitPCI(SK_AC *pAC)
+static int SkGeInitPCI(SK_AC *pAC)
 {
 	struct net_device *dev = pAC->dev[0];
 	struct pci_dev *pdev = pAC->PciDev;
 	int retval;
 
-	if (pci_enable_device(pdev) != 0) {
-		return 1;
-	}
-
 	dev->mem_start = pci_resource_start (pdev, 0);
 	pci_set_master(pdev);
 
@@ -326,7 +552,6 @@
 	return retval;
 }
 
-
 /*****************************************************************************
  *
  * 	FreeResources - release resources allocated for adapter
@@ -462,6 +687,69 @@
 
 /*****************************************************************************
  *
+ * 	sk98lin_remove_device - device deinit function
+ *
+ * Description:
+ *	Disable adapter if it is still running, free resources,
+ *	free device struct.
+ *
+ * Returns: N/A
+ */
+static void __devexit sk98lin_remove_device(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	DEV_NET *pNet = netdev_priv(dev);
+	SK_AC *pAC = pNet->pAC;
+	struct net_device *dev1 = pAC->dev[1];
+
+	if (dev1 != dev) {
+		unregister_netdev(dev1);
+		SkGeProcRemove(dev1);
+	}
+
+	SkGeProcRemove(dev);
+	unregister_netdev(dev);
+
+	SkGeYellowLED(pAC, pAC->IoBase, 0);
+
+	if (pAC->BoardLevel == SK_INIT_RUN) {
+		SK_EVPARA EvPara;
+		unsigned long Flags;
+
+		/* board is still alive */
+		spin_lock_irqsave(&pAC->SlowPathLock, Flags);
+		EvPara.Para32[0] = 0;
+		EvPara.Para32[1] = -1;
+		SkEventQueue(pAC, SKGE_RLMT, SK_RLMT_STOP, EvPara);
+		EvPara.Para32[0] = 1;
+		EvPara.Para32[1] = -1;
+		SkEventQueue(pAC, SKGE_RLMT, SK_RLMT_STOP, EvPara);
+		SkEventDispatcher(pAC, pAC->IoBase);
+		/* disable interrupts */
+		SK_OUT32(pAC->IoBase, B0_IMSK, 0);
+		SkGeDeInit(pAC, pAC->IoBase);
+		spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
+		pAC->BoardLevel = SK_INIT_DATA;
+		/* We do NOT check here, if IRQ was pending, of course*/
+	}
+
+	if (pAC->BoardLevel == SK_INIT_IO) {
+		/* board is still alive */
+		SkGeDeInit(pAC, pAC->IoBase);
+		pAC->BoardLevel = SK_INIT_DATA;
+	}
+
+	FreeResources(dev);
+
+	if (dev1 != dev)
+		free_netdev(dev1);
+	free_netdev(dev);
+	pci_disable_device(pdev);
+	pci_set_drvdata(pdev, NULL);
+}
+
+/*****************************************************************************
+ *
  * 	SkGeBoardInit - do level 0 and 1 initialization
  *
  * Description:
@@ -4821,253 +5109,6 @@
 
 #endif
 
-static int __devinit skge_probe_one(struct pci_dev *pdev,
-		const struct pci_device_id *ent)
-{
-	SK_AC			*pAC;
-	DEV_NET			*pNet = NULL;
-	struct net_device	*dev = NULL;
-	static int boards_found = 0;
-	int error = -ENODEV;
-
-	if (pci_enable_device(pdev))
-		goto out;
- 
-	/* Configure DMA attributes. */
-	if (pci_set_dma_mask(pdev, (u64) 0xffffffffffffffffULL) &&
-	    pci_set_dma_mask(pdev, (u64) 0xffffffff))
-		goto out_disable_device;
-
-
-	if ((dev = alloc_etherdev(sizeof(DEV_NET))) == NULL) {
-		printk(KERN_ERR "Unable to allocate etherdev "
-		       "structure!\n");
-		goto out_disable_device;
-	}
-
-	pNet = netdev_priv(dev);
-	pNet->pAC = kmalloc(sizeof(SK_AC), GFP_KERNEL);
-	if (!pNet->pAC) {
-		printk(KERN_ERR "Unable to allocate adapter "
-		       "structure!\n");
-		goto out_free_netdev;
-	}
-
-	memset(pNet->pAC, 0, sizeof(SK_AC));
-	pAC = pNet->pAC;
-	pAC->PciDev = pdev;
-	pAC->dev[0] = dev;
-	pAC->dev[1] = dev;
-	pAC->CheckQueue = SK_FALSE;
-
-	dev->irq = pdev->irq;
-	error = SkGeInitPCI(pAC);
-	if (error) {
-		printk("SKGE: PCI setup failed: %i\n", error);
-		goto out_free_netdev;
-	}
-
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
-	pAC->Index = boards_found++;
-
-	if (SkGeBoardInit(dev, pAC))
-		goto out_free_netdev;
-
-	/* Register net device */
-	if (register_netdev(dev)) {
-		printk(KERN_ERR "SKGE: Could not register device.\n");
-		goto out_free_resources;
-	}
-
-	/* Print adapter specific string from vpd */
-	PrintProductStr(dev->name, pAC);
-
-	/* Print configuration settings */
-	printk("      PrefPort:%c  RlmtMode:%s\n",
-		'A' + pAC->Rlmt.Net[0].Port[pAC->Rlmt.Net[0].PrefPort]->PortNumber,
-		(pAC->RlmtMode==0)  ? "Check Link State" :
-		((pAC->RlmtMode==1) ? "Check Link State" :
-		((pAC->RlmtMode==3) ? "Check Local Port" :
-		((pAC->RlmtMode==7) ? "Check Segmentation" :
-		((pAC->RlmtMode==17) ? "Dual Check Link State" :"Error")))));
-
-	SkGeYellowLED(pAC, pAC->IoBase, 1);
-
-
-	memcpy(&dev->dev_addr, &pAC->Addr.Net[0].CurrentMacAddress, 6);
-
-	SkGeProcCreate(dev);
-
-	/* More then one port found */
-	if ((pAC->GIni.GIMacsFound == 2 ) && (pAC->RlmtNets == 2)) {
-		if ((dev = alloc_etherdev(sizeof(DEV_NET))) == 0) {
-			printk(KERN_ERR "Unable to allocate etherdev "
-				"structure!\n");
-			goto out;
-		}
-
-		pAC->dev[1]   = dev;
-		pNet          = netdev_priv(dev);
-		pNet->PortNr  = 1;
-		pNet->NetNr   = 1;
-		pNet->pAC     = pAC;
-
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
-
-		if (register_netdev(dev)) {
-			printk(KERN_ERR "SKGE: Could not register device.\n");
-			free_netdev(dev);
-			pAC->dev[1] = pAC->dev[0];
-		} else {
-			SkGeProcCreate(dev);
-			memcpy(&dev->dev_addr,
-					&pAC->Addr.Net[1].CurrentMacAddress, 6);
-	
-			PrintProductStr(dev->name, pAC);
-			printk("      PrefPort:B  RlmtMode:Dual Check Link State\n");
-		}
-	}
-
-	/* Save the hardware revision */
-	pAC->HWRevision = (((pAC->GIni.GIPciHwRev >> 4) & 0x0F)*10) +
-		(pAC->GIni.GIPciHwRev & 0x0F);
-
-	/* Set driver globals */
-	pAC->Pnmi.pDriverFileName    = DRIVER_FILE_NAME;
-	pAC->Pnmi.pDriverReleaseDate = DRIVER_REL_DATE;
-
-	memset(&pAC->PnmiBackup, 0, sizeof(SK_PNMI_STRUCT_DATA));
-	memcpy(&pAC->PnmiBackup, &pAC->PnmiStruct, sizeof(SK_PNMI_STRUCT_DATA));
-
-	pci_set_drvdata(pdev, dev);
-	return 0;
-
- out_free_resources:
-	FreeResources(dev);
- out_free_netdev:
-	free_netdev(dev);
- out_disable_device:
-	pci_disable_device(pdev);
- out:
-	return error;
-}
-
-static void __devexit skge_remove_one(struct pci_dev *pdev)
-{
-	struct net_device *dev = pci_get_drvdata(pdev);
-	DEV_NET *pNet = netdev_priv(dev);
-	SK_AC *pAC = pNet->pAC;
-	struct net_device *otherdev = pAC->dev[1];
-
-	SkGeProcRemove(dev);
-	unregister_netdev(dev);
-	if (otherdev != dev)
-		SkGeProcRemove(otherdev);
-
-	SkGeYellowLED(pAC, pAC->IoBase, 0);
-
-	if (pAC->BoardLevel == SK_INIT_RUN) {
-		SK_EVPARA EvPara;
-		unsigned long Flags;
-
-		/* board is still alive */
-		spin_lock_irqsave(&pAC->SlowPathLock, Flags);
-		EvPara.Para32[0] = 0;
-		EvPara.Para32[1] = -1;
-		SkEventQueue(pAC, SKGE_RLMT, SK_RLMT_STOP, EvPara);
-		EvPara.Para32[0] = 1;
-		EvPara.Para32[1] = -1;
-		SkEventQueue(pAC, SKGE_RLMT, SK_RLMT_STOP, EvPara);
-		SkEventDispatcher(pAC, pAC->IoBase);
-		/* disable interrupts */
-		SK_OUT32(pAC->IoBase, B0_IMSK, 0);
-		SkGeDeInit(pAC, pAC->IoBase);
-		spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
-		pAC->BoardLevel = SK_INIT_DATA;
-		/* We do NOT check here, if IRQ was pending, of course*/
-	}
-
-	if (pAC->BoardLevel == SK_INIT_IO) {
-		/* board is still alive */
-		SkGeDeInit(pAC, pAC->IoBase);
-		pAC->BoardLevel = SK_INIT_DATA;
-	}
-
-	FreeResources(dev);
-	free_netdev(dev);
-	if (otherdev != dev)
-		free_netdev(otherdev);
-	kfree(pAC);
-}
-
-static struct pci_device_id skge_pci_tbl[] = {
-	{ PCI_VENDOR_ID_3COM, 0x1700, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_3COM, 0x80eb, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_SYSKONNECT, 0x4300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_SYSKONNECT, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_DLINK, 0x4c00, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_MARVELL, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-#if 0	/* don't handle Yukon2 cards at the moment -- mlindner@syskonnect.de */
-	{ PCI_VENDOR_ID_MARVELL, 0x4360, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_MARVELL, 0x4361, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-#endif
-	{ PCI_VENDOR_ID_MARVELL, 0x5005, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_CNET, 0x434e, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_LINKSYS, 0x1032, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ PCI_VENDOR_ID_LINKSYS, 0x1064, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ 0, }
-};
-
-static struct pci_driver skge_driver = {
-	.name		= "skge",
-	.id_table	= skge_pci_tbl,
-	.probe		= skge_probe_one,
-	.remove		= __devexit_p(skge_remove_one),
-};
 
 static int __init skge_init(void)
 {
