From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: tun mq failure
Date: Wed, 23 Jan 2013 15:18:10 +0200
Message-ID: <20130123131810.GA18276@redhat.com>
References: <20130123100516.GB8108@redhat.com>
 <20130123110640.GC7005@order.stressinduktion.org>
 <20130123114102.GA10426@redhat.com>
 <50FFD33B.2090103@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8649 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159Ab3AWNOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 08:14:02 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0NDE1hT002117
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 08:14:01 -0500
Content-Disposition: inline
In-Reply-To: <50FFD33B.2090103@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 08:10:35PM +0800, Jason Wang wrote:
> On 01/23/2013 07:41 PM, Michael S. Tsirkin wrote:
> > On Wed, Jan 23, 2013 at 12:06:40PM +0100, Hannes Frederic Sowa wrote:
> >> On Wed, Jan 23, 2013 at 12:05:16PM +0200, Michael S. Tsirkin wrote:
> >>> This is when trying to start a VPN using some old openvpn binary so MQ
> >>> is not set.
> >>>
> >>> So
> >>> 1. I think we should limit allocation of MQ to when MQ flag is set in SETIFF.
> >>> 2. order 7 allocation is 2^^7 pages - about half a megabyte of contigious
> >>>    memory. This is quite likely to fail.
> >>>    Let's start with a small limit on number of queues, like 8?
> >>>    Then we know it will succeed.
> >>>    Longer term we might want to solve it differently.
> >> This has been come up before:
> >> http://thread.gmane.org/gmane.linux.network/255647/focus=255902
> >>
> >> I think a solution to this problem is still outstanding.
> > Right. What (at least I) missed is that it's the
> > queue array allocation that fails here.
> > So I think something like the following will sort the first issue
> > (compiled only):
> >
> > For the second, for 3.8 maybe the prudent thing to do is
> > to set MAX_TAP_QUEUES to a small value, like 8, to avoid
> > userspace relying on a large number of queues being available,
> > and look at a better way to do this longer term, like
> > using an array of pointers.
> 
> Sure, this is just the method I reply in that thread. Not sure 8 is the
> best, but since it fit into one page, should be ok. Maybe we can use
> flex array to avoid high order memory allocation in the longer term.

Right so let's for now use  DEFAULT_MAX_NUM_RSS_QUEUES as Eric suggested.

> >
> > --->
> >
> > tun: don't waste memory on unused queues
> >
> > If MQ flag is off, we never attach more than 1 queue.
> > So let's not allocate memory for the unused ones.
> >
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >
> > ---
> >
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index af372d0..813d303 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -1577,6 +1577,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
> >  	else {
> >  		char *name;
> >  		unsigned long flags = 0;
> > +		unsigned int max_tap_queues;
> >  
> >  		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> >  			return -EPERM;
> > @@ -1599,9 +1600,13 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
> >  		if (*ifr->ifr_name)
> >  			name = ifr->ifr_name;
> >  
> > +		if (ifr->ifr_flags & IFF_MULTI_QUEUE)
> > +			max_tap_queues = MAX_TAP_QUEUES;
> > +		else
> > +			max_tap_queues = 1;
> >  		dev = alloc_netdev_mqs(sizeof(struct tun_struct), name,
> >  				       tun_setup,
> > -				       MAX_TAP_QUEUES, MAX_TAP_QUEUES);
> > +				       max_tap_queues, max_tap_queues);
> >  		if (!dev)
> >  			return -ENOMEM;
> >  
