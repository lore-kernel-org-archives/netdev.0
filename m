From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH 03/10] [RFC] ixgbe: remove ntuple filtering
Date: Fri, 25 Feb 2011 15:32:55 -0800
Message-ID: <20110225233255.7920.82452.stgit@gitlad.jf.intel.com>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5807 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932815Ab1BYXcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:32:55 -0500
In-Reply-To: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to numerous issues in ntuple filters it has been decieded to move the
interface over to the network flow classification interface.  As a first
step to achieving this I first need to remove the old ntuple interface.

In addition I am removing the requirement that ntuple filters have the same
number of queues and requirements as ATR.  As a result this change will
make it so that all the ntuple flag does is disable ATR for now.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c  |   47 +++++------
 drivers/net/ixgbe/ixgbe_ethtool.c |  162 +++----------------------------------
 drivers/net/ixgbe/ixgbe_main.c    |   45 +++-------
 3 files changed, 48 insertions(+), 206 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index a977df3..47fd9f6 100644
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
@@ -138,7 +139,6 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 		case ixgbe_mac_82599EB:
 		case ixgbe_mac_X540:
 			adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-			adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
 			break;
 		default:
 			break;
@@ -150,29 +150,28 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			netdev->netdev_ops->ndo_open(netdev);
 	} else {
 		/* Turn off DCB */
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			if (netif_running(netdev))
-				netdev->netdev_ops->ndo_stop(netdev);
-			ixgbe_clear_interrupt_scheme(adapter);
+		if (netif_running(netdev))
+			netdev->netdev_ops->ndo_stop(netdev);
+		ixgbe_clear_interrupt_scheme(adapter);
 
-			adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
-			adapter->temp_dcb_cfg.pfc_mode_enable = false;
-			adapter->dcb_cfg.pfc_mode_enable = false;
-			adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
-			adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
-			switch (adapter->hw.mac.type) {
-			case ixgbe_mac_82599EB:
-			case ixgbe_mac_X540:
+		adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
+		adapter->temp_dcb_cfg.pfc_mode_enable = false;
+		adapter->dcb_cfg.pfc_mode_enable = false;
+		adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
+		adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
+		switch (adapter->hw.mac.type) {
+		case ixgbe_mac_82599EB:
+		case ixgbe_mac_X540:
+			if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
 				adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
-				break;
-			default:
-				break;
-			}
-
-			ixgbe_init_interrupt_scheme(adapter);
-			if (netif_running(netdev))
-				netdev->netdev_ops->ndo_open(netdev);
+			break;
+		default:
+			break;
 		}
+
+		ixgbe_init_interrupt_scheme(adapter);
+		if (netif_running(netdev))
+			netdev->netdev_ops->ndo_open(netdev);
 	}
 out:
 	return err;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 309272f..1b40c02 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1031,9 +1031,6 @@ static int ixgbe_get_sset_count(struct net_device *netdev, int sset)
 		return IXGBE_TEST_LEN;
 	case ETH_SS_STATS:
 		return IXGBE_STATS_LEN;
-	case ETH_SS_NTUPLE_FILTERS:
-		return ETHTOOL_MAX_NTUPLE_LIST_ENTRY *
-		       ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -2277,20 +2274,19 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
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
+		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED)
+			adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
 		need_reset = true;
-	} else {
-		/* no state change */
 	}
 
 	if (need_reset) {
@@ -2303,141 +2299,6 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 	return 0;
 }
 
