From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH 09/10] [RFC] ixgbe: add support for nfc addition
	and removal of filters
Date: Fri, 25 Feb 2011 15:33:25 -0800
Message-ID: <20110225233325.7920.87815.stgit@gitlad.jf.intel.com>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29473 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933040Ab1BYXd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:33:26 -0500
In-Reply-To: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to allow for nfc to insert and remove filters in order
to test the ethtool interface which includes it's own rules manager.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |  232 +++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c    |   45 +++++++
 2 files changed, 277 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 145e018..a91e8db 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2453,6 +2453,237 @@ static int ixgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 	return ret;
 }
 
+static int ixgbe_update_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
+					   struct ixgbe_fdir_filter *input,
+					   u16 sw_idx)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct hlist_node *node, *node2, *parent;
+	struct ixgbe_fdir_filter *rule;
+	int err = -EINVAL;
+
+	parent = NULL;
+	rule = NULL;
+
+	hlist_for_each_entry_safe(rule, node, node2,
+				  &adapter->fdir_filter_list, fdir_node) {
+		/* hash found, or no matching entry */
+		if (rule->sw_idx >= sw_idx)
+			break;
+		parent = node;
+	}
+
+	/* if there is an old rule occupying our place remove it */
+	if (rule && (rule->sw_idx == sw_idx)) {
+		if (!input || (rule->filter.formatted.bkt_hash !=
+			       input->filter.formatted.bkt_hash)) {
+			err = ixgbe_fdir_erase_perfect_filter_82599(hw,
+								    &rule->filter,
+								    sw_idx);
+		}
+
+		hlist_del(&rule->fdir_node);
+		kfree(rule);
+		adapter->fdir_filter_count--;
+	}
+
+	/* stop here if there was not an input filter provided */
+	if (!input)
+		return err;
+
+	/* reset error since we are now adding a filter */
+	err = 0;
+
+	/* initialize node and set software index */
+	INIT_HLIST_NODE(&input->fdir_node);
+
+	/* add filter to the list */
+	if (parent)
+		hlist_add_after(parent, &input->fdir_node);
+	else
+		hlist_add_head(&input->fdir_node,
+			       &adapter->fdir_filter_list);
+
+	/* update counts */
+	adapter->fdir_filter_count++;
+
+	return err;
+}
+
+static int ixgbe_flowspec_to_flow_type(struct ethtool_rx_flow_spec *fsp,
+				       u8 *flow_type)
+{
+	switch (fsp->flow_type) {
+	case TCP_V4_FLOW:
+		*flow_type = IXGBE_ATR_FLOW_TYPE_TCPV4;
+		break;
+	case UDP_V4_FLOW:
+		*flow_type = IXGBE_ATR_FLOW_TYPE_UDPV4;
+		break;
+	case SCTP_V4_FLOW:
+		*flow_type = IXGBE_ATR_FLOW_TYPE_SCTPV4;
+		break;
+	case IP_USER_FLOW:
+		switch (fsp->h_u.usr_ip4_spec.proto) {
+		case IPPROTO_TCP:
+			*flow_type = IXGBE_ATR_FLOW_TYPE_TCPV4;
+			break;
+		case IPPROTO_UDP:
+			*flow_type = IXGBE_ATR_FLOW_TYPE_UDPV4;
+			break;
+		case IPPROTO_SCTP:
+			*flow_type = IXGBE_ATR_FLOW_TYPE_SCTPV4;
+			break;
+		case 0:
+			if (!fsp->m_u.usr_ip4_spec.proto) {
+				*flow_type = IXGBE_ATR_FLOW_TYPE_IPV4;
+				break;
+			}
+		default:
+			return 0;
+		}
+		break;
+	default:
+		return 0;
+	}
+
+	return 1;
+}
+
+static int ixgbe_add_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
+					struct ethtool_rxnfc *cmd)
+{
+	struct ethtool_rx_flow_spec *fsp =
+		(struct ethtool_rx_flow_spec *)&cmd->fs;
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_fdir_filter *input;
+	union ixgbe_atr_input mask;
+	int err;
+
+	if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
+		return -EOPNOTSUPP;
+
+	/*
+	 * Don't allow programming if the action is a queue greater than
+	 * the number of online Rx queues.
+	 */
+	if ((fsp->ring_cookie != RX_CLS_FLOW_DISC) &&
+	    (fsp->ring_cookie >= adapter->num_rx_queues))
+		return -EINVAL;
+
+	input = kzalloc(sizeof(*input), GFP_ATOMIC);
+	if (!input)
+		return -ENOMEM;
+
+	memset(&mask, 0, sizeof(union ixgbe_atr_input));
+
+	/* set SW index */
+	input->sw_idx = fsp->location;
+
+	/* record flow type */
+	if (!ixgbe_flowspec_to_flow_type(fsp,
+					 &input->filter.formatted.flow_type)) {
+		e_err(drv, "Unrecognized flow type\n");
+		goto err_out;
+	}
+
+	mask.formatted.flow_type = IXGBE_ATR_L4TYPE_IPV6_MASK |
+				   IXGBE_ATR_L4TYPE_MASK;
+
+	if (input->filter.formatted.flow_type == IXGBE_ATR_FLOW_TYPE_IPV4)
+		mask.formatted.flow_type &= IXGBE_ATR_L4TYPE_IPV6_MASK;
+
+	/* Copy input into formatted structures */
+	input->filter.formatted.src_ip[0] = fsp->h_u.tcp_ip4_spec.ip4src;
+	mask.formatted.src_ip[0] = fsp->m_u.tcp_ip4_spec.ip4src;
+	input->filter.formatted.dst_ip[0] = fsp->h_u.tcp_ip4_spec.ip4dst;
+	mask.formatted.dst_ip[0] = fsp->m_u.tcp_ip4_spec.ip4dst;
+	input->filter.formatted.src_port = fsp->h_u.tcp_ip4_spec.psrc;
+	mask.formatted.src_port = fsp->m_u.tcp_ip4_spec.psrc;
+	input->filter.formatted.dst_port = fsp->h_u.tcp_ip4_spec.pdst;
+	mask.formatted.dst_port = fsp->m_u.tcp_ip4_spec.pdst;
+
+	/* determine if we need to drop or route the packet */
+	if (fsp->ring_cookie == RX_CLS_FLOW_DISC)
+		input->action = IXGBE_FDIR_DROP_QUEUE;
+	else
+		input->action = fsp->ring_cookie;
+
+	spin_lock(&adapter->fdir_perfect_lock);
+
+	if (hlist_empty(&adapter->fdir_filter_list)) {
+		/* save mask and program input mask into HW */
+		memcpy(&adapter->fdir_mask, &mask, sizeof(mask));
+		err = ixgbe_fdir_set_input_mask_82599(hw, &mask);
+		if (err) {
+			e_err(drv, "Error writing mask\n");
+			goto err_out_w_lock;
+		}
+	} else if (memcmp(&adapter->fdir_mask, &mask, sizeof(mask))) {
+		e_err(drv, "Only one mask supported per port\n");
+		goto err_out_w_lock;
+	}
+
+	/* apply mask and compute/store hash */
+	ixgbe_atr_compute_perfect_hash_82599(&input->filter, &mask);
+
+	/* Don't exceed the available space for filters in the HW */
+	if (adapter->fdir_filter_count >=
+	    ((1024 << adapter->fdir_pballoc) - 2))
+		goto err_out_w_lock;
+
+	/* program filters to filter memory */
+	err = ixgbe_fdir_write_perfect_filter_82599(hw,
+				&input->filter, input->sw_idx,
+				adapter->rx_ring[input->action]->reg_idx);
+	if (err)
+		goto err_out_w_lock;
+
+	ixgbe_update_ethtool_fdir_entry(adapter, input, input->sw_idx);
+
+	spin_unlock(&adapter->fdir_perfect_lock);
+
+	return err;
+err_out_w_lock:
+	spin_unlock(&adapter->fdir_perfect_lock);
+err_out:
+	kfree(input);
+	return -1;
+}
+
+static int ixgbe_del_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
+					struct ethtool_rxnfc *cmd)
+{
+	struct ethtool_rx_flow_spec *fsp =
+		(struct ethtool_rx_flow_spec *)&cmd->fs;
+	int err;
+
+	spin_lock(&adapter->fdir_perfect_lock);
+	err = ixgbe_update_ethtool_fdir_entry(adapter, NULL, fsp->location);
+	spin_unlock(&adapter->fdir_perfect_lock);
+
+	return err;
+}
+
+static int ixgbe_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	int ret = -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_SRXCLSRLINS:
+		ret = ixgbe_add_ethtool_fdir_entry(adapter, cmd);
+		break;
+	case ETHTOOL_SRXCLSRLDEL:
+		ret = ixgbe_del_ethtool_fdir_entry(adapter, cmd);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
@@ -2489,6 +2720,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_flags              = ethtool_op_get_flags,
 	.set_flags              = ixgbe_set_flags,
 	.get_rxnfc		= ixgbe_get_rxnfc,
