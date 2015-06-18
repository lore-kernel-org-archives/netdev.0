From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 05/22] fjes: ES information acquisition routine
Date: Thu, 18 Jun 2015 09:49:30 +0900
Message-ID: <1434588587-25655-5-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds ES information acquisition routine.
ES information can be retrieved issuing information
request command. ES information includes which
receiver is same zone.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes_hw.c   | 101 ++++++++++++++++++++++++++++++++++
 drivers/platform/x86/fjes/fjes_hw.h   |  24 ++++++++
 drivers/platform/x86/fjes/fjes_regs.h |  23 ++++++++
 3 files changed, 148 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes_hw.c b/drivers/platform/x86/fjes/fjes_hw.c
index d1f090a..eb04d9a 100644
--- a/drivers/platform/x86/fjes/fjes_hw.c
+++ b/drivers/platform/x86/fjes/fjes_hw.c
@@ -360,6 +360,107 @@ void fjes_hw_exit(struct fjes_hw *hw)
 	fjes_hw_cleanup(hw);
 }
 
+static enum fjes_dev_command_response_e fjes_hw_issue_request_command(
+	struct fjes_hw *hw, enum fjes_dev_command_request_type type)
+{
+	union REG_CR cr;
+	union REG_CS cs;
+	enum fjes_dev_command_response_e ret = FJES_CMD_STATUS_UNKNOWN;
+	int timeout;
+
+	cr.Reg = 0;
+	cr.Bits.req_start = 1;
+	cr.Bits.req_code = type;
+	wr32(XSCT_CR, cr.Reg);
+	cr.Reg = rd32(XSCT_CR);
+
+	if (cr.Bits.error == 0) {
+		timeout = FJES_COMMAND_REQ_TIMEOUT * 1000;
+		cs.Reg = rd32(XSCT_CS);
+
+		while ((cs.Bits.complete != 1) && timeout > 0) {
+			msleep(1000);
+			cs.Reg = rd32(XSCT_CS);
+			timeout -= 1000;
+		}
+
+		if (cs.Bits.complete == 1)
+			ret = FJES_CMD_STATUS_NORMAL;
+		else if (timeout <= 0)
+			ret = FJES_CMD_STATUS_TIMEOUT;
+
+	} else {
+		switch (cr.Bits.err_info) {
+		case FJES_CMD_REQ_ERR_INFO_PARAM:
+			ret = FJES_CMD_STATUS_ERROR_PARAM;
+			break;
+		case FJES_CMD_REQ_ERR_INFO_STATUS:
+			ret = FJES_CMD_STATUS_ERROR_STATUS;
+			break;
+		default:
+			ret = FJES_CMD_STATUS_UNKNOWN;
+			break;
+		}
+	}
+
+	return ret;
+}
+
+int fjes_hw_request_info(struct fjes_hw *hw)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	enum fjes_dev_command_response_e ret;
+	int result;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+
+	req_buf->info.length = FJES_DEV_COMMAND_INFO_REQ_LEN;
+
+	res_buf->info.length = 0;
+	res_buf->info.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_INFO);
+
+	result = 0;
+
+	if (FJES_DEV_COMMAND_INFO_RES_LEN((*(hw->hw_info.max_epid))) !=
+		res_buf->info.length) {
+		result = -ENOMSG;
+	} else if (ret == FJES_CMD_STATUS_NORMAL) {
+
+		switch (res_buf->info.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			break;
+		default:
+			result = -EPERM;
+			break;
+		}
+	} else {
+		switch (ret) {
+		case FJES_CMD_STATUS_UNKNOWN:
+			result = -EPERM;
+			break;
+		case FJES_CMD_STATUS_TIMEOUT:
+			result = -EBUSY;
+			break;
+		case FJES_CMD_STATUS_ERROR_PARAM:
+			result = -EPERM;
+			break;
+		case FJES_CMD_STATUS_ERROR_STATUS:
+			result = -EPERM;
+			break;
+		default:
+			result = -EPERM;
+			break;
+		}
+	}
+
+	return result;
+}
+
 void fjes_hw_set_irqmask(struct fjes_hw *hw, enum REG_ICTL_MASK intr_mask,
 		bool mask)
 {
diff --git a/drivers/platform/x86/fjes/fjes_hw.h b/drivers/platform/x86/fjes/fjes_hw.h
index 0bb2d51..7861fe3 100644
--- a/drivers/platform/x86/fjes/fjes_hw.h
+++ b/drivers/platform/x86/fjes/fjes_hw.h
@@ -33,6 +33,12 @@ struct fjes_hw;
 #define EP_BUFFER_INFO_SIZE 4096
 
 #define FJES_DEVICE_RESET_TIMEOUT  ((17 + 1) * 3) /* sec */
+#define FJES_COMMAND_REQ_TIMEOUT  (5 + 1) /* sec */
+
+#define FJES_CMD_REQ_ERR_INFO_PARAM  (0x0001)
+#define FJES_CMD_REQ_ERR_INFO_STATUS (0x0002)
+
+#define FJES_CMD_REQ_RES_CODE_NORMAL (0)
 
 #define EP_BUFFER_SIZE \
 	(((sizeof(union ep_buffer_info) + (128 * (64 * 1024))) \
@@ -49,6 +55,7 @@ struct fjes_hw;
 	((size) - sizeof(struct esmem_frame_t) - \
 	(ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
 
+#define FJES_DEV_COMMAND_INFO_REQ_LEN	(4)
 #define FJES_DEV_COMMAND_INFO_RES_LEN(epnum) (8 + 2*(epnum))
 #define FJES_DEV_COMMAND_SHARE_BUFFER_REQ_LEN(txb, rxb) \
 	(24 + (8 * ((txb)/EP_BUFFER_INFO_SIZE + (rxb)/EP_BUFFER_INFO_SIZE)))
@@ -124,6 +131,13 @@ union fjes_device_command_res {
 	} stop_trace;
 };
 
+/* request command type */
+enum fjes_dev_command_request_type {
+	FJES_CMD_REQ_INFO			= 0x0001,
+	FJES_CMD_REQ_SHARE_BUFFER	= 0x0002,
+	FJES_CMD_REQ_UNSHARE_BUFFER = 0x0004,
+};
+
 /* parameter for command control */
 struct fjes_device_command_param {
 	u32 req_len;
@@ -133,6 +147,15 @@ struct fjes_device_command_param {
 	phys_addr_t share_start;
 };
 
+/* error code for command control */
+enum fjes_dev_command_response_e {
+	FJES_CMD_STATUS_UNKNOWN,
+	FJES_CMD_STATUS_NORMAL,
+	FJES_CMD_STATUS_TIMEOUT,
+	FJES_CMD_STATUS_ERROR_PARAM,
+	FJES_CMD_STATUS_ERROR_STATUS,
+};
+
 /* EP buffer information */
 union ep_buffer_info {
 	u8 raw[EP_BUFFER_INFO_SIZE];
@@ -246,6 +269,7 @@ struct fjes_hw {
 int fjes_hw_init(struct fjes_hw *);
 void fjes_hw_exit(struct fjes_hw *);
 int fjes_hw_reset(struct fjes_hw *);
+int fjes_hw_request_info(struct fjes_hw *);
 
 void fjes_hw_init_command_registers(struct fjes_hw *,
 		struct fjes_device_command_param *);
diff --git a/drivers/platform/x86/fjes/fjes_regs.h b/drivers/platform/x86/fjes/fjes_regs.h
index 1e79976..e7acf1f 100644
--- a/drivers/platform/x86/fjes/fjes_regs.h
+++ b/drivers/platform/x86/fjes/fjes_regs.h
@@ -38,6 +38,8 @@
 #define XSCT_DCTL           0x0010  /* Device Control */
 
 /* Command Control registers */
+#define XSCT_CR             0x0020  /* Command request */
+#define XSCT_CS             0x0024  /* Command status */
 #define XSCT_SHSTSAL        0x0028  /* Share status address Low */
 #define XSCT_SHSTSAH        0x002C  /* Share status address High */
 
@@ -85,6 +87,27 @@ union REG_DCTL {
 	__le32 Reg;
 };
 
+/* Command Control registers */
+union REG_CR {
+	struct {
+		__le32 req_code:16;
+		__le32 err_info:14;
+		__le32 error:1;
+		__le32 req_start:1;
+	} Bits;
+	__le32 Reg;
+};
+
+union REG_CS {
+	struct {
+		__le32 req_code:16;
+		__le32 rsv0:14;
+		__le32 busy:1;
+		__le32 complete:1;
+	} Bits;
+	__le32 Reg;
+};
+
 enum REG_ICTL_MASK {
 	REG_ICTL_MASK_INFO_UPDATE     = 1 << 20,
 	REG_ICTL_MASK_DEV_STOP_REQ    = 1 << 19,
-- 
1.8.3.1
