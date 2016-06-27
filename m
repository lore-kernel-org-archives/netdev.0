From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] net: bridge: add support for IGMP/MLD stats and export them via netlink
Date: Mon, 27 Jun 2016 20:10:48 +0200
Message-ID: <1467051048-32604-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:33994 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbcF0SK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:10:59 -0400
Received: by mail-wm0-f41.google.com with SMTP id 187so22739993wmz.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 11:10:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds stats support for the currently used IGMP/MLD types by the
bridge. The stats are per-port (plus one stat per-bridge) and per-direction
(RX/TX). The stats are exported via netlink via the new linkxstats API
(RTM_GETSTATS). In order to minimize the performance impact, a new option
is used to enable/disable the stats - multicast_stats_enabled, similar to
the recent vlan stats. Also in order to avoid multiple IGMP/MLD type
lookups and checks, we make use of the current "igmp" member of the bridge
private skb->cb region to record the type on Rx (both host-generated and
external packets pass by multicast_rcv()). We can do that since the igmp
member was used as a boolean and all the valid IGMP/MLD types are positive
values. The normal bridge fast-path is not affected at all, the only
affected paths are the flooding ones and since we make use of the IGMP/MLD
type, we can quickly determine if the packet should be counted using
cache-hot data (cb's igmp member). We add counters for:
* IGMP Queries
* IGMP Leaves
* IGMP v1/v2/v3 reports

* MLD Queries
* MLD Leaves
* MLD v1/v2 reports

These are invaluable when monitoring or debugging complex multicast setups
with bridges.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_bridge.h |  27 +++++++
 include/uapi/linux/if_link.h   |   1 +
 net/bridge/br_device.c         |  10 ++-
 net/bridge/br_forward.c        |  13 ++-
 net/bridge/br_if.c             |   9 ++-
 net/bridge/br_input.c          |   3 +
 net/bridge/br_multicast.c      | 176 +++++++++++++++++++++++++++++++++++++----
 net/bridge/br_netlink.c        |  94 ++++++++++++++++------
 net/bridge/br_private.h        |  41 +++++++++-
 net/bridge/br_sysfs_br.c       |  25 ++++++
 10 files changed, 356 insertions(+), 43 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 397d503fdedb..9a0d81615a2f 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -247,8 +247,35 @@ enum {
 enum {
 	BRIDGE_XSTATS_UNSPEC,
 	BRIDGE_XSTATS_VLAN,
+	BRIDGE_XSTATS_MCAST,
+	BRIDGE_XSTATS_PAD,
 	__BRIDGE_XSTATS_MAX
 };
 #define BRIDGE_XSTATS_MAX (__BRIDGE_XSTATS_MAX - 1)
 
+enum {
+	BR_MCAST_DIR_RX,
+	BR_MCAST_DIR_TX,
+	BR_MCAST_DIR_SIZE
+};
+
+/* IGMP/MLD statistics */
+struct br_mcast_stats {
+	__u64 igmp_queries[BR_MCAST_DIR_SIZE];
+	__u64 igmp_leaves[BR_MCAST_DIR_SIZE];
+	__u64 igmp_v1reports[BR_MCAST_DIR_SIZE];
+	__u64 igmp_v2reports[BR_MCAST_DIR_SIZE];
+	__u64 igmp_v3reports[BR_MCAST_DIR_SIZE];
+
+	__u64 mld_queries[BR_MCAST_DIR_SIZE];
+	__u64 mld_leaves[BR_MCAST_DIR_SIZE];
+	__u64 mld_v1reports[BR_MCAST_DIR_SIZE];
+	__u64 mld_v2reports[BR_MCAST_DIR_SIZE];
+};
+
+struct br_mcast_stats_nla {
+	int ifindex;
+	__u32 pad1;
+	struct br_mcast_stats mstats;
+};
 #endif /* _UAPI_LINUX_IF_BRIDGE_H */
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index bb36bd5675a7..c9cb6adfda13 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -273,6 +273,7 @@ enum {
 	IFLA_BR_VLAN_DEFAULT_PVID,
 	IFLA_BR_PAD,
 	IFLA_BR_VLAN_STATS_ENABLED,
+	IFLA_BR_MCAST_STATS_ENABLED,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 2c8095a5d824..0c39e0f6da09 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -104,8 +104,16 @@ static int br_dev_init(struct net_device *dev)
 		return -ENOMEM;
 
 	err = br_vlan_init(br);
-	if (err)
+	if (err) {
 		free_percpu(br->stats);
+		return err;
+	}
+
+	err = br_multicast_init_stats(br);
+	if (err) {
+		free_percpu(br->stats);
+		br_vlan_flush(br);
+	}
 	br_set_lockdep_class(dev);
 
 	return err;
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index f47759f05b6d..6c196037d818 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -198,8 +198,10 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 					   struct sk_buff *skb),
 		     bool unicast)
 {
-	struct net_bridge_port *p;
+	u8 igmp_type = br_multicast_igmp_type(skb);
+	__be16 proto = skb->protocol;
 	struct net_bridge_port *prev;
+	struct net_bridge_port *p;
 
 	prev = NULL;
 
@@ -218,6 +220,9 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		prev = maybe_deliver(prev, p, skb, __packet_hook);
 		if (IS_ERR(prev))
 			goto out;
+		if (prev == p)
+			br_multicast_count(p->br, p, proto, igmp_type,
+					   BR_MCAST_DIR_TX);
 	}
 
 	if (!prev)
@@ -257,9 +262,12 @@ static void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
 					struct sk_buff *skb))
 {
 	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
+	u8 igmp_type = br_multicast_igmp_type(skb);
 	struct net_bridge *br = netdev_priv(dev);
 	struct net_bridge_port *prev = NULL;
 	struct net_bridge_port_group *p;
+	__be16 proto = skb->protocol;
+
 	struct hlist_node *rp;
 
 	rp = rcu_dereference(hlist_first_rcu(&br->router_list));
@@ -277,6 +285,9 @@ static void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
 		prev = maybe_deliver(prev, port, skb, __packet_hook);
 		if (IS_ERR(prev))
 			goto out;
+		if (prev == port)
+			br_multicast_count(port->br, port, proto, igmp_type,
+					   BR_MCAST_DIR_TX);
 
 		if ((unsigned long)lport >= (unsigned long)port)
 			p = rcu_dereference(p->next);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 8217aecf025b..f2fede05d32c 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -345,8 +345,8 @@ static int find_portno(struct net_bridge *br)
 static struct net_bridge_port *new_nbp(struct net_bridge *br,
 				       struct net_device *dev)
 {
-	int index;
 	struct net_bridge_port *p;
+	int index, err;
 
 	index = find_portno(br);
 	if (index < 0)
@@ -366,7 +366,12 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	br_init_port(p);
 	br_set_state(p, BR_STATE_DISABLED);
 	br_stp_port_timer_init(p);
-	br_multicast_add_port(p);
+	err = br_multicast_add_port(p);
+	if (err) {
+		dev_put(dev);
+		kfree(p);
+		p = ERR_PTR(err);
+	}
 
 	return p;
 }
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 160797722228..67bfa1ea9827 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -60,6 +60,9 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	skb = br_handle_vlan(br, vg, skb);
 	if (!skb)
 		return NET_RX_DROP;
+	/* update the multicast stats if the packet is IGMP/MLD */
+	br_multicast_count(br, NULL, skb->protocol, br_multicast_igmp_type(skb),
+			   BR_MCAST_DIR_TX);
 
 	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN,
 		       dev_net(indev), NULL, skb, indev, NULL,
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 6852f3c7009c..ec7fbe1a6c25 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -361,7 +361,8 @@ out:
 }
 
 static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
