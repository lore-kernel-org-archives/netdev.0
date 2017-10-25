From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v4 2/2] bridge: vlan: signal if anything changed on vlan add
Date: Thu, 26 Oct 2017 01:52:34 +0300
Message-ID: <1508971954-3567-3-git-send-email-nikolay@cumulusnetworks.com>
References: <f6c0da96-77f0-db19-7a9a-13b246d83d39@cumulusnetworks.com>
 <1508971954-3567-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: dsa@cumulusnetworks.com, mrv@mojatatu.com, davem@davemloft.net,
        bridge@lists.linux-foundation.org, roopa@cumulusnetworks.com,
        stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:44307 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751753AbdJYWxx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 18:53:53 -0400
Received: by mail-wr0-f196.google.com with SMTP id z55so1475512wrz.1
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 15:53:53 -0700 (PDT)
In-Reply-To: <1508971954-3567-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch there was no way to tell if the vlan add operation
actually changed anything, thus we would always generate a notification
on adds. Let's make the notifications more precise and generate them
only if anything changed, so use the new bool parameter to signal that the
vlan was updated. We cannot return an error because there are valid use
cases that will be broken (e.g. overlapping range add) and also we can't
risk masking errors due to calls into drivers for vlan add which can
potentially return anything.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v4: set changed always to false in the non-vlan config case
v3: fix non-vlan config functions reported by kbuild bot
v2: pass changed down to vlan add functions instead of using a specific
error that needs to be masked

 net/bridge/br_netlink.c |  9 ++++--
 net/bridge/br_private.h | 14 ++++++---
 net/bridge/br_vlan.c    | 78 +++++++++++++++++++++++++++++++++++--------------
 3 files changed, 72 insertions(+), 29 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index d0290ede9342..e732403669c6 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -508,6 +508,7 @@ int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
 			int cmd, struct bridge_vlan_info *vinfo, bool *changed)
 {
+	bool curr_change;
 	int err = 0;
 
 	switch (cmd) {
@@ -516,12 +517,14 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
 			/* if the MASTER flag is set this will act on the global
 			 * per-VLAN entry as well
 			 */
-			err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
+			err = nbp_vlan_add(p, vinfo->vid, vinfo->flags,
+					   &curr_change);
 		} else {
 			vinfo->flags |= BRIDGE_VLAN_INFO_BRENTRY;
-			err = br_vlan_add(br, vinfo->vid, vinfo->flags);
+			err = br_vlan_add(br, vinfo->vid, vinfo->flags,
+					  &curr_change);
 		}
-		if (!err)
+		if (curr_change)
 			*changed = true;
 		break;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index fa0039f44818..860e4afaf71a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -803,7 +803,8 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 			       const struct net_bridge_port *port,
 			       struct net_bridge_vlan_group *vg,
 			       struct sk_buff *skb);
-int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags);
+int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags,
+		bool *changed);
 int br_vlan_delete(struct net_bridge *br, u16 vid);
 void br_vlan_flush(struct net_bridge *br);
 struct net_bridge_vlan *br_vlan_find(struct net_bridge_vlan_group *vg, u16 vid);
@@ -816,7 +817,8 @@ int br_vlan_set_stats(struct net_bridge *br, unsigned long val);
 int br_vlan_init(struct net_bridge *br);
 int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val);
 int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid);
-int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
+int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags,
+		 bool *changed);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 void nbp_vlan_flush(struct net_bridge_port *port);
 int nbp_vlan_init(struct net_bridge_port *port);
@@ -903,8 +905,10 @@ static inline struct sk_buff *br_handle_vlan(struct net_bridge *br,
 	return skb;
 }
 
-static inline int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
+static inline int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags,
+			      bool *changed)
 {
+	*changed = false;
 	return -EOPNOTSUPP;
 }
 
@@ -926,8 +930,10 @@ static inline int br_vlan_init(struct net_bridge *br)
 	return 0;
 }
 
-static inline int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
+static inline int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags,
+			       bool *changed)
 {
+	*changed = false;
 	return -EOPNOTSUPP;
 }
 
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 233a30040c91..fb0a903d19d1 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -32,27 +32,34 @@ static struct net_bridge_vlan *br_vlan_lookup(struct rhashtable *tbl, u16 vid)
 	return rhashtable_lookup_fast(tbl, &vid, br_vlan_rht_params);
 }
 
