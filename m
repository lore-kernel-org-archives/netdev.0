From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net 2/9] net: hns3: Fix initialization when cmd is not supported
Date: Wed, 20 Sep 2017 18:52:51 +0800
Message-ID: <1505904778-53217-3-git-send-email-linyunsheng@huawei.com>
References: <1505904778-53217-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505904778-53217-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When ae_dev doesn't support DCB, rx_priv_wl_config,
common_thrd_config and tm_qs_bp_cfg can't be called, otherwise
cmd return fail, which causes the hclge module initialization
process to fail.
This patch fix it by adding a DCB capability flag to check if
the ae_dev support DCB.

Fixes: 46a3df9f9718 ("net: hns3: Add HNS3 Acceleration Engine & Compatibility Layer Support")
Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  7 ++++++
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 26 +++++++++++++---------
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c  |  4 ++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 10 ++++-----
 4 files changed, 31 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.h b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
index 0f7b61a..ad685f5 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hnae3.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
@@ -50,10 +50,17 @@
 
 #define HNAE3_DEV_INITED_B			0x0
 #define HNAE3_DEV_SUPPORT_ROCE_B		0x1
+#define HNAE3_DEV_SUPPORT_DCB_B			0x2
+
+#define HNAE3_DEV_SUPPORT_ROCE_DCB_BITS (BIT(HNAE3_DEV_SUPPORT_DCB_B) |\
+		BIT(HNAE3_DEV_SUPPORT_ROCE_B))
 
 #define hnae3_dev_roce_supported(hdev) \
 	hnae_get_bit(hdev->ae_dev->flag, HNAE3_DEV_SUPPORT_ROCE_B)
 
+#define hnae3_dev_dcb_supported(hdev) \
+	hnae_get_bit(hdev->ae_dev->flag, HNAE3_DEV_SUPPORT_DCB_B)
+
 #define ring_ptr_move_fw(ring, p) \
 	((ring)->p = ((ring)->p + 1) % (ring)->desc_num)
 #define ring_ptr_move_bw(ring, p) \
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index eb78c23..c515b84 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1772,18 +1772,22 @@ int hclge_buffer_alloc(struct hclge_dev *hdev)
 		return ret;
 	}
 
-	ret = hclge_rx_priv_wl_config(hdev);
-	if (ret) {
-		dev_err(&hdev->pdev->dev,
-			"could not configure rx private waterline %d\n", ret);
-		return ret;
-	}
+	if (hnae3_dev_dcb_supported(hdev)) {
+		ret = hclge_rx_priv_wl_config(hdev);
+		if (ret) {
+			dev_err(&hdev->pdev->dev,
+				"could not configure rx private waterline %d\n",
+				ret);
+			return ret;
+		}
 
-	ret = hclge_common_thrd_config(hdev);
-	if (ret) {
-		dev_err(&hdev->pdev->dev,
-			"could not configure common threshold %d\n", ret);
-		return ret;
+		ret = hclge_common_thrd_config(hdev);
+		if (ret) {
+			dev_err(&hdev->pdev->dev,
+				"could not configure common threshold %d\n",
+				ret);
+			return ret;
+		}
 	}
 
 	ret = hclge_common_wl_config(hdev);
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
index 1c577d2..c91dbf1 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
@@ -976,6 +976,10 @@ int hclge_pause_setup_hw(struct hclge_dev *hdev)
 	if (ret)
 		return ret;
 
+	/* Only DCB-supported dev supports qset back pressure setting */
+	if (!hnae3_dev_dcb_supported(hdev))
+		return 0;
+
 	for (i = 0; i < hdev->tm_info.num_tc; i++) {
 		ret = hclge_tm_qs_bp_cfg(hdev, i);
 		if (ret)
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 94d8bb5..35369e1 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -42,15 +42,15 @@
 	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_GE), 0},
 	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE), 0},
 	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE_RDMA),
-	 BIT(HNAE3_DEV_SUPPORT_ROCE_B)},
+	 HNAE3_DEV_SUPPORT_ROCE_DCB_BITS},
 	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE_RDMA_MACSEC),
-	 BIT(HNAE3_DEV_SUPPORT_ROCE_B)},
+	 HNAE3_DEV_SUPPORT_ROCE_DCB_BITS},
 	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA),
-	 BIT(HNAE3_DEV_SUPPORT_ROCE_B)},
+	 HNAE3_DEV_SUPPORT_ROCE_DCB_BITS},
 	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA_MACSEC),
-	 BIT(HNAE3_DEV_SUPPORT_ROCE_B)},
+	 HNAE3_DEV_SUPPORT_ROCE_DCB_BITS},
 	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_100G_RDMA_MACSEC),
-	 BIT(HNAE3_DEV_SUPPORT_ROCE_B)},
+	 HNAE3_DEV_SUPPORT_ROCE_DCB_BITS},
 	/* required last entry */
 	{0, }
 };
-- 
1.9.1
