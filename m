From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 3/5] bridge: vlan: move pvid inside net_bridge_vlan_group
Date: Wed, 30 Sep 2015 20:16:53 +0200
Message-ID: <1443637015-4153-4-git-send-email-razor@blackwall.org>
References: <1443637015-4153-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, vyasevich@gmail.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38695 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933107AbbI3SRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 14:17:04 -0400
Received: by wiclk2 with SMTP id lk2so74352046wic.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 11:17:02 -0700 (PDT)
In-Reply-To: <1443637015-4153-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

One obvious way to converge more code (which was also used by the
previous vlan code) is to move pvid inside net_bridge_vlan_group. This
allows us to simplify some and remove other port-specific functions.
Also gives us the ability to simply pass the vlan group and use all of the
contained information.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_device.c  |   2 +-
 net/bridge/br_input.c   |   2 +-
 net/bridge/br_netlink.c |  42 +++++++++-----------
 net/bridge/br_private.h |  44 ++++++---------------
 net/bridge/br_vlan.c    | 103 ++++++++++++++++++++----------------------------
 5 files changed, 75 insertions(+), 118 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index c915c5b408ea..bdfb9544ca03 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -56,7 +56,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
 
-	if (!br_allowed_ingress(br, skb, &vid))
+	if (!br_allowed_ingress(br, br_vlan_group(br), skb, &vid))
 		goto out;
 
 	if (is_broadcast_ether_addr(dest))
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index e27d0dfd2ee9..f5c5a4500e2f 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -140,7 +140,7 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
-	if (!nbp_allowed_ingress(p, skb, &vid))
+	if (!br_allowed_ingress(p->br, nbp_vlan_group(p), skb, &vid))
 		goto out;
 
 	/* insert into forwarding database after filtering to avoid spoofing */
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index bb8bb7b36f04..c64dcad11662 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -22,17 +22,17 @@
 #include "br_private_stp.h"
 
 static int __get_num_vlan_infos(struct net_bridge_vlan_group *vg,
-				u32 filter_mask,
-				u16 pvid)
+				u32 filter_mask)
 {
 	struct net_bridge_vlan *v;
 	u16 vid_range_start = 0, vid_range_end = 0, vid_range_flags = 0;
-	u16 flags;
+	u16 flags, pvid;
 	int num_vlans = 0;
 
 	if (!(filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED))
 		return 0;
 
+	pvid = br_get_pvid(vg);
 	/* Count number of vlan infos */
 	list_for_each_entry(v, &vg->vlan_list, vlist) {
 		flags = 0;
@@ -74,7 +74,7 @@ initvars:
 }
 
 static int br_get_num_vlan_infos(struct net_bridge_vlan_group *vg,
-				 u32 filter_mask, u16 pvid)
+				 u32 filter_mask)
 {
 	if (!vg)
 		return 0;
@@ -82,7 +82,7 @@ static int br_get_num_vlan_infos(struct net_bridge_vlan_group *vg,
 	if (filter_mask & RTEXT_FILTER_BRVLAN)
 		return vg->num_vlans;
 
-	return __get_num_vlan_infos(vg, filter_mask, pvid);
+	return __get_num_vlan_infos(vg, filter_mask);
 }
 
 static size_t br_get_link_af_size_filtered(const struct net_device *dev,
@@ -92,19 +92,16 @@ static size_t br_get_link_af_size_filtered(const struct net_device *dev,
 	struct net_bridge_port *p;
 	struct net_bridge *br;
 	int num_vlan_infos;
-	u16 pvid = 0;
 
 	rcu_read_lock();
 	if (br_port_exists(dev)) {
 		p = br_port_get_rcu(dev);
 		vg = nbp_vlan_group(p);
-		pvid = nbp_get_pvid(p);
 	} else if (dev->priv_flags & IFF_EBRIDGE) {
 		br = netdev_priv(dev);
 		vg = br_vlan_group(br);
-		pvid = br_get_pvid(br);
 	}
-	num_vlan_infos = br_get_num_vlan_infos(vg, filter_mask, pvid);
+	num_vlan_infos = br_get_num_vlan_infos(vg, filter_mask);
 	rcu_read_unlock();
 
 	/* Each VLAN is returned in bridge_vlan_info along with flags */
@@ -196,18 +193,18 @@ nla_put_failure:
 }
 
 static int br_fill_ifvlaninfo_compressed(struct sk_buff *skb,
-					 struct net_bridge_vlan_group *vg,
-					 u16 pvid)
+					 struct net_bridge_vlan_group *vg)
 {
 	struct net_bridge_vlan *v;
 	u16 vid_range_start = 0, vid_range_end = 0, vid_range_flags = 0;
-	u16 flags;
+	u16 flags, pvid;
 	int err = 0;
 
 	/* Pack IFLA_BRIDGE_VLAN_INFO's for every vlan
 	 * and mark vlan info with begin and end flags
 	 * if vlaninfo represents a range
 	 */
+	pvid = br_get_pvid(vg);
 	list_for_each_entry(v, &vg->vlan_list, vlist) {
 		flags = 0;
 		if (!br_vlan_should_use(v))
@@ -251,12 +248,13 @@ initvars:
 }
 
 static int br_fill_ifvlaninfo(struct sk_buff *skb,
-			      struct net_bridge_vlan_group *vg,
-			      u16 pvid)
+			      struct net_bridge_vlan_group *vg)
 {
 	struct bridge_vlan_info vinfo;
 	struct net_bridge_vlan *v;
+	u16 pvid;
 
+	pvid = br_get_pvid(vg);
 	list_for_each_entry(v, &vg->vlan_list, vlist) {
 		if (!br_vlan_should_use(v))
 			continue;
@@ -338,16 +336,12 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 	    (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)) {
 		struct net_bridge_vlan_group *vg;
 		struct nlattr *af;
-		u16 pvid;
 		int err;
 
-		if (port) {
+		if (port)
 			vg = nbp_vlan_group(port);
-			pvid = nbp_get_pvid(port);
-		} else {
+		else
 			vg = br_vlan_group(br);
-			pvid = br_get_pvid(br);
-		}
 
 		if (!vg || !vg->num_vlans)
 			goto done;
@@ -357,9 +351,9 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 			goto nla_put_failure;
 
 		if (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)
-			err = br_fill_ifvlaninfo_compressed(skb, vg, pvid);
+			err = br_fill_ifvlaninfo_compressed(skb, vg);
 		else
-			err = br_fill_ifvlaninfo(skb, vg, pvid);
+			err = br_fill_ifvlaninfo(skb, vg);
 		if (err)
 			goto nla_put_failure;
 		nla_nest_end(skb, af);
@@ -884,11 +878,11 @@ static size_t br_get_link_af_size(const struct net_device *dev)
 	if (br_port_exists(dev)) {
 		p = br_port_get_rtnl(dev);
 		num_vlans = br_get_num_vlan_infos(nbp_vlan_group(p),
-						  RTEXT_FILTER_BRVLAN, 0);
+						  RTEXT_FILTER_BRVLAN);
 	} else if (dev->priv_flags & IFF_EBRIDGE) {
 		br = netdev_priv(dev);
 		num_vlans = br_get_num_vlan_infos(br_vlan_group(br),
-						  RTEXT_FILTER_BRVLAN, 0);
+						  RTEXT_FILTER_BRVLAN);
 	}
 
 	/* Each VLAN is returned in bridge_vlan_info along with flags */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index cfe945f5ab8b..4ed8308db66e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -119,6 +119,7 @@ struct net_bridge_vlan {
  * @vlan_hash: VLAN entry rhashtable
  * @vlan_list: sorted VLAN entry list
  * @num_vlans: number of total VLAN entries
+ * @pvid: PVID VLAN id
  *
  * IMPORTANT: Be careful when checking if there're VLAN entries using list
  *            primitives because the bridge can have entries in its list which
@@ -130,6 +131,7 @@ struct net_bridge_vlan_group {
 	struct rhashtable		vlan_hash;
 	struct list_head		vlan_list;
 	u16				num_vlans;
+	u16				pvid;
 };
 
 struct net_bridge_fdb_entry
@@ -228,7 +230,6 @@ struct net_bridge_port
 #endif
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	struct net_bridge_vlan_group	*vlgrp;
-	u16				pvid;
 #endif
 };
 
@@ -340,7 +341,6 @@ struct net_bridge
 	u8				vlan_enabled;
 	__be16				vlan_proto;
 	u16				default_pvid;
-	u16				pvid;
 #endif
 };
 
