From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC NET-NEXT PATCH 2/6] e1000e: implement 82577/579 MDI setting
 support
Date: Wed, 25 Jul 2012 11:00:10 -0700
Message-ID: <20120725180010.9995.26853.stgit@jbrandeb-snb.jf.intel.com>
References: <20120725175430.9995.11370.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45999 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751485Ab2GYUwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2012 16:52:03 -0400
In-Reply-To: <20120725175430.9995.11370.stgit@jbrandeb-snb.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce W Allan <bruce.w.allan@intel.com>

in order for e1000e to support MDI setting support via
ethtool this code is needed to allow setting the MDI state
via software.

This is in regards to the related ethtool patch and
fixes bugzilla.kernel.org bug 11998

Signed-off-by: Bruce W Allan <bruce.w.allan@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/ethernet/intel/e1000e/phy.c |   31 +++++++++++++++++++++++++++++--
 1 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index b860d4f..fc62a3f 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -84,8 +84,9 @@ static const u16 e1000_igp_2_cable_length_table[] = {
 #define I82577_PHY_STATUS2_SPEED_1000MBPS 0x0200
 
 /* I82577 PHY Control 2 */
-#define I82577_PHY_CTRL2_AUTO_MDIX        0x0400
-#define I82577_PHY_CTRL2_FORCE_MDI_MDIX   0x0200
+#define I82577_PHY_CTRL2_MANUAL_MDIX      0x0200
+#define I82577_PHY_CTRL2_AUTO_MDI_MDIX    0x0400
+#define I82577_PHY_CTRL2_MDIX_CFG_MASK    0x0600
 
 /* I82577 PHY Diagnostics Status */
 #define I82577_DSTATUS_CABLE_LENGTH       0x03FC
@@ -702,6 +703,32 @@ s32 e1000_copper_link_setup_82577(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
+	/* Set MDI/MDIX mode */
+	ret_val = e1e_rphy(hw, I82577_PHY_CTRL_2, &phy_data);
+	if (ret_val)
+		return ret_val;
+	phy_data &= ~I82577_PHY_CTRL2_MDIX_CFG_MASK;
+	/*
+	 * Options:
+	 *   0 - Auto (default)
+	 *   1 - MDI mode
+	 *   2 - MDI-X mode
+	 */
+	switch (hw->phy.mdix) {
+	case 1:
+		break;
+	case 2:
+		phy_data |= I82577_PHY_CTRL2_MANUAL_MDIX;
+		break;
+	case 0:
+	default:
+		phy_data |= I82577_PHY_CTRL2_AUTO_MDI_MDIX;
+		break;
+	}
+	ret_val = e1e_wphy(hw, I82577_PHY_CTRL_2, phy_data);
+	if (ret_val)
+		return ret_val;
+
 	return e1000_set_master_slave_mode(hw);
 }
 
