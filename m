From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC] bridge: partial rtnetlink hooks
Date: Thu, 27 Apr 2006 00:24:01 +0200
Message-ID: <20060426222401.GA6860@electric-eye.fr.zoreil.com>
References: <20060426104521.44682924@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46479 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S964874AbWDZW1e
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 18:27:34 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060426104521.44682924@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> --- /dev/null
> +++ bridge-2.6/net/bridge/br_netlink.c
[...]
> +static int br_fill_ifinfo(struct sk_buff *skb, const struct net_bridge_port *port,
> +			  u32 pid, u32 seq, int event, unsigned int flags)
> +{
[...]
> +nlmsg_failure:
> +rtattr_failure:
> +
> +	skb_trim(skb, b - skb->data);
> +	return -1;

	return -EINVAL;

(see below)

> +}
> +
> +
> +void br_ifinfo_notify(int event, struct net_bridge_port *port)
> +{
> +	struct sk_buff *skb;
> +
> +	printk(KERN_DEBUG "bridge notify event=%d\n", event);
> +	skb = alloc_skb(NLMSG_SPACE(sizeof(struct ifinfomsg) + 128),
> +			GFP_ATOMIC);
> +	if (!skb) {
> +		netlink_set_err(rtnl, 0, RTNLGRP_BRIDGE_IFINFO, ENOBUFS);
> +		return;
> +	}
> +	if (br_fill_ifinfo(skb, port, current->pid, 0, event, 0) < 0) {
> +		kfree_skb(skb);
> +		netlink_set_err(rtnl, 0, RTNLGRP_BRIDGE_IFINFO, EINVAL);
> +		return;
> +	}
> +	NETLINK_CB(skb).dst_group = RTNLGRP_IPV6_IFINFO;
> +	netlink_broadcast(rtnl, skb, 0, RTNLGRP_BRIDGE_IFINFO, GFP_ATOMIC);
> +}

void br_ifinfo_notify(int event, struct net_bridge_port *port)
{
	struct sk_buff *skb;
	int err = -ENOBUFS;

	printk(KERN_DEBUG "bridge notify event=%d\n", event);
	skb = alloc_skb(NLMSG_SPACE(sizeof(struct ifinfomsg) + 128),
			GFP_ATOMIC);
	if (!skb)
		goto err_out;

	err = br_fill_ifinfo(skb, port, current->pid, 0, event, 0);
	if (unlikely((err < 0))
		goto err_kfree;

	NETLINK_CB(skb).dst_group = RTNLGRP_IPV6_IFINFO;
	netlink_broadcast(rtnl, skb, 0, RTNLGRP_BRIDGE_IFINFO, GFP_ATOMIC);
	return;

err_kfree:
	kfree_skb(skb);
err_out:
	netlink_set_err(rtnl, 0, RTNLGRP_BRIDGE_IFINFO, -err);
}

-- 
Ueimor
