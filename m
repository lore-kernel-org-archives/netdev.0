From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2 2/2] enic: Add ethtool support to show classifier filters added by the driver
Date: Mon, 21 Jul 2014 17:22:18 +0530
Message-ID: <1405943538-3086-3-git-send-email-_govind@gmx.com>
References: <1405943538-3086-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:49964 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754874AbaGULxV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2014 07:53:21 -0400
In-Reply-To: <1405943538-3086-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch impliments ethtool_ops->get_rxnfc() to display the classifier
filter added by the driver.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_clsf.c    | 18 +++++
 drivers/net/ethernet/cisco/enic/enic_clsf.h    |  1 +
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 98 ++++++++++++++++++++++++++
 3 files changed, 117 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.c b/drivers/net/ethernet/cisco/enic/enic_clsf.c
index ee6acbf..69dfd3c 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.c
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.c
@@ -103,6 +103,24 @@ void enic_rfs_flw_tbl_free(struct enic *enic)
 	spin_unlock(&enic->rfs_h.lock);
 }
 
+struct enic_rfs_fltr_node *htbl_fltr_search(struct enic *enic, u16 fltr_id)
+{
+	int i;
+
+	for (i = 0; i < (1 << ENIC_RFS_FLW_BITSHIFT); i++) {
+		struct hlist_head *hhead;
+		struct hlist_node *tmp;
+		struct enic_rfs_fltr_node *n;
+
+		hhead = &enic->rfs_h.ht_head[i];
+		hlist_for_each_entry_safe(n, tmp, hhead, node)
+			if (n->fltr_id == fltr_id)
+				return n;
+	}
+
+	return NULL;
+}
+
 #ifdef CONFIG_RFS_ACCEL
 void enic_flow_may_expire(unsigned long data)
 {
diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.h b/drivers/net/ethernet/cisco/enic/enic_clsf.h
index 221f364..6aa9f89 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.h
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.h
@@ -10,6 +10,7 @@ int enic_addfltr_5t(struct enic *enic, struct flow_keys *keys, u16 rq);
 int enic_delfltr(struct enic *enic, u16 filter_id);
 void enic_rfs_flw_tbl_init(struct enic *enic);
 void enic_rfs_flw_tbl_free(struct enic *enic);
+struct enic_rfs_fltr_node *htbl_fltr_search(struct enic *enic, u16 fltr_id);
 
 #ifdef CONFIG_RFS_ACCEL
 int enic_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index c75f84b..523c9ce 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -22,6 +22,7 @@
 #include "enic_res.h"
 #include "enic.h"
 #include "enic_dev.h"
+#include "enic_clsf.h"
 
 struct enic_stat {
 	char name[ETH_GSTRING_LEN];
@@ -282,6 +283,102 @@ static int enic_set_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+static int enic_grxclsrlall(struct enic *enic, struct ethtool_rxnfc *cmd,
+			    u32 *rule_locs)
+{
+	int j, ret = 0, cnt = 0;
+
+	cmd->data = enic->rfs_h.max - enic->rfs_h.free;
+	for (j = 0; j < (1 << ENIC_RFS_FLW_BITSHIFT); j++) {
+		struct hlist_head *hhead;
+		struct hlist_node *tmp;
+		struct enic_rfs_fltr_node *n;
+
+		hhead = &enic->rfs_h.ht_head[j];
+		hlist_for_each_entry_safe(n, tmp, hhead, node) {
+			if (cnt == cmd->rule_cnt)
+				return -EMSGSIZE;
+			rule_locs[cnt] = n->fltr_id;
+			cnt++;
+		}
+	}
+	cmd->rule_cnt = cnt;
+
+	return ret;
+}
+
+static int enic_grxclsrule(struct enic *enic, struct ethtool_rxnfc *cmd)
+{
+	struct ethtool_rx_flow_spec *fsp =
+				(struct ethtool_rx_flow_spec *)&cmd->fs;
+	struct enic_rfs_fltr_node *n;
+
+	n = htbl_fltr_search(enic, (u16)fsp->location);
+	if (!n)
+		return -EINVAL;
+	switch (n->keys.ip_proto) {
+	case IPPROTO_TCP:
+		fsp->flow_type = TCP_V4_FLOW;
+		break;
+	case IPPROTO_UDP:
+		fsp->flow_type = UDP_V4_FLOW;
+		break;
+	default:
+		return -EINVAL;
+		break;
+	}
+
+	fsp->h_u.tcp_ip4_spec.ip4src = n->keys.src;
+	fsp->m_u.tcp_ip4_spec.ip4src = (__u32)~0;
+
+	fsp->h_u.tcp_ip4_spec.ip4dst = n->keys.dst;
+	fsp->m_u.tcp_ip4_spec.ip4dst = (__u32)~0;
+
+	fsp->h_u.tcp_ip4_spec.psrc = n->keys.port16[0];
+	fsp->m_u.tcp_ip4_spec.psrc = (__u16)~0;
+
+	fsp->h_u.tcp_ip4_spec.pdst = n->keys.port16[1];
+	fsp->m_u.tcp_ip4_spec.pdst = (__u16)~0;
+
+	fsp->ring_cookie = n->rq_id;
+
+	return 0;
+}
+
+static int enic_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
+			  u32 *rule_locs)
+{
+	struct enic *enic = netdev_priv(dev);
+	int ret = 0;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXRINGS:
+		cmd->data = enic->rq_count;
+		break;
+	case ETHTOOL_GRXCLSRLCNT:
+		spin_lock_bh(&enic->rfs_h.lock);
+		cmd->rule_cnt = enic->rfs_h.max - enic->rfs_h.free;
+		cmd->data = enic->rfs_h.max;
+		spin_unlock_bh(&enic->rfs_h.lock);
+		break;
+	case ETHTOOL_GRXCLSRLALL:
+		spin_lock_bh(&enic->rfs_h.lock);
+		ret = enic_grxclsrlall(enic, cmd, rule_locs);
+		spin_unlock_bh(&enic->rfs_h.lock);
+		break;
+	case ETHTOOL_GRXCLSRULE:
+		spin_lock_bh(&enic->rfs_h.lock);
+		ret = enic_grxclsrule(enic, cmd);
+		spin_unlock_bh(&enic->rfs_h.lock);
+		break;
+	default:
+		ret = -EOPNOTSUPP;
+		break;
+	}
+
+	return ret;
+}
+
 static const struct ethtool_ops enic_ethtool_ops = {
 	.get_settings = enic_get_settings,
 	.get_drvinfo = enic_get_drvinfo,
@@ -293,6 +390,7 @@ static const struct ethtool_ops enic_ethtool_ops = {
 	.get_ethtool_stats = enic_get_ethtool_stats,
 	.get_coalesce = enic_get_coalesce,
 	.set_coalesce = enic_set_coalesce,
+	.get_rxnfc = enic_get_rxnfc,
 };
 
 void enic_set_ethtool_ops(struct net_device *netdev)
-- 
2.0.2
