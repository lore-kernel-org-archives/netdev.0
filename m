From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] ixgbe: remove ntuple filtering
Date: Thu, 23 Jun 2011 23:03:07 -0700
Message-ID: <1308895397-23133-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21960 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752536Ab1FXGDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 02:03:36 -0400
In-Reply-To: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Due to numerous issues in ntuple filters it has been decided to move the
interface over to the network flow classification interface.  As a first
step to achieving this I first need to remove the old ntuple interface.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |  136 -------------------------------------
 1 files changed, 0 insertions(+), 136 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 4950d03..e41dd24 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2336,141 +2336,6 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
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
@@ -2506,7 +2371,6 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_flags              = ethtool_op_get_flags,
 	.set_flags              = ixgbe_set_flags,
-	.set_rx_ntuple          = ixgbe_set_rx_ntuple,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.5.4

