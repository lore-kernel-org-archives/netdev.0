From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [RFC PATCH] sched: only dequeue if packet can be queued to
	hardware queue.
Date: Fri, 19 Sep 2008 09:26:29 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F1598E4A3@orsmsx501.amr.corp.intel.com>
References: <20080918063036.27934.91273.stgit@localhost.localdomain>
 <20080918194419.GA2982@ami.dom.local> <20080919151632.GB2646@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37766 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752464AbYISQ0b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 12:26:31 -0400
In-Reply-To: <20080919151632.GB2646@ami.dom.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Thu, Sep 18, 2008 at 09:44:19PM +0200, Jarek Poplawski wrote:
>> Alexander Duyck wrote, On 09/18/2008 08:43 AM:
>> ...
>>> ---
>>> This patch changes the behavior of the sch->dequeue to only
>>> dequeue a packet if the queue it is bound for is not currently
>>> stopped.  This functionality is provided via a new op called
>>> smart_dequeue.
>>>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>>> ---
>
> Alexander, I guess you've seen my last messages/patches in this thread
> and noticed that this __netif_schedule() problem is present both in
> this RFC patch and sch_multiq: if skb isn't dequeued because of inner
> tx_queue stopped state check, there is missing __netif_schedule()
> before exit from qdisc_run().
>
> Jarek P.

Actually most of that is handled in the fact that netif_tx_wake_queue
will call __netif_schedule when it decides to wake up a queue that has
been stopped.  Putting it in skb_dequeue is unnecessary, and the way
you did it would cause issues because you should be scheduling the root
qdisc, not the one currently doing the dequeue.

My bigger concern is the fact one queue is back to stopping all queues.
By using one global XOFF state, you create head-of-line blocking.  I can
see the merit in this approach but the problem is for multiqueue the
queues really should be independent.  What your change does is reduce the
benefit of having multiqueue by throwing in a new state which pretty much
matches what netif_stop/wake_queue used to do in the 2.6.26 version of tx
multiqueue.

Also changing dequeue_skb will likely cause additional issues for
several qdiscs as it doesn't report anything up to parent queues, as a
result you will end up with qdiscs like prio acting more like multiq
because they won't know if a queue is empty, stopped, or throttled.
Also I believe this will cause a panic on pfifo_fast and several other
qdiscs because some check to see if there are packets in the queue and
if so dequeue with the assumption that they will get a packet out.  You
will need to add checks for this to resolve this issue.

The one thing I liked about my approach was that after I was done you
could have prio as a parent of multiq leaves or multiq as the parent of
prio leaves and all the hardware queues would receive the packets in the
same order as the result.

Thanks,

Alex