-						    __be32 group)
+						    __be32 group,
+						    u8 *igmp_type)
 {
 	struct sk_buff *skb;
 	struct igmphdr *ih;
@@ -411,6 +412,7 @@ static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
 
 	skb_set_transport_header(skb, skb->len);
 	ih = igmp_hdr(skb);
+	*igmp_type = IGMP_HOST_MEMBERSHIP_QUERY;
 	ih->type = IGMP_HOST_MEMBERSHIP_QUERY;
 	ih->code = (group ? br->multicast_last_member_interval :
 			    br->multicast_query_response_interval) /
@@ -428,7 +430,8 @@ out:
 
 #if IS_ENABLED(CONFIG_IPV6)
 static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
-						    const struct in6_addr *group)
+						    const struct in6_addr *grp,
+						    u8 *igmp_type)
 {
 	struct sk_buff *skb;
 	struct ipv6hdr *ip6h;
@@ -484,16 +487,17 @@ static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
 	skb_set_transport_header(skb, skb->len);
 	mldq = (struct mld_msg *) icmp6_hdr(skb);
 
-	interval = ipv6_addr_any(group) ?
+	interval = ipv6_addr_any(grp) ?
 			br->multicast_query_response_interval :
 			br->multicast_last_member_interval;
 
+	*igmp_type = ICMPV6_MGM_QUERY;
 	mldq->mld_type = ICMPV6_MGM_QUERY;
 	mldq->mld_code = 0;
 	mldq->mld_cksum = 0;
 	mldq->mld_maxdelay = htons((u16)jiffies_to_msecs(interval));
 	mldq->mld_reserved = 0;
-	mldq->mld_mca = *group;
+	mldq->mld_mca = *grp;
 
 	/* checksum */
 	mldq->mld_cksum = csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
@@ -510,14 +514,16 @@ out:
 #endif
 
 static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
-						struct br_ip *addr)
+						struct br_ip *addr,
+						u8 *igmp_type)
 {
 	switch (addr->proto) {
 	case htons(ETH_P_IP):
-		return br_ip4_multicast_alloc_query(br, addr->u.ip4);
+		return br_ip4_multicast_alloc_query(br, addr->u.ip4, igmp_type);
 #if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
-		return br_ip6_multicast_alloc_query(br, &addr->u.ip6);
+		return br_ip6_multicast_alloc_query(br, &addr->u.ip6,
+						    igmp_type);
 #endif
 	}
 	return NULL;
@@ -826,18 +832,23 @@ static void __br_multicast_send_query(struct net_bridge *br,
 				      struct br_ip *ip)
 {
 	struct sk_buff *skb;
+	u8 igmp_type;
 
-	skb = br_multicast_alloc_query(br, ip);
+	skb = br_multicast_alloc_query(br, ip, &igmp_type);
 	if (!skb)
 		return;
 
 	if (port) {
 		skb->dev = port->dev;
+		br_multicast_count(br, port, skb->protocol, igmp_type,
+				   BR_MCAST_DIR_TX);
 		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT,
 			dev_net(port->dev), NULL, skb, NULL, skb->dev,
 			br_dev_queue_push_xmit);
 	} else {
 		br_multicast_select_own_querier(br, ip, skb);
+		br_multicast_count(br, port, skb->protocol, igmp_type,
+				   BR_MCAST_DIR_RX);
 		netif_rx(skb);
 	}
 }
