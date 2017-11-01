From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 4/9] net: hns3: Add support for misc interrupt
Date: Wed, 1 Nov 2017 22:47:17 +0800
Message-ID: <1509547642-51110-5-git-send-email-lipeng321@huawei.com>
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

This patch adds initialization and deinitialization for misc interrupt.
This interrupt will be used to handle reset message(IRQ).

Signed-off-by: qumingguang <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  5 ++
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 74 ++++++++++++++++++++++
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |  2 +
 3 files changed, 81 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index 6bdc216..db4d887 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -63,6 +63,11 @@ enum hclge_cmd_status {
 	HCLGE_ERR_CSQ_ERROR	= -3,
 };
 
+struct hclge_misc_vector {
+	u8 __iomem *addr;
+	int vector_irq;
+};
+
 struct hclge_cmq {
 	struct hclge_cmq_ring csq;
 	struct hclge_cmq_ring crq;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index a7686fe..7558cfb 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -2392,11 +2392,71 @@ static void hclge_service_complete(struct hclge_dev *hdev)
 	clear_bit(HCLGE_STATE_SERVICE_SCHED, &hdev->state);
 }
 
+static irqreturn_t hclge_misc_irq_handle(int irq, void *data)
+{
+	struct hclge_dev *hdev = data;
+
+	hclge_enable_vector(&hdev->misc_vector, false);
+	if (!test_and_set_bit(HCLGE_STATE_SERVICE_SCHED, &hdev->state))
+		schedule_work(&hdev->service_task);
+
+	return IRQ_HANDLED;
+}
+
+static void hclge_free_vector(struct hclge_dev *hdev, int vector_id)
+{
+	hdev->vector_status[vector_id] = HCLGE_INVALID_VPORT;
+	hdev->num_msi_left += 1;
+	hdev->num_msi_used -= 1;
+}
+
+static void hclge_get_misc_vector(struct hclge_dev *hdev)
+{
+	struct hclge_misc_vector *vector = &hdev->misc_vector;
+
+	vector->vector_irq = pci_irq_vector(hdev->pdev, 0);
+
+	vector->addr = hdev->hw.io_base + HCLGE_MISC_VECTOR_REG_BASE;
+	hdev->vector_status[0] = 0;
+
+	hdev->num_msi_left -= 1;
+	hdev->num_msi_used += 1;
+}
+
+static int hclge_misc_irq_init(struct hclge_dev *hdev)
+{
+	int ret;
+
+	hclge_get_misc_vector(hdev);
+
+	ret = devm_request_irq(&hdev->pdev->dev,
+			       hdev->misc_vector.vector_irq,
+			       hclge_misc_irq_handle, 0, "hclge_misc", hdev);
+	if (ret) {
+		hclge_free_vector(hdev, 0);
+		dev_err(&hdev->pdev->dev, "request misc irq(%d) fail\n",
+			hdev->misc_vector.vector_irq);
+	}
+
+	return ret;
+}
+
+void hclge_enable_vector(struct hclge_misc_vector *vector, bool enable)
+{
+	writel(enable, vector->addr);
+}
+
+static void hclge_misc_irq_service_task(struct hclge_dev *hdev)
+{
+	hclge_enable_vector(&hdev->misc_vector, true);
+}
+
 static void hclge_service_task(struct work_struct *work)
 {
 	struct hclge_dev *hdev =
 		container_of(work, struct hclge_dev, service_task);
 
+	hclge_misc_irq_service_task(hdev);
 	hclge_update_speed_duplex(hdev);
 	hclge_update_link_status(hdev);
 	hclge_update_stats_for_all(hdev);
@@ -4480,6 +4540,14 @@ static int hclge_init_ae_dev(struct hnae3_ae_dev *ae_dev)
 		return ret;
 	}
 
+	ret = hclge_misc_irq_init(hdev);
+	if (ret) {
+		dev_err(&pdev->dev,
+			"Misc IRQ(vector0) init error, ret = %d.\n",
+			ret);
+		return ret;
+	}
+
 	ret = hclge_alloc_tqps(hdev);
 	if (ret) {
 		dev_err(&pdev->dev, "Allocate TQPs error, ret = %d.\n", ret);
@@ -4545,6 +4613,9 @@ static int hclge_init_ae_dev(struct hnae3_ae_dev *ae_dev)
 	timer_setup(&hdev->service_timer, hclge_service_timer, 0);
 	INIT_WORK(&hdev->service_task, hclge_service_task);
 
+	/* Enable MISC vector(vector0) */
+	hclge_enable_vector(&hdev->misc_vector, true);
+
 	set_bit(HCLGE_STATE_SERVICE_INITED, &hdev->state);
 	set_bit(HCLGE_STATE_DOWN, &hdev->state);
 
@@ -4577,6 +4648,9 @@ static void hclge_uninit_ae_dev(struct hnae3_ae_dev *ae_dev)
 	if (mac->phydev)
 		mdiobus_unregister(mac->mdio_bus);
 
+	/* Disable MISC vector(vector0) */
+	hclge_enable_vector(&hdev->misc_vector, false);
+	hclge_free_vector(hdev, 0);
 	hclge_destroy_cmd_queue(&hdev->hw);
 	hclge_pci_uninit(hdev);
 	ae_dev->priv = NULL;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
index bca4430..2a1d4d6 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
@@ -27,6 +27,7 @@
 	(HCLGE_PF_CFG_BLOCK_SIZE / HCLGE_CFG_RD_LEN_BYTES)
 
 #define HCLGE_VECTOR_REG_BASE		0x20000
+#define HCLGE_MISC_VECTOR_REG_BASE	0x20400
 
 #define HCLGE_VECTOR_REG_OFFSET		0x4
 #define HCLGE_VECTOR_VF_OFFSET		0x100000
@@ -400,6 +401,7 @@ struct hclge_dev {
 	struct pci_dev *pdev;
 	struct hnae3_ae_dev *ae_dev;
 	struct hclge_hw hw;
+	struct hclge_misc_vector misc_vector;
 	struct hclge_hw_stats hw_stats;
 	unsigned long state;
 
-- 
1.9.1
