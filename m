From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RCU PATCH 00/14] Remove qdisc lock around ingress Qdisc
Date: Wed, 12 Mar 2014 09:45:05 -0700
Message-ID: <53208F11.8010304@gmail.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32> <53200588.5060805@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:55169 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756AbaCLQpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 12:45:22 -0400
Received: by mail-ob0-f175.google.com with SMTP id uy5so10197676obc.6
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 09:45:22 -0700 (PDT)
In-Reply-To: <53200588.5060805@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2014 11:58 PM, Jamal Hadi Salim wrote:
> On 03/10/14 13:03, John Fastabend wrote:
>> This series drops the qdisc lock that is currently protecting the
>> ingress qdisc. This can be done after the tcf filters are made
>> lockless and the statistic accounting is safe to run without locks.
>>
>> To do this the classifiers are converted to use RCU. This requires
>> updating each classifier individually to handle the new copy/update
>> requirement and also to update the core list traversals. This is
>> done in patches 2-11. This also makes the assumption that updates
>> to the tables are infrequent in comparison to the packet per second
>> being classified. On a 10Gbps running near line rate we can easily
>> produce 12+ million packets per second so IMO this is a reasonable
>> assumption. And the updates are serialized by RTNL.
>>
>
>
> I am in travel mode and dont have much cycles to do full review
> and the patch set seems to be based on what we discussed earlier.
> I worry on whether the assumption that table updates being
> infrequent is going to cripple some of the use cases that have
> made the interface powerful.  Cant find a presentation i did a
> while back nor my data (i will look when i get back)- but one of the
> things we prided on was ability to do extremely fast updates (both
> latency and throughput) even in presence of datapath activity.
> My comparison at the time was against netfilter (we were about
> a magnitude faster).
> So a good metric is to pick some classifier and action - then do
> table updates with no traffic as a base metric and with your changes
> after. Likewise with traffic.

Sure I can provide this data as part of the patch description. My
expectation is now that the qdisc lock is not needed there should
be less impact to throughput/latency due to filter updates. But I'll
produce the data.

>
> BTW: does this mean there may be lack of sync between what the
> control update is doing and what is being used in the datapath?

Yes upto one RCU grace period. Although I don't think this is an
issue because we get consistency eventually and even with the qdisc
lock there is no way to know if a set of skbs hit the filter list
before or after the update.

I'll get a v2 out tomorrow morning after making Eric's changes and
fixing the last compiler warning.

> net/core/gen_estimator.c: In function =91gen_get_bstats=92:
> net/core/gen_estimator.c:163:43: warning: pointer type mismatch in co=
nditional expression [enabled by default]
> net/core/gen_estimator.c: In function =91gen_find_node=92:
> net/core/gen_estimator.c:191:28: warning: pointer type mismatch in co=
nditional expression [enabled by default]

compiler doesn't like the usage of voids here.

Thanks,
John


>
> cheers,
> jamal
>
>
>


--=20
John Fastabend         Intel Corporation
