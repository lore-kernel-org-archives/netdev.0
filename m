From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH net-next v3 1/2] inetpeer: add namespace support for inetpeer
Date: Fri, 8 Jun 2012 19:20:41 +0800
Message-ID: <1339154441-4513-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org
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

now inetpeer doesn't support namespace,the information will
be leaking across namespace.

this patch move the global vars v4_peers and v6_peers to
netns_ipv4 and netns_ipv6 as a field peers.

add struct pernet_operations inetpeer_ops to initial pernet
inetpeer data.

and change family_to_base and inet_getpeer to support namespace.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/net/inetpeer.h   |   10 ++++---
 include/net/netns/ipv4.h |    2 +-
 include/net/netns/ipv6.h |    1 +
 net/ipv4/inetpeer.c      |   68 +++++++++++++++++++++++++++++++++------------
 net/ipv4/route.c         |    2 +-
 5 files changed, 59 insertions(+), 24 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 2040bff..fef9dfa 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -75,7 +75,9 @@ static inline bool inet_metrics_new(const struct inet_peer *p)
 }
 
 /* can be called with or without local BH being disabled */
-struct inet_peer	*inet_getpeer(const struct inetpeer_addr *daddr, int create);
+struct inet_peer *inet_getpeer(struct net *net,
+			       const struct inetpeer_addr *daddr,
+			       int create);
 
 static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
 {
@@ -83,7 +85,7 @@ static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
 
 	daddr.addr.a4 = v4daddr;
 	daddr.family = AF_INET;
-	return inet_getpeer(&daddr, create);
+	return inet_getpeer(&init_net, &daddr, create);
 }
 
 static inline struct inet_peer *inet_getpeer_v6(const struct in6_addr *v6daddr, int create)
@@ -92,14 +94,14 @@ static inline struct inet_peer *inet_getpeer_v6(const struct in6_addr *v6daddr,
 
 	*(struct in6_addr *)daddr.addr.a6 = *v6daddr;
 	daddr.family = AF_INET6;
-	return inet_getpeer(&daddr, create);
+	return inet_getpeer(&init_net, &daddr, create);
 }
 
 /* can be called from BH context or outside */
 extern void inet_putpeer(struct inet_peer *p);
 extern bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
 
-extern void inetpeer_invalidate_tree(int family);
+extern void inetpeer_invalidate_tree(struct net *net, int family);
 
 /*
  * temporary check to make sure we dont access rid, ip_id_count, tcp_ts,
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index bbd023a..227f0cd 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -30,7 +30,7 @@ struct netns_ipv4 {
 
 	struct sock		**icmp_sk;
 	struct sock		*tcp_sock;
-
+	struct inet_peer_base	*peers;
 	struct netns_frags	frags;
 #ifdef CONFIG_NETFILTER
 	struct xt_table		*iptable_filter;
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index b42be53..df0a545 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -33,6 +33,7 @@ struct netns_ipv6 {
 	struct netns_sysctl_ipv6 sysctl;
 	struct ipv6_devconf	*devconf_all;
 	struct ipv6_devconf	*devconf_dflt;
+	struct inet_peer_base	*peers;
 	struct netns_frags	frags;
 #ifdef CONFIG_NETFILTER
 	struct xt_table		*ip6table_filter;
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index dfba343..1c85273 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -88,18 +88,6 @@ struct inet_peer_base {
 	int		total;
 };
 
-static struct inet_peer_base v4_peers = {
-	.root		= peer_avl_empty_rcu,
-	.lock		= __SEQLOCK_UNLOCKED(v4_peers.lock),
-	.total		= 0,
-};
-
-static struct inet_peer_base v6_peers = {
-	.root		= peer_avl_empty_rcu,
-	.lock		= __SEQLOCK_UNLOCKED(v6_peers.lock),
-	.total		= 0,
-};
-
 #define PEER_MAXDEPTH 40 /* sufficient for about 2^27 nodes */
 
 /* Exported for sysctl_net_ipv4.  */
@@ -153,6 +141,46 @@ static void inetpeer_gc_worker(struct work_struct *work)
 	schedule_delayed_work(&gc_work, gc_delay);
 }
 
