From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen/netfront: do not mark packets of length < MSS as
	GSO
Date: Wed, 14 Jan 2009 10:59:12 +0000
Message-ID: <1231930752.4078.18.camel@zakaz.uk.xensource.com>
References: <20090114041845.GA8881@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, jeremy@goop.org,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45539 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755277AbZANK7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 05:59:44 -0500
In-Reply-To: <20090114041845.GA8881@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 15:18 +1100, Herbert Xu wrote:
> Ian Campbell <Ian.Campbell@citrix.com> wrote:
> > Linux assumes that skbs marked for GSO are longer than MSS. In
> > particular tcp_tso_segment assumes that skb_segment will return a
> > chain of at least 2 skbs.
> > 
> > Therefore netfront should not pass such a packet up the stack.
> > 
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> > Cc: jgarzik@pobox.com
> > Cc: netdev@vger.kernel.org
> 
> Great catch!
> 
> But we should fix this in the stack instead.
> 
> gso: Ensure that the packet is long enough
> 
> When we get a GSO packet from an untrusted source, we need to
> ensure that it is sufficiently long so that we don't end up
> crashing.
> 
> Based on discovery and patch by Ian Campbell.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good, thanks.

Tested-by: Ian Campbell <ian.campbell@citrix.com>

> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index bd6ff90..12e56ec 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2383,7 +2383,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
>  	unsigned int seq;
>  	__be32 delta;
>  	unsigned int oldlen;
> -	unsigned int len;
> +	unsigned int mss;
>  
>  	if (!pskb_may_pull(skb, sizeof(*th)))
>  		goto out;
> @@ -2399,10 +2399,13 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
>  	oldlen = (u16)~skb->len;
>  	__skb_pull(skb, thlen);
>  
> +	mss = skb_shinfo(skb)->gso_size;
> +	if (unlikely(skb->len <= mss))
> +		goto out;
> +
>  	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
>  		/* Packet is from an untrusted source, reset gso_segs. */
>  		int type = skb_shinfo(skb)->gso_type;
> -		int mss;
>  
>  		if (unlikely(type &
>  			     ~(SKB_GSO_TCPV4 |
> @@ -2413,7 +2416,6 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
>  			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
>  			goto out;
>  
> -		mss = skb_shinfo(skb)->gso_size;
>  		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
>  
>  		segs = NULL;
> @@ -2424,8 +2426,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
>  	if (IS_ERR(segs))
>  		goto out;
>  
> -	len = skb_shinfo(skb)->gso_size;
> -	delta = htonl(oldlen + (thlen + len));
> +	delta = htonl(oldlen + (thlen + mss));
>  
>  	skb = segs;
>  	th = tcp_hdr(skb);
> @@ -2441,7 +2442,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
>  			     csum_fold(csum_partial(skb_transport_header(skb),
>  						    thlen, skb->csum));
>  
> -		seq += len;
> +		seq += mss;
>  		skb = skb->next;
>  		th = tcp_hdr(skb);
>  
> 
> Thanks,

