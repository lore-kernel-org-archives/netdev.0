From: Simon Horman <horms@verge.net.au>
Subject: [PATCH net-next v2 5/7] ipv4: Correct comparisons and calculations using skb->tail and skb-transport_header
Date: Wed, 29 May 2013 15:34:27 +0900
Message-ID: <1369809269-13130-6-git-send-email-horms@verge.net.au>
References: <1369809269-13130-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53148 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759494Ab3E2Gdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 02:33:49 -0400
In-Reply-To: <1369809269-13130-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This corrects an regression introduced by "net: Use 16bits for *_headers
fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
that case skb->tail will be a pointer whereas skb->transport_header
will be an offset from head. This is corrected by using wrappers that
ensure that comparisons and calculations are always made using pointers.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/ipv4/icmp.c |    3 ++-
 net/ipv4/igmp.c |    2 +-
 net/ipv4/tcp.c  |    3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 562efd9..5d0d379 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -503,7 +503,8 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	iph = ip_hdr(skb_in);
 
 	if ((u8 *)iph < skb_in->head ||
-	    (skb_in->network_header + sizeof(*iph)) > skb_in->tail)
+	    (skb_network_header(skb_in) + sizeof(*iph)) >
+	    skb_tail_pointer(skb_in))
 		goto out;
 
 	/*
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index d8c2327..450f625 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -363,7 +363,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 static int igmpv3_sendpack(struct sk_buff *skb)
 {
 	struct igmphdr *pig = igmp_hdr(skb);
-	const int igmplen = skb->tail - skb->transport_header;
+	const int igmplen = skb_tail_pointer(skb) - skb_transport_header(skb);
 
 	pig->csum = ip_compute_csum(igmp_hdr(skb), igmplen);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ba4186e..1f58594 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2989,7 +2989,8 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 		swap(gso_skb->truesize, skb->truesize);
 	}
 
-	delta = htonl(oldlen + (skb->tail - skb->transport_header) +
+	delta = htonl(oldlen + (skb_tail_pointer(skb) -
+				skb_transport_header(skb)) +
 		      skb->data_len);
 	th->check = ~csum_fold((__force __wsum)((__force u32)th->check +
 				(__force u32)delta));
-- 
1.7.10.4
