From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 2/7] qlcnic: Take EPORT out of reset sequence before disabling PAUSE
Date: Wed, 24 Apr 2013 18:42:40 -0400
Message-ID: <1366843365-2787-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:10502
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932166Ab3DXXHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 19:07:03 -0400
In-Reply-To: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Disabling PAUSE requires access to EPORT registers,
  which may cause a wedge, if EPORT is in reset.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   25 ++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 6ea3a09..ab1d8d9 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -25,6 +25,17 @@
 #define QLC_83XX_OPCODE_TMPL_END		0x0080
 #define QLC_83XX_OPCODE_POLL_READ_LIST		0x0100
 
+/* EPORT control registers */
+#define QLC_83XX_RESET_CONTROL			0x28084E50
+#define QLC_83XX_RESET_REG			0x28084E60
+#define QLC_83XX_RESET_PORT0			0x28084E70
+#define QLC_83XX_RESET_PORT1			0x28084E80
+#define QLC_83XX_RESET_PORT2			0x28084E90
+#define QLC_83XX_RESET_PORT3			0x28084EA0
+#define QLC_83XX_RESET_SRESHIM			0x28084EB0
+#define QLC_83XX_RESET_EPGSHIM			0x28084EC0
+#define QLC_83XX_RESET_ETHERPCS			0x28084ED0
+
 static int qlcnic_83xx_init_default_driver(struct qlcnic_adapter *adapter);
 static int qlcnic_83xx_check_heartbeat(struct qlcnic_adapter *p_dev);
 static int qlcnic_83xx_restart_hw(struct qlcnic_adapter *adapter);
@@ -1374,6 +1385,19 @@ static void qlcnic_83xx_disable_pause_frames(struct qlcnic_adapter *adapter)
 	qlcnic_83xx_unlock_driver(adapter);
 }
 
+static void qlcnic_83xx_take_eport_out_of_reset(struct qlcnic_adapter *adapter)
+{
+	QLCWR32(adapter, QLC_83XX_RESET_REG, 0);
+	QLCWR32(adapter, QLC_83XX_RESET_PORT0, 0);
+	QLCWR32(adapter, QLC_83XX_RESET_PORT1, 0);
+	QLCWR32(adapter, QLC_83XX_RESET_PORT2, 0);
+	QLCWR32(adapter, QLC_83XX_RESET_PORT3, 0);
+	QLCWR32(adapter, QLC_83XX_RESET_SRESHIM, 0);
+	QLCWR32(adapter, QLC_83XX_RESET_EPGSHIM, 0);
+	QLCWR32(adapter, QLC_83XX_RESET_ETHERPCS, 0);
+	QLCWR32(adapter, QLC_83XX_RESET_CONTROL, 1);
+}
+
 static int qlcnic_83xx_check_heartbeat(struct qlcnic_adapter *p_dev)
 {
 	u32 heartbeat, peg_status;
@@ -1395,6 +1419,7 @@ static int qlcnic_83xx_check_heartbeat(struct qlcnic_adapter *p_dev)
 
 	if (ret) {
 		dev_err(&p_dev->pdev->dev, "firmware hang detected\n");
+		qlcnic_83xx_take_eport_out_of_reset(p_dev);
 		qlcnic_83xx_disable_pause_frames(p_dev);
 		peg_status = QLC_SHARED_REG_RD32(p_dev,
 						 QLCNIC_PEG_HALT_STATUS1);
-- 
1.7.6.rc1.1.g2c162b
