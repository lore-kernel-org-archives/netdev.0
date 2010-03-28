From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Sat, 27 Mar 2010 21:06:55 -0700 (PDT)
Message-ID: <20100327.210655.241441383.davem@davemloft.net>
References: <20100327.203120.98894145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34120
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750724Ab0C1EGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 00:06:31 -0400
In-Reply-To: <20100327.203120.98894145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 27 Mar 2010 20:31:20 -0700 (PDT)

> The limited dst metric usage in DecNET could then be moved into
> the DecNET route entry struct.  This way we don't have to support
> DecNET in the inetpeer cache just for the sake of it's metrics. :-)

And this is what that patch would look like:

decnet: Move route metrics into struct dn_route

This way we can move ipv4/ipv6 metrics into the inetpeer cache.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dn_route.h |   23 +++++++++++++++++++++++
 net/decnet/af_decnet.c |    4 ++--
 net/decnet/dn_route.c  |   35 ++++++++++++++++++-----------------
 3 files changed, 43 insertions(+), 19 deletions(-)

diff --git a/include/net/dn_route.h b/include/net/dn_route.h
index 60c9f22..62b04db 100644
--- a/include/net/dn_route.h
+++ b/include/net/dn_route.h
@@ -80,8 +80,31 @@ struct dn_route {
 
 	unsigned rt_flags;
 	unsigned rt_type;
+
+	u32 metrics[RTAX_MAX];
 };
 
+static inline u32 dn_dst_metric(const struct dst_entry *dst, int metric)
+{
+	struct dn_route *rt = (struct dn_route *) dst;
+	return rt->metrics[metric - 1];
+}
+
+static inline int dn_dst_metric_locked(const struct dst_entry *dst, int metric)
+{
+	return dn_dst_metric(dst, RTAX_LOCK) & (1 << metric);
+}
+
+static inline u32 dn_dst_mtu(const struct dst_entry *dst)
+{
+	u32 mtu = dn_dst_metric(dst, RTAX_MTU);
+	/*
+	 * Alexey put it here, so ask him about it :)
+	 */
+	barrier();
+	return mtu;
+}
+
 extern void dn_route_init(void);
 extern void dn_route_cleanup(void);
 
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 2b494fa..83228a2 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -829,7 +829,7 @@ static int dn_confirm_accept(struct sock *sk, long *timeo, gfp_t allocation)
 		return -EINVAL;
 
 	scp->state = DN_CC;
-	scp->segsize_loc = dst_metric(__sk_dst_get(sk), RTAX_ADVMSS);
+	scp->segsize_loc = dn_dst_metric(__sk_dst_get(sk), RTAX_ADVMSS);
 	dn_send_conn_conf(sk, allocation);
 
 	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
@@ -958,7 +958,7 @@ static int __dn_connect(struct sock *sk, struct sockaddr_dn *addr, int addrlen,
 	sk->sk_route_caps = sk->sk_dst_cache->dev->features;
 	sock->state = SS_CONNECTING;
 	scp->state = DN_CI;
-	scp->segsize_loc = dst_metric(sk->sk_dst_cache, RTAX_ADVMSS);
+	scp->segsize_loc = dn_dst_metric(sk->sk_dst_cache, RTAX_ADVMSS);
 
 	dn_nsp_send_conninit(sk, NSP_CI);
 	err = -EINPROGRESS;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index a7bf03c..ff62012 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -234,15 +234,16 @@ static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu)
 	else
 		min_mtu -= 21;
 
