From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH] inet: Initialize per-netns inetpeer roots in
	net/ipv{4,6}/route.c
Date: Sat, 09 Jun 2012 16:32:02 -0700 (PDT)
Message-ID: <20120609.163202.516027044484907548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, wfg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org


Instead of net/ipv4/inetpeer.c

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/net/inetpeer.h |    9 +++++++
 net/ipv4/inetpeer.c    |   64 ++++++++++++------------------------------------
 net/ipv4/route.c       |   25 +++++++++++++++++++
 net/ipv6/route.c       |   34 ++++++++++++++++++++++++-
 4 files changed, 83 insertions(+), 49 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 20e67db..5a96c8e 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -65,6 +65,14 @@ struct inet_peer {
 	atomic_t		refcnt;
 };
 
+struct inet_peer_base {
+	struct inet_peer __rcu	*root;
+	seqlock_t		lock;
+	int			total;
+};
+
+extern void inet_peer_base_init(struct inet_peer_base *);
+
 void			inet_initpeers(void) __init;
 
 #define INETPEER_METRICS_NEW	(~(u32) 0)
@@ -105,6 +113,7 @@ static inline struct inet_peer *inet_getpeer_v6(struct net *net,
 extern void inet_putpeer(struct inet_peer *p);
 extern bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
 
+extern void __inetpeer_invalidate_tree(struct inet_peer_base *);
 extern void inetpeer_invalidate_tree(struct net *net, int family);
 
 /*
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 1c85273..d0d72f8 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -82,11 +82,13 @@ static const struct inet_peer peer_fake_node = {
 	.avl_height	= 0
 };
 
-struct inet_peer_base {
-	struct inet_peer __rcu *root;
-	seqlock_t	lock;
-	int		total;
-};
+void inet_peer_base_init(struct inet_peer_base *bp)
+{
+	bp->root = peer_avl_empty_rcu;
+	seqlock_init(&bp->lock);
+	bp->total = 0;
+}
+EXPORT_SYMBOL_GPL(inet_peer_base_init);
 
 #define PEER_MAXDEPTH 40 /* sufficient for about 2^27 nodes */
 
@@ -141,46 +143,6 @@ static void inetpeer_gc_worker(struct work_struct *work)
 	schedule_delayed_work(&gc_work, gc_delay);
 }
 
-static int __net_init inetpeer_net_init(struct net *net)
-{
-	net->ipv4.peers = kzalloc(sizeof(struct inet_peer_base),
-				  GFP_KERNEL);
-	if (net->ipv4.peers == NULL)
-		return -ENOMEM;
-
-	net->ipv4.peers->root = peer_avl_empty_rcu;
-	seqlock_init(&net->ipv4.peers->lock);
-
-	net->ipv6.peers = kzalloc(sizeof(struct inet_peer_base),
-				  GFP_KERNEL);
-	if (net->ipv6.peers == NULL)
-		goto out_ipv6;
-
-	net->ipv6.peers->root = peer_avl_empty_rcu;
-	seqlock_init(&net->ipv6.peers->lock);
-
-	return 0;
-out_ipv6:
-	kfree(net->ipv4.peers);
-	return -ENOMEM;
-}
-
-static void __net_exit inetpeer_net_exit(struct net *net)
-{
-	inetpeer_invalidate_tree(net, AF_INET);
-	kfree(net->ipv4.peers);
-	net->ipv4.peers = NULL;
-
-	inetpeer_invalidate_tree(net, AF_INET6);
-	kfree(net->ipv6.peers);
-	net->ipv6.peers = NULL;
-}
-
-static struct pernet_operations inetpeer_ops = {
-	.init = inetpeer_net_init,
-	.exit = inetpeer_net_exit,
-};
-
 /* Called from ip_output.c:ip_init  */
 void __init inet_initpeers(void)
 {
@@ -205,7 +167,6 @@ void __init inet_initpeers(void)
 			NULL);
 
 	INIT_DELAYED_WORK_DEFERRABLE(&gc_work, inetpeer_gc_worker);
-	register_pernet_subsys(&inetpeer_ops);
 }
 
 static int addr_compare(const struct inetpeer_addr *a,
@@ -603,10 +564,9 @@ static void inetpeer_inval_rcu(struct rcu_head *head)
 	schedule_delayed_work(&gc_work, gc_delay);
 }
 
-void inetpeer_invalidate_tree(struct net *net, int family)
+void __inetpeer_invalidate_tree(struct inet_peer_base *base)
 {
 	struct inet_peer *old, *new, *prev;
-	struct inet_peer_base *base = family_to_base(net, family);
 
 	write_seqlock_bh(&base->lock);
 
@@ -625,4 +585,12 @@ void inetpeer_invalidate_tree(struct net *net, int family)
 out:
 	write_sequnlock_bh(&base->lock);
 }
