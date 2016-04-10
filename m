From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Sun, 10 Apr 2016 10:16:50 +0200
Message-ID: <20160410081650.GB22873@pox.localdomain>
References: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37619 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbcDJIQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 04:16:53 -0400
Received: by mail-wm0-f52.google.com with SMTP id n3so67867598wmn.0
        for <netdev@vger.kernel.org>; Sun, 10 Apr 2016 01:16:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/16 at 11:38pm, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds a new RTM_GETSTATS message to query link stats via netlink
> from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK
> returns a lot more than just stats and is expensive in some cases when
> frequent polling for stats from userspace is a common operation.
> 
> RTM_GETSTATS is an attempt to provide a light weight netlink message
> to explicity query only link stats from the kernel on an interface.
> The idea is to also keep it extensible so that new kinds of stats can be
> added to it in the future.
> 
> This patch adds the following attribute for NETDEV stats:
> struct nla_policy ifla_stats_policy[IFLA_STATS_MAX + 1] = {
>         [IFLA_STATS_LINK64]  = { .len = sizeof(struct rtnl_link_stats64) },
> };
> 
> This patch also allows for af family stats (an example af stats for IPV6
> is available with the second patch in the series).
> 
> Like any other rtnetlink message, RTM_GETSTATS can be used to get stats of
> a single interface or all interfaces with NLM_F_DUMP.

Awesome stuff Roopa.

This currently ties everything to a net_device with a selector to
include certain bits of that net_device. How about we take it half a
step further and allow for non net_device stats such as IP, TCP,
routing or ipsec stats to be retrieved as well?

A simple array of nested attributes replacing IFLA_STATS_* would
allow for that, e.g.

1. {.type = ST_IPSTATS, value = { ...} }

2. {.type = ST_LINK, .value = {
    {.type = ST_LINK_NAME, .value = "eth0"},
    {.type = ST_LINK_Q, .value = 10}
  }}

3. ...

So for your initial patch, you'd simply add a new top level attribute
which ties all the net_device specific statistics to a top level
attribute and we can add the non net_device specific stats later on.
We can't do that later on though without breaking ABI so that would
have to go in with the first iteration.

We can preserve all the existing attribute formats, we simply have
to introduce new attribute types which don't overlap and document
which statistic identifier maps to which existing attribute id.
