From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 3/10 REV5] [sched] Modify qdisc_run to support batching
Date: Mon, 17 Sep 2007 09:19:36 +0530
Message-ID: <OF65D855C9.D3C88167-ON65257359.0014901D-65257359.0015059F@in.ibm.com>
References: <20070914121518.GB18517@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	kaber@trash.net, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, randy.dunlap@oracle.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP01.au.ibm.com ([202.81.18.162]:58560 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbXIQDtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 23:49:47 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8H3nX3k009236
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 13:49:33 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8H3r3fi213820
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 13:53:03 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8H3mgE9010751
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 13:49:12 +1000
In-Reply-To: <20070914121518.GB18517@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote on 09/14/2007 05:45:19 PM:

> > +      if (skb->next) {
> > +         int count = 0;
> > +
> > +         do {
> > +            struct sk_buff *nskb = skb->next;
> > +
> > +            skb->next = nskb->next;
> > +            __skb_queue_tail(dev->skb_blist, nskb);
> > +            count++;
> > +         } while (skb->next);
>
> Could it be list_move()-like function for skb lists?
> I'm pretty sure if you change first and the last skbs and ke of the
> queue in one shot, result will be the same.

I have to do a bit more like update count, etc, but I agree it is do-able.
I had mentioned in my PATCH 0/10 that I will later try this suggestion
that you provided last time.

> Actually how many skbs are usually batched in your load?

It depends, eg when the tx lock is not got, I get batching of upto 8-10
skbs (assuming that tx lock was not got quite a few times). But when the
queue gets blocked, I have seen batching upto 4K skbs (if tx_queue_len
is 4K).

> > +         /* Reset destructor for kfree_skb to work */
> > +         skb->destructor = DEV_GSO_CB(skb)->destructor;
> > +         kfree_skb(skb);
>
> Why do you free first skb in the chain?

This is the gso code which has segmented 'skb' to skb'1-n', and those
skb'1-n' are sent out and freed by driver, which means the dummy 'skb'
(without any data) remains to be freed.

Thanks,

- KK

