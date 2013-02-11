From: Amir Vadai <amirv@mellanox.com>
Subject: Re: linux-next: build failure after merge of the akpm tree
Date: Mon, 11 Feb 2013 14:04:18 +0200
Message-ID: <5118DE42.7040902@mellanox.com>
References: <20130211181332.ecf1cad33b04b3872b685620@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Yan Burman <yanb@mellanox.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130211181332.ecf1cad33b04b3872b685620@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/02/2013 09:13, Stephen Rothwell wrote:
> Hi Andrew,
> 
> After merging the akpm tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
> 
> drivers/net/ethernet/mellanox/mlx4/en_rx.c: In function 'mlx4_en_process_rx_cq':
> drivers/net/ethernet/mellanox/mlx4/en_rx.c:628:53: error: macro "hlist_for_each_entry_rcu" passed 4 arguments, but takes just 3
> drivers/net/ethernet/mellanox/mlx4/en_rx.c:628:5: error: 'hlist_for_each_entry_rcu' undeclared (first use in this function)
> drivers/net/ethernet/mellanox/mlx4/en_rx.c:628:55: error: expected ';' before '{' token
> 
> Caused by commit c07cb4b0ab78 ("net/mlx4_en: Manage hash of MAC addresses
> per port") from the net-next tree interacting with commit "hlist: drop
> the node parameter from iterators" from the akpm tree.
> 
> I applied the following merge fix patch for today:
> 
> From 7a10f5e7e8d1232d618307d568ea9a78dc4680bb Mon Sep 17 00:00:00 2001
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 11 Feb 2013 18:01:23 +1100
> Subject: [PATCH] net/mlx4_en: fix up for hlist_for_each_entry_rcu API change
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index ce38654..19a9c05 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -617,7 +617,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  
>  			if (is_multicast_ether_addr(ethh->h_dest)) {
>  				struct mlx4_mac_entry *entry;
> -				struct hlist_node *n;
>  				struct hlist_head *bucket;
>  				unsigned int mac_hash;
>  
> @@ -625,7 +624,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  				mac_hash = ethh->h_source[MLX4_EN_MAC_HASH_IDX];
>  				bucket = &priv->mac_hash[mac_hash];
>  				rcu_read_lock();
> -				hlist_for_each_entry_rcu(entry, n, bucket, hlist) {
> +				hlist_for_each_entry_rcu(entry, bucket, hlist) {
>  					if (ether_addr_equal_64bits(entry->mac,
>  								    ethh->h_source)) {
>  						rcu_read_unlock();
> 

Acked-By: Amir Vadai <amirv@mellanox.com>
