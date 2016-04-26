From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] net/mlx5e: avoid stack overflow in mlx5e_open_channels
Date: Tue, 26 Apr 2016 16:48:33 +0300
Message-ID: <CALzJLG98swFRKAZUcoXMWMyzX3z_h-HhTNZD_unh43VHByZY0A@mail.gmail.com>
References: <1461590139-1396745-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Achiad Shochat <achiad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Amir Vadai <amir-IB5XiEnQfqI@public.gmane.org>,
	Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461590139-1396745-1-git-send-email-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 25, 2016 at 4:15 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> struct mlx5e_channel_param is a large structure that is allocated
> on the stack of mlx5e_open_channels, and with a recent change
> it has grown beyond the warning size for the maximum stack
> that a single function should use:
>
> mellanox/mlx5/core/en_main.c: In function 'mlx5e_open_channels':
> mellanox/mlx5/core/en_main.c:1325:1: error: the frame size of 1072 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
>
> The function is already using dynamic allocation and is not in
> a fast path, so the easiest workaround is to use another kzalloc
> for allocating the channel parameters.
>
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> Fixes: d3c9bc2743dc ("net/mlx5e: Added ICO SQs")
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 21 +++++++++++++++------
>  1 file changed, 15 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index 22742e1fbcb9..2ec547a80886 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -1266,12 +1266,14 @@ static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
>         param->icosq = true;
>  }
>
> -static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
> -                                     struct mlx5e_channel_param *cparam)
> +static struct mlx5e_channel_param *mlx5e_build_channel_param(struct mlx5e_priv *priv)

I prefer to keep the function prototype as before and move the dynamic
allocation to mlx5e_open_channels,
to keep alloc/free symmetric in mlx5e_open_channels.

>  {
> +       struct mlx5e_channel_param *cparam;
>         u8 icosq_log_wq_sz = MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE;
>
> -       memset(cparam, 0, sizeof(*cparam));
> +       cparam = kzalloc(sizeof(struct mlx5e_channel_param), GFP_KERNEL);
> +       if (!cparam)
> +               return NULL;
>
>         mlx5e_build_rq_param(priv, &cparam->rq);
>         mlx5e_build_sq_param(priv, &cparam->sq);
> @@ -1279,11 +1281,13 @@ static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
>         mlx5e_build_rx_cq_param(priv, &cparam->rx_cq);
>         mlx5e_build_tx_cq_param(priv, &cparam->tx_cq);
>         mlx5e_build_ico_cq_param(priv, &cparam->icosq_cq, icosq_log_wq_sz);
> +
> +       return cparam;
>  }
>
>  static int mlx5e_open_channels(struct mlx5e_priv *priv)
>  {
> -       struct mlx5e_channel_param cparam;
> +       struct mlx5e_channel_param *cparam;
>         int nch = priv->params.num_channels;
>         int err = -ENOMEM;
>         int i;
> @@ -1298,9 +1302,12 @@ static int mlx5e_open_channels(struct mlx5e_priv *priv)

You can do the allocation here,  then you can benefit from the next
allocation check to test the 3 allocations altogether.
i.e:
if (!cparam || !priv->channel || !priv->txq_to_sq_map)
           goto err_free_txq_to_sq_map;

>         if (!priv->channel || !priv->txq_to_sq_map)
>                 goto err_free_txq_to_sq_map;
>
> -       mlx5e_build_channel_param(priv, &cparam);
> +       cparam = mlx5e_build_channel_param(priv);
> +       if (!cparam)
> +               goto err_free_txq_to_sq_map;
> +
>         for (i = 0; i < nch; i++) {
> -               err = mlx5e_open_channel(priv, i, &cparam, &priv->channel[i]);
> +               err = mlx5e_open_channel(priv, i, cparam, &priv->channel[i]);
>                 if (err)
>                         goto err_close_channels;
>         }
> @@ -1311,11 +1318,13 @@ static int mlx5e_open_channels(struct mlx5e_priv *priv)
>                         goto err_close_channels;
>         }
>
> +       kfree(cparam);
>         return 0;
>
>  err_close_channels:
>         for (i--; i >= 0; i--)
>                 mlx5e_close_channel(priv->channel[i]);
> +       kfree(cparam);
>
>  err_free_txq_to_sq_map:
>         kfree(priv->txq_to_sq_map);
> --
> 2.7.0
>


Saeed.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
