From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/2][NETNS] net: Modify the neighbour table code so it handles multiple network namespaces
Date: Wed, 19 Dec 2007 15:55:45 +0100
Message-ID: <20071219145830.605868037@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071219145544.184198087@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:63804 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476AbXLSPEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 10:04:01 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBJF411M149104
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 15:04:01 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBJF40Qc2703534
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 16:04:00 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBJF3xot024092
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 16:04:00 +0100
Content-Disposition: inline; filename=0001-net-Modify-the-neighbour-table-code-so-it-handles-m.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm actually surprised at how much was involved.  At first glance it appears
that the neighbour table data structures are already split by network device
so all that should be needed is to modify the user interface commands
to filter the set of neighbours by the network namespace of their devices.

However a couple things turned up while I was reading through the code.
The proxy neighbour table allows entries with no network device, and
the neighbour parms are per network device (except for the defaults)
so they now need a per network namespace default.

So I updated the two structures (which surprised me) with their very
own network namespace parameter.  Updated the relevant lookup and
destroy routines with a network namespace parameter and modified
the code that interacts with users to filter out neighbour
table entries for devices of other namespaces.

I'm a little concerned that we can modify and display the global
table configuration and from all network namespaces.  But
this appears good enough for now.

I keep thinking modifying the neighbour table to have per network
namespace instances of each table type would should be cleaner.  The
hash table is already dynamically sized so there are it is not a limiter.
The default parameter would be straight forward to take care of.  However
when I look at the how the network table is built and used I still find
some assumptions that there is only a single neighbour table for each
type of table in the kernel.  The netlink operations, neigh_seq_start,
the non-core network users that call neigh_lookup.  So while it might
be doable it would require more refactoring than my current approach
of just doing a little extra filtering in the code.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/neighbour.h |   13 +++--
 net/atm/clip.c          |   15 +++++-
 net/core/neighbour.c    |  115 +++++++++++++++++++++++++++++-------------------
 net/decnet/dn_neigh.c   |   35 +++++++++++++-
 net/decnet/dn_route.c   |    2 
 net/ipv4/arp.c          |   12 ++---
 net/ipv6/ip6_output.c   |    2 
 net/ipv6/ndisc.c        |    4 -
 8 files changed, 136 insertions(+), 62 deletions(-)

Index: net-2.6.25/include/net/neighbour.h
===================================================================
--- net-2.6.25.orig/include/net/neighbour.h
+++ net-2.6.25/include/net/neighbour.h
@@ -34,6 +34,7 @@ struct neighbour;
 
 struct neigh_parms
 {
+	struct net *net;
 	struct net_device *dev;
 	struct neigh_parms *next;
 	int	(*neigh_setup)(struct neighbour *);
@@ -126,7 +127,8 @@ struct neigh_ops
 struct pneigh_entry
 {
 	struct pneigh_entry	*next;
-	struct net_device		*dev;
+	struct net		*net;
+	struct net_device	*dev;
 	u8			flags;
 	u8			key[0];
 };
@@ -187,6 +189,7 @@ extern struct neighbour *	neigh_lookup(s
 					     const void *pkey,
 					     struct net_device *dev);
 extern struct neighbour *	neigh_lookup_nodev(struct neigh_table *tbl,
+						   struct net *net,
 						   const void *pkey);
 extern struct neighbour *	neigh_create(struct neigh_table *tbl,
 					     const void *pkey,
@@ -211,15 +214,17 @@ extern unsigned long		neigh_rand_reach_t
 
 extern void			pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 					       struct sk_buff *skb);
-extern struct pneigh_entry	*pneigh_lookup(struct neigh_table *tbl, const void *key, struct net_device *dev, int creat);
-extern int			pneigh_delete(struct neigh_table *tbl, const void *key, struct net_device *dev);
+extern struct pneigh_entry	*pneigh_lookup(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev, int creat);
+extern int			pneigh_delete(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev);
 
 extern void neigh_app_ns(struct neighbour *n);
 extern void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void *), void *cookie);
 extern void __neigh_for_each_release(struct neigh_table *tbl, int (*cb)(struct neighbour *));
 extern void pneigh_for_each(struct neigh_table *tbl, void (*cb)(struct pneigh_entry *));
 
