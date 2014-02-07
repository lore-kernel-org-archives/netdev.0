From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v3 net 6/9] bridge: Properly check if local fdb entry can be deleted in br_fdb_change_mac_address
Date: Fri,  7 Feb 2014 16:48:23 +0900
Message-ID: <1391759306-24956-7-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:46705 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbaBGHss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 02:48:48 -0500
In-Reply-To: <1391759306-24956-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_fdb_change_mac_address() doesn't check if the local entry has the
same address as any of bridge ports.
Although I'm not sure when it is beneficial, current implementation allow
the bridge device to receive any mac address of its ports.
To preserve this behavior, we have to check if the mac address of the
entry being deleted is identical to that of any port.

As this check is almost the same as that in br_fdb_changeaddr(), create
a common function fdb_delete_local() and call it from
br_fdb_changeadddr() and br_fdb_change_mac_address().

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Acked-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_fdb.c | 57 ++++++++++++++++++++++++++++++-----------------------
 1 file changed, 32 insertions(+), 25 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index b4005f5..15bf13d 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -89,6 +89,34 @@ static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 	call_rcu(&f->rcu, fdb_rcu_free);
 }
 
+/* Delete a local entry if no other port had the same address. */
+static void fdb_delete_local(struct net_bridge *br,
+			     const struct net_bridge_port *p,
+			     struct net_bridge_fdb_entry *f)
+{
+	const unsigned char *addr = f->addr.addr;
+	u16 vid = f->vlan_id;
+	struct net_bridge_port *op;
+
+	/* Maybe another port has same hw addr? */
+	list_for_each_entry(op, &br->port_list, list) {
+		if (op != p && ether_addr_equal(op->dev->dev_addr, addr) &&
+		    (!vid || nbp_vlan_find(op, vid))) {
+			f->dst = op;
+			return;
+		}
+	}
+
+	/* Maybe bridge device has same hw addr? */
+	if (p && ether_addr_equal(br->dev->dev_addr, addr) &&
+	    (!vid || br_vlan_find(br, vid))) {
+		f->dst = NULL;
+		return;
+	}
+
+	fdb_delete(br, f);
+}
+
 void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 {
 	struct net_bridge *br = p->br;
@@ -107,30 +135,9 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 
 			f = hlist_entry(h, struct net_bridge_fdb_entry, hlist);
 			if (f->dst == p && f->is_local && !f->added_by_user) {
-				/* maybe another port has same hw addr? */
-				struct net_bridge_port *op;
-				u16 vid = f->vlan_id;
-				list_for_each_entry(op, &br->port_list, list) {
-					if (op != p &&
-					    ether_addr_equal(op->dev->dev_addr,
-							     f->addr.addr) &&
-					    (!vid || nbp_vlan_find(op, vid))) {
-						f->dst = op;
-						goto skip_delete;
-					}
-				}
-
-				/* maybe bridge device has same hw addr? */
-				if (ether_addr_equal(br->dev->dev_addr,
-						     f->addr.addr) &&
-				    (!vid || br_vlan_find(br, vid))) {
-					f->dst = NULL;
-					goto skip_delete;
-				}
-
 				/* delete old one */
-				fdb_delete(br, f);
-skip_delete:
+				fdb_delete_local(br, p, f);
+
 				/* if this port has no vlan information
 				 * configured, we can safely be done at
 				 * this point.
@@ -168,7 +175,7 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	/* If old entry was unassociated with any port, then delete it. */
 	f = __br_fdb_get(br, br->dev->dev_addr, 0);
 	if (f && f->is_local && !f->dst)
-		fdb_delete(br, f);
+		fdb_delete_local(br, NULL, f);
 
 	fdb_insert(br, NULL, newaddr, 0);
 
@@ -183,7 +190,7 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	for_each_set_bit_from(vid, pv->vlan_bitmap, VLAN_N_VID) {
 		f = __br_fdb_get(br, br->dev->dev_addr, vid);
 		if (f && f->is_local && !f->dst)
-			fdb_delete(br, f);
+			fdb_delete_local(br, NULL, f);
 		fdb_insert(br, NULL, newaddr, vid);
 	}
 }
-- 
1.8.1.2
