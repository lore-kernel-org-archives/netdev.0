From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v1 8/9] net/mlx4_en: Add unicast MAC filtering
Date: Wed, 06 Feb 2013 09:37:35 -0800
Message-ID: <1360172255.28557.42.camel@edumazet-glaptop>
References: <1360142035-13228-1-git-send-email-amirv@mellanox.com>
	 <1360142035-13228-9-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:53839 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754987Ab3BFRhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 12:37:39 -0500
Received: by mail-da0-f48.google.com with SMTP id v40so768604dad.21
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 09:37:39 -0800 (PST)
In-Reply-To: <1360142035-13228-9-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 11:13 +0200, Amir Vadai wrote:
> From: Yan Burman <yanb@mellanox.com>
> 
> Implement and advertise unicast MAC filtering, such that setting macvlan
> instance over mlx4_en interfaces will not require the networking core
> to put mlx4_en devices in promiscuous mode.
> 
> Signed-off-by: Yan Burman <yanb@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  102 ++++++++++++++++++++++++
>  1 files changed, 102 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 8eb24ee..5da293b 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1016,6 +1016,102 @@ static void mlx4_en_do_multicast(struct mlx4_en_priv *priv,
>  	}
>  }
>  
> +static void mlx4_en_do_uc_filter(struct mlx4_en_priv *priv,
> +				 struct net_device *dev,
> +				 struct mlx4_en_dev *mdev)
> +{
> +	struct netdev_hw_addr *ha;
> +	struct mlx4_mac_entry *entry;
> +	struct hlist_node *n, *tmp;
> +	bool found;
> +	u64 mac;
> +	int err = 0;
> +	struct hlist_head *bucket;
> +	unsigned int i;
> +
> +	/* Note that we do not need to protect our mac_hash traversal with rcu,
> +	 * since all modification code is protected by mdev->state_lock
> +	 */
> +
> +	/* find what to add */
> +	netdev_for_each_uc_addr(ha, dev) {
> +		found = false;
> +		bucket = &priv->mac_hash[ha->addr[MLX4_EN_MAC_HASH_IDX]];
> +		hlist_for_each_entry(entry, n, bucket, hlist) {
> +			if (ether_addr_equal_64bits(entry->mac, ha->addr)) {
> +				found = true;
> +				break;
> +			}
> +		}
> +
> +		if (!found) {
> +			entry = kmalloc(sizeof(*entry), GFP_KERNEL);
> +			if (!entry) {
> +				en_err(priv, "Failed adding MAC %pM on port:%d (out of memory)\n",
> +				       ha->addr, priv->port);
> +				return;
> +			}
> +			mac = mlx4_en_mac_to_u64(ha->addr);
> +			memcpy(entry->mac, ha->addr, ETH_ALEN);
> +			err = mlx4_register_mac(mdev->dev, priv->port, mac);
> +			if (err < 0) {
> +				en_err(priv, "Failed registering MAC %pM on port %d: %d\n",
> +				       ha->addr, priv->port, err);
> +				kfree(entry);
> +				continue;
> +			}

In case of error (kmalloc() -> NULL, or mlx4_register_mac() -> err,
should not you need to force promisc ?

At first glance, there is a limit of 128 mac per device
(MLX4_MAX_MAC_NUM), but one can declare more than 128 macvlans...
