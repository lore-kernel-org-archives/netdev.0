From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net v2 1/9] bridge: Fix the way to find old local fdb entries in br_fdb_changeaddr
Date: Tue, 17 Dec 2013 21:03:33 +0900
Message-ID: <1387281821-21342-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:60420 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab3LQME0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 07:04:26 -0500
In-Reply-To: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_fdb_changeaddr() assumes that there is at most one local entry per port
per vlan. It used to be true, but since commit 36fd2b63e3b4 ("bridge: allow
creating/deleting fdb entries via netlink"), it has not been so.
Therefore, the function might fail to search a correct previous address
to be deleted and delete an arbitrary local entry if user has added local
entries manually.

Example of problematic case:
  ip link set eth0 address ee:ff:12:34:56:78
  brctl addif br0 eth0
  bridge fdb add 12:34:56:78:90:ab dev eth0 master
  ip link set eth0 address aa:bb:cc:dd:ee:ff
Then, the address 12:34:56:78:90:ab might be deleted instead of
ee:ff:12:34:56:78, the original mac address of eth0.

Address this issue by introducing a new flag, added_by_user, to struct
net_bridge_fdb_entry.

Note that br_fdb_delete_by_port() has to set added_by_user to 0 in case
like:
  ip link set eth0 address 12:34:56:78:90:ab
  ip link set eth1 address aa:bb:cc:dd:ee:ff
  brctl addif br0 eth0
  bridge fdb add aa:bb:cc:dd:ee:ff dev eth0 master
  brctl addif br0 eth1
  brctl delif br0 eth0
In this case, kernel should delete the user-added entry aa:bb:cc:dd:ee:ff,
but it also should have been added by "brctl addif br0 eth1" originally,
so we don't delete it and treat it a new kernel-created entry.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_fdb.c     | 5 ++++-
 net/bridge/br_private.h | 1 +
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 33e8f23..5dab230 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -104,7 +104,7 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 			struct net_bridge_fdb_entry *f;
 
 			f = hlist_entry(h, struct net_bridge_fdb_entry, hlist);
-			if (f->dst == p && f->is_local) {
+			if (f->dst == p && f->is_local && !f->added_by_user) {
 				/* maybe another port has same hw addr? */
 				struct net_bridge_port *op;
 				u16 vid = f->vlan_id;
@@ -247,6 +247,7 @@ void br_fdb_delete_by_port(struct net_bridge *br,
 					    ether_addr_equal(op->dev->dev_addr,
 							     f->addr.addr)) {
 						f->dst = op;
+						f->added_by_user = 0;
 						goto skip_delete;
 					}
 				}
@@ -397,6 +398,7 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
 		fdb->vlan_id = vid;
 		fdb->is_local = 0;
 		fdb->is_static = 0;
+		fdb->added_by_user = 0;
 		fdb->updated = fdb->used = jiffies;
 		hlist_add_head_rcu(&fdb->hlist, head);
 	}
@@ -648,6 +650,7 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 
 		modified = true;
 	}
+	fdb->added_by_user = 1;
 
 	fdb->used = jiffies;
 	if (modified) {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 045d56e..91fb2c2 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -104,6 +104,7 @@ struct net_bridge_fdb_entry
 	mac_addr			addr;
 	unsigned char			is_local;
 	unsigned char			is_static;
+	unsigned char			added_by_user;
 	__u16				vlan_id;
 };
 
-- 
1.8.1.2
