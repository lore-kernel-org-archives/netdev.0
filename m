From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V1 2/2] net/mlx4_en: Add netdev support for
 TCP/IP offloads of vxlan tunneling
Date: Sun, 22 Dec 2013 06:19:49 -0800
Message-ID: <1387721989.22671.16.camel@joe-AO722>
References: <1387720854-1355-1-git-send-email-ogerlitz@mellanox.com>
	 <1387720854-1355-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, amirv@mellanox.com,
	yanb@mellanox.com, ast@plumgrid.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0228.hostedemail.com ([216.40.44.228]:57404 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752290Ab3LVOUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 09:20:43 -0500
Received: from smtprelay.hostedemail.com (ff-bigip1 [10.5.19.254])
	by smtpgrave08.hostedemail.com (Postfix) with ESMTP id 62E8721194F
	for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 14:20:03 +0000 (UTC)
In-Reply-To: <1387720854-1355-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-12-22 at 16:00 +0200, Or Gerlitz wrote:

trivia:

> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
[]
> @@ -1061,6 +1126,10 @@ static void mlx4_en_do_multicast(struct mlx4_en_priv *priv,
>  				if (err)
>  					en_err(priv, "Fail to attach multicast address\n");
>  
> +				err = mlx4_en_tunnel_steer_add(priv, &mc_list[10], priv->base_qpn,
> +							       &mclist->tunnel_reg_id);
> +					if (err)
> +						en_err(priv, "Failed to attach multicast address\n");

Overly indented if/en_err here.

> @@ -2400,6 +2478,14 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
>  	if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_A0)
>  		dev->priv_flags |= IFF_UNICAST_FLT;
>  
> +	if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> +		dev->hw_enc_features = NETIF_F_SG | NETIF_F_IP_CSUM |
> +					NETIF_F_RXCSUM | NETIF_F_TSO |
> +					NETIF_F_GSO_UDP_TUNNEL;
> +		dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
> +		dev->features    |= NETIF_F_GSO_UDP_TUNNEL;

Perhaps hw_enc_features should be |= as well.
NETIF_F_SG is set in register_netdevice() for hw_enc_features.

> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
[]
> @@ -68,6 +68,12 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
>  	context->db_rec_addr = cpu_to_be64(priv->res.db.dma << 2);
>  	if (!(dev->features & NETIF_F_HW_VLAN_CTAG_RX))
>  		context->param3 |= cpu_to_be32(1 << 30);
> +
> +	if (!is_tx && !rss &&
> +	    (mdev->dev->caps.tunnel_offload_mode ==  MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
> +		en_dbg(HW, priv, "Setting RX qp %x tunnel mode to RX tunneled & non-tunneled\n", qpn);
> +		context->srqn |= cpu_to_be32(7 << 28); /* this fills bits 30:28 */

Is that bit setting 0 based or 1 based?

> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
[]
> @@ -628,7 +628,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  	int nr;
>  	unsigned int length;
>  	int polled = 0;
> -	int ip_summed;
> +	int ip_summed, l2_tunnel;

Maybe nicer as bool
