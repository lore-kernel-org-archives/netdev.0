From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Only flood unregistered groups to routers
Date: Thu, 23 Jun 2011 20:39:12 +0800
Message-ID: <20110623123912.GA29381@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43550 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759400Ab1FWMjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 08:39:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

bridge: Only flood traffic for unregistered groups to routers

The bridge currently floods packets to groups that we have never
seen before to all ports.  This is not required by RFC4541 and
in fact it is not desirable in environment where traffic to
unregistered group is always present.

This patch changes the behaviour so that we only send traffic
to unregistered groups to ports marked as routers.

The user can always force flooding behaviour to any given port
by marking it as a router.

Note that this change does not apply to traffic to 224.0.0.X
as traffic to those groups must always be flooded to all ports.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 29b9812..2d85ca7 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1379,8 +1379,11 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
 		return -EINVAL;
 
-	if (iph->protocol != IPPROTO_IGMP)
+	if (iph->protocol != IPPROTO_IGMP) {
+		if ((iph->daddr & IGMP_LOCAL_GROUP_MASK) != IGMP_LOCAL_GROUP)
+			BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
 		return 0;
+	}
 
 	len = ntohs(iph->tot_len);
 	if (skb->len < len || len < ip_hdrlen(skb))

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
