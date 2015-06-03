From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] e1000e: fix unit hang during loopback test
Date: Wed,  3 Jun 2015 04:27:55 -0700
Message-ID: <1433330876-2658-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:63339 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754576AbbFCL2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 07:28:07 -0400
In-Reply-To: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

System would hang during execution of "ethtool -t <NIC>" for the same
reason that required flushing the descriptor rings. This fix disables
MULR for the loopback test to avoid the hang state.

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 27 ++++++++++++++++++++++++---
 1 file changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 11f486e..c62f0db 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1516,8 +1516,19 @@ static int e1000_set_es2lan_mac_loopback(struct e1000_adapter *adapter)
 static int e1000_setup_loopback_test(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 rctl;
-
+	u32 rctl, fext_nvm11, tarc0;
+
+	if (hw->mac.type == e1000_pch_spt) {
+		fext_nvm11 = er32(FEXTNVM11);
+		fext_nvm11 |= E1000_FEXTNVM11_DISABLE_MULR_FIX;
+		ew32(FEXTNVM11, fext_nvm11);
+		tarc0 = er32(TARC(0));
+		/* clear bits 28 & 29 (control of MULR concurrent requests) */
+		tarc0 &= 0xcfffffff;
+		/* set bit 29 (value of MULR requests is now 2) */
+		tarc0 |= 0x20000000;
+		ew32(TARC(0), tarc0);
+	}
 	if (hw->phy.media_type == e1000_media_type_fiber ||
 	    hw->phy.media_type == e1000_media_type_internal_serdes) {
 		switch (hw->mac.type) {
@@ -1542,7 +1553,7 @@ static int e1000_setup_loopback_test(struct e1000_adapter *adapter)
 static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 rctl;
+	u32 rctl, fext_nvm11, tarc0;
 	u16 phy_reg;
 
 	rctl = er32(RCTL);
@@ -1550,6 +1561,16 @@ static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 	ew32(RCTL, rctl);
 
 	switch (hw->mac.type) {
+	case e1000_pch_spt:
+		fext_nvm11 = er32(FEXTNVM11);
+		fext_nvm11 &= ~E1000_FEXTNVM11_DISABLE_MULR_FIX;
+		ew32(FEXTNVM11, fext_nvm11);
+		tarc0 = er32(TARC(0));
+		/* clear bits 28 & 29 (control of MULR concurrent requests) */
+		/* set bit 29 (value of MULR requests is now 0) */
+		tarc0 &= 0xcfffffff;
+		ew32(TARC(0), tarc0);
+		/* fall through */
 	case e1000_80003es2lan:
 		if (hw->phy.media_type == e1000_media_type_fiber ||
 		    hw->phy.media_type == e1000_media_type_internal_serdes) {
-- 
2.1.0
