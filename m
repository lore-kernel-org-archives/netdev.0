From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/5] ipv6: Eliminate dst_get_neighbour_noref() usage in
 ip6_forward().
Date: Fri, 27 Jan 2012 21:03:51 -0500 (EST)
Message-ID: <20120127.210351.1552670841188297125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795Ab2A1CDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 21:03:53 -0500
Received: from localhost (cpe-66-65-56-15.nyc.res.rr.com [66.65.56.15])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q0S23qS9009924
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 18:03:52 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's only used to get at neigh->primary_key, which in this context is
always going to be the same as rt->rt6i_gateway.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/ip6_output.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 604809b..7a98fc2 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -388,7 +388,6 @@ int ip6_forward(struct sk_buff *skb)
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct inet6_skb_parm *opt = IP6CB(skb);
 	struct net *net = dev_net(dst->dev);
-	struct neighbour *n;
 	u32 mtu;
 
 	if (net->ipv6.devconf_all->forwarding == 0)
@@ -463,8 +462,7 @@ int ip6_forward(struct sk_buff *skb)
 	   send redirects to source routed frames.
 	   We don't send redirects to frames decapsulated from IPsec.
 	 */
-	n = dst_get_neighbour_noref(dst);
-	if (skb->dev == dst->dev && n && opt->srcrt == 0 && !skb_sec_path(skb)) {
+	if (skb->dev == dst->dev && opt->srcrt == 0 && !skb_sec_path(skb)) {
 		struct in6_addr *target = NULL;
 		struct rt6_info *rt;
 
@@ -474,8 +472,8 @@ int ip6_forward(struct sk_buff *skb)
 		 */
 
 		rt = (struct rt6_info *) dst;
-		if ((rt->rt6i_flags & RTF_GATEWAY))
-			target = (struct in6_addr*)&n->primary_key;
+		if (rt->rt6i_flags & RTF_GATEWAY)
+			target = &rt->rt6i_gateway;
 		else
 			target = &hdr->daddr;
 
-- 
1.7.7.5
