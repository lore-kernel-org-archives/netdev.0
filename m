From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Wed, 25 Apr 2012 12:02:37 +0200
Message-ID: <1335348157.3274.30.camel@edumazet-glaptop>
References: <1335289058.5205.165.camel@edumazet-glaptop>
	 <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
	 <1335298228.5205.168.camel@edumazet-glaptop>
	 <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
	 <1335331960.5205.180.camel@edumazet-glaptop>
	 <CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
	 <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
	 <1335346710.3274.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61954 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757371Ab2DYKCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 06:02:45 -0400
Received: by eaaq12 with SMTP id q12so436569eaa.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 03:02:44 -0700 (PDT)
In-Reply-To: <1335346710.3274.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-25 at 11:38 +0200, Eric Dumazet wrote:

> Hmm, but what if we change linux to choice a) instead of b) ?
> 
> That is, not cap mtu to minimum value 1280 (and not use anymore
> RTAX_FEATURE_ALLFRAG) : dst_allfrag() would be always false.
> 
> In this case, do we still need to send the frag header ?
> 
> I ask this because some TSO6 implementations probably dont cope very
> well with this added header (untested path)
> 

So a patch against net-next would looks like :

(Incredible, we remove some code in linux ;) )

 include/linux/rtnetlink.h |    2 +-
 include/net/dst.h         |    7 -------
 include/net/inet_sock.h   |    2 +-
 net/ipv6/ip6_output.c     |   14 +++++---------
 net/ipv6/route.c          |   28 ----------------------------
 net/ipv6/xfrm6_output.c   |    9 ++++-----
 6 files changed, 11 insertions(+), 51 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 2c1de89..92ed273 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -380,7 +380,7 @@ enum {
 #define RTAX_FEATURE_ECN	0x00000001
 #define RTAX_FEATURE_SACK	0x00000002
 #define RTAX_FEATURE_TIMESTAMP	0x00000004
-#define RTAX_FEATURE_ALLFRAG	0x00000008
+#define RTAX_FEATURE_ALLFRAG	0x00000008 /* not used anymore */
 
 struct rta_session {
 	__u8	proto;
diff --git a/include/net/dst.h b/include/net/dst.h
index ff4da42..e69c55b 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -226,13 +226,6 @@ static inline void set_dst_metric_rtt(struct dst_entry *dst, int metric,
 	dst_metric_set(dst, metric, jiffies_to_msecs(rtt));
 }
 
-static inline u32
-dst_allfrag(const struct dst_entry *dst)
-{
-	int ret = dst_feature(dst,  RTAX_FEATURE_ALLFRAG);
-	return ret;
-}
-
 static inline int
 dst_metric_locked(const struct dst_entry *dst, int metric)
 {
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index ae17e13..381ddc3 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -177,7 +177,7 @@ struct inet_sock {
 };
 
 #define IPCORK_OPT	1	/* ip-options has been held in ipcork.opt */
-#define IPCORK_ALLFRAG	2	/* always fragment (for ipv6 for now) */
+#define IPCORK_ALLFRAG	2	/* always fragment (for ipv6 for now), unused */
 
 static inline struct inet_sock *inet_sk(const struct sock *sk)
 {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index b7ca461..314275e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -152,11 +152,10 @@ static int ip6_finish_output2(struct sk_buff *skb)
 
 static int ip6_finish_output(struct sk_buff *skb)
 {
-	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
-	    dst_allfrag(skb_dst(skb)))
+	if (skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb))
 		return ip6_fragment(skb, ip6_finish_output2);
-	else
-		return ip6_finish_output2(skb);
+
+	return ip6_finish_output2(skb);
 }
 
 int ip6_output(struct sk_buff *skb)
@@ -1255,8 +1254,6 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 				mtu = np->frag_size;
 		}
 		cork->fragsize = mtu;
-		if (dst_allfrag(rt->dst.path))
-			cork->flags |= IPCORK_ALLFRAG;
 		cork->length = 0;
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
@@ -1335,7 +1332,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 
 	while (length > 0) {
 		/* Check if the remaining data fits into current packet. */
-		copy = (cork->length <= mtu && !(cork->flags & IPCORK_ALLFRAG) ? mtu : maxfraglen) - skb->len;
+		copy = (cork->length <= mtu ? mtu : maxfraglen) - skb->len;
 		if (copy < length)
 			copy = maxfraglen - skb->len;
 
@@ -1360,7 +1357,7 @@ alloc_new_skb:
 			 * we know we need more fragment(s).
 			 */
 			datalen = length + fraggap;
-			if (datalen > (cork->length <= mtu && !(cork->flags & IPCORK_ALLFRAG) ? mtu : maxfraglen) - fragheaderlen)
+			if (datalen > (cork->length <= mtu ? mtu : maxfraglen) - fragheaderlen)
 				datalen = maxfraglen - fragheaderlen;
 
 			fraglen = datalen + fragheaderlen;
@@ -1550,7 +1547,6 @@ static void ip6_cork_release(struct inet_sock *inet, struct ipv6_pinfo *np)
 	if (inet->cork.base.dst) {
 		dst_release(inet->cork.base.dst);
 		inet->cork.base.dst = NULL;
-		inet->cork.base.flags &= ~IPCORK_ALLFRAG;
 	}
 	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0aefc36..43e2ec1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1044,12 +1044,6 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 
 	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
 		rt6->rt6i_flags |= RTF_MODIFIED;
-		if (mtu < IPV6_MIN_MTU) {
-			u32 features = dst_metric(dst, RTAX_FEATURES);
-			mtu = IPV6_MIN_MTU;
-			features |= RTAX_FEATURE_ALLFRAG;
-			dst_metric_set(dst, RTAX_FEATURES, features);
-		}
 		dst_metric_set(dst, RTAX_MTU, mtu);
 	}
 }
