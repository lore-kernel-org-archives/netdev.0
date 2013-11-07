From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Thu, 7 Nov 2013 15:17:42 +0800
Message-ID: <20131107071742.GA31901@gondor.apana.org.au>
References: <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <20131106013038.GA14894@gondor.apana.org.au>
 <20131106123900.GA20259@gondor.apana.org.au>
 <20131106133045.GA20931@gondor.apana.org.au>
 <20131106143927.GA21604@gondor.apana.org.au>
 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107004339.GA28156@gondor.apana.org.au>
 <1383808262.9412.33.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107071531.GA31857@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:53989 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751033Ab3KGHRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 02:17:49 -0500
Content-Disposition: inline
In-Reply-To: <20131107071531.GA31857@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 03:15:31PM +0800, Herbert Xu wrote:
> On Wed, Nov 06, 2013 at 11:11:02PM -0800, Eric Dumazet wrote:
> > On Thu, 2013-11-07 at 08:43 +0800, Herbert Xu wrote:
> > 
> > > -		if (fskb != skb_shinfo(skb)->frag_list)
> > > -			goto perform_csum_check;
> > > +		if (fskb != skb_shinfo(skb)->frag_list) {
> > > +			struct sk_buff *nsegs;
> > > +
> > > +			if (nskb->len == len + doffset)
> > > +				goto perform_csum_check;
> > > +
> > > +			if (skb_has_frag_list(nskb)) {
> > > +				net_warn_ratelimited(
> > > +					"skb_segment: "
> > > +					"nested frag_list detected\n");
> > > +				kfree(nskb);
> > > +				err = -EINVAL;
> > > +				goto err;
> > > +			}
> > > +
> > > +			__skb_pull(nskb, doffset);
> > > +			skb_shinfo(nskb)->gso_size = mss;
> > > +			nsegs = skb_segment(nskb, features);
> > > +
> > 
> > This still assumes each skb found in frag_list has a exact multiple of
> > @mss bytes, and that the initial skb also ends at a right boundary.
> 
> So what in our stack violates this assumption? We've never handled
> arbitrary frag_lists in GSO and I see no reason why we need to start
> doing that now.
> 
> Also GRO was designed to only merge packets that satisfy these
> assumptions so that through GSO the original packets can be
> recovered without losing end-to-end connectivity.  This is really
> important for routers/switches.

Or perhaps you are saying that this doesn't handle page frags?
It should because each GRO frag_list entry looks just like any
boring old GSO packet filled with frags.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
