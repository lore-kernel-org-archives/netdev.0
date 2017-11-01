From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 5/9] net: hns3: Add reset process in hclge_main
Date: Wed, 1 Nov 2017 22:47:18 +0800
Message-ID: <1509547642-51110-6-git-send-email-lipeng321@huawei.com>
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

This patch add reset support for PF,It include : global reset, core reset,
IMP reset, PF reset.The core reset will Reset all datapath of all functions
except IMP, MAC and PCI interface. Global reset is equal with the core
reset plus all MAC reset. IMP reset is caused by watchdog timer expiration,
the same range with core reset. PF reset will reset whole physical
function.

Signed-off-by: qumingguang <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hnae3.h        |  19 ++
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |   7 +
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 295 ++++++++++++++++++++-
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |  16 +-
 4 files changed, 332 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.h b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
index 3acd8db..5fc8c97 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hnae3.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hnae3.h
@@ -110,6 +110,21 @@ enum hnae3_media_type {
 	HNAE3_MEDIA_TYPE_BACKPLANE,
 };
 
+enum hnae3_reset_notify_type {
+	HNAE3_DOWN_CLIENT,
+	HNAE3_INIT_CLIENT,
+	HNAE3_UNINIT_CLIENT,
+	HNAE3_UP_CLIENT,
+};
+
+enum hnae3_reset_type {
+	HNAE3_FUNC_RESET,
+	HNAE3_CORE_RESET,
+	HNAE3_GLOBAL_RESET,
+	HNAE3_IMP_RESET,
+	HNAE3_NONE_RESET,
+};
+
 struct hnae3_vector_info {
 	u8 __iomem *io_addr;
 	int vector;
@@ -133,6 +148,8 @@ struct hnae3_client_ops {
 	void (*uninit_instance)(struct hnae3_handle *handle, bool reset);
 	void (*link_status_change)(struct hnae3_handle *handle, bool state);
 	int (*setup_tc)(struct hnae3_handle *handle, u8 tc);
+	int (*reset_notify)(struct hnae3_handle *handle,
+			    enum hnae3_reset_notify_type type);
 };
 
 #define HNAE3_CLIENT_NAME_LENGTH 16
@@ -367,6 +384,8 @@ struct hnae3_ae_ops {
 			       u16 vlan_id, bool is_kill);
 	int (*set_vf_vlan_filter)(struct hnae3_handle *handle, int vfid,
 				  u16 vlan, u8 qos, __be16 proto);
+	void (*reset_event)(struct hnae3_handle *handle,
+			    enum hnae3_reset_type reset_level, u16 vfid);
 };
 
 struct hnae3_dcb_ops {
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index db4d887..844c83e 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -697,6 +697,13 @@ struct hclge_reset_tqp_queue_cmd {
 	u8 rsv[20];
 };
 
+#define HCLGE_CFG_RESET_MAC_B		3
+#define HCLGE_CFG_RESET_FUNC_B		7
+struct hclge_reset_cmd {
+	u8 mac_func_reset;
+	u8 fun_reset_vfid;
+	u8 rsv[22];
+};
 #define HCLGE_DEFAULT_TX_BUF		0x4000	 /* 16k  bytes */
 #define HCLGE_TOTAL_PKT_BUF		0x108000 /* 1.03125M bytes */
 #define HCLGE_DEFAULT_DV		0xA000	 /* 40k byte */
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 7558cfb..141c758 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -35,6 +35,7 @@ static int hclge_set_mta_filter_mode(struct hclge_dev *hdev,
 				     enum hclge_mta_dmac_sel_type mta_mac_sel,
 				     bool enable);
 static int hclge_init_vlan_config(struct hclge_dev *hdev);
+static int hclge_reset_ae_dev(struct hnae3_ae_dev *ae_dev);
 
 static struct hnae3_ae_algo ae_algo;
 
@@ -2392,6 +2393,11 @@ static void hclge_service_complete(struct hclge_dev *hdev)
 	clear_bit(HCLGE_STATE_SERVICE_SCHED, &hdev->state);
 }
 
