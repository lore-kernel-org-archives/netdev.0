From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC 5/7] neighbour: convert lookup to sequence lock
Date: Mon, 14 Aug 2006 15:37:43 -0700
Message-ID: <20060814153743.0ab60955@localhost.localdomain>
References: <20060814212004.606140865@localhost.localdomain>
	<20060814212143.845202090@localhost.localdomain>
	<20060814222220.GQ14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:24463 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932734AbWHNWhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 18:37:50 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060814222220.GQ14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Aug 2006 00:22:20 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> * Stephen Hemminger <shemminger@osdl.org> 2006-08-14 14:20
> > --- net-2.6.19.orig/net/core/neighbour.c
> > +++ net-2.6.19/net/core/neighbour.c
> > @@ -1160,19 +1164,24 @@ int neigh_resolve_output(struct sk_buff 
> >  	if (!neigh_event_send(neigh, skb)) {
> >  		int err;
> >  		struct net_device *dev = neigh->dev;
> > +		unsigned short type = ntohs(skb->protocol);
> > +
> >  		if (dev->hard_header_cache && !dst->hh) {
> > -			write_lock_bh(&neigh->lock);
> > +			write_seqlock_bh(&neigh->lock);
> >  			if (!dst->hh)
> >  				neigh_hh_init(neigh, dst, dst->ops->protocol);
> > -			err = dev->hard_header(skb, dev, ntohs(skb->protocol),
> > +			err = dev->hard_header(skb, dev, type,
> >  					       neigh->ha, NULL, skb->len);
> > -			write_unlock_bh(&neigh->lock);
> > +			write_sequnlock_bh(&neigh->lock);
> >  		} else {
> > -			read_lock_bh(&neigh->lock);
> > -			err = dev->hard_header(skb, dev, ntohs(skb->protocol),
> > -					       neigh->ha, NULL, skb->len);
> > -			read_unlock_bh(&neigh->lock);
> > +			unsigned seq;
> > +			do {
> > +				seq = read_seqbegin(&neigh->lock);
> > +				err = dev->hard_header(skb, dev, type,
> > +						       neigh->ha, NULL, skb->len);
> > +			} while (read_seqretry(&neigh->lock, seq));
> 
> Don't you need to pull in order to undo the push that probably
> happened in dev->hard_header()?

Probably just record the headroom() and undo that?
