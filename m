From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/13 net-3.1-stable] ipv4: make sure RTO_ONLINK is saved
 in routing cache
Date: Tue, 06 Dec 2011 16:33:59 -0500 (EST)
Message-ID: <20111206.163359.805307383294780203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385Ab1LFVeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:34:01 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6LXxY9024356
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 13:34:00 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Julian Anastasov <ja@ssi.bg>

[ Upstream commit f61759e6b831a55b89e584b198c3da325e2bc379 ]

__mkroute_output fails to work with the original tos
and uses value with stripped RTO_ONLINK bit. Make sure we put
the original TOS bits into rt_key_tos because it used to match
cached route.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5c9b20f..05ac666c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -112,7 +112,7 @@
 #include <net/secure_seq.h>
 
 #define RT_FL_TOS(oldflp4) \
-    ((u32)(oldflp4->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK)))
+	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
 
 #define IP_MAX_MTU	0xFFF0
 
@@ -2430,11 +2430,11 @@ EXPORT_SYMBOL(ip_route_input_common);
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
@@ -2485,7 +2485,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
-	rth->rt_key_tos	= tos;
+	rth->rt_key_tos	= orig_rtos;
 	rth->rt_dst	= fl4->daddr;
 	rth->rt_src	= fl4->saddr;
 	rth->rt_route_iif = 0;
@@ -2535,7 +2535,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 static struct rtable *ip_route_output_slow(struct net *net, struct flowi4 *fl4)
 {
 	struct net_device *dev_out = NULL;
-	u32 tos	= RT_FL_TOS(fl4);
+	__u8 tos = RT_FL_TOS(fl4);
 	unsigned int flags = 0;
 	struct fib_result res;
 	struct rtable *rth;
@@ -2711,7 +2711,7 @@ static struct rtable *ip_route_output_slow(struct net *net, struct flowi4 *fl4)
 
 make_route:
 	rth = __mkroute_output(&res, fl4, orig_daddr, orig_saddr, orig_oif,
-			       dev_out, flags);
+			       tos, dev_out, flags);
 	if (!IS_ERR(rth)) {
 		unsigned int hash;
 
-- 
1.7.7.3
