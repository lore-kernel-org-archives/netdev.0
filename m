From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v3] neigh: remove dynamic neigh table registration support
Date: Mon, 10 Nov 2014 15:59:36 -0800
Message-ID: <1415663976-7507-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:63488 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbaKJX7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 18:59:40 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so9393276pab.0
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 15:59:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there are only three neigh tables in the whole kernel:
arp table, ndisc table and decnet neigh table. What's more,
we don't support registering multiple tables per family.
Therefore we can just make these tables statically built-in.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
v3: fix neigh_table_clear()
v2: remove useless #ifdef's
    move the assignment to the end of neigh_table_init()

 include/net/neighbour.h |  11 ++-
 net/core/neighbour.c    | 247 ++++++++++++++++++++++--------------------------
 net/decnet/dn_neigh.c   |   4 +-
 net/ipv4/arp.c          |   2 +-
 net/ipv6/ndisc.c        |   4 +-
 5 files changed, 126 insertions(+), 142 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index dedfb18..eb070b3 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -220,6 +220,13 @@ struct neigh_table {
 	struct pneigh_entry	**phash_buckets;
 };
 
+enum {
+	NEIGH_ARP_TABLE = 0,
+	NEIGH_ND_TABLE = 1,
+	NEIGH_DN_TABLE = 2,
+	NEIGH_NR_TABLES,
+};
+
 static inline int neigh_parms_family(struct neigh_parms *p)
 {
 	return p->tbl->family;
@@ -240,8 +247,8 @@ static inline void *neighbour_priv(const struct neighbour *n)
 #define NEIGH_UPDATE_F_ISROUTER			0x40000000
 #define NEIGH_UPDATE_F_ADMIN			0x80000000
 
-void neigh_table_init(struct neigh_table *tbl);
-int neigh_table_clear(struct neigh_table *tbl);
+void neigh_table_init(int index, struct neigh_table *tbl);
+int neigh_table_clear(int index, struct neigh_table *tbl);
 struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 			       struct net_device *dev);
 struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index edd0411..8e38f17 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -56,7 +56,6 @@ static void __neigh_notify(struct neighbour *n, int type, int flags);
 static void neigh_update_notify(struct neighbour *neigh);
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 
-static struct neigh_table *neigh_tables;
 #ifdef CONFIG_PROC_FS
 static const struct file_operations neigh_stat_seq_fops;
 #endif
@@ -87,13 +86,8 @@ static const struct file_operations neigh_stat_seq_fops;
    the most complicated procedure, which we allow is dev->hard_header.
    It is supposed, that dev->hard_header is simplistic and does
    not make callbacks to neighbour tables.
-
-   The last lock is neigh_tbl_lock. It is pure SMP lock, protecting
-   list of neighbour tables. This list is used only in process context,
  */
 
-static DEFINE_RWLOCK(neigh_tbl_lock);
-
 static int neigh_blackhole(struct neighbour *neigh, struct sk_buff *skb)
 {
 	kfree_skb(skb);
@@ -1520,7 +1514,9 @@ static void neigh_parms_destroy(struct neigh_parms *parms)
 
 static struct lock_class_key neigh_table_proxy_queue_class;
 
-static void neigh_table_init_no_netlink(struct neigh_table *tbl)
+static struct neigh_table *neigh_tables[NEIGH_NR_TABLES] __read_mostly;
+
+void neigh_table_init(int index, struct neigh_table *tbl)
 {
 	unsigned long now = jiffies;
 	unsigned long phsize;
@@ -1566,34 +1562,14 @@ static void neigh_table_init_no_netlink(struct neigh_table *tbl)
 
 	tbl->last_flush = now;
 	tbl->last_rand	= now + tbl->parms.reachable_time * 20;
-}
-
-void neigh_table_init(struct neigh_table *tbl)
-{
-	struct neigh_table *tmp;
 
-	neigh_table_init_no_netlink(tbl);
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
-		pr_err("Registering multiple tables for family %d\n",
-		       tbl->family);
-		dump_stack();
-	}
+	neigh_tables[index] = tbl;
 }
 EXPORT_SYMBOL(neigh_table_init);
 
