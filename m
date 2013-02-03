From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH] net/mlx4_en: Fixed compilation error when CONFIG_INET
 isn't defined
Date: Sun, 3 Feb 2013 14:36:14 +0200
Message-ID: <510E59BE.8050705@mellanox.com>
References: <1359894819-18794-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Hadar Hen Zion" <hadarh@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:33058 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751732Ab3BCMgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 07:36:21 -0500
In-Reply-To: <1359894819-18794-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2013 14:33, Amir Vadai wrote:
> From: Hadar Hen Zion <hadarh@mellanox.com>
>
> ip_eth_mc_map function can't be used when CONFIG_INET isn't defined.
> Fixed compilation error by adding CONFIG_INET define check before using the
> function.
>
> Change-Id: I50a95f283548b0d782def2d49077e35f91fe1c2e
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   56 +++++++++++++++-------
>   1 files changed, 38 insertions(+), 18 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> index 911d488..f523f02 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> @@ -711,6 +711,7 @@ static int mlx4_en_ethtool_add_mac_rule_by_ipv4(struct mlx4_en_priv *priv,
>   						struct mlx4_spec_list *spec_l2,
>   						__be32 ipv4_dst)
>   {
> +#ifdef CONFIG_INET
>   	__be64 be_mac = 0;
>   	unsigned char mac[ETH_ALEN];
>
> @@ -726,12 +727,16 @@ static int mlx4_en_ethtool_add_mac_rule_by_ipv4(struct mlx4_en_priv *priv,
>   	}
>
>   	return mlx4_en_ethtool_add_mac_rule(cmd, rule_list_h, spec_l2, &mac[0]);
> +#else
> +	return -EINVAL;
> +#endif
>   }
>
>   static int add_ip_rule(struct mlx4_en_priv *priv,
>   		       struct ethtool_rxnfc *cmd,
>   		       struct list_head *list_h)
>   {
> +	int err;
>   	struct mlx4_spec_list *spec_l2 = NULL;
>   	struct mlx4_spec_list *spec_l3 = NULL;
>   	struct ethtool_usrip4_spec *l3_mask = &cmd->fs.m_u.usr_ip4_spec;
> @@ -740,14 +745,15 @@ static int add_ip_rule(struct mlx4_en_priv *priv,
>   	spec_l2 = kzalloc(sizeof(*spec_l2), GFP_KERNEL);
>   	if (!spec_l2 || !spec_l3) {
>   		en_err(priv, "Fail to alloc ethtool rule.\n");
> -		kfree(spec_l2);
> -		kfree(spec_l3);
> -		return -ENOMEM;
> +		err = -ENOMEM;
> +		goto free_spec;
>   	}
>
> -	mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h, spec_l2,
> -					     cmd->fs.h_u.
> -					     usr_ip4_spec.ip4dst);
> +	err = mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h, spec_l2,
> +						   cmd->fs.h_u.
> +						   usr_ip4_spec.ip4dst);
> +	if (err)
> +		goto free_spec;
>   	spec_l3->id = MLX4_NET_TRANS_RULE_ID_IPV4;
>   	spec_l3->ipv4.src_ip = cmd->fs.h_u.usr_ip4_spec.ip4src;
>   	if (l3_mask->ip4src)
> @@ -758,12 +764,18 @@ static int add_ip_rule(struct mlx4_en_priv *priv,
>   	list_add_tail(&spec_l3->list, list_h);
>
>   	return 0;
> +
> +free_spec:
> +	kfree(spec_l2);
> +	kfree(spec_l3);
> +	return err;
>   }
>
>   static int add_tcp_udp_rule(struct mlx4_en_priv *priv,
>   			     struct ethtool_rxnfc *cmd,
>   			     struct list_head *list_h, int proto)
>   {
> +	int err;
>   	struct mlx4_spec_list *spec_l2 = NULL;
>   	struct mlx4_spec_list *spec_l3 = NULL;
>   	struct mlx4_spec_list *spec_l4 = NULL;
> @@ -774,29 +786,31 @@ static int add_tcp_udp_rule(struct mlx4_en_priv *priv,
>   	spec_l4 = kzalloc(sizeof(*spec_l4), GFP_KERNEL);
>   	if (!spec_l2 || !spec_l3 || !spec_l4) {
>   		en_err(priv, "Fail to alloc ethtool rule.\n");
> -		kfree(spec_l2);
> -		kfree(spec_l3);
> -		kfree(spec_l4);
> -		return -ENOMEM;
> +		err = -ENOMEM;
> +		goto free_spec;
>   	}
>
>   	spec_l3->id = MLX4_NET_TRANS_RULE_ID_IPV4;
>
>   	if (proto == TCP_V4_FLOW) {
> -		mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h,
> -						     spec_l2,
> -						     cmd->fs.h_u.
> -						     tcp_ip4_spec.ip4dst);
> +		err = mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h,
> +							   spec_l2,
> +							   cmd->fs.h_u.
> +							   tcp_ip4_spec.ip4dst);
> +		if (err)
> +			goto free_spec;
>   		spec_l4->id = MLX4_NET_TRANS_RULE_ID_TCP;
>   		spec_l3->ipv4.src_ip = cmd->fs.h_u.tcp_ip4_spec.ip4src;
>   		spec_l3->ipv4.dst_ip = cmd->fs.h_u.tcp_ip4_spec.ip4dst;
>   		spec_l4->tcp_udp.src_port = cmd->fs.h_u.tcp_ip4_spec.psrc;
>   		spec_l4->tcp_udp.dst_port = cmd->fs.h_u.tcp_ip4_spec.pdst;
>   	} else {
> -		mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h,
> -						     spec_l2,
> -						     cmd->fs.h_u.
> -						     udp_ip4_spec.ip4dst);
> +		err = mlx4_en_ethtool_add_mac_rule_by_ipv4(priv, cmd, list_h,
> +							   spec_l2,
> +							   cmd->fs.h_u.
> +							   udp_ip4_spec.ip4dst);
> +		if (err)
> +			goto free_spec;
>   		spec_l4->id = MLX4_NET_TRANS_RULE_ID_UDP;
>   		spec_l3->ipv4.src_ip = cmd->fs.h_u.udp_ip4_spec.ip4src;
>   		spec_l3->ipv4.dst_ip = cmd->fs.h_u.udp_ip4_spec.ip4dst;
> @@ -818,6 +832,12 @@ static int add_tcp_udp_rule(struct mlx4_en_priv *priv,
>   	list_add_tail(&spec_l4->list, list_h);
>
>   	return 0;
> +
> +free_spec:
> +	kfree(spec_l2);
> +	kfree(spec_l3);
> +	kfree(spec_l4);
> +	return err;
>   }
>
>   static int mlx4_en_ethtool_to_net_trans_rule(struct net_device *dev,
>

Please apply this to net-next.

Amir
