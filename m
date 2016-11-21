From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 1/2] bridge: mcast: add IGMPv3 query support
Date: Mon, 21 Nov 2016 13:03:24 +0100
Message-ID: <1479729805-23108-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1479729805-23108-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, sashok@cumulusnetworks.com,
        stephen@networkplumber.org, davem@davemloft.net,
        liuhangbin@gmail.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36280 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753623AbcKUMFE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 07:05:04 -0500
Received: by mail-wm0-f44.google.com with SMTP id g23so142932340wme.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 04:05:04 -0800 (PST)
In-Reply-To: <1479729805-23108-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds basic support for IGMPv3 queries, the default is IGMPv2
as before. A new multicast option - multicast_igmp_version, adds the
ability to change it between 2 and 3 via netlink and sysfs. The option
struct member is in a 4 byte hole in net_bridge.

There also a few minor style adjustments in br_multicast_new_group and
br_multicast_add_group.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_multicast.c    | 79 ++++++++++++++++++++++++++++++++++----------
 net/bridge/br_netlink.c      | 15 ++++++++-
 net/bridge/br_private.h      |  3 ++
 net/bridge/br_sysfs_br.c     | 18 ++++++++++
 5 files changed, 98 insertions(+), 18 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b4fba662cd32..325d2601150d 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -275,6 +275,7 @@ enum {
 	IFLA_BR_PAD,
 	IFLA_BR_VLAN_STATS_ENABLED,
 	IFLA_BR_MCAST_STATS_ENABLED,
+	IFLA_BR_MCAST_IGMP_VERSION,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 073d54afa056..66192c11aa45 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -365,13 +365,18 @@ static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
 						    __be32 group,
 						    u8 *igmp_type)
 {
+	struct igmpv3_query *ihv3;
+	size_t igmp_hdr_size;
 	struct sk_buff *skb;
 	struct igmphdr *ih;
 	struct ethhdr *eth;
 	struct iphdr *iph;
 
+	igmp_hdr_size = sizeof(*ih);
+	if (br->multicast_igmp_version == 3)
+		igmp_hdr_size = sizeof(*ihv3);
 	skb = netdev_alloc_skb_ip_align(br->dev, sizeof(*eth) + sizeof(*iph) +
-						 sizeof(*ih) + 4);
+						 igmp_hdr_size + 4);
 	if (!skb)
 		goto out;
 
@@ -396,7 +401,7 @@ static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
 	iph->version = 4;
 	iph->ihl = 6;
 	iph->tos = 0xc0;
-	iph->tot_len = htons(sizeof(*iph) + sizeof(*ih) + 4);
+	iph->tot_len = htons(sizeof(*iph) + igmp_hdr_size + 4);
 	iph->id = 0;
 	iph->frag_off = htons(IP_DF);
 	iph->ttl = 1;
@@ -412,17 +417,37 @@ static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
 	skb_put(skb, 24);
 
 	skb_set_transport_header(skb, skb->len);
-	ih = igmp_hdr(skb);
 	*igmp_type = IGMP_HOST_MEMBERSHIP_QUERY;
-	ih->type = IGMP_HOST_MEMBERSHIP_QUERY;
-	ih->code = (group ? br->multicast_last_member_interval :
-			    br->multicast_query_response_interval) /
-		   (HZ / IGMP_TIMER_SCALE);
-	ih->group = group;
-	ih->csum = 0;
-	ih->csum = ip_compute_csum((void *)ih, sizeof(struct igmphdr));
-	skb_put(skb, sizeof(*ih));
 
