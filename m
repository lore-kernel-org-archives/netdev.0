From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next] mlx4: fix mlx4_en_set_rxfh()
Date: Sun, 23 Nov 2014 18:53:03 +0200
Message-ID: <547210EF.9030800@mellanox.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
	 <1416147798-16561-13-git-send-email-edumazet@google.com>
	 <1416692961.7215.31.camel@decadent.org.uk>
	 <1416700690.20938.34.camel@edumazet-glaptop2.roam.corp.google.com>
 <1416705859.17888.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0100.outbound.protection.outlook.com ([157.55.234.100]:40288
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751253AbaKWQx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2014 11:53:28 -0500
In-Reply-To: <1416705859.17888.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2014 3:24 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> mlx4_en_set_rxfh() can crash if no RSS indir table is provided.
> 
> While we are at it, allow RSS key to be changed with ethtool -X
> 
> Tested:
> 
> myhost:~# cat /proc/sys/net/core/netdev_rss_key 
> b6:89:91:f3:b2:c3:c2:90:11:e8:ce:45:e8:a9:9d:1c:f2:f6:d4:53:61:8b:26:3a:b3:9a:57:97:c3:b6:79:4d:2e:d9:66:5c:72:ed:b6:8e:c5:5d:4d:8c:22:67:30:ab:8a:6e:c3:6a
> 
> myhost:~# ethtool -x eth0
> RX flow hash indirection table for eth0 with 8 RX ring(s):
>     0:      0     1     2     3     4     5     6     7
> RSS hash key:
> b6:89:91:f3:b2:c3:c2:90:11:e8:ce:45:e8:a9:9d:1c:f2:f6:d4:53:61:8b:26:3a:b3:9a:57:97:c3:b6:79:4d:2e:d9:66:5c:72:ed:b6:8e
> 
> myhost:~# ethtool -X eth0 hkey \
> 03:0e:e2:43:fa:82:0e:73:14:2d:c0:68:21:9e:82:99:b9:84:d0:22:e2:b3:64:9f:4a:af:00:fa:cc:05:b4:4a:17:05:14:73:76:58:bd:2f
> 
> myhost:~# ethtool -x eth0
> RX flow hash indirection table for eth0 with 8 RX ring(s):
>     0:      0     1     2     3     4     5     6     7
> RSS hash key:
> 03:0e:e2:43:fa:82:0e:73:14:2d:c0:68:21:9e:82:99:b9:84:d0:22:e2:b3:64:9f:4a:af:00:fa:cc:05:b4:4a:17:05:14:73:76:58:bd:2f
> 
> 
> Reported-by: Ben Hutchings <ben@decadent.org.uk>
> Fixes: b9d1ab7eb42e ("mlx4: use netdev_rss_key_fill() helper")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   10 +++++++---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    1 +
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c      |    3 +--
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    1 +
>  4 files changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> index bdff834a2a7e..c45e06abc073 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> @@ -994,7 +994,7 @@ static int mlx4_en_get_rxfh(struct net_device *dev, u32 *ring_index, u8 *key)
>  			rss_map->base_qpn;
>  	}
>  	if (key)
> -		netdev_rss_key_fill(key, MLX4_EN_RSS_KEY_SIZE);
> +		memcpy(key, priv->rss_key, MLX4_EN_RSS_KEY_SIZE);
>  	return err;
>  }
>  
> @@ -1012,6 +1012,8 @@ static int mlx4_en_set_rxfh(struct net_device *dev, const u32 *ring_index,
>  	 * between rings
>  	 */
>  	for (i = 0; i < priv->rx_ring_num; i++) {
> +		if (!ring_index)
> +			continue;

Why didn't you put the whole loop under the 'if'?

>  		if (i > 0 && !ring_index[i] && !rss_rings)
>  			rss_rings = i;
>  

[...]

Amir
