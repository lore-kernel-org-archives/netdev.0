From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 1/4] net/mlx5_core: Fix internal error detection conditions
Date: Wed, 14 Oct 2015 17:43:45 +0300
Message-ID: <1444833828-8240-2-git-send-email-ogerlitz@mellanox.com>
References: <1444833828-8240-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37099 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754018AbbJNOoN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 10:44:13 -0400
In-Reply-To: <1444833828-8240-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

The detection of a fatal condition has been updated to take into account
the state reported by the device or by detecting an all ones read of the
firmware version which indicates that the device is not accessible.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 51 ++++++++++++++++++++----
 include/linux/mlx5/driver.h                      |  1 +
 2 files changed, 45 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 9b81e1c..f1eb686 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -57,6 +57,31 @@ enum {
 	MLX5_HEALTH_SYNDR_HIGH_TEMP		= 0x10
 };
 
+enum {
+	MLX5_NIC_IFC_FULL		= 0,
+	MLX5_NIC_IFC_DISABLED		= 1,
+	MLX5_NIC_IFC_NO_DRAM_NIC	= 2
+};
+
+static u8 get_nic_interface(struct mlx5_core_dev *dev)
+{
+	return (ioread32be(&dev->iseg->cmdq_addr_l_sz) >> 8) & 3;
+}
+
+static int in_fatal(struct mlx5_core_dev *dev)
+{
+	struct mlx5_core_health *health = &dev->priv.health;
+	struct health_buffer __iomem *h = health->health;
+
+	if (get_nic_interface(dev) == MLX5_NIC_IFC_DISABLED)
+		return 1;
+
+	if (ioread32be(&h->fw_ver) == 0xffffffff)
+		return 1;
+
+	return 0;
+}
+
 static void health_care(struct work_struct *work)
 {
 	struct mlx5_core_health *health;
@@ -136,11 +161,21 @@ static void print_health_info(struct mlx5_core_dev *dev)
 	dev_err(&dev->pdev->dev, "ext_synd 0x%04x\n", ioread16be(&h->ext_synd));
 }
 
+static unsigned long get_next_poll_jiffies(void)
+{
+	unsigned long next;
+
+	get_random_bytes(&next, sizeof(next));
+	next %= HZ;
+	next += jiffies + MLX5_HEALTH_POLL_INTERVAL;
+
+	return next;
+}
+
 static void poll_health(unsigned long data)
 {
 	struct mlx5_core_dev *dev = (struct mlx5_core_dev *)data;
 	struct mlx5_core_health *health = &dev->priv.health;
-	unsigned long next;
 	u32 count;
 
 	count = ioread32be(health->health_counter);
@@ -151,14 +186,16 @@ static void poll_health(unsigned long data)
 
 	health->prev = count;
 	if (health->miss_counter == MAX_MISSES) {
-		mlx5_core_err(dev, "device's health compromised\n");
+		dev_err(&dev->pdev->dev, "device's health compromised - reached miss count\n");
 		print_health_info(dev);
-		queue_work(health->wq, &health->work);
 	} else {
-		get_random_bytes(&next, sizeof(next));
-		next %= HZ;
-		next += jiffies + MLX5_HEALTH_POLL_INTERVAL;
-		mod_timer(&health->timer, next);
+		mod_timer(&health->timer, get_next_poll_jiffies());
+	}
+
+	if (in_fatal(dev) && !health->sick) {
+		health->sick = true;
+		print_health_info(dev);
+		queue_work(health->wq, &health->work);
 	}
 }
 
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 41a3287..62b7d43 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -393,6 +393,7 @@ struct mlx5_core_health {
 	struct timer_list		timer;
 	u32				prev;
 	int				miss_counter;
+	bool				sick;
 	struct workqueue_struct	       *wq;
 	struct work_struct		work;
 };
-- 
2.3.7
