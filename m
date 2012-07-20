From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] net: Add support for virtual machine device queues
 (VMDQ)
Date: Fri, 20 Jul 2012 19:09:36 +0100
Message-ID: <1342807776.2678.40.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120718220544.22619.97136.stgit@i40e.jf1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <or.gerlitz@gmail.com>, <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, <shlomop@mellanox.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55390 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752731Ab2GTSJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:09:40 -0400
In-Reply-To: <20120718220544.22619.97136.stgit@i40e.jf1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 18:05 -0400, John Fastabend wrote:
> This adds support to allow virtual net devices to be created. These
> devices can be managed independtly of the physical function but
> use the same physical link.
> 
> This is analagous to an offloaded macvlan device. The primary
> advantage to VMDQ net devices over virtual functions is they can
> be added and removed dynamically as needed.

Is VMDQ intended to become a generic name?

> Sending this for Or Gerlitz to take a peak at and see if this
> could be used for his ipoib bits. Its not pretty as is and
> likely needs some work its just an idea at this point use at
> your own risk I believe it compiles.
[...]
> +static int vmdq_newlink(struct net *src_net, struct net_device *dev,
> +		       struct nlattr *tb[], struct nlattr *data[])
> +{
> +	struct net_device *lowerdev;
> +	int err = -EOPNOTSUPP;
> +
> +	if (!tb[IFLA_LINK])
> +		return -EINVAL;
> +
> +	lowerdev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
> +	if (!lowerdev)
> +		return -ENODEV;
> +
> +	if (!tb[IFLA_MTU])
> +		dev->mtu = lowerdev->mtu;
> +	else if (dev->mtu > lowerdev->mtu)
> +		return -EINVAL;
> +
> +	if (lowerdev->netdev_ops->ndo_add_vmdq)
> +		err = lowerdev->netdev_ops->ndo_add_vmdq(lowerdev, dev);

Why isn't the device allocation left to the lower device driver?  It
seems like this would simplify things quite a bit.

[...]
> +int vmdq_get_tx_queues(struct net *net, struct nlattr *tb[])
> +{
> +       struct net_device *lowerdev;
> +
> +       if (!tb[IFLA_LINK])
> +               return -EINVAL;
> +
> +       lowerdev = __dev_get_by_index(net, nla_get_u32(tb[IFLA_LINK]));
> +       if (!lowerdev)
> +               return -ENODEV;
> +
> +       return lowerdev->num_tx_queues;
> +}
[...]

Why should this match the lower device?  Is the assumption that it will
share the lower device's TX queues and only have its own RX queue(s)?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
