From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 4/4] bridge: vlan: combine (br|nbp)_vlan_flush into one
Date: Mon, 12 Oct 2015 13:41:09 +0200
Message-ID: <1444650069-32572-5-git-send-email-razor@blackwall.org>
References: <1444650069-32572-1-git-send-email-razor@blackwall.org>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, idosch@mellanox.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36310 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729AbbJLLl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 07:41:58 -0400
Received: by wicgb1 with SMTP id gb1so145459943wic.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 04:41:57 -0700 (PDT)
In-Reply-To: <1444650069-32572-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

As Ido Schimmel pointed out the vlan_vid_del() loop in nbp_vlan_flush is
unnecessary (and is actually a remnant of the old vlan code) so we can
remove it and combine both br/nbp vlan_flush functions into one.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_if.c      |  8 +++++---
 net/bridge/br_private.h |  9 ++-------
 net/bridge/br_vlan.c    | 16 +---------------
 3 files changed, 8 insertions(+), 25 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 74a03c0a4e5f..ed431cc80b3d 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -233,6 +233,7 @@ static void destroy_nbp_rcu(struct rcu_head *head)
  */
 static void del_nbp(struct net_bridge_port *p)
 {
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge *br = p->br;
 	struct net_device *dev = p->dev;
 
@@ -249,7 +250,8 @@ static void del_nbp(struct net_bridge_port *p)
 	list_del_rcu(&p->list);
 
 	/* vlan_flush phase I: remove vlans */
-	nbp_vlan_flush(p, false);
+	vg = nbp_vlan_group(p);
+	br_vlan_flush(vg, false);
 	br_fdb_delete_by_port(br, p, 0, 1);
 	nbp_update_port_count(br);
 
@@ -261,7 +263,7 @@ static void del_nbp(struct net_bridge_port *p)
 	/* use the synchronize_rcu done by netdev_rx_handler_unregister
 	 * vlan_flush phase II: free rht and vlgrp
 	 */
-	nbp_vlan_flush(p, true);
+	br_vlan_flush(vg, true);
 
 	br_multicast_del_port(p);
 
@@ -286,7 +288,7 @@ void br_dev_delete(struct net_device *dev, struct list_head *head)
 	br_fdb_delete_by_port(br, NULL, 0, 1);
 
 	/* vlan_flush execute both phases (see del_nbp) */
-	br_vlan_flush(br, true);
+	br_vlan_flush(br_vlan_group(br), true);
 	br_multicast_dev_del(br);
 	del_timer_sync(&br->gc_timer);
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 3938a976417f..73ee71c0a960 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -682,7 +682,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 			       struct sk_buff *skb);
 int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags);
 int br_vlan_delete(struct net_bridge *br, u16 vid);
-void br_vlan_flush(struct net_bridge *br, bool free_rht);
+void br_vlan_flush(struct net_bridge_vlan_group *vg, bool free_rht);
 struct net_bridge_vlan *br_vlan_find(struct net_bridge_vlan_group *vg, u16 vid);
 void br_recalculate_fwd_mask(struct net_bridge *br);
 int __br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
@@ -694,7 +694,6 @@ int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val);
 int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid);
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
-void nbp_vlan_flush(struct net_bridge_port *port, bool free_rht);
 int nbp_vlan_init(struct net_bridge_port *port);
 int nbp_get_num_vlan_infos(struct net_bridge_port *p, u32 filter_mask);
 
@@ -790,7 +789,7 @@ static inline int br_vlan_delete(struct net_bridge *br, u16 vid)
 	return -EOPNOTSUPP;
 }
 
-static inline void br_vlan_flush(struct net_bridge *br, bool free_rht)
+static inline void br_vlan_flush(struct net_bridge_vlan_group *vg, bool free_rht)
 {
 }
 
@@ -813,10 +812,6 @@ static inline int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 	return -EOPNOTSUPP;
 }
 
-static inline void nbp_vlan_flush(struct net_bridge_port *port, bool free_rht)
-{
-}
-
 static inline struct net_bridge_vlan *br_vlan_find(struct net_bridge_vlan_group *vg,
 						   u16 vid)
 {
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 4fb9b23c9838..11ac14f60206 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -572,13 +572,6 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
 	return __vlan_del(v);
 }
 
-void br_vlan_flush(struct net_bridge *br, bool free_rht)
-{
-	ASSERT_RTNL();
-
-	__vlan_flush(br_vlan_group(br), free_rht);
-}
-
 struct net_bridge_vlan *br_vlan_find(struct net_bridge_vlan_group *vg, u16 vid)
 {
 	if (!vg)
@@ -960,16 +953,9 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 	return __vlan_del(v);
 }
 
-void nbp_vlan_flush(struct net_bridge_port *port, bool free_rht)
+void br_vlan_flush(struct net_bridge_vlan_group *vg, bool free_rht)
 {
-	struct net_bridge_vlan_group *vg;
-	struct net_bridge_vlan *vlan;
-
 	ASSERT_RTNL();
 
-	vg = nbp_vlan_group(port);
-	list_for_each_entry(vlan, &vg->vlan_list, vlist)
-		vlan_vid_del(port->dev, port->br->vlan_proto, vlan->vid);
-
 	__vlan_flush(vg, free_rht);
 }
-- 
2.4.3
