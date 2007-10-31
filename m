From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.24 1/1]S2io: Fixed memory leak by freeing MSI-X local
 entry memories when vector allocation fails
Date: Wed, 31 Oct 2007 04:10:19 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10710310408190.9897-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:48433 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302AbXJaIKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 04:10:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Fixed memory leak by freeing MSI-X local entry memories when vector allocation
fails in s2io_add_isr.
- Added two utility functions remove_msix_isr and remove_inta_isr to eliminate
code duplication.
- Implemented following review comments from Jeff
	- Removed redundant stats->mem_freed and synchronize_irq call
	- do_rem_msix_isr is renamed as remove_msix_isr
	- do_rem_inta_isr is renamed as remove_inta_isr

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp org/drivers/net/s2io.c patch1/drivers/net/s2io.c
--- org/drivers/net/s2io.c	2007-10-30 23:31:09.000000000 +0530
+++ patch1/drivers/net/s2io.c	2007-10-31 04:12:00.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.6"
+#define DRV_VERSION "2.0.26.7"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -3775,6 +3775,40 @@ static int __devinit s2io_test_msi(struc
 
 	return err;
 }
+
+static void remove_msix_isr(struct s2io_nic *sp)
+{
+	int i;
+	u16 msi_control;
+
+	for (i = 0; i < MAX_REQUESTED_MSI_X; i++) {
+		if (sp->s2io_entries[i].in_use ==
+			MSIX_REGISTERED_SUCCESS) {
+			int vector = sp->entries[i].vector;
+			void *arg = sp->s2io_entries[i].arg;
+			free_irq(vector, arg);
+		}
+	}
+
+	kfree(sp->entries);
+	kfree(sp->s2io_entries);
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
+static void remove_inta_isr(struct s2io_nic *sp)
+{
+	struct net_device *dev = sp->dev;
+
+	free_irq(sp->pdev->irq, dev);
+}
+
 /* ********************************************************* *
  * Functions defined below concern the OS part of the driver *
  * ********************************************************* */
@@ -3809,28 +3843,9 @@ static int s2io_open(struct net_device *
 		int ret = s2io_enable_msi_x(sp);
 
 		if (!ret) {
-			u16 msi_control;
-
 			ret = s2io_test_msi(sp);
-
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
+			remove_msix_isr(sp);
 		}
 		if (ret) {
 
@@ -6864,15 +6879,23 @@ static int s2io_add_isr(struct s2io_nic 
 				}
 			}
 			if (err) {
+				remove_msix_isr(sp);
+
 				DBG_PRINT(ERR_DBG,"%s:MSI-X-%d registration "
 					  "failed\n", dev->name, i);
-				DBG_PRINT(ERR_DBG, "Returned: %d\n", err);
-				return -1;
+				DBG_PRINT(ERR_DBG, "%s: defaulting to INTA\n",
+					dev->name);
+				sp->config.intr_type = INTA;
+				break;
 			}
 			sp->s2io_entries[i].in_use = MSIX_REGISTERED_SUCCESS;
 		}
-		printk("MSI-X-TX %d entries enabled\n",msix_tx_cnt);
-		printk("MSI-X-RX %d entries enabled\n",msix_rx_cnt);
+		if (!err) {
+			DBG_PRINT(INFO_DBG, "MSI-X-TX %d entries enabled\n",
+				msix_tx_cnt);
+			DBG_PRINT(INFO_DBG, "MSI-X-RX %d entries enabled\n",
+				msix_rx_cnt);
+		}
 	}
 	if (sp->config.intr_type == INTA) {
 		err = request_irq((int) sp->pdev->irq, s2io_isr, IRQF_SHARED,
@@ -6887,40 +6910,10 @@ static int s2io_add_isr(struct s2io_nic 
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
+		remove_msix_isr(sp);
+	else
+		remove_inta_isr(sp);
 }
 
 static void do_s2io_card_down(struct s2io_nic * sp, int do_io)


