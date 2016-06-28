From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 10/16] net/mlx5e: Add devlink based SRIOV mode
 changes (legacy --> offloads)
Date: Tue, 28 Jun 2016 09:42:13 -0400
Message-ID: <20160628134211.GK18787@gospo.rdu.cumulusnetworks.com>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
 <1467043649-28594-11-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35582 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbcF1NmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 09:42:17 -0400
Received: by mail-qk0-f173.google.com with SMTP id a125so29283210qkc.2
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 06:42:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1467043649-28594-11-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 07:07:23PM +0300, Saeed Mahameed wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> 
> Implement handlers for the devlink commands to get and set the SRIOV
> E-Switch mode.
> 
> When turning to the offloads mode, we disable the e-switch and enable
> it again in the new mode, create the NIC offloads table and create VF reps.
> 
> When turning to legacy mode, we remove the VF reps and the offloads
> table, and re-initiate the e-switch in it's legacy mode.
> 
> The actual creation/removal of the VF reps is done in downstream patches.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  12 ++-
>  .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 102 ++++++++++++++++++++-
>  2 files changed, 105 insertions(+), 9 deletions(-)
> 
[...]
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> index 3b3afbd..a39af6b 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
[...]
>  int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode)
>  {
> -	return -EOPNOTSUPP;
> +	struct mlx5_core_dev *dev;
> +	u16 cur_mode;
> +
> +	dev = devlink_priv(devlink);
> +
> +	if (!MLX5_CAP_GEN(dev, vport_group_manager))
> +		return -EOPNOTSUPP;
> +
> +	cur_mode = dev->priv.eswitch->mode;
> +
> +	if (cur_mode == SRIOV_NONE || mode == SRIOV_NONE)
> +		return -EOPNOTSUPP;
> +
> +	if (cur_mode == mode)
> +		return 0;
> +
> +	if (mode == SRIOV_OFFLOADS) /* current mode is legacy */
> +		return esw_offloads_start(dev->priv.eswitch);
> +	else if (mode == SRIOV_LEGACY) /* curreny mode is offloads */
> +		return esw_offloads_stop(dev->priv.eswitch);
> +	else
> +		return -EINVAL;
>  }
>  
>  int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
>  {
> -	return -EOPNOTSUPP;
> +	struct mlx5_core_dev *dev;
> +
> +	dev = devlink_priv(devlink);
> +
> +	if (!MLX5_CAP_GEN(dev, vport_group_manager))
> +		return -EOPNOTSUPP;
> +
> +	if (dev->priv.eswitch->mode == SRIOV_NONE)
> +		return -EOPNOTSUPP;
> +
> +	*mode = dev->priv.eswitch->mode;
> +
> +	return 0;
>  }

This is an _extremely_ minor nit, but I only bring it up since you are
leading the way here and your model may be one that other people
follow...

Internally you have a enum to track the SRIOV modes:

enum {
       SRIOV_NONE,
       SRIOV_LEGACY,
       SRIOV_OFFLOADS
};

But patch 8 adds a new enum for devlink to track this as well.

enum devlink_eswitch_mode {
       DEVLINK_ESWITCH_MODE_NONE,
       DEVLINK_ESWITCH_MODE_LEGACY,
       DEVLINK_ESWITCH_MODE_OFFLOADS,
};

Would it make sense at some point to use the devlink modes in the driver
so it's less to track?

Again, this is an extremely _minor_ concern.  The rest of the set looks
great and I like the architectural decisions made here.  Awesome work
all around!