-static void __vlan_add_pvid(struct net_bridge_vlan_group *vg, u16 vid)
+static bool __vlan_add_pvid(struct net_bridge_vlan_group *vg, u16 vid)
 {
 	if (vg->pvid == vid)
-		return;
+		return false;
 
 	smp_wmb();
 	vg->pvid = vid;
+
+	return true;
 }
 
-static void __vlan_delete_pvid(struct net_bridge_vlan_group *vg, u16 vid)
+static bool __vlan_delete_pvid(struct net_bridge_vlan_group *vg, u16 vid)
 {
 	if (vg->pvid != vid)
-		return;
+		return false;
 
 	smp_wmb();
 	vg->pvid = 0;
+
+	return true;
 }
 
-static void __vlan_add_flags(struct net_bridge_vlan *v, u16 flags)
+/* return true if anything changed, false otherwise */
+static bool __vlan_add_flags(struct net_bridge_vlan *v, u16 flags)
 {
 	struct net_bridge_vlan_group *vg;
+	u16 old_flags = v->flags;
+	bool ret;
 
 	if (br_vlan_is_master(v))
 		vg = br_vlan_group(v->br);
@@ -60,14 +67,16 @@ static void __vlan_add_flags(struct net_bridge_vlan *v, u16 flags)
 		vg = nbp_vlan_group(v->port);
 
 	if (flags & BRIDGE_VLAN_INFO_PVID)
-		__vlan_add_pvid(vg, v->vid);
+		ret = __vlan_add_pvid(vg, v->vid);
 	else
-		__vlan_delete_pvid(vg, v->vid);
+		ret = __vlan_delete_pvid(vg, v->vid);
 
 	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
 		v->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 	else
 		v->flags &= ~BRIDGE_VLAN_INFO_UNTAGGED;
+
+	return ret || !!(old_flags ^ v->flags);
 }
 
 static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
@@ -151,8 +160,10 @@ static struct net_bridge_vlan *br_vlan_get_master(struct net_bridge *br, u16 vid
 	vg = br_vlan_group(br);
 	masterv = br_vlan_find(vg, vid);
 	if (!masterv) {
+		bool changed;
+
 		/* missing global ctx, create it now */
-		if (br_vlan_add(br, vid, 0))
+		if (br_vlan_add(br, vid, 0, &changed))
 			return NULL;
 		masterv = br_vlan_find(vg, vid);
 		if (WARN_ON(!masterv))
@@ -232,8 +243,11 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 
 		/* need to work on the master vlan too */
 		if (flags & BRIDGE_VLAN_INFO_MASTER) {
-			err = br_vlan_add(br, v->vid, flags |
-						      BRIDGE_VLAN_INFO_BRENTRY);
+			bool changed;
+
+			err = br_vlan_add(br, v->vid,
+					  flags | BRIDGE_VLAN_INFO_BRENTRY,
+					  &changed);
 			if (err)
 				goto out_filt;
 		}
@@ -550,8 +564,9 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
 
 /* Must be protected by RTNL.
  * Must be called with vid in range from 1 to 4094 inclusive.
+ * changed must be true only if the vlan was created or updated
  */
-int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
+int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags, bool *changed)
 {
 	struct net_bridge_vlan_group *vg;
 	struct net_bridge_vlan *vlan;
@@ -559,6 +574,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 
 	ASSERT_RTNL();
 
+	*changed = false;
 	vg = br_vlan_group(br);
 	vlan = br_vlan_find(vg, vid);
 	if (vlan) {
@@ -576,9 +592,12 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 			refcount_inc(&vlan->refcnt);
 			vlan->flags |= BRIDGE_VLAN_INFO_BRENTRY;
 			vg->num_vlans++;
+			*changed = true;
 		}
-		__vlan_add_flags(vlan, flags);
-		return 0;
+		if (__vlan_add_flags(vlan, flags))
+			*changed = true;
+
+		return ret;
 	}
 
 	vlan = kzalloc(sizeof(*vlan), GFP_KERNEL);
@@ -601,6 +620,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 		free_percpu(vlan->stats);
 		kfree(vlan);
 	}
+	*changed = true;
 
 	return ret;
 }
@@ -824,9 +844,10 @@ int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 	const struct net_bridge_vlan *pvent;
 	struct net_bridge_vlan_group *vg;
 	struct net_bridge_port *p;
+	unsigned long *changed;
+	bool vlchange;
 	u16 old_pvid;
 	int err = 0;
