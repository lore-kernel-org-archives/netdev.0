From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] PATCH 1/2 [SCHED 2.6.24]: Check subqueue status before
 calling hard_start_xmit
Date: Tue, 13 Nov 2007 22:14:39 -0800 (PST)
Message-ID: <20071113.221439.225154441.davem@davemloft.net>
References: <20071114060412.9556.84833.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49300
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759014AbXKNGOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 01:14:40 -0500
In-Reply-To: <20071114060412.9556.84833.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Wed, 14 Nov 2007 11:34:12 +0530

> Hi Peter,
> 
> Peter wrote on 11/13/2007 11:14:50 PM:
> > @@ -134,7 +134,7 @@ static inline int qdisc_restart(struct net_device *dev)
> >  {
> >     struct Qdisc *q = dev->qdisc;
> >     struct sk_buff *skb;
> > -   int ret;
> > +   int ret = NETDEV_TX_BUSY;
> >  
> >     /* Dequeue packet */
> >     if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
> > @@ -145,7 +145,8 @@ static inline int qdisc_restart(struct net_device *dev)
> >     spin_unlock(&dev->queue_lock);
> >  
> >     HARD_TX_LOCK(dev, smp_processor_id());
> > -   ret = dev_hard_start_xmit(skb, dev);
> > +   if (!netif_subqueue_stopped(dev, skb))
> > +      ret = dev_hard_start_xmit(skb, dev);
> >     HARD_TX_UNLOCK(dev);
> 
> You could optimize this by getting HARD_TX_LOCK after the check. I
> assume that netif_stop_subqueue (from another CPU) would always be
> called by the driver xmit, and that is not possible since we hold
> the __LINK_STATE_QDISC_RUNNING bit. Does that sound correct?

I don't think this is a critical optimization at this time,
but something to certainly do along with the surgery
we'll undoubtedly be doing here in the future :-)
