From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [RFC] [PATCH] Fix UDP short packet false positive
Date: Fri, 06 Feb 2009 10:00:24 +0100
Message-ID: <1233910824.21135.6.camel@localhost.localdomain>
References: <20090204.010029.12969718.davem@davemloft.net>
	 <1233837840.20497.129.camel@localhost.localdomain>
	 <1233838027.20497.132.camel@localhost.localdomain>
	 <20090205.150612.208352009.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:50605 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbZBFJAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:00:30 -0500
In-Reply-To: <20090205.150612.208352009.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-02-05 at 15:06 -0800, David Miller wrote:
> From: Jesper Dangaard Brouer <jdb@comx.dk>
> Date: Thu, 05 Feb 2009 13:47:07 +0100
>
> > The UDP header pointer assignment must happen after calling
> > pskb_may_pull().  As pskb_may_pull() can potentially alter the SKB
> > buffer.
>
> Excellent work!

Thanks :-)

I'm wondering if the ip_hdr() pointer can be changed by the
pskb_may_pull(), but I assume it cannot as it should already be in the
linear area... right?

Well the patch below, shows what I mean...

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cc3a0a0..7390af6 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1232,20 +1232,23 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 {
 	struct sock *sk;
 	struct udphdr *uh;
 	unsigned short ulen;
 	struct rtable *rt = (struct rtable*)skb->dst;
-	__be32 saddr = ip_hdr(skb)->saddr;
-	__be32 daddr = ip_hdr(skb)->daddr;
+	__be32 saddr;
+	__be32 daddr;
 	struct net *net = dev_net(skb->dev);
 
 	/*
 	 *  Validate the packet.
 	 */
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
 		goto drop;		/* No space for header. */
 
+	saddr = ip_hdr(skb)->saddr;
+	daddr = ip_hdr(skb)->daddr;
+
 	uh   = udp_hdr(skb);
 	ulen = ntohs(uh->len);
 	if (ulen > skb->len)
 		goto short_packet;
 


-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
