From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V6 09/14] bridge: API to configure egress policy
Date: Wed, 16 Jan 2013 13:18:04 -0500
Message-ID: <1358360289-23249-10-git-send-email-vyasevic@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	shemminger@vyatta.com, mst@redhat.com, shmulik.ladkani@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63534 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756976Ab3APSS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 13:18:26 -0500
In-Reply-To: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
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
 net/bridge/br_vlan.c           |   49 +++++++++++++++++++++++++++++++--------
 2 files changed, 40 insertions(+), 10 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index c6c30e2..f1bf8d3 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -121,6 +121,7 @@ enum {
 
 #define BRIDGE_VLAN_INFO_MASTER	(1<<0)	/* Operate on Bridge device as well */
 #define BRIDGE_VLAN_INFO_PVID	(1<<1)	/* VLAN is PVID, ingress untagged */
+#define BRIDGE_VLAN_INFO_UNTAGGED	(1<<2)	/* VLAN egresses untagged */
 
 struct bridge_vlan_info {
 	u16 flags;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index cbaa6b5..58cfbb4 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -292,6 +292,32 @@ static void nbp_vlan_delete_pvid(struct net_port_vlans *v,
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
@@ -326,10 +352,14 @@ int nbp_vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
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
@@ -358,11 +388,9 @@ int nbp_vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 
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
 
@@ -393,7 +421,9 @@ int nbp_vlan_delete(struct net_port_vlans *v, u16 vid)
 	if (!pve)
 		return -ENOENT;
 
-	nbp_vlan_delete_pvid(v, pve->vlan);
+	vlan = rtnl_dereference(pve->vlan);
+	nbp_vlan_undo_flags(v, vlan,
+			    BRIDGE_VLAN_INFO_PVID | BRIDGE_VLAN_INFO_UNTAGGED);
 
 	if (v->port_idx) {
 		/* A valid port index means this is a port.
@@ -407,7 +437,6 @@ int nbp_vlan_delete(struct net_port_vlans *v, u16 vid)
 	}
 	pve->vid = BR_INVALID_VID;
 
-	vlan = rtnl_dereference(pve->vlan);
 	rcu_assign_pointer(pve->vlan, NULL);
 	clear_bit(v->port_idx, vlan->port_bitmap);
 	br_vlan_put(vlan);
-- 
1.7.7.6
