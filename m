From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] rps: overflow prevention for saturated cpus
Date: Thu, 6 Dec 2012 18:04:23 -0500
Message-ID: <CA+FuTSc=-TE4X=VWmdXMLhE_jn6CtjUpauznt4evrRLi-DOd2g@mail.gmail.com>
References: <1354826194-9289-1-git-send-email-willemb@google.com> <50C11B4D.4040109@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f179.google.com ([209.85.210.179]:48182 "EHLO
	mail-ia0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab2LFXEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 18:04:54 -0500
Received: by mail-ia0-f179.google.com with SMTP id o25so5227827iad.10
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 15:04:53 -0800 (PST)
In-Reply-To: <50C11B4D.4040109@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 6, 2012 at 5:25 PM, Rick Jones <rick.jones2@hp.com> wrote:
> On 12/06/2012 12:36 PM, Willem de Bruijn wrote:
>>
>> RPS and RFS balance load across cpus with flow affinity. This can
>> cause local bottlenecks, where a small number or single large flow
>> (DoS) can saturate one CPU while others are idle.
>>
>> This patch maintains flow affinity in normal conditions, but
>> trades it for throughput when a cpu becomes saturated. Then, packets
>> destined to that cpu (only) are redirected to the lightest loaded cpu
>> in the rxqueue's rps_map. This breaks flow affinity under high load
>> for some flows, in favor of processing packets up to the capacity
>> of the complete rps_map cpuset in all circumstances.
>
>
> I thought (one of) the ideas behind RFS at least was to give the CPU
> scheduler control over where network processing took place instead of it
> being dictated solely by the addressing. I would have expected the CPU
> scheduler to migrate some work off the saturated CPU.  Or will this only
> affect RPS and not RFS?

I wrote it with RPS in mind, indeed. With RFS, for sufficiently
multithreaded applications that are unpinned, the scheduler will
likely spread the threads across as many cpus as possible. In that
case, the mechanism will not kick in, or as quickly. Even with RFS,
pinned threads and single-threaded applications will likely also
benefit during high load from redirecting kernel receive
processing away from the cpu that runs the application thread. I
haven't tested that case independently.

> Allowing individual flows to straddle the CPUs - won't that be somewhat like
> what happens in bonding with mode-rr in the outbound case - packet
> reordering evil?

Yes, that's the main drawback.

> What kind of workload is this targeting that calls for
> such intra-flow parallelism?

Packet processing middeboxes that rather operate in degraded mode
(reordering) than drop packets. Intrusion detection systems and proxies,
for instance. These boxes are actually likely to have RPS enabled and
RFS disabled.

> With respect to the examples given, what happens when it is TCP traffic
> rather than UDP?

That should be identical. RFS is supported for both protocols. In the test, it
is turned off to demonstrate the effect solely with RPS.

Restricting this to only RPS is easy, btw: get_rps_overflow_cpu() is called
one for RFS and once for RPS.

> happy benchmarking,
>
> rick jones
>
