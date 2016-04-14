From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS
 message to dump link stats
Date: Thu, 14 Apr 2016 00:19:48 -0400 (EDT)
Message-ID: <20160414.001948.1059678462607051806.davem@davemloft.net>
References: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbcDNETy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 00:19:54 -0400
In-Reply-To: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Fri,  8 Apr 2016 23:38:11 -0700

> This patch adds a new RTM_GETSTATS message to query link stats via netlink
> from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK
> returns a lot more than just stats and is expensive in some cases when
> frequent polling for stats from userspace is a common operation.

Great work.  One thing catches my eye:

> +	if (filter_mask & IFLA_STATS_FILTER_BIT(IFLA_STATS_LINK64)) {
> +		attr = nla_reserve(skb, IFLA_STATS_LINK64,
> +				   sizeof(struct rtnl_link_stats64));
> +		if (!attr)
> +			return -EMSGSIZE;
> +
> +		stats = dev_get_stats(dev, &temp);
> +
> +		copy_rtnl_link_stats64(nla_data(attr), stats);

This extra copy bothers me, so I tried to figure out what is going
on here.

dev_get_stats() always returns the rtnl_link_stats64 pointer it was
given.  We should be able to pass, therefore, nla_data(attr), straight
there to avoid the copy.

Bonding even uses dev_get_stats() in this way.

The existing rtnl_fill_stats() can be improved similarly but is of
course a separate change.  In that case, we'd do something like:

	struct rtnl_link_stats64 *sp;

	attr = nla_reserve(skb, IFLA_STATS64,
			   sizeof(struct rtnl_link_stats64));
	if (!attr)
		return -EMSGSIZE;

	sp = nla_data(attr);
	dev_get_stats(dev, sp);

	attr = nla_reserve(skb, IFLA_STATS,
			   sizeof(struct rtnl_link_stats));
	if (!attr)
		return -EMSGSIZE;

	copy_rtnl_link_stats(nla_data(attr), sp);

Thanks.
