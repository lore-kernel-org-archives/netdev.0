From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need
 also be handled by UFO
Date: Tue, 1 Oct 2013 12:58:37 +0200
Message-ID: <20131001105837.GA1424@minipsycho.brq.redhat.com>
References: <20130921042700.GB8070@order.stressinduktion.org>
 <20130930114343.GA6356@minipsycho.brq.redhat.com>
 <20130930172312.GE10771@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:43182 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394Ab3JAK6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 06:58:42 -0400
Received: by mail-wi0-f169.google.com with SMTP id hj3so5067488wib.0
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 03:58:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130930172312.GE10771@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> 
>> What if non-ufo-path-created skb is peeked?
>
>You mean like:
>first append a frame < mtu
>second frame > mtu so it gets handles by ip6_ufo_append?
>
>Currently I don't see a problem with it but I may be wrong. What is
>your suspicion?

Well the skb will have gso_size==0 and ip_summed==CHECKSUM_NONE
Because of that it will be not threated as ufo skb.

Following patch fixes it:

Subject: [patch net] ip6_output: do skb ufo init for peeked non ufo skb as well

Now, if user application does:
sendto len<mtu flag MSG_MORE
sendto len>mtu flag 0
The skb is not treated as fragmented one because it is not initialized
that way. So move the initialization to fix this.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv6/ip6_output.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a54c45c..c6cfa2f 100644
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
@@ -1036,20 +1035,23 @@ static inline int ip6_ufo_append_data(struct sock *sk,
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
-	}
+	} else if (skb_is_gso(skb))
+		goto append;
+
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	/* Specify the length of each IPv6 datagram fragment.
+	 * It has to be a multiple of 8.
+	 */
+	skb_shinfo(skb)->gso_size = (mtu - fragheaderlen -
+				     sizeof(struct frag_hdr)) & ~7;
+	skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+	ipv6_select_ident(&fhdr, rt);
+	skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
 
+append:
 	return skb_append_datato_frags(sk, skb, getfrag, from,
 				       (length - transhdrlen));
 }
-- 
1.8.3.1
