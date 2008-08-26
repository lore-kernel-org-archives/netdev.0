From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 10/13] ixgbe: update dca to new interface,
	fix CONFIG_DCA_MODULE
Date: Tue, 26 Aug 2008 04:27:21 -0700
Message-ID: <20080826112721.15787.65269.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37405 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755333AbYHZL1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:27:22 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099738rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:27:22 -0700 (PDT)
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

DCA related fixes
=================
- ixgbe was not compiling and using DCA correctly if dca was a module
- DCA interface changed with new kernel
- ixgbe was not correctly configured to indicate DCA hints to the
  correct CPU.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |   35 +++++++++++++++++++---------
 drivers/net/ixgbe/ixgbe_main.c |   50 ++++++++++++++++++++++++++++------------
 2 files changed, 59 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 628f60c..90b5383 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -37,7 +37,7 @@
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
 
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 #include <linux/dca.h>
 #endif
 
@@ -150,7 +150,7 @@ struct ixgbe_ring {
 		      * offset associated with this ring, which is different
 		      * for DCE and RSS modes */
 
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	/* cpu for tx queue */
 	int cpu;
 #endif
@@ -267,15 +267,28 @@ struct ixgbe_adapter {
 	 * thus the additional *_CAPABLE flags.
 	 */
 	u32 flags;
-#define IXGBE_FLAG_RX_CSUM_ENABLED              (u32)(1 << 0)
-#define IXGBE_FLAG_MSI_ENABLED                  (u32)(1 << 1)
-#define IXGBE_FLAG_MSIX_ENABLED                 (u32)(1 << 2)
-#define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 3)
-#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 4)
-#define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 5)
-#define IXGBE_FLAG_RSS_ENABLED                  (u32)(1 << 6)
-#define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 7)
-#define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 8)
+#define IXGBE_FLAG_RX_CSUM_ENABLED              (u32)(1)
+#define IXGBE_FLAG_MSI_CAPABLE                  (u32)(1 << 1)
+#define IXGBE_FLAG_MSI_ENABLED                  (u32)(1 << 2)
+#define IXGBE_FLAG_MSIX_CAPABLE                 (u32)(1 << 3)
+#define IXGBE_FLAG_MSIX_ENABLED                 (u32)(1 << 4)
+#define IXGBE_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 6)
+#define IXGBE_FLAG_RX_PS_CAPABLE                (u32)(1 << 7)
+#define IXGBE_FLAG_RX_PS_ENABLED                (u32)(1 << 8)
+#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 9)
+#define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 10)
+#define IXGBE_FLAG_DCA_CAPABLE                  (u32)(1 << 11)
+#define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 12)
+#define IXGBE_FLAG_MQ_CAPABLE                   (u32)(1 << 13)
+#define IXGBE_FLAG_RSS_ENABLED                  (u32)(1 << 16)
+#define IXGBE_FLAG_RSS_CAPABLE                  (u32)(1 << 17)
+#define IXGBE_FLAG_VMDQ_CAPABLE                 (u32)(1 << 18)
+#define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 19)
+#define IXGBE_FLAG_NEED_LINK_UPDATE             (u32)(1 << 22)
+#define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1 << 23)
+
+/* default to trying for four seconds */
+#define IXGBE_TRY_LINK_TIMEOUT (4 * HZ)
 
 	/* OS defined structs */
 	struct net_device *netdev;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b6973ee..f37e3eb 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -80,7 +80,7 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 };
 MODULE_DEVICE_TABLE(pci, ixgbe_pci_tbl);
 
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 static int ixgbe_notify_dca(struct notifier_block *, unsigned long event,
 			    void *p);
 static struct notifier_block dca_notifier = {
@@ -309,7 +309,7 @@ done_cleaning:
 	return (total_packets ? true : false);
 }
 
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 				struct ixgbe_ring *rx_ring)
 {
@@ -320,7 +320,7 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 	if (rx_ring->cpu != cpu) {
 		rxctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q));
 		rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK;
