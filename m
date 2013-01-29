From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 13/13] bridge: Separate egress policy bitmap
Date: Tue, 29 Jan 2013 14:53:00 -0500
Message-ID: <1359489180-10012-14-git-send-email-vyasevic@redhat.com>
References: <1359489180-10012-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54561 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754237Ab3A2TxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 14:53:20 -0500
In-Reply-To: <1359489180-10012-1-git-send-email-vyasevic@redhat.com>
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
 net/bridge/br_netlink.c        |    2 ++
 net/bridge/br_private.h        |    1 +
 net/bridge/br_vlan.c           |   20 ++++++++++++++------
 4 files changed, 18 insertions(+), 6 deletions(-)

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
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index ddbb2c7..b71d1c5 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -141,6 +141,8 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 			vinfo.flags = 0;
 			if (vid == pv->pvid)
 				vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
+			if (test_bit(vid, pv->untagged_bitmap))
+				vinfo.flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 
 			if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
 				    sizeof(vinfo), &vinfo))
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 40688ad..c088ded 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -73,6 +73,7 @@ struct net_port_vlans {
 	void				*parent;
 	struct rcu_head			rcu;
 	unsigned long			vlan_bitmap[BR_VLAN_BITMAP_LEN];
+	unsigned long			untagged_bitmap[BR_VLAN_BITMAP_LEN];
 	u16				num_vlans;
 };
 
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 2243795..a507cb0 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -45,13 +45,21 @@ static void __vlan_delete_pvid(struct net_port_vlans *v, u16 vid)
 	v->pvid = BR_INVALID_VID;
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
 	int err;
 
 	if (test_bit(vid, v->vlan_bitmap)) {
-		if (flags & BRIDGE_VLAN_INFO_PVID)
-			__vlan_add_pvid(v, vid);
+		__vlan_add_flags(v, vid, flags);
 		return 0;
 	}
 
@@ -72,8 +80,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 
 	set_bit(vid, v->vlan_bitmap);
 	v->num_vlans++;
-	if (flags & BRIDGE_VLAN_INFO_PVID)
-		__vlan_add_pvid(v, vid);
+	__vlan_add_flags(v, vid, flags);
 
 	return 0;
 }
@@ -87,6 +94,7 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 		return -EINVAL;
 
 	__vlan_delete_pvid(v, vid);
+	clear_bit(vid, v->untagged_bitmap);
 
 	/* Check to see if any other vlans are in this table.  If this
 	 * is the last vlan, delete the whole structure.  If this is not the
@@ -159,11 +167,11 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
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
