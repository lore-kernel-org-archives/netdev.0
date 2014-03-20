From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] ixgbe: fix ixgbe_setup_mac_link_82599 autoc variables
Date: Thu, 20 Mar 2014 01:33:00 -0700
Message-ID: <1395304385-6874-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Arun Sharma <asharma@fb.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8080 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755853AbaCTIdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 04:33:53 -0400
In-Reply-To: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes flow control autonegotiation for KR/KX/K4 interfaces.
When setting up MAC link, the cached autoc value and current autoc value
were being incorrectly used to determine whether link reset is required.
This resulted in the driver ignoring and discarding flow control
negotiation changes that occur since the caching happened, as well as
when the mac was being setup.

This patch also splits the assignments for the 3 autoc variables into
their own block, and adds a comment explaining what each one means, in
order to help keep logic more straightforward while reading the code.

CC: Arun Sharma <asharma@fb.com>
Reported-by: Sourav Chatterjee <sourav.chatterjee@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index ef808bc..e0fe8e8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1031,15 +1031,19 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
 				      ixgbe_link_speed speed,
 				      bool autoneg_wait_to_complete)
 {
+	bool autoneg = false;
 	s32 status = 0;
-	u32 autoc, pma_pmd_1g, link_mode, start_autoc;
+	u32 pma_pmd_1g, link_mode, links_reg, i;
 	u32 autoc2 = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
-	u32 orig_autoc = 0;
 	u32 pma_pmd_10g_serial = autoc2 & IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_MASK;
-	u32 links_reg;
-	u32 i;
 	ixgbe_link_speed link_capabilities = IXGBE_LINK_SPEED_UNKNOWN;
-	bool autoneg = false;
+
+	/* holds the value of AUTOC register at this current point in time */
+	u32 current_autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	/* holds the cached value of AUTOC register */
+	u32 orig_autoc = 0;
+	/* temporary variable used for comparison purposes */
+	u32 autoc = current_autoc;
 
 	/* Check to see if speed passed in is supported. */
 	status = hw->mac.ops.get_link_capabilities(hw, &link_capabilities,
@@ -1056,12 +1060,10 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
 
 	/* Use stored value (EEPROM defaults) of AUTOC to find KR/KX4 support*/
 	if (hw->mac.orig_link_settings_stored)
-		autoc = hw->mac.orig_autoc;
+		orig_autoc = hw->mac.orig_autoc;
 	else
-		autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+		orig_autoc = autoc;
 
-	orig_autoc = autoc;
-	start_autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
 	link_mode = autoc & IXGBE_AUTOC_LMS_MASK;
 	pma_pmd_1g = autoc & IXGBE_AUTOC_1G_PMA_PMD_MASK;
 
@@ -1101,7 +1103,7 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
 		}
 	}
 
-	if (autoc != start_autoc) {
+	if (autoc != current_autoc) {
 		/* Restart link */
 		status = hw->mac.ops.prot_autoc_write(hw, autoc, false);
 		if (status)
-- 
1.8.3.1
