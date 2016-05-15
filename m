From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] i40e: Add support for disabling all link and change bits needed for PHY interactions
Date: Sat, 14 May 2016 21:57:23 -0700
Message-ID: <1463288255-1654-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57094 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704AbcEOE5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:38 -0400
In-Reply-To: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

Add flag to tell firmware to disable link on all ports.

This patch changes the bits set for telling firmware the PHY needs
to be modified by driver.  Without this patch, the setting will only
set that mode for the current port on the device.  Because the
MDIO interface is common for the copper device. The command needs to
set the mode for all ports.

Change-ID: I8baa7da91d384291ac95b41ae1a516604f8eb67f
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h            | 4 +++-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h | 3 +++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c    | 2 +-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 2a6a5d3..01cc732 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -111,7 +111,9 @@
 #define I40E_OEM_VER_PATCH_MASK    0xff
 #define I40E_OEM_VER_BUILD_SHIFT   8
 #define I40E_OEM_VER_SHIFT         24
-#define I40E_PHY_DEBUG_PORT        BIT(4)
+#define I40E_PHY_DEBUG_ALL \
+	(I40E_AQ_PHY_DEBUG_DISABLE_LINK_FW | \
+	I40E_AQ_PHY_DEBUG_DISABLE_ALL_LINK_FW)
 
 /* The values in here are decimal coded as hex as is the case in the NVM map*/
 #define I40E_CURRENT_NVM_VERSION_HI 0x2
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index eacbe74..11cf1a5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -1833,7 +1833,10 @@ struct i40e_aqc_set_phy_debug {
 #define I40E_AQ_PHY_DEBUG_RESET_EXTERNAL_NONE	0x00
 #define I40E_AQ_PHY_DEBUG_RESET_EXTERNAL_HARD	0x01
 #define I40E_AQ_PHY_DEBUG_RESET_EXTERNAL_SOFT	0x02
+/* Disable link manageability on a single port */
 #define I40E_AQ_PHY_DEBUG_DISABLE_LINK_FW	0x10
+/* Disable link manageability on all ports */
+#define I40E_AQ_PHY_DEBUG_DISABLE_ALL_LINK_FW	0x20
 	u8	reserved[15];
 };
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 51a994d..6fa05c4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1880,7 +1880,7 @@ static int i40e_set_phys_id(struct net_device *netdev,
 		if (!(pf->flags & I40E_FLAG_HAVE_10GBASET_PHY)) {
 			pf->led_status = i40e_led_get(hw);
 		} else {
-			i40e_aq_set_phy_debug(hw, I40E_PHY_DEBUG_PORT, NULL);
+			i40e_aq_set_phy_debug(hw, I40E_PHY_DEBUG_ALL, NULL);
 			ret = i40e_led_get_phy(hw, &temp_status,
 					       &pf->phy_led_val);
 			pf->led_status = temp_status;
-- 
2.5.5
