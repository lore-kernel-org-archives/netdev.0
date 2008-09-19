From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] sched: only dequeue if packet can be queued to
	hardware queue.
Date: Fri, 19 Sep 2008 19:35:23 +0200
Message-ID: <20080919173523.GA2888@ami.dom.local>
References: <20080918063036.27934.91273.stgit@localhost.localdomain> <20080918194419.GA2982@ami.dom.local> <20080919151632.GB2646@ami.dom.local> <80769D7B14936844A23C0C43D9FBCF0F1598E4A3@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:34107 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbYISReG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 13:34:06 -0400
Received: by nf-out-0910.google.com with SMTP id d3so210310nfc.21
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2008 10:34:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F1598E4A3@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2008 at 09:26:29AM -0700, Duyck, Alexander H wrote:
...
> Actually most of that is handled in the fact that netif_tx_wake_queue
> will call __netif_schedule when it decides to wake up a queue that has
> been stopped.  Putting it in skb_dequeue is unnecessary,

You are right, I've just noticed this too, and I'll withdraw this change.

> and the way
> you did it would cause issues because you should be scheduling the root
> qdisc, not the one currently doing the dequeue.

I think, this is the right way (but useless here).

> My bigger concern is the fact one queue is back to stopping all queues.
> By using one global XOFF state, you create head-of-line blocking.  I can
> see the merit in this approach but the problem is for multiqueue the
> queues really should be independent.  What your change does is reduce the
> benefit of having multiqueue by throwing in a new state which pretty much
> matches what netif_stop/wake_queue used to do in the 2.6.26 version of tx
> multiqueue.

Do you mean netif_tx_stop_all_queues() and then netif_tx_wake_queue()
before netif_tx_wake_all_queues()? OK, I'll withdraw this patch too.

> Also changing dequeue_skb will likely cause additional issues for
> several qdiscs as it doesn't report anything up to parent queues, as a
> result you will end up with qdiscs like prio acting more like multiq
> because they won't know if a queue is empty, stopped, or throttled.
> Also I believe this will cause a panic on pfifo_fast and several other
> qdiscs because some check to see if there are packets in the queue and
> if so dequeue with the assumption that they will get a packet out.  You
> will need to add checks for this to resolve this issue.

I really can't get your point. Don't you mean skb_dequeue()?
dequeue_skb() is used only by qdisc_restart()...

> The one thing I liked about my approach was that after I was done you
> could have prio as a parent of multiq leaves or multiq as the parent of
> prio leaves and all the hardware queues would receive the packets in the
> same order as the result.

I'm not against your approach, but I'd like to be sure these
complications are really worth of it. Of course, if my proposal, the
first take of 3 patches, doesn't work as you predict (and I doubt),
then we can forget about it.

Thanks,
Jarek P.