-int neigh_table_clear(struct neigh_table *tbl)
+int neigh_table_clear(int index, struct neigh_table *tbl)
 {
-	struct neigh_table **tp;
-
+	neigh_tables[index] = NULL;
 	/* It is not clean... Fix it to unload IPv6 module safely */
 	cancel_delayed_work_sync(&tbl->gc_work);
 	del_timer_sync(&tbl->proxy_timer);
@@ -1601,14 +1577,6 @@ int neigh_table_clear(struct neigh_table *tbl)
 	neigh_ifdown(tbl, NULL);
 	if (atomic_read(&tbl->entries))
 		pr_crit("neighbour leakage\n");
-	write_lock(&neigh_tbl_lock);
-	for (tp = &neigh_tables; *tp; tp = &(*tp)->next) {
-		if (*tp == tbl) {
-			*tp = tbl->next;
-			break;
-		}
-	}
-	write_unlock(&neigh_tbl_lock);
 
 	call_rcu(&rcu_dereference_protected(tbl->nht, 1)->rcu,
 		 neigh_hash_free_rcu);
@@ -1626,12 +1594,32 @@ int neigh_table_clear(struct neigh_table *tbl)
 }
 EXPORT_SYMBOL(neigh_table_clear);
 
+static struct neigh_table *neigh_find_table(int family)
+{
+	struct neigh_table *tbl = NULL;
+
+	switch (family) {
+	case AF_INET:
+		tbl = neigh_tables[NEIGH_ARP_TABLE];
+		break;
+	case AF_INET6:
+		tbl = neigh_tables[NEIGH_ND_TABLE];
+		break;
+	case AF_DECnet:
+		tbl = neigh_tables[NEIGH_DN_TABLE];
+		break;
+	}
+
+	return tbl;
+}
+
 static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
 	struct nlattr *dst_attr;
 	struct neigh_table *tbl;
+	struct neighbour *neigh;
 	struct net_device *dev = NULL;
 	int err = -EINVAL;
 
@@ -1652,39 +1640,31 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 	}
 
-	read_lock(&neigh_tbl_lock);
-	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
-		struct neighbour *neigh;
-
-		if (tbl->family != ndm->ndm_family)
-			continue;
-		read_unlock(&neigh_tbl_lock);
-
-		if (nla_len(dst_attr) < tbl->key_len)
-			goto out;
+	tbl = neigh_find_table(ndm->ndm_family);
+	if (tbl == NULL)
+		return -EAFNOSUPPORT;
 
-		if (ndm->ndm_flags & NTF_PROXY) {
-			err = pneigh_delete(tbl, net, nla_data(dst_attr), dev);
-			goto out;
-		}
+	if (nla_len(dst_attr) < tbl->key_len)
+		goto out;
 
-		if (dev == NULL)
-			goto out;
+	if (ndm->ndm_flags & NTF_PROXY) {
+		err = pneigh_delete(tbl, net, nla_data(dst_attr), dev);
+		goto out;
+	}
 
-		neigh = neigh_lookup(tbl, nla_data(dst_attr), dev);
-		if (neigh == NULL) {
-			err = -ENOENT;
-			goto out;
-		}
+	if (dev == NULL)
+		goto out;
 
-		err = neigh_update(neigh, NULL, NUD_FAILED,
-				   NEIGH_UPDATE_F_OVERRIDE |
-				   NEIGH_UPDATE_F_ADMIN);
-		neigh_release(neigh);
+	neigh = neigh_lookup(tbl, nla_data(dst_attr), dev);
+	if (neigh == NULL) {
+		err = -ENOENT;
 		goto out;
 	}
-	read_unlock(&neigh_tbl_lock);
-	err = -EAFNOSUPPORT;
+
+	err = neigh_update(neigh, NULL, NUD_FAILED,
+			   NEIGH_UPDATE_F_OVERRIDE |
+			   NEIGH_UPDATE_F_ADMIN);
+	neigh_release(neigh);
 
 out:
 	return err;
@@ -1692,11 +1672,14 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
+	int flags = NEIGH_UPDATE_F_ADMIN | NEIGH_UPDATE_F_OVERRIDE;
 	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
 	struct nlattr *tb[NDA_MAX+1];
 	struct neigh_table *tbl;
 	struct net_device *dev = NULL;
+	struct neighbour *neigh;
+	void *dst, *lladdr;
 	int err;
 
 	ASSERT_RTNL();
@@ -1720,70 +1703,60 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 			goto out;
 	}
 
-	read_lock(&neigh_tbl_lock);
-	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
-		int flags = NEIGH_UPDATE_F_ADMIN | NEIGH_UPDATE_F_OVERRIDE;
-		struct neighbour *neigh;
-		void *dst, *lladdr;
+	tbl = neigh_find_table(ndm->ndm_family);
+	if (tbl == NULL)
+		return -EAFNOSUPPORT;
 
