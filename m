From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Sat, 09 Apr 2016 11:00:06 -0700
Message-ID: <57094326.9040009@cumulusnetworks.com>
References: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com> <5709120D.9010107@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33003 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754909AbcDISAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 14:00:09 -0400
Received: by mail-pf0-f177.google.com with SMTP id 184so95812315pff.0
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 11:00:09 -0700 (PDT)
In-Reply-To: <5709120D.9010107@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/9/16, 7:30 AM, Jamal Hadi Salim wrote:
>
> Thanks for doing the work Roopa and I apologize for late comments
> below:
>
> On 16-04-09 02:38 AM, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>
>> This patch also allows for af family stats (an example af stats for IPV6
>> is available with the second patch in the series).
>>
>> Like any other rtnetlink message, RTM_GETSTATS can be used to get stats of
>> a single interface or all interfaces with NLM_F_DUMP.
>>
>> Future possible new types of stat attributes:
>> - IFLA_MPLS_STATS  (nested. for mpls/mdev stats)
>> - IFLA_EXTENDED_STATS (nested. extended software netdev stats like bridge,
>>    vlan, vxlan etc)
>> - IFLA_EXTENDED_HW_STATS (nested. extended hardware stats which are
>>    available via ethtool today)
>>
>
> I got the extended_hw_stats (which are very common in a lot of ASICS) if
> you mean stats on packet sizes. But would the other extended stats not
> just be per netdev kind specific? We have concept of XSTATS which maybe
> a fit.
This EXTENDED_HW_STATS is for ethtool like extended hw stats. This is keeping in
mind that we want to also move ethtool to netlink in the future and with switchdev
it becomes more necessary that we provide all stats closer to the other netdev stats.
So far hw extended stats have always been available through this separate ethtool
channel. The intent here is to unify the api for extended hw and software only stats.

XSTATS is per netdev can be included as a nested attribute inside IFLA_EXTENDED_STATS
which are per netdev. bridge vlan stats will also fall here.

And this api  provides netdev specific stats. We have always mapped all
asic stats to the switch port netdev stats. and this api does not cover the non-netdev specific stats.
If you are for example asking for stats for a hardware offloaded bridge, then yes, they will fall here
and be available on the bridge netdev. For asic stats that don't map to any netdev, devlink will be an
appropriate infrastructure IMO.

I am not sure if I answered your question :).

>
>> This patch also declares a filter mask for all stat attributes.
>> User has to provide a mask of stats attributes to query. This will be
>> specified in a new hdr 'struct if_stats_msg' for stats messages.
>>
>> Without any attributes in the filter_mask, no stats will be returned.
>>
>
> Should such a command then not be rejected with an error code?
Dumps with no data are not rejected with an error code AFAIK. ie they don't return
-ENODATA. This is consistent with all other dumps (unless i missed it).
 But, if there is a need for an error code, i can certainly check again.

>> +/* STATS section */
>> +
>> +struct if_stats_msg {
>> +    __u8  family;
>> +    __u32 ifindex;
>> +    __u32 filter_mask;
>> +};
>
> Needs to be 32 bit aligned.
> Do you need 32 bits for the filter mask?
yes, i think we should keep it minimum 32 bits.
> Perhaps a 16bit mask and an 8bit pad for future use.
>
> struct if_stats_msg {
>            __u32 ifindex;
>        __u16 filter_mask;
>        __u8  family;
>            __u8 pad; /* future use */
> };
>
> Or you could reverse those (from smallest to largest).

The __u8 family needs to be the first field in the structure and at the first byte in the header data.
hence family is first and i added the others after that. It follows the format for existing such structs (for other message types).

> BTW, any plans to do the cool feature where i inject a timeout period
> and i just get STATS events ;-> The filter struct would have to be more
> sophisticated - user would need to pass a list of ifindices and
> filter_mask as well as timeout.
Yeah i remember :). But deferring it for a later incremental feature. That needs some more thought.
Right now there is an urgent need to get the basic get stats api for a bunch of other stats: mpls, bridge vlan etc.
Because it is not clean to extend the current stats infra part of the link message for this. So trying to get this in first.

And this patchset only adds a handler for RTM_NEWSTATS dump and get stats. Your stats events request should be part of the  RTM_NEWSTATS handler and can include other attributes (like timeout) in the future.

Thanks,
Roopa
