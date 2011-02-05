From: David Miller <davem@davemloft.net>
Subject: inetpeer: Move ICMP rate limiting state into inet_peer entries.
Date: Fri, 04 Feb 2011 16:24:02 -0800 (PST)
Message-ID: <20110204.162402.115920873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55644
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751643Ab1BEAX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 19:23:27 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D749324C087
	for <netdev@vger.kernel.org>; Fri,  4 Feb 2011 16:24:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Like metrics, the ICMP rate limiting bits are cached state about
a destination.  So move it into the inet_peer entries.

If an inet_peer cannot be bound (the reason is memory allocation
failure or similar), the policy is to allow.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h      |    2 -
 include/net/icmp.h     |    3 --
 include/net/inetpeer.h |    3 ++
 net/ipv4/icmp.c        |   49 ++++++-----------------------------------
 net/ipv4/inetpeer.c    |   43 ++++++++++++++++++++++++++++++++++++
 net/ipv4/route.c       |   56 ++++++++++++++++++++++++++++++++---------------
 net/ipv6/icmp.c        |   16 +++++++------
 net/ipv6/ip6_output.c  |    5 +++-
 net/ipv6/ndisc.c       |    4 ++-
 9 files changed, 108 insertions(+), 73 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 484f80b..e550195 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -78,8 +78,6 @@ struct dst_entry {
 	atomic_t		__refcnt;	/* client references	*/
 	int			__use;
 	unsigned long		lastuse;
-	unsigned long		rate_last;	/* rate limiting for ICMP */
-	unsigned int		rate_tokens;
 	int			flags;
 #define DST_HOST		0x0001
 #define DST_NOXFRM		0x0002
diff --git a/include/net/icmp.h b/include/net/icmp.h
index 6e991e0..f0698b9 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -45,7 +45,4 @@ extern int	icmp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int	icmp_init(void);
 extern void	icmp_out_count(struct net *net, unsigned char type);
 
-/* Move into dst.h ? */
-extern int 	xrlim_allow(struct dst_entry *dst, int timeout);
-
 #endif	/* _ICMP_H */
diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 61f2c66..ead2cb2 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -44,6 +44,8 @@ struct inet_peer {
 			__u32		tcp_ts;
 			__u32		tcp_ts_stamp;
 			u32		metrics[RTAX_MAX];
+			u32		rate_tokens;	/* rate limiting for ICMP */
+			unsigned long	rate_last;
 		};
 		struct rcu_head         rcu;
 	};
@@ -81,6 +83,7 @@ static inline struct inet_peer *inet_getpeer_v6(struct in6_addr *v6daddr, int cr
 
 /* can be called from BH context or outside */
 extern void inet_putpeer(struct inet_peer *p);
+extern bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
 
 /*
  * temporary check to make sure we dont access rid, ip_id_count, tcp_ts,
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 4aa1b7f..ad2bcf1 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -233,48 +233,11 @@ static inline void icmp_xmit_unlock(struct sock *sk)
  *	Send an ICMP frame.
  */
 
-/*
- *	Check transmit rate limitation for given message.
- *	The rate information is held in the destination cache now.
- *	This function is generic and could be used for other purposes
- *	too. It uses a Token bucket filter as suggested by Alexey Kuznetsov.
- *
- *	Note that the same dst_entry fields are modified by functions in
- *	route.c too, but these work for packet destinations while xrlim_allow
- *	works for icmp destinations. This means the rate limiting information
- *	for one "ip object" is shared - and these ICMPs are twice limited:
- *	by source and by destination.
- *
- *	RFC 1812: 4.3.2.8 SHOULD be able to limit error message rate
- *			  SHOULD allow setting of rate limits
- *
- * 	Shared between ICMPv4 and ICMPv6.
- */
-#define XRLIM_BURST_FACTOR 6
-int xrlim_allow(struct dst_entry *dst, int timeout)
-{
-	unsigned long now, token = dst->rate_tokens;
-	int rc = 0;
-
-	now = jiffies;
-	token += now - dst->rate_last;
-	dst->rate_last = now;
-	if (token > XRLIM_BURST_FACTOR * timeout)
-		token = XRLIM_BURST_FACTOR * timeout;
-	if (token >= timeout) {
-		token -= timeout;
-		rc = 1;
-	}
-	dst->rate_tokens = token;
-	return rc;
-}
-EXPORT_SYMBOL(xrlim_allow);
-
-static inline int icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
+static inline bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 		int type, int code)
 {
 	struct dst_entry *dst = &rt->dst;
-	int rc = 1;
+	bool rc = true;
 
 	if (type > NR_ICMP_TYPES)
 		goto out;
@@ -288,8 +251,12 @@ static inline int icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 		goto out;
 
 	/* Limit if icmp type is enabled in ratemask. */
-	if ((1 << type) & net->ipv4.sysctl_icmp_ratemask)
-		rc = xrlim_allow(dst, net->ipv4.sysctl_icmp_ratelimit);
+	if ((1 << type) & net->ipv4.sysctl_icmp_ratemask) {
+		if (!rt->peer)
+			rt_bind_peer(rt, 1);
+		rc = inet_peer_xrlim_allow(rt->peer,
+					   net->ipv4.sysctl_icmp_ratelimit);
+	}
 out:
 	return rc;
 }
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index b6513b1..709fbb4 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -513,6 +513,8 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr *daddr, int create)
 		atomic_set(&p->ip_id_count, secure_ip_id(daddr->a4));
 		p->tcp_ts_stamp = 0;
 		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
