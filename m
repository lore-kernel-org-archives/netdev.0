From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_v4_early_demux() fixes
Date: Tue, 24 Jul 2012 12:42:35 +0200
Message-ID: <1343126555.2626.11053.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33033 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989Ab2GXKmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 06:42:40 -0400
Received: by bkwj10 with SMTP id j10so6159193bkw.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 03:42:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

1) Remove a non needed pskb_may_pull() and fix a potential bug
if skb->head was reallocated (iph & th pointers were not reloaded)

TCP stack will pull/check headers anyway.

2) skb->dev->ifindex can be now replaced by skb->skb_iif

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

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
