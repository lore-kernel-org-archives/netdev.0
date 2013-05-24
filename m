From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 08/12] qlcnic: modify reset recovery path in diag mode
Date: Fri, 24 May 2013 03:04:32 -0400
Message-ID: <1369379076-4718-9-git-send-email-shahed.shaikh@qlogic.com>
References: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0185.outbound.messaging.microsoft.com ([213.199.154.185]:53674
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759944Ab3EXHaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:30:05 -0400
In-Reply-To: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Provide diagnostics routines enough time to unwind before
proceeding with reset recovery.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    6 +++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   35 ++++++++++++++++----
 3 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 3e8941a..765fee5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1473,7 +1473,6 @@ int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
 void qlcnic_update_cmd_producer(struct qlcnic_host_tx_ring *);
 
 /* Functions from qlcnic_ethtool.c */
-
 int qlcnic_check_loopback_buff(unsigned char *, u8 []);
 int qlcnic_do_lb_test(struct qlcnic_adapter *, u8);
 int qlcnic_loopback_test(struct net_device *, u8);
@@ -1891,6 +1890,11 @@ static inline void qlcnic_release_diag_lock(struct qlcnic_adapter *adapter)
 	clear_bit(__QLCNIC_DIAG_MODE, &adapter->state);
 }
 
+static inline int qlcnic_check_diag_status(struct qlcnic_adapter *adapter)
+{
+	return test_bit(__QLCNIC_DIAG_MODE, &adapter->state);
+}
+
 extern const struct ethtool_ops qlcnic_sriov_vf_ethtool_ops;
 extern const struct ethtool_ops qlcnic_ethtool_ops;
 extern const struct ethtool_ops qlcnic_ethtool_failed_ops;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index f5db67f..1bfe283 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -314,6 +314,7 @@ struct qlc_83xx_idc {
 	u8		vnic_state;
 	u8		vnic_wait_limit;
 	u8		quiesce_req;
+	u8		delay_reset;
 	char		**name;
 };
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index c67d1eb..fe18730 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -651,6 +651,7 @@ static void qlcnic_83xx_idc_update_idc_params(struct qlcnic_adapter *adapter)
 	ahw->idc.collect_dump = 0;
 	ahw->reset_context = 0;
 	adapter->tx_timeo_cnt = 0;
+	ahw->idc.delay_reset = 0;
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 }
@@ -885,21 +886,41 @@ static int qlcnic_83xx_idc_need_reset_state(struct qlcnic_adapter *adapter)
 	int ret = 0;
 
 	if (adapter->ahw->idc.prev_state != QLC_83XX_IDC_DEV_NEED_RESET) {
-		qlcnic_83xx_idc_update_drv_ack_reg(adapter, 1, 1);
 		qlcnic_83xx_idc_update_audit_reg(adapter, 0, 1);
 		set_bit(__QLCNIC_RESETTING, &adapter->state);
 		clear_bit(QLC_83XX_MBX_READY, &adapter->ahw->idc.status);
 		if (adapter->ahw->nic_mode == QLC_83XX_VIRTUAL_NIC_MODE)
 			qlcnic_83xx_disable_vnic_mode(adapter, 1);
-		qlcnic_83xx_idc_detach_driver(adapter);
+
+		if (qlcnic_check_diag_status(adapter)) {
+			dev_info(&adapter->pdev->dev,
+				 "%s: Wait for diag completion\n", __func__);
+			adapter->ahw->idc.delay_reset = 1;
+			return 0;
+		} else {
+			qlcnic_83xx_idc_update_drv_ack_reg(adapter, 1, 1);
+			qlcnic_83xx_idc_detach_driver(adapter);
+		}
 	}
 
-	/* Check ACK from other functions */
-	ret = qlcnic_83xx_idc_check_reset_ack_reg(adapter);
-	if (ret) {
+	if (qlcnic_check_diag_status(adapter)) {
 		dev_info(&adapter->pdev->dev,
-			 "%s: Waiting for reset ACK\n", __func__);
-		return 0;
+			 "%s: Wait for diag completion\n", __func__);
+		return  -1;
+	} else {
+		if (adapter->ahw->idc.delay_reset) {
+			qlcnic_83xx_idc_update_drv_ack_reg(adapter, 1, 1);
+			qlcnic_83xx_idc_detach_driver(adapter);
+			adapter->ahw->idc.delay_reset = 0;
+		}
+
+		/* Check for ACK from other functions */
+		ret = qlcnic_83xx_idc_check_reset_ack_reg(adapter);
+		if (ret) {
+			dev_info(&adapter->pdev->dev,
+				 "%s: Waiting for reset ACK\n", __func__);
+			return -1;
+		}
 	}
 
 	/* Transit to INIT state and restart the HW */
-- 
1.5.6
