From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/4] e1000e: Expand workaround for 10Mb HD throughput bug
Date: Mon,  5 May 2014 13:07:38 -0700
Message-ID: <1399320460-21774-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1399320460-21774-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21818 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752588AbaEEUHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 16:07:50 -0400
In-Reply-To: <1399320460-21774-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

In commit 772d05c51c4f4896c120ad418b1e91144a2ac813 "e1000e: slow performance
between two 82579 connected via 10Mbit hub", a workaround was put into place
to address the overaggressive transmit behavior of 82579 parts when connecting
at 10Mbs half-duplex.

This same behavior is seen on i217 and i218 parts as well.  This patch expands
the original workaround to encompass these parts.

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 15 +++++++++++----
 drivers/net/ethernet/intel/e1000e/ich8lan.h |  1 +
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 9b736b8..059f1b0 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1314,14 +1314,17 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 			return ret_val;
 	}
 
-	/* When connected at 10Mbps half-duplex, 82579 parts are excessively
+	/* When connected at 10Mbps half-duplex, some parts are excessively
 	 * aggressive resulting in many collisions. To avoid this, increase
 	 * the IPG and reduce Rx latency in the PHY.
 	 */
-	if ((hw->mac.type == e1000_pch2lan) && link) {
+	if (((hw->mac.type == e1000_pch2lan) ||
+	     (hw->mac.type == e1000_pch_lpt)) && link) {
 		u32 reg;
 		reg = er32(STATUS);
 		if (!(reg & (E1000_STATUS_FD | E1000_STATUS_SPEED_MASK))) {
+			u16 emi_addr;
+
 			reg = er32(TIPG);
 			reg &= ~E1000_TIPG_IPGT_MASK;
 			reg |= 0xFF;
@@ -1332,8 +1335,12 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 			if (ret_val)
 				return ret_val;
 
-			ret_val =
-			    e1000_write_emi_reg_locked(hw, I82579_RX_CONFIG, 0);
+			if (hw->mac.type == e1000_pch2lan)
+				emi_addr = I82579_RX_CONFIG;
+			else
+				emi_addr = I217_RX_CONFIG;
+
+			ret_val = e1000_write_emi_reg_locked(hw, emi_addr, 0);
 
 			hw->phy.ops.release(hw);
 
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index bead50f..8fc6c15 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -242,6 +242,7 @@
 #define I217_EEE_CAPABILITY	0x8000	/* IEEE MMD Register 3.20 */
 #define I217_EEE_ADVERTISEMENT	0x8001	/* IEEE MMD Register 7.60 */
 #define I217_EEE_LP_ABILITY	0x8002	/* IEEE MMD Register 7.61 */
+#define I217_RX_CONFIG		0xB20C	/* Receive configuration */
 
 #define E1000_EEE_RX_LPI_RCVD	0x0400	/* Tx LP idle received */
 #define E1000_EEE_TX_LPI_RCVD	0x0800	/* Rx LP idle received */
-- 
1.9.0
