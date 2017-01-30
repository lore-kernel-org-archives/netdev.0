From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH net] mlx4: xdp_prog becomes inactive after ethtool '-L' or
 '-G'
Date: Mon, 30 Jan 2017 19:18:28 +0200
Message-ID: <f2963258-62af-c7ed-b1ad-2924ba087880@mellanox.com>
References: <1485589251-3896393-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0040.outbound.protection.outlook.com ([104.47.2.40]:28256
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751066AbdA3Rgd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 12:36:33 -0500
In-Reply-To: <1485589251-3896393-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,

Thanks for your patch.

It looks good to me, in general.
I just have one small comment below.

On 28/01/2017 9:40 AM, Martin KaFai Lau wrote:
> If the rx-queues ever get re-initialized (e.g. by changing the
> number of rx-queues with ethtool -L), the existing xdp_prog becomes
> inactive.
>
> The bug is that the xdp_prog ptr has not been carried over from
> the old rx-queues to the new rx-queues
>
> Fixes: 47a38e155037 ("net/mlx4_en: add support for fast rx drop bpf program")
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---
...
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 761f8b12399c..f4179086b3c6 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2184,23 +2184,57 @@ static void mlx4_en_update_priv(struct mlx4_en_priv *dst,
>   
>   int mlx4_en_try_alloc_resources(struct mlx4_en_priv *priv,
>   				struct mlx4_en_priv *tmp,
> -				struct mlx4_en_port_profile *prof)
> +				struct mlx4_en_port_profile *prof,
> +				bool carry_xdp_prog)
>   {
> -	int t;
> +	struct bpf_prog *xdp_prog = NULL;
> +	int err;
> +	int i;
>   
>   	mlx4_en_copy_priv(tmp, priv, prof);
>   
> +	if (carry_xdp_prog) {
> +		/* All rx_rings has the same xdp_prog.  Pick the first one */
> +		xdp_prog = rcu_dereference_protected(
> +			priv->rx_ring[0]->xdp_prog,
> +			lockdep_is_held(&priv->mdev->state_lock));
> +
> +		if (xdp_prog) {
> +			xdp_prog = bpf_prog_add(xdp_prog, tmp->rx_ring_num);
> +			if (IS_ERR(xdp_prog)) {
> +				err = PTR_ERR(xdp_prog);
> +				xdp_prog = NULL;
> +				goto err_free;
> +			}
> +		}
> +	}
Why do you prefer dealing with xdp_prog in two stages? You can handle it 
all at once, after "mlx4_en_alloc_resources()" succeeds.
> +
>   	if (mlx4_en_alloc_resources(tmp)) {
>   		en_warn(priv,
>   			"%s: Resource allocation failed, using previous configuration\n",
>   			__func__);
> -		for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
> -			kfree(tmp->tx_ring[t]);
> -			kfree(tmp->tx_cq[t]);
> -		}
> -		return -ENOMEM;
> +		err = -ENOMEM;
> +		goto err_free;
> +	}
> +
> +	if (xdp_prog) {
> +		for (i = 0; i < tmp->rx_ring_num; i++)
> +			rcu_assign_pointer(tmp->rx_ring[i]->xdp_prog,
> +					   xdp_prog);
>   	}
> +
>   	return 0;
> +
> +err_free:
> +	if (xdp_prog)
> +		bpf_prog_sub(xdp_prog, tmp->rx_ring_num);
> +
> +	for (i = 0; i < MLX4_EN_NUM_TX_TYPES; i++) {
> +		kfree(tmp->tx_ring[i]);
> +		kfree(tmp->tx_cq[i]);
> +	}
> +
> +	return err;
>   }
>   
>   void mlx4_en_safe_replace_resources(struct mlx4_en_priv *priv,
>
Regards,
Tariq Toukan.
