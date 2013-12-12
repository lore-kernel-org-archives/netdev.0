From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: fix pf reset after offline test
Date: Thu, 12 Dec 2013 04:40:39 -0800
Message-ID: <1386852051-27907-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26106 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535Ab3LLMlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 07:41:00 -0500
In-Reply-To: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

When the ethtool testing starts it sets the I40E_TESTING state
bit, which blocks new netdev opens so that things don't get
confused, while the testing might be messing with register and
other things.  Unfortunately, that was keeping the PF resets
after the register test from working correctly because the netdev
would not get reopened.  This patch reorders the tests to put the
register test last as it is the only one that needs a reset, and
we wait to trigger the reset until after we clear the
I40E_TESTING bit.

Change-Id: Ieaa18d74264250ac336b0656b490125ee8a22d2a
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index eb34375..9c380a8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -748,7 +748,6 @@ static int i40e_reg_test(struct net_device *netdev, u64 *data)
 	netif_info(pf, hw, netdev, "register test\n");
 	*data = i40e_diag_reg_test(&pf->hw);
 
-	i40e_do_reset(pf, (1 << __I40E_PF_RESET_REQUESTED));
 	return *data;
 }
 
@@ -796,20 +795,18 @@ static void i40e_diag_test(struct net_device *netdev,
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_pf *pf = np->vsi->back;
 
-	set_bit(__I40E_TESTING, &pf->state);
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
 		/* Offline tests */
 		netif_info(pf, drv, netdev, "offline testing starting\n");
 
+		set_bit(__I40E_TESTING, &pf->state);
+
 		/* Link test performed before hardware reset
 		 * so autoneg doesn't interfere with test result
 		 */
 		if (i40e_link_test(netdev, &data[I40E_ETH_TEST_LINK]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		if (i40e_reg_test(netdev, &data[I40E_ETH_TEST_REG]))
-			eth_test->flags |= ETH_TEST_FL_FAILED;
-
 		if (i40e_eeprom_test(netdev, &data[I40E_ETH_TEST_EEPROM]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
@@ -819,6 +816,12 @@ static void i40e_diag_test(struct net_device *netdev,
 		if (i40e_loopback_test(netdev, &data[I40E_ETH_TEST_LOOPBACK]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
+		/* run reg test last, a reset is required after it */
+		if (i40e_reg_test(netdev, &data[I40E_ETH_TEST_REG]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		clear_bit(__I40E_TESTING, &pf->state);
+		i40e_do_reset(pf, (1 << __I40E_PF_RESET_REQUESTED));
 	} else {
 		/* Online tests */
 		netif_info(pf, drv, netdev, "online testing starting\n");
@@ -832,7 +835,6 @@ static void i40e_diag_test(struct net_device *netdev,
 		data[I40E_ETH_TEST_INTR] = 0;
 		data[I40E_ETH_TEST_LOOPBACK] = 0;
 	}
-	clear_bit(__I40E_TESTING, &pf->state);
 
 	netif_info(pf, drv, netdev, "testing finished\n");
 }
-- 
1.8.3.1
