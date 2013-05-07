From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 5/8] qlcnic: Fix reset recovery after transmit timeout
Date: Tue, 7 May 2013 15:55:03 -0400
Message-ID: <1367956506-3290-6-git-send-email-shahed.shaikh@qlogic.com>
References: <1367956506-3290-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe006.messaging.microsoft.com ([216.32.180.189]:45291
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758185Ab3EGUUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 16:20:17 -0400
In-Reply-To: <1367956506-3290-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

o When transmit timeout happens, recovery attempt should start with
  adapter soft reset. If soft reset fails to resume traffic, firmware
  dump will be collected and driver will perform a hard reset of the
  adapter. Reset recovery on 83xx was failing after a hard reset.
  This patch fixes that issue.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   24 ++++++++++++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   15 ++++++++----
 2 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index ab1d8d9..66f355d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -435,10 +435,7 @@ static void qlcnic_83xx_idc_attach_driver(struct qlcnic_adapter *adapter)
 	}
 done:
 	netif_device_attach(netdev);
-	if (netif_running(netdev)) {
-		netif_carrier_on(netdev);
-		netif_wake_queue(netdev);
-	}
+	adapter->netdev->trans_start = jiffies;
 }
 
 static int qlcnic_83xx_idc_enter_failed_state(struct qlcnic_adapter *adapter,
@@ -642,15 +639,22 @@ static int qlcnic_83xx_idc_reattach_driver(struct qlcnic_adapter *adapter)
 
 static void qlcnic_83xx_idc_update_idc_params(struct qlcnic_adapter *adapter)
 {
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
 	qlcnic_83xx_idc_update_drv_presence_reg(adapter, 1, 1);
-	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 	set_bit(QLC_83XX_MBX_READY, &adapter->ahw->idc.status);
 	qlcnic_83xx_idc_update_audit_reg(adapter, 0, 1);
 	set_bit(QLC_83XX_MODULE_LOADED, &adapter->ahw->idc.status);
-	adapter->ahw->idc.quiesce_req = 0;
-	adapter->ahw->idc.delay = QLC_83XX_IDC_FW_POLL_DELAY;
-	adapter->ahw->idc.err_code = 0;
-	adapter->ahw->idc.collect_dump = 0;
+
+	ahw->idc.quiesce_req = 0;
+	ahw->idc.delay = QLC_83XX_IDC_FW_POLL_DELAY;
+	ahw->idc.err_code = 0;
+	ahw->idc.collect_dump = 0;
+	ahw->reset_context = 0;
+	adapter->tx_timeo_cnt = 0;
+	adapter->netdev->trans_start = jiffies;
+
+	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 }
 
 /**
@@ -851,6 +855,7 @@ static int qlcnic_83xx_idc_ready_state(struct qlcnic_adapter *adapter)
 	/* Check for soft reset request */
 	if (ahw->reset_context &&
 	    !(val & QLC_83XX_IDC_DISABLE_FW_RESET_RECOVERY)) {
+		adapter->ahw->reset_context = 0;
 		qlcnic_83xx_idc_tx_soft_reset(adapter);
 		return ret;
 	}
@@ -914,6 +919,7 @@ static int qlcnic_83xx_idc_need_quiesce_state(struct qlcnic_adapter *adapter)
 static int qlcnic_83xx_idc_failed_state(struct qlcnic_adapter *adapter)
 {
 	dev_err(&adapter->pdev->dev, "%s: please restart!!\n", __func__);
+	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 	adapter->ahw->idc.err_code = -EIO;
 
 	return 0;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index d97446a..8fb836d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2502,12 +2502,17 @@ static void qlcnic_tx_timeout(struct net_device *netdev)
 	if (test_bit(__QLCNIC_RESETTING, &adapter->state))
 		return;
 
-	dev_err(&netdev->dev, "transmit timeout, resetting.\n");
-
-	if (++adapter->tx_timeo_cnt >= QLCNIC_MAX_TX_TIMEOUTS)
-		adapter->need_fw_reset = 1;
-	else
+	if (++adapter->tx_timeo_cnt >= QLCNIC_MAX_TX_TIMEOUTS) {
+		netdev_info(netdev, "Tx timeout, reset the adapter.\n");
+		if (qlcnic_82xx_check(adapter))
+			adapter->need_fw_reset = 1;
+		else if (qlcnic_83xx_check(adapter))
+			qlcnic_83xx_idc_request_reset(adapter,
+						      QLCNIC_FORCE_FW_DUMP_KEY);
+	} else {
+		netdev_info(netdev, "Tx timeout, reset adapter context.\n");
 		adapter->ahw->reset_context = 1;
+	}
 }
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
-- 
1.5.6
