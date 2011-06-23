From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] ixgbe: fix flags relating to perfect filters to support coexistence
Date: Wed, 22 Jun 2011 18:44:26 -0700
Message-ID: <1308793476-11596-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308793476-11596-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:43939 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932287Ab1FWBol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 21:44:41 -0400
In-Reply-To: <1308793476-11596-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

I am removing the requirement that Ntuple filters have the same
number of queues and requirements as ATR.  As a result this change will
make it so that all the Ntuple flag does is disable ATR for now.

This change fixes an issue in which we were incorrectly re-enabling ATR
when we exited perfect filter mode.  This was due to the fact that the
logic assumed RSS and DCB were mutually exclusive which is no longer the
case.

To correct this we just need to add a check to guarantee DCB is disabled
before re-enabling ATR.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c  |   13 ++++++-------
 drivers/net/ixgbe/ixgbe_ethtool.c |   24 ++++++++++++------------
 drivers/net/ixgbe/ixgbe_main.c    |   34 ++++++++++++----------------------
 3 files changed, 30 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 08c7aeb..bd2d752 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -114,11 +114,12 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 	u8 err = 0;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
+	/* verify there is something to do, if not then exit */
+	if (!!state != !(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+		return err;
+
 	if (state > 0) {
 		/* Turn on DCB */
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
-			goto out;
-
 		if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
 			e_err(drv, "Enable failed, needs MSI-X\n");
 			err = 1;
@@ -143,9 +144,6 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 		ixgbe_setup_tc(netdev, MAX_TRAFFIC_CLASS);
 	} else {
 		/* Turn off DCB */
-		if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
-			goto out;
-
 		adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
 		adapter->temp_dcb_cfg.pfc_mode_enable = false;
 		adapter->dcb_cfg.pfc_mode_enable = false;
@@ -153,7 +151,8 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 		switch (adapter->hw.mac.type) {
 		case ixgbe_mac_82599EB:
 		case ixgbe_mac_X540:
-			adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+			if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
+				adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
 			break;
 		default:
 			break;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index e41dd24..a2d8ed5 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2310,20 +2310,20 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 	 * Check if Flow Director n-tuple support was enabled or disabled.  If
 	 * the state changed, we need to reset.
 	 */
-	if ((adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) &&
-	    (!(data & ETH_FLAG_NTUPLE))) {
-		/* turn off Flow Director perfect, set hash and reset */
+	if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) {
+		/* turn off ATR, enable perfect filters and reset */
+		if (data & ETH_FLAG_NTUPLE) {
+			adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+			adapter->flags |= IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+			need_reset = true;
+		}
+	} else if (!(data & ETH_FLAG_NTUPLE)) {
+		/* turn off Flow Director, set ATR and reset */
 		adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
-		adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
-		need_reset = true;
-	} else if ((!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) &&
-	           (data & ETH_FLAG_NTUPLE)) {
-		/* turn off Flow Director hash, enable perfect and reset */
-		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-		adapter->flags |= IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+		if ((adapter->flags & IXGBE_FLAG_RSS_ENABLED) &&
+		    !(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+			adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
 		need_reset = true;
-	} else {
-		/* no state change */
 	}
 
 	if (need_reset) {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 4cd66ae..5483b9c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1555,9 +1555,8 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 			q_vector->eitr = adapter->rx_eitr_param;
 
 		ixgbe_write_eitr(q_vector);
-		/* If Flow Director is enabled, set interrupt affinity */
-		if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
-		    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) {
+		/* If ATR is enabled, set interrupt affinity */
+		if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
 			/*
 			 * Allocate the affinity_hint cpumask, assign the mask
 			 * for this vector, and set our affinity_hint for
@@ -2468,8 +2467,7 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
 	default:
 		break;
 	}
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
-	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
 		mask |= IXGBE_EIMS_FLOW_DIR;
 
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
@@ -3767,8 +3765,6 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 			adapter->tx_ring[i]->atr_sample_rate =
 						       adapter->atr_sample_rate;
 		ixgbe_init_fdir_signature_82599(hw, adapter->fdir_pballoc);
-	} else if (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) {
-		ixgbe_init_fdir_perfect_82599(hw, adapter->fdir_pballoc);
 	}
 	ixgbe_configure_virtualization(adapter);
 
@@ -4334,15 +4330,13 @@ static inline bool ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
 	f_fdir->mask = 0;
 
 	/* Flow Director must have RSS enabled */
-	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED &&
-	    ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
-	     (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)))) {
+	if ((adapter->flags & IXGBE_FLAG_RSS_ENABLED) &&
+	    (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)) {
 		adapter->num_tx_queues = f_fdir->indices;
 		adapter->num_rx_queues = f_fdir->indices;
 		ret = true;
 	} else {
 		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-		adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
 	}
 	return ret;
 }
@@ -4372,12 +4366,12 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 		e_info(probe, "FCoE enabled with RSS\n");
-		if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
-		    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
+		if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
 			ixgbe_set_fdir_queues(adapter);
 		else
 			ixgbe_set_rss_queues(adapter);
 	}
+
 	/* adding FCoE rx rings to the end */
 	f->mask = adapter->num_rx_queues;
 	adapter->num_rx_queues += f->indices;
@@ -4670,9 +4664,8 @@ static inline bool ixgbe_cache_ring_fdir(struct ixgbe_adapter *adapter)
 	int i;
 	bool ret = false;
 
-	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED &&
-	    ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
-	     (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))) {
+	if ((adapter->flags & IXGBE_FLAG_RSS_ENABLED) &&
+	    (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)) {
 		for (i = 0; i < adapter->num_rx_queues; i++)
 			adapter->rx_ring[i]->reg_idx = i;
 		for (i = 0; i < adapter->num_tx_queues; i++)
@@ -4701,8 +4694,7 @@ static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 		return false;
 
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-		if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
-		    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
+		if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
 			ixgbe_cache_ring_fdir(adapter);
 		else
 			ixgbe_cache_ring_rss(adapter);
@@ -4882,14 +4874,12 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 
 	adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 	adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
-	if (adapter->flags & (IXGBE_FLAG_FDIR_HASH_CAPABLE |
-			      IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) {
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
 		e_err(probe,
-		      "Flow Director is not supported while multiple "
+		      "ATR is not supported while multiple "
 		      "queues are disabled.  Disabling Flow Director\n");
 	}
 	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-	adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
 	adapter->atr_sample_rate = 0;
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		ixgbe_disable_sriov(adapter);
-- 
1.7.5.4

