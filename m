From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 6lowpan: lockless tx queue of routing
	netlink device
Date: Mon, 10 Feb 2014 10:16:26 -0800
Message-ID: <1392056186.6615.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140209102047.GA14770@omega>
	<1391949707.10160.130.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140210173314.GA12594@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20140210173314.GA12594@omega>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-02-10 at 18:33 +0100, Alexander Aring wrote:
> Hi Eric,
> 
> On Sun, Feb 09, 2014 at 04:41:47AM -0800, Eric Dumazet wrote:
> > 
> > Please try the following fix, thanks for this report !
> > 
> > diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> > index 48b25c0af4d0..069af33013c4 100644
> > --- a/net/ieee802154/6lowpan.c
> > +++ b/net/ieee802154/6lowpan.c
> > @@ -533,7 +533,27 @@ static struct header_ops lowpan_header_ops = {
> >  	.create	= lowpan_header_create,
> >  };
> >  
> > +static struct lock_class_key lowpan_tx_busylock;
> > +static struct lock_class_key lowpan_netdev_xmit_lock_key;
> > +
> > +static void lowpan_set_lockdep_class_one(struct net_device *dev,
> > +					 struct netdev_queue *txq,
> > +					 void *_unused)
> > +{
> > +	lockdep_set_class(&txq->_xmit_lock,
> > +			  &lowpan_netdev_xmit_lock_key);
> > +}
> > +
> > +
> > +static int lowpan_dev_init(struct net_device *dev)
> > +{
> > +	netdev_for_each_tx_queue(dev, lowpan_set_lockdep_class_one, NULL);
> > +	dev->qdisc_tx_busylock = &lowpan_tx_busylock;
> > +	return 0;
> > +}
> > +
> >  static const struct net_device_ops lowpan_netdev_ops = {
> > +	.ndo_init		= lowpan_dev_init,
> >  	.ndo_start_xmit		= lowpan_xmit,
> >  	.ndo_set_mac_address	= lowpan_set_address,
> >  };
> 
> thanks, this fixed the issue. What we should do as next?
> 
> Should I create a patch for this or do you want to make a patch?

I'll take care of this, don't worry ;)

Thanks for testing !



------------------------------------------------------------------------------
Android&trade; apps run on BlackBerry&reg;10
Introducing the new BlackBerry 10.2.1 Runtime for Android apps.
Now with support for Jelly Bean, Bluetooth, Mapview and more.
Get your Android app in front of a whole new audience.  Start now.
http://pubads.g.doubleclick.net/gampad/clk?id=124407151&iu=/4140/ostg.clktrk
