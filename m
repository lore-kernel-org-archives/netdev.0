From: David Miller <davem@davemloft.net>
Subject: [PATCH v6 3/3] ipv4: Remove rt_key_{src,dst,tos} from struct
 rtable.
Date: Thu, 05 May 2011 16:36:11 -0700 (PDT)
Message-ID: <20110505.163611.200356549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jpirko@redhat.com, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47510
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754248Ab1EEXgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 19:36:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


They are always used in contexts where they can be reconstituted,
or where the finally resolved rt->rt_{src,dst} is semantically
equivalent.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h     |    7 +-----
 net/ipv4/ip_options.c   |   10 ++++----
 net/ipv4/route.c        |   49 +++++++++++++---------------------------------
 net/ipv4/xfrm4_policy.c |    3 --
 4 files changed, 20 insertions(+), 49 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index ef20edc..70155fb 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -45,14 +45,9 @@ struct fib_info;
 struct rtable {
 	struct dst_entry	dst;
 
-	/* Lookup key. */
-	__be32			rt_key_dst;
-	__be32			rt_key_src;
-
 	int			rt_genid;
 	unsigned		rt_flags;
 	__u16			rt_type;
-	__u8			rt_key_tos;
 
 	__be32			rt_dst;	/* Path destination	*/
 	__be32			rt_src;	/* Path source		*/
@@ -176,7 +171,7 @@ extern unsigned		inet_addr_type(struct net *net, __be32 addr);
 extern unsigned		inet_dev_addr_type(struct net *net, const struct net_device *dev, __be32 addr);
 extern void		ip_rt_multicast_event(struct in_device *);
 extern int		ip_rt_ioctl(struct net *, unsigned int cmd, void __user *arg);
-extern void		ip_rt_get_source(u8 *src, struct rtable *rt);
+extern void		ip_rt_get_source(struct iphdr *iph, u8 *src, struct rtable *rt);
 extern int		ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb);
 
 struct in_ifaddr;
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 01fc409..4dc0f22 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -50,9 +50,9 @@ void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
 
 	if (!is_frag) {
 		if (opt->rr_needaddr)
-			ip_rt_get_source(iph+opt->rr+iph[opt->rr+2]-5, rt);
+			ip_rt_get_source(ip_hdr(skb), iph+opt->rr+iph[opt->rr+2]-5, rt);
 		if (opt->ts_needaddr)
-			ip_rt_get_source(iph+opt->ts+iph[opt->ts+2]-9, rt);
+			ip_rt_get_source(ip_hdr(skb), iph+opt->ts+iph[opt->ts+2]-9, rt);
 		if (opt->ts_needtime) {
 			struct timespec tv;
 			__be32 midtime;
@@ -553,7 +553,7 @@ void ip_forward_options(struct sk_buff *skb)
 
 	if (opt->rr_needaddr) {
 		optptr = (unsigned char *)raw + opt->rr;
-		ip_rt_get_source(&optptr[optptr[2]-5], rt);
+		ip_rt_get_source(ip_hdr(skb), &optptr[optptr[2]-5], rt);
 		opt->is_changed = 1;
 	}
 	if (opt->srr_is_hit) {
@@ -572,14 +572,14 @@ void ip_forward_options(struct sk_buff *skb)
 		}
 		if (srrptr + 3 <= srrspace) {
 			opt->is_changed = 1;
-			ip_rt_get_source(&optptr[srrptr-1], rt);
+			ip_rt_get_source(ip_hdr(skb), &optptr[srrptr-1], rt);
 			ip_hdr(skb)->daddr = rt->rt_dst;
 			optptr[2] = srrptr+4;
 		} else if (net_ratelimit())
 			printk(KERN_CRIT "ip_forward(): Argh! Destination lost!\n");
 		if (opt->ts_needaddr) {
 			optptr = raw + opt->ts;
-			ip_rt_get_source(&optptr[optptr[2]-9], rt);
+			ip_rt_get_source(ip_hdr(skb), &optptr[optptr[2]-9], rt);
 			opt->is_changed = 1;
 		}
 	}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index be5976a..1e67624 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -628,8 +628,8 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 			ret = NULL;
 		} else if (rt->rt_flags & RTCF_REDIRECTED) {
 #if RT_CACHE_DEBUG >= 1
-			printk(KERN_DEBUG "ipv4_negative_advice: redirect to %pI4/%02x dropped\n",
-			       &rt->rt_dst, rt->rt_key_tos);
+			printk(KERN_DEBUG "ipv4_negative_advice: redirect to %pI4 dropped\n",
+			       &rt->rt_dst);
 #endif
 			ip_rt_put(rt);
 			ret = NULL;
@@ -979,7 +979,7 @@ static int ip_rt_bug(struct sk_buff *skb)
    in IP options!
  */
 
-void ip_rt_get_source(u8 *addr, struct rtable *rt)
+void ip_rt_get_source(struct iphdr *iph, u8 *addr, struct rtable *rt)
 {
 	__be32 src;
 	struct fib_result res;
@@ -988,9 +988,9 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 		src = rt->rt_src;
 	else {
 		struct flowi4 fl4 = {
-			.daddr = rt->rt_key_dst,
-			.saddr = rt->rt_key_src,
-			.flowi4_tos = rt->rt_key_tos,
+			.daddr = rt->rt_dst,
+			.saddr = rt->rt_src,
+			.flowi4_tos = iph->tos,
 			.flowi4_oif = rt->rt_oif,
 			.flowi4_iif = rt->rt_iif,
 			.flowi4_mark = rt->rt_mark,
@@ -1160,12 +1160,9 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 #endif
 	rth->dst.output = ip_rt_bug;
 
-	rth->rt_key_dst	= daddr;
-	rth->rt_key_src	= saddr;
 	rth->rt_genid	= rt_genid(dev_net(dev));
 	rth->rt_flags	= RTCF_MULTICAST;
 	rth->rt_type	= RTN_MULTICAST;
-	rth->rt_key_tos	= tos;
 	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
 	rth->rt_route_iif = dev->ifindex;
@@ -1296,12 +1293,9 @@ static int __mkroute_input(struct sk_buff *skb,
 		goto cleanup;
 	}
 
-	rth->rt_key_dst	= daddr;
-	rth->rt_key_src	= saddr;
 	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
-	rth->rt_key_tos	= tos;
 	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
 	rth->rt_route_iif = in_dev->dev->ifindex;
@@ -1471,12 +1465,9 @@ local_input:
 	rth->dst.tclassid = itag;
 #endif
 
-	rth->rt_key_dst	= daddr;
-	rth->rt_key_src	= saddr;
 	rth->rt_genid = rt_genid(net);
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	rth->rt_type	= res.type;
-	rth->rt_key_tos	= tos;
 	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
 #ifdef CONFIG_IP_ROUTE_CLASSID
@@ -1589,12 +1580,10 @@ EXPORT_SYMBOL(ip_route_input);
 /* called with rcu_read_lock() */
 static struct rtable *__mkroute_output(const struct fib_result *res,
 				       const struct flowi4 *fl4,
-				       __be32 orig_daddr, __be32 orig_saddr,
 				       int orig_oif, struct net_device *dev_out,
 				       unsigned int flags)
 {
 	struct fib_info *fi = res->fi;
-	u32 tos = RT_FL_TOS(fl4);
 	struct in_device *in_dev;
 	u16 type = res->type;
 	struct rtable *rth;
@@ -1640,12 +1629,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	rth->dst.output = ip_output;
 
-	rth->rt_key_dst	= orig_daddr;
-	rth->rt_key_src	= orig_saddr;
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
-	rth->rt_key_tos	= tos;
 	rth->rt_dst	= fl4->daddr;
 	rth->rt_src	= fl4->saddr;
 	rth->rt_route_iif = 0;
@@ -1698,8 +1684,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	unsigned int flags = 0;
 	struct fib_result res;
 	struct rtable *rth;
-	__be32 orig_daddr;
-	__be32 orig_saddr;
 	int orig_oif;
 
 	res.fi		= NULL;
@@ -1707,8 +1691,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	res.r		= NULL;
 #endif
 
-	orig_daddr = fl4->daddr;
-	orig_saddr = fl4->saddr;
 	orig_oif = fl4->flowi4_oif;
 
 	fl4->flowi4_iif = net->loopback_dev->ifindex;
@@ -1869,8 +1851,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 
 
 make_route:
-	rth = __mkroute_output(&res, fl4, orig_daddr, orig_saddr, orig_oif,
-			       dev_out, flags);
+	rth = __mkroute_output(&res, fl4, orig_oif, dev_out, flags);
 	if (!IS_ERR(rth))
 		rth = rt_finalize(rth, NULL);
 
@@ -1928,9 +1909,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		if (new->dev)
 			dev_hold(new->dev);
 
-		rt->rt_key_dst = ort->rt_key_dst;
-		rt->rt_key_src = ort->rt_key_src;
-		rt->rt_key_tos = ort->rt_key_tos;
 		rt->rt_route_iif = ort->rt_route_iif;
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_oif = ort->rt_oif;
@@ -1975,7 +1953,7 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 }
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
-static int rt_fill_info(struct net *net,
+static int rt_fill_info(struct net *net,  __be32 src, u8 tos,
 			struct sk_buff *skb, u32 pid, u32 seq, int event,
 			int nowait, unsigned int flags)
 {
@@ -1993,7 +1971,7 @@ static int rt_fill_info(struct net *net,
 	r->rtm_family	 = AF_INET;
 	r->rtm_dst_len	= 32;
 	r->rtm_src_len	= 0;
-	r->rtm_tos	= rt->rt_key_tos;
+	r->rtm_tos	= tos;
 	r->rtm_table	= RT_TABLE_MAIN;
 	NLA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
 	r->rtm_type	= rt->rt_type;
@@ -2005,9 +1983,9 @@ static int rt_fill_info(struct net *net,
 
 	NLA_PUT_BE32(skb, RTA_DST, rt->rt_dst);
 
-	if (rt->rt_key_src) {
+	if (src) {
 		r->rtm_src_len = 32;
-		NLA_PUT_BE32(skb, RTA_SRC, rt->rt_key_src);
+		NLA_PUT_BE32(skb, RTA_SRC, src);
 	}
 	if (rt->dst.dev)
 		NLA_PUT_U32(skb, RTA_OIF, rt->dst.dev->ifindex);
@@ -2017,7 +1995,7 @@ static int rt_fill_info(struct net *net,
 #endif
 	if (rt_is_input_route(rt))
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_spec_dst);
-	else if (rt->rt_src != rt->rt_key_src)
+	else if (rt->rt_src != src)
 		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_src);
 
 	if (rt->rt_dst != rt->rt_gateway)
@@ -2158,7 +2136,8 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	err = rt_fill_info(net, skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
+	err = rt_fill_info(net, src, rtm->rtm_tos, skb,
+			   NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
 			   RTM_NEWROUTE, 0, 0);
 	if (err <= 0)
 		goto errout_free;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 7ff973b..bfe3d50 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -71,9 +71,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	struct rtable *rt = (struct rtable *)xdst->route;
 	const struct flowi4 *fl4 = &fl->u.ip4;
 
-	rt->rt_key_dst = fl4->daddr;
-	rt->rt_key_src = fl4->saddr;
-	rt->rt_key_tos = fl4->flowi4_tos;
 	rt->rt_route_iif = fl4->flowi4_iif;
 	rt->rt_iif = fl4->flowi4_iif;
 	rt->rt_oif = fl4->flowi4_oif;
-- 
1.7.5.1

