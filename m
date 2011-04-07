From: Michael Smith <msmith@cbnco.com>
Subject: [PATCH v2 1/2] fib_validate_source(): pass sk_buff instead of mark
Date: Thu,  7 Apr 2011 10:51:50 -0400
Message-ID: <1302187911-20688-2-git-send-email-msmith@cbnco.com>
References: <1302187911-20688-1-git-send-email-msmith@cbnco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cbnco.com ([207.164.182.72]:47793 "EHLO smtp.cbnco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754592Ab1DGOp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 10:45:28 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtp.cbnco.com (Postfix) with ESMTP id 4F5B5B75570
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2011 10:45:26 -0400 (EDT)
Received: from smtp.cbnco.com ([127.0.0.1])
 by localhost (mail.cbnco.com [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 15219-08-2 for <netdev@vger.kernel.org>;
 Thu,  7 Apr 2011 10:45:25 -0400 (EDT)
Received: from sles10-64.jrz.cbn (dmzgw2.cbnco.com [207.164.182.65])
	by smtp.cbnco.com (Postfix) with ESMTPS id 019C5B59B1A
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2011 10:45:23 -0400 (EDT)
In-Reply-To: <1302187911-20688-1-git-send-email-msmith@cbnco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes sk_buff available for other use in fib_validate_source().

Signed-off-by: Michael Smith <msmith@cbnco.com>
---
 include/net/ip_fib.h    |    6 +++---
 net/ipv4/fib_frontend.c |   10 ++++------
 net/ipv4/route.c        |   16 ++++++++--------
 3 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e5d66ec..514627f 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -227,9 +227,9 @@ extern struct fib_table *fib_get_table(struct net *net, u32 id);
 /* Exported by fib_frontend.c */
 extern const struct nla_policy rtm_ipv4_policy[];
 extern void		ip_fib_init(void);
-extern int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
-			       struct net_device *dev, __be32 *spec_dst,
-			       u32 *itag, u32 mark);
+extern int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
+			       u8 tos, int oif, struct net_device *dev,
+			       __be32 *spec_dst, u32 *itag);
 extern void fib_select_default(struct fib_result *res);
 
 /* Exported by fib_semantics.c */
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 4510883..f162f84 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -188,9 +188,9 @@ EXPORT_SYMBOL(inet_dev_addr_type);
  * - check, that packet arrived from expected physical interface.
  * called with rcu_read_lock()
  */
-int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
-			struct net_device *dev, __be32 *spec_dst,
-			u32 *itag, u32 mark)
+int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst, u8 tos,
+			int oif, struct net_device *dev, __be32 *spec_dst,
+			u32 *itag)
 {
 	struct in_device *in_dev;
 	struct flowi4 fl4;
@@ -202,7 +202,6 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 
 	fl4.flowi4_oif = 0;
 	fl4.flowi4_iif = oif;
-	fl4.flowi4_mark = mark;
 	fl4.daddr = src;
 	fl4.saddr = dst;
 	fl4.flowi4_tos = tos;
@@ -214,8 +213,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 		no_addr = in_dev->ifa_list == NULL;
 		rpf = IN_DEV_RPFILTER(in_dev);
 		accept_local = IN_DEV_ACCEPT_LOCAL(in_dev);
-		if (mark && !IN_DEV_SRC_VMARK(in_dev))
-			fl4.flowi4_mark = 0;
+		fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
 	}
 
 	if (in_dev == NULL)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4b0c811..57447b7 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1871,8 +1871,8 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			goto e_inval;
 		spec_dst = inet_select_addr(dev, 0, RT_SCOPE_LINK);
 	} else {
-		err = fib_validate_source(saddr, 0, tos, 0, dev, &spec_dst,
-					  &itag, 0);
+		err = fib_validate_source(skb, saddr, 0, tos, 0, dev, &spec_dst,
+					  &itag);
 		if (err < 0)
 			goto e_err;
 	}
@@ -1980,8 +1980,8 @@ static int __mkroute_input(struct sk_buff *skb,
 	}
 
 
-	err = fib_validate_source(saddr, daddr, tos, FIB_RES_OIF(*res),
-				  in_dev->dev, &spec_dst, &itag, skb->mark);
+	err = fib_validate_source(skb, saddr, daddr, tos, FIB_RES_OIF(*res),
+				  in_dev->dev, &spec_dst, &itag);
 	if (err < 0) {
 		ip_handle_martian_source(in_dev->dev, in_dev, skb, daddr,
 					 saddr);
@@ -2148,9 +2148,9 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		goto brd_input;
 
 	if (res.type == RTN_LOCAL) {
-		err = fib_validate_source(saddr, daddr, tos,
+		err = fib_validate_source(skb, saddr, daddr, tos,
 					  net->loopback_dev->ifindex,
-					  dev, &spec_dst, &itag, skb->mark);
+					  dev, &spec_dst, &itag);
 		if (err < 0)
 			goto martian_source_keep_err;
 		if (err)
@@ -2174,8 +2174,8 @@ brd_input:
 	if (ipv4_is_zeronet(saddr))
 		spec_dst = inet_select_addr(dev, 0, RT_SCOPE_LINK);
 	else {
-		err = fib_validate_source(saddr, 0, tos, 0, dev, &spec_dst,
-					  &itag, skb->mark);
+		err = fib_validate_source(skb, saddr, 0, tos, 0, dev, &spec_dst,
+					  &itag);
 		if (err < 0)
 			goto martian_source_keep_err;
 		if (err)
-- 
1.6.3.2

