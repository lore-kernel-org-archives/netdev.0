From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 6 Nov 2013 21:12:52 +0800
Message-ID: <20131106131252.GA20680@gondor.apana.org.au>
References: <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <20131106013038.GA14894@gondor.apana.org.au>
 <1383702347.4291.152.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106040717.GA15711@gondor.apana.org.au>
 <1383711785.4291.156.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106042858.GA15745@gondor.apana.org.au>
 <1383715222.4291.158.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106080425.GA17556@gondor.apana.org.au>
 <20131106081638.GA17665@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com, mst@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:45458 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756221Ab3KFNNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 08:13:00 -0500
Content-Disposition: inline
In-Reply-To: <20131106081638.GA17665@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 04:16:38PM +0800, Herbert Xu wrote:
>
> I just looked at the aformentioned patch again and it is seriously
> broken! How on earth did it get merged?
> 
> Instead of using perfectly sane 4K pages per frag to store guest to
> guest traffic, we now end up using 1.5K frags, which that's why you
> end up having to use the frag_list, WTF?
> 
> Dave, please revert the above commit as it is seriously broken.

I take that back.  While the original patch was seriously broken,
it has since been fixed by the coalescing patch that Jason Wang
wrote.

It's still pretty weird to be dividing page frags into 1500-byte
chunks and then merging back up to 4K but at least it should do the
right thing now.

With regards to the impact on my skb_segment patch, there should be
none because those packets ultimately are still originating from
either GRO or the TCP stack.  In which case the same assumptions
on frag_list still holds.

However, we do have to guard against evil hosts/guests injecting
bogus packets into our stack, so either we'll have to lose the
BUG_ON in skb_segment or we'll need some sort of a filter in
virtio_net.

Perhaps a rate-limited printk might be the go.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
