From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V4 net-next 09/21] net-next/hinic: Add Rx mode and link event handler
Date: Wed, 16 Aug 2017 19:52:00 +0800
Message-ID: <293ebce746ed6370fb96aa6fdb30981dce37bf4e.1502883967.git.aviad.krawczyk@huawei.com>
References: <cover.1502883967.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502883967.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add port management message for setting Rx mode in the card,
used for rx_mode netdev operation. The link event handler is used for
getting a notification about the link state.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_dev.h     |  17 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h  |   2 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c  | 118 +++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h  |  37 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.c   |  17 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h   |  17 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c |  64 ++++-
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h |  28 +++
 drivers/net/ethernet/huawei/hinic/hinic_main.c    | 284 ++++++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_port.c    |  92 +++++++
 drivers/net/ethernet/huawei/hinic/hinic_port.h    |  66 +++++
 11 files changed, 741 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
index e54a45c..5c5b4e9 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_dev.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
@@ -19,19 +19,36 @@
 #include <linux/netdevice.h>
 #include <linux/types.h>
 #include <linux/semaphore.h>
+#include <linux/workqueue.h>
+#include <linux/bitops.h>
 
 #include "hinic_hw_dev.h"
 
 #define HINIC_DRV_NAME          "hinic"
 
+enum hinic_flags {
+	HINIC_LINK_UP = BIT(0),
+	HINIC_INTF_UP = BIT(1),
+};
+
+struct hinic_rx_mode_work {
+	struct work_struct      work;
+	u32                     rx_mode;
+};
+
 struct hinic_dev {
 	struct net_device               *netdev;
 	struct hinic_hwdev              *hwdev;
 
 	u32                             msg_enable;
 
+	unsigned int                    flags;
+
 	struct semaphore                mgmt_lock;
 	unsigned long                   *vlan_bitmap;
+
+	struct hinic_rx_mode_work       rx_mode_work;
+	struct workqueue_struct         *workq;
 };
 
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
index 52eb89c..1f57301 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
@@ -20,6 +20,8 @@
 #define HINIC_CSR_FUNC_ATTR0_ADDR                       0x0
 #define HINIC_CSR_FUNC_ATTR1_ADDR                       0x4
 