@@ -670,10 +670,10 @@ static inline void br_mdb_uninit(void)
 
 /* br_vlan.c */
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-bool br_allowed_ingress(struct net_bridge *br, struct sk_buff *skb, u16 *vid);
-bool nbp_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb,
-			 u16 *vid);
-bool br_allowed_egress(struct net_bridge_vlan_group *br,
+bool br_allowed_ingress(const struct net_bridge *br,
+			struct net_bridge_vlan_group *vg, struct sk_buff *skb,
+			u16 *vid);
+bool br_allowed_egress(struct net_bridge_vlan_group *vg,
 		       const struct sk_buff *skb);
 bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid);
 struct sk_buff *br_handle_vlan(struct net_bridge *br,
@@ -725,22 +725,13 @@ static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *vid)
 	return err;
 }
 
-static inline u16 br_get_pvid(const struct net_bridge *br)
-{
-	if (!br)
-		return 0;
-
-	smp_rmb();
-	return br->pvid;
-}
-
-static inline u16 nbp_get_pvid(const struct net_bridge_port *p)
+static inline u16 br_get_pvid(const struct net_bridge_vlan_group *vg)
 {
-	if (!p)
+	if (!vg)
 		return 0;
 
 	smp_rmb();
-	return p->pvid;
+	return vg->pvid;
 }
 
 static inline int br_vlan_enabled(struct net_bridge *br)
