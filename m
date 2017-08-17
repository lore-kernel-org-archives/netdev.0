From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V5 net-next 05/21] net-next/hinic: Add management messages
Date: Thu, 17 Aug 2017 19:52:46 +0800
Message-ID: <45e5341bec32ed73fa06deed413ee8747bb4aa9e.1502970631.git.aviad.krawczyk@huawei.com>
References: <cover.1502970631.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502970631.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the management messages for sending to api cmd and add the
asynchronous event handler for the completion of the messages.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 .../net/ethernet/huawei/hinic/hinic_hw_api_cmd.c   |  35 ++
 .../net/ethernet/huawei/hinic/hinic_hw_api_cmd.h   |   3 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h    |   5 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c  | 439 ++++++++++++++++++++-
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h  |  59 +++
 5 files changed, 538 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
index 234ede9..b44ddf2 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
@@ -54,6 +54,41 @@ enum api_cmd_xor_chk_level {
 };
 
 /**
+ * api_cmd - API CMD command
+ * @chain: chain for the command
+ * @dest: destination node on the card that will receive the command
+ * @cmd: command data
+ * @size: the command size
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int api_cmd(struct hinic_api_cmd_chain *chain,
+		   enum hinic_node_id dest, u8 *cmd, u16 cmd_size)
+{
+	/* should be implemented */
+	return -EINVAL;
+}
+
+/**
+ * hinic_api_cmd_write - Write API CMD command
+ * @chain: chain for write command
+ * @dest: destination node on the card that will receive the command
+ * @cmd: command data
+ * @size: the command size
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_api_cmd_write(struct hinic_api_cmd_chain *chain,
+			enum hinic_node_id dest, u8 *cmd, u16 size)
+{
+	/* Verify the chain type */
+	if (chain->chain_type == HINIC_API_CMD_WRITE_TO_MGMT_CPU)
+		return api_cmd(chain, dest, cmd, size);
+
+	return -EINVAL;
+}
+
+/**
  * api_cmd_hw_restart - restart the chain in the HW
  * @chain: the API CMD specific chain to restart
  *
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h
index 0c83b80..e8865d6 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h
@@ -132,6 +132,9 @@ struct hinic_api_cmd_chain {
 	struct hinic_api_cmd_cell       *curr_node;
 };
 
+int hinic_api_cmd_write(struct hinic_api_cmd_chain *chain,
+			enum hinic_node_id dest, u8 *cmd, u16 size);
+
 int hinic_api_cmd_init(struct hinic_api_cmd_chain **chain,
 		       struct hinic_hwif *hwif);
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
index b6d9850..98623d6 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
@@ -93,6 +93,7 @@
 #define HINIC_HWIF_NUM_IRQS(hwif)       ((hwif)->attr.num_irqs)
 #define HINIC_HWIF_FUNC_IDX(hwif)       ((hwif)->attr.func_idx)
 #define HINIC_HWIF_PCI_INTF(hwif)       ((hwif)->attr.pci_intf_idx)
+#define HINIC_HWIF_PF_IDX(hwif)         ((hwif)->attr.pf_idx)
 
 #define HINIC_FUNC_TYPE(hwif)           ((hwif)->attr.func_type)
 #define HINIC_IS_PF(hwif)               (HINIC_FUNC_TYPE(hwif) == HINIC_PF)
@@ -127,6 +128,10 @@ enum hinic_mod_type {
 	HINIC_MOD_MAX   = 15
 };
 
+enum hinic_node_id {
+	HINIC_NODE_ID_MGMT = 21,
+};
+
 struct hinic_func_attr {
 	u16                     func_idx;
 	u8                      pf_idx;
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c
index f914bc7..147c404 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c
@@ -16,6 +16,12 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/errno.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/semaphore.h>
+#include <linux/completion.h>
+#include <linux/slab.h>
+#include <asm/barrier.h>
 
 #include "hinic_hw_if.h"
 #include "hinic_hw_eqs.h"
@@ -23,9 +29,267 @@
 #include "hinic_hw_mgmt.h"
 #include "hinic_hw_dev.h"
 
+#define SYNC_MSG_ID_MASK                0x1FF
+
+#define SYNC_MSG_ID(pf_to_mgmt)         ((pf_to_mgmt)->sync_msg_id)
+
+#define SYNC_MSG_ID_INC(pf_to_mgmt)     (SYNC_MSG_ID(pf_to_mgmt) = \
+					((SYNC_MSG_ID(pf_to_mgmt) + 1) & \
+					 SYNC_MSG_ID_MASK))
+
+#define MSG_SZ_IS_VALID(in_size)        ((in_size) <= MAX_MSG_LEN)
+
+#define MGMT_MSG_LEN_MIN                20
+#define MGMT_MSG_LEN_STEP               16
+#define MGMT_MSG_RSVD_FOR_DEV           8
+
+#define SEGMENT_LEN                     48
+
+#define MAX_PF_MGMT_BUF_SIZE            2048
+
+/* Data should be SEG LEN size aligned */
+#define MAX_MSG_LEN                     2016
+
+#define MSG_NOT_RESP                    0xFFFF
+
+#define MGMT_MSG_TIMEOUT                1000
+
 #define mgmt_to_pfhwdev(pf_mgmt)        \
 		container_of(pf_mgmt, struct hinic_pfhwdev, pf_to_mgmt)
 
