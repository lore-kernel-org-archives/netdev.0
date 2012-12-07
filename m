From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] rps: overflow prevention for saturated cpus
Date: Fri, 7 Dec 2012 11:41:31 -0500
Message-ID: <CA+FuTSdeZ5BTOVLHJZ0pZCA_f+VyR_u2ivMXgrrCyzMx=ZtstA@mail.gmail.com>
References: <1354826194-9289-1-git-send-email-willemb@google.com> <1354891889.2707.2.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:64071 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422760Ab2LGQmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 11:42:03 -0500
Received: by mail-ie0-f181.google.com with SMTP id 16so1670822iea.26
        for <netdev@vger.kernel.org>; Fri, 07 Dec 2012 08:42:01 -0800 (PST)
In-Reply-To: <1354891889.2707.2.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 7, 2012 at 9:51 AM, Ben Hutchings <bhutchings@solarflare.com> wrote:
> On Thu, 2012-12-06 at 15:36 -0500, Willem de Bruijn wrote:
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
> [...]
>> --- a/Documentation/networking/scaling.txt
>> +++ b/Documentation/networking/scaling.txt
>> @@ -135,6 +135,18 @@ packets have been queued to their backlog queue. The IPI wakes backlog
>>  processing on the remote CPU, and any queued packets are then processed
>>  up the networking stack.
>>
>> +==== RPS Overflow Protection
>> +
>> +By selecting the same cpu from the cpuset for each packet in the same
>> +flow, RPS will cause load imbalance when input flows are not uniformly
>> +random. In the extreme case, a single flow, all packets are handled on a
>> +single CPU, which limits the throughput of the machine to the throughput
>> +of that CPU. RPS has optional overflow protection, which disables flow
>> +affinity when an RPS CPU becomes saturated: during overload, its packets
>> +will be sent to the least loaded other CPU in the RPS cpuset. To enable
>> +this option, set sysctl net.core.netdev_max_rps_backlog to be smaller than
>> +net.core.netdev_max_backlog. Setting it to half is a reasonable heuristic.
> [...]
>
> This only seems to be suitable for specialised applications where a high
> degree of reordering is tolerable.  This documentation should make that
> very clear.

Good point. I'll revise that when I respin the patch.

I wasn't too concerned with this earlier, but there may be a way
to reduce the amount of reordering imposed, in
particular in the case where normal load has many small flows and the
exception is the normal case plus a small number of very high rate flows
(think synflood).

It is possible for a single high rate flow to exceed a single cpu
capacity, so those flows will always either drop packets or span
cpus and thus witness reordering (they are unlikely to be tcp
connections). It would be an improvement if the smaller flows
would at least not see reordering.

If the algorithm only redistributes packets from high rate flows, or an
approximation thereof, this will be the case. Keeping a hashtable,
counting arrivals per bucket and redirecting the highest fraction of buckets,
will do this (not my idea: a variation on a drop strategy that Eric mentioned
to me earlier). I can implement this, instead, if that sounds like a better
idea.

Because of the constraint that a single flow may exceed a single cpu
capacity, redistributed packets will always have to be redistributed
without flow affinity, I think.


> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
