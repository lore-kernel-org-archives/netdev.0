From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: locating the 'tc actions' hook
Date: Mon, 05 Aug 2013 09:11:31 -0700
Message-ID: <51FFCEB3.3010404@gmail.com>
References: <51F97F4E.5070102@gmail.com> <51FA493C.8080207@mojatatu.com> <51FAECBF.3030704@intel.com> <51FCEDCF.8010107@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:50729 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570Ab3HEQL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 12:11:58 -0400
Received: by mail-ob0-f174.google.com with SMTP id wd6so5989552obb.33
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 09:11:58 -0700 (PDT)
In-Reply-To: <51FCEDCF.8010107@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2013 04:47 AM, Jamal Hadi Salim wrote:
> On 13-08-01 07:18 PM, John Fastabend wrote:
>
> [..]
>
>> The first being directly related to the previous per queue rate limiter
>> patch. With rate limiters per queue on a multiqueue device using mq or
>> mqprio I need some mechanism to steer packets to queues. One way to do
>> this is to use mqprio and create a 'tc' with a single queue in it.
>> And then use iptables or netprio_cgroup to steer packets. Another way
>> to do this would be to use 'skbedit queue_mapping' to set the queue from
>> 'tc' but unfortunately with the existing flows the queue has already
>> been selected by the time the classifiers are called.
>
> I am assuming the skb (mark) will be tagged with a proper meaningful
> tag maybe by the driver. Such a tag can be used later up-stack.
>

Actually in the first case here I was considering egress traffic.

Separating the classifier chain from the qdisc allows using the
classifiers to pick a qdisc via queue_mapping because qdisc's are
attached to queues when using sch_mq.

>> Calling into the
>> classifier chain before picking the qdisc would fix this. For flow based
>> QOS with multiqueue devices this type of functionality would be useful.
>>
>
>  From your description this seems to be ingress side; so we should be
> able to use that tag if you set it.
>

Sorry I mucked two examples one egress and one ingress together without
clearly stating it. The second case here was ingress the first egress.

>
>> The second thought that I've been piecing together would be to populate
>> the rxhash (or maybe some other field) using the hardware flow
>> classifier in some meaningful way for the ingress qdisc.
>
>
> The rxhash would be useful for further classification or avoiding
> further classification.
>
>> Some of the
>> existing Intel NICs can do this and I believe other vendors have similar
>> capabilities. Although currently with the qdisc lock running around the
>> ingress qdisc the multiqueue devices take a perf hit just by
>> instantiating the ingress qdisc which really is only using the lock to
>> guard some stats and keep the classifier/action chains sane.
>>
>
> Instantiating any qdisc is not a problem. You do it once and are done.
> There are penalties with using qdiscs in terms of locking.
> The locks penalties really have to do with the design of the netdev
> not qdiscs i.e queues are centered around netdevs and netdevs
> are shared across  processors.
>

But currently we have a situation on egress where multiqueue devices
use mq or mqprio which aligns qdisc's with queues. This fixes the
performance penalties but you lose the ability to have state across
multiple queues and the ability to bind flows to queues.

For example a SW rate limiter that applies to a set of queues or a set
of tuned low latency queues. To fix this we can attach a qdisc (htb,
whatever) to the netdev but this has performance penalties. So we are
left with a trade off between functionality and performance.

On the ingress side we may have many queues but as soon as we add a
qdisc/classifier/action we have a single lock.

>
>> If you have some good examples it would be great to see them and drop
>> them in my testbed. Go ahead and send them to me offlist if you can.
>>
>
> will do.
>

Thanks. I'll see if I can draw up what I'm thinking here a bit more
clearly and send it your way.

> cheers,
> jamal
>
>
>> .John
>>


-- 
John Fastabend         Intel Corporation
