From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Mon, 25 Aug 2008 06:06:40 +0000
Message-ID: <20080825060640.GA2633@ff.dom.local>
References: <20080824075331.GA2721@ami.dom.local> <1219585163.4698.43.camel@localhost> <20080824191905.GA3372@ami.dom.local> <20080824.174949.118585414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.182]:8445 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbYHYGGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 02:06:46 -0400
Received: by ik-out-1112.google.com with SMTP id c28so1254858ika.5
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2008 23:06:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080824.174949.118585414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 24, 2008 at 05:49:49PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 24 Aug 2008 21:19:05 +0200
> 
> > On Sun, Aug 24, 2008 at 09:39:23AM -0400, jamal wrote:
> > ...
> > > With current controls being per qdisc instead of per netdevice,
> > > the hol fear is unfounded. 
> > > You send and when hw cant keep up, you block just the one hwqueue.
> > > While hwqueue is blocked, you can accumulate packets in the prio qdisc
> > > (hence my statement it may not be necessary to accumulate packets in
> > > driver).
> > 
> > Jamal, maybe I miss something, but this could be like this only with
> > default pfifo_fast qdiscs, which really are per dev hwqueue. Other
> > qdiscs, including prio, are per device, so with prio, if a band with
> > the highest priority is blocked it would be requeued blocking other
> > bands (hwqueues in Alexander's case).
> 
> It only blocks if the highest priority band's HW queue is blocked, and
> that's what you want to happen.
> 
> Think about it, if the highest priority HW queue is full, queueing
> packets to the lower priority queues won't make anything happen.
> 
> As the highest priority queue opens up and begins to have space,
> we'll feed it high priority packets from the prio qdisc, and so
> on and so forth.

It seems the priority can really be misleading here. Do you mean these
hwqueues are internally prioritized too? This would be strange to me,
because why would we need this independent locking per hwqueue if
everything has to wait for the most prioritized hwqueue anyway? And,
if so, current dev_pick_tx() with simple_tx_hash() would always harm
some flows directing them to lower priority hwqueues?!

But, even if it's true, let's take a look at fifo: a packet at the
head of the qdisc's queue could be hashed to the last hwqueue. If
it's stopped for some reason, this packed would be constantly
requeued blocking all other packets, while their hwqueues are ready
and empty!

Jarek P.
