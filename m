From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] ixgbe: fix rx-usecs range checks for BQL
Date: Thu, 24 Oct 2013 08:27:35 -0700
Message-ID: <1382628458-26601-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61169 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755507Ab3JXP1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 11:27:48 -0400
In-Reply-To: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch resolves an issue where the logic used to detect changes in rx-usecs
was incorrect and was masked by the call to ixgbe_update_rsc().

Setting rx-usecs between 0,2-9 and 1,10 and up requires a reset to allow
ixgbe_configure_tx_ring() to set the correct value for TXDCTL.WTHRESH in
order to avoid Tx hangs with BQL enabled.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 90aac31..4e7c9b0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2257,13 +2257,13 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 
 #if IS_ENABLED(CONFIG_BQL)
 	/* detect ITR changes that require update of TXDCTL.WTHRESH */
-	if ((adapter->tx_itr_setting > 1) &&
+	if ((adapter->tx_itr_setting != 1) &&
 	    (adapter->tx_itr_setting < IXGBE_100K_ITR)) {
 		if ((tx_itr_prev == 1) ||
-		    (tx_itr_prev > IXGBE_100K_ITR))
+		    (tx_itr_prev >= IXGBE_100K_ITR))
 			need_reset = true;
 	} else {
-		if ((tx_itr_prev > 1) &&
+		if ((tx_itr_prev != 1) &&
 		    (tx_itr_prev < IXGBE_100K_ITR))
 			need_reset = true;
 	}
-- 
1.8.3.1
