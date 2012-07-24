From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: early_demux fixes
Date: Tue, 24 Jul 2012 13:19:31 +0200
Message-ID: <1343128771.2626.11059.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56540 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244Ab2GXLTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 07:19:36 -0400
Received: by bkwj10 with SMTP id j10so6189808bkw.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 04:19:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

1) Remove a non needed pskb_may_pull() in tcp_v4_early_demux()
   and fix a potential bug if skb->head was reallocated
   (iph & th pointers were not reloaded)

TCP stack will pull/check headers anyway.

2) must reload iph in ip_rcv_finish() after early_demux()
 call since skb->head might have changed.

3) skb->dev->ifindex can be now replaced by skb->skb_iif

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_input.c |    5 ++++-
 net/ipv4/tcp_ipv4.c |    9 ++-------
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 4ebc6fe..93134b0 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -326,8 +326,11 @@ static int ip_rcv_finish(struct sk_buff *skb)
 
 		rcu_read_lock();
 		ipprot = rcu_dereference(inet_protos[protocol]);
-		if (ipprot && ipprot->early_demux)
+		if (ipprot && ipprot->early_demux) {
 			ipprot->early_demux(skb);
+			/* must reload iph, skb->head might have changed */
+			iph = ip_hdr(skb);
+		}
 		rcu_read_unlock();
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3e30548..b6b07c9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1686,7 +1686,6 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	const struct iphdr *iph;
 	const struct tcphdr *th;
-	struct net_device *dev;
 	struct sock *sk;
 
 	if (skb->pkt_type != PACKET_HOST)
@@ -1701,14 +1700,10 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 	if (th->doff < sizeof(struct tcphdr) / 4)
 		return;
 
-	if (!pskb_may_pull(skb, ip_hdrlen(skb) + th->doff * 4))
-		return;
-
-	dev = skb->dev;
 	sk = __inet_lookup_established(net, &tcp_hashinfo,
 				       iph->saddr, th->source,
 				       iph->daddr, ntohs(th->dest),
-				       dev->ifindex);
+				       skb->skb_iif);
 	if (sk) {
 		skb->sk = sk;
 		skb->destructor = sock_edemux;
@@ -1718,7 +1713,7 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 			if (dst)
 				dst = dst_check(dst, 0);
 			if (dst &&
-			    icsk->rx_dst_ifindex == dev->ifindex)
+			    icsk->rx_dst_ifindex == skb->skb_iif)
 				skb_dst_set_noref(skb, dst);
 		}
 	}
