From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT] convert syskonnect gigabit ether driver to PCI module
 interface
Date: Tue, 22 Jun 2004 16:11:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622161130.0adaac78@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Tue__22_Jun_2004_16_11_30_-0700_8uIkj/kgIxNhFzbe"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mirko Lindner <mlinder@syskonnect.de>,
        Ralph Roesler
 <rroesler@syskonnect.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Tue__22_Jun_2004_16_11_30_-0700_8uIkj/kgIxNhFzbe
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

This patch converts the SysKonnect Gigabit Ethernet (Yukon) driver from
the old pci_find_class infrastructure, to the current 2.4/2.6 pci_module probing
model.  The device identification is no longer done in the macro, but in a pci_device_id
table like other drivers.

I don't have any hardware to test it on, but it builds on 2.6; could someone please
validate that it correctly finds and initializes all the ports on the card.


--Multipart=_Tue__22_Jun_2004_16_11_30_-0700_8uIkj/kgIxNhFzbe
Content-Type: text/plain;
 name="skge-pci-ids.patch"
Content-Disposition: attachment;
 filename="skge-pci-ids.patch"
Content-Transfer-Encoding: quoted-printable

diff -Nru a/include/linux/pci_ids.h b/include/linux/pci_ids.h
--- a/include/linux/pci_ids.h	2004-06-22 10:08:12 -07:00
+++ b/include/linux/pci_ids.h	2004-06-22 10:08:12 -07:00
@@ -967,12 +967,14 @@
=20
 #define PCI_VENDOR_ID_3COM		0x10b7
 #define PCI_DEVICE_ID_3COM_3C985	0x0001
+#define PCI_DEVICE_ID_3COM_3C940	0x1700
 #define PCI_DEVICE_ID_3COM_3C339	0x3390
 #define PCI_DEVICE_ID_3COM_3C359	0x3590
 #define PCI_DEVICE_ID_3COM_3C590	0x5900
 #define PCI_DEVICE_ID_3COM_3C595TX	0x5950
 #define PCI_DEVICE_ID_3COM_3C595T4	0x5951
 #define PCI_DEVICE_ID_3COM_3C595MII	0x5952
+#define PCI_DEVICE_ID_3COM_3C940B	0x80eb
 #define PCI_DEVICE_ID_3COM_3C900TPO	0x9000
 #define PCI_DEVICE_ID_3COM_3C900COMBO	0x9001
 #define PCI_DEVICE_ID_3COM_3C905TX	0x9050
@@ -1420,6 +1422,9 @@
 #define PCI_DEVICE_ID_RICOH_RL5C476	0x0476
 #define PCI_DEVICE_ID_RICOH_RL5C478	0x0478
=20
+#define PCI_VENDOR_ID_DLINK		0x1186
+#define PCI_DEVICE_ID_DLINK_DGE510T	0x4c00
+
 #define PCI_VENDOR_ID_ARTOP		0x1191
 #define PCI_DEVICE_ID_ARTOP_ATP8400	0x0004
 #define PCI_DEVICE_ID_ARTOP_ATP850UF	0x0005
@@ -1735,6 +1740,9 @@
 #define PCI_VENDOR_ID_KAWASAKI		0x136b
 #define PCI_DEVICE_ID_MCHIP_KL5A72002	0xff01
=20
+#define PCI_VENDOR_ID_CNET		0x1371
+#define PCI_DEVICE_ID_CNET_GIGACARD	0x434e
+
 #define PCI_VENDOR_ID_LMC		0x1376
 #define PCI_DEVICE_ID_LMC_HSSI		0x0003
 #define PCI_DEVICE_ID_LMC_DS3		0x0004
@@ -1918,6 +1926,10 @@
 #define PCI_DEVICE_ID_FARSITE_T4U       0x0640
 #define PCI_DEVICE_ID_FARSITE_TE1       0x1610
 #define PCI_DEVICE_ID_FARSITE_TE1C      0x1612
+
+#define PCI_VENDOR_ID_LINKSYS		0x1737
+#define PCI_DEVICE_ID_LINKSYS_EG1032	0x1032
+#define PCI_DEVICE_ID_LINKSYS_EG1064	0x1064
=20
 #define PCI_VENDOR_ID_ALTIMA		0x173b
 #define PCI_DEVICE_ID_ALTIMA_AC1000	0x03e8

--Multipart=_Tue__22_Jun_2004_16_11_30_-0700_8uIkj/kgIxNhFzbe
Content-Type: application/octet-stream;
 name="skge-pci-init.patch"
Content-Disposition: attachment;
 filename="skge-pci-init.patch"
