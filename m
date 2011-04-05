From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/7] bridge: split rcu and no-rcu cases of fdb lookup
Date: Mon, 04 Apr 2011 17:03:29 -0700
Message-ID: <20110405000537.187138133@vyatta.com>
References: <20110405000326.714524584@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42823 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750846Ab1DEAJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 20:09:50 -0400
Content-Disposition: inline; filename=br-fdb-norcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases, look up of forward database entry is done with RCU;
and for others no RCU is needed because of locking. Split the two
cases into two differnt loops (and take off inline).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_fdb.c	2011-03-21 10:36:51.109460181 -0700
+++ b/net/bridge/br_fdb.c	2011-03-21 10:37:11.872443564 -0700
@@ -305,8 +305,21 @@ int br_fdb_fillbuf(struct net_bridge *br
 	return num;
 }
 
-static inline struct net_bridge_fdb_entry *fdb_find(struct hlist_head *head,
-						    const unsigned char *addr)
+static struct net_bridge_fdb_entry *fdb_find(struct hlist_head *head,
+					     const unsigned char *addr)
+{
+	struct hlist_node *h;
+	struct net_bridge_fdb_entry *fdb;
+
+	hlist_for_each_entry(fdb, h, head, hlist) {
+		if (!compare_ether_addr(fdb->addr.addr, addr))
+			return fdb;
+	}
+	return NULL;
+}
+
+static struct net_bridge_fdb_entry *fdb_find_rcu(struct hlist_head *head,
+						 const unsigned char *addr)
 {
 	struct hlist_node *h;
 	struct net_bridge_fdb_entry *fdb;
@@ -393,7 +406,7 @@ void br_fdb_update(struct net_bridge *br
 	      source->state == BR_STATE_FORWARDING))
 		return;
 
-	fdb = fdb_find(head, addr);
+	fdb = fdb_find_rcu(head, addr);
 	if (likely(fdb)) {
 		/* attempt to update an entry for a local interface */
 		if (unlikely(fdb->is_local)) {


