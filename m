From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 06/10] e1000e: i219 - increase IPG for speed 10/100 full duplex
Date: Fri, 26 Jun 2015 03:20:36 -0700
Message-ID: <1435314040-3228-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58214 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751843AbbFZKUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 06:20:48 -0400
In-Reply-To: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

In SPT/i219, there were CRC errors in speed 10/100 full duplex.
The solution given by the HW team is to increase the IPG from 8 to 0xC

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index c5bb1dd..983f5bf 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1400,16 +1400,20 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 	if (((hw->mac.type == e1000_pch2lan) ||
 	     (hw->mac.type == e1000_pch_lpt) ||
 	     (hw->mac.type == e1000_pch_spt)) && link) {
-		u32 reg;
+		u16 speed, duplex;
 
-		reg = er32(STATUS);
+		e1000e_get_speed_and_duplex_copper(hw, &speed, &duplex);
 		tipg_reg = er32(TIPG);
 		tipg_reg &= ~E1000_TIPG_IPGT_MASK;
 
-		if (!(reg & (E1000_STATUS_FD | E1000_STATUS_SPEED_MASK))) {
+		if (duplex == HALF_DUPLEX && speed == SPEED_10) {
 			tipg_reg |= 0xFF;
 			/* Reduce Rx latency in analog PHY */
 			emi_val = 0;
+		} else if (hw->mac.type == e1000_pch_spt &&
+			   duplex == FULL_DUPLEX && speed != SPEED_1000) {
+			tipg_reg |= 0xC;
+			emi_val = 1;
 		} else {
 
 			/* Roll back the default values */
-- 
2.4.3
