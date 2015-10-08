From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/7] net/mlx5_core: Use accessor functions to read from device memory
Date: Thu,  8 Oct 2015 17:13:59 +0300
Message-ID: <1444313643-15284-4-git-send-email-ogerlitz@mellanox.com>
References: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45244 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932084AbbJHOOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 10:14:30 -0400
In-Reply-To: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Use ioread function to read health buffer data. In addition, print the
firmware version as a string for readability and also use dev_err to have
the device string to be printed.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 35 +++++++++++++++---------
 1 file changed, 22 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 1277c42..8770968 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -114,32 +114,41 @@ static const char *hsynd_str(u8 synd)
 	}
 }
 
-static u16 read_be16(__be16 __iomem *p)
+static u16 get_maj(u32 fw)
 {
-	return swab16(readl((__force u16 __iomem *) p));
+	return fw >> 28;
 }
 
-static u32 read_be32(__be32 __iomem *p)
+static u16 get_min(u32 fw)
 {
-	return swab32(readl((__force u32 __iomem *) p));
+	return fw >> 16 & 0xfff;
+}
+
+static u16 get_sub(u32 fw)
+{
+	return fw & 0xffff;
 }
 
 static void print_health_info(struct mlx5_core_dev *dev)
 {
 	struct mlx5_core_health *health = &dev->priv.health;
 	struct health_buffer __iomem *h = health->health;
+	char fw_str[18];
+	u32 fw;
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(h->assert_var); i++)
-		pr_info("assert_var[%d] 0x%08x\n", i, read_be32(h->assert_var + i));
-
-	pr_info("assert_exit_ptr 0x%08x\n", read_be32(&h->assert_exit_ptr));
-	pr_info("assert_callra 0x%08x\n", read_be32(&h->assert_callra));
-	pr_info("fw_ver 0x%08x\n", read_be32(&h->fw_ver));
-	pr_info("hw_id 0x%08x\n", read_be32(&h->hw_id));
-	pr_info("irisc_index %d\n", readb(&h->irisc_index));
-	pr_info("synd 0x%x: %s\n", readb(&h->synd), hsynd_str(readb(&h->synd)));
-	pr_info("ext_sync 0x%04x\n", read_be16(&h->ext_synd));
+		dev_err(&dev->pdev->dev, "assert_var[%d] 0x%08x\n", i, ioread32be(h->assert_var + i));
+
+	dev_err(&dev->pdev->dev, "assert_exit_ptr 0x%08x\n", ioread32be(&h->assert_exit_ptr));
+	dev_err(&dev->pdev->dev, "assert_callra 0x%08x\n", ioread32be(&h->assert_callra));
+	fw = ioread32be(&h->fw_ver);
+	sprintf(fw_str, "%d.%d.%d", get_maj(fw), get_min(fw), get_sub(fw));
+	dev_err(&dev->pdev->dev, "fw_ver %s\n", fw_str);
+	dev_err(&dev->pdev->dev, "hw_id 0x%08x\n", ioread32be(&h->hw_id));
+	dev_err(&dev->pdev->dev, "irisc_index %d\n", ioread8(&h->irisc_index));
+	dev_err(&dev->pdev->dev, "synd 0x%x: %s\n", ioread8(&h->synd), hsynd_str(ioread8(&h->synd)));
+	dev_err(&dev->pdev->dev, "ext_synd 0x%04x\n", ioread16be(&h->ext_synd));
 }
 
 static void poll_health(unsigned long data)
-- 
2.3.7
