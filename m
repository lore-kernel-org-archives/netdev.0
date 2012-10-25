From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/3] net/mlx4_core: Unmap UAR also in the case of error flow
Date: Thu, 25 Oct 2012 13:12:49 +0200
Message-ID: <1351163569-17132-4-git-send-email-ogerlitz@mellanox.com>
References: <1351163569-17132-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Dotan Barak <dotanb@dev.mellanox.co.il>,
	Uri Habusha <urih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:40824 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933181Ab2JYLM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 07:12:59 -0400
In-Reply-To: <1351163569-17132-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dotan Barak <dotanb@dev.mellanox.co.il>

If a failure takes place during the EQ creation, we need to unmap the
UAR memory block too.

Signed-off-by: Dotan Barak <dotanb@dev.mellanox.co.il>
Signed-off-by: Uri Habusha <urih@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 51c7649..083767b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -843,6 +843,18 @@ static void __iomem *mlx4_get_eq_uar(struct mlx4_dev *dev, struct mlx4_eq *eq)
 	return priv->eq_table.uar_map[index] + 0x800 + 8 * (eq->eqn % 4);
 }
 
+static void mlx4_unmap_uar(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int i;
+
+	for (i = 0; i < mlx4_num_eq_uar(dev); ++i)
+		if (priv->eq_table.uar_map[i]) {
+			iounmap(priv->eq_table.uar_map[i]);
+			priv->eq_table.uar_map[i] = NULL;
+		}
+}
+
 static int mlx4_create_eq(struct mlx4_dev *dev, int nent,
 			  u8 intr, struct mlx4_eq *eq)
 {
@@ -1207,6 +1219,7 @@ err_out_unmap:
 	mlx4_free_irqs(dev);
 
 err_out_bitmap:
+	mlx4_unmap_uar(dev);
 	mlx4_bitmap_cleanup(&priv->eq_table.bitmap);
 
 err_out_free:
@@ -1231,10 +1244,7 @@ void mlx4_cleanup_eq_table(struct mlx4_dev *dev)
 	if (!mlx4_is_slave(dev))
 		mlx4_unmap_clr_int(dev);
 
-	for (i = 0; i < mlx4_num_eq_uar(dev); ++i)
-		if (priv->eq_table.uar_map[i])
-			iounmap(priv->eq_table.uar_map[i]);
-
+	mlx4_unmap_uar(dev);
 	mlx4_bitmap_cleanup(&priv->eq_table.bitmap);
 
 	kfree(priv->eq_table.uar_map);
-- 
1.7.1
