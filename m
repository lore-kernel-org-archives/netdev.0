From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net 1/9] net: hns3: Cleanup for ROCE capability flag in ae_dev
Date: Wed, 20 Sep 2017 18:52:50 +0800
Message-ID: <1505904778-53217-2-git-send-email-linyunsheng@huawei.com>
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

This patch add the ROCE supported flag in the driver_data
field of pci_device_id, delete roce_pci_tbl and change
HNAE_DEV_SUPPORT_ROCE_B to HNAE3_DEV_SUPPORT_ROCE_B.
This cleanup is done in order to support adding capability
in pci_device_id and to fix initialization failure when
cmd is not supported.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  5 ++++-
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 25 ++++------------------
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 16 +++++++++-----
 3 files changed, 19 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.h b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
index b2f28ae..0f7b61a 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hnae3.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
@@ -49,7 +49,10 @@
 #define HNAE3_CLASS_NAME_SIZE 16
 
 #define HNAE3_DEV_INITED_B			0x0
-#define HNAE_DEV_SUPPORT_ROCE_B			0x1
+#define HNAE3_DEV_SUPPORT_ROCE_B		0x1
+
+#define hnae3_dev_roce_supported(hdev) \
+	hnae_get_bit(hdev->ae_dev->flag, HNAE3_DEV_SUPPORT_ROCE_B)
 
 #define ring_ptr_move_fw(ring, p) \
 	((ring)->p = ((ring)->p + 1) % (ring)->desc_num)
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 44c722a..eb78c23 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -46,17 +46,7 @@ static int hclge_set_mta_filter_mode(struct hclge_dev *hdev,
 	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA), 0},
 	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA_MACSEC), 0},
 	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_100G_RDMA_MACSEC), 0},
-	/* Required last entry */
-	{0, }
-};
-
-static const struct pci_device_id roce_pci_tbl[] = {
-	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE_RDMA), 0},
-	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE_RDMA_MACSEC), 0},
-	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA), 0},
-	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA_MACSEC), 0},
-	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_100G_RDMA_MACSEC), 0},
-	/* Required last entry */
+	/* required last entry */
 	{0, }
 };
 
@@ -894,7 +884,7 @@ static int hclge_query_pf_resource(struct hclge_dev *hdev)
 	hdev->num_tqps = __le16_to_cpu(req->tqp_num);
 	hdev->pkt_buf_size = __le16_to_cpu(req->buf_size) << HCLGE_BUF_UNIT_S;
 
-	if (hnae_get_bit(hdev->ae_dev->flag, HNAE_DEV_SUPPORT_ROCE_B)) {
+	if (hnae3_dev_roce_supported(hdev)) {
 		hdev->num_roce_msix =
 		hnae_get_field(__le16_to_cpu(req->pf_intr_vector_number),
 			       HCLGE_PF_VEC_NUM_M, HCLGE_PF_VEC_NUM_S);
@@ -3931,8 +3921,7 @@ static int hclge_init_client_instance(struct hnae3_client *client,
 				goto err;
 
 			if (hdev->roce_client &&
-			    hnae_get_bit(hdev->ae_dev->flag,
-					 HNAE_DEV_SUPPORT_ROCE_B)) {
+			    hnae3_dev_roce_supported(hdev)) {
 				struct hnae3_client *rc = hdev->roce_client;
 
 				ret = hclge_init_roce_base_info(vport);
@@ -3955,8 +3944,7 @@ static int hclge_init_client_instance(struct hnae3_client *client,
 
 			break;
 		case HNAE3_CLIENT_ROCE:
-			if (hnae_get_bit(hdev->ae_dev->flag,
-					 HNAE_DEV_SUPPORT_ROCE_B)) {
+			if (hnae3_dev_roce_supported(hdev)) {
 				hdev->roce_client = client;
 				vport->roce.client = client;
 			}
@@ -4068,7 +4056,6 @@ static void hclge_pci_uninit(struct hclge_dev *hdev)
 static int hclge_init_ae_dev(struct hnae3_ae_dev *ae_dev)
 {
 	struct pci_dev *pdev = ae_dev->pdev;
-	const struct pci_device_id *id;
 	struct hclge_dev *hdev;
 	int ret;
 
@@ -4083,10 +4070,6 @@ static int hclge_init_ae_dev(struct hnae3_ae_dev *ae_dev)
 	hdev->ae_dev = ae_dev;
 	ae_dev->priv = hdev;
 
-	id = pci_match_id(roce_pci_tbl, ae_dev->pdev);
-	if (id)
-		hnae_set_bit(ae_dev->flag, HNAE_DEV_SUPPORT_ROCE_B, 1);
-
 	ret = hclge_pci_init(hdev);
 	if (ret) {
 		dev_err(&pdev->dev, "PCI init failed\n");
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 4d68d6e..94d8bb5 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -41,11 +41,16 @@
 static const struct pci_device_id hns3_pci_tbl[] = {
 	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_GE), 0},
 	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE), 0},
-	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE_RDMA), 0},
-	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE_RDMA_MACSEC), 0},
-	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA), 0},
-	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA_MACSEC), 0},
-	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_100G_RDMA_MACSEC), 0},
+	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE_RDMA),
+	 BIT(HNAE3_DEV_SUPPORT_ROCE_B)},
+	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE_RDMA_MACSEC),
+	 BIT(HNAE3_DEV_SUPPORT_ROCE_B)},
+	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA),
+	 BIT(HNAE3_DEV_SUPPORT_ROCE_B)},
+	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA_MACSEC),
+	 BIT(HNAE3_DEV_SUPPORT_ROCE_B)},
+	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_100G_RDMA_MACSEC),
+	 BIT(HNAE3_DEV_SUPPORT_ROCE_B)},
 	/* required last entry */
 	{0, }
 };
@@ -1348,6 +1353,7 @@ static int hns3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	ae_dev->pdev = pdev;
+	ae_dev->flag = ent->driver_data;
 	ae_dev->dev_type = HNAE3_DEV_KNIC;
 	pci_set_drvdata(pdev, ae_dev);
 
-- 
1.9.1
