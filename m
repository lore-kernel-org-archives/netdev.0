From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/4] inetpeer: protect the inetpeerpeer metrics with rcu
Date: Thu, 2 Feb 2012 11:13:36 +0100
Message-ID: <20120202101336.GF23142@secunet.com>
References: <20120202101141.GC23142@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48774 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755351Ab2BBKNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 05:13:41 -0500
Content-Disposition: inline
In-Reply-To: <20120202101141.GC23142@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to be able to exchange the inetpeer metrics,
we add rcu protection to the struct inetpeer_metrics.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/dst.h      |   21 +++++++++++++++++----
 include/net/inetpeer.h |    8 ++++++--
 net/ipv4/inetpeer.c    |   26 ++++++++++++++++++++++++++
 net/ipv4/route.c       |    6 +++++-
 net/ipv6/route.c       |    6 +++++-
 5 files changed, 59 insertions(+), 8 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index be1ffc8..f1141d8 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -159,21 +159,31 @@ static inline void dst_init_metrics(struct dst_entry *dst,
 
 static inline void dst_copy_metrics(struct dst_entry *dest, const struct dst_entry *src)
 {
-	u32 *dst_metrics = dst_metrics_write_ptr(dest);
+	u32 *dst_metrics;
+
+	rcu_read_lock();
+	dst_metrics = dst_metrics_write_ptr(dest);
 
 	if (dst_metrics) {
 		u32 *src_metrics = dst_metrics_ptr(src);
 
 		memcpy(dst_metrics, src_metrics, RTAX_MAX * sizeof(u32));
 	}
+	rcu_read_unlock();
 }
 
 static inline u32
 dst_metric_raw(const struct dst_entry *dst, const int metric)
 {
-	u32 *p = dst_metrics_ptr(dst);
+	u32 *p;
+	u32 val;
+
+	rcu_read_lock();
+	p = dst_metrics_ptr(dst);
+	val = p[metric-1];
+	rcu_read_unlock();
 
-	return p[metric-1];
+	return val;
 }
 
 static inline u32
@@ -198,10 +208,13 @@ dst_metric_advmss(const struct dst_entry *dst)
 
 static inline void dst_metric_set(struct dst_entry *dst, int metric, u32 val)
 {
-	u32 *p = dst_metrics_write_ptr(dst);
+	u32 *p;
 
+	rcu_read_lock();
+	p = dst_metrics_write_ptr(dst);
 	if (p)
 		p[metric-1] = val;
+	rcu_read_unlock();
 }
 
 static inline u32
diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 6bb8060..d97211a 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -28,6 +28,7 @@ struct inetpeer_addr {
 };
 
 struct inetpeer_metrics {
+	struct rcu_head	rcu;
 	u32		m[RTAX_MAX];
 };
 
@@ -37,7 +38,7 @@ struct inet_peer {
 	struct inetpeer_addr	daddr;
 	__u32			avl_height;
 
-	struct inetpeer_metrics *metrics;
+	struct inetpeer_metrics __rcu *metrics;
 	u32			rate_tokens;	/* rate limiting for ICMP */
 	int			redirect_genid;
 	unsigned long		rate_last;
@@ -75,9 +76,11 @@ static inline bool inet_metrics_new(const struct inet_peer *p)
 	return p->metrics->m[RTAX_LOCK-1] == INETPEER_METRICS_NEW;
 }
 
+/* called in rcu_read_lock() section */
 static inline u32 *inetpeer_metrics(const struct inet_peer *p)
 {
-	return p->metrics->m;
+	struct inetpeer_metrics *metrics = rcu_dereference(p->metrics);
+	return metrics->m;
 }
 
 /* can be called with or without local BH being disabled */
@@ -130,4 +133,5 @@ static inline int inet_getid(struct inet_peer *p, int more)
 	return new;
 }
 
+extern bool inetpeer_reset_metrics(struct inet_peer *p);
 #endif /* _NET_INETPEER_H */
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 92071a4..2bf23a9 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -519,3 +519,29 @@ bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout)
 	return rc;
 }
 EXPORT_SYMBOL(inet_peer_xrlim_allow);
+
+bool inetpeer_reset_metrics(struct inet_peer *p)
+{
+	struct inetpeer_metrics *old, *prev, *new;
+
+	if (inet_metrics_new(p))
+		return true;
+
+	new = kmalloc(sizeof(struct inetpeer_metrics), GFP_ATOMIC);
+	if (!new)
+		return false;
+
+	new->m[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
+
+	old = p->metrics;
+
+	prev = cmpxchg(&p->metrics, old, new);
+	if (prev != old) {
+		kfree(new);
+		return false;
+	}
+
+	kfree_rcu(old, rcu);
+	return true;
+}
+EXPORT_SYMBOL(inetpeer_reset_metrics);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index dc22d6f..1a88484 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2971,6 +2971,7 @@ static int rt_fill_info(struct net *net,
 	unsigned long expires = 0;
 	const struct inet_peer *peer = rt->peer;
 	u32 id = 0, ts = 0, tsage = 0, error;
+	int ret;
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
 	if (nlh == NULL)
@@ -3010,7 +3011,10 @@ static int rt_fill_info(struct net *net,
 	if (rt->rt_dst != rt->rt_gateway)
 		NLA_PUT_BE32(skb, RTA_GATEWAY, rt->rt_gateway);
 
-	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
+	rcu_read_lock();
+	ret = rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst));
+	rcu_read_unlock();
+	if (ret < 0)
 		goto nla_put_failure;
 
 	if (rt->rt_mark)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d8b01c0..5a1c256 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2378,6 +2378,7 @@ static int rt6_fill_node(struct net *net,
 	u32 table;
 	struct neighbour *n;
 	u32 ts, tsage;
+	int ret;
 
 	if (prefix) {	/* user wants prefix routes only */
 		if (!(rt->rt6i_flags & RTF_PREFIX_RT)) {
@@ -2463,7 +2464,10 @@ static int rt6_fill_node(struct net *net,
 		NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
 
-	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
+	rcu_read_lock();
+	ret = rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst));
+	rcu_read_unlock();
+	if (ret < 0)
 		goto nla_put_failure;
 
 	rcu_read_lock();
-- 
1.7.0.4
