From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/10] ipvs: Eliminate rt->rt_dst usage in
 __ip_vs_get_out_rt().
Date: Mon, 09 May 2011 22:31:20 -0700 (PDT)
Message-ID: <20110509.223120.246536545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53408
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753366Ab1EJFbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 01:31:52 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B970824C087
	for <netdev@vger.kernel.org>; Mon,  9 May 2011 22:31:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We can simply track what destination address is used based upon which
code block is taken at the top of the function.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index c4a19f9..e5ef75b 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -110,6 +110,7 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 				  &dest->addr.ip,
 				  atomic_read(&rt->dst.__refcnt), rtos);
 		}
+		daddr = dest->addr.ip;
 		spin_unlock(&dest->dst_lock);
 	} else {
 		rt = ip_route_output(net, daddr, 0, rtos, 0);
@@ -125,7 +126,7 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 	      rt_mode)) {
 		IP_VS_DBG_RL("Stopping traffic to %s address, dest: %pI4\n",
 			     (rt->rt_flags & RTCF_LOCAL) ?
-			     "local":"non-local", &rt->rt_dst);
+			     "local":"non-local", &daddr);
 		ip_rt_put(rt);
 		return NULL;
 	}
@@ -133,14 +134,14 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 	    !((ort = skb_rtable(skb)) && ort->rt_flags & RTCF_LOCAL)) {
 		IP_VS_DBG_RL("Redirect from non-local address %pI4 to local "
 			     "requires NAT method, dest: %pI4\n",
-			     &ip_hdr(skb)->daddr, &rt->rt_dst);
+			     &ip_hdr(skb)->daddr, &daddr);
 		ip_rt_put(rt);
 		return NULL;
 	}
 	if (unlikely(!local && ipv4_is_loopback(ip_hdr(skb)->saddr))) {
 		IP_VS_DBG_RL("Stopping traffic from loopback address %pI4 "
 			     "to non-local address, dest: %pI4\n",
-			     &ip_hdr(skb)->saddr, &rt->rt_dst);
+			     &ip_hdr(skb)->saddr, &daddr);
 		ip_rt_put(rt);
 		return NULL;
 	}
-- 
1.7.5.1

