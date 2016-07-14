From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen exceeds
 MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Thu, 14 Jul 2016 15:12:07 +0200
Message-ID: <1468501927.1817077.666165049.62D074FE@webmail.messagingengine.com>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
 <20160705130327.GA10737@breakpoint.cc> <20160705170541.3f210675@pixies>
 <20160709090020.GB2067@breakpoint.cc> <20160709153017.791f2607@halley>
 <20160709132230.GD2067@breakpoint.cc> <20160712085656.79f1c5fc@halley>
 <20160713170038.1d02eb2b@halley>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, shmulik.ladkani@gmail.com,
	netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:44597 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750966AbcGNNMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 09:12:08 -0400
In-Reply-To: <20160713170038.1d02eb2b@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Shmulik,

On Wed, Jul 13, 2016, at 16:00, Shmulik Ladkani wrote:
> Hi Florian, Hannes,
> 
> On Tue, 12 Jul 2016 08:56:56 +0300 Shmulik Ladkani
> <shmulik.ladkani@ravellosystems.com> wrote:
> > On Sat, 9 Jul 2016 15:22:30 +0200 Florian Westphal <fw@strlen.de> wrote:
> > > >     
> > > > > What about setting IPCB FORWARD flag in iptunnel_xmit if
> > > > > skb->skb_iif != 0... instead?    
> > 
> > I've came up with a suggestion that does not abuse IPSKB_FORWARDED,
> > while properly addressing the use case (and similar ones), without
> > introducing the cost of entering 'skb_gso_validate_mtu' in the local
> > case.
> > 
> > How about:
> > 
> > @@ -220,12 +220,15 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
> >  				struct sk_buff *skb, unsigned int mtu)
> >  {
> >  	netdev_features_t features;
> > +	int local_trusted_gso;
> >  	struct sk_buff *segs;
> >  	int ret = 0;
> >  
> > -	/* common case: locally created skb or seglen is <= mtu */
> > -	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
> > -	      skb_gso_validate_mtu(skb, mtu))
> > +	local_trusted_gso = (IPCB(skb)->flags & IPSKB_FORWARDED) == 0 &&
> > +			    !(skb_shinfo(skb)->gso_type & SKB_GSO_DODGY);
> > +	/* common case: locally created skb from a trusted gso source or
> > +	 * seglen is <= mtu */
> > +	if (local_trusted_gso || skb_gso_validate_mtu(skb, mtu))
> >  		return ip_finish_output2(net, sk, skb);
> >  
> >  	/* Slowpath -  GSO segment length is exceeding the dst MTU.
> > 
> > This well addresses the usecase where we have gso-skb arriving from an
> > untrusted source, thus its gso_size is out of our control (e.g. tun/tap,
> > macvtap, af_packet, xen-netfront...).
> > 
> > Locally "gso trusted" skbs (the common case) will NOT suffer the
> > additional (possibly costy) call to 'skb_gso_validate_mtu'.
> > 
> > Also, if IPSKB_FORWARDED is true, behavior stays exactly the same.

Sorry for the late reply, I am right now travelling and can't review
that closely.

> Any commnets regarding the latest suggestion above?
> I'd like to post it as v2 - if it is in the right direction.
> 
> It handles the problem of gso_size values which are not in host's
> control, it addresses the usecase described, and has a benefit of not
> overloading IPSKB_FORWARDED with a new semantic that might be hard to
> maintain.

I liked the fact that setting IPSKB_FORWARDED was only contained in
vxlan and as such wouldn't have as much impact. It was more logically
easy to review for me actually.

> PS:
> Also, if we'd like to pinpoint it even further, we can:
> 
> local_trusted_gso = (IPCB(skb)->flags & IPSKB_FORWARDED) == 0 &&
> 		    (!sk || !(skb_shinfo(skb)->gso_type & SKB_GSO_DODGY));

This also looks valid but too random. It seems to be a mix of random
conditions to make it work. ;)

> 
> Which ensures only the following conditions go to the expensive
> skb_gso_validate_mtu:
> 
> 1. IPSKB_FORWARDED is on
> 2. IPSKB_FORWARDED is off, but sk exists and gso_size is untrusted.
>    Meaning: we have a packet arriving from higher layers (sk is set)
>    with a gso_size out of host's control.

When can this really happen? In general we don't want to refragment gso
skb's and I think we can only make an exception for vxlan or udp.

> This fine-tuining leaves standard l2 bridging case (e.g 2x taps bridged)
> of a gso skb unaffected, as sk would be NULL.

Bridging does not in general orphan the socket, no?

Bye,
Hannes
