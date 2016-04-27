From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 6/7] bridge: vlan: learn to count
Date: Wed, 27 Apr 2016 18:18:21 +0200
Message-ID: <1461773902-13528-7-git-send-email-nikolay@cumulusnetworks.com>
References: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, jhs@mojatatu.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35641 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbcD0QSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 12:18:39 -0400
Received: by mail-wm0-f50.google.com with SMTP id e201so46302821wme.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 09:18:38 -0700 (PDT)
In-Reply-To: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for per-VLAN Tx/Rx statistics. Every global vlan context gets
allocated a per-cpu stats which is then set in each per-port vlan context
for quick access. The br_allowed_ingress() common function is used to
account for Rx packets and the br_handle_vlan() common function is used
to account for Tx packets.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
Note: maybe in the future it'd be better to rename br_allowed_ingress to
br_vlan_ingress() or something similar as it's not doing only checks.

 net/bridge/br_private.h | 11 +++++++++-
 net/bridge/br_vlan.c    | 53 +++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 53 insertions(+), 11 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 50d70b5eb307..f6876ed718a5 100644
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
@@ -866,7 +876,6 @@ static inline struct net_bridge_vlan_group *nbp_vlan_group_rcu(
 {
 	return NULL;
 }
-
 #endif
 
 struct nf_br_ops {
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 4fab7665df8c..d7a70c2ea3ec 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -151,6 +151,17 @@ static struct net_bridge_vlan *br_vlan_get_master(struct net_bridge *br, u16 vid
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
@@ -163,7 +174,7 @@ static void br_vlan_put_master(struct net_bridge_vlan *masterv)
 		rhashtable_remove_fast(&vg->vlan_hash,
 				       &masterv->vnode, br_vlan_rht_params);
 		__vlan_del_list(masterv);
-		kfree_rcu(masterv, rcu);
+		call_rcu(&masterv->rcu, br_master_vlan_rcu_free);
 	}
 }
 
@@ -219,6 +230,7 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 		if (!masterv)
 			goto out_filt;
 		v->brvlan = masterv;
+		v->stats = masterv->stats;
 	}
 
 	/* Add the dev mac and count the vlan only if it's usable */
@@ -320,6 +332,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 			       struct net_bridge_vlan_group *vg,
 			       struct sk_buff *skb)
 {
+	struct br_vlan_stats *stats;
 	struct net_bridge_vlan *v;
 	u16 vid;
 
@@ -346,9 +359,14 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 			return NULL;
 		}
 	}
+	stats = this_cpu_ptr(v->stats);
+	u64_stats_update_begin(&stats->syncp);
+	stats->tx_bytes += skb->len;
+	stats->tx_packets++;
+	u64_stats_update_end(&stats->syncp);
+
 	if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
 		skb->vlan_tci = 0;
-
 out:
 	return skb;
 }
@@ -357,7 +375,8 @@ out:
 static bool __allowed_ingress(struct net_bridge_vlan_group *vg, __be16 proto,
 			      struct sk_buff *skb, u16 *vid)
 {
-	const struct net_bridge_vlan *v;
+	struct br_vlan_stats *stats;
+	struct net_bridge_vlan *v;
 	bool tagged;
 
 	BR_INPUT_SKB_CB(skb)->vlan_filtered = true;
@@ -418,14 +437,21 @@ static bool __allowed_ingress(struct net_bridge_vlan_group *vg, __be16 proto,
 			 * We update only VID field and preserve PCP field.
 			 */
 			skb->vlan_tci |= v->vid;
-
-		return true;
+	} else {
+		/* Frame had a valid vlan tag.  See if vlan is allowed */
+		v = br_vlan_find(vg, *vid);
 	}
+	if (!v || !br_vlan_should_use(v))
+		goto drop;
+
+	stats = this_cpu_ptr(v->stats);
+	u64_stats_update_begin(&stats->syncp);
+	stats->rx_bytes += skb->len;
+	stats->rx_packets++;
+	u64_stats_update_end(&stats->syncp);
+
+	return true;
 
-	/* Frame had a valid vlan tag.  See if vlan is allowed */
-	v = br_vlan_find(vg, *vid);
-	if (v && br_vlan_should_use(v))
-		return true;
 drop:
 	kfree_skb(skb);
 	return false;
@@ -538,6 +564,11 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
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
@@ -545,8 +576,10 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
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
-- 
2.4.11
