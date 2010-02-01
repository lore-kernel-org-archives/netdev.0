From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH ver2] Avoid enqueuing skb for default qdiscs
Date: Mon, 1 Feb 2010 19:12:06 +0530
Message-ID: <OF6B2AD304.3AD05621-ON652576BD.0047556A-652576BD.004B1F23@in.ibm.com>
References: <20090806114421.19208.39374.sendpatchset@localhost.localdomain> <1265017940.32192.23.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	Jarek Poplawski <jarkao2@gmail.com>, kaber@trash.net,
	netdev@vger.kernel.org
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:47172 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149Ab0BANkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 08:40:37 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id o11D6UIN008345
	for <netdev@vger.kernel.org>; Mon, 1 Feb 2010 18:36:30 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o11DeYqA1208522
	for <netdev@vger.kernel.org>; Mon, 1 Feb 2010 19:10:34 +0530
Received: from d28av06.in.ibm.com (loopback [127.0.0.1])
	by d28av06.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o11DeYHn020944
	for <netdev@vger.kernel.org>; Mon, 1 Feb 2010 19:10:34 +0530
In-Reply-To: <1265017940.32192.23.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Maxime,

Maxime Bizon <mbizon@freebox.fr> wrote on 02/01/2010 03:22:20 PM:

> Sorry old stuff, but I just noticed this.
>
> One side effect of this patch is that tc now shows a lot of requeue for
> slow interfaces (slow dsl link in my case), because sch_direct_xmit is
> called even if device stopped its queue.

sch_direct_xmit can be called from dev_queue_xmit for a
stopped device only if the device had xmit the previous
skb, stopped the device and returned OK. Then the next
sch_d_x will dequeue and requeue the new skb. But from
now on, sch_d_x is never called from dev_queue_xmit
since qdisc_qlen(q) > 0. Instead dev_queue_xmit enqueue's
the skb and calls qdisc_restart, which calls dequeue_skb.
dequeue_skb finds there is an earlier gso_skb but since
the device is stopped, it returns NULL. Hence there
should be only one requeue (and dequeue) for every stop.

BTW, I don't think this patch would change the earlier
behavior. The old code would have done the same thing.

> My first reflex was too investigate for a misbehaving driver (returning
> TX_BUSY), but start_xmit is not even called, sch_direct_xmit notices
> that queue is stopped, and just does a dequeue/requeue.

As I explained, this should happen only once per stop event.
Could you tell which driver is having this problem? Is it
waking up too early, eg, it might be stopping when the hw tx
descriptor is full but waking up when a few slots open up,
and those will get filled up immediately on fast systems.
Then you will see a lot of requeue's.

> Since we're talking about slow interfaces, this has no impact on
> performance, the requeue counter incrementing is just a bit scary.
>
> Shouldn't we check for stopped queue earlier to avoid this ?

dev_queue_xmit is checking for qdisc_qlen == 0 before calling
sch_direct_xmit, which is enough for all stopped queue except
the first time. Also, it's not possible to check for stopped
Q earlier in qdisc_restart() due to multiqueue implementation.

Please let me know if you find something different from what
I have described.

thanks,

- KK

