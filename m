From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need
 also be handled by UFO
Date: Mon, 30 Sep 2013 13:43:43 +0200
Message-ID: <20130930114343.GA6356@minipsycho.brq.redhat.com>
References: <20130921042700.GB8070@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:62932 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004Ab3I3Lnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 07:43:47 -0400
Received: by mail-wg0-f54.google.com with SMTP id m15so5625615wgh.9
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 04:43:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130921042700.GB8070@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Sep 21, 2013 at 06:27:00AM CEST, hannes@stressinduktion.org wrote:
>In the following scenario the socket is corked:
>If the first UDP packet is larger then the mtu we try to append it to the
>write queue via ip6_ufo_append_data. A following packet, which is smaller
>than the mtu would be appended to the already queued up gso-skb via
>plain ip6_append_data. This causes random memory corruptions.
>
>In ip6_ufo_append_data we also have to be careful to not queue up the
>same skb multiple times. So setup the gso frame only when no first skb
>is available.
>
>This also fixes a shortcoming where we add the current packet's length to
>cork->length but return early because of a packet > mtu with dontfrag set
>(instead of sutracting it again).
>
>Found with trinity.
>
>Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>---
>
>I could only test this with virtualized UFO enabled network cards. Could
>someone test this on real hardware?
>
> net/ipv6/ip6_output.c | 53 +++++++++++++++++++++------------------------------
> 1 file changed, 22 insertions(+), 31 deletions(-)
>
>diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
>index 3a692d5..a54c45c 100644
>--- a/net/ipv6/ip6_output.c
>+++ b/net/ipv6/ip6_output.c
>@@ -1015,6 +1015,8 @@ static inline int ip6_ufo_append_data(struct sock *sk,
> 	 * udp datagram
> 	 */
> 	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL) {
>+		struct frag_hdr fhdr;
>+
> 		skb = sock_alloc_send_skb(sk,
> 			hh_len + fragheaderlen + transhdrlen + 20,
> 			(flags & MSG_DONTWAIT), &err);
>@@ -1036,12 +1038,6 @@ static inline int ip6_ufo_append_data(struct sock *sk,
> 		skb->protocol = htons(ETH_P_IPV6);
> 		skb->ip_summed = CHECKSUM_PARTIAL;
> 		skb->csum = 0;
>-	}
>-
>-	err = skb_append_datato_frags(sk,skb, getfrag, from,
>-				      (length - transhdrlen));
>-	if (!err) {
>-		struct frag_hdr fhdr;
> 
> 		/* Specify the length of each IPv6 datagram fragment.
> 		 * It has to be a multiple of 8.
>@@ -1052,15 +1048,10 @@ static inline int ip6_ufo_append_data(struct sock *sk,
> 		ipv6_select_ident(&fhdr, rt);
> 		skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
> 		__skb_queue_tail(&sk->sk_write_queue, skb);
>-
>-		return 0;
> 	}
>-	/* There is not enough support do UPD LSO,
>-	 * so follow normal path
>-	 */
>-	kfree_skb(skb);
> 
>-	return err;
>+	return skb_append_datato_frags(sk, skb, getfrag, from,
>+				       (length - transhdrlen));
> }
> 

What if non-ufo-path-created skb is peeked?
