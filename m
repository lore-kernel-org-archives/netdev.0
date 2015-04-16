From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Thu, 16 Apr 2015 06:42:34 +0100
Message-ID: <20150416054233.GB3285@acer.localdomain>
References: <20150413.135348.461869719021663434.davem@davemloft.net>
 <20150416045622.GA12454@gondor.apana.org.au>
 <20150416052357.GA3285@acer.localdomain>
 <20150416052904.GA12648@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64539 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbbDPFmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 01:42:39 -0400
Content-Disposition: inline
In-Reply-To: <20150416052904.GA12648@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.04, Herbert Xu wrote:
> On Thu, Apr 16, 2015 at 06:24:00AM +0100, Patrick McHardy wrote:
> >
> > Netfilter may change the contents of the packet, even change its size.
> > It is *really* hard to do this while keeping the original fragments
> > intact.
> 
> Perhaps we should provide better helpers to facilitate this?
> 
> So instead of directly manipulating the content of the skb you
> would so so through helpers and the helpers can then try to do
> sensible things with the fragments.

Yeah, but its going to get pretty complicated. There can be multiple
size changes and modifications for every packet, so we would need to
keep track of the size modifications that have already occured to
map to the correct position in the frag_list. The modifications
would then have to be performed on both the reassembled skb since
they might again be matched against later on and on the frag_list,
potentially split over multiple skbs.

When enlarging the packet, I guess we would insert a new (small)
fragment to keep the geometry of the original fragments. In extreme
cases like H.323 NAT this might result in a huge amount of new very
small fragments. And it might still break the geometry when the
size difference isn't representable as a multiple of 8.

When reducing the skb size, we might have to choice but to change
the geometry of at least on fragment and would have to shift a lot
of data around.

This is very complicated, it we really want to do this, its a lot
easier to just keep note of the full original geometry and refragment
to those exact sizes while potentially adding or removing things
at the end.

My personal opinion is, why bother. The only thing that cares about
the fragment sizes is PMTUD, and that's what this patch is fixing in
a much simpler fashion.
