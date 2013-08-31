From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [BUG] missing rcu_derefernce of txq->qdisc
Date: Sat, 31 Aug 2013 10:23:54 -0700
Message-ID: <20130831102354.3ff9cc53@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:39906 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501Ab3HaRX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 13:23:58 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so3094705pbc.22
        for <netdev@vger.kernel.org>; Sat, 31 Aug 2013 10:23:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Way back in 2008, this commit added rcu_assign_pointer for the dev_queue->qdisc.
But we aren't using rcu_dereference to fetch the pointer, here and a couple
of other places. This is probably harmless, but could cause issues when compiler
decides to optimizations because of missing barrier.

static inline void netif_schedule_queue(struct netdev_queue *txq)
{
	if (!(txq->state & QUEUE_STATE_ANY_XOFF))
		__netif_schedule(txq->qdisc);
}

Adding the needed rcu_dereference creates other problems because the the
struct Qdisc needs to be fully known, net/sch_generic.h has to be included
from netdevice.h which creates other build problems.

A good way to see all the fallout is to put needed __rcu annotation
on netdev_tx_queue qdisc and use sparse.

I don't have time or patience to deal with it right now, maybe someone
else could have a go at it.
