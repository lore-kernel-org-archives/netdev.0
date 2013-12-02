From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 6/7] bridge: Properly check if local fdb entry can be deleted in br_fdb_delete_by_port
Date: Mon,  2 Dec 2013 15:40:37 +0900
Message-ID: <1385966439-26526-7-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:56248 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817Ab3LBGl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 01:41:59 -0500
In-Reply-To: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_fdb_delete_by_port() doesn't care about vlan and mac addresses of the
bridge device.

We can use the same logic as other codes to check if a local entry can
be deleted.
To share the code, create __fdb_delete_local() and call it from
fdb_delete_local() and br_fdb_delete_by_port().

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_fdb.c | 52 ++++++++++++++++++++++++----------------------------
 1 file changed, 24 insertions(+), 28 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index d39b525..d87d4cd 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -92,19 +92,14 @@ static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 	call_rcu(&f->rcu, fdb_rcu_free);
 }
 
-/* Delete a local entry if no other port had the same address. */
-static void fdb_delete_local(struct net_bridge *br,
-			     const struct net_bridge_port *p,
-			     const unsigned char *addr, u16 vid)
+static void __fdb_delete_local(struct net_bridge *br,
+			       const struct net_bridge_port *p,
+			       struct net_bridge_fdb_entry *f)
 {
-	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
-	struct net_bridge_fdb_entry *f;
+	const unsigned char *addr = f->addr.addr;
+	u16 vid = f->vlan_id;
 	struct net_bridge_port *op;
 
-	f = fdb_find(head, addr, vid);
-	if (!f || !f->is_local || f->dst != p)
-		return;
-
 	/* Maybe another port has same hw addr? */
 	list_for_each_entry(op, &br->port_list, list) {
 		if (op != p && ether_addr_equal(op->dev->dev_addr, addr) &&
@@ -124,6 +119,21 @@ static void fdb_delete_local(struct net_bridge *br,
 	fdb_delete(br, f);
 }
 
+/* Delete a local entry if no other port had the same address. */
+static void fdb_delete_local(struct net_bridge *br,
+			     const struct net_bridge_port *p,
+			     const unsigned char *addr, u16 vid)
+{
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
+	struct net_bridge_fdb_entry *f;
+
+	f = fdb_find(head, addr, vid);
+	if (!f || !f->is_local || f->dst != p)
+		return;
+
+	__fdb_delete_local(br, p, f);
+}
+
 void br_fdb_change_locals(struct net_bridge *br, struct net_bridge_port *p,
 			  const unsigned char *oldaddr,
 			  const unsigned char *newaddr)
@@ -226,25 +236,11 @@ void br_fdb_delete_by_port(struct net_bridge *br,
 
 			if (f->is_static && !do_all)
 				continue;
-			/*
-			 * if multiple ports all have the same device address
-			 * then when one port is deleted, assign
-			 * the local entry to other port
-			 */
-			if (f->is_local) {
-				struct net_bridge_port *op;
-				list_for_each_entry(op, &br->port_list, list) {
-					if (op != p &&
-					    ether_addr_equal(op->dev->dev_addr,
-							     f->addr.addr)) {
-						f->dst = op;
-						goto skip_delete;
-					}
-				}
-			}
 
-			fdb_delete(br, f);
-		skip_delete: ;
+			if (f->is_local)
+				__fdb_delete_local(br, p, f);
+			else
+				fdb_delete(br, f);
 		}
 	}
 	spin_unlock_bh(&br->hash_lock);
-- 
1.8.1.2