+#define HINIC_CSR_FUNC_ATTR5_ADDR                       0x14
+
 #define HINIC_DMA_ATTR_BASE                             0xC80
 #define HINIC_ELECTION_BASE                             0x4200
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
index 6bb6c33..75fd6d2 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
@@ -230,6 +230,114 @@ int hinic_port_msg_cmd(struct hinic_hwdev *hwdev, enum hinic_port_cmd cmd,
 }
 
 /**
+ * hinic_hwdev_cb_register - register callback handler for MGMT events
+ * @hwdev: the NIC HW device
+ * @cmd: the mgmt event
+ * @handle: private data for the handler
+ * @handler: event handler
+ **/
+void hinic_hwdev_cb_register(struct hinic_hwdev *hwdev,
+			     enum hinic_mgmt_msg_cmd cmd, void *handle,
+			     void (*handler)(void *handle, void *buf_in,
+					     u16 in_size, void *buf_out,
+					     u16 *out_size))
+{
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_pfhwdev *pfhwdev;
+	struct hinic_nic_cb *nic_cb;
+	u8 cmd_cb;
+
+	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
+		dev_err(&pdev->dev, "unsupported PCI Function type\n");
+		return;
+	}
+
+	pfhwdev = container_of(hwdev, struct hinic_pfhwdev, hwdev);
+
+	cmd_cb = cmd - HINIC_MGMT_MSG_CMD_BASE;
+	nic_cb = &pfhwdev->nic_cb[cmd_cb];
+
+	nic_cb->handler = handler;
+	nic_cb->handle = handle;
+	nic_cb->cb_state = HINIC_CB_ENABLED;
+}
+
+/**
+ * hinic_hwdev_cb_unregister - unregister callback handler for MGMT events
+ * @hwdev: the NIC HW device
+ * @cmd: the mgmt event
+ **/
+void hinic_hwdev_cb_unregister(struct hinic_hwdev *hwdev,
+			       enum hinic_mgmt_msg_cmd cmd)
+{
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_pfhwdev *pfhwdev;
+	struct hinic_nic_cb *nic_cb;
+	u8 cmd_cb;
+
+	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
+		dev_err(&pdev->dev, "unsupported PCI Function type\n");
+		return;
+	}
+
+	pfhwdev = container_of(hwdev, struct hinic_pfhwdev, hwdev);
+
+	cmd_cb = cmd - HINIC_MGMT_MSG_CMD_BASE;
+	nic_cb = &pfhwdev->nic_cb[cmd_cb];
+
+	nic_cb->cb_state &= ~HINIC_CB_ENABLED;
+
+	while (nic_cb->cb_state & HINIC_CB_RUNNING)
+		schedule();
+
+	nic_cb->handler = NULL;
+}
+
+/**
+ * nic_mgmt_msg_handler - nic mgmt event handler
+ * @handle: private data for the handler
+ * @buf_in: input buffer
+ * @in_size: input size
+ * @buf_out: output buffer
+ * @out_size: returned output size
+ **/
+static void nic_mgmt_msg_handler(void *handle, u8 cmd, void *buf_in,
+				 u16 in_size, void *buf_out, u16 *out_size)
+{
+	struct hinic_pfhwdev *pfhwdev = (struct hinic_pfhwdev *)handle;
+	struct hinic_hwdev *hwdev = &pfhwdev->hwdev;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_nic_cb *nic_cb;
+	enum hinic_cb_state cb_state;
+	u8 cmd_cb;
+
+	if ((cmd < HINIC_MGMT_MSG_CMD_BASE) ||
+	    (cmd >= HINIC_MGMT_MSG_CMD_MAX)) {
+		dev_err(&pdev->dev, "unknown L2NIC event, cmd = %d\n", cmd);
+		return;
+	}
+
+	cmd_cb = (enum hinic_mgmt_msg_cmd)cmd - HINIC_MGMT_MSG_CMD_BASE;
+
+	nic_cb = &pfhwdev->nic_cb[cmd_cb];
+
+	cb_state = cmpxchg(&nic_cb->cb_state,
+			   HINIC_CB_ENABLED,
+			   HINIC_CB_ENABLED | HINIC_CB_RUNNING);
+
+	if ((cb_state == HINIC_CB_ENABLED) && (nic_cb->handler))
+		nic_cb->handler(nic_cb->handle, buf_in,
+				in_size, buf_out, out_size);
+	else
+		dev_err(&pdev->dev, "Unhandled NIC Event %d\n", cmd);
+
+	nic_cb->cb_state &= ~HINIC_CB_RUNNING;
+}
+
+/**
  * init_pfhwdev - Initialize the extended components of PF
  * @pfhwdev: the HW device for PF
  *
@@ -248,6 +356,10 @@ static int init_pfhwdev(struct hinic_pfhwdev *pfhwdev)
 		return err;
 	}
 
+	hinic_register_mgmt_msg_cb(&pfhwdev->pf_to_mgmt, HINIC_MOD_L2NIC,
+				   pfhwdev, nic_mgmt_msg_handler);
+
+	hinic_set_pf_action(hwif, HINIC_PF_MGMT_ACTIVE);
 	return 0;
 }
 
@@ -257,6 +369,12 @@ static int init_pfhwdev(struct hinic_pfhwdev *pfhwdev)
  **/
 static void free_pfhwdev(struct hinic_pfhwdev *pfhwdev)
 {
+	struct hinic_hwdev *hwdev = &pfhwdev->hwdev;
+
+	hinic_set_pf_action(hwdev->hwif, HINIC_PF_MGMT_INIT);
+
+	hinic_unregister_mgmt_msg_cb(&pfhwdev->pf_to_mgmt, HINIC_MOD_L2NIC);
+
 	hinic_pf_to_mgmt_free(&pfhwdev->pf_to_mgmt);
 }
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
index ee9e76a..1cd8159 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
@@ -18,6 +18,7 @@
 
 #include <linux/pci.h>
 #include <linux/types.h>
+#include <linux/bitops.h>
 
 #include "hinic_hw_if.h"
 #include "hinic_hw_eqs.h"
@@ -25,6 +26,9 @@
 
 #define HINIC_MAX_QPS   32
 
