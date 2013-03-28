From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] e1000e: slow performance between two 82579 connected via 10Mbit hub
Date: Thu, 28 Mar 2013 02:00:05 -0700
Message-ID: <1364461215-7793-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61712 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230Ab3C1JAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 05:00:21 -0400
In-Reply-To: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Two 82579 LOMs connected via a 10Mb hub experience extraordinarily low
performance.  This is because 82579 is excessively aggressive on transmit
at 10Mb half-duplex and will not provide sufficient time for the link
partner to transmit.  When the link partner is also 82579, the result is a
lot of collisions (and corresponding re-transmits) that cause the poor
performance. To work-around this issue, significantly increase the IPG in
the MAC to allow enough gap for the link partner to transmit and reduce the
Rx latency in the analog PHY to 0 to reduce the number of collisions.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h |  1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 28 ++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/e1000e/ich8lan.h |  1 +
 3 files changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index a6aeb19..351c94a 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -236,6 +236,7 @@
 #define E1000_STATUS_FUNC_SHIFT 2
 #define E1000_STATUS_FUNC_1     0x00000004      /* Function 1 */
 #define E1000_STATUS_TXOFF      0x00000010      /* transmission paused */
+#define E1000_STATUS_SPEED_MASK 0x000000C0
 #define E1000_STATUS_SPEED_10   0x00000000      /* Speed 10Mb/s */
 #define E1000_STATUS_SPEED_100  0x00000040      /* Speed 100Mb/s */
 #define E1000_STATUS_SPEED_1000 0x00000080      /* Speed 1000Mb/s */
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 1cdec5f..4f2f0f6 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -871,6 +871,34 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 			return ret_val;
 	}
 
+	/* When connected at 10Mbps half-duplex, 82579 parts are excessively
+	 * aggressive resulting in many collisions. To avoid this, increase
+	 * the IPG and reduce Rx latency in the PHY.
+	 */
+	if ((hw->mac.type == e1000_pch2lan) && link) {
+		u32 reg;
+		reg = er32(STATUS);
+		if (!(reg & (E1000_STATUS_FD | E1000_STATUS_SPEED_MASK))) {
+			reg = er32(TIPG);
+			reg &= ~E1000_TIPG_IPGT_MASK;
+			reg |= 0xFF;
+			ew32(TIPG, reg);
+
+			/* Reduce Rx latency in analog PHY */
+			ret_val = hw->phy.ops.acquire(hw);
+			if (ret_val)
+				return ret_val;
+
+			ret_val =
+			    e1000_write_emi_reg_locked(hw, I82579_RX_CONFIG, 0);
+
+			hw->phy.ops.release(hw);
+
+			if (ret_val)
+				return ret_val;
+		}
+	}
+
 	/* Work-around I218 hang issue */
 	if ((hw->adapter->pdev->device == E1000_DEV_ID_PCH_LPTLP_I218_LM) ||
 	    (hw->adapter->pdev->device == E1000_DEV_ID_PCH_LPTLP_I218_V)) {
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index 8bf4655..00ba6c9 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -211,6 +211,7 @@
 #define I82579_MSE_THRESHOLD	0x084F	/* 82579 Mean Square Error Threshold */
 #define I82577_MSE_THRESHOLD	0x0887	/* 82577 Mean Square Error Threshold */
 #define I82579_MSE_LINK_DOWN	0x2411	/* MSE count before dropping link */
+#define I82579_RX_CONFIG		0x3412	/* Receive configuration */
 #define I82579_EEE_PCS_STATUS		0x182D	/* IEEE MMD Register 3.1 >> 8 */
 #define I82579_EEE_CAPABILITY		0x0410	/* IEEE MMD Register 3.20 */
 #define I82579_EEE_ADVERTISEMENT	0x040E	/* IEEE MMD Register 7.60 */
-- 
1.7.11.7
