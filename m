From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] i40e: Fix ethtool offline test
Date: Thu,  5 Mar 2015 08:46:26 -0800
Message-ID: <1425573992-30955-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47536 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754662AbbCEQqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:39 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

If the system administrator is requesting an offline diagnostic test using
'ethtool -t' then we should, you know, actually take the device offline
before doing the testing.

Change-ID: I6afa1cbfcc821c9ab6e6f47ed4d8dc2d8dd20e82
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 7413b0e..415aebc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1530,6 +1530,7 @@ static void i40e_diag_test(struct net_device *netdev,
 			   struct ethtool_test *eth_test, u64 *data)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	bool if_running = netif_running(netdev);
 	struct i40e_pf *pf = np->vsi->back;
 
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
@@ -1537,6 +1538,12 @@ static void i40e_diag_test(struct net_device *netdev,
 		netif_info(pf, drv, netdev, "offline testing starting\n");
 
 		set_bit(__I40E_TESTING, &pf->state);
+		/* If the device is online then take it offline */
+		if (if_running)
+			/* indicate we're in test mode */
+			dev_close(netdev);
+		else
+			i40e_do_reset(pf, (1 << __I40E_PF_RESET_REQUESTED));
 
 		/* Link test performed before hardware reset
 		 * so autoneg doesn't interfere with test result
@@ -1559,6 +1566,9 @@ static void i40e_diag_test(struct net_device *netdev,
 
 		clear_bit(__I40E_TESTING, &pf->state);
 		i40e_do_reset(pf, (1 << __I40E_PF_RESET_REQUESTED));
+
+		if (if_running)
+			dev_open(netdev);
 	} else {
 		/* Online tests */
 		netif_info(pf, drv, netdev, "online testing starting\n");
-- 
1.9.3
