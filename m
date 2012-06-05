From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH net-next v2 2/2] inetpeer: add parameter net for
	inet_getpeer_v4, v6
Date: Tue, 5 Jun 2012 15:52:56 +0800
Message-ID: <1338882776-12042-1-git-send-email-gaofeng@cn.fujitsu.com>
References: <1338882737-11914-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338882737-11914-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

add struct net as a parameter of inet_getpeer_v[4,6],
use net to replace &init_net.

and modify some places to provide net for inet_getpeer_v[4,6]

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/net/inetpeer.h   |   12 ++++++++----
 net/ipv4/inet_fragment.c |    2 +-
 net/ipv4/ip_fragment.c   |    6 +++++-
 net/ipv4/route.c         |    8 +++++---
 net/ipv4/tcp_ipv4.c      |    6 ++++--
 net/ipv6/route.c         |    3 ++-
 net/ipv6/tcp_ipv6.c      |    6 ++++--
 7 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 4a50449..31101e0 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -76,22 +76,26 @@ struct inet_peer *inet_getpeer(struct net *net,
 			       const struct inetpeer_addr *daddr,
 			       int create);
 
-static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
+static inline struct inet_peer *inet_getpeer_v4(struct net *net,
+						__be32 v4daddr,
+						int create)
 {
 	struct inetpeer_addr daddr;
 
 	daddr.addr.a4 = v4daddr;
 	daddr.family = AF_INET;
-	return inet_getpeer(&init_net, &daddr, create);
+	return inet_getpeer(net, &daddr, create);
 }
 
-static inline struct inet_peer *inet_getpeer_v6(const struct in6_addr *v6daddr, int create)
+static inline struct inet_peer *inet_getpeer_v6(struct net *net,
+						const struct in6_addr *v6daddr,
+						int create)
 {
 	struct inetpeer_addr daddr;
 
 	*(struct in6_addr *)daddr.addr.a6 = *v6daddr;
 	daddr.family = AF_INET6;
-	return inet_getpeer(&init_net, &daddr, create);
+	return inet_getpeer(net, &daddr, create);
 }
 
 /* can be called from BH context or outside */
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 5ff2a51..85190e6 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -243,12 +243,12 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
 	if (q == NULL)
 		return NULL;
 
+	q->net = nf;
 	f->constructor(q, arg);
 	atomic_add(f->qsize, &nf->mem);
 	setup_timer(&q->timer, f->frag_expire, (unsigned long)q);
 	spin_lock_init(&q->lock);
 	atomic_set(&q->refcnt, 1);
