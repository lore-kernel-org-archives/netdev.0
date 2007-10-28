From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.24 1/1]S2io: Fixed memory leak by freeing MSI-X local
 entry memories when vector allocation fails
Date: Sun, 28 Oct 2007 04:05:32 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10710280403250.29009-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:38767 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbXJ1ISQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 04:18:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Fixed memory leak by freeing MSI-X local entry memories when vector allocation
fails in s2io_add_isr.
- Added two utility functions do_rem_msix_isr and do_rem_inta_isr to eliminate
code duplication.

Signed-off-by: Veena Parat <veena.parat@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
---
diff -Nurp 2-0-26-6/drivers/net/s2io.c 2-0-26-7/drivers/net/s2io.c
--- 2-0-26-6/drivers/net/s2io.c	2007-10-24 09:20:39.000000000 -0700
+++ 2-0-26-7/drivers/net/s2io.c	2007-10-24 09:46:16.000000000 -0700
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.6"
+#define DRV_VERSION "2.0.26.7"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -3775,6 +3775,46 @@ static int __devinit s2io_test_msi(struc
 
 	return err;
 }
+
+static void do_rem_msix_isr(struct s2io_nic * sp)
+{
+	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
+	int i;
+	u16 msi_control;
+
+	for (i=1; (sp->s2io_entries[i].in_use ==
+		MSIX_REGISTERED_SUCCESS); i++) {
+		int vector = sp->entries[i].vector;
+		void *arg = sp->s2io_entries[i].arg;
+
+		synchronize_irq(vector);
+		free_irq(vector, arg);
+	}
+
+	kfree(sp->entries);
+	stats->mem_freed +=
+		(MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+	kfree(sp->s2io_entries);
+	stats->mem_freed +=
+		(MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
+	sp->entries = NULL;
+	sp->s2io_entries = NULL;
+
+	pci_read_config_word(sp->pdev, 0x42, &msi_control);
+	msi_control &= 0xFFFE; /* Disable MSI */
+	pci_write_config_word(sp->pdev, 0x42, msi_control);
+
+	pci_disable_msix(sp->pdev);
+}
+
+static void do_rem_inta_isr(struct s2io_nic * sp)
+{
+	struct net_device *dev = sp->dev;
+
+	synchronize_irq(sp->pdev->irq);
+	free_irq(sp->pdev->irq, dev);
+}
+
 /* ********************************************************* *
  * Functions defined below concern the OS part of the driver *
  * ********************************************************* */
@@ -3809,28 +3849,11 @@ static int s2io_open(struct net_device *
 		int ret = s2io_enable_msi_x(sp);
 
 		if (!ret) {
-			u16 msi_control;
 
 			ret = s2io_test_msi(sp);
 
 			/* rollback MSI-X, will re-enable during add_isr() */
-			kfree(sp->entries);
-			sp->mac_control.stats_info->sw_stat.mem_freed +=
-				(MAX_REQUESTED_MSI_X *
-				sizeof(struct msix_entry));
-			kfree(sp->s2io_entries);
-			sp->mac_control.stats_info->sw_stat.mem_freed +=
-				(MAX_REQUESTED_MSI_X *
-				sizeof(struct s2io_msix_entry));
-			sp->entries = NULL;
-			sp->s2io_entries = NULL;
-
-			pci_read_config_word(sp->pdev, 0x42, &msi_control);
-			msi_control &= 0xFFFE; /* Disable MSI */
-			pci_write_config_word(sp->pdev, 0x42, msi_control);
-
-			pci_disable_msix(sp->pdev);
-
+			do_rem_msix_isr(sp);
 		}
 		if (ret) {
 
@@ -6864,15 +6887,22 @@ static int s2io_add_isr(struct s2io_nic 
 				}
 			}
 			if (err) {
+				do_rem_msix_isr(sp);
+
 				DBG_PRINT(ERR_DBG,"%s:MSI-X-%d registration "
 					  "failed\n", dev->name, i);
-				DBG_PRINT(ERR_DBG, "Returned: %d\n", err);
-				return -1;
+
+				DBG_PRINT(ERR_DBG, "%s: Defaulting to INTA\n",
+					dev->name);
+				sp->config.intr_type = INTA;
+				break;
 			}
 			sp->s2io_entries[i].in_use = MSIX_REGISTERED_SUCCESS;
 		}
-		printk("MSI-X-TX %d entries enabled\n",msix_tx_cnt);
-		printk("MSI-X-RX %d entries enabled\n",msix_rx_cnt);
+		if(!err) {
+			printk("MSI-X-TX %d entries enabled\n",msix_tx_cnt);
+			printk("MSI-X-RX %d entries enabled\n",msix_rx_cnt);
+		}
 	}
 	if (sp->config.intr_type == INTA) {
 		err = request_irq((int) sp->pdev->irq, s2io_isr, IRQF_SHARED,
@@ -6887,40 +6917,10 @@ static int s2io_add_isr(struct s2io_nic 
 }
 static void s2io_rem_isr(struct s2io_nic * sp)
 {
-	struct net_device *dev = sp->dev;
-	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
-
-	if (sp->config.intr_type == MSI_X) {
-		int i;
-		u16 msi_control;
-
-		for (i=1; (sp->s2io_entries[i].in_use ==
-			MSIX_REGISTERED_SUCCESS); i++) {
-			int vector = sp->entries[i].vector;
-			void *arg = sp->s2io_entries[i].arg;
-
-			synchronize_irq(vector);
-			free_irq(vector, arg);
-		}
-
-		kfree(sp->entries);
-		stats->mem_freed +=
-			(MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
-		kfree(sp->s2io_entries);
-		stats->mem_freed +=
-			(MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
-		sp->entries = NULL;
-		sp->s2io_entries = NULL;
-
-		pci_read_config_word(sp->pdev, 0x42, &msi_control);
-		msi_control &= 0xFFFE; /* Disable MSI */
-		pci_write_config_word(sp->pdev, 0x42, msi_control);
-
-		pci_disable_msix(sp->pdev);
-	} else {
-		synchronize_irq(sp->pdev->irq);
-		free_irq(sp->pdev->irq, dev);
-	}
+	if (sp->config.intr_type == MSI_X)
+		do_rem_msix_isr(sp);
+	else
+		do_rem_inta_isr(sp);
 }
 
 static void do_s2io_card_down(struct s2io_nic * sp, int do_io)

