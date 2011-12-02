From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipv4: make sure RTO_ONLINK is saved in routing cache
Date: Fri,  2 Dec 2011 23:39:42 +0200
Message-ID: <1322861982-3780-1-git-send-email-ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:38861 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755539Ab1LBVjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 16:39:06 -0500
Received: from ja.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id pB2Ldw5M003808
	for <netdev@vger.kernel.org>; Fri, 2 Dec 2011 23:39:58 +0200
Received: (from root@localhost)
	by ja.ssi.bg (8.14.4/8.14.4/Submit) id pB2Ldw32003806
	for netdev@vger.kernel.org; Fri, 2 Dec 2011 23:39:58 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	__mkroute_output fails to work with the original tos
and uses value with stripped RTO_ONLINK bit. Make sure we put
the original TOS bits into rt_key_tos because it used to match
cached route.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/route.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7047069..c546c4c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -111,7 +111,7 @@
 #include <net/secure_seq.h>
 
 #define RT_FL_TOS(oldflp4) \
-    ((u32)(oldflp4->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK)))
+	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
 
 #define IP_MAX_MTU	0xFFF0
 
@@ -2435,11 +2435,11 @@ EXPORT_SYMBOL(ip_route_input_common);
 static struct rtable *__mkroute_output(const struct fib_result *res,
 				       const struct flowi4 *fl4,
 				       __be32 orig_daddr, __be32 orig_saddr,
-				       int orig_oif, struct net_device *dev_out,
+				       int orig_oif, __u8 orig_rtos,
+				       struct net_device *dev_out,
 				       unsigned int flags)
 {
 	struct fib_info *fi = res->fi;
-	u32 tos = RT_FL_TOS(fl4);
 	struct in_device *in_dev;
 	u16 type = res->type;
 	struct rtable *rth;
@@ -2490,7 +2490,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
-	rth->rt_key_tos	= tos;
+	rth->rt_key_tos	= orig_rtos;
 	rth->rt_dst	= fl4->daddr;
 	rth->rt_src	= fl4->saddr;
 	rth->rt_route_iif = 0;
@@ -2540,7 +2540,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 static struct rtable *ip_route_output_slow(struct net *net, struct flowi4 *fl4)
 {
 	struct net_device *dev_out = NULL;
-	u32 tos	= RT_FL_TOS(fl4);
+	__u8 tos = RT_FL_TOS(fl4);
 	unsigned int flags = 0;
 	struct fib_result res;
 	struct rtable *rth;
@@ -2716,7 +2716,7 @@ static struct rtable *ip_route_output_slow(struct net *net, struct flowi4 *fl4)
 
 make_route:
 	rth = __mkroute_output(&res, fl4, orig_daddr, orig_saddr, orig_oif,
-			       dev_out, flags);
+			       tos, dev_out, flags);
 	if (!IS_ERR(rth)) {
 		unsigned int hash;
 
-- 
1.7.3.4
