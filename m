From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 1/2] net: Kill hold_net release_net
Date: Wed, 11 Mar 2015 23:04:08 -0500
Message-ID: <87ioe67tfr.fsf_-_@x220.int.ebiederm.org>
References: <20150311.215553.1544350193194225837.davem@davemloft.net>
	<1426128863.11398.135.camel@edumazet-glaptop2.roam.corp.google.com>
	<1426130872.11398.141.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150311.232940.1345045254716776224.davem@davemloft.net>
	<87oany7tha.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, salo@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40888 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbbCLEHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 00:07:49 -0400
In-Reply-To: <87oany7tha.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 11 Mar 2015 23:03:13 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


hold_net and release_net were an idea that turned out to be useless.
The code has been disabled since 2008.  Kill the code it is long past due.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netdevice.h     |  3 +--
 include/net/fib_rules.h       |  9 +--------
 include/net/net_namespace.h   | 29 -----------------------------
 include/net/sock.h            |  2 +-
 net/core/dev.c                |  2 --
 net/core/fib_rules.c          | 17 +++--------------
 net/core/neighbour.c          |  9 ++-------
 net/core/net_namespace.c      | 11 -----------
 net/core/sock.c               |  1 -
 net/ipv4/fib_semantics.c      |  3 +--
 net/ipv4/inet_hashtables.c    |  3 +--
 net/ipv4/inet_timewait_sock.c |  3 +--
 net/ipv6/addrlabel.c          |  5 +----
 net/ipv6/ip6_flowlabel.c      |  3 +--
 net/openvswitch/datapath.c    |  4 +---
 15 files changed, 14 insertions(+), 90 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1354ae83efc8..cede40d9cac9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1864,8 +1864,7 @@ static inline
 void dev_net_set(struct net_device *dev, struct net *net)
 {
 #ifdef CONFIG_NET_NS
-	release_net(dev->nd_net);
-	dev->nd_net = hold_net(net);
+	dev->nd_net = net;
 #endif
 }
 
diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 88d2ae526961..6d67383a5114 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -95,17 +95,10 @@ static inline void fib_rule_get(struct fib_rule *rule)
 	atomic_inc(&rule->refcnt);
 }
 
-static inline void fib_rule_put_rcu(struct rcu_head *head)
-{
-	struct fib_rule *rule = container_of(head, struct fib_rule, rcu);
-	release_net(rule->fr_net);
-	kfree(rule);
-}
-
 static inline void fib_rule_put(struct fib_rule *rule)
 {
 	if (atomic_dec_and_test(&rule->refcnt))
-		call_rcu(&rule->rcu, fib_rule_put_rcu);
+		kfree_rcu(rule, rcu);
 }
 
 static inline u32 frh_get_table(struct fib_rule_hdr *frh, struct nlattr **nla)
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index e086f4030dd2..fab51ceeabf3 100644
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
 
 	atomic64_t		cookie_gen;
@@ -236,30 +231,6 @@ int net_eq(const struct net *net1, const struct net *net2)
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
index d996c633bec2..95b2c1c220f9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2204,7 +2204,7 @@ static inline void sk_change_net(struct sock *sk, struct net *net)
 
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
index b55677fed1c8..68ea6950cad1 100644
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
@@ -160,15 +159,6 @@ static void fib_rules_cleanup_ops(struct fib_rules_ops *ops)
 	}
 }
 
-static void fib_rules_put_rcu(struct rcu_head *head)
-{
-	struct fib_rules_ops *ops = container_of(head, struct fib_rules_ops, rcu);
-	struct net *net = ops->fro_net;
-
-	release_net(net);
-	kfree(ops);
-}
-
 void fib_rules_unregister(struct fib_rules_ops *ops)
 {
 	struct net *net = ops->fro_net;
@@ -178,7 +168,7 @@ void fib_rules_unregister(struct fib_rules_ops *ops)
 	fib_rules_cleanup_ops(ops);
 	spin_unlock(&net->rules_mod_lock);
 
-	call_rcu(&ops->rcu, fib_rules_put_rcu);
+	kfree_rcu(ops, rcu);
 }
 EXPORT_SYMBOL_GPL(fib_rules_unregister);
 
@@ -303,7 +293,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 		err = -ENOMEM;
 		goto errout;
 	}
-	rule->fr_net = hold_net(net);
+	rule->fr_net = net;
 
 	if (tb[FRA_PRIORITY])
 		rule->pref = nla_get_u32(tb[FRA_PRIORITY]);
@@ -423,7 +413,6 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
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
index a9a9c2ff9260..c8842f279f7a 100644
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
index 2bd980526631..86ebf020925b 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -98,7 +98,6 @@ void inet_twsk_free(struct inet_timewait_sock *tw)
 #ifdef SOCK_REFCNT_DEBUG
 	pr_debug("%s timewait_sock %p released\n", tw->tw_prot->name, tw);
 #endif
-	release_net(twsk_net(tw));
 	kmem_cache_free(tw->tw_prot->twsk_prot->twsk_slab, tw);
 	module_put(owner);
 }
@@ -196,7 +195,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_transparent  = inet->transparent;
 		tw->tw_prot	    = sk->sk_prot_creator;
 		atomic64_set(&tw->tw_cookie, atomic64_read(&sk->sk_cookie));
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