@@ -915,7 +926,7 @@ static void br_ip6_multicast_port_query_expired(unsigned long data)
 }
 #endif
 
-void br_multicast_add_port(struct net_bridge_port *port)
+int br_multicast_add_port(struct net_bridge_port *port)
 {
 	port->multicast_router = MDB_RTR_TYPE_TEMP_QUERY;
 
@@ -927,6 +938,11 @@ void br_multicast_add_port(struct net_bridge_port *port)
 	setup_timer(&port->ip6_own_query.timer,
 		    br_ip6_multicast_port_query_expired, (unsigned long)port);
 #endif
+	port->mcast_stats = netdev_alloc_pcpu_stats(struct bridge_mcast_stats);
+	if (!port->mcast_stats)
+		return -ENOMEM;
+
+	return 0;
 }
 
 void br_multicast_del_port(struct net_bridge_port *port)
@@ -941,6 +957,7 @@ void br_multicast_del_port(struct net_bridge_port *port)
 		br_multicast_del_pg(br, pg);
 	spin_unlock_bh(&br->multicast_lock);
 	del_timer_sync(&port->multicast_router_timer);
+	free_percpu(port->mcast_stats);
 }
 
 static void br_multicast_enable(struct bridge_mcast_own_query *query)
@@ -1599,8 +1616,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 		return err;
 	}
 
