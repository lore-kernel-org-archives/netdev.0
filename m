From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] rps: overflow prevention for saturated cpus
Date: Fri, 7 Dec 2012 11:04:12 -0500
Message-ID: <CA+FuTScOXn8gz-=VcbVMuv6WvVgdp0Q1tEDuySusniC7Mb7H-g@mail.gmail.com>
References: <1354826194-9289-1-git-send-email-willemb@google.com>
 <50C11B4D.4040109@hp.com> <CA+FuTSc=-TE4X=VWmdXMLhE_jn6CtjUpauznt4evrRLi-DOd2g@mail.gmail.com>
 <50C12E22.3030206@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:56606 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030765Ab2LGQEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 11:04:44 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so795066iay.19
        for <netdev@vger.kernel.org>; Fri, 07 Dec 2012 08:04:44 -0800 (PST)
In-Reply-To: <50C12E22.3030206@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 6, 2012 at 6:45 PM, Rick Jones <rick.jones2@hp.com> wrote:
> On 12/06/2012 03:04 PM, Willem de Bruijn wrote:
>>
>> On Thu, Dec 6, 2012 at 5:25 PM, Rick Jones <rick.jones2@hp.com> wrote:
>>>
>>> I thought (one of) the ideas behind RFS at least was to give the CPU
>>> scheduler control over where network processing took place instead of it
>>> being dictated solely by the addressing. I would have expected the CPU
>>> scheduler to migrate some work off the saturated CPU.  Or will this only
>>> affect RPS and not RFS?
>>
>>
>> I wrote it with RPS in mind, indeed. With RFS, for sufficiently
>> multithreaded applications that are unpinned, the scheduler will
>> likely spread the threads across as many cpus as possible. In that
>> case, the mechanism will not kick in, or as quickly. Even with RFS,
>> pinned threads and single-threaded applications will likely also
>> benefit during high load from redirecting kernel receive
>> processing away from the cpu that runs the application thread. I
>> haven't tested that case independently.
>
>
> Unless that single-threaded application (or single receiving thread) is
> pinned to a CPU, isn't there a non-trivial chance that incoming traffic
> flowing up different CPUs will cause it to be bounced from one CPU to
> another, taking its cache lines with it and not just the "intra-stack" cache
> lines?

Yes. The patch restricts the offload cpus to rps_cpus, with the assumption
that this is a small subset of all cpus. In that case, other workloads will
eventually migrate to the remainder. I previously tested spreading across
all cpus, which indeed did interfere with the userspace threads.

> Long (?) ago and far away it was possible to say that a given IRQ should be
> potentially serviced by more than one CPU (if I recall though not phrase
> correctly).  Didn't that get taken away because it did such nasty things
> like reordering and such?  (Admittedly, I'm really stretching the limits of
> my dimm memory there)

Sounds familiar. Wasn't there a mechanism to periodically switch the
destination cpu? If at HZ granularity, that is very coarse grain compared to
Mpps, but out of order does seem likely. I assume that this patch will lead
to a steady state where userspace and kernel receive run on disjoint cpusets,
due to the rps_cpus set being hot with kernel receive processing. That said,
I can run a test with RFS enabled to see whether that actually holds.

>>> What kind of workload is this targeting that calls for
>>> such intra-flow parallelism?
>>
>>
>> Packet processing middeboxes that rather operate in degraded mode
>> (reordering) than drop packets. Intrusion detection systems and proxies,
>> for instance. These boxes are actually likely to have RPS enabled and
>> RFS disabled.
>>
>>> With respect to the examples given, what happens when it is TCP traffic
>>> rather than UDP?
>>
>>
>> That should be identical. RFS is supported for both protocols. In the
>> test, it is turned off to demonstrate the effect solely with RPS.
>
>
> Will it be identical with TCP?  If anything, I would think causing
> reordering of the TCP segments within flows would only further increase the
> workload of the middlebox because it will increase the ACK rates. Perhaps
> quite significantly if GRO was effective at the receivers before the
> reordering started.
>
> At least unless/until the reordering is bad enough to cause the sending TCPs
> to fast retransmit and so throttle back.  And unless we are talking about
> being overloaded by massive herds of "mice" I'd think that the TCP flows
> would be throttling back to what the single CPU in the middlebox could
> handle.

Agreed, I will try to get some data on the interaction with TCP flows. My
hunch is that they throttle down due to the reordering, but data is more useful.
The initial increase in ACKs, if any, will likely not increase rate beyond a
small factor.

The situations that this patch mean to address are more straightforward
DoS attacks, where a box can handle normal load with a big safety margin,
but falls over at a 10x or 100x flood of TCP SYN or similar packets.

> rick
