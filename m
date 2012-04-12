From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/4] ipgre: follow state of lower device
Date: Thu, 12 Apr 2012 10:38:25 -0700
Message-ID: <20120412103825.74ff915a@s6510.linuxnetplumber.net>
References: <20120412163115.076119065@vyatta.com>
	<20120412163142.544953001@vyatta.com>
	<1334251927.2497.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37540 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757736Ab2DLRi2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 13:38:28 -0400
In-Reply-To: <1334251927.2497.7.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Apr 2012 18:32:07 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Thu, 2012-04-12 at 09:31 -0700, Stephen Hemminger wrote:
> 
> > GRE tunnels like other layered devices should propogate
> > carrier and RFC2863 state from lower device to tunnel.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > --- a/net/ipv4/ip_gre.c	2012-04-12 08:07:39.508107847 -0700
> > +++ b/net/ipv4/ip_gre.c	2012-04-12 08:10:14.177499183 -0700
> [...]
> > @@ -1732,6 +1734,36 @@ static struct rtnl_link_ops ipgre_tap_op
> >  	.fill_info	= ipgre_fill_info,
> >  };
> >  
> > +/* If lower device changes state, reflect that to the tunnel. */
> > +static int ipgre_notify(struct notifier_block *unused,
> > +			unsigned long event, void *ptr)
> > +{
> > +	struct net_device *dev = ptr;
> > +	struct net *net = dev_net(dev);
> > +	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
> > +	unsigned int prio, h;
> > +	struct ip_tunnel *t;
> > +
> > +	if (event == NETDEV_CHANGE)
> > +		return NOTIFY_DONE;
> 
> Surely we should handle NETDEV_UP, NETDEV_CHANGE, NETDEV_DOWN here?  Not
> everything other than NETDEV_CHANGE.

yes, up and down needed as well.

> > +	for (prio = 0; prio < 4; prio++)
> > +		for (h = 0; h < HASH_SIZE; h++) {
> > +			for (t = rtnl_dereference(ign->tunnels[prio][h]);
> > +			     t; t = rtnl_dereference(t->next)) {
> > +				if (dev->ifindex != t->dev->iflink)
> > +					continue;
> > +				netif_stacked_transfer_operstate(dev, t->dev);
> > +			}
> > +		}
> [...]
> 
> This seems potentially very inefficient.

Yes, but there is no list of tunnels per device.