-	BR_INPUT_SKB_CB(skb)->igmp = 1;
 	ih = igmp_hdr(skb);
+	BR_INPUT_SKB_CB(skb)->igmp = ih->type;
 
 	switch (ih->type) {
 	case IGMP_HOST_MEMBERSHIP_REPORT:
@@ -1645,8 +1662,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 		return err;
 	}
 
-	BR_INPUT_SKB_CB(skb)->igmp = 1;
 	mld = (struct mld_msg *)skb_transport_header(skb);
+	BR_INPUT_SKB_CB(skb)->igmp = mld->mld_type;
 
 	switch (mld->mld_type) {
 	case ICMPV6_MGM_REPORT:
@@ -1674,6 +1691,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 		     struct sk_buff *skb, u16 vid)
 {
+	int ret = 0;
+
 	BR_INPUT_SKB_CB(skb)->igmp = 0;
 	BR_INPUT_SKB_CB(skb)->mrouters_only = 0;
 
@@ -1682,14 +1701,18 @@ int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		return br_multicast_ipv4_rcv(br, port, skb, vid);
+		ret = br_multicast_ipv4_rcv(br, port, skb, vid);
+		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
-		return br_multicast_ipv6_rcv(br, port, skb, vid);
+		ret = br_multicast_ipv6_rcv(br, port, skb, vid);
+		break;
 #endif
 	}
+	br_multicast_count(br, port, skb->protocol, BR_INPUT_SKB_CB(skb)->igmp,
+			   BR_MCAST_DIR_RX);
 
-	return 0;
+	return ret;
 }
 
 static void br_multicast_query_expired(struct net_bridge *br,
@@ -1827,6 +1850,8 @@ void br_multicast_dev_del(struct net_bridge *br)
 
 out:
 	spin_unlock_bh(&br->multicast_lock);
+
+	free_percpu(br->mcast_stats);
 }
 
 int br_multicast_set_router(struct net_bridge *br, unsigned long val)
@@ -2181,3 +2206,126 @@ unlock:
 	return ret;
 }
 EXPORT_SYMBOL_GPL(br_multicast_has_querier_adjacent);
