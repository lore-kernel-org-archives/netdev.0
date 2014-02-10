From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Mon, 10 Feb 2014 13:43:46 +0100
Message-ID: <20140210124346.GA6329@breakpoint.cc>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
 <1390810971-23959-2-git-send-email-fw@strlen.de>
 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140128085706.GB30123@breakpoint.cc>
 <1390926883.28432.12.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140209025504.GB17395@gondor.apana.org.au>
 <20140210122331.GA25153@breakpoint.cc>
 <20140210123124.GA28752@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56066 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751851AbaBJMnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 07:43:49 -0500
Content-Disposition: inline
In-Reply-To: <20140210123124.GA28752@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, Feb 10, 2014 at 01:23:31PM +0100, Florian Westphal wrote:
> > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > > > > static void ip_gso_adjust_seglen(struct sk_buff *skb)
> > > > > {
> > > > >         unsigned int mtu;
> > > > > 
> > > > >         if (!skb_is_gso(skb))
> > > > >                 return;
> > > > > 
> > > > >         mtu = ip_dst_mtu_maybe_forward(skb_dst(skb), true);
> > > > >         skb_shinfo(skb)->gso_size = mtu - sizeof(struct iphdr);
> > > > > }
> > > > > 
> > > > > But this yields
> > > > > 
> > > > > [   28.644776] kernel BUG at net/net/core/skbuff.c:2984!
> > > > 
> > > > Yep, lets CC Herbert Xu, as he 'owns' skb_segment()
> > > 
> > > IMHO we should just stop merging ~DF packets altogether, at least
> > > for TCP.
> > 
> > Eric, you added DF aggregation in db8caf3dbc77599dc90f4ea0a803cd1d97116f30
> > (gro: should aggregate frames without DF).
> > 
> > I guess you don't want to revert this commit?
> > Any other ideas?
> > 
> > skb_gso_segment() is already very complex, I don't want to add more code
> > to it.  And that seems unavoidable if we need to de-couple nr_frags and
> > gso_size.
> 
> I don't think adding all this complexity just to be able to
> aggregate ~DF packets (which are just wrong to begin with) is
> worth it.
> 
> If aggregating ~DF packets was a one-liner then sure, but there
> is a reason why I didn't aggregate them in the first place and
> you've found it :)

Well we could go with my original patch that will do software
segmentation on ~DF packets in the forwarding path if the outmtu is too
small for the individual packets.  The output path then simply
creates fragments.

Eric suggested to shrink gso_size instead to avoid segmentation+fragments.
I think its nice idea, but skb_gso_segment makes certain assumptions about
nr_frags and gso_size (it can't handle frag size > desired mss).

Hannes pointed out that we'd also need to deal with
SKB_MAX_FRAGS * gso_size exceeding fragments.

Quite frankly, I'd prefer to go with

skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);

The scenario is rare anyway given the number of bug reports (or lack
thereof) about '~DF tcp doesn't work with gro in fwd path when output
mtu is too small'.

Its not like this could never be improved later on.

Best regards,
Florian
