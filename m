From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC] rtnetlink: add new RTM_GETSTATS to dump
 link stats
Date: Wed, 24 Feb 2016 16:40:03 -0500 (EST)
Message-ID: <20160224.164003.357595978348193472.davem@davemloft.net>
References: <1456207293-36903-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbcBXVkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 16:40:08 -0500
In-Reply-To: <1456207293-36903-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Mon, 22 Feb 2016 22:01:33 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds a new RTM_GETSTATS message to query link stats via netlink
> from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK returns a
> lot more than just stats and is expensive in some cases when frequent
> polling for stats from userspace is a common operation.

Even worse, we push two copies of the same exact stats.  Once to give
the (deprecated) 32-bit rtnl stats, and once to give the 64-bit ones.

This is rather rediculous, but was probably done for compatability.

> To begin with, this patch adds the following types of stats (which are
> also available via RTM_NEWLINK today):
> 
> struct nla_policy ifla_stats_policy[IFLA_LINK_STATS_MAX + 1] = {
>         [IFLA_LINK_STATS]       = { .len = sizeof(struct rtnl_link_stats) },
>         [IFLA_LINK_STATS64]     = { .len = sizeof(struct rtnl_link_stats64) },
>         [IFLA_LINK_INET6_STATS] = {. type = NLA_NESTED },
> };

I think we should skip the old 32-bit stats and only provide the full
native 64-bit rtnl_link_stats64.  Apps have to have changes to use
this new facility, therefore they can be adjusted for the (extremely
minimal) amount of work necessary to understand 64-bit stats if
necessary.

By using rtnl_fill_stats() we would unnecessarily continue to send
duplicate and extra information unnecessarily.

We have the chance to fix this here, so let's take advantage of the
opportunity to promote the data structure which can then be a first
class citizen not only in the kernel but in userspace too.

> Filtering stats (if the user wanted to query just ipv6 stats ?):
> a) I have a version of the patch that uses 'struct ifinfomsg->ifi_family'
> as a filter from userspace. But, given that in the future we may want to
> not just filter by family, I have dropped it in favor of
> attribute filtering (not included in this patch but point b) below).
> 
> b) RTM_GETSTATS message to contain attributes in the request message
> 
> 	nlmsg_parse(nlh, ....IFLA_LINK_STATS_MAX, ifla_stats_policy...)
> 
> 	if tb[IFLA_LINK_INET6_STATS]
> 		include ipv6 stats in the dump
> 
> 	if tb[IFLA_LINK_MPLS_STATS]
> 		include mpls stats in the dump

I wonder if an additive method is better.  Provide IFLA_LINK_STATS64
by default, and the user has to ask for more.

Or the user gets nothing, and a simply u32 bitmap in the request acts
as a selector, with enable bits for each stat type.

It really has to be easy to carve out exactly the information the user
wants, and be very minimal by default in order to be as efficient as
possible.
