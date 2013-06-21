From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 3/8] qlcnic: Minimize sleep duration within loopback diagnostic test.
Date: Fri, 21 Jun 2013 12:30:56 -0400
Message-ID: <1371832261-18930-4-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1371832261-18930-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:2499
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423380Ab3FUQ5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 12:57:49 -0400
In-Reply-To: <1371832261-18930-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

o Minimize sleep duration and check for adapter status.
o Exit from loopback test if adapter reset is detected.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   57 +++++++++++++------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    3 +-
 2 files changed, 41 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index a0248b7..48fdaff 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1676,13 +1676,19 @@ int qlcnic_83xx_loopback_test(struct net_device *netdev, u8 mode)
 
 	/* Poll for link up event before running traffic */
 	do {
-		msleep(500);
+		msleep(QLC_83XX_LB_MSLEEP_COUNT);
 		if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
 			qlcnic_83xx_process_aen(adapter);
 
-		if (loop++ > QLCNIC_ILB_MAX_RCV_LOOP) {
-			dev_info(&adapter->pdev->dev,
-				 "Firmware didn't sent link up event to loopback request\n");
+		if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
+			netdev_info(netdev,
+				    "Device is resetting, free LB test resources\n");
+			ret = -EIO;
+			goto free_diag_res;
+		}
+		if (loop++ > QLC_83XX_LB_WAIT_COUNT) {
+			netdev_info(netdev,
+				    "Firmware didn't sent link up event to loopback request\n");
 			ret = -QLCNIC_FW_NOT_RESPOND;
 			qlcnic_83xx_clear_lb_mode(adapter, mode);
 			goto free_diag_res;
@@ -1711,6 +1717,7 @@ fail_diag_alloc:
 int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct net_device *netdev = adapter->netdev;
 	int status = 0, loop = 0;
 	u32 config;
 
@@ -1728,9 +1735,9 @@ int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 
 	status = qlcnic_83xx_set_port_config(adapter);
 	if (status) {
-		dev_err(&adapter->pdev->dev,
-			"Failed to Set Loopback Mode = 0x%x.\n",
-			ahw->port_config);
+		netdev_err(netdev,
+			   "Failed to Set Loopback Mode = 0x%x.\n",
+			   ahw->port_config);
 		ahw->port_config = config;
 		clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
 		return status;
@@ -1738,13 +1745,19 @@ int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 
 	/* Wait for Link and IDC Completion AEN */
 	do {
-		msleep(300);
+		msleep(QLC_83XX_LB_MSLEEP_COUNT);
 		if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
 			qlcnic_83xx_process_aen(adapter);
 
-		if (loop++ > QLCNIC_ILB_MAX_RCV_LOOP) {
-			dev_err(&adapter->pdev->dev,
-				"FW did not generate IDC completion AEN\n");
+		if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
+			netdev_info(netdev,
+				    "Device is resetting, free LB test resources\n");
+			clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
+			return -EIO;
+		}
+		if (loop++ > QLC_83XX_LB_WAIT_COUNT) {
+			netdev_err(netdev,
+				   "Did not receive IDC completion AEN\n");
 			clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
 			qlcnic_83xx_clear_lb_mode(adapter, mode);
 			return -EIO;
@@ -1759,6 +1772,7 @@ int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct net_device *netdev = adapter->netdev;
 	int status = 0, loop = 0;
 	u32 config = ahw->port_config;
 
@@ -1770,9 +1784,9 @@ int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 
 	status = qlcnic_83xx_set_port_config(adapter);
 	if (status) {
-		dev_err(&adapter->pdev->dev,
-			"Failed to Clear Loopback Mode = 0x%x.\n",
-			ahw->port_config);
+		netdev_err(netdev,
+			   "Failed to Clear Loopback Mode = 0x%x.\n",
+			   ahw->port_config);
 		ahw->port_config = config;
 		clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
 		return status;
@@ -1780,13 +1794,20 @@ int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 
 	/* Wait for Link and IDC Completion AEN */
 	do {
-		msleep(300);
+		msleep(QLC_83XX_LB_MSLEEP_COUNT);
 		if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
 			qlcnic_83xx_process_aen(adapter);
 
-		if (loop++ > QLCNIC_ILB_MAX_RCV_LOOP) {
-			dev_err(&adapter->pdev->dev,
-				"Firmware didn't sent IDC completion AEN\n");
+		if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
+			netdev_info(netdev,
+				    "Device is resetting, free LB test resources\n");
+			clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
+			return -EIO;
+		}
+
+		if (loop++ > QLC_83XX_LB_WAIT_COUNT) {
+			netdev_err(netdev,
+				   "Did not receive IDC completion AEN\n");
 			clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
 			return -EIO;
 		}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index e821ee4..e356ee8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -36,7 +36,8 @@
 #define QLC_83XX_MAX_DRV_LOCK_RECOVERY_ATTEMPT		3
 #define QLC_83XX_DRV_LOCK_RECOVERY_DELAY		200
 #define QLC_83XX_DRV_LOCK_RECOVERY_STATUS_MASK		0x3
-
+#define QLC_83XX_LB_WAIT_COUNT				250
+#define QLC_83XX_LB_MSLEEP_COUNT			20
 #define QLC_83XX_NO_NIC_RESOURCE	0x5
 #define QLC_83XX_MAC_PRESENT		0xC
 #define QLC_83XX_MAC_ABSENT		0xD
-- 
1.7.1