+
+static void br_mcast_stats_add(struct bridge_mcast_stats __percpu *stats,
+			       __be16 proto, u8 type, u8 dir)
+{
+	struct bridge_mcast_stats *pstats = this_cpu_ptr(stats);
+
+	u64_stats_update_begin(&pstats->syncp);
+	switch (proto) {
+	case htons(ETH_P_IP):
+		switch (type) {
+		case IGMP_HOST_MEMBERSHIP_REPORT:
+			pstats->mstats.igmp_v1reports[dir]++;
+			break;
+		case IGMPV2_HOST_MEMBERSHIP_REPORT:
+			pstats->mstats.igmp_v2reports[dir]++;
+			break;
+		case IGMPV3_HOST_MEMBERSHIP_REPORT:
+			pstats->mstats.igmp_v3reports[dir]++;
+			break;
+		case IGMP_HOST_MEMBERSHIP_QUERY:
+			pstats->mstats.igmp_queries[dir]++;
+			break;
+		case IGMP_HOST_LEAVE_MESSAGE:
+			pstats->mstats.igmp_leaves[dir]++;
+			break;
+		}
+		break;
+#if IS_ENABLED(CONFIG_IPV6)
+	case htons(ETH_P_IPV6):
+		switch (type) {
+		case ICMPV6_MGM_REPORT:
+			pstats->mstats.mld_v1reports[dir]++;
+			break;
+		case ICMPV6_MLD2_REPORT:
+			pstats->mstats.mld_v2reports[dir]++;
+			break;
+		case ICMPV6_MGM_QUERY:
+			pstats->mstats.mld_queries[dir]++;
+			break;
+		case ICMPV6_MGM_REDUCTION:
+			pstats->mstats.mld_leaves[dir]++;
+			break;
+		}
+		break;
+#endif /* CONFIG_IPV6 */
+	}
+	u64_stats_update_end(&pstats->syncp);
+}
+
+void br_multicast_count(struct net_bridge *br, const struct net_bridge_port *p,
+			__be16 proto, u8 type, u8 dir)
+{
+	struct bridge_mcast_stats __percpu *stats;
+
+	/* if multicast_disabled is true then igmp type can't be set */
+	if (!type || !br->multicast_stats_enabled)
+		return;
+
+	if (p)
+		stats = p->mcast_stats;
+	else
+		stats = br->mcast_stats;
+	if (WARN_ON(!stats))
+		return;
+
+	br_mcast_stats_add(stats, proto, type, dir);
+}
+
+int br_multicast_init_stats(struct net_bridge *br)
+{
+	br->mcast_stats = netdev_alloc_pcpu_stats(struct bridge_mcast_stats);
+	if (!br->mcast_stats)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void mcast_stats_add(u64 *dst, u64 *src)
+{
+	dst[BR_MCAST_DIR_RX] += src[BR_MCAST_DIR_RX];
+	dst[BR_MCAST_DIR_TX] += src[BR_MCAST_DIR_TX];
+}
+
+void br_multicast_get_stats(const struct net_bridge *br,
+			    const struct net_bridge_port *p,
+			    struct br_mcast_stats *dest)
+{
+	struct bridge_mcast_stats __percpu *stats;
+	struct br_mcast_stats tdst;
+	int i;
+
+	memset(dest, 0, sizeof(*dest));
+	if (p)
+		stats = p->mcast_stats;
+	else
+		stats = br->mcast_stats;
+	if (WARN_ON(!stats))
+		return;
+
+	memset(&tdst, 0, sizeof(tdst));
+	for_each_possible_cpu(i) {
+		struct bridge_mcast_stats *cpu_stats = per_cpu_ptr(stats, i);
+		struct br_mcast_stats temp;
+		unsigned int start;
+
+		do {
+			start = u64_stats_fetch_begin_irq(&cpu_stats->syncp);
+			memcpy(&temp, &cpu_stats->mstats, sizeof(temp));
+		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, start));
+
+		mcast_stats_add(tdst.igmp_queries, temp.igmp_queries);
+		mcast_stats_add(tdst.igmp_leaves, temp.igmp_leaves);
+		mcast_stats_add(tdst.igmp_v1reports, temp.igmp_v1reports);
+		mcast_stats_add(tdst.igmp_v2reports, temp.igmp_v2reports);
+		mcast_stats_add(tdst.igmp_v3reports, temp.igmp_v3reports);
+
+		mcast_stats_add(tdst.mld_queries, temp.mld_queries);
+		mcast_stats_add(tdst.mld_leaves, temp.mld_leaves);
+		mcast_stats_add(tdst.mld_v1reports, temp.mld_v1reports);
+		mcast_stats_add(tdst.mld_v2reports, temp.mld_v2reports);
+	}
+	memcpy(dest, &tdst, sizeof(*dest));
+}
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index a5343c7232bf..598917e1e6e8 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -851,6 +851,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_NF_CALL_ARPTABLES] = { .type = NLA_U8 },
 	[IFLA_BR_VLAN_DEFAULT_PVID] = { .type = NLA_U16 },
 	[IFLA_BR_VLAN_STATS_ENABLED] = { .type = NLA_U8 },
