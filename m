From: Salam Noureddine <noureddine@arista.com>
Subject: [PATCH net-next 3/4] net: core: introduce neigh_ifdown_all for all down interfaces
Date: Mon,  1 Feb 2016 14:32:31 -0800
Message-ID: <1454365952-10324-4-git-send-email-noureddine@arista.com>
References: <1454365952-10324-1-git-send-email-noureddine@arista.com>
Cc: Salam Noureddine <noureddine@arista.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:24225 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752203AbcBAWda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 17:33:30 -0500
In-Reply-To: <1454365952-10324-1-git-send-email-noureddine@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This cleans up neighbour entries for all interfaces in the down
state, avoiding walking the whole neighbour table for each interface
being brought down.

Signed-off-by: Salam Noureddine <noureddine@arista.com>
---
 include/net/arp.h       |  1 +
 include/net/neighbour.h |  1 +
 net/core/neighbour.c    | 38 +++++++++++++++++++++++++++++++-------
 net/ipv4/arp.c          |  4 ++++
 4 files changed, 37 insertions(+), 7 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 5e0f891..0efee66 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -43,6 +43,7 @@ void arp_send(int type, int ptype, __be32 dest_ip,
 	      const unsigned char *src_hw, const unsigned char *th);
 int arp_mc_map(__be32 addr, u8 *haddr, struct net_device *dev, int dir);
 void arp_ifdown(struct net_device *dev);
+void arp_ifdown_all(void);
 
 struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 			   struct net_device *dev, __be32 src_ip,
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 8b68384..8785d7b 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -318,6 +318,7 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new, u32 flags);
 void __neigh_set_probe_once(struct neighbour *neigh);
 void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
+int neigh_ifdown_all(struct neigh_table *tbl);
 int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb);
 int neigh_connected_output(struct neighbour *neigh, struct sk_buff *skb);
 int neigh_direct_output(struct neighbour *neigh, struct sk_buff *skb);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f18ae91..bfbd97a 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -54,7 +54,8 @@ do {						\
 static void neigh_timer_handler(unsigned long arg);
 static void __neigh_notify(struct neighbour *n, int type, int flags);
 static void neigh_update_notify(struct neighbour *neigh);
-static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
+static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev,
+			 bool all_down);
 
 #ifdef CONFIG_PROC_FS
 static const struct file_operations neigh_stat_seq_fops;
@@ -192,7 +193,8 @@ static void pneigh_queue_purge(struct sk_buff_head *list)
 	}
 }
 
-static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
+static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev,
+			    bool all_down)
 {
 	int i;
 	struct neigh_hash_table *nht;
@@ -210,6 +212,12 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 				np = &n->next;
 				continue;
 			}
+			if (!dev && n->dev && all_down) {
+				if (n->dev->flags & IFF_UP) {
+					np = &n->next;
+					continue;
+				}
+			}
 			rcu_assign_pointer(*np,
 				   rcu_dereference_protected(n->next,
 						lockdep_is_held(&tbl->lock)));
@@ -245,7 +253,7 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
 void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev)
 {
 	write_lock_bh(&tbl->lock);
-	neigh_flush_dev(tbl, dev);
+	neigh_flush_dev(tbl, dev, false);
 	write_unlock_bh(&tbl->lock);
 }
 EXPORT_SYMBOL(neigh_changeaddr);
@@ -253,8 +261,8 @@ EXPORT_SYMBOL(neigh_changeaddr);
 int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 {
 	write_lock_bh(&tbl->lock);
-	neigh_flush_dev(tbl, dev);
-	pneigh_ifdown(tbl, dev);
+	neigh_flush_dev(tbl, dev, false);
+	pneigh_ifdown(tbl, dev, false);
 	write_unlock_bh(&tbl->lock);
 
 	del_timer_sync(&tbl->proxy_timer);
@@ -263,6 +271,19 @@ int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 }
 EXPORT_SYMBOL(neigh_ifdown);
 
+int neigh_ifdown_all(struct neigh_table *tbl)
+{
+	write_lock_bh(&tbl->lock);
+	neigh_flush_dev(tbl, NULL, true);
+	pneigh_ifdown(tbl, NULL, true);
+	write_unlock_bh(&tbl->lock);
+
+	del_timer_sync(&tbl->proxy_timer);
+	pneigh_queue_purge(&tbl->proxy_queue);
+	return 0;
+}
+EXPORT_SYMBOL(neigh_ifdown_all);
+
 static struct neighbour *neigh_alloc(struct neigh_table *tbl, struct net_device *dev)
 {
 	struct neighbour *n = NULL;
@@ -645,7 +666,8 @@ int pneigh_delete(struct neigh_table *tbl, struct net *net, const void *pkey,
 	return -ENOENT;
 }
 
-static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
+static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev,
+			 bool all_down)
 {
 	struct pneigh_entry *n, **np;
 	u32 h;
@@ -653,7 +675,9 @@ static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 	for (h = 0; h <= PNEIGH_HASHMASK; h++) {
 		np = &tbl->phash_buckets[h];
 		while ((n = *np) != NULL) {
-			if (!dev || n->dev == dev) {
+			if ((!dev && !all_down) || (all_down && n->dev &&
+						    !(n->dev->flags & IFF_UP)) ||
+			    n->dev == dev) {
 				*np = n->next;
 				if (tbl->pdestructor)
 					tbl->pdestructor(n);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 59b3e0e..1328244 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1219,6 +1219,10 @@ void arp_ifdown(struct net_device *dev)
 	neigh_ifdown(&arp_tbl, dev);
 }
 
+void arp_ifdown_all(void)
+{
+	neigh_ifdown_all(&arp_tbl);
+}
 
 /*
  *	Called once on startup.
-- 
1.8.1.4
