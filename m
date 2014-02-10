From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: 6lowpan: lockless tx queue of routing netlink device
Date: Mon, 10 Feb 2014 19:21:40 +0100
Message-ID: <20140210182138.GB15674@omega>
References: <20140209102047.GA14770@omega>
 <1391949707.10160.130.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140210173314.GA12594@omega>
 <1392056186.6615.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:35670 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbaBJSVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 13:21:45 -0500
Received: by mail-ee0-f54.google.com with SMTP id e53so3154412eek.13
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 10:21:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1392056186.6615.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Feb 10, 2014 at 10:16:26AM -0800, Eric Dumazet wrote:
> On Mon, 2014-02-10 at 18:33 +0100, Alexander Aring wrote:
> > Hi Eric,
> > 
> > On Sun, Feb 09, 2014 at 04:41:47AM -0800, Eric Dumazet wrote:
> > > 
> > > Please try the following fix, thanks for this report !
> > > 
> > > diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> > > index 48b25c0af4d0..069af33013c4 100644
> > > --- a/net/ieee802154/6lowpan.c
> > > +++ b/net/ieee802154/6lowpan.c
> > > @@ -533,7 +533,27 @@ static struct header_ops lowpan_header_ops = {
> > >  	.create	= lowpan_header_create,
> > >  };
> > >  
> > > +static struct lock_class_key lowpan_tx_busylock;
> > > +static struct lock_class_key lowpan_netdev_xmit_lock_key;
> > > +
> > > +static void lowpan_set_lockdep_class_one(struct net_device *dev,
> > > +					 struct netdev_queue *txq,
> > > +					 void *_unused)
> > > +{
> > > +	lockdep_set_class(&txq->_xmit_lock,
> > > +			  &lowpan_netdev_xmit_lock_key);
> > > +}
> > > +
> > > +
> > > +static int lowpan_dev_init(struct net_device *dev)
> > > +{
> > > +	netdev_for_each_tx_queue(dev, lowpan_set_lockdep_class_one, NULL);
> > > +	dev->qdisc_tx_busylock = &lowpan_tx_busylock;
> > > +	return 0;
> > > +}
> > > +
> > >  static const struct net_device_ops lowpan_netdev_ops = {
> > > +	.ndo_init		= lowpan_dev_init,
> > >  	.ndo_start_xmit		= lowpan_xmit,
> > >  	.ndo_set_mac_address	= lowpan_set_address,
> > >  };
> > 
> > thanks, this fixed the issue. What we should do as next?
> > 
> > Should I create a patch for this or do you want to make a patch?
> 
> I'll take care of this, don't worry ;)
> 
> Thanks for testing !
> 
no problem. Maybe you can try to give me some explanation what you did
there?

I see you make a lockdep_set_class for each tx queue and assign the 
lowpan_netdev_xmit_lock_key. So why it's better to make a own
"lock_key".

thanks.

- Alex