+		p->rate_tokens = 0;
+		p->rate_last = 0;
 		INIT_LIST_HEAD(&p->unused);
 
 
@@ -580,3 +582,44 @@ void inet_putpeer(struct inet_peer *p)
 	local_bh_enable();
 }
 EXPORT_SYMBOL_GPL(inet_putpeer);
+
+/*
+ *	Check transmit rate limitation for given message.
+ *	The rate information is held in the inet_peer entries now.
+ *	This function is generic and could be used for other purposes
+ *	too. It uses a Token bucket filter as suggested by Alexey Kuznetsov.
+ *
+ *	Note that the same inet_peer fields are modified by functions in
+ *	route.c too, but these work for packet destinations while xrlim_allow
+ *	works for icmp destinations. This means the rate limiting information
+ *	for one "ip object" is shared - and these ICMPs are twice limited:
+ *	by source and by destination.
+ *
+ *	RFC 1812: 4.3.2.8 SHOULD be able to limit error message rate
+ *			  SHOULD allow setting of rate limits
+ *
+ * 	Shared between ICMPv4 and ICMPv6.
+ */
+#define XRLIM_BURST_FACTOR 6
+bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout)
+{
+	unsigned long now, token;
+	bool rc = false;
+
+	if (!peer)
+		return true;
+
+	token = peer->rate_tokens;
+	now = jiffies;
+	token += now - peer->rate_last;
+	peer->rate_last = now;
+	if (token > XRLIM_BURST_FACTOR * timeout)
+		token = XRLIM_BURST_FACTOR * timeout;
+	if (token >= timeout) {
+		token -= timeout;
+		rc = true;
+	}
+	peer->rate_tokens = token;
+	return rc;
+}
+EXPORT_SYMBOL(inet_peer_xrlim_allow);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0ba6a38..2e225da 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1563,6 +1563,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 {
 	struct rtable *rt = skb_rtable(skb);
 	struct in_device *in_dev;
+	struct inet_peer *peer;
 	int log_martians;
 
 	rcu_read_lock();
@@ -1574,33 +1575,41 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 	log_martians = IN_DEV_LOG_MARTIANS(in_dev);
 	rcu_read_unlock();
 
+	if (!rt->peer)
+		rt_bind_peer(rt, 1);
+	peer = rt->peer;
+	if (!peer) {
+		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);
+		return;
+	}
+
 	/* No redirected packets during ip_rt_redirect_silence;
 	 * reset the algorithm.
 	 */
-	if (time_after(jiffies, rt->dst.rate_last + ip_rt_redirect_silence))
-		rt->dst.rate_tokens = 0;
+	if (time_after(jiffies, peer->rate_last + ip_rt_redirect_silence))
+		peer->rate_tokens = 0;
 
 	/* Too many ignored redirects; do not send anything
 	 * set dst.rate_last to the last seen redirected packet.
 	 */
