From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 3/7] mlx4: In RoCE allow guests to have
 multiple GIDS
Date: Wed, 12 Mar 2014 01:00:52 -0400 (EDT)
Message-ID: <20140312.010052.1153760698053567291.davem@davemloft.net>
References: <1394542976-20095-1-git-send-email-ogerlitz@mellanox.com>
	<1394542976-20095-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbaCLFAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 01:00:54 -0400
In-Reply-To: <1394542976-20095-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 11 Mar 2014 15:02:52 +0200

> +static int get_slave_base_gid_ix(struct mlx4_ib_dev *dev, int slave, int port)
> +{
> +	int gids;
> +	int vfs;
> +
> +	if (rdma_port_get_link_layer(&dev->ib_dev, port) == IB_LINK_LAYER_INFINIBAND)
> +		return slave;
> +
> +	gids = MLX4_ROCE_MAX_GIDS - MLX4_ROCE_PF_GIDS;
> +	vfs = dev->dev->num_vfs;
> +
> +	if (slave == 0)
> +		return 0;
> +	if (slave <= gids % vfs)
> +		return MLX4_ROCE_PF_GIDS + ((gids / vfs) + 1) * (slave - 1);
> +
> +	return MLX4_ROCE_PF_GIDS + (gids % vfs) + ((gids / vfs) * (slave - 1));
> +}
> +
> +static int get_real_sgid_index(struct mlx4_ib_dev *dev, int slave, int port,
> +			       struct ib_ah_attr *ah_attr)
> +{
> +	if (rdma_port_get_link_layer(&dev->ib_dev, port) == IB_LINK_LAYER_INFINIBAND) {
> +		ah_attr->grh.sgid_index = slave;
> +		return 0;
> +	}
> +	ah_attr->grh.sgid_index += get_slave_base_gid_ix(dev, slave, port);
> +	return 0;
> +}

I hate to be picky like this, but this second function could be improved.

The first function is fine, it's named "get_*" and it really does return
a value.

But the second one, it's also named "get_*" but it doesn't return the
stated value.  Instead, it assigns it into a structure.

The return value is always zero, so I suggest you make it return void and
adjust the name.  Perhaps "fill_in_real_sgid_index", since that states
explicitly that the value is "filled in" to the passed ah_attr.
