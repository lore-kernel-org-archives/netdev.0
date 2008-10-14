From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Tue, 14 Oct 2008 13:39:23 +0200
Message-ID: <48F484EB.8000201@trash.net>
References: <20081014095246.GA10804@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33434 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755255AbYJNLj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 07:39:27 -0400
In-Reply-To: <20081014095246.GA10804@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> The aim of this patch-set is to finish changes proposed by David S.
> Miller in his patch-set with the same subject from Mon, 18 Aug 2008.
> The first two patches were applied with some modifications, so, to
> apply the rest, there were needed some changes.
> 
> Original David's patches include additional info, but signed-off-by
> is removed because of changed context. I expect they will be merged
> and signed off by David as an author, anyway.
> 
> The qdisc->requeue list idea is to limit requeuing to one level only,
> so a parent can requeue to its child only. This list is then tried
> first while dequeuing (qdisc_dequeue()), except at the top level,
> so packets could be requeued only by qdiscs, not by qdisc_restart()
> after xmit errors.

I didn't follow the original discussion, but I'm wondering what
the reasoning is why these patches won't have negative impact
on latency. Consider these two scenarios with HFSC or TBF:

current situation:

- packet is dequeued and sent
- next packet is peeked at for calculating the deadline
- watchdog is scheduled
- higher priority packet arrives and is queued to inner qdisc
- dequeue is called again, qdisc is overlimit, so peeks again
- watchdog is rescheduled based on higher priority packet

without ->requeue:

- packet is dequeued and sent
- next packet is peeked at for calculating the deadline and
   put into private "requeue" queue
- watchdog is scheduled
- higher priority packet arrives and is queued to inner qdisc
- dequeue is called again, qdisc is overlimit, so peeks again
- higher priority packet doesn't affect watchdog rescheduling
   since we still have one in the private queue
- lower priority packet is sent, assuming qdisc is overlimit
   watchdog is then rescheduled based on higher priority packet

The end result is that the worst case latency for a packet increases
by a full packet transmission time. This may not matter much for high
bandwidth connections, but for f.i. with a 1mbit connection it adds a
full 12ms for a MTU of 1500, which is clearly in the noticable range.

I'm not opposed to killing top-level ->requeue since in that case
the qdisc has already decided to send the packet and if it affects
latency, the qdisc is misconfigured to use too much bandwidth.
Qdisc' use of ->requeue can only be removed without bad side effects
for the CBQ case of overlimit handling, it shouldn't matter much
since CBQ is not very accurate anyways. For the ->peek case (HFSC,
TBF, I think also netem) we really need the peek semantic to avoid
these side effects.

It should actually be pretty easy because for every ->enqueue call,
there is at least one immediately following ->dequeue call, which
gives an upper qdisc a chance to reschedule the watchdog when
conditions change. So what should work is having the requeue-queue
(actually, just an skb pointer) within the innermost qdisc instead
of one level higher, as in your patches.

On a ->peek operation, the qdisc would simply do what is currently
done in ->dequeue, but instead of removing the packet from its
private queues, it would set the pointer to point to the chosen
packet and return it to the upper qdisc. The upper qdisc can use
this for watchdog scheduling. If the next event is a dequeue event
(meaning the watchdog expired), it removes the peeked packet from
the private queues and returns it to the upper qdisc again. If the
next event is an enqueue event, it can replace the pointer
unconditionally since the upper qdisc will immediately call
->dequeue or ->peek again, giving it a chance to reschedule based
on the changed conditions.

So the implementation would probably roughly look like this:

- split ->dequeue into a queue and packet selection operation, setting
   the above mentioned pointer, and an actual dequeue operation to
   remove the selected packet from the queue.

- the queue and packet selection operation is at the same time the
   ->peek operation