+#define HINIC_MGMT_NUM_MSG_CMD  (HINIC_MGMT_MSG_CMD_MAX - \
+				 HINIC_MGMT_MSG_CMD_BASE)
+
 struct hinic_cap {
 	u16     max_qps;
 	u16     num_qps;
@@ -55,6 +59,19 @@ enum hinic_port_cmd {
 	HINIC_PORT_CMD_GET_CAP          = 170,
 };
 
+enum hinic_mgmt_msg_cmd {
+	HINIC_MGMT_MSG_CMD_BASE         = 160,
+
+	HINIC_MGMT_MSG_CMD_LINK_STATUS  = 160,
+
+	HINIC_MGMT_MSG_CMD_MAX,
+};
+
+enum hinic_cb_state {
+	HINIC_CB_ENABLED = BIT(0),
+	HINIC_CB_RUNNING = BIT(1),
+};
+
 struct hinic_hwdev {
 	struct hinic_hwif               *hwif;
 	struct msix_entry               *msix_entries;
@@ -64,12 +81,32 @@ struct hinic_hwdev {
 	struct hinic_cap                nic_cap;
 };
 
+struct hinic_nic_cb {
+	void    (*handler)(void *handle, void *buf_in,
+			   u16 in_size, void *buf_out,
+			   u16 *out_size);
+
+	void            *handle;
+	unsigned long   cb_state;
+};
+
 struct hinic_pfhwdev {
 	struct hinic_hwdev              hwdev;
 
 	struct hinic_pf_to_mgmt         pf_to_mgmt;
+
+	struct hinic_nic_cb             nic_cb[HINIC_MGMT_NUM_MSG_CMD];
 };
 
+void hinic_hwdev_cb_register(struct hinic_hwdev *hwdev,
+			     enum hinic_mgmt_msg_cmd cmd, void *handle,
+			     void (*handler)(void *handle, void *buf_in,
+					     u16 in_size, void *buf_out,
+					     u16 *out_size));
+
+void hinic_hwdev_cb_unregister(struct hinic_hwdev *hwdev,
+			       enum hinic_mgmt_msg_cmd cmd);
+
 int hinic_port_msg_cmd(struct hinic_hwdev *hwdev, enum hinic_port_cmd cmd,
 		       void *buf_in, u16 in_size, void *buf_out,
 		       u16 *out_size);
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
index 2b9410c..d4e6ec4 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
@@ -117,6 +117,23 @@ int hinic_msix_attr_cnt_clear(struct hinic_hwif *hwif, u16 msix_index)
 }
 
 /**
+ * hinic_set_pf_action - set action on pf channel
+ * @hwif: the HW interface of a pci function device
+ * @action: action on pf channel
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+void hinic_set_pf_action(struct hinic_hwif *hwif, enum hinic_pf_action action)
+{
+	u32 attr5 = hinic_hwif_read_reg(hwif, HINIC_CSR_FUNC_ATTR5_ADDR);
+
+	attr5 = HINIC_FA5_CLEAR(attr5, PF_ACTION);
+	attr5 |= HINIC_FA5_SET(action, PF_ACTION);
+
+	hinic_hwif_write_reg(hwif, HINIC_CSR_FUNC_ATTR5_ADDR, attr5);
+}
+
+/**
  * hwif_ready - test if the HW is ready for use
  * @hwif: the HW interface of a pci function device
  *
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
index 707a046..2280698 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
@@ -73,6 +73,15 @@
 #define HINIC_FA1_GET(val, member)                              \
 	(((val) >> HINIC_FA1_##member##_SHIFT) & HINIC_FA1_##member##_MASK)
 
+#define HINIC_FA5_PF_ACTION_SHIFT                               0
+#define HINIC_FA5_PF_ACTION_MASK                                0xFFFF
+
+#define HINIC_FA5_SET(val, member)                              \
+	(((u32)(val) & HINIC_FA5_##member##_MASK) << HINIC_FA5_##member##_SHIFT)
+
+#define HINIC_FA5_CLEAR(val, member)                            \
+	((val) & (~(HINIC_FA5_##member##_MASK << HINIC_FA5_##member##_SHIFT)))
+
 #define HINIC_PPF_ELECTION_IDX_SHIFT                            0
 #define HINIC_PPF_ELECTION_IDX_MASK                             0x1F
 
@@ -166,6 +175,12 @@ enum hinic_node_id {
 	HINIC_NODE_ID_MGMT = 21,
 };
 
+enum hinic_pf_action {
+	HINIC_PF_MGMT_INIT = 0x0,
+
+	HINIC_PF_MGMT_ACTIVE = 0x11,
+};
+
 struct hinic_func_attr {
 	u16                     func_idx;
 	u8                      pf_idx;
@@ -212,6 +227,8 @@ int hinic_msix_attr_get(struct hinic_hwif *hwif, u16 msix_index,
 
 int hinic_msix_attr_cnt_clear(struct hinic_hwif *hwif, u16 msix_index);
 
+void hinic_set_pf_action(struct hinic_hwif *hwif, enum hinic_pf_action action);
+
 int hinic_init_hwif(struct hinic_hwif *hwif, struct pci_dev *pdev);
 
 void hinic_free_hwif(struct hinic_hwif *hwif);
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c
index 147c404..434e134 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c
@@ -73,6 +73,46 @@ enum msg_ack_type {
 };
 
 /**
+ * hinic_register_mgmt_msg_cb - register msg handler for a msg from a module
+ * @pf_to_mgmt: PF to MGMT channel
+ * @mod: module in the chip that this handler will handle its messages
+ * @handle: private data for the callback
+ * @callback: the handler that will handle messages
+ **/
+void hinic_register_mgmt_msg_cb(struct hinic_pf_to_mgmt *pf_to_mgmt,
+				enum hinic_mod_type mod,
+				void *handle,
+				void (*callback)(void *handle,
+						 u8 cmd, void *buf_in,
+						 u16 in_size, void *buf_out,
+						 u16 *out_size))
+{
+	struct hinic_mgmt_cb *mgmt_cb = &pf_to_mgmt->mgmt_cb[mod];
+
+	mgmt_cb->cb = callback;
+	mgmt_cb->handle = handle;
+	mgmt_cb->state = HINIC_MGMT_CB_ENABLED;
+}
+
+/**
+ * hinic_unregister_mgmt_msg_cb - unregister msg handler for a msg from a module
+ * @pf_to_mgmt: PF to MGMT channel
+ * @mod: module in the chip that this handler handles its messages
+ **/
+void hinic_unregister_mgmt_msg_cb(struct hinic_pf_to_mgmt *pf_to_mgmt,
+				  enum hinic_mod_type mod)
+{
+	struct hinic_mgmt_cb *mgmt_cb = &pf_to_mgmt->mgmt_cb[mod];
+
+	mgmt_cb->state &= ~HINIC_MGMT_CB_ENABLED;
+
+	while (mgmt_cb->state & HINIC_MGMT_CB_RUNNING)
+		schedule();
+
+	mgmt_cb->cb = NULL;
+}
+
+/**
  * prepare_header - prepare the header of the message
  * @pf_to_mgmt: PF to MGMT channel
  * @msg_len: the length of the message
@@ -337,9 +377,31 @@ static void mgmt_recv_msg_handler(struct hinic_pf_to_mgmt *pf_to_mgmt,
 	struct hinic_hwif *hwif = pf_to_mgmt->hwif;
 	struct pci_dev *pdev = hwif->pdev;
 	u8 *buf_out = recv_msg->buf_out;
+	struct hinic_mgmt_cb *mgmt_cb;
+	unsigned long cb_state;
 	u16 out_size = 0;
 
-	dev_err(&pdev->dev, "No MGMT msg handler, mod = %d\n", recv_msg->mod);
+	if (recv_msg->mod >= HINIC_MOD_MAX) {
+		dev_err(&pdev->dev, "Unknown MGMT MSG module = %d\n",
+			recv_msg->mod);
+		return;
+	}
+
+	mgmt_cb = &pf_to_mgmt->mgmt_cb[recv_msg->mod];
+
+	cb_state = cmpxchg(&mgmt_cb->state,
+			   HINIC_MGMT_CB_ENABLED,
+			   HINIC_MGMT_CB_ENABLED | HINIC_MGMT_CB_RUNNING);
+
+	if ((cb_state == HINIC_MGMT_CB_ENABLED) && (mgmt_cb->cb))
+		mgmt_cb->cb(mgmt_cb->handle, recv_msg->cmd,
+			    recv_msg->msg, recv_msg->msg_len,
+			    buf_out, &out_size);
+	else
+		dev_err(&pdev->dev, "No MGMT msg handler, mod = %d\n",
+			recv_msg->mod);
+
+	mgmt_cb->state &= ~HINIC_MGMT_CB_RUNNING;
 
 	if (!recv_msg->async_mgmt_to_pf)
 		/* MGMT sent sync msg, send the response */
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
index eca7ad8..8021406 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
@@ -19,6 +19,7 @@
 #include <linux/types.h>
 #include <linux/semaphore.h>
 #include <linux/completion.h>
+#include <linux/bitops.h>
 
 #include "hinic_hw_if.h"
 #include "hinic_hw_api_cmd.h"
@@ -67,6 +68,11 @@ enum hinic_cfg_cmd {
 	HINIC_CFG_NIC_CAP = 0,
 };
 
+enum hinic_mgmt_cb_state {
+	HINIC_MGMT_CB_ENABLED = BIT(0),
+	HINIC_MGMT_CB_RUNNING = BIT(1),
+};
+
 struct hinic_recv_msg {
 	u8                      *msg;
 	u8                      *buf_out;
@@ -81,6 +87,15 @@ struct hinic_recv_msg {
 	u16                     msg_id;
 };
 
+struct hinic_mgmt_cb {
+	void    (*cb)(void *handle, u8 cmd,
+		      void *buf_in, u16 in_size,
+		      void *buf_out, u16 *out_size);
+
+	void            *handle;
+	unsigned long   state;
+};
+
 struct hinic_pf_to_mgmt {
 	struct hinic_hwif               *hwif;
 
@@ -92,8 +107,21 @@ struct hinic_pf_to_mgmt {
 	struct hinic_recv_msg           recv_msg_from_mgmt;
 
 	struct hinic_api_cmd_chain      *cmd_chain[HINIC_API_CMD_MAX];
+
+	struct hinic_mgmt_cb            mgmt_cb[HINIC_MOD_MAX];
 };
 
+void hinic_register_mgmt_msg_cb(struct hinic_pf_to_mgmt *pf_to_mgmt,
+				enum hinic_mod_type mod,
+				void *handle,
+				void (*callback)(void *handle,
+						 u8 cmd, void *buf_in,
+						 u16 in_size, void *buf_out,
+						 u16 *out_size));
+
+void hinic_unregister_mgmt_msg_cb(struct hinic_pf_to_mgmt *pf_to_mgmt,
+				  enum hinic_mod_type mod);
+
 int hinic_msg_to_mgmt(struct hinic_pf_to_mgmt *pf_to_mgmt,
 		      enum hinic_mod_type mod, u8 cmd,
 		      void *buf_in, u16 in_size, void *buf_out, u16 *out_size,
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
index f46c2bc..3fe8a6f 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_main.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
@@ -24,9 +24,11 @@
 #include <linux/slab.h>
 #include <linux/if_vlan.h>
 #include <linux/semaphore.h>
+#include <linux/workqueue.h>
 #include <net/ip.h>
 #include <linux/bitops.h>
 #include <linux/bitmap.h>
+#include <linux/delay.h>
 #include <linux/err.h>
 
 #include "hinic_hw_dev.h"
@@ -39,12 +41,99 @@
 
 #define PCI_DEVICE_ID_HI1822_PF         0x1822
 
+#define HINIC_WQ_NAME                   "hinic_dev"
+
 #define MSG_ENABLE_DEFAULT              (NETIF_MSG_DRV | NETIF_MSG_PROBE | \
 					 NETIF_MSG_IFUP |                  \
 					 NETIF_MSG_TX_ERR | NETIF_MSG_RX_ERR)
 
 #define VLAN_BITMAP_SIZE(nic_dev)       (ALIGN(VLAN_N_VID, 8) / 8)
 
+#define work_to_rx_mode_work(work)      \
+		container_of(work, struct hinic_rx_mode_work, work)
+
+#define rx_mode_work_to_nic_dev(rx_mode_work) \
+		container_of(rx_mode_work, struct hinic_dev, rx_mode_work)
+
+static int change_mac_addr(struct net_device *netdev, const u8 *addr);
+
+static int hinic_open(struct net_device *netdev)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	enum hinic_port_link_state link_state;
+	int err, ret;
+
+	err = hinic_port_set_state(nic_dev, HINIC_PORT_ENABLE);
+	if (err) {
+		netif_err(nic_dev, drv, netdev,
+			  "Failed to set port state\n");
+		return err;
+	}
+
+	/* Wait up to 3 sec between port enable to link state */
+	msleep(3000);
+
+	down(&nic_dev->mgmt_lock);
+
+	err = hinic_port_link_state(nic_dev, &link_state);
+	if (err) {
+		netif_err(nic_dev, drv, netdev, "Failed to get link state\n");
+		goto err_port_link;
+	}
+
+	if (link_state == HINIC_LINK_STATE_UP)
+		nic_dev->flags |= HINIC_LINK_UP;
+
+	nic_dev->flags |= HINIC_INTF_UP;
+
+	if ((nic_dev->flags & (HINIC_LINK_UP | HINIC_INTF_UP)) ==
+	    (HINIC_LINK_UP | HINIC_INTF_UP)) {
+		netif_info(nic_dev, drv, netdev, "link + intf UP\n");
+		netif_carrier_on(netdev);
+		netif_tx_wake_all_queues(netdev);
+	}
+
+	up(&nic_dev->mgmt_lock);
+
+	netif_info(nic_dev, drv, netdev, "HINIC_INTF is UP\n");
+	return 0;
+
+err_port_link:
+	up(&nic_dev->mgmt_lock);
+	ret = hinic_port_set_state(nic_dev, HINIC_PORT_DISABLE);
+	if (ret)
+		netif_warn(nic_dev, drv, netdev,
+			   "Failed to revert port state\n");
+	return err;
+}
+
+static int hinic_close(struct net_device *netdev)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	unsigned int flags;
+	int err;
+
+	down(&nic_dev->mgmt_lock);
+
+	flags = nic_dev->flags;
+	nic_dev->flags &= ~HINIC_INTF_UP;
+
+	netif_carrier_off(netdev);
+	netif_tx_disable(netdev);
+
+	up(&nic_dev->mgmt_lock);
+
+	err = hinic_port_set_state(nic_dev, HINIC_PORT_DISABLE);
+	if (err) {
+		netif_err(nic_dev, drv, netdev, "Failed to set port state\n");
+		nic_dev->flags |= (flags & HINIC_INTF_UP);
+		return err;
+	}
+
+	netif_info(nic_dev, drv, netdev, "HINIC_INTF is DOWN\n");
+	return 0;
+}
+
 static int hinic_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct hinic_dev *nic_dev = netdev_priv(netdev);
@@ -118,6 +207,77 @@ static int hinic_set_mac_addr(struct net_device *netdev, void *addr)
 	return err;
 }
 
