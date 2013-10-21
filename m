From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH stable] inet: fix possible memory corruption with UDP_CORK and UFO
Date: Tue, 22 Oct 2013 00:07:47 +0200
Message-ID: <20131021220747.GC24158@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jiri@resnulli.us, eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49264 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463Ab3JUWHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 18:07:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a replacement patch only for stable which does fix the problems
handled by the following two commits in -net:

"ip_output: do skb ufo init for peeked non ufo skb as well" (e93b7d748be887cd7639b113ba7d7ef792a7efb9)
"ip6_output: do skb ufo init for peeked non ufo skb as well" (c547dbf55d5f8cf615ccc0e7265e98db27d3fb8b)

Three frames are written on a corked udp socket for which the output
netdevice has UFO enabled.  If the first and third frame are smaller than
the mtu and the second one is bigger, we enqueue the second frame with
skb_append_datato_frags without initializing the gso fields. This leads
to the third frame appended regulary and thus constructing an invalid skb.

This fixes the problem by always using skb_append_datato_frags as soon
as the first frag got enqueued to the skb without marking the packet
as SKB_GSO_UDP.

The problem with only two frames for ipv6 was fixed by "ipv6: udp
packets following an UFO enqueued packet need also be handled by UFO"
(2811ebac2521ceac84f2bdae402455baa6a7fb47).

Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/skbuff.h | 5 +++++
 net/ipv4/ip_output.c   | 2 +-
 net/ipv6/ip6_output.c  | 2 +-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c2d8933..eee3d92 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1316,6 +1316,11 @@ static inline int skb_pagelen(const struct sk_buff *skb)
 	return len + skb_headlen(skb);
 }
 
+static inline bool skb_has_frags(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->nr_frags;
+}
+
 /**
  * __skb_fill_page_desc - initialise a paged fragment in an skb
  * @skb: buffer containing fragment to be initialised
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3982eab..13e617f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -841,7 +841,7 @@ static int __ip_append_data(struct sock *sk,
 		csummode = CHECKSUM_PARTIAL;
 
 	cork->length += length;
-	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
+	if (((length > mtu) || (skb && skb_has_frags(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len) {
 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 975624b..65f28be 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1230,7 +1230,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	skb = skb_peek_tail(&sk->sk_write_queue);
 	cork->length += length;
 	if (((length > mtu) ||
-	     (skb && skb_is_gso(skb))) &&
+	     (skb && skb_has_frags(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO)) {
 		err = ip6_ufo_append_data(sk, getfrag, from, length,
-- 
1.8.3.1