-struct neigh_seq_state {
+struct neigh_seq_state
+{
+	struct net *net;
 	struct neigh_table *tbl;
 	void *(*neigh_sub_iter)(struct neigh_seq_state *state,
 				struct neighbour *n, loff_t *pos);
Index: net-2.6.25/net/atm/clip.c
===================================================================
--- net-2.6.25.orig/net/atm/clip.c
+++ net-2.6.25/net/atm/clip.c
@@ -949,6 +949,11 @@ static int arp_seq_open(struct inode *in
 
 	seq = file->private_data;
 	seq->private = state;
+	state->ns.net = get_proc_net(inode);
+	if (!state->ns.net) {
+		seq_release_private(inode, file);
+		rc = -ENXIO;
+	}
 out:
 	return rc;
 
@@ -957,11 +962,19 @@ out_kfree:
 	goto out;
 }
 
+static int arp_seq_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct clip_seq_state *state = seq->private;
+	put_net(state->ns.net);
+	return seq_release_private(inode, file);
+}
+
 static const struct file_operations arp_seq_fops = {
 	.open		= arp_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= seq_release_private,
+	.release	= arp_seq_release,
 	.owner		= THIS_MODULE
 };
 #endif
Index: net-2.6.25/net/core/neighbour.c
===================================================================
--- net-2.6.25.orig/net/core/neighbour.c
+++ net-2.6.25/net/core/neighbour.c
@@ -365,7 +365,7 @@ struct neighbour *neigh_lookup(struct ne
 	return n;
 }
 
-struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, const void *pkey)
+struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net * net, const void *pkey)
 {
 	struct neighbour *n;
 	int key_len = tbl->key_len;
@@ -375,7 +375,8 @@ struct neighbour *neigh_lookup_nodev(str
 
 	read_lock_bh(&tbl->lock);
 	for (n = tbl->hash_buckets[hash_val & tbl->hash_mask]; n; n = n->next) {
-		if (!memcmp(n->primary_key, pkey, key_len)) {
+		if (!memcmp(n->primary_key, pkey, key_len) &&
+		    (net == n->dev->nd_net)) {
 			neigh_hold(n);
 			NEIGH_CACHE_STAT_INC(tbl, hits);
 			break;
@@ -453,7 +454,8 @@ out_neigh_release:
 	goto out;
 }
 
-struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl, const void *pkey,
+struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
+				    struct net * net, const void *pkey,
 				    struct net_device *dev, int creat)
 {
 	struct pneigh_entry *n;
@@ -469,6 +471,7 @@ struct pneigh_entry * pneigh_lookup(stru
 
 	for (n = tbl->phash_buckets[hash_val]; n; n = n->next) {
 		if (!memcmp(n->key, pkey, key_len) &&
+		    (n->net == net) &&
 		    (n->dev == dev || !n->dev)) {
 			read_unlock_bh(&tbl->lock);
 			goto out;
@@ -485,6 +488,7 @@ struct pneigh_entry * pneigh_lookup(stru
 	if (!n)
 		goto out;
 
+	n->net = hold_net(net);
 	memcpy(n->key, pkey, key_len);
 	n->dev = dev;
 	if (dev)
@@ -507,7 +511,7 @@ out:
 }
 
 
-int pneigh_delete(struct neigh_table *tbl, const void *pkey,
+int pneigh_delete(struct neigh_table *tbl, struct net * net, const void *pkey,
 		  struct net_device *dev)
 {
 	struct pneigh_entry *n, **np;
@@ -522,13 +526,15 @@ int pneigh_delete(struct neigh_table *tb
 	write_lock_bh(&tbl->lock);
 	for (np = &tbl->phash_buckets[hash_val]; (n = *np) != NULL;
 	     np = &n->next) {
-		if (!memcmp(n->key, pkey, key_len) && n->dev == dev) {
+		if (!memcmp(n->key, pkey, key_len) && n->dev == dev &&
+		    (n->net == net)) {
 			*np = n->next;
 			write_unlock_bh(&tbl->lock);
 			if (tbl->pdestructor)
 				tbl->pdestructor(n);
 			if (n->dev)
 				dev_put(n->dev);
+			release_net(n->net);
 			kfree(n);
 			return 0;
 		}
@@ -551,6 +557,7 @@ static int pneigh_ifdown(struct neigh_ta
 					tbl->pdestructor(n);
 				if (n->dev)
 					dev_put(n->dev);
+				release_net(n->net);
 				kfree(n);
 				continue;
 			}
@@ -1264,12 +1271,37 @@ void pneigh_enqueue(struct neigh_table *
 	spin_unlock(&tbl->proxy_queue.lock);
 }
 
+static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
+						      struct net * net, int ifindex)
+{
+	struct neigh_parms *p;
+
+	for (p = &tbl->parms; p; p = p->next) {
+		if (p->net != net)
+			continue;
+		if ((p->dev && p->dev->ifindex == ifindex) ||
+		    (!p->dev && !ifindex))
+			return p;
+	}
+
+	return NULL;
+}
 
 struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 				      struct neigh_table *tbl)
 {
-	struct neigh_parms *p = kmemdup(&tbl->parms, sizeof(*p), GFP_KERNEL);
+	struct neigh_parms *p, *ref;
+	struct net * net;
+
+	net = &init_net;
+	if (dev)
+		net = dev->nd_net;
+
+	ref = lookup_neigh_params(tbl, net, 0);
+	if (!ref)
+		return NULL;
 
+	p = kmemdup(ref, sizeof(*p), GFP_KERNEL);
 	if (p) {
 		p->tbl		  = tbl;
 		atomic_set(&p->refcnt, 1);
@@ -1285,6 +1317,7 @@ struct neigh_parms *neigh_parms_alloc(st
 			dev_hold(dev);
 			p->dev = dev;
 		}
+		p->net = hold_net(net);
 		p->sysctl_table = NULL;
 		write_lock_bh(&tbl->lock);
 		p->next		= tbl->parms.next;
@@ -1326,6 +1359,7 @@ void neigh_parms_release(struct neigh_ta
 
 void neigh_parms_destroy(struct neigh_parms *parms)
 {
+	release_net(parms->net);
 	kfree(parms);
 }
 
@@ -1336,6 +1370,7 @@ void neigh_table_init_no_netlink(struct 
 	unsigned long now = jiffies;
 	unsigned long phsize;
 
+	tbl->parms.net = &init_net;
 	atomic_set(&tbl->parms.refcnt, 1);
 	INIT_RCU_HEAD(&tbl->parms.rcu_head);
 	tbl->parms.reachable_time =
@@ -1449,9 +1484,6 @@ static int neigh_delete(struct sk_buff *
 	struct net_device *dev = NULL;
 	int err = -EINVAL;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	if (nlmsg_len(nlh) < sizeof(*ndm))
 		goto out;
 
@@ -1480,7 +1512,7 @@ static int neigh_delete(struct sk_buff *
 			goto out_dev_put;
 
 		if (ndm->ndm_flags & NTF_PROXY) {
-			err = pneigh_delete(tbl, nla_data(dst_attr), dev);
+			err = pneigh_delete(tbl, net, nla_data(dst_attr), dev);
 			goto out_dev_put;
 		}
 
@@ -1518,9 +1550,6 @@ static int neigh_add(struct sk_buff *skb
 	struct net_device *dev = NULL;
 	int err;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
 	if (err < 0)
 		goto out;
@@ -1560,7 +1589,7 @@ static int neigh_add(struct sk_buff *skb
 			struct pneigh_entry *pn;
 
 			err = -ENOBUFS;
-			pn = pneigh_lookup(tbl, dst, dev, 1);
+			pn = pneigh_lookup(tbl, net, dst, dev, 1);
 			if (pn) {
 				pn->flags = ndm->ndm_flags;
 				err = 0;
@@ -1755,19 +1784,6 @@ errout:
 	return -EMSGSIZE;
 }
 
-static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
-						      int ifindex)
-{
-	struct neigh_parms *p;
-
-	for (p = &tbl->parms; p; p = p->next)
-		if ((p->dev && p->dev->ifindex == ifindex) ||
-		    (!p->dev && !ifindex))
-			return p;
-
-	return NULL;
-}
-
 static const struct nla_policy nl_neightbl_policy[NDTA_MAX+1] = {
 	[NDTA_NAME]		= { .type = NLA_STRING },
 	[NDTA_THRESH1]		= { .type = NLA_U32 },
@@ -1801,9 +1817,6 @@ static int neightbl_set(struct sk_buff *
 	struct nlattr *tb[NDTA_MAX+1];
 	int err;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = nlmsg_parse(nlh, sizeof(*ndtmsg), tb, NDTA_MAX,
 			  nl_neightbl_policy);
 	if (err < 0)
@@ -1848,7 +1861,7 @@ static int neightbl_set(struct sk_buff *
 		if (tbp[NDTPA_IFINDEX])
 			ifindex = nla_get_u32(tbp[NDTPA_IFINDEX]);
 
-		p = lookup_neigh_params(tbl, ifindex);
+		p = lookup_neigh_params(tbl, net, ifindex);
 		if (p == NULL) {
 			err = -ENOENT;
 			goto errout_tbl_lock;
@@ -1929,9 +1942,6 @@ static int neightbl_dump_info(struct sk_
 	int neigh_skip = cb->args[1];
 	struct neigh_table *tbl;
 
-	if (net != &init_net)
-		return 0;
-
 	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
 
 	read_lock(&neigh_tbl_lock);
@@ -1946,8 +1956,11 @@ static int neightbl_dump_info(struct sk_
 				       NLM_F_MULTI) <= 0)
 			break;
 
-		for (nidx = 0, p = tbl->parms.next; p; p = p->next, nidx++) {
-			if (nidx < neigh_skip)
+		for (nidx = 0, p = tbl->parms.next; p; p = p->next) {
+			if (net != p->net)
+				continue;
+
+			if (nidx++ < neigh_skip)
 				continue;
 
 			if (neightbl_fill_param_info(skb, tbl, p,
@@ -2023,6 +2036,7 @@ static void neigh_update_notify(struct n
 static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			    struct netlink_callback *cb)
 {
+	struct net * net = skb->sk->sk_net;
 	struct neighbour *n;
 	int rc, h, s_h = cb->args[1];
 	int idx, s_idx = idx = cb->args[2];
@@ -2033,8 +2047,12 @@ static int neigh_dump_table(struct neigh
 			continue;
 		if (h > s_h)
 			s_idx = 0;
-		for (n = tbl->hash_buckets[h], idx = 0; n; n = n->next, idx++) {
-			if (idx < s_idx)
+		for (n = tbl->hash_buckets[h], idx = 0; n; n = n->next) {
+			int lidx;
+			if (n->dev->nd_net != net)
+				continue;
+			lidx = idx++;
+			if (lidx < s_idx)
 				continue;
 			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).pid,
 					    cb->nlh->nlmsg_seq,
@@ -2056,13 +2074,9 @@ out:
 
 static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
 	struct neigh_table *tbl;
 	int t, family, s_t;
 
-	if (net != &init_net)
-		return 0;
-
 	read_lock(&neigh_tbl_lock);
 	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
 	s_t = cb->args[0];
@@ -2130,6 +2144,7 @@ EXPORT_SYMBOL(__neigh_for_each_release);
 static struct neighbour *neigh_get_first(struct seq_file *seq)
 {
 	struct neigh_seq_state *state = seq->private;
+	struct net * net = state->net;
 	struct neigh_table *tbl = state->tbl;
 	struct neighbour *n = NULL;
 	int bucket = state->bucket;
@@ -2139,6 +2154,8 @@ static struct neighbour *neigh_get_first
 		n = tbl->hash_buckets[bucket];
 
 		while (n) {
+			if (n->dev->nd_net != net)
+				goto next;
 			if (state->neigh_sub_iter) {
 				loff_t fakep = 0;
 				void *v;
@@ -2168,6 +2185,7 @@ static struct neighbour *neigh_get_next(
 					loff_t *pos)
 {
 	struct neigh_seq_state *state = seq->private;
+	struct net * net = state->net;
 	struct neigh_table *tbl = state->tbl;
 
 	if (state->neigh_sub_iter) {
@@ -2179,6 +2197,8 @@ static struct neighbour *neigh_get_next(
 
 	while (1) {
 		while (n) {
+			if (n->dev->nd_net != net)
+				goto next;
 			if (state->neigh_sub_iter) {
 				void *v = state->neigh_sub_iter(state, n, pos);
 				if (v)
@@ -2225,6 +2245,7 @@ static struct neighbour *neigh_get_idx(s
 static struct pneigh_entry *pneigh_get_first(struct seq_file *seq)
 {
 	struct neigh_seq_state *state = seq->private;
+	struct net * net = state->net;
 	struct neigh_table *tbl = state->tbl;
 	struct pneigh_entry *pn = NULL;
 	int bucket = state->bucket;
@@ -2232,6 +2253,8 @@ static struct pneigh_entry *pneigh_get_f
 	state->flags |= NEIGH_SEQ_IS_PNEIGH;
 	for (bucket = 0; bucket <= PNEIGH_HASHMASK; bucket++) {
 		pn = tbl->phash_buckets[bucket];
+		while (pn && (pn->net != net))
+			pn = pn->next;
 		if (pn)
 			break;
 	}
@@ -2245,6 +2268,7 @@ static struct pneigh_entry *pneigh_get_n
 					    loff_t *pos)
 {
 	struct neigh_seq_state *state = seq->private;
+	struct net * net = state->net;
 	struct neigh_table *tbl = state->tbl;
 
 	pn = pn->next;
@@ -2252,6 +2276,8 @@ static struct pneigh_entry *pneigh_get_n
 		if (++state->bucket > PNEIGH_HASHMASK)
 			break;
 		pn = tbl->phash_buckets[state->bucket];
+		while (pn && (pn->net != net))
+			pn = pn->next;
 		if (pn)
 			break;
 	}
@@ -2453,6 +2479,7 @@ static inline size_t neigh_nlmsg_size(vo
 
 static void __neigh_notify(struct neighbour *n, int type, int flags)
 {
+	struct net * net = n->dev->nd_net;
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
@@ -2467,10 +2494,10 @@ static void __neigh_notify(struct neighb
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, &init_net, 0, RTNLGRP_NEIGH, NULL, GFP_ATOMIC);
+	err = rtnl_notify(skb, net, 0, RTNLGRP_NEIGH, NULL, GFP_ATOMIC);
 errout:
 	if (err < 0)
-		rtnl_set_sk_err(&init_net, RTNLGRP_NEIGH, err);
+		rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
 }
 
 #ifdef CONFIG_ARPD
Index: net-2.6.25/net/decnet/dn_neigh.c
===================================================================
--- net-2.6.25.orig/net/decnet/dn_neigh.c
+++ net-2.6.25/net/decnet/dn_neigh.c
@@ -580,8 +580,37 @@ static const struct seq_operations dn_ne
 
 static int dn_neigh_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &dn_neigh_seq_ops,
-			sizeof(struct neigh_seq_state));
+        struct seq_file *seq;
+        int rc = -ENOMEM;
+        struct neigh_seq_state *s = kzalloc(sizeof(*s), GFP_KERNEL);
+
+        if (!s)
+                goto out;
+
+        rc = seq_open(file, &dn_neigh_seq_ops);
+        if (rc)
+                goto out_kfree;
+
+        seq          = file->private_data;
+        seq->private = s;
+        s->net = get_proc_net(inode);
+        if (!s->net) {
+                seq_release_private(inode, file);
+                rc = -ENXIO;
+        }
+out:
+        return rc;
+out_kfree:
+        kfree(s);
+        goto out;
+}
+
+static int dn_neigh_seq_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct neigh_seq_state *state = seq->private;
+	put_net(state->net);
+	return seq_release_private(inode, file);
 }
 
 static const struct file_operations dn_neigh_seq_fops = {
@@ -589,7 +618,7 @@ static const struct file_operations dn_n
 	.open		= dn_neigh_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= seq_release_private,
+	.release	= dn_neigh_seq_release,
 };
 
 #endif
Index: net-2.6.25/net/decnet/dn_route.c
===================================================================
--- net-2.6.25.orig/net/decnet/dn_route.c
+++ net-2.6.25/net/decnet/dn_route.c
@@ -984,7 +984,7 @@ source_ok:
 		 * here
 		 */
 		if (!try_hard) {
-			neigh = neigh_lookup_nodev(&dn_neigh_table, &fl.fld_dst);
+			neigh = neigh_lookup_nodev(&dn_neigh_table, &init_net, &fl.fld_dst);
 			if (neigh) {
 				if ((oldflp->oif &&
 				    (neigh->dev->ifindex != oldflp->oif)) ||
Index: net-2.6.25/net/ipv4/arp.c
===================================================================
--- net-2.6.25.orig/net/ipv4/arp.c
+++ net-2.6.25/net/ipv4/arp.c
@@ -838,7 +838,7 @@ static int arp_process(struct sk_buff *s
 		} else if (IN_DEV_FORWARD(in_dev)) {
 			if ((rt->rt_flags&RTCF_DNAT) ||
 			    (addr_type == RTN_UNICAST  && rt->u.dst.dev != dev &&
-			     (arp_fwd_proxy(in_dev, rt) || pneigh_lookup(&arp_tbl, &tip, dev, 0)))) {
+			     (arp_fwd_proxy(in_dev, rt) || pneigh_lookup(&arp_tbl, &init_net, &tip, dev, 0)))) {
 				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 				if (n)
 					neigh_release(n);
@@ -981,7 +981,7 @@ static int arp_req_set_public(struct net
 			return -ENODEV;
 	}
 	if (mask) {
-		if (pneigh_lookup(&arp_tbl, &ip, dev, 1) == NULL)
+		if (pneigh_lookup(&arp_tbl, &init_net, &ip, dev, 1) == NULL)
 			return -ENOBUFS;
 		return 0;
 	}
@@ -1090,7 +1090,7 @@ static int arp_req_delete_public(struct 
 	__be32 mask = ((struct sockaddr_in *)&r->arp_netmask)->sin_addr.s_addr;
 
 	if (mask == htonl(0xFFFFFFFF))
-		return pneigh_delete(&arp_tbl, &ip, dev);
+		return pneigh_delete(&arp_tbl, &init_net, &ip, dev);
 
 	if (mask)
 		return -EINVAL;
@@ -1376,8 +1376,8 @@ static const struct seq_operations arp_s
 
 static int arp_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &arp_seq_ops,
-			sizeof(struct neigh_seq_state));
+	return seq_open_net(inode, file, &arp_seq_ops,
+			    sizeof(struct neigh_seq_state));
 }
 
 static const struct file_operations arp_seq_fops = {
@@ -1385,7 +1385,7 @@ static const struct file_operations arp_
 	.open           = arp_seq_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release	= seq_release_private,
+	.release	= seq_release_net,
 };
 
 static int __init arp_proc_init(void)
Index: net-2.6.25/net/ipv6/ip6_output.c
===================================================================
--- net-2.6.25.orig/net/ipv6/ip6_output.c
+++ net-2.6.25/net/ipv6/ip6_output.c
@@ -449,7 +449,7 @@ int ip6_forward(struct sk_buff *skb)
 
 	/* XXX: idev->cnf.proxy_ndp? */
 	if (ipv6_devconf.proxy_ndp &&
-	    pneigh_lookup(&nd_tbl, &hdr->daddr, skb->dev, 0)) {
+	    pneigh_lookup(&nd_tbl, &init_net, &hdr->daddr, skb->dev, 0)) {
 		int proxied = ip6_forward_proxy_check(skb);
 		if (proxied > 0)
 			return ip6_input(skb);
Index: net-2.6.25/net/ipv6/ndisc.c
===================================================================
--- net-2.6.25.orig/net/ipv6/ndisc.c
+++ net-2.6.25/net/ipv6/ndisc.c
@@ -789,7 +789,7 @@ static void ndisc_recv_ns(struct sk_buff
 		if (ipv6_chk_acast_addr(dev, &msg->target) ||
 		    (idev->cnf.forwarding &&
 		     (ipv6_devconf.proxy_ndp || idev->cnf.proxy_ndp) &&
-		     (pneigh = pneigh_lookup(&nd_tbl,
+		     (pneigh = pneigh_lookup(&nd_tbl, &init_net,
 					     &msg->target, dev, 0)) != NULL)) {
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 			    skb->pkt_type != PACKET_HOST &&
@@ -930,7 +930,7 @@ static void ndisc_recv_na(struct sk_buff
 		 */
 		if (lladdr && !memcmp(lladdr, dev->dev_addr, dev->addr_len) &&
 		    ipv6_devconf.forwarding && ipv6_devconf.proxy_ndp &&
-		    pneigh_lookup(&nd_tbl, &msg->target, dev, 0)) {
+		    pneigh_lookup(&nd_tbl, &init_net, &msg->target, dev, 0)) {
 			/* XXX: idev->cnf.prixy_ndp */
 			goto out;
 		}

-- 
