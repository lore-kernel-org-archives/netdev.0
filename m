From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Mon, 11 Apr 2016 20:53:23 -0700
Message-ID: <570C7133.8070109@cumulusnetworks.com>
References: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com> <20160410081650.GB22873@pox.localdomain> <570A9B4D.80104@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33117 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbcDLDxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 23:53:25 -0400
Received: by mail-pf0-f173.google.com with SMTP id 184so5344764pff.0
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 20:53:25 -0700 (PDT)
In-Reply-To: <570A9B4D.80104@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/16, 11:28 AM, roopa wrote:
> On 4/10/16, 1:16 AM, Thomas Graf wrote:
[snip]
>>
>> This currently ties everything to a net_device with a selector to
>> include certain bits of that net_device. How about we take it half a
>> step further and allow for non net_device stats such as IP, TCP,
>> routing or ipsec stats to be retrieved as well?
> yes, absolutely. and that is also the goal.
>> A simple array of nested attributes replacing IFLA_STATS_* would
>> allow for that, e.g.
>>
>> 1. {.type = ST_IPSTATS, value = { ...} }
>>
>> 2. {.type = ST_LINK, .value = {
>>     {.type = ST_LINK_NAME, .value = "eth0"},
>>     {.type = ST_LINK_Q, .value = 10}
>>   }}
>>
>> 3. ...
> One thing though,  Its unclear to me if we absolutely need the additional nest.
> Every stats netlink msg has an ifindex in the header (if_stats_msg) if the scope
> of the stats is a netdev. If the msg does not have an ifindex in the if_stats_msg,
> it represents a global stat. ie Cant a dump, include other stats netlink msgs after
> all the netdev msgs are done when the filter has global stat filters ?.
> same will apply to RTM_GETSTATS (without NLM_F_DUMP).
>
> Since the msg may potentially have more nest levels
> in the IFLA_EXT_STATS categories, just trying to see if i can avoid adding another
> top-level nest. We can sure add it if there is no other way to include global
> stats in the same dump.
>

Just wanted to elaborate on what i was trying to say:

Top level stats attributes can be netdev or global attributes: We can include string "LINK" in
the names of all stats belonging to a netdev to make it easier to recognize the netdev stats (example):
 IFLA_STATS_LINK64,           (netdev)
 IFLA_STATS_LINK_INET6,    (netdev)
 IFLA_STATS_TCP,                (non-netdev, global tcp stats)

RTM_GETSTATS (NLM_F_DUMP)  with user given filter_mask {
        If filter-mask contains any link stats, start with per netdev stats messages:
        { if_stats_msg.ifindex = 1,
          if_stats_msg.filter_mask = mask of included link stats,
          <stats attributes> }

        { if_stats_msg.ifindex = 2,
          if_stats_msg.filter_mask = mask of included link stats,
          <stats attributes> }

        global stats (if user given filter mask contains global filters.):
        { if_stats_msg.ifindex = 0,
          if_stats_msg.filter_mask = mask of included global stats,
          <stats attributes> }
}

We will need a field in netlink_callback to indicate global or netdev stats when the stats
crosses skb boundaries. A single nlmsg cannot have both netdev and global stats.

Non-dump RTM_GETSTATS examples:

RTM_GETSTATS with valid ifindex and filter_mask {
        filter_mask cannot have global stats (return -EINVAL)
        { if_stats_msg.ifindex = <user_given_ifindex>,
          if_stats_msg.filter_mask = mask of included link stats,
          <stats attributes> }
}

RTM_GETSTATS with ifindex = 0 and filter_mask {
        filter_mask cannot have link stats (return -EINVAL)
        { if_stats_msg.ifindex = 0,
          if_stats_msg.filter_mask = mask of included global link stats,
          <stats attributes> }
}


Will this not work ?

Thanks,
Roopa
