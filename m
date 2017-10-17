From: <netanel@amazon.com>
Subject: [PATCH net-next 3/6] net: ena: add power management ops to the ENA driver
Date: Tue, 17 Oct 2017 07:33:58 +0000
Message-ID: <1508225641-106366-4-git-send-email-netanel@amazon.com>
References: <1508225641-106366-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:23398 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933098AbdJQHeh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:34:37 -0400
In-Reply-To: <1508225641-106366-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_ethtool.c |   2 +
 drivers/net/ethernet/amazon/ena/ena_netdev.c  | 117 ++++++++++++++++++++------
 drivers/net/ethernet/amazon/ena/ena_netdev.h  |   3 +
 3 files changed, 95 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_ethtool.c b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
index 1cd8eb8e5a15..2aa1fd0e15ec 100644
--- a/drivers/net/ethernet/amazon/ena/ena_ethtool.c
+++ b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
@@ -60,6 +60,8 @@ struct ena_stats {
 
 static const struct ena_stats ena_stats_global_strings[] = {
 	ENA_STAT_GLOBAL_ENTRY(tx_timeout),
+	ENA_STAT_GLOBAL_ENTRY(suspend),
+	ENA_STAT_GLOBAL_ENTRY(resume),
 	ENA_STAT_GLOBAL_ENTRY(wd_expired),
 	ENA_STAT_GLOBAL_ENTRY(interface_up),
 	ENA_STAT_GLOBAL_ENTRY(interface_down),
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index dbeff3064c0d..0aa56707d7cc 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2529,38 +2529,31 @@ static int ena_enable_msix_and_set_admin_interrupts(struct ena_adapter *adapter,
 	return rc;
 }
 
-static void ena_fw_reset_device(struct work_struct *work)
+static void ena_destroy_device(struct ena_adapter *adapter)
 {
-	struct ena_com_dev_get_features_ctx get_feat_ctx;
-	struct ena_adapter *adapter =
-		container_of(work, struct ena_adapter, reset_task);
 	struct net_device *netdev = adapter->netdev;
 	struct ena_com_dev *ena_dev = adapter->ena_dev;
-	struct pci_dev *pdev = adapter->pdev;
-	bool dev_up, wd_state;
-	int rc;
-
-	if (unlikely(!test_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags))) {
-		dev_err(&pdev->dev,
-			"device reset schedule while reset bit is off\n");
-		return;
-	}
+	bool dev_up;
 
 	netif_carrier_off(netdev);
 
 	del_timer_sync(&adapter->timer_service);
 
-	rtnl_lock();
-
 	dev_up = test_bit(ENA_FLAG_DEV_UP, &adapter->flags);
+	adapter->dev_up_before_reset = dev_up;
+
 	ena_com_set_admin_running_state(ena_dev, false);
 
-	/* After calling ena_close the tx queues and the napi
-	 * are disabled so no one can interfere or touch the
-	 * data structures
-	 */
 	ena_close(netdev);
 
+	/* Before releasing the ENA resources, a device reset is required.
+	 * (to prevent the device from accessing them).
+	 * In case the reset flag is set and the device is up, ena_close
+	 * already perform the reset, so it can be skipped.
+	 */
+	if (!(test_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags) && dev_up))
+		ena_com_dev_reset(adapter->ena_dev, adapter->reset_reason);
+
 	ena_free_mgmnt_irq(adapter);
 
 	ena_disable_msix(adapter);
@@ -2574,9 +2567,17 @@ static void ena_fw_reset_device(struct work_struct *work)
 	ena_com_mmio_reg_read_request_destroy(ena_dev);
 
 	adapter->reset_reason = ENA_REGS_RESET_NORMAL;
+
 	clear_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags);
+}
 
