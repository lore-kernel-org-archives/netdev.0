From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 11 Aug 2008 22:40:47 -0700 (PDT)
Message-ID: <20080811.224047.154563272.davem@davemloft.net>
References: <20080811205357.GA15293@ami.dom.local>
	<20080811.181235.141399855.davem@davemloft.net>
	<20080812052048.GA4291@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52842
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750878AbYHLFkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 01:40:46 -0400
In-Reply-To: <20080812052048.GA4291@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 12 Aug 2008 05:20:48 +0000

> On Mon, Aug 11, 2008 at 06:12:35PM -0700, David Miller wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Mon, 11 Aug 2008 22:53:57 +0200
> > 
> > > pkt_sched: Destroy gen estimators under rtnl_lock().
> > > 
> > > gen_kill_estimator() requires rtnl_lock() protection, and since it is
> > > called in qdisc ->destroy() too, this has to go back from RCU callback
> > > to qdisc_destroy().
> > > 
> > > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > 
> > We can't do this.  And at a minimum, the final ->reset() must
> > occur in the RCU callback, otherwise asynchronous threads of
> > execution could queue packets into this dying qdisc and
> > such packets would leak forever.
> 
> Could you explain this more? I've thought this synchronize_rcu() is
> just to prevent this (and what these comments talk about?):

Those comments are out of date and I need to update them.
In fact this whole loop is now largely pointless.

The rcu_dereference() on dev_queue->qdisc happens before the
QDISC_RUNNING bit is set.

We no longer resample the qdisc under any kind of lock.  Because we no
longer have a top-level lock that synchronizes the setting of
dev_queue->qdisc

Rather, the lock we use for calling ->enqueue() and ->dequeue() is
inside of the root qdisc itself.

That's why all of the real destruction has to occur in the RCU handler.

Anyways, this is part of the problem I think is causing the crash the
Intel folks are triggering.

We sample the qdisc in dev_queue_xmit() or wherever, then we attach
that to the per-cpu ->output_queue to process it via qdisc_run()
in the software interrupt handler.

The RCU quiesce period extends to the next scheduling point and this
is enough if we do normal direct softirq processing of this qdisc.

But if it gets postponed into ksoftirqd... the RCU will pass too
early.

I'm still thinking about how to fix this without avoiding RCU
and without adding new synchronization primitives.
