From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 2/3] ip6_output: do skb ufo init for peeked non ufo skb as well
Date: Sat, 19 Oct 2013 12:29:16 +0200
Message-ID: <1382178557-14737-3-git-send-email-jiri@resnulli.us>
References: <1382178557-14737-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	hannes@stressinduktion.org, jdmason@kudzu.us,
	yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:34266 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843Ab3JSK3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 06:29:23 -0400
Received: by mail-ee0-f44.google.com with SMTP id b47so2610787eek.17
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 03:29:22 -0700 (PDT)
In-Reply-To: <1382178557-14737-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now, if user application does:
sendto len<mtu flag MSG_MORE
sendto len>mtu flag 0
The skb is not treated as fragmented one because it is not initialized
that way. So move the initialization to fix this.

introduced by:
commit e89e9cf539a28df7d0eb1d0a545368e9920b34ac "[IPv4/IPv6]: UFO Scatter-gather approach"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv6/ip6_output.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a54c45c..975624b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1008,6 +1008,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 
 {
 	struct sk_buff *skb;
+	struct frag_hdr fhdr;
 	int err;
 
 	/* There is support for UDP large send offload by network
@@ -1015,8 +1016,6 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 	 * udp datagram
 	 */
 	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL) {
-		struct frag_hdr fhdr;
-
 		skb = sock_alloc_send_skb(sk,
 			hh_len + fragheaderlen + transhdrlen + 20,
 			(flags & MSG_DONTWAIT), &err);
@@ -1036,20 +1035,24 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 		skb->transport_header = skb->network_header + fragheaderlen;
 
 		skb->protocol = htons(ETH_P_IPV6);
-		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
 
-		/* Specify the length of each IPv6 datagram fragment.
-		 * It has to be a multiple of 8.
-		 */
-		skb_shinfo(skb)->gso_size = (mtu - fragheaderlen -
-					     sizeof(struct frag_hdr)) & ~7;
-		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
-		ipv6_select_ident(&fhdr, rt);
-		skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
 		__skb_queue_tail(&sk->sk_write_queue, skb);
+	} else if (skb_is_gso(skb)) {
+		goto append;
 	}
 
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	/* Specify the length of each IPv6 datagram fragment.
+	 * It has to be a multiple of 8.
+	 */
+	skb_shinfo(skb)->gso_size = (mtu - fragheaderlen -
+				     sizeof(struct frag_hdr)) & ~7;
+	skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+	ipv6_select_ident(&fhdr, rt);
+	skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
+
+append:
 	return skb_append_datato_frags(sk, skb, getfrag, from,
 				       (length - transhdrlen));
 }
-- 
1.8.3.1
