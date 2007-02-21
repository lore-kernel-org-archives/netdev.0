From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] net/bridge/br_if.c: fix possible use-after-free in port_carrier_check()
Date: Wed, 21 Feb 2007 09:23:45 +0100
Message-ID: <20070221082345.GB1662@ff.dom.local>
References: <20070220221941.GA707@tv-sign.ru> <20070220162434.72d3ad7b@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@tv-sign.ru>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S\. Miller" <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:33228 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751186AbXBUIUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 03:20:19 -0500
Content-Disposition: inline
In-Reply-To: <20070220162434.72d3ad7b@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 04:24:34PM -0800, Stephen Hemminger wrote:
> On Wed, 21 Feb 2007 01:19:41 +0300
> Oleg Nesterov <oleg@tv-sign.ru> wrote:
> 
> > If del_nbp()->cancel_delayed_work(carrier_check) fails, port_carrier_check()
> > may run later and access an already freed container (struct net_bridge_port).
> > 
> > With this patch, carrier_check owns a reference to "struct net_bridge_port",
> > not net_device, so it is always safe to acces the container.
> > 
> > port_carrier_check() uses p->dev->br_port == NULL as indication that net_bridge_port
> > is under destruction. Otherwise it assumes that p->dev->br_port == p.
> > 
> > Signed-off-by: Oleg Nesterov <oleg@tv-sign.ru>
> > Acked-By: David Howells <dhowells@redhat.com>
> > 
> > --- WQ/net/bridge/br_if.c~5_bridge_uaf	2007-02-18 23:06:15.000000000 +0300
> > +++ WQ/net/bridge/br_if.c	2007-02-20 00:59:54.000000000 +0300
> > @@ -83,14 +83,14 @@ static void port_carrier_check(struct wo
> >  	struct net_device *dev;
> >  	struct net_bridge *br;
> >  
> > -	dev = container_of(work, struct net_bridge_port,
> > -			   carrier_check.work)->dev;
> > +	p = container_of(work, struct net_bridge_port, carrier_check.work);
> >  
> >  	rtnl_lock();
> > -	p = dev->br_port;
> > -	if (!p)
> > -		goto done;
> >  	br = p->br;

It doesn't matter very much but I think this would look
better after the first if check.

> > +	dev = p->dev;
> > +
> > +	if (!dev->br_port)
> > +		goto done;
> >  
> >  	if (netif_carrier_ok(dev))
> >  		p->path_cost = port_cost(dev);
> > @@ -107,14 +107,16 @@ static void port_carrier_check(struct wo
> >  		spin_unlock_bh(&br->lock);
> >  	}
> >  done:
> > -	dev_put(dev);
> >  	rtnl_unlock();
> > +	kobject_put(&p->kobj);
> >  }
> >  
> >  static void release_nbp(struct kobject *kobj)
> >  {
> >  	struct net_bridge_port *p
> >  		= container_of(kobj, struct net_bridge_port, kobj);
> > +
> > +	dev_put(p->dev);
> >  	kfree(p);
> >  }
> >  
> > @@ -127,12 +129,6 @@ static struct kobj_type brport_ktype = {
> >  
> >  static void destroy_nbp(struct net_bridge_port *p)
> >  {
> > -	struct net_device *dev = p->dev;
> > -
> > -	p->br = NULL;
> > -	p->dev = NULL;
> > -	dev_put(dev);
> > -
> >  	kobject_put(&p->kobj);
> >  }
> 
> Moving this around is problematic.
> The ordering here was chosen to be RCU friendly so that
> p->dev indicates the port is in process of being deleted but traffic
> may still be using old reference, but new traffic should not use it.

I have known issues with RCU, but dare to disagree here.
It's done during call_rcu, so anything RCU friendly shouldn't
see this at the moment at all. It could be needed for those
with refcounting - than it should be checked, if there is
anything more than port_carrier_check.

I don't have enough time to check this deep enough, but at
the moment I think this patch is right (there is really a
very short race time between calling this function and
container_of).

Regards,
Jarek P.
