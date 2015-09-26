From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 01/11] net: Introduce L3 Master device
 abstraction
Date: Sat, 26 Sep 2015 15:24:22 +0200
Message-ID: <56069C86.6040400@cumulusnetworks.com>
References: <1443140467-69297-1-git-send-email-dsa@cumulusnetworks.com>
 <1443140467-69297-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:34934 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbbIZNYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 09:24:25 -0400
Received: by wicge5 with SMTP id ge5so52414319wic.0
        for <netdev@vger.kernel.org>; Sat, 26 Sep 2015 06:24:24 -0700 (PDT)
In-Reply-To: <1443140467-69297-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<<<snip>>>
> + *	l3mdev_master_ifindex - get index of L3 master device
> + *	@dev: targeted interface
> + */
> +
> +int l3mdev_master_ifindex_rcu(struct net_device *dev)
> +{
> +	int ifindex = 0;
> +
> +	if (!dev)
> +		return 0;
> +
> +	if (netif_is_l3_master(dev)) {
> +		ifindex = dev->ifindex;
> +
^^
Extra empty line.

> +	} else if (dev->flags & IFF_SLAVE) {
> +		struct net_device *master;
> +
> +		master = netdev_master_upper_dev_get_rcu(dev);
> +		if (netif_is_l3_master(master))
^^
maybe check if master is non-null, otherwise this imposes a new
restriction on the ordering of iff_slave / master_upper setting,
also a very old driver that uses iff_slave/master doesn't set the
master_upper, but only the flag (eql).
Actually, is this bisectable ? I see netif_is_l3_master() being
introduced in the next patch, so I don't think you can compile
this one.

> +			ifindex = master->ifindex;
> +	}
> +
> +	return ifindex;
> +}
> +
> +/**
> + *	l3mdev_fib_table - get FIB table id associated with an L3
> + *                             master interface
> + *	@dev: targeted interface
> + */
> +
> +u32 l3mdev_fib_table_rcu(const struct net_device *dev)
> +{
> +	u32 tb_id = 0;
> +
> +	if (!dev)
> +		return 0;
> +
> +	if (netif_is_l3_master(dev)) {
> +		if (dev->l3mdev_ops->l3mdev_fib_table)
> +			tb_id = dev->l3mdev_ops->l3mdev_fib_table(dev);
> +
^^
Extra empty line.

> +	} else if (dev->flags & IFF_SLAVE) {
> +		/* TO-DO: remove the need for typecast.
> +		 * Users of netdev_master_upper_dev_get_rcu need non-const,
> +		 * but current inet_*type functions take a const
> +		 */
> +		struct net_device *_dev = (struct net_device *) dev;
> +		const struct net_device *master;
> +
> +		master = netdev_master_upper_dev_get_rcu(_dev);
> +		if (!master)
> +			return 0;
> +
> +		if (netif_is_l3_master(master) &&
> +		    master->l3mdev_ops->l3mdev_fib_table)
> +			tb_id = master->l3mdev_ops->l3mdev_fib_table(master);
> +	}
> +
> +	return tb_id;
> +}
> +
> +u32 l3mdev_fib_table_by_index(struct net *net, int ifindex)
> +{
> +	struct net_device *dev;
> +	u32 tb_id = 0;
> +
> +	if (!ifindex)
> +		return 0;
> +
> +	rcu_read_lock();
> +
> +	dev = dev_get_by_index_rcu(net, ifindex);
> +	if (dev)
> +		tb_id = l3mdev_fib_table_rcu(dev);
> +
> +	rcu_read_unlock();
> +
> +	return tb_id;
> +}
> 