+static int __net_init inetpeer_net_init(struct net *net)
+{
+	net->ipv4.peers = kzalloc(sizeof(struct inet_peer_base),
+				  GFP_KERNEL);
+	if (net->ipv4.peers == NULL)
+		return -ENOMEM;
+
+	net->ipv4.peers->root = peer_avl_empty_rcu;
+	seqlock_init(&net->ipv4.peers->lock);
+
+	net->ipv6.peers = kzalloc(sizeof(struct inet_peer_base),
+				  GFP_KERNEL);
+	if (net->ipv6.peers == NULL)
+		goto out_ipv6;
+
+	net->ipv6.peers->root = peer_avl_empty_rcu;
+	seqlock_init(&net->ipv6.peers->lock);
+
+	return 0;
+out_ipv6:
+	kfree(net->ipv4.peers);
+	return -ENOMEM;
+}
+
+static void __net_exit inetpeer_net_exit(struct net *net)
+{
+	inetpeer_invalidate_tree(net, AF_INET);
+	kfree(net->ipv4.peers);
+	net->ipv4.peers = NULL;
+
+	inetpeer_invalidate_tree(net, AF_INET6);
+	kfree(net->ipv6.peers);
+	net->ipv6.peers = NULL;
+}
+
+static struct pernet_operations inetpeer_ops = {
+	.init = inetpeer_net_init,
+	.exit = inetpeer_net_exit,
+};
+
 /* Called from ip_output.c:ip_init  */
 void __init inet_initpeers(void)
 {
@@ -177,6 +205,7 @@ void __init inet_initpeers(void)
 			NULL);
 
 	INIT_DELAYED_WORK_DEFERRABLE(&gc_work, inetpeer_gc_worker);
+	register_pernet_subsys(&inetpeer_ops);
 }
 
 static int addr_compare(const struct inetpeer_addr *a,
@@ -401,9 +430,10 @@ static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base,
 	call_rcu(&p->rcu, inetpeer_free_rcu);
 }
 
-static struct inet_peer_base *family_to_base(int family)
+static struct inet_peer_base *family_to_base(struct net *net,
+					     int family)
 {
-	return family == AF_INET ? &v4_peers : &v6_peers;
+	return family == AF_INET ? net->ipv4.peers : net->ipv6.peers;
 }
 
 /* perform garbage collect on all items stacked during a lookup */
@@ -443,10 +473,12 @@ static int inet_peer_gc(struct inet_peer_base *base,
 	return cnt;
 }
 
-struct inet_peer *inet_getpeer(const struct inetpeer_addr *daddr, int create)
+struct inet_peer *inet_getpeer(struct net *net,
+			       const struct inetpeer_addr *daddr,
+			       int create)
 {
 	struct inet_peer __rcu **stack[PEER_MAXDEPTH], ***stackptr;
-	struct inet_peer_base *base = family_to_base(daddr->family);
+	struct inet_peer_base *base = family_to_base(net, daddr->family);
 	struct inet_peer *p;
 	unsigned int sequence;
 	int invalidated, gccnt = 0;
@@ -571,10 +603,10 @@ static void inetpeer_inval_rcu(struct rcu_head *head)
 	schedule_delayed_work(&gc_work, gc_delay);
 }
 
-void inetpeer_invalidate_tree(int family)
+void inetpeer_invalidate_tree(struct net *net, int family)
 {
 	struct inet_peer *old, *new, *prev;
-	struct inet_peer_base *base = family_to_base(family);
+	struct inet_peer_base *base = family_to_base(net, family);
 
 	write_seqlock_bh(&base->lock);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 98b30d0..006c21c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -938,7 +938,7 @@ static void rt_cache_invalidate(struct net *net)
 
 	get_random_bytes(&shuffle, sizeof(shuffle));
 	atomic_add(shuffle + 1U, &net->ipv4.rt_genid);
-	inetpeer_invalidate_tree(AF_INET);
+	inetpeer_invalidate_tree(net, AF_INET);
 }
 
 /*
-- 
1.7.1