-	if (rt->dst.rate_tokens >= ip_rt_redirect_number) {
-		rt->dst.rate_last = jiffies;
+	if (peer->rate_tokens >= ip_rt_redirect_number) {
+		peer->rate_last = jiffies;
 		return;
 	}
 
 	/* Check for load limit; set rate_last to the latest sent
 	 * redirect.
 	 */
-	if (rt->dst.rate_tokens == 0 ||
+	if (peer->rate_tokens == 0 ||
 	    time_after(jiffies,
-		       (rt->dst.rate_last +
-			(ip_rt_redirect_load << rt->dst.rate_tokens)))) {
+		       (peer->rate_last +
+			(ip_rt_redirect_load << peer->rate_tokens)))) {
 		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);
-		rt->dst.rate_last = jiffies;
-		++rt->dst.rate_tokens;
+		peer->rate_last = jiffies;
+		++peer->rate_tokens;
 #ifdef CONFIG_IP_ROUTE_VERBOSE
 		if (log_martians &&
-		    rt->dst.rate_tokens == ip_rt_redirect_number &&
+		    peer->rate_tokens == ip_rt_redirect_number &&
 		    net_ratelimit())
 			printk(KERN_WARNING "host %pI4/if%d ignores redirects for %pI4 to %pI4.\n",
 				&rt->rt_src, rt->rt_iif,
@@ -1612,7 +1621,9 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 static int ip_error(struct sk_buff *skb)
 {
 	struct rtable *rt = skb_rtable(skb);
+	struct inet_peer *peer;
 	unsigned long now;
+	bool send;
 	int code;
 
 	switch (rt->dst.error) {
@@ -1632,15 +1643,24 @@ static int ip_error(struct sk_buff *skb)
 			break;
 	}
 
-	now = jiffies;
-	rt->dst.rate_tokens += now - rt->dst.rate_last;
-	if (rt->dst.rate_tokens > ip_rt_error_burst)
-		rt->dst.rate_tokens = ip_rt_error_burst;
-	rt->dst.rate_last = now;
-	if (rt->dst.rate_tokens >= ip_rt_error_cost) {
-		rt->dst.rate_tokens -= ip_rt_error_cost;
-		icmp_send(skb, ICMP_DEST_UNREACH, code, 0);
+	if (!rt->peer)
+		rt_bind_peer(rt, 1);
+	peer = rt->peer;
+
+	send = true;
+	if (peer) {
+		now = jiffies;
+		peer->rate_tokens += now - peer->rate_last;
+		if (peer->rate_tokens > ip_rt_error_burst)
+			peer->rate_tokens = ip_rt_error_burst;
+		peer->rate_last = now;
+		if (peer->rate_tokens >= ip_rt_error_cost)
+			peer->rate_tokens -= ip_rt_error_cost;
+		else
+			send = false;
 	}
+	if (send)
+		icmp_send(skb, ICMP_DEST_UNREACH, code, 0);
 
 out:	kfree_skb(skb);
 	return 0;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 03e62f9..a31d91b 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -157,20 +157,20 @@ static int is_ineligible(struct sk_buff *skb)
 /*
  * Check the ICMP output rate limit
  */
-static inline int icmpv6_xrlim_allow(struct sock *sk, u8 type,
-				     struct flowi *fl)
+static inline bool icmpv6_xrlim_allow(struct sock *sk, u8 type,
+				      struct flowi *fl)
 {
 	struct dst_entry *dst;
 	struct net *net = sock_net(sk);
-	int res = 0;
+	bool res = false;
 
 	/* Informational messages are not limited. */
 	if (type & ICMPV6_INFOMSG_MASK)
-		return 1;
+		return true;
 
 	/* Do not limit pmtu discovery, it would break it. */
 	if (type == ICMPV6_PKT_TOOBIG)
-		return 1;
+		return true;
 
 	/*
 	 * Look up the output route.
@@ -182,7 +182,7 @@ static inline int icmpv6_xrlim_allow(struct sock *sk, u8 type,
 		IP6_INC_STATS(net, ip6_dst_idev(dst),
 			      IPSTATS_MIB_OUTNOROUTES);
 	} else if (dst->dev && (dst->dev->flags&IFF_LOOPBACK)) {
-		res = 1;
+		res = true;
 	} else {
 		struct rt6_info *rt = (struct rt6_info *)dst;
 		int tmo = net->ipv6.sysctl.icmpv6_time;
@@ -191,7 +191,9 @@ static inline int icmpv6_xrlim_allow(struct sock *sk, u8 type,
 		if (rt->rt6i_dst.plen < 128)
 			tmo >>= ((128 - rt->rt6i_dst.plen)>>5);
 
-		res = xrlim_allow(dst, tmo);
+		if (!rt->rt6i_peer)
+			rt6_bind_peer(rt, 1);
+		res = inet_peer_xrlim_allow(rt->rt6i_peer, tmo);
 	}
 	dst_release(dst);
 	return res;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 5f8d242..2600e22 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -479,10 +479,13 @@ int ip6_forward(struct sk_buff *skb)
 		else
 			target = &hdr->daddr;
 
+		if (!rt->rt6i_peer)
+			rt6_bind_peer(rt, 1);
+
 		/* Limit redirects both by destination (here)
 		   and by source (inside ndisc_send_redirect)
 		 */
-		if (xrlim_allow(dst, 1*HZ))
+		if (inet_peer_xrlim_allow(rt->rt6i_peer, 1*HZ))
 			ndisc_send_redirect(skb, n, target);
 	} else {
 		int addrtype = ipv6_addr_type(&hdr->saddr);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2342545..7254ce3 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1553,7 +1553,9 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 			   "ICMPv6 Redirect: destination is not a neighbour.\n");
 		goto release;
 	}
-	if (!xrlim_allow(dst, 1*HZ))
+	if (!rt->rt6i_peer)
+		rt6_bind_peer(rt, 1);
+	if (inet_peer_xrlim_allow(rt->rt6i_peer, 1*HZ))
 		goto release;
 
 	if (dev->addr_len) {
-- 
1.7.4

