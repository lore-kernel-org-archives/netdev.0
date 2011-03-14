From: Michael Smith <msmith@cbnco.com>
Subject: [PATCH] Disable rp_filter for IPsec packets
Date: Mon, 14 Mar 2011 17:14:59 -0400
Message-ID: <1300137299-28161-1-git-send-email-msmith@cbnco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cbnco.com ([207.164.182.72]:53950 "EHLO smtp.cbnco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755631Ab1CNVR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 17:17:57 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtp.cbnco.com (Postfix) with ESMTP id 054035C3BCE
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 17:10:30 -0400 (EDT)
Received: from smtp.cbnco.com ([127.0.0.1])
 by localhost (mail.cbnco.com [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 03864-02 for <netdev@vger.kernel.org>;
 Mon, 14 Mar 2011 17:10:29 -0400 (EDT)
Received: from sles10-64.jrz.cbn (dmzgw2.cbnco.com [207.164.182.65])
	by smtp.cbnco.com (Postfix) with ESMTPS id D008A2B0B9D
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 17:10:29 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reverse path filter interferes with IPsec subnet-to-subnet tunnels,
especially when the link to the IPsec peer is on an interface other than
the one hosting the default route.

With dynamic routing, where the peer might be reachable through eth0
today and eth1 tomorrow, it's difficult to keep rp_filter enabled unless
fake routes to the remote subnets are configured on the interface
currently used to reach the peer.

IPsec provides a much stronger anti-spoofing policy than rp_filter, so
this patch disables the rp_filter for packets with a security path.

Signed-off-by: Michael Smith <msmith@cbnco.com>
---
 include/net/ip_fib.h    |    2 +-
 net/ipv4/fib_frontend.c |    4 ++--
 net/ipv4/route.c        |   26 ++++++++++++++++++--------
 3 files changed, 21 insertions(+), 11 deletions(-)


I have a feeling the approach of checking for skb->sp != NULL is pretty
naive, but it seems to work. Patch is against Linus' tree.


diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 07bdb5e..61d5365 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -217,7 +217,7 @@ extern const struct nla_policy rtm_ipv4_policy[];
 extern void		ip_fib_init(void);
 extern int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			       struct net_device *dev, __be32 *spec_dst,
-			       u32 *itag, u32 mark);
+			       u32 *itag, u32 mark, int norpf);
 extern void fib_select_default(struct net *net, const struct flowi *flp,
 			       struct fib_result *res);
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 1d2cdd4..ae889cc 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -245,7 +245,7 @@ EXPORT_SYMBOL(inet_dev_addr_type);
  */
 int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			struct net_device *dev, __be32 *spec_dst,
-			u32 *itag, u32 mark)
+			u32 *itag, u32 mark, int norpf)
 {
 	struct in_device *in_dev;
 	struct flowi fl = {
@@ -265,7 +265,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 	in_dev = __in_dev_get_rcu(dev);
 	if (in_dev) {
 		no_addr = in_dev->ifa_list == NULL;
-		rpf = IN_DEV_RPFILTER(in_dev);
+		rpf = norpf ? 0 : IN_DEV_RPFILTER(in_dev);
 		accept_local = IN_DEV_ACCEPT_LOCAL(in_dev);
 		if (mark && !IN_DEV_SRC_VMARK(in_dev))
 			fl.mark = 0;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6ed6603..3ada54c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1870,7 +1870,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		spec_dst = inet_select_addr(dev, 0, RT_SCOPE_LINK);
 	} else {
 		err = fib_validate_source(saddr, 0, tos, 0, dev, &spec_dst,
-					  &itag, 0);
+					  &itag, 0, 0);
 		if (err < 0)
 			goto e_err;
 	}
@@ -1962,7 +1962,7 @@ static int __mkroute_input(struct sk_buff *skb,
 			   struct fib_result *res,
 			   struct in_device *in_dev,
 			   __be32 daddr, __be32 saddr, u32 tos,
-			   struct rtable **result)
+			   struct rtable **result, int norpf)
 {
 	struct rtable *rth;
 	int err;
@@ -1982,7 +1982,8 @@ static int __mkroute_input(struct sk_buff *skb,
 
 
 	err = fib_validate_source(saddr, daddr, tos, FIB_RES_OIF(*res),
-				  in_dev->dev, &spec_dst, &itag, skb->mark);
+				  in_dev->dev, &spec_dst, &itag, skb->mark,
+				  norpf);
 	if (err < 0) {
 		ip_handle_martian_source(in_dev->dev, in_dev, skb, daddr,
 					 saddr);
@@ -2059,7 +2060,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 			    struct fib_result *res,
 			    const struct flowi *fl,
 			    struct in_device *in_dev,
-			    __be32 daddr, __be32 saddr, u32 tos)
+			    __be32 daddr, __be32 saddr, u32 tos, int norpf)
 {
 	struct rtable* rth = NULL;
 	int err;
@@ -2071,7 +2072,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 #endif
 
 	/* create a routing cache entry */
-	err = __mkroute_input(skb, res, in_dev, daddr, saddr, tos, &rth);
+	err = __mkroute_input(skb, res, in_dev, daddr, saddr, tos, &rth, norpf);
 	if (err)
 		return err;
 
@@ -2111,6 +2112,13 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	int		err = -EINVAL;
 	struct net    * net = dev_net(dev);
 
+#ifdef CONFIG_XFRM
+	/* Disable the reverse path filter for IPsec-protected packets. */
+	int		norpf = skb->sp != NULL;
+#else
+	int		norpf = 0;
+#endif
+
 	/* IP on this device is disabled. */
 
 	if (!in_dev)
@@ -2154,7 +2162,8 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (res.type == RTN_LOCAL) {
 		err = fib_validate_source(saddr, daddr, tos,
 					  net->loopback_dev->ifindex,
-					  dev, &spec_dst, &itag, skb->mark);
+					  dev, &spec_dst, &itag, skb->mark,
+					  norpf);
 		if (err < 0)
 			goto martian_source_keep_err;
 		if (err)
@@ -2168,7 +2177,8 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (res.type != RTN_UNICAST)
 		goto martian_destination;
 
-	err = ip_mkroute_input(skb, &res, &fl, in_dev, daddr, saddr, tos);
+	err = ip_mkroute_input(skb, &res, &fl, in_dev, daddr, saddr, tos,
+			       norpf);
 out:	return err;
 
 brd_input:
@@ -2179,7 +2189,7 @@ brd_input:
 		spec_dst = inet_select_addr(dev, 0, RT_SCOPE_LINK);
 	else {
 		err = fib_validate_source(saddr, 0, tos, 0, dev, &spec_dst,
-					  &itag, skb->mark);
+					  &itag, skb->mark, norpf);
 		if (err < 0)
 			goto martian_source_keep_err;
 		if (err)
-- 
1.6.3.2

