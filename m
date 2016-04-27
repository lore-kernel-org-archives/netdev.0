From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/7] bridge: per-vlan stats
Date: Wed, 27 Apr 2016 19:13:03 +0200
Message-ID: <5720F31F.2040709@cumulusnetworks.com>
References: <1461773902-13528-1-git-send-email-nikolay@cumulusnetworks.com>
 <20160427100601.6bbf9d28@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	davem@davemloft.net, jhs@mojatatu.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37752 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbcD0RNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 13:13:07 -0400
Received: by mail-wm0-f46.google.com with SMTP id a17so25080960wme.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 10:13:06 -0700 (PDT)
In-Reply-To: <20160427100601.6bbf9d28@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/27/2016 07:06 PM, Stephen Hemminger wrote:
> On Wed, 27 Apr 2016 18:18:15 +0200
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> Hi,
>> This set adds support for bridge per-vlan statistics.
>> In order to be able to dump statistics we need a way to continue
>> dumping after reaching maximum size, thus patches 01-03 extend the new
>> stats API with a per-device extended link stats attribute and callback
>> which can save its local state and continue where it left off afterwards.
>> I considered using the already existing "fill_xstats" callback but it gets
>> confusing since we need to separate the linkinfo dump from the new stats
>> api dump and adding a flag/argument to do that just looks messy. I don't
>> think the rtnl_link_ops size is an issue, so adding these seemed like the
>> cleaner approach.
>>
>> Patch 05 converts the pvid to a pointer so we can consolidate the vlan
>> stats accounting paths later, also allows to simplify the pvid code.
>> Patches 06 and 07 add the stats support and netlink dump support
>> respectively.
>> I've tested this set with both old and modified iproute2, kmemleak on and
>> some traffic stress tests while adding/removing vlans and ports.
>>
>> Thank you,
>>  Nik
>>
>> Note: Jamal I haven't forgotten about the per-port per-vlan stats, I've got
>> a follow-up patch that adds it. You can easily see that the infrastructure
>> for private port/vlan stats is in place after this set. Though the stats
>> api will need some more changes to support that.
>>
>>
>> Nikolay Aleksandrov (7):
>>   net: rtnetlink: allow rtnl_fill_statsinfo to save private state
>>     counter
>>   net: rtnetlink: allow only one idx saving stats attribute
>>   net: rtnetlink: add linkxstats callbacks and attribute
>>   net: constify is_skb_forwardable's arguments
>>   bridge: vlan: RCUify pvid
>>   bridge: vlan: learn to count
>>   bridge: netlink: export per-vlan stats
>>
>>  include/linux/netdevice.h      |   3 +-
>>  include/net/rtnetlink.h        |  10 +++
>>  include/uapi/linux/if_bridge.h |   8 +++
>>  include/uapi/linux/if_link.h   |   9 +++
>>  net/bridge/br_netlink.c        |  80 ++++++++++++++++++++----
>>  net/bridge/br_private.h        |  32 +++++-----
>>  net/bridge/br_vlan.c           | 134 +++++++++++++++++++++++++++++------------
>>  net/core/dev.c                 |   2 +-
>>  net/core/rtnetlink.c           |  64 +++++++++++++++++---
>>  9 files changed, 266 insertions(+), 76 deletions(-)
>>
> 
> I am concerned this adds unnecessary complexity (more bugs)
IMO the whole point in moving to a per-vlan structure from a bitmap was to
have per-vlan context and flexibility to implement functions like this.
The fast path code that is added is minimal (fetch & stats adds).
In any case I'm sure there're more per-vlan options coming, and not only from
me or Cumulus. If we won't make use of the per-vlan context, then I'd suggest
we revert to bitmaps as that's faster and more compact.

> and overhead (slower performance). Statistics are not free, and having
> them in a convenient place maybe unnecessary duplication.
> 
The performance impact is minimal as we're using per-cpu counters. If you're
concerned that even that is too much I can make this conditional on a per-vlan
flag that can be requested by the user to enable the stats, but that is overkill
for something as basic as stats in my opinion.

Thanks,
 Nik
