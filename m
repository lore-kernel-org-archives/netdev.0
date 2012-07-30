From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: TCP early demux cleanup
Date: Mon, 30 Jul 2012 09:06:13 +0200
Message-ID: <1343631973.2626.13317.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:58509 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714Ab2G3HGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 03:06:18 -0400
Received: by wgbdr13 with SMTP id dr13so4563597wgb.1
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2012 00:06:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

early_demux() handlers should be called in RCU context, and as we
use skb_dst_set_noref(skb, dst), caller must not exit from RCU context
before dst use (skb_dst(skb)) or release (skb_drop(dst))

Therefore, rcu_read_lock()/rcu_read_unlock() pairs around
->early_demux() are confusing and not needed :

Protocol handlers are already in an RCU read lock section.
(__netif_receive_skb() does the rcu_read_lock() )

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_input.c  |    2 --
 net/ipv6/ip6_input.c |    2 --
 2 files changed, 4 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 981ff1e..f1395a6 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -325,14 +325,12 @@ static int ip_rcv_finish(struct sk_buff *skb)
 		const struct net_protocol *ipprot;
 		int protocol = iph->protocol;
 
-		rcu_read_lock();
 		ipprot = rcu_dereference(inet_protos[protocol]);
 		if (ipprot && ipprot->early_demux) {
 			ipprot->early_demux(skb);
 			/* must reload iph, skb->head might have changed */
 			iph = ip_hdr(skb);
 		}
-		rcu_read_unlock();
 	}
 
 	/*
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 47975e3..a52d864 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -52,11 +52,9 @@ int ip6_rcv_finish(struct sk_buff *skb)
 	if (sysctl_ip_early_demux && !skb_dst(skb)) {
 		const struct inet6_protocol *ipprot;
 
-		rcu_read_lock();
 		ipprot = rcu_dereference(inet6_protos[ipv6_hdr(skb)->nexthdr]);
 		if (ipprot && ipprot->early_demux)
 			ipprot->early_demux(skb);
-		rcu_read_unlock();
 	}
 	if (!skb_dst(skb))
 		ip6_route_input(skb);
