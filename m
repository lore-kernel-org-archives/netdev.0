From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
Date: Tue, 7 Jan 2014 21:29:03 +0100
Message-ID: <20140107202903.GI30393@order.stressinduktion.org>
References: <20140107170145.317040@gmx.com> <20140107174322.GC30393@order.stressinduktion.org> <20140107201147.GG30393@order.stressinduktion.org> <1389126413.26646.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46194 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158AbaAGU3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:29:04 -0500
Content-Disposition: inline
In-Reply-To: <1389126413.26646.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 12:26:53PM -0800, Eric Dumazet wrote:
> On Tue, 2014-01-07 at 21:11 +0100, Hannes Frederic Sowa wrote:
> 
> > It seems ip(6)mr_fib_lookup is not always called  from rcu section
> > (ndo_start_xmit), so I had to restructure a bit. Could you retest this
> > patch as preparation for a submission to stable? Thanks!
> > 
> > RCU conversion can be done later then.
> > 
> > diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> > index 421a249..9ae4ae7 100644
> > --- a/net/ipv4/ipmr.c
> > +++ b/net/ipv4/ipmr.c
> 
> >  
> >  static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
> >  {
> > +	int err;
> > +	struct ipmr_result res;
> >  	struct net *net = dev_net(dev);
> > -	struct mr_table *mrt;
> > +
> > +	struct fib_lookup_arg arg = {
> > +		.result = &res,
> > +		.flags = FIB_LOOKUP_NOREF,
> > +	};
> > +
> >  	struct flowi4 fl4 = {
> >  		.flowi4_oif	= dev->ifindex,
> >  		.flowi4_iif	= skb->skb_iif,
> >  		.flowi4_mark	= skb->mark,
> >  	};
> > -	int err;
> 
> Technically speaking, I don't think reg_vif_xmit() is enclosed
> in rcu_read_lock() section.
> 
> >  
> > -	err = ipmr_fib_lookup(net, &fl4, &mrt);
> > +	err = fib_rules_lookup(net->ipv4.mr_rules_ops,
> > +			       flowi4_to_flowi(&fl4), 0, &arg);
> >  	if (err < 0) {
> >  		kfree_skb(skb);
> >  		return err;
> > @@ -466,9 +476,12 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
> >  	read_lock(&mrt_lock);
> >  	dev->stats.tx_bytes += skb->len;
> >  	dev->stats.tx_packets++;
> > -	ipmr_cache_report(mrt, skb, mrt->mroute_reg_vif_num, IGMPMSG_WHOLEPKT);
> > +	ipmr_cache_report(res.mrt, skb, res.mrt->mroute_reg_vif_num,
> > +			  IGMPMSG_WHOLEPKT);
> >  	read_unlock(&mrt_lock);
> >  	kfree_skb(skb);
> > +	if (arg.rule)
> > +		fib_rule_put(arg.rule);
> >  	return NETDEV_TX_OK;
> >  }
> >  
> 
> Hmm... Are you sure you meant to use FIB_LOOKUP_NOREF in
> reg_vif_xmit() ?

Nope, that's the reason for the second patch. Should have mentioned that.

Thanks for the review,

  Hannes
