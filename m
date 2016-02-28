From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH] net/mlx5e: make VXLAN support conditional
Date: Sun, 28 Feb 2016 15:26:53 +0200
Message-ID: <CALzJLG8MG9y8yr7zi4UTED0FwgBTJ+_5vSSWHB5SHFs-e8WTbg@mail.gmail.com>
References: <1456521217-2174580-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	linux-arm-kernel@lists.infradead.org,
	"David S . Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456521217-2174580-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 26, 2016 at 11:13 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> VXLAN can be disabled at compile-time or it can be a loadable
> module while mlx5 is built-in, which leads to a link error:
>
> drivers/net/built-in.o: In function `mlx5e_create_netdev':
> ntb_netdev.c:(.text+0x106de4): undefined reference to `vxlan_get_rx_port'
>
> This avoids the link error and makes the vxlan code optional,
> like the other ethernet drivers do as well.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: b3f63c3d5e2c ("net/mlx5e: Add netdev support for VXLAN tunneling")
Hi Arnd,

Thanks for the patch, I will suggest some slight modifications and we
will handle it and re-post the patch.

>
>         struct mlx5e_params        params;
>         spinlock_t                 async_events_spinlock; /* sync hw events */
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index 0d45f35aee72..44fc4bc35ffd 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -2116,6 +2116,9 @@ static netdev_features_t mlx5e_vxlan_features_check(struct mlx5e_priv *priv,
>         u16 proto;
>         u16 port = 0;
>
> +       if (!IS_ENABLED(CONFIG_MLX5_CORE_EN_VXLAN))
> +               goto out;
> +

I would rather wrap the whole mlx5e_features_check with the suggested
config flag and disable it in case CONFIG_MLX5_CORE_EN_VXLAN is OFF,
since this function is only needed for when vxlan is supported.

>
>  static inline bool mlx5e_vxlan_allowed(struct mlx5_core_dev *mdev)
>  {
> -       return (MLX5_CAP_ETH(mdev, tunnel_stateless_vxlan) &&
> +       return IS_ENABLED(CONFIG_MLX5_CORE_EN_VXLAN) &&
> +               (MLX5_CAP_ETH(mdev, tunnel_stateless_vxlan) &&
>                 mlx5_core_is_pf(mdev));
>  }

Same here.
