From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/10] ipv4: xfrm: Eliminate ->rt_src reference in policy
 code.
Date: Mon, 09 May 2011 22:31:36 -0700 (PDT)
Message-ID: <20110509.223136.70188816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53423
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753762Ab1EJFcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 01:32:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E95EC24C087
	for <netdev@vger.kernel.org>; Mon,  9 May 2011 22:31:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Rearrange xfrm4_dst_lookup() so that it works by calling a helper
function __xfrm_dst_lookup() that takes an explicit flow key storage
area as an argument.

Use this new helper in xfrm4_get_saddr() so we can fetch the selected
source address from the flow instead of from rt->rt_src

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/xfrm4_policy.c |   34 +++++++++++++++++++++-------------
 1 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 7ff973b..981e43e 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -18,38 +18,46 @@
 
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
 
-static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
-					  const xfrm_address_t *saddr,
-					  const xfrm_address_t *daddr)
+static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
+					    int tos,
+					    const xfrm_address_t *saddr,
+					    const xfrm_address_t *daddr)
 {
-	struct flowi4 fl4 = {
-		.daddr = daddr->a4,
-		.flowi4_tos = tos,
-	};
 	struct rtable *rt;
 
+	memset(fl4, 0, sizeof(*fl4));
+	fl4->daddr = daddr->a4;
+	fl4->flowi4_tos = tos;
 	if (saddr)
-		fl4.saddr = saddr->a4;
+		fl4->saddr = saddr->a4;
 
-	rt = __ip_route_output_key(net, &fl4);
+	rt = __ip_route_output_key(net, fl4);
 	if (!IS_ERR(rt))
 		return &rt->dst;
 
 	return ERR_CAST(rt);
 }
 
+static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
+					  const xfrm_address_t *saddr,
+					  const xfrm_address_t *daddr)
+{
+	struct flowi4 fl4;
+
+	return __xfrm4_dst_lookup(net, &fl4, tos, saddr, daddr);
+}
+
 static int xfrm4_get_saddr(struct net *net,
 			   xfrm_address_t *saddr, xfrm_address_t *daddr)
 {
 	struct dst_entry *dst;
-	struct rtable *rt;
+	struct flowi4 fl4;
 
-	dst = xfrm4_dst_lookup(net, 0, NULL, daddr);
+	dst = __xfrm4_dst_lookup(net, &fl4, 0, NULL, daddr);
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
 
-	rt = (struct rtable *)dst;
-	saddr->a4 = rt->rt_src;
+	saddr->a4 = fl4.saddr;
 	dst_release(dst);
 	return 0;
 }
-- 
1.7.5.1

