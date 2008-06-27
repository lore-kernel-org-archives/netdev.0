From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 10/18] igb: add DCA support
Date: Fri, 27 Jun 2008 11:01:04 -0700
Message-ID: <20080627180101.22428.22066.stgit@localhost.localdomain>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080627175921.22428.52767.stgit@localhost.localdomain>
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

Add DCA support in the similar method that it was added to the ixgbe
driver recently. DCA allows the network device to put data in the
CPU cache and notify the chipset of that event. This reduces cache
misses during receives.

Signed-off-by: Jeb Cramer <cramerj@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
---

 drivers/net/igb/e1000_82575.h |   11 +++
 drivers/net/igb/e1000_regs.h  |    2 
 drivers/net/igb/igb.h         |    4 +
 drivers/net/igb/igb_main.c    |  174 ++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 187 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index d78ad33..02e57a8 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -144,9 +144,20 @@ struct e1000_adv_tx_context_desc {
 #define E1000_RXDCTL_QUEUE_ENABLE  0x02000000 /* Enable specific Rx Queue */
 
 /* Direct Cache Access (DCA) definitions */
+#define E1000_DCA_CTRL_DCA_ENABLE  0x00000000 /* DCA Enable */
+#define E1000_DCA_CTRL_DCA_DISABLE 0x00000001 /* DCA Disable */
 
+#define E1000_DCA_CTRL_DCA_MODE_CB1 0x00 /* DCA Mode CB1 */
+#define E1000_DCA_CTRL_DCA_MODE_CB2 0x02 /* DCA Mode CB2 */
 
+#define E1000_DCA_RXCTRL_CPUID_MASK 0x0000001F /* Rx CPUID Mask */
+#define E1000_DCA_RXCTRL_DESC_DCA_EN (1 << 5) /* DCA Rx Desc enable */
+#define E1000_DCA_RXCTRL_HEAD_DCA_EN (1 << 6) /* DCA Rx Desc header enable */
+#define E1000_DCA_RXCTRL_DATA_DCA_EN (1 << 7) /* DCA Rx Desc payload enable */
 
+#define E1000_DCA_TXCTRL_CPUID_MASK 0x0000001F /* Tx CPUID Mask */
+#define E1000_DCA_TXCTRL_DESC_DCA_EN (1 << 5) /* DCA Tx Desc enable */
 #define E1000_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
 
+
 #endif
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index ff187b7..d25e914 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -235,6 +235,8 @@
 #define E1000_FACTPS    0x05B30 /* Function Active and Power State to MNG */
 #define E1000_SWSM      0x05B50 /* SW Semaphore */
 #define E1000_FWSM      0x05B54 /* FW Semaphore */
+#define E1000_DCA_ID    0x05B70 /* DCA Requester ID Information - RO */
+#define E1000_DCA_CTRL  0x05B74 /* DCA Control - RW */
 #define E1000_HICR      0x08F00 /* Host Inteface Control */
 
 /* RSS registers */
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 0551a63..fa941da 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -271,7 +271,9 @@ struct igb_adapter {
 	/* to not mess up cache alignment, always add to the bottom */
 	unsigned long state;
 	unsigned int msi_enabled;
-
+#ifdef CONFIG_DCA
+	unsigned int dca_enabled;
+#endif
 	u32 eeprom_wol;
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	struct igb_ring *multi_tx_table[IGB_MAX_TX_QUEUES];
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 5fcc043..501ab4e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -41,7 +41,9 @@
 #include <linux/delay.h>
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
-
+#ifdef CONFIG_DCA
+#include <linux/dca.h>
+#endif
 #include "igb.h"
 
 #define DRV_VERSION "1.0.8-k2"
@@ -102,6 +104,11 @@ static irqreturn_t igb_msix_other(int irq, void *);
 static irqreturn_t igb_msix_rx(int irq, void *);
 static irqreturn_t igb_msix_tx(int irq, void *);
 static int igb_clean_rx_ring_msix(struct napi_struct *, int);
+#ifdef CONFIG_DCA
+static void igb_update_rx_dca(struct igb_ring *);
+static void igb_update_tx_dca(struct igb_ring *);
+static void igb_setup_dca(struct igb_adapter *);
+#endif /* CONFIG_DCA */
 static bool igb_clean_tx_irq(struct igb_ring *);
 static int igb_poll(struct napi_struct *, int);
 static bool igb_clean_rx_irq_adv(struct igb_ring *, int *, int);
@@ -119,6 +126,14 @@ static int igb_suspend(struct pci_dev *, pm_message_t);
 static int igb_resume(struct pci_dev *);
 #endif
 static void igb_shutdown(struct pci_dev *);
+#ifdef CONFIG_DCA
+static int igb_notify_dca(struct notifier_block *, unsigned long, void *);
+static struct notifier_block dca_notifier = {
+	.notifier_call	= igb_notify_dca,
+	.next		= NULL,
+	.priority	= 0
+};
+#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /* for netdump / net console */
@@ -183,6 +198,9 @@ static int __init igb_init_module(void)
 	printk(KERN_INFO "%s\n", igb_copyright);
 
 	ret = pci_register_driver(&igb_driver);
+#ifdef CONFIG_DCA
+	dca_register_notify(&dca_notifier);
+#endif
 	return ret;
 }
 
@@ -196,6 +214,9 @@ module_init(igb_init_module);
  **/
 static void __exit igb_exit_module(void)
 {
+#ifdef CONFIG_DCA
+	dca_unregister_notify(&dca_notifier);
+#endif
 	pci_unregister_driver(&igb_driver);
 }
 
@@ -1103,6 +1124,17 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
+#ifdef CONFIG_DCA
+	if (dca_add_requester(&pdev->dev) == 0) {
+		adapter->dca_enabled = true;
+		dev_info(&pdev->dev, "DCA enabled\n");
+		/* Always use CB2 mode, difference is masked
+		 * in the CB driver. */
+		wr32(E1000_DCA_CTRL, 2);
+		igb_setup_dca(adapter);
+	}
+#endif
+
 	dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n");
 	/* print bus type/speed/width info */
 	dev_info(&pdev->dev,
@@ -1166,6 +1198,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 
 	/* flush_scheduled work may reschedule our watchdog task, so
 	 * explicitly disable watchdog tasks from being rescheduled  */
@@ -1175,6 +1208,15 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
+#ifdef CONFIG_DCA
+	if (adapter->dca_enabled) {
+		dev_info(&pdev->dev, "DCA disabled\n");
+		dca_remove_requester(&pdev->dev);
+		adapter->dca_enabled = false;
+		wr32(E1000_DCA_CTRL, 1);
+	}
+#endif
+
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant. */
 	igb_release_hw_control(adapter);
@@ -3085,7 +3127,10 @@ static irqreturn_t igb_msix_tx(int irq, void *data)
 
 	if (!tx_ring->itr_val)
 		wr32(E1000_EIMC, tx_ring->eims_value);
-
+#ifdef CONFIG_DCA
+	if (adapter->dca_enabled)
+		igb_update_tx_dca(tx_ring);
+#endif
 	tx_ring->total_bytes = 0;
 	tx_ring->total_packets = 0;
 
@@ -3119,9 +3164,119 @@ static irqreturn_t igb_msix_rx(int irq, void *data)
 	if (netif_rx_schedule_prep(adapter->netdev, &rx_ring->napi))
 		__netif_rx_schedule(adapter->netdev, &rx_ring->napi);
 
-	return IRQ_HANDLED;
+#ifdef CONFIG_DCA
+	if (adapter->dca_enabled)
+		igb_update_rx_dca(rx_ring);
+#endif
+		return IRQ_HANDLED;
+}
+
+#ifdef CONFIG_DCA
+static void igb_update_rx_dca(struct igb_ring *rx_ring)
+{
+	u32 dca_rxctrl;
+	struct igb_adapter *adapter = rx_ring->adapter;
+	struct e1000_hw *hw = &adapter->hw;
+	int cpu = get_cpu();
+	int q = rx_ring - adapter->rx_ring;
+
+	if (rx_ring->cpu != cpu) {
+		dca_rxctrl = rd32(E1000_DCA_RXCTRL(q));
+		dca_rxctrl &= ~E1000_DCA_RXCTRL_CPUID_MASK;
+		dca_rxctrl |= dca_get_tag(cpu);
+		dca_rxctrl |= E1000_DCA_RXCTRL_DESC_DCA_EN;
+		dca_rxctrl |= E1000_DCA_RXCTRL_HEAD_DCA_EN;
+		dca_rxctrl |= E1000_DCA_RXCTRL_DATA_DCA_EN;
+		wr32(E1000_DCA_RXCTRL(q), dca_rxctrl);
+		rx_ring->cpu = cpu;
+	}
+	put_cpu();
+}
+
+static void igb_update_tx_dca(struct igb_ring *tx_ring)
+{
+	u32 dca_txctrl;
+	struct igb_adapter *adapter = tx_ring->adapter;
+	struct e1000_hw *hw = &adapter->hw;
+	int cpu = get_cpu();
+	int q = tx_ring - adapter->tx_ring;
+
+	if (tx_ring->cpu != cpu) {
+		dca_txctrl = rd32(E1000_DCA_TXCTRL(q));
+		dca_txctrl &= ~E1000_DCA_TXCTRL_CPUID_MASK;
+		dca_txctrl |= dca_get_tag(cpu);
+		dca_txctrl |= E1000_DCA_TXCTRL_DESC_DCA_EN;
+		wr32(E1000_DCA_TXCTRL(q), dca_txctrl);
+		tx_ring->cpu = cpu;
+	}
+	put_cpu();
+}
+
+static void igb_setup_dca(struct igb_adapter *adapter)
+{
+	int i;
+
+	if (!(adapter->dca_enabled))
+		return;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		adapter->tx_ring[i].cpu = -1;
+		igb_update_tx_dca(&adapter->tx_ring[i]);
+	}
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		adapter->rx_ring[i].cpu = -1;
+		igb_update_rx_dca(&adapter->rx_ring[i]);
+	}
 }
 
