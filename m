From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/3] net/mlx4_en: Add tx queue maxrate support
Date: Wed, 11 Mar 2015 18:47:38 +0300
Message-ID: <5500639A.4080606@cogentembedded.com>
References: <1426079690-28271-1-git-send-email-ogerlitz@mellanox.com> <1426079690-28271-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:44004 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbbCKPrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 11:47:43 -0400
Received: by lbvp9 with SMTP id p9so9779863lbv.10
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 08:47:42 -0700 (PDT)
In-Reply-To: <1426079690-28271-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/11/2015 4:14 PM, Or Gerlitz wrote:

> Add ndo_set_tx_maxrate support.

> To support per tx queue maxrate limit, we use the update-qp firmware
> command to do run-time rate setting for the qp that serves this tx ring.

> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Ido Shamay <idos@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   33 ++++++++++++++++++++++++
>   1 files changed, 33 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index c59ed92..2a58d2a 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2379,6 +2379,37 @@ static netdev_features_t mlx4_en_features_check(struct sk_buff *skb,
>   }
>   #endif
>
> +int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 maxrate)
> +{
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +	struct mlx4_en_tx_ring *tx_ring = priv->tx_ring[queue_index];
> +	struct mlx4_update_qp_params params;
> +	int err;
> +
> +	if (!(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_QP_RATE_LIMIT)) {
> +		err = -EOPNOTSUPP;
> +		goto out;
> +	}
> +
> +	/* rate provided to us in Mbs, check if it fits into 12 bits, if not use Gbs */
> +	if ((maxrate >> 12)) {
> +		params.rate_unit = MLX4_QP_RATE_LIMIT_GBS;
> +		params.rate_val  = maxrate >> 10;

    And shouldn't that be 'maxrate  / 1000' as we seem to be dealing with Mbps?

[...]

WBR, Sergei
