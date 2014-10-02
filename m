From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] ixgbe: fix setting of TXDCTL.WTRHESH when ITR is set to 0 and no BQL
Date: Thu,  2 Oct 2014 03:16:30 -0700
Message-ID: <1412244994-23636-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25391 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750987AbaJBKQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 06:16:44 -0400
In-Reply-To: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch consolidates the logic behind dynamically setting TXDCTL.WTHRESH
depending on interrupt throttle rate (ITR) setting regardless of BQL.

Previously TXDCTL.WTHRESH was dynamically being set only with BQL being
enabled, but we have to set it regardless of BQL when ITR is low to avoid
Tx stalls/hangs.

CC: John Greene <jogreene@redhat.com>
Reported by: Masayuki Gouji <gouji.masayuki@jp.fujitsu.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 4 ----
 2 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index cff383b..3ce4a25 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2267,7 +2267,6 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	if (adapter->q_vector[0]->tx.count && adapter->q_vector[0]->rx.count)
 		adapter->tx_itr_setting = adapter->rx_itr_setting;
 
-#if IS_ENABLED(CONFIG_BQL)
 	/* detect ITR changes that require update of TXDCTL.WTHRESH */
 	if ((adapter->tx_itr_setting != 1) &&
 	    (adapter->tx_itr_setting < IXGBE_100K_ITR)) {
@@ -2279,7 +2278,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		    (tx_itr_prev < IXGBE_100K_ITR))
 			need_reset = true;
 	}
-#endif
+
 	/* check the old value and enable RSC if necessary */
 	need_reset |= ixgbe_update_rsc(adapter);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2daf257..d677b5a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2982,11 +2982,7 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 	 * to or less than the number of on chip descriptors, which is
 	 * currently 40.
 	 */
-#if IS_ENABLED(CONFIG_BQL)
 	if (!ring->q_vector || (ring->q_vector->itr < IXGBE_100K_ITR))
-#else
-	if (!ring->q_vector || (ring->q_vector->itr < 8))
-#endif
 		txdctl |= (1 << 16);	/* WTHRESH = 1 */
 	else
 		txdctl |= (8 << 16);	/* WTHRESH = 8 */
-- 
1.9.3
