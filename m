From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 1/8] net: hns3: add check when initialize
Date: Thu, 31 Aug 2017 21:39:02 +0800
Message-ID: <1504186749-8926-2-git-send-email-lipeng321@huawei.com>
References: <1504186749-8926-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504186749-8926-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

private waterline and and common packet buffer

Command HCLGE_OPC_RX_PRIV_WL_ALLOC configure waterline for TC's PFC,
which has private buffer.Command HCLGE_OPC_RX_COM_THRD_ALLOC Control
each TC's occupation in common packet buffer, also generate PFC for
TC, which has not private buffer.When device do not support DCB,
command HCLGE_OPC_RX_PRIV_WL_ALLOC and HCLGE_OPC_RX_COM_THRD_ALLOC
should not be used.

The current code does not support DCB feature, DCB feature will be added
later. The current code works well if device support DCB though it do
not enable DCB feature, but it works fail if device do not support DCB.

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  1 +
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 41 ++++++++++++++++------
 2 files changed, 31 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.h b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
index b2f28ae..e23e028 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hnae3.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
@@ -50,6 +50,7 @@
 
 #define HNAE3_DEV_INITED_B			0x0
 #define HNAE_DEV_SUPPORT_ROCE_B			0x1
+#define HNAE_DEV_SUPPORT_DCB_B			0x2
 
 #define ring_ptr_move_fw(ring, p) \
 	((ring)->p = ((ring)->p + 1) % (ring)->desc_num)
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index bb45365..acc4016 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -60,6 +60,16 @@ static int hclge_set_mta_filter_mode(struct hclge_dev *hdev,
 	{0, }
 };
 
+static const struct pci_device_id dcb_pci_tbl[] = {
+	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE_RDMA), 0},
+	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE_RDMA_MACSEC), 0},
+	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA), 0},
+	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA_MACSEC), 0},
+	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_100G_RDMA_MACSEC), 0},
+	/* Required last entry */
+	{0, }
+};
+
 static const char hns3_nic_test_strs[][ETH_GSTRING_LEN] = {
 	"Mac    Loopback test",
 	"Serdes Loopback test",
@@ -1782,18 +1792,23 @@ int hclge_buffer_alloc(struct hclge_dev *hdev)
 		return ret;
 	}
 
-	ret = hclge_rx_priv_wl_config(hdev);
-	if (ret) {
-		dev_err(&hdev->pdev->dev,
-			"could not configure rx private waterline %d\n", ret);
-		return ret;
-	}
+	if (hnae_get_bit(hdev->ae_dev->flag,
+			 HNAE_DEV_SUPPORT_DCB_B)) {
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
@@ -4076,6 +4091,10 @@ static int hclge_init_ae_dev(struct hnae3_ae_dev *ae_dev)
 	if (id)
 		hnae_set_bit(ae_dev->flag, HNAE_DEV_SUPPORT_ROCE_B, 1);
 
+	id = pci_match_id(dcb_pci_tbl, ae_dev->pdev);
+	if (id)
+		hnae_set_bit(ae_dev->flag, HNAE_DEV_SUPPORT_DCB_B, 1);
+
 	ret = hclge_pci_init(hdev);
 	if (ret) {
 		dev_err(&pdev->dev, "PCI init failed\n");
-- 
1.9.1
