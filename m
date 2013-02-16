From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] ixgbe: fix Tx timeouts with BQL
Date: Sat, 16 Feb 2013 00:33:35 -0800
Message-ID: <1361003616-3422-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21658 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752532Ab3BPIdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 03:33:49 -0500
In-Reply-To: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch makes sure that TXDCTL.WTHRESH is set to 1 when BQL is enabled
and EITR is set to more than 100k interrupts per second to avoid Tx timeouts.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 33 +++++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  8 +++++-
 2 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index e6cebdc..f4d2e9e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2113,13 +2113,17 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_q_vector *q_vector;
 	int i;
-	u16 tx_itr_param, rx_itr_param;
+	u16 tx_itr_param, rx_itr_param, tx_itr_prev;
 	bool need_reset = false;
 
-	/* don't accept tx specific changes if we've got mixed RxTx vectors */
-	if (adapter->q_vector[0]->tx.count && adapter->q_vector[0]->rx.count
-	    && ec->tx_coalesce_usecs)
-		return -EINVAL;
+	if (adapter->q_vector[0]->tx.count && adapter->q_vector[0]->rx.count) {
+		/* reject Tx specific changes in case of mixed RxTx vectors */
+		if (ec->tx_coalesce_usecs)
+			return -EINVAL;
+		tx_itr_prev = adapter->rx_itr_setting;
+	} else {
+		tx_itr_prev = adapter->tx_itr_setting;
+	}
 
 	if ((ec->rx_coalesce_usecs > (IXGBE_MAX_EITR >> 2)) ||
 	    (ec->tx_coalesce_usecs > (IXGBE_MAX_EITR >> 2)))
@@ -2145,8 +2149,25 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	else
 		tx_itr_param = adapter->tx_itr_setting;
 
+	/* mixed Rx/Tx */
+	if (adapter->q_vector[0]->tx.count && adapter->q_vector[0]->rx.count)
+		adapter->tx_itr_setting = adapter->rx_itr_setting;
+
+#if IS_ENABLED(CONFIG_BQL)
+	/* detect ITR changes that require update of TXDCTL.WTHRESH */
+	if ((adapter->tx_itr_setting > 1) &&
+	    (adapter->tx_itr_setting < IXGBE_100K_ITR)) {
+		if ((tx_itr_prev == 1) ||
+		    (tx_itr_prev > IXGBE_100K_ITR))
+			need_reset = true;
+	} else {
+		if ((tx_itr_prev > 1) &&
+		    (tx_itr_prev < IXGBE_100K_ITR))
+			need_reset = true;
+	}
+#endif
 	/* check the old value and enable RSC if necessary */
-	need_reset = ixgbe_update_rsc(adapter);
+	need_reset |= ixgbe_update_rsc(adapter);
 
 	for (i = 0; i < adapter->num_q_vectors; i++) {
 		q_vector = adapter->q_vector[i];
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b0b72fc..68478d6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2786,13 +2786,19 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 
 	/*
 	 * set WTHRESH to encourage burst writeback, it should not be set
-	 * higher than 1 when ITR is 0 as it could cause false TX hangs
+	 * higher than 1 when:
+	 * - ITR is 0 as it could cause false TX hangs
+	 * - ITR is set to > 100k int/sec and BQL is enabled
 	 *
 	 * In order to avoid issues WTHRESH + PTHRESH should always be equal
 	 * to or less than the number of on chip descriptors, which is
 	 * currently 40.
 	 */
+#if IS_ENABLED(CONFIG_BQL)
+	if (!ring->q_vector || (ring->q_vector->itr < IXGBE_100K_ITR))
+#else
 	if (!ring->q_vector || (ring->q_vector->itr < 8))
+#endif
 		txdctl |= (1 << 16);	/* WTHRESH = 1 */
 	else
 		txdctl |= (8 << 16);	/* WTHRESH = 8 */
-- 
1.7.11.7
