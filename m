From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v2 4/4] bridge: vlan: move back vlan_flush
Date: Mon, 12 Oct 2015 21:47:05 +0200
Message-ID: <1444679225-7354-5-git-send-email-razor@blackwall.org>
References: <1444679225-7354-1-git-send-email-razor@blackwall.org>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, idosch@mellanox.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33694 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbbJLTrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 15:47:13 -0400
Received: by wicge5 with SMTP id ge5so30419278wic.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 12:47:12 -0700 (PDT)
In-Reply-To: <1444679225-7354-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Ido Schimmel reported a problem with switchdev devices because of the
order change of del_nbp operations, more specifically the move of
nbp_vlan_flush() which deletes all vlans and frees vlgrp after the
rx_handler has been unregistered. So in order to fix this move
vlan_flush back where it was and make it destroy the rhtable after
NULLing vlgrp and waiting a grace period to make sure noone can see it.

Reported-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: use synchronize_rcu() explicitly and free the vlan_group afterwards
also added a WARN_ON() to catch non-empty vlan lists.

 net/bridge/br_if.c      |  3 +--
 net/bridge/br_private.h |  1 -
 net/bridge/br_vlan.c    | 31 ++++++++++++++++++++++++-------
 3 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 934cae9fa317..45e4757c6fd2 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -248,6 +248,7 @@ static void del_nbp(struct net_bridge_port *p)
 
 	list_del_rcu(&p->list);
 
+	nbp_vlan_flush(p);
 	br_fdb_delete_by_port(br, p, 0, 1);
 	nbp_update_port_count(br);
 
@@ -256,8 +257,6 @@ static void del_nbp(struct net_bridge_port *p)
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
 	netdev_rx_handler_unregister(dev);
-	/* use the synchronize_rcu done by netdev_rx_handler_unregister */
-	nbp_vlan_flush(p);
 
 	br_multicast_del_port(p);
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8835642a6326..216018c76018 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -132,7 +132,6 @@ struct net_bridge_vlan_group {
 	struct list_head		vlan_list;
 	u16				num_vlans;
 	u16				pvid;
-	struct rcu_head			rcu;
 };
 
 struct net_bridge_fdb_entry
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 573ddfc31fb1..fbb9f8ce36c7 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -321,15 +321,20 @@ out:
 	return err;
 }
 
-static void __vlan_flush(struct net_bridge_vlan_group *vlgrp)
+static void __vlan_group_free(struct net_bridge_vlan_group *vg)
+{
+	WARN_ON(!list_empty(&vg->vlan_list));
+	rhashtable_destroy(&vg->vlan_hash);
+	kfree(vg);
+}
+
+static void __vlan_flush(struct net_bridge_vlan_group *vg)
 {
 	struct net_bridge_vlan *vlan, *tmp;
 
-	__vlan_delete_pvid(vlgrp, vlgrp->pvid);
-	list_for_each_entry_safe(vlan, tmp, &vlgrp->vlan_list, vlist)
+	__vlan_delete_pvid(vg, vg->pvid);
+	list_for_each_entry_safe(vlan, tmp, &vg->vlan_list, vlist)
 		__vlan_del(vlan);
-	rhashtable_destroy(&vlgrp->vlan_hash);
-	kfree_rcu(vlgrp, rcu);
 }
 
 struct sk_buff *br_handle_vlan(struct net_bridge *br,
@@ -585,9 +590,15 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
 
 void br_vlan_flush(struct net_bridge *br)
 {
+	struct net_bridge_vlan_group *vg;
+
 	ASSERT_RTNL();
 
-	__vlan_flush(br_vlan_group(br));
+	vg = br_vlan_group(br);
+	__vlan_flush(vg);
+	RCU_INIT_POINTER(br->vlgrp, NULL);
+	synchronize_rcu();
+	__vlan_group_free(vg);
 }
 
 struct net_bridge_vlan *br_vlan_find(struct net_bridge_vlan_group *vg, u16 vid)
@@ -973,7 +984,13 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 
 void nbp_vlan_flush(struct net_bridge_port *port)
 {
+	struct net_bridge_vlan_group *vg;
+
 	ASSERT_RTNL();
 
-	__vlan_flush(nbp_vlan_group(port));
+	vg = nbp_vlan_group(port);
+	__vlan_flush(vg);
+	RCU_INIT_POINTER(port->vlgrp, NULL);
+	synchronize_rcu();
+	__vlan_group_free(vg);
 }
-- 
2.4.3
