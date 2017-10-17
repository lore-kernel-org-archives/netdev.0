From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: convert i40e_set_link_ksettings to new API
Date: Tue, 17 Oct 2017 11:21:18 -0700
Message-ID: <20171017182119.71989-15-jeffrey.t.kirsher@intel.com>
References: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:41366 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937370AbdJQSVo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 14:21:44 -0400
In-Reply-To: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

This finishes off the conversion to the new ethtool API by removing the
old macros being used in i40e_set_link_ksettings and replacing them with
shiny new ones.

This conversion also allows us to provide link speed support for new 25G
and 10G macros which is included here as well.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 93 ++++++++++++++++----------
 1 file changed, 57 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 9c70555bf49c..9eb618799a30 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -832,9 +832,7 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 	i40e_status status = 0;
 	int timeout = 50;
 	int err = 0;
-	u32 autoneg;
-	u32 advertise;
-	u32 tmp;
+	u8 autoneg;
 
 	/* Changing port settings is not supported if this isn't the
 	 * port's controlling PF
@@ -862,28 +860,34 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 	/* copy the ksettings to copy_ks to avoid modifying the origin */
 	memcpy(&copy_ks, ks, sizeof(struct ethtool_link_ksettings));
 
+	/* save autoneg out of ksettings */
+	autoneg = copy_ks.base.autoneg;
+
+	memset(&safe_ks, 0, sizeof(safe_ks));
+	/* Get link modes supported by hardware and check against modes
+	 * requested by the user.  Return an error if unsupported mode was set.
+	 */
+	i40e_phy_type_to_ethtool(pf, &safe_ks);
+	if (!bitmap_subset(copy_ks.link_modes.advertising,
+			   safe_ks.link_modes.supported,
+			   __ETHTOOL_LINK_MODE_MASK_NBITS))
+		return -EINVAL;
+
 	/* get our own copy of the bits to check against */
 	memset(&safe_ks, 0, sizeof(struct ethtool_link_ksettings));
+	safe_ks.base.cmd = copy_ks.base.cmd;
+	safe_ks.base.link_mode_masks_nwords =
+		copy_ks.base.link_mode_masks_nwords;
 	i40e_get_link_ksettings(netdev, &safe_ks);
 
-	/* save autoneg and speed out of ksettings */
-	autoneg = ks->base.autoneg;
-	ethtool_convert_link_mode_to_legacy_u32(&advertise,
-						ks->link_modes.advertising);
-
-	/* set autoneg and speed back to what they currently are */
+	/* set autoneg back to what it currently is */
 	copy_ks.base.autoneg = safe_ks.base.autoneg;
-	ethtool_convert_link_mode_to_legacy_u32(
-		&tmp, safe_ks.link_modes.advertising);
-	ethtool_convert_legacy_u32_to_link_mode(
-		copy_ks.link_modes.advertising, tmp);
 
-	copy_ks.base.cmd = safe_ks.base.cmd;
-
-	/* If copy_ks and safe_ks are not the same now, then they are
-	 * trying to set something that we do not support
+	/* If copy_ks.base and safe_ks.base are not the same now, then they are
+	 * trying to set something that we do not support.
 	 */
-	if (memcmp(&copy_ks, &safe_ks, sizeof(struct ethtool_link_ksettings)))
+	if (memcmp(&copy_ks.base, &safe_ks.base,
+		   sizeof(struct ethtool_link_settings)))
 		return -EOPNOTSUPP;
 
 	while (test_and_set_bit(__I40E_CONFIG_BUSY, pf->state)) {
@@ -946,28 +950,45 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 		}
 	}
 
-	ethtool_convert_link_mode_to_legacy_u32(&tmp,
-						safe_ks.link_modes.supported);
-	if (advertise & ~tmp) {
-		err = -EINVAL;
-		goto done;
-	}
-
-	if (advertise & ADVERTISED_100baseT_Full)
+	if (ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  100baseT_Full))
 		config.link_speed |= I40E_LINK_SPEED_100MB;
-	if (advertise & ADVERTISED_1000baseT_Full ||
-	    advertise & ADVERTISED_1000baseKX_Full)
+	if (ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  1000baseT_Full) ||
+	    ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  1000baseX_Full) ||
+	    ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  1000baseKX_Full))
 		config.link_speed |= I40E_LINK_SPEED_1GB;
-	if (advertise & ADVERTISED_10000baseT_Full ||
-	    advertise & ADVERTISED_10000baseKX4_Full ||
-	    advertise & ADVERTISED_10000baseKR_Full)
+	if (ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  10000baseT_Full) ||
+	    ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  10000baseKX4_Full) ||
+	    ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  10000baseKR_Full) ||
+	    ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  10000baseCR_Full) ||
+	    ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  10000baseSR_Full))
 		config.link_speed |= I40E_LINK_SPEED_10GB;
-	if (advertise & ADVERTISED_20000baseKR2_Full)
+	if (ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  20000baseKR2_Full))
 		config.link_speed |= I40E_LINK_SPEED_20GB;
-	if (advertise & ADVERTISED_40000baseKR4_Full ||
-	    advertise & ADVERTISED_40000baseCR4_Full ||
-	    advertise & ADVERTISED_40000baseSR4_Full ||
-	    advertise & ADVERTISED_40000baseLR4_Full)
+	if (ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  25000baseCR_Full) ||
+	    ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  25000baseKR_Full) ||
+	    ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  25000baseSR_Full))
+		config.link_speed |= I40E_LINK_SPEED_25GB;
+	if (ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  40000baseKR4_Full) ||
+	    ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  40000baseCR4_Full) ||
+	    ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  40000baseSR4_Full) ||
+	    ethtool_link_ksettings_test_link_mode(ks, advertising,
+						  40000baseLR4_Full))
 		config.link_speed |= I40E_LINK_SPEED_40GB;
 
 	/* If speed didn't get set, set it to what it currently is.
-- 
2.14.2
