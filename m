From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 08/11] net/mlx5e: Properly resolve TC offloaded ipv6 vxlan tunnel source address
Date: Thu, 31 Aug 2017 01:21:07 +0300
Message-ID: <20170830222110.15737-9-saeedm@mellanox.com>
References: <20170830222110.15737-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Paul Blakey <paulb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53266 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751372AbdH3WVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:21:33 -0400
In-Reply-To: <20170830222110.15737-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>

Currently if vxlan tunnel ipv6 src isn't supplied the driver fails to
resolve it as part of the route lookup. The resulting encap header
is left with a zeroed out ipv6 src address so the packets are sent
with this src ip.

Use an appropriate route lookup API that also resolves the source
ipv6 address if it's not supplied.

Fixes: ce99f6b97fcd ('net/mlx5e: Support SRIOV TC encapsulation offloads for IPv6 tunnels')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 3c536f560dd2..7f282e8f4e7f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1443,12 +1443,10 @@ static int mlx5e_route_lookup_ipv6(struct mlx5e_priv *priv,
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	int ret;
 
-	dst = ip6_route_output(dev_net(mirred_dev), NULL, fl6);
-	ret = dst->error;
-	if (ret) {
-		dst_release(dst);
+	ret = ipv6_stub->ipv6_dst_lookup(dev_net(mirred_dev), NULL, &dst,
+					 fl6);
+	if (ret < 0)
 		return ret;
-	}
 
 	*out_ttl = ip6_dst_hoplimit(dst);
 
-- 
2.13.0
