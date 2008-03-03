From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/5] ixgbe: Add optional DCA infrastructure
Date: Mon, 03 Mar 2008 15:04:02 -0800
Message-ID: <20080303230402.25151.77032.stgit@localhost.localdomain>
References: <20080303230345.25151.48298.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080303230345.25151.48298.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jeb Cramer <cramerj@intel.com>

82598 cards and up support DCA, which enables the chipset to warm
up the caches for upcoming payload data. This code makes the
driver plug into the CONFIG_DCA infrastructure that was merged
earlier.

Signed-off-by: Jeb Cramer <cramerj@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    9 ++
 drivers/net/ixgbe/ixgbe_main.c |  148 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 157 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 79f5519..d981134 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -36,6 +36,9 @@
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
 
+#ifdef CONFIG_DCA
+#include <linux/dca.h>
+#endif
 
 #define IXGBE_ERR(args...) printk(KERN_ERR "ixgbe: " args)
 
@@ -142,6 +145,11 @@ struct ixgbe_ring {
 	u16 reg_idx; /* holds the special value that gets the hardware register
 		      * offset associated with this ring, which is different
 		      * for DCE and RSS modes */
+
+#ifdef CONFIG_DCA
+	/* cpu for tx queue */
+	int cpu;
+#endif
 	struct ixgbe_queue_stats stats;
 	u8 v_idx; /* maps directly to the index for this ring in the hardware
 		   * vector array, can also be used for finding the bit in EICR
@@ -261,6 +269,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 5)
 #define IXGBE_FLAG_RSS_ENABLED                  (u32)(1 << 6)
 #define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 7)
+#define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 8)
 
 	/* OS defined structs */
 	struct net_device *netdev;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e1f11e6..da8becf 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -80,6 +80,16 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 };
 MODULE_DEVICE_TABLE(pci, ixgbe_pci_tbl);
 
+#ifdef CONFIG_DCA
+static int ixgbe_notify_dca(struct notifier_block *, unsigned long event,
+			    void *p);
+static struct notifier_block dca_notifier = {
+	.notifier_call = ixgbe_notify_dca,
+	.next          = NULL,
+	.priority      = 0
+};
+#endif
+
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
@@ -290,6 +300,91 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 	return cleaned;
 }
 
