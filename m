From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] igb: add IGB_DCA instead of selecting INTEL_IOATDMA
Date: Fri, 17 Oct 2008 11:08:31 -0700
Message-ID: <20081017180831.15639.50705.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brice@myri.com, dan.j.williams@intel.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	tiwai@suse.de, apw@shadowen.org, linuxppc-dev@ozlabs.org,
	sam@ravnborg.org, e1000-devel@lists.sourceforge.net,
	maciej.sosnowski@intel.com, bunk@kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:46021 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751886AbYJQSJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 14:09:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a bool IGB_DCA defined to y if IGB and DCA are enabled, but IGB isn't y while DCA=m.  And thus remove the need to select INTEL_IOATDMA when IGB is enabled, so that non-x86 architectures can build the igb driver.
Based on work/patch from Brice Goglin <brice@myri.com>

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/Kconfig        |    5 +++++
 drivers/net/igb/igb_main.c |   32 ++++++++++++++++----------------
 2 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ad301ac..588ef13 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2003,6 +2003,11 @@ config IGB_LRO
 
 	  If in doubt, say N.
 
+config IGB_DCA
+	bool "Enable DCA"
+	default y
+	depends on IGB && DCA && !(IGB=y && DCA=m)
+
 source "drivers/net/ixp2000/Kconfig"
 
 config MYRI_SBUS
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 53cbeae..2bd3629 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -41,7 +41,7 @@
 #include <linux/delay.h>
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 #include <linux/dca.h>
 #endif
 #include "igb.h"
@@ -106,11 +106,11 @@ static irqreturn_t igb_msix_other(int irq, void *);
 static irqreturn_t igb_msix_rx(int irq, void *);
 static irqreturn_t igb_msix_tx(int irq, void *);
 static int igb_clean_rx_ring_msix(struct napi_struct *, int);
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 static void igb_update_rx_dca(struct igb_ring *);
 static void igb_update_tx_dca(struct igb_ring *);
 static void igb_setup_dca(struct igb_adapter *);
-#endif /* CONFIG_DCA */
+#endif /* CONFIG_IGB_DCA */
 static bool igb_clean_tx_irq(struct igb_ring *);
 static int igb_poll(struct napi_struct *, int);
 static bool igb_clean_rx_irq_adv(struct igb_ring *, int *, int);
@@ -131,7 +131,7 @@ static int igb_suspend(struct pci_dev *, pm_message_t);
 static int igb_resume(struct pci_dev *);
 #endif
 static void igb_shutdown(struct pci_dev *);
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 static int igb_notify_dca(struct notifier_block *, unsigned long, void *);
 static struct notifier_block dca_notifier = {
 	.notifier_call	= igb_notify_dca,
@@ -207,7 +207,7 @@ static int __init igb_init_module(void)
 	global_quad_port_a = 0;
 
 	ret = pci_register_driver(&igb_driver);
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	dca_register_notify(&dca_notifier);
 #endif
 	return ret;
@@ -223,7 +223,7 @@ module_init(igb_init_module);
  **/
 static void __exit igb_exit_module(void)
 {
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&igb_driver);
@@ -1260,7 +1260,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if ((adapter->flags & IGB_FLAG_HAS_DCA) &&
 	    (dca_add_requester(&pdev->dev) == 0)) {
 		adapter->flags |= IGB_FLAG_DCA_ENABLED;
@@ -1334,7 +1334,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	struct e1000_hw *hw = &adapter->hw;
 #endif
 
@@ -1346,7 +1346,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED) {
 		dev_info(&pdev->dev, "DCA disabled\n");
 		dca_remove_requester(&pdev->dev);
@@ -3294,7 +3294,7 @@ static irqreturn_t igb_msix_tx(int irq, void *data)
 	struct igb_adapter *adapter = tx_ring->adapter;
 	struct e1000_hw *hw = &adapter->hw;
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_tx_dca(tx_ring);
 #endif
@@ -3346,14 +3346,14 @@ static irqreturn_t igb_msix_rx(int irq, void *data)
 	if (netif_rx_schedule_prep(adapter->netdev, &rx_ring->napi))
 		__netif_rx_schedule(adapter->netdev, &rx_ring->napi);
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(rx_ring);
 #endif
 		return IRQ_HANDLED;
 }
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 static void igb_update_rx_dca(struct igb_ring *rx_ring)
 {
 	u32 dca_rxctrl;
@@ -3473,7 +3473,7 @@ static int igb_notify_dca(struct notifier_block *nb, unsigned long event,
 
 	return ret_val ? NOTIFY_BAD : NOTIFY_DONE;
 }
-#endif /* CONFIG_DCA */
+#endif /* CONFIG_IGB_DCA */
 
 /**
  * igb_intr_msi - Interrupt Handler
@@ -3552,13 +3552,13 @@ static int igb_poll(struct napi_struct *napi, int budget)
 	int tx_clean_complete, work_done = 0;
 
 	/* this poll routine only supports one tx and one rx queue */
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_tx_dca(&adapter->tx_ring[0]);
 #endif
 	tx_clean_complete = igb_clean_tx_irq(&adapter->tx_ring[0]);
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(&adapter->rx_ring[0]);
 #endif
@@ -3586,7 +3586,7 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 	struct net_device *netdev = adapter->netdev;
 	int work_done = 0;
 
-#ifdef CONFIG_DCA
+#ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(rx_ring);
 #endif