Content-Transfer-Encoding: quoted-printable

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/06/22 15:57:48-07:00 shemminger@zqx3.pdx.osdl.net=20
#   skge-2
#=20
# drivers/net/sk98lin/h/skdrv2nd.h
#   2004/06/22 15:56:10-07:00 shemminger@zqx3.pdx.osdl.net +1 -55
#   Import patch skge-2
#=20
# ChangeSet
#   2004/06/22 15:53:11-07:00 shemminger@zqx3.pdx.osdl.net=20
#   skge-pci
#=20
# drivers/net/sk98lin/skge.c
#   2004/06/22 11:12:17-07:00 shemminger@zqx3.pdx.osdl.net +270 -292
#   Import patch skge-pci
#=20
diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2=
nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-06-22 15:59:00 -07:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-06-22 15:59:00 -07:00
@@ -53,60 +53,6 @@
 #include "h/skrlmt.h"
 #include "h/skgedrv.h"
=20
-#define SK_PCI_ISCOMPLIANT(result, pdev) {     \
-    result =3D SK_FALSE; /* default */     \
-    /* 3Com (0x10b7) */     \
-    if (pdev->vendor =3D=3D 0x10b7) {     \
-        /* Gigabit Ethernet Adapter (0x1700) */     \
-        if ((pdev->device =3D=3D 0x1700) || \
-            (pdev->device =3D=3D 0x80eb)) { \
-            result =3D SK_TRUE;     \
-        }     \
-    /* SysKonnect (0x1148) */     \
-    } else if (pdev->vendor =3D=3D 0x1148) {     \
-        /* SK-98xx Gigabit Ethernet Server Adapter (0x4300) */     \
-        /* SK-98xx V2.0 Gigabit Ethernet Adapter (0x4320) */     \
-        if ((pdev->device =3D=3D 0x4300) || \
-            (pdev->device =3D=3D 0x4320)) { \
-            result =3D SK_TRUE;     \
-        }     \
-    /* D-Link (0x1186) */     \
-    } else if (pdev->vendor =3D=3D 0x1186) {     \
-        /* Gigabit Ethernet Adapter (0x4c00) */     \
-        if ((pdev->device =3D=3D 0x4c00)) { \
-            result =3D SK_TRUE;     \
-        }     \
-    /* Marvell (0x11ab) */     \
-    } else if (pdev->vendor =3D=3D 0x11ab) {     \
-        /* Gigabit Ethernet Adapter (0x4320) */     \
-        /* Gigabit Ethernet Adapter (0x4360) */     \
-        /* Gigabit Ethernet Adapter (0x4361) */     \
-        /* Belkin (0x5005) */     \
-        if ((pdev->device =3D=3D 0x4320) || \
-            (pdev->device =3D=3D 0x4360) || \
-            (pdev->device =3D=3D 0x4361) || \
-            (pdev->device =3D=3D 0x5005)) { \
-            result =3D SK_TRUE;     \
-        }     \
-    /* CNet (0x1371) */     \
-    } else if (pdev->vendor =3D=3D 0x1371) {     \
-        /* GigaCard Network Adapter (0x434e) */     \
-        if ((pdev->device =3D=3D 0x434e)) { \
-            result =3D SK_TRUE;     \
-        }     \
-    /* Linksys (0x1737) */     \
-    } else if (pdev->vendor =3D=3D 0x1737) {     \
-        /* Gigabit Network Adapter (0x1032) */     \
-        /* Gigabit Network Adapter (0x1064) */     \
-        if ((pdev->device =3D=3D 0x1032) || \
-            (pdev->device =3D=3D 0x1064)) { \
-            result =3D SK_TRUE;     \
-        }     \
-    } else {     \
-        result =3D SK_FALSE;     \
-    }     \
-}
-
=20
 extern SK_MBUF		*SkDrvAllocRlmtMbuf(SK_AC*, SK_IOC, unsigned);
 extern void		SkDrvFreeRlmtMbuf(SK_AC*, SK_IOC, SK_MBUF*);
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-06-22 15:59:00 -07:00
+++ b/drivers/net/sk98lin/skge.c	2004-06-22 15:59:00 -07:00
@@ -257,26 +257,40 @@
 /* global variables ******************************************************=
***/
 static const char *BootString =3D BOOT_STRING;
 struct SK_NET_DEVICE *SkGeRootDev =3D NULL;
-static int probed __initdata =3D 0;
 static SK_BOOL DoPrintInterfaceChange =3D SK_TRUE;
=20
 /* local variables *******************************************************=
***/
 static uintptr_t TxQueueAddr[SK_MAX_MACS][2] =3D {{0x680, 0x600},{0x780, 0=
x700}};
 static uintptr_t RxQueueAddr[SK_MAX_MACS] =3D {0x400, 0x480};
