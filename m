From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: introduce read_pnet() and write_pnet() functions
Date: Fri, 07 Nov 2008 16:44:37 +0100
Message-ID: <49146265.8040301@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000203000204060201020602"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34585 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbYKGPo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 10:44:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000203000204060201020602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

CONFIG_NET_NS is not a widespread option, we can reduce kernel size
not declaring useless "struct net" pointers in several structures.

This patch declares three helper to clean various "ifdef CONFIG_NET_NS"
that we have in many places.

#ifdef CONFIG_NET_NS

#define DECLARE_PNET(name) struct net *name;
static inline void write_pnet(struct net **pnet, struct net *net)
{
        *pnet = net;
}

static inline struct net *read_pnet(struct net * const *pnet)
{
        return *pnet;
}
#else

#define DECLARE_PNET(name)
#define write_pnet(pnet, net)   do { (void)(net);} while (0)
#define read_pnet(pnet)         (&init_net)

#endif

In particular, using these helpers permits a shrink of inet_bind_bucket
(16 bytes instead of 32 on 32bit arches, and 32 bytes instead of 64 on 64bits)

<net/net_namespace.h> doesnt automatically includes <linux/seq_file_net.h>
anymore.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 fs/proc/proc_net.c                                    |    1
 include/linux/netdevice.h                             |   21 ++++------
 include/linux/seq_file_net.h                          |   13 ------
 include/net/dst.h                                     |    4 -
 include/net/inet_hashtables.h                         |    2
 include/net/inet_timewait_sock.h                      |   10 ----
 include/net/ip_fib.h                                  |    2
 include/net/neighbour.h                               |   21 ++--------
 include/net/net_namespace.h                           |   20 +++++++++
 include/net/netfilter/nf_conntrack.h                  |   10 ----
 include/net/netfilter/nf_conntrack_expect.h           |    6 --
 include/net/sock.h                                    |   14 +-----
 net/8021q/vlanproc.c                                  |    1
 net/core/neighbour.c                                  |   12 +----
 net/ipv4/fib_semantics.c                              |    8 +--
 net/ipv4/inet_connection_sock.c                       |    6 +-
 net/ipv4/inet_hashtables.c                            |    7 +--
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |    1
 net/ipv6/addrlabel.c                                  |   18 +-------
 net/ipv6/route.c                                      |    8 +--
 net/netfilter/nf_conntrack_acct.c                     |    1
 net/netfilter/nf_conntrack_core.c                     |    8 ---
 net/netfilter/nf_conntrack_expect.c                   |    1
 net/netfilter/nf_conntrack_standalone.c               |    1
 net/netfilter/x_tables.c                              |    1
 25 files changed, 79 insertions(+), 118 deletions(-)

--------------000203000204060201020602
Content-Type: text/plain;
 name="cond_net.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cond_net.patch"

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 7bc296f..0a91454 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -23,6 +23,7 @@
 #include <linux/nsproxy.h>
 #include <net/net_namespace.h>
 #include <linux/seq_file.h>
+#include <linux/seq_file_net.h>
 
 #include "internal.h"
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 12d7f44..3ea874f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -734,10 +734,8 @@ struct net_device
 	u16			(*select_queue)(struct net_device *dev,
 						struct sk_buff *skb);
 
-#ifdef CONFIG_NET_NS
 	/* Network namespace this network device is inside */
-	struct net		*nd_net;
-#endif
+	DECLARE_PNET(nd_net)
 
 	/* mid-layer private */
 	void			*ml_priv;
@@ -794,20 +792,19 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 static inline
 struct net *dev_net(const struct net_device *dev)
 {
-#ifdef CONFIG_NET_NS
-	return dev->nd_net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&dev->nd_net);
 }
 
 static inline
 void dev_net_set(struct net_device *dev, struct net *net)
 {
-#ifdef CONFIG_NET_NS
-	release_net(dev->nd_net);
-	dev->nd_net = hold_net(net);
-#endif
+	/*
+	 * hold this one before release old one
+	 */
+	struct net *new_net = hold_net(net);
+
+	release_net(read_pnet(&dev->nd_net));
+	write_pnet(&dev->nd_net, new_net);
 }
 
 static inline bool netdev_uses_dsa_tags(struct net_device *dev)
diff --git a/include/linux/seq_file_net.h b/include/linux/seq_file_net.h
index 32c89bb..892f86d 100644
--- a/include/linux/seq_file_net.h
+++ b/include/linux/seq_file_net.h
@@ -3,13 +3,8 @@
 
 #include <linux/seq_file.h>
 
