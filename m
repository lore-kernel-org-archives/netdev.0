From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] ixgbe: Fix the DCB PFC thresholds for 82599
Date: Thu, 16 Apr 2009 18:00:41 -0700
Message-ID: <20090417010041.19018.76862.stgit@localhost.localdomain>
References: <20090417010019.19018.62374.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:49906
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754858AbZDQBBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 21:01:00 -0400
In-Reply-To: <20090417010019.19018.62374.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The thresholds for the DCB priority flow control are incorrect for 82599.
This fixes the thresholds to be correct.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_82599.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index 470b676..f4417fc 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -290,7 +290,7 @@ s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
 s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
                                struct ixgbe_dcb_config *dcb_config)
 {
-	u32 i, reg;
+	u32 i, reg, rx_pba_size;
 
 	/* If PFC is disabled globally then fall back to LFC. */
 	if (!dcb_config->pfc_mode_enable) {
@@ -301,17 +301,23 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
 
 	/* Configure PFC Tx thresholds per TC */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		/* Config and remember Tx */
+		if (dcb_config->rx_pba_cfg == pba_equal)
+			rx_pba_size = IXGBE_RXPBSIZE_64KB;
+		else
+			rx_pba_size = (i < 4) ? IXGBE_RXPBSIZE_80KB
+			                      : IXGBE_RXPBSIZE_48KB;
+
+		reg = ((rx_pba_size >> 5) & 0xFFE0);
 		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full ||
-		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx) {
-			reg = hw->fc.high_water | IXGBE_FCRTH_FCEN;
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(i), reg);
-			reg = hw->fc.low_water | IXGBE_FCRTL_XONE;
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(i), reg);
-		} else {
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(i), 0);
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(i), 0);
-		}
+		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx)
+			reg |= IXGBE_FCRTL_XONE;
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(i), reg);
+
+		reg = ((rx_pba_size >> 2) & 0xFFE0);
+		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full ||
+		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx)
+			reg |= IXGBE_FCRTH_FCEN;
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(i), reg);
 	}
 
 	/* Configure pause time (2 TCs per register) */

