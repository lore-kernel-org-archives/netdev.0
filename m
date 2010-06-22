From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 6/8] qlcnic: offload tx timeout recovery
Date: Tue, 22 Jun 2010 06:19:03 -0700
Message-ID: <1277212745-26857-7-git-send-email-amit.salecha@qlogic.com>
References: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:2022 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754968Ab0FVNTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 09:19:07 -0400
In-Reply-To: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

Offload tx timeout recovery to fw recovery func(check_health).
In check_health, first check health of device, if it its ok, then
do tx timeout recovery otherwise device recovery.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    3 +-
 drivers/net/qlcnic/qlcnic_main.c |   65 ++++++++++++++++++--------------------
 2 files changed, 32 insertions(+), 36 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 5c7d474..6ec34a7 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -934,6 +934,7 @@ struct qlcnic_adapter {
 	u8 rx_csum;
 	u8 portnum;
 	u8 physical_port;
+	u8 reset_context;
 
 	u8 mc_enabled;
 	u8 max_mc_count;
@@ -1001,8 +1002,6 @@ struct qlcnic_adapter {
 
 	struct delayed_work fw_work;
 
-	struct work_struct  tx_timeout_task;
-
 	struct qlcnic_nic_intr_coalesce coal;
 
 	unsigned long state;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index c4602fa..3b71dfc 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -75,7 +75,6 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev);
 static int qlcnic_open(struct net_device *netdev);
 static int qlcnic_close(struct net_device *netdev);
 static void qlcnic_tx_timeout(struct net_device *netdev);
-static void qlcnic_tx_timeout_task(struct work_struct *work);
 static void qlcnic_attach_work(struct work_struct *work);
 static void qlcnic_fwinit_work(struct work_struct *work);
 static void qlcnic_fw_poll_work(struct work_struct *work);
@@ -911,6 +910,7 @@ __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 	qlcnic_linkevent_request(adapter, 1);
 
+	adapter->reset_context = 0;
 	set_bit(__QLCNIC_DEV_UP, &adapter->state);
 	return 0;
 }
@@ -1110,6 +1110,27 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 	return 0;
 }
 
+/* Reset context in hardware only */
+static int
+qlcnic_reset_hw_context(struct qlcnic_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+		return -EBUSY;
+
+	netif_device_detach(netdev);
+
+	qlcnic_down(adapter, netdev);
+
+	qlcnic_up(adapter, netdev);
+
+	netif_device_attach(netdev);
+
+	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	return 0;
+}
+
 int
 qlcnic_reset_context(struct qlcnic_adapter *adapter)
 {
@@ -1178,8 +1199,6 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 
 	netdev->irq = adapter->msix_entries[0].vector;
 
-	INIT_WORK(&adapter->tx_timeout_task, qlcnic_tx_timeout_task);
-
 	if (qlcnic_read_mac_addr(adapter))
 		dev_warn(&pdev->dev, "failed to read mac addr\n");
 
@@ -1350,8 +1369,6 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 
-	cancel_work_sync(&adapter->tx_timeout_task);
-
 	qlcnic_detach(adapter);
 
 	if (adapter->npars != NULL)
@@ -1390,8 +1407,6 @@ static int __qlcnic_shutdown(struct pci_dev *pdev)
 	if (netif_running(netdev))
 		qlcnic_down(adapter, netdev);
 
-	cancel_work_sync(&adapter->tx_timeout_task);
-
 	qlcnic_clr_all_drv_state(adapter);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
@@ -1854,35 +1869,11 @@ static void qlcnic_tx_timeout(struct net_device *netdev)
 		return;
 
 	dev_err(&netdev->dev, "transmit timeout, resetting.\n");
-	schedule_work(&adapter->tx_timeout_task);
-}
-
-static void qlcnic_tx_timeout_task(struct work_struct *work)
-{
-	struct qlcnic_adapter *adapter =
-		container_of(work, struct qlcnic_adapter, tx_timeout_task);
-
-	if (!netif_running(adapter->netdev))
-		return;
-
-	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-		return;
 
 	if (++adapter->tx_timeo_cnt >= QLCNIC_MAX_TX_TIMEOUTS)
-		goto request_reset;
-
-	clear_bit(__QLCNIC_RESETTING, &adapter->state);
-	if (!qlcnic_reset_context(adapter)) {
-		adapter->netdev->trans_start = jiffies;
-		return;
-
-		/* context reset failed, fall through for fw reset */
-	}
-
-request_reset:
-	adapter->need_fw_reset = 1;
-	clear_bit(__QLCNIC_RESETTING, &adapter->state);
-	QLCDB(adapter, DRV, "Resetting adapter\n");
+		adapter->need_fw_reset = 1;
+	else
+		adapter->reset_context = 1;
 }
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
@@ -2540,6 +2531,12 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		adapter->fw_fail_cnt = 0;
 		if (adapter->need_fw_reset)
 			goto detach;
+
+		if (adapter->reset_context) {
+			qlcnic_reset_hw_context(adapter);
+			adapter->netdev->trans_start = jiffies;
+		}
+
 		return 0;
 	}
 
-- 
1.6.0.2

