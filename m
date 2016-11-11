From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net 2/2] mlxsw: spectrum_router: Correctly dump neighbour
 activity
Date: Fri, 11 Nov 2016 14:54:05 +0200
Message-ID: <20161111125405.x56ipwlaoln4b4fe@splinter>
References: <1478859642-2918-1-git-send-email-jiri@resnulli.us>
 <1478859642-2918-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        arkadis@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        nogahf@mellanox.com, ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:44658 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750714AbcKKNBQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 08:01:16 -0500
Content-Disposition: inline
In-Reply-To: <1478859642-2918-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2016 at 11:20:42AM +0100, Jiri Pirko wrote:
> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> During neighbour activity check the device's table is dumped by multiple
> query requests. The query session should end when the response carries
> less records than requested or when a given record is not full. Current
> code only stops the dumping process if the number of returned records is
> zero, which can result in infinite loop in case of activity.
> 
> Fix this by stopping the dumping process according to the above logic.
> 
> Fixes: c723c735fa6b ("mlxsw: spectrum_router: Periodically update the kernel's neigh table")
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 22 +++++++++++++++++++++-
>  1 file changed, 21 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> index 040737e..d437457 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> @@ -800,6 +800,26 @@ static void mlxsw_sp_router_neigh_rec_process(struct mlxsw_sp *mlxsw_sp,
>  	}
>  }
>  
> +static bool mlxsw_sp_router_rauhtd_is_full(char *rauhtd_pl)
> +{
> +	u8 num_rec, last_rec_index, num_entries;
> +
> +	num_rec = mlxsw_reg_rauhtd_num_rec_get(rauhtd_pl);
> +	last_rec_index = num_rec - 1;
> +
> +	if (num_rec < MLXSW_REG_RAUHTD_REC_MAX_NUM)
> +		return false;
> +	if (mlxsw_reg_rauhtd_rec_type_get(rauhtd_pl, last_rec_index) ==
> +	    MLXSW_REG_RAUHTD_TYPE_IPV6)
> +		return true;
> +
> +	num_entries = mlxsw_reg_rauhtd_ipv4_rec_num_entries_get(rauhtd_pl,
> +								last_rec_index);
> +	if (++num_entries ==  MLXSW_REG_RAUHTD_IPV4_ENT_PER_REC)

Jiri, I just noticed we have an extra space after the '=='. Can you
please remove it in v2? Sorry for not spotting this earlier.

> +		return true;
> +	return false;
> +}
> +
>  static int mlxsw_sp_router_neighs_update_rauhtd(struct mlxsw_sp *mlxsw_sp)
>  {
>  	char *rauhtd_pl;
> @@ -826,7 +846,7 @@ static int mlxsw_sp_router_neighs_update_rauhtd(struct mlxsw_sp *mlxsw_sp)
>  		for (i = 0; i < num_rec; i++)
>  			mlxsw_sp_router_neigh_rec_process(mlxsw_sp, rauhtd_pl,
>  							  i);
> -	} while (num_rec);
> +	} while (mlxsw_sp_router_rauhtd_is_full(rauhtd_pl));
>  	rtnl_unlock();
>  
>  	kfree(rauhtd_pl);
> -- 
> 2.7.4
> 
