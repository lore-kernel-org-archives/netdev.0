From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/18] i40e: Never let speed get set to 0 in get_settings
Date: Wed,  7 Oct 2015 15:47:04 -0700
Message-ID: <1444258032-41476-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:48647 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753726AbbJGWrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:25 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

In ethtool, there is a possibility of speed getting set to 0
if advertise is set to 0 (which it is when autoneg is disabled).
We never want this to happen as the firmware will actually attempt
to set the speed to 0 sending link down, so add an extra check
to make sure this doesn't happen.

Change-ID: I62e0eeee2cbf043d8e6f5c9c9f0b92794e877f01
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 928bd5a..930369c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -666,6 +666,13 @@ static int i40e_set_settings(struct net_device *netdev,
 	    advertise & ADVERTISED_40000baseLR4_Full)
 		config.link_speed |= I40E_LINK_SPEED_40GB;
 
+	/* If speed didn't get set, set it to what it currently is.
+	 * This is needed because if advertise is 0 (as it is when autoneg
+	 * is disabled) then speed won't get set.
+	 */
+	if (!config.link_speed)
+		config.link_speed = abilities.link_speed;
+
 	if (change || (abilities.link_speed != config.link_speed)) {
 		/* copy over the rest of the abilities */
 		config.phy_type = abilities.phy_type;
-- 
2.4.3
