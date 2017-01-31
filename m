From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 31 Jan 2017 12:23:03 +1100
Message-ID: <20170131122303.5a5bb47a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/mellanox/mlx5/core/en_tc.c

between commit:

  3e621b19b0bb ("net/mlx5e: Support TC encapsulation offloads with upper devices")

from the net tree and commits:

  75c33da82736 ("net/mlx5e: TC ipv4 tunnel encap offload cosmetic changes")
  9a941117fb76 ("net/mlx5e: Maximize ip tunnel key usage on the TC offloading path")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index c5282b6aba8b,640f10f2e994..000000000000
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@@ -660,13 -684,10 +684,11 @@@ static int mlx5e_route_lookup_ipv4(stru
  				   struct net_device **out_dev,
  				   struct flowi4 *fl4,
  				   struct neighbour **out_n,
- 				   __be32 *saddr,
  				   int *out_ttl)
  {
 +	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
  	struct rtable *rt;
  	struct neighbour *n = NULL;
- 	int ttl;
  
  #if IS_ENABLED(CONFIG_INET)
  	int ret;
@@@ -678,21 -699,21 +700,19 @@@
  #else
  	return -EOPNOTSUPP;
  #endif
 -
 -	if (!switchdev_port_same_parent_id(priv->netdev, rt->dst.dev)) {
 -		pr_warn("%s: can't offload, devices not on same HW e-switch\n", __func__);
 -		ip_rt_put(rt);
 -		return -EOPNOTSUPP;
 -	}
 +	/* if the egress device isn't on the same HW e-switch, we use the uplink */
 +	if (!switchdev_port_same_parent_id(priv->netdev, rt->dst.dev))
 +		*out_dev = mlx5_eswitch_get_uplink_netdev(esw);
 +	else
 +		*out_dev = rt->dst.dev;
  
- 	ttl = ip4_dst_hoplimit(&rt->dst);
+ 	*out_ttl = ip4_dst_hoplimit(&rt->dst);
  	n = dst_neigh_lookup(&rt->dst, &fl4->daddr);
  	ip_rt_put(rt);
  	if (!n)
  		return -ENOMEM;
  
  	*out_n = n;
- 	*saddr = fl4->saddr;
- 	*out_ttl = ttl;
 -	*out_dev = rt->dst.dev;
  
  	return 0;
  }