@@ -748,20 +739,14 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 	return br->vlan_enabled;
 }
 #else
-static inline bool br_allowed_ingress(struct net_bridge *br,
+static inline bool br_allowed_ingress(const struct net_bridge *br,
+				      struct net_bridge_vlan_group *vg,
 				      struct sk_buff *skb,
 				      u16 *vid)
 {
 	return true;
 }
 
-static inline bool nbp_allowed_ingress(struct net_bridge_port *p,
-				       struct sk_buff *skb,
-				       u16 *vid)
-{
-	return true;
-}
-
 static inline bool br_allowed_egress(struct net_bridge_vlan_group *vg,
 				     const struct sk_buff *skb)
 {
@@ -834,12 +819,7 @@ static inline u16 br_vlan_get_tag(const struct sk_buff *skb, u16 *tag)
 	return 0;
 }
 
-static inline u16 br_get_pvid(const struct net_bridge *br)
-{
-	return 0;
-}
-
-static inline u16 nbp_get_pvid(const struct net_bridge_port *p)
+static inline u16 br_get_pvid(const struct net_bridge_vlan_group *vg)
 {
 	return 0;
 }
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 678d5c41b551..90ac4b0c55c1 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -31,37 +31,37 @@ static struct net_bridge_vlan *br_vlan_lookup(struct rhashtable *tbl, u16 vid)
 	return rhashtable_lookup_fast(tbl, &vid, br_vlan_rht_params);
 }
 
-static void __vlan_add_pvid(u16 *pvid, u16 vid)
+static void __vlan_add_pvid(struct net_bridge_vlan_group *vg, u16 vid)
 {
-	if (*pvid == vid)
+	if (vg->pvid == vid)
 		return;
 
 	smp_wmb();
-	*pvid = vid;
+	vg->pvid = vid;
 }
 
