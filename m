From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 00/12] RCU'ify the net:sched classifier chains
Date: Sat, 11 Jan 2014 15:33:17 -0800
Message-ID: <52D1D4BD.9080906@gmail.com>
References: <20140110092041.7193.5952.stgit@nitbit.x32> <CAM_iQpU6WWB72zBdU4mh-sB+8B8Vz2gPvH7Hxhjhkr+vMjwdpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:35421 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbaAKXdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 18:33:41 -0500
Received: by mail-ob0-f173.google.com with SMTP id gq1so6356134obb.18
        for <netdev@vger.kernel.org>; Sat, 11 Jan 2014 15:33:39 -0800 (PST)
In-Reply-To: <CAM_iQpU6WWB72zBdU4mh-sB+8B8Vz2gPvH7Hxhjhkr+vMjwdpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2014 11:43 AM, Cong Wang wrote:
> On Fri, Jan 10, 2014 at 1:36 AM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> There appears to be some interest in a few topics around the qdisc
>> layer which could benefit from having the ability to run the
>> filters and actions without holding the qdisc lock.
>>
>> Recently Cong Wang proposed a patch series to drop the ingress
>> qdisc and asked for comments. This series I think gets closer to
>> that goal.
>>
>> The ingress qdisc is a simple qdisc which doesn't maintain any
>> actual list of skb's and is primarily a hook to attach filters.
>> Further the only qdisc that can be attached to the ingress qdisc
>> is sch_ingress. The qdisc lock is currently serializing two
>> operations (1) tc_classify which is addressed here and (2)
>> statistics accounting. The second point is not solved here but
>> it could be a matter of making the bstats and qstats per cpu
>> stats.
>
>
> Yeah, actually I tried to make bstats percpu, but I still doubt
> if it is necessary, since increasing a 32bit counter doesn't
> sound dangerous on SMP?
>

Well what happens when multiple cpus are incrementing the counter?
You can't assume all archs have a fetch and add instruction (addl on
x86) and I fairly certain there is no guarantee the compiler even
on x86 will do it that way. Minimally we need to use the atomic
operations but then its a cache thrashing problem. And because worse
case every CPU is going to be touching those bstats you really need
to make them per cpu. Look around the kernel at other counters its a
common pattern.

Similarly the qstats need to be per cpu, I might have a patch
around here for that piece somewhere. I'll look later.

Send me your patch so I can integrate it with the rest.

>>
>> This is an RFC for now and needs some more work. Some items
>> I know about are (a) an audit of the ematch code paths, (b) resolving
>> the checpatch errors mostly due to moving code around that
>> generates those errors, (c) run smatch, (d) audit u32 code
>> for correctness, (e) do a lot more testing so far only very
>> basic testing has been done. I tried to put some reasonable
>> comments in the commit logs but yes they need more work.
>>
>> Cong, if its not too much to ask can we use this as a base
>> set of patches for this work? I think its reasonably close to
>> correct as is.
>>
>
> Sure, just that:
>
> 1) I myself don't like playing RCU list without using list_head API
> it is still hard for me to read.

I think its a reasonably common practice, and if we don't need the
prev pointer we can save a pointer.

>
> 2) The first patch in your series seems completely irrelevant to
> $subject. :)

If the intent is to drop the qdisc lock around the ingress qdisc and
use the RCU api's I want to be sure to annotate it so we can use
the analysis tools to catch any errors. Smatch and others really are
pretty good at catching dumb mistakes or missed call sites.

>
> Thanks.
>

-- 
John Fastabend         Intel Corporation