-static int ixgbe_set_rx_ntuple(struct net_device *dev,
-                               struct ethtool_rx_ntuple *cmd)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	struct ethtool_rx_ntuple_flow_spec *fs = &cmd->fs;
-	union ixgbe_atr_input input_struct;
-	struct ixgbe_atr_input_masks input_masks;
-	int target_queue;
-	int err;
-
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
-		return -EOPNOTSUPP;
-
-	/*
-	 * Don't allow programming if the action is a queue greater than
-	 * the number of online Tx queues.
-	 */
-	if ((fs->action >= adapter->num_tx_queues) ||
-	    (fs->action < ETHTOOL_RXNTUPLE_ACTION_DROP))
-		return -EINVAL;
-
-	memset(&input_struct, 0, sizeof(union ixgbe_atr_input));
-	memset(&input_masks, 0, sizeof(struct ixgbe_atr_input_masks));
-
-	/* record flow type */
-	switch (fs->flow_type) {
-	case IPV4_FLOW:
-		input_struct.formatted.flow_type = IXGBE_ATR_FLOW_TYPE_IPV4;
-		break;
-	case TCP_V4_FLOW:
-		input_struct.formatted.flow_type = IXGBE_ATR_FLOW_TYPE_TCPV4;
-		break;
-	case UDP_V4_FLOW:
-		input_struct.formatted.flow_type = IXGBE_ATR_FLOW_TYPE_UDPV4;
-		break;
-	case SCTP_V4_FLOW:
-		input_struct.formatted.flow_type = IXGBE_ATR_FLOW_TYPE_SCTPV4;
-		break;
-	default:
-		return -1;
-	}
-
-	/* copy vlan tag minus the CFI bit */
-	if ((fs->vlan_tag & 0xEFFF) || (~fs->vlan_tag_mask & 0xEFFF)) {
-		input_struct.formatted.vlan_id = htons(fs->vlan_tag & 0xEFFF);
-		if (!fs->vlan_tag_mask) {
-			input_masks.vlan_id_mask = htons(0xEFFF);
-		} else {
-			switch (~fs->vlan_tag_mask & 0xEFFF) {
-			/* all of these are valid vlan-mask values */
-			case 0xEFFF:
-			case 0xE000:
-			case 0x0FFF:
-			case 0x0000:
-				input_masks.vlan_id_mask =
-					htons(~fs->vlan_tag_mask);
-				break;
-			/* exit with error if vlan-mask is invalid */
-			default:
-				e_err(drv, "Partial VLAN ID or "
-				      "priority mask in vlan-mask is not "
-				      "supported by hardware\n");
-				return -1;
-			}
-		}
-	}
-
-	/* make sure we only use the first 2 bytes of user data */
-	if ((fs->data & 0xFFFF) || (~fs->data_mask & 0xFFFF)) {
-		input_struct.formatted.flex_bytes = htons(fs->data & 0xFFFF);
-		if (!(fs->data_mask & 0xFFFF)) {
-			input_masks.flex_mask = 0xFFFF;
-		} else if (~fs->data_mask & 0xFFFF) {
-			e_err(drv, "Partial user-def-mask is not "
-			      "supported by hardware\n");
-			return -1;
-		}
-	}
-
-	/*
-	 * Copy input into formatted structures
-	 *
-	 * These assignments are based on the following logic
-	 * If neither input or mask are set assume value is masked out.
-	 * If input is set, but mask is not mask should default to accept all.
-	 * If input is not set, but mask is set then mask likely results in 0.
-	 * If input is set and mask is set then assign both.
-	 */
-	if (fs->h_u.tcp_ip4_spec.ip4src || ~fs->m_u.tcp_ip4_spec.ip4src) {
-		input_struct.formatted.src_ip[0] = fs->h_u.tcp_ip4_spec.ip4src;
-		if (!fs->m_u.tcp_ip4_spec.ip4src)
-			input_masks.src_ip_mask[0] = 0xFFFFFFFF;
-		else
-			input_masks.src_ip_mask[0] =
-				~fs->m_u.tcp_ip4_spec.ip4src;
-	}
-	if (fs->h_u.tcp_ip4_spec.ip4dst || ~fs->m_u.tcp_ip4_spec.ip4dst) {
-		input_struct.formatted.dst_ip[0] = fs->h_u.tcp_ip4_spec.ip4dst;
-		if (!fs->m_u.tcp_ip4_spec.ip4dst)
-			input_masks.dst_ip_mask[0] = 0xFFFFFFFF;
-		else
-			input_masks.dst_ip_mask[0] =
-				~fs->m_u.tcp_ip4_spec.ip4dst;
-	}
-	if (fs->h_u.tcp_ip4_spec.psrc || ~fs->m_u.tcp_ip4_spec.psrc) {
-		input_struct.formatted.src_port = fs->h_u.tcp_ip4_spec.psrc;
-		if (!fs->m_u.tcp_ip4_spec.psrc)
-			input_masks.src_port_mask = 0xFFFF;
-		else
-			input_masks.src_port_mask = ~fs->m_u.tcp_ip4_spec.psrc;
-	}
-	if (fs->h_u.tcp_ip4_spec.pdst || ~fs->m_u.tcp_ip4_spec.pdst) {
-		input_struct.formatted.dst_port = fs->h_u.tcp_ip4_spec.pdst;
-		if (!fs->m_u.tcp_ip4_spec.pdst)
-			input_masks.dst_port_mask = 0xFFFF;
-		else
-			input_masks.dst_port_mask = ~fs->m_u.tcp_ip4_spec.pdst;
-	}
-
-	/* determine if we need to drop or route the packet */
-	if (fs->action == ETHTOOL_RXNTUPLE_ACTION_DROP)
-		target_queue = MAX_RX_QUEUES - 1;
-	else
-		target_queue = fs->action;
-
-	spin_lock(&adapter->fdir_perfect_lock);
-	err = ixgbe_fdir_add_perfect_filter_82599(&adapter->hw,
-						  &input_struct,
-						  &input_masks, 0,
-						  target_queue);
-	spin_unlock(&adapter->fdir_perfect_lock);
-
-	return err ? -1 : 0;
-}
-
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
@@ -2473,7 +2334,6 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_flags              = ethtool_op_get_flags,
 	.set_flags              = ixgbe_set_flags,
