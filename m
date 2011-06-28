From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Tue, 28 Jun 2011 08:10:15 -0700
Message-ID: <20110628081015.1b06a3f0@nehalam.ftrdhcpuser.net>
References: <BANLkTim2G7_pnv5W10Q7kHHCnc2v126fZw@mail.gmail.com>
	<20110623152929.3f94b3e7@nehalam.ftrdhcpuser.net>
	<BANLkTi==Ho+6nCX=0hFEQgNAoNE34g35UA@mail.gmail.com>
	<20110624120859.3c43bbcb@nehalam.ftrdhcpuser.net>
	<BANLkTin4XOCmpFaETsjkYb2kk+psZUBKcA@mail.gmail.com>
	<BANLkTimD+fvhrhpc+kPXt1qMnQvVi2dw=Q@mail.gmail.com>
	<20110628150257.GB126252@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nick Carter <ncarter100@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47247 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758067Ab1F1PLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 11:11:40 -0400
In-Reply-To: <20110628150257.GB126252@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jun 2011 17:02:57 +0200
David Lamparter <equinox@diac24.net> wrote:

> On Sat, Jun 25, 2011 at 12:33:05AM +0100, Nick Carter wrote:
> > @@ -98,6 +98,14 @@ int br_handle_frame_finish(struct sk_buff *skb)
> >  	}
> > 
> >  	if (skb) {
> > +		/* Prevent Crosstalk where a Supplicant on one Port attempts to
> > +		 * interfere with authentications occurring on another Port.
> > +		 * (IEEE Std 802.1X-2001 C.3.3)
> > +		 */
> > +		if (unlikely(!br->pae_forward &&
> > +		    skb->protocol == htons(ETH_P_PAE)))
> > +			goto drop;
> > +
> >  		if (dst)
> >  			br_forward(dst->dst, skb, skb2);
> >  		else
> > @@ -166,6 +174,10 @@ struct sk_buff *br_handle_frame(struct sk_buff *skb)
> >  		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
> >  			goto forward;
> > 
> > +		/* Check if PAE frame should be forwarded */
> > +		if (p->br->pae_forward && skb->protocol == htons(ETH_P_PAE))
> > +			goto forward;
> > +
> >  		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> >  			    NULL, br_handle_local_finish))
> >  			return NULL;	/* frame consumed by filter */
> 
> No, please don't.
> 
> Linux bridging has two "grand" modes: dumb and STP enabled.
> 
> If we're running a dumb bridge, we behave like an ethernet hub without
> any intelligence, and in that case we should absolutely forward 802.1X
> frames. We may have (e.g. VM) client(s) that want to authenticate with a
> physical switch.
> (For the spec, this counts as "repeater", not "bridge"/"switch")
> 
> If we're running with STP enabled, then 802.1X traffic should already be
> caught by the general ethernet link-local multicast drop (which applies
> to 01:80:c2:/24 and therefore catches 802.1X too.)

The problem is that STP is not enabled by default, and most people don't
know how to enable it.
