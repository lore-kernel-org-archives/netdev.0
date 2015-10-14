From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 3/4] net/mlx5_core: Wait for FW readiness on startup
Date: Wed, 14 Oct 2015 17:43:47 +0300
Message-ID: <1444833828-8240-4-git-send-email-ogerlitz@mellanox.com>
References: <1444833828-8240-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37122 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753193AbbJNOoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 10:44:34 -0400
In-Reply-To: <1444833828-8240-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

On device initialization, wait till firmware indicates that that it is done
with initialization before proceeding to initialize the device.

Also update initialization segment layout to match driver/firmware
interface definitions.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 27 ++++++++++++++++++++++++++
 include/linux/mlx5/device.h                    |  3 ++-
 include/linux/mlx5/driver.h                    |  5 +++++
 3 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index a103a54..2388aec 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -39,6 +39,7 @@
 #include <linux/slab.h>
 #include <linux/io-mapping.h>
 #include <linux/interrupt.h>
+#include <linux/delay.h>
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/cq.h>
 #include <linux/mlx5/qp.h>
@@ -152,6 +153,25 @@ static struct mlx5_profile profile[] = {
 	},
 };
 
+#define FW_INIT_TIMEOUT_MILI	2000
+#define FW_INIT_WAIT_MS		2
+
+static int wait_fw_init(struct mlx5_core_dev *dev, u32 max_wait_mili)
+{
+	unsigned long end = jiffies + msecs_to_jiffies(max_wait_mili);
+	int err = 0;
+
+	while (fw_initializing(dev)) {
+		if (time_after(jiffies, end)) {
+			err = -EBUSY;
+			break;
+		}
+		msleep(FW_INIT_WAIT_MS);
+	}
+
+	return err;
+}
+
 static int set_dma_caps(struct pci_dev *pdev)
 {
 	int err;
@@ -913,6 +933,13 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 		goto out_err;
 	}
 
+	err = wait_fw_init(dev, FW_INIT_TIMEOUT_MILI);
+	if (err) {
+		dev_err(&dev->pdev->dev, "Firmware over %d MS in initializing state, aborting\n",
+			FW_INIT_TIMEOUT_MILI);
+		goto out_err;
+	}
+
 	mlx5_pagealloc_init(dev);
 
 	err = mlx5_core_enable_hca(dev);
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 2a0b956..0b473cb 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -439,7 +439,8 @@ struct mlx5_init_seg {
 	__be32			cmdq_addr_h;
 	__be32			cmdq_addr_l_sz;
 	__be32			cmd_dbell;
-	__be32			rsvd1[121];
+	__be32			rsvd1[120];
+	__be32			initializing;
 	struct health_buffer	health;
 	__be32			rsvd2[884];
 	__be32			health_counter;
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 9aba8d51..5c857f2 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -826,6 +826,11 @@ void mlx5_core_put_rsc(struct mlx5_core_rsc_common *common);
 int mlx5_query_odp_caps(struct mlx5_core_dev *dev,
 			struct mlx5_odp_caps *odp_caps);
 
+static inline int fw_initializing(struct mlx5_core_dev *dev)
+{
+	return ioread32be(&dev->iseg->initializing) >> 31;
+}
+
 static inline u32 mlx5_mkey_to_idx(u32 mkey)
 {
 	return mkey >> 8;
-- 
2.3.7