+/**
+ * add_mac_addr - add mac address to network device
+ * @netdev: network device
+ * @addr: mac address to add
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int add_mac_addr(struct net_device *netdev, const u8 *addr)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	u16 vid = 0;
+	int err;
+
+	if (!is_valid_ether_addr(addr))
+		return -EADDRNOTAVAIL;
+
+	netif_info(nic_dev, drv, netdev, "set mac addr = %02x %02x %02x %02x %02x %02x\n",
+		   addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
+
+	down(&nic_dev->mgmt_lock);
+
+	do {
+		err = hinic_port_add_mac(nic_dev, addr, vid);
+		if (err) {
+			netif_err(nic_dev, drv, netdev, "Failed to add mac\n");
+			break;
+		}
+
+		vid = find_next_bit(nic_dev->vlan_bitmap, VLAN_N_VID, vid + 1);
+	} while (vid != VLAN_N_VID);
+
+	up(&nic_dev->mgmt_lock);
+	return err;
+}
+
+/**
+ * remove_mac_addr - remove mac address from network device
+ * @netdev: network device
+ * @addr: mac address to remove
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int remove_mac_addr(struct net_device *netdev, const u8 *addr)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	u16 vid = 0;
+	int err;
+
+	if (!is_valid_ether_addr(addr))
+		return -EADDRNOTAVAIL;
+
+	netif_info(nic_dev, drv, netdev, "remove mac addr = %02x %02x %02x %02x %02x %02x\n",
+		   addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
+
+	down(&nic_dev->mgmt_lock);
+
+	do {
+		err = hinic_port_del_mac(nic_dev, addr, vid);
+		if (err) {
+			netif_err(nic_dev, drv, netdev,
+				  "Failed to delete mac\n");
+			break;
+		}
+
+		vid = find_next_bit(nic_dev->vlan_bitmap, VLAN_N_VID, vid + 1);
+	} while (vid != VLAN_N_VID);
+
+	up(&nic_dev->mgmt_lock);
+	return err;
+}
+
 static int hinic_vlan_rx_add_vid(struct net_device *netdev,
 				 __always_unused __be16 proto, u16 vid)
 {
@@ -182,12 +342,56 @@ static int hinic_vlan_rx_kill_vid(struct net_device *netdev,
 	return err;
 }
 
+static void set_rx_mode(struct work_struct *work)
+{
+	struct hinic_rx_mode_work *rx_mode_work = work_to_rx_mode_work(work);
+	struct hinic_dev *nic_dev = rx_mode_work_to_nic_dev(rx_mode_work);
+
+	netif_info(nic_dev, drv, nic_dev->netdev, "set rx mode work\n");
+
+	hinic_port_set_rx_mode(nic_dev, rx_mode_work->rx_mode);
+
+	__dev_uc_sync(nic_dev->netdev, add_mac_addr, remove_mac_addr);
+	__dev_mc_sync(nic_dev->netdev, add_mac_addr, remove_mac_addr);
+}
+
+static void hinic_set_rx_mode(struct net_device *netdev)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	struct hinic_rx_mode_work *rx_mode_work;
+	u32 rx_mode;
+
+	rx_mode_work = &nic_dev->rx_mode_work;
+
+	rx_mode = HINIC_RX_MODE_UC |
+		  HINIC_RX_MODE_MC |
+		  HINIC_RX_MODE_BC;
+
+	if (netdev->flags & IFF_PROMISC)
+		rx_mode |= HINIC_RX_MODE_PROMISC;
+	else if (netdev->flags & IFF_ALLMULTI)
+		rx_mode |= HINIC_RX_MODE_MC_ALL;
+
+	rx_mode_work->rx_mode = rx_mode;
+
+	queue_work(nic_dev->workq, &rx_mode_work->work);
+}
+
+netdev_tx_t hinic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	return NETDEV_TX_BUSY;
+}
+
 static const struct net_device_ops hinic_netdev_ops = {
+	.ndo_open = hinic_open,
+	.ndo_stop = hinic_close,
 	.ndo_change_mtu = hinic_change_mtu,
 	.ndo_set_mac_address = hinic_set_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_vlan_rx_add_vid = hinic_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = hinic_vlan_rx_kill_vid,
+	.ndo_set_rx_mode = hinic_set_rx_mode,
+	.ndo_start_xmit = hinic_xmit_frame,
 	/* more operations should be filled */
 };
 
