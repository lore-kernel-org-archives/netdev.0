From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH] Fix UDP short packet false positive
Date: Thu, 05 Feb 2009 13:47:07 +0100
Message-ID: <1233838027.20497.132.camel@localhost.localdomain>
References: <1233668300.20497.49.camel@localhost.localdomain>
	 <20090203.153853.163818774.davem@davemloft.net>
	 <1233737704.20497.70.camel@localhost.localdomain>
	 <20090204.010029.12969718.davem@davemloft.net>
	 <1233837840.20497.129.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:58692 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbZBEMrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 07:47:09 -0500
In-Reply-To: <1233837840.20497.129.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The UDP header pointer assignment must happen after calling
pskb_may_pull().  As pskb_may_pull() can potentially alter the SKB
buffer.

This was exposted by running multicast traffic through the NIU driver,
as it won't prepull the protocol headers into the linear area on
receive.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/ipv4/udp.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)


diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1ab180b..cc3a0a0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1231,7 +1231,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		   int proto)
 {
 	struct sock *sk;
-	struct udphdr *uh = udp_hdr(skb);
+	struct udphdr *uh;
 	unsigned short ulen;
 	struct rtable *rt = (struct rtable*)skb->dst;
 	__be32 saddr = ip_hdr(skb)->saddr;
@@ -1244,6 +1244,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
 		goto drop;		/* No space for header. */
 
+	uh   = udp_hdr(skb);
 	ulen = ntohs(uh->len);
 	if (ulen > skb->len)
 		goto short_packet;

