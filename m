From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v11 net-next 12/12] bridge: Separate egress policy bitmap
Date: Wed, 13 Feb 2013 17:00:20 -0500
Message-ID: <1360792820-14116-13-git-send-email-vyasevic@redhat.com>
References: <1360792820-14116-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965029Ab3BMWBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2013 17:01:00 -0500
In-Reply-To: <1360792820-14116-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an ability to configure a separate "untagged" egress
policy to the VLAN information of the bridge.  This superseeds PVID
policy and makes PVID ingress-only.  The policy is configured with a
new flag and is represented as a port bitmap per vlan.  Egress frames
with a VLAN id in "untagged" policy bitmap would egress
the port without VLAN header.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_bridge.h |    1 +
 net/bridge/br_netlink.c        |    4 ++++
 net/bridge/br_private.h        |    1 +
 net/bridge/br_vlan.c           |   20 ++++++++++++++------
 4 files changed, 20 insertions(+), 6 deletions(-)

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
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e044cc0..d1dda47 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -143,6 +143,10 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 			vinfo.flags = 0;
 			if (vid == pvid)
 				vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
+
+			if (test_bit(vid, pv->untagged_bitmap))
+				vinfo.flags |= BRIDGE_VLAN_INFO_UNTAGGED;
+
 			if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
 				    sizeof(vinfo), &vinfo))
 				goto nla_put_failure;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6f9675a..9b75548 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -75,6 +75,7 @@ struct net_port_vlans {
 	}				parent;
 	struct rcu_head			rcu;
 	unsigned long			vlan_bitmap[BR_VLAN_BITMAP_LEN];
+	unsigned long			untagged_bitmap[BR_VLAN_BITMAP_LEN];
 	u16				num_vlans;
 };
 
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 9ea358f..93dde75 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -23,6 +23,15 @@ static void __vlan_delete_pvid(struct net_port_vlans *v, u16 vid)
 	v->pvid = 0;
 }
 
+static void __vlan_add_flags(struct net_port_vlans *v, u16 vid, u16 flags)
+{
+	if (flags & BRIDGE_VLAN_INFO_PVID)
+		__vlan_add_pvid(v, vid);
+
+	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
+		set_bit(vid, v->untagged_bitmap);
+}
+
 static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 {
 	struct net_bridge_port *p = NULL;
@@ -31,8 +40,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 	int err;
 
 	if (test_bit(vid, v->vlan_bitmap)) {
-		if (flags & BRIDGE_VLAN_INFO_PVID)
-			__vlan_add_pvid(v, vid);
+		__vlan_add_flags(v, vid, flags);
 		return 0;
 	}
 
@@ -69,8 +77,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 
 	set_bit(vid, v->vlan_bitmap);
 	v->num_vlans++;
-	if (flags & BRIDGE_VLAN_INFO_PVID)
-		__vlan_add_pvid(v, vid);
+	__vlan_add_flags(v, vid, flags);
 
 	return 0;
 
@@ -86,6 +93,7 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 		return -EINVAL;
 
 	__vlan_delete_pvid(v, vid);
+	clear_bit(vid, v->untagged_bitmap);
 
 	if (v->port_idx && vid) {
 		struct net_device *dev = v->parent.port->dev;
@@ -144,11 +152,11 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 		goto out;
 
 	/* At this point, we know that the frame was filtered and contains
-	 * a valid vlan id.  If the vlan id matches the pvid of current port
+	 * a valid vlan id.  If the vlan id is set in the untagged bitmap,
 	 * send untagged; otherwise, send taged.
 	 */
 	br_vlan_get_tag(skb, &vid);
-	if (vid == br_get_pvid(pv))
+	if (test_bit(vid, pv->untagged_bitmap))
 		skb = br_vlan_untag(skb);
 	else {
 		/* Egress policy says "send tagged".  If output device
-- 
1.7.7.6