-	.set_rx_ntuple          = ixgbe_set_rx_ntuple,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f0d0c5a..929f059 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1568,9 +1568,8 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
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
@@ -2453,8 +2452,7 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
 	default:
 		break;
 	}
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
-	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
 		mask |= IXGBE_EIMS_FLOW_DIR;
 
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
@@ -3692,8 +3690,6 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 			adapter->tx_ring[i]->atr_sample_rate =
 						       adapter->atr_sample_rate;
 		ixgbe_init_fdir_signature_82599(hw, adapter->fdir_pballoc);
-	} else if (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) {
-		ixgbe_init_fdir_perfect_82599(hw, adapter->fdir_pballoc);
 	}
 	ixgbe_configure_virtualization(adapter);
 
@@ -4138,8 +4134,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		free_cpumask_var(q_vector->affinity_mask);
 	}
 
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
-	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
 		cancel_work_sync(&adapter->fdir_reinit_task);
 
 	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
@@ -4164,9 +4159,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		break;
 	}
 
-	/* clear n-tuple filters that are cached */
-	ethtool_ntuple_flush(netdev);
-
 	if (!pci_channel_offline(adapter->pdev))
 		ixgbe_reset(adapter);
 
@@ -4313,15 +4305,13 @@ static inline bool ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
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
@@ -4354,8 +4344,7 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 #endif
 		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 			e_info(probe, "FCoE enabled with RSS\n");
-			if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
-			    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
+			if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
 				ixgbe_set_fdir_queues(adapter);
 			else
 				ixgbe_set_rss_queues(adapter);
@@ -4598,9 +4587,8 @@ static inline bool ixgbe_cache_ring_fdir(struct ixgbe_adapter *adapter)
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
@@ -4656,8 +4644,7 @@ static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 	}
 #endif /* CONFIG_IXGBE_DCB */
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-		if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
-		    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
+		if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
 			ixgbe_cache_ring_fdir(adapter);
 		else
 			ixgbe_cache_ring_rss(adapter);
@@ -4837,14 +4824,12 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 
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
@@ -7446,8 +7431,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
 
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
-	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
 		INIT_WORK(&adapter->fdir_reinit_task, ixgbe_fdir_reinit_task);
 
 	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
@@ -7524,8 +7508,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	cancel_work_sync(&adapter->sfp_task);
 	cancel_work_sync(&adapter->multispeed_fiber_task);
 	cancel_work_sync(&adapter->sfp_config_module_task);
-	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
-	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
 		cancel_work_sync(&adapter->fdir_reinit_task);
 	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE)
 		cancel_work_sync(&adapter->check_overtemp_task);