-	q->net = nf;
 
 	return q;
 }
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 9dbd3dd..22c6bab 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -171,6 +171,10 @@ static void frag_kfree_skb(struct netns_frags *nf, struct sk_buff *skb)
 static void ip4_frag_init(struct inet_frag_queue *q, void *a)
 {
 	struct ipq *qp = container_of(q, struct ipq, q);
+	struct netns_ipv4 *ipv4 = container_of(q->net, struct netns_ipv4,
+					       frags);
+	struct net *net = container_of(ipv4, struct net, ipv4);
+
 	struct ip4_create_arg *arg = a;
 
 	qp->protocol = arg->iph->protocol;
@@ -180,7 +184,7 @@ static void ip4_frag_init(struct inet_frag_queue *q, void *a)
 	qp->daddr = arg->iph->daddr;
 	qp->user = arg->user;
 	qp->peer = sysctl_ipfrag_max_dist ?
-		inet_getpeer_v4(arg->iph->saddr, 1) : NULL;
+		inet_getpeer_v4(net, arg->iph->saddr, 1) : NULL;
 }
 
 static __inline__ void ip4_frag_free(struct inet_frag_queue *q)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e5b18b8..448e56b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1328,9 +1328,10 @@ static u32 rt_peer_genid(void)
 
 void rt_bind_peer(struct rtable *rt, __be32 daddr, int create)
 {
+	struct net *net = dev_net(rt->dst.dev);
 	struct inet_peer *peer;
 
-	peer = inet_getpeer_v4(daddr, create);
+	peer = inet_getpeer_v4(net, daddr, create);
 
 	if (peer && cmpxchg(&rt->peer, NULL, peer) != NULL)
 		inet_putpeer(peer);
@@ -1694,7 +1695,7 @@ unsigned short ip_rt_frag_needed(struct net *net, const struct iphdr *iph,
 	unsigned short est_mtu = 0;
 	struct inet_peer *peer;
 
-	peer = inet_getpeer_v4(iph->daddr, 1);
+	peer = inet_getpeer_v4(net, iph->daddr, 1);
 	if (peer) {
 		unsigned short mtu = new_mtu;
 
@@ -1935,6 +1936,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 			    struct fib_info *fi)
 {
+	struct net *net = dev_net(rt->dst.dev);
 	struct inet_peer *peer;
 	int create = 0;
 
@@ -1944,7 +1946,7 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 	if (fl4 && (fl4->flowi4_flags & FLOWI_FLAG_PRECOW_METRICS))
 		create = 1;
 
-	rt->peer = peer = inet_getpeer_v4(rt->rt_dst, create);
+	rt->peer = peer = inet_getpeer_v4(net, rt->rt_dst, create);
 	if (peer) {
 		rt->rt_peer_genid = rt_peer_genid();
 		if (inet_metrics_new(peer))
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a43b87d..50d4bee 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1822,11 +1822,12 @@ struct inet_peer *tcp_v4_get_peer(struct sock *sk, bool *release_it)
 {
 	struct rtable *rt = (struct rtable *) __sk_dst_get(sk);
 	struct inet_sock *inet = inet_sk(sk);
+	struct net *net = sock_net(sk);
 	struct inet_peer *peer;
 
 	if (!rt ||
 	    inet->cork.fl.u.ip4.daddr != inet->inet_daddr) {
-		peer = inet_getpeer_v4(inet->inet_daddr, 1);
+		peer = inet_getpeer_v4(net, inet->inet_daddr, 1);
 		*release_it = true;
 	} else {
 		if (!rt->peer)
@@ -1842,8 +1843,9 @@ EXPORT_SYMBOL(tcp_v4_get_peer);
 void *tcp_v4_tw_get_peer(struct sock *sk)
 {
 	const struct inet_timewait_sock *tw = inet_twsk(sk);
+	struct net *net = sock_net(sk);
 
-	return inet_getpeer_v4(tw->tw_daddr, 1);
+	return inet_getpeer_v4(net, tw->tw_daddr, 1);
 }
 EXPORT_SYMBOL(tcp_v4_tw_get_peer);
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 999a982..4eca013 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -306,9 +306,10 @@ static u32 rt6_peer_genid(void)
 
 void rt6_bind_peer(struct rt6_info *rt, int create)
 {
+	struct net *net = dev_net(rt->dst.dev);
 	struct inet_peer *peer;
 
-	peer = inet_getpeer_v6(&rt->rt6i_dst.addr, create);
+	peer = inet_getpeer_v6(net, &rt->rt6i_dst.addr, create);
 	if (peer && cmpxchg(&rt->rt6i_peer, NULL, peer) != NULL)
 		inet_putpeer(peer);
 	else
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 554d599..56aae14 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1734,11 +1734,12 @@ static struct inet_peer *tcp_v6_get_peer(struct sock *sk, bool *release_it)
 {
 	struct rt6_info *rt = (struct rt6_info *) __sk_dst_get(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct net *net = sock_net(sk);
 	struct inet_peer *peer;
 
 	if (!rt ||
 	    !ipv6_addr_equal(&np->daddr, &rt->rt6i_dst.addr)) {
-		peer = inet_getpeer_v6(&np->daddr, 1);
+		peer = inet_getpeer_v6(net, &np->daddr, 1);
 		*release_it = true;
 	} else {
 		if (!rt->rt6i_peer)
@@ -1754,11 +1755,12 @@ static void *tcp_v6_tw_get_peer(struct sock *sk)
 {
 	const struct inet6_timewait_sock *tw6 = inet6_twsk(sk);
 	const struct inet_timewait_sock *tw = inet_twsk(sk);
+	struct net *net = sock_net(sk);
 
 	if (tw->tw_family == AF_INET)
 		return tcp_v4_tw_get_peer(sk);
 
-	return inet_getpeer_v6(&tw6->tw_v6_daddr, 1);
+	return inet_getpeer_v6(net, &tw6->tw_v6_daddr, 1);
 }
 
 static struct timewait_sock_ops tcp6_timewait_sock_ops = {
-- 
1.7.7.6
