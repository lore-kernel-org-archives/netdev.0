From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 02/11] net/mlx5_core: Add EQ renaming
 mechanism
Date: Mon, 11 May 2015 13:40:08 -0400 (EDT)
Message-ID: <20150511.134008.7539040783838247.davem@davemloft.net>
References: <1431250746-11941-1-git-send-email-amirv@mellanox.com>
	<1431250746-11941-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	achiad@mellanox.com, saeedm@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbbEKRkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:40:10 -0400
In-Reply-To: <1431250746-11941-3-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sun, 10 May 2015 12:38:57 +0300

> +int mlx5_rename_eq(struct mlx5_core_dev *dev, int eq_ix, char *name)
> +{
> +	struct mlx5_priv *priv = &dev->priv;
> +	struct mlx5_eq_table *table = &priv->eq_table;
> +	struct mlx5_eq *eq;
> +	int err = -ENOENT;
> +
> +	spin_lock(&table->lock);
> +	list_for_each_entry(eq, &table->comp_eqs_list, list) {
> +		if (eq->index == eq_ix) {
> +			snprintf(priv->irq_info[eq_ix].name, MLX5_MAX_IRQ_NAME,
> +				 "%s-%d", name, eq_ix);
> +			err = 0;
> +			break;
> +		}
> +	}
> +	spin_unlock(&table->lock);
> +
> +	return err;
> +}

You have to be very careful with this.

If you change these names after the request_irq() call(s), the new name string
will not propagate to /proc/interrupts output etc.

Looking at your later patches, this seems to be invoked very late in
mlx5e_open_locked(), so I am concerned.