@@ -201,6 +405,57 @@ static void netdev_features_init(struct net_device *netdev)
 }
 
 /**
+ * link_status_event_handler - link event handler
+ * @handle: nic device for the handler
+ * @buf_in: input buffer
+ * @in_size: input size
+ * @buf_in: output buffer
+ * @out_size: returned output size
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static void link_status_event_handler(void *handle, void *buf_in, u16 in_size,
+				      void *buf_out, u16 *out_size)
+{
+	struct hinic_port_link_status *link_status, *ret_link_status;
+	struct hinic_dev *nic_dev = (struct hinic_dev *)handle;
+
+	link_status = buf_in;
+
+	if (link_status->link == HINIC_LINK_STATE_UP) {
+		down(&nic_dev->mgmt_lock);
+
+		nic_dev->flags |= HINIC_LINK_UP;
+
+		if ((nic_dev->flags & (HINIC_LINK_UP | HINIC_INTF_UP)) ==
+		    (HINIC_LINK_UP | HINIC_INTF_UP)) {
+			netif_carrier_on(nic_dev->netdev);
+			netif_tx_wake_all_queues(nic_dev->netdev);
+		}
+
+		up(&nic_dev->mgmt_lock);
+
+		netif_info(nic_dev, drv, nic_dev->netdev, "HINIC_Link is UP\n");
+	} else {
+		down(&nic_dev->mgmt_lock);
+
+		nic_dev->flags &= ~HINIC_LINK_UP;
+
+		netif_carrier_off(nic_dev->netdev);
+		netif_tx_disable(nic_dev->netdev);
+
+		up(&nic_dev->mgmt_lock);
+
+		netif_info(nic_dev, drv, nic_dev->netdev, "HINIC_Link is DOWN\n");
+	}
+
+	ret_link_status = buf_out;
+	ret_link_status->status = 0;
+
+	*out_size = sizeof(*ret_link_status);
+}
+
+/**
  * nic_dev_init - Initialize the NIC device
  * @pdev: the NIC pci device
  *
@@ -208,6 +463,7 @@ static void netdev_features_init(struct net_device *netdev)
  **/
 static int nic_dev_init(struct pci_dev *pdev)
 {
+	struct hinic_rx_mode_work *rx_mode_work;
 	struct hinic_dev *nic_dev;
 	struct net_device *netdev;
 	struct hinic_hwdev *hwdev;
@@ -239,6 +495,7 @@ static int nic_dev_init(struct pci_dev *pdev)
 	nic_dev->netdev = netdev;
 	nic_dev->hwdev = hwdev;
 	nic_dev->msg_enable = MSG_ENABLE_DEFAULT;
+	nic_dev->flags = 0;
 
 	sema_init(&nic_dev->mgmt_lock, 1);
 
@@ -250,6 +507,12 @@ static int nic_dev_init(struct pci_dev *pdev)
 		goto err_vlan_bitmap;
 	}
 
