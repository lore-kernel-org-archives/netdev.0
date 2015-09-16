From: Florian Westphal <fw@strlen.de>
Subject: Re: IPv6 routing/fragmentation panic
Date: Wed, 16 Sep 2015 17:30:56 +0200
Message-ID: <20150916153056.GR24810@breakpoint.cc>
References: <1442332400.131189.21.camel@infradead.org>
 <20150915234848.GO24810@breakpoint.cc>
 <1442398145.131189.46.camel@infradead.org>
 <20150916132733.GQ24810@breakpoint.cc>
 <1442412054.131189.97.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	johannes@sipsolutions.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39087 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752326AbbIPPa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 11:30:58 -0400
Content-Disposition: inline
In-Reply-To: <1442412054.131189.97.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> wrote:
> >                         if (frag->len > mtu ||
> >                             ((frag->len & 7) && frag->next) ||
> > -                           skb_headroom(frag) < hlen)
> > +                           skb_headroom(frag) < (hlen + hroom))
> >                                 goto slow_path_clean;
> >  
> >                         /* Partially cloned skb? */
> 
> My test is 'ping -s 2000', and I end up with a fragment of 1280 bytes
> followed by a fragment of 776 bytes.
> 
> The test cited above is only actually running on the latter fragment
> (which for some reason is fine and has headroom of 58 bytes).
> 
> The first, larger, fragment isn't being checked. And that's the one
> with only 10 bytes of headroom.

Thanks for this detailed analysis.
I've sent a patch that should address all of these issues.

Turns out that all tests are wrong in your case.

ip6_fragment doesn't expand headroom, since this skb had the ipv6
fragment header pulled, so that part thinks there are 18 bytes
available (we later push the frag header back when sending fragments).

The 'skb_headroom(frag) < hlen))' is wrong since it neither accounts for
device header length nor the fragment header that we need to push.
