From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v3 3/4] bridge: vlan: learn to count
Date: Sat, 30 Apr 2016 10:25:28 +0200
Message-ID: <1462004729-12185-4-git-send-email-nikolay@cumulusnetworks.com>
References: <1462004729-12185-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37444 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbcD3IZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 04:25:46 -0400
Received: by mail-wm0-f52.google.com with SMTP id a17so69060176wme.0
        for <netdev@vger.kernel.org>; Sat, 30 Apr 2016 01:25:45 -0700 (PDT)
In-Reply-To: <1462004729-12185-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for per-VLAN Tx/Rx statistics. Every global vlan context gets
allocated a per-cpu stats which is then set in each per-port vlan context
for quick access. The br_allowed_ingress() common function is used to
account for Rx packets and the br_handle_vlan() common function is used
to account for Tx packets. Stats accounting is performed only if the
bridge-wide vlan_stats_enabled option is set either via sysfs or netlink.
A struct hole between vlan_enabled and vlan_proto is used for the new
option so it is in the same cache line. Currently it is binary (on/off)
but it is intentionally restricted to exactly 0 and 1 since other values
will be used in the future for different purposes (e.g. per-port stats).

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v3: make stats accounting optional with default to off
v2: no change

 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 13 ++++++-
 net/bridge/br_private.h      | 13 ++++++-
 net/bridge/br_sysfs_br.c     | 17 +++++++++
 net/bridge/br_vlan.c         | 82 ++++++++++++++++++++++++++++++++++++--------
 5 files changed, 110 insertions(+), 16 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8577c0e4116f..cc50261baf59 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -272,6 +272,7 @@ enum {
 	IFLA_BR_NF_CALL_ARPTABLES,
 	IFLA_BR_VLAN_DEFAULT_PVID,
 	IFLA_BR_PAD,
+	IFLA_BR_VLAN_STATS_ENABLED,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 6bae1125e36d..7fba1f018bc9 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -850,6 +850,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_NF_CALL_IP6TABLES] = { .type = NLA_U8 },
 	[IFLA_BR_NF_CALL_ARPTABLES] = { .type = NLA_U8 },
 	[IFLA_BR_VLAN_DEFAULT_PVID] = { .type = NLA_U16 },
+	[IFLA_BR_VLAN_STATS_ENABLED] = { .type = NLA_U8 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -921,6 +922,14 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 		if (err)
 			return err;
 	}
+
+	if (data[IFLA_BR_VLAN_STATS_ENABLED]) {
+		__u8 vlan_stats = nla_get_u8(data[IFLA_BR_VLAN_STATS_ENABLED]);
+
+		err = br_vlan_set_stats(br, vlan_stats);
+		if (err)
+			return err;
+	}
 #endif
 
 	if (data[IFLA_BR_GROUP_FWD_MASK]) {
@@ -1082,6 +1091,7 @@ static size_t br_get_size(const struct net_device *brdev)
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	       nla_total_size(sizeof(__be16)) +	/* IFLA_BR_VLAN_PROTOCOL */
 	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_VLAN_DEFAULT_PVID */
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_VLAN_STATS_ENABLED */
 #endif
 	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_GROUP_FWD_MASK */
 	       nla_total_size(sizeof(struct ifla_bridge_id)) +   /* IFLA_BR_ROOT_ID */
@@ -1167,7 +1177,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	if (nla_put_be16(skb, IFLA_BR_VLAN_PROTOCOL, br->vlan_proto) ||
-	    nla_put_u16(skb, IFLA_BR_VLAN_DEFAULT_PVID, br->default_pvid))
+	    nla_put_u16(skb, IFLA_BR_VLAN_DEFAULT_PVID, br->default_pvid) ||
+	    nla_put_u8(skb, IFLA_BR_VLAN_STATS_ENABLED, br->vlan_stats_enabled))
 		return -EMSGSIZE;
 #endif
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1b5d145dfcbf..8b644069a1a1 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -77,12 +77,21 @@ struct bridge_mcast_querier {
 };
 #endif
 
