From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_en: Add DCB PFC support through CEE
 netlink commands
Date: Tue, 21 Jun 2016 15:17:23 +0300
Message-ID: <CAJ3xEMi-si0g1pZrmQ8B+KVRFGsSSacHq1=byAxnOmZfAaLbhQ@mail.gmail.com>
References: <1466507559-13592-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Rana Shahout <ranas@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f195.google.com ([209.85.214.195]:34426 "EHLO
	mail-ob0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbcFUMRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 08:17:25 -0400
Received: by mail-ob0-f195.google.com with SMTP id s7so2399985obo.1
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 05:17:25 -0700 (PDT)
In-Reply-To: <1466507559-13592-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 2:12 PM, Tariq Toukan <tariqt@mellanox.com> wrote:
> From: Rana Shahout <ranas@mellanox.com>
>
> This patch adds support for reading and updating priority flow
> control (PFC) attributes in the driver via netlink.

The patch does multiple things, you need to break it to few patches, I
guess 2-3 patches could be fine, e.g

1. changes to areas areas where you read new values from the FW
2. changes/refactoring to the IEEE code to make some of the callbacks general
3. add CEE code and usage of the code you added in steps 1,2 above



> ---
>  drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 277 +++++++++++++++++++++++--
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  25 +++
>  drivers/net/ethernet/mellanox/mlx4/fw.c        |   1 +
>  drivers/net/ethernet/mellanox/mlx4/fw.h        |   1 +
>  drivers/net/ethernet/mellanox/mlx4/main.c      |   1 +
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  26 +++
>  drivers/net/ethernet/mellanox/mlx4/port.c      |  12 ++
>  include/linux/mlx4/device.h                    |   2 +
>  8 files changed, 331 insertions(+), 14 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
> index f01918c..99c6bbd 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
> @@ -37,6 +37,11 @@
>  #include "mlx4_en.h"
>  #include "fw_qos.h"
>
> +enum {
> +       MLX4_CEE_STATE_DOWN   = 0,
> +       MLX4_CEE_STATE_UP     = 1,
> +};
> +
>  /* Definitions for QCN
>   */
>
> @@ -80,13 +85,202 @@ struct mlx4_congestion_control_mb_prio_802_1_qau_statistics {
>         __be32 reserved3[4];
>  };
>
> +static u8 mlx4_en_dcbnl_getcap(struct net_device *dev, int capid, u8 *cap)
> +{
> +       struct mlx4_en_priv *priv = netdev_priv(dev);
> +
> +       switch (capid) {
> +       case DCB_CAP_ATTR_PFC:
> +               *cap = true;
> +               break;
> +       case DCB_CAP_ATTR_DCBX:
> +               *cap = priv->cee_params.dcbx_cap;
> +               break;
> +       case DCB_CAP_ATTR_PFC_TCS:
> +               *cap = 1 <<  mlx4_max_tc(priv->mdev->dev);
> +               break;
> +       default:
> +               *cap = false;
> +               break;
> +       }
> +
> +       return 0;
> +}
> +
> +static u8 mlx4_en_dcbnl_getpfcstate(struct net_device *netdev)
> +{
> +       struct mlx4_en_priv *priv = netdev_priv(netdev);
> +
> +       return priv->cee_params.dcb_cfg.pfc_state;
> +}
> +
> +static void mlx4_en_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
> +{
> +       struct mlx4_en_priv *priv = netdev_priv(netdev);
> +
> +       priv->cee_params.dcb_cfg.pfc_state = state;
> +}
> +
> +static void mlx4_en_dcbnl_get_pfc_cfg(struct net_device *netdev, int priority,
> +                                     u8 *setting)
> +{
> +       struct mlx4_en_priv *priv = netdev_priv(netdev);
> +
> +       *setting = priv->cee_params.dcb_cfg.tc_config[priority].dcb_pfc;
> +}
> +
> +static void mlx4_en_dcbnl_set_pfc_cfg(struct net_device *netdev, int priority,
> +                                     u8 setting)
> +{
> +       struct mlx4_en_priv *priv = netdev_priv(netdev);
> +
> +       priv->cee_params.dcb_cfg.tc_config[priority].dcb_pfc = setting;
> +       priv->cee_params.dcb_cfg.pfc_state = true;
> +}
> +
> +static int mlx4_en_dcbnl_getnumtcs(struct net_device *netdev, int tcid, u8 *num)
> +{
> +       struct mlx4_en_priv *priv = netdev_priv(netdev);
> +
> +       if (!(priv->flags & MLX4_EN_FLAG_DCB_ENABLED))
> +               return -EINVAL;
> +
> +       if (tcid == DCB_NUMTCS_ATTR_PFC)
> +               *num = mlx4_max_tc(priv->mdev->dev);
> +       else
> +               *num = 0;
> +
> +       return 0;
> +}
> +
> +static u8 mlx4_en_dcbnl_set_all(struct net_device *netdev)
> +{
> +       struct mlx4_en_priv *priv = netdev_priv(netdev);
> +       struct mlx4_en_dev *mdev = priv->mdev;
> +       struct mlx4_en_cee_config *dcb_cfg = &priv->cee_params.dcb_cfg;
> +       int err = 0;
> +
> +       if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
> +               return -EINVAL;
> +
> +       if (dcb_cfg->pfc_state) {
> +               int tc;
> +
> +               priv->prof->rx_pause = 0;
> +               priv->prof->tx_pause = 0;
> +               for (tc = 0; tc < CEE_DCBX_MAX_PRIO; tc++) {
> +                       u8 tc_mask = 1 << tc;
> +
> +                       switch (dcb_cfg->tc_config[tc].dcb_pfc) {
> +                       case pfc_disabled:
> +                               priv->prof->tx_ppp &= ~tc_mask;
> +                               priv->prof->rx_ppp &= ~tc_mask;
> +                               break;
> +                       case pfc_enabled_full:
> +                               priv->prof->tx_ppp |= tc_mask;
> +                               priv->prof->rx_ppp |= tc_mask;
> +                               break;
> +                       case pfc_enabled_tx:
> +                               priv->prof->tx_ppp |= tc_mask;
> +                               priv->prof->rx_ppp &= ~tc_mask;
> +                               break;
> +                       case pfc_enabled_rx:
> +                               priv->prof->tx_ppp &= ~tc_mask;
> +                               priv->prof->rx_ppp |= tc_mask;
> +                               break;
> +                       default:
> +                               break;
> +                       }
> +               }
> +               en_dbg(DRV, priv, "Set pfc on\n");
> +       } else {
> +               priv->prof->rx_pause = 1;
> +               priv->prof->tx_pause = 1;
> +               en_dbg(DRV, priv, "Set pfc off\n");
> +       }
> +
> +       err = mlx4_SET_PORT_general(mdev->dev, priv->port,
> +                                   priv->rx_skb_size + ETH_FCS_LEN,
> +                                   priv->prof->tx_pause,
> +                                   priv->prof->tx_ppp,
> +                                   priv->prof->rx_pause,
> +                                   priv->prof->rx_ppp);
> +       if (err)
> +               en_err(priv, "Failed setting pause params\n");
> +       return err;
> +}
> +
> +static u8 mlx4_en_dcbnl_get_state(struct net_device *dev)
> +{
> +       struct mlx4_en_priv *priv = netdev_priv(dev);
> +
> +       if (priv->flags & MLX4_EN_FLAG_DCB_ENABLED)
> +               return MLX4_CEE_STATE_UP;
> +
> +       return MLX4_CEE_STATE_DOWN;
> +}
> +
> +static u8 mlx4_en_dcbnl_set_state(struct net_device *dev, u8 state)
> +{
> +       struct mlx4_en_priv *priv = netdev_priv(dev);
> +       int num_tcs = 0;
> +
> +       if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
> +               return 1;
> +
> +       if (!!(state) == !!(priv->flags & MLX4_EN_FLAG_DCB_ENABLED))
> +               return 0;
> +
> +       if (state) {
> +               priv->flags |= MLX4_EN_FLAG_DCB_ENABLED;
> +               num_tcs = IEEE_8021QAZ_MAX_TCS;
> +       } else {
> +               priv->flags &= ~MLX4_EN_FLAG_DCB_ENABLED;
> +       }
> +
> +       return mlx4_en_setup_tc(dev, num_tcs);
> +}
> +
> +/* On success returns a non-zero 802.1p user priority bitmap
> + * otherwise returns 0 as the invalid user priority bitmap to
> + * indicate an error.
> + */
> +static int mlx4_en_dcbnl_getapp(struct net_device *netdev, u8 idtype, u16 id)
> +{
> +       struct mlx4_en_priv *priv = netdev_priv(netdev);
> +       struct dcb_app app = {
> +                               .selector = idtype,
> +                               .protocol = id,
> +                            };
> +       if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
> +               return 0;
> +
> +       return dcb_getapp(netdev, &app);
> +}
> +
> +static int mlx4_en_dcbnl_setapp(struct net_device *netdev, u8 idtype,
> +                               u16 id, u8 up)
> +{
> +       struct mlx4_en_priv *priv = netdev_priv(netdev);
> +       struct dcb_app app;
> +
> +       if (!(priv->cee_params.dcbx_cap & DCB_CAP_DCBX_VER_CEE))
> +               return -EINVAL;
> +
> +       memset(&app, 0, sizeof(struct dcb_app));
> +       app.selector = idtype;
> +       app.protocol = id;
> +       app.priority = up;
> +
> +       return dcb_setapp(netdev, &app);
> +}
> +
>  static int mlx4_en_dcbnl_ieee_getets(struct net_device *dev,
>                                    struct ieee_ets *ets)
>  {
>         struct mlx4_en_priv *priv = netdev_priv(dev);
>         struct ieee_ets *my_ets = &priv->ets;
>
> -       /* No IEEE PFC settings available */
>         if (!my_ets)
>                 return -EINVAL;
>
> @@ -237,18 +431,51 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct net_device *dev,
>
>  static u8 mlx4_en_dcbnl_getdcbx(struct net_device *dev)
>  {
> -       return DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE;
> +       struct mlx4_en_priv *priv = netdev_priv(dev);
> +
> +       return priv->cee_params.dcbx_cap;
>  }
>
>  static u8 mlx4_en_dcbnl_setdcbx(struct net_device *dev, u8 mode)
>  {
> +       struct mlx4_en_priv *priv = netdev_priv(dev);
> +       struct ieee_ets ets = {0};
> +       struct ieee_pfc pfc = {0};
> +
> +       if (mode == priv->cee_params.dcbx_cap)
> +               return 0;
> +
>         if ((mode & DCB_CAP_DCBX_LLD_MANAGED) ||
> -           (mode & DCB_CAP_DCBX_VER_CEE) ||
> -           !(mode & DCB_CAP_DCBX_VER_IEEE) ||
> +           ((mode & DCB_CAP_DCBX_VER_IEEE) &&
> +            (mode & DCB_CAP_DCBX_VER_CEE)) ||
>             !(mode & DCB_CAP_DCBX_HOST))
> -               return 1;
> +               goto err;
> +
> +       priv->cee_params.dcbx_cap = mode;
> +
> +       ets.ets_cap = IEEE_8021QAZ_MAX_TCS;
> +       pfc.pfc_cap = IEEE_8021QAZ_MAX_TCS;
> +
> +       if (mode & DCB_CAP_DCBX_VER_IEEE) {
> +               if (mlx4_en_dcbnl_ieee_setets(dev, &ets))
> +                       goto err;
> +               if (mlx4_en_dcbnl_ieee_setpfc(dev, &pfc))
> +                       goto err;
> +       } else if (mode & DCB_CAP_DCBX_VER_CEE) {
> +               if (mlx4_en_dcbnl_set_all(dev))
> +                       goto err;
> +       } else {
> +               if (mlx4_en_dcbnl_ieee_setets(dev, &ets))
> +                       goto err;
> +               if (mlx4_en_dcbnl_ieee_setpfc(dev, &pfc))
> +                       goto err;
> +               if (mlx4_en_setup_tc(dev, 0))
> +                       goto err;
> +       }
>
>         return 0;
> +err:
> +       return 1;
>  }
>
>  #define MLX4_RATELIMIT_UNITS_IN_KB 100000 /* rate-limit HW unit in Kbps */
> @@ -463,24 +690,46 @@ static int mlx4_en_dcbnl_ieee_getqcnstats(struct net_device *dev,
>  }
>
>  const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops = {
> -       .ieee_getets    = mlx4_en_dcbnl_ieee_getets,
> -       .ieee_setets    = mlx4_en_dcbnl_ieee_setets,
> -       .ieee_getmaxrate = mlx4_en_dcbnl_ieee_getmaxrate,
> -       .ieee_setmaxrate = mlx4_en_dcbnl_ieee_setmaxrate,
> -       .ieee_getpfc    = mlx4_en_dcbnl_ieee_getpfc,
> -       .ieee_setpfc    = mlx4_en_dcbnl_ieee_setpfc,
> +       .ieee_getets            = mlx4_en_dcbnl_ieee_getets,
> +       .ieee_setets            = mlx4_en_dcbnl_ieee_setets,
> +       .ieee_getmaxrate        = mlx4_en_dcbnl_ieee_getmaxrate,
> +       .ieee_setmaxrate        = mlx4_en_dcbnl_ieee_setmaxrate,
> +       .ieee_getqcn            = mlx4_en_dcbnl_ieee_getqcn,
> +       .ieee_setqcn            = mlx4_en_dcbnl_ieee_setqcn,
> +       .ieee_getqcnstats       = mlx4_en_dcbnl_ieee_getqcnstats,
> +       .ieee_getpfc            = mlx4_en_dcbnl_ieee_getpfc,
> +       .ieee_setpfc            = mlx4_en_dcbnl_ieee_setpfc,
> +
> +       .getstate       = mlx4_en_dcbnl_get_state,
> +       .setstate       = mlx4_en_dcbnl_set_state,
> +       .getpfccfg      = mlx4_en_dcbnl_get_pfc_cfg,
> +       .setpfccfg      = mlx4_en_dcbnl_set_pfc_cfg,
> +       .setall         = mlx4_en_dcbnl_set_all,
> +       .getcap         = mlx4_en_dcbnl_getcap,
> +       .getnumtcs      = mlx4_en_dcbnl_getnumtcs,
> +       .getpfcstate    = mlx4_en_dcbnl_getpfcstate,
> +       .setpfcstate    = mlx4_en_dcbnl_setpfcstate,
> +       .getapp         = mlx4_en_dcbnl_getapp,
> +       .setapp         = mlx4_en_dcbnl_setapp,
>
>         .getdcbx        = mlx4_en_dcbnl_getdcbx,
>         .setdcbx        = mlx4_en_dcbnl_setdcbx,
> -       .ieee_getqcn    = mlx4_en_dcbnl_ieee_getqcn,
> -       .ieee_setqcn    = mlx4_en_dcbnl_ieee_setqcn,
> -       .ieee_getqcnstats = mlx4_en_dcbnl_ieee_getqcnstats,
>  };
>
>  const struct dcbnl_rtnl_ops mlx4_en_dcbnl_pfc_ops = {
>         .ieee_getpfc    = mlx4_en_dcbnl_ieee_getpfc,
>         .ieee_setpfc    = mlx4_en_dcbnl_ieee_setpfc,
>
> +       .setstate       = mlx4_en_dcbnl_set_state,
> +       .getpfccfg      = mlx4_en_dcbnl_get_pfc_cfg,
> +       .setpfccfg      = mlx4_en_dcbnl_set_pfc_cfg,
> +       .setall         = mlx4_en_dcbnl_set_all,
> +       .getnumtcs      = mlx4_en_dcbnl_getnumtcs,
> +       .getpfcstate    = mlx4_en_dcbnl_getpfcstate,
> +       .setpfcstate    = mlx4_en_dcbnl_setpfcstate,
> +       .getapp         = mlx4_en_dcbnl_getapp,
> +       .setapp         = mlx4_en_dcbnl_setapp,
> +
>         .getdcbx        = mlx4_en_dcbnl_getdcbx,
>         .setdcbx        = mlx4_en_dcbnl_setdcbx,
>  };
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 8e318d2..d42083a 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -67,6 +67,17 @@ int mlx4_en_setup_tc(struct net_device *dev, u8 up)
>                 offset += priv->num_tx_rings_p_up;
>         }
>
> +#ifdef CONFIG_MLX4_EN_DCB
> +       if (!mlx4_is_slave(priv->mdev->dev)) {
> +               if (up) {
> +                       priv->flags |= MLX4_EN_FLAG_DCB_ENABLED;

you don't check any device capability here before declaring that, bug, I guess





> diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
> index 087b23b..3d2095e 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/port.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/port.c
> @@ -52,6 +52,7 @@
>
>  #define MLX4_FLAG_V_IGNORE_FCS_MASK            0x2
>  #define MLX4_IGNORE_FCS_MASK                   0x1
> +#define MLNX4_TX_MAX_NUMBER                    8

MLNX --> MLX
TX --> TC ?
