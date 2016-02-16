From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 04/12] net/mlx5e: Support DCBNL IEEE ETS
Date: Tue, 16 Feb 2016 23:10:27 +0200
Message-ID: <CAJ3xEMhxezhiU4XjVZuaDbvZ=0D-HLZYnm8DORLDSg_xquT3Yw@mail.gmail.com>
References: <1455653401-9808-1-git-send-email-saeedm@mellanox.com>
	<1455653401-9808-5-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:33539 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779AbcBPVK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 16:10:28 -0500
Received: by mail-ig0-f178.google.com with SMTP id y8so108058813igp.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 13:10:28 -0800 (PST)
In-Reply-To: <1455653401-9808-5-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 16, 2016 at 10:09 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> Support the ndo_setup_tc callback.
> Added en_dcbnl.c which implements the set/get DCBNL IEEE ETS,
> set/get dcbx and registers the mlx5e dcbnl ops.
>
> So far each channel had a single TXQ.
> Now each channel has a TXQ per TC (Traffic Class).
>
> We still use the kernel's default TXQ selection method to select the
> channel to transmit through but now we use our own method to select
> the TXQ inside the channel based on VLAN priority.
>
> In mlx5, as opposed to mlx4, tc group N gets lower priority than
> tc group N+1.
>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> Signed-off-by: Rana Shahout <ranas@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   12 ++
>  drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    3 +
>  drivers/net/ethernet/mellanox/mlx5/core/en.h       |   15 ++-
>  drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |  184 ++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   92 +++++++++-
>  drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |    8 +-
>  6 files changed, 301 insertions(+), 13 deletions(-)
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
> index c503ea0..1cf722e 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
> @@ -19,3 +19,15 @@ config MLX5_CORE_EN
>           Ethernet support in Mellanox Technologies ConnectX-4 NIC.
>           Ethernet and Infiniband support in ConnectX-4 are currently mutually
>           exclusive.
> +
> +config MLX5_CORE_EN_DCB
> +       bool "Data Center Bridging (DCB) Support"
> +       default y
> +       depends on MLX5_CORE_EN && DCB
> +       ---help---
> +         Say Y here if you want to use Data Center Bridging (DCB) in the
> +         driver.
> +         If set to N, will not be able to configure QoS and ratelimit attributes.
> +         This flag is depended on the kernel's DCB support.
> +
> +         If unsure, set to Y
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
> index 01c0256..1a82e23 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
> @@ -3,6 +3,9 @@ obj-$(CONFIG_MLX5_CORE)         += mlx5_core.o
>  mlx5_core-y := main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
>                 health.o mcg.o cq.o srq.o alloc.o qp.o port.o mr.o pd.o   \
>                 mad.o transobj.o vport.o sriov.o fs_cmd.o fs_core.o
> +
>  mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
>                 en_main.o en_fs.o en_ethtool.o en_tx.o en_rx.o \
>                 en_txrx.o en_clock.o
> +
> +mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> index 15f6cdb..dfbc4e5 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> @@ -70,6 +70,11 @@
>
>  #define MLX5E_NUM_MAIN_GROUPS 9
>
> +#ifdef CONFIG_MLX5_CORE_EN_DCB
> +#define MLX5E_MAX_BW_ALLOC 100 /* Max percentage of BW allocation */
> +#define MLX5E_MIN_BW_ALLOC 1   /* Min percentage of BW allocation */
> +#endif
> +
>  static const char vport_strings[][ETH_GSTRING_LEN] = {
>         /* vport statistics */
>         "rx_packets",
> @@ -273,7 +278,6 @@ struct mlx5e_params {
>         u8  log_sq_size;
>         u8  log_rq_size;
>         u16 num_channels;
> -       u8  default_vlan_prio;
>         u8  num_tc;
>         u16 rx_cq_moderation_usec;
>         u16 rx_cq_moderation_pkts;
> @@ -286,6 +290,9 @@ struct mlx5e_params {
>         u8  rss_hfunc;
>         u8  toeplitz_hash_key[40];
>         u32 indirection_rqt[MLX5E_INDIR_RQT_SIZE];
> +#ifdef CONFIG_MLX5_CORE_EN_DCB
> +       struct ieee_ets ets;
> +#endif
>  };
>
>  struct mlx5e_tstamp {
> @@ -506,7 +513,6 @@ struct mlx5e_flow_tables {
>
>  struct mlx5e_priv {
>         /* priv data path fields - start */
> -       int                        default_vlan_prio;
>         struct mlx5e_sq            **txq_to_sq_map;
>         int channeltc_to_txq_map[MLX5E_MAX_NUM_CHANNELS][MLX5E_MAX_NUM_TC];
>         /* priv data path fields - end */


Didn't see a note on the removal of the default vlan prio in the
change-log, could you elaborate what was the role of it before the
patch and why we can just throw it?


> @@ -666,4 +672,9 @@ static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
>  }
>
>  extern const struct ethtool_ops mlx5e_ethtool_ops;
> +#ifdef CONFIG_MLX5_CORE_EN_DCB
> +extern const struct dcbnl_rtnl_ops mlx5e_dcbnl_ops;
> +int mlx5e_dcbnl_ieee_setets_core(struct mlx5e_priv *priv, struct ieee_ets *ets);
> +#endif
> +
>  u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev);
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
> new file mode 100644
> index 0000000..72ba7e3
> --- /dev/null
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
> @@ -0,0 +1,184 @@
> +/*
> + * Copyright (c) 2015, Mellanox Technologies. All rights reserved.

we're happily in 2016 (please fix here and also in other patches that
introduce new files)

> @@ -2127,7 +2193,10 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
>         priv->mdev                         = mdev;
>         priv->netdev                       = netdev;
>         priv->params.num_channels          = num_channels;
> -       priv->default_vlan_prio            = priv->params.default_vlan_prio;
> +
> +#ifdef CONFIG_MLX5_CORE_EN_DCB
> +       mlx5e_ets_init(priv);
> +#endif


> @@ -2164,6 +2233,9 @@ static void mlx5e_build_netdev(struct net_device > +#ifdef CONFIG_MLX5_CORE_EN_DCB
> +       netdev->dcbnl_ops         = &mlx5e_dcbnl_ops;
> +#endif

I guess we don't want VF drivers to control the uplink port QoS
arbiter, PFC setup and such, agree?

> @@ -2241,6 +2315,12 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
> +#ifdef CONFIG_MLX5_CORE_EN_DCB
> +       err = mlx5e_dcbnl_ieee_setets_core(priv, &priv->params.ets);
> +       if (err)
> +               goto err_free_netdev;
> +#endif
