From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v2 1/4] bridge: vlan: use proper rcu for the vlgrp member
Date: Mon, 12 Oct 2015 21:47:02 +0200
Message-ID: <1444679225-7354-2-git-send-email-razor@blackwall.org>
References: <1444679225-7354-1-git-send-email-razor@blackwall.org>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, idosch@mellanox.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33655 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790AbbJLTrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 15:47:11 -0400
Received: by wicge5 with SMTP id ge5so30418104wic.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 12:47:09 -0700 (PDT)
In-Reply-To: <1444679225-7354-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

The bridge and port's vlgrp member is already used in RCU way, currently
we rely on the fact that it cannot disappear while the port exists but
that is error-prone and we might miss places with improper locking
(either RCU or RTNL must be held to walk the vlan_list). So make it
official and use RCU for vlgrp to catch offenders. Introduce proper vlgrp
accessors and use them consistently throughout the code.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: changed sizeof(struct ...) to sizeof(*vg) as per Ido's comment

 net/bridge/br_device.c  |   2 +-
 net/bridge/br_forward.c |   6 +--
 net/bridge/br_input.c   |   4 +-
 net/bridge/br_netlink.c |   4 +-
 net/bridge/br_private.h |  34 +++++++++++++--
 net/bridge/br_vlan.c    | 107 +++++++++++++++++++++++++++++-------------------
 6 files changed, 104 insertions(+), 53 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index bdfb9544ca03..5e88d3e17546 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -56,7 +56,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
 
