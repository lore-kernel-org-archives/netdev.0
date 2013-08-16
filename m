From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 3/5] qlcnic: Loopback Inter Driver Communication AEN handler
Date: Fri, 16 Aug 2013 19:07:15 -0400
Message-ID: <cfdc3288f52e9e128846c4ed5d44891ed5b8cf3c.1376720973.git.himanshu.madhani@qlogic.com>
References: <cover.1376720973.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51217 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754057Ab3HQAAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 20:00:25 -0400
In-Reply-To: <cover.1376720973.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Loopback initiator function drivers should process loopback time extend AEN.
  These AENs are triggered by the loopback time extend mailbox command
  issued by the target function drivers.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 45 +++++++++++++++++-----
 2 files changed, 37 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 9ae5d2e..86dd695 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -467,6 +467,7 @@ struct qlcnic_hardware_context {
 	u32 mbox_aen[QLC_83XX_MBX_AEN_CNT];
 	u32 mbox_reg[4];
 	struct qlcnic_mailbox *mailbox;
+	u8 extend_lb_time;
 };
 
 struct qlcnic_adapter_stats {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 78ca755..6b8e903 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -860,9 +860,9 @@ static void qlcnic_83xx_handle_idc_comp_aen(struct qlcnic_adapter *adapter,
 
 void __qlcnic_83xx_process_aen(struct qlcnic_adapter *adapter)
 {
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u32 event[QLC_83XX_MBX_AEN_CNT];
 	int i;
-	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	for (i = 0; i < QLC_83XX_MBX_AEN_CNT; i++)
 		event[i] = readl(QLCNIC_MBX_FW(ahw, i));
@@ -882,6 +882,7 @@ void __qlcnic_83xx_process_aen(struct qlcnic_adapter *adapter)
 				   &adapter->idc_aen_work, 0);
 		break;
 	case QLCNIC_MBX_TIME_EXTEND_EVENT:
+		ahw->extend_lb_time = event[1] >> 8 & 0xf;
 		break;
 	case QLCNIC_MBX_BC_EVENT:
 		qlcnic_sriov_handle_bc_event(adapter, event[1]);
@@ -1706,13 +1707,28 @@ fail_diag_alloc:
 	return ret;
 }
 
+static void qlcnic_extend_lb_idc_cmpltn_wait(struct qlcnic_adapter *adapter,
+					     u32 *max_wait_count)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	int temp;
+
+	netdev_info(adapter->netdev, "Recieved loopback IDC time extend event for 0x%x seconds\n",
+		    ahw->extend_lb_time);
+	temp = ahw->extend_lb_time * 1000;
+	*max_wait_count += temp / QLC_83XX_LB_MSLEEP_COUNT;
+	ahw->extend_lb_time = 0;
+}
+
 int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct net_device *netdev = adapter->netdev;
+	u32 config, max_wait_count;
 	int status = 0, loop = 0;
-	u32 config;
 
+	ahw->extend_lb_time = 0;
+	max_wait_count = QLC_83XX_LB_WAIT_COUNT;
 	status = qlcnic_83xx_get_port_config(adapter);
 	if (status)
 		return status;
@@ -1754,9 +1770,14 @@ int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 			clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
 			return -EBUSY;
 		}
-		if (loop++ > QLC_83XX_LB_WAIT_COUNT) {
-			netdev_err(netdev,
-				   "Did not receive IDC completion AEN\n");
+
+		if (ahw->extend_lb_time)
+			qlcnic_extend_lb_idc_cmpltn_wait(adapter,
+							 &max_wait_count);
+
+		if (loop++ > max_wait_count) {
+			netdev_err(netdev, "%s: Did not receive loopback IDC completion AEN\n",
+				   __func__);
 			clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
 			qlcnic_83xx_clear_lb_mode(adapter, mode);
 			return -ETIMEDOUT;
@@ -1771,10 +1792,12 @@ int qlcnic_83xx_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	u32 config = ahw->port_config, max_wait_count;
 	struct net_device *netdev = adapter->netdev;
 	int status = 0, loop = 0;
-	u32 config = ahw->port_config;
 
+	ahw->extend_lb_time = 0;
+	max_wait_count = QLC_83XX_LB_WAIT_COUNT;
 	set_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
 	if (mode == QLCNIC_ILB_MODE)
 		ahw->port_config &= ~QLC_83XX_CFG_LOOPBACK_HSS;
@@ -1802,9 +1825,13 @@ int qlcnic_83xx_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
 			return -EBUSY;
 		}
 
-		if (loop++ > QLC_83XX_LB_WAIT_COUNT) {
-			netdev_err(netdev,
-				   "Did not receive IDC completion AEN\n");
+		if (ahw->extend_lb_time)
+			qlcnic_extend_lb_idc_cmpltn_wait(adapter,
+							 &max_wait_count);
+
+		if (loop++ > max_wait_count) {
+			netdev_err(netdev, "%s: Did not receive loopback IDC completion AEN\n",
+				   __func__);
 			clear_bit(QLC_83XX_IDC_COMP_AEN, &ahw->idc.status);
 			return -ETIMEDOUT;
 		}
-- 
1.8.1.4
