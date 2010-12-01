From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v2 2/3] netlink: implement nla_policy for HW QOS
Date: Wed, 01 Dec 2010 10:22:58 -0800
Message-ID: <20101201182258.2748.99569.stgit@jf-dev1-dcblab>
References: <20101201182252.2748.15208.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	tgraf@infradead.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17306 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133Ab0LASZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 13:25:05 -0500
In-Reply-To: <20101201182252.2748.15208.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement nla_policy hooks to get/set HW offloaded QOS policies.
The following types are added to RTM_{GET|SET}LINK.


 [IFLA_TC]
	[IFLA_TC_MAX_TC]
 	[IFLA_TC_NUM_TC]
 	[IFLA_TC_TXQS]
		[IFLA_TC_TXQ]
 		...
	[IFLA_TC_MAPS]
		[IFLA_TC_MAP]
		...

The following are read only,

IFLA_TC_MAX_TC
IFLA_TC_TXQS

The IFLA_TC_MAX_TC attribute can only be set by the lower layer drivers
because it is a hardware limit. The IFLA_TC_TXQ_* values provide insight
into how the hardware has aligned the tx queues with traffic classes
but can not be modified.

This adds a net_device ops ndo_set_num_tc() to callback into drivers
to change the number of traffic classes. Lower layer drivers may need to
move resources around or reconfigure HW to support changing number
of traffic classes.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/if_link.h   |   50 ++++++++++++++++++++++
 include/linux/netdevice.h |    4 ++
 net/core/rtnetlink.c      |  103 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 156 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 6485d2a..ebe13a0 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -135,6 +135,7 @@ enum {
 	IFLA_VF_PORTS,
 	IFLA_PORT_SELF,
 	IFLA_AF_SPEC,
+	IFLA_TC,
 	__IFLA_MAX
 };
 
@@ -378,4 +379,53 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+/* HW QOS management section
+ *
+ *	Nested layout of set/get msg is:
+ *
+ *		[IFLA_TC]
+ *			[IFLA_TC_MAX_TC]
+ *			[IFLA_TC_NUM_TC]
+ *			[IFLA_TC_TXQS]
+ *				[IFLA_TC_TXQ]
+ *				...
+ *			[IFLA_TC_MAPS]
+ *				[IFLA_TC_MAP]
+ *				...
+ */
+enum {
+	IFLA_TC_UNSPEC,
+	IFLA_TC_TXMAX,
+	IFLA_TC_TXNUM,
+	IFLA_TC_TXQS,
+	IFLA_TC_MAPS,
+	__IFLA_TC_MAX,
+};
+#define IFLA_TC_MAX (__IFLA_TC_MAX - 1)
+
+struct ifla_tc_txq {
+	__u8 tc;
+	__u16 count;
+	__u16 offset;
+};
+
+enum {
+	IFLA_TC_TXQ_UNSPEC,
+	IFLA_TC_TXQ,
+	__IFLA_TC_TCQ_MAX,
+};
+#define IFLA_TC_TXQS_MAX (__IFLA_TC_TCQ_MAX - 1)
+
+struct ifla_tc_map {
+	__u8 prio;
+	__u8 tc;
+};
+
+enum {
+	IFLA_TC_MAP_UNSPEC,
+	IFLA_TC_MAP,
+	__IFLA_TC_MAP_MAX,
+};
+#define IFLA_TC_MAPS_MAX (__IFLA_TC_TCQ_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3307979..c44da29 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -744,6 +744,8 @@ struct netdev_tc_txq {
  * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
  *			  struct nlattr *port[]);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
+ *
+ * int (*ndo_set_num_tc)(struct net_device *dev, int tcs);
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -802,6 +804,8 @@ struct net_device_ops {
 						   struct nlattr *port[]);
 	int			(*ndo_get_vf_port)(struct net_device *dev,
 						   int vf, struct sk_buff *skb);
+	int			(*ndo_set_num_tc)(struct net_device *dev,
+						  u8 tcs);
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 750db57..12bdff5 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -739,6 +739,21 @@ static size_t rtnl_port_size(const struct net_device *dev)
 		return port_self_size;
 }
 
+static size_t rtnl_tc_size(const struct net_device *dev)
+{
+	u8 num_tcs = netdev_get_num_tc(dev);
+	size_t table_size = nla_total_size(8)	/* IFLA_TC_TXMAX */
+		+ nla_total_size(8);		/* IFLA_TC_TXNUM */
+
+	table_size += nla_total_size(sizeof(struct nlattr));
+	table_size += num_tcs * nla_total_size(sizeof(struct ifla_tc_txq));
+
+	table_size += nla_total_size(sizeof(struct nlattr));
+	table_size += 16 * nla_total_size(sizeof(struct ifla_tc_map));
+
+	return table_size;
+}
+
 static noinline size_t if_nlmsg_size(const struct net_device *dev)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
