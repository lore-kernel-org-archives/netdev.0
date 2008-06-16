From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 4/4] netxen: download firmware in pci probe
Date: Sun, 15 Jun 2008 22:59:46 -0700
Message-ID: <1213595986-1929-5-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:32891 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752637AbYFPGiu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 02:38:50 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Downloading firmware in pci probe allows recovery in case of
firmware failure by reloading the driver.

Also reduced delays in firmware load.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_init.c |   24 ++++++++++--
 drivers/net/netxen/netxen_nic_main.c |   65 +++++----------------------------
 2 files changed, 30 insertions(+), 59 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index f6aeccf..70d1b22 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -840,10 +840,10 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 				netxen_nic_pci_change_crbwindow(adapter, 1);
 			}
 			if (init_delay == 1) {
-				msleep(2000);
+				msleep(1000);
 				init_delay = 0;
 			}
-			msleep(20);
+			msleep(1);
 		}
 		kfree(buf);
 
@@ -918,12 +918,28 @@ int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
 
 void netxen_free_adapter_offload(struct netxen_adapter *adapter)
 {
+	int i;
+
 	if (adapter->dummy_dma.addr) {
-		pci_free_consistent(adapter->ahw.pdev,
+		i = 100;
+		do {
+			if (dma_watchdog_shutdown_request(adapter) == 1)
+				break;
+			msleep(50);
+			if (dma_watchdog_shutdown_poll_result(adapter) == 1)
+				break;
+		} while (--i);
+
+		if (i) {
+			pci_free_consistent(adapter->ahw.pdev,
 				    NETXEN_HOST_DUMMY_DMA_SIZE,
 				    adapter->dummy_dma.addr,
 				    adapter->dummy_dma.phys_addr);
-		adapter->dummy_dma.addr = NULL;
+			adapter->dummy_dma.addr = NULL;
+		} else {
+			printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
+					adapter->netdev->name);
+		}
 	}
 }
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 755f4ab..6797ed0 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -543,14 +543,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		break;
 	}
 
-#ifdef CONFIG_IA64
-	if(adapter->portnum == 0) {
-		netxen_pinit_from_rom(adapter, 0);
-		udelay(500);
-		netxen_load_firmware(adapter);
-	}
-#endif
-
 	init_timer(&adapter->watchdog_timer);
 	adapter->ahw.xg_linkup = 0;
 	adapter->watchdog_timer.function = &netxen_watchdog;
@@ -622,11 +614,18 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 				err = -ENODEV;
 				goto err_out_free_dev;
 		    }
+		} else {
+			writel(0, NETXEN_CRB_NORMALIZE(adapter,
+						CRB_CMDPEG_STATE));
+			netxen_pinit_from_rom(adapter, 0);
+			msleep(1);
+			netxen_load_firmware(adapter);
+			netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 		}
 
 		/* clear the register for future unloads/loads */
 		writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
-		printk(KERN_DEBUG "State: 0x%0x\n",
+		dev_info(&pdev->dev, "cmdpeg state: 0x%0x\n",
 			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
 
 		/*
@@ -757,52 +756,8 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	vfree(adapter->cmd_buf_arr);
 
-	if (adapter->portnum == 0) {
-		if (init_firmware_done) {
-			i = 100;
-			do {
-				if (dma_watchdog_shutdown_request(adapter) == 1)
-					break;
-				msleep(100);
-				if (dma_watchdog_shutdown_poll_result(adapter) == 1)
-					break;
-			} while (--i);
-
-			if (i == 0)
-				printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
-						netdev->name);
-
-			/* clear the register for future unloads/loads */
-			writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
-			/* leave the hw in the same state as reboot */
-			writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
-			netxen_pinit_from_rom(adapter, 0);
-			msleep(1);
-			netxen_load_firmware(adapter);
-			netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
-		}
-
-		/* clear the register for future unloads/loads */
-		writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
-		printk(KERN_DEBUG "State: 0x%0x\n",
-			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
-
-		i = 100;
-		do {
-			if (dma_watchdog_shutdown_request(adapter) == 1)
-				break;
-			msleep(100);
-			if (dma_watchdog_shutdown_poll_result(adapter) == 1)
-				break;
-		} while (--i);
-
-		if (i) {
-			netxen_free_adapter_offload(adapter);
-		} else {
-			printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
-					netdev->name);
-		}
-	}
+	if (adapter->portnum == 0)
+		netxen_free_adapter_offload(adapter);
 
 	if (adapter->irq)
 		free_irq(adapter->irq, adapter);
-- 
1.5.4.3

