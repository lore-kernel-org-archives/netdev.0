From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] udp: consistently apply ufo or fragmentation
Date: Thu, 10 Aug 2017 12:29:19 -0400
Message-ID: <20170810162919.50577-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, andreyknvl@gmail.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36638 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752283AbdHJQ3a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 12:29:30 -0400
Received: by mail-qt0-f193.google.com with SMTP id c15so1203384qta.3
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 09:29:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

When iteratively building a UDP datagram with MSG_MORE and that
datagram exceeds MTU, consistently choose UFO or fragmentation.

Once skb_is_gso, always apply ufo. Conversely, once a datagram is
split across multiple skbs, do not consider ufo.

Sendpage already maintains the first invariant, only add the second.
IPv6 does not have a sendpage implementation to modify.

A gso skb must have a partial checksum, do not follow sk_no_check_tx
in udp_send_skb.

Found by syzkaller.

Fixes: e89e9cf539a2 ("[IPv4/IPv6]: UFO Scatter-gather approach")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/ip_output.c  | 8 +++++---
 net/ipv4/udp.c        | 2 +-
 net/ipv6/ip6_output.c | 7 ++++---
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 50c74cd890bc..e153c40c2436 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -965,11 +965,12 @@ static int __ip_append_data(struct sock *sk,
 		csummode = CHECKSUM_PARTIAL;
 
 	cork->length += length;
-	if ((((length + (skb ? skb->len : fragheaderlen)) > mtu) ||
-	     (skb && skb_is_gso(skb))) &&
+	if ((skb && skb_is_gso(skb)) ||
+	    (((length + (skb ? skb->len : fragheaderlen)) > mtu) &&
+	    (skb_queue_len(queue) <= 1) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO) && !dst_xfrm(&rt->dst) &&
-	    (sk->sk_type == SOCK_DGRAM) && !sk->sk_no_check_tx) {
+	    (sk->sk_type == SOCK_DGRAM) && !sk->sk_no_check_tx)) {
 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
 					 hh_len, fragheaderlen, transhdrlen,
 					 maxfraglen, flags);
@@ -1288,6 +1289,7 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 		return -EINVAL;
 
 	if ((size + skb->len > mtu) &&
+	    (skb_queue_len(&sk->sk_write_queue) == 1) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO)) {
 		if (skb->ip_summed != CHECKSUM_PARTIAL)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e6276fa3750b..a7c804f73990 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -802,7 +802,7 @@ static int udp_send_skb(struct sk_buff *skb, struct flowi4 *fl4)
 	if (is_udplite)  				 /*     UDP-Lite      */
 		csum = udplite_csum(skb);
 
-	else if (sk->sk_no_check_tx) {   /* UDP csum disabled */
+	else if (sk->sk_no_check_tx && !skb_is_gso(skb)) {   /* UDP csum off */
 
 		skb->ip_summed = CHECKSUM_NONE;
 		goto send;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 162efba0d0cd..2dfe50d8d609 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1381,11 +1381,12 @@ static int __ip6_append_data(struct sock *sk,
 	 */
 
 	cork->length += length;
-	if ((((length + (skb ? skb->len : headersize)) > mtu) ||
-	     (skb && skb_is_gso(skb))) &&
+	if ((skb && skb_is_gso(skb)) ||
+	    (((length + (skb ? skb->len : headersize)) > mtu) &&
+	    (skb_queue_len(queue) <= 1) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO) && !dst_xfrm(&rt->dst) &&
-	    (sk->sk_type == SOCK_DGRAM) && !udp_get_no_check6_tx(sk)) {
+	    (sk->sk_type == SOCK_DGRAM) && !udp_get_no_check6_tx(sk))) {
 		err = ip6_ufo_append_data(sk, queue, getfrag, from, length,
 					  hh_len, fragheaderlen, exthdrlen,
 					  transhdrlen, mtu, flags, fl6);
-- 
2.14.0.434.g98096fd7a8-goog
