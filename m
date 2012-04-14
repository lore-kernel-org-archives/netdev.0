From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH v2 12/12] atl1c: restore max-read-request-size in Device Conrol Register
Date: Sat, 14 Apr 2012 19:59:26 +0800
Message-ID: <1334404766-11892-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:16779 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952Ab2DNL7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 07:59:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

register REG_DEVICE_CTRL is removed since the kernel provides
API to read/write this standard pcie register.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   15 ---------------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   10 +++-------
 2 files changed, 3 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index 590ad3d..a37c82f 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -54,22 +54,7 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define DEVICE_CAP_MAX_PAYLOAD_MASK     0x7
 #define DEVICE_CAP_MAX_PAYLOAD_SHIFT    0
 
-#define REG_DEVICE_CTRL			0x60	/* 16bit */
-#define DEVICE_CTRL_MAX_RREQ_SZ_MASK	7U
-#define DEVICE_CTRL_MAX_RREQ_SZ_SHIFT	12
 #define DEVICE_CTRL_MAXRRS_MIN		2
-#define DEVICE_CTRL_NOSNP_EN		BIT(11)
-#define DEVICE_CTRL_AUXPWR_EN		BIT(10)
-#define DEVICE_CTRL_PHANTOM_EN		BIT(9)
-#define DEVICE_CTRL_EXTAG_EN		BIT(8)
-#define DEVICE_CTRL_MAX_PAYLOAD_MASK	7U
-#define DEVICE_CTRL_MAX_PAYLOAD_SHIFT	5
-#define DEVICE_CTRL_RELORD_EN		BIT(4)
-#define DEVICE_CTRL_URR_EN		BIT(3)
-#define DEVICE_CTRL_FERR_EN		BIT(2)
-#define DEVICE_CTRL_NFERR_EN		BIT(1)
-#define DEVICE_CTRL_CERR_EN		BIT(0)
-
 
 #define REG_LINK_CTRL			0x68
 #define LINK_CTRL_L0S_EN		0x01
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 18c91b6..01dc348 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1045,25 +1045,21 @@ static void atl1c_configure_des_ring(struct atl1c_adapter *adapter)
 static void atl1c_configure_tx(struct atl1c_adapter *adapter)
 {
 	struct atl1c_hw *hw = &adapter->hw;
-	u16 dev_ctrl_data;
-	u32 max_pay_load;
+	int max_pay_load;
 	u16 tx_offload_thresh;
 	u32 txq_ctrl_data;
 
 	tx_offload_thresh = MAX_TX_OFFLOAD_THRESH;
 	AT_WRITE_REG(hw, REG_TX_TSO_OFFLOAD_THRESH,
 		(tx_offload_thresh >> 3) & TX_TSO_OFFLOAD_THRESH_MASK);
-	AT_READ_REGW(hw, REG_DEVICE_CTRL, &dev_ctrl_data);
-	max_pay_load  = FIELD_GETX(dev_ctrl_data, DEVICE_CTRL_MAX_RREQ_SZ);
+	max_pay_load  = pcie_get_readrq(adapter->pdev) >> 8;
 	hw->dmar_block = min_t(u32, max_pay_load, hw->dmar_block);
 	/*
 	 * if BIOS had changed the dam-read-max-length to an invalid value,
 	 * restore it to default value
 	 */
 	if (hw->dmar_block < DEVICE_CTRL_MAXRRS_MIN) {
-		dev_ctrl_data = FIELD_SETX(dev_ctrl_data,
-			DEVICE_CTRL_MAX_RREQ_SZ, DEVICE_CTRL_MAXRRS_MIN);
-		AT_WRITE_REGW(hw, REG_DEVICE_CTRL, dev_ctrl_data);
+		pcie_set_readrq(adapter->pdev, 128 << DEVICE_CTRL_MAXRRS_MIN);
 		hw->dmar_block = DEVICE_CTRL_MAXRRS_MIN;
 	}
 	txq_ctrl_data =
-- 
1.7.7
