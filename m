From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH v2] netns: Add network namespace argument to rt6_fill_node()
 and ipv6_dev_get_saddr()
Date: Thu, 14 Aug 2008 17:38:12 -0400
Message-ID: <48A4A5C4.4080109@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050908000604000606070108"
Cc: containers <containers@lists.osdl.org>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:13196 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592AbYHNViQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 17:38:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050908000604000606070108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Sorry for the resend, forgot netdev the first time.

ipv6_dev_get_saddr() blindly de-references dst_dev to get the network
namespace, but some callers might pass NULL.  Change callers to pass a
namespace pointer instead.

-Brian

Signed-off-by: Brian Haley <brian.haley@hp.com>
---


--------------050908000604000606070108
Content-Type: text/x-patch;
 name="netns.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netns.patch"

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 06b2814..c216de5 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -80,7 +80,8 @@ extern struct inet6_ifaddr      *ipv6_get_ifaddr(struct net *net,
 						 struct net_device *dev,
 						 int strict);
 
-extern int			ipv6_dev_get_saddr(struct net_device *dev, 
+extern int			ipv6_dev_get_saddr(struct net *net,
+					       struct net_device *dev,
 					       const struct in6_addr *daddr,
 					       unsigned int srcprefs,
 					       struct in6_addr *saddr);
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index bc391ba..5f53db7 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -107,6 +107,7 @@ struct rt6_rtnl_dump_arg
 {
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
+	struct net *net;
 };
 
 extern int rt6_dump_route(struct rt6_info *rt, void *p_arg);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a7842c5..e2d3b75 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1106,13 +1106,12 @@ out:
 	return ret;
 }
 
-int ipv6_dev_get_saddr(struct net_device *dst_dev,
+int ipv6_dev_get_saddr(struct net *net, struct net_device *dst_dev,
 		       const struct in6_addr *daddr, unsigned int prefs,
 		       struct in6_addr *saddr)
 {
 	struct ipv6_saddr_score scores[2],
 				*score = &scores[0], *hiscore = &scores[1];
-	struct net *net = dev_net(dst_dev);
 	struct ipv6_saddr_dst dst;
 	struct net_device *dev;
 	int dst_type;
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 8d05527..f5de3f9 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -93,7 +93,8 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 			if (flags & RT6_LOOKUP_F_SRCPREF_COA)
 				srcprefs |= IPV6_PREFER_SRC_COA;
 
-			if (ipv6_dev_get_saddr(ip6_dst_idev(&rt->u.dst)->dev,
+			if (ipv6_dev_get_saddr(net,
+					       ip6_dst_idev(&rt->u.dst)->dev,
 					       &flp->fl6_dst, srcprefs,
 					       &saddr))
 				goto again;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 52dddc2..29c7c99 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -378,6 +378,7 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 
 	arg.skb = skb;
 	arg.cb = cb;
+	arg.net = net;
 	w->args = &arg;
 
 	for (h = s_h; h < FIB_TABLE_HASHSZ; h++, s_e = 0) {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a4402de..0e844c2 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -934,7 +934,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 		goto out_err_release;
 
 	if (ipv6_addr_any(&fl->fl6_src)) {
-		err = ipv6_dev_get_saddr(ip6_dst_idev(*dst)->dev,
+		err = ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
 					 &fl->fl6_dst,
 					 sk ? inet6_sk(sk)->srcprefs : 0,
 					 &fl->fl6_src);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index beb48e3..f1c62ba 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -549,7 +549,7 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 			override = 0;
 		in6_ifa_put(ifp);
 	} else {
-		if (ipv6_dev_get_saddr(dev, daddr,
+		if (ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
 				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->srcprefs,
 				       &tmpaddr))
 			return;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 41b165f..9af6115 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2106,7 +2106,8 @@ static inline size_t rt6_nlmsg_size(void)
 	       + nla_total_size(sizeof(struct rta_cacheinfo));
 }
 
-static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
+static int rt6_fill_node(struct net *net,
+			 struct sk_buff *skb, struct rt6_info *rt,
 			 struct in6_addr *dst, struct in6_addr *src,
 			 int iif, int type, u32 pid, u32 seq,
 			 int prefix, int nowait, unsigned int flags)
@@ -2189,7 +2190,7 @@ static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
 	} else if (dst) {
 		struct inet6_dev *idev = ip6_dst_idev(&rt->u.dst);
 		struct in6_addr saddr_buf;
-		if (ipv6_dev_get_saddr(idev ? idev->dev : NULL,
+		if (ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
 				       dst, 0, &saddr_buf) == 0)
 			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
 	}
@@ -2234,7 +2235,8 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 	} else
 		prefix = 0;
 
-	return rt6_fill_node(arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
+	return rt6_fill_node(arg->net,
+		     arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
 		     NETLINK_CB(arg->cb->skb).pid, arg->cb->nlh->nlmsg_seq,
 		     prefix, 0, NLM_F_MULTI);
 }
@@ -2300,7 +2302,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	rt = (struct rt6_info*) ip6_route_output(net, NULL, &fl);
 	skb->dst = &rt->u.dst;
 
-	err = rt6_fill_node(skb, rt, &fl.fl6_dst, &fl.fl6_src, iif,
+	err = rt6_fill_node(net, skb, rt, &fl.fl6_dst, &fl.fl6_src, iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
 			    nlh->nlmsg_seq, 0, 0, 0);
 	if (err < 0) {
@@ -2327,7 +2329,7 @@ void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info)
 	if (skb == NULL)
 		goto errout;
 
-	err = rt6_fill_node(skb, rt, NULL, NULL, 0,
+	err = rt6_fill_node(net, skb, rt, NULL, NULL, 0,
 				event, info->pid, seq, 0, 0, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in rt6_nlmsg_size() */
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 8f1e054..08e4cbb 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -52,12 +52,14 @@ static struct dst_entry *xfrm6_dst_lookup(int tos, xfrm_address_t *saddr,
 static int xfrm6_get_saddr(xfrm_address_t *saddr, xfrm_address_t *daddr)
 {
 	struct dst_entry *dst;
+	struct net_device *dev;
 
 	dst = xfrm6_dst_lookup(0, NULL, daddr);
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
 
-	ipv6_dev_get_saddr(ip6_dst_idev(dst)->dev,
+	dev = ip6_dst_idev(dst)->dev;
+	ipv6_dev_get_saddr(dev_net(dev), dev,
 			   (struct in6_addr *)&daddr->a6, 0,
 			   (struct in6_addr *)&saddr->a6);
 	dst_release(dst);
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 483a01d..47f91af 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -319,7 +319,8 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 			  __func__, asoc, dst, NIP6(daddr->v6.sin6_addr));
 
 	if (!asoc) {
-		ipv6_dev_get_saddr(dst ? ip6_dst_idev(dst)->dev : NULL,
+		ipv6_dev_get_saddr(sock_net(sctp_opt2sk(sk)),
+				   dst ? ip6_dst_idev(dst)->dev : NULL,
 				   &daddr->v6.sin6_addr,
 				   inet6_sk(&sk->inet.sk)->srcprefs,
 				   &saddr->v6.sin6_addr);


--------------050908000604000606070108--
