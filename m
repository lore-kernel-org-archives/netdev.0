From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH V4 4/4] net: No dst refcounting in ip_queue_xmit()
Date: Mon, 10 May 2010 23:31:49 +0200
Message-ID: <1273527109.10889.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:37908 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab0EJVb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 17:31:56 -0400
Received: by wwa36 with SMTP id 36so1963733wwa.19
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 14:31:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP outgoing packets can avoid two atomic ops, and dirtying
of previously higly contended cache line using new refdst
infrastructure.

Note 1: loopback device excluded because of !IFF_XMIT_DST_RELEASE
Note 2: UDP packets dsts are built before ip_queue_xmit().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
net/ipv4/ip_output.c |    9 +++++++--
1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index f039219..012f1c9 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -318,10 +318,12 @@ int ip_queue_xmit(struct sk_buff *skb)
 	struct ip_options *opt = inet->opt;
 	struct rtable *rt;
 	struct iphdr *iph;
+	int res;
 
 	/* Skip all of this if the packet is already routed,
 	 * f.e. by something like SCTP.
 	 */
+	rcu_read_lock();
 	rt = skb_rtable(skb);
 	if (rt != NULL)
 		goto packet_routed;
@@ -359,7 +361,7 @@ int ip_queue_xmit(struct sk_buff *skb)
 		}
 		sk_setup_caps(sk, &rt->u.dst);
 	}
-	skb_dst_set(skb, dst_clone(&rt->u.dst));
+	skb_dst_set_noref(skb, &rt->u.dst);
 
 packet_routed:
 	if (opt && opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
@@ -391,9 +393,12 @@ packet_routed:
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
-	return ip_local_out(skb);
+	res = ip_local_out(skb);
+	rcu_read_unlock();
+	return res;
 
 no_route:
+	rcu_read_unlock();
 	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
 	return -EHOSTUNREACH;



