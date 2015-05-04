From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH V2 -next 0/5] don't exceed original maximum fragment size
 when refragmenting
Date: Tue, 5 May 2015 01:48:14 +0200
Message-ID: <20150504234814.GC17061@breakpoint.cc>
References: <1430772888-5682-1-git-send-email-fw@strlen.de>
 <20150504.192925.1995874259134884815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, hannes@stressinduktion.org,
	jesse@nicira.com, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47532 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751277AbbEDXsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 19:48:18 -0400
Content-Disposition: inline
In-Reply-To: <20150504.192925.1995874259134884815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> > #2 keep fragments attached to reassembled
> > 
> > The idea is to attach the original skbs to the reassembled one, so the
> > networking stack can choose which ones to use depending on the use
> > case. Forwarding would operate on the original ones while code dealing
> > with PACKET_HOST frames would use the reassembled one.
> > 
> > 	- We have the overhead to carry more skbs around, which we
> >           currently don't do.
> 
> I disagree.  It is much more cheaper to save around a chain of smaller
> than PAGE_SIZE SKB fragments, than have to allocate multi-order linear
> SKB to hold the whole thing.
> 
> Furthermore, the allocation of the incoming SKB fragments has by
> definition _ALREADY_ suceeded.  Therefore it is more likely to result
> in successful passing of the frames through the host.

Sorry, but I am very confused.

The existing ipv4 defrag engine that we have attempts to use the
frag_list, we just don't push the individual skbs though and rather
the 'refragmented' one which will be non-linear and refer to the data
area of the fragments instead of realloactions etc.

Its just that this will 'normalize' the fragments to eliminate overlaps.
It also destroys arrival ordering (timing) because we need to put it
into correct 'logical' order.

> All of these overlapping frag etc. issues are just details, and I am
> still not convinced these cannot be handled properly.  Please try
> harder.
> 
> > 	- This information cannot be stored in any of the currently
> >           available fields in the skb or shared_info. That said, a new
> >           pointer would be necessary in every skb, independently if it
> >           is fragmented or not. This change does impact fast path and
> >           skb size.
> 
> You could use the existing frag_list, or make a new member (but not
> in sk_buff, but rather in the shinfo).
> 
> Just imposing a size limit does not preserve the geometry.

Yes, but there is no functionality loss. Nevertheless, patch #4
will preserve geometry for all fragments (discarding overlaps),
provided that no packet linearization took place (or any other
operation that destroys frag lists).

[ I am refering to http://patchwork.ozlabs.org/patch/467834/ ]

Is that not sufficient, i.e. what functionality is missing/which
property needs to be preserved?
Do you want arrival ordering, overlaps etc. to be kept?

Thank you.
