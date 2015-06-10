From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 02/13] net/mlx4_core: Reset counters data when freed
Date: Wed, 10 Jun 2015 17:59:27 +0300
Message-ID: <1433948378-17570-3-git-send-email-ogerlitz@mellanox.com>
References: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37790 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933140AbbFJPAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 11:00:21 -0400
In-Reply-To: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Add resetting the counter data to the free counter flow, so the counter's
data won't be accessible anymore if querying the counter. Also, on next
counter allocation (to another VM for example), it will be fresh and clear.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   21 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |    2 ++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index f95466f..11f5568 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2242,11 +2242,32 @@ int mlx4_counter_alloc(struct mlx4_dev *dev, u32 *idx)
 }
 EXPORT_SYMBOL_GPL(mlx4_counter_alloc);
 
+static int __mlx4_clear_if_stat(struct mlx4_dev *dev,
+				u8 counter_index)
+{
+	struct mlx4_cmd_mailbox *if_stat_mailbox;
+	int err;
+	u32 if_stat_in_mod = (counter_index & 0xff) | MLX4_QUERY_IF_STAT_RESET;
+
+	if_stat_mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(if_stat_mailbox))
+		return PTR_ERR(if_stat_mailbox);
+
+	err = mlx4_cmd_box(dev, 0, if_stat_mailbox->dma, if_stat_in_mod, 0,
+			   MLX4_CMD_QUERY_IF_STAT, MLX4_CMD_TIME_CLASS_C,
+			   MLX4_CMD_NATIVE);
+
+	mlx4_free_cmd_mailbox(dev, if_stat_mailbox);
+	return err;
+}
+
 void __mlx4_counter_free(struct mlx4_dev *dev, u32 idx)
 {
 	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_COUNTERS))
 		return;
 
+	__mlx4_clear_if_stat(dev, idx);
+
 	mlx4_bitmap_free(&mlx4_priv(dev)->counters_bitmap, idx, MLX4_USE_RR);
 	return;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index f424900..8d2d359 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -65,6 +65,8 @@
 
 #define INIT_HCA_TPT_MW_ENABLE          (1 << 7)
 
+#define MLX4_QUERY_IF_STAT_RESET	BIT(31)
+
 enum {
 	MLX4_HCR_BASE		= 0x80680,
 	MLX4_HCR_SIZE		= 0x0001c,
-- 
1.7.1