+struct br_vlan_stats {
+	u64 rx_bytes;
+	u64 rx_packets;
+	u64 tx_bytes;
+	u64 tx_packets;
+	struct u64_stats_sync syncp;
+};
+
 /**
  * struct net_bridge_vlan - per-vlan entry
  *
  * @vnode: rhashtable member
  * @vid: VLAN id
  * @flags: bridge vlan flags
+ * @stats: per-cpu VLAN statistics
  * @br: if MASTER flag set, this points to a bridge struct
  * @port: if MASTER flag unset, this points to a port struct
  * @refcnt: if MASTER flag set, this is bumped for each port referencing it
@@ -100,6 +109,7 @@ struct net_bridge_vlan {
 	struct rhash_head		vnode;
 	u16				vid;
 	u16				flags;
+	struct br_vlan_stats __percpu	*stats;
 	union {
 		struct net_bridge	*br;
 		struct net_bridge_port	*port;
@@ -342,6 +352,7 @@ struct net_bridge
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	struct net_bridge_vlan_group	__rcu *vlgrp;
 	u8				vlan_enabled;
+	u8				vlan_stats_enabled;
 	__be16				vlan_proto;
 	u16				default_pvid;
 #endif
@@ -691,6 +702,7 @@ int __br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
 int __br_vlan_set_proto(struct net_bridge *br, __be16 proto);
 int br_vlan_set_proto(struct net_bridge *br, unsigned long val);
+int br_vlan_set_stats(struct net_bridge *br, unsigned long val);
 int br_vlan_init(struct net_bridge *br);
 int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val);
 int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid);
@@ -880,7 +892,6 @@ static inline struct net_bridge_vlan_group *nbp_vlan_group_rcu(
 {
 	return NULL;
 }
-
 #endif
 
 struct nf_br_ops {
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 70bddfd0f3e9..beb47071e38d 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -731,6 +731,22 @@ static ssize_t default_pvid_store(struct device *d,
 	return store_bridge_parm(d, buf, len, br_vlan_set_default_pvid);
 }
 static DEVICE_ATTR_RW(default_pvid);
+
+static ssize_t vlan_stats_enabled_show(struct device *d,
+				       struct device_attribute *attr,
+				       char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%u\n", br->vlan_stats_enabled);
+}
+
+static ssize_t vlan_stats_enabled_store(struct device *d,
+					struct device_attribute *attr,
+					const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, br_vlan_set_stats);
+}
+static DEVICE_ATTR_RW(vlan_stats_enabled);
 #endif
 
 static struct attribute *bridge_attrs[] = {
@@ -778,6 +794,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_vlan_filtering.attr,
 	&dev_attr_vlan_protocol.attr,
 	&dev_attr_default_pvid.attr,
+	&dev_attr_vlan_stats_enabled.attr,
 #endif
 	NULL
 };
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index e001152d6ad1..065c35351356 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -162,6 +162,17 @@ static struct net_bridge_vlan *br_vlan_get_master(struct net_bridge *br, u16 vid
 	return masterv;
 }
 
+static void br_master_vlan_rcu_free(struct rcu_head *rcu)
+{
+	struct net_bridge_vlan *v;
+
+	v = container_of(rcu, struct net_bridge_vlan, rcu);
+	WARN_ON(!br_vlan_is_master(v));
+	free_percpu(v->stats);
+	v->stats = NULL;
+	kfree(v);
+}
+
 static void br_vlan_put_master(struct net_bridge_vlan *masterv)
 {
 	struct net_bridge_vlan_group *vg;
@@ -174,7 +185,7 @@ static void br_vlan_put_master(struct net_bridge_vlan *masterv)
 		rhashtable_remove_fast(&vg->vlan_hash,
 				       &masterv->vnode, br_vlan_rht_params);
 		__vlan_del_list(masterv);
-		kfree_rcu(masterv, rcu);
+		call_rcu(&masterv->rcu, br_master_vlan_rcu_free);
 	}
 }
 
@@ -230,6 +241,7 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 		if (!masterv)
 			goto out_filt;
 		v->brvlan = masterv;
+		v->stats = masterv->stats;
 	}
 
 	/* Add the dev mac and count the vlan only if it's usable */
@@ -329,6 +341,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 			       struct net_bridge_vlan_group *vg,
 			       struct sk_buff *skb)
 {
+	struct br_vlan_stats *stats;
 	struct net_bridge_vlan *v;
 	u16 vid;
 
@@ -355,18 +368,27 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 			return NULL;
 		}
 	}
+	if (br->vlan_stats_enabled) {
+		stats = this_cpu_ptr(v->stats);
+		u64_stats_update_begin(&stats->syncp);
+		stats->tx_bytes += skb->len;
+		stats->tx_packets++;
+		u64_stats_update_end(&stats->syncp);
+	}
+
 	if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
 		skb->vlan_tci = 0;
-
 out:
 	return skb;
 }
 
 /* Called under RCU */
