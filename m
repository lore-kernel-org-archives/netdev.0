From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] i40e: fix CONFIG_BUSY checks in i40e_set_settings function
Date: Wed, 19 Apr 2017 18:57:45 -0700
Message-ID: <20170420015750.6828-10-jeffrey.t.kirsher@intel.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:29694 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939106AbdDTB6B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 21:58:01 -0400
In-Reply-To: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The check for I40E_CONFIG_BUSY state bit in the i40e_set_link_ksettings
function is fishy. First we can notice a few things about the check here.

First a similar check was introduced by commit
'c7d05ca89f8e ("i40e: driver ethtool core")'

Later a commit introducing the link settings was added by commit
'bf9c71417f72 ("i40e: Implement set_settings for ethtool")'

However, this second check was against vsi->state instead of pf->state,
and also failed to set the bit, it only checks. That indicates the locking
was not quite correct. The only other place that the state bit
in vsi->state gets used is to protect the filter list.

Since this code does not care about the mac filter list,  and seems
clear the original code should have set the pf->state bit. Fix these
issues by using pf->state correctly, and by actually setting the bit
so that we properly lock as expected.

Since these checks occur while holding the rtnl_lock(), lets also add a
timeout so that we don't potentially softlock the system.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 38 ++++++++++++++++++++------
 1 file changed, 29 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 10325b5a9805..08035c4389cd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -698,6 +698,7 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 	struct ethtool_link_ksettings copy_cmd;
 	i40e_status status = 0;
 	bool change = false;
+	int timeout = 50;
 	int err = 0;
 	u32 autoneg;
 	u32 advertise;
@@ -756,14 +757,20 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 	if (memcmp(&copy_cmd, &safe_cmd, sizeof(struct ethtool_link_ksettings)))
 		return -EOPNOTSUPP;
 
-	while (test_bit(__I40E_CONFIG_BUSY, &vsi->state))
+	while (test_and_set_bit(__I40E_CONFIG_BUSY, &pf->state)) {
+		timeout--;
+		if (!timeout)
+			return -EBUSY;
 		usleep_range(1000, 2000);
+	}
 
 	/* Get the current phy config */
 	status = i40e_aq_get_phy_capabilities(hw, false, false, &abilities,
 					      NULL);
-	if (status)
-		return -EAGAIN;
+	if (status) {
+		err = -EAGAIN;
+		goto done;
+	}
 
 	/* Copy abilities to config in case autoneg is not
 	 * set below
@@ -779,7 +786,8 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 			if (!ethtool_link_ksettings_test_link_mode(
 				    &safe_cmd, supported, Autoneg)) {
 				netdev_info(netdev, "Autoneg not supported on this phy\n");
-				return -EINVAL;
+				err = -EINVAL;
+				goto done;
 			}
 			/* Autoneg is allowed to change */
 			config.abilities = abilities.abilities |
@@ -797,7 +805,8 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 			    hw->phy.link_info.phy_type !=
 			    I40E_PHY_TYPE_10GBASE_T) {
 				netdev_info(netdev, "Autoneg cannot be disabled on this phy\n");
-				return -EINVAL;
+				err = -EINVAL;
+				goto done;
 			}
 			/* Autoneg is allowed to change */
 			config.abilities = abilities.abilities &
@@ -808,8 +817,10 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 
 	ethtool_convert_link_mode_to_legacy_u32(&tmp,
 						safe_cmd.link_modes.supported);
-	if (advertise & ~tmp)
-		return -EINVAL;
+	if (advertise & ~tmp) {
+		err = -EINVAL;
+		goto done;
+	}
 
 	if (advertise & ADVERTISED_100baseT_Full)
 		config.link_speed |= I40E_LINK_SPEED_100MB;
@@ -865,7 +876,8 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 			netdev_info(netdev, "Set phy config failed, err %s aq_err %s\n",
 				    i40e_stat_str(hw, status),
 				    i40e_aq_str(hw, hw->aq.asq_last_status));
-			return -EAGAIN;
+			err = -EAGAIN;
+			goto done;
 		}
 
 		status = i40e_update_link_info(hw);
@@ -878,6 +890,9 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 		netdev_info(netdev, "Nothing changed, exiting without setting anything.\n");
 	}
 
+done:
+	clear_bit(__I40E_CONFIG_BUSY, &pf->state);
+
 	return err;
 }
 
@@ -1292,6 +1307,7 @@ static int i40e_set_ringparam(struct net_device *netdev,
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
 	u32 new_rx_count, new_tx_count;
+	int timeout = 50;
 	int i, err = 0;
 
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
@@ -1316,8 +1332,12 @@ static int i40e_set_ringparam(struct net_device *netdev,
 	    (new_rx_count == vsi->rx_rings[0]->count))
 		return 0;
 
-	while (test_and_set_bit(__I40E_CONFIG_BUSY, &pf->state))
+	while (test_and_set_bit(__I40E_CONFIG_BUSY, &pf->state)) {
+		timeout--;
+		if (!timeout)
+			return -EBUSY;
 		usleep_range(1000, 2000);
+	}
 
 	if (!netif_running(vsi->netdev)) {
 		/* simple case - set for the next time the netdev is started */
-- 
2.12.2