-	/* Finish with the destroy part. Start the init part */
+static int ena_restore_device(struct ena_adapter *adapter)
+{
+	struct ena_com_dev_get_features_ctx get_feat_ctx;
+	struct ena_com_dev *ena_dev = adapter->ena_dev;
+	struct pci_dev *pdev = adapter->pdev;
+	bool wd_state;
+	int rc;
 
 	rc = ena_device_init(ena_dev, adapter->pdev, &get_feat_ctx, &wd_state);
 	if (rc) {
@@ -2598,7 +2599,7 @@ static void ena_fw_reset_device(struct work_struct *work)
 		goto err_device_destroy;
 	}
 	/* If the interface was up before the reset bring it up */
-	if (dev_up) {
+	if (adapter->dev_up_before_reset) {
 		rc = ena_up(adapter);
 		if (rc) {
 			dev_err(&pdev->dev, "Failed to create I/O queues\n");
@@ -2607,24 +2608,38 @@ static void ena_fw_reset_device(struct work_struct *work)
 	}
 
 	mod_timer(&adapter->timer_service, round_jiffies(jiffies + HZ));
-
-	rtnl_unlock();
-
 	dev_err(&pdev->dev, "Device reset completed successfully\n");
 
-	return;
+	return rc;
 err_disable_msix:
 	ena_free_mgmnt_irq(adapter);
 	ena_disable_msix(adapter);
 err_device_destroy:
 	ena_com_admin_destroy(ena_dev);
 err:
-	rtnl_unlock();
-
 	clear_bit(ENA_FLAG_DEVICE_RUNNING, &adapter->flags);
 
 	dev_err(&pdev->dev,
 		"Reset attempt failed. Can not reset the device\n");
+
+	return rc;
+}
+
+static void ena_fw_reset_device(struct work_struct *work)
+{
+	struct ena_adapter *adapter =
+		container_of(work, struct ena_adapter, reset_task);
+	struct pci_dev *pdev = adapter->pdev;
+
+	if (unlikely(!test_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags))) {
+		dev_err(&pdev->dev,
+			"device reset schedule while reset bit is off\n");
+		return;
+	}
+	rtnl_lock();
+	ena_destroy_device(adapter);
+	ena_restore_device(adapter);
+	rtnl_unlock();
 }
 
 static int check_missing_comp_in_queue(struct ena_adapter *adapter,
@@ -3379,11 +3394,59 @@ static void ena_remove(struct pci_dev *pdev)
 	vfree(ena_dev);
 }
 
+#ifdef CONFIG_PM
+/* ena_suspend - PM suspend callback
+ * @pdev: PCI device information struct
+ * @state:power state
+ */
+static int ena_suspend(struct pci_dev *pdev,  pm_message_t state)
+{
+	struct ena_adapter *adapter = pci_get_drvdata(pdev);
+
+	u64_stats_update_begin(&adapter->syncp);
+	adapter->dev_stats.suspend++;
+	u64_stats_update_end(&adapter->syncp);
+
+	rtnl_lock();
+	if (unlikely(test_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags))) {
+		dev_err(&pdev->dev,
+			"ignoring device reset request as the device is being suspended\n");
+		clear_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags);
+	}
+	ena_destroy_device(adapter);
+	rtnl_unlock();
+	return 0;
+}
+
+/* ena_resume - PM resume callback
+ * @pdev: PCI device information struct
+ *
+ */
+static int ena_resume(struct pci_dev *pdev)
+{
+	struct ena_adapter *adapter = pci_get_drvdata(pdev);
+	int rc;
+
+	u64_stats_update_begin(&adapter->syncp);
+	adapter->dev_stats.resume++;
+	u64_stats_update_end(&adapter->syncp);
+
+	rtnl_lock();
+	rc = ena_restore_device(adapter);
+	rtnl_unlock();
+	return rc;
+}
+#endif
+
 static struct pci_driver ena_pci_driver = {
 	.name		= DRV_MODULE_NAME,
 	.id_table	= ena_pci_tbl,
 	.probe		= ena_probe,
 	.remove		= ena_remove,
+#ifdef CONFIG_PM
+	.suspend    = ena_suspend,
+	.resume     = ena_resume,
+#endif
 	.sriov_configure = ena_sriov_configure,
 };
 
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index fb0c98bb9290..7b07bfbf0fe4 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -257,6 +257,8 @@ struct ena_ring {
 
 struct ena_stats_dev {
 	u64 tx_timeout;
+	u64 suspend;
+	u64 resume;
 	u64 wd_expired;
 	u64 interface_up;
 	u64 interface_down;
@@ -327,6 +329,7 @@ struct ena_adapter {
 	struct timer_list timer_service;
 
 	bool wd_state;
+	bool dev_up_before_reset;
 	unsigned long last_keep_alive_jiffies;
 
 	struct u64_stats_sync syncp;
-- 
1.8.3.1
