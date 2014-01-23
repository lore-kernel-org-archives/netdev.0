From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net] IPv6: Fix broken IPv6 routing table after loopback down-up
Date: Thu, 23 Jan 2014 15:11:24 +0100
Message-ID: <20140123141124.GJ7269@order.stressinduktion.org>
References: <1390404908-3914-1-git-send-email-sd@queasysnail.net> <20140122213446.GD7269@order.stressinduktion.org> <52E068C5.2050405@cn.fujitsu.com> <20140123010123.GF7269@order.stressinduktion.org> <52E0B55F.4070501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60448 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbaAWOLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 09:11:25 -0500
Content-Disposition: inline
In-Reply-To: <52E0B55F.4070501@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 23, 2014 at 02:23:27PM +0800, Gao feng wrote:
> >  
> > -static int fib6_ifdown(struct rt6_info *rt, void *arg)
> > +static int __fib6_match_or_update_if(struct rt6_info *rt, void *arg)
> >  {
> >  	const struct arg_dev_net *adn = arg;
> >  	const struct net_device *dev = adn->dev;
> >  
> >  	if ((rt->dst.dev == dev || !dev) &&
> > -	    rt != adn->net->ipv6.ip6_null_entry)
> > -		return -1;
> > +	    rt != adn->net->ipv6.ip6_null_entry) {
> > +		switch (adn->action) {
> > +		case ARG_DEV_NET_REMOVE:
> > +			/* remove rt */
> > +			return -1;
> > +		case ARG_DEV_NET_DISABLE:
> > +			WARN_ON(rt->rt6i_flags & RTF_DEAD);
> > +			rt->rt6i_flags |= RTF_DEAD;
> > +			return 0;
> > +		case ARG_DEV_NET_ENABLE:
> > +			WARN_ON(!(rt->rt6i_flags & RTF_DEAD));
> 
> I think this may happen, think a new router is cloned from this rt but hasn't been inserted
> into the router tree on other CPU at the same time.

Yes, there are still some problems with this patch. I actually shuffeled
the code around to purge all those RTF_CACHE RTF_DEAD routes yesterday
while holding the same write_lock on the table.

Regarding the problem you addressed, I tried to validate the route
using dst.from on insert while holding write_lock, somehow like we do
for checking expire time. But I really dislike this.

Thanks,

  Hannes
