From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 3/9 Rev3] [sched] Modify qdisc_run to support batching
Date: Thu, 9 Aug 2007 08:43:46 +0530
Message-ID: <OF83470D1B.58B9A3A0-ON65257332.001155B8-65257332.0011BD84@in.ibm.com>
References: <20070808121401.GB8478@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	kaber@trash.net, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:51377 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618AbXHIDNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 23:13:09 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l793GGIS222812
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2007 13:16:16 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l793D6W64288684
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2007 13:13:06 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l793D4ro024837
	for <netdev@vger.kernel.org>; Thu, 9 Aug 2007 13:13:06 +1000
In-Reply-To: <20070808121401.GB8478@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote on 08/08/2007 05:44:02 PM:

> On Wed, Aug 08, 2007 at 03:01:45PM +0530, Krishna Kumar
(krkumar2@in.ibm.com) wrote:
> > +static inline int get_skb(struct net_device *dev, struct Qdisc *q,
> > +           struct sk_buff_head *blist, struct sk_buff **skbp)
> > +{
> > +   if (likely(!blist || (!skb_queue_len(blist) && qdisc_qlen(q) <=
1))) {
> > +      return likely((*skbp = dev_dequeue_skb(dev, q)) != NULL);
> > +   } else {
> > +      int max = dev->tx_queue_len - skb_queue_len(blist);
> > +      struct sk_buff *skb;
> > +
> > +      while (max > 0 && (skb = dev_dequeue_skb(dev, q)) != NULL)
> > +         max -= dev_add_skb_to_blist(skb, dev);
> > +
> > +      *skbp = NULL;
> > +      return 1;   /* we have atleast one skb in blist */
> > +   }
> > +}
>
> Same here - is it possible to get a list in one go instead of pulling
> one-by-one, since it forces quite a few additional unneded lock
> get/releases. What about dev_dequeue_number_skb(dev, q, num), which will
> grab the lock and move a list of skbs from one queue to provided head.

OK, I will try this out.

> > @@ -158,7 +198,10 @@ static inline int qdisc_restart(struct n
> >     /* And release queue */
> >     spin_unlock(&dev->queue_lock);
> >
> > -   ret = dev_hard_start_xmit(skb, dev);
> > +   if (likely(skb))
> > +      ret = dev_hard_start_xmit(skb, dev);
> > +   else
> > +      ret = dev->hard_start_xmit_batch(dev);
>
> Perfectionism says that having array of two functions and calling one of
> them via array_func_pointer[!!skb] will be much faster. Just a though.
> It is actually much faster than if/else on x86 at least.

Thinking about this - I will have to store the 2 pointer array in dev
itself wasting some space, and also fn pointer will have wrong signature
as one takes an extra argument. Will ponder some more :)

thanks,

- KK

