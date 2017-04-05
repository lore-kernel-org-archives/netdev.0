From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] net/mlx5e: fix build error without CONFIG_SYSFS
Date: Wed, 5 Apr 2017 10:55:00 -0400
Message-ID: <CALzJLG_cxNi37SSZaeMOjDHzURtHp088LJFXG-D3TYvUPTH7vQ@mail.gmail.com>
References: <20170405091110.711-1-tobias.regnery@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Tobias Regnery <tobias.regnery@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170405091110.711-1-tobias.regnery@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 5, 2017 at 5:11 AM, Tobias Regnery <tobias.regnery@gmail.com> wrote:
> Commit 9008ae074885 ("net/mlx5e: Minimize mlx5e_{open/close}_locked")
> copied the calls to netif_set_real_num_{tx,rx}_queues from
> mlx5e_open_locked to mlx5e_activate_priv_channels and wraps them in an
> if condition to test for netdev->real_num_{tx,rx}_queues.
>
> But netdev->real_num_rx_queues is conditionally compiled in if CONFIG_SYSFS
> is set. Without CONFIG_SYSFS the build fails:
>
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c: In function 'mlx5e_activate_priv_channels':
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2515:12: error: 'struct net_device' has no member named 'real_num_rx_queues'; did you mean 'real_num_tx_queues'?
>
> Fix this by unconditionally call netif_set_real_num{tx,rx}_queues like before
> commit 9008ae074885.
>
> Fixes: 9008ae074885 ("net/mlx5e: Minimize mlx5e_{open/close}_locked")
> Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index ec389b1b51cb..d5248637d44f 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -2510,10 +2510,8 @@ static void mlx5e_activate_priv_channels(struct mlx5e_priv *priv)
>         struct net_device *netdev = priv->netdev;
>
>         mlx5e_netdev_set_tcs(netdev);
> -       if (netdev->real_num_tx_queues != num_txqs)
> -               netif_set_real_num_tx_queues(netdev, num_txqs);
> -       if (netdev->real_num_rx_queues != priv->channels.num)
> -               netif_set_real_num_rx_queues(netdev, priv->channels.num);
> +       netif_set_real_num_tx_queues(netdev, num_txqs);
> +       netif_set_real_num_rx_queues(netdev, priv->channels.num);
>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>

Thanks Tobias for the fix, although it is redundant for most of the
reconfiguration options of mlx5 to call set_real_num_{rx,tx} queues
every time, but it is not that big of a deal, so it is ok with me to
align the code with the previous behavior we had before ("net/mlx5e:
Minimize mlx5e_{open/close}_locked").
