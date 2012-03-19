From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/10] ixgbe: Correct flag values set by ixgbe_fix_features
Date: Mon, 19 Mar 2012 14:22:37 -0700
Message-ID: <1332192158-14771-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11090 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755507Ab2CSVWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 17:22:44 -0400
In-Reply-To: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch replaces the variable name data with the variable name features
for ixgbe_fix_features and ixgbe_set_features.  This helps to make some
issues more obvious such as the fact that we were disabling Rx VLAN tag
stripping when we should have been forcing it to be enabled when DCB is
enabled.

In addition there was deprecated code present that was disabling the LRO
flag if we had the itr value set too low.  I have updated this logic so
that we will now allow the LRO flag to be set, but will not enable RSC
until the rx-usecs value is high enough to allow enough time for Rx packet
coalescing.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   38 +++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   75 ++++++++++-----------
 3 files changed, 54 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 4ceac3a..e0cc311 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -101,8 +101,6 @@
 #define IXGBE_TX_FLAGS_VLAN_PRIO_SHIFT  29
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
 
-#define IXGBE_MAX_RSC_INT_RATE          162760
-
 #define IXGBE_MAX_VF_MC_ENTRIES         30
 #define IXGBE_MAX_VF_FUNCTIONS          64
 #define IXGBE_MAX_VFTA_ENTRIES          128
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index b64d8a2..31a2bf7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2137,31 +2137,29 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
  * this function must be called before setting the new value of
  * rx_itr_setting
  */
-static bool ixgbe_update_rsc(struct ixgbe_adapter *adapter,
-			     struct ethtool_coalesce *ec)
+static bool ixgbe_update_rsc(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
-	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE))
+	/* nothing to do if LRO or RSC are not enabled */
+	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) ||
+	    !(netdev->features & NETIF_F_LRO))
 		return false;
 
-	/* if interrupt rate is too high then disable RSC */
-	if (ec->rx_coalesce_usecs != 1 &&
-	    ec->rx_coalesce_usecs <= (IXGBE_MIN_RSC_ITR >> 2)) {
-		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
-			e_info(probe, "rx-usecs set too low, disabling RSC\n");
-			adapter->flags2 &= ~IXGBE_FLAG2_RSC_ENABLED;
-			return true;
-		}
-	} else {
-		/* check the feature flag value and enable RSC if necessary */
-		if ((netdev->features & NETIF_F_LRO) &&
-		    !(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)) {
-			e_info(probe, "rx-usecs set to %d, re-enabling RSC\n",
-			       ec->rx_coalesce_usecs);
+	/* check the feature flag value and enable RSC if necessary */
+	if (adapter->rx_itr_setting == 1 ||
+	    adapter->rx_itr_setting > IXGBE_MIN_RSC_ITR) {
+		if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)) {
 			adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
+			e_info(probe, "rx-usecs value high enough "
+				      "to re-enable RSC\n");
 			return true;
 		}
+	/* if interrupt rate is too high then disable RSC */
+	} else if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
+		adapter->flags2 &= ~IXGBE_FLAG2_RSC_ENABLED;
+		e_info(probe, "rx-usecs set too low, disabling RSC\n");
+		return true;
 	}
 	return false;
 }
@@ -2185,9 +2183,6 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	    (ec->tx_coalesce_usecs > (IXGBE_MAX_EITR >> 2)))
 		return -EINVAL;
 
-	/* check the old value and enable RSC if necessary */
-	need_reset = ixgbe_update_rsc(adapter, ec);
-
 	if (ec->rx_coalesce_usecs > 1)
 		adapter->rx_itr_setting = ec->rx_coalesce_usecs << 2;
 	else
@@ -2208,6 +2203,9 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	else
 		tx_itr_param = adapter->tx_itr_setting;
 
+	/* check the old value and enable RSC if necessary */
+	need_reset = ixgbe_update_rsc(adapter);
+
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
 		num_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 	else
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5c7e7d8..e9d9fca 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7492,54 +7492,52 @@ void ixgbe_do_reset(struct net_device *netdev)
 }
 
 static netdev_features_t ixgbe_fix_features(struct net_device *netdev,
-	netdev_features_t data)
+					    netdev_features_t features)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 #ifdef CONFIG_DCB
 	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
