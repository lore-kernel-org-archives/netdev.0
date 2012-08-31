From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/8] ixgbevf: Add suspend and resume support to the VF
Date: Thu, 30 Aug 2012 22:16:13 -0700
Message-ID: <1346390174-30449-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1346390174-30449-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59105 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229Ab2HaFQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 01:16:43 -0400
In-Reply-To: <1346390174-30449-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds PCI suspend and resume support to ixgbevf.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 93 ++++++++++++++++++++++-
 1 file changed, 89 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 60ef645..87f87d8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1867,6 +1867,22 @@ err_set_interrupt:
 }
 
 /**
+ * ixgbevf_clear_interrupt_scheme - Clear the current interrupt scheme settings
+ * @adapter: board private structure to clear interrupt scheme on
+ *
+ * We go through and clear interrupt specific resources and reset the structure
+ * to pre-load conditions
+ **/
+static void ixgbevf_clear_interrupt_scheme(struct ixgbevf_adapter *adapter)
+{
+	adapter->num_tx_queues = 0;
+	adapter->num_rx_queues = 0;
+
+	ixgbevf_free_q_vectors(adapter);
+	ixgbevf_reset_interrupt_capability(adapter);
+}
+
+/**
  * ixgbevf_sw_init - Initialize general software structures
  * (struct ixgbevf_adapter)
  * @adapter: board private structure to initialize
@@ -2889,23 +2905,85 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
-static void ixgbevf_shutdown(struct pci_dev *pdev)
+static int ixgbevf_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+#ifdef CONFIG_PM
+	int retval = 0;
+#endif
 
 	netif_device_detach(netdev);
 
 	if (netif_running(netdev)) {
+		rtnl_lock();
 		ixgbevf_down(adapter);
 		ixgbevf_free_irq(adapter);
 		ixgbevf_free_all_tx_resources(adapter);
 		ixgbevf_free_all_rx_resources(adapter);
+		rtnl_unlock();
 	}
 
-	pci_save_state(pdev);
+	ixgbevf_clear_interrupt_scheme(adapter);
+
+#ifdef CONFIG_PM
+	retval = pci_save_state(pdev);
+	if (retval)
+		return retval;
 
+#endif
 	pci_disable_device(pdev);
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int ixgbevf_resume(struct pci_dev *pdev)
+{
+	struct ixgbevf_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev = adapter->netdev;
+	u32 err;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	/*
+	 * pci_restore_state clears dev->state_saved so call
+	 * pci_save_state to restore it.
+	 */
+	pci_save_state(pdev);
+
+	err = pci_enable_device_mem(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "Cannot enable PCI device from suspend\n");
+		return err;
+	}
+	pci_set_master(pdev);
+
+	rtnl_lock();
+	err = ixgbevf_init_interrupt_scheme(adapter);
+	rtnl_unlock();
+	if (err) {
+		dev_err(&pdev->dev, "Cannot initialize interrupts\n");
+		return err;
+	}
+
+	ixgbevf_reset(adapter);
+
+	if (netif_running(netdev)) {
+		err = ixgbevf_open(netdev);
+		if (err)
+			return err;
+	}
+
+	netif_device_attach(netdev);
+
+	return err;
+}
+
+#endif /* CONFIG_PM */
+static void ixgbevf_shutdown(struct pci_dev *pdev)
+{
+	ixgbevf_suspend(pdev, PMSG_SUSPEND);
 }
 
 static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
@@ -2946,7 +3024,7 @@ static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
 	return stats;
 }
 
-static const struct net_device_ops ixgbe_netdev_ops = {
+static const struct net_device_ops ixgbevf_netdev_ops = {
 	.ndo_open		= ixgbevf_open,
 	.ndo_stop		= ixgbevf_close,
 	.ndo_start_xmit		= ixgbevf_xmit_frame,
@@ -2962,7 +3040,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 
 static void ixgbevf_assign_netdev_ops(struct net_device *dev)
 {
-	dev->netdev_ops = &ixgbe_netdev_ops;
+	dev->netdev_ops = &ixgbevf_netdev_ops;
 	ixgbevf_set_ethtool_ops(dev);
 	dev->watchdog_timeo = 5 * HZ;
 }
@@ -3131,6 +3209,7 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	return 0;
 
 err_register:
+	ixgbevf_clear_interrupt_scheme(adapter);
 err_sw_init:
 	ixgbevf_reset_interrupt_capability(adapter);
 	iounmap(hw->hw_addr);
@@ -3168,6 +3247,7 @@ static void __devexit ixgbevf_remove(struct pci_dev *pdev)
 	if (netdev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(netdev);
 
+	ixgbevf_clear_interrupt_scheme(adapter);
 	ixgbevf_reset_interrupt_capability(adapter);
 
 	iounmap(adapter->hw.hw_addr);
@@ -3267,6 +3347,11 @@ static struct pci_driver ixgbevf_driver = {
 	.id_table = ixgbevf_pci_tbl,
 	.probe    = ixgbevf_probe,
 	.remove   = __devexit_p(ixgbevf_remove),
+#ifdef CONFIG_PM
+	/* Power Management Hooks */
+	.suspend  = ixgbevf_suspend,
+	.resume   = ixgbevf_resume,
+#endif
 	.shutdown = ixgbevf_shutdown,
 	.err_handler = &ixgbevf_err_handler
 };
-- 
1.7.11.4
