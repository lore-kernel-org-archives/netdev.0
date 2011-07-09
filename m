From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/5] ixgbe: convert to ndo_fix_features
Date: Sat,  9 Jul 2011 04:50:40 -0700
Message-ID: <1310212240-24623-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1310212240-24623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Michal Miroslaw <mirq-linux@rere.qmqm.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29205 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409Ab1GILup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 07:50:45 -0400
In-Reply-To: <1310212240-24623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Private rx_csum flags are now duplicate of netdev->features &
NETIF_F_RXCSUM.  We remove those duplicates and now use the net_device_ops
ndo_set_features.  This was based on the original patch submitted by
Michal Miroslaw <mirq-linux@rere.qmqm.pl>.  I also removed the special
case not requiring a reset for X540 hardware.  It is needed just as it is
in 82599 hardware.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Cc:  Michal Miroslaw <mirq-linux@rere.qmqm.pl>
Tested-by: Phillip Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h         |    1 +
 drivers/net/ixgbe/ixgbe_ethtool.c |  188 -------------------------------------
 drivers/net/ixgbe/ixgbe_main.c    |  105 +++++++++++++++++++--
 3 files changed, 99 insertions(+), 195 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 744b641..2b96d8d 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -588,6 +588,7 @@ extern void ixgbe_clear_rscctl(struct ixgbe_adapter *adapter,
 extern void ixgbe_set_rx_mode(struct net_device *netdev);
 extern int ixgbe_setup_tc(struct net_device *dev, u8 tc);
 extern void ixgbe_tx_ctxtdesc(struct ixgbe_ring *, u32, u32, u32, u32);
+extern void ixgbe_do_reset(struct net_device *netdev);
 #ifdef IXGBE_FCOE
 extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fso(struct ixgbe_ring *tx_ring, struct sk_buff *skb,
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 074e9ba..06b7f88 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -442,109 +442,6 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 	return 0;
 }
 
-static void ixgbe_do_reset(struct net_device *netdev)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-
-	if (netif_running(netdev))
-		ixgbe_reinit_locked(adapter);
-	else
-		ixgbe_reset(adapter);
-}
-
-static u32 ixgbe_get_rx_csum(struct net_device *netdev)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	return adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED;
-}
-
-static void ixgbe_set_rsc(struct ixgbe_adapter *adapter)
-{
-	int i;
-
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		struct ixgbe_ring *ring = adapter->rx_ring[i];
-		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
-			set_ring_rsc_enabled(ring);
-			ixgbe_configure_rscctl(adapter, ring);
-		} else {
-			ixgbe_clear_rscctl(adapter, ring);
-		}
-	}
-}
-
-static int ixgbe_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	bool need_reset = false;
-
-	if (data) {
-		adapter->flags |= IXGBE_FLAG_RX_CSUM_ENABLED;
-	} else {
-		adapter->flags &= ~IXGBE_FLAG_RX_CSUM_ENABLED;
-
-		if (adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) {
-			adapter->flags2 &= ~IXGBE_FLAG2_RSC_ENABLED;
-			netdev->features &= ~NETIF_F_LRO;
-		}
-
-		switch (adapter->hw.mac.type) {
-		case ixgbe_mac_X540:
-			ixgbe_set_rsc(adapter);
-			break;
-		case ixgbe_mac_82599EB:
-			need_reset = true;
-			break;
-		default:
-			break;
-		}
-	}
-
-	if (need_reset)
-		ixgbe_do_reset(netdev);
-
-	return 0;
-}
-
-static u32 ixgbe_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_IP_CSUM) != 0;
-}
-
-static int ixgbe_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u32 feature_list;
-
-	feature_list = (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-		feature_list |= NETIF_F_SCTP_CSUM;
-		break;
-	default:
-		break;
-	}
-	if (data)
-		netdev->features |= feature_list;
-	else
-		netdev->features &= ~feature_list;
-
-	return 0;
-}
-
-static int ixgbe_set_tso(struct net_device *netdev, u32 data)
-{
-	if (data) {
-		netdev->features |= NETIF_F_TSO;
-		netdev->features |= NETIF_F_TSO6;
-	} else {
-		netdev->features &= ~NETIF_F_TSO;
-		netdev->features &= ~NETIF_F_TSO6;
-	}
-	return 0;
-}
-
 static u32 ixgbe_get_msglevel(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
@@ -2287,81 +2184,6 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	return 0;
 }
 
