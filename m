From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/4] e1000e: clear REQ and GNT in EECD (82571 && 82572)
Date: Sat,  5 May 2012 05:38:11 -0700
Message-ID: <1336221493-913-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336221493-913-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Richard Alpe <richard.alpe@ericsson.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42294 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755401Ab2EEMiR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2012 08:38:17 -0400
In-Reply-To: <1336221493-913-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

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
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 6a8a908..36db4df 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -999,7 +999,7 @@ static s32 e1000_set_d0_lplu_state_82571(struct e1000_hw *hw, bool active)
  **/
 static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 {
-	u32 ctrl, ctrl_ext;
+	u32 ctrl, ctrl_ext, eecd;
 	s32 ret_val;
 
 	/*
@@ -1072,6 +1072,16 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	 */
 
 	switch (hw->mac.type) {
+	case e1000_82571:
+	case e1000_82572:
+		/*
+		 * REQ and GNT bits need to be cleared when using AUTO_RD
+		 * to access the EEPROM.
+		 */
+		eecd = er32(EECD);
+		eecd &= ~(E1000_EECD_REQ | E1000_EECD_GNT);
+		ew32(EECD, eecd);
+		break;
 	case e1000_82573:
 	case e1000_82574:
 	case e1000_82583:
-- 
1.7.7.6