+	nic_dev->workq = create_singlethread_workqueue(HINIC_WQ_NAME);
+	if (!nic_dev->workq) {
+		err = -ENOMEM;
+		goto err_workq;
+	}
+
 	pci_set_drvdata(pdev, netdev);
 
 	err = hinic_port_get_mac(nic_dev, netdev->dev_addr);
@@ -268,10 +531,16 @@ static int nic_dev_init(struct pci_dev *pdev)
 		goto err_set_mtu;
 	}
 
+	rx_mode_work = &nic_dev->rx_mode_work;
+	INIT_WORK(&rx_mode_work->work, set_rx_mode);
+
 	netdev_features_init(netdev);
 
 	netif_carrier_off(netdev);
 
+	hinic_hwdev_cb_register(nic_dev->hwdev, HINIC_MGMT_MSG_CMD_LINK_STATUS,
+				nic_dev, link_status_event_handler);
+
 	err = register_netdev(netdev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to register netdev\n");
@@ -281,10 +550,16 @@ static int nic_dev_init(struct pci_dev *pdev)
 	return 0;
 
 err_reg_netdev:
+	hinic_hwdev_cb_unregister(nic_dev->hwdev,
+				  HINIC_MGMT_MSG_CMD_LINK_STATUS);
+	cancel_work_sync(&rx_mode_work->work);
+
 err_set_mtu:
 err_add_mac:
 	pci_set_drvdata(pdev, NULL);
+	destroy_workqueue(nic_dev->workq);
 
+err_workq:
 err_vlan_bitmap:
 	free_netdev(netdev);
 
@@ -357,11 +632,20 @@ static void hinic_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	struct hinic_rx_mode_work *rx_mode_work;
 
 	unregister_netdev(netdev);
 
+	hinic_hwdev_cb_unregister(nic_dev->hwdev,
+				  HINIC_MGMT_MSG_CMD_LINK_STATUS);
+
+	rx_mode_work = &nic_dev->rx_mode_work;
+	cancel_work_sync(&rx_mode_work->work);
+
 	pci_set_drvdata(pdev, NULL);
 
+	destroy_workqueue(nic_dev->workq);
+
 	hinic_free_hwdev(nic_dev->hwdev);
 
 	free_netdev(netdev);
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_port.c b/drivers/net/ethernet/huawei/hinic/hinic_port.c
index 5b249e8..0dafede 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_port.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_port.c
@@ -222,3 +222,95 @@ int hinic_port_del_vlan(struct hinic_dev *nic_dev, u16 vlan_id)
 				 &port_vlan_cmd, sizeof(port_vlan_cmd),
 				 NULL, NULL);
 }
