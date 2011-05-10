From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/10] ipv4: icmp: Eliminate remaining uses of rt->rt_src
Date: Mon, 09 May 2011 22:31:13 -0700 (PDT)
Message-ID: <20110509.223113.115938589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53398
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752889Ab1EJFbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 01:31:45 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A4B0A24C087
	for <netdev@vger.kernel.org>; Mon,  9 May 2011 22:31:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On input packets, rt->rt_src always equals ip_hdr(skb)->saddr

Anything that mangles or otherwise changes the IP header must
relookup the route found at skb_rtable().  Therefore this
invariant must always hold true.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/icmp.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 853a670..3314394 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -345,7 +345,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	icmp_param->data.icmph.checksum = 0;
 
 	inet->tos = ip_hdr(skb)->tos;
-	daddr = ipc.addr = rt->rt_src;
+	daddr = ipc.addr = ip_hdr(skb)->saddr;
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
 	if (icmp_param->replyopts.opt.opt.optlen) {
@@ -930,12 +930,12 @@ static void icmp_address_reply(struct sk_buff *skb)
 		BUG_ON(mp == NULL);
 		for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
 			if (*mp == ifa->ifa_mask &&
-			    inet_ifa_match(rt->rt_src, ifa))
+			    inet_ifa_match(ip_hdr(skb)->saddr, ifa))
 				break;
 		}
 		if (!ifa && net_ratelimit()) {
 			printk(KERN_INFO "Wrong address mask %pI4 from %s/%pI4\n",
-			       mp, dev->name, &rt->rt_src);
+			       mp, dev->name, &ip_hdr(skb)->saddr);
 		}
 	}
 }
-- 
1.7.5.1

