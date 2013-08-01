From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 1/3] af_packet: when sending ethernet frames, parse
 header for skb->protocol
Date: Thu, 1 Aug 2013 12:35:09 +0200
Message-ID: <20130801103509.GB27563@orbit.nwl.cc>
References: <20130729165357.GA23134@orbit.nwl.cc>
 <1375291667-9572-1-git-send-email-phil@nwl.cc>
 <1375291667-9572-2-git-send-email-phil@nwl.cc>
 <20130731.173017.624144247713296239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:37703 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204Ab3HAKfg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 06:35:36 -0400
Content-Disposition: inline
In-Reply-To: <20130731.173017.624144247713296239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Jul 31, 2013 at 05:30:17PM -0700, David Miller wrote:
> From: Phil Sutter <phil@nwl.cc>
> Date: Wed, 31 Jul 2013 19:27:45 +0200
> 
> > @@ -2324,6 +2328,13 @@ static int packet_snd(struct socket *sock,
> >  
> >  	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
> >  
> > +	if (dev->type == ARPHRD_ETHER) {
> > +		skb->protocol = eth_type_trans(skb, dev);
> > +	} else {
> > +		skb->protocol = proto;
> > +		skb->dev = dev;
> > +	}
> > +
> >  	if (!gso_type && (len > dev->mtu + reserve + extra_len)) {
> >  		/* Earlier code assumed this would be a VLAN pkt,
> >  		 * double-check this now that we have the actual
> > @@ -2338,8 +2349,6 @@ static int packet_snd(struct socket *sock,
> >  		}
> >  	}
> >  
> > -	skb->protocol = proto;
> > -	skb->dev = dev;
> >  	skb->priority = sk->sk_priority;
> >  	skb->mark = sk->sk_mark;
> 
> I don't see anything explaining why you are avoiding setting skb->dev when
> you use eth_type_trans() to set the skb->protocol field.

Simply because eth_type_trans() sets skb->dev already. You're right, I
probably should have mentioned this explicitly. At least my introductory
mail elaborated on this.

> Also, why isn't the user setting the protocol field correctly?  Isn't
> that the _real_ source of these problems?

Because the user specifies the value later used for skb->protocol at
either socket(), bind() or sendto() (i.e. flush) stage. Having both
"regular" and VLAN frames in the same TX ring is not possible at least.

> This patch series cannot be applied as is, it's either wrong, or
> explanations are missing from the commit messages.

Hmm. Is it OK to rely on eth_type_trans() setting skb->dev after all?
Depending on that, I would either add a comment or drop the change.

Best wishes, Phil
