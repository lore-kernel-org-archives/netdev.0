From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH] net/bridge/br_if.c: fix possible use-after-free in port_carrier_check()
Date: Wed, 21 Feb 2007 17:22:04 +0300
Message-ID: <20070221142204.GA134@tv-sign.ru>
References: <20070220221941.GA707@tv-sign.ru> <20070220162434.72d3ad7b@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jarek Poplawski <jarkao2@o2.pl>,
	"David S. Miller" <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.screens.ru ([213.234.233.54]:38582 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030258AbXBUOWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 09:22:13 -0500
Content-Disposition: inline
In-Reply-To: <20070220162434.72d3ad7b@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/20, Stephen Hemminger wrote:
>
> On Wed, 21 Feb 2007 01:19:41 +0300
> Oleg Nesterov <oleg@tv-sign.ru> wrote:
> 
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

But it is still RCU friendly? destroy_nbp() is rcu-callback which
calls release_nbp() if we have a last reference to ->kobj. This
means that dev_put() may be done a bit later, but not earlier.
And RCU can only garantee "not before", any rcu-callback could be
delayed unpredictably.

Stephen, I know nothing about net/, and

> Probably the best thing to do is pull the whole delayed work queue
> and auto port speed stuff. When STP is moved to user space then
> it can do the ethtool op there.

I can't understand any single word in the paragraph above :)

But the bug (the stable tree has it too) is real. If this patch is
really wrong, could you please take care of it?

Oleg.