-		rxctrl |= dca_get_tag(cpu);
+		rxctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
 		rxctrl |= IXGBE_DCA_RXCTRL_DESC_DCA_EN;
 		rxctrl |= IXGBE_DCA_RXCTRL_HEAD_DCA_EN;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q), rxctrl);
@@ -339,7 +339,7 @@ static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
 	if (tx_ring->cpu != cpu) {
 		txctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_TXCTRL(q));
 		txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK;
-		txctrl |= dca_get_tag(cpu);
+		txctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
 		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_TXCTRL(q), txctrl);
 		tx_ring->cpu = cpu;
@@ -372,11 +372,14 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 
 	switch (event) {
 	case DCA_PROVIDER_ADD:
-		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
+		/* if we're already enabled, don't do it again */
+		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+			break;
 		/* Always use CB2 mode, difference is masked
 		 * in the CB driver. */
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
 		if (dca_add_requester(dev) == 0) {
+			adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
 			ixgbe_setup_dca(adapter);
 			break;
 		}
@@ -393,7 +396,7 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 	return 0;
 }
 
-#endif /* CONFIG_DCA */
+#endif /* CONFIG_DCA or CONFIG_DCA_MODULE */
 /**
  * ixgbe_receive_skb - Send a completed packet up the stack
  * @adapter: board private structure
@@ -931,7 +934,7 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
 		tx_ring = &(adapter->tx_ring[r_idx]);
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 			ixgbe_update_tx_dca(adapter, tx_ring);
 #endif
@@ -996,7 +999,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	rx_ring = &(adapter->rx_ring[r_idx]);
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 		ixgbe_update_rx_dca(adapter, rx_ring);
 #endif
@@ -2054,11 +2057,28 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	netif_carrier_off(netdev);
 	netif_tx_stop_all_queues(netdev);
 
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
+		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
+		dca_remove_requester(&adapter->pdev->dev);
+	}
+
+#endif
 	if (!pci_channel_offline(adapter->pdev))
 		ixgbe_reset(adapter);
 	ixgbe_clean_all_tx_rings(adapter);
 	ixgbe_clean_all_rx_rings(adapter);
 
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+	/* since we reset the hardware DCA settings were cleared */
+	if (dca_add_requester(&adapter->pdev->dev) == 0) {
+		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
+		/* always use CB2 mode, difference is masked
+		 * in the CB driver */
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
+		ixgbe_setup_dca(adapter);
+	}
+#endif
 }
 
 static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
@@ -2113,7 +2133,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	int tx_cleaned = 0, work_done = 0;
 
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		ixgbe_update_tx_dca(adapter, adapter->tx_ring);
 		ixgbe_update_rx_dca(adapter, adapter->rx_ring);
@@ -3677,7 +3697,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
 		/* always use CB2 mode, difference is masked
@@ -3727,7 +3747,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
 		dca_remove_requester(&pdev->dev);
@@ -3860,7 +3880,7 @@ static int __init ixgbe_init_module(void)
 
 	printk(KERN_INFO "%s: %s\n", ixgbe_driver_name, ixgbe_copyright);
 
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 	dca_register_notify(&dca_notifier);
 
 #endif
@@ -3877,13 +3897,13 @@ module_init(ixgbe_init_module);
  **/
 static void __exit ixgbe_exit_module(void)
 {
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&ixgbe_driver);
 }
 
-#ifdef CONFIG_DCA
+#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
 static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long event,
 			    void *p)
 {
@@ -3894,7 +3914,7 @@ static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long event,
 
 	return ret_val ? NOTIFY_BAD : NOTIFY_DONE;
 }
-#endif /* CONFIG_DCA */
+#endif /* CONFIG_DCA or CONFIG_DCA_MODULE */
 
 module_exit(ixgbe_exit_module);
 

