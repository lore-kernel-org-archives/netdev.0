From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [XFRM] Beet: Fix output for ipv6
Date: Thu, 6 Mar 2008 19:08:35 +0800
Message-ID: <20080306110835.GA6802@gondor.apana.org.au>
References: <200802081812.18985.joakim.koskela@hiit.fi> <200802252231.01021.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34643 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753402AbYCFLIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 06:08:40 -0500
Content-Disposition: inline
In-Reply-To: <200802252231.01021.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 25, 2008 at 10:31:00PM +0200, Joakim Koskela wrote:
> Hi Herbert, 
> 
> Have you had a chance to look this, or are you working on something else for 
> it?

Sorry, I've been flat out lately so I missed your patch.

> On Friday 08 February 2008 18:12, Joakim Koskela wrote:
> >
> > This patch fixes the ipv6 mode of ipsec beet. It has been using logic
> > similar to tunnel mode, making it crash during esp packaging.
> >
> > Signed-off-by: Joakim Koskela <jookos@gmail.com>
> > ---
> >  net/ipv6/xfrm6_mode_beet.c |    9 ++++++---
> >  1 files changed, 6 insertions(+), 3 deletions(-)
> >
> > diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
> > index 0527d11..0395800 100644
> > --- a/net/ipv6/xfrm6_mode_beet.c
> > +++ b/net/ipv6/xfrm6_mode_beet.c
> > @@ -40,11 +40,14 @@ static void xfrm6_beet_make_header(struct sk_buff *skb)
> >  static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
> >  {
> >  	struct ipv6hdr *top_iph;
> > +	u8 *prevhdr;
> > +	int hdr_len;
> >
> > +	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
> > +	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
> >  	skb_set_network_header(skb, -x->props.header_len);
> > -	skb->mac_header = skb->network_header +
> > -			  offsetof(struct ipv6hdr, nexthdr);
> > -	skb->transport_header = skb->network_header + sizeof(*top_iph);
> > +	skb->transport_header = skb->network_header + hdr_len;
> > +	__skb_pull(skb, hdr_len);

After a quick a look I have to say that I don't think this is
right.  BEET is supposed to wrap around all extension headers
so we shouldn't call hdr_offset.  In fact the packet could be
IPv4 for all we know.

So why don't you show us the crash that you're experiencing?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
