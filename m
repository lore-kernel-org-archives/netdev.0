From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next v2 10/11] mlxsw: spectrum_router: Request a dump of
 FIB tables during init
Date: Wed, 23 Nov 2016 17:00:00 +0100
Message-ID: <1479916800.4019894.797128001.743EBB6A@webmail.messagingengine.com>
References: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
 <1479912528-4636-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:34277 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S940622AbcKWQAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 11:00:46 -0500
In-Reply-To: <1479912528-4636-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016, at 15:48, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Make sure the device has a complete view of the FIB tables by invoking
> their dump during module init.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 16
>  ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> index 14bed1d..36a71d2 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> @@ -2027,6 +2027,21 @@ static int mlxsw_sp_router_fib_event(struct
> notifier_block *nb,
>  	return NOTIFY_DONE;
>  }
>  
> +static void mlxsw_sp_router_fib_dump(struct mlxsw_sp *mlxsw_sp)
> +{
> +       while (!fib_notifier_dump(&mlxsw_sp->fib_nb)) {
> +               /* Flush pending FIB notifications and then flush the
> +                * device's table before requesting another dump. Do
> +                * that with RTNL held, as FIB notification block is
> +                * already registered.
> +                */
> +               mlxsw_core_flush_owq();
> +               rtnl_lock();
> +               mlxsw_sp_router_fib_flush(mlxsw_sp);
> +               rtnl_unlock();
> +       }
> +}

I think it is fine to use this kind of synchronization.

But I think that this part of the logic still belongs into the core
kernel. I still think it could happen that we will loop here
indefinitely because of a lot of routing updates and as such would need
to abort this loop after a number of tries.

I would like that the kernel has one function to do this decision
instead of later patching all users of this API. Do you think it is
worth it?

Bye,
Hannes
