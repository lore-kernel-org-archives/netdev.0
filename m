From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 11/24] ixgbe: Check link wants report current link state
Date: Thu,  3 Mar 2011 05:03:36 -0800
Message-ID: <1299157429-15878-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45826 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758201Ab1CCNEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:22 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Currently check link reports the link state as down, if at any time
the link had previously gone down since the last time the LINKS
register was read.  This does not accurately reflect the function of
the check link call, which should be to return the CURRENT link
state. Code now reads the LINKS registers twice, once to clear the
previous and again to get the current value.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_common.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 6d87c74..7e3bb55 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -2769,10 +2769,19 @@ s32 ixgbe_clear_vfta_generic(struct ixgbe_hw *hw)
 s32 ixgbe_check_mac_link_generic(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
                                bool *link_up, bool link_up_wait_to_complete)
 {
-	u32 links_reg;
+	u32 links_reg, links_orig;
 	u32 i;
 
+	/* clear the old state */
+	links_orig = IXGBE_READ_REG(hw, IXGBE_LINKS);
+
 	links_reg = IXGBE_READ_REG(hw, IXGBE_LINKS);
+
+	if (links_orig != links_reg) {
+		hw_dbg(hw, "LINKS changed from %08X to %08X\n",
+		       links_orig, links_reg);
+	}
+
 	if (link_up_wait_to_complete) {
 		for (i = 0; i < IXGBE_LINK_UP_TIME; i++) {
 			if (links_reg & IXGBE_LINKS_UP) {
-- 
1.7.4

