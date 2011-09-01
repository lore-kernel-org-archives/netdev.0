From: Carolyn Wyborny <carolyn.wyborny@intel.com>
Subject: [RFC] igb: Add notifier mechanism in order to synch DMA Coalescing feature
Date: Thu,  1 Sep 2011 08:21:28 -0700
Message-ID: <1314890488-1743-1-git-send-email-carolyn.wyborny@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18244 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932346Ab1IAPWI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Sep 2011 11:22:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DMA Coalescing feature runs on every port of quad i350 adapters.  Having
more than one card in a system can cause the DMA Coalescing feature
to be offset enough on each port to eventually reduce the expected power
savings on the system overall.  This feature is a way to synch the
DMA Coalescing instances in order to improve the power savings with multiple
cards in a system.

I'm sending this RFC to see if anyone has a better way of doing this.
The requirement is to have every driver instance attached to this
particular device write a single register bit on every rx interrrupt.
People using this feature would be more interested in power savings
than extreme performance. For purposes of this RFC, the DMAC feature isi
enabled.  The feature is normally disabled by default
---
 drivers/net/ethernet/intel/igb/igb.h      |    1 +
 drivers/net/ethernet/intel/igb/igb_main.c |   63 ++++++++++++++++++++++++++++-
 2 files changed, 63 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 265e151..272ceb1 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -341,6 +341,7 @@ struct igb_adapter {
 #define IGB_MIN_TXPBSIZE           20408
 #define IGB_TX_BUF_4096            4096
 #define IGB_DMCTLX_DCFLUSH_DIS     0x80000000  /* Disable DMA Coal Flush */
+#define IGB_DMACR_EXIT_DC          0x20000000 /* Exit DMAC Coalescing */
 
 #define IGB_82576_TSYNC_SHIFT 19
 #define IGB_82580_TSYNC_SHIFT 24
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8016084..c6a4b88 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -173,6 +173,20 @@ static struct notifier_block dca_notifier = {
 	.priority	= 0
 };
 #endif
+
+#define IGB_OPTIMIZE_DMAC 0x0001
+static ATOMIC_NOTIFIER_HEAD(igb_opt_dmac_notify_list);
+static int igb_register_opt_dmac_notifier (struct notifier_block *nb);
+static int igb_unregister_opt_dmac_notifier (struct notifier_block *nb);
+static void igb_call_opt_dmac_notify(unsigned long msg);
+static int igb_notify_opt_dmac(struct notifier_block *, unsigned long, void *);
+static int __igb_notify_opt_dmac(struct device *dev, void *data);
+static struct notifier_block igb_notifier_opt_dmac = {
+	.notifier_call	= igb_notify_opt_dmac,
+	.next		= NULL,
+	.priority	= 0
+};
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /* for netdump / net console */
 static void igb_netpoll(struct net_device *);
@@ -599,6 +613,9 @@ static int __init igb_init_module(void)
 	dca_register_notify(&dca_notifier);
 #endif
 	ret = pci_register_driver(&igb_driver);
+	if (ret >= 0) {
+		igb_register_opt_dmac_notifier(&igb_notifier_opt_dmac);
+	}
 	return ret;
 }
 
@@ -615,6 +632,7 @@ static void __exit igb_exit_module(void)
 #ifdef CONFIG_IGB_DCA
 	dca_unregister_notify(&dca_notifier);
 #endif
+	igb_unregister_opt_dmac_notifier(&igb_notifier_opt_dmac);
 	pci_unregister_driver(&igb_driver);
 }
 
@@ -2441,7 +2459,8 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 	igb_irq_disable(adapter);
 
 	if (hw->mac.type == e1000_i350)
-		adapter->flags &= ~IGB_FLAG_DMAC;
+		/* adapter->flags &= ~IGB_FLAG_DMAC; */
+		adapter->flags |= IGB_FLAG_DMAC;
 
 	set_bit(__IGB_DOWN, &adapter->state);
 	return 0;
@@ -5539,6 +5558,10 @@ static int igb_poll(struct napi_struct *napi, int budget)
 	if (q_vector->rx_ring)
 		igb_clean_rx_irq_adv(q_vector, &work_done, budget);
 
+	if ((q_vector->adapter->hw.mac.type = e1000_i350) &&
+		(q_vector->adapter->flags & IGB_FLAG_DMAC))
+		igb_call_opt_dmac_notify(IGB_OPTIMIZE_DMAC);
+
 	if (!tx_clean_complete)
 		work_done = budget;
 
@@ -6889,4 +6912,42 @@ static void igb_vmm_control(struct igb_adapter *adapter)
 	}
 }
 
+static int igb_register_opt_dmac_notifier (struct notifier_block *nb)
+{
+	return atomic_notifier_chain_register(&igb_opt_dmac_notify_list,
+	                                        &igb_notifier_opt_dmac);
+}
+static int igb_unregister_opt_dmac_notifier (struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&igb_opt_dmac_notify_list,
+	                                          &igb_notifier_opt_dmac);
+}
+static void igb_call_opt_dmac_notify(unsigned long msg)
+{
+	atomic_notifier_call_chain(&igb_opt_dmac_notify_list, msg,
+	                             NULL);
+}
+static int igb_notify_opt_dmac(struct notifier_block *nb, unsigned long event,
+                          void *p)
+{
+	int ret_val;
+
+	ret_val = driver_for_each_device(&igb_driver.driver, NULL, &event,
+	                                 __igb_notify_opt_dmac);
+
+	return NOTIFY_DONE;
+}
+static int __igb_notify_opt_dmac(struct device *dev, void *data)
+{
+	struct net_device *netdev = dev_get_drvdata(dev);
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	unsigned long event = *(unsigned long *)data;
+
+	if (event == IGB_OPTIMIZE_DMAC) {
+		wr32(E1000_DMACR, IGB_DMACR_EXIT_DC);
+	}
+	return E1000_SUCCESS;
+}
+
 /* igb_main.c */
-- 
1.7.4.4
