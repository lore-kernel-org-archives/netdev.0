From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] bridge: vlan: return EEXIST on add if nothing changed
Date: Thu, 19 Oct 2017 18:54:59 +0300
Message-ID: <1508428499-32355-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1508428499-32355-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        mrv@mojatatu.com, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:56520 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753282AbdJSPzl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 11:55:41 -0400
Received: by mail-wm0-f66.google.com with SMTP id l68so17306126wmd.5
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 08:55:40 -0700 (PDT)
In-Reply-To: <1508428499-32355-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch there was no way to tell if the vlan add operation
actually changed anything, thus we would always generate a notification
on adds. Let's make the notifications more precise and generate them
only if anything changed, so use EEXIST error to signal that the vlan
was not updated in any way. We just need to be careful about a few
places that could re-add the same vlan with the same flags not to return
any errors on EEXIST.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |  5 +++++
 net/bridge/br_vlan.c    | 38 ++++++++++++++++++++++++++------------
 2 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e8d74a3f44f7..80d9334a4b46 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -523,6 +523,11 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
 		}
 		if (!err)
 			*changed = true;
+		else if (err == -EEXIST)
+			/* nothing changed, return 0 for overlapping range add
+			 * and compatibility reasons
+			 */
+			err = 0;
 		break;
 
 	case RTM_DELLINK:
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 233a30040c91..e021a80eb8e9 100644
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
@@ -234,7 +243,7 @@ static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 		if (flags & BRIDGE_VLAN_INFO_MASTER) {
 			err = br_vlan_add(br, v->vid, flags |
 						      BRIDGE_VLAN_INFO_BRENTRY);
-			if (err)
+			if (err && err != -EEXIST)
 				goto out_filt;
 		}
 
@@ -562,6 +571,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 	vg = br_vlan_group(br);
 	vlan = br_vlan_find(vg, vid);
 	if (vlan) {
+		ret = -EEXIST;
 		if (!br_vlan_is_brentry(vlan)) {
 			/* Trying to change flags of non-existent bridge vlan */
 			if (!(flags & BRIDGE_VLAN_INFO_BRENTRY))
@@ -577,8 +587,10 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 			vlan->flags |= BRIDGE_VLAN_INFO_BRENTRY;
 			vg->num_vlans++;
 		}
-		__vlan_add_flags(vlan, flags);
-		return 0;
+		if (__vlan_add_flags(vlan, flags))
+			ret = 0;
+
+		return ret;
 	}
 
 	vlan = kzalloc(sizeof(*vlan), GFP_KERNEL);
@@ -870,7 +882,7 @@ int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 		err = nbp_vlan_add(p, pvid,
 				   BRIDGE_VLAN_INFO_PVID |
 				   BRIDGE_VLAN_INFO_UNTAGGED);
-		if (err)
+		if (err && err != -EEXIST)
 			goto err_port;
 		nbp_vlan_delete(p, old_pvid);
 		set_bit(p->port_no, changed);
@@ -1037,7 +1049,9 @@ int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 		ret = switchdev_port_obj_add(port->dev, &v.obj);
 		if (ret && ret != -EOPNOTSUPP)
 			return ret;
-		__vlan_add_flags(vlan, flags);
+		if (!__vlan_add_flags(vlan, flags))
+			return -EEXIST;
+
 		return 0;
 	}
 
-- 
2.1.4