=20
-
-#ifdef CONFIG_PROC_FS
-static struct proc_dir_entry	*pSkRootDir;
-#endif
-
-
+#define SK_PCI_DEVICE(vend, dev) \
+	{ PCI_DEVICE(vend, dev), \
+	  .class =3D PCI_CLASS_NETWORK_ETHERNET << 8, \
+	 .class_mask =3D 0xffff00, }
+
+static struct pci_device_id skge_pci_table[] =3D {
+	SK_PCI_DEVICE(PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3C940),
+	SK_PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_GE),
+	SK_PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_YU),
+	SK_PCI_DEVICE(PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE510T),
+	SK_PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4320),
+/* Don't handle Yukon2 cards at the moment */
+/* 12-feb-2004 ---- mlindner@syskonnect.de */
+//	SK_PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361),
+	SK_PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x5005),	/* Belkin (0x5005) */=20
+	SK_PCI_DEVICE(PCI_VENDOR_ID_CNET, PCI_DEVICE_ID_CNET_GIGACARD),
+	SK_PCI_DEVICE(PCI_VENDOR_ID_LINKSYS, PCI_DEVICE_ID_LINKSYS_EG1032),
+	SK_PCI_DEVICE(PCI_VENDOR_ID_LINKSYS, PCI_DEVICE_ID_LINKSYS_EG1064),
+	{ 0 }
+};
+MODULE_DEVICE_TABLE(pci, skge_pci_table);
=20
 /*************************************************************************=
****
  *
- * 	skge_probe - find all SK-98xx adapters
+ * 	skge_init_one -- initialize one PCI board
  *
  * Description:
- *	This function scans the PCI bus for SK-98xx adapters. Resources for
+ *	This function initializes a SK-98xx adapter. Resources for
  *	each adapter are allocated and the adapter is brought into Init 1
  *	state.
  *
@@ -284,13 +298,12 @@
  *	0, if everything is ok
  *	!=3D0, on error
  */
