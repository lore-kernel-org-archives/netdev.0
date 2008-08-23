From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Fri, 22 Aug 2008 23:35:24 -0700
Message-ID: <5f2db9d90808222335p223f1577l41841fb37490d85a@mail.gmail.com>
References: <5f2db9d90808221837h2f727478qf78bb6e6a2867802@mail.gmail.com>
	 <E1KWlQH-0001Ge-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jarkao2@gmail.com, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:54312 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667AbYHWGfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 02:35:31 -0400
Received: by yx-out-2324.google.com with SMTP id 8so478051yxm.1
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 23:35:30 -0700 (PDT)
In-Reply-To: <E1KWlQH-0001Ge-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 10:12 PM, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>>
>> That issue led me to the thought of creating a redirect action that
>> would take the packet from one qdisc to the correct qdisc for the
>> transmit queue.  That setup has two issues.  First, all traffic would
>> need to go to one queue by default to avoid a possible deadlock
>> condition in the event that two queues try to enqueue packets on one
>> another at the same time.  That combined with the fact that one packet
>
> That looks like a problem but it isn't.  When you're overriding
> the default queue selection you're breaking CPU affinity.  As such
> cache-line bouncing is clearly not a concern or you wouldn't be
> doing this (that is, you're doing this for QOS rather than CPU
> scalability).  So having everything go through a single qdisc
> shouldn't be a problem.
>
> Cheers,

It isn't the performance aspect of running everything through one
queue that I am concerned about since that is how it was working
before.  My concern is that the action could cause a dead lock if
simple_tx_hash places traffic on 2 queues and then the tc rule tried
to swap the traffic between those queues while they are each holding
their own queue locks.  The tc rule would have to receive all traffic
onto a single qdisc to prevent this, which would require setting
select_queue for the netdev to return a fixed queue.  The multiqueue
prio qdisc is flexible enough to allow all traffic to be directed to
one queue or be received on multiple queues without causing the system
to lock up which means that implementing select_queue on the device
wouldn't be mandatory.

Thanks,

Alex
