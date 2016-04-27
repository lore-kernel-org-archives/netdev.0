From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 5/7] bridge: vlan: RCUify pvid
Date: Wed, 27 Apr 2016 18:18:20 +0200
Message-ID: <1461773902-13528-6-git-send-email-nikolay@cumulusnetworks.com>
References: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, jhs@mojatatu.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38591 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbcD0QSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 12:18:37 -0400
Received: by mail-wm0-f52.google.com with SMTP id u206so57105606wme.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 09:18:36 -0700 (PDT)
In-Reply-To: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make pvid a pointer to a vlan struct and RCUify the access to it. Vlans
are already RCU-protected so the pvid vlan entry cannot disappear
without being initialized to NULL and going through a grace period first.
This change is necessary for the upcoming vlan counters and also would
serve to later move to vlan passing via a pointer instead of id.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_netlink.c | 23 ++++++++++-----------
 net/bridge/br_private.h | 16 +--------------
 net/bridge/br_vlan.c    | 54 +++++++++++++++++++++++--------------------------
 3 files changed, 37 insertions(+), 56 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e9c635eae24d..f33d95b0f5d3 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -24,22 +24,22 @@
 static int __get_num_vlan_infos(struct net_bridge_vlan_group *vg,
 				u32 filter_mask)
 {
-	struct net_bridge_vlan *v;
+	struct net_bridge_vlan *v, *pvid;
 	u16 vid_range_start = 0, vid_range_end = 0, vid_range_flags = 0;
-	u16 flags, pvid;
 	int num_vlans = 0;
+	u16 flags;
 
 	if (!(filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED))
 		return 0;
 
-	pvid = br_get_pvid(vg);
+	pvid = rcu_dereference(vg->pvid);
 	/* Count number of vlan infos */
 	list_for_each_entry_rcu(v, &vg->vlan_list, vlist) {
 		flags = 0;
 		/* only a context, bridge vlan not activated */
 		if (!br_vlan_should_use(v))
 			continue;
-		if (v->vid == pvid)
+		if (v == pvid)
 			flags |= BRIDGE_VLAN_INFO_PVID;
 
 		if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
@@ -243,21 +243,21 @@ nla_put_failure:
 static int br_fill_ifvlaninfo_compressed(struct sk_buff *skb,
 					 struct net_bridge_vlan_group *vg)
 {
-	struct net_bridge_vlan *v;
+	struct net_bridge_vlan *v, *pvid;
 	u16 vid_range_start = 0, vid_range_end = 0, vid_range_flags = 0;
-	u16 flags, pvid;
 	int err = 0;
+	u16 flags;
 
 	/* Pack IFLA_BRIDGE_VLAN_INFO's for every vlan
 	 * and mark vlan info with begin and end flags
 	 * if vlaninfo represents a range
 	 */
-	pvid = br_get_pvid(vg);
+	pvid = rcu_dereference(vg->pvid);
 	list_for_each_entry_rcu(v, &vg->vlan_list, vlist) {
 		flags = 0;
 		if (!br_vlan_should_use(v))
 			continue;
-		if (v->vid == pvid)
+		if (v == pvid)
 			flags |= BRIDGE_VLAN_INFO_PVID;
 
 		if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
@@ -298,18 +298,17 @@ initvars:
 static int br_fill_ifvlaninfo(struct sk_buff *skb,
 			      struct net_bridge_vlan_group *vg)
 {
+	struct net_bridge_vlan *v, *pvid;
 	struct bridge_vlan_info vinfo;
-	struct net_bridge_vlan *v;
-	u16 pvid;
 
-	pvid = br_get_pvid(vg);
+	pvid = rcu_dereference(vg->pvid);
 	list_for_each_entry_rcu(v, &vg->vlan_list, vlist) {
 		if (!br_vlan_should_use(v))
 			continue;
 
 		vinfo.vid = v->vid;
 		vinfo.flags = 0;
-		if (v->vid == pvid)
+		if (v == pvid)
 			vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
 
 		if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1b5d145dfcbf..50d70b5eb307 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -130,8 +130,8 @@ struct net_bridge_vlan {
 struct net_bridge_vlan_group {
 	struct rhashtable		vlan_hash;
 	struct list_head		vlan_list;
+	struct net_bridge_vlan __rcu	*pvid;
 	u16				num_vlans;
-	u16				pvid;
 };
 
 struct net_bridge_fdb_entry
@@ -741,15 +741,6 @@ static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *vid)
 	return err;
 }
 
-static inline u16 br_get_pvid(const struct net_bridge_vlan_group *vg)
-{
-	if (!vg)
-		return 0;
-
-	smp_rmb();
-	return vg->pvid;
-}
-
 static inline int br_vlan_enabled(struct net_bridge *br)
 {
 	return br->vlan_enabled;
@@ -835,11 +826,6 @@ static inline u16 br_vlan_get_tag(const struct sk_buff *skb, u16 *tag)
 	return 0;
 }
 
-static inline u16 br_get_pvid(const struct net_bridge_vlan_group *vg)
-{
-	return 0;
-}
-
 static inline int br_vlan_enabled(struct net_bridge *br)
 {
 	return 0;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index e001152d6ad1..4fab7665df8c 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -31,22 +31,11 @@ static struct net_bridge_vlan *br_vlan_lookup(struct rhashtable *tbl, u16 vid)
 	return rhashtable_lookup_fast(tbl, &vid, br_vlan_rht_params);
 }
 
-static void __vlan_add_pvid(struct net_bridge_vlan_group *vg, u16 vid)
+/* __vlan_delete_pvid is just __vlan_set_pvid(vg, NULL) */
+static void __vlan_set_pvid(struct net_bridge_vlan_group *vg,
+			    struct net_bridge_vlan *v)
 {
-	if (vg->pvid == vid)
-		return;
-
-	smp_wmb();
-	vg->pvid = vid;
-}
-
-static void __vlan_delete_pvid(struct net_bridge_vlan_group *vg, u16 vid)
-{
-	if (vg->pvid != vid)
-		return;
-
-	smp_wmb();
-	vg->pvid = 0;
+	rcu_assign_pointer(vg->pvid, v);
 }
 
 static void __vlan_add_flags(struct net_bridge_vlan *v, u16 flags)
@@ -59,9 +48,9 @@ static void __vlan_add_flags(struct net_bridge_vlan *v, u16 flags)
 		vg = nbp_vlan_group(v->port);
 
 	if (flags & BRIDGE_VLAN_INFO_PVID)
-		__vlan_add_pvid(vg, v->vid);
-	else
-		__vlan_delete_pvid(vg, v->vid);
+		__vlan_set_pvid(vg, v);
+	else if (rtnl_dereference(vg->pvid) == v)
+		__vlan_set_pvid(vg, NULL);
 
 	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
 		v->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
@@ -285,7 +274,9 @@ static int __vlan_del(struct net_bridge_vlan *v)
 		masterv = v->brvlan;
 	}
 
-	__vlan_delete_pvid(vg, v->vid);
+	if (rtnl_dereference(vg->pvid) == v)
+		__vlan_set_pvid(vg, NULL);
+
 	if (p) {
 		err = __vlan_vid_del(p->dev, p->br, v->vid);
 		if (err)
@@ -320,7 +311,7 @@ static void __vlan_flush(struct net_bridge_vlan_group *vg)
 {
 	struct net_bridge_vlan *vlan, *tmp;
 
-	__vlan_delete_pvid(vg, vg->pvid);
+	__vlan_set_pvid(vg, NULL);
 	list_for_each_entry_safe(vlan, tmp, &vg->vlan_list, vlist)
 		__vlan_del(vlan);
 }
@@ -404,29 +395,29 @@ static bool __allowed_ingress(struct net_bridge_vlan_group *vg, __be16 proto,
 	}
 
 	if (!*vid) {
-		u16 pvid = br_get_pvid(vg);
+		v = rcu_dereference(vg->pvid);
 
 		/* Frame had a tag with VID 0 or did not have a tag.
 		 * See if pvid is set on this port.  That tells us which
 		 * vlan untagged or priority-tagged traffic belongs to.
 		 */
-		if (!pvid)
+		if (!v)
 			goto drop;
 
 		/* PVID is set on this port.  Any untagged or priority-tagged
 		 * ingress frame is considered to belong to this vlan.
 		 */
-		*vid = pvid;
+		*vid = v->vid;
 		if (likely(!tagged))
 			/* Untagged Frame. */
-			__vlan_hwaccel_put_tag(skb, proto, pvid);
+			__vlan_hwaccel_put_tag(skb, proto, v->vid);
 		else
 			/* Priority-tagged Frame.
 			 * At this point, We know that skb->vlan_tci had
 			 * VLAN_TAG_PRESENT bit and its VID field was 0x000.
 			 * We update only VID field and preserve PCP field.
 			 */
-			skb->vlan_tci |= pvid;
+			skb->vlan_tci |= v->vid;
 
 		return true;
 	}
@@ -451,6 +442,9 @@ bool br_allowed_ingress(const struct net_bridge *br,
 		BR_INPUT_SKB_CB(skb)->vlan_filtered = false;
 		return true;
 	}
+	/* if there's no vlan_group, there's nothing to match against */
+	if (!vg)
+		return false;
 
 	return __allowed_ingress(vg, br->vlan_proto, skb, vid);
 }
@@ -492,9 +486,11 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
 		*vid = 0;
 
 	if (!*vid) {
-		*vid = br_get_pvid(vg);
-		if (!*vid)
+		struct net_bridge_vlan *v = rcu_dereference(vg->pvid);
+
+		if (!v)
 			return false;
+		*vid = v->vid;
 
 		return true;
 	}
@@ -713,9 +709,9 @@ int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
 
 static bool vlan_default_pvid(struct net_bridge_vlan_group *vg, u16 vid)
 {
-	struct net_bridge_vlan *v;
+	struct net_bridge_vlan *v = rtnl_dereference(vg->pvid);
 
-	if (vid != vg->pvid)
+	if (v && vid != v->vid)
 		return false;
 
 	v = br_vlan_lookup(&vg->vlan_hash, vid);
-- 
2.4.11