-		data &= ~NETIF_F_HW_VLAN_RX;
+		features &= ~NETIF_F_HW_VLAN_RX;
 #endif
 
 	/* return error if RXHASH is being enabled when RSS is not supported */
 	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
-		data &= ~NETIF_F_RXHASH;
+		features &= ~NETIF_F_RXHASH;
 
 	/* If Rx checksum is disabled, then RSC/LRO should also be disabled */
-	if (!(data & NETIF_F_RXCSUM))
-		data &= ~NETIF_F_LRO;
+	if (!(features & NETIF_F_RXCSUM))
+		features &= ~NETIF_F_LRO;
 
-	/* Turn off LRO if not RSC capable or invalid ITR settings */
-	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE)) {
-		data &= ~NETIF_F_LRO;
-	} else if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
-		   (adapter->rx_itr_setting != 1 &&
-		    adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE)) {
-		data &= ~NETIF_F_LRO;
-		e_info(probe, "rx-usecs set too low, not enabling RSC\n");
-	}
+	/* Turn off LRO if not RSC capable */
+	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE))
+		features &= ~NETIF_F_LRO;
+	
 
-	return data;
+	return features;
 }
 
 static int ixgbe_set_features(struct net_device *netdev,
-	netdev_features_t data)
+			      netdev_features_t features)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	netdev_features_t changed = netdev->features ^ data;
+	netdev_features_t changed = netdev->features ^ features;
 	bool need_reset = false;
 
 	/* Make sure RSC matches LRO, reset if change */
-	if (!!(data & NETIF_F_LRO) !=
-	     !!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)) {
-		adapter->flags2 ^= IXGBE_FLAG2_RSC_ENABLED;
-		switch (adapter->hw.mac.type) {
-		case ixgbe_mac_X540:
-		case ixgbe_mac_82599EB:
+	if (!(features & NETIF_F_LRO)) {
+		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
 			need_reset = true;
-			break;
-		default:
-			break;
+		adapter->flags2 &= ~IXGBE_FLAG2_RSC_ENABLED;
+	} else if ((adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) &&
+		   !(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)) {
+		if (adapter->rx_itr_setting == 1 ||
+		    adapter->rx_itr_setting > IXGBE_MIN_RSC_ITR) {
+			adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
+			need_reset = true;
+		} else if ((changed ^ features) & NETIF_F_LRO) {
+			e_info(probe, "rx-usecs set too low, "
+			       "disabling RSC\n");
 		}
 	}
 
@@ -7547,31 +7545,30 @@ static int ixgbe_set_features(struct net_device *netdev,
 	 * Check if Flow Director n-tuple support was enabled or disabled.  If
 	 * the state changed, we need to reset.
 	 */
-	if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) {
-		/* turn off ATR, enable perfect filters and reset */
-		if (data & NETIF_F_NTUPLE) {
-			adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-			adapter->flags |= IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+	if (!(features & NETIF_F_NTUPLE)) {
+		if (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) {
+			/* turn off Flow Director, set ATR and reset */
+			if ((adapter->flags & IXGBE_FLAG_RSS_ENABLED) &&
+			    !(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+				adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
 			need_reset = true;
 		}
-	} else if (!(data & NETIF_F_NTUPLE)) {
-		/* turn off Flow Director, set ATR and reset */
 		adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
-		if ((adapter->flags &  IXGBE_FLAG_RSS_ENABLED) &&
-		    !(adapter->flags &  IXGBE_FLAG_DCB_ENABLED))
-			adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+	} else if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) {
+		/* turn off ATR, enable perfect filters and reset */
+		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+		adapter->flags |= IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
 		need_reset = true;
 	}
 
 	if (changed & NETIF_F_RXALL)
 		need_reset = true;
 
-	netdev->features = data;
+	netdev->features = features;
 	if (need_reset)
 		ixgbe_do_reset(netdev);
 
 	return 0;
-
 }
 
 static const struct net_device_ops ixgbe_netdev_ops = {
@@ -7611,7 +7608,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 };
 
 static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
-			   const struct ixgbe_info *ii)
+				     const struct ixgbe_info *ii)
 {
 #ifdef CONFIG_PCI_IOV
 	struct ixgbe_hw *hw = &adapter->hw;
-- 
1.7.7.6
