From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] udp: ipv4: fix potential use after free in
 udp_v4_early_demux()
Date: Wed, 11 Dec 2013 08:10:05 -0800
Message-ID: <1386778205.30495.374.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131211003948.GA18825@redhat.com>
	 <1386723287.30495.352.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386727643.30495.363.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:61275 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945Ab3LKQKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 11:10:07 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so9757494pdj.31
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 08:10:07 -0800 (PST)
In-Reply-To: <1386727643.30495.363.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

pskb_may_pull() can reallocate skb->head, we need to move the
initialization of iph and uh pointers after its call.

Fixes: 421b3885bf6d ("udp: ipv4: Add udp early demux")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
 net/ipv4/udp.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2e2aecbe22c4..16d246a51a02 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1909,17 +1909,20 @@ static struct sock *__udp4_lib_demux_lookup(struct net *net,
 
 void udp_v4_early_demux(struct sk_buff *skb)
 {
-	const struct iphdr *iph = ip_hdr(skb);
-	const struct udphdr *uh = udp_hdr(skb);
+	struct net *net = dev_net(skb->dev);
+	const struct iphdr *iph;
+	const struct udphdr *uh;
 	struct sock *sk;
 	struct dst_entry *dst;
-	struct net *net = dev_net(skb->dev);
 	int dif = skb->dev->ifindex;
 
 	/* validate the packet */
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + sizeof(struct udphdr)))
 		return;
 
+	iph = ip_hdr(skb);
+	uh = udp_hdr(skb);
+
 	if (skb->pkt_type == PACKET_BROADCAST ||
 	    skb->pkt_type == PACKET_MULTICAST)
 		sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
