From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 13 Aug 2008 06:53:03 +0000
Message-ID: <20080813065302.GB4251@ff.dom.local>
References: <E1KT803-00086Y-00@gondolin.me.apana.org.au> <20080812.221103.91087925.davem@davemloft.net> <20080813061317.GA4251@ff.dom.local> <20080812.231633.193696650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:28796 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbYHMGxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 02:53:10 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1583334fgg.17
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 23:53:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080812.231633.193696650.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 11:16:33PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 13 Aug 2008 06:13:17 +0000
> 
> > On Tue, Aug 12, 2008 at 10:11:03PM -0700, David Miller wrote:
> > > So, just like one of Jarek's patches, we should simply change
> > > dev_queue->qdisc into dev_queue->qdisc_sleeping and that should
> > > take care of the bulk of the issues.
> > > 
> > > Shouldn't it?
> > 
> > If we don't change anything in __netif_schedule() I doubt it's enough.
> > And if this old way of waiting for "outstanding qdisc-less" calls was
> > really needed we should probably wait for both qdisc and qdisc_sleeping
> > then.
> 
> I think if we check both RUNNING and SCHED bits, we'll be OK.
> 
> > > Hmmm... maybe we have to sample __QDISC_STATE_SCHED too.
> > 
> > We could probably even think of using this flag napi_disable() way.
> 
> Here (in dev_deactivate), ->qdisc is going to now be &noop_qdisc or
> similar.  Asynchronous contexts can run into that thing as much as
> they want :-)

Thats why I still think a "common" RCU with rcu_dereference() (from
dev_queue pointer) in net_tx_action() should be enough: after
synchronize_rcu() in dev_deactivate() we are sure any qdisc_run(),
from dev_queue_xmit() or net_tx_action() can only see and lock
noop_qdisc. Any activities on qdisc_sleeping can't happen so no
need to wait for this. There could be some skbs enqueued just before
synchronize, and they could be ->reset() and ->destroy() just after,
even without rcu_call().

Otherwise, I think you would better send some code example with these
flags, so we could be sure there is no misunderstanding around this.

Jarek P.
