From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] gro: Handle inline VLAN tags
Date: Sat, 17 Nov 2012 00:00:30 +0000
Message-ID: <1353110430.2743.73.camel@bwh-desktop.uk.solarflarecom.com>
References: <1353097030.2743.28.camel@bwh-desktop.uk.solarflarecom.com>
	 <1353106865.10798.61.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10962 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173Ab2KQAAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 19:00:34 -0500
In-Reply-To: <1353106865.10798.61.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-16 at 15:01 -0800, Eric Dumazet wrote:
> On Fri, 2012-11-16 at 20:17 +0000, Ben Hutchings wrote:
> > The receive paths for skbs with inline and out-of-line VLAN tags (VLAN
> > RX accleration) were made largely consistent in 2.6.37, with tags
> > pulled out by software as necessary.  However GRO doesn't do this, so
> > it is not effective for VLAN-tagged packets received on devices
> > without VLAN RX acceleration.
> > 
> > napi_gro_frags() must not free the skb and does not advance the
> > skb->data pointer, so cannot use vlan_untag().  Extract the core of
> > vlan_untag() into a new function __vlan_untag() that allows the offset
> > to the VLAN tag to be specified and returns an error code.  Add
> > kernel-doc comments for both those functions.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> > Tested with sfc using both napi_gro_receive() and napi_gro_frags().  On
> > a Core i7 920 (Nehalem) system it increased TCP/IPv4 receive throughput
> > over a VLAN from ~8.0 to ~9.3 Gbit/s.
> > 
> > Ben.
> > 
> 
> > index b4978e2..9d658eb 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -3668,6 +3668,13 @@ static void skb_gro_reset_offset(struct sk_buff *skb)
> >  
> >  gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
> >  {
> > +	if (unlikely(skb->protocol == htons(ETH_P_8021Q)) &&
> > +	    !vlan_tx_tag_present(skb)) {
> > +		skb = vlan_untag(skb);
> > +		if (unlikely(!skb))
> > +			return GRO_DROP;
> > +	}
> > +
> >  	skb_gro_reset_offset(skb);
> 
> I am not very convinced.
> 
> So for some drivers _not_ doing vlan acceleration, we are slowing down
> GRO.

It's a single comparison, hinted as 'unlikely'.

> I mean, driver authors should know if they need to call a helper before
> calling napi_gro_receive()
> 
> To date, only two drivers would need this, and it was discovered very
> recently.

It's not only two drivers.  qlcnic fakes RX VLAN acceleration precisely
to work around this limitation.  netxen, niu and Calxeda's xgmac might
also benefit (it's not clear whether the hardware does checksum
validation for VLAN-tagged packets).

> Also at GRO point, we totally own the skb and the vlan decap cannot
> possibly fail (and free the skb)
> 
> A packet sniffer should see all skbs delivered to napi_gro_receive()

I'm not sure what you mean by this.  Is your point that the
copy-on-write is never needed?  It is still possible for pskb_may_pull()
to fail.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