+EXPORT_SYMBOL(__inetpeer_invalidate_tree);
+
+void inetpeer_invalidate_tree(struct net *net, int family)
+{
+	struct inet_peer_base *base = family_to_base(net, family);
+
+	__inetpeer_invalidate_tree(base);
+}
 EXPORT_SYMBOL(inetpeer_invalidate_tree);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7a4d724..4cd35c3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3385,6 +3385,30 @@ static __net_initdata struct pernet_operations rt_genid_ops = {
 	.init = rt_genid_init,
 };
 
+static int __net_init ipv4_inetpeer_init(struct net *net)
+{
+	struct inet_peer_base *bp = kmalloc(sizeof(*bp), GFP_KERNEL);
+
+	if (!bp)
+		return -ENOMEM;
+	inet_peer_base_init(bp);
+	net->ipv4.peers = bp;
+	return 0;
+}
+
+static void __net_exit ipv4_inetpeer_exit(struct net *net)
+{
+	struct inet_peer_base *bp = net->ipv4.peers;
+
+	net->ipv4.peers = NULL;
+	__inetpeer_invalidate_tree(bp);
+	kfree(bp);
+}
+
+static __net_initdata struct pernet_operations ipv4_inetpeer_ops = {
+	.init	=	ipv4_inetpeer_init,
+	.exit	=	ipv4_inetpeer_exit,
+};
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
 struct ip_rt_acct __percpu *ip_rt_acct __read_mostly;
@@ -3465,6 +3489,7 @@ int __init ip_rt_init(void)
 	register_pernet_subsys(&sysctl_route_ops);
 #endif
 	register_pernet_subsys(&rt_genid_ops);
+	register_pernet_subsys(&ipv4_inetpeer_ops);
 	return rc;
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8a986be..3e1e4e0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2996,6 +2996,31 @@ static struct pernet_operations ip6_route_net_ops = {
 	.exit = ip6_route_net_exit,
 };
 
+static int __net_init ipv6_inetpeer_init(struct net *net)
+{
+	struct inet_peer_base *bp = kmalloc(sizeof(*bp), GFP_KERNEL);
+
+	if (!bp)
+		return -ENOMEM;
+	inet_peer_base_init(bp);
+	net->ipv6.peers = bp;
+	return 0;
+}
+
+static void __net_exit ipv6_inetpeer_exit(struct net *net)
+{
+	struct inet_peer_base *bp = net->ipv6.peers;
+
+	net->ipv6.peers = NULL;
+	__inetpeer_invalidate_tree(bp);
+	kfree(bp);
+}
+
+static __net_initdata struct pernet_operations ipv6_inetpeer_ops = {
+	.init	=	ipv6_inetpeer_init,
+	.exit	=	ipv6_inetpeer_exit,
+};
+
 static struct notifier_block ip6_route_dev_notifier = {
 	.notifier_call = ip6_route_dev_notify,
 	.priority = 0,
@@ -3020,6 +3045,10 @@ int __init ip6_route_init(void)
 	if (ret)
 		goto out_dst_entries;
 
+	ret = register_pernet_subsys(&ipv6_inetpeer_ops);
+	if (ret)
+		goto out_register_subsys;
+
 	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops_template.kmem_cachep;
 
 	/* Registering of the loopback is done before this portion of code,
@@ -3035,7 +3064,7 @@ int __init ip6_route_init(void)
   #endif
 	ret = fib6_init();
 	if (ret)
-		goto out_register_subsys;
+		goto out_register_inetpeer;
 
 	ret = xfrm6_init();
 	if (ret)
@@ -3064,6 +3093,8 @@ xfrm6_init:
 	xfrm6_fini();
 out_fib6_init:
 	fib6_gc_cleanup();
+out_register_inetpeer:
+	unregister_pernet_subsys(&ipv6_inetpeer_ops);
 out_register_subsys:
 	unregister_pernet_subsys(&ip6_route_net_ops);
 out_dst_entries:
@@ -3079,6 +3110,7 @@ void ip6_route_cleanup(void)
 	fib6_rules_cleanup();
 	xfrm6_fini();
 	fib6_gc_cleanup();
+	unregister_pernet_subsys(&ipv6_inetpeer_ops);
 	unregister_pernet_subsys(&ip6_route_net_ops);
 	dst_entries_destroy(&ip6_dst_blackhole_ops);
 	kmem_cache_destroy(ip6_dst_ops_template.kmem_cachep);
-- 
1.7.10