+enum msg_segment_type {
+	NOT_LAST_SEGMENT        = 0,
+	LAST_SEGMENT            = 1,
+};
+
+enum mgmt_direction_type {
+	MGMT_DIRECT_SEND        = 0,
+	MGMT_RESP               = 1,
+};
+
+enum msg_ack_type {
+	MSG_ACK         = 0,
+	MSG_NO_ACK      = 1,
+};
+
+/**
+ * prepare_header - prepare the header of the message
+ * @pf_to_mgmt: PF to MGMT channel
+ * @msg_len: the length of the message
+ * @mod: module in the chip that will get the message
+ * @ack_type: ask for response
+ * @direction: the direction of the message
+ * @cmd: command of the message
+ * @msg_id: message id
+ *
+ * Return the prepared header value
+ **/
+static u64 prepare_header(struct hinic_pf_to_mgmt *pf_to_mgmt,
+			  u16 msg_len, enum hinic_mod_type mod,
+			  enum msg_ack_type ack_type,
+			  enum mgmt_direction_type direction,
+			  u16 cmd, u16 msg_id)
+{
+	struct hinic_hwif *hwif = pf_to_mgmt->hwif;
+
+	return HINIC_MSG_HEADER_SET(msg_len, MSG_LEN)           |
+	       HINIC_MSG_HEADER_SET(mod, MODULE)                |
+	       HINIC_MSG_HEADER_SET(SEGMENT_LEN, SEG_LEN)       |
+	       HINIC_MSG_HEADER_SET(ack_type, NO_ACK)           |
+	       HINIC_MSG_HEADER_SET(0, ASYNC_MGMT_TO_PF)        |
+	       HINIC_MSG_HEADER_SET(0, SEQID)                   |
+	       HINIC_MSG_HEADER_SET(LAST_SEGMENT, LAST)         |
+	       HINIC_MSG_HEADER_SET(direction, DIRECTION)       |
+	       HINIC_MSG_HEADER_SET(cmd, CMD)                   |
+	       HINIC_MSG_HEADER_SET(HINIC_HWIF_PCI_INTF(hwif), PCI_INTF) |
+	       HINIC_MSG_HEADER_SET(HINIC_HWIF_PF_IDX(hwif), PF_IDX)     |
+	       HINIC_MSG_HEADER_SET(msg_id, MSG_ID);
+}
+
+/**
+ * prepare_mgmt_cmd - prepare the mgmt command
+ * @mgmt_cmd: pointer to the command to prepare
+ * @header: pointer of the header for the message
+ * @msg: the data of the message
+ * @msg_len: the length of the message
+ **/
+static void prepare_mgmt_cmd(u8 *mgmt_cmd, u64 *header, u8 *msg, u16 msg_len)
+{
+	memset(mgmt_cmd, 0, MGMT_MSG_RSVD_FOR_DEV);
+
+	mgmt_cmd += MGMT_MSG_RSVD_FOR_DEV;
+	memcpy(mgmt_cmd, header, sizeof(*header));
+
+	mgmt_cmd += sizeof(*header);
+	memcpy(mgmt_cmd, msg, msg_len);
+}
+
+/**
+ * mgmt_msg_len - calculate the total message length
+ * @msg_data_len: the length of the message data
+ *
+ * Return the total message length
+ **/
+static u16 mgmt_msg_len(u16 msg_data_len)
+{
+	/* RSVD + HEADER_SIZE + DATA_LEN */
+	u16 msg_len = MGMT_MSG_RSVD_FOR_DEV + sizeof(u64) + msg_data_len;
+
+	if (msg_len > MGMT_MSG_LEN_MIN)
+		msg_len = MGMT_MSG_LEN_MIN +
+			   ALIGN((msg_len - MGMT_MSG_LEN_MIN),
+				 MGMT_MSG_LEN_STEP);
+	else
+		msg_len = MGMT_MSG_LEN_MIN;
+
+	return msg_len;
+}
+
+/**
+ * send_msg_to_mgmt - send message to mgmt by API CMD
+ * @pf_to_mgmt: PF to MGMT channel
+ * @mod: module in the chip that will get the message
+ * @cmd: command of the message
+ * @data: the msg data
+ * @data_len: the msg data length
+ * @ack_type: ask for response
+ * @direction: the direction of the original message
+ * @resp_msg_id: msg id to response for
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int send_msg_to_mgmt(struct hinic_pf_to_mgmt *pf_to_mgmt,
+			    enum hinic_mod_type mod, u8 cmd,
+			    u8 *data, u16 data_len,
+			    enum msg_ack_type ack_type,
+			    enum mgmt_direction_type direction,
+			    u16 resp_msg_id)
+{
+	struct hinic_api_cmd_chain *chain;
+	u64 header;
+	u16 msg_id;
+
+	msg_id = SYNC_MSG_ID(pf_to_mgmt);
+
+	if (direction == MGMT_RESP) {
+		header = prepare_header(pf_to_mgmt, data_len, mod, ack_type,
+					direction, cmd, resp_msg_id);
+	} else {
+		SYNC_MSG_ID_INC(pf_to_mgmt);
+		header = prepare_header(pf_to_mgmt, data_len, mod, ack_type,
+					direction, cmd, msg_id);
+	}
+
+	prepare_mgmt_cmd(pf_to_mgmt->sync_msg_buf, &header, data, data_len);
+
+	chain = pf_to_mgmt->cmd_chain[HINIC_API_CMD_WRITE_TO_MGMT_CPU];
+	return hinic_api_cmd_write(chain, HINIC_NODE_ID_MGMT,
+				   pf_to_mgmt->sync_msg_buf,
+				   mgmt_msg_len(data_len));
+}
+
+/**
+ * msg_to_mgmt_sync - send sync message to mgmt
+ * @pf_to_mgmt: PF to MGMT channel
+ * @mod: module in the chip that will get the message
+ * @cmd: command of the message
+ * @buf_in: the msg data
+ * @in_size: the msg data length
+ * @buf_out: response
+ * @out_size: response length
+ * @direction: the direction of the original message
+ * @resp_msg_id: msg id to response for
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int msg_to_mgmt_sync(struct hinic_pf_to_mgmt *pf_to_mgmt,
+			    enum hinic_mod_type mod, u8 cmd,
+			    u8 *buf_in, u16 in_size,
+			    u8 *buf_out, u16 *out_size,
+			    enum mgmt_direction_type direction,
+			    u16 resp_msg_id)
+{
+	struct hinic_hwif *hwif = pf_to_mgmt->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_recv_msg *recv_msg;
+	struct completion *recv_done;
+	u16 msg_id;
+	int err;
+
+	/* Lock the sync_msg_buf */
+	down(&pf_to_mgmt->sync_msg_lock);
+
+	recv_msg = &pf_to_mgmt->recv_resp_msg_from_mgmt;
+	recv_done = &recv_msg->recv_done;
+
+	if (resp_msg_id == MSG_NOT_RESP)
+		msg_id = SYNC_MSG_ID(pf_to_mgmt);
+	else
+		msg_id = resp_msg_id;
+
+	init_completion(recv_done);
+
+	err = send_msg_to_mgmt(pf_to_mgmt, mod, cmd, buf_in, in_size,
+			       MSG_ACK, direction, resp_msg_id);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to send sync msg to mgmt\n");
+		goto unlock_sync_msg;
+	}
+
+	if (!wait_for_completion_timeout(recv_done, MGMT_MSG_TIMEOUT)) {
+		dev_err(&pdev->dev, "MGMT timeout, MSG id = %d\n", msg_id);
+		err = -ETIMEDOUT;
+		goto unlock_sync_msg;
+	}
+
+	smp_rmb();      /* verify reading after completion */
+
+	if (recv_msg->msg_id != msg_id) {
+		dev_err(&pdev->dev, "incorrect MSG for id = %d\n", msg_id);
+		err = -EFAULT;
+		goto unlock_sync_msg;
+	}
+
+	if ((buf_out) && (recv_msg->msg_len <= MAX_PF_MGMT_BUF_SIZE)) {
+		memcpy(buf_out, recv_msg->msg, recv_msg->msg_len);
+		*out_size = recv_msg->msg_len;
+	}
+
+unlock_sync_msg:
+	up(&pf_to_mgmt->sync_msg_lock);
+	return err;
+}
+
+/**
+ * msg_to_mgmt_async - send message to mgmt without response
+ * @pf_to_mgmt: PF to MGMT channel
+ * @mod: module in the chip that will get the message
+ * @cmd: command of the message
+ * @buf_in: the msg data
+ * @in_size: the msg data length
+ * @direction: the direction of the original message
+ * @resp_msg_id: msg id to response for
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int msg_to_mgmt_async(struct hinic_pf_to_mgmt *pf_to_mgmt,
+			     enum hinic_mod_type mod, u8 cmd,
+			     u8 *buf_in, u16 in_size,
+			     enum mgmt_direction_type direction,
+			     u16 resp_msg_id)
+{
+	int err;
+
+	/* Lock the sync_msg_buf */
+	down(&pf_to_mgmt->sync_msg_lock);
+
+	err = send_msg_to_mgmt(pf_to_mgmt, mod, cmd, buf_in, in_size,
+			       MSG_NO_ACK, direction, resp_msg_id);
+
+	up(&pf_to_mgmt->sync_msg_lock);
+	return err;
+}
+
 /**
  * hinic_msg_to_mgmt - send message to mgmt
  * @pf_to_mgmt: PF to MGMT channel
@@ -44,8 +308,98 @@ int hinic_msg_to_mgmt(struct hinic_pf_to_mgmt *pf_to_mgmt,
 		      void *buf_in, u16 in_size, void *buf_out, u16 *out_size,
 		      enum hinic_mgmt_msg_type sync)
 {
-	/* should be implemented */
-	return -EINVAL;
+	struct hinic_hwif *hwif = pf_to_mgmt->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+
+	if (sync != HINIC_MGMT_MSG_SYNC) {
+		dev_err(&pdev->dev, "Invalid MGMT msg type\n");
+		return -EINVAL;
+	}
+
+	if (!MSG_SZ_IS_VALID(in_size)) {
+		dev_err(&pdev->dev, "Invalid MGMT msg buffer size\n");
+		return -EINVAL;
+	}
+
+	return msg_to_mgmt_sync(pf_to_mgmt, mod, cmd, buf_in, in_size,
+				buf_out, out_size, MGMT_DIRECT_SEND,
+				MSG_NOT_RESP);
+}
+
+/**
+ * mgmt_recv_msg_handler - handler for message from mgmt cpu
+ * @pf_to_mgmt: PF to MGMT channel
+ * @recv_msg: received message details
+ **/
+static void mgmt_recv_msg_handler(struct hinic_pf_to_mgmt *pf_to_mgmt,
+				  struct hinic_recv_msg *recv_msg)
+{
+	struct hinic_hwif *hwif = pf_to_mgmt->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	u8 *buf_out = recv_msg->buf_out;
+	u16 out_size = 0;
+
+	dev_err(&pdev->dev, "No MGMT msg handler, mod = %d\n", recv_msg->mod);
+
+	if (!recv_msg->async_mgmt_to_pf)
+		/* MGMT sent sync msg, send the response */
+		msg_to_mgmt_async(pf_to_mgmt, recv_msg->mod, recv_msg->cmd,
+				  buf_out, out_size, MGMT_RESP,
+				  recv_msg->msg_id);
+}
+
+/**
+ * mgmt_resp_msg_handler - handler for a response message from mgmt cpu
+ * @pf_to_mgmt: PF to MGMT channel
+ * @recv_msg: received message details
+ **/
+static void mgmt_resp_msg_handler(struct hinic_pf_to_mgmt *pf_to_mgmt,
+				  struct hinic_recv_msg *recv_msg)
+{
+	wmb();  /* verify writing all, before reading */
+
+	complete(&recv_msg->recv_done);
+}
+
+/**
+ * recv_mgmt_msg_handler - handler for a message from mgmt cpu
+ * @pf_to_mgmt: PF to MGMT channel
+ * @header: the header of the message
+ * @recv_msg: received message details
+ **/
+static void recv_mgmt_msg_handler(struct hinic_pf_to_mgmt *pf_to_mgmt,
+				  u64 *header, struct hinic_recv_msg *recv_msg)
+{
+	struct hinic_hwif *hwif = pf_to_mgmt->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int seq_id, seg_len;
+	u8 *msg_body;
+
+	seq_id = HINIC_MSG_HEADER_GET(*header, SEQID);
+	seg_len = HINIC_MSG_HEADER_GET(*header, SEG_LEN);
+
+	if (seq_id >= (MAX_MSG_LEN / SEGMENT_LEN)) {
+		dev_err(&pdev->dev, "recv big mgmt msg\n");
+		return;
+	}
+
+	msg_body = (u8 *)header + sizeof(*header);
+	memcpy(recv_msg->msg + seq_id * SEGMENT_LEN, msg_body, seg_len);
+
+	if (!HINIC_MSG_HEADER_GET(*header, LAST))
+		return;
+
+	recv_msg->cmd = HINIC_MSG_HEADER_GET(*header, CMD);
+	recv_msg->mod = HINIC_MSG_HEADER_GET(*header, MODULE);
+	recv_msg->async_mgmt_to_pf = HINIC_MSG_HEADER_GET(*header,
+							  ASYNC_MGMT_TO_PF);
+	recv_msg->msg_len = HINIC_MSG_HEADER_GET(*header, MSG_LEN);
+	recv_msg->msg_id = HINIC_MSG_HEADER_GET(*header, MSG_ID);
+
+	if (HINIC_MSG_HEADER_GET(*header, DIRECTION) == MGMT_RESP)
+		mgmt_resp_msg_handler(pf_to_mgmt, recv_msg);
+	else
+		mgmt_recv_msg_handler(pf_to_mgmt, recv_msg);
 }
 
 /**
@@ -56,7 +410,77 @@ int hinic_msg_to_mgmt(struct hinic_pf_to_mgmt *pf_to_mgmt,
  **/
 static void mgmt_msg_aeqe_handler(void *handle, void *data, u8 size)
 {
-	/* should be implemented */
+	struct hinic_pf_to_mgmt *pf_to_mgmt = handle;
+	struct hinic_recv_msg *recv_msg;
+	u64 *header = (u64 *)data;
+
+	recv_msg = HINIC_MSG_HEADER_GET(*header, DIRECTION) ==
+		   MGMT_DIRECT_SEND ?
+		   &pf_to_mgmt->recv_msg_from_mgmt :
+		   &pf_to_mgmt->recv_resp_msg_from_mgmt;
+
+	recv_mgmt_msg_handler(pf_to_mgmt, header, recv_msg);
+}
+
+/**
+ * alloc_recv_msg - allocate receive message memory
+ * @pf_to_mgmt: PF to MGMT channel
+ * @recv_msg: pointer that will hold the allocated data
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int alloc_recv_msg(struct hinic_pf_to_mgmt *pf_to_mgmt,
+			  struct hinic_recv_msg *recv_msg)
+{
+	struct hinic_hwif *hwif = pf_to_mgmt->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+
+	recv_msg->msg = devm_kzalloc(&pdev->dev, MAX_PF_MGMT_BUF_SIZE,
+				     GFP_KERNEL);
+	if (!recv_msg->msg)
+		return -ENOMEM;
+
+	recv_msg->buf_out = devm_kzalloc(&pdev->dev, MAX_PF_MGMT_BUF_SIZE,
+					 GFP_KERNEL);
+	if (!recv_msg->buf_out)
+		return -ENOMEM;
+
+	return 0;
+}
+
+/**
+ * alloc_msg_buf - allocate all the message buffers of PF to MGMT channel
+ * @pf_to_mgmt: PF to MGMT channel
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int alloc_msg_buf(struct hinic_pf_to_mgmt *pf_to_mgmt)
+{
+	struct hinic_hwif *hwif = pf_to_mgmt->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int err;
+
+	err = alloc_recv_msg(pf_to_mgmt,
+			     &pf_to_mgmt->recv_msg_from_mgmt);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate recv msg\n");
+		return err;
+	}
+
+	err = alloc_recv_msg(pf_to_mgmt,
+			     &pf_to_mgmt->recv_resp_msg_from_mgmt);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate resp recv msg\n");
+		return err;
+	}
+
+	pf_to_mgmt->sync_msg_buf = devm_kzalloc(&pdev->dev,
+						MAX_PF_MGMT_BUF_SIZE,
+						GFP_KERNEL);
+	if (!pf_to_mgmt->sync_msg_buf)
+		return -ENOMEM;
+
+	return 0;
 }
 
 /**
@@ -76,6 +500,15 @@ int hinic_pf_to_mgmt_init(struct hinic_pf_to_mgmt *pf_to_mgmt,
 
 	pf_to_mgmt->hwif = hwif;
 
+	sema_init(&pf_to_mgmt->sync_msg_lock, 1);
+	pf_to_mgmt->sync_msg_id = 0;
+
+	err = alloc_msg_buf(pf_to_mgmt);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to allocate msg buffers\n");
+		return err;
+	}
+
 	err = hinic_api_cmd_init(pf_to_mgmt->cmd_chain, hwif);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to initialize cmd chains\n");
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
index dff321c..eca7ad8 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
@@ -17,10 +17,48 @@
 #define HINIC_HW_MGMT_H
 
 #include <linux/types.h>
+#include <linux/semaphore.h>
+#include <linux/completion.h>
 
 #include "hinic_hw_if.h"
 #include "hinic_hw_api_cmd.h"
 
+#define HINIC_MSG_HEADER_MSG_LEN_SHIFT                          0
+#define HINIC_MSG_HEADER_MODULE_SHIFT                           11
+#define HINIC_MSG_HEADER_SEG_LEN_SHIFT                          16
+#define HINIC_MSG_HEADER_NO_ACK_SHIFT                           22
+#define HINIC_MSG_HEADER_ASYNC_MGMT_TO_PF_SHIFT                 23
+#define HINIC_MSG_HEADER_SEQID_SHIFT                            24
+#define HINIC_MSG_HEADER_LAST_SHIFT                             30
+#define HINIC_MSG_HEADER_DIRECTION_SHIFT                        31
+#define HINIC_MSG_HEADER_CMD_SHIFT                              32
+#define HINIC_MSG_HEADER_ZEROS_SHIFT                            40
+#define HINIC_MSG_HEADER_PCI_INTF_SHIFT                         48
+#define HINIC_MSG_HEADER_PF_IDX_SHIFT                           50
+#define HINIC_MSG_HEADER_MSG_ID_SHIFT                           54
+
+#define HINIC_MSG_HEADER_MSG_LEN_MASK                           0x7FF
+#define HINIC_MSG_HEADER_MODULE_MASK                            0x1F
+#define HINIC_MSG_HEADER_SEG_LEN_MASK                           0x3F
+#define HINIC_MSG_HEADER_NO_ACK_MASK                            0x1
+#define HINIC_MSG_HEADER_ASYNC_MGMT_TO_PF_MASK                  0x1
+#define HINIC_MSG_HEADER_SEQID_MASK                             0x3F
+#define HINIC_MSG_HEADER_LAST_MASK                              0x1
+#define HINIC_MSG_HEADER_DIRECTION_MASK                         0x1
+#define HINIC_MSG_HEADER_CMD_MASK                               0xFF
+#define HINIC_MSG_HEADER_ZEROS_MASK                             0xFF
+#define HINIC_MSG_HEADER_PCI_INTF_MASK                          0x3
+#define HINIC_MSG_HEADER_PF_IDX_MASK                            0xF
+#define HINIC_MSG_HEADER_MSG_ID_MASK                            0x3FF
+
+#define HINIC_MSG_HEADER_SET(val, member)                       \
+		((u64)((val) & HINIC_MSG_HEADER_##member##_MASK) << \
+		 HINIC_MSG_HEADER_##member##_SHIFT)
+
+#define HINIC_MSG_HEADER_GET(val, member)                       \
+		(((val) >> HINIC_MSG_HEADER_##member##_SHIFT) & \
+		 HINIC_MSG_HEADER_##member##_MASK)
+
 enum hinic_mgmt_msg_type {
 	HINIC_MGMT_MSG_SYNC = 1,
 };
@@ -29,9 +67,30 @@ enum hinic_cfg_cmd {
 	HINIC_CFG_NIC_CAP = 0,
 };
 
+struct hinic_recv_msg {
+	u8                      *msg;
+	u8                      *buf_out;
+
+	struct completion       recv_done;
+
+	u16                     cmd;
+	enum hinic_mod_type     mod;
+	int                     async_mgmt_to_pf;
+
+	u16                     msg_len;
+	u16                     msg_id;
+};
+
 struct hinic_pf_to_mgmt {
 	struct hinic_hwif               *hwif;
 
+	struct semaphore                sync_msg_lock;
+	u16                             sync_msg_id;
+	u8                              *sync_msg_buf;
+
+	struct hinic_recv_msg           recv_resp_msg_from_mgmt;
+	struct hinic_recv_msg           recv_msg_from_mgmt;
+
 	struct hinic_api_cmd_chain      *cmd_chain[HINIC_API_CMD_MAX];
 };
 
-- 
1.9.1