+#ifdef CONFIG_DCA
+static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
+				struct ixgbe_ring *rxr)
+{
+	u32 rxctrl;
+	int cpu = get_cpu();
+	int q = rxr - adapter->rx_ring;
+
+	if (rxr->cpu != cpu) {
+		rxctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q));
+		rxctrl &= ~IXGBE_DCA_RXCTRL_CPUID_MASK;
+		rxctrl |= dca_get_tag(cpu);
+		rxctrl |= IXGBE_DCA_RXCTRL_DESC_DCA_EN;
+		rxctrl |= IXGBE_DCA_RXCTRL_HEAD_DCA_EN;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q), rxctrl);
+		rxr->cpu = cpu;
+	}
+	put_cpu();
+}
+
+static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
+				struct ixgbe_ring *txr)
+{
+	u32 txctrl;
+	int cpu = get_cpu();
+	int q = txr - adapter->tx_ring;
+
+	if (txr->cpu != cpu) {
+		txctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_TXCTRL(q));
+		txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK;
+		txctrl |= dca_get_tag(cpu);
+		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_TXCTRL(q), txctrl);
+		txr->cpu = cpu;
+	}
+	put_cpu();
+}
+
+static void ixgbe_setup_dca(struct ixgbe_adapter *adapter)
+{
+	int i;
+
+	if (!(adapter->flags & IXGBE_FLAG_DCA_ENABLED))
+		return;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		adapter->tx_ring[i].cpu = -1;
+		ixgbe_update_tx_dca(adapter, &adapter->tx_ring[i]);
+	}
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		adapter->rx_ring[i].cpu = -1;
+		ixgbe_update_rx_dca(adapter, &adapter->rx_ring[i]);
+	}
+}
+
+static int __ixgbe_notify_dca(struct device *dev, void *data)
+{
+	struct net_device *netdev = dev_get_drvdata(dev);
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	unsigned long event = *(unsigned long *)data;
+
+	switch (event) {
+	case DCA_PROVIDER_ADD:
+		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
+		/* Always use CB2 mode, difference is masked
+		 * in the CB driver. */
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
+		if (dca_add_requester(dev) == IXGBE_SUCCESS) {
+			ixgbe_setup_dca(adapter);
+			break;
+		}
+		/* Fall Through since DCA is disabled. */
+	case DCA_PROVIDER_REMOVE:
+		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
+			dca_remove_requester(dev);
+			adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 1);
+		}
+		break;
+	}
+
+	return IXGBE_SUCCESS;
+}
+
+#endif /* CONFIG_DCA */
 /**
  * ixgbe_receive_skb - Send a completed packet up the stack
  * @adapter: board private structure
@@ -811,6 +906,10 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
 		txr = &(adapter->tx_ring[r_idx]);
+#ifdef CONFIG_DCA
+		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+			ixgbe_update_tx_dca(adapter, txr);
+#endif
 		txr->total_bytes = 0;
 		txr->total_packets = 0;
 		ixgbe_clean_tx_irq(adapter, txr);
@@ -872,6 +971,10 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	rxr = &(adapter->rx_ring[r_idx]);
+#ifdef CONFIG_DCA
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+		ixgbe_update_rx_dca(adapter, rxr);
+#endif
 
 	ixgbe_clean_rx_irq(adapter, rxr, &work_done, budget);
 
@@ -1924,6 +2027,13 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	int tx_cleaned = 0, work_done = 0;
 
+#ifdef CONFIG_DCA
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
+		ixgbe_update_tx_dca(adapter, adapter->tx_ring);
+		ixgbe_update_rx_dca(adapter, adapter->rx_ring);
+	}
+#endif
+
 	tx_cleaned = ixgbe_clean_tx_irq(adapter, adapter->tx_ring);
 	ixgbe_clean_rx_irq(adapter, adapter->rx_ring, &work_done, budget);
 
@@ -3494,6 +3604,15 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
+#ifdef CONFIG_DCA
+	if (dca_add_requester(&pdev->dev) == IXGBE_SUCCESS) {
+		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
+		/* always use CB2 mode, difference is masked
+		 * in the CB driver */
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_CTRL, 2);
+		ixgbe_setup_dca(adapter);
+	}
+#endif
 
 	dev_info(&pdev->dev, "Intel(R) 10 Gigabit Network Connection\n");
 	cards_found++;
@@ -3535,6 +3654,14 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
+#ifdef CONFIG_DCA
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
+		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
+		dca_remove_requester(&pdev->dev);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 1);
+	}
+
+#endif
 	unregister_netdev(netdev);
 
 	ixgbe_reset_interrupt_capability(adapter);
@@ -3659,6 +3786,10 @@ static int __init ixgbe_init_module(void)
 
 	printk(KERN_INFO "%s: %s\n", ixgbe_driver_name, ixgbe_copyright);
 
+#ifdef CONFIG_DCA
+	dca_register_notify(&dca_notifier);
+
+#endif
 	ret = pci_register_driver(&ixgbe_driver);
 	return ret;
 }
@@ -3672,8 +3803,25 @@ module_init(ixgbe_init_module);
  **/
 static void __exit ixgbe_exit_module(void)
 {
+#ifdef CONFIG_DCA
+	dca_unregister_notify(&dca_notifier);
+#endif
 	pci_unregister_driver(&ixgbe_driver);
 }
+
+#ifdef CONFIG_DCA
+static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long event,
+			    void *p)
+{
+	int ret_val;
+
+	ret_val = driver_for_each_device(&ixgbe_driver.driver, NULL, &event,
+					 __ixgbe_notify_dca);
+
+	return ret_val ? NOTIFY_BAD : NOTIFY_DONE;
+}
+#endif /* CONFIG_DCA */
+
 module_exit(ixgbe_exit_module);
 
 /* ixgbe_main.c */


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