-static int ixgbe_set_flags(struct net_device *netdev, u32 data)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	bool need_reset = false;
-	int rc;
-
-#ifdef CONFIG_IXGBE_DCB
-	if ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
-	    !(data & ETH_FLAG_RXVLAN))
-		return -EINVAL;
-#endif
-
-	need_reset = (data & ETH_FLAG_RXVLAN) !=
-		     (netdev->features & NETIF_F_HW_VLAN_RX);
-
-	if ((data & ETH_FLAG_RXHASH) &&
-	    !(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
-		return -EOPNOTSUPP;
-
-	rc = ethtool_op_set_flags(netdev, data, ETH_FLAG_LRO | ETH_FLAG_NTUPLE |
-				  ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN |
-				  ETH_FLAG_RXHASH);
-	if (rc)
-		return rc;
-
-	/* if state changes we need to update adapter->flags and reset */
-	if ((adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) &&
-	    (!!(data & ETH_FLAG_LRO) !=
-	     !!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))) {
-		if ((data & ETH_FLAG_LRO) &&
-		    (!adapter->rx_itr_setting ||
-		     (adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE))) {
-			e_info(probe, "rx-usecs set too low, "
-				      "not enabling RSC.\n");
-		} else {
-			adapter->flags2 ^= IXGBE_FLAG2_RSC_ENABLED;
-			switch (adapter->hw.mac.type) {
-			case ixgbe_mac_X540:
-				ixgbe_set_rsc(adapter);
-				break;
-			case ixgbe_mac_82599EB:
-				need_reset = true;
-				break;
-			default:
-				break;
-			}
-		}
-	}
-
-	/*
-	 * Check if Flow Director n-tuple support was enabled or disabled.  If
-	 * the state changed, we need to reset.
-	 */
-	if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) {
-		/* turn off ATR, enable perfect filters and reset */
-		if (data & ETH_FLAG_NTUPLE) {
-			adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-			adapter->flags |= IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
-			need_reset = true;
-		}
-	} else if (!(data & ETH_FLAG_NTUPLE)) {
-		/* turn off Flow Director, set ATR and reset */
-		adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
-		if ((adapter->flags & IXGBE_FLAG_RSS_ENABLED) &&
-		    !(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
-			adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
-		need_reset = true;
-	}
-
-	if (need_reset)
-		ixgbe_do_reset(netdev);
-
-	return 0;
-}
-
 static int ixgbe_get_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
 					struct ethtool_rxnfc *cmd)
 {
@@ -2744,16 +2566,8 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_ringparam          = ixgbe_set_ringparam,
 	.get_pauseparam         = ixgbe_get_pauseparam,
 	.set_pauseparam         = ixgbe_set_pauseparam,
-	.get_rx_csum            = ixgbe_get_rx_csum,
-	.set_rx_csum            = ixgbe_set_rx_csum,
-	.get_tx_csum            = ixgbe_get_tx_csum,
-	.set_tx_csum            = ixgbe_set_tx_csum,
-	.get_sg                 = ethtool_op_get_sg,
-	.set_sg                 = ethtool_op_set_sg,
 	.get_msglevel           = ixgbe_get_msglevel,
 	.set_msglevel           = ixgbe_set_msglevel,
-	.get_tso                = ethtool_op_get_tso,
-	.set_tso                = ixgbe_set_tso,
 	.self_test              = ixgbe_diag_test,
 	.get_strings            = ixgbe_get_strings,
 	.set_phys_id            = ixgbe_set_phys_id,
@@ -2761,8 +2575,6 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_ethtool_stats      = ixgbe_get_ethtool_stats,
 	.get_coalesce           = ixgbe_get_coalesce,
 	.set_coalesce           = ixgbe_set_coalesce,
-	.get_flags              = ethtool_op_get_flags,
-	.set_flags              = ixgbe_set_flags,
 	.get_rxnfc		= ixgbe_get_rxnfc,
 	.set_rxnfc		= ixgbe_set_rxnfc,
 };
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index de30796..206c069 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7188,6 +7188,88 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	return 0;
 }
 