-		if (tbl->family != ndm->ndm_family)
-			continue;
-		read_unlock(&neigh_tbl_lock);
+	if (nla_len(tb[NDA_DST]) < tbl->key_len)
+		goto out;
+	dst = nla_data(tb[NDA_DST]);
+	lladdr = tb[NDA_LLADDR] ? nla_data(tb[NDA_LLADDR]) : NULL;
 
-		if (nla_len(tb[NDA_DST]) < tbl->key_len)
-			goto out;
-		dst = nla_data(tb[NDA_DST]);
-		lladdr = tb[NDA_LLADDR] ? nla_data(tb[NDA_LLADDR]) : NULL;
+	if (ndm->ndm_flags & NTF_PROXY) {
+		struct pneigh_entry *pn;
+
+		err = -ENOBUFS;
+		pn = pneigh_lookup(tbl, net, dst, dev, 1);
+		if (pn) {
+			pn->flags = ndm->ndm_flags;
+			err = 0;
+		}
+		goto out;
+	}
 
-		if (ndm->ndm_flags & NTF_PROXY) {
-			struct pneigh_entry *pn;
+	if (dev == NULL)
+		goto out;
 
-			err = -ENOBUFS;
-			pn = pneigh_lookup(tbl, net, dst, dev, 1);
-			if (pn) {
-				pn->flags = ndm->ndm_flags;
-				err = 0;
-			}
+	neigh = neigh_lookup(tbl, dst, dev);
+	if (neigh == NULL) {
+		if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
+			err = -ENOENT;
 			goto out;
 		}
 
-		if (dev == NULL)
+		neigh = __neigh_lookup_errno(tbl, dst, dev);
+		if (IS_ERR(neigh)) {
+			err = PTR_ERR(neigh);
+			goto out;
+		}
+	} else {
+		if (nlh->nlmsg_flags & NLM_F_EXCL) {
+			err = -EEXIST;
+			neigh_release(neigh);
 			goto out;
-
-		neigh = neigh_lookup(tbl, dst, dev);
-		if (neigh == NULL) {
-			if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
-				err = -ENOENT;
-				goto out;
-			}
-
-			neigh = __neigh_lookup_errno(tbl, dst, dev);
-			if (IS_ERR(neigh)) {
-				err = PTR_ERR(neigh);
-				goto out;
-			}
-		} else {
-			if (nlh->nlmsg_flags & NLM_F_EXCL) {
-				err = -EEXIST;
-				neigh_release(neigh);
-				goto out;
-			}
-
-			if (!(nlh->nlmsg_flags & NLM_F_REPLACE))
-				flags &= ~NEIGH_UPDATE_F_OVERRIDE;
 		}
 
-		if (ndm->ndm_flags & NTF_USE) {
-			neigh_event_send(neigh, NULL);
-			err = 0;
-		} else
-			err = neigh_update(neigh, lladdr, ndm->ndm_state, flags);
-		neigh_release(neigh);
-		goto out;
+		if (!(nlh->nlmsg_flags & NLM_F_REPLACE))
+			flags &= ~NEIGH_UPDATE_F_OVERRIDE;
 	}
 
-	read_unlock(&neigh_tbl_lock);
-	err = -EAFNOSUPPORT;
+	if (ndm->ndm_flags & NTF_USE) {
+		neigh_event_send(neigh, NULL);
+		err = 0;
+	} else
+		err = neigh_update(neigh, lladdr, ndm->ndm_state, flags);
+	neigh_release(neigh);
+
 out:
 	return err;
 }
@@ -1982,7 +1955,8 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct neigh_table *tbl;
 	struct ndtmsg *ndtmsg;
 	struct nlattr *tb[NDTA_MAX+1];
-	int err;
+	bool found = false;
+	int err, tidx;
 
 	err = nlmsg_parse(nlh, sizeof(*ndtmsg), tb, NDTA_MAX,
 			  nl_neightbl_policy);
@@ -1995,19 +1969,21 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 	}
 
 	ndtmsg = nlmsg_data(nlh);
