From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 09/12] net: ethernet: aquantia: Call
 netdev_register after all initialized.
Date: Mon, 20 Feb 2017 11:28:20 -0500 (EST)
Message-ID: <20170220.112820.161041046228087344.davem@davemloft.net>
References: <cover.1487590641.git.pavel.belous@aquantia.com>
        <13775c9d9cacbb20b276d350c46c74182fb92ab0.1487590641.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon.Edelhaus@aquantia.com,
        Alexey.Andriyanov@aquantia.com, LinoSanfilippo@gmx.de
To: Pavel.Belous@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39536 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753470AbdBTQ2W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 11:28:22 -0500
In-Reply-To: <13775c9d9cacbb20b276d350c46c74182fb92ab0.1487590641.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <Pavel.Belous@aquantia.com>
Date: Mon, 20 Feb 2017 14:41:51 +0300

> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> netdev_register should be called when everything is initialized.
> 
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> index a8a27c5..fdd7d72 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> @@ -261,16 +261,18 @@ int aq_nic_ndev_register(struct aq_nic_s *self)
>  		ether_addr_copy(self->ndev->dev_addr, mac_addr_permanent);
>  	}
>  #endif
> -	err = register_netdev(self->ndev);
> -	if (err < 0)
> -		goto err_exit;
>  
> -	self->is_ndev_registered = true;
>  	netif_carrier_off(self->ndev);
>  
>  	for (i = AQ_CFG_VECS_MAX; i--;)
>  		aq_nic_ndev_queue_stop(self, i);
>  
> +	err = register_netdev(self->ndev);
> +	if (err < 0)
> +		goto err_exit;
> +
> +	self->is_ndev_registered = true;
> +

Please get rid of this self->is_ndev_registered state, it is not
necessary and it is racey.

The very moment you call register_netdev(), your ->open() method
along with the rest of your driver can be invoked.

Therefore any dependency of state changes after register_netdev()
cannot be depended upon by the rest of the driver, code is going
to run immediately elsewhere in your driver as soon as that
register_netdev() is invoked, and it is going to test that
->is_ndev_registered() value, and it's going to be wrong.

Instead, test netdev->reg_state if you absolutely must have this
piece of information.
