From: dhananjay@netxen.com
Subject: [PATCH 1/1] netxen: Load firmware during probe, dma watchdog fix.
Date: Thu, 19 Jul 2007 14:41:09 +0530
Message-ID: <20070719091131.467737478@netxen.com>
References: <20070719091108.839200259@netxen.com>
Cc: rob@netxen.com, Milan Bag <mbag@netxen.com>,
	Wen Xiong <wenxiong@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.199.144.227] ([203.199.144.227]:1943 "EHLO
	stellar.unminc.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764117AbXGSJQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 05:16:52 -0400
Content-Disposition: inline; filename=dma.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The firmware should be loaded after resetting hardware during PCI probe,
besides module unload. This fixes issue with 2nd port of multiport adapter
on powerpc blades. This patch also fixes a bug that PCI resources are not
freed if dma watchdog shutdown failed. The dma watchdog poll messages
during module unload are also suppressed.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
Signed-off-by: Milan Bag <mbag@netxen.com>
Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>

Index: netdev-2.6/drivers/net/netxen/netxen_nic_main.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_main.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c
@@ -46,7 +46,7 @@ MODULE_DESCRIPTION("NetXen Multi port (1
 MODULE_LICENSE("GPL");
 MODULE_VERSION(NETXEN_NIC_LINUX_VERSIONID);
 
-char netxen_nic_driver_name[] = "netxen-nic";
+char netxen_nic_driver_name[] = "netxen_nic";
 static char netxen_nic_driver_string[] = "NetXen Network Driver version "
     NETXEN_NIC_LINUX_VERSIONID;
 
@@ -643,6 +643,10 @@ netxen_nic_probe(struct pci_dev *pdev, c
 			NETXEN_CRB_NORMALIZE(adapter,
 				NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
 		/* Handshake with the card before we register the devices. */
+		writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+		netxen_pinit_from_rom(adapter, 0);
+		msleep(1);
+		netxen_load_firmware(adapter);
 		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	}
 
@@ -785,19 +789,18 @@ static void __devexit netxen_nic_remove(
 
 	if (adapter->portnum == 0) {
 		if (init_firmware_done) {
-			dma_watchdog_shutdown_request(adapter);
-			msleep(100);
 			i = 100;
-			while ((dma_watchdog_shutdown_poll_result(adapter) != 1) && i) {
-				printk(KERN_INFO "dma_watchdog_shutdown_poll still in progress\n");
+			do {
+				if (dma_watchdog_shutdown_request(adapter) == 1)
+					break;
 				msleep(100);
-				i--;
-			}
-
-			if (i == 0) {
-				printk(KERN_ERR "dma_watchdog_shutdown_request failed\n");
-				return;
-			}
+				if (dma_watchdog_shutdown_poll_result(adapter) == 1)
+					break;
+			} while (--i);
+
+			if (i == 0)
+				printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
+						netdev->name);
 
 			/* clear the register for future unloads/loads */
 			writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
@@ -806,11 +809,9 @@ static void __devexit netxen_nic_remove(
 
 			/* leave the hw in the same state as reboot */
 			writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
-			if (netxen_pinit_from_rom(adapter, 0))
-				return;
+			netxen_pinit_from_rom(adapter, 0);
 			msleep(1);
-			if (netxen_load_firmware(adapter))
-				return;
+			netxen_load_firmware(adapter);
 			netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 		}
 
@@ -819,22 +820,21 @@ static void __devexit netxen_nic_remove(
 		printk(KERN_INFO "State: 0x%0x\n",
 			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
 
-		dma_watchdog_shutdown_request(adapter);
-		msleep(100);
 		i = 100;
-		while ((dma_watchdog_shutdown_poll_result(adapter) != 1) && i) {
-			printk(KERN_INFO "dma_watchdog_shutdown_poll still in progress\n");
+		do {
+			if (dma_watchdog_shutdown_request(adapter) == 1)
+				break;
 			msleep(100);
-			i--;
-		}
+			if (dma_watchdog_shutdown_poll_result(adapter) == 1)
+				break;
+		} while (--i);
 
 		if (i) {
 			netxen_free_adapter_offload(adapter);
 		} else {
-			printk(KERN_ERR "failed to dma shutdown\n");
-			return;
+			printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
+					netdev->name);
 		}
-
 	}
 
 	iounmap(adapter->ahw.db_base);
Index: netdev-2.6/drivers/net/netxen/netxen_nic.h
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic.h
+++ netdev-2.6/drivers/net/netxen/netxen_nic.h
@@ -1179,8 +1179,7 @@ dma_watchdog_shutdown_poll_result(struct
 	    NETXEN_CAM_RAM(NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL), &ctrl, 4))
 		printk(KERN_ERR "failed to read dma watchdog status\n");
 
-	return ((netxen_get_dma_watchdog_enabled(ctrl) == 0) &&
-		(netxen_get_dma_watchdog_disabled(ctrl) == 0));
+	return (netxen_get_dma_watchdog_enabled(ctrl) == 0);
 }
 
 static inline int

-- 
