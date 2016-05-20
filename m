From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [PATCH][3.13.y-ckt][PATCH 1/1] bridge: Fix the way to find old local fdb entries in br_fdb_changeaddr
Date: Fri, 20 May 2016 12:59:37 -0400
Message-ID: <903d05de6310fe2491c160713e918f87f32a4090.1463760264.git.joseph.salisbury__45513.5806966156$1463763838$gmane$org@canonical.com>
References: <cover.1463760264.git.joseph.salisbury@canonical.com>
Cc: stable@vger.kernel.org, jmaxwell37@gmail.com, jiri@resnulli.us,
	makita.toshiaki@lab.ntt.co.jp, stephen@networkplumber.org,
	davem@davemloft.net, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kamal.mostafa@canonical.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <cover.1463760264.git.joseph.salisbury@canonical.com>
In-Reply-To: <cover.1463760264.git.joseph.salisbury@canonical.com>
References: <cover.1463760264.git.joseph.salisbury@canonical.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

BugLink: http://bugs.launchpad.net/bugs/1581585

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

Note that br_fdb_delete_by_port() has to set added_by_user to 0 in cases
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
Signed-off-by: David S. Miller <davem@davemloft.net>
(backported from commit a5642ab4744bc8c5a8c7ce7c6e30c01bd6bbc691)
Signed-off-by: Joseph Salisbury <joseph.salisbury@canonical.com>
---
 net/bridge/br_fdb.c     | 16 ++++++++++++----
 net/bridge/br_input.c   |  8 ++++----
 net/bridge/br_private.h |  3 ++-
 3 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 62c444d..551a27d 100644
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
@@ -447,7 +449,7 @@ int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 }
 
 void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
-		   const unsigned char *addr, u16 vid)
+		   const unsigned char *addr, u16 vid, bool added_by_user)
 {
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
@@ -473,13 +475,18 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 			/* fastpath: update of existing entry */
 			fdb->dst = source;
 			fdb->updated = jiffies;
+			if (unlikely(added_by_user))
+				fdb->added_by_user = 1;
 		}
 	} else {
 		spin_lock(&br->hash_lock);
 		if (likely(!fdb_find(head, addr, vid))) {
 			fdb = fdb_create(head, source, addr, vid);
-			if (fdb)
+			if (fdb) {
+				if (unlikely(added_by_user))
+					fdb->added_by_user = 1;
 				fdb_notify(br, fdb, RTM_NEWNEIGH);
+			}
 		}
 		/* else  we lose race and someone else inserts
 		 * it first, don't bother updating
@@ -648,6 +655,7 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 
 		modified = true;
 	}
+	fdb->added_by_user = 1;
 
 	fdb->used = jiffies;
 	if (modified) {
@@ -666,7 +674,7 @@ static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge_port *p,
 	if (ndm->ndm_flags & NTF_USE) {
 		local_bh_disable();
 		rcu_read_lock();
-		br_fdb_update(p->br, p, addr, vid);
+		br_fdb_update(p->br, p, addr, vid, true);
 		rcu_read_unlock();
 		local_bh_enable();
 	} else {
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 2bc64f8..ab0ee7d 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -77,7 +77,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
 	if (p->flags & BR_LEARNING)
-		br_fdb_update(br, p, eth_hdr(skb)->h_source, vid);
+		br_fdb_update(br, p, eth_hdr(skb)->h_source, vid, false);
 
 	if (!is_broadcast_ether_addr(dest) && is_multicast_ether_addr(dest) &&
 	    br_multicast_rcv(br, p, skb, vid))
@@ -146,9 +146,9 @@ static int br_handle_local_finish(struct sk_buff *skb)
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 	u16 vid = 0;
 
-	/* check if vlan is allowed, to avoid spoofing */
-	if (p->flags & BR_LEARNING && br_should_learn(p, skb, &vid))
-		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid);
+	br_vlan_get_tag(skb, &vid);
+	if (p->flags & BR_LEARNING)
+		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid, false);
 	return 0;	 /* process further */
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 59788d6..a932c46 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -105,6 +105,7 @@ struct net_bridge_fdb_entry
 	mac_addr			addr;
 	unsigned char			is_local;
 	unsigned char			is_static;
+	unsigned char			added_by_user;
 	__u16				vlan_id;
 };
 
@@ -398,7 +399,7 @@ int br_fdb_fillbuf(struct net_bridge *br, void *buf, unsigned long count,
 int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
 		  const unsigned char *addr, u16 vid);
 void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
-		   const unsigned char *addr, u16 vid);
+		   const unsigned char *addr, u16 vid, bool added_by_user);
 int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr, u16 vid);
 
 int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
-- 
2.7.4
