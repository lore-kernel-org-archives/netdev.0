From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v3 1/2] rtnetlink: add new RTM_GETSTATS message
 to query stats
Date: Sat, 16 Apr 2016 09:49:10 +0200
Message-ID: <20160416074910.GA2486@pox.localdomain>
References: <1460777293-39474-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35364 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbcDPHtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 03:49:13 -0400
Received: by mail-wm0-f54.google.com with SMTP id a140so57554243wma.0
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 00:49:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1460777293-39474-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/16 at 08:28pm, Roopa Prabhu wrote:
> +static u16 rtnl_stats_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
> +{
> +	struct net *net = sock_net(skb->sk);
> +	struct net_device *dev;
> +	u16 min_ifinfo_dump_size = 0;
> +	struct if_stats_msg *ifsm;
> +	u32 filter_mask;
> +
> +	ifsm = nlmsg_data(nlh);
> +	filter_mask = ifsm->filter_mask;
> +
> +	/* traverse the list of net devices and compute the minimum
> +	 * buffer size based upon the filter mask.
> +	 */
> +	list_for_each_entry(dev, &net->dev_base_head, dev_list) {
> +		min_ifinfo_dump_size = max_t(u16, min_ifinfo_dump_size,
> +					     if_nlmsg_stats_size(dev,
> +								 filter_mask));
> +	}

Iterating over all net_devices in the namespace is quite an expensive
operation and it would now be done twice.

I understand that this code is taken over from rtnl_calcit() but there
the cost is at least only paid if ext_filter_mask is actually set and
the user opts into additional statistics.

I wonder if we can reduce the cost for the stats interface as its
purpose is to be minimal cost. I suggest we only add the loop once we
have an extension which actually depends on it. We can then try and
figure out to not require it.
