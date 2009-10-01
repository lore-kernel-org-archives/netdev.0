From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 1/7] mlx4: Added interrupts test support
Date: Thu, 01 Oct 2009 16:32:58 +0200
Message-ID: <4AC4BD9A.2050101@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:60171 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756358AbZJALe6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 07:34:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A test that verifies that we can accept interrupts on all
the irq vectors of the device.
Interrupts are checked using the NOP command.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/eq.c       |   44 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/mlx4/device.h |    1 +
 2 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index bffb799..81619a1 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -698,3 +698,47 @@ void mlx4_cleanup_eq_table(struct mlx4_dev *dev)
 
 	kfree(priv->eq_table.uar_map);
 }
+
+/* A test that verifies that we can accept interrupts on all
+ * the irq vectors of the device.
+ * Interrupts are checked using the NOP command.
+ */
+int mlx4_test_interrupts(struct mlx4_dev *dev)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int i;
+	int err;
+
+	err = mlx4_NOP(dev);
+	/* When not in MSI_X, there is only one irq to check */
+	if (!(dev->flags & MLX4_FLAG_MSI_X))
+		return err;
+
+	/* A loop over all completion vectors, for each vector we will check
+	 * whether it works by mapping command completions to that vector
+	 * and performing a NOP command
+	 */
+	for (i = 0; !err && (i < dev->caps.num_comp_vectors); ++i) {
+		/* Temporary use polling for command completions */
+		mlx4_cmd_use_polling(dev);
+
+		/* Map the new eq to handle all asyncronous events */
+		err = mlx4_MAP_EQ(dev, MLX4_ASYNC_EVENT_MASK, 0,
+				  priv->eq_table.eq[i].eqn);
+		if (err) {
+			mlx4_warn(dev, "Failed mapping eq for interrupt test\n");
+			mlx4_cmd_use_events(dev);
+			break;
+		}
+
+		/* Go back to using events */
+		mlx4_cmd_use_events(dev);
+		err = mlx4_NOP(dev);
+	}
+
+	/* Return to default */
+	mlx4_MAP_EQ(dev, MLX4_ASYNC_EVENT_MASK, 0,
+		    priv->eq_table.eq[dev->caps.num_comp_vectors].eqn);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_test_interrupts);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index ce7cc6c..e27a68d 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -480,4 +480,5 @@ void mlx4_fmr_unmap(struct mlx4_dev *dev, struct mlx4_fmr *fmr,
 int mlx4_fmr_free(struct mlx4_dev *dev, struct mlx4_fmr *fmr);
 int mlx4_SYNC_TPT(struct mlx4_dev *dev);
 
+int mlx4_test_interrupts(struct mlx4_dev *dev);
 #endif /* MLX4_DEVICE_H */
-- 
1.6.1.3