+	.set_rxnfc		= ixgbe_set_rxnfc,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 6b6f602..bd79ac1 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3667,6 +3667,28 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 }
 
 #endif
+static void ixgbe_fdir_filter_restore(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct hlist_node *node, *node2;
+	struct ixgbe_fdir_filter *filter;
+
+	spin_lock(&adapter->fdir_perfect_lock);
+
+	if (!hlist_empty(&adapter->fdir_filter_list))
+		ixgbe_fdir_set_input_mask_82599(hw, &adapter->fdir_mask);
+
+	hlist_for_each_entry_safe(filter, node, node2,
+				  &adapter->fdir_filter_list, fdir_node) {
+		ixgbe_fdir_write_perfect_filter_82599(hw,
+						      &filter->filter,
+						      filter->sw_idx,
+						      filter->action);
+	}
+
+	spin_unlock(&adapter->fdir_perfect_lock);
+}
+
 static void ixgbe_configure(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -3690,6 +3712,10 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 			adapter->tx_ring[i]->atr_sample_rate =
 						       adapter->atr_sample_rate;
 		ixgbe_init_fdir_signature_82599(hw, adapter->fdir_pballoc);
+	} else if (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) {
+		ixgbe_init_fdir_perfect_82599(&adapter->hw,
+					      adapter->fdir_pballoc);
+		ixgbe_fdir_filter_restore(adapter);
 	}
 	ixgbe_configure_virtualization(adapter);
 
@@ -4075,6 +4101,23 @@ static void ixgbe_clean_all_tx_rings(struct ixgbe_adapter *adapter)
 		ixgbe_clean_tx_ring(adapter->tx_ring[i]);
 }
 
+static void ixgbe_fdir_filter_exit(struct ixgbe_adapter *adapter)
+{
+	struct hlist_node *node, *node2;
+	struct ixgbe_fdir_filter *filter;
+
+	spin_lock(&adapter->fdir_perfect_lock);
+
+	hlist_for_each_entry_safe(filter, node, node2,
+				  &adapter->fdir_filter_list, fdir_node) {
+		hlist_del(&filter->fdir_node);
+		kfree(filter);
+	}
+	adapter->fdir_filter_count = 0;
+
+	spin_unlock(&adapter->fdir_perfect_lock);
+}
+
 void ixgbe_down(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -5534,6 +5577,8 @@ static int ixgbe_close(struct net_device *netdev)
 	ixgbe_down(adapter);
 	ixgbe_free_irq(adapter);
 
+	ixgbe_fdir_filter_exit(adapter);
+
 	ixgbe_free_all_tx_resources(adapter);
 	ixgbe_free_all_rx_resources(adapter);
 

