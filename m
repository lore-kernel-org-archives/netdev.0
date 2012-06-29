From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Adjust in_dev handling in fib_validate_source()
Date: Thu, 28 Jun 2012 19:05:11 -0700 (PDT)
Message-ID: <20120628.190511.1109096696797440163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692Ab2F2CFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 22:05:12 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 6CB23584B18
	for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 19:05:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Checking for in_dev being NULL is pointless.

In fact, all of our callers have in_dev precomputed already,
so just pass it in and remove the NULL checking.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h    |    2 +-
 net/ipv4/fib_frontend.c |   27 ++++++++++-----------------
 net/ipv4/route.c        |   10 ++++++----
 3 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 9e6c26d..619f68a 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -233,7 +233,7 @@ extern void		ip_fib_init(void);
 extern __be32 fib_compute_spec_dst(struct sk_buff *skb);
 extern int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 			       u8 tos, int oif, struct net_device *dev,
-			       u32 *itag);
+			       struct in_device *idev, u32 *itag);
 extern void fib_select_default(struct fib_result *res);
 
 /* Exported by fib_semantics.c */
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 1d13217..c84cff5 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -226,15 +226,14 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
  * called with rcu_read_lock()
  */
 int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst, u8 tos,
-			int oif, struct net_device *dev, u32 *itag)
+			int oif, struct net_device *dev, struct in_device *idev,
+			u32 *itag)
 {
-	struct in_device *in_dev;
-	struct flowi4 fl4;
+	int ret, no_addr, rpf, accept_local;
 	struct fib_result res;
-	int no_addr, rpf, accept_local;
-	bool dev_match;
-	int ret;
+	struct flowi4 fl4;
 	struct net *net;
+	bool dev_match;
 
 	fl4.flowi4_oif = 0;
 	fl4.flowi4_iif = oif;
@@ -244,19 +243,13 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst, u8 tos,
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
 
 	no_addr = rpf = accept_local = 0;
-	in_dev = __in_dev_get_rcu(dev);
-	if (in_dev) {
-		no_addr = in_dev->ifa_list == NULL;
-
-		/* Ignore rp_filter for packets protected by IPsec. */
-		rpf = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(in_dev);
+	no_addr = idev->ifa_list == NULL;
 
-		accept_local = IN_DEV_ACCEPT_LOCAL(in_dev);
-		fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
-	}
+	/* Ignore rp_filter for packets protected by IPsec. */
+	rpf = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
 
-	if (in_dev == NULL)
-		goto e_inval;
+	accept_local = IN_DEV_ACCEPT_LOCAL(idev);
+	fl4.flowi4_mark = IN_DEV_SRC_VMARK(idev) ? skb->mark : 0;
 
 	net = dev_net(dev);
 	if (fib_lookup(net, &fl4, &res))
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 83d56a0..919d69e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1999,7 +1999,8 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		if (!ipv4_is_local_multicast(daddr))
 			goto e_inval;
 	} else {
-		err = fib_validate_source(skb, saddr, 0, tos, 0, dev, &itag);
+		err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
+					  in_dev, &itag);
 		if (err < 0)
 			goto e_err;
 	}
@@ -2100,7 +2101,7 @@ static int __mkroute_input(struct sk_buff *skb,
 
 
 	err = fib_validate_source(skb, saddr, daddr, tos, FIB_RES_OIF(*res),
-				  in_dev->dev, &itag);
+				  in_dev->dev, in_dev, &itag);
 	if (err < 0) {
 		ip_handle_martian_source(in_dev->dev, in_dev, skb, daddr,
 					 saddr);
@@ -2274,7 +2275,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (res.type == RTN_LOCAL) {
 		err = fib_validate_source(skb, saddr, daddr, tos,
 					  net->loopback_dev->ifindex,
-					  dev, &itag);
+					  dev, in_dev, &itag);
 		if (err < 0)
 			goto martian_source_keep_err;
 		if (err)
@@ -2295,7 +2296,8 @@ brd_input:
 		goto e_inval;
 
 	if (!ipv4_is_zeronet(saddr)) {
-		err = fib_validate_source(skb, saddr, 0, tos, 0, dev, &itag);
+		err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
+					  in_dev, &itag);
 		if (err < 0)
 			goto martian_source_keep_err;
 		if (err)
-- 
1.7.10