-struct net;
-extern struct net init_net;
-
 struct seq_net_private {
-#ifdef CONFIG_NET_NS
-	struct net *net;
-#endif
+	DECLARE_PNET(net)
 };
 
 int seq_open_net(struct inode *, struct file *,
@@ -20,11 +15,7 @@ int seq_release_net(struct inode *, struct file *);
 int single_release_net(struct inode *, struct file *);
 static inline struct net *seq_file_net(struct seq_file *seq)
 {
-#ifdef CONFIG_NET_NS
-	return ((struct seq_net_private *)seq->private)->net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&((struct seq_net_private *)seq->private)->net);
 }
 
 #endif
diff --git a/include/net/dst.h b/include/net/dst.h
index f96c4ba..7ae79a6 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -107,8 +107,8 @@ struct dst_ops
 	int			entry_size;
 
 	atomic_t		entries;
-	struct kmem_cache 		*kmem_cachep;
-	struct net              *dst_net;
+	struct kmem_cache 	*kmem_cachep;
+	DECLARE_PNET(dst_net)
 };
 
 #ifdef __KERNEL__
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 5cc182f..47f64d0 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -77,7 +77,7 @@ struct inet_ehash_bucket {
  * ports are created in O(1) time?  I thought so. ;-)	-DaveM
  */
 struct inet_bind_bucket {
-	struct net		*ib_net;
+	DECLARE_PNET(ib_net)
 	unsigned short		port;
 	signed short		fastreuse;
 	struct hlist_node	node;
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 80e4977..5d2c232 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -215,18 +215,12 @@ extern void inet_twsk_purge(struct net *net, struct inet_hashinfo *hashinfo,
 static inline
 struct net *twsk_net(const struct inet_timewait_sock *twsk)
 {
-#ifdef CONFIG_NET_NS
-	return twsk->tw_net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&twsk->tw_net);
 }
 
 static inline
 void twsk_net_set(struct inet_timewait_sock *twsk, struct net *net)
 {
-#ifdef CONFIG_NET_NS
-	twsk->tw_net = net;
-#endif
+	write_pnet(&twsk->tw_net, net);
 }
 #endif	/* _INET_TIMEWAIT_SOCK_ */
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 8b12667..f872f11 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -69,7 +69,7 @@ struct fib_nh {
 struct fib_info {
 	struct hlist_node	fib_hash;
 	struct hlist_node	fib_lhash;
-	struct net		*fib_net;
+	DECLARE_PNET(fib_net)
 	int			fib_treeref;
 	atomic_t		fib_clntref;
 	int			fib_dead;
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index aa4b708..77dbad7 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -25,6 +25,7 @@
 #include <linux/err.h>
 #include <linux/sysctl.h>
 #include <net/rtnetlink.h>
+#include <linux/seq_file_net.h>
 
 /*
  * NUD stands for "neighbor unreachability detection"
@@ -38,9 +39,7 @@ struct neighbour;
 
 struct neigh_parms
 {
-#ifdef CONFIG_NET_NS
-	struct net *net;
-#endif
+	DECLARE_PNET(net)
 	struct net_device *dev;
 	struct neigh_parms *next;
 	int	(*neigh_setup)(struct neighbour *);
@@ -135,9 +134,7 @@ struct neigh_ops
 struct pneigh_entry
 {
 	struct pneigh_entry	*next;
-#ifdef CONFIG_NET_NS
-	struct net		*net;
-#endif
+	DECLARE_PNET(net)
 	struct net_device	*dev;
 	u8			flags;
 	u8			key[0];
@@ -223,11 +220,7 @@ extern void			neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *p
 static inline
 struct net			*neigh_parms_net(const struct neigh_parms *parms)
 {
-#ifdef CONFIG_NET_NS
-	return parms->net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&parms->net);
 }
 
 extern unsigned long		neigh_rand_reach_time(unsigned long base);
@@ -244,11 +237,7 @@ extern int			pneigh_delete(struct neigh_table *tbl, struct net *net, const void
 static inline
 struct net			*pneigh_net(const struct pneigh_entry *pneigh)
 {
-#ifdef CONFIG_NET_NS
-	return pneigh->net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&pneigh->net);
 }
 
 extern void neigh_app_ns(struct neighbour *n);
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 700c53a..5aef6c1 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -78,7 +78,6 @@ struct net {
 };
 
 
-#include <linux/seq_file_net.h>
 
 /* Init's network namespace */
 extern struct net init_net;
@@ -192,6 +191,25 @@ static inline void release_net(struct net *net)
 }
 #endif
 
+#ifdef CONFIG_NET_NS
+
+#define DECLARE_PNET(name) struct net *name;
+static inline void write_pnet(struct net **pnet, struct net *net)
+{
+	*pnet = net;
+}
+
+static inline struct net *read_pnet(struct net * const *pnet)
+{
+	return *pnet;
+}
+#else
+
+#define DECLARE_PNET(name)
+#define write_pnet(pnet, net)	do { (void)(net);} while (0)
+#define read_pnet(pnet)		(&init_net)
+
+#endif
 
 #define for_each_net(VAR)				\
 	list_for_each_entry(VAR, &net_namespace_list, list)
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index b76a868..373f801 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -123,9 +123,7 @@ struct nf_conn
 
 	/* Extensions */
 	struct nf_ct_ext *ext;
-#ifdef CONFIG_NET_NS
-	struct net *ct_net;
-#endif
+	DECLARE_PNET(ct_net);
 	struct rcu_head rcu;
 };
 
@@ -153,11 +151,7 @@ extern struct net init_net;
 
 static inline struct net *nf_ct_net(const struct nf_conn *ct)
 {
-#ifdef CONFIG_NET_NS
-	return ct->ct_net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&ct->ct_net);
 }
 
 /* Alter reply tuple (maybe alter helper). */
diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index 37a7fc1..1612b1f 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -57,11 +57,7 @@ struct nf_conntrack_expect
 
 static inline struct net *nf_ct_exp_net(struct nf_conntrack_expect *exp)
 {
-#ifdef CONFIG_NET_NS
-	return exp->master->ct_net;	/* by definition */
-#else
-	return &init_net;
-#endif
+	return read_pnet(&exp->master->ct_net);	/* by definition */
 }
 
 struct nf_conntrack_expect_policy
diff --git a/include/net/sock.h b/include/net/sock.h
index 08291c1..c5760e8 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -125,9 +125,7 @@ struct sock_common {
 	atomic_t		skc_refcnt;
 	unsigned int		skc_hash;
 	struct proto		*skc_prot;
-#ifdef CONFIG_NET_NS
-	struct net	 	*skc_net;
-#endif
+	DECLARE_PNET(skc_net)
 };
 
 /**
@@ -1340,19 +1338,13 @@ static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb, int copied_e
 static inline
 struct net *sock_net(const struct sock *sk)
 {
-#ifdef CONFIG_NET_NS
-	return sk->sk_net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&sk->sk_net);
 }
 
 static inline
 void sock_net_set(struct sock *sk, struct net *net)
 {
-#ifdef CONFIG_NET_NS
-	sk->sk_net = net;
-#endif
+	write_pnet(&sk->sk_net, net);
 }
 
 /*
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 0feefa4..389be65 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -28,6 +28,7 @@
 #include <linux/if_vlan.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <linux/seq_file_net.h>
 #include "vlanproc.h"
 #include "vlan.h"
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d9bbe01..7a7e5a1 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -531,9 +531,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 	if (!n)
 		goto out;
 
-#ifdef CONFIG_NET_NS
-	n->net = hold_net(net);
-#endif
+	write_pnet(&n->net, hold_net(net));
 	memcpy(n->key, pkey, key_len);
 	n->dev = dev;
 	if (dev)
@@ -1350,9 +1348,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 
 		dev_hold(dev);
 		p->dev = dev;
-#ifdef CONFIG_NET_NS
-		p->net = hold_net(net);
-#endif
+		write_pnet(&p->net, hold_net(net));
 		p->sysctl_table = NULL;
 		write_lock_bh(&tbl->lock);
 		p->next		= tbl->parms.next;
@@ -1407,9 +1403,7 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 	unsigned long now = jiffies;
 	unsigned long phsize;
 
-#ifdef CONFIG_NET_NS
-	tbl->parms.net = &init_net;
-#endif
+	write_pnet(&tbl->parms.net, &init_net);
 	atomic_set(&tbl->parms.refcnt, 1);
 	tbl->parms.reachable_time =
 			  neigh_rand_reach_time(tbl->parms.base_reachable_time);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 4817dea..1854b25 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -150,7 +150,7 @@ void free_fib_info(struct fib_info *fi)
 		nh->nh_dev = NULL;
 	} endfor_nexthops(fi);
 	fib_info_cnt--;
-	release_net(fi->fib_net);
+	release_net(read_pnet(&fi->fib_net));
 	kfree(fi);
 }
 
@@ -228,7 +228,7 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
 	head = &fib_info_hash[hash];
 
 	hlist_for_each_entry(fi, node, head, fib_hash) {
-		if (fi->fib_net != nfi->fib_net)
+		if (!net_eq(read_pnet(&fi->fib_net),read_pnet(&nfi->fib_net)))
 			continue;
 		if (fi->fib_nhs != nfi->fib_nhs)
 			continue;
@@ -729,7 +729,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		goto failure;
 	fib_info_cnt++;
 
-	fi->fib_net = hold_net(net);
+	write_pnet(&fi->fib_net, hold_net(net));
 	fi->fib_protocol = cfg->fc_protocol;
 	fi->fib_flags = cfg->fc_flags;
 	fi->fib_priority = cfg->fc_priority;
@@ -1047,7 +1047,7 @@ int fib_sync_down_addr(struct net *net, __be32 local)
 		return 0;
 
 	hlist_for_each_entry(fi, node, head, fib_lhash) {
-		if (fi->fib_net != net)
+		if (!net_eq(read_pnet(&fi->fib_net),net))
 			continue;
 		if (fi->fib_prefsrc == local) {
 			fi->fib_flags |= RTNH_F_DEAD;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 36f4cbc..0c61f69 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -109,7 +109,8 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 					hashinfo->bhash_size)];
 			spin_lock(&head->lock);
 			inet_bind_bucket_for_each(tb, node, &head->chain)
-				if (tb->ib_net == net && tb->port == rover)
+				if (net_eq(read_pnet(&tb->ib_net), net) &&
+					tb->port == rover)
 					goto next;
 			break;
 		next:
@@ -137,7 +138,8 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 				hashinfo->bhash_size)];
 		spin_lock(&head->lock);
 		inet_bind_bucket_for_each(tb, node, &head->chain)
-			if (tb->ib_net == net && tb->port == snum)
+			if (net_eq(read_pnet(&tb->ib_net), net) &&
+				tb->port == snum)
 				goto tb_found;
 	}
 	tb = NULL;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 4498190..30aa9ff 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -35,7 +35,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
 
 	if (tb != NULL) {
-		tb->ib_net       = hold_net(net);
+		write_pnet(&tb->ib_net, hold_net(net));
 		tb->port      = snum;
 		tb->fastreuse = 0;
 		INIT_HLIST_HEAD(&tb->owners);
@@ -51,7 +51,7 @@ void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket
 {
 	if (hlist_empty(&tb->owners)) {
 		__hlist_del(&tb->node);
-		release_net(tb->ib_net);
+		release_net(read_pnet(&tb->ib_net));
 		kmem_cache_free(cachep, tb);
 	}
 }
@@ -449,7 +449,8 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			 * unique enough.
 			 */
 			inet_bind_bucket_for_each(tb, node, &head->chain) {
-				if (tb->ib_net == net && tb->port == port) {
+				if (net_eq(read_pnet(&tb->ib_net), net) &&
+					tb->port == port) {
 					WARN_ON(hlist_empty(&tb->owners));
 					if (tb->fastreuse >= 0)
 						goto next_port;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 313ebf0..6ba76ce 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -12,6 +12,7 @@
 #include <linux/seq_file.h>
 #include <linux/percpu.h>
 #include <net/net_namespace.h>
+#include <linux/seq_file_net.h>
 
 #include <linux/netfilter.h>
 #include <net/netfilter/nf_conntrack_core.h>
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 6ff73c4..f021bed 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -29,9 +29,7 @@
  */
 struct ip6addrlbl_entry
 {
-#ifdef CONFIG_NET_NS
-	struct net *lbl_net;
-#endif
+	DECLARE_PNET(lbl_net)
 	struct in6_addr prefix;
 	int prefixlen;
 	int ifindex;
@@ -52,11 +50,7 @@ static struct ip6addrlbl_table
 static inline
 struct net *ip6addrlbl_net(const struct ip6addrlbl_entry *lbl)
 {
-#ifdef CONFIG_NET_NS
-	return lbl->lbl_net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&lbl->lbl_net);
 }
 
 /*
@@ -121,9 +115,7 @@ static const __net_initdata struct ip6addrlbl_init_table
 /* Object management */
 static inline void ip6addrlbl_free(struct ip6addrlbl_entry *p)
 {
-#ifdef CONFIG_NET_NS
-	release_net(p->lbl_net);
-#endif
+	release_net(read_pnet(&p->lbl_net));
 	kfree(p);
 }
 
@@ -233,9 +225,7 @@ static struct ip6addrlbl_entry *ip6addrlbl_alloc(struct net *net,
 	newp->addrtype = addrtype;
 	newp->label = label;
 	INIT_HLIST_NODE(&newp->list);
-#ifdef CONFIG_NET_NS
-	newp->lbl_net = hold_net(net);
-#endif
+	write_pnet(&newp->lbl_net, hold_net(net));
 	atomic_set(&newp->refcnt, 1);
 	return newp;
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d40dc2..5820738 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1025,7 +1025,7 @@ static void icmp6_clean_all(int (*func)(struct rt6_info *rt, void *arg),
 static int ip6_dst_gc(struct dst_ops *ops)
 {
 	unsigned long now = jiffies;
-	struct net *net = ops->dst_net;
+	struct net *net = read_pnet(&ops->dst_net);
 	int rt_min_interval = net->ipv6.sysctl.ip6_rt_gc_min_interval;
 	int rt_max_size = net->ipv6.sysctl.ip6_rt_max_size;
 	int rt_elasticity = net->ipv6.sysctl.ip6_rt_gc_elasticity;
@@ -2616,7 +2616,7 @@ static int ip6_route_net_init(struct net *net)
 					GFP_KERNEL);
 	if (!net->ipv6.ip6_dst_ops)
 		goto out;
-	net->ipv6.ip6_dst_ops->dst_net = hold_net(net);
+	write_pnet(&net->ipv6.ip6_dst_ops->dst_net, hold_net(net));
 
 	net->ipv6.ip6_null_entry = kmemdup(&ip6_null_entry_template,
 					   sizeof(*net->ipv6.ip6_null_entry),
@@ -2673,7 +2673,7 @@ out_ip6_null_entry:
 	kfree(net->ipv6.ip6_null_entry);
 #endif
 out_ip6_dst_ops:
-	release_net(net->ipv6.ip6_dst_ops->dst_net);
+	release_net(read_pnet(&net->ipv6.ip6_dst_ops->dst_net));
 	kfree(net->ipv6.ip6_dst_ops);
 	goto out;
 }
@@ -2689,7 +2689,7 @@ static void ip6_route_net_exit(struct net *net)
 	kfree(net->ipv6.ip6_prohibit_entry);
 	kfree(net->ipv6.ip6_blk_hole_entry);
 #endif
-	release_net(net->ipv6.ip6_dst_ops->dst_net);
+	release_net(read_pnet(&net->ipv6.ip6_dst_ops->dst_net));
 	kfree(net->ipv6.ip6_dst_ops);
 }
 
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index 9fe8982..4d73477 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -15,6 +15,7 @@
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_extend.h>
 #include <net/netfilter/nf_conntrack_acct.h>
+#include <linux/seq_file_net.h>
 
 #ifdef CONFIG_NF_CT_ACCT
 #define NF_CT_ACCT_DEFAULT 1
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 622d7c6..b210d4c 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -505,9 +505,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 	ct->tuplehash[IP_CT_DIR_REPLY].tuple = *repl;
 	/* Don't set timer yet: wait for confirmation */
 	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
-#ifdef CONFIG_NET_NS
-	ct->ct_net = net;
-#endif
+	write_pnet(&ct->ct_net, net);
 	INIT_RCU_HEAD(&ct->rcu);
 
 	return ct;
@@ -1232,9 +1230,7 @@ static int nf_conntrack_init_net(struct net *net)
 
 	/* Set up fake conntrack:
 	    - to never be deleted, not in any hashes */
-#ifdef CONFIG_NET_NS
-	nf_conntrack_untracked.ct_net = &init_net;
-#endif
+	write_pnet(&nf_conntrack_untracked.ct_net, &init_net);
 	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
 	/*  - and look it like as a confirmed connection */
 	set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 37a703b..8cd2694 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -422,6 +422,7 @@ out:
 EXPORT_SYMBOL_GPL(nf_ct_expect_related);
 
 #ifdef CONFIG_PROC_FS
+#include <linux/seq_file_net.h>
 struct ct_expect_iter_state {
 	struct seq_net_private p;
 	unsigned int bucket;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index f37b9b7..6ae6494 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -15,6 +15,7 @@
 #include <linux/percpu.h>
 #include <linux/netdevice.h>
 #include <net/net_namespace.h>
+#include <linux/seq_file_net.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 89837a4..a8313e1 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -749,6 +749,7 @@ void *xt_unregister_table(struct xt_table *table)
 EXPORT_SYMBOL_GPL(xt_unregister_table);
 
 #ifdef CONFIG_PROC_FS
+#include <linux/seq_file_net.h>
 struct xt_names_priv {
 	struct seq_net_private p;
 	u_int8_t af;

--------------000203000204060201020602--
