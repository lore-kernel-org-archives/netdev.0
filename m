From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: LRO/GSO interaction when packets are forwarded
Date: Wed, 23 Apr 2008 11:04:46 +0100
Message-ID: <20080423100444.GR21637@solarflare.com>
References: <1204898997.4220.41.camel@moonstone.uk.level5networks.com> <20080307082538.1a674ae1@extreme> <1204909575.4220.71.camel@moonstone.uk.level5networks.com> <20080422211512.GQ21637@solarflare.com> <20080422160130.0b84959a@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kieran Mansley <kmansley@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:49021 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751370AbYDWKEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 06:04:51 -0400
Content-Disposition: inline
In-Reply-To: <20080422160130.0b84959a@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
<snip>
> > diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> > index 6848e47..f88d395 100644
> > --- a/net/ipv4/devinet.c
> > +++ b/net/ipv4/devinet.c
> > @@ -171,6 +171,8 @@ static struct in_device *inetdev_init(struct net_device *dev)
> >  	in_dev->dev = dev;
> >  	if ((in_dev->arp_parms = neigh_parms_alloc(dev, &arp_tbl)) == NULL)
> >  		goto out_kfree;
> > +	if (IPV4_DEVCONF(in_dev->cnf, FORWARDING))
> > +		dev_disable_lro(dev);
> >  	/* Reference in_dev->dev */
> >  	dev_hold(dev);
> >  	/* Account for reference dev->ip_ptr (below) */
> > @@ -1250,6 +1252,8 @@ static void inet_forward_change(struct net *net)
> >  	read_lock(&dev_base_lock);
> >  	for_each_netdev(net, dev) {
> >  		struct in_device *in_dev;
> > +		if (on)
> > +			dev_disable_lro(dev);
> >  		rcu_read_lock();
> >  		in_dev = __in_dev_get_rcu(dev);
> >  		if (in_dev)
> > @@ -1257,8 +1261,6 @@ static void inet_forward_change(struct net *net)
> >  		rcu_read_unlock();
> >  	}
> >  	read_unlock(&dev_base_lock);
> > -
> > -	rt_cache_flush(0);
> >  }
> 
> Why did you delete the route cache flush here?

I changed devinet_sysctl_forward() (the only caller of inet_forward_change())
to combine code for the change-one and change-all cases.  It calls
rt_cache_flush(0) in both cases.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
