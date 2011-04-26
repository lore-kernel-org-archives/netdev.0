From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/4] ipv4: Remove erroneous check in igmpv3_newpack() and
 igmp_send_report().
Date: Tue, 26 Apr 2011 15:12:04 -0700 (PDT)
Message-ID: <20110426.151204.70183859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48349
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932997Ab1DZWMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 18:12:38 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id F377A24C08A
	for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 15:12:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Output route resolution never returns a route with rt_src set to zero
(which is INADDR_ANY).

Even if the flow key for the output route lookup specifies INADDR_ANY
for the source address, the output route resolution chooses a real
source address to use in the final route.

This test has existed forever in igmp_send_report() and David Stevens
simply copied over the erroneous test when implementing support for
IGMPv3.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/igmp.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 1fd3d9c..8ae0a57 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -328,11 +328,6 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 		kfree_skb(skb);
 		return NULL;
 	}
-	if (rt->rt_src == 0) {
-		kfree_skb(skb);
-		ip_rt_put(rt);
-		return NULL;
-	}
 
 	skb_dst_set(skb, &rt->dst);
 	skb->dev = dev;
@@ -670,11 +665,6 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 	if (IS_ERR(rt))
 		return -1;
 
-	if (rt->rt_src == 0) {
-		ip_rt_put(rt);
-		return -1;
-	}
-
 	skb = alloc_skb(IGMP_SIZE+LL_ALLOCATED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL) {
 		ip_rt_put(rt);
-- 
1.7.4.5