@@ -1707,7 +1701,6 @@ static void rt6_do_pmtu_disc(const struct in6_addr *daddr, const struct in6_addr
 			     struct net *net, u32 pmtu, int ifindex)
 {
 	struct rt6_info *rt, *nrt;
-	int allfrag = 0;
 again:
 	rt = rt6_lookup(net, daddr, saddr, ifindex, 0);
 	if (!rt)
@@ -1721,17 +1714,6 @@ again:
 	if (pmtu >= dst_mtu(&rt->dst))
 		goto out;
 
-	if (pmtu < IPV6_MIN_MTU) {
-		/*
-		 * According to RFC2460, PMTU is set to the IPv6 Minimum Link
-		 * MTU (1280) and a fragment header should always be included
-		 * after a node receiving Too Big message reporting PMTU is
-		 * less than the IPv6 Minimum Link MTU.
-		 */
-		pmtu = IPV6_MIN_MTU;
-		allfrag = 1;
-	}
-
 	/* New mtu received -> path was valid.
 	   They are sent only in response to data packets,
 	   so that this nexthop apparently is reachable. --ANK
@@ -1745,11 +1727,6 @@ again:
 	 */
 	if (rt->rt6i_flags & RTF_CACHE) {
 		dst_metric_set(&rt->dst, RTAX_MTU, pmtu);
-		if (allfrag) {
-			u32 features = dst_metric(&rt->dst, RTAX_FEATURES);
-			features |= RTAX_FEATURE_ALLFRAG;
-			dst_metric_set(&rt->dst, RTAX_FEATURES, features);
-		}
 		rt6_update_expires(rt, net->ipv6.sysctl.ip6_rt_mtu_expires);
 		rt->rt6i_flags |= RTF_MODIFIED;
 		goto out;
@@ -1767,11 +1744,6 @@ again:
 
 	if (nrt) {
 		dst_metric_set(&nrt->dst, RTAX_MTU, pmtu);
-		if (allfrag) {
-			u32 features = dst_metric(&nrt->dst, RTAX_FEATURES);
-			features |= RTAX_FEATURE_ALLFRAG;
-			dst_metric_set(&nrt->dst, RTAX_FEATURES, features);
-		}
 
 		/* According to RFC 1981, detecting PMTU increase shouldn't be
 		 * happened within 5 mins, the recommended timer is 10 mins.
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 8755a30..8242af0 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -146,11 +146,10 @@ static int __xfrm6_output(struct sk_buff *skb)
 		return -EMSGSIZE;
 	}
 
-	if (x->props.mode == XFRM_MODE_TUNNEL &&
-	    ((skb->len > mtu && !skb_is_gso(skb)) ||
-		dst_allfrag(skb_dst(skb)))) {
-			return ip6_fragment(skb, x->outer_mode->afinfo->output_finish);
-	}
+	if (x->props.mode == XFRM_MODE_TUNNEL && skb->len > mtu &&
+	    !skb_is_gso(skb))
+		return ip6_fragment(skb, x->outer_mode->afinfo->output_finish);
+
 	return x->outer_mode->afinfo->output_finish(skb);
 }
 
