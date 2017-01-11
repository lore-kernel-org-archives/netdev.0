From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net] net/mlx5e: fix another -Wmaybe-uninitialized warning
Date: Wed, 11 Jan 2017 22:14:51 +0100
Message-ID: <20170111211451.2705705-1-arnd@arndb.de>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: Saeed Mahameed <saeedm@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As found by Olof's build bot, today's mainline kernel gained a harmless
warning about a potential uninitalied variable reference:

drivers/net/ethernet/mellanox/mlx5/core/en_tc.c: In function 'parse_tc_fdb_actions':
drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:769:13: warning: 'out_dev' may be used uninitialized in this function [-Wmaybe-uninitialized]
drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:811:21: note: 'out_dev' was declared here

This was introduced through the addition of an 'IS_ERR/PTR_ERR' pair that
gcc is unfortunately unable to completely figure out. Replacing it with
PTR_ERR_OR_ZERO makes the code more understandable to gcc so it no longer
warns.

Hadar Hen Zion already attempted to fix the warning earlier by adding
fake initializations, but that ended up just making the code worse without
fully addressing all warnings, so I'm reverting it now that it is no longer
needed.

In order to avoid pulling a variable declaration into the #ifdef, I'm
removing it in favor of a more readable 'if()' statement here that
has the same effect.

Link: http://arm-soc.lixom.net/buildlogs/mainline/v4.10-rc3-98-gcff3b2c/
Fixes: a42485eb0ee4 ("net/mlx5e: TC ipv4 tunnel encap offload error flow fixes")
Fixes: a757d108dc1a ("net/mlx5e: Fix kbuild warnings for uninitialized parameters")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 118cea5..07d83835 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -666,14 +666,15 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
 	struct rtable *rt;
 	struct neighbour *n = NULL;
 	int ttl;
+	int ret;
+
+	if (!IS_ENABLED(CONFIG_INET))
+		return -EOPNOTSUPP;
 
-#if IS_ENABLED(CONFIG_INET)
 	rt = ip_route_output_key(dev_net(mirred_dev), fl4);
-	if (IS_ERR(rt))
-		return PTR_ERR(rt);
-#else
-	return -EOPNOTSUPP;
-#endif
+	ret = PTR_ERR_OR_ZERO(rt);
+	if (ret)
+		return ret;
 
 	if (!switchdev_port_same_parent_id(priv->netdev, rt->dst.dev)) {
 		pr_warn("%s: can't offload, devices not on same HW e-switch\n", __func__);
@@ -741,8 +742,8 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	struct flowi4 fl4 = {};
 	char *encap_header;
 	int encap_size;
-	__be32 saddr = 0;
-	int ttl = 0;
+	__be32 saddr;
+	int ttl;
 	int err;
 
 	encap_header = kzalloc(max_encap_size, GFP_KERNEL);
-- 
2.9.0
