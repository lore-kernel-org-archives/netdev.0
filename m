From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Fri, 22 Aug 2008 17:01:50 -0700
Message-ID: <5f2db9d90808221701t4c576282m34a46999b76b6e83@mail.gmail.com>
References: <1219415417.4672.79.camel@localhost>
	 <20080822221913.GA2981@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, "David Miller" <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:3853 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953AbYHWABv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 20:01:51 -0400
Received: by yx-out-2324.google.com with SMTP id 8so434443yxm.1
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 17:01:50 -0700 (PDT)
In-Reply-To: <20080822221913.GA2981@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 3:19 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> jamal wrote, On 08/22/2008 04:30 PM:
> ...
>> There are two issues at stake:
>> 1) egress Multiq support and the desire to have concurency based on
>> however many cpus and hardware queues exist on the system.
>> 2) scheduling of the such hardware queues being executed by the hardware
>> (and not by software).
>>
>> Daves goal: #1; run faster than Usain Bolt.
>
> Looks fine.
>
In the case of this scheduler our main focus is QOS and then
performance.  Basically I was trying to achieve the goal of setting up
the queues as needed without forcing a serious change in the current
transmit path or seriously impacting performance.  I figure since all
I am doing is restoring part of what was there for 2.6.26 the
likelihood of this causing a performance regression is small.

>> What we were solving at the time: #2. My view was to solve it with
>> minimal changes.
>>
>> #1 and #2 are orthogonal. Yes, there is religion: Dave yours is #1.
>> Intels is #2; And there are a lot of people in intels camp because
>> they bill their customers based on qos of resources. The wire being one
>> such resource.
>
> If we can guarentee that current, automatic steering gives always the
> best performance than David seems to be right. But I doubt it, and
> that's why I think such a simple, manual control could be useful.
> Especially if it doesn't add much overhead.

I am almost certain that David's approach using the hash will show
better performance than the multiqueue prio qdisc would.  The
multiqueue prio qdisc is meant to allow for classification of traffic
into separate traffic classes to support stuff like Enhanced Ethernet
for Data Center (EEDC) / Data Center Bridging (DCB).  Basically we
can't use the hash to place things into the correct queue because each
hardware queue has a specific traffic class assigned to it, and the
queue can be stopped via priority flow control packets leaving the
other queues still going.  The multiqueue prio qdisc will allow all of
the other traffic classes on the other queues to continue flowing
without causing any head-of-line issues simply because one queue is
stopped.

>
>> Therefore your statement that these schemes exist to "enforce fairness
>> amongst the TX queues" needs to be qualified mon ami;-> The end parts of
>> Animal Farm come to mind: Some animals have more rights than others;->
>
> Sure, but shouldn't this other kind of fairness be applied on lower
> levels?
>
> Cheers,
> Jarek P.

This qdisc isn't so much about fairness as just making sure that the
right traffic gets to the right tx queue, and that there are no
head-of-line issues that occur between traffic classes in the process.
One of the things I looked at was slipping an extra pass-thru qdisc
into the path prior to, or as part of, dev->select_queue.  It would
have required some serious changes to the transmit path in addition to
application changes to iproute2 in order to support adding rules on
yet another qdisc layer in the transmit path, with all the changes
that would have been required the risk was high so I defaulted to what
was already there prior to 2.6.27.  The multiqueue prio qdisc had been
in the kernel since 2.6.23 and already has an existing interface for
enabling it in iproute2 so the transition back to it should be fairly
seamless and the risk should be low.

Thanks,

Alex