+	[IFLA_BR_MCAST_STATS_ENABLED] = { .type = NLA_U8 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -1055,6 +1056,13 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 
 		br->multicast_startup_query_interval = clock_t_to_jiffies(val);
 	}
+
+	if (data[IFLA_BR_MCAST_STATS_ENABLED]) {
+		__u8 mcast_stats;
+
+		mcast_stats = nla_get_u8(data[IFLA_BR_MCAST_STATS_ENABLED]);
+		br->multicast_stats_enabled = !!mcast_stats;
+	}
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (data[IFLA_BR_NF_CALL_IPTABLES]) {
@@ -1110,6 +1118,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_SNOOPING */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_QUERY_USE_IFADDR */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_QUERIER */
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_STATS_ENABLED */
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_HASH_ELASTICITY */
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_HASH_MAX */
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_MCAST_LAST_MEMBER_CNT */
@@ -1187,6 +1196,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u8(skb, IFLA_BR_MCAST_QUERY_USE_IFADDR,
 		       br->multicast_query_use_ifaddr) ||
 	    nla_put_u8(skb, IFLA_BR_MCAST_QUERIER, br->multicast_querier) ||
+	    nla_put_u8(skb, IFLA_BR_MCAST_STATS_ENABLED,
+		       br->multicast_stats_enabled) ||
 	    nla_put_u32(skb, IFLA_BR_MCAST_HASH_ELASTICITY,
 			br->hash_elasticity) ||
 	    nla_put_u32(skb, IFLA_BR_MCAST_HASH_MAX, br->hash_max) ||
@@ -1237,58 +1248,95 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 static size_t br_get_linkxstats_size(const struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *p __maybe_unused;
 	struct net_bridge_vlan_group *vg;
 	struct net_bridge_vlan *v;
+	int num_ports = 0;
 	int numvls = 0;
 
 	vg = br_vlan_group(br);
-	if (!vg)
-		return 0;
+	if (vg) {
+		/* we need to count all, even placeholder entries */
+		list_for_each_entry(v, &vg->vlan_list, vlist)
+			numvls++;
+	}
 
-	/* we need to count all, even placeholder entries */
-	list_for_each_entry(v, &vg->vlan_list, vlist)
-		numvls++;
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+	list_for_each_entry(p, &br->port_list, list)
+		num_ports++;
+#endif
 
-	/* account for the vlans and the link xstats type nest attribute */
 	return numvls * nla_total_size(sizeof(struct bridge_vlan_xstats)) +
+	       num_ports * nla_total_size(sizeof(struct br_mcast_stats_nla)) +
 	       nla_total_size(0);
 }
 
 static int br_fill_linkxstats(struct sk_buff *skb, const struct net_device *dev,
 			      int *prividx)
 {
+	struct br_mcast_stats_nla *mstnl __maybe_unused;
 	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *p __maybe_unused;
+	struct nlattr *nla __maybe_unused;
 	struct net_bridge_vlan_group *vg;
 	struct net_bridge_vlan *v;
 	struct nlattr *nest;
 	int vl_idx = 0;
 
-	vg = br_vlan_group(br);
-	if (!vg)
-		goto out;
 	nest = nla_nest_start(skb, LINK_XSTATS_TYPE_BRIDGE);
 	if (!nest)
 		return -EMSGSIZE;
-	list_for_each_entry(v, &vg->vlan_list, vlist) {
-		struct bridge_vlan_xstats vxi;
-		struct br_vlan_stats stats;
 
-		if (vl_idx++ < *prividx)
+	vg = br_vlan_group(br);
+	if (vg) {
+		list_for_each_entry(v, &vg->vlan_list, vlist) {
+			struct bridge_vlan_xstats vxi;
+			struct br_vlan_stats stats;
+
+			if (vl_idx++ < *prividx)
+				continue;
+			memset(&vxi, 0, sizeof(vxi));
+			vxi.vid = v->vid;
+			br_vlan_get_stats(v, &stats);
+			vxi.rx_bytes = stats.rx_bytes;
+			vxi.rx_packets = stats.rx_packets;
+			vxi.tx_bytes = stats.tx_bytes;
+			vxi.tx_packets = stats.tx_packets;
+
+			if (nla_put(skb, BRIDGE_XSTATS_VLAN, sizeof(vxi), &vxi))
+				goto nla_put_failure;
+		}
+	}
+
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+	/* First dump the bridge's stats, then ports */
+	if (++vl_idx >= *prividx) {
+		nla = nla_reserve_64bit(skb, BRIDGE_XSTATS_MCAST,
+					sizeof(struct br_mcast_stats_nla),
+					BRIDGE_XSTATS_PAD);
+		if (!nla)
+			goto nla_put_failure;
+		mstnl = nla_data(nla);
+		mstnl->ifindex = dev->ifindex;
+		br_multicast_get_stats(br, NULL, &mstnl->mstats);
+	}
+	list_for_each_entry(p, &br->port_list, list) {
+		if (++vl_idx < *prividx)
 			continue;
-		memset(&vxi, 0, sizeof(vxi));
-		vxi.vid = v->vid;
-		br_vlan_get_stats(v, &stats);
-		vxi.rx_bytes = stats.rx_bytes;
-		vxi.rx_packets = stats.rx_packets;
-		vxi.tx_bytes = stats.tx_bytes;
-		vxi.tx_packets = stats.tx_packets;
-
-		if (nla_put(skb, BRIDGE_XSTATS_VLAN, sizeof(vxi), &vxi))
+		nla = nla_reserve_64bit(skb, BRIDGE_XSTATS_MCAST,
+					sizeof(struct br_mcast_stats_nla),
+					BRIDGE_XSTATS_PAD);
+		if (!nla)
 			goto nla_put_failure;
+		mstnl = nla_data(nla);
+		mstnl->ifindex = p->dev->ifindex;
+		br_multicast_get_stats(NULL, p, &mstnl->mstats);
 	}
+#endif
+
 	nla_nest_end(skb, nest);
 	*prividx = 0;
-out:
+
 	return 0;
 
 nla_put_failure:
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c7fb5d7a7218..e49ddc1b9c7f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -75,6 +75,12 @@ struct bridge_mcast_querier {
 	struct br_ip addr;
 	struct net_bridge_port __rcu	*port;
 };
+
+/* IGMP/MLD statistics */
+struct bridge_mcast_stats {
+	struct br_mcast_stats mstats;
+	struct u64_stats_sync syncp;
+};
 #endif
 
 struct br_vlan_stats {
@@ -229,6 +235,7 @@ struct net_bridge_port
 	struct bridge_mcast_own_query	ip6_own_query;
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 	unsigned char			multicast_router;
+	struct bridge_mcast_stats	__percpu *mcast_stats;
 	struct timer_list		multicast_router_timer;
 	struct hlist_head		mglist;
 	struct hlist_node		rlist;
@@ -314,6 +321,7 @@ struct net_bridge
 	u8				multicast_disabled:1;
 	u8				multicast_querier:1;
 	u8				multicast_query_use_ifaddr:1;
+	u8				multicast_stats_enabled:1;
 
 	u32				hash_elasticity;
 	u32				hash_max;
@@ -336,6 +344,7 @@ struct net_bridge
 	struct bridge_mcast_other_query	ip4_other_query;
 	struct bridge_mcast_own_query	ip4_own_query;
 	struct bridge_mcast_querier	ip4_querier;
+	struct bridge_mcast_stats	__percpu *mcast_stats;
 #if IS_ENABLED(CONFIG_IPV6)
 	struct bridge_mcast_other_query	ip6_other_query;
 	struct bridge_mcast_own_query	ip6_own_query;
@@ -542,7 +551,7 @@ int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 		     struct sk_buff *skb, u16 vid);
 struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 					struct sk_buff *skb, u16 vid);
-void br_multicast_add_port(struct net_bridge_port *port);
+int br_multicast_add_port(struct net_bridge_port *port);
 void br_multicast_del_port(struct net_bridge_port *port);
 void br_multicast_enable_port(struct net_bridge_port *port);
 void br_multicast_disable_port(struct net_bridge_port *port);
@@ -575,6 +584,12 @@ void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
 		   struct br_ip *group, int type, u8 flags);
 void br_rtr_notify(struct net_device *dev, struct net_bridge_port *port,
 		   int type);
+void br_multicast_count(struct net_bridge *br, const struct net_bridge_port *p,
+			__be16 proto, u8 type, u8 dir);
+int br_multicast_init_stats(struct net_bridge *br);
+void br_multicast_get_stats(const struct net_bridge *br,
+			    const struct net_bridge_port *p,
+			    struct br_mcast_stats *dest);
 
 #define mlock_dereference(X, br) \
 	rcu_dereference_protected(X, lockdep_is_held(&br->multicast_lock))
@@ -608,6 +623,11 @@ static inline bool br_multicast_querier_exists(struct net_bridge *br,
 		return false;
 	}
 }
