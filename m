From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 8/8] qlcnic: fix mailbox response handling
Date: Sat,  9 Feb 2013 14:29:55 -0500
Message-ID: <1360438195-12667-9-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1360438195-12667-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:22982 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932529Ab3BITv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Feb 2013 14:51:26 -0500
In-Reply-To: <1360438195-12667-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

o Do not read mailbox registers on timeout
o Add a helper function to handle mailbox response

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   66 ++++++++++++--------
 1 files changed, 40 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 51b4340..f7b39d1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -664,6 +664,21 @@ static void qlcnic_dump_mbx(struct qlcnic_adapter *adapter,
 	pr_info("\n");
 }
 
+/* Mailbox response for mac rcode */
+static u32 qlcnic_83xx_mac_rcode(struct qlcnic_adapter *adapter)
+{
+	u32 fw_data;
+	u8 mac_cmd_rcode;
+
+	fw_data = readl(QLCNIC_MBX_FW(adapter->ahw, 2));
+	mac_cmd_rcode = (u8)fw_data;
+	if (mac_cmd_rcode == QLC_83XX_NO_NIC_RESOURCE ||
+	    mac_cmd_rcode == QLC_83XX_MAC_PRESENT ||
+	    mac_cmd_rcode == QLC_83XX_MAC_ABSENT)
+		return QLCNIC_RCODE_SUCCESS;
+	return 1;
+}
+
 static u32 qlcnic_83xx_mbx_poll(struct qlcnic_adapter *adapter)
 {
 	u32 data;
@@ -686,7 +701,7 @@ int qlcnic_83xx_mbx_op(struct qlcnic_adapter *adapter,
 {
 	int i;
 	u16 opcode;
-	u8 mbx_err_code, mac_cmd_rcode;
+	u8 mbx_err_code;
 	u32 rsp, mbx_val, fw_data, rsp_num, mbx_cmd;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
@@ -722,45 +737,44 @@ int qlcnic_83xx_mbx_op(struct qlcnic_adapter *adapter,
 	QLCWRX(ahw, QLCNIC_HOST_MBX_CTRL, QLCNIC_SET_OWNER);
 poll:
 	rsp = qlcnic_83xx_mbx_poll(adapter);
-	/* Get the FW response data */
-	fw_data = readl(QLCNIC_MBX_FW(ahw, 0));
-	mbx_err_code = QLCNIC_MBX_STATUS(fw_data);
-	rsp_num = QLCNIC_MBX_NUM_REGS(fw_data);
-	opcode = QLCNIC_MBX_RSP(fw_data);
-
 	if (rsp != QLCNIC_RCODE_TIMEOUT) {
+		/* Get the FW response data */
+		fw_data = readl(QLCNIC_MBX_FW(ahw, 0));
 		if (fw_data &  QLCNIC_MBX_ASYNC_EVENT) {
 			qlcnic_83xx_process_aen(adapter);
 			mbx_val = QLCRDX(ahw, QLCNIC_HOST_MBX_CTRL);
 			if (mbx_val)
 				goto poll;
-		} else if ((mbx_err_code == QLCNIC_MBX_RSP_OK) ||
-			   (mbx_err_code == QLCNIC_MBX_PORT_RSP_OK)) {
-			qlcnic_83xx_get_mbx_data(adapter, cmd);
+		}
+		mbx_err_code = QLCNIC_MBX_STATUS(fw_data);
+		rsp_num = QLCNIC_MBX_NUM_REGS(fw_data);
+		opcode = QLCNIC_MBX_RSP(fw_data);
+		qlcnic_83xx_get_mbx_data(adapter, cmd);
+
+		switch (mbx_err_code) {
+		case QLCNIC_MBX_RSP_OK:
+		case QLCNIC_MBX_PORT_RSP_OK:
 			rsp = QLCNIC_RCODE_SUCCESS;
-		} else {
-			qlcnic_83xx_get_mbx_data(adapter, cmd);
+			break;
+		default:
 			if (opcode == QLCNIC_CMD_CONFIG_MAC_VLAN) {
-				fw_data = readl(QLCNIC_MBX_FW(ahw, 2));
-				mac_cmd_rcode = (u8)fw_data;
-				if (mac_cmd_rcode == QLC_83XX_NO_NIC_RESOURCE ||
-				    mac_cmd_rcode == QLC_83XX_MAC_PRESENT ||
-				    mac_cmd_rcode == QLC_83XX_MAC_ABSENT) {
-					rsp = QLCNIC_RCODE_SUCCESS;
+				rsp = qlcnic_83xx_mac_rcode(adapter);
+				if (!rsp)
 					goto out;
-				}
 			}
-			dev_info(&adapter->pdev->dev,
-				 "MBX command 0x%x failed with err:0x%x\n",
-				 opcode, mbx_err_code);
+			dev_err(&adapter->pdev->dev,
+				"MBX command 0x%x failed with err:0x%x\n",
+				opcode, mbx_err_code);
 			rsp = mbx_err_code;
 			qlcnic_dump_mbx(adapter, cmd);
+			break;
 		}
-	} else {
-		dev_info(&adapter->pdev->dev,
-			 "MBX command 0x%x timed out\n", opcode);
-		qlcnic_dump_mbx(adapter, cmd);
+		goto out;
 	}
+
+	dev_err(&adapter->pdev->dev, "MBX command 0x%x timed out\n",
+		QLCNIC_MBX_RSP(mbx_cmd));
+	rsp = QLCNIC_RCODE_TIMEOUT;
 out:
 	/* clear fw mbx control register */
 	QLCWRX(ahw, QLCNIC_FW_MBX_CTRL, QLCNIC_CLR_OWNER);
-- 
1.7.1
