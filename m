From: David Miller <davem@davemloft.net>
Subject: Re: [net-tx-2.6 PATCH]: Push TX lock down into drivers
Date: Fri, 27 Jun 2008 04:19:17 -0700 (PDT)
Message-ID: <20080627.041917.193698243.davem@davemloft.net>
References: <20080625.013355.229057310.davem@davemloft.net>
	<20080626.023555.71060613.davem@davemloft.net>
	<4864C9B7.4070003@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753590AbYF0LTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 07:19:17 -0400
In-Reply-To: <4864C9B7.4070003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 27 Jun 2008 13:06:31 +0200

> David Miller wrote, On 06/26/2008 11:35 AM:
> ...
> 
> > I've also written up a blog
> > entry about netdev TX locking at the usual spot:
> > 
> >       http://vger.kernel.org/~davem/cgi-bin/blog.cgi/index.html
> 
> ...So, why exactly this nice lady didn't like new TX locking?

Actually that photo is from a trip to cut down a Christmas tree at a
local tree farm up in the Cascade mountains 2 years ago :-)

And this lady would have good reason to not like the new TX locking I
had proposed, it was completely the wrong approach.

I have a new set of patches which already seems a lot saner and
should be in a state I can publish in a few days.

The new idea is to replicate the qdisc state and the TX lock
into an array of per-queue state blobs.  So we now have:

--------------------
enum netdev_tx_state_t
{
	__LINK_TX_STATE_XOFF=0,
	__LINK_TX_STATE_QDISC_RUNNING,
};

struct netdev_tx_queue {
	spinlock_t		lock;
	unsigned long		state;
	spinlock_t		_xmit_lock;
	struct Qdisc		*qdisc;
	struct netdev_tx_queue	*next_sched;
	struct net_device	*dev;
	struct Qdisc		*qdisc_sleeping;
	struct list_head	qdisc_list;
};
--------------------

And struct net_device gets:

____________________
	struct netdev_tx_queue	*_tx ____cacheline_aligned_in_smp;
	unsigned short		num_tx_queues;
	unsigned short		real_num_tx_queues;
	unsigned int		tx_queue_len;
--------------------

It's done in such a way that non-multiqueue drivers simply keep on
working out of the box.  For example, all the existing
non-multiqueue-aware interfaces simply operate on queue 0.

The part I haven't coded up yet is the qdisc replication bits.  But
once that's done all I really need to do is grind through the patch
set with allmodconfig/allyesconfig test builds before posting a first
draft.

Not having to touch 400 drivers this time around is a good initial
sign :)
