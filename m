From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 12 Aug 2008 01:15:10 -0700 (PDT)
Message-ID: <20080812.011510.20845920.davem@davemloft.net>
References: <20080812052048.GA4291@ff.dom.local>
	<20080811.224047.154563272.davem@davemloft.net>
	<20080812070005.GB5066@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43087
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751490AbYHLIPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 04:15:09 -0400
In-Reply-To: <20080812070005.GB5066@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 12 Aug 2008 07:00:05 +0000

> Of course I've to miss something, but I still don't get it: after
> synchronize_rcu() in dev_deactivate() we are sure anyone in
> dev_queue_xmit() rcu block has to see the change to noop_qdisc(),
> so it can only lose packets and not really enqueue().

The qdisc pointer traverses to the softirq handler, which can be run
in a process context (via ksoftirqd), and this pointer gets there
via the per-cpu ->output_queue.

> IMHO the only problem is this __netif_schedule(), which could be
> done with dev_queues instead of Qdiscs with proper dereferencing
> there.  (BTW, I think we need rcu_read_lock() instead of the _bh()
> version in dev_queue_xmit() to match this with rcu_call() or
> synchronize_rcu().)

I didn't see it possible to keep scheduling the netdev_queues, as the
qdiscs can be shared with multiple queues.

Qdisc "are we running?" and other state pieces are now inside of the
Qdisc itself.  And all of the qdisc_run() and netif_schedule logic is,
as a result, Qdisc centric.

The synchronization object is the qdisc.  So we can't resample the
qdisc after scheduling it, because then the qdisc attached to the
netdev_queue can change and we'd be holding the root lock for
the wrong qdisc object.
