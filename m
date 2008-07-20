From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
	RCU.
Date: Sun, 20 Jul 2008 11:16:03 -0400
Message-ID: <1216566963.4847.81.camel@localhost>
References: <487FDA67.30902@trash.net> <1216386624.4833.94.camel@localhost>
	 <1216387641.4833.96.camel@localhost>
	 <20080718.140539.122169028.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:33051 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757940AbYGTPQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 11:16:07 -0400
Received: by py-out-1112.google.com with SMTP id p76so815845pyb.10
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2008 08:16:06 -0700 (PDT)
In-Reply-To: <20080718.140539.122169028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-18-07 at 14:05 -0700, David Miller wrote:

> The fundamental issue is what we believe qdiscs schedule, do they
> schedule a device, or do they schedule what their namesake implies,
> "queues"?

In the simple case of a single hardware queue/ring, the mapping between
a hardware queue and "physical wire" is one-to-one.
So in that case one could argue the root qdiscs are scheduling a device.

> Logically once we have multiple queues, we schedule queues.
> Therefore what probably makes sense is that for mostly stateless
> priority queueing such as pfifo_fast, doing prioritization at the
> queue level is OK.

IMO, in the case of multiple hardware queues per physical wire,
and such a netdevice already has a built-in hardware scheduler (they all
seem to have this feature) then if we can feed the hardware queues
directly, theres no need for any intermediate buffer(s).
In such a case, to compare with qdisc arch, its like the root qdisc is
in hardware.

The only need for intermediate s/ware queues is for cases of congestion.
If you could have a single software queue for each hardware queue, then
you still have the obligation of correctness to make sure higher prio
hardware rings get fed with packets first (depending on the hardwares
scheduling capability).

> But where non-trivial classification occurs, we have to either:
> 
> 1) Make the queue selection match what the classifiers would do
>    exactly.
> 
> OR
> 
> 2) Point all the queues at a single device global qdisc.
> 
> What we have now implements #2.  Later on we can try to do something
> as sophisticated as #1.

sure; i think you could achieve the goals by using the single queue with
a software pfifo_fast which maps skb->prio to hardware queues. such a
pfifo_fast may even sit in the driver. This queue will always be empty
unless you have congestion. The other thing is to make sure there is an
upper bound to the size of this queue; otherwise a remote bug could
cause it to grow infinitely and consume all memory.

cheers,
jamal