-static void __vlan_delete_pvid(u16 *pvid, u16 vid)
+static void __vlan_delete_pvid(struct net_bridge_vlan_group *vg, u16 vid)
 {
-	if (*pvid != vid)
+	if (vg->pvid != vid)
 		return;
 
 	smp_wmb();
-	*pvid = 0;
+	vg->pvid = 0;
 }
 
 static void __vlan_add_flags(struct net_bridge_vlan *v, u16 flags)
 {
-	if (flags & BRIDGE_VLAN_INFO_PVID) {
-		if (br_vlan_is_master(v))
-			__vlan_add_pvid(&v->br->pvid, v->vid);
-		else
-			__vlan_add_pvid(&v->port->pvid, v->vid);
-	} else {
-		if (br_vlan_is_master(v))
-			__vlan_delete_pvid(&v->br->pvid, v->vid);
-		else
-			__vlan_delete_pvid(&v->port->pvid, v->vid);
-	}
+	struct net_bridge_vlan_group *vg;
+
+	if (br_vlan_is_master(v))
+		vg = v->br->vlgrp;
+	else
+		vg = v->port->vlgrp;
+
+	if (flags & BRIDGE_VLAN_INFO_PVID)
+		__vlan_add_pvid(vg, v->vid);
+	else
+		__vlan_delete_pvid(vg, v->vid);
 
 	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
 		v->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
@@ -249,25 +249,22 @@ out_filt:
 static int __vlan_del(struct net_bridge_vlan *v)
 {
 	struct net_bridge_vlan *masterv = v;
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge_port *p = NULL;
 	struct net_bridge *br;
 	int err = 0;
-	struct rhashtable *tbl;
-	u16 *pvid;
 
 	if (br_vlan_is_master(v)) {
 		br = v->br;
-		tbl = &v->br->vlgrp->vlan_hash;
-		pvid = &v->br->pvid;
+		vg = v->br->vlgrp;
 	} else {
 		p = v->port;
 		br = p->br;
-		tbl = &p->vlgrp->vlan_hash;
+		vg = v->port->vlgrp;
 		masterv = v->brvlan;
-		pvid = &p->pvid;
 	}
 
-	__vlan_delete_pvid(pvid, v->vid);
+	__vlan_delete_pvid(vg, v->vid);
 	if (p) {
 		err = __vlan_vid_del(p->dev, p->br, v->vid);
 		if (err)
@@ -284,7 +281,8 @@ static int __vlan_del(struct net_bridge_vlan *v)
 	}
 
 	if (masterv != v) {
-		rhashtable_remove_fast(tbl, &v->vnode, br_vlan_rht_params);
+		rhashtable_remove_fast(&vg->vlan_hash, &v->vnode,
+				       br_vlan_rht_params);
 		__vlan_del_list(v);
 		kfree_rcu(v, rcu);
 	}
@@ -299,11 +297,11 @@ out:
 	return err;
 }
 
-static void __vlan_flush(struct net_bridge_vlan_group *vlgrp, u16 *pvid)
+static void __vlan_flush(struct net_bridge_vlan_group *vlgrp)
 {
 	struct net_bridge_vlan *vlan, *tmp;
 
-	__vlan_delete_pvid(pvid, *pvid);
+	__vlan_delete_pvid(vlgrp, vlgrp->pvid);
 	list_for_each_entry_safe(vlan, tmp, &vlgrp->vlan_list, vlist)
 		__vlan_del(vlan);
 	rhashtable_destroy(&vlgrp->vlan_hash);
@@ -348,7 +346,7 @@ out:
 }
 
 /* Called under RCU */
-static bool __allowed_ingress(struct rhashtable *tbl, u16 pvid, __be16 proto,
+static bool __allowed_ingress(struct net_bridge_vlan_group *vg, __be16 proto,
 			      struct sk_buff *skb, u16 *vid)
 {
 	const struct net_bridge_vlan *v;
@@ -389,6 +387,8 @@ static bool __allowed_ingress(struct rhashtable *tbl, u16 pvid, __be16 proto,
 	}
 
 	if (!*vid) {
+		u16 pvid = br_get_pvid(vg);
+
 		/* Frame had a tag with VID 0 or did not have a tag.
 		 * See if pvid is set on this port.  That tells us which
 		 * vlan untagged or priority-tagged traffic belongs to.
@@ -415,7 +415,7 @@ static bool __allowed_ingress(struct rhashtable *tbl, u16 pvid, __be16 proto,
 	}
 
 	/* Frame had a valid vlan tag.  See if vlan is allowed */
-	v = br_vlan_lookup(tbl, *vid);
+	v = br_vlan_find(vg, *vid);
 	if (v && br_vlan_should_use(v))
 		return true;
 drop:
@@ -423,7 +423,9 @@ drop:
 	return false;
 }
 
-bool br_allowed_ingress(struct net_bridge *br, struct sk_buff *skb, u16 *vid)
+bool br_allowed_ingress(const struct net_bridge *br,
+			struct net_bridge_vlan_group *vg, struct sk_buff *skb,
+			u16 *vid)
 {
 	/* If VLAN filtering is disabled on the bridge, all packets are
 	 * permitted.
@@ -433,25 +435,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct sk_buff *skb, u16 *vid)
 		return true;
 	}
 
-	return __allowed_ingress(&br->vlgrp->vlan_hash, br->pvid,
-				 br->vlan_proto, skb, vid);
-}
-
-bool nbp_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb,
-			 u16 *vid)
-{
-	struct net_bridge *br = p->br;
-
-	/* If VLAN filtering is disabled on the bridge, all packets are
-	 * permitted.
-	 */
-	if (!br->vlan_enabled) {
-		BR_INPUT_SKB_CB(skb)->vlan_filtered = false;
-		return true;
-	}
-
-	return __allowed_ingress(&p->vlgrp->vlan_hash, p->pvid, br->vlan_proto,
-				 skb, vid);
+	return __allowed_ingress(vg, br->vlan_proto, skb, vid);
 }
 
 /* Called under RCU. */
@@ -491,14 +475,14 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
 		*vid = 0;
 
 	if (!*vid) {
-		*vid = nbp_get_pvid(p);
+		*vid = br_get_pvid(vg);
 		if (!*vid)
 			return false;
 
 		return true;
 	}
 
-	if (br_vlan_find(p->vlgrp, *vid))
+	if (br_vlan_find(vg, *vid))
 		return true;
 
 	return false;
@@ -574,7 +558,7 @@ void br_vlan_flush(struct net_bridge *br)
 {
 	ASSERT_RTNL();
 
-	__vlan_flush(br_vlan_group(br), &br->pvid);
+	__vlan_flush(br_vlan_group(br));
 }
 
 struct net_bridge_vlan *br_vlan_find(struct net_bridge_vlan_group *vg, u16 vid)
@@ -695,12 +679,11 @@ int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
 	return err;
 }
 
-static bool vlan_default_pvid(struct net_bridge_vlan_group *vg, u16 pvid,
-			      u16 vid)
+static bool vlan_default_pvid(struct net_bridge_vlan_group *vg, u16 vid)
 {
 	struct net_bridge_vlan *v;
 
-	if (vid != pvid)
+	if (vid != vg->pvid)
 		return false;
 
 	v = br_vlan_lookup(&vg->vlan_hash, vid);
@@ -719,11 +702,11 @@ static void br_vlan_disable_default_pvid(struct net_bridge *br)
 	/* Disable default_pvid on all ports where it is still
 	 * configured.
 	 */
-	if (vlan_default_pvid(br->vlgrp, br->pvid, pvid))
+	if (vlan_default_pvid(br->vlgrp, pvid))
 		br_vlan_delete(br, pvid);
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (vlan_default_pvid(p->vlgrp, p->pvid, pvid))
+		if (vlan_default_pvid(p->vlgrp, pvid))
 			nbp_vlan_delete(p, pvid);
 	}
 
@@ -749,7 +732,7 @@ static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 	 * user configuration.
 	 */
 	pvent = br_vlan_find(br->vlgrp, pvid);
-	if ((!old_pvid || vlan_default_pvid(br->vlgrp, br->pvid, old_pvid)) &&
+	if ((!old_pvid || vlan_default_pvid(br->vlgrp, old_pvid)) &&
 	    (!pvent || !br_vlan_should_use(pvent))) {
 		err = br_vlan_add(br, pvid,
 				  BRIDGE_VLAN_INFO_PVID |
@@ -766,7 +749,7 @@ static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 		 * user configuration.
 		 */
 		if ((old_pvid &&
-		     !vlan_default_pvid(p->vlgrp, p->pvid, old_pvid)) ||
+		     !vlan_default_pvid(p->vlgrp, old_pvid)) ||
 		    br_vlan_find(p->vlgrp, pvid))
 			continue;
 
@@ -955,5 +938,5 @@ void nbp_vlan_flush(struct net_bridge_port *port)
 	list_for_each_entry(vlan, &port->vlgrp->vlan_list, vlist)
 		vlan_vid_del(port->dev, port->br->vlan_proto, vlan->vid);
 
-	__vlan_flush(nbp_vlan_group(port), &port->pvid);
+	__vlan_flush(nbp_vlan_group(port));
 }
-- 
2.4.3
