From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next v5 11/14] bridge: API to configure egress policy
Date: Wed,  9 Jan 2013 12:17:59 -0500
Message-ID: <1357751882-8619-13-git-send-email-vyasevic@redhat.com>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932274Ab3AIRSW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 12:18:22 -0500
In-Reply-To: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an ability to configure "untagged" egress policy to
the VLAN information of the bridge.  The policy is by a
flag and is represented as a port bitmap per vlan.  Frames
that leave a ports in "untagged" policy bitmap would egress
the port without VLAN header.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_bridge.h |    1 +
 net/bridge/br_if.c             |   49 +++++++++++++++++++++++++++++++--------
 net/bridge/br_private.h        |    1 +
 3 files changed, 41 insertions(+), 10 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 875c9e2..8e1fc51 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -121,6 +121,7 @@ enum {
 
 #define BRIDGE_VLAN_INFO_MASTER	(1<<0)	/* Operate on Bridge device as well */
 #define BRIDGE_VLAN_INFO_PVID	(1<<1)	/* VLAN is PVID, ingress untagged */
+#define BRIDGE_VLAN_INFO_UNTAGGED	(1<<2)	/* VLAN egresses untagged */
 
 struct bridge_vlan_info {
 	u16 flags;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index ca8ae30..3e4c841 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -232,6 +232,32 @@ static void nbp_vlan_delete_pvid(struct net_port_vlans *v,
 	rcu_assign_pointer(v->pvlan, NULL);
 }
 
+static int nbp_vlan_do_flags(struct net_port_vlans *v,
+			     struct net_bridge_vlan *vlan,
+			     u16 flags)
+{
+	int err = 0;
+
+	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
+		set_bit(v->port_idx, vlan->untagged_bitmap);
+
+	if (flags & BRIDGE_VLAN_INFO_PVID)
+		err = nbp_vlan_add_pvid(v, vlan);
+
+	return err;
+}
+
+static void nbp_vlan_undo_flags(struct net_port_vlans *v,
+				struct net_bridge_vlan *vlan,
+				u16 flags)
+{
+	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
+		clear_bit(v->port_idx, vlan->untagged_bitmap);
+
+	if (flags & BRIDGE_VLAN_INFO_PVID)
+		nbp_vlan_delete_pvid(v, vlan);
+}
+
 struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v, u16 vid)
 {
 	struct net_port_vlan *pve;
@@ -266,10 +292,14 @@ int nbp_vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 		return -ENOMEM;
 
 	/* Check to see if this port is already part of the vlan.  If
-	 * it is, there is nothing more to do.
+	 * it is, handle any flags and return.
 	 */
-	if (test_bit(v->port_idx, vlan->port_bitmap))
-		return -EEXIST;
+	if (test_bit(v->port_idx, vlan->port_bitmap)) {
+		err = nbp_vlan_do_flags(v, vlan, flags);
+		if (err)
+			nbp_vlan_undo_flags(v, vlan, flags);
+		return err;
+	}
 
 	/* Create port vlan, link it to bridge vlan list, and add port the
 	 * portgroup.
@@ -298,11 +328,9 @@ int nbp_vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 
 	list_add_tail_rcu(&pve->list, &v->vlan_list);
 
-	if (flags & BRIDGE_VLAN_INFO_PVID) {
-		err = nbp_vlan_add_pvid(v, vlan);
-		if (err)
-			goto del_vlan;
-	}
+	err = nbp_vlan_do_flags(v, vlan, flags);
+	if (err)
+		goto del_vlan;
 
 	return 0;
 
@@ -333,7 +361,9 @@ int nbp_vlan_delete(struct net_port_vlans *v, u16 vid)
 	if (!pve)
 		return -ENOENT;
 
-	nbp_vlan_delete_pvid(v, pve->vlan);
+	vlan = rtnl_dereference(pve->vlan);
+	nbp_vlan_undo_flags(v, vlan,
+			    BRIDGE_VLAN_INFO_PVID | BRIDGE_VLAN_INFO_UNTAGGED);
 
 	if (v->port_idx) {
 		/* A valid port index means this is a port.
@@ -348,7 +378,6 @@ int nbp_vlan_delete(struct net_port_vlans *v, u16 vid)
 
 	pve->vid = BR_INVALID_VID;
 
-	vlan = rtnl_dereference(pve->vlan);
 	rcu_assign_pointer(pve->vlan, NULL);
 	clear_bit(v->port_idx, vlan->port_bitmap);
 	br_vlan_put(vlan);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index bf00a5e..2e3317a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -77,6 +77,7 @@ struct net_bridge_vlan {
 	struct rcu_head			rcu;
 	u16				vid;
 	unsigned long			port_bitmap[PORT_BITMAP_LEN];
+	unsigned long			untagged_bitmap[PORT_BITMAP_LEN];
 };
 
 struct net_port_vlan {
-- 
1.7.7.6
