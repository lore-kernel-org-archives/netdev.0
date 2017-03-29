From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [net-next 09/14] net/mlx5e: Minimize mlx5e_{open/close}_locked
Date: Tue, 28 Mar 2017 21:11:53 -0700
Message-ID: <20170328211153.4492ec44@cakuba.lan>
References: <20170327204910.20287-1-saeedm@mellanox.com>
        <20170327204910.20287-10-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:55241 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751325AbdC2EMP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 00:12:15 -0400
In-Reply-To: <20170327204910.20287-10-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Mar 2017 23:49:05 +0300, Saeed Mahameed wrote:
> mlx5e_redirect_rqts_to_{channels,drop} and mlx5e_{add,del}_sqs_fwd_rules
> and Set real num tx/rx queues belong to
> mlx5e_{activate,deactivate}_priv_channels, for that we move those functions
> and minimize mlx5e_open/close flows.
> 
> This will be needed in downstream patches to replace old channels with new
> ones without the need to call mlx5e_close/open.
> 
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> Reviewed-by: Tariq Toukan <tariqt@mellanox.com>

Nice series!  Let me share some experiences below...

> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 40 +++++++++++------------
>  drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 10 ++++--
>  2 files changed, 26 insertions(+), 24 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index a6e09c46440b..a94f84ec2c1a 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -2498,14 +2498,33 @@ static void mlx5e_build_channels_tx_maps(struct mlx5e_priv *priv)
>  
>  static void mlx5e_activate_priv_channels(struct mlx5e_priv *priv)
>  {
> +	int num_txqs = priv->channels.num * priv->channels.params.num_tc;
> +	struct net_device *netdev = priv->netdev;
> +
> +	mlx5e_netdev_set_tcs(netdev);
> +	if (netdev->real_num_tx_queues != num_txqs)
> +		netif_set_real_num_tx_queues(netdev, num_txqs);

netif_set_real_num_{r,t}x_queues() is the only thing stopping us from
achieving perfection :)  When new queues are allocated these calls may
fail.  I remember writing a "try to do increases first" helper but
ultimately didn't think it was worth while.  Perhaps we can revisit
that if more drivers move to this paradigm...

> +	if (netdev->real_num_rx_queues != priv->channels.num)

Arnd pointed out to me in:

08348995c47e ("netronome: don't access real_num_rx_queues directly")

that read_num_rx_queues is under CONFIG_SYSFS :)

> +		netif_set_real_num_rx_queues(netdev, priv->channels.num);
