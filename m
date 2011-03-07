From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 08/17] mlx4_en: Reporting HW revision in ethtool -i
Date: Mon, 7 Mar 2011 12:17:24 +0200
Message-ID: <4D74B0B4.9010502@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:40319 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755776Ab1CGKRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 05:17:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


HW revision is derived from device ID and rev id.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/infiniband/hw/mlx4/main.c |    1 -
 drivers/net/mlx4/en_ethtool.c     |   15 ++++++++++++++-
 drivers/net/mlx4/main.c           |    2 ++
 drivers/net/mlx4/mlx4_en.h        |    3 +++
 include/linux/mlx4/device.h       |    2 +-
 5 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index c7a6213..66e3eec 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -721,7 +721,6 @@ static int init_node_data(struct mlx4_ib_dev *dev)
 	if (err)
 		goto out;
 
-	dev->dev->rev_id = be32_to_cpup((__be32 *) (out_mad->data + 32));
 	memcpy(&dev->ib_dev.node_guid, out_mad->data + 12, 8);
 
 out:
diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index c1f351f..62ace6c 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -45,7 +45,20 @@ mlx4_en_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 
-	sprintf(drvinfo->driver, DRV_NAME " (%s)", mdev->dev->board_id);
+	switch (mdev->dev->rev_id) {
+	case 0xa0:
+		if (dev->dev_id >= MLX4_EN_CX3_LOW_ID && dev->dev_id <= MLX4_EN_CX3_HIGH_ID)
+			sprintf(drvinfo->driver, DRV_NAME " (%s_CX-3)", mdev->dev->board_id);
+		else
+			sprintf(drvinfo->driver, DRV_NAME " (%s_CX)", mdev->dev->board_id);
+		break;
+	case 0xb0:
+		sprintf(drvinfo->driver, DRV_NAME " (%s_CX-2)", mdev->dev->board_id);
+		break;
+	default:
+		sprintf(drvinfo->driver, DRV_NAME " (%s)", mdev->dev->board_id);
+		break;
+	}
 	strncpy(drvinfo->version, DRV_VERSION " (" DRV_RELDATE ")", 32);
 	sprintf(drvinfo->fw_version, "%d.%d.%d",
 		(u16) (mdev->dev->caps.fw_ver >> 32),
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 42d4fb4..5bebb88 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -1139,6 +1139,8 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	INIT_LIST_HEAD(&priv->pgdir_list);
 	mutex_init(&priv->pgdir_mutex);
 
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &dev->rev_id);
+
 	/*
 	 * Now reset the HCA before we touch the PCI capabilities or
 	 * attempt a firmware command, since a boot ROM may have left
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 07aea8d..ad4df66 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -216,6 +216,9 @@ struct mlx4_en_tx_desc {
 
 #define MLX4_EN_USE_SRQ		0x01000000
 
+#define MLX4_EN_CX3_LOW_ID	0x1000
+#define MLX4_EN_CX3_HIGH_ID	0x1005
+
 struct mlx4_en_rx_alloc {
 	struct page *page;
 	u16 offset;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 2460356..fe2a3a3 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -422,7 +422,7 @@ struct mlx4_dev {
 	unsigned long		flags;
 	struct mlx4_caps	caps;
 	struct radix_tree_root	qp_table_tree;
-	u32			rev_id;
+	u8			rev_id;
 	char			board_id[MLX4_BOARD_ID_LEN];
 };
 
-- 
1.6.0.2




