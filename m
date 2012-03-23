From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH] e1000e: clear REQ and GNT in EECD (82571 && 82572)
Date: Fri, 23 Mar 2012 13:55:20 +0100
Message-ID: <1332507320-19902-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<bruce.w.allan@intel.com>, <carolyn.wyborny@intel.com>,
	<donald.c.skidmore@intel.com>, <gregory.v.rose@intel.com>,
	<peter.p.waskiewicz.jr@intel.com>, <alexander.h.duyck@intel.com>,
	<john.ronciak@intel.com>, <e1000-devel@lists.sourceforge.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:56306 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704Ab2CWMzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 08:55:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clear the REQ and GNT bit in the eeprom control register (EECD).
This is required if the eeprom is to be accessed with auto read
EERD register.

After a cold reset this doesn't matter but if PBIST MAC test was
executed before booting, the register was left in a dirty state
(the 2 bits where set), which caused the read operation to time out
and returning 0.

Reference (page 312):
http://download.intel.com/design/network/manuals/316080.pdf

Reported-by: Aleksandar Igic <aleksandar.igic@dektech.com.au>
Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index b3fdc69..51f7d2e 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1001,6 +1001,7 @@ static s32 e1000_set_d0_lplu_state_82571(struct e1000_hw *hw, bool active)
 static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 {
 	u32 ctrl, ctrl_ext;
+	u32 ctrl, ctrl_ext, eecd;
 	s32 ret_val;
 
 	/*
@@ -1099,6 +1100,16 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	if (hw->phy.media_type == e1000_media_type_internal_serdes)
 		hw->mac.serdes_link_state = e1000_serdes_link_down;
 
+	/*
+	 * 82571 and 82572 need EEC.EE_REQ and EEC.EE_GNT cleared
+	 * when using EERD to access the EEPROM
+	 */
+	if ((hw->mac.type == e1000_82571) || (hw->mac.type == e1000_82572)) {
+		eecd = er32(EECD);
+		eecd &= ~(E1000_EECD_REQ | E1000_EECD_GNT);
+		ew32(EECD, eecd);
+	}
+
 	return 0;
 }
 
-- 
1.7.2.5
