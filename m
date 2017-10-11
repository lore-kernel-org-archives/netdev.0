From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [RFC net-next 4/4] mlxsw: spectrum_router: Add extack message
 for RIF and VRF overflow
Date: Wed, 11 Oct 2017 17:13:30 +0300
Message-ID: <20171011141330.GC11653@splinter>
References: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
 <1507653665-20540-5-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        kjlx@templeofstupid.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:60643 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753699AbdJKONe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 10:13:34 -0400
Content-Disposition: inline
In-Reply-To: <1507653665-20540-5-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 09:41:05AM -0700, David Ahern wrote:
> Add extack argument down to mlxsw_sp_rif_create and mlxsw_sp_vr_create
> to set an error message on RIF or VR overflow. Now an overflow of
> either resource the use gets an informative message as opposed to

s/the/in/ ?

> failing with EBUSY.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

One comment below, but other than that:

Reviewed-by: Ido Schimmel <idosch@mellanox.com>

I'll run some tests and report if anything blows up.

Thanks David!

> ---
>  .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 114 +++++++++++++--------
>  1 file changed, 69 insertions(+), 45 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> index 7d53fdf2c0a8..ec4d313b9eca 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> @@ -731,14 +731,17 @@ static struct mlxsw_sp_fib *mlxsw_sp_vr_fib(const struct mlxsw_sp_vr *vr,
>  }
>  
>  static struct mlxsw_sp_vr *mlxsw_sp_vr_create(struct mlxsw_sp *mlxsw_sp,
> -					      u32 tb_id)
> +					      u32 tb_id,
> +					      struct netlink_ext_ack *extack)
>  {
>  	struct mlxsw_sp_vr *vr;
>  	int err;
>  
>  	vr = mlxsw_sp_vr_find_unused(mlxsw_sp);
> -	if (!vr)
> +	if (!vr) {
> +		NL_SET_ERR_MSG(extack, "spectrum: Exceeded number of supported VRF");

Maybe:
"spectrum: Exceeded number of supported VRF devices"

To be consistent with previously added:
"spectrum: Exceeded number of supported LAG devices"

>  		return ERR_PTR(-EBUSY);
> +	}
>  	vr->fib4 = mlxsw_sp_fib_create(vr, MLXSW_SP_L3_PROTO_IPV4);
>  	if (IS_ERR(vr->fib4))
>  		return ERR_CAST(vr->fib4);
> @@ -775,14 +778,15 @@ static void mlxsw_sp_vr_destroy(struct mlxsw_sp_vr *vr)
>  	vr->fib4 = NULL;
>  }
