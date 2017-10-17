From: <netanel@amazon.com>
Subject: [PATCH net-next 2/6] net: ena: remove legacy suspend suspend/resume support
Date: Tue, 17 Oct 2017 07:33:57 +0000
Message-ID: <1508225641-106366-3-git-send-email-netanel@amazon.com>
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
        with ESMTP id S933027AbdJQHeg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:34:36 -0400
In-Reply-To: <1508225641-106366-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Remove ena_device_io_suspend/resume() methods
Those methods were intend to be used by the device to trigger
suspend/resume but eventually it was dropped.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_ethtool.c |  2 --
 drivers/net/ethernet/amazon/ena/ena_netdev.c  | 50 ---------------------------
 drivers/net/ethernet/amazon/ena/ena_netdev.h  |  4 ---
 3 files changed, 56 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_ethtool.c b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
index 967020fb26ee..1cd8eb8e5a15 100644
--- a/drivers/net/ethernet/amazon/ena/ena_ethtool.c
+++ b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
@@ -60,8 +60,6 @@ struct ena_stats {
 
 static const struct ena_stats ena_stats_global_strings[] = {
 	ENA_STAT_GLOBAL_ENTRY(tx_timeout),
-	ENA_STAT_GLOBAL_ENTRY(io_suspend),
-	ENA_STAT_GLOBAL_ENTRY(io_resume),
 	ENA_STAT_GLOBAL_ENTRY(wd_expired),
 	ENA_STAT_GLOBAL_ENTRY(interface_up),
 	ENA_STAT_GLOBAL_ENTRY(interface_down),
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index c6bd5e24005d..dbeff3064c0d 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2361,38 +2361,6 @@ static void ena_get_stats64(struct net_device *netdev,
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 };
 
-static void ena_device_io_suspend(struct work_struct *work)
-{
-	struct ena_adapter *adapter =
-		container_of(work, struct ena_adapter, suspend_io_task);
-	struct net_device *netdev = adapter->netdev;
-
-	/* ena_napi_disable_all disables only the IO handling.
-	 * We are still subject to AENQ keep alive watchdog.
-	 */
-	u64_stats_update_begin(&adapter->syncp);
-	adapter->dev_stats.io_suspend++;
-	u64_stats_update_begin(&adapter->syncp);
-	ena_napi_disable_all(adapter);
-	netif_tx_lock(netdev);
-	netif_device_detach(netdev);
-	netif_tx_unlock(netdev);
-}
-
-static void ena_device_io_resume(struct work_struct *work)
-{
-	struct ena_adapter *adapter =
-		container_of(work, struct ena_adapter, resume_io_task);
-	struct net_device *netdev = adapter->netdev;
-
-	u64_stats_update_begin(&adapter->syncp);
-	adapter->dev_stats.io_resume++;
-	u64_stats_update_end(&adapter->syncp);
-
-	netif_device_attach(netdev);
-	ena_napi_enable_all(adapter);
-}
-
 static int ena_device_validate_params(struct ena_adapter *adapter,
 				      struct ena_com_dev_get_features_ctx *get_feat_ctx)
 {
@@ -3276,8 +3244,6 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_rss;
 	}
 
-	INIT_WORK(&adapter->suspend_io_task, ena_device_io_suspend);
-	INIT_WORK(&adapter->resume_io_task, ena_device_io_resume);
 	INIT_WORK(&adapter->reset_task, ena_fw_reset_device);
 
 	adapter->last_keep_alive_jiffies = jiffies;
@@ -3311,8 +3277,6 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 err_worker_destroy:
 	ena_com_destroy_interrupt_moderation(ena_dev);
 	del_timer(&adapter->timer_service);
-	cancel_work_sync(&adapter->suspend_io_task);
-	cancel_work_sync(&adapter->resume_io_task);
 err_netdev_destroy:
 	free_netdev(netdev);
 err_device_destroy:
@@ -3382,10 +3346,6 @@ static void ena_remove(struct pci_dev *pdev)
 
 	cancel_work_sync(&adapter->reset_task);
 
-	cancel_work_sync(&adapter->suspend_io_task);
-
-	cancel_work_sync(&adapter->resume_io_task);
-
 	/* Reset the device only if the device is running. */
 	if (test_bit(ENA_FLAG_DEVICE_RUNNING, &adapter->flags))
 		ena_com_dev_reset(ena_dev, adapter->reset_reason);
@@ -3504,16 +3464,6 @@ static void ena_notification(void *adapter_data,
 	     ENA_ADMIN_NOTIFICATION);
 
 	switch (aenq_e->aenq_common_desc.syndrom) {
-	case ENA_ADMIN_SUSPEND:
-		/* Suspend just the IO queues.
-		 * We deliberately don't suspend admin so the timer and
-		 * the keep_alive events should remain.
-		 */
-		queue_work(ena_wq, &adapter->suspend_io_task);
-		break;
-	case ENA_ADMIN_RESUME:
-		queue_work(ena_wq, &adapter->resume_io_task);
-		break;
 	case ENA_ADMIN_UPDATE_HINTS:
 		hints = (struct ena_admin_ena_hw_hints *)
 			(&aenq_e->inline_data_w4);
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.h b/drivers/net/ethernet/amazon/ena/ena_netdev.h
index 29bb5704260b..fb0c98bb9290 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.h
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.h
@@ -257,8 +257,6 @@ struct ena_ring {
 
 struct ena_stats_dev {
 	u64 tx_timeout;
-	u64 io_suspend;
-	u64 io_resume;
 	u64 wd_expired;
 	u64 interface_up;
 	u64 interface_down;
@@ -326,8 +324,6 @@ struct ena_adapter {
 
 	/* timer service */
 	struct work_struct reset_task;
-	struct work_struct suspend_io_task;
-	struct work_struct resume_io_task;
 	struct timer_list timer_service;
 
 	bool wd_state;
-- 
1.8.3.1
