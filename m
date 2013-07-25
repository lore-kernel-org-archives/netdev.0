From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: minimum ICMPv6 message size vs. RPL's DIS
Date: Thu, 25 Jul 2013 08:17:31 +0200
Message-ID: <20130725061731.GA12365@order.stressinduktion.org>
References: <20130724232852.GA29572@ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:38214 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab3GYGRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 02:17:33 -0400
Content-Disposition: inline
In-Reply-To: <20130724232852.GA29572@ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 24, 2013 at 08:28:52PM -0300, Werner Almesberger wrote:
> The kernel assumes that any valid ICMPv6 message is at least eight
> bytes long, for example in net/ipv6/raw.c:icmpv6_filter
> 
> The DIS message of RPL (RFC 6550 section 6.2, from the 6LoWPAN
> world), has a minimum length of six bytes, and is thus blocked by
> icmpv6_filter.
> 
> Contiki OS sends this sort of messages and is thus ignored by an
> user-space RPL application on Linux (in my case simpleRPL). Nodes
> will eventually join the network regardless, but this can take
> hours instead of seconds.
>  
> RFC 4443 seems to allow even a zero-sized body, making the minimum
> allowable size four bytes.
> 
> A similar restriction exists in net/ipv6/icmp.c:icmpv6_rcv but
> causes no harm there since all potential recipients at that point
> expect a larger payload.
> 
> Now, while this is easy enough to fix on the Linux side (see
> below), I wonder if it is really a Linux bug or if I (and the
> authors of RPL in Contiki) may have missed some minimum size
> requirement for ICMPv6 messages stated elsewhere.
> 
> Opinions ?

Browsing the RFCs, I do think you are correct. Did you check what IPv4 does?
(what a strange errata to RFC 4443...)

> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
> index c45f7a5..539534c 100644
> --- a/net/ipv6/raw.c
> +++ b/net/ipv6/raw.c
> @@ -112,7 +112,7 @@ static int icmpv6_filter(const struct sock *sk, const struct sk_buff *skb)
>  	const struct icmp6hdr *hdr;
>  
>  	hdr = skb_header_pointer(skb, skb_transport_offset(skb),
> -				 sizeof(_hdr), &_hdr);
> +				 4, &_hdr);
>  	if (hdr) {
>  		const __u32 *data = &raw6_sk(sk)->filter.data[0];
>  		unsigned int type = hdr->icmp6_type;

Hmm, maybe we should update the icmp header to something like

struct icmp6hdr {
	struct icmp6hdr_head {
		__u8 icmp6_type;
		...;
	} icmpv6_head;
#define icmp6_type icmpv6_head.icmp6_type

and just change the type in icmpv6_filter to icmp6hdr_head.

Hmm, there is a bug in this function, _hdr must not be a pointer.

Greetings,

  Hannes
