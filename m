From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [RFC PATCH] sched: only dequeue if packet can be queued to
	hardware queue.
Date: Fri, 19 Sep 2008 11:01:12 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F1598E7E1@orsmsx501.amr.corp.intel.com>
References: <20080918063036.27934.91273.stgit@localhost.localdomain>
 <20080918194419.GA2982@ami.dom.local> <20080919151632.GB2646@ami.dom.local>
 <80769D7B14936844A23C0C43D9FBCF0F1598E4A3@orsmsx501.amr.corp.intel.com>
 <20080919173523.GA2888@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38578 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754705AbYISSBr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 14:01:47 -0400
In-Reply-To: <20080919173523.GA2888@ami.dom.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:

>> Also changing dequeue_skb will likely cause additional issues for
>> several qdiscs as it doesn't report anything up to parent queues, as
>> a result you will end up with qdiscs like prio acting more like
>> multiq because they won't know if a queue is empty, stopped, or
>> throttled.
>> Also I believe this will cause a panic on pfifo_fast and several
>> other qdiscs because some check to see if there are packets in the
>> queue and if so dequeue with the assumption that they will get a
>> packet out.  You will need to add checks for this to resolve this
>> issue.
>
> I really can't get your point. Don't you mean skb_dequeue()?
> dequeue_skb() is used only by qdisc_restart()...
You're right.  I misread it as skb_dequeue.  The problem is though you
are still relying on q->requeue which last I knew was only being used
a few qdiscs.  In addition you will still be taking the cpu hit for the
dequeue/requeue on several qdiscs which can't use q->requeue without
violating the way they were supposed to work.

>> The one thing I liked about my approach was that after I was done you
>> could have prio as a parent of multiq leaves or multiq as the parent
>> of prio leaves and all the hardware queues would receive the packets
>> in the same order as the result.
>
> I'm not against your approach, but I'd like to be sure these
> complications are really worth of it. Of course, if my proposal, the
> first take of 3 patches, doesn't work as you predict (and I doubt),
> then we can forget about it.
Well when you get some testing done let me know.  The main areas I am
concerned with are:

1.  CPU utilization stays the same regardless of which queue used.
2.  Maintain current qdisc behavior on a per hw queue basis.
3.  Avoid head-of-line blocking where it applies
        for example: prio band 0 not blocked by band 1, or 1 by 2, etc..
                                or
                         multiq not blocked on any band due to 1 band blocked

As long as all 3 criteria are met I would be happy with any solution
provided.

Thanks,

Alex
