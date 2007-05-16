From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: Fix msi enable leak on error, don't print error message,
	cleanup
Date: Wed, 16 May 2007 01:49:46 -0700
Message-ID: <20070516084946.29078.55152.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	hpa@zytor.com, auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15970 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761474AbXEPPrC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 11:47:02 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_enable_msi failure is a normal event so we should not print any error.
Going over the code I spotted a missing pci_disable_msi() leak when irq
allocation fails. The whole code also needed a cleanup, so I combined the
two different calls to pci_request_irq into a single call making this
look a lot better. All #ifdef CONFIG_PCI_MSI's have been removed.

Compile tested with both CONFIG_PCI_MSI enabled and disabled.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: H. Peter Anvin <hpa@zytor.com>
---

 drivers/net/e1000/e1000.h      |    4 +---
 drivers/net/e1000/e1000_main.c |   39 ++++++++++++++-------------------------
 2 files changed, 15 insertions(+), 28 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index a9ea67e..16a6edf 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -333,11 +333,9 @@ struct e1000_adapter {
 	struct e1000_tx_ring test_tx_ring;
 	struct e1000_rx_ring test_rx_ring;
 
-
 	int msg_enable;
-#ifdef CONFIG_PCI_MSI
 	boolean_t have_msi;
-#endif
+
 	/* to not mess up cache alignment, always add to the bottom */
 	boolean_t tso_force;
 	boolean_t smart_power_down;	/* phy smart power down */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 637ae8f..49be393 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -158,9 +158,7 @@ static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t e1000_intr(int irq, void *data);
-#ifdef CONFIG_PCI_MSI
 static irqreturn_t e1000_intr_msi(int irq, void *data);
-#endif
 static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter,
                                     struct e1000_tx_ring *tx_ring);
 #ifdef CONFIG_E1000_NAPI
@@ -300,31 +298,26 @@ module_exit(e1000_exit_module);
 static int e1000_request_irq(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int flags, err = 0;
+	void (*handler) = &e1000_intr;
+	int irq_flags = IRQF_SHARED;
+	int err;
 
-	flags = IRQF_SHARED;
-#ifdef CONFIG_PCI_MSI
 	if (adapter->hw.mac_type >= e1000_82571) {
-		adapter->have_msi = TRUE;
-		if ((err = pci_enable_msi(adapter->pdev))) {
-			DPRINTK(PROBE, ERR,
-			 "Unable to allocate MSI interrupt Error: %d\n", err);
-			adapter->have_msi = FALSE;
+		adapter->have_msi = !pci_enable_msi(adapter->pdev);
+		if (adapter->have_msi) {
+			handler = &e1000_intr_msi;
+			irq_flags = 0;
 		}
 	}
-	if (adapter->have_msi) {
-		flags &= ~IRQF_SHARED;
-		err = request_irq(adapter->pdev->irq, &e1000_intr_msi, flags,
-		                  netdev->name, netdev);
-		if (err)
-			DPRINTK(PROBE, ERR,
-			       "Unable to allocate interrupt Error: %d\n", err);
-	} else
-#endif
-	if ((err = request_irq(adapter->pdev->irq, &e1000_intr, flags,
-	                       netdev->name, netdev)))
+
+	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
+	                  netdev);
+	if (err) {
+		if (adapter->have_msi)
+			pci_disable_msi(adapter->pdev);
 		DPRINTK(PROBE, ERR,
 		        "Unable to allocate interrupt Error: %d\n", err);
+	}
 
 	return err;
 }
@@ -335,10 +328,8 @@ static void e1000_free_irq(struct e1000_adapter *adapter)
 
 	free_irq(adapter->pdev->irq, netdev);
 
-#ifdef CONFIG_PCI_MSI
 	if (adapter->have_msi)
 		pci_disable_msi(adapter->pdev);
-#endif
 }
 
 /**
@@ -3744,7 +3735,6 @@ e1000_update_stats(struct e1000_adapter *adapter)
 
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
-#ifdef CONFIG_PCI_MSI
 
 /**
  * e1000_intr_msi - Interrupt Handler
@@ -3810,7 +3800,6 @@ e1000_intr_msi(int irq, void *data)
 
 	return IRQ_HANDLED;
 }
-#endif
 
 /**
  * e1000_intr - Interrupt Handler
