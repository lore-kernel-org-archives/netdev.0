From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need
 also be handled by UFO
Date: Wed, 2 Oct 2013 10:58:42 +0200
Message-ID: <20131002085842.GA1528@minipsycho.brq.redhat.com>
References: <20130921042700.GB8070@order.stressinduktion.org>
 <20130930114343.GA6356@minipsycho.brq.redhat.com>
 <20130930172312.GE10771@order.stressinduktion.org>
 <20131001105837.GA1424@minipsycho.brq.redhat.com>
 <20131001120907.GH10771@order.stressinduktion.org>
 <20131001123214.GI10771@order.stressinduktion.org>
 <20131001214721.GJ10771@order.stressinduktion.org>
 <20131001232534.GM10771@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:61582 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895Ab3JBI6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 04:58:45 -0400
Received: by mail-wi0-f171.google.com with SMTP id hm2so6899078wib.16
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 01:58:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20131001232534.GM10771@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 02, 2013 at 01:25:34AM CEST, hannes@stressinduktion.org wrote:
>On Tue, Oct 01, 2013 at 11:47:21PM +0200, Hannes Frederic Sowa wrote:
>> The strange thing is that if I don't do the IPV6_MTU setsockopt I don't
>> get an oops.
>
>This is incorrect, it just depends on the size of the writes and on the
>interface mtu.
>
>> IPv4 seems to work without problems, too.
>
>I also get kernel oopses from IPv4 now, too.
>
>
>So, skb_is_gso is not accurate enough in the output and we have to check if we
>already started to append to skb frags. The following diff does resolve this
>issue in both the IPv4 and IPv6 non-page-append output path but I am not
>confident if it is correct:
>
>diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>index 6d56840..3565450 100644
>--- a/include/linux/skbuff.h
>+++ b/include/linux/skbuff.h
>@@ -1308,6 +1308,11 @@ static inline int skb_pagelen(const struct sk_buff *skb)
> 	return len + skb_headlen(skb);
> }
> 
>+static inline bool skb_has_frags(const struct sk_buff *skb)
>+{
>+	return skb_shinfo(skb)->nr_frags;
>+}
>+
> /**
>  * __skb_fill_page_desc - initialise a paged fragment in an skb
>  * @skb: buffer containing fragment to be initialised
>diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
>index 7d8357b..8dc3d8d 100644
>--- a/net/ipv4/ip_output.c
>+++ b/net/ipv4/ip_output.c
>@@ -836,7 +836,7 @@ static int __ip_append_data(struct sock *sk,
> 		csummode = CHECKSUM_PARTIAL;
> 
> 	cork->length += length;
>-	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
>+	if (((length > mtu) || (skb && skb_has_frags(skb))) &&
> 	    (sk->sk_protocol == IPPROTO_UDP) &&
> 	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len) {
> 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
>diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
>index a54c45c..ded4f6f 100644
>--- a/net/ipv6/ip6_output.c
>+++ b/net/ipv6/ip6_output.c
>@@ -1227,7 +1227,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
> 	skb = skb_peek_tail(&sk->sk_write_queue);
> 	cork->length += length;
> 	if (((length > mtu) ||
>-	     (skb && skb_is_gso(skb))) &&
>+	     (skb && skb_has_frags(skb))) &&
> 	    (sk->sk_protocol == IPPROTO_UDP) &&
> 	    (rt->dst.dev->features & NETIF_F_UFO)) {
> 		err = ip6_ufo_append_data(sk, getfrag, from, length,
>
>Greetings,
>
>  Hannes
>


This seems correct to me. sk_is_gso would work as well is you apply my
patch "[patch net] ip6_output: do skb ufo init for peeked non ufo skb as
well" which does the setting of gso_size.

Jiri
