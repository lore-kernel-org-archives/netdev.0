From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 1/4] net: dsa: Add plumbing for port mirroring
Date: Mon, 30 Jan 2017 12:41:40 -0800
Message-ID: <20170130204143.539-2-f.fainelli@gmail.com>
References: <20170130204143.539-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35144 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754444AbdA3UtU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 15:49:20 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so24100671pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 12:48:51 -0800 (PST)
In-Reply-To: <20170130204143.539-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add necessary plumbing at the slave network device level to have switch
drivers implement ndo_setup_tc() and most particularly the cls_matchall
classifier. We add support for two switch operations:

port_add_mirror and port_del_mirror() which configure, on a per-port
basis the mirror parameters requested from the cls_matchall classifier.

Code is largely borrowed from the Mellanox Spectrum switch driver.

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h  |  33 +++++++++++++
 net/dsa/dsa_priv.h |   3 ++
 net/dsa/slave.c    | 137 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 172 insertions(+), 1 deletion(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index d5d618c3de64..2cb77e64d648 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -20,6 +20,8 @@
 #include <linux/phy_fixed.h>
 #include <linux/ethtool.h>
 
+struct tc_action;
+
 enum dsa_tag_protocol {
 	DSA_TAG_PROTO_NONE = 0,
 	DSA_TAG_PROTO_DSA,
@@ -139,6 +141,28 @@ struct dsa_switch_tree {
 	const struct dsa_device_ops *tag_ops;
 };
 
+/* TC matchall action types, only mirroring for now */
+enum dsa_port_mall_action_type {
+	DSA_PORT_MALL_MIRROR,
+};
+
+/* TC mirroring entry */
+struct dsa_mall_mirror_tc_entry {
+	u8 to_local_port;
+	bool ingress;
+};
+
+/* TC matchall entry */
+struct dsa_mall_tc_entry {
+	struct list_head list;
+	unsigned long cookie;
+	enum dsa_port_mall_action_type type;
+	union {
+		struct dsa_mall_mirror_tc_entry mirror;
+	};
+};
+
+
 struct dsa_port {
 	struct dsa_switch	*ds;
 	unsigned int		index;
@@ -385,6 +409,15 @@ struct dsa_switch_ops {
 			     struct ethtool_rxnfc *nfc, u32 *rule_locs);
 	int	(*set_rxnfc)(struct dsa_switch *ds, int port,
 			     struct ethtool_rxnfc *nfc);
+
+	/*
+	 * TC integration
+	 */
+	int	(*port_mirror_add)(struct dsa_switch *ds, int port,
+				   struct dsa_mall_mirror_tc_entry *mirror,
+				   bool ingress);
+	void	(*port_mirror_del)(struct dsa_switch *ds, int port,
+				   struct dsa_mall_mirror_tc_entry *mirror);
 };
 
 struct dsa_switch_driver {
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 3022f2e42cdc..a5509b765fc0 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -41,6 +41,9 @@ struct dsa_slave_priv {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll		*netpoll;
 #endif
+
+	/* TC context */
+	struct list_head	mall_tc_list;
 };
 
 /* dsa.c */
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6881889e1a9b..09fc3e9462c1 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -16,12 +16,17 @@
 #include <linux/of_net.h>
 #include <linux/of_mdio.h>
 #include <linux/mdio.h>
+#include <linux/list.h>
 #include <net/rtnetlink.h>
 #include <net/switchdev.h>
+#include <net/pkt_cls.h>
+#include <net/tc_act/tc_mirred.h>
 #include <linux/if_bridge.h>
 #include <linux/netpoll.h>
 #include "dsa_priv.h"
 
+static bool dsa_slave_dev_check(struct net_device *dev);
+
 /* slave mii_bus handling ***************************************************/
 static int dsa_slave_phy_read(struct mii_bus *bus, int addr, int reg)
 {
@@ -995,6 +1000,133 @@ static int dsa_slave_get_phys_port_name(struct net_device *dev,
 	return 0;
 }
 
+static struct dsa_mall_tc_entry *
+dsa_slave_mall_tc_entry_find(struct dsa_slave_priv *p,
+			     unsigned long cookie)
+{
+	struct dsa_mall_tc_entry *mall_tc_entry;
+
+	list_for_each_entry(mall_tc_entry, &p->mall_tc_list, list)
+		if (mall_tc_entry->cookie == cookie)
+			return mall_tc_entry;
+
+	return NULL;
+}
+
+static int dsa_slave_add_cls_matchall(struct net_device *dev,
+				      __be16 protocol,
+				      struct tc_cls_matchall_offload *cls,
+				      bool ingress)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_mall_tc_entry *mall_tc_entry;
+	struct dsa_switch *ds = p->dp->ds;
+	struct net *net = dev_net(dev);
+	struct dsa_slave_priv *to_p;
+	struct net_device *to_dev;
+	const struct tc_action *a;
+	int err = -EOPNOTSUPP;
+	LIST_HEAD(actions);
+	int ifindex;
+
+	if (!ds->ops->port_mirror_add)
+		return err;
+
+	if (!tc_single_action(cls->exts))
+		return err;
+
+	tcf_exts_to_list(cls->exts, &actions);
+	a = list_first_entry(&actions, struct tc_action, list);
+
+	if (is_tcf_mirred_egress_mirror(a) && protocol == htons(ETH_P_ALL)) {
+		struct dsa_mall_mirror_tc_entry *mirror;
+
+		ifindex = tcf_mirred_ifindex(a);
+		to_dev = __dev_get_by_index(net, ifindex);
+		if (!to_dev)
+			return -EINVAL;
+
+		if (!dsa_slave_dev_check(to_dev))
+			return -EOPNOTSUPP;
+
+		mall_tc_entry = kzalloc(sizeof(*mall_tc_entry), GFP_KERNEL);
+		if (!mall_tc_entry)
+			return -ENOMEM;
+
+		mall_tc_entry->cookie = cls->cookie;
+		mall_tc_entry->type = DSA_PORT_MALL_MIRROR;
+		mirror = &mall_tc_entry->mirror;
+
+		to_p = netdev_priv(to_dev);
+
+		mirror->to_local_port = to_p->dp->index;
+		mirror->ingress = ingress;
+
+		err = ds->ops->port_mirror_add(ds, p->dp->index, mirror,
+					       ingress);
+		if (err) {
+			kfree(mall_tc_entry);
+			return err;
+		}
+
+		list_add_tail(&mall_tc_entry->list, &p->mall_tc_list);
+	}
+
+	return 0;
+}
+
+static void dsa_slave_del_cls_matchall(struct net_device *dev,
+				       struct tc_cls_matchall_offload *cls)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_mall_tc_entry *mall_tc_entry;
+	struct dsa_switch *ds = p->dp->ds;
+
+	if (!ds->ops->port_mirror_del)
+		return;
+
+	mall_tc_entry = dsa_slave_mall_tc_entry_find(p, cls->cookie);
+	if (!mall_tc_entry)
+		return;
+
+	list_del(&mall_tc_entry->list);
+
+	switch (mall_tc_entry->type) {
+	case DSA_PORT_MALL_MIRROR:
+		ds->ops->port_mirror_del(ds, p->dp->index,
+					 &mall_tc_entry->mirror);
+		break;
+	default:
+		WARN_ON(1);
+	}
+
+	kfree(mall_tc_entry);
+}
+
+static int dsa_slave_setup_tc(struct net_device *dev, u32 handle,
+			      __be16 protocol, struct tc_to_netdev *tc)
+{
+	bool ingress = TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS);
+	int ret = -EOPNOTSUPP;
+
+	switch (tc->type) {
+	case TC_SETUP_MATCHALL:
+		switch (tc->cls_mall->command) {
+		case TC_CLSMATCHALL_REPLACE:
+			return dsa_slave_add_cls_matchall(dev, protocol,
+							  tc->cls_mall,
+							  ingress);
+		case TC_CLSMATCHALL_DESTROY:
+			dsa_slave_del_cls_matchall(dev, tc->cls_mall);
+			return 0;
+		}
+	default:
+		break;
+	}
+
+	return ret;
+}
+
 void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops)
 {
 	ops->get_sset_count = dsa_cpu_port_get_sset_count;
@@ -1069,6 +1201,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_get_phys_port_name	= dsa_slave_get_phys_port_name,
+	.ndo_setup_tc		= dsa_slave_setup_tc,
 };
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
@@ -1285,7 +1418,8 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	if (slave_dev == NULL)
 		return -ENOMEM;
 
-	slave_dev->features = master->vlan_features;
+	slave_dev->features = master->vlan_features | NETIF_F_HW_TC;
+	slave_dev->hw_features |= NETIF_F_HW_TC;
 	slave_dev->ethtool_ops = &dsa_slave_ethtool_ops;
 	eth_hw_addr_inherit(slave_dev, master);
 	slave_dev->priv_flags |= IFF_NO_QUEUE;
@@ -1304,6 +1438,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	p = netdev_priv(slave_dev);
 	p->dp = &ds->ports[port];
+	INIT_LIST_HEAD(&p->mall_tc_list);
 	p->xmit = dst->tag_ops->xmit;
 
 	p->old_pause = -1;
-- 
2.9.3
