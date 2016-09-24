From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH] mlx5: Add ndo_poll_controller() implementation
Date: Sat, 24 Sep 2016 13:51:46 +0300
Message-ID: <CALzJLG8o3dfPJR-2iaWb-s7r65r51HhgTs5Srf92-Tx0sZCSHw@mail.gmail.com>
References: <a1f1b99a1f13786722f9d30636173ad1a5b5b5ad.1474661274.git.calvinowens@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>, kernel-team@fb.com
To: Calvin Owens <calvinowens@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a1f1b99a1f13786722f9d30636173ad1a5b5b5ad.1474661274.git.calvinowens@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 23, 2016 at 11:13 PM, Calvin Owens <calvinowens@fb.com> wrote:
> This implements ndo_poll_controller in net_device_ops for mlx5, which is
> necessary to use netconsole with this driver.
>
> Signed-off-by: Calvin Owens <calvinowens@fb.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index 2459c7f..439476f 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -2786,6 +2786,20 @@ static void mlx5e_tx_timeout(struct net_device *dev)
>                 schedule_work(&priv->tx_timeout_work);
>  }
>
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +/* Fake "interrupt" called by netpoll (eg netconsole) to send skbs without
> + * reenabling interrupts.
> + */
> +static void mlx5e_netpoll(struct net_device *dev)
> +{
> +       struct mlx5e_priv *priv = netdev_priv(dev);
> +       int i, nr_sq = priv->params.num_channels * priv->params.num_tc;
> +
> +       for (i = 0; i < nr_sq; i++)
> +               napi_schedule(priv->txq_to_sq_map[i]->cq.napi);

Hi Calvin,

Basically all CQs on the same channel are sharing the same napi, so
here you will end up calling napi_schedule more than once for each
napi (channel).
iterating over the SQs map is irrelevant here, all you need to do is
to iterate over the channels:

 for (i = 0; i < priv->params.num_channels; i++)
        napi_schedule(priv->channel[i]->napi);


Thanks,
Saeed.

> +}
> +#endif
> +
>  static const struct net_device_ops mlx5e_netdev_ops_basic = {
>         .ndo_open                = mlx5e_open,
>         .ndo_stop                = mlx5e_close,
> @@ -2805,6 +2819,9 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
>         .ndo_rx_flow_steer       = mlx5e_rx_flow_steer,
>  #endif
>         .ndo_tx_timeout          = mlx5e_tx_timeout,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +       .ndo_poll_controller     = mlx5e_netpoll,
> +#endif
>  };
>
>  static const struct net_device_ops mlx5e_netdev_ops_sriov = {
> @@ -2836,6 +2853,9 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
>         .ndo_set_vf_link_state   = mlx5e_set_vf_link_state,
>         .ndo_get_vf_stats        = mlx5e_get_vf_stats,
>         .ndo_tx_timeout          = mlx5e_tx_timeout,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +       .ndo_poll_controller     = mlx5e_netpoll,
> +#endif
>  };
>
>  static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
> --
> 2.9.3
>
