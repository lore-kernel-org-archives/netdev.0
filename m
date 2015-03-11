From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 1/8] net: Kill hold_net release_net
Date: Wed, 11 Mar 2015 11:35:16 -0500
Message-ID: <87pp8ffq63.fsf_-_@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com,
	Julian Anastasov <ja@ssi.bg>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:54874 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbbCKQjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 12:39:01 -0400
In-Reply-To: <87vbi7fq92.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 11 Mar 2015 11:33:29 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


hold_net and release_net were an idea that didn't work.  Kill them
it is long past due.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netdevice.h     |  3 +--
 include/net/fib_rules.h       |  1 -
 include/net/net_namespace.h   | 29 -----------------------------
 include/net/sock.h            |  2 +-
 net/core/dev.c                |  2 --
 net/core/fib_rules.c          |  8 ++------
 net/core/neighbour.c          |  9 ++-------
 net/core/net_namespace.c      | 11 -----------
 net/core/sock.c               |  1 -
 net/ipv4/fib_semantics.c      |  3 +--
 net/ipv4/inet_hashtables.c    |  3 +--
 net/ipv4/inet_timewait_sock.c |  4 ++--
 net/ipv6/addrlabel.c          |  5 +----
 net/ipv6/ip6_flowlabel.c      |  3 +--
 net/openvswitch/datapath.c    |  4 +---
 15 files changed, 13 insertions(+), 75 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 45413784a3b1..b214ba2ebbce 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1863,8 +1863,7 @@ static inline
 void dev_net_set(struct net_device *dev, struct net *net)
 {
 #ifdef CONFIG_NET_NS
-	release_net(dev->nd_net);
-	dev->nd_net = hold_net(net);
+	dev->nd_net = net;
 #endif
 }
 
diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index e584de16e4c3..ef94dc379e6f 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -98,7 +98,6 @@ static inline void fib_rule_get(struct fib_rule *rule)
 static inline void fib_rule_put_rcu(struct rcu_head *head)
 {
 	struct fib_rule *rule = container_of(head, struct fib_rule, rcu);
-	release_net(rule->fr_net);
 	kfree(rule);
 }
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 2cb9acb618e9..6fd76650d36f 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -49,11 +49,6 @@ struct net {
 	atomic_t		count;		/* To decided when the network
 						 *  namespace should be shut down.
 						 */
-#ifdef NETNS_REFCNT_DEBUG
-	atomic_t		use_count;	/* To track references we
-						 * destroy on demand
-						 */
-#endif
 	spinlock_t		rules_mod_lock;
 
 	struct list_head	list;		/* list of network namespaces */
@@ -234,30 +229,6 @@ int net_eq(const struct net *net1, const struct net *net2)
 #endif
 
 
-#ifdef NETNS_REFCNT_DEBUG
-static inline struct net *hold_net(struct net *net)
-{
-	if (net)
-		atomic_inc(&net->use_count);
-	return net;
-}
-
-static inline void release_net(struct net *net)
-{
-	if (net)
-		atomic_dec(&net->use_count);
-}
-#else
-static inline struct net *hold_net(struct net *net)
-{
-	return net;
-}
-
-static inline void release_net(struct net *net)
-{
-}
-#endif
-
 #ifdef CONFIG_NET_NS
 
 static inline void write_pnet(struct net **pnet, struct net *net)
diff --git a/include/net/sock.h b/include/net/sock.h
index 250822cc1e02..40437e0a94a8 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2201,7 +2201,7 @@ static inline void sk_change_net(struct sock *sk, struct net *net)
 
 	if (!net_eq(current_net, net)) {
 		put_net(current_net);
-		sock_net_set(sk, hold_net(net));
+		sock_net_set(sk, net);
 	}
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 962ee9d71964..39fe369b46ad 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6841,8 +6841,6 @@ void free_netdev(struct net_device *dev)
 {
 	struct napi_struct *p, *n;
 
-	release_net(dev_net(dev));
-
 	netif_free_tx_queues(dev);
 #ifdef CONFIG_SYSFS
 	kvfree(dev->_rx);
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 44706e81b2e0..0b204626f784 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -31,7 +31,7 @@ int fib_default_rule_add(struct fib_rules_ops *ops,
 	r->pref = pref;
 	r->table = table;
 	r->flags = flags;
-	r->fr_net = hold_net(ops->fro_net);
+	r->fr_net = ops->fro_net;
 
 	r->suppress_prefixlen = -1;
 	r->suppress_ifgroup = -1;
@@ -116,7 +116,6 @@ static int __fib_rules_register(struct fib_rules_ops *ops)
 		if (ops->family == o->family)
 			goto errout;
 
-	hold_net(net);
 	list_add_tail_rcu(&ops->list, &net->rules_ops);
 	err = 0;
 errout:
@@ -163,9 +162,7 @@ static void fib_rules_cleanup_ops(struct fib_rules_ops *ops)
 static void fib_rules_put_rcu(struct rcu_head *head)
 {
 	struct fib_rules_ops *ops = container_of(head, struct fib_rules_ops, rcu);
-	struct net *net = ops->fro_net;
 
-	release_net(net);
 	kfree(ops);
 }
 
@@ -303,7 +300,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 		err = -ENOMEM;
 		goto errout;
 	}
-	rule->fr_net = hold_net(net);
+	rule->fr_net = net;
 
 	if (tb[FRA_PRIORITY])
 		rule->pref = nla_get_u32(tb[FRA_PRIORITY]);
@@ -423,7 +420,6 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	return 0;
 
 errout_free:
-	release_net(rule->fr_net);
 	kfree(rule);
 errout:
 	rules_ops_put(ops);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ad07990e943d..0e8b32efc031 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -591,7 +591,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 	if (!n)
 		goto out;
 
-	write_pnet(&n->net, hold_net(net));
+	write_pnet(&n->net, net);
 	memcpy(n->key, pkey, key_len);
 	n->dev = dev;
 	if (dev)
@@ -600,7 +600,6 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 	if (tbl->pconstructor && tbl->pconstructor(n)) {
 		if (dev)
 			dev_put(dev);
-		release_net(net);
 		kfree(n);
 		n = NULL;
 		goto out;
@@ -634,7 +633,6 @@ int pneigh_delete(struct neigh_table *tbl, struct net *net, const void *pkey,
 				tbl->pdestructor(n);
 			if (n->dev)
 				dev_put(n->dev);
-			release_net(pneigh_net(n));
 			kfree(n);
 			return 0;
 		}
@@ -657,7 +655,6 @@ static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 					tbl->pdestructor(n);
 				if (n->dev)
 					dev_put(n->dev);
-				release_net(pneigh_net(n));
 				kfree(n);
 				continue;
 			}
@@ -1428,11 +1425,10 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 				neigh_rand_reach_time(NEIGH_VAR(p, BASE_REACHABLE_TIME));
 		dev_hold(dev);
 		p->dev = dev;
-		write_pnet(&p->net, hold_net(net));
+		write_pnet(&p->net, net);
 		p->sysctl_table = NULL;
 
 		if (ops->ndo_neigh_setup && ops->ndo_neigh_setup(dev, p)) {
-			release_net(net);
 			dev_put(dev);
 			kfree(p);
 			return NULL;
@@ -1472,7 +1468,6 @@ EXPORT_SYMBOL(neigh_parms_release);
 
 static void neigh_parms_destroy(struct neigh_parms *parms)
 {
-	release_net(neigh_parms_net(parms));
 	kfree(parms);
 }
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index cb5290b8c428..e5e96b0f6717 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -236,10 +236,6 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 	net->user_ns = user_ns;
 	idr_init(&net->netns_ids);
 
-#ifdef NETNS_REFCNT_DEBUG
-	atomic_set(&net->use_count, 0);
-#endif
-
 	list_for_each_entry(ops, &pernet_list, list) {
 		error = ops_init(ops, net);
 		if (error < 0)
@@ -294,13 +290,6 @@ out_free:
 
 static void net_free(struct net *net)
 {
-#ifdef NETNS_REFCNT_DEBUG
-	if (unlikely(atomic_read(&net->use_count) != 0)) {
-		pr_emerg("network namespace not free! Usage: %d\n",
-			 atomic_read(&net->use_count));
-		return;
-	}
-#endif
 	kfree(rcu_access_pointer(net->gen));
 	kmem_cache_free(net_cachep, net);
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 726e1f99aa8d..cb5cf93683c8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1455,7 +1455,6 @@ void sk_release_kernel(struct sock *sk)
 
 	sock_hold(sk);
 	sock_release(sk->sk_socket);
-	release_net(sock_net(sk));
 	sock_net_set(sk, get_net(&init_net));
 	sock_put(sk);
 }
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index c6d267442dac..66c1e4fbf884 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -213,7 +213,6 @@ static void free_fib_info_rcu(struct rcu_head *head)
 		rt_fibinfo_free(&nexthop_nh->nh_rth_input);
 	} endfor_nexthops(fi);
 
-	release_net(fi->fib_net);
 	if (fi->fib_metrics != (u32 *) dst_default_metrics)
 		kfree(fi->fib_metrics);
 	kfree(fi);
@@ -814,7 +813,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	} else
 		fi->fib_metrics = (u32 *) dst_default_metrics;
 
-	fi->fib_net = hold_net(net);
+	fi->fib_net = net;
 	fi->fib_protocol = cfg->fc_protocol;
 	fi->fib_scope = cfg->fc_scope;
 	fi->fib_flags = cfg->fc_flags;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 9111a4e22155..f6a12b97d12b 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -61,7 +61,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
 
 	if (tb != NULL) {
-		write_pnet(&tb->ib_net, hold_net(net));
+		write_pnet(&tb->ib_net, net);
 		tb->port      = snum;
 		tb->fastreuse = 0;
 		tb->fastreuseport = 0;
@@ -79,7 +79,6 @@ void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket
 {
 	if (hlist_empty(&tb->owners)) {
 		__hlist_del(&tb->node);
-		release_net(ib_net(tb));
 		kmem_cache_free(cachep, tb);
 	}
 }
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 6d592f8555fb..e0d5c8327159 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -98,7 +98,7 @@ void inet_twsk_free(struct inet_timewait_sock *tw)
 #ifdef SOCK_REFCNT_DEBUG
 	pr_debug("%s timewait_sock %p released\n", tw->tw_prot->name, tw);
 #endif
-	release_net(twsk_net(tw));
+	twsk_net(tw);
 	kmem_cache_free(tw->tw_prot->twsk_prot->twsk_slab, tw);
 	module_put(owner);
 }
@@ -195,7 +195,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_ipv6only	    = 0;
 		tw->tw_transparent  = inet->transparent;
 		tw->tw_prot	    = sk->sk_prot_creator;
-		twsk_net_set(tw, hold_net(sock_net(sk)));
+		twsk_net_set(tw, sock_net(sk));
 		/*
 		 * Because we use RCU lookups, we should not set tw_refcnt
 		 * to a non null value before everything is setup for this
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index e43e79d0a612..59c793040498 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -129,9 +129,6 @@ static const __net_initconst struct ip6addrlbl_init_table
 /* Object management */
 static inline void ip6addrlbl_free(struct ip6addrlbl_entry *p)
 {
-#ifdef CONFIG_NET_NS
-	release_net(p->lbl_net);
-#endif
 	kfree(p);
 }
 
@@ -241,7 +238,7 @@ static struct ip6addrlbl_entry *ip6addrlbl_alloc(struct net *net,
 	newp->label = label;
 	INIT_HLIST_NODE(&newp->list);
 #ifdef CONFIG_NET_NS
-	newp->lbl_net = hold_net(net);
+	newp->lbl_net = net;
 #endif
 	atomic_set(&newp->refcnt, 1);
 	return newp;
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index f45d6db50a45..457303886fd4 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -100,7 +100,6 @@ static void fl_free(struct ip6_flowlabel *fl)
 	if (fl) {
 		if (fl->share == IPV6_FL_S_PROCESS)
 			put_pid(fl->owner.pid);
-		release_net(fl->fl_net);
 		kfree(fl->opt);
 		kfree_rcu(fl, rcu);
 	}
@@ -403,7 +402,7 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 		}
 	}
 
-	fl->fl_net = hold_net(net);
+	fl->fl_net = net;
 	fl->expires = jiffies;
 	err = fl6_renew(fl, freq->flr_linger, freq->flr_expires);
 	if (err)
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 5bae7243c577..096c6276e6b9 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -203,7 +203,6 @@ static void destroy_dp_rcu(struct rcu_head *rcu)
 
 	ovs_flow_tbl_destroy(&dp->table);
 	free_percpu(dp->stats_percpu);
-	release_net(ovs_dp_get_net(dp));
 	kfree(dp->ports);
 	kfree(dp);
 }
@@ -1501,7 +1500,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	if (dp == NULL)
 		goto err_free_reply;
 
-	ovs_dp_set_net(dp, hold_net(sock_net(skb->sk)));
+	ovs_dp_set_net(dp, sock_net(skb->sk));
 
 	/* Allocate table. */
 	err = ovs_flow_tbl_init(&dp->table);
@@ -1575,7 +1574,6 @@ err_destroy_percpu:
 err_destroy_table:
 	ovs_flow_tbl_destroy(&dp->table);
 err_free_dp:
-	release_net(ovs_dp_get_net(dp));
 	kfree(dp);
 err_free_reply:
 	kfree_skb(reply);
-- 
2.2.1
