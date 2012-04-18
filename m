From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 12/12] atl1c: restore max-read-request-size in Device Conrol Register
Date: Wed, 18 Apr 2012 13:32:36 +0800
Message-ID: <1334727156-6830-13-git-send-email-xiong@qca.qualcomm.com>
References: <1334727156-6830-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:64760 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533Ab2DRFec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 01:34:32 -0400
In-Reply-To: <1334727156-6830-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in some platforms, we found the max-read-request-size in Device Control
Register is set to 0 by (BIOS?) during bootup, this will cause the
performance(throughput) very bad.
Restore it to a min-value.
register definition of REG_DEVICE_CTRL is removed, using kernel API to
access it as it's a standard pcie register.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |    6 +-----
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   16 ++++++++++------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index a0b56ef..a37c82f 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -54,11 +54,7 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 #define DEVICE_CAP_MAX_PAYLOAD_MASK     0x7
 #define DEVICE_CAP_MAX_PAYLOAD_SHIFT    0
 
-#define REG_DEVICE_CTRL			0x60
-#define DEVICE_CTRL_MAX_PAYLOAD_MASK    0x7
-#define DEVICE_CTRL_MAX_PAYLOAD_SHIFT   5
-#define DEVICE_CTRL_MAX_RREQ_SZ_MASK    0x7
-#define DEVICE_CTRL_MAX_RREQ_SZ_SHIFT   12
+#define DEVICE_CTRL_MAXRRS_MIN		2
 
 #define REG_LINK_CTRL			0x68
 #define LINK_CTRL_L0S_EN		0x01
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 8e737a5..b554004 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1045,19 +1045,23 @@ static void atl1c_configure_des_ring(struct atl1c_adapter *adapter)
 static void atl1c_configure_tx(struct atl1c_adapter *adapter)
 {
 	struct atl1c_hw *hw = &adapter->hw;
-	u32 dev_ctrl_data;
-	u32 max_pay_load;
+	int max_pay_load;
 	u16 tx_offload_thresh;
 	u32 txq_ctrl_data;
 
 	tx_offload_thresh = MAX_TX_OFFLOAD_THRESH;
 	AT_WRITE_REG(hw, REG_TX_TSO_OFFLOAD_THRESH,
 		(tx_offload_thresh >> 3) & TX_TSO_OFFLOAD_THRESH_MASK);
-	AT_READ_REG(hw, REG_DEVICE_CTRL, &dev_ctrl_data);
-	max_pay_load  = (dev_ctrl_data >> DEVICE_CTRL_MAX_RREQ_SZ_SHIFT) &
-			DEVICE_CTRL_MAX_RREQ_SZ_MASK;
+	max_pay_load = pcie_get_readrq(adapter->pdev) >> 8;
 	hw->dmar_block = min_t(u32, max_pay_load, hw->dmar_block);
-
+	/*
+	 * if BIOS had changed the dam-read-max-length to an invalid value,
+	 * restore it to default value
+	 */
+	if (hw->dmar_block < DEVICE_CTRL_MAXRRS_MIN) {
+		pcie_set_readrq(adapter->pdev, 128 << DEVICE_CTRL_MAXRRS_MIN);
+		hw->dmar_block = DEVICE_CTRL_MAXRRS_MIN;
+	}
 	txq_ctrl_data =
 		hw->nic_type == athr_l2c_b || hw->nic_type == athr_l2c_b2 ?
 		L2CB_TXQ_CFGV : L1C_TXQ_CFGV;
-- 
1.7.7
