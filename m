From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 14/37] atl1c: add module parameter for l1c_wait_until_idle
Date: Fri, 13 Apr 2012 08:14:39 +0800
Message-ID: <1334276102-15866-15-git-send-email-xiong@qca.qualcomm.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:12950 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966410Ab2DMAR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 20:17:28 -0400
In-Reply-To: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l1c_wait_until_idle is called for serval modules (TXQ/RXQ/TXMAC/RXMAC)
specific moudle have specific idle/busy status in reg REG_IDLE_STATUS
the previous code return if all modules are in idle status, though
the 'stop' action is applied on specific module.
Refine the reg REG_IDLE_STATUS definition as well.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   28 ++++++++++++++--------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   11 +++++----
 2 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index 590ad3d..ec68611 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -242,17 +242,25 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 		GPHY_CTRL_HIB_PULSE	|\
 		GPHY_CTRL_PWDOWN_HW	|\
 		GPHY_CTRL_PHY_IDDQ)
+
 /* Block IDLE Status Register */
-#define REG_IDLE_STATUS  		0x1410
-#define IDLE_STATUS_MASK		0x00FF
-#define IDLE_STATUS_RXMAC_NO_IDLE      	0x1
-#define IDLE_STATUS_TXMAC_NO_IDLE      	0x2
-#define IDLE_STATUS_RXQ_NO_IDLE        	0x4
-#define IDLE_STATUS_TXQ_NO_IDLE        	0x8
-#define IDLE_STATUS_DMAR_NO_IDLE       	0x10
-#define IDLE_STATUS_DMAW_NO_IDLE       	0x20
-#define IDLE_STATUS_SMB_NO_IDLE        	0x40
-#define IDLE_STATUS_CMB_NO_IDLE        	0x80
+#define REG_IDLE_STATUS			0x1410
+#define IDLE_STATUS_SFORCE_MASK		0xFUL
+#define IDLE_STATUS_SFORCE_SHIFT	14
+#define IDLE_STATUS_CALIB_DONE		BIT(13)
+#define IDLE_STATUS_CALIB_RES_MASK	0x1FUL
+#define IDLE_STATUS_CALIB_RES_SHIFT	8
+#define IDLE_STATUS_CALIBERR_MASK	0xFUL
+#define IDLE_STATUS_CALIBERR_SHIFT	4
+#define IDLE_STATUS_TXQ_BUSY		BIT(3)
+#define IDLE_STATUS_RXQ_BUSY		BIT(2)
+#define IDLE_STATUS_TXMAC_BUSY		BIT(1)
+#define IDLE_STATUS_RXMAC_BUSY		BIT(0)
+#define IDLE_STATUS_MASK		(\
+	IDLE_STATUS_TXQ_BUSY		|\
+	IDLE_STATUS_RXQ_BUSY		|\
+	IDLE_STATUS_TXMAC_BUSY		|\
+	IDLE_STATUS_RXMAC_BUSY)
 
 /* MDIO Control Register */
 #define REG_MDIO_CTRL           	0x1414
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 8228aa7..141fe67 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -185,14 +185,14 @@ static inline void atl1c_irq_reset(struct atl1c_adapter *adapter)
  * atl1c_wait_until_idle - wait up to AT_HW_MAX_IDLE_DELAY reads
  * of the idle status register until the device is actually idle
  */
-static u32 atl1c_wait_until_idle(struct atl1c_hw *hw)
+static u32 atl1c_wait_until_idle(struct atl1c_hw *hw, u32 modu_ctrl)
 {
 	int timeout;
 	u32 data;
 
 	for (timeout = 0; timeout < AT_HW_MAX_IDLE_DELAY; timeout++) {
 		AT_READ_REG(hw, REG_IDLE_STATUS, &data);
-		if ((data & IDLE_STATUS_MASK) == 0)
+		if ((data & modu_ctrl) == 0)
 			return 0;
 		msleep(1);
 	}
@@ -1123,13 +1123,14 @@ static int atl1c_stop_mac(struct atl1c_hw *hw)
 	data &= ~TXQ_CTRL_EN;
 	AT_WRITE_REG(hw, REG_TXQ_CTRL, data);
 
-	atl1c_wait_until_idle(hw);
+	atl1c_wait_until_idle(hw, IDLE_STATUS_RXQ_BUSY | IDLE_STATUS_TXQ_BUSY);
 
 	AT_READ_REG(hw, REG_MAC_CTRL, &data);
 	data &= ~(MAC_CTRL_TX_EN | MAC_CTRL_RX_EN);
 	AT_WRITE_REG(hw, REG_MAC_CTRL, data);
 
-	return (int)atl1c_wait_until_idle(hw);
+	return (int)atl1c_wait_until_idle(hw,
+		IDLE_STATUS_TXMAC_BUSY | IDLE_STATUS_RXMAC_BUSY);
 }
 
 static void atl1c_enable_rx_ctrl(struct atl1c_hw *hw)
@@ -1180,7 +1181,7 @@ static int atl1c_reset_mac(struct atl1c_hw *hw)
 	msleep(10);
 	/* Wait at least 10ms for All module to be Idle */
 
-	if (atl1c_wait_until_idle(hw)) {
+	if (atl1c_wait_until_idle(hw, IDLE_STATUS_MASK)) {
 		dev_err(&pdev->dev,
 			"MAC state machine can't be idle since"
 			" disabled for 10ms second\n");
-- 
1.7.7
