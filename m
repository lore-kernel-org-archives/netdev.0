From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 11/18] net/ena: fix potential access to freed memory during device reset
Date: Sun, 20 Nov 2016 10:45:40 +0200
Message-ID: <1479631547-29354-12-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f170.google.com ([209.85.210.170]:33047 "EHLO
        mail-wj0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753121AbcKTIvt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 03:51:49 -0500
Received: by mail-wj0-f170.google.com with SMTP id xy5so14046495wjc.0
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 00:51:48 -0800 (PST)
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the ena driver detects that the device is not behave as expected,
it tries to reset the device.
The reset flow calls ena_down, which will frees all the resources
the driver allocates and then it will reset the device.

This flow can cause memory corruption if the device is still writes
to the driver's memory space.
To overcome this potential race, move the reset before the device
resources are freed.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 56 +++++++++++++++++++++-------
 1 file changed, 43 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index dd7c74b..3bc8f43 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -80,14 +80,18 @@ static void ena_tx_timeout(struct net_device *dev)
 {
 	struct ena_adapter *adapter = netdev_priv(dev);
 
+	/* Change the state of the device to trigger reset
+	 * Check that we are not in the middle or a trigger already
+	 */
+
+	if (test_and_set_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags))
+		return;
+
 	u64_stats_update_begin(&adapter->syncp);
 	adapter->dev_stats.tx_timeout++;
 	u64_stats_update_end(&adapter->syncp);
 
 	netif_err(adapter, tx_err, dev, "Transmit time out\n");
-
-	/* Change the state of the device to trigger reset */
-	set_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags);
 }
 
 static void update_rx_ring_mtu(struct ena_adapter *adapter, int mtu)
@@ -1124,7 +1128,8 @@ static int ena_io_poll(struct napi_struct *napi, int budget)
 
 	tx_budget = tx_ring->ring_size / ENA_TX_POLL_BUDGET_DIVIDER;
 
-	if (!test_bit(ENA_FLAG_DEV_UP, &tx_ring->adapter->flags)) {
+	if (!test_bit(ENA_FLAG_DEV_UP, &tx_ring->adapter->flags) ||
+	    test_bit(ENA_FLAG_TRIGGER_RESET, &tx_ring->adapter->flags)) {
 		napi_complete_done(napi, 0);
 		return 0;
 	}
@@ -1713,12 +1718,22 @@ static void ena_down(struct ena_adapter *adapter)
 	adapter->dev_stats.interface_down++;
 	u64_stats_update_end(&adapter->syncp);
 
-	/* After this point the napi handler won't enable the tx queue */
-	ena_napi_disable_all(adapter);
 	netif_carrier_off(adapter->netdev);
 	netif_tx_disable(adapter->netdev);
 
+	/* After this point the napi handler won't enable the tx queue */
+	ena_napi_disable_all(adapter);
+
 	/* After destroy the queue there won't be any new interrupts */
+
+	if (test_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags)) {
+		int rc;
+
+		rc = ena_com_dev_reset(adapter->ena_dev);
+		if (rc)
+			dev_err(&adapter->pdev->dev, "Device reset failed\n");
+	}
+
 	ena_destroy_all_io_queues(adapter);
 
 	ena_disable_io_intr_sync(adapter);
@@ -2081,6 +2096,14 @@ static void ena_netpoll(struct net_device *netdev)
 	struct ena_adapter *adapter = netdev_priv(netdev);
 	int i;
 
+	/* Dont schedule NAPI if the driver is in the middle of reset
+	 * or netdev is down.
+	 */
+
+	if (!test_bit(ENA_FLAG_DEV_UP, &adapter->flags) ||
+	    test_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags))
+		return;
+
 	for (i = 0; i < adapter->num_queues; i++)
 		napi_schedule(&adapter->ena_napi[i].napi);
 }
@@ -2468,6 +2491,14 @@ static void ena_fw_reset_device(struct work_struct *work)
 	bool dev_up, wd_state;
 	int rc;
 
+	if (unlikely(!test_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags))) {
+		dev_err(&pdev->dev,
+			"device reset schedule while reset bit is off\n");
+		return;
+	}
+
+	netif_carrier_off(netdev);
+
 	del_timer_sync(&adapter->timer_service);
 
 	rtnl_lock();
@@ -2481,12 +2512,6 @@ static void ena_fw_reset_device(struct work_struct *work)
 	 */
 	ena_close(netdev);
 
-	rc = ena_com_dev_reset(ena_dev);
-	if (rc) {
-		dev_err(&pdev->dev, "Device reset failed\n");
-		goto err;
-	}
-
 	ena_free_mgmnt_irq(adapter);
 
 	ena_disable_msix(adapter);
@@ -2499,6 +2524,8 @@ static void ena_fw_reset_device(struct work_struct *work)
 
 	ena_com_mmio_reg_read_request_destroy(ena_dev);
 
+	clear_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags);
+
 	/* Finish with the destroy part. Start the init part */
 
 	rc = ena_device_init(ena_dev, adapter->pdev, &get_feat_ctx, &wd_state);
@@ -2562,6 +2589,9 @@ static void check_for_missing_tx_completions(struct ena_adapter *adapter)
 	if (!test_bit(ENA_FLAG_DEV_UP, &adapter->flags))
 		return;
 
+	if (test_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags))
+		return;
+
 	if (adapter->missing_tx_completion_to == ENA_HW_HINTS_NO_TIMEOUT)
 		return;
 
@@ -2703,7 +2733,7 @@ static void ena_timer_service(unsigned long data)
 	if (host_info)
 		ena_update_host_info(host_info, adapter->netdev);
 
-	if (unlikely(test_and_clear_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags))) {
+	if (unlikely(test_bit(ENA_FLAG_TRIGGER_RESET, &adapter->flags))) {
 		netif_err(adapter, drv, adapter->netdev,
 			  "Trigger reset is on\n");
 		ena_dump_stats_to_dmesg(adapter);
-- 
1.9.1
