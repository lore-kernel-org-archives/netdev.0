From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: reset ip_summed in skb_tunnel_rx()
Date: Sun, 29 Aug 2010 09:48:44 +0200
Message-ID: <1283068124.2277.230.camel@edumazet-laptop>
References: <20100820193835.GA6025@del.dom.local>
	 <20100821074742.GA2367@del.dom.local>
	 <1282377058.2636.12.camel@edumazet-laptop>
	 <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg>
	 <20100823124736.GA16966@ff.dom.local>
	 <1282568443.2486.34.camel@edumazet-laptop>
	 <20100823131056.GA19160@ff.dom.local> <4C727B06.2060002@fs.uni-ruse.bg>
	 <4C72802D.8090405@fs.uni-ruse.bg> <20100823141437.GA2282@del.dom.local>
	 <4C734FB5.1090702@fs.uni-ruse.bg>
	 <1282626102.2378.1351.camel@edumazet-laptop>
	 <4C738636.4000107@fs.uni-ruse.bg> <4C73C8DF.4060601@fs.uni-ruse.bg>
	 <1282662532.2477.248.camel@edumazet-laptop>
	 <courier.4C74007C.00000EE4@fs.ru.acad.bg>
	 <1282677599.2467.54.camel@edumazet-laptop>
	 <4C74C0C4.5060102@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51605 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab0H2Hst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Aug 2010 03:48:49 -0400
Received: by wwb28 with SMTP id 28so5827884wwb.1
        for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 00:48:48 -0700 (PDT)
In-Reply-To: <4C74C0C4.5060102@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems we forget to reset skb->ip_summed to CHECKSUM_NONE in various
tunnels (gre, ipip, sit, ip6_tunnel), before re-entering stack.

Add ip_summed initialization in skb_tunnel_rx(), and remove it from
ipmr / ip6mr

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
include/net/dst.h |    1 +
net/ipv4/ipmr.c   |    1 -
net/ipv6/ip6mr.c  |    1 -
3 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 81d1413..2ef5580 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -237,6 +237,7 @@ static inline void skb_dst_force(struct sk_buff *skb)
  */
 static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
 {
+	skb->ip_summed = CHECKSUM_NONE;
 	skb->dev = dev;
 	/* TODO : stats should be SMP safe */
 	dev->stats.rx_packets++;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 179fcab..70fa43b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1837,7 +1837,6 @@ static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
 	skb_pull(skb, (u8*)encap - skb->data);
 	skb_reset_network_header(skb);
 	skb->protocol = htons(ETH_P_IP);
-	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
 
 	skb_tunnel_rx(skb, reg_dev);
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 66078da..c4d0146 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -661,7 +661,6 @@ static int pim6_rcv(struct sk_buff *skb)
 	skb_pull(skb, (u8 *)encap - skb->data);
 	skb_reset_network_header(skb);
 	skb->protocol = htons(ETH_P_IPV6);
-	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
 
 	skb_tunnel_rx(skb, reg_dev);



