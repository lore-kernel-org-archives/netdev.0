From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC 1/7] net neighbor: convert top level list to RCU
Date: Mon, 14 Aug 2006 14:20:05 -0700
Message-ID: <20060814212142.992058651@localhost.localdomain>
References: <20060814212004.606140865@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58345 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964964AbWHNVYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:24:25 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=neigh-top-lock.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the top level list of neighbor tables to use RCU.
Minor change to BUG() if a neighbor table is registered twice.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 include/net/neighbour.h |    2 -
 net/core/neighbour.c    |   89 ++++++++++++++++++++++--------------------------
 2 files changed, 42 insertions(+), 49 deletions(-)

--- net-2.6.19.orig/net/core/neighbour.c
+++ net-2.6.19/net/core/neighbour.c
@@ -61,7 +61,7 @@ static void neigh_app_notify(struct neig
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 
-static struct neigh_table *neigh_tables;
+static LIST_HEAD(neigh_tables);
 #ifdef CONFIG_PROC_FS
 static struct file_operations neigh_stat_seq_fops;
 #endif
@@ -93,11 +93,11 @@ static struct file_operations neigh_stat
    It is supposed, that dev->hard_header is simplistic and does
    not make callbacks to neighbour tables.
 
-   The last lock is neigh_tbl_lock. It is pure SMP lock, protecting
-   list of neighbour tables. This list is used only in process context,
+   The last lock is neigh_tbl_lock. It controls update to the
+   set of neighbor tables. Typically used during initialization
  */
 
-static DEFINE_RWLOCK(neigh_tbl_lock);
+static DEFINE_SPINLOCK(neigh_tbl_lock);
 
 static int neigh_blackhole(struct sk_buff *skb)
 {
@@ -1391,26 +1391,18 @@ void neigh_table_init(struct neigh_table
 	struct neigh_table *tmp;
 
 	neigh_table_init_no_netlink(tbl);
-	write_lock(&neigh_tbl_lock);
-	for (tmp = neigh_tables; tmp; tmp = tmp->next) {
-		if (tmp->family == tbl->family)
-			break;
-	}
-	tbl->next	= neigh_tables;
-	neigh_tables	= tbl;
-	write_unlock(&neigh_tbl_lock);
-
-	if (unlikely(tmp)) {
-		printk(KERN_ERR "NEIGH: Registering multiple tables for "
-		       "family %d\n", tbl->family);
-		dump_stack();
+
+	spin_lock(&neigh_tbl_lock);
+	list_for_each_entry(tmp, &neigh_tables, list) {
+		BUG_ON(tmp->family == tbl->family);
 	}
+
+	list_add_rcu(&tbl->list, &neigh_tables);
+	spin_unlock(&neigh_tbl_lock);
 }
 
 int neigh_table_clear(struct neigh_table *tbl)
 {
-	struct neigh_table **tp;
-
 	/* It is not clean... Fix it to unload IPv6 module safely */
 	del_timer_sync(&tbl->gc_timer);
 	del_timer_sync(&tbl->proxy_timer);
@@ -1418,14 +1410,12 @@ int neigh_table_clear(struct neigh_table
 	neigh_ifdown(tbl, NULL);
 	if (atomic_read(&tbl->entries))
 		printk(KERN_CRIT "neighbour leakage\n");
-	write_lock(&neigh_tbl_lock);
-	for (tp = &neigh_tables; *tp; tp = &(*tp)->next) {
-		if (*tp == tbl) {
-			*tp = tbl->next;
-			break;
-		}
-	}
-	write_unlock(&neigh_tbl_lock);
+
+	spin_lock(&neigh_tbl_lock);
+	list_del_rcu(&tbl->list);
+	spin_unlock(&neigh_tbl_lock);
+
+	synchronize_rcu();
 
 	neigh_hash_free(tbl->hash_buckets, tbl->hash_mask + 1);
 	tbl->hash_buckets = NULL;
@@ -1460,13 +1450,12 @@ int neigh_delete(struct sk_buff *skb, st
 		}
 	}
 
-	read_lock(&neigh_tbl_lock);
-	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(tbl, &neigh_tables, list) {
 		struct neighbour *neigh;
 
 		if (tbl->family != ndm->ndm_family)
 			continue;
-		read_unlock(&neigh_tbl_lock);
 
 		if (nla_len(dst_attr) < tbl->key_len)
 			goto out_dev_put;
@@ -1491,12 +1480,12 @@ int neigh_delete(struct sk_buff *skb, st
 		neigh_release(neigh);
 		goto out_dev_put;
 	}
-	read_unlock(&neigh_tbl_lock);
 	err = -EAFNOSUPPORT;
 
 out_dev_put:
 	if (dev)
 		dev_put(dev);
+	rcu_read_unlock();
 out:
 	return err;
 }
@@ -1529,15 +1518,14 @@ int neigh_add(struct sk_buff *skb, struc
 			goto out_dev_put;
 	}
 
-	read_lock(&neigh_tbl_lock);
-	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(tbl, &neigh_tables, list) {
 		int flags = NEIGH_UPDATE_F_ADMIN | NEIGH_UPDATE_F_OVERRIDE;
 		struct neighbour *neigh;
 		void *dst, *lladdr;
 
 		if (tbl->family != ndm->ndm_family)
 			continue;
-		read_unlock(&neigh_tbl_lock);
 
 		if (nla_len(tb[NDA_DST]) < tbl->key_len)
 			goto out_dev_put;
@@ -1582,12 +1570,12 @@ int neigh_add(struct sk_buff *skb, struc
 		goto out_dev_put;
 	}
 
-	read_unlock(&neigh_tbl_lock);
 	err = -EAFNOSUPPORT;
 
 out_dev_put:
 	if (dev)
 		dev_put(dev);
+	rcu_read_unlock();
 out:
 	return err;
 }
@@ -1792,8 +1780,8 @@ int neightbl_set(struct sk_buff *skb, st
 	}
 
 	ndtmsg = nlmsg_data(nlh);
-	read_lock(&neigh_tbl_lock);
-	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(tbl, &neigh_tables, list) {
 		if (ndtmsg->ndtm_family && tbl->family != ndtmsg->ndtm_family)
 			continue;
 
@@ -1893,26 +1881,26 @@ int neightbl_set(struct sk_buff *skb, st
 errout_tbl_lock:
 	write_unlock_bh(&tbl->lock);
 errout_locked:
-	read_unlock(&neigh_tbl_lock);
+	rcu_read_unlock();
 errout:
 	return err;
 }
 
 int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int family, tidx, nidx = 0;
+	int family, tidx = 0, nidx = 0;
 	int tbl_skip = cb->args[0];
 	int neigh_skip = cb->args[1];
 	struct neigh_table *tbl;
 
 	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
 
-	read_lock(&neigh_tbl_lock);
-	for (tbl = neigh_tables, tidx = 0; tbl; tbl = tbl->next, tidx++) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(tbl, &neigh_tables, list) {
 		struct neigh_parms *p;
 
 		if (tidx < tbl_skip || (family && tbl->family != family))
-			continue;
+			goto next_tbl;
 
 		if (neightbl_fill_info(skb, tbl, NETLINK_CB(cb->skb).pid,
 				       cb->nlh->nlmsg_seq, RTM_NEWNEIGHTBL,
@@ -1932,9 +1920,11 @@ int neightbl_dump_info(struct sk_buff *s
 		}
 
 		neigh_skip = 0;
+next_tbl:
+		++tidx;
 	}
 out:
-	read_unlock(&neigh_tbl_lock);
+	rcu_read_unlock();
 	cb->args[0] = tidx;
 	cb->args[1] = nidx;
 
@@ -2024,22 +2014,25 @@ out:
 int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct neigh_table *tbl;
-	int t, family, s_t;
+	int t = 0, family, s_t;
+
 
-	read_lock(&neigh_tbl_lock);
 	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
 	s_t = cb->args[0];
 
-	for (tbl = neigh_tables, t = 0; tbl; tbl = tbl->next, t++) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(tbl, &neigh_tables, list) {
 		if (t < s_t || (family && tbl->family != family))
-			continue;
+			goto next;
 		if (t > s_t)
 			memset(&cb->args[1], 0, sizeof(cb->args) -
 						sizeof(cb->args[0]));
 		if (neigh_dump_table(tbl, skb, cb) < 0)
 			break;
+next:
+		++t;
 	}
-	read_unlock(&neigh_tbl_lock);
+	rcu_read_unlock();
 
 	cb->args[0] = t;
 	return skb->len;
--- net-2.6.19.orig/include/net/neighbour.h
+++ net-2.6.19/include/net/neighbour.h
@@ -136,7 +136,7 @@ struct pneigh_entry
 
 struct neigh_table
 {
-	struct neigh_table	*next;
+	struct list_head	list;
 	int			family;
 	int			entry_size;
 	int			key_len;

--