+	switch (br->multicast_igmp_version) {
+	case 2:
+		ih = igmp_hdr(skb);
+		ih->type = IGMP_HOST_MEMBERSHIP_QUERY;
+		ih->code = (group ? br->multicast_last_member_interval :
+				    br->multicast_query_response_interval) /
+			   (HZ / IGMP_TIMER_SCALE);
+		ih->group = group;
+		ih->csum = 0;
+		ih->csum = ip_compute_csum((void *)ih, sizeof(*ih));
+		break;
+	case 3:
+		ihv3 = igmpv3_query_hdr(skb);
+		ihv3->type = IGMP_HOST_MEMBERSHIP_QUERY;
+		ihv3->code = (group ? br->multicast_last_member_interval :
+				      br->multicast_query_response_interval) /
+			     (HZ / IGMP_TIMER_SCALE);
+		ihv3->group = group;
+		ihv3->qqic = br->multicast_query_interval / HZ;
+		ihv3->nsrcs = 0;
+		ihv3->resv = 0;
+		ihv3->suppress = 0;
+		ihv3->qrv = 2;
+		ihv3->csum = 0;
+		ihv3->csum = ip_compute_csum((void *)ihv3, sizeof(*ihv3));
+		break;
+	}
+
+	skb_put(skb, igmp_hdr_size);
 	__skb_pull(skb, sizeof(*eth));
 
 out:
@@ -608,7 +633,8 @@ static struct net_bridge_mdb_entry *br_multicast_get_group(
 }
 
 struct net_bridge_mdb_entry *br_multicast_new_group(struct net_bridge *br,
-	struct net_bridge_port *port, struct br_ip *group)
+						    struct net_bridge_port *p,
+						    struct br_ip *group)
 {
 	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -624,7 +650,7 @@ struct net_bridge_mdb_entry *br_multicast_new_group(struct net_bridge *br,
 	}
 
 	hash = br_ip_hash(mdb, group);
-	mp = br_multicast_get_group(br, port, group, hash);
+	mp = br_multicast_get_group(br, p, group, hash);
 	switch (PTR_ERR(mp)) {
 	case 0:
 		break;
@@ -681,9 +707,9 @@ static int br_multicast_add_group(struct net_bridge *br,
 				  struct net_bridge_port *port,
 				  struct br_ip *group)
 {
-	struct net_bridge_mdb_entry *mp;
-	struct net_bridge_port_group *p;
 	struct net_bridge_port_group __rcu **pp;
+	struct net_bridge_port_group *p;
+	struct net_bridge_mdb_entry *mp;
 	unsigned long now = jiffies;
 	int err;
 
@@ -861,9 +887,9 @@ static void br_multicast_send_query(struct net_bridge *br,
 				    struct net_bridge_port *port,
 				    struct bridge_mcast_own_query *own_query)
 {
-	unsigned long time;
-	struct br_ip br_group;
 	struct bridge_mcast_other_query *other_query = NULL;
+	struct br_ip br_group;
+	unsigned long time;
 
 	if (!netif_running(br->dev) || br->multicast_disabled ||
 	    !br->multicast_querier)
@@ -1816,6 +1842,7 @@ void br_multicast_init(struct net_bridge *br)
 	br->hash_elasticity = 4;
 	br->hash_max = 512;
 
+	br->multicast_igmp_version = 2;
 	br->multicast_router = MDB_RTR_TYPE_TEMP_QUERY;
 	br->multicast_querier = 0;
 	br->multicast_query_use_ifaddr = 0;
@@ -2132,6 +2159,24 @@ int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val)
 	return err;
 }
 
+int br_multicast_set_igmp_version(struct net_bridge *br, unsigned long val)
+{
+	/* Currently we support only version 2 and 3 */
+	switch (val) {
+	case 2:
+	case 3:
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	spin_lock_bh(&br->multicast_lock);
+	br->multicast_igmp_version = val;
+	spin_unlock_bh(&br->multicast_lock);
+
+	return 0;
+}
+
 /**
  * br_multicast_list_adjacent - Returns snooped multicast addresses
  * @dev:	The bridge port adjacent to which to retrieve addresses
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e99037c6f7b7..10b9b80f778f 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -858,6 +858,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_VLAN_DEFAULT_PVID] = { .type = NLA_U16 },
 	[IFLA_BR_VLAN_STATS_ENABLED] = { .type = NLA_U8 },
 	[IFLA_BR_MCAST_STATS_ENABLED] = { .type = NLA_U8 },
+	[IFLA_BR_MCAST_IGMP_VERSION] = { .type = NLA_U8 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -1069,6 +1070,15 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 		mcast_stats = nla_get_u8(data[IFLA_BR_MCAST_STATS_ENABLED]);
 		br->multicast_stats_enabled = !!mcast_stats;
 	}
+
+	if (data[IFLA_BR_MCAST_IGMP_VERSION]) {
+		__u8 igmp_version;
+
+		igmp_version = nla_get_u8(data[IFLA_BR_MCAST_IGMP_VERSION]);
+		err = br_multicast_set_igmp_version(br, igmp_version);
+		if (err)
+			return err;
+	}
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	if (data[IFLA_BR_NF_CALL_IPTABLES]) {
@@ -1135,6 +1145,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_MCAST_QUERY_INTVL */
 	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_MCAST_QUERY_RESPONSE_INTVL */
 	       nla_total_size_64bit(sizeof(u64)) + /* IFLA_BR_MCAST_STARTUP_QUERY_INTVL */
+	       nla_total_size(sizeof(u8)) +	/* IFLA_BR_MCAST_IGMP_VERSION */
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_NF_CALL_IPTABLES */
@@ -1210,7 +1221,9 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u32(skb, IFLA_BR_MCAST_LAST_MEMBER_CNT,
 			br->multicast_last_member_count) ||
 	    nla_put_u32(skb, IFLA_BR_MCAST_STARTUP_QUERY_CNT,
-			br->multicast_startup_query_count))
+			br->multicast_startup_query_count) ||
+	    nla_put_u8(skb, IFLA_BR_MCAST_IGMP_VERSION,
+		       br->multicast_igmp_version))
 		return -EMSGSIZE;
 
 	clockval = jiffies_to_clock_t(br->multicast_last_member_interval);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1b63177e0ccd..3d207d92d899 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -333,6 +333,8 @@ struct net_bridge
 	u32				multicast_last_member_count;
 	u32				multicast_startup_query_count;
 
