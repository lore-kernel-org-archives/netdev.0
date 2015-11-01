From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/8] net/mlx5e: Consider IRQ affinity changes
 in NAPI poll
Date: Sun, 01 Nov 2015 17:34:07 -0500 (EST)
Message-ID: <20151101.173407.1794026161201499991.davem@davemloft.net>
References: <1446399322-14046-1-git-send-email-ogerlitz@mellanox.com>
	<1446399322-14046-5-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, saeedm@mellanox.com, achiad@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbbKAWeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 17:34:11 -0500
In-Reply-To: <1446399322-14046-5-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  1 Nov 2015 19:35:18 +0200

> @@ -49,6 +50,15 @@ struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
>  	return cqe;
>  }
>  
> +static inline bool mlx5e_no_channel_affinity_change(struct mlx5e_channel *c)
> +{
> +	int current_cpu = smp_processor_id();
> +	struct irq_data *d = irq_desc_get_irq_data(c->irq_desc);
> +	struct cpumask *aff = irq_data_get_affinity_mask(d);
> +
> +	return cpumask_test_cpu(current_cpu, aff);
> +}

This is so much pointer dereferencing and then a bitmask test as well.

Are you really sure sure an extremely rare situation warrants this
test every single NAPI poll call?

If this is a real problem, then every driver is susceptible to the
issue and it therefore warrants a generic solution.  And if we have
generic infrastructure for this situation in the code NAPI polling
networking code, I guarantee that it will probably be implemented much
more cheaply than this.
