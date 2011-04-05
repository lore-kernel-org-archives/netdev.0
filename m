From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/7] bridge: change arguments to fdb_create
Date: Mon, 04 Apr 2011 17:03:27 -0700
Message-ID: <20110405000537.001922245@vyatta.com>
References: <20110405000326.714524584@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42820 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899Ab1DEAJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 20:09:50 -0400
Content-Disposition: inline; filename=br-fdb-reorg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Later patch provides ability to create non-local static entry.
To make this easier move the updating of the flag values to
after the code that creates entry.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_fdb.c	2011-03-21 09:04:33.000000000 -0700
+++ b/net/bridge/br_fdb.c	2011-03-21 10:36:09.359041121 -0700
@@ -320,8 +320,7 @@ static inline struct net_bridge_fdb_entr
 
 static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 					       struct net_bridge_port *source,
-					       const unsigned char *addr,
-					       int is_local)
+					       const unsigned char *addr)
 {
 	struct net_bridge_fdb_entry *fdb;
 
@@ -329,10 +328,9 @@ static struct net_bridge_fdb_entry *fdb_
 	if (fdb) {
 		memcpy(fdb->addr.addr, addr, ETH_ALEN);
 		fdb->dst = source;
-		fdb->is_local = is_local;
-		fdb->is_static = is_local;
+		fdb->is_local = 0;
+		fdb->is_static = 0;
 		fdb->ageing_timer = jiffies;
-
 		hlist_add_head_rcu(&fdb->hlist, head);
 	}
 	return fdb;
@@ -360,12 +358,15 @@ static int fdb_insert(struct net_bridge
 		fdb_delete(fdb);
 	}
 
-	if (!fdb_create(head, source, addr, 1))
+	fdb = fdb_create(head, source, addr);
+	if (!fdb)
 		return -ENOMEM;
 
+	fdb->is_local = fdb->is_static = 1;
 	return 0;
 }
 
+/* Add entry for local address of interface */
 int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		  const unsigned char *addr)
 {
@@ -407,8 +408,9 @@ void br_fdb_update(struct net_bridge *br
 		}
 	} else {
 		spin_lock(&br->hash_lock);
-		if (!fdb_find(head, addr))
-			fdb_create(head, source, addr, 0);
+		if (likely(!fdb_find(head, addr)))
+			fdb_create(head, source, addr);
+
 		/* else  we lose race and someone else inserts
 		 * it first, don't bother updating
 		 */