+	u8				multicast_igmp_version;
+
 	unsigned long			multicast_last_member_interval;
 	unsigned long			multicast_membership_interval;
 	unsigned long			multicast_querier_interval;
@@ -582,6 +584,7 @@ int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long val);
 int br_multicast_toggle(struct net_bridge *br, unsigned long val);
 int br_multicast_set_querier(struct net_bridge *br, unsigned long val);
 int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val);
+int br_multicast_set_igmp_version(struct net_bridge *br, unsigned long val);
 struct net_bridge_mdb_entry *
 br_mdb_ip_get(struct net_bridge_mdb_htable *mdb, struct br_ip *dst);
 struct net_bridge_mdb_entry *
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index e120307c6e36..f00d1690658c 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -440,6 +440,23 @@ static ssize_t hash_max_store(struct device *d, struct device_attribute *attr,
 }
 static DEVICE_ATTR_RW(hash_max);
 
+static ssize_t multicast_igmp_version_show(struct device *d,
+					   struct device_attribute *attr,
+					   char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+
+	return sprintf(buf, "%u\n", br->multicast_igmp_version);
+}
+
+static ssize_t multicast_igmp_version_store(struct device *d,
+					    struct device_attribute *attr,
+					    const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, br_multicast_set_igmp_version);
+}
+static DEVICE_ATTR_RW(multicast_igmp_version);
+
 static ssize_t multicast_last_member_count_show(struct device *d,
 						struct device_attribute *attr,
 						char *buf)
@@ -809,6 +826,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_multicast_query_response_interval.attr,
 	&dev_attr_multicast_startup_query_interval.attr,
 	&dev_attr_multicast_stats_enabled.attr,
+	&dev_attr_multicast_igmp_version.attr,
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	&dev_attr_nf_call_iptables.attr,
-- 
2.1.4
