From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 2/6] qlcnic: Return appropriate error code.
Date: Tue, 30 Jul 2013 21:54:20 -0400
Message-ID: <4b8aa090f215fba7e929d3b97dadd11e82ab0828.1375244889.git.himanshu.madhani@qlogic.com>
References: <cover.1375244889.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:35174 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751784Ab3GaCWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 22:22:07 -0400
In-Reply-To: <cover.1375244889.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Driver should return appropriate error code when diagnotics
loopback test is performed.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  3 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 23 +++++++++++++++-------
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  2 +-
 3 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index ac4160c..469f049 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -953,10 +953,11 @@ struct qlcnic_ipaddr {
 #define QLCNIC_LB_BUCKET_SIZE	32
 
 /* QLCNIC Driver Error Code */
-#define QLCNIC_FW_NOT_RESPOND		51
+#define QLCNIC_FW_RESPONSE_TIMEOUT	51
 #define QLCNIC_TEST_IN_PROGRESS		52
 #define QLCNIC_UNDEFINED_ERROR		53
 #define QLCNIC_LB_CABLE_NOT_CONN	54
+#define QLCNIC_LB_IN_PROGRESS		55
 #define QLCNIC_ILB_MAX_RCV_LOOP	10
 
 struct qlcnic_filter {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 0913c62..48666d4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1652,7 +1652,7 @@ int qlcnic_83xx_loopback_test(struct net_device *netdev, u8 mode)
 	if (ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		netdev_warn(netdev,
 			    "Loopback test not supported in non privileged mode\n");
-		return ret;
+		return -ENOTSUPP;
 	}
 
 	if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
@@ -1686,13 +1686,13 @@ int qlcnic_83xx_loopback_test(struct net_device *netdev, u8 mode)
 		if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
 			netdev_info(netdev,
 				    "Device is resetting, free LB test resources\n");
-			ret = -EIO;
+			ret = -EBUSY;
 			goto free_diag_res;
 		}
 		if (loop++ > QLC_83XX_LB_WAIT_COUNT) {
 			netdev_info(netdev,
 				    "Firmware didn't sent link up event to loopback request\n");
-			ret = -QLCNIC_FW_NOT_RESPOND;
+			ret = -QLCNIC_FW_RESPONSE_TIMEOUT;
 			qlcnic_83xx_clear_lb_mode(adapter, mode);
 			goto free_diag_res;
 		}
@@ -1729,6 +1729,15 @@ int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 		return status;
 
 	config = ahw->port_config;
+
+	/* Check if port is already in loopback mode */
+	if ((config & QLC_83XX_CFG_LOOPBACK_HSS) ||
+	    (config & QLC_83XX_CFG_LOOPBACK_EXT)) {
+		netdev_err(netdev,
+			   "Port already in Loopback mode.\n");
+		return -QLCNIC_LB_IN_PROGRESS;
+	}
+
 	set_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
 
 	if (mode == QLCNIC_ILB_MODE)
@@ -1756,14 +1765,14 @@ int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 			netdev_info(netdev,
 				    "Device is resetting, free LB test resources\n");
 			clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
-			return -EIO;
+			return -EBUSY;
 		}
 		if (loop++ > QLC_83XX_LB_WAIT_COUNT) {
 			netdev_err(netdev,
 				   "Did not receive IDC completion AEN\n");
 			clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
 			qlcnic_83xx_clear_lb_mode(adapter, mode);
-			return -EIO;
+			return -QLCNIC_FW_RESPONSE_TIMEOUT;
 		}
 	} while (test_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status));
 
@@ -1805,14 +1814,14 @@ int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 			netdev_info(netdev,
 				    "Device is resetting, free LB test resources\n");
 			clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
-			return -EIO;
+			return -EBUSY;
 		}
 
 		if (loop++ > QLC_83XX_LB_WAIT_COUNT) {
 			netdev_err(netdev,
 				   "Did not receive IDC completion AEN\n");
 			clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
-			return -EIO;
+			return -QLCNIC_FW_RESPONSE_TIMEOUT;
 		}
 	} while (test_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status));
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 6edebe2..9eb97cd 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -984,7 +984,7 @@ int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 		if (loop++ > QLCNIC_ILB_MAX_RCV_LOOP) {
 			netdev_info(netdev, "firmware didnt respond to loopback"
 				" configure request\n");
-			ret = -QLCNIC_FW_NOT_RESPOND;
+			ret = -QLCNIC_FW_RESPONSE_TIMEOUT;
 			goto free_res;
 		} else if (adapter->ahw->diag_cnt) {
 			ret = adapter->ahw->diag_cnt;
-- 
1.8.1.4
