From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net v2 2/9] bridge: Fix the way to insert new local fdb entries in br_fdb_changeaddr
Date: Tue, 17 Dec 2013 21:03:34 +0900
Message-ID: <1387281821-21342-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:60422 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab3LQME0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 07:04:26 -0500
In-Reply-To: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit bc9a25d21ef8 ("bridge: Add vlan support for local fdb entries"),
br_fdb_changeaddr() has inserted a new local fdb entry only if it can
find old one. But if we have two ports where they have the same address
or user has deleted a local entry, there will be no entry for one of the
ports.

Example of problematic case:
  ip link set eth0 address aa:bb:cc:dd:ee:ff
  ip link set eth1 address aa:bb:cc:dd:ee:ff
  brctl addif br0 eth0
  brctl addif br0 eth1 # eth1 will not have a local entry due to dup.
  ip link set eth1 address 12:34:56:78:90:ab
Then, the new entry for the address 12:34:56:78:90:ab will not be
created, and the bridge device will not be able to communicate.

Insert new entries regardless of whether we can find old entries or not.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_fdb.c | 29 ++++++++++++++++++++---------
 1 file changed, 20 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 5dab230..5f1bd11 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -92,8 +92,10 @@ static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 {
 	struct net_bridge *br = p->br;
-	bool no_vlan = (nbp_get_vlan_info(p) == NULL) ? true : false;
+	struct net_port_vlans *pv = nbp_get_vlan_info(p);
+	bool no_vlan = !pv;
 	int i;
+	u16 vid;
 
 	spin_lock_bh(&br->hash_lock);
 
@@ -114,28 +116,37 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 							     f->addr.addr) &&
 					    nbp_vlan_find(op, vid)) {
 						f->dst = op;
-						goto insert;
+						goto skip_delete;
 					}
 				}
 
 				/* delete old one */
 				fdb_delete(br, f);
-insert:
-				/* insert new address,  may fail if invalid
-				 * address or dup.
-				 */
-				fdb_insert(br, p, newaddr, vid);
-
+skip_delete:
 				/* if this port has no vlan information
 				 * configured, we can safely be done at
 				 * this point.
 				 */
 				if (no_vlan)
-					goto done;
+					goto insert;
 			}
 		}
 	}
 
+insert:
+	/* insert new address,  may fail if invalid address or dup. */
+	fdb_insert(br, p, newaddr, 0);
+
+	if (no_vlan)
+		goto done;
+
+	/* Now add entries for every VLAN configured on the port.
+	 * This function runs under RTNL so the bitmap will not change
+	 * from under us.
+	 */
+	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID)
+		fdb_insert(br, p, newaddr, vid);
+
 done:
 	spin_unlock_bh(&br->hash_lock);
 }
-- 
1.8.1.2
