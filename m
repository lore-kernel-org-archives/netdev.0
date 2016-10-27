From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 08/10] net/mlx4: Fix firmware command timeout during interrupt test
Date: Thu, 27 Oct 2016 16:27:20 +0300
Message-ID: <1477574842-29688-9-git-send-email-tariqt@mellanox.com>
References: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57534 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941564AbcJ0NyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:54:22 -0400
In-Reply-To: <1477574842-29688-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Currently interrupt test that is part of ethtool selftest runs the
check over all interrupt vectors of the device.
In mlx4_en package part of interrupt vectors are uninitialized since
mlx4_ib doesn't exist. This causes NOP FW command to time out.
Change logic to test current port interrupt vectors only.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c | 26 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/eq.c          | 62 +++++++++++-------------
 include/linux/mlx4/device.h                      |  3 +-
 3 files changed, 55 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index b66e03d9711f..c06346a82496 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -118,6 +118,29 @@ static int mlx4_en_test_loopback(struct mlx4_en_priv *priv)
 	return !loopback_ok;
 }
 
+static int mlx4_en_test_interrupts(struct mlx4_en_priv *priv)
+{
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int err = 0;
+	int i = 0;
+
+	err = mlx4_test_async(mdev->dev);
+	/* When not in MSI_X or slave, test only async */
+	if (!(mdev->dev->flags & MLX4_FLAG_MSI_X) || mlx4_is_slave(mdev->dev))
+		return err;
+
+	/* A loop over all completion vectors of current port,
+	 * for each vector check whether it works by mapping command
+	 * completions to that vector and performing a NOP command
+	 */
+	for (i = 0; i < priv->rx_ring_num; i++) {
+		err = mlx4_test_interrupt(mdev->dev, priv->rx_cq[i]->vector);
+		if (err)
+			break;
+	}
+
+	return err;
+}
 
 static int mlx4_en_test_link(struct mlx4_en_priv *priv)
 {
@@ -151,7 +174,6 @@ static int mlx4_en_test_speed(struct mlx4_en_priv *priv)
 void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;
 	int i, carrier_ok;
 
 	memset(buf, 0, sizeof(u64) * MLX4_EN_NUM_SELF_TEST);
@@ -177,7 +199,7 @@ void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf)
 			netif_carrier_on(dev);
 
 	}
-	buf[0] = mlx4_test_interrupts(mdev->dev);
+	buf[0] = mlx4_en_test_interrupts(priv);
 	buf[1] = mlx4_en_test_link(priv);
 	buf[2] = mlx4_en_test_speed(priv);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index cf8f8a72a801..cd3638e6fe25 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -1361,53 +1361,49 @@ void mlx4_cleanup_eq_table(struct mlx4_dev *dev)
 	kfree(priv->eq_table.uar_map);
 }
 
-/* A test that verifies that we can accept interrupts on all
- * the irq vectors of the device.
+/* A test that verifies that we can accept interrupts
+ * on the vector allocated for asynchronous events
+ */
+int mlx4_test_async(struct mlx4_dev *dev)
+{
+	return mlx4_NOP(dev);
+}
+EXPORT_SYMBOL(mlx4_test_async);
+
+/* A test that verifies that we can accept interrupts
+ * on the given irq vector of the tested port.
  * Interrupts are checked using the NOP command.
  */
-int mlx4_test_interrupts(struct mlx4_dev *dev)
+int mlx4_test_interrupt(struct mlx4_dev *dev, int vector)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	int i;
 	int err;
 
-	err = mlx4_NOP(dev);
-	/* When not in MSI_X, there is only one irq to check */
-	if (!(dev->flags & MLX4_FLAG_MSI_X) || mlx4_is_slave(dev))
-		return err;
-
-	/* A loop over all completion vectors, for each vector we will check
-	 * whether it works by mapping command completions to that vector
-	 * and performing a NOP command
-	 */
-	for(i = 0; !err && (i < dev->caps.num_comp_vectors); ++i) {
-		/* Make sure request_irq was called */
-		if (!priv->eq_table.eq[i].have_irq)
-			continue;
-
-		/* Temporary use polling for command completions */
-		mlx4_cmd_use_polling(dev);
-
-		/* Map the new eq to handle all asynchronous events */
-		err = mlx4_MAP_EQ(dev, get_async_ev_mask(dev), 0,
-				  priv->eq_table.eq[i].eqn);
-		if (err) {
-			mlx4_warn(dev, "Failed mapping eq for interrupt test\n");
-			mlx4_cmd_use_events(dev);
-			break;
-		}
+	/* Temporary use polling for command completions */
+	mlx4_cmd_use_polling(dev);
 
-		/* Go back to using events */
-		mlx4_cmd_use_events(dev);
-		err = mlx4_NOP(dev);
+	/* Map the new eq to handle all asynchronous events */
+	err = mlx4_MAP_EQ(dev, get_async_ev_mask(dev), 0,
+			  priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(vector)].eqn);
+	if (err) {
+		mlx4_warn(dev, "Failed mapping eq for interrupt test\n");
+		goto out;
 	}
 
+	/* Go back to using events */
+	mlx4_cmd_use_events(dev);
+	err = mlx4_NOP(dev);
+
 	/* Return to default */
+	mlx4_cmd_use_polling(dev);
+out:
 	mlx4_MAP_EQ(dev, get_async_ev_mask(dev), 0,
 		    priv->eq_table.eq[MLX4_EQ_ASYNC].eqn);
+	mlx4_cmd_use_events(dev);
+
 	return err;
 }
-EXPORT_SYMBOL(mlx4_test_interrupts);
+EXPORT_SYMBOL(mlx4_test_interrupt);
 
 bool mlx4_is_eq_vector_valid(struct mlx4_dev *dev, u8 port, int vector)
 {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index f6a164297358..3be7abd6e722 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1399,7 +1399,8 @@ void mlx4_fmr_unmap(struct mlx4_dev *dev, struct mlx4_fmr *fmr,
 		    u32 *lkey, u32 *rkey);
 int mlx4_fmr_free(struct mlx4_dev *dev, struct mlx4_fmr *fmr);
 int mlx4_SYNC_TPT(struct mlx4_dev *dev);
-int mlx4_test_interrupts(struct mlx4_dev *dev);
+int mlx4_test_interrupt(struct mlx4_dev *dev, int vector);
+int mlx4_test_async(struct mlx4_dev *dev);
 int mlx4_query_diag_counters(struct mlx4_dev *dev, u8 op_modifier,
 			     const u32 offset[], u32 value[],
 			     size_t array_len, u8 port);
-- 
1.8.3.1
