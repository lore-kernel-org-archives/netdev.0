From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 12/37] atl1c: restore max-read-request-size in Device Conrol Register
Date: Fri, 13 Apr 2012 08:14:37 +0800
Message-ID: <1334276102-15866-13-git-send-email-xiong@qca.qualcomm.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

in some platforms, we found the max-read-request-size in Device Control
Register is set to 0 by (BIOS?) during bootup, this will cause the
performance(throughput) very bad.
Restore it to a min-value.
register definition of REG_DEVICE_CTRL is refined as well.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   21 ++++++++++++++++-----
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   18 +++++++++++++-----
 2 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index a0b56ef..590ad3d 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -54,11 +54,22 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define DEVICE_CAP_MAX_PAYLOAD_MASK     0x7
 #define DEVICE_CAP_MAX_PAYLOAD_SHIFT    0
 
-#define REG_DEVICE_CTRL			0x60
-#define DEVICE_CTRL_MAX_PAYLOAD_MASK    0x7
-#define DEVICE_CTRL_MAX_PAYLOAD_SHIFT   5
-#define DEVICE_CTRL_MAX_RREQ_SZ_MASK    0x7
-#define DEVICE_CTRL_MAX_RREQ_SZ_SHIFT   12
+#define REG_DEVICE_CTRL			0x60	/* 16bit */
+#define DEVICE_CTRL_MAX_RREQ_SZ_MASK	7U
+#define DEVICE_CTRL_MAX_RREQ_SZ_SHIFT	12
+#define DEVICE_CTRL_MAXRRS_MIN		2
+#define DEVICE_CTRL_NOSNP_EN		BIT(11)
+#define DEVICE_CTRL_AUXPWR_EN		BIT(10)
+#define DEVICE_CTRL_PHANTOM_EN		BIT(9)
+#define DEVICE_CTRL_EXTAG_EN		BIT(8)
+#define DEVICE_CTRL_MAX_PAYLOAD_MASK	7U
+#define DEVICE_CTRL_MAX_PAYLOAD_SHIFT	5
+#define DEVICE_CTRL_RELORD_EN		BIT(4)
+#define DEVICE_CTRL_URR_EN		BIT(3)
+#define DEVICE_CTRL_FERR_EN		BIT(2)
+#define DEVICE_CTRL_NFERR_EN		BIT(1)
+#define DEVICE_CTRL_CERR_EN		BIT(0)
+
 
 #define REG_LINK_CTRL			0x68
 #define LINK_CTRL_L0S_EN		0x01
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 8e737a5..18c91b6 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1045,7 +1045,7 @@ static void atl1c_configure_des_ring(struct atl1c_adapter *adapter)
 static void atl1c_configure_tx(struct atl1c_adapter *adapter)
 {
 	struct atl1c_hw *hw = &adapter->hw;
-	u32 dev_ctrl_data;
+	u16 dev_ctrl_data;
 	u32 max_pay_load;
 	u16 tx_offload_thresh;
 	u32 txq_ctrl_data;
@@ -1053,11 +1053,19 @@ static void atl1c_configure_tx(struct atl1c_adapter *adapter)
 	tx_offload_thresh = MAX_TX_OFFLOAD_THRESH;
 	AT_WRITE_REG(hw, REG_TX_TSO_OFFLOAD_THRESH,
 		(tx_offload_thresh >> 3) & TX_TSO_OFFLOAD_THRESH_MASK);
-	AT_READ_REG(hw, REG_DEVICE_CTRL, &dev_ctrl_data);
-	max_pay_load  = (dev_ctrl_data >> DEVICE_CTRL_MAX_RREQ_SZ_SHIFT) &
-			DEVICE_CTRL_MAX_RREQ_SZ_MASK;
+	AT_READ_REGW(hw, REG_DEVICE_CTRL, &dev_ctrl_data);
+	max_pay_load  = FIELD_GETX(dev_ctrl_data, DEVICE_CTRL_MAX_RREQ_SZ);
 	hw->dmar_block = min_t(u32, max_pay_load, hw->dmar_block);
-
+	/*
+	 * if BIOS had changed the dam-read-max-length to an invalid value,
+	 * restore it to default value
+	 */
+	if (hw->dmar_block < DEVICE_CTRL_MAXRRS_MIN) {
+		dev_ctrl_data = FIELD_SETX(dev_ctrl_data,
+			DEVICE_CTRL_MAX_RREQ_SZ, DEVICE_CTRL_MAXRRS_MIN);
+		AT_WRITE_REGW(hw, REG_DEVICE_CTRL, dev_ctrl_data);
+		hw->dmar_block = DEVICE_CTRL_MAXRRS_MIN;
+	}
 	txq_ctrl_data =
 		hw->nic_type == athr_l2c_b || hw->nic_type == athr_l2c_b2 ?
 		L2CB_TXQ_CFGV : L1C_TXQ_CFGV;
-- 
1.7.7