-static int __init skge_probe (void)
+static int __devinit skge_init_one (struct pci_dev *pdev,
+				 const struct pci_device_id *ent)
 {
-	int			boards_found =3D 0;
-	int			vendor_flag =3D SK_FALSE;
+	static int		boards_found =3D 0;
 	SK_AC			*pAC;
 	DEV_NET			*pNet =3D NULL;
-	struct pci_dev	*pdev =3D NULL;
 	struct SK_NET_DEVICE *dev =3D NULL;
 	SK_BOOL DeviceFound =3D SK_FALSE;
 	SK_BOOL BootStringCount =3D SK_FALSE;
@@ -299,257 +312,230 @@
 	struct proc_dir_entry	*pProcFile;
 #endif
=20
-	if (probed)
-		return -ENODEV;
-	probed++;
-
-
-	while((pdev =3D pci_find_class(PCI_CLASS_NETWORK_ETHERNET << 8, pdev))) {
-
-                if (pci_enable_device(pdev)) {
-                        continue;
-                }
-		dev =3D NULL;
-		pNet =3D NULL;
-
-		/* Don't handle Yukon2 cards at the moment */
-		/* 12-feb-2004 ---- mlindner@syskonnect.de */
-		if (pdev->vendor =3D=3D 0x11ab) {
-			if ( (pdev->device =3D=3D 0x4360) || (pdev->device =3D=3D 0x4361) )
-				continue;
-		}
-
-		SK_PCI_ISCOMPLIANT(vendor_flag, pdev);
-		if (!vendor_flag)
-			continue;
-
-		/* Configure DMA attributes. */
-		if (pci_set_dma_mask(pdev, (u64) 0xffffffffffffffffULL) &&
-			pci_set_dma_mask(pdev, (u64) 0xffffffff))
-			continue;
-
-
-		if ((dev =3D alloc_etherdev(sizeof(DEV_NET))) =3D=3D NULL) {
-			printk(KERN_ERR "Unable to allocate etherdev "
-			       "structure!\n");
-			break;
-		}
-
-		pNet =3D dev->priv;
-		pNet->pAC =3D kmalloc(sizeof(SK_AC), GFP_KERNEL);
-		if (pNet->pAC =3D=3D NULL){
-			free_netdev(dev);
-			printk(KERN_ERR "Unable to allocate adapter "
-			       "structure!\n");
-			break;
-		}
+	retval =3D pci_enable_device(pdev);
+	if (retval)
+		goto err_out;
+
+	/* Configure DMA attributes. */
+	retval =3D pci_set_dma_mask(pdev, (u64) 0xffffffffffffffffULL);
+	if (retval)
+		retval =3D pci_set_dma_mask(pdev, (u64) 0xffffffff);
+=09
+	if (retval) {
+		printk(KERN_ERR "Can't setup pci DMA\n");
+		goto err_out;
+	}
+=09
+	if ((dev =3D alloc_etherdev(sizeof(DEV_NET) + sizeof(SK_AC))) =3D=3D NULL=
) {
+		printk(KERN_ERR "Unable to allocate etherdev "
+		       "structure!\n");
+		retval =3D -ENOMEM;
+		goto err_out;
+	}
=20
-		/* Print message */
-		if (!BootStringCount) {
-			/* set display flag to TRUE so that */
-			/* we only display this string ONCE */
-			BootStringCount =3D SK_TRUE;
-			printk("%s\n", BootString);
-		}
+	pNet =3D dev->priv;
+	pNet->pAC =3D kmalloc(sizeof(SK_AC), GFP_KERNEL);
+	if (pNet->pAC =3D=3D NULL){
+		printk(KERN_ERR "Unable to allocate adapter "
+		       "structure!\n");
+		goto free_dev_err;
+	}
=20
-		memset(pNet->pAC, 0, sizeof(SK_AC));
-		pAC =3D pNet->pAC;
-		pAC->PciDev =3D pdev;
-		pAC->PciDevId =3D pdev->device;
-		pAC->dev[0] =3D dev;
-		pAC->dev[1] =3D dev;
-		sprintf(pAC->Name, "SysKonnect SK-98xx");
-		pAC->CheckQueue =3D SK_FALSE;
-
-		pNet->Mtu =3D 1500;
-		pNet->Up =3D 0;
-		dev->irq =3D pdev->irq;
-		retval =3D SkGeInitPCI(pAC);
-		if (retval) {
-			printk("SKGE: PCI setup failed: %i\n", retval);
-			free_netdev(dev);
-			continue;
-		}
+	/* Print message */
+	if (!BootStringCount) {
+		/* set display flag to TRUE so that */
+		/* we only display this string ONCE */
+		BootStringCount =3D SK_TRUE;
+		printk("%s\n", BootString);
+	}
+=09
+	memset(pNet->pAC, 0, sizeof(SK_AC));
+	pAC =3D pNet->pAC;
+	pAC->PciDev =3D pdev;
+	pAC->PciDevId =3D pdev->device;
+	pAC->dev[0] =3D dev;
+	pAC->dev[1] =3D dev;
+	sprintf(pAC->Name, "SysKonnect SK-98xx");
+	pAC->CheckQueue =3D SK_FALSE;
+
+	pNet->Mtu =3D 1500;
+	pNet->Up =3D 0;
+	dev->irq =3D pdev->irq;
+	retval =3D SkGeInitPCI(pAC);
+	if (retval) {
+		printk("SKGE: PCI setup failed: %i\n", retval);
+		goto free_dev_err;
+	}
=20
-		SET_MODULE_OWNER(dev);
-		dev->open =3D		&SkGeOpen;
-		dev->stop =3D		&SkGeClose;
-		dev->hard_start_xmit =3D	&SkGeXmit;
-		dev->get_stats =3D	&SkGeStats;
-		dev->last_stats =3D	&SkGeStats;
-		dev->set_multicast_list =3D &SkGeSetRxMode;
-		dev->set_mac_address =3D	&SkGeSetMacAddr;
-		dev->do_ioctl =3D		&SkGeIoctl;
-		dev->change_mtu =3D	&SkGeChangeMtu;
-		dev->flags &=3D 		~IFF_RUNNING;
-		SET_NETDEV_DEV(dev, &pdev->dev);
+	SET_MODULE_OWNER(dev);
+	dev->open =3D		&SkGeOpen;
+	dev->stop =3D		&SkGeClose;
+	dev->hard_start_xmit =3D	&SkGeXmit;
+	dev->get_stats =3D	&SkGeStats;
+	dev->last_stats =3D	&SkGeStats;
+	dev->set_multicast_list =3D &SkGeSetRxMode;
+	dev->set_mac_address =3D	&SkGeSetMacAddr;
+	dev->do_ioctl =3D		&SkGeIoctl;
+	dev->change_mtu =3D	&SkGeChangeMtu;
+	dev->flags &=3D 		~IFF_RUNNING;
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	pci_set_drvdata(pdev, dev);
=20
 #ifdef SK_ZEROCOPY
 #ifdef USE_SK_TX_CHECKSUM
=20
-		if (pAC->ChipsetType) {
-			/* Use only if yukon hardware */
-			/* SK and ZEROCOPY - fly baby... */
-			dev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;
-		}
+	if (pAC->ChipsetType) {
+		/* Use only if yukon hardware */
+		/* SK and ZEROCOPY - fly baby... */
+		dev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;
+	}
 #endif
 #endif
=20
-		pAC->Index =3D boards_found;
+	pAC->Index =3D ++boards_found;
=20
-		if (SkGeBoardInit(dev, pAC)) {
-			free_netdev(dev);
-			continue;
-		}
+	if((retval =3D SkGeBoardInit(dev, pAC)) !=3D 0)
+		goto free_dev_err;
=20
-		/* Register net device */
-		if (register_netdev(dev)) {
-			printk(KERN_ERR "SKGE: Could not register device.\n");
-			FreeResources(dev);
-			free_netdev(dev);
-			continue;
-		}
+	/* Register net device */
+	if ((retval =3D register_netdev(dev)) !=3D 0) {
+		printk(KERN_ERR "SKGE: Could not register device.\n");
+		FreeResources(dev);
+		goto free_dev_err;
+	}
=20
-		/* Print adapter specific string from vpd */
-		ProductStr(pAC);
-		printk("%s: %s\n", dev->name, pAC->DeviceStr);
-
-		/* Print configuration settings */
-		printk("      PrefPort:%c  RlmtMode:%s\n",
-			'A' + pAC->Rlmt.Net[0].Port[pAC->Rlmt.Net[0].PrefPort]->PortNumber,
-			(pAC->RlmtMode=3D=3D0)  ? "Check Link State" :
-			((pAC->RlmtMode=3D=3D1) ? "Check Link State" :
-			((pAC->RlmtMode=3D=3D3) ? "Check Local Port" :
-			((pAC->RlmtMode=3D=3D7) ? "Check Segmentation" :
-			((pAC->RlmtMode=3D=3D17) ? "Dual Check Link State" :"Error")))));
+	/* Print adapter specific string from vpd */
+	ProductStr(pAC);
+	printk("%s: %s\n", dev->name, pAC->DeviceStr);
+
+	/* Print configuration settings */
+	printk("      PrefPort:%c  RlmtMode:%s\n",
+	       'A' + pAC->Rlmt.Net[0].Port[pAC->Rlmt.Net[0].PrefPort]->PortNumber,
+	       (pAC->RlmtMode=3D=3D0)  ? "Check Link State" :
+	       ((pAC->RlmtMode=3D=3D1) ? "Check Link State" :
+		((pAC->RlmtMode=3D=3D3) ? "Check Local Port" :
+		 ((pAC->RlmtMode=3D=3D7) ? "Check Segmentation" :
+		  ((pAC->RlmtMode=3D=3D17) ? "Dual Check Link State" :"Error")))));
=20
-		SkGeYellowLED(pAC, pAC->IoBase, 1);
+	SkGeYellowLED(pAC, pAC->IoBase, 1);
=20
=20
-		memcpy((caddr_t) &dev->dev_addr,
-			(caddr_t) &pAC->Addr.Net[0].CurrentMacAddress, 6);
+	memcpy((caddr_t) &dev->dev_addr,
+	       (caddr_t) &pAC->Addr.Net[0].CurrentMacAddress, 6);
=20
-		/* First adapter... Create proc and print message */
+	/* First adapter... Create proc and print message */
 #ifdef CONFIG_PROC_FS
-		if (!DeviceFound) {
-			DeviceFound =3D SK_TRUE;
-			SK_MEMCPY(&SK_Root_Dir_entry, BootString,
-				sizeof(SK_Root_Dir_entry) - 1);
-
-			/*Create proc (directory)*/
-			if(!pSkRootDir) {
-				pSkRootDir =3D proc_mkdir(SK_Root_Dir_entry, proc_net);
-				if (!pSkRootDir) {
-					printk(KERN_WARNING "%s: Unable to create /proc/net/%s",
-						dev->name, SK_Root_Dir_entry);
-				} else {
-					pSkRootDir->owner =3D THIS_MODULE;
-				}
+	if (!DeviceFound) {
+		DeviceFound =3D SK_TRUE;
+		SK_MEMCPY(&SK_Root_Dir_entry, BootString,
+			  sizeof(SK_Root_Dir_entry) - 1);
+
+		/*Create proc (directory)*/
+		if(!pSkRootDir) {
+			pSkRootDir =3D proc_mkdir(SK_Root_Dir_entry, proc_net);
+			if (!pSkRootDir) {
+				printk(KERN_WARNING "%s: Unable to create /proc/net/%s",
+				       dev->name, SK_Root_Dir_entry);
+			} else {
+				pSkRootDir->owner =3D THIS_MODULE;
 			}
 		}
+	}
=20
-		/* Create proc file */
-		if (pSkRootDir &&=20
-			(pProcFile =3D create_proc_entry(dev->name, S_IRUGO,
-				pSkRootDir))) {
-			pProcFile->proc_fops =3D &sk_proc_fops;
-			pProcFile->data      =3D dev;
-		}
+	/* Create proc file */
+	if (pSkRootDir &&=20
+	    (pProcFile =3D create_proc_entry(dev->name, S_IRUGO,
+					   pSkRootDir))) {
+		pProcFile->proc_fops =3D &sk_proc_fops;
+		pProcFile->data      =3D dev;
+	}
=20
 #endif
=20
-		pNet->PortNr =3D 0;
-		pNet->NetNr  =3D 0;
+	pNet->PortNr =3D 0;
+	pNet->NetNr  =3D 0;
=20
-		boards_found++;
+	boards_found++;
=20
-		/* More then one port found */
-		if ((pAC->GIni.GIMacsFound =3D=3D 2 ) && (pAC->RlmtNets =3D=3D 2)) {
-			if ((dev =3D alloc_etherdev(sizeof(DEV_NET))) =3D=3D 0) {
-				printk(KERN_ERR "Unable to allocate etherdev "
-					"structure!\n");
-				break;
-			}
+	/* More then one port found */
+	if ((pAC->GIni.GIMacsFound =3D=3D 2 ) && (pAC->RlmtNets =3D=3D 2)) {
+		if ((dev =3D alloc_etherdev(sizeof(DEV_NET))) =3D=3D 0) {
+			printk(KERN_ERR "Unable to allocate etherdev second"
+			       "structure!\n");
+			goto skip;
+		}
=20
-			pAC->dev[1]   =3D dev;
-			pNet          =3D dev->priv;
-			pNet->PortNr  =3D 1;
-			pNet->NetNr   =3D 1;
-			pNet->pAC     =3D pAC;
-			pNet->Mtu     =3D 1500;
-			pNet->Up      =3D 0;
-
-			dev->open               =3D &SkGeOpen;
-			dev->stop               =3D &SkGeClose;
-			dev->hard_start_xmit    =3D &SkGeXmit;
-			dev->get_stats          =3D &SkGeStats;
-			dev->last_stats         =3D &SkGeStats;
-			dev->set_multicast_list =3D &SkGeSetRxMode;
-			dev->set_mac_address    =3D &SkGeSetMacAddr;
-			dev->do_ioctl           =3D &SkGeIoctl;
-			dev->change_mtu         =3D &SkGeChangeMtu;
-			dev->flags             &=3D ~IFF_RUNNING;
+		pAC->dev[1]   =3D dev;
+		pNet          =3D dev->priv;
+		pNet->PortNr  =3D 1;
+		pNet->NetNr   =3D 1;
+		pNet->pAC     =3D pAC;
+		pNet->Mtu     =3D 1500;
+		pNet->Up      =3D 0;
+
+		dev->open               =3D &SkGeOpen;
+		dev->stop               =3D &SkGeClose;
+		dev->hard_start_xmit    =3D &SkGeXmit;
+		dev->get_stats          =3D &SkGeStats;
+		dev->last_stats         =3D &SkGeStats;
+		dev->set_multicast_list =3D &SkGeSetRxMode;
+		dev->set_mac_address    =3D &SkGeSetMacAddr;
+		dev->do_ioctl           =3D &SkGeIoctl;
+		dev->change_mtu         =3D &SkGeChangeMtu;
+		dev->flags             &=3D ~IFF_RUNNING;
=20
 #ifdef SK_ZEROCOPY
 #ifdef USE_SK_TX_CHECKSUM
-			if (pAC->ChipsetType) {
-				/* SG and ZEROCOPY - fly baby... */
-				dev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;
-			}
+		if (pAC->ChipsetType) {
+			/* SG and ZEROCOPY - fly baby... */
+			dev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;
+		}
 #endif
 #endif
=20
-			if (register_netdev(dev)) {
-				printk(KERN_ERR "SKGE: Could not register device.\n");
-				free_netdev(dev);
-				pAC->dev[1] =3D pAC->dev[0];
-			} else {
+		if (register_netdev(dev)) {
+			printk(KERN_ERR "SKGE: Could not register device.\n");
+			free_netdev(dev);
+			pAC->dev[1] =3D pAC->dev[0];
+		} else {
 #ifdef CONFIG_PROC_FS
-				if (pSkRootDir=20
-				    && (pProcFile =3D create_proc_entry(dev->name,=20
-								S_IRUGO, pSkRootDir))) {
-					pProcFile->proc_fops =3D &sk_proc_fops;
-					pProcFile->data      =3D dev;
-				}
+			if (pSkRootDir=20
+			    && (pProcFile =3D create_proc_entry(dev->name,=20
+							      S_IRUGO, pSkRootDir))) {
+				pProcFile->proc_fops =3D &sk_proc_fops;
+				pProcFile->data      =3D dev;
+			}
 #endif
=20
 			memcpy((caddr_t) &dev->dev_addr,
-			(caddr_t) &pAC->Addr.Net[1].CurrentMacAddress, 6);
+			       (caddr_t) &pAC->Addr.Net[1].CurrentMacAddress, 6);
 =09
 			printk("%s: %s\n", dev->name, pAC->DeviceStr);
 			printk("      PrefPort:B  RlmtMode:Dual Check Link State\n");
-			}
 		}
-
-		/* Save the hardware revision */
-		pAC->HWRevision =3D (((pAC->GIni.GIPciHwRev >> 4) & 0x0F)*10) +
-			(pAC->GIni.GIPciHwRev & 0x0F);
-
-		/* Set driver globals */
-		pAC->Pnmi.pDriverFileName    =3D DRIVER_FILE_NAME;
-		pAC->Pnmi.pDriverReleaseDate =3D DRIVER_REL_DATE;
-
-		SK_MEMSET(&(pAC->PnmiBackup), 0, sizeof(SK_PNMI_STRUCT_DATA));
-		SK_MEMCPY(&(pAC->PnmiBackup), &(pAC->PnmiStruct),=20
-				sizeof(SK_PNMI_STRUCT_DATA));
-
-		/*
-		 * This is bollocks, but we need to tell the net-init
-		 * code that it shall go for the next device.
-		 */
-#ifndef MODULE
-		dev->base_addr =3D 0;
-#endif
 	}
=20
-	/*
-	 * If we're at this point we're going through skge_probe() for
-	 * the first time.  Return success (0) if we've initialized 1
-	 * or more boards. Otherwise, return failure (-ENODEV).
-	 */
+ skip:
+	/* Save the hardware revision */
+	pAC->HWRevision =3D (((pAC->GIni.GIPciHwRev >> 4) & 0x0F)*10) +
+		(pAC->GIni.GIPciHwRev & 0x0F);
+
+	/* Set driver globals */
+	pAC->Pnmi.pDriverFileName    =3D DRIVER_FILE_NAME;
+	pAC->Pnmi.pDriverReleaseDate =3D DRIVER_REL_DATE;
+
+	SK_MEMSET(&(pAC->PnmiBackup), 0, sizeof(SK_PNMI_STRUCT_DATA));
+	SK_MEMCPY(&(pAC->PnmiBackup), &(pAC->PnmiStruct),=20
+		  sizeof(SK_PNMI_STRUCT_DATA));
+
+	return 0;
=20
-	return boards_found;
-} /* skge_probe */
+ free_dev_err:
+	pci_set_drvdata(pdev, NULL);
+	free_netdev(dev);
+ err_out:
+	return retval;
+}
=20
=20
 /*************************************************************************=
****
@@ -755,9 +741,6 @@
 static char *RlmtMode[SK_MAX_CARD_PARAM] =3D {"", };
 #endif
=20
-static int debug =3D 0; /* not used */
-static int options[SK_MAX_CARD_PARAM] =3D {0, }; /* not used */
-
 static int   IntsPerSec[SK_MAX_CARD_PARAM];
 static char *Moderation[SK_MAX_CARD_PARAM];
 static char *ModerationMask[SK_MAX_CARD_PARAM];
@@ -765,12 +748,72 @@
 static char *Stats[SK_MAX_CARD_PARAM];
=20
=20
+static void __devexit skge_remove_one(struct pci_dev *pdev)
+{
+	struct SK_NET_DEVICE *dev =3D pci_get_drvdata(pdev);
+	DEV_NET		*pNet =3D dev->priv;
+	SK_AC		*pAC =3D pNet->pAC;
+	unsigned long Flags;
+	SK_EVPARA EvPara;
+
+	netif_stop_queue(SkGeRootDev);
+	SkGeYellowLED(pAC, pAC->IoBase, 0);
+
+	if(pAC->BoardLevel =3D=3D SK_INIT_RUN) {
+		/* board is still alive */
+		spin_lock_irqsave(&pAC->SlowPathLock, Flags);
+		EvPara.Para32[0] =3D 0;
+		EvPara.Para32[1] =3D -1;
+		SkEventQueue(pAC, SKGE_RLMT, SK_RLMT_STOP, EvPara);
+		EvPara.Para32[0] =3D 1;
+		EvPara.Para32[1] =3D -1;
+		SkEventQueue(pAC, SKGE_RLMT, SK_RLMT_STOP, EvPara);
+		SkEventDispatcher(pAC, pAC->IoBase);
+		/* disable interrupts */
+		SK_OUT32(pAC->IoBase, B0_IMSK, 0);
+		SkGeDeInit(pAC, pAC->IoBase);
+		spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
+		pAC->BoardLevel =3D SK_INIT_DATA;
+		/* We do NOT check here, if IRQ was pending, of course*/
+	}
+
+	if(pAC->BoardLevel =3D=3D SK_INIT_IO) {
+		/* board is still alive */
+		SkGeDeInit(pAC, pAC->IoBase);
+		pAC->BoardLevel =3D SK_INIT_DATA;
+	}
+
+	if ((pAC->GIni.GIMacsFound =3D=3D 2) && pAC->RlmtNets =3D=3D 2){
+		unregister_netdev(pAC->dev[1]);
+		free_netdev(pAC->dev[1]);
+	}
+
+	FreeResources(SkGeRootDev);
+
+	SkGeRootDev->get_stats =3D NULL;
+	/*
+	 * otherwise unregister_netdev calls get_stats with
+	 * invalid IO ...  :-(
+	 */
+	unregister_netdev(SkGeRootDev);
+	free_netdev(SkGeRootDev);
+	kfree(pAC);
+} /* skge_remove */
+
+static struct pci_driver skge_driver =3D {
+	.name	=3D "skge",
+	.id_table =3D skge_pci_table,
+	.probe	=3D skge_init_one,
+	.remove =3D __devexit_p(skge_remove_one),
+};
+
+
 /*************************************************************************=
****
  *
  * 	skge_init_module - module initialization function
  *
  * Description:
- *	Very simple, only call skge_probe and return approriate result.
+ *	Very simple, call pci registation
  *
  * Returns:
  *	0, if everything is ok
@@ -778,18 +821,7 @@
  */
 static int __init skge_init_module(void)
 {
-	int cards;
-	SkGeRootDev =3D NULL;
-=09
-	/* just to avoid warnings ... */
-	debug =3D 0;
-	options[0] =3D 0;
-
-	cards =3D skge_probe();
-	if (cards =3D=3D 0) {
-		printk("sk98lin: No adapter found.\n");
-	}
-	return cards ? 0 : -ENODEV;
+	return pci_module_init(&skge_driver);
 } /* skge_init_module */
=20
=20
@@ -805,68 +837,14 @@
  */
 static void __exit skge_cleanup_module(void)
 {
-DEV_NET		*pNet;
-SK_AC		*pAC;
-struct SK_NET_DEVICE *next;
-unsigned long Flags;
-SK_EVPARA EvPara;
-
-	while (SkGeRootDev) {
-		pNet =3D (DEV_NET*) SkGeRootDev->priv;
-		pAC =3D pNet->pAC;
-		next =3D pAC->Next;
-
-		netif_stop_queue(SkGeRootDev);
-		SkGeYellowLED(pAC, pAC->IoBase, 0);
-
-		if(pAC->BoardLevel =3D=3D SK_INIT_RUN) {
-			/* board is still alive */
-			spin_lock_irqsave(&pAC->SlowPathLock, Flags);
-			EvPara.Para32[0] =3D 0;
-			EvPara.Para32[1] =3D -1;
-			SkEventQueue(pAC, SKGE_RLMT, SK_RLMT_STOP, EvPara);
-			EvPara.Para32[0] =3D 1;
-			EvPara.Para32[1] =3D -1;
-			SkEventQueue(pAC, SKGE_RLMT, SK_RLMT_STOP, EvPara);
-			SkEventDispatcher(pAC, pAC->IoBase);
-			/* disable interrupts */
-			SK_OUT32(pAC->IoBase, B0_IMSK, 0);
-			SkGeDeInit(pAC, pAC->IoBase);
-			spin_unlock_irqrestore(&pAC->SlowPathLock, Flags);
-			pAC->BoardLevel =3D SK_INIT_DATA;
-			/* We do NOT check here, if IRQ was pending, of course*/
-		}
-
-		if(pAC->BoardLevel =3D=3D SK_INIT_IO) {
-			/* board is still alive */
-			SkGeDeInit(pAC, pAC->IoBase);
-			pAC->BoardLevel =3D SK_INIT_DATA;
-		}
-
-		if ((pAC->GIni.GIMacsFound =3D=3D 2) && pAC->RlmtNets =3D=3D 2){
-			unregister_netdev(pAC->dev[1]);
-			free_netdev(pAC->dev[1]);
-		}
-
-		FreeResources(SkGeRootDev);
-
-		SkGeRootDev->get_stats =3D NULL;
-		/*
-		 * otherwise unregister_netdev calls get_stats with
-		 * invalid IO ...  :-(
-		 */
-		unregister_netdev(SkGeRootDev);
-		free_netdev(SkGeRootDev);
-		kfree(pAC);
-		SkGeRootDev =3D next;
-	}
+	pci_unregister_driver(&skge_driver);
=20
 #ifdef CONFIG_PROC_FS
 	/* clear proc-dir */
 	remove_proc_entry(pSkRootDir->name, proc_net);
 #endif
=20
-} /* skge_cleanup_module */
+}
=20
 module_init(skge_init_module);
 module_exit(skge_cleanup_module);

--Multipart=_Tue__22_Jun_2004_16_11_30_-0700_8uIkj/kgIxNhFzbe--
