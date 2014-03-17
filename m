From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH v2 2/2] IB/mlx5: Free resources during PCI error
Date: Mon, 17 Mar 2014 15:32:55 +0200
Message-ID: <20140317133255.GA22637@mtldesk30>
References: <20140314171456.181059236@linux.vnet.ibm.com>
 <20140314171659.686646150@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eli@mellanox.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:46923 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933409AbaCQNdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 09:33:01 -0400
Received: by mail-ee0-f41.google.com with SMTP id t10so4147720eei.14
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 06:33:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140314171659.686646150@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 14, 2014 at 12:14:58PM -0500, clsoto@linux.vnet.ibm.com wrote:

Hi Carol, see my comments below.
Also, can please share with us if you've been making any testing to
these patches, how you tested and what were the results?
 
> @@ -471,9 +471,12 @@ static void clean_keys(struct mlx5_ib_de
>  		ent->size--;
>  		spin_unlock_irq(&ent->lock);
>  		err = mlx5_core_destroy_mkey(&dev->mdev, &mr->mmr);
> -		if (err)
> -			mlx5_ib_warn(dev, "failed destroy mkey\n");
> -		else
> +		if (err) {
> +			if (pci_channel_offline(dev->mdev.pdev))
> +				kfree(mr);

Why not just check if -EIO returned.

> +			else
> +				mlx5_ib_warn(dev, "failed destroy mkey\n");
> +		} else
>  			kfree(mr);
>  	}
>  }
> Index: b/drivers/infiniband/hw/mlx5/qp.c
> ===================================================================
> --- a/drivers/infiniband/hw/mlx5/qp.c
> +++ b/drivers/infiniband/hw/mlx5/qp.c
> @@ -2564,7 +2564,11 @@ int mlx5_ib_dealloc_xrcd(struct ib_xrcd 
>  
>  	err = mlx5_core_xrcd_dealloc(&dev->mdev, xrcdn);
>  	if (err) {
> -		mlx5_ib_warn(dev, "failed to dealloc xrcdn 0x%x\n", xrcdn);
> +		if (pci_channel_offline(dev->mdev.pdev))
> +			kfree(xrcd);
> +		else
> +			mlx5_ib_warn(dev, "failed to dealloc xrcdn 0x%x\n",
> +				     xrcdn);
You chose to give special treatment to this command, why is that?
>  		return err;
>  	}
>  
