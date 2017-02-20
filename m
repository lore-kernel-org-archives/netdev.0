From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next v4 09/12] net: ethernet: aquantia: Call
 netdev_register after all initialized.
Date: Mon, 20 Feb 2017 23:48:05 +0100
Message-ID: <84899350-639a-e31e-b9b8-c717b33f172b@gmx.de>
References: <cover.1487618263.git.pavel.belous@aquantia.com>
 <dfd4ea5db31da50c549a7ed411d1b0660a9b7498.1487618263.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:49636 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750981AbdBTWsS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 17:48:18 -0500
In-Reply-To: <dfd4ea5db31da50c549a7ed411d1b0660a9b7498.1487618263.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.02.2017 20:36, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> netdev_register should be called when everything is initialized.
> Also we should use net_device->reg_state field instead own
> "is_ndev_registered" flag to avoid any race.
> 
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c          | 10 +++++-----
>  drivers/net/ethernet/aquantia/atlantic/aq_nic_internal.h |  1 -
>  2 files changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> index a8a27c5..bce312a 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> @@ -261,16 +261,16 @@ int aq_nic_ndev_register(struct aq_nic_s *self)
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
>  err_exit:
>  	return err;
>  }
> @@ -293,7 +293,7 @@ void aq_nic_ndev_free(struct aq_nic_s *self)
>  	if (!self->ndev)
>  		goto err_exit;
>  
> -	if (self->is_ndev_registered)
> +	if (self->ndev->reg_state == NETREG_REGISTERED)
>  		unregister_netdev(self->ndev);

Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

A suggestion for a future patch (not necessarily part of this series):
Get rid of the above check at all. AFAICS aq_nic_ndev_free() is only
called in remove() and in probe(). In remove() the check is not needed, since it
always evaluates to true (device is always registered). In probe() it is only
needed for a clean unwind in case of error. The latter can also be done without
 the check in aq_nic_ndev_free().

Regards,
Lino