-	read_lock(&neigh_tbl_lock);
-	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
+
+	for (tidx = 0; tidx < NEIGH_NR_TABLES; tidx++) {
+		tbl = neigh_tables[tidx];
+		if (!tbl)
+			continue;
 		if (ndtmsg->ndtm_family && tbl->family != ndtmsg->ndtm_family)
 			continue;
-
-		if (nla_strcmp(tb[NDTA_NAME], tbl->id) == 0)
+		if (nla_strcmp(tb[NDTA_NAME], tbl->id) == 0) {
+			found = true;
 			break;
+		}
 	}
 
-	if (tbl == NULL) {
-		err = -ENOENT;
-		goto errout_locked;
-	}
+	if (!found)
+		return -ENOENT;
 
 	/*
 	 * We acquire tbl->lock to be nice to the periodic timers and
@@ -2118,8 +2094,6 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 errout_tbl_lock:
 	write_unlock_bh(&tbl->lock);
-errout_locked:
-	read_unlock(&neigh_tbl_lock);
 errout:
 	return err;
 }
@@ -2134,10 +2108,13 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 
 	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
 
-	read_lock(&neigh_tbl_lock);
-	for (tbl = neigh_tables, tidx = 0; tbl; tbl = tbl->next, tidx++) {
+	for (tidx = 0; tidx < NEIGH_NR_TABLES; tidx++) {
 		struct neigh_parms *p;
 
+		tbl = neigh_tables[tidx];
+		if (!tbl)
+			continue;
+
 		if (tidx < tbl_skip || (family && tbl->family != family))
 			continue;
 
@@ -2168,7 +2145,6 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 		neigh_skip = 0;
 	}
 out:
-	read_unlock(&neigh_tbl_lock);
 	cb->args[0] = tidx;
 	cb->args[1] = nidx;
 
@@ -2351,7 +2327,6 @@ static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 	int proxy = 0;
 	int err;
 
-	read_lock(&neigh_tbl_lock);
 	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
 
 	/* check for full ndmsg structure presence, family member is
@@ -2363,8 +2338,11 @@ static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 
 	s_t = cb->args[0];
 
-	for (tbl = neigh_tables, t = 0; tbl;
-	     tbl = tbl->next, t++) {
+	for (t = 0; t < NEIGH_NR_TABLES; t++) {
+		tbl = neigh_tables[t];
+
+		if (!tbl)
+			continue;
 		if (t < s_t || (family && tbl->family != family))
 			continue;
 		if (t > s_t)
@@ -2377,7 +2355,6 @@ static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 		if (err < 0)
 			break;
 	}
-	read_unlock(&neigh_tbl_lock);
 
 	cb->args[0] = t;
 	return skb->len;
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index c8121ce..7ca7c31 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -591,7 +591,7 @@ static const struct file_operations dn_neigh_seq_fops = {
 
 void __init dn_neigh_init(void)
 {
-	neigh_table_init(&dn_neigh_table);
+	neigh_table_init(NEIGH_DN_TABLE, &dn_neigh_table);
 	proc_create("decnet_neigh", S_IRUGO, init_net.proc_net,
 		    &dn_neigh_seq_fops);
 }
@@ -599,5 +599,5 @@ void __init dn_neigh_init(void)
 void __exit dn_neigh_cleanup(void)
 {
 	remove_proc_entry("decnet_neigh", init_net.proc_net);
-	neigh_table_clear(&dn_neigh_table);
+	neigh_table_clear(NEIGH_DN_TABLE, &dn_neigh_table);
 }
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 16acb59..205e147 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1292,7 +1292,7 @@ static int arp_proc_init(void);
 
 void __init arp_init(void)
 {
-	neigh_table_init(&arp_tbl);
+	neigh_table_init(NEIGH_ARP_TABLE, &arp_tbl);
 
 	dev_add_pack(&arp_packet_type);
 	arp_proc_init();
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 4cb45c1..2c9f6bf 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1763,7 +1763,7 @@ int __init ndisc_init(void)
 	/*
 	 * Initialize the neighbour table
 	 */
-	neigh_table_init(&nd_tbl);
+	neigh_table_init(NEIGH_ND_TABLE, &nd_tbl);
 
 #ifdef CONFIG_SYSCTL
 	err = neigh_sysctl_register(NULL, &nd_tbl.parms,
@@ -1796,6 +1796,6 @@ void ndisc_cleanup(void)
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_unregister(&nd_tbl.parms);
 #endif
-	neigh_table_clear(&nd_tbl);
+	neigh_table_clear(NEIGH_ND_TABLE, &nd_tbl);
 	unregister_pernet_subsys(&ndisc_net_ops);
 }
