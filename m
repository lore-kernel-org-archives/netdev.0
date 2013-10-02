From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Neterion and UFO handling [was: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need also be handled by UFO]
Date: Wed, 2 Oct 2013 18:27:30 +0200
Message-ID: <20131002162730.GA3991@order.stressinduktion.org>
References: <20131001105837.GA1424@minipsycho.brq.redhat.com> <20131001120907.GH10771@order.stressinduktion.org> <20131001123214.GI10771@order.stressinduktion.org> <20131001214721.GJ10771@order.stressinduktion.org> <20131001232534.GM10771@order.stressinduktion.org> <20131002085842.GA1528@minipsycho.brq.redhat.com> <1380710488.19002.67.camel@edumazet-glaptop.roam.corp.google.com> <20131002121207.GO10771@order.stressinduktion.org> <20131002130329.GP10771@order.stressinduktion.org> <1380726867.19002.104.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36474 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461Ab3JBQ1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 12:27:32 -0400
Content-Disposition: inline
In-Reply-To: <1380726867.19002.104.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I have a question regarding UFO and the neterion driver, which as the only one
advertises hardware UFO support:

The patch discusses in this thread
http://thread.gmane.org/gmane.linux.network/284348/focus=285405 could change
some semantics how packets are constructed before submitted to the driver.

We currently guarantee that we have the MAC/IP/UDP header in skb->data and the
payload is attached in the skb's frags. With the changes discussed in this
thread it is possible that we also append to skb->data some amount of data
which is not targeted for the header. From reading the driver sources it seems
the hardware interprets the skb->data to skb_headlen as the header, so we
could include some data in the fragments more than once.

Do you think this change is safe? Otherwise I would suggest that the UFO
capability is switched off until the driver signals the hardware the start and
end of the headers correctly?

I left the mail below intact which points to the specific place in s2io.c
where I think the problem is.

On Wed, Oct 02, 2013 at 08:14:27AM -0700, Eric Dumazet wrote:
> On Wed, 2013-10-02 at 15:03 +0200, Hannes Frederic Sowa wrote:
> > On Wed, Oct 02, 2013 at 02:12:07PM +0200, Hannes Frederic Sowa wrote:
> > > Hi Eric!
> > > 
> > > On Wed, Oct 02, 2013 at 03:41:28AM -0700, Eric Dumazet wrote:
> > > > On Wed, 2013-10-02 at 10:58 +0200, Jiri Pirko wrote:
> > > > > Wed, Oct 02, 2013 at 01:25:34AM CEST, hannes@stressinduktion.org wrote:
> > > > > >-	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
> > > > > >+	if (((length > mtu) || (skb && skb_has_frags(skb))) &&
> > > > 
> > > > > 
> > > > > This seems correct to me. sk_is_gso would work as well is you apply my
> > > > > patch "[patch net] ip6_output: do skb ufo init for peeked non ufo skb as
> > > > > well" which does the setting of gso_size.
> > > > 
> > > > Well, skb having frags or not should not be a concern :
> > > > Thats an allocation choice (lets say to avoid high order allocations). 
> > > > 
> > > > Setting gso_size is probably better.
> > > 
> > > e89e9cf539a28df7d0eb1d0a545368e9920b34ac ("[IPv4/IPv6]: UFO Scatter-gather
> > > approach") states:
> > > 
> > > "
> > > skb->data will contain MAC/IP/UDP header and skb_shinfo(skb)->frags[]
> > > contains the data payload. The skb->ip_summed will be set to CHECKSUM_HW
> > > indicating that hardware has to do checksum calculation. Hardware should
> > > compute the UDP checksum of complete datagram and also ip header checksum of
> > > each fragmented IP packet.
> > > "
> > > 
> > > This is the reason why I tried not to update the gso_size. If it is ok, I am
> > > fine with that.
> > 
> > Especially, drivers/net/ethernet/neterion/s2io.c states that the first dma
> > mapping (skb->data with skb_headlen, which is fine) is used as the inband
> > header:
> > 
> >         if (offload_type == SKB_GSO_UDP)
> >                 frg_cnt++; /* as Txd0 was used for inband header */
> > 
> > That is my only other hint that we maybe should not update gso_size and
> > gso_type. I guess software fallback does not have this problem, but I won't
> > have time to check until this evening.
> > 
> > I am really not sure if just setting gso_size does not break neterion UFO
> > offloading. :/
> 
> Well, just ask Jon Mason to double check ;)
> 
> I think the commit intent was to set gso_size :
> 
>    skb_shinfo(skb)->ufo_size will indicate the length of data part in each IP
>     fragment going out of the adapter after IP fragmentation by hardware.
> 
> The fact that it states "skb->data will contain MAC/IP/UDP header and
> skb_shinfo(skb)->frags[] contains the data payload." seems irrelevant.
> 
> If Neterion driver mandates that skb->head *only* contains the
> MAC/IP/UDP header, that should be handled in the driver itself.

Thanks Eric for clearing this up.

I really thought it would be the common pattern for UFO to have only headers
in skb->data, so I didn't bother to ask in the first place.

Thanks,

  Hannes
