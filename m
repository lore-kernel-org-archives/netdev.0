From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 4/5] netxen: fix tx timeout recovery
Date: Fri, 11 Sep 2009 14:28:14 -0700
Message-ID: <1252704495-16118-5-git-send-email-dhananjay@netxen.com>
References: <1252704495-16118-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@qlogic.com>,
	Amit Kumar Salecha <amit@netxen.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43925 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756894AbZIKV2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 17:28:13 -0400
In-Reply-To: <1252704495-16118-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@qlogic.com>

Redesign tx timeout handling in line with new firmware
reset design that co-ordinates with other PCI function
drivers.

o For NX3031, first try to reset PCI function's own
  context before requesting firmware reset.

o For NX2031, since firmware heartbit is not supported
  directly request firmware reset.

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    4 +-
 drivers/net/netxen/netxen_nic_init.c |    4 +-
 drivers/net/netxen/netxen_nic_main.c |   69 ++++++++++++++++++++++++++++-----
 3 files changed, 64 insertions(+), 13 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 7e3d2b9..1ae46e8 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -178,6 +178,7 @@
 
 #define MAX_BUFFERS_PER_CMD	32
 #define TX_STOP_THRESH		((MAX_SKB_FRAGS >> 2) + 4)
+#define NX_MAX_TX_TIMEOUTS	2
 
 /*
  * Following are the states of the Phantom. Phantom will set them and
@@ -1145,7 +1146,8 @@ struct netxen_adapter {
 	u8 link_changed;
 	u8 fw_wait_cnt;
 	u8 fw_fail_cnt;
-	u16 resv4;
+	u8 tx_timeo_cnt;
+	u8 need_fw_reset;
 
 	u8 has_link_events;
 	u8 fw_type;
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 8926b0e..128d1b6 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1434,8 +1434,10 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 
 		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev)) {
 			__netif_tx_lock(tx_ring->txq, smp_processor_id());
-			if (netxen_tx_avail(tx_ring) > TX_STOP_THRESH)
+			if (netxen_tx_avail(tx_ring) > TX_STOP_THRESH) {
 				netif_wake_queue(netdev);
+				adapter->tx_timeo_cnt = 0;
+			}
 			__netif_tx_unlock(tx_ring->txq);
 		}
 	}
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 4668a72..2b1b939 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -66,7 +66,7 @@ static int netxen_nic_close(struct net_device *netdev);
 static netdev_tx_t netxen_nic_xmit_frame(struct sk_buff *,
 					       struct net_device *);
 static void netxen_tx_timeout(struct net_device *netdev);
-static void netxen_reset_task(struct work_struct *work);
+static void netxen_tx_timeout_task(struct work_struct *work);
 static void netxen_fw_poll_work(struct work_struct *work);
 static void netxen_schedule_work(struct netxen_adapter *adapter,
 		work_func_t func, int delay);
@@ -875,6 +875,8 @@ wait_init:
 
 	netxen_check_options(adapter);
 
+	adapter->need_fw_reset = 0;
+
 	/* fall through and release firmware */
 
 err_out:
@@ -1183,7 +1185,7 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 
 	netdev->irq = adapter->msix_entries[0].vector;
 
-	INIT_WORK(&adapter->tx_timeout_task, netxen_reset_task);
+	INIT_WORK(&adapter->tx_timeout_task, netxen_tx_timeout_task);
 
 	if (netxen_read_mac_addr(adapter))
 		dev_warn(&pdev->dev, "failed to read mac addr\n");
@@ -1882,7 +1884,7 @@ static void netxen_tx_timeout(struct net_device *netdev)
 	schedule_work(&adapter->tx_timeout_task);
 }
 
-static void netxen_reset_task(struct work_struct *work)
+static void netxen_tx_timeout_task(struct work_struct *work)
 {
 	struct netxen_adapter *adapter =
 		container_of(work, struct netxen_adapter, tx_timeout_task);
@@ -1890,15 +1892,37 @@ static void netxen_reset_task(struct work_struct *work)
 	if (!netif_running(adapter->netdev))
 		return;
 
-	if (test_bit(__NX_RESETTING, &adapter->state))
+	if (test_and_set_bit(__NX_RESETTING, &adapter->state))
 		return;
 
-	netxen_napi_disable(adapter);
+	if (++adapter->tx_timeo_cnt >= NX_MAX_TX_TIMEOUTS)
+		goto request_reset;
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+		/* try to scrub interrupt */
+		netxen_napi_disable(adapter);
 
-	adapter->netdev->trans_start = jiffies;
+		adapter->netdev->trans_start = jiffies;
 
-	netxen_napi_enable(adapter);
-	netif_wake_queue(adapter->netdev);
+		netxen_napi_enable(adapter);
+
+		netif_wake_queue(adapter->netdev);
+
+		goto done;
+
+	} else {
+		if (!netxen_nic_reset_context(adapter)) {
+			adapter->netdev->trans_start = jiffies;
+			goto done;
+		}
+
+		/* context reset failed, fall through for fw reset */
+	}
+
+request_reset:
+	adapter->need_fw_reset = 1;
+done:
+	clear_bit(__NX_RESETTING, &adapter->state);
 }
 
 struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
@@ -2048,6 +2072,22 @@ nx_decr_dev_ref_cnt(struct netxen_adapter *adapter)
 	return count;
 }
 
+static void
+nx_dev_request_reset(struct netxen_adapter *adapter)
+{
+	u32 state;
+
+	if (netxen_api_lock(adapter))
+		return;
+
+	state = NXRD32(adapter, NX_CRB_DEV_STATE);
+
+	if (state != NX_DEV_INITALIZING)
+		NXWR32(adapter, NX_CRB_DEV_STATE, NX_DEV_NEED_RESET);
+
+	netxen_api_unlock(adapter);
+}
+
 static int
 netxen_can_start_firmware(struct netxen_adapter *adapter)
 {
@@ -2133,9 +2173,11 @@ netxen_fwinit_work(struct work_struct *work)
 	switch (dev_state) {
 	case NX_DEV_COLD:
 	case NX_DEV_READY:
-		netxen_start_firmware(adapter);
-		netxen_schedule_work(adapter, netxen_attach_work, 0);
-		return;
+		if (!netxen_start_firmware(adapter)) {
+			netxen_schedule_work(adapter, netxen_attach_work, 0);
+			return;
+		}
+		break;
 
 	case NX_DEV_INITALIZING:
 		if (++adapter->fw_wait_cnt < FW_POLL_THRESH) {
@@ -2195,6 +2237,11 @@ netxen_check_health(struct netxen_adapter *adapter)
 	if (netxen_nic_check_temp(adapter))
 		goto detach;
 
+	if (adapter->need_fw_reset) {
+		nx_dev_request_reset(adapter);
+		goto detach;
+	}
+
 	state = NXRD32(adapter, NX_CRB_DEV_STATE);
 	if (state == NX_DEV_NEED_RESET)
 		goto detach;
-- 
1.6.0.2

