From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Sun, 10 Apr 2016 11:28:29 -0700
Message-ID: <570A9B4D.80104@cumulusnetworks.com>
References: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com> <20160410081650.GB22873@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35077 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbcDJS2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 14:28:32 -0400
Received: by mail-pa0-f53.google.com with SMTP id td3so106791938pab.2
        for <netdev@vger.kernel.org>; Sun, 10 Apr 2016 11:28:31 -0700 (PDT)
In-Reply-To: <20160410081650.GB22873@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/16, 1:16 AM, Thomas Graf wrote:
> On 04/08/16 at 11:38pm, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds a new RTM_GETSTATS message to query link stats via netlink
>> from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK
>> returns a lot more than just stats and is expensive in some cases when
>> frequent polling for stats from userspace is a common operation.
>>
>> RTM_GETSTATS is an attempt to provide a light weight netlink message
>> to explicity query only link stats from the kernel on an interface.
>> The idea is to also keep it extensible so that new kinds of stats can be
>> added to it in the future.
>>
>> This patch adds the following attribute for NETDEV stats:
>> struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
>>         [IFLA_STATS_LINK64]  = { .len = sizeof(struct rtnl_link_stats64) },
>> };
>>
>> This patch also allows for af family stats (an example af stats for IPV6
>> is available with the second patch in the series).
>>
>> Like any other rtnetlink message, RTM_GETSTATS can be used to get stats of
>> a single interface or all interfaces with NLM_F_DUMP.
> Awesome stuff Roopa.
>
> This currently ties everything to a net_device with a selector to
> include certain bits of that net_device. How about we take it half a
> step further and allow for non net_device stats such as IP, TCP,
> routing or ipsec stats to be retrieved as well?
yes, absolutely. and that is also the goal.
> A simple array of nested attributes replacing IFLA_STATS_* would
> allow for that, e.g.
>
> 1. {.type = ST_IPSTATS, value = { ...} }
>
> 2. {.type = ST_LINK, .value = {
>     {.type = ST_LINK_NAME, .value = "eth0"},
>     {.type = ST_LINK_Q, .value = 10}
>   }}
>
> 3. ...

One thing though,  Its unclear to me if we absolutely need the additional nest.
Every stats netlink msg has an ifindex in the header (if_stats_msg) if the scope
of the stats is a netdev. If the msg does not have an ifindex in the if_stats_msg,
it represents a global stat. ie Cant a dump, include other stats netlink msgs after
all the netdev msgs are done when the filter has global stat filters ?.
same will apply to RTM_GETSTATS (without NLM_F_DUMP).

Since the msg may potentially have more nest levels
in the IFLA_EXT_STATS categories, just trying to see if i can avoid adding another
top-level nest. We can sure add it if there is no other way to include global
stats in the same dump.
> So for your initial patch, you'd simply add a new top level attribute
> which ties all the net_device specific statistics to a top level
> attribute and we can add the non net_device specific stats later on.
> We can't do that later on though without breaking ABI so that would
> have to go in with the first iteration.
agreed
>
> We can preserve all the existing attribute formats, we simply have
> to introduce new attribute types which don't overlap and document
> which statistic identifier maps to which existing attribute id.
sure,

thanks Thomas.