+void ixgbe_do_reset(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	if (netif_running(netdev))
+		ixgbe_reinit_locked(adapter);
+	else
+		ixgbe_reset(adapter);
+}
+
+static int ixgbe_set_features(struct net_device *netdev, u32 data)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	bool need_reset = false;
+
+#ifdef CONFIG_DCB
+	if ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
+	    !(data &  NETIF_F_HW_VLAN_RX))
+		return -EINVAL;
+#endif
+	/* return error if RXHASH is being enabled when RSS is not supported */
+	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED) &&
+	     (data &  NETIF_F_RXHASH))
+		return -EINVAL;
+
+	/* If Rx checksum is disabled, then RSC/LRO should also be disabled */
+	if (!(data & NETIF_F_RXCSUM)) {
+		data &= ~NETIF_F_LRO;
+		adapter->flags &= ~IXGBE_FLAG_RX_CSUM_ENABLED;
+	} else {
+		adapter->flags |= IXGBE_FLAG_RX_CSUM_ENABLED;
+	}
+
+	/* if state changes we need to update adapter->flags and reset */
+	if ((adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE) &&
+	    (!!(data & NETIF_F_LRO) !=
+	     !!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))) {
+		if ((data &  NETIF_F_LRO) &&
+		    adapter->rx_itr_setting != 1 &&
+		    adapter->rx_itr_setting > IXGBE_MAX_RSC_INT_RATE) {
+			e_info(probe, "rx-usecs set too low, "
+			       "not enabling RSC\n");
+		} else {
+			adapter->flags2 ^= IXGBE_FLAG2_RSC_ENABLED;
+			switch (adapter->hw.mac.type) {
+			case ixgbe_mac_X540:
+			case ixgbe_mac_82599EB:
+				need_reset = true;
+				break;
+			default:
+				break;
+			}
+		}
+	}
+
+	/*
+	 * Check if Flow Director n-tuple support was enabled or disabled.  If
+	 * the state changed, we need to reset.
+	 */
+	if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) {
+		/* turn off ATR, enable perfect filters and reset */
+		if (data & NETIF_F_NTUPLE) {
+			adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+			adapter->flags |= IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+			need_reset = true;
+		}
+	} else if (!(data & NETIF_F_NTUPLE)) {
+		/* turn off Flow Director, set ATR and reset */
+		adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
+		if ((adapter->flags &  IXGBE_FLAG_RSS_ENABLED) &&
+		    !(adapter->flags &  IXGBE_FLAG_DCB_ENABLED))
+			adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+		need_reset = true;
+	}
+
+	if (need_reset)
+		ixgbe_do_reset(netdev);
+
+	return 0;
+
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -7219,6 +7301,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_fcoe_disable = ixgbe_fcoe_disable,
 	.ndo_fcoe_get_wwn = ixgbe_fcoe_get_wwn,
 #endif /* IXGBE_FCOE */
+	.ndo_set_features = ixgbe_set_features,
 };
 
 static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
@@ -7486,20 +7569,24 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	netdev->features = NETIF_F_SG |
 			   NETIF_F_IP_CSUM |
+			   NETIF_F_IPV6_CSUM |
 			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX |
-			   NETIF_F_HW_VLAN_FILTER;
+			   NETIF_F_HW_VLAN_FILTER |
+			   NETIF_F_TSO |
+			   NETIF_F_TSO6 |
+			   NETIF_F_GRO |
+			   NETIF_F_RXHASH |
+			   NETIF_F_RXCSUM;
 
-	netdev->features |= NETIF_F_IPV6_CSUM;
-	netdev->features |= NETIF_F_TSO;
-	netdev->features |= NETIF_F_TSO6;
-	netdev->features |= NETIF_F_GRO;
-	netdev->features |= NETIF_F_RXHASH;
+	netdev->hw_features = netdev->features;
 
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		netdev->features |= NETIF_F_SCTP_CSUM;
+		netdev->hw_features |= NETIF_F_SCTP_CSUM |
+				       NETIF_F_NTUPLE;
 		break;
 	default:
 		break;
@@ -7538,6 +7625,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		netdev->vlan_features |= NETIF_F_HIGHDMA;
 	}
 
+	if (adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE)
+		netdev->hw_features |= NETIF_F_LRO;
 	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
 		netdev->features |= NETIF_F_LRO;
 
@@ -7574,8 +7663,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
-	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
+	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED)) {
+		netdev->hw_features &= ~NETIF_F_RXHASH;
 		netdev->features &= ~NETIF_F_RXHASH;
+	}
 
 	switch (pdev->device) {
 	case IXGBE_DEV_ID_82599_SFP:
-- 
1.7.6

