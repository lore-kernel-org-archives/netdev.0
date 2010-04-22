From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/8] qlcnic: fix defines as per IDC document
Date: Thu, 22 Apr 2010 05:51:36 -0700
Message-ID: <1271940702-17064-3-git-send-email-amit.salecha@qlogic.com>
References: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:28789 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754577Ab0DVMvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 08:51:44 -0400
In-Reply-To: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different class of drivers co-exist for CNA device,
there is some minimal interaction that will be required amongst
the drivers for performing some device level operations.

All the driver should follow inter driver coexistence document.

Fixing polling interval and spelling mistake.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hdr.h  |   22 +++++++++++-----------
 drivers/net/qlcnic/qlcnic_main.c |    9 +++++++--
 2 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 51fa3fb..8285a06 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -694,17 +694,18 @@ enum {
 #define QLCNIC_CRB_DRV_STATE               (QLCNIC_CAM_RAM(0x144))
 #define QLCNIC_CRB_DRV_SCRATCH             (QLCNIC_CAM_RAM(0x148))
 #define QLCNIC_CRB_DEV_PARTITION_INFO      (QLCNIC_CAM_RAM(0x14c))
-#define QLCNIC_CRB_DRV_IDC_VER             (QLCNIC_CAM_RAM(0x14c))
+#define QLCNIC_CRB_DRV_IDC_VER		(QLCNIC_CAM_RAM(0x174))
 #define QLCNIC_ROM_DEV_INIT_TIMEOUT	(0x3e885c)
 #define QLCNIC_ROM_DRV_RESET_TIMEOUT	(0x3e8860)
 
-		 /* Device State */
-#define QLCNIC_DEV_COLD 		1
-#define QLCNIC_DEV_INITALIZING		2
-#define QLCNIC_DEV_READY		3
-#define QLCNIC_DEV_NEED_RESET		4
-#define QLCNIC_DEV_NEED_QUISCENT	5
-#define QLCNIC_DEV_FAILED		6
+/* Device State */
+#define QLCNIC_DEV_COLD			0x1
+#define QLCNIC_DEV_INITIALIZING		0x2
+#define QLCNIC_DEV_READY		0x3
+#define QLCNIC_DEV_NEED_RESET		0x4
+#define QLCNIC_DEV_NEED_QUISCENT	0x5
+#define QLCNIC_DEV_FAILED		0x6
+#define QLCNIC_DEV_QUISCENT		0x7
 
 #define QLCNIC_RCODE_DRIVER_INFO		0x20000000
 #define QLCNIC_RCODE_DRIVER_CAN_RELOAD		0x40000000
@@ -712,9 +713,8 @@ enum {
 #define QLCNIC_FWERROR_PEGNUM(code)		((code) & 0xff)
 #define QLCNIC_FWERROR_CODE(code)		((code >> 8) & 0xfffff)
 
-#define FW_POLL_DELAY			(2 * HZ)
-#define FW_FAIL_THRESH			3
-#define FW_POLL_THRESH			10
+#define FW_POLL_DELAY		(1 * HZ)
+#define FW_FAIL_THRESH		2
 
 #define	ISR_MSI_INT_TRIGGER(FUNC) (QLCNIC_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
 #define ISR_LEGACY_INT_TRIGGERED(VAL)	(((VAL) & 0x300) == 0x200)
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 5845dc0..ff7705b 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2054,7 +2054,7 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	switch (prev_state) {
 	case QLCNIC_DEV_COLD:
 start_fw:
-		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITALIZING);
+		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
 		qlcnic_api_unlock(adapter);
 		return 1;
 
@@ -2077,6 +2077,10 @@ start_fw:
 	case QLCNIC_DEV_FAILED:
 		qlcnic_api_unlock(adapter);
 		return -1;
+
+	case QLCNIC_DEV_INITIALIZING:
+	case QLCNIC_DEV_QUISCENT:
+		break;
 	}
 
 	qlcnic_api_unlock(adapter);
@@ -2208,7 +2212,8 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 
 	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
 
-	if (state != QLCNIC_DEV_INITALIZING && state != QLCNIC_DEV_NEED_RESET) {
+	if (state != QLCNIC_DEV_INITIALIZING &&
+					state != QLCNIC_DEV_NEED_RESET) {
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
 		set_bit(__QLCNIC_START_FW, &adapter->state);
 		QLCDB(adapter, DRV, "NEED_RESET state set\n");
-- 
1.6.0.2