-static bool __allowed_ingress(struct net_bridge_vlan_group *vg, __be16 proto,
+static bool __allowed_ingress(const struct net_bridge *br,
+			      struct net_bridge_vlan_group *vg,
 			      struct sk_buff *skb, u16 *vid)
 {
-	const struct net_bridge_vlan *v;
+	struct br_vlan_stats *stats;
+	struct net_bridge_vlan *v;
 	bool tagged;
 
 	BR_INPUT_SKB_CB(skb)->vlan_filtered = true;
@@ -375,7 +397,7 @@ static bool __allowed_ingress(struct net_bridge_vlan_group *vg, __be16 proto,
 	 * HW accelerated vlan tag.
 	 */
 	if (unlikely(!skb_vlan_tag_present(skb) &&
-		     skb->protocol == proto)) {
+		     skb->protocol == br->vlan_proto)) {
 		skb = skb_vlan_untag(skb);
 		if (unlikely(!skb))
 			return false;
@@ -383,7 +405,7 @@ static bool __allowed_ingress(struct net_bridge_vlan_group *vg, __be16 proto,
 
 	if (!br_vlan_get_tag(skb, vid)) {
 		/* Tagged frame */
-		if (skb->vlan_proto != proto) {
+		if (skb->vlan_proto != br->vlan_proto) {
 			/* Protocol-mismatch, empty out vlan_tci for new tag */
 			skb_push(skb, ETH_HLEN);
 			skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
@@ -419,7 +441,7 @@ static bool __allowed_ingress(struct net_bridge_vlan_group *vg, __be16 proto,
 		*vid = pvid;
 		if (likely(!tagged))
 			/* Untagged Frame. */
-			__vlan_hwaccel_put_tag(skb, proto, pvid);
+			__vlan_hwaccel_put_tag(skb, br->vlan_proto, pvid);
 		else
 			/* Priority-tagged Frame.
 			 * At this point, We know that skb->vlan_tci had
@@ -428,13 +450,24 @@ static bool __allowed_ingress(struct net_bridge_vlan_group *vg, __be16 proto,
 			 */
 			skb->vlan_tci |= pvid;
 
-		return true;
+		/* if stats are disabled we can avoid the lookup */
+		if (!br->vlan_stats_enabled)
+			return true;
 	}
-
-	/* Frame had a valid vlan tag.  See if vlan is allowed */
 	v = br_vlan_find(vg, *vid);
-	if (v && br_vlan_should_use(v))
-		return true;
+	if (!v || !br_vlan_should_use(v))
+		goto drop;
+
+	if (br->vlan_stats_enabled) {
+		stats = this_cpu_ptr(v->stats);
+		u64_stats_update_begin(&stats->syncp);
+		stats->rx_bytes += skb->len;
+		stats->rx_packets++;
+		u64_stats_update_end(&stats->syncp);
+	}
+
+	return true;
+
 drop:
 	kfree_skb(skb);
 	return false;
@@ -452,7 +485,7 @@ bool br_allowed_ingress(const struct net_bridge *br,
 		return true;
 	}
 
-	return __allowed_ingress(vg, br->vlan_proto, skb, vid);
+	return __allowed_ingress(br, vg, skb, vid);
 }
 
 /* Called under RCU. */
@@ -542,6 +575,11 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 	if (!vlan)
 		return -ENOMEM;
 
+	vlan->stats = netdev_alloc_pcpu_stats(struct br_vlan_stats);
+	if (!vlan->stats) {
+		kfree(vlan);
+		return -ENOMEM;
+	}
 	vlan->vid = vid;
 	vlan->flags = flags | BRIDGE_VLAN_INFO_MASTER;
 	vlan->flags &= ~BRIDGE_VLAN_INFO_PVID;
@@ -549,8 +587,10 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 	if (flags & BRIDGE_VLAN_INFO_BRENTRY)
 		atomic_set(&vlan->refcnt, 1);
 	ret = __vlan_add(vlan, flags);
-	if (ret)
+	if (ret) {
+		free_percpu(vlan->stats);
 		kfree(vlan);
+	}
 
 	return ret;
 }
@@ -711,6 +751,20 @@ int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
 	return __br_vlan_set_proto(br, htons(val));
 }
 
+int br_vlan_set_stats(struct net_bridge *br, unsigned long val)
+{
+	switch (val) {
+	case 0:
+	case 1:
+		br->vlan_stats_enabled = val;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static bool vlan_default_pvid(struct net_bridge_vlan_group *vg, u16 vid)
 {
 	struct net_bridge_vlan *v;
-- 
2.4.11
