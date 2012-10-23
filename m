From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 2/3] rtnl/ipv6: use netconf msg to
 advertise forwarding status
Date: Tue, 23 Oct 2012 13:29:40 -0400 (EDT)
Message-ID: <20121023.132940.1732325493436273627.davem@davemloft.net>
References: <1350985789-24966-1-git-send-email-nicolas.dichtel@6wind.com>
	<1350985789-24966-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42584 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757268Ab2JWR3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:29:42 -0400
In-Reply-To: <1350985789-24966-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 23 Oct 2012 11:49:48 +0200

> +static int inet6_fill_netconf_devconf(struct sk_buff *skb, int ifindex,
> +				      struct ipv6_devconf *devconf, u32 portid,
> +				      u32 seq, int event, unsigned int flags)
> +{
> +	struct nlmsghdr  *nlh;
> +	struct netconfmsg *ncm;
> +
> +	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct netconfmsg),
> +			flags);
> +	if (nlh == NULL)
> +		return -EMSGSIZE;
> +
> +	ncm = nlmsg_data(nlh);
> +	ncm->ncm_family = AF_INET6;
> +
> +	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0) {
> +		nlmsg_cancel(skb, nlh);
> +		return -EMSGSIZE;
> +	}
> +	if (nla_put_s32(skb, NETCONFA_FORWARDING, devconf->forwarding) < 0) {
> +		nlmsg_cancel(skb, nlh);
> +		return -EMSGSIZE;
> +	}
> +
> +	return nlmsg_end(skb, nlh);
> +}

Don't report values that aren't changing, that's wasteful.

You need to therefore provide a ->get() operation, so that when
a daemon starts up which is interested in these values, it can
fetch the initial state.

That's why you should only report the differences in the events,
rather than unconditionally reporting all the values all the
time, whether they change or not.
