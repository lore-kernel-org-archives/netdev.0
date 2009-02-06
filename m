From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH] udp: Fix potential wrong ip_hdr(skb) pointers
Date: Fri, 06 Feb 2009 10:55:58 +0100
Message-ID: <1233914158.21135.11.camel@localhost.localdomain>
References: <1233838027.20497.132.camel@localhost.localdomain>
	 <20090205.150612.208352009.davem@davemloft.net>
	 <1233910824.21135.6.camel@localhost.localdomain>
	 <20090206.010824.99072382.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:52475 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbZBFJ4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:56:00 -0500
In-Reply-To: <20090206.010824.99072382.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-02-06 at 01:08 -0800, David Miller wrote:
> Please respin this patch of your's with proper commit message
> and signoffs, thanks!

Like the UDP header fix, pskb_may_pull() can potentially
alter the SKB buffer.  Thus the saddr and daddr, pointers
may point to the old skb->data buffer.

I haven't seen corruptions, as its only seen if the old
skb->data buffer were reallocated by another user and
written into very quickly (or poison'd by SLAB debugging).

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/ipv4/udp.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)


diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cc3a0a0..c47c989 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1234,8 +1234,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	struct udphdr *uh;
 	unsigned short ulen;
 	struct rtable *rt = (struct rtable*)skb->dst;
-	__be32 saddr = ip_hdr(skb)->saddr;
-	__be32 daddr = ip_hdr(skb)->daddr;
+	__be32 saddr, daddr;
 	struct net *net = dev_net(skb->dev);
 
 	/*
@@ -1259,6 +1258,9 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (udp4_csum_init(skb, uh, proto))
 		goto csum_error;
 
+	saddr = ip_hdr(skb)->saddr;
+	daddr = ip_hdr(skb)->daddr;
+
 	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return __udp4_lib_mcast_deliver(net, skb, uh,
 				saddr, daddr, udptable);

