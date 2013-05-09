From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net v2 7/8] qlcnic: Fix mailbox response handling.
Date: Thu, 9 May 2013 15:25:15 -0400
Message-ID: <1368127516-9943-8-git-send-email-shahed.shaikh@qlogic.com>
References: <1368127516-9943-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:4019
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752918Ab3EITuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 15:50:06 -0400
In-Reply-To: <1368127516-9943-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Fix mailbox response poll time to maximum 5 seconds which
  includes mailbox response time as well as time required for
  processing AEN if any.
o Driver need to read firmware control mailbox register instead
  of host control mailbox register.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   13 +++++--------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    2 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    8 +++-----
 4 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 7b5cb61..b4ff1e3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -696,15 +696,14 @@ u32 qlcnic_83xx_mac_rcode(struct qlcnic_adapter *adapter)
 	return 1;
 }
 
-u32 qlcnic_83xx_mbx_poll(struct qlcnic_adapter *adapter)
+u32 qlcnic_83xx_mbx_poll(struct qlcnic_adapter *adapter, u32 *wait_time)
 {
 	u32 data;
-	unsigned long wait_time = 0;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	/* wait for mailbox completion */
 	do {
 		data = QLCRDX(ahw, QLCNIC_FW_MBX_CTRL);
-		if (++wait_time > QLCNIC_MBX_TIMEOUT) {
+		if (++(*wait_time) > QLCNIC_MBX_TIMEOUT) {
 			data = QLCNIC_RCODE_TIMEOUT;
 			break;
 		}
@@ -720,8 +719,8 @@ int qlcnic_83xx_mbx_op(struct qlcnic_adapter *adapter,
 	u16 opcode;
 	u8 mbx_err_code;
 	unsigned long flags;
-	u32 rsp, mbx_val, fw_data, rsp_num, mbx_cmd;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	u32 rsp, mbx_val, fw_data, rsp_num, mbx_cmd, wait_time = 0;
 
 	opcode = LSW(cmd->req.arg[0]);
 	if (!test_bit(QLC_83XX_MBX_READY, &adapter->ahw->idc.status)) {
@@ -754,15 +753,13 @@ int qlcnic_83xx_mbx_op(struct qlcnic_adapter *adapter,
 	/* Signal FW about the impending command */
 	QLCWRX(ahw, QLCNIC_HOST_MBX_CTRL, QLCNIC_SET_OWNER);
 poll:
-	rsp = qlcnic_83xx_mbx_poll(adapter);
+	rsp = qlcnic_83xx_mbx_poll(adapter, &wait_time);
 	if (rsp != QLCNIC_RCODE_TIMEOUT) {
 		/* Get the FW response data */
 		fw_data = readl(QLCNIC_MBX_FW(ahw, 0));
 		if (fw_data &  QLCNIC_MBX_ASYNC_EVENT) {
 			__qlcnic_83xx_process_aen(adapter);
-			mbx_val = QLCRDX(ahw, QLCNIC_HOST_MBX_CTRL);
-			if (mbx_val)
-				goto poll;
+			goto poll;
 		}
 		mbx_err_code = QLCNIC_MBX_STATUS(fw_data);
 		rsp_num = QLCNIC_MBX_NUM_REGS(fw_data);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index faf5553..f5db67f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -620,7 +620,7 @@ int qlcnic_83xx_flash_test(struct qlcnic_adapter *);
 int qlcnic_83xx_enable_flash_write(struct qlcnic_adapter *);
 int qlcnic_83xx_disable_flash_write(struct qlcnic_adapter *);
 u32 qlcnic_83xx_mac_rcode(struct qlcnic_adapter *);
-u32 qlcnic_83xx_mbx_poll(struct qlcnic_adapter *);
+u32 qlcnic_83xx_mbx_poll(struct qlcnic_adapter *, u32 *);
 void qlcnic_83xx_enable_mbx_poll(struct qlcnic_adapter *);
 void qlcnic_83xx_disable_mbx_poll(struct qlcnic_adapter *);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index 95b1b57..b6818f4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -134,7 +134,7 @@ struct qlcnic_mailbox_metadata {
 
 #define QLCNIC_SET_OWNER        1
 #define QLCNIC_CLR_OWNER        0
-#define QLCNIC_MBX_TIMEOUT      10000
+#define QLCNIC_MBX_TIMEOUT      5000
 
 #define QLCNIC_MBX_RSP_OK	1
 #define QLCNIC_MBX_PORT_RSP_OK	0x1a
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 44d547d..3869c38 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -280,9 +280,9 @@ void qlcnic_sriov_cleanup(struct qlcnic_adapter *adapter)
 static int qlcnic_sriov_post_bc_msg(struct qlcnic_adapter *adapter, u32 *hdr,
 				    u32 *pay, u8 pci_func, u8 size)
 {
+	u32 rsp, mbx_val, fw_data, rsp_num, mbx_cmd, val, wait_time = 0;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	unsigned long flags;
-	u32 rsp, mbx_val, fw_data, rsp_num, mbx_cmd, val;
 	u16 opcode;
 	u8 mbx_err_code;
 	int i, j;
@@ -330,15 +330,13 @@ static int qlcnic_sriov_post_bc_msg(struct qlcnic_adapter *adapter, u32 *hdr,
 	 * assume something is wrong.
 	 */
 poll:
-	rsp = qlcnic_83xx_mbx_poll(adapter);
+	rsp = qlcnic_83xx_mbx_poll(adapter, &wait_time);
 	if (rsp != QLCNIC_RCODE_TIMEOUT) {
 		/* Get the FW response data */
 		fw_data = readl(QLCNIC_MBX_FW(ahw, 0));
 		if (fw_data &  QLCNIC_MBX_ASYNC_EVENT) {
 			__qlcnic_83xx_process_aen(adapter);
-			mbx_val = QLCRDX(ahw, QLCNIC_HOST_MBX_CTRL);
-			if (mbx_val)
-				goto poll;
+			goto poll;
 		}
 		mbx_err_code = QLCNIC_MBX_STATUS(fw_data);
 		rsp_num = QLCNIC_MBX_NUM_REGS(fw_data);
-- 
1.5.6
