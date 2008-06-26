From: David Miller <davem@davemloft.net>
Subject: Re: [net-tx-2.6 PATCH]: Push TX lock down into drivers
Date: Thu, 26 Jun 2008 02:35:55 -0700 (PDT)
Message-ID: <20080626.023555.71060613.davem@davemloft.net>
References: <20080625.013355.229057310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53177
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752548AbYFZJfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 05:35:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B927CC8C192
	for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 02:35:55 -0700 (PDT)
In-Reply-To: <20080625.013355.229057310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 25 Jun 2008 01:33:55 -0700 (PDT)

> Here is the patch I've been crunching on the past few days.

So after spending all of that time hand-editing 350+ drivers I realize
that my approach is all wrong :-)  I've also written up a blog
entry about netdev TX locking at the usual spot:

      http://vger.kernel.org/~davem/cgi-bin/blog.cgi/index.html

I tried today to take the next step and actually remove the
netdev->_xmit_lock and the problems became clear.

My new plan is to move the qdisc state down into the drivers too.  And
also perhaps provide a better transition path.

There is, of course, the question of semantics.

Currently I think we should:

1) By default do pure replication.  If qdisc X is configured for
   device Y, then X is configured for each of device Y'd transmit
   queues.

2) A "TX queue index" attribute is added for qdisc netlink config
   messages.  If present, the request applies only to the qdisc of a
   specific transmit queue of the device.  Otherwise we replicate the
   request onto all transmit queues.

This would mean that old tools work and do something mostly sane on
multiqueue devices.

Maybe in the end this is nicer.  All the qdisc management can move
under the driver's ->tx_lock.  Or even, the qdisc can be the locked
element.  The idea being we stick a lock in there and that's what the
driver holds across ->hard_start_xmit().

Qdisc running will thus be naturally batched, rather than the ad-hoc
scheme we have now where we set some "running the queue" state bit
since we can't hold the qdisc lock and the TX lock at the same time.

In this manner the qdisc object works sort of like a NAPI context.  It
provides the synchronization and packet processing locking semantics.

The only part I haven't figured out is how to glue the scheduler
API bits down into the per-queue qdiscs.

Another thing I noticed in all of this is that we perhaps want to
replicate the ingress qdisc bits when there are multiple receive
queues.

One thing I want to avoid, for the TX qdiscs, is having some array of
pointers and a TX queue count stored in the netdev struct.

Anyways, I'll see if this works out.
