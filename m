From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 6/9] qlcnic: Fix recurring firmware dump collection
Date: Sat, 13 Apr 2013 13:28:31 -0400
Message-ID: <1365874114-6759-7-git-send-email-shahed.shaikh@qlogic.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:62768 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753088Ab3DMRwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 13:52:50 -0400
In-Reply-To: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Firmware dump is collected after a non-recoverable Tx timeout error.
Reset dump collection flag and context reset flag in virtual NIC
mode to prevent recurring dump collection and context resets.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    3 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   11 ++++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index c302d11..ad3ac82 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -641,6 +641,7 @@ static void qlcnic_83xx_idc_update_idc_params(struct qlcnic_adapter *adapter)
 	adapter->ahw->idc.delay = QLC_83XX_IDC_FW_POLL_DELAY;
 	adapter->ahw->idc.err_code = 0;
 	adapter->ahw->idc.collect_dump = 0;
+	adapter->ahw->reset_context = 0;
 }
 
 /**
@@ -691,6 +692,8 @@ int qlcnic_83xx_idc_vnic_pf_entry(struct qlcnic_adapter *adapter)
 	/* Privileged function waits till mgmt function enables VNIC mode */
 	state = QLCRDX(adapter->ahw, QLC_83XX_VNIC_STATE);
 	if (state != QLCNIC_DEV_NPAR_OPER) {
+		adapter->ahw->idc.collect_dump = 0;
+		adapter->ahw->reset_context = 0;
 		if (!ahw->idc.vnic_wait_limit--) {
 			qlcnic_83xx_idc_enter_failed_state(adapter, 1);
 			return -EIO;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index e0598cc..2a72c4f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2378,10 +2378,15 @@ static void qlcnic_tx_timeout(struct net_device *netdev)
 
 	dev_err(&netdev->dev, "transmit timeout, resetting.\n");
 
-	if (++adapter->tx_timeo_cnt >= QLCNIC_MAX_TX_TIMEOUTS)
-		adapter->need_fw_reset = 1;
-	else
+	if (++adapter->tx_timeo_cnt >= QLCNIC_MAX_TX_TIMEOUTS) {
+		if (qlcnic_82xx_check(adapter))
+			adapter->need_fw_reset = 1;
+		else if (qlcnic_83xx_check(adapter))
+			qlcnic_dev_request_reset(adapter,
+						 QLCNIC_FORCE_FW_DUMP_KEY);
+	} else {
 		adapter->ahw->reset_context = 1;
+	}
 }
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
-- 
1.5.6