@@ -761,7 +776,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev)
 	       + rtnl_vfinfo_size(dev) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
-	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
+	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
+	       + rtnl_tc_size(dev); /* IFLA_TC */
 }
 
 static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
@@ -952,6 +968,41 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (rtnl_port_fill(skb, dev))
 		goto nla_put_failure;
 
+	if (dev->max_tcs) {
+		struct nlattr *tc_tbl, *tc_txq, *tc_map;
+		struct netdev_tc_txq *tcq;
+		struct ifla_tc_txq ifla_tcq;
+		struct ifla_tc_map ifla_map;
+		u8 i;
+
+		tc_tbl = nla_nest_start(skb, IFLA_TC);
+		if (!tc_tbl)
+			goto nla_put_failure;
+
+		NLA_PUT_U8(skb, IFLA_TC_TXMAX, dev->max_tcs);
+		NLA_PUT_U8(skb, IFLA_TC_TXNUM, dev->num_tcs);
+
+		tc_txq = nla_nest_start(skb, IFLA_TC_TXQS);
+		for (i = 0; i < dev->num_tcs; i++) {
+			tcq = netdev_get_tc_queue(dev, i);
+			ifla_tcq.tc = i;
+			ifla_tcq.count = tcq->count;
+			ifla_tcq.offset = tcq->offset;
+
+			NLA_PUT(skb, IFLA_TC_TXQ, sizeof(ifla_tcq), &ifla_tcq);
+		}
+		nla_nest_end(skb, tc_txq);
+
+		tc_map = nla_nest_start(skb, IFLA_TC_MAPS);
+		for (i = 0; i < 16; i++) {
+			ifla_map.prio = i;
+			ifla_map.tc = netdev_get_prio_tc_map(dev, i);
+			NLA_PUT(skb, IFLA_TC_MAP, sizeof(ifla_map), &ifla_map);
+		}
+		nla_nest_end(skb, tc_map);
+		nla_nest_end(skb, tc_tbl);
+	}
+
 	if (dev->rtnl_link_ops) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
@@ -1046,6 +1097,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_VF_PORTS]		= { .type = NLA_NESTED },
 	[IFLA_PORT_SELF]	= { .type = NLA_NESTED },
 	[IFLA_AF_SPEC]		= { .type = NLA_NESTED },
+	[IFLA_TC]		= { .type = NLA_NESTED },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1081,6 +1133,23 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
 };
 
+static const struct nla_policy ifla_tc_policy[IFLA_TC_MAX+1] = {
+	[IFLA_TC_TXMAX]		= { .type = NLA_U8 },
+	[IFLA_TC_TXNUM]		= { .type = NLA_U8 },
+	[IFLA_TC_TXQS]		= { .type = NLA_NESTED },
+	[IFLA_TC_MAPS]		= { .type = NLA_NESTED },
+};
+
+static const struct nla_policy ifla_tc_txq[IFLA_TC_TXQS_MAX+1] = {
+	[IFLA_TC_TXQ]		= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_tc_txq)},
+};
+
+static const struct nla_policy ifla_tc_map[IFLA_TC_MAPS_MAX+1] = {
+	[IFLA_TC_MAP]		= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_tc_map)},
+};
+
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 {
 	struct net *net;
@@ -1389,6 +1458,38 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	}
 	err = 0;
 
+	if (tb[IFLA_TC]) {
+		struct nlattr *table[IFLA_TC_MAX+1];
+		struct nlattr *tc_maps;
+		int rem;
+
+		err = nla_parse_nested(table, IFLA_TC_MAX, tb[IFLA_TC],
+				       ifla_tc_policy);
+		if (err < 0)
+			goto errout;
+
+		if (table[IFLA_TC_TXNUM]) {
+			u8 tcs = nla_get_u8(table[IFLA_TC_TXNUM]);
+			err = -EOPNOTSUPP;
+			if (ops->ndo_set_num_tc)
+				err = ops->ndo_set_num_tc(dev, tcs);
+			if (err < 0)
+				goto errout;
+		}
+
+		if (table[IFLA_TC_MAPS]) {
+			nla_for_each_nested(tc_maps, table[IFLA_TC_MAPS], rem) {
+				struct ifla_tc_map *map;
+				map = nla_data(tc_maps);
+				err = netdev_set_prio_tc_map(dev, map->prio,
+							     map->tc);
+				if (err < 0)
+					goto errout;
+			}
+		}
+	}
+	err = 0;
+
 errout:
 	if (err < 0 && modified && net_ratelimit())
 		printk(KERN_WARNING "A link change request failed with "