+void hclge_enable_vector(struct hclge_misc_vector *vector, bool enable)
+{
+	writel(enable, vector->addr);
+}
+
 static irqreturn_t hclge_misc_irq_handle(int irq, void *data)
 {
 	struct hclge_dev *hdev = data;
@@ -2441,13 +2447,214 @@ static int hclge_misc_irq_init(struct hclge_dev *hdev)
 	return ret;
 }
 
-void hclge_enable_vector(struct hclge_misc_vector *vector, bool enable)
+static int hclge_notify_client(struct hclge_dev *hdev,
+			       enum hnae3_reset_notify_type type)
 {
-	writel(enable, vector->addr);
+	struct hnae3_client *client = hdev->nic_client;
+	u16 i;
+
+	if (!client->ops->reset_notify)
+		return -EOPNOTSUPP;
+
+	for (i = 0; i < hdev->num_vmdq_vport + 1; i++) {
+		struct hnae3_handle *handle = &hdev->vport[i].nic;
+		int ret;
+
+		ret = client->ops->reset_notify(handle, type);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int hclge_reset_wait(struct hclge_dev *hdev)
+{
+#define HCLGE_RESET_WATI_MS	100
+#define HCLGE_RESET_WAIT_CNT	5
+	u32 val, reg, reg_bit;
+	u32 cnt = 0;
+
+	switch (hdev->reset_type) {
+	case HNAE3_GLOBAL_RESET:
+		reg = HCLGE_GLOBAL_RESET_REG;
+		reg_bit = HCLGE_GLOBAL_RESET_BIT;
+		break;
+	case HNAE3_CORE_RESET:
+		reg = HCLGE_GLOBAL_RESET_REG;
+		reg_bit = HCLGE_CORE_RESET_BIT;
+		break;
+	case HNAE3_FUNC_RESET:
+		reg = HCLGE_FUN_RST_ING;
+		reg_bit = HCLGE_FUN_RST_ING_B;
+		break;
+	default:
+		dev_err(&hdev->pdev->dev,
+			"Wait for unsupported reset type: %d\n",
+			hdev->reset_type);
+		return -EINVAL;
+	}
+
+	val = hclge_read_dev(&hdev->hw, reg);
+	while (hnae_get_bit(val, reg_bit) && cnt < HCLGE_RESET_WAIT_CNT) {
+		msleep(HCLGE_RESET_WATI_MS);
+		val = hclge_read_dev(&hdev->hw, reg);
+		cnt++;
+	}
+
+	/* must clear reset status register to
+	 * prevent driver detect reset interrupt again
+	 */
+	reg = hclge_read_dev(&hdev->hw, HCLGE_MISC_RESET_STS_REG);
+	hclge_write_dev(&hdev->hw, HCLGE_MISC_RESET_STS_REG, reg);
+
+	if (cnt >= HCLGE_RESET_WAIT_CNT) {
+		dev_warn(&hdev->pdev->dev,
+			 "Wait for reset timeout: %d\n", hdev->reset_type);
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+static int hclge_func_reset_cmd(struct hclge_dev *hdev, int func_id)
+{
+	struct hclge_desc desc;
+	struct hclge_reset_cmd *req = (struct hclge_reset_cmd *)desc.data;
+	int status;
+
+	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_CFG_RST_TRIGGER, false);
+	hnae_set_bit(req->mac_func_reset, HCLGE_CFG_RESET_MAC_B, 0);
+	hnae_set_bit(req->mac_func_reset, HCLGE_CFG_RESET_FUNC_B, 1);
+	req->fun_reset_vfid = func_id;
+
+	status = hclge_cmd_send(&hdev->hw, &desc, 1);
+	if (status) {
+		dev_err(&hdev->pdev->dev,
+			"send function reset cmd fail, status =%d\n", status);
+		return status;
+	}
+
+	return 0;
+}
+
+static void hclge_do_reset(struct hclge_dev *hdev, enum hnae3_reset_type type)
+{
+	struct pci_dev *pdev = hdev->pdev;
+	u32 val;
+
+	switch (type) {
+	case HNAE3_GLOBAL_RESET:
+		val = hclge_read_dev(&hdev->hw, HCLGE_GLOBAL_RESET_REG);
+		hnae_set_bit(val, HCLGE_GLOBAL_RESET_BIT, 1);
+		hclge_write_dev(&hdev->hw, HCLGE_GLOBAL_RESET_REG, val);
+		dev_info(&pdev->dev, "Global Reset requested\n");
+		break;
+	case HNAE3_CORE_RESET:
+		val = hclge_read_dev(&hdev->hw, HCLGE_GLOBAL_RESET_REG);
+		hnae_set_bit(val, HCLGE_CORE_RESET_BIT, 1);
+		hclge_write_dev(&hdev->hw, HCLGE_GLOBAL_RESET_REG, val);
+		dev_info(&pdev->dev, "Core Reset requested\n");
+		break;
+	case HNAE3_FUNC_RESET:
+		dev_info(&pdev->dev, "PF Reset requested\n");
+		hclge_func_reset_cmd(hdev, 0);
+		break;
+	default:
+		dev_warn(&pdev->dev,
+			 "Unsupported reset type: %d\n", type);
+		break;
+	}
+}
+
+static enum hnae3_reset_type hclge_detected_reset_event(struct hclge_dev *hdev)
+{
+	enum hnae3_reset_type rst_level = HNAE3_NONE_RESET;
+	u32 rst_reg_val;
+
+	rst_reg_val = hclge_read_dev(&hdev->hw, HCLGE_MISC_RESET_STS_REG);
+	if (BIT_ULL(HCLGE_VECTOR0_GLOBALRESET_INT_B) & rst_reg_val)
+		rst_level = HNAE3_GLOBAL_RESET;
+	else if (BIT_ULL(HCLGE_VECTOR0_CORERESET_INT_B) & rst_reg_val)
+		rst_level = HNAE3_CORE_RESET;
+	else if (BIT_ULL(HCLGE_VECTOR0_IMPRESET_INT_B) & rst_reg_val)
+		rst_level = HNAE3_IMP_RESET;
+
+	return rst_level;
+}
+
+static void hclge_reset_event(struct hnae3_handle *handle,
+			      enum hnae3_reset_type reset, u16 vfid)
+{
+	struct hclge_vport *vport = hclge_get_vport(handle);
+	struct hclge_dev *hdev = vport->back;
+
+	dev_info(&hdev->pdev->dev,
+		 "Receive reset event , reset_type is %d", reset);
+
+	switch (reset) {
+	case HNAE3_FUNC_RESET:
+	case HNAE3_CORE_RESET:
+	case HNAE3_GLOBAL_RESET:
+		if (test_bit(HCLGE_STATE_RESET_INT, &hdev->state)) {
+			dev_err(&hdev->pdev->dev, "Already in reset state");
+			return;
+		}
+		hdev->reset_type = reset;
+		set_bit(HCLGE_STATE_RESET_INT, &hdev->state);
+		set_bit(HCLGE_STATE_SERVICE_SCHED, &hdev->state);
+		schedule_work(&hdev->service_task);
+		break;
+	default:
+		dev_warn(&hdev->pdev->dev, "Unsupported reset event:%d", reset);
+		break;
+	}
+}
+
+static void hclge_reset_subtask(struct hclge_dev *hdev)
+{
+	bool do_reset;
+
+	do_reset = hdev->reset_type != HNAE3_NONE_RESET;
+
+	/* Reset is detected by interrupt */
+	if (hdev->reset_type == HNAE3_NONE_RESET)
+		hdev->reset_type = hclge_detected_reset_event(hdev);
+
+	if (hdev->reset_type == HNAE3_NONE_RESET)
+		return;
+
+	switch (hdev->reset_type) {
+	case HNAE3_FUNC_RESET:
+	case HNAE3_CORE_RESET:
+	case HNAE3_GLOBAL_RESET:
+	case HNAE3_IMP_RESET:
+		hclge_notify_client(hdev, HNAE3_DOWN_CLIENT);
+
+		if (do_reset)
+			hclge_do_reset(hdev, hdev->reset_type);
+		else
+			set_bit(HCLGE_STATE_RESET_INT, &hdev->state);
+
+		if (!hclge_reset_wait(hdev)) {
+			hclge_notify_client(hdev, HNAE3_UNINIT_CLIENT);
+			hclge_reset_ae_dev(hdev->ae_dev);
+			hclge_notify_client(hdev, HNAE3_INIT_CLIENT);
+			clear_bit(HCLGE_STATE_RESET_INT, &hdev->state);
+		}
+		hclge_notify_client(hdev, HNAE3_UP_CLIENT);
+		break;
+	default:
+		dev_err(&hdev->pdev->dev, "Unsupported reset type:%d\n",
+			hdev->reset_type);
+		break;
+	}
+	hdev->reset_type = HNAE3_NONE_RESET;
 }
 
 static void hclge_misc_irq_service_task(struct hclge_dev *hdev)
 {
+	hclge_reset_subtask(hdev);
 	hclge_enable_vector(&hdev->misc_vector, true);
 }
 
@@ -4498,18 +4705,19 @@ static int hclge_init_ae_dev(struct hnae3_ae_dev *ae_dev)
 	hdev->flag |= HCLGE_FLAG_USE_MSIX;
 	hdev->pdev = pdev;
 	hdev->ae_dev = ae_dev;
+	hdev->reset_type = HNAE3_NONE_RESET;
 	ae_dev->priv = hdev;
 
 	ret = hclge_pci_init(hdev);
 	if (ret) {
-		dev_err(&pdev->dev, "PCI init failed\n");
+		dev_err(&pdev->dev, "PCI init failed, ret = %d.\n", ret);
 		goto err_pci_init;
 	}
 
 	/* Firmware command queue initialize */
 	ret = hclge_cmd_queue_init(hdev);
 	if (ret) {
-		dev_err(&pdev->dev, "Cmd queue init failed\n");
+		dev_err(&pdev->dev, "Cmd queue init failed, ret = %d.\n", ret);
 		return ret;
 	}
 
@@ -4630,6 +4838,84 @@ static int hclge_init_ae_dev(struct hnae3_ae_dev *ae_dev)
 	return ret;
 }
 
+static int hclge_reset_ae_dev(struct hnae3_ae_dev *ae_dev)
+{
+	struct hclge_dev *hdev = ae_dev->priv;
+	struct pci_dev *pdev = ae_dev->pdev;
+	int ret;
+
+	set_bit(HCLGE_STATE_DOWN, &hdev->state);
+
+	ret = hclge_cmd_init(hdev);
+	if (ret) {
+		dev_err(&pdev->dev, "Cmd queue init failed\n");
+		return ret;
+	}
+
+	ret = hclge_get_cap(hdev);
+	if (ret) {
+		dev_err(&pdev->dev, "get hw capability error, ret = %d.\n",
+			ret);
+		return ret;
+	}
+
+	ret = hclge_configure(hdev);
+	if (ret) {
+		dev_err(&pdev->dev, "Configure dev error, ret = %d.\n", ret);
+		return ret;
+	}
+
+	ret = hclge_map_tqp(hdev);
+	if (ret) {
+		dev_err(&pdev->dev, "Map tqp error, ret = %d.\n", ret);
+		return ret;
+	}
+
+	ret = hclge_mac_init(hdev);
+	if (ret) {
+		dev_err(&pdev->dev, "Mac init error, ret = %d\n", ret);
+		return ret;
+	}
+
+	ret = hclge_buffer_alloc(hdev);
+	if (ret) {
+		dev_err(&pdev->dev, "Buffer allocate fail, ret =%d\n", ret);
+		return ret;
+	}
+
+	ret = hclge_config_tso(hdev, HCLGE_TSO_MSS_MIN, HCLGE_TSO_MSS_MAX);
+	if (ret) {
+		dev_err(&pdev->dev, "Enable tso fail, ret =%d\n", ret);
+		return ret;
+	}
+
+	ret = hclge_init_vlan_config(hdev);
+	if (ret) {
+		dev_err(&pdev->dev, "VLAN init fail, ret =%d\n", ret);
+		return ret;
+	}
+
+	ret = hclge_tm_schd_init(hdev);
+	if (ret) {
+		dev_err(&pdev->dev, "tm schd init fail, ret =%d\n", ret);
+		return ret;
+	}
+
+	ret = hclge_rss_init_hw(hdev);
+	if (ret) {
+		dev_err(&pdev->dev, "Rss init fail, ret =%d\n", ret);
+		return ret;
+	}
+
+	/* Enable MISC vector(vector0) */
+	hclge_enable_vector(&hdev->misc_vector, true);
+
+	dev_info(&pdev->dev, "Reset done, %s driver initialization finished.\n",
+		 HCLGE_DRIVER_NAME);
+
+	return 0;
+}
+
 static void hclge_uninit_ae_dev(struct hnae3_ae_dev *ae_dev)
 {
 	struct hclge_dev *hdev = ae_dev->priv;
@@ -4699,6 +4985,7 @@ static void hclge_uninit_ae_dev(struct hnae3_ae_dev *ae_dev)
 	.get_mdix_mode = hclge_get_mdix_mode,
 	.set_vlan_filter = hclge_set_port_vlan_filter,
 	.set_vf_vlan_filter = hclge_set_vf_vlan_filter,
+	.reset_event = hclge_reset_event,
 };
 
 static struct hnae3_ae_algo ae_algo = {
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
index 2a1d4d6..a8219be 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
@@ -79,6 +79,19 @@
 #define HCLGE_PHY_MDIX_STATUS_B	(6)
 #define HCLGE_PHY_SPEED_DUP_RESOLVE_B	(11)
 
+/* Reset related Registers */
+#define HCLGE_MISC_RESET_STS_REG	0x20700
+#define HCLGE_GLOBAL_RESET_REG		0x20A00
+#define HCLGE_GLOBAL_RESET_BIT		0x0
+#define HCLGE_CORE_RESET_BIT		0x1
+#define HCLGE_FUN_RST_ING		0x20C00
+#define HCLGE_FUN_RST_ING_B		0
+
+/* Vector0 register bits define */
+#define HCLGE_VECTOR0_GLOBALRESET_INT_B	5
+#define HCLGE_VECTOR0_CORERESET_INT_B	6
+#define HCLGE_VECTOR0_IMPRESET_INT_B	7
+
 enum HCLGE_DEV_STATE {
 	HCLGE_STATE_REINITING,
 	HCLGE_STATE_DOWN,
@@ -88,6 +101,7 @@ enum HCLGE_DEV_STATE {
 	HCLGE_STATE_SERVICE_SCHED,
 	HCLGE_STATE_MBX_HANDLING,
 	HCLGE_STATE_MBX_IRQ,
+	HCLGE_STATE_RESET_INT,
 	HCLGE_STATE_MAX
 };
 
@@ -404,7 +418,7 @@ struct hclge_dev {
 	struct hclge_misc_vector misc_vector;
 	struct hclge_hw_stats hw_stats;
 	unsigned long state;
-
+	enum hnae3_reset_type reset_type;
 	u32 fw_version;
 	u16 num_vmdq_vport;		/* Num vmdq vport this PF has set up */
 	u16 num_tqps;			/* Num task queue pairs of this PF */
-- 
1.9.1
