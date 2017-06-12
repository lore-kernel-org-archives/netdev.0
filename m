From: Jes Sorensen <jsorensen@fb.com>
Subject: Re: [PATCH RFC net-next 4/4] net/mlx5: Add CONFIG_MLX5_ESWITCH
 Kconfig
Date: Mon, 12 Jun 2017 14:20:32 -0400
Message-ID: <f30b57d2-176d-891e-3ac5-8e775946fed2@fb.com>
References: <20170607234214.24723-1-saeedm@mellanox.com>
 <20170607234214.24723-5-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kernel-team@fb.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Tzahi Oved <tzahio@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35109 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752583AbdFLSUp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 14:20:45 -0400
In-Reply-To: <20170607234214.24723-5-saeedm@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2017 07:42 PM, Saeed Mahameed wrote:
> This patch gives the option to chose whether to compile the driver with or
> without eswitch/eswitch_offloads(switchdev mode)/en_rep(VF representors)
> and en_tc offloads.
> 
> It also removes most of the above modules headers declarations and stubs
> out the API functions which are used outside these modules.
> 
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  7 +++++
>   drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  6 +++--
>   drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 33 +++++++++++++++--------
>   drivers/net/ethernet/mellanox/mlx5/core/en_rep.h  |  8 ++++++
>   drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |  2 ++
>   drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |  7 +++++
>   drivers/net/ethernet/mellanox/mlx5/core/eswitch.h | 23 +++++++++++-----
>   drivers/net/ethernet/mellanox/mlx5/core/main.c    | 10 +------
>   8 files changed, 68 insertions(+), 28 deletions(-)

Overall good, a few nits

> @@ -3316,6 +3317,7 @@ static int mlx5e_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>   	}
>   }
>   
> +#ifdef CONFIG_MLX5_ESWITCH
>   static int mlx5e_set_vf_mac(struct net_device *dev, int vf, u8 *mac)
>   {
>   	struct mlx5e_priv *priv = netdev_priv(dev);
> @@ -3418,6 +3420,7 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
>   	return mlx5_eswitch_get_vport_stats(mdev->priv.eswitch, vf + 1,
>   					    vf_stats);
>   }
> +#endif
>   
>   static void mlx5e_add_vxlan_port(struct net_device *netdev,
>   				 struct udp_tunnel_info *ti)
> @@ -3659,6 +3662,7 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
>   #endif
>   };
>   
> +#ifdef CONFIG_MLX5_ESWITCH
>   static const struct net_device_ops mlx5e_netdev_ops_sriov = {
>   	.ndo_open                = mlx5e_open,
>   	.ndo_stop                = mlx5e_close,
> @@ -3697,6 +3701,7 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
>   	.ndo_has_offload_stats	 = mlx5e_has_offload_stats,
>   	.ndo_get_offload_stats	 = mlx5e_get_offload_stats,
>   };
> +#endif
>   
>   static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
>   {
> @@ -3923,9 +3928,11 @@ static void mlx5e_set_netdev_dev_addr(struct net_device *netdev)
>   	}
>   }
>   
> +#if IS_ENABLED(CONFIG_NET_SWITCHDEV) && IS_ENABLED(CONFIG_MLX5_ESWITCH)
>   static const struct switchdev_ops mlx5e_switchdev_ops = {
>   	.switchdev_port_attr_get	= mlx5e_attr_get,
>   };
> +#endif
>   
>   static void mlx5e_build_nic_netdev(struct net_device *netdev)
>   {

Why not move these functions and the struct into one of the files that 
is being compiled out. The less #ifdefs we leave in the code the better.

> @@ -3936,15 +3943,17 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
>   
>   	SET_NETDEV_DEV(netdev, &mdev->pdev->dev);
>   
> -	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
> -		netdev->netdev_ops = &mlx5e_netdev_ops_sriov;
>   #ifdef CONFIG_MLX5_CORE_EN_DCB
> -		if (MLX5_CAP_GEN(mdev, qos))
> -			netdev->dcbnl_ops = &mlx5e_dcbnl_ops;
> +	if (MLX5_CAP_GEN(mdev, vport_group_manager) && MLX5_CAP_GEN(mdev, qos))
> +		netdev->dcbnl_ops = &mlx5e_dcbnl_ops;
> +#endif
> +
> +#ifdef CONFIG_MLX5_ESWITCH
> +	if (MLX5_CAP_GEN(mdev, vport_group_manager))
> +		netdev->netdev_ops = &mlx5e_netdev_ops_sriov;
> +	else
>   #endif
> -	} else {
>   		netdev->netdev_ops = &mlx5e_netdev_ops_basic;
> -	}
>   
>   	netdev->watchdog_timeo    = 15 * HZ;

This kind of #ifdef is always bad, it's hard to read and easy to get 
wrong. Why not have MLX5_CAP_GEN return 0 if MLX5_ESWITCH is not enabled 
and have a dummy pointer?

> @@ -4016,7 +4025,7 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
>   
>   	mlx5e_set_netdev_dev_addr(netdev);
>   
> -#ifdef CONFIG_NET_SWITCHDEV
> +#if IS_ENABLED(CONFIG_NET_SWITCHDEV) && IS_ENABLED(CONFIG_MLX5_ESWITCH)
>   	if (MLX5_CAP_GEN(mdev, vport_group_manager))
>   		netdev->switchdev_ops = &mlx5e_switchdev_ops;
>   #endif

Can MLX5_ESWITCH be enabled without NET_SWITCHDEV?

> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> index 66b5fec15313..7d2860252dce 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
> @@ -806,6 +806,7 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
>   		       &wqe->next.next_wqe_index);
>   }
>   
> +#ifdef CONFIG_MLX5_ESWITCH
>   void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
>   {
>   	struct net_device *netdev = rq->netdev;
> @@ -838,6 +839,7 @@ void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
>   	mlx5_wq_ll_pop(&rq->wq, wqe_counter_be,
>   		       &wqe->next.next_wqe_index);
>   }
> +#endif
>   
>   static inline void mlx5e_mpwqe_fill_rx_skb(struct mlx5e_rq *rq,
>   					   struct mlx5_cqe64 *cqe,

Another case of moving it to one of the disabled files.

Cheers,
Jes
