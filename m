From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 3/9] net: hns3: Refactor the initialization of command queue
Date: Wed, 1 Nov 2017 22:47:16 +0800
Message-ID: <1509547642-51110-4-git-send-email-lipeng321@huawei.com>
References: <1509547642-51110-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509547642-51110-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: qumingguang <qumingguang@huawei.com>

There is no necessary to reallocate the descriptor and remap the descriptor
memory in reset process, But there is still some other action exit in both
reset process and initialization process.

To reuse the common interface of reset process and initialization process,
This patch moved out the descriptor allocate and memory maping from
interface cmdq_init.

Signed-off-by: qumingguang <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c | 39 +++++++++++++---------
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  1 +
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    |  9 ++++-
 3 files changed, 33 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
index 60960e5..ff13d18 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
@@ -62,7 +62,7 @@ static void hclge_free_cmd_desc(struct hclge_cmq_ring *ring)
 	ring->desc = NULL;
 }
 
-static int hclge_init_cmd_queue(struct hclge_dev *hdev, int ring_type)
+static int hclge_alloc_cmd_queue(struct hclge_dev *hdev, int ring_type)
 {
 	struct hclge_hw *hw = &hdev->hw;
 	struct hclge_cmq_ring *ring =
@@ -79,9 +79,6 @@ static int hclge_init_cmd_queue(struct hclge_dev *hdev, int ring_type)
 		return ret;
 	}
 
-	ring->next_to_clean = 0;
-	ring->next_to_use = 0;
-
 	return 0;
 }
 
@@ -302,37 +299,52 @@ static enum hclge_cmd_status hclge_cmd_query_firmware_version(
 	return ret;
 }
 
-int hclge_cmd_init(struct hclge_dev *hdev)
+int hclge_cmd_queue_init(struct hclge_dev *hdev)
 {
-	u32 version;
 	int ret;
 
 	/* Setup the queue entries for use cmd queue */
 	hdev->hw.cmq.csq.desc_num = HCLGE_NIC_CMQ_DESC_NUM;
 	hdev->hw.cmq.crq.desc_num = HCLGE_NIC_CMQ_DESC_NUM;
 
-	/* Setup the lock for command queue */
-	spin_lock_init(&hdev->hw.cmq.csq.lock);
-	spin_lock_init(&hdev->hw.cmq.crq.lock);
-
 	/* Setup Tx write back timeout */
 	hdev->hw.cmq.tx_timeout = HCLGE_CMDQ_TX_TIMEOUT;
 
 	/* Setup queue rings */
-	ret = hclge_init_cmd_queue(hdev, HCLGE_TYPE_CSQ);
+	ret = hclge_alloc_cmd_queue(hdev, HCLGE_TYPE_CSQ);
 	if (ret) {
 		dev_err(&hdev->pdev->dev,
 			"CSQ ring setup error %d\n", ret);
 		return ret;
 	}
 
-	ret = hclge_init_cmd_queue(hdev, HCLGE_TYPE_CRQ);
+	ret = hclge_alloc_cmd_queue(hdev, HCLGE_TYPE_CRQ);
 	if (ret) {
 		dev_err(&hdev->pdev->dev,
 			"CRQ ring setup error %d\n", ret);
 		goto err_csq;
 	}
 
+	return 0;
+err_csq:
+	hclge_free_cmd_desc(&hdev->hw.cmq.csq);
+	return ret;
+}
+
+int hclge_cmd_init(struct hclge_dev *hdev)
+{
+	u32 version;
+	int ret;
+
+	hdev->hw.cmq.csq.next_to_clean = 0;
+	hdev->hw.cmq.csq.next_to_use = 0;
+	hdev->hw.cmq.crq.next_to_clean = 0;
+	hdev->hw.cmq.crq.next_to_use = 0;
+
+	/* Setup the lock for command queue */
+	spin_lock_init(&hdev->hw.cmq.csq.lock);
+	spin_lock_init(&hdev->hw.cmq.crq.lock);
+
 	hclge_cmd_init_regs(&hdev->hw);
 
 	ret = hclge_cmd_query_firmware_version(&hdev->hw, &version);
@@ -346,9 +358,6 @@ int hclge_cmd_init(struct hclge_dev *hdev)
 	dev_info(&hdev->pdev->dev, "The firmware version is %08x\n", version);
 
 	return 0;
-err_csq:
-	hclge_free_cmd_desc(&hdev->hw.cmq.csq);
-	return ret;
 }
 
 static void hclge_destroy_queue(struct hclge_cmq_ring *ring)
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index b437334..6bdc216 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -750,4 +750,5 @@ enum hclge_cmd_status hclge_cmd_mdio_read(struct hclge_hw *hw,
 					  struct hclge_desc *desc);
 
 void hclge_destroy_cmd_queue(struct hclge_hw *hw);
+int hclge_cmd_queue_init(struct hclge_dev *hdev);
 #endif
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 4ef4592..a7686fe 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -4446,7 +4446,14 @@ static int hclge_init_ae_dev(struct hnae3_ae_dev *ae_dev)
 		goto err_pci_init;
 	}
 
-	/* Command queue initialize */
+	/* Firmware command queue initialize */
+	ret = hclge_cmd_queue_init(hdev);
+	if (ret) {
+		dev_err(&pdev->dev, "Cmd queue init failed\n");
+		return ret;
+	}
+
+	/* Firmware command initialize */
 	ret = hclge_cmd_init(hdev);
 	if (ret)
 		goto err_cmd_init;
-- 
1.9.1
