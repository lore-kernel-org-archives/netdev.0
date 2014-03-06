From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net/mlx4_core: mlx4_init_slave() shouldn't
 access comm channel before PF is ready
Date: Thu, 06 Mar 2014 15:12:54 -0500 (EST)
Message-ID: <20140306.151254.914568962698409365.davem@davemloft.net>
References: <1394123297-7878-1-git-send-email-amirv@mellanox.com>
	<1394123297-7878-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, yevgenyp@mellanox.com, Narendra_K@Dell.com,
	Sreekanth_Reddy@Dell.com, netdev@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbaCFUM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 15:12:56 -0500
In-Reply-To: <1394123297-7878-3-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu,  6 Mar 2014 18:28:17 +0200

> @@ -150,6 +150,8 @@ struct mlx4_port_config {
>  	struct pci_dev *pdev;
>  };
>  
> +static atomic_t pf_loading = ATOMIC_INIT(0);
> +
>  int mlx4_check_port_params(struct mlx4_dev *dev,
>  			   enum mlx4_port_type *port_type)
>  {
> @@ -1407,6 +1409,11 @@ static int mlx4_init_slave(struct mlx4_dev *dev)
>  	u32 slave_read;
>  	u32 cmd_channel_ver;
>  
> +	if (atomic_read(&pf_loading)) {
> +		mlx4_warn(dev, "PF is not ready. Deferring probe\n");
> +		return -EPROBE_DEFER;
> +	}
> +
 ...
> @@ -2319,7 +2326,11 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
>  
>  		if (num_vfs) {
>  			mlx4_warn(dev, "Enabling SR-IOV with %d VFs\n", num_vfs);
> +
> +			atomic_inc(&pf_loading);
>  			err = pci_enable_sriov(pdev, num_vfs);
> +			atomic_dec(&pf_loading);
> +

This synchronization scheme doesn't look right to me at all.

It's global, so VF's for _any_ PF will probe defer while one is enabling
SRIOV.

It doesn't seem correct to cause unrelated VF's to defer the probe.

You have absolutely have to maintain this state at least on a per-PF
level.
