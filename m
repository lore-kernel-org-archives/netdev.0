From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/14]: Make packet scheduler multiqueue aware.
Date: Tue, 15 Jul 2008 21:14:11 -0700 (PDT)
Message-ID: <20080715.211411.99900109.davem@davemloft.net>
References: <20080714.155908.174564017.davem@davemloft.net>
	<487BEE7C.6080300@trash.net>
	<20080714.184849.121429019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47785
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751314AbYGPEOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 00:14:12 -0400
In-Reply-To: <20080714.184849.121429019.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 14 Jul 2008 18:48:49 -0700 (PDT)

> One idea is to allow all of the queues to point at a
> single qdisc.  We'd just need to work out how to do the
> locking.
> 
> For example, the Qdisc has a lock member, and a pointer.
> For simple qdiscs the pointer points at the netdev_queue
> lock.  But when sharing, we use the in-Qdisc static lock.

I've investigated several avenues to implement this, and so I've hit
several brick walls with each approach.  It's not easy.

Much of the locking, and some of the semantics, can be trivially
sorted out:

1) I have a change which moves gso_skb into the Qdisc.  That
   definitely would be needed for qdisc sharing amongst netdev_queue
   objects.

2) Qdiscs want to lock the qdisc tree and do several things, ror
   example, unlink and walk up the parents to adjust the qlen.

   For that, locking the root qdisc ought to be sufficient, I suppose.

3) The netdev_queue lock also synchronizes the ->qdisc linkage of the
   root.  In order to combat some of this, I wrote up a change that moved
   the bulk of qdisc_destroy()'s work into the qdisc destroy RCU handler.
   On top of that I passed the first seen qdisc in a qdisc_run() call all
   the way down into qdisc_restart() and removed all of the "recheck
   txq->qdisc" scatters all over these parts.

   Basically this works because we can just enqueue or whatever since
   BH's are disabled the whole time and thus RCU's are blocked out.  The
   RCU will reset and destroy the queue, freeing up any packets therein.

But then we get into the issue of which netdev_queue backpointer
should be used?  This is especially important for a shared qdisc.

At the top level we enqueue an SKB for a particular TXQ.  But as we
call down into qdisc_run(), the SKB we get out of q->dequeue() could
be for another TXQ.

This gets even more interesting when a qdisc_watchdog() fires.  Which
TXQ should we call netif_schedule for? :-)

I guess this means qdisc_run() and netif_schedule() should operate
on root qdiscs, rather than netdev_queue objects.

Then, as qdisc_restart() pulls packets out of the qdisc, it determines
the TXQ for that SKB and uses that to lock and call down into the
->hard_start_xmit() handler.

Just FYI and I'll try to explore this further.