+
+static inline int br_multicast_igmp_type(const struct sk_buff *skb)
+{
+	return BR_INPUT_SKB_CB(skb)->igmp;
+}
 #else
 static inline int br_multicast_rcv(struct net_bridge *br,
 				   struct net_bridge_port *port,
@@ -623,8 +643,9 @@ static inline struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 	return NULL;
 }
 
-static inline void br_multicast_add_port(struct net_bridge_port *port)
+static inline int br_multicast_add_port(struct net_bridge_port *port)
 {
+	return 0;
 }
 
 static inline void br_multicast_del_port(struct net_bridge_port *port)
@@ -680,6 +701,22 @@ static inline void br_mdb_init(void)
 static inline void br_mdb_uninit(void)
 {
 }
+
+static inline void br_multicast_count(struct net_bridge *br,
+				      const struct net_bridge_port *p,
+				      __be16 proto, u8 type, u8 dir)
+{
+}
+
+static inline int br_multicast_init_stats(struct net_bridge *br)
+{
+	return 0;
+}
+
+static inline int br_multicast_igmp_type(const struct sk_buff *skb)
+{
+	return 0;
+}
 #endif
 
 /* br_vlan.c */
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index beb47071e38d..e120307c6e36 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -618,6 +618,30 @@ static ssize_t multicast_startup_query_interval_store(
 	return store_bridge_parm(d, buf, len, set_startup_query_interval);
 }
 static DEVICE_ATTR_RW(multicast_startup_query_interval);
+
+static ssize_t multicast_stats_enabled_show(struct device *d,
+					    struct device_attribute *attr,
+					    char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+
+	return sprintf(buf, "%u\n", br->multicast_stats_enabled);
+}
+
+static int set_stats_enabled(struct net_bridge *br, unsigned long val)
+{
+	br->multicast_stats_enabled = !!val;
+	return 0;
+}
+
+static ssize_t multicast_stats_enabled_store(struct device *d,
+					     struct device_attribute *attr,
+					     const char *buf,
+					     size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_stats_enabled);
+}
+static DEVICE_ATTR_RW(multicast_stats_enabled);
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 static ssize_t nf_call_iptables_show(
@@ -784,6 +808,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_multicast_query_interval.attr,
 	&dev_attr_multicast_query_response_interval.attr,
 	&dev_attr_multicast_startup_query_interval.attr,
+	&dev_attr_multicast_stats_enabled.attr,
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	&dev_attr_nf_call_iptables.attr,
-- 
2.1.4
