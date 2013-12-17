From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net v2 7/9] bridge: Properly check if local fdb entry can be deleted in br_fdb_delete_by_port
Date: Tue, 17 Dec 2013 21:03:39 +0900
Message-ID: <1387281821-21342-8-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:60423 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab3LQME0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 07:04:26 -0500
In-Reply-To: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_fdb_delete_by_port() doesn't care about vlan and mac address of the
bridge device.

As the check is almost the same as mac address changing, slightly modify
fdb_delete_local() and use it.

Note:
- We change the dst of a local entry when the same address is found.
  This occurs in the case kernel has inserted the same address for another
  port but has failed due to dup. We can regard changing dst as deleting
  old one and inserting new one that should have been added by the dup
  port, so we can always set its added_by_user to 0 in fdb_delete_local().

- This is a slight change in behavior where the bridge device can receive
  the traffic to the old address during the short window between calling
  del_nbp() and br_stp_recalculate_bridge_id() in br_del_if(). However,
  it is not a problem because we still have the address on the bridge device.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_fdb.c | 25 ++++++-------------------
 1 file changed, 6 insertions(+), 19 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 817f138..bd43cb1 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -103,6 +103,7 @@ static void fdb_delete_local(struct net_bridge *br,
 		if (op != p && ether_addr_equal(op->dev->dev_addr, addr) &&
 		    (!vid || nbp_vlan_find(op, vid))) {
 			f->dst = op;
+			f->added_by_user = 0;
 			return;
 		}
 	}
@@ -111,6 +112,7 @@ static void fdb_delete_local(struct net_bridge *br,
 	if (p && ether_addr_equal(br->dev->dev_addr, addr) &&
 	    (!vid || br_vlan_find(br, vid))) {
 		f->dst = NULL;
+		f->added_by_user = 0;
 		return;
 	}
 
@@ -261,26 +263,11 @@ void br_fdb_delete_by_port(struct net_bridge *br,
 
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
-						f->added_by_user = 0;
-						goto skip_delete;
-					}
-				}
-			}
 
-			fdb_delete(br, f);
-		skip_delete: ;
+			if (f->is_local)
+				fdb_delete_local(br, p, f);
+			else
+				fdb_delete(br, f);
 		}
 	}
 	spin_unlock_bh(&br->hash_lock);
-- 
1.8.1.2
