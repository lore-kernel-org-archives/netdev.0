From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Fri, 19 Jan 2007 15:32:28 +0100
Message-ID: <20070119143228.GB3424@ff.dom.local>
References: <20070119110641.GA3135@ff.dom.local> <45B0B63C.3080201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Tokarev <mjt@tls.msk.ru>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:34818 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965040AbXASOaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 09:30:15 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <45B0B63C.3080201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 19, 2007 at 01:14:52PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > Here is my patch proposal. If I'm not totally wrong,
> > there is a possibility that, during collapsing, empty
> > skb with FIN is added to "normal" packet and changes
> > its ip_summed field to CHECKSUM_NONE.
> > 
> > diff -Nurp linux-2.6.19-/net/ipv4/tcp_output.c linux-2.6.19/net/ipv4/tcp_output.c
> > --- linux-2.6.19-/net/ipv4/tcp_output.c	2006-11-29 22:57:37.000000000 +0100
> > +++ linux-2.6.19/net/ipv4/tcp_output.c	2007-01-19 07:58:39.000000000 +0100
> > @@ -1590,7 +1590,8 @@ static void tcp_retrans_try_collapse(str
> >  
> >  		memcpy(skb_put(skb, next_skb_size), next_skb->data, next_skb_size);
> >  
> > -		skb->ip_summed = next_skb->ip_summed;
> > +		if (next_skb->ip_summed == CHECKSUM_PARTIAL)
> > +			skb->ip_summed = CHECKSUM_PARTIAL;
> >  
> >  		if (skb->ip_summed != CHECKSUM_PARTIAL)
> >  			skb->csum = csum_block_add(skb->csum, next_skb->csum, skb_size);
> > 
> 
> I noticed this too, but I can't see how it could lead to
> a partial checksum on the wire since the checksumming is
> done after changing ip_summed to CHECKSUM_NONE. Is this
> patch verified to fix Michael's problem?

No, this was intended as a proposal for testing.
I didn't verify all the checksum path here, but I
guessed such change during the summing could matter
(probably for skb_copy_and_csum_dev and maybe earlier)
and I couldn't find more suspicious change since 2.6.17
near this FINs. But if it really works, it shoudn't be
so hard to verify the mechanism, I hope.

Jarek P.
