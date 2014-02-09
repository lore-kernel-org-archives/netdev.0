From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Sun, 9 Feb 2014 10:55:04 +0800
Message-ID: <20140209025504.GB17395@gondor.apana.org.au>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
 <1390810971-23959-2-git-send-email-fw@strlen.de>
 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140128085706.GB30123@breakpoint.cc>
 <1390926883.28432.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:48154 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbaBICzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Feb 2014 21:55:09 -0500
Content-Disposition: inline
In-Reply-To: <1390926883.28432.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 28, 2014 at 08:34:43AM -0800, Eric Dumazet wrote:
> On Tue, 2014-01-28 at 09:57 +0100, Florian Westphal wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > > +	do {
> > > > +		struct sk_buff *nskb = segs->next;
> > > > +		int err;
> > > > +
> > > > +		segs->next = NULL;
> > > > +		err = dst_output(segs);
> > > > +
> > > > +		if (err && ret == 0)
> > > > +			ret = err;
> > > > +		segs = nskb;
> > > > +	} while (segs);
> > > > +
> > > > +	return ret;
> > > > +}
> > > > +
> > > 
> > > Its still unclear if this is the best strategy.
> > > 
> > > TCP stream not using DF flag are very unlikely to care if we adjust
> > > their MTU (lowering gso_size) at this point ?
> > 
> > Thanks for this suggestion.  It would indeed be nice to avoid sw
> > segmentation.  I tried:
> > 
> > static void ip_gso_adjust_seglen(struct sk_buff *skb)
> > {
> >         unsigned int mtu;
> > 
> >         if (!skb_is_gso(skb))
> >                 return;
> > 
> >         mtu = ip_dst_mtu_maybe_forward(skb_dst(skb), true);
> >         skb_shinfo(skb)->gso_size = mtu - sizeof(struct iphdr);
> > }
> > 
> > But this yields
> > 
> > [   28.644776] kernel BUG at net/net/core/skbuff.c:2984!
> 
> Yep, lets CC Herbert Xu, as he 'owns' skb_segment()

IMHO we should just stop merging ~DF packets altogether, at least
for TCP.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