+
+/**
+ * hinic_port_set_rx_mode - set rx mode in the nic device
+ * @nic_dev: nic device
+ * @rx_mode: the rx mode to set
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_port_set_rx_mode(struct hinic_dev *nic_dev, u32 rx_mode)
+{
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_port_rx_mode_cmd rx_mode_cmd;
+
+	rx_mode_cmd.func_idx = HINIC_HWIF_FUNC_IDX(hwdev->hwif);
+	rx_mode_cmd.rx_mode = rx_mode;
+
+	return hinic_port_msg_cmd(hwdev, HINIC_PORT_CMD_SET_RX_MODE,
+				  &rx_mode_cmd, sizeof(rx_mode_cmd),
+				  NULL, NULL);
+}
+
+/**
+ * hinic_port_link_state - get the link state
+ * @nic_dev: nic device
+ * @link_state: the returned link state
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_port_link_state(struct hinic_dev *nic_dev,
+			  enum hinic_port_link_state *link_state)
+{
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct hinic_port_link_cmd link_cmd;
+	struct pci_dev *pdev = hwif->pdev;
+	u16 out_size;
+	int err;
+
+	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
+		dev_err(&pdev->dev, "unsupported PCI Function type\n");
+		return -EINVAL;
+	}
+
+	link_cmd.func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+
+	err = hinic_port_msg_cmd(hwdev, HINIC_PORT_CMD_GET_LINK_STATE,
+				 &link_cmd, sizeof(link_cmd),
+				 &link_cmd, &out_size);
+	if (err || (out_size != sizeof(link_cmd)) || link_cmd.status) {
+		dev_err(&pdev->dev, "Failed to get link state, ret = %d\n",
+			link_cmd.status);
+		return -EINVAL;
+	}
+
+	*link_state = link_cmd.state;
+	return 0;
+}
+
+/**
+ * hinic_port_set_state - set port state
+ * @nic_dev: nic device
+ * @state: the state to set
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_port_set_state(struct hinic_dev *nic_dev, enum hinic_port_state state)
+{
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_port_state_cmd port_state;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	u16 out_size;
+	int err;
+
+	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
+		dev_err(&pdev->dev, "unsupported PCI Function type\n");
+		return -EINVAL;
+	}
+
+	port_state.state = state;
+
+	err = hinic_port_msg_cmd(hwdev, HINIC_PORT_CMD_SET_PORT_STATE,
+				 &port_state, sizeof(port_state),
+				 &port_state, &out_size);
+	if (err || (out_size != sizeof(port_state)) || port_state.status) {
+		dev_err(&pdev->dev, "Failed to set port state, ret = %d\n",
+			port_state.status);
+		return -EFAULT;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_port.h b/drivers/net/ethernet/huawei/hinic/hinic_port.h
index 4cafb94..3a8da8e 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_port.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_port.h
@@ -18,9 +18,28 @@
 
 #include <linux/types.h>
 #include <linux/etherdevice.h>
+#include <linux/bitops.h>
 
 #include "hinic_dev.h"
 
+enum hinic_rx_mode {
+	HINIC_RX_MODE_UC        = BIT(0),
+	HINIC_RX_MODE_MC        = BIT(1),
+	HINIC_RX_MODE_BC        = BIT(2),
+	HINIC_RX_MODE_MC_ALL    = BIT(3),
+	HINIC_RX_MODE_PROMISC   = BIT(4),
+};
+
+enum hinic_port_link_state {
+	HINIC_LINK_STATE_DOWN,
+	HINIC_LINK_STATE_UP,
+};
+
+enum hinic_port_state {
+	HINIC_PORT_DISABLE      = 0,
+	HINIC_PORT_ENABLE       = 3,
+};
+
 struct hinic_port_mac_cmd {
 	u8              status;
 	u8              version;
@@ -51,6 +70,45 @@ struct hinic_port_vlan_cmd {
 	u16     vlan_id;
 };
 
+struct hinic_port_rx_mode_cmd {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+	u16     rsvd;
+	u32     rx_mode;
+};
+
+struct hinic_port_link_cmd {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+	u8      state;
+	u8      rsvd1;
+};
+
+struct hinic_port_state_cmd {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u8      state;
+	u8      rsvd1[3];
+};
+
+struct hinic_port_link_status {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     rsvd1;
+	u8      link;
+	u8      rsvd2;
+};
+
 int hinic_port_add_mac(struct hinic_dev *nic_dev, const u8 *addr,
 		       u16 vlan_id);
 
@@ -65,4 +123,12 @@ int hinic_port_del_mac(struct hinic_dev *nic_dev, const u8 *addr,
 
 int hinic_port_del_vlan(struct hinic_dev *nic_dev, u16 vlan_id);
 
+int hinic_port_set_rx_mode(struct hinic_dev *nic_dev, u32 rx_mode);
+
+int hinic_port_link_state(struct hinic_dev *nic_dev,
+			  enum hinic_port_link_state *link_state);
+
+int hinic_port_set_state(struct hinic_dev *nic_dev,
+			 enum hinic_port_state state);
+
 #endif
-- 
1.9.1
