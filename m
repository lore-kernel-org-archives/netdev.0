From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 08/10] ixgbe: Update the usage of orig_autoc to be more
	consistent
Date: Fri, 10 Apr 2009 01:28:33 -0700
Message-ID: <20090410082832.14372.72843.stgit@localhost.localdomain>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:35193 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761411AbZDJQ5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 12:57:00 -0400
In-Reply-To: <20090410082618.14372.86091.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The orig_autoc variable tracks the original setting of the autonegotiate
state prior to trying a new speed.  The usage is inconsistent and not very
maintainable.  This patch updates the usage to make it more consistent.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |   15 +++++++++++----
 drivers/net/ixgbe/ixgbe_82599.c |   37 ++++++++++++++++++++++++++++---------
 2 files changed, 39 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 2400fcf..89bc87a 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -165,12 +165,19 @@ static s32 ixgbe_get_link_capabilities_82598(struct ixgbe_hw *hw,
                                              bool *autoneg)
 {
 	s32 status = 0;
+	u32 autoc = 0;
 
 	/*
 	 * Determine link capabilities based on the stored value of AUTOC,
-	 * which represents EEPROM defaults.
+	 * which represents EEPROM defaults.  If AUTOC value has not been
+	 * stored, use the current register value.
 	 */
-	switch (hw->mac.orig_autoc & IXGBE_AUTOC_LMS_MASK) {
+	if (hw->mac.orig_link_settings_stored)
+		autoc = hw->mac.orig_autoc;
+	else
+		autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+
+	switch (autoc & IXGBE_AUTOC_LMS_MASK) {
 	case IXGBE_AUTOC_LMS_1G_LINK_NO_AN:
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;
 		*autoneg = false;
@@ -189,9 +196,9 @@ static s32 ixgbe_get_link_capabilities_82598(struct ixgbe_hw *hw,
 	case IXGBE_AUTOC_LMS_KX4_AN:
 	case IXGBE_AUTOC_LMS_KX4_AN_1G_AN:
 		*speed = IXGBE_LINK_SPEED_UNKNOWN;
-		if (hw->mac.orig_autoc & IXGBE_AUTOC_KX4_SUPP)
+		if (autoc & IXGBE_AUTOC_KX4_SUPP)
 			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
-		if (hw->mac.orig_autoc & IXGBE_AUTOC_KX_SUPP)
+		if (autoc & IXGBE_AUTOC_KX_SUPP)
 			*speed |= IXGBE_LINK_SPEED_1GB_FULL;
 		*autoneg = true;
 		break;
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 9528d8b..2faf190 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -219,8 +219,19 @@ s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
                                       bool *negotiation)
 {
 	s32 status = 0;
+	u32 autoc = 0;
 
-	switch (hw->mac.orig_autoc & IXGBE_AUTOC_LMS_MASK) {
+	/*
+	 * Determine link capabilities based on the stored value of AUTOC,
+	 * which represents EEPROM defaults.  If AUTOC value has not been
+	 * stored, use the current register value.
+	 */
+	if (hw->mac.orig_link_settings_stored)
+		autoc = hw->mac.orig_autoc;
+	else
+		autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+
+	switch (autoc & IXGBE_AUTOC_LMS_MASK) {
 	case IXGBE_AUTOC_LMS_1G_LINK_NO_AN:
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;
 		*negotiation = false;
@@ -244,22 +255,22 @@ s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
 	case IXGBE_AUTOC_LMS_KX4_KX_KR:
 	case IXGBE_AUTOC_LMS_KX4_KX_KR_1G_AN:
 		*speed = IXGBE_LINK_SPEED_UNKNOWN;
-		if (hw->mac.orig_autoc & IXGBE_AUTOC_KR_SUPP)
+		if (autoc & IXGBE_AUTOC_KR_SUPP)
 			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
-		if (hw->mac.orig_autoc & IXGBE_AUTOC_KX4_SUPP)
+		if (autoc & IXGBE_AUTOC_KX4_SUPP)
 			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
-		if (hw->mac.orig_autoc & IXGBE_AUTOC_KX_SUPP)
+		if (autoc & IXGBE_AUTOC_KX_SUPP)
 			*speed |= IXGBE_LINK_SPEED_1GB_FULL;
 		*negotiation = true;
 		break;
 
 	case IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII:
 		*speed = IXGBE_LINK_SPEED_100_FULL;
-		if (hw->mac.orig_autoc & IXGBE_AUTOC_KR_SUPP)
+		if (autoc & IXGBE_AUTOC_KR_SUPP)
 			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
-		if (hw->mac.orig_autoc & IXGBE_AUTOC_KX4_SUPP)
+		if (autoc & IXGBE_AUTOC_KX4_SUPP)
 			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
-		if (hw->mac.orig_autoc & IXGBE_AUTOC_KX_SUPP)
+		if (autoc & IXGBE_AUTOC_KX_SUPP)
 			*speed |= IXGBE_LINK_SPEED_1GB_FULL;
 		*negotiation = true;
 		break;
@@ -570,6 +581,7 @@ s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
 	s32 status = 0;
 	u32 autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
 	u32 autoc2 = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
+	u32 orig_autoc = 0;
 	u32 link_mode = autoc & IXGBE_AUTOC_LMS_MASK;
 	u32 pma_pmd_1g = autoc & IXGBE_AUTOC_1G_PMA_PMD_MASK;
 	u32 pma_pmd_10g_serial = autoc2 & IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_MASK;
@@ -581,6 +593,13 @@ s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
 	hw->mac.ops.get_link_capabilities(hw, &link_capabilities, &autoneg);
 	speed &= link_capabilities;
 
+	/* Use stored value (EEPROM defaults) of AUTOC to find KR/KX4 support*/
+	if (hw->mac.orig_link_settings_stored)
+		orig_autoc = hw->mac.orig_autoc;
+	else
+		orig_autoc = autoc;
+
+
 	if (speed == IXGBE_LINK_SPEED_UNKNOWN) {
 		status = IXGBE_ERR_LINK_SETUP;
 	} else if (link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR ||
@@ -589,9 +608,9 @@ s32 ixgbe_setup_mac_link_speed_82599(struct ixgbe_hw *hw,
 		/* Set KX4/KX/KR support according to speed requested */
 		autoc &= ~(IXGBE_AUTOC_KX4_KX_SUPP_MASK | IXGBE_AUTOC_KR_SUPP);
 		if (speed & IXGBE_LINK_SPEED_10GB_FULL)
-			if (hw->mac.orig_autoc & IXGBE_AUTOC_KX4_SUPP)
+			if (orig_autoc & IXGBE_AUTOC_KX4_SUPP)
 				autoc |= IXGBE_AUTOC_KX4_SUPP;
-			if (hw->mac.orig_autoc & IXGBE_AUTOC_KR_SUPP)
+			if (orig_autoc & IXGBE_AUTOC_KR_SUPP)
 				autoc |= IXGBE_AUTOC_KR_SUPP;
 		if (speed & IXGBE_LINK_SPEED_1GB_FULL)
 			autoc |= IXGBE_AUTOC_KX_SUPP;

