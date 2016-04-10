From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Sun, 10 Apr 2016 09:48:36 -0400
Message-ID: <570A59B4.30007@mojatatu.com>
References: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com>
 <5709120D.9010107@mojatatu.com> <57094326.9040009@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34639 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052AbcDJNsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 09:48:38 -0400
Received: by mail-ig0-f182.google.com with SMTP id gy3so64591250igb.1
        for <netdev@vger.kernel.org>; Sun, 10 Apr 2016 06:48:38 -0700 (PDT)
In-Reply-To: <57094326.9040009@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-04-09 02:00 PM, roopa wrote:

> This EXTENDED_HW_STATS is for ethtool like extended hw stats. This is keeping in
> mind that we want to also move ethtool to netlink in the future and with switchdev
> it becomes more necessary that we provide all stats closer to the other netdev stats.
> So far hw extended stats have always been available through this separate ethtool
> channel. The intent here is to unify the api for extended hw and software only stats.

Ok, so these are _not_ the stats which are broken down by packet size
ranges which are quiet common; but rather "proprietary" per port
type h/w stats? I browsed a couple of users of ethtool_stats and i see
they return proprietary looking 64 bit counters (batman for example
has a very strange meaning to those stats).
What i meant is a lot of ASICS have counters for byte ranges
[64bytes-128bytes], [128bytes-256bytes], etc - sorry i cant pin a name
to those but i am sure you have seen them and i thought those at minimal
need their own TLV since they are always fixed.

> XSTATS is per netdev can be included as a nested attribute inside IFLA_EXTENDED_STATS
> which are per netdev. bridge vlan stats will also fall here.
>

And you are going to distinguish which come from hardware and which are
software derived?

> And this api  provides netdev specific stats. We have always mapped all
> asic stats to the switch port netdev stats. and this api does not cover the non-netdev specific stats.
> If you are for example asking for stats for a hardware offloaded bridge, then yes, they will fall here
> and be available on the bridge netdev. For asic stats that don't map to any netdev, devlink will be an
> appropriate infrastructure IMO.
>
> I am not sure if I answered your question :).
>

It is useful to have this discussion; unfortunately these user APIS once 
are in will never be allowed to change. The answers could come
in time.

>> Should such a command then not be rejected with an error code?
> Dumps with no data are not rejected with an error code AFAIK. ie they don't return
> -ENODATA. This is consistent with all other dumps (unless i missed it).
>   But, if there is a need for an error code, i can certainly check again.
>

It is mostly because you chose a whitelist filter i.e you list what
is allowed to be sent back. And if such a list is missing there
needs to be an opposite default (which is a deny all).

>>> +/* STATS section */
>>> +
>>> +struct if_stats_msg {
>>> +    __u8  family;
>>> +    __u32 ifindex;
>>> +    __u32 filter_mask;
>>> +};
>>
>> Needs to be 32 bit aligned.
>> Do you need 32 bits for the filter mask?
> yes, i think we should keep it minimum 32 bits.

Ok, that is fine then. I thought it wont exceed
3-4 per port type but i could be wrong. 32 bits
should be safer.

>> Perhaps a 16bit mask and an 8bit pad for future use.
>>
>> struct if_stats_msg {
>>             __u32 ifindex;
>>         __u16 filter_mask;
>>         __u8  family;
>>             __u8 pad; /* future use */
>> };
>>
>> Or you could reverse those (from smallest to largest).
>
> The __u8 family needs to be the first field in the structure and at the first byte in the header data.
> hence family is first and i added the others after that. It follows the format for existing such structs (for other message types).
>

True, but it must be 32 bit aligned. So something like:
struct if_stats_msg {
      __u8  family;
      __u8 pad1;
      __u16 pad2;
     __u32 ifindex;
     __u32 filter_mask;
}


> Yeah i remember :). But deferring it for a later incremental feature. That needs some more thought.

NP ;->

> Right now there is an urgent need to get the basic get stats api for a bunch of other stats: mpls, bridge vlan etc.
> Because it is not clean to extend the current stats infra part of the link message for this. So trying to get this in first.
>

Agreed.
The only thing i strongly feel about is the if_stats_msg - please fix
that and lets get at least the basics in. We can resolve other things
with further discussions.

> And this patchset only adds a handler for RTM_NEWSTATS dump and get stats. Your stats events request should be part of the  RTM_NEWSTATS handler and can include other attributes (like timeout) in the future.
>

Ok.

cheers,
jamal
> Thanks,
> Roopa
>
