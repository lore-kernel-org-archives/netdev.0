From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] ixgbe: Fix handling of FDIR_HASH flag
Date: Sat, 21 Jul 2012 16:08:54 -0700
Message-ID: <1342912142-11130-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11129 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822Ab2GUXJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 19:09:09 -0400
In-Reply-To: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we can use the atr_sample_rate to determine if
we are capable of supporting ATR. The advantage to this approach is that it
allows us to now determine the setting of the IXGBE_FLAG_FDIR_HASH_CAPABLE
based on the queueing scheme, instead of the queueing scheme being based on
the flag.

Using this approach there are essentially 5 conditions that must be checked
prior to trying to enable ATR:
1.  Is SR-IOV disabled?
2.  Are the number of TCs <= 1?
3.  Is RSS queueing limit greater than 1?
4.  Is atr_sample_rate set?
5.  Is Flow Director perfect filtering disabled?

If any of these conditions are enabled they should disable ATR filtering.
Note that in the case of conditions 1 through 4 being met we will set
things up for ATR queueing, however if test 5 fails we will still leave the
queues allocated for use by perfect filters.  The reason for this is to
allow for us to switch back and forth between ntuple and ATR without
needing to reallocate the descriptor rings.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |   22 +++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   48 ++++++++++++++++---------
 2 files changed, 46 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 3ff5aa8..29a2a85 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -370,6 +370,9 @@ static bool ixgbe_set_dcb_sriov_queues(struct ixgbe_adapter *adapter)
 	adapter->ring_feature[RING_F_RSS].indices = 1;
 	adapter->ring_feature[RING_F_RSS].mask = IXGBE_RSS_DISABLED_MASK;
 
+	/* disable ATR as it is not supported when VMDq is enabled */
+	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+
 	adapter->num_rx_pools = vmdq_i;
 	adapter->num_rx_queues_per_pool = tcs;
 
@@ -450,6 +453,9 @@ static bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 	f->indices = rss_i;
 	f->mask = rss_m;
 
+	/* disable ATR as it is not supported when multiple TCs are enabled */
+	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+
 #ifdef IXGBE_FCOE
 	/* FCoE enabled queues require special configuration indexed
 	 * by feature specific indices and offset. Here we map FCoE
@@ -606,16 +612,22 @@ static bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 	f->indices = rss_i;
 	f->mask = IXGBE_RSS_16Q_MASK;
 
+	/* disable ATR by default, it will be configured below */
+	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+
 	/*
 	 * Use Flow Director in addition to RSS to ensure the best
 	 * distribution of flows across cores, even when an FDIR flow
 	 * isn't matched.
 	 */
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
+	if (rss_i > 1 && adapter->atr_sample_rate) {
 		f = &adapter->ring_feature[RING_F_FDIR];
 
 		f->indices = min_t(u16, num_online_cpus(), f->limit);
 		rss_i = max_t(u16, rss_i, f->indices);
+
+		if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
+			adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
 	}
 
 #ifdef IXGBE_FCOE
@@ -1054,13 +1066,7 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	}
 
 	adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
-		e_err(probe,
-		      "ATR is not supported while multiple "
-		      "queues are disabled.  Disabling Flow Director\n");
-	}
-	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-	adapter->atr_sample_rate = 0;
+
 	ixgbe_disable_sriov(adapter);
 
 	adapter->ring_feature[RING_F_RSS].limit = 1;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9c42679..7be3504 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2688,8 +2688,7 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 		   32;		/* PTHRESH = 32 */
 
 	/* reinitialize flowdirector state */
-	if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) &&
-	    adapter->atr_sample_rate) {
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
 		ring->atr_sample_rate = adapter->atr_sample_rate;
 		ring->atr_count = 0;
 		set_bit(__IXGBE_TX_FDIR_INIT_DONE, &ring->state);
@@ -4419,7 +4418,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		if (hw->device_id == IXGBE_DEV_ID_82599_T3_LOM)
 			adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_CAPABLE;
 		/* Flow Director hash filters enabled */
-		adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
 		adapter->atr_sample_rate = 20;
 		adapter->ring_feature[RING_F_FDIR].limit =
 							 IXGBE_MAX_FDIR_INDICES;
@@ -6726,7 +6724,6 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 		ixgbe_set_prio_tc_map(adapter);
 
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
-		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
 
 		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
 			adapter->last_lfc_mode = adapter->hw.fc.requested_mode;
@@ -6739,7 +6736,6 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 			adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
 
 		adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
-		adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
 
 		adapter->temp_dcb_cfg.pfc_mode_enable = false;
 		adapter->dcb_cfg.pfc_mode_enable = false;
@@ -6808,20 +6804,40 @@ static int ixgbe_set_features(struct net_device *netdev,
 	 * Check if Flow Director n-tuple support was enabled or disabled.  If
 	 * the state changed, we need to reset.
 	 */
-	if (!(features & NETIF_F_NTUPLE)) {
-		if (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) {
-			/* turn off Flow Director, set ATR and reset */
-			if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) &&
-			    !(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
-				adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
-			need_reset = true;
-		}
-		adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
-	} else if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) {
+	switch (features & NETIF_F_NTUPLE) {
+	case NETIF_F_NTUPLE:
 		/* turn off ATR, enable perfect filters and reset */
+		if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
+			need_reset = true;
+
 		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
 		adapter->flags |= IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
-		need_reset = true;
+		break;
+	default:
+		/* turn off perfect filters, enable ATR and reset */
+		if (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
+			need_reset = true;
+
+		adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+
+		/* We cannot enable ATR if SR-IOV is enabled */
+		if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+			break;
+
+		/* We cannot enable ATR if we have 2 or more traffic classes */
+		if (netdev_get_num_tc(netdev) > 1)
+			break;
+
+		/* We cannot enable ATR if RSS is disabled */
+		if (adapter->ring_feature[RING_F_RSS].limit <= 1)
+			break;
+
+		/* A sample rate of 0 indicates ATR disabled */
+		if (!adapter->atr_sample_rate)
+			break;
+
+		adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+		break;
 	}
 
 	if (features & NETIF_F_HW_VLAN_RX)
-- 
1.7.10.4
