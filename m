From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] net/mlx5e: skip loopback selftest with !CONFIG_INET
Date: Wed, 30 Nov 2016 22:05:39 +0100
Message-ID: <20161130210552.1756085-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Kamal Heib <kamalh@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_INET is disabled, the new selftest results in a link
error:

drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.o: In function `mlx5e_test_loopback':
en_selftest.c:(.text.mlx5e_test_loopback+0x2ec): undefined reference to `ip_send_check'
en_selftest.c:(.text.mlx5e_test_loopback+0x34c): undefined reference to `udp4_hwcsum'

This hides the specific test in that configuration.

Fixes: 0952da791c97 ("net/mlx5e: Add support for loopback selftest")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
index c32af7daf3ff..65442c36a6e1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
@@ -39,7 +39,9 @@ enum {
 	MLX5E_ST_LINK_STATE,
 	MLX5E_ST_LINK_SPEED,
 	MLX5E_ST_HEALTH_INFO,
+#ifdef CONFIG_INET
 	MLX5E_ST_LOOPBACK,
+#endif
 	MLX5E_ST_NUM,
 };
 
@@ -47,7 +49,9 @@ const char mlx5e_self_tests[MLX5E_ST_NUM][ETH_GSTRING_LEN] = {
 	"Link Test",
 	"Speed Test",
 	"Health Test",
+#ifdef CONFIG_INET
 	"Loopback Test",
+#endif
 };
 
 int mlx5e_self_test_num(struct mlx5e_priv *priv)
@@ -93,6 +97,7 @@ static int mlx5e_test_link_speed(struct mlx5e_priv *priv)
 	return 1;
 }
 
+#ifdef CONFIG_INET
 /* loopback test */
 #define MLX5E_TEST_PKT_SIZE (MLX5_MPWRQ_SMALL_PACKET_THRESHOLD - NET_IP_ALIGN)
 static const char mlx5e_test_text[ETH_GSTRING_LEN] = "MLX5E SELF TEST";
@@ -304,12 +309,15 @@ static int mlx5e_test_loopback(struct mlx5e_priv *priv)
 	kfree(lbtp);
 	return err;
 }
+#endif
 
 static int (*mlx5e_st_func[MLX5E_ST_NUM])(struct mlx5e_priv *) = {
 	mlx5e_test_link_state,
 	mlx5e_test_link_speed,
 	mlx5e_test_health_info,
-	mlx5e_test_loopback
+#ifdef CONFIG_INET
+	mlx5e_test_loopback,
+#endif
 };
 
 void mlx5e_self_test(struct net_device *ndev, struct ethtool_test *etest,
-- 
2.9.0