+static int __igb_notify_dca(struct device *dev, void *data)
+{
+	struct net_device *netdev = dev_get_drvdata(dev);
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	unsigned long event = *(unsigned long *)data;
+
+	switch (event) {
+	case DCA_PROVIDER_ADD:
+		/* if already enabled, don't do it again */
+		if (adapter->dca_enabled)
+			break;
+		adapter->dca_enabled = true;
+		/* Always use CB2 mode, difference is masked
+		 * in the CB driver. */
+		wr32(E1000_DCA_CTRL, 2);
+		if (dca_add_requester(dev) == 0) {
+			dev_info(&adapter->pdev->dev, "DCA enabled\n");
+			igb_setup_dca(adapter);
+			break;
+		}
+		/* Fall Through since DCA is disabled. */
+	case DCA_PROVIDER_REMOVE:
+		if (adapter->dca_enabled) {
+			/* without this a class_device is left
+ 			 * hanging around in the sysfs model */
+			dca_remove_requester(dev);
+			dev_info(&adapter->pdev->dev, "DCA disabled\n");
+			adapter->dca_enabled = false;
+			wr32(E1000_DCA_CTRL, 1);
+		}
+		break;
+	}
+
+	return 0;
+}
+
+static int igb_notify_dca(struct notifier_block *nb, unsigned long event,
+                          void *p)
+{
+	int ret_val;
+
+	ret_val = driver_for_each_device(&igb_driver.driver, NULL, &event,
+	                                 __igb_notify_dca);
+
+	return ret_val ? NOTIFY_BAD : NOTIFY_DONE;
+}
+#endif /* CONFIG_DCA */
 
 /**
  * igb_intr_msi - Interrupt Handler
@@ -3212,7 +3367,16 @@ static int igb_poll(struct napi_struct *napi, int budget)
 	int tx_clean_complete, work_done = 0;
 
 	/* this poll routine only supports one tx and one rx queue */
+#ifdef CONFIG_DCA
+	if (adapter->dca_enabled)
+		igb_update_tx_dca(&adapter->tx_ring[0]);
+#endif
 	tx_clean_complete = igb_clean_tx_irq(&adapter->tx_ring[0]);
+
+#ifdef CONFIG_DCA
+	if (adapter->dca_enabled)
+		igb_update_rx_dca(&adapter->rx_ring[0]);
+#endif
 	igb_clean_rx_irq_adv(&adapter->rx_ring[0], &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
@@ -3241,6 +3405,10 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 	if (!netif_carrier_ok(netdev))
 		goto quit_polling;
 
+#ifdef CONFIG_DCA
+	if (adapter->dca_enabled)
+		igb_update_rx_dca(rx_ring);
+#endif
 	igb_clean_rx_irq_adv(rx_ring, &work_done, budget);
 
 


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
