From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH RFC net-next 4/4] net/mlx5: Add CONFIG_MLX5_ESWITCH Kconfig
Date: Thu, 8 Jun 2017 12:35:20 +0300
Message-ID: <CAJ3xEMhPkf9DSs=zguYNzp13iMVDHJoLbFhi8MihuD6C5LHXeg@mail.gmail.com>
References: <20170607234214.24723-1-saeedm@mellanox.com> <20170607234214.24723-5-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jes Sorensen <jsorensen@fb.com>,
        Kernel Team <kernel-team@fb.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36687 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751760AbdFHJfW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 05:35:22 -0400
Received: by mail-oi0-f66.google.com with SMTP id g14so2012066oib.3
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 02:35:21 -0700 (PDT)
In-Reply-To: <20170607234214.24723-5-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 8, 2017 at 2:42 AM, Saeed Mahameed <saeedm@mellanox.com> wrote:

> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -2961,9 +2961,8 @@ static int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd)
>         return 0;
>  }
>
> -static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
> +static int mlx5e_setup_tc(struct mlx5e_priv *priv, u8 tc)
>  {
> -       struct mlx5e_priv *priv = netdev_priv(netdev);
>         struct mlx5e_channels new_channels = {};
>         int err = 0;
>
> @@ -2995,6 +2994,7 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
>  {
>         struct mlx5e_priv *priv = netdev_priv(dev);
>
> +#ifdef CONFIG_MLX5_ESWITCH
>         if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
>                 goto mqprio;
>
> @@ -3013,12 +3013,13 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
>         }
>
>  mqprio:
> +#endif
>         if (tc->type != TC_SETUP_MQPRIO)
> -               return -EINVAL;
> +               return -EOPNOTSUPP;

why change this corner in this patch? we're doing enough changes

>
>         tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
>
> -       return mlx5e_setup_tc(dev, tc->mqprio->num_tc);
> +       return mlx5e_setup_tc(priv, tc->mqprio->num_tc);
>  }

same comment

> --- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c

> @@ -948,13 +946,11 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
>                 goto err_rl_cleanup;
>         }
>
> -#ifdef CONFIG_MLX5_CORE_EN
>         err = mlx5_eswitch_init(dev);
>         if (err) {
>                 dev_err(&pdev->dev, "Failed to init eswitch %d\n", err);
>                 goto err_mpfs_cleanup;
>         }
> -#endif

why? before this patch we were doing it only if Ethernet
(MLX5_CORE_EN) was defined into the build,
and now we are returning blindly zero if another config isn't there
(CONFIG_MLX5_ESWITCH) - is that
fully equivalent? do we want to be fully equiv?

> @@ -965,10 +961,8 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
>         return 0;
>
>  err_eswitch_cleanup:
> -#ifdef CONFIG_MLX5_CORE_EN
>         mlx5_eswitch_cleanup(dev->priv.eswitch);
>  err_mpfs_cleanup:
> -#endif

same comment/question
