From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sun, 17 Aug 2008 16:03:29 -0700 (PDT)
Message-ID: <20080817.160329.121812684.davem@davemloft.net>
References: <20080814084429.GB12217@ff.dom.local>
	<20080814085250.GC12217@ff.dom.local>
	<20080817.155723.214209606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39063
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752419AbYHQXDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 19:03:30 -0400
In-Reply-To: <20080817.155723.214209606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 17 Aug 2008 15:57:23 -0700 (PDT)

> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 14 Aug 2008 08:52:50 +0000
> 
> > On the other hand... such a flag would be probably for one thing only.
> > And if we would have a "netif_scheduled_without_xmitting" counter this
> > could probably make 2 in 1?
> 
> Here is how I propose to plug this hole.  The issue is that there is
> this potential gap where both bits are clear while there is a context
> that can reschedule the qdisc.

My apologies Jarek, this is largely identical to a patch you posted
already.  Sorry :(

I thought about it some more, but there is still the dev_queue_xmit()
context that can have a reference to the old qdisc, be about to take
the qdisc lock and feed packets into it's ->enqueue().

That's why we need the RCU destruction still.  dev_deactivate() really
doesn't clear out all references to the qdisc fully.

It might be a better approach to work on making that simply not matter,
and just rely on RCU or similar to defer destruction and any real state
changes internally to the qdisc tree will simply use the root qdisc's
lock to block out enqueue/dequeue/requeue calls.

In that kind of scheme dev_deactivate() just sets the RCU pointer and
doesn't sit around waiting for anything.
