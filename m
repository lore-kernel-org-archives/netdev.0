From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: Tell OS link is going down when calling set_phy_config
Date: Fri, 29 Aug 2014 02:30:10 -0700
Message-ID: <1409304620-23251-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53242 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752509AbaH2JaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:25 -0400
In-Reply-To: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Since we don't seem to be getting an LSE telling us link is going down
during set_phy_config (but we do get an LSE telling us we are coming
back up), fake one for the OS and tell them link is going down. Also
do an atomic restart no matter what because there are times the user
may want to end with link up even if they started with link down (like
if they accidentally set it to a speed that can't link and are trying to
fix it).

Change-ID: I0a642af9c1d0feb67bce741aba1a9c33bd349ed6
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index de4ce0e..101be2f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -559,9 +559,17 @@ static int i40e_set_settings(struct net_device *netdev,
 		config.eeer = abilities.eeer_val;
 		config.low_power_ctrl = abilities.d3_lpan;
 
-		/* If link is up set link and an so changes take effect */
-		if (hw->phy.link_info.link_info & I40E_AQ_LINK_UP)
-			config.abilities |= I40E_AQ_PHY_ENABLE_ATOMIC_LINK;
+		/* set link and an so changes take effect */
+		config.abilities |= I40E_AQ_PHY_ENABLE_ATOMIC_LINK;
+		/* If link is up put link down */
+		if (hw->phy.link_info.link_info & I40E_AQ_LINK_UP) {
+			/* Tell the OS link is going down, the link will go
+			 * back up when fw says it is ready asynchronously
+			 */
+			netdev_info(netdev, "PHY settings change requested, NIC Link is going down.\n");
+			netif_carrier_off(netdev);
+			netif_tx_stop_all_queues(netdev);
+		}
 
 		/* make the aq call */
 		status = i40e_aq_set_phy_config(hw, &config, NULL);
@@ -678,6 +686,13 @@ static int i40e_set_pauseparam(struct net_device *netdev,
 	else
 		 return -EINVAL;
 
+	/* Tell the OS link is going down, the link will go back up when fw
+	 * says it is ready asynchronously
+	 */
+	netdev_info(netdev, "Flow control settings change requested, NIC Link is going down.\n");
+	netif_carrier_off(netdev);
+	netif_tx_stop_all_queues(netdev);
+
 	/* Set the fc mode and only restart an if link is up*/
 	status = i40e_set_fc(hw, &aq_failures, link_up);
 
-- 
1.9.3
