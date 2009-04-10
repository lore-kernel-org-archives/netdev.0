From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 07/10] ixgbe: Remove unnecessary PHY reset,
	properly identify multispeed fiber modules
Date: Fri, 10 Apr 2009 01:28:15 -0700
Message-ID: <20090410082815.14372.18601.stgit@localhost.localdomain>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:52944 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762899AbZDJQ4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 12:56:43 -0400
In-Reply-To: <20090410082618.14372.86091.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch does two things:
1) On 82599, the PHY is emedded in the MAC.  On 82598, the SFP+ NIC has an external PHY.  The reset in the SFP+ setup patch for 82598 is unnecessary on 82599, and adds extra dead time to device initialization.  This removes that PHY reset for 82599 only.

2) On 82599, the SFP+ modules are multispeed fiber modules (10G/1G).  We need to make sure to identify them properly for the remaining init sections to properly set them up.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |   24 ++++++++++++++++--------
 drivers/net/ixgbe/ixgbe_phy.c   |   11 +++++++++++
 drivers/net/ixgbe/ixgbe_phy.h   |    1 +
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 4 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 35689d8..9528d8b 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -100,6 +100,9 @@ s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 
 	if (hw->phy.sfp_type != ixgbe_sfp_type_unknown) {
 		ixgbe_init_mac_link_ops_82599(hw);
+
+		hw->phy.ops.reset = NULL;
+
 		ret_val = ixgbe_get_sfp_init_sequence_offsets(hw, &list_offset,
 		                                              &data_offset);
 
@@ -714,19 +717,24 @@ s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 	/* Call adapter stop to disable tx/rx and clear interrupts */
 	hw->mac.ops.stop_adapter(hw);
 
-	/* Reset PHY */
-	if (hw->phy.reset_disable == false) {
-		/* PHY ops must be identified and initialized prior to reset */
+	/* PHY ops must be identified and initialized prior to reset */
 
-		/* Init PHY and function pointers, perform SFP setup */
-		status = hw->phy.ops.init(hw);
+	/* Init PHY and function pointers, perform SFP setup */
+	status = hw->phy.ops.init(hw);
 
-		if (status == IXGBE_ERR_SFP_NOT_SUPPORTED)
-			goto reset_hw_out;
+	if (status == IXGBE_ERR_SFP_NOT_SUPPORTED)
+		goto reset_hw_out;
 
-		hw->phy.ops.reset(hw);
+	/* Setup SFP module if there is one present. */
+	if (hw->phy.sfp_setup_needed) {
+		status = hw->mac.ops.setup_sfp(hw);
+		hw->phy.sfp_setup_needed = false;
 	}
 
+	/* Reset PHY */
+	if (hw->phy.reset_disable == false && hw->phy.ops.reset != NULL)
+		hw->phy.ops.reset(hw);
+
 	/*
 	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
 	 * access and verify no pending requests before reset
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 14e9606..6f11df7 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -552,6 +552,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 {
 	s32 status = IXGBE_ERR_PHY_ADDR_INVALID;
 	u32 vendor_oui = 0;
+	enum ixgbe_sfp_type stored_sfp_type = hw->phy.sfp_type;
 	u8 identifier = 0;
 	u8 comp_codes_1g = 0;
 	u8 comp_codes_10g = 0;
@@ -620,6 +621,16 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 				hw->phy.sfp_type = ixgbe_sfp_type_unknown;
 		}
 
+		if (hw->phy.sfp_type != stored_sfp_type)
+			hw->phy.sfp_setup_needed = true;
+
+		/* Determine if the SFP+ PHY is dual speed or not. */
+		if (((comp_codes_1g & IXGBE_SFF_1GBASESX_CAPABLE) &&
+		   (comp_codes_10g & IXGBE_SFF_10GBASESR_CAPABLE)) ||
+		   ((comp_codes_1g & IXGBE_SFF_1GBASELX_CAPABLE) &&
+		   (comp_codes_10g & IXGBE_SFF_10GBASELR_CAPABLE)))
+			hw->phy.multispeed_fiber = true;
+
 		/* Determine PHY vendor */
 		if (hw->phy.type == ixgbe_phy_unknown) {
 			hw->phy.id = identifier;
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index cc5f1b3..c9964b7 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -44,6 +44,7 @@
 /* Bitmasks */
 #define IXGBE_SFF_TWIN_AX_CAPABLE            0x80
 #define IXGBE_SFF_1GBASESX_CAPABLE           0x1
+#define IXGBE_SFF_1GBASELX_CAPABLE           0x2
 #define IXGBE_SFF_10GBASESR_CAPABLE          0x10
 #define IXGBE_SFF_10GBASELR_CAPABLE          0x20
 #define IXGBE_I2C_EEPROM_READ_MASK           0x100
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 06d7e8a..db65c05 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2198,6 +2198,7 @@ struct ixgbe_phy_info {
 	u32                             addr;
 	u32                             id;
 	enum ixgbe_sfp_type             sfp_type;
+	bool                            sfp_setup_needed;
 	u32                             revision;
 	enum ixgbe_media_type           media_type;
 	bool                            reset_disable;

