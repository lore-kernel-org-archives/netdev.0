From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Sun, 10 Apr 2016 12:17:05 -0700
Message-ID: <570AA6B1.3060305@cumulusnetworks.com>
References: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com> <5709120D.9010107@mojatatu.com> <57094326.9040009@cumulusnetworks.com> <570A59B4.30007@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34625 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932718AbcDJTRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 15:17:08 -0400
Received: by mail-pf0-f172.google.com with SMTP id c20so109421253pfc.1
        for <netdev@vger.kernel.org>; Sun, 10 Apr 2016 12:17:07 -0700 (PDT)
In-Reply-To: <570A59B4.30007@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/16, 6:48 AM, Jamal Hadi Salim wrote:
> On 16-04-09 02:00 PM, roopa wrote:
>
>> This EXTENDED_HW_STATS is for ethtool like extended hw stats. This is keeping in
>> mind that we want to also move ethtool to netlink in the future and with switchdev
>> it becomes more necessary that we provide all stats closer to the other netdev stats.
>> So far hw extended stats have always been available through this separate ethtool
>> channel. The intent here is to unify the api for extended hw and software only stats.
>
> Ok, so these are _not_ the stats which are broken down by packet size
> ranges which are quiet common; but rather "proprietary" per port
> type h/w stats? I browsed a couple of users of ethtool_stats and i see
> they return proprietary looking 64 bit counters (batman for example
> has a very strange meaning to those stats).
> What i meant is a lot of ASICS have counters for byte ranges
> [64bytes-128bytes], [128bytes-256bytes], etc - sorry i cant pin a name
> to those but i am sure you have seen them and i thought those at minimal
> need their own TLV since they are always fixed.

yes, I think i have seen this. But, these if presented by the driver or hardware,
can be part of the extended hw stats (just like how ethtool would do).
So, there is the base netdev stats IFLA_STATS_LINK64 which is nothing but
rtnl_link_stats64 (which this patch adds). And this patch does not add but lists
examples for future additions IFLA_STATS_EXTENDED (for example: bridge
(can include igmp, stp, vlan stats here). bond can includelacp, and other stats here). All these will be TLV based.
and note that this patch does notrestrict or define the design for these yet.


>
>> XSTATS is per netdev can be included as a nested attribute inside IFLA_EXTENDED_STATS
>> which are per netdev. bridge vlan stats will also fall here.
>>
>
> And you are going to distinguish which come from hardware and which are
> software derived?

a) IFLA_EXTENDED_STATS - these are all software. ( for example: bridge (can include 
igmp, stp, vlan stats here).
bond can include lacp, and other stats here).

b) IFLA_HW_EXTENDED_STATS - for hardware stats. for a switch port these will be 
similar to ethtool
physical port stats today. For logical devices, this can include specific hw 
stats that switch asics
provide and those which cannot be added to the software stats.

And since this patch does not define the format for these stats yet, we can 
potentially design it when we see the first case of such stats.




>
>> And this api  provides netdev specific stats. We have always mapped all
>> asic stats to the switch port netdev stats. and this api does not cover the non-netdev specific stats.
>> If you are for example asking for stats for a hardware offloaded bridge, then yes, they will fall here
>> and be available on the bridge netdev. For asic stats that don't map to any netdev, devlink will be an
>> appropriate infrastructure IMO.
>>
>> I am not sure if I answered your question :).
>>
>
> It is useful to have this discussion; unfortunately these user APIS once are in will never be allowed to change. The answers could come
> in time.

yep, agreed.
>
>>> Should such a command then not be rejected with an error code?
>> Dumps with no data are not rejected with an error code AFAIK. ie they don't return
>> -ENODATA. This is consistent with all other dumps (unless i missed it).
>>   But, if there is a need for an error code, i can certainly check again.
>>
>
> It is mostly because you chose a whitelist filter i.e you list what
> is allowed to be sent back. And if such a list is missing there
> needs to be an opposite default (which is a deny all).

ok, by default no-filter = no-data is what we decided. And that
keeps the api simple. will think some more about if we should return
an err in case of no-filter.


>
>

[snip]

> True, but it must be 32 bit aligned. So something like:
> struct if_stats_msg {
>      __u8  family;
>      __u8 pad1;
>      __u16 pad2;
>     __u32 ifindex;
>     __u32 filter_mask;
> }
>

ok ack

>
>> Yeah i remember :). But deferring it for a later incremental feature. That needs some more thought.
>
> NP ;->
>
>> Right now there is an urgent need to get the basic get stats api for a bunch of other stats: mpls, bridge vlan etc.
>> Because it is not clean to extend the current stats infra part of the link message for this. So trying to get this in first.
>>
>
> Agreed.
> The only thing i strongly feel about is the if_stats_msg - please fix
> that and lets get at least the basics in. We can resolve other things
> with further discussions.

will do. Thanks for the review.
