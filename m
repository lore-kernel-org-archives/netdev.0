From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] i40e: Give link more time after setting flow control
Date: Thu, 24 Jul 2014 06:13:23 -0700
Message-ID: <1406207604-31653-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36526 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759245AbaGXNOH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 09:14:07 -0400
In-Reply-To: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Give link a little more time to come back up after setting flow control
before resetting. In the new NVMs it is taking longer for link to come back.
This causes the driver to attempt to reset the link, which then errors
because the firmware was already in the middle of a reset. Also, initialize
err to 0.

Change-ID: I1cc987a944e389d8909c262da5796f50722b4d6b
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <jmyoungx@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index f1d241e..9c93ff2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -630,7 +630,7 @@ static int i40e_set_pauseparam(struct net_device *netdev,
 	bool link_up = hw_link_info->link_info & I40E_AQ_LINK_UP;
 	i40e_status status;
 	u8 aq_failures;
-	int err;
+	int err = 0;
 
 	if (vsi != pf->vsi[pf->lan_vsi])
 		return -EOPNOTSUPP;
@@ -683,8 +683,12 @@ static int i40e_set_pauseparam(struct net_device *netdev,
 		err = -EAGAIN;
 	}
 
-	if (!test_bit(__I40E_DOWN, &pf->state))
-		return i40e_nway_reset(netdev);
+	if (!test_bit(__I40E_DOWN, &pf->state)) {
+		/* Give it a little more time to try to come back */
+		msleep(75);
+		if (!test_bit(__I40E_DOWN, &pf->state))
+			return i40e_nway_reset(netdev);
+	}
 
 	return err;
 }
-- 
1.9.3
