From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 24/26] mlxsw: spectrum: Implement LAG port join/leave
Date: Wed, 2 Dec 2015 07:47:51 +0200
Message-ID: <CAJ3xEMjzSHFo8YQZcd-nP0BeMhnSV=1kgtdkk_Wc80Tuk=GnKQ@mail.gmail.com>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
	<1448977744-17930-25-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>, yotamg@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34654 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbbLBFrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 00:47:51 -0500
Received: by igvg19 with SMTP id g19so111019724igv.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 21:47:51 -0800 (PST)
In-Reply-To: <1448977744-17930-25-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2015 at 3:49 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Implement basic procedures for joining/leaving port to/from LAG. That
> includes HW setup of collector, core LAG mapping setup.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 284 +++++++++++++++++++++++--
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  35 ++-
>  2 files changed, 302 insertions(+), 17 deletions(-)
>
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c

[...]

> +static int mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
> +                                  struct net_device *lag_dev)
> +{
> +       struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
> +       struct mlxsw_sp_upper *lag;
> +       u16 lag_id = mlxsw_sp_port->lag_id;
> +       int err;
> +
> +       if (!mlxsw_sp_port->lagged)
> +               return 0;
> +       lag = mlxsw_sp_lag_get(mlxsw_sp, lag_id);
> +       BUG_ON(lag->ref_count == 0);

is this a must to crash the system here? can't we do something less drastic?

> +
> +       err = mlxsw_sp_lag_col_port_disable(mlxsw_sp_port, lag_id);
> +       if (err)
> +               return err;
> +       mlxsw_sp_lag_col_port_remove(mlxsw_sp_port, lag_id);
> +       if (err)
> +               return err;
> +
> +       if (lag->ref_count == 1) {
> +               err = mlxsw_sp_lag_destroy(mlxsw_sp, lag_id);
> +               if (err)
> +                       return err;
> +       }
> +
> +       mlxsw_core_lag_mapping_clear(mlxsw_sp->core, lag_id,
> +                                    mlxsw_sp_port->local_port);
> +       mlxsw_sp_port->lagged = 0;
> +       lag->ref_count--;
> +       return 0;
> +}