-	if (dst_metric(dst, RTAX_MTU) > mtu && mtu >= min_mtu) {
-		if (!(dst_metric_locked(dst, RTAX_MTU))) {
-			dst->metrics[RTAX_MTU-1] = mtu;
+	if (dn_dst_metric(dst, RTAX_MTU) > mtu && mtu >= min_mtu) {
+		struct dn_route *rt = (struct dn_route *) dst;
+		if (!(dn_dst_metric_locked(dst, RTAX_MTU))) {
+			rt->metrics[RTAX_MTU-1] = mtu;
 			dst_set_expires(dst, dn_rt_mtu_expires);
 		}
-		if (!(dst_metric_locked(dst, RTAX_ADVMSS))) {
+		if (!(dn_dst_metric_locked(dst, RTAX_ADVMSS))) {
 			u32 mss = mtu - DN_MAX_NSP_DATA_HEADER;
-			if (dst_metric(dst, RTAX_ADVMSS) > mss)
-				dst->metrics[RTAX_ADVMSS-1] = mss;
+			if (dn_dst_metric(dst, RTAX_ADVMSS) > mss)
+				rt->metrics[RTAX_ADVMSS-1] = mss;
 		}
 	}
 }
@@ -788,8 +789,8 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 		if (DN_FIB_RES_GW(*res) &&
 		    DN_FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = DN_FIB_RES_GW(*res);
-		memcpy(rt->u.dst.metrics, fi->fib_metrics,
-		       sizeof(rt->u.dst.metrics));
+		memcpy(rt->metrics, fi->fib_metrics,
+		       sizeof(rt->metrics));
 	}
 	rt->rt_type = res->type;
 
@@ -800,13 +801,13 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 		rt->u.dst.neighbour = n;
 	}
 
-	if (dst_metric(&rt->u.dst, RTAX_MTU) == 0 ||
-	    dst_metric(&rt->u.dst, RTAX_MTU) > rt->u.dst.dev->mtu)
-		rt->u.dst.metrics[RTAX_MTU-1] = rt->u.dst.dev->mtu;
-	mss = dn_mss_from_pmtu(dev, dst_mtu(&rt->u.dst));
-	if (dst_metric(&rt->u.dst, RTAX_ADVMSS) == 0 ||
-	    dst_metric(&rt->u.dst, RTAX_ADVMSS) > mss)
-		rt->u.dst.metrics[RTAX_ADVMSS-1] = mss;
+	if (dn_dst_metric(&rt->u.dst, RTAX_MTU) == 0 ||
+	    dn_dst_metric(&rt->u.dst, RTAX_MTU) > rt->u.dst.dev->mtu)
+		rt->metrics[RTAX_MTU-1] = rt->u.dst.dev->mtu;
+	mss = dn_mss_from_pmtu(dev, dn_dst_mtu(&rt->u.dst));
+	if (dn_dst_metric(&rt->u.dst, RTAX_ADVMSS) == 0 ||
+	    dn_dst_metric(&rt->u.dst, RTAX_ADVMSS) > mss)
+		rt->metrics[RTAX_ADVMSS-1] = mss;
 	return 0;
 }
 
@@ -1485,7 +1486,7 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	RTA_PUT(skb, RTA_PREFSRC, 2, &rt->rt_local_src);
 	if (rt->rt_daddr != rt->rt_gateway)
 		RTA_PUT(skb, RTA_GATEWAY, 2, &rt->rt_gateway);
-	if (rtnetlink_put_metrics(skb, rt->u.dst.metrics) < 0)
+	if (rtnetlink_put_metrics(skb, rt->metrics) < 0)
 		goto rtattr_failure;
 	expires = rt->u.dst.expires ? rt->u.dst.expires - jiffies : 0;
 	if (rtnl_put_cacheinfo(skb, &rt->u.dst, 0, 0, 0, expires,
@@ -1712,7 +1713,7 @@ static int dn_rt_cache_seq_show(struct seq_file *seq, void *v)
 			dn_addr2asc(le16_to_cpu(rt->rt_saddr), buf2),
 			atomic_read(&rt->u.dst.__refcnt),
 			rt->u.dst.__use,
-			(int) dst_metric(&rt->u.dst, RTAX_RTT));
+			(int) dn_dst_metric(&rt->u.dst, RTAX_RTT));
 	return 0;
 }
 
-- 
1.7.0.3

