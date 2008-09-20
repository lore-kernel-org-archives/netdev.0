From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Sat, 20 Sep 2008 00:21:37 -0700 (PDT)
Message-ID: <20080920.002137.108837580.davem@davemloft.net>
References: <20080913205408.GA2545@ami.dom.local>
	<20080914061610.GA20571@gondor.apana.org.au>
	<20080914202715.GA2540@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34795
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750922AbYITHVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 03:21:49 -0400
In-Reply-To: <20080914202715.GA2540@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 14 Sep 2008 22:27:15 +0200

[ I'm just picking one posting out of several in this thread.  ]

> Anyway, the main problem here was a high cpu load despite stopped
> queue. Are you sure this peek, which is almost full dequeue, can
> really help for this? BTW, since after current fix there were no
> later complains I guess it's just about full netif_stop or non-mq
> device.

I think we are overengineering this situation.

Let's look at what actually matters for cpu utilization.  These
__qdisc_run() things are invoked in two situations where we might
block on the hw queue being stopped:

1) When feeding packets into the qdisc in dev_queue_xmit().

   Guess what?  We _know_ the queue this packet is going to
   hit.

   The only new thing we can possible trigger and be interested
   in at this specific point is if _this_ packet can be sent at
   this time.

   And we can check that queue mapping after the qdisc_enqueue_root()
   call, so that multiq aware qdiscs can have made their changes.

2) When waking up a queue.  And here we should schedule the qdisc_run
   _unconditionally_.

   If the queue was full, it is extremely likely that new packets
   are bound for that device queue.  There is no real savings to
   be had by doing this peek/requeue/dequeue stuff.

The cpu utilization savings exist for case #1 only, and we can
implement the bypass logic _perfectly_ as described above.

For #2 there is nothing to check, just do it and see what comes
out of the qdisc.

I would suggest adding an skb pointer argument to qdisc_run().
If it's NULL, unconditionally schedule __qdisc_run().  Else,
only schedule if the TX queue indicated by skb_queue_mapping()
is not stopped.

dev_queue_xmit() will use the "pass the skb" case, but only if
qdisc_enqueue_root()'s return value doesn't indicate that there
is a potential drop.  On potential drop, we'll pass NULL to
make sure we don't potentially reference a free'd SKB.

The other case in net_tx_action() can always pass NULL to qdisc_run().
