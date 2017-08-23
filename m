From: Matthew Tan <matthew.tan_1@nxp.com>
Subject: [PATCH] e1000e: changed some expensive calls of udelay to usleep_range
Date: Wed, 23 Aug 2017 10:59:45 -0500
Message-ID: <1503503985-3869-1-git-send-email-matthew.tan_1@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <michael.kardonik@nxp.com>, <carolyn.wyborny@intel.com>,
        <donald.c.skidmore@intel.com>, <bruce.w.allan@intel.com>,
        <john.ronciak@intel.com>, <mitch.a.williams@intel.com>,
        <intel-wired-lan@lists.osuosl.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Matthew Tan <matthew.tan_1@nxp.com>
To: <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0048.outbound.protection.outlook.com ([104.47.37.48]:7020
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932129AbdHWQBF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 12:01:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    Calls to udelay are not preemtable by userspace so userspace
    applications experience a large (~200us) latency when running on core
    0. Instead usleep_range can be used to be more friendly to userspace
    since it is preemtable. This is due to udelay using busy-wait loops
    while usleep_rang uses hrtimers instead. It is recommended to use
    udelay when the delay is <10us since at that precision overhead of
    usleep_range hrtimer setup causes issues. However, the replaced calls
    are for 50us and 100us so this should not be not an issue.

Signed-off-by: Matthew Tan <matthew.tan_1@nxp.com>
---
 drivers/net/ethernet/intel/e1000e/phy.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index de13aea..e318fdc 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -158,7 +158,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	 * the lower time out
 	 */
 	for (i = 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
-		udelay(50);
+		usleep_range(40, 60);
 		mdic = er32(MDIC);
 		if (mdic & E1000_MDIC_READY)
 			break;
@@ -183,7 +183,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	 * reading duplicate data in the next MDIC transaction.
 	 */
 	if (hw->mac.type == e1000_pch2lan)
-		udelay(100);
+		usleep_range(90, 100);
 
 	return 0;
 }
@@ -222,7 +222,7 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 	 * the lower time out
 	 */
 	for (i = 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
-		udelay(50);
+		usleep_range(40, 60);
 		mdic = er32(MDIC);
 		if (mdic & E1000_MDIC_READY)
 			break;
@@ -246,7 +246,7 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 	 * reading duplicate data in the next MDIC transaction.
 	 */
 	if (hw->mac.type == e1000_pch2lan)
-		udelay(100);
+		usleep_range(90, 110);
 
 	return 0;
 }
-- 
2.7.4
