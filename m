From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 10/10 REV5] [E1000] Implement batching
Date: Mon, 17 Sep 2007 09:26:47 +0530
Message-ID: <OF94AB804C.3E924624-ON65257359.001540B0-65257359.0015ADB1@in.ibm.com>
References: <20070914124714.GD18517@2ka.mipt.ru>
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
Received: from E23SMTP06.au.ibm.com ([202.81.18.175]:43797 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbXIQDzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 23:55:51 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8H3tYsF008274
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 13:55:34 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8H3x8sK115800
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 13:59:08 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8H3tWNC004453
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 13:55:34 +1000
In-Reply-To: <20070914124714.GD18517@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote on 09/14/2007 06:17:14 PM:

> >     if (unlikely(skb->len <= 0)) {
> >        dev_kfree_skb_any(skb);
> > -      return NETDEV_TX_OK;
> > +      return NETDEV_TX_DROPPED;
> >     }
>
> This changes could actually go as own patch, although not sure it is
> ever used. just a though, not a stopper.

Since this flag is new and useful only for batching, I feel it is OK to
include it in this patch.

> > +   if (!skb || (blist && skb_queue_len(blist))) {
> > +      /*
> > +       * Either batching xmit call, or single skb case but there are
> > +       * skbs already in the batch list from previous failure to
> > +       * xmit - send the earlier skbs first to avoid out of order.
> > +       */
> > +      if (skb)
> > +         __skb_queue_tail(blist, skb);
> > +      skb = __skb_dequeue(blist);
>
> Why is it put at the end?

There is a bug that I had explained in rev4 (see XXX below) resulting
in sending out skbs out of order. The fix is that if the driver gets
called with a skb but there are older skbs already in the batch list
(which failed to get sent out), send those skbs first before this one.

Thanks,

- KK

[XXX] Dave had suggested to use batching only in the net_tx_action case.
When I implemented that in earlier revisions, there were lots of TCP
retransmissions (about 18,000 to every 1 in regular code). I found the
reason
for part of that problem as: skbs get queue'd up in dev->qdisc (when tx
lock
was not got or queue blocked); when net_tx_action is called later, it
passes
the batch list as argument to qdisc_run and this results in skbs being
moved
to the batch list; then batching xmit also fails due to tx lock failure;
the
next many regular xmit of a single skb will go through the fast path (pass
NULL batch list to qdisc_run) and send those skbs out to the device while
previous skbs are cooling their heels in the batch list.

The first fix was to not pass NULL/batch-list to qdisc_run() but to always
check whether skbs are present in batch list when trying to xmit. This
reduced
retransmissions by a third (from 18,000 to around 12,000), but led to
another
problem while testing - iperf transmit almost zero data for higher # of
parallel flows like 64 or more (and when I run iperf for a 2 min run, it
takes about 5-6 mins, and reports that it ran 0 secs and the amount of data
transfered is a few MB's). I don't know why this happens with this being
the
only change (any ideas is very appreciated).

The second fix that resolved this was to revert back to Dave's suggestion
to
use batching only in net_tx_action case, and modify the driver to see if
skbs
are present in batch list and to send them out first before sending the
current skb. I still see huge retransmission for IPoIB (but not for E1000),
though it has reduced to 12,000 from the earlier 18,000 number.


