From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network optimality (was Re: [PATCH net-next] qdisc: validate
 skb without holding lock_
Date: Mon, 13 Oct 2014 09:58:52 -0700
Message-ID: <1413219532.9362.109.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAA93jw58cBPToe7oL6YH-178n2jg+qh5GYJW7Ww9NHgcb5QPnA@mail.gmail.com>
	 <CAL4WiioOodM60_Ud6qyGt1_uyeqpDeGFF6PtEKtGa=NwHhVFiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:55964 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbaJMQ7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 12:59:07 -0400
Received: by mail-pa0-f52.google.com with SMTP id fb1so6074156pad.25
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 09:59:06 -0700 (PDT)
In-Reply-To: <CAL4WiioOodM60_Ud6qyGt1_uyeqpDeGFF6PtEKtGa=NwHhVFiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Oct 13, 2014 7:22 AM, "Dave Taht" <dave.taht@gmail.com> wrote:
>         When I first got cc'd on these threads, and saw
>         netperf-wrapper being
>         used on it,
>         I thought: "Oh god, I've created a monster.". My intent with
>         helping create
>         such a measurement tool was not to routinely drive a network
>         to saturation
>         but to be able to measure the impact on latency of doing so.
>         
>         I was trying get reasonable behavior when a "router" went into
>         overload.
>         
>         Servers, on the other hand, have more options to avoid
>         overload than
>         routers do. There's been a great deal of really nice work on
>         that
>         front. I love all that.
>         
>         and I like BQL because it provides enough backpressure to be
>         able to
>         do smarter things about scheduling packets higher in the
>         stack. (life
>         pre-BQL cost some hair)
>         
>         But tom once told me me "BQL's objective is to keep the
>         hardware busy".
>         It uses an MIAD controller instead of a more sane AIMD one, in
>         particular,
>         I'd much rather it ramped down to smaller values after
>         absorbing a burst.
>         
>         My objective is always to keep the *network's behavior
>         optimal*,
>         minimizing bursts, and subsequent tail loss on the other side,
>         and responding quickly to loss, and doing that by
>         preserving to the highest extent possible the ack clocking
>         that a
>         fluid model has. I LOVE BQL for providing more backpressure
>         than has
>         ever existed before, and I know it's incredibly difficult to
>         have fluid models
>         in a conventional cpu architecture that has to do other stuff.
>         
>         But in order to get the best results for network behavior I'm
>         willing to
>         sacrifice a great deal of cpu, interrupts, whatever it takes!
>         to get the
>         most packets to all the destinations specified, whatever the
>         workload,
>         with the *minimum amount of latency between ack and reply*
>         possible.
>         
>         What I'd hoped for in the new bulking and rcu stuff was to be
>         able to
>         see a net reduction in TSO/GSO Size, and/or BQL's size, and I
>         also did
>         keep hoping for some profiles on sch_fq, and for more complex
>         benchmarking of dozens or hundreds of realistically sized TCP
>         flows
>         (in both directions) to exercise it all.
>         
>         Some of the data presented showed that a single BQL'd queue
>         was >400K,
>         and with hardware multi-queue, 128K, when TSO and GSO were
>         used, but
>         with hardware multi-queue and no TSO/GSO, BQL was closer to
>         30K.
>         
>         This said to me that the maximum "right" size for a TSO/GSO
>         "packet" was
>         closer to 12k in this environment, and the right size for BQL,
>         30k,
>         before it started exerting backpressure to the qdisc.
>         
>         This would reduce the potential inter-flow network latency by
>         a factor
>         of 10 on the single hw queue scenario, and 4 in the multi
>         queue one.
>         
>         It would probably cost some interrupts, and in scenarios
>         lacking
>         packet loss, throughput, but in other scenarios with lots of
>         flows
>         each flow will ramp up in speed, faster, as you reduce the
>         RTTs.
>         Paying attention to this will also push profiling activities
>         into
>         areas of the stack that might be profitable.
>         
>         I would very much like to have profiles of happens now both
>         here and
>         elsewhere in the stack with this new code with TSO/GSO sizes
>         capped
>         thusly and BQL capped to 30k, and a smarter qdisc like fq
>         used.
>         
>         2) Most of the time, a server is not driving the wire to
>         saturation. If
>            it is, you are doing something wrong. The BQL queues are
>         empty, or
>            nearly so, so the instant someone creates a qdisc queue, it
>            drains.
>         
>         But: if there are two or more flows under contention, creating
>         a qdisc queue
>             better multiplexing the results is highly desirable, and
>         the stack
>            should be smart enough to make that overload only last
>         briefly.
>         
>            This is part of why I'm unfond of the deep and persistent
>         BQL queues as we
>         get today.
>         
>         3) Pure ack-only workloads are rare. It is a useful test case,
>         but...
>         
>         4) I thought the ring-cleanup optimization was rather
>         interesting and
>            could be made more dynamic.
>         
>         5) I remain amazed at the vast improvements in throughput,
>         reductions in
>         interrupts, lockless operation and the RCU stuff that have
>         come out of
>         this so far, but had to make these points in the hope that the
>         big picture
>         is retained.
>         
>         It does no good to blast packets through the network unless
>         there is a
>         high probability that they will actually be received on the
>         other side.
>         
>         thanks for listening.

Dave

I am kind of surprised you wrote this nonsense.

Being able to send data at full speed has nothing to do about how
packets are scheduled. You are concerned about packet scheduling, and
not about how fast we can send raw data on a 40Gb NIC.

We made all these changes so that we can spend cpu cycles at the right
place.

There are reasons we have fq_codel, and fq. Do not forget this, please.

Take a deep breath, some coffee, and rethink.

Thanks
