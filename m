From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 17:21:19 -0800
Message-ID: <1383787279.2878.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
	 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383783321.2878.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107011337.GD8144@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:54796 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab3KGBVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 20:21:39 -0500
Received: by mail-pb0-f45.google.com with SMTP id ma3so316389pbc.32
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 17:21:39 -0800 (PST)
In-Reply-To: <20131107011337.GD8144@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 02:13 +0100, Hannes Frederic Sowa wrote:
> On Wed, Nov 06, 2013 at 04:15:21PM -0800, Eric Dumazet wrote:
> > On Wed, 2013-11-06 at 11:47 -0800, Eric Dumazet wrote:
> > > I'll try a different way.
> > > 
> > > The frag_list would contain a bunch of frags, that we logically add to the bunch
> > > of frags found in the first skb shared_info structure.
> > 
> > Here is the patch I came into (I tested it and it works very fine)
> > 
> > The theory is that in GRO stack, all skbs use the head_frag trick,
> > so even if one NIC pulled some payload into skb->head, we do not have to
> > copy anything. Outside of GRO stack, we are not supposed to provide data
> > in skb->head (I am speaking of the skb found on the frag_list extension,
> > not the skb_head)
> > 
> > I put a fallback code, just in case, with a WARN_ON_ONCE() so that we
> > can catch the offenders (if any) to fix them.
> > 
> > I renamed @skb to @skb_head to more clearly document this code.
> > Same for @i renamed to @cur_frag
> 
> I wanted to understand this code more closely and tried it with a test case I
> used for the UDP_CORK bugs and also for the tbf panic.
> 
> The packet is allocated as an UFO one and gets segmented by tbf.
> 
> # tc qdisc replace dev eth0 root tbf rate 200kbit latency 20ms burst 5kb
> # ./udptest
> (Just doing two writes of 200 bytes, then a write of 4096 bytes on a udp
> socket. I can send you the source (or a stripped down version, because it got
> realy noisy.))

Interesting :

                       if (cskb == head_skb)
                               cskb = skb_shinfo(head_skb)->frag_list;
                       else
                               cskb = cskb->next;
                       if (!cskb) {
                               WARN_ON_ONCE(1);
                               goto err;
                       }

So here either head_skb->frag_list is NULL, or the frag_list chain finishes too early.

More probably I have a bug in the code ;)

I'll take a look, thanks !
