From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Wed, 13 Jun 2007 11:34:55 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290306A87D@orsmsx414.amr.corp.intel.com>
References: <466D883B.5050409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39433 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758742AbXFMSfF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 14:35:05 -0400
Content-class: urn:content-classes:message
In-Reply-To: <466D883B.5050409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> PJ Waskiewicz wrote:
> > diff --git a/net/sched/sch_generic.c 
> b/net/sched/sch_generic.c index 
> > f28bb2d..b9dc2a6 100644
> > --- a/net/sched/sch_generic.c
> > +++ b/net/sched/sch_generic.c
> > @@ -123,7 +123,8 @@ static inline int qdisc_restart(struct 
> net_device *dev)
> >  			/* And release queue */
> >  			spin_unlock(&dev->queue_lock);
> >  
> > -			if (!netif_queue_stopped(dev)) {
> > +			if (!netif_queue_stopped(dev) &&
> > +			    !netif_subqueue_stopped(dev, 
> skb->queue_mapping)) {
> >  				int ret;
> >  
> >  				ret = dev_hard_start_xmit(skb, dev);
> 
> 
> Your patch doesn't update any other users of netif_queue_stopped().
> The assumption that they can pass packets to the driver when 
> the queue is running is no longer valid since they don't know 
> whether the subqueue the packet will end up in is active (it 
> might be different from queue 0 if packets were redirected 
> from a multiqueue aware qdisc through TC actions). So they 
> need to be changed to check the subqueue state as well.

The cases I found were net/core/netpoll.c, net/core/pktgen.c, and the
software device case in net/core/dev.c.  In all cases, the value of
skb->queue_mapping will be zero, but they don't initialize the subqueue
lock of the single allocated queue (hence panic when trying to use
it...).  I also don't think it makes sense for them to care, since
->enqueue() doesn't get called as far as I can tell, therefore the
classification won't happen.  Did I miss something in looking at this?

Thanks,
-PJ
