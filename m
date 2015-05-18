From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: preserve geometry of fragment sizes when
 forwarding
Date: Tue, 19 May 2015 01:02:55 +0200
Message-ID: <20150518230255.GB2335@breakpoint.cc>
References: <20150518200637.GB20709@breakpoint.cc>
 <20150518.162854.1116793790405432801.davem@davemloft.net>
 <20150518204049.GC20709@breakpoint.cc>
 <20150518.165550.359134808190719687.davem@davemloft.net>
 <20150518213329.GA2335@breakpoint.cc>
 <20150518225043.GA25702@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hannes@stressinduktion.org, edumazet@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54958 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752302AbbERXDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 19:03:00 -0400
Content-Disposition: inline
In-Reply-To: <20150518225043.GA25702@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, May 18, 2015 at 11:33:29PM +0200, Florian Westphal wrote:
> >
> > > Every objection has been of the form "this special case" (this time
> > > SIP) is not easy.
> > 
> > Yes, but these objections are not some random hand-waving gesture.
> > It presents us with certain dilemmas, e.g. single udp packet:
> > 
> > 1280 1280 1280 542
> > 
> > sip nat helper has to do nat/pat and replaces 10.2.3.4 with 192.168.2.3
> > (lets assume we'd have helpers that deal with addresses split over 2
> >  fragmented skbs so we can deal with 10.2 appearing in fragment #2
> >   and .3.4 in fragment #3)
> > 
> > We can then end up with something like
> > 1283 1281 1282 542
> > 
> > ... and what should we do then?
> 
> I think what David is saying that you can apply your special
> logic to these edge cases, e.g., linearise them and on output
> use your MTU cap to refragment.
> 
> However, for the vast majority of fragments that you receive,
> which would not be modified by NAT, they should retain their
> original geometry.

That would be achived by this patch (perhaps altered to coalesce later
in ip stack when we're sure skb is locally delivered rather than doing
it depending on nf_defrag module presence) plus the earlier patches to:

1. track largest fragment size unconditionally in IPCB
2. refragment to at most this size.

This would keep full geometry of all fragments EXCEPT for
edge cases (overlapping fragments, xfrm, nfqueue payload rewrite from
userspace and anything else that destroys frag lists).

For those edge cases, we would rely on the
IPCB information to re-fragment according to the largest original fragment.

For the vast majority, we would just re-frag via the original
skbs from the skb frag list.  The nice thing is that this is transparent to
netfilter (just another non-linear skb) and ip_fragment can even cope with
reduced mtu on output path (when we eg. receive 1400 byte fragments but
packet is routed via outdevice with 1280 byte mtu).

What am I missing?

Thanks.