-	unsigned long *changed;
 
 	if (!pvid) {
 		br_vlan_disable_default_pvid(br);
@@ -850,7 +871,8 @@ int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 		err = br_vlan_add(br, pvid,
 				  BRIDGE_VLAN_INFO_PVID |
 				  BRIDGE_VLAN_INFO_UNTAGGED |
-				  BRIDGE_VLAN_INFO_BRENTRY);
+				  BRIDGE_VLAN_INFO_BRENTRY,
+				  &vlchange);
 		if (err)
 			goto out;
 		br_vlan_delete(br, old_pvid);
@@ -869,7 +891,8 @@ int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 
 		err = nbp_vlan_add(p, pvid,
 				   BRIDGE_VLAN_INFO_PVID |
-				   BRIDGE_VLAN_INFO_UNTAGGED);
+				   BRIDGE_VLAN_INFO_UNTAGGED,
+				   &vlchange);
 		if (err)
 			goto err_port;
 		nbp_vlan_delete(p, old_pvid);
@@ -890,7 +913,8 @@ int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 		if (old_pvid)
 			nbp_vlan_add(p, old_pvid,
 				     BRIDGE_VLAN_INFO_PVID |
-				     BRIDGE_VLAN_INFO_UNTAGGED);
+				     BRIDGE_VLAN_INFO_UNTAGGED,
+				     &vlchange);
 		nbp_vlan_delete(p, pvid);
 	}
 
@@ -899,7 +923,8 @@ int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 			br_vlan_add(br, old_pvid,
 				    BRIDGE_VLAN_INFO_PVID |
 				    BRIDGE_VLAN_INFO_UNTAGGED |
-				    BRIDGE_VLAN_INFO_BRENTRY);
+				    BRIDGE_VLAN_INFO_BRENTRY,
+				    &vlchange);
 		br_vlan_delete(br, pvid);
 	}
 	goto out;
@@ -931,6 +956,7 @@ int br_vlan_init(struct net_bridge *br)
 {
 	struct net_bridge_vlan_group *vg;
 	int ret = -ENOMEM;
+	bool changed;
 
 	vg = kzalloc(sizeof(*vg), GFP_KERNEL);
 	if (!vg)
@@ -947,7 +973,7 @@ int br_vlan_init(struct net_bridge *br)
 	rcu_assign_pointer(br->vlgrp, vg);
 	ret = br_vlan_add(br, 1,
 			  BRIDGE_VLAN_INFO_PVID | BRIDGE_VLAN_INFO_UNTAGGED |
-			  BRIDGE_VLAN_INFO_BRENTRY);
+			  BRIDGE_VLAN_INFO_BRENTRY, &changed);
 	if (ret)
 		goto err_vlan_add;
 
@@ -992,9 +1018,12 @@ int nbp_vlan_init(struct net_bridge_port *p)
 	INIT_LIST_HEAD(&vg->vlan_list);
 	rcu_assign_pointer(p->vlgrp, vg);
 	if (p->br->default_pvid) {
+		bool changed;
+
 		ret = nbp_vlan_add(p, p->br->default_pvid,
 				   BRIDGE_VLAN_INFO_PVID |
-				   BRIDGE_VLAN_INFO_UNTAGGED);
+				   BRIDGE_VLAN_INFO_UNTAGGED,
+				   &changed);
 		if (ret)
 			goto err_vlan_add;
 	}
@@ -1016,8 +1045,10 @@ int nbp_vlan_init(struct net_bridge_port *p)
 
 /* Must be protected by RTNL.
  * Must be called with vid in range from 1 to 4094 inclusive.
+ * changed must be true only if the vlan was created or updated
  */
-int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
+int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags,
+		 bool *changed)
 {
 	struct switchdev_obj_port_vlan v = {
 		.obj.orig_dev = port->dev,
@@ -1031,13 +1062,15 @@ int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 
 	ASSERT_RTNL();
 
+	*changed = false;
 	vlan = br_vlan_find(nbp_vlan_group(port), vid);
 	if (vlan) {
 		/* Pass the flags to the hardware bridge */
 		ret = switchdev_port_obj_add(port->dev, &v.obj);
 		if (ret && ret != -EOPNOTSUPP)
 			return ret;
-		__vlan_add_flags(vlan, flags);
+		*changed = __vlan_add_flags(vlan, flags);
+
 		return 0;
 	}
 
@@ -1050,6 +1083,7 @@ int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 	ret = __vlan_add(vlan, flags);
 	if (ret)
 		kfree(vlan);
+	*changed = true;
 
 	return ret;
 }
-- 
2.1.4
