From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 4/5] [NET] NETNS: Omit neigh_parms->net and
 pneigh_entry->net without CONFIG_NET_NS.
Date: Wed, 26 Mar 2008 08:44:39 +0900 (JST)
Message-ID: <20080326.084439.32621075.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, dlezcano@fr.ibm.com, brian.haley@hp.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55060 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbYCYXnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 19:43:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce neigh_parms/pneigh_entry inlines: neigh_parms_net(), pneigh_net().
Without CONFIG_NET_NS, no namespace other than &init_net exists.
Let's explicitly define them to help compiler optimizations.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/neighbour.h |   25 +++++++++++++++++++++++++
 net/core/neighbour.c    |   26 ++++++++++++++++----------
 2 files changed, 41 insertions(+), 10 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 0622818..8bec0d6 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -38,7 +38,9 @@ struct neighbour;
 
 struct neigh_parms
 {
+#ifdef CONFIG_NET_NS
 	struct net *net;
+#endif
 	struct net_device *dev;
 	struct neigh_parms *next;
 	int	(*neigh_setup)(struct neighbour *);
@@ -131,7 +133,9 @@ struct neigh_ops
 struct pneigh_entry
 {
 	struct pneigh_entry	*next;
+#ifdef CONFIG_NET_NS
 	struct net		*net;
+#endif
 	struct net_device	*dev;
 	u8			flags;
 	u8			key[0];
@@ -213,6 +217,17 @@ extern struct neighbour 	*neigh_event_ns(struct neigh_table *tbl,
 
 extern struct neigh_parms	*neigh_parms_alloc(struct net_device *dev, struct neigh_table *tbl);
 extern void			neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms);
+
+static inline
+struct net			*neigh_parms_net(const struct neigh_parms *parms)
+{
+#ifdef CONFIG_NET_NS
+	return parms->net;
+#else
+	return &init_net;
+#endif
+}
+
 extern unsigned long		neigh_rand_reach_time(unsigned long base);
 
 extern void			pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
@@ -220,6 +235,16 @@ extern void			pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 extern struct pneigh_entry	*pneigh_lookup(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev, int creat);
 extern int			pneigh_delete(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev);
 
+static inline
+struct net			*pneigh_net(const struct pneigh_entry *pneigh)
+{
+#ifdef CONFIG_NET_NS
+	return pneigh->net;
+#else
+	return &init_net;
+#endif
+}
+
 extern void neigh_app_ns(struct neighbour *n);
 extern void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void *), void *cookie);
 extern void __neigh_for_each_release(struct neigh_table *tbl, int (*cb)(struct neighbour *));
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index b8d491f..de654ea 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -483,7 +483,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 
 	for (n = tbl->phash_buckets[hash_val]; n; n = n->next) {
 		if (!memcmp(n->key, pkey, key_len) &&
-		    (n->net == net) &&
+		    (pneigh_net(n) == net) &&
 		    (n->dev == dev || !n->dev)) {
 			read_unlock_bh(&tbl->lock);
 			goto out;
@@ -500,7 +500,9 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 	if (!n)
 		goto out;
 
+#ifdef CONFIG_NET_NS
 	n->net = hold_net(net);
+#endif
 	memcpy(n->key, pkey, key_len);
 	n->dev = dev;
 	if (dev)
@@ -540,14 +542,14 @@ int pneigh_delete(struct neigh_table *tbl, struct net *net, const void *pkey,
 	for (np = &tbl->phash_buckets[hash_val]; (n = *np) != NULL;
 	     np = &n->next) {
 		if (!memcmp(n->key, pkey, key_len) && n->dev == dev &&
-		    (n->net == net)) {
+		    (pneigh_net(n) == net)) {
 			*np = n->next;
 			write_unlock_bh(&tbl->lock);
 			if (tbl->pdestructor)
 				tbl->pdestructor(n);
 			if (n->dev)
 				dev_put(n->dev);
-			release_net(n->net);
+			release_net(pneigh_net(n));
 			kfree(n);
 			return 0;
 		}
@@ -570,7 +572,7 @@ static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 					tbl->pdestructor(n);
 				if (n->dev)
 					dev_put(n->dev);
-				release_net(n->net);
+				release_net(pneigh_net(n));
 				kfree(n);
 				continue;
 			}
@@ -1284,7 +1286,7 @@ static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
 	struct neigh_parms *p;
 
 	for (p = &tbl->parms; p; p = p->next) {
-		if ((p->dev && p->dev->ifindex == ifindex && p->net == net) ||
+		if ((p->dev && p->dev->ifindex == ifindex && neigh_parms_net(p) == net) ||
 		    (!p->dev && !ifindex))
 			return p;
 	}
@@ -1318,7 +1320,9 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 
 		dev_hold(dev);
 		p->dev = dev;
+#ifdef CONFIG_NET_NS
 		p->net = hold_net(net);
+#endif
 		p->sysctl_table = NULL;
 		write_lock_bh(&tbl->lock);
 		p->next		= tbl->parms.next;
@@ -1360,7 +1364,7 @@ void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms)
 
 static void neigh_parms_destroy(struct neigh_parms *parms)
 {
-	release_net(parms->net);
+	release_net(neigh_parms_net(parms));
 	kfree(parms);
 }
 
@@ -1371,7 +1375,9 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 	unsigned long now = jiffies;
 	unsigned long phsize;
 
+#ifdef CONFIG_NET_NS
 	tbl->parms.net = &init_net;
+#endif
 	atomic_set(&tbl->parms.refcnt, 1);
 	INIT_RCU_HEAD(&tbl->parms.rcu_head);
 	tbl->parms.reachable_time =
@@ -1958,7 +1964,7 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 			break;
 
 		for (nidx = 0, p = tbl->parms.next; p; p = p->next) {
-			if (net != p->net)
+			if (net != neigh_parms_net(p))
 				continue;
 
 			if (nidx++ < neigh_skip)
@@ -2254,7 +2260,7 @@ static struct pneigh_entry *pneigh_get_first(struct seq_file *seq)
 	state->flags |= NEIGH_SEQ_IS_PNEIGH;
 	for (bucket = 0; bucket <= PNEIGH_HASHMASK; bucket++) {
 		pn = tbl->phash_buckets[bucket];
-		while (pn && (pn->net != net))
+		while (pn && (pneigh_net(pn) != net))
 			pn = pn->next;
 		if (pn)
 			break;
@@ -2277,7 +2283,7 @@ static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
 		if (++state->bucket > PNEIGH_HASHMASK)
 			break;
 		pn = tbl->phash_buckets[state->bucket];
-		while (pn && (pn->net != net))
+		while (pn && (pneigh_net(pn) != net))
 			pn = pn->next;
 		if (pn)
 			break;
@@ -2740,7 +2746,7 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	neigh_path[NEIGH_CTL_PATH_PROTO].ctl_name = p_id;
 
 	t->sysctl_header =
-		register_net_sysctl_table(p->net, neigh_path, t->neigh_vars);
+		register_net_sysctl_table(neigh_parms_net(p), neigh_path, t->neigh_vars);
 	if (!t->sysctl_header)
 		goto free_procname;
 
-- 
1.4.4.4

