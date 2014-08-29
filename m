From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: Add dual speed module support
Date: Fri, 29 Aug 2014 02:30:06 -0700
Message-ID: <1409304620-23251-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53234 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbaH2JaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:24 -0400
In-Reply-To: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Now that fw has implemented dual speed module support, we can add ours.
Also, add the phy type for 1G LR/SR and set its media type to fiber.
Lastly, instead of a WARN_ON if the phy type is not recognized just print
a warning.

Change-ID: I2e5227d4a8c2907b0ed423038e5dbce774e466b0
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c  |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 31 +++++++++-----------------
 2 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 01874c0..30056b2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -752,6 +752,8 @@ static enum i40e_media_type i40e_get_media_type(struct i40e_hw *hw)
 	switch (hw->phy.link_info.phy_type) {
 	case I40E_PHY_TYPE_10GBASE_SR:
 	case I40E_PHY_TYPE_10GBASE_LR:
+	case I40E_PHY_TYPE_1000BASE_SX:
+	case I40E_PHY_TYPE_1000BASE_LX:
 	case I40E_PHY_TYPE_40GBASE_SR4:
 	case I40E_PHY_TYPE_40GBASE_LR4:
 		media = I40E_MEDIA_TYPE_FIBER;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 571d527..e701f42 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -313,7 +313,10 @@ static int i40e_get_settings(struct net_device *netdev,
 		break;
 	case I40E_PHY_TYPE_10GBASE_SR:
 	case I40E_PHY_TYPE_10GBASE_LR:
+	case I40E_PHY_TYPE_1000BASE_SX:
+	case I40E_PHY_TYPE_1000BASE_LX:
 		ecmd->supported = SUPPORTED_10000baseT_Full;
+		ecmd->supported |= SUPPORTED_1000baseT_Full;
 		break;
 	case I40E_PHY_TYPE_10GBASE_CR1_CU:
 	case I40E_PHY_TYPE_10GBASE_CR1:
@@ -352,7 +355,8 @@ static int i40e_get_settings(struct net_device *netdev,
 		break;
 	default:
 		/* if we got here and link is up something bad is afoot */
-		WARN_ON(link_up);
+		netdev_info(netdev, "WARNING: Link is up but PHY type 0x%x is not recognized.\n",
+			    hw_link_info->phy_type);
 	}
 
 no_valid_phy_type:
@@ -493,11 +497,10 @@ static int i40e_set_settings(struct net_device *netdev,
 	if (status)
 		return -EAGAIN;
 
-	/* Copy link_speed and abilities to config in case they are not
+	/* Copy abilities to config in case autoneg is not
 	 * set below
 	 */
 	memset(&config, 0, sizeof(struct i40e_aq_set_phy_config));
-	config.link_speed = abilities.link_speed;
 	config.abilities = abilities.abilities;
 
 	/* Check autoneg */
@@ -534,33 +537,21 @@ static int i40e_set_settings(struct net_device *netdev,
 		return -EINVAL;
 
 	if (advertise & ADVERTISED_100baseT_Full)
-		if (!(abilities.link_speed & I40E_LINK_SPEED_100MB)) {
-			config.link_speed |= I40E_LINK_SPEED_100MB;
-			change = true;
-		}
+		config.link_speed |= I40E_LINK_SPEED_100MB;
 	if (advertise & ADVERTISED_1000baseT_Full ||
 	    advertise & ADVERTISED_1000baseKX_Full)
-		if (!(abilities.link_speed & I40E_LINK_SPEED_1GB)) {
-			config.link_speed |= I40E_LINK_SPEED_1GB;
-			change = true;
-		}
+		config.link_speed |= I40E_LINK_SPEED_1GB;
 	if (advertise & ADVERTISED_10000baseT_Full ||
 	    advertise & ADVERTISED_10000baseKX4_Full ||
 	    advertise & ADVERTISED_10000baseKR_Full)
-		if (!(abilities.link_speed & I40E_LINK_SPEED_10GB)) {
-			config.link_speed |= I40E_LINK_SPEED_10GB;
-			change = true;
-		}
+		config.link_speed |= I40E_LINK_SPEED_10GB;
 	if (advertise & ADVERTISED_40000baseKR4_Full ||
 	    advertise & ADVERTISED_40000baseCR4_Full ||
 	    advertise & ADVERTISED_40000baseSR4_Full ||
 	    advertise & ADVERTISED_40000baseLR4_Full)
-		if (!(abilities.link_speed & I40E_LINK_SPEED_40GB)) {
-			config.link_speed |= I40E_LINK_SPEED_40GB;
-			change = true;
-		}
+		config.link_speed |= I40E_LINK_SPEED_40GB;
 
-	if (change) {
+	if (change || (abilities.link_speed != config.link_speed)) {
 		/* copy over the rest of the abilities */
 		config.phy_type = abilities.phy_type;
 		config.eee_capability = abilities.eee_capability;
-- 
1.9.3
