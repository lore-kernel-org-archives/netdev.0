From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Wed, 13 Apr 2016 23:35:26 -0700
Message-ID: <570F3A2E.2000707@cumulusnetworks.com>
References: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com> <20160414.001948.1059678462607051806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34304 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbcDNGf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 02:35:28 -0400
Received: by mail-pf0-f181.google.com with SMTP id c20so43044568pfc.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 23:35:28 -0700 (PDT)
In-Reply-To: <20160414.001948.1059678462607051806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/16, 9:19 PM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Fri,  8 Apr 2016 23:38:11 -0700
>
>> This patch adds a new RTM_GETSTATS message to query link stats via netlink
>> from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK
>> returns a lot more than just stats and is expensive in some cases when
>> frequent polling for stats from userspace is a common operation.
> Great work.  One thing catches my eye:
>
>> +	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK64)) {
>> +		attr = nla_reserve(skb, IFLA_STATS_LINK64,
>> +				   sizeof(struct rtnl_link_stats64));
>> +		if (!attr)
>> +			return -EMSGSIZE;
>> +
>> +		stats = dev_get_stats(dev, &temp);
>> +
>> +		copy_rtnl_link_stats64(nla_data(attr), stats);
> This extra copy bothers me, so I tried to figure out what is going
> on here.
>
> dev_get_stats() always returns the rtnl_link_stats64 pointer it was
> given.  We should be able to pass, therefore, nla_data(attr), straight
> there to avoid the copy.

nice catch. I picked this up straight from rtnl_fill_stats. agree, also thanks
 for the example below.

>
> Bonding even uses dev_get_stats() in this way.
>
> The existing rtnl_fill_stats() can be improved similarly but is of
> course a separate change.  In that case, we'd do something like:
>
> 	struct rtnl_link_stats64 *sp;
>
> 	attr = nla_reserve(skb, IFLA_STATS64,
> 			   sizeof(struct rtnl_link_stats64));
> 	if (!attr)
> 		return -EMSGSIZE;
>
> 	sp = nla_data(attr);
> 	dev_get_stats(dev, sp);
>
> 	attr = nla_reserve(skb, IFLA_STATS,
> 			   sizeof(struct rtnl_link_stats));
> 	if (!attr)
> 		return -EMSGSIZE;
>
> 	copy_rtnl_link_stats(nla_data(attr), sp);

I will submit a separate patch for this with some testing.

Will send a v3 out before end of this week.

Thank you!.
