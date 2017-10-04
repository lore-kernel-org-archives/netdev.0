From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next 7/7] mlxsw: spectrum: Add extack messages for
 enslave failures
Date: Wed, 4 Oct 2017 16:24:03 +0300
Message-ID: <20171004132403.GA14864@splinter>
References: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
 <1507093134-20406-8-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, jiri@mellanox.com, idosch@mellanox.com,
        davem@davemloft.net, bridge@lists.linux-foundation.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:46895 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752332AbdJDNYI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 09:24:08 -0400
Content-Disposition: inline
In-Reply-To: <1507093134-20406-8-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 03, 2017 at 09:58:54PM -0700, David Ahern wrote:
> mlxsw fails device enslavement for a number of reasons. Use the extack
> facility to return an error message to the user stating why the enslave
> is failing.
> 
> Messages are prefixed with "spectrum" so users know it is a constraint
> imposed by the hardware driver. For example:
>     $ ip li add br0.11 link br0 type vlan id 11
>     $ ip li set swp11 master br0
>     Error: spectrum: Enslaving a port to a device that already has an upper device is not supported.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Great stuff, thanks David!

Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Tested-by: Ido Schimmel <idosch@mellanox.com>

See one small nit below, but I would like to patch
mlxsw_sp_netdevice_port_vlan_event() as well, so I can take care of it
then.

> ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 46 ++++++++++++++++++++------
>  1 file changed, 36 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
> index 3adf237c951a..a6cc00e4e543 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
> @@ -4019,14 +4019,20 @@ static int mlxsw_sp_lag_index_get(struct mlxsw_sp *mlxsw_sp,
>  static bool
>  mlxsw_sp_master_lag_check(struct mlxsw_sp *mlxsw_sp,
>  			  struct net_device *lag_dev,
> -			  struct netdev_lag_upper_info *lag_upper_info)
> +			  struct netdev_lag_upper_info *lag_upper_info,
> +			  struct netlink_ext_ack *extack)
>  {
>  	u16 lag_id;
>  
> -	if (mlxsw_sp_lag_index_get(mlxsw_sp, lag_dev, &lag_id) != 0)
> +	if (mlxsw_sp_lag_index_get(mlxsw_sp, lag_dev, &lag_id) != 0) {
> +		NL_SET_ERR_MSG(extack, "spectrum: Unknown LAG device");

A more accurate message would be:
"spectrum: Exceeded number of supported LAG devices"

>  		return false;
> -	if (lag_upper_info->tx_type != NETDEV_LAG_TX_TYPE_HASH)
> +	}
> +	if (lag_upper_info->tx_type != NETDEV_LAG_TX_TYPE_HASH) {
> +		NL_SET_ERR_MSG(extack,
> +			       "spectrum: LAG device using unsupported Tx type");
>  		return false;
> +	}
>  	return true;
>  }
