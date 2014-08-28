From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Thu, 28 Aug 2014 03:42:54 +0200
Message-ID: <1409190174.27664.10.camel@localhost>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	 <1409142672.26515.24.camel@localhost>
	 <20140827.134510.2172564669938048576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com, brouer@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:55043 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932384AbaH1Bm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 21:42:57 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 349802084D
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 21:42:57 -0400 (EDT)
In-Reply-To: <20140827.134510.2172564669938048576.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mi, 2014-08-27 at 13:45 -0700, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 27 Aug 2014 14:31:12 +0200
> 
> > On Mo, 2014-08-25 at 16:34 -0700, David Miller wrote:
> >> Given Jesper's performance numbers, it's not the way to go.
> >> 
> >> Instead, go with a signalling scheme via new boolean skb->xmit_more.
> >> 
> >> This has several advantages:
> >> 
> >> 1) Nearly trivial driver support, just protect the tail pointer
> >>    update with the skb->xmit_more check.
> > 
> > One thing one should keep in mind is, that there must be a skb available
> > to trigger the flush, maybe this will hurt us one day.
> > 
> > Thinking more about it should we go with a coccinelle script and
> > replace/extend ndo_start_xmit with an additional argument?
> > 
> > We can also add a new function pointer and call that instead of
> > ndo_start_xmit. I think only the callq *%rax hurts performance.
> 
> I don't think we will have any problems here, the caller will always
> be the entity which analyzes the upcoming set of SKBs to submit and
> tag them properly.
> 
> I really do not want to add a new OP and I even more so do not want to
> adjust the ndo_start_xmit() signature.  It's effect is far reaching,
> and for absolutely no gain as far as I can see.
> 
> Thanks.

Just brainstorming a bit:

I wonder if we still might need a separate call for tx_flush, e.g. for
af_packet if one wants to allow user space control of batching, MSG_MORE
with tx hangcheck (also in case user space has control over it) or
implement TCP_CORK alike option in af_packet. Even in the case we
someday might allow concurrent dequeueing from a qdisc we might want to
use xmit_more opportunistic (also user space might use xmit_more
opportunistic if dequeueing from lockless data structures). I just want
to ensure we thought about possible reuses of this driver api change. ;)

To do so just some proposals:

1) export tx_flush function nonetheless but normal/fast path just depends on
skb->xmit_more (so driver just does a static call to the flushing
function, no indirection here). We would keep the ndo_op for flushing
around, but ndo_start_xmit must still honor xmit_more by itself.
af_packet sockets could then flush the queues separately if wanted. Also if
ndo_op != NULL we know that driver supports batching.

2) add new op like ndo_start_xmit_flags op with an additional flags
parameter and document that NULL skbs can happen. In this case tx-queue
should only get flushed. By checking for the new method we also know
that the driver supports batching.

3) provide special skb (only head) with no data to ndo_start_xmit which
only clears the queue but prepare drivers to not enqueue any new data.
I am concerned that if user space can control batching to the NIC we can
have side-effects if user space did not flush the queue of the nic
before and we dequeue more packets from qdisc into the same nic's tx
queue.


Allowing user space control over batching might make the conversion of
drivers more painful, as driver might have to check for "dirtiness"
before it tries to enqueue the packet internally. (To track queueing
state of nic we also must track the state globally per queue which might
also become a performance problem cache trashing wise, I am unsure about
that; at least seems not to be the case with bql. My idea was a tx-queue
dirty bit somewhere, or check bql state before submitting skb. But maybe
one has to extend bql to keep track of unflushed vs. flushed skbs to
make this safe.)

If queuing failed because of missing tx_flush we either have to requeue
the skb to the qdisc or do a fast retry, but I don't think that NICs
will catch up that fast, no? Or can we just blame user space
applications that they are wrong if they use xmit_more irresponsible?

I liked the separate ndo ops approach because it seemed so very well
extendable to me. :/

I know that these concerns a bit messy but wanted to share them
nonetheless. Maybe they are all void in the end. ;)

Also maybe these concerns can get solved by the addition of future
AF_PACKETV4 ndo ops and we can just postpone this discussion.

Bye,
Hannes
