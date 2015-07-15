From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] bridge: multicast: fix handling of temp and perm entries
Date: Wed, 15 Jul 2015 07:16:51 -0700
Message-ID: <1436969811-13237-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1436969811-13237-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: bridge@lists.linux-foundation.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, stephen@networkplumber.org,
	sashok@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:32825 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbbGOOR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 10:17:59 -0400
Received: by pdbqm3 with SMTP id qm3so25896795pdb.0
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 07:17:58 -0700 (PDT)
In-Reply-To: <1436969811-13237-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Ashok <sashok@cumulusnetworks.com>

When the bridge (or port) is brought down/up flush only temp entries and
leave the perm ones. Flush perm entries only when deleting the bridge
device or the associated port.

Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_if.c        |  1 +
 net/bridge/br_multicast.c | 27 ++++++++++++++++++++-------
 net/bridge/br_private.h   |  1 +
 3 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index a538cb1199a3..45e4757c6fd2 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -281,6 +281,7 @@ void br_dev_delete(struct net_device *dev, struct list_head *head)
 	br_fdb_delete_by_port(br, NULL, 0, 1);
 
 	br_vlan_flush(br);
+	br_multicast_dev_del(br);
 	del_timer_sync(&br->gc_timer);
 
 	br_sysfs_delbr(br->dev);
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 55903d91d0a8..0dd3cd90962c 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -916,6 +916,15 @@ void br_multicast_add_port(struct net_bridge_port *port)
 
 void br_multicast_del_port(struct net_bridge_port *port)
 {
+	struct net_bridge *br = port->br;
+	struct net_bridge_port_group *pg;
+	struct hlist_node *n;
+
+	/* Take care of the remaining groups, only perm ones should be left */
+	spin_lock_bh(&br->multicast_lock);
+	hlist_for_each_entry_safe(pg, n, &port->mglist, mglist)
+		br_multicast_del_pg(br, pg);
+	spin_unlock_bh(&br->multicast_lock);
 	del_timer_sync(&port->multicast_router_timer);
 }
 
@@ -955,7 +964,8 @@ void br_multicast_disable_port(struct net_bridge_port *port)
 
 	spin_lock(&br->multicast_lock);
 	hlist_for_each_entry_safe(pg, n, &port->mglist, mglist)
-		br_multicast_del_pg(br, pg);
+		if (pg->state == MDB_TEMPORARY)
+			br_multicast_del_pg(br, pg);
 
 	if (!hlist_unhashed(&port->rlist))
 		hlist_del_init_rcu(&port->rlist);
@@ -1732,12 +1742,6 @@ void br_multicast_open(struct net_bridge *br)
 
 void br_multicast_stop(struct net_bridge *br)
 {
-	struct net_bridge_mdb_htable *mdb;
-	struct net_bridge_mdb_entry *mp;
-	struct hlist_node *n;
-	u32 ver;
-	int i;
-
 	del_timer_sync(&br->multicast_router_timer);
 	del_timer_sync(&br->ip4_other_query.timer);
 	del_timer_sync(&br->ip4_own_query.timer);
@@ -1745,6 +1749,15 @@ void br_multicast_stop(struct net_bridge *br)
 	del_timer_sync(&br->ip6_other_query.timer);
 	del_timer_sync(&br->ip6_own_query.timer);
 #endif
+}
+
+void br_multicast_dev_del(struct net_bridge *br)
+{
+	struct net_bridge_mdb_htable *mdb;
+	struct net_bridge_mdb_entry *mp;
+	struct hlist_node *n;
+	u32 ver;
+	int i;
 
 	spin_lock_bh(&br->multicast_lock);
 	mdb = mlock_dereference(br->mdb, br);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c73fd785654d..2bada2279721 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -466,6 +466,7 @@ void br_multicast_disable_port(struct net_bridge_port *port);
 void br_multicast_init(struct net_bridge *br);
 void br_multicast_open(struct net_bridge *br);
 void br_multicast_stop(struct net_bridge *br);
+void br_multicast_dev_del(struct net_bridge *br);
 void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
 			  struct sk_buff *skb);
 void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
-- 
1.9.3
