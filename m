From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 1/5] qlcnic: detect fan failure
Date: Mon, 29 Aug 2011 15:50:26 -0700
Message-ID: <1314658231-30735-1-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:22624
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754103Ab1H2XBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 19:01:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    1 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |    4 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   29 ++++++++++++++++---
 3 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 7c64f2f..59d73f2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -832,7 +832,6 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 		data[3] = qlcnic_loopback_test(dev, QLCNIC_ILB_MODE);
 		if (data[3])
 			eth_test->flags |= ETH_TEST_FL_FAILED;
-
 		if (eth_test->flags & ETH_TEST_FL_EXTERNAL_LB) {
 			data[4] = qlcnic_loopback_test(dev, QLCNIC_ELB_MODE);
 			if (data[4])
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index d14506f..92bc8ce 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -609,6 +609,7 @@ enum {
 	QLCNIC_TEMP_PANIC	/* Fatal error, hardware has shut down. */
 };
 
+
 /* Lock IDs for PHY lock */
 #define PHY_LOCK_DRIVER		0x44524956
 
@@ -723,7 +724,8 @@ enum {
 #define QLCNIC_RCODE_DRIVER_CAN_RELOAD		BIT_30
 #define QLCNIC_RCODE_FATAL_ERROR		BIT_31
 #define QLCNIC_FWERROR_PEGNUM(code)		((code) & 0xff)
-#define QLCNIC_FWERROR_CODE(code)		((code >> 8) & 0xfffff)
+#define QLCNIC_FWERROR_CODE(code)		((code >> 8) & 0x1fffff)
+#define QLCNIC_FWERROR_FAN_FAILURE		0x16
 
 #define FW_POLL_DELAY		(1 * HZ)
 #define FW_FAIL_THRESH		2
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index b447cc5..998bb1d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2928,15 +2928,36 @@ qlcnic_detach_work(struct work_struct *work)
 
 	status = QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1);
 
-	if (status & QLCNIC_RCODE_FATAL_ERROR)
+	if (status & QLCNIC_RCODE_FATAL_ERROR) {
+		dev_err(&adapter->pdev->dev,
+			"Detaching the device: peg halt status1=0x%x\n",
+					status);
+
+		if (QLCNIC_FWERROR_CODE(status) == QLCNIC_FWERROR_FAN_FAILURE) {
+			dev_err(&adapter->pdev->dev,
+			"On board active cooling fan failed. "
+				"Device has been halted.\n");
+			dev_err(&adapter->pdev->dev,
+				"Replace the adapter.\n");
+		}
+
 		goto err_ret;
+	}
 
-	if (adapter->temp == QLCNIC_TEMP_PANIC)
+	if (adapter->temp == QLCNIC_TEMP_PANIC) {
+		dev_err(&adapter->pdev->dev, "Detaching the device: temp=%d\n",
+			adapter->temp);
 		goto err_ret;
+	}
+
 	/* Dont ack if this instance is the reset owner */
 	if (!(adapter->flags & QLCNIC_FW_RESET_OWNER)) {
-		if (qlcnic_set_drv_state(adapter, adapter->dev_state))
+		if (qlcnic_set_drv_state(adapter, adapter->dev_state)) {
+			dev_err(&adapter->pdev->dev,
+				"Failed to set driver state,"
+					"detaching the device.\n");
 			goto err_ret;
+		}
 	}
 
 	adapter->fw_wait_cnt = 0;
@@ -2946,8 +2967,6 @@ qlcnic_detach_work(struct work_struct *work)
 	return;
 
 err_ret:
-	dev_err(&adapter->pdev->dev, "detach failed; status=%d temp=%d\n",
-			status, adapter->temp);
 	netif_device_attach(netdev);
 	qlcnic_clr_all_drv_state(adapter, 1);
 }
-- 
1.6.0.2