-	if (!br_allowed_ingress(br, br_vlan_group(br), skb, &vid))
+	if (!br_allowed_ingress(br, br_vlan_group_rcu(br), skb, &vid))
 		goto out;
 
 	if (is_broadcast_ether_addr(dest))
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 6d5ed795c3e2..a9d424e20229 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -32,7 +32,7 @@ static inline int should_deliver(const struct net_bridge_port *p,
 {
 	struct net_bridge_vlan_group *vg;
 
-	vg = nbp_vlan_group(p);
+	vg = nbp_vlan_group_rcu(p);
 	return ((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
 		br_allowed_egress(vg, skb) && p->state == BR_STATE_FORWARDING;
 }
@@ -80,7 +80,7 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
 	struct net_bridge_vlan_group *vg;
 
-	vg = nbp_vlan_group(to);
+	vg = nbp_vlan_group_rcu(to);
 	skb = br_handle_vlan(to->br, vg, skb);
 	if (!skb)
 		return;
@@ -112,7 +112,7 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 		return;
 	}
 
-	vg = nbp_vlan_group(to);
+	vg = nbp_vlan_group_rcu(to);
 	skb = br_handle_vlan(to->br, vg, skb);
 	if (!skb)
 		return;
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f5c5a4500e2f..f7fba74108a9 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -44,7 +44,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	brstats->rx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
-	vg = br_vlan_group(br);
+	vg = br_vlan_group_rcu(br);
 	/* Bridge is just like any other port.  Make sure the
 	 * packet is allowed except in promisc modue when someone
 	 * may be running packet capture.
@@ -140,7 +140,7 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
-	if (!br_allowed_ingress(p->br, nbp_vlan_group(p), skb, &vid))
+	if (!br_allowed_ingress(p->br, nbp_vlan_group_rcu(p), skb, &vid))
 		goto out;
 
 	/* insert into forwarding database after filtering to avoid spoofing */
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 544ab966d477..7723a5be6c18 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -102,10 +102,10 @@ static size_t br_get_link_af_size_filtered(const struct net_device *dev,
 	rcu_read_lock();
 	if (br_port_exists(dev)) {
 		p = br_port_get_rcu(dev);
-		vg = nbp_vlan_group(p);
+		vg = nbp_vlan_group_rcu(p);
 	} else if (dev->priv_flags & IFF_EBRIDGE) {
 		br = netdev_priv(dev);
-		vg = br_vlan_group(br);
+		vg = br_vlan_group_rcu(br);
 	}
 	num_vlan_infos = br_get_num_vlan_infos(vg, filter_mask);
 	rcu_read_unlock();
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index ba0c67b2159a..8835642a6326 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -132,6 +132,7 @@ struct net_bridge_vlan_group {
 	struct list_head		vlan_list;
 	u16				num_vlans;
 	u16				pvid;
+	struct rcu_head			rcu;
 };
 
 struct net_bridge_fdb_entry
@@ -229,7 +230,7 @@ struct net_bridge_port
 	struct netpoll			*np;
 #endif
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-	struct net_bridge_vlan_group	*vlgrp;
+	struct net_bridge_vlan_group	__rcu *vlgrp;
 #endif
 };
 
@@ -337,7 +338,7 @@ struct net_bridge
 	struct kobject			*ifobj;
 	u32				auto_cnt;
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-	struct net_bridge_vlan_group	*vlgrp;
+	struct net_bridge_vlan_group	__rcu *vlgrp;
 	u8				vlan_enabled;
 	__be16				vlan_proto;
 	u16				default_pvid;
@@ -700,13 +701,25 @@ int nbp_get_num_vlan_infos(struct net_bridge_port *p, u32 filter_mask);
 static inline struct net_bridge_vlan_group *br_vlan_group(
 					const struct net_bridge *br)
 {
-	return br->vlgrp;
+	return rtnl_dereference(br->vlgrp);
 }
 
 static inline struct net_bridge_vlan_group *nbp_vlan_group(
 					const struct net_bridge_port *p)
 {
-	return p->vlgrp;
+	return rtnl_dereference(p->vlgrp);
+}
+
+static inline struct net_bridge_vlan_group *br_vlan_group_rcu(
+					const struct net_bridge *br)
+{
+	return rcu_dereference(br->vlgrp);
+}
+
+static inline struct net_bridge_vlan_group *nbp_vlan_group_rcu(
+					const struct net_bridge_port *p)
+{
+	return rcu_dereference(p->vlgrp);
 }
 
 /* Since bridge now depends on 8021Q module, but the time bridge sees the
@@ -853,6 +866,19 @@ static inline struct net_bridge_vlan_group *nbp_vlan_group(
 {
 	return NULL;
 }
+
+static inline struct net_bridge_vlan_group *br_vlan_group_rcu(
+					const struct net_bridge *br)
+{
+	return NULL;
+}
+
+static inline struct net_bridge_vlan_group *nbp_vlan_group_rcu(
+					const struct net_bridge_port *p)
+{
+	return NULL;
+}
+
 #endif
 
 struct nf_br_ops {
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 7a95e31f782f..4d8a21daf728 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -54,9 +54,9 @@ static void __vlan_add_flags(struct net_bridge_vlan *v, u16 flags)
 	struct net_bridge_vlan_group *vg;
 
 	if (br_vlan_is_master(v))
-		vg = v->br->vlgrp;
+		vg = br_vlan_group(v->br);
 	else
-		vg = v->port->vlgrp;
+		vg = nbp_vlan_group(v->port);
 
 	if (flags & BRIDGE_VLAN_INFO_PVID)
 		__vlan_add_pvid(vg, v->vid);
@@ -99,11 +99,16 @@ static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
 
 static void __vlan_add_list(struct net_bridge_vlan *v)
 {
+	struct net_bridge_vlan_group *vg;
 	struct list_head *headp, *hpos;
 	struct net_bridge_vlan *vent;
 
-	headp = br_vlan_is_master(v) ? &v->br->vlgrp->vlan_list :
-				       &v->port->vlgrp->vlan_list;
+	if (br_vlan_is_master(v))
+		vg = br_vlan_group(v->br);
+	else
+		vg = nbp_vlan_group(v->port);
+
+	headp = &vg->vlan_list;
 	list_for_each_prev(hpos, headp) {
 		vent = list_entry(hpos, struct net_bridge_vlan, vlist);
 		if (v->vid < vent->vid)
@@ -151,14 +156,16 @@ static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
  */
 static struct net_bridge_vlan *br_vlan_get_master(struct net_bridge *br, u16 vid)
 {
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge_vlan *masterv;
 
-	masterv = br_vlan_find(br->vlgrp, vid);
+	vg = br_vlan_group(br);
+	masterv = br_vlan_find(vg, vid);
 	if (!masterv) {
 		/* missing global ctx, create it now */
 		if (br_vlan_add(br, vid, 0))
 			return NULL;
-		masterv = br_vlan_find(br->vlgrp, vid);
+		masterv = br_vlan_find(vg, vid);
 		if (WARN_ON(!masterv))
 			return NULL;
 	}
@@ -169,11 +176,14 @@ static struct net_bridge_vlan *br_vlan_get_master(struct net_bridge *br, u16 vid
 
 static void br_vlan_put_master(struct net_bridge_vlan *masterv)
 {
+	struct net_bridge_vlan_group *vg;
+
 	if (!br_vlan_is_master(masterv))
 		return;
 
+	vg = br_vlan_group(masterv->br);
 	if (atomic_dec_and_test(&masterv->refcnt)) {
-		rhashtable_remove_fast(&masterv->br->vlgrp->vlan_hash,
+		rhashtable_remove_fast(&vg->vlan_hash,
 				       &masterv->vnode, br_vlan_rht_params);
 		__vlan_del_list(masterv);
 		kfree_rcu(masterv, rcu);
@@ -203,12 +213,12 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 	if (br_vlan_is_master(v)) {
 		br = v->br;
 		dev = br->dev;
-		vg = br->vlgrp;
+		vg = br_vlan_group(br);
 	} else {
 		p = v->port;
 		br = p->br;
 		dev = p->dev;
-		vg = p->vlgrp;
+		vg = nbp_vlan_group(p);
 	}
 
 	if (p) {
@@ -280,10 +290,10 @@ static int __vlan_del(struct net_bridge_vlan *v)
 	int err = 0;
 
 	if (br_vlan_is_master(v)) {
-		vg = v->br->vlgrp;
+		vg = br_vlan_group(v->br);
 	} else {
 		p = v->port;
-		vg = v->port->vlgrp;
+		vg = nbp_vlan_group(v->port);
 		masterv = v->brvlan;
 	}
 
@@ -319,7 +329,7 @@ static void __vlan_flush(struct net_bridge_vlan_group *vlgrp)
 	list_for_each_entry_safe(vlan, tmp, &vlgrp->vlan_list, vlist)
 		__vlan_del(vlan);
 	rhashtable_destroy(&vlgrp->vlan_hash);
-	kfree(vlgrp);
+	kfree_rcu(vlgrp, rcu);
 }
 
 struct sk_buff *br_handle_vlan(struct net_bridge *br,
@@ -481,7 +491,7 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
 	if (!br->vlan_enabled)
 		return true;
 
-	vg = p->vlgrp;
+	vg = nbp_vlan_group(p);
 	if (!vg || !vg->num_vlans)
 		return false;
 
@@ -507,12 +517,14 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
  */
 int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 {
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge_vlan *vlan;
 	int ret;
 
 	ASSERT_RTNL();
 
-	vlan = br_vlan_find(br->vlgrp, vid);
+	vg = br_vlan_group(br);
+	vlan = br_vlan_find(vg, vid);
 	if (vlan) {
 		if (!br_vlan_is_brentry(vlan)) {
 			/* Trying to change flags of non-existent bridge vlan */
@@ -527,7 +539,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 			}
 			atomic_inc(&vlan->refcnt);
 			vlan->flags |= BRIDGE_VLAN_INFO_BRENTRY;
-			br->vlgrp->num_vlans++;
+			vg->num_vlans++;
 		}
 		__vlan_add_flags(vlan, flags);
 		return 0;
@@ -555,11 +567,13 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
  */
 int br_vlan_delete(struct net_bridge *br, u16 vid)
 {
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge_vlan *v;
 
 	ASSERT_RTNL();
 
-	v = br_vlan_find(br->vlgrp, vid);
+	vg = br_vlan_group(br);
+	v = br_vlan_find(vg, vid);
 	if (!v || !br_vlan_is_brentry(v))
 		return -ENOENT;
 
@@ -640,6 +654,7 @@ int __br_vlan_set_proto(struct net_bridge *br, __be16 proto)
 	int err = 0;
 	struct net_bridge_port *p;
 	struct net_bridge_vlan *vlan;
+	struct net_bridge_vlan_group *vg;
 	__be16 oldproto;
 
 	if (br->vlan_proto == proto)
@@ -647,7 +662,8 @@ int __br_vlan_set_proto(struct net_bridge *br, __be16 proto)
 
 	/* Add VLANs for the new proto to the device filter. */
 	list_for_each_entry(p, &br->port_list, list) {
-		list_for_each_entry(vlan, &p->vlgrp->vlan_list, vlist) {
+		vg = nbp_vlan_group(p);
+		list_for_each_entry(vlan, &vg->vlan_list, vlist) {
 			err = vlan_vid_add(p->dev, proto, vlan->vid);
 			if (err)
 				goto err_filt;
@@ -661,19 +677,23 @@ int __br_vlan_set_proto(struct net_bridge *br, __be16 proto)
 	br_recalculate_fwd_mask(br);
 
 	/* Delete VLANs for the old proto from the device filter. */
-	list_for_each_entry(p, &br->port_list, list)
-		list_for_each_entry(vlan, &p->vlgrp->vlan_list, vlist)
+	list_for_each_entry(p, &br->port_list, list) {
+		vg = nbp_vlan_group(p);
+		list_for_each_entry(vlan, &vg->vlan_list, vlist)
 			vlan_vid_del(p->dev, oldproto, vlan->vid);
+	}
 
 	return 0;
 
 err_filt:
-	list_for_each_entry_continue_reverse(vlan, &p->vlgrp->vlan_list, vlist)
+	list_for_each_entry_continue_reverse(vlan, &vg->vlan_list, vlist)
 		vlan_vid_del(p->dev, proto, vlan->vid);
 
-	list_for_each_entry_continue_reverse(p, &br->port_list, list)
-		list_for_each_entry(vlan, &p->vlgrp->vlan_list, vlist)
+	list_for_each_entry_continue_reverse(p, &br->port_list, list) {
+		vg = nbp_vlan_group(p);
+		list_for_each_entry(vlan, &vg->vlan_list, vlist)
 			vlan_vid_del(p->dev, proto, vlan->vid);
+	}
 
 	return err;
 }
@@ -717,11 +737,11 @@ static void br_vlan_disable_default_pvid(struct net_bridge *br)
 	/* Disable default_pvid on all ports where it is still
 	 * configured.
 	 */
-	if (vlan_default_pvid(br->vlgrp, pvid))
+	if (vlan_default_pvid(br_vlan_group(br), pvid))
 		br_vlan_delete(br, pvid);
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (vlan_default_pvid(p->vlgrp, pvid))
+		if (vlan_default_pvid(nbp_vlan_group(p), pvid))
 			nbp_vlan_delete(p, pvid);
 	}
 
@@ -731,6 +751,7 @@ static void br_vlan_disable_default_pvid(struct net_bridge *br)
 int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 {
 	const struct net_bridge_vlan *pvent;
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge_port *p;
 	u16 old_pvid;
 	int err = 0;
@@ -751,8 +772,9 @@ int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 	/* Update default_pvid config only if we do not conflict with
 	 * user configuration.
 	 */
-	pvent = br_vlan_find(br->vlgrp, pvid);
-	if ((!old_pvid || vlan_default_pvid(br->vlgrp, old_pvid)) &&
+	vg = br_vlan_group(br);
+	pvent = br_vlan_find(vg, pvid);
+	if ((!old_pvid || vlan_default_pvid(vg, old_pvid)) &&
 	    (!pvent || !br_vlan_should_use(pvent))) {
 		err = br_vlan_add(br, pvid,
 				  BRIDGE_VLAN_INFO_PVID |
@@ -768,9 +790,10 @@ int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 		/* Update default_pvid config only if we do not conflict with
 		 * user configuration.
 		 */
+		vg = nbp_vlan_group(p);
 		if ((old_pvid &&
-		     !vlan_default_pvid(p->vlgrp, old_pvid)) ||
-		    br_vlan_find(p->vlgrp, pvid))
+		     !vlan_default_pvid(vg, old_pvid)) ||
+		    br_vlan_find(vg, pvid))
 			continue;
 
 		err = nbp_vlan_add(p, pvid,
@@ -839,17 +862,19 @@ unlock:
 
 int br_vlan_init(struct net_bridge *br)
 {
+	struct net_bridge_vlan_group *vg;
 	int ret = -ENOMEM;
 
-	br->vlgrp = kzalloc(sizeof(struct net_bridge_vlan_group), GFP_KERNEL);
-	if (!br->vlgrp)
+	vg = kzalloc(sizeof(*vg), GFP_KERNEL);
+	if (!vg)
 		goto out;
-	ret = rhashtable_init(&br->vlgrp->vlan_hash, &br_vlan_rht_params);
+	ret = rhashtable_init(&vg->vlan_hash, &br_vlan_rht_params);
 	if (ret)
 		goto err_rhtbl;
-	INIT_LIST_HEAD(&br->vlgrp->vlan_list);
+	INIT_LIST_HEAD(&vg->vlan_list);
 	br->vlan_proto = htons(ETH_P_8021Q);
 	br->default_pvid = 1;
+	rcu_assign_pointer(br->vlgrp, vg);
 	ret = br_vlan_add(br, 1,
 			  BRIDGE_VLAN_INFO_PVID | BRIDGE_VLAN_INFO_UNTAGGED |
 			  BRIDGE_VLAN_INFO_BRENTRY);
@@ -860,9 +885,9 @@ out:
 	return ret;
 
 err_vlan_add:
-	rhashtable_destroy(&br->vlgrp->vlan_hash);
+	rhashtable_destroy(&vg->vlan_hash);
 err_rhtbl:
-	kfree(br->vlgrp);
+	kfree(vg);
 
 	goto out;
 }
@@ -880,9 +905,7 @@ int nbp_vlan_init(struct net_bridge_port *p)
 	if (ret)
 		goto err_rhtbl;
 	INIT_LIST_HEAD(&vg->vlan_list);
-	/* Make sure everything's committed before publishing vg */
-	smp_wmb();
-	p->vlgrp = vg;
+	rcu_assign_pointer(p->vlgrp, vg);
 	if (p->br->default_pvid) {
 		ret = nbp_vlan_add(p, p->br->default_pvid,
 				   BRIDGE_VLAN_INFO_PVID |
@@ -911,7 +934,7 @@ int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 
 	ASSERT_RTNL();
 
-	vlan = br_vlan_find(port->vlgrp, vid);
+	vlan = br_vlan_find(nbp_vlan_group(port), vid);
 	if (vlan) {
 		__vlan_add_flags(vlan, flags);
 		return 0;
@@ -939,7 +962,7 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 
 	ASSERT_RTNL();
 
-	v = br_vlan_find(port->vlgrp, vid);
+	v = br_vlan_find(nbp_vlan_group(port), vid);
 	if (!v)
 		return -ENOENT;
 	br_fdb_find_delete_local(port->br, port, port->dev->dev_addr, vid);
@@ -950,12 +973,14 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 
 void nbp_vlan_flush(struct net_bridge_port *port)
 {
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge_vlan *vlan;
 
 	ASSERT_RTNL();
 
-	list_for_each_entry(vlan, &port->vlgrp->vlan_list, vlist)
+	vg = nbp_vlan_group(port);
+	list_for_each_entry(vlan, &vg->vlan_list, vlist)
 		vlan_vid_del(port->dev, port->br->vlan_proto, vlan->vid);
 
-	__vlan_flush(nbp_vlan_group(port));
+	__vlan_flush(vg);
 }
-- 
2.4.3
