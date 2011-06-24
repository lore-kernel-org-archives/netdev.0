From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] ixgbe: add support for displaying ntuple filters via the nfc interface
Date: Thu, 23 Jun 2011 23:03:11 -0700
Message-ID: <1308895397-23133-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9660 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752672Ab1FXGDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 02:03:36 -0400
In-Reply-To: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This code adds support for displaying the filters that were added via the
nfc interface.  This is primarily to test the interface for now, but I am
also looking into the feasibility of moving all of the ntuple filter code
in ixgbe over to the nfc interface since it seems to be better implemented.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h         |   11 ++++
 drivers/net/ixgbe/ixgbe_ethtool.c |  102 +++++++++++++++++++++++++++++++++++++
 2 files changed, 113 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 5ea5b4c..d6bfb2f 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -482,6 +482,17 @@ struct ixgbe_adapter {
 	struct vf_macvlans vf_mvs;
 	struct vf_macvlans *mv_list;
 	bool antispoofing_enabled;
+
+	struct hlist_head fdir_filter_list;
+	union ixgbe_atr_input fdir_mask;
+	int fdir_filter_count;
+};
+
+struct ixgbe_fdir_filter {
+	struct hlist_node fdir_node;
+	union ixgbe_atr_input filter;
+	u16 sw_idx;
+	u16 action;
 };
 
 enum ixbge_state_t {
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 8373244..649e596 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2336,6 +2336,97 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 	return 0;
 }
 
+static int ixgbe_get_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
+					struct ethtool_rxnfc *cmd)
+{
+	union ixgbe_atr_input *mask = &adapter->fdir_mask;
+	struct ethtool_rx_flow_spec *fsp =
+		(struct ethtool_rx_flow_spec *)&cmd->fs;
+	struct hlist_node *node, *node2;
+	struct ixgbe_fdir_filter *rule = NULL;
+
+	/* report total rule count */
+	cmd->data = (1024 << adapter->fdir_pballoc) - 2;
+
+	hlist_for_each_entry_safe(rule, node, node2,
+				  &adapter->fdir_filter_list, fdir_node) {
+		if (fsp->location <= rule->sw_idx)
+			break;
+	}
+
+	if (!rule || fsp->location != rule->sw_idx)
+		return -EINVAL;
+
+	/* fill out the flow spec entry */
+
+	/* set flow type field */
+	switch (rule->filter.formatted.flow_type) {
+	case IXGBE_ATR_FLOW_TYPE_TCPV4:
+		fsp->flow_type = TCP_V4_FLOW;
+		break;
+	case IXGBE_ATR_FLOW_TYPE_UDPV4:
+		fsp->flow_type = UDP_V4_FLOW;
+		break;
+	case IXGBE_ATR_FLOW_TYPE_SCTPV4:
+		fsp->flow_type = SCTP_V4_FLOW;
+		break;
+	case IXGBE_ATR_FLOW_TYPE_IPV4:
+		fsp->flow_type = IP_USER_FLOW;
+		fsp->h_u.usr_ip4_spec.ip_ver = ETH_RX_NFC_IP4;
+		fsp->h_u.usr_ip4_spec.proto = 0;
+		fsp->m_u.usr_ip4_spec.proto = 0;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	fsp->h_u.tcp_ip4_spec.psrc = rule->filter.formatted.src_port;
+	fsp->m_u.tcp_ip4_spec.psrc = mask->formatted.src_port;
+	fsp->h_u.tcp_ip4_spec.pdst = rule->filter.formatted.dst_port;
+	fsp->m_u.tcp_ip4_spec.pdst = mask->formatted.dst_port;
+	fsp->h_u.tcp_ip4_spec.ip4src = rule->filter.formatted.src_ip[0];
+	fsp->m_u.tcp_ip4_spec.ip4src = mask->formatted.src_ip[0];
+	fsp->h_u.tcp_ip4_spec.ip4dst = rule->filter.formatted.dst_ip[0];
+	fsp->m_u.tcp_ip4_spec.ip4dst = mask->formatted.dst_ip[0];
+	fsp->h_ext.vlan_tci = rule->filter.formatted.vlan_id;
+	fsp->m_ext.vlan_tci = mask->formatted.vlan_id;
+	fsp->h_ext.vlan_etype = rule->filter.formatted.flex_bytes;
+	fsp->m_ext.vlan_etype = mask->formatted.flex_bytes;
+	fsp->h_ext.data[1] = htonl(rule->filter.formatted.vm_pool);
+	fsp->m_ext.data[1] = htonl(mask->formatted.vm_pool);
+	fsp->flow_type |= FLOW_EXT;
+
+	/* record action */
+	if (rule->action == IXGBE_FDIR_DROP_QUEUE)
+		fsp->ring_cookie = RX_CLS_FLOW_DISC;
+	else
+		fsp->ring_cookie = rule->action;
+
+	return 0;
+}
+
+static int ixgbe_get_ethtool_fdir_all(struct ixgbe_adapter *adapter,
+				      struct ethtool_rxnfc *cmd,
+				      u32 *rule_locs)
+{
+	struct hlist_node *node, *node2;
+	struct ixgbe_fdir_filter *rule;
+	int cnt = 0;
+
+	/* report total rule count */
+	cmd->data = (1024 << adapter->fdir_pballoc) - 2;
+
+	hlist_for_each_entry_safe(rule, node, node2,
+				  &adapter->fdir_filter_list, fdir_node) {
+		if (cnt == cmd->rule_cnt)
+			return -EMSGSIZE;
+		rule_locs[cnt] = rule->sw_idx;
+		cnt++;
+	}
+
+	return 0;
+}
+
 static int ixgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 			   void *rule_locs)
 {
@@ -2347,6 +2438,17 @@ static int ixgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 		cmd->data = adapter->num_rx_queues;
 		ret = 0;
 		break;
+	case ETHTOOL_GRXCLSRLCNT:
+		cmd->rule_cnt = adapter->fdir_filter_count;
+		ret = 0;
+		break;
+	case ETHTOOL_GRXCLSRULE:
+		ret = ixgbe_get_ethtool_fdir_entry(adapter, cmd);
+		break;
+	case ETHTOOL_GRXCLSRLALL:
+		ret = ixgbe_get_ethtool_fdir_all(adapter, cmd,
+						 (u32 *)rule_locs);
+		break;
 	default:
 		break;
 	}
-- 
1.7.5.4

