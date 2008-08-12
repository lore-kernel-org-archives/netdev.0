From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 12 Aug 2008 07:00:05 +0000
Message-ID: <20080812070005.GB5066@ff.dom.local>
References: <20080811205357.GA15293@ami.dom.local> <20080811.181235.141399855.davem@davemloft.net> <20080812052048.GA4291@ff.dom.local> <20080811.224047.154563272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:12631 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbYHLHAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 03:00:14 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1260423fgg.17
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 00:00:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080811.224047.154563272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 10:40:47PM -0700, David Miller wrote:
...
> Those comments are out of date and I need to update them.
> In fact this whole loop is now largely pointless.
> 
> The rcu_dereference() on dev_queue->qdisc happens before the
> QDISC_RUNNING bit is set.
> 
> We no longer resample the qdisc under any kind of lock.  Because we no
> longer have a top-level lock that synchronizes the setting of
> dev_queue->qdisc
> 
> Rather, the lock we use for calling ->enqueue() and ->dequeue() is
> inside of the root qdisc itself.
> 
> That's why all of the real destruction has to occur in the RCU handler.
> 
> Anyways, this is part of the problem I think is causing the crash the
> Intel folks are triggering.
> 
> We sample the qdisc in dev_queue_xmit() or wherever, then we attach
> that to the per-cpu ->output_queue to process it via qdisc_run()
> in the software interrupt handler.
> 
> The RCU quiesce period extends to the next scheduling point and this
> is enough if we do normal direct softirq processing of this qdisc.
> 
> But if it gets postponed into ksoftirqd... the RCU will pass too
> early.
> 
> I'm still thinking about how to fix this without avoiding RCU
> and without adding new synchronization primitives.

Of course I've to miss something, but I still don't get it: after
synchronize_rcu() in dev_deactivate() we are sure anyone in
dev_queue_xmit() rcu block has to see the change to noop_qdisc(),
so it can only lose packets and not really enqueue(). IMHO the
only problem is this __netif_schedule(), which could be done with
dev_queues instead of Qdiscs with proper dereferencing there.
(BTW, I think we need rcu_read_lock() instead of the _bh() version in
dev_queue_xmit() to match this with rcu_call() or synchronize_rcu().)

Thanks,
Jarek P.
