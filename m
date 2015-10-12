From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 3/4] bridge: vlan: break vlan_flush in two phases to keep old order
Date: Mon, 12 Oct 2015 13:41:08 +0200
Message-ID: <1444650069-32572-4-git-send-email-razor@blackwall.org>
References: <1444650069-32572-1-git-send-email-razor@blackwall.org>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, idosch@mellanox.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38868 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722AbbJLLl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 07:41:57 -0400
Received: by wieq12 with SMTP id q12so16053564wie.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 04:41:56 -0700 (PDT)
In-Reply-To: <1444650069-32572-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Ido Schimmel reported a problem with switchdev devices because of the
order change of del_nbp operations, more specifically the move of
nbp_vlan_flush() which deletes all vlans and frees vlgrp after the
rx_handler has been unregistered. So in order to fix this break
vlan_flush in two phases:
1. delete all of vlan_group's vlans
2. destroy rhtable and free vlgrp
We execute phase I (free_rht == false) in the same place as before so the
vlans can be cleared and free the vlgrp after the rx_handler has been
unregistered in phase II (free_rht == true).

Reported-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
Ido: I hope this fixes it for your case, a test would be much appreciated.

 net/bridge/br_if.c      | 11 ++++++++---
 net/bridge/br_private.h |  8 ++++----
 net/bridge/br_vlan.c    | 17 ++++++++++-------
 3 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 934cae9fa317..74a03c0a4e5f 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -248,6 +248,8 @@ static void del_nbp(struct net_bridge_port *p)
 
 	list_del_rcu(&p->list);
 
+	/* vlan_flush phase I: remove vlans */
+	nbp_vlan_flush(p, false);
 	br_fdb_delete_by_port(br, p, 0, 1);
 	nbp_update_port_count(br);
 
@@ -256,8 +258,10 @@ static void del_nbp(struct net_bridge_port *p)
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
 	netdev_rx_handler_unregister(dev);
-	/* use the synchronize_rcu done by netdev_rx_handler_unregister */
-	nbp_vlan_flush(p);
+	/* use the synchronize_rcu done by netdev_rx_handler_unregister
+	 * vlan_flush phase II: free rht and vlgrp
+	 */
+	nbp_vlan_flush(p, true);
 
 	br_multicast_del_port(p);
 
@@ -281,7 +285,8 @@ void br_dev_delete(struct net_device *dev, struct list_head *head)
 
 	br_fdb_delete_by_port(br, NULL, 0, 1);
 
-	br_vlan_flush(br);
+	/* vlan_flush execute both phases (see del_nbp) */
+	br_vlan_flush(br, true);
 	br_multicast_dev_del(br);
 	del_timer_sync(&br->gc_timer);
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 7d14ba93bba4..3938a976417f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -682,7 +682,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 			       struct sk_buff *skb);
 int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags);
 int br_vlan_delete(struct net_bridge *br, u16 vid);
-void br_vlan_flush(struct net_bridge *br);
+void br_vlan_flush(struct net_bridge *br, bool free_rht);
 struct net_bridge_vlan *br_vlan_find(struct net_bridge_vlan_group *vg, u16 vid);
 void br_recalculate_fwd_mask(struct net_bridge *br);
 int __br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
@@ -694,7 +694,7 @@ int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val);
 int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid);
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
-void nbp_vlan_flush(struct net_bridge_port *port);
+void nbp_vlan_flush(struct net_bridge_port *port, bool free_rht);
 int nbp_vlan_init(struct net_bridge_port *port);
 int nbp_get_num_vlan_infos(struct net_bridge_port *p, u32 filter_mask);
 
@@ -790,7 +790,7 @@ static inline int br_vlan_delete(struct net_bridge *br, u16 vid)
 	return -EOPNOTSUPP;
 }
 
-static inline void br_vlan_flush(struct net_bridge *br)
+static inline void br_vlan_flush(struct net_bridge *br, bool free_rht)
 {
 }
 
@@ -813,7 +813,7 @@ static inline int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 	return -EOPNOTSUPP;
 }
 
-static inline void nbp_vlan_flush(struct net_bridge_port *port)
+static inline void nbp_vlan_flush(struct net_bridge_port *port, bool free_rht)
 {
 }
 
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index a212979257b1..4fb9b23c9838 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -307,15 +307,18 @@ out:
 	return err;
 }
 
-static void __vlan_flush(struct net_bridge_vlan_group *vlgrp)
+static void __vlan_flush(struct net_bridge_vlan_group *vlgrp, bool free_rht)
 {
 	struct net_bridge_vlan *vlan, *tmp;
 
 	__vlan_delete_pvid(vlgrp, vlgrp->pvid);
 	list_for_each_entry_safe(vlan, tmp, &vlgrp->vlan_list, vlist)
 		__vlan_del(vlan);
-	rhashtable_destroy(&vlgrp->vlan_hash);
-	kfree_rcu(vlgrp, rcu);
+
+	if (free_rht) {
+		rhashtable_destroy(&vlgrp->vlan_hash);
+		kfree_rcu(vlgrp, rcu);
+	}
 }
 
 struct sk_buff *br_handle_vlan(struct net_bridge *br,
@@ -569,11 +572,11 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
 	return __vlan_del(v);
 }
 
-void br_vlan_flush(struct net_bridge *br)
+void br_vlan_flush(struct net_bridge *br, bool free_rht)
 {
 	ASSERT_RTNL();
 
-	__vlan_flush(br_vlan_group(br));
+	__vlan_flush(br_vlan_group(br), free_rht);
 }
 
 struct net_bridge_vlan *br_vlan_find(struct net_bridge_vlan_group *vg, u16 vid)
@@ -957,7 +960,7 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 	return __vlan_del(v);
 }
 
-void nbp_vlan_flush(struct net_bridge_port *port)
+void nbp_vlan_flush(struct net_bridge_port *port, bool free_rht)
 {
 	struct net_bridge_vlan_group *vg;
 	struct net_bridge_vlan *vlan;
@@ -968,5 +971,5 @@ void nbp_vlan_flush(struct net_bridge_port *port)
 	list_for_each_entry(vlan, &vg->vlan_list, vlist)
 		vlan_vid_del(port->dev, port->br->vlan_proto, vlan->vid);
 
-	__vlan_flush(vg);
+	__vlan_flush(vg, free_rht);
 }
-- 
2.4.3
