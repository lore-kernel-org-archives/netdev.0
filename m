From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH 08/10] [RFC] ixgbe: add support for displaying
	ntuple filters via the nfc interface
Date: Fri, 25 Feb 2011 15:33:20 -0800
Message-ID: <20110225233320.7920.52937.stgit@gitlad.jf.intel.com>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:7834 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932994Ab1BYXdW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:33:22 -0500
In-Reply-To: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code adds support for displaying the filters that were added via the
nfc interface.  This is primarily to test the interface for now, but I am
also looking into the feasability of moving all of the ntuple filter code
in ixgbe over to the nfc interface since it seems to be better implemented.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |   11 ++++
 drivers/net/ixgbe/ixgbe_ethtool.c |   95 +++++++++++++++++++++++++++++++++++++
 2 files changed, 106 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 0cd75d6..903c828 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -466,6 +466,17 @@ struct ixgbe_adapter {
 	DECLARE_BITMAP(active_vfs, IXGBE_MAX_VF_FUNCTIONS);
 	unsigned int num_vfs;
 	struct vf_data_storage *vfinfo;
+
+	struct hlist_head fdir_filter_list;
+	union ixgbe_atr_input fdir_mask;
+	int fdir_filter_count;
+};
+
+struct ixgbe_fdir_filter {
+	struct  hlist_node fdir_node;
+	union ixgbe_atr_input filter;
+	u16 sw_idx;
+	u16 action;
 };
 
 enum ixbge_state_t {
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 6c17e45..145e018 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2337,6 +2337,89 @@ static int ixgbe_get_rss_hash_opts(struct ixgbe_adapter *adapter,
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
@@ -2351,6 +2434,18 @@ static int ixgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
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
+
 	default:
 		break;
 	}

