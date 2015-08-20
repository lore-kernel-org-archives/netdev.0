From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2.2 06/22] fjes: buffer address regist/unregistration routine
Date: Thu, 20 Aug 2015 17:46:10 +0900
Message-ID: <1440060386-13189-6-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440060306-13040-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm02.jp.fujitsu.com ([202.219.69.169]:22671 "EHLO
	mgwkm02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbbHTIvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 04:51:32 -0400
In-Reply-To: <1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds buffer address regist/unregistration routine.

This function is mainly invoked when network device's
activation (open) and deactivation (close)
in order to retist/unregist shared buffer address.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_hw.c | 186 +++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_hw.h |   9 ++-
 2 files changed, 194 insertions(+), 1 deletion(-)

diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index 3fbe68e..5f43957 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -452,6 +452,192 @@ int fjes_hw_request_info(struct fjes_hw *hw)
 	return result;
 }
 
+int fjes_hw_register_buff_addr(struct fjes_hw *hw, int dest_epid,
+			       struct ep_share_mem_info *buf_pair)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	enum fjes_dev_command_response_e ret;
+	int i, idx;
+	int page_count;
+	void *addr;
+	int timeout;
+	int result;
+
+	if (test_bit(dest_epid, &hw->hw_info.buffer_share_bit))
+		return 0;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+
+	req_buf->share_buffer.length = FJES_DEV_COMMAND_SHARE_BUFFER_REQ_LEN(
+						buf_pair->tx.size,
+						buf_pair->rx.size);
+	req_buf->share_buffer.epid = dest_epid;
+
+	idx = 0;
+	req_buf->share_buffer.buffer[idx++] = buf_pair->tx.size;
+	page_count = buf_pair->tx.size / EP_BUFFER_INFO_SIZE;
+	for (i = 0; i < page_count; i++) {
+		addr = ((u8 *)(buf_pair->tx.buffer)) +
+				(i * EP_BUFFER_INFO_SIZE);
+		req_buf->share_buffer.buffer[idx++] =
+				(__le64)(page_to_phys(vmalloc_to_page(addr)) +
+						offset_in_page(addr));
+	}
+
+	req_buf->share_buffer.buffer[idx++] = buf_pair->rx.size;
+	page_count = buf_pair->rx.size / EP_BUFFER_INFO_SIZE;
+	for (i = 0; i < page_count; i++) {
+		addr = ((u8 *)(buf_pair->rx.buffer)) +
+				(i * EP_BUFFER_INFO_SIZE);
+		req_buf->share_buffer.buffer[idx++] =
+				(__le64)(page_to_phys(vmalloc_to_page(addr)) +
+						offset_in_page(addr));
+	}
+
+	res_buf->share_buffer.length = 0;
+	res_buf->share_buffer.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_SHARE_BUFFER);
+
+	timeout = FJES_COMMAND_REQ_BUFF_TIMEOUT * 1000;
+	while ((ret == FJES_CMD_STATUS_NORMAL) &&
+	       (res_buf->share_buffer.length ==
+		FJES_DEV_COMMAND_SHARE_BUFFER_RES_LEN) &&
+	       (res_buf->share_buffer.code == FJES_CMD_REQ_RES_CODE_BUSY) &&
+	       (timeout > 0)) {
+			msleep(200 + hw->my_epid * 20);
+			timeout -= (200 + hw->my_epid * 20);
+
+			res_buf->share_buffer.length = 0;
+			res_buf->share_buffer.code = 0;
+
+			ret = fjes_hw_issue_request_command(
+					hw, FJES_CMD_REQ_SHARE_BUFFER);
+	}
+
+	result = 0;
+
+	if (res_buf->share_buffer.length !=
+			FJES_DEV_COMMAND_SHARE_BUFFER_RES_LEN)
+		result = -ENOMSG;
+	else if (ret == FJES_CMD_STATUS_NORMAL) {
+		switch (res_buf->share_buffer.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			set_bit(dest_epid, &hw->hw_info.buffer_share_bit);
+			break;
+		case FJES_CMD_REQ_RES_CODE_BUSY:
+			result = -EBUSY;
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
+		case FJES_CMD_STATUS_ERROR_STATUS:
+		default:
+			result = -EPERM;
+			break;
+		}
+	}
+
+	return result;
+}
+
+int fjes_hw_unregister_buff_addr(struct fjes_hw *hw, int dest_epid)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	struct fjes_device_shared_info *share = hw->hw_info.share;
+	enum fjes_dev_command_response_e ret;
+	int result;
+	int timeout;
+
+	if (!hw->base)
+		return -EPERM;
+
+	if (!req_buf || !res_buf || !share)
+		return -EPERM;
+
+	if (!test_bit(dest_epid, &hw->hw_info.buffer_share_bit))
+		return 0;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+
+	req_buf->unshare_buffer.length =
+			FJES_DEV_COMMAND_UNSHARE_BUFFER_REQ_LEN;
+	req_buf->unshare_buffer.epid = dest_epid;
+
+	res_buf->unshare_buffer.length = 0;
+	res_buf->unshare_buffer.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_UNSHARE_BUFFER);
+
+	timeout = FJES_COMMAND_REQ_BUFF_TIMEOUT * 1000;
+	while ((ret == FJES_CMD_STATUS_NORMAL) &&
+	       (res_buf->unshare_buffer.length ==
+		FJES_DEV_COMMAND_UNSHARE_BUFFER_RES_LEN) &&
+	       (res_buf->unshare_buffer.code ==
+		FJES_CMD_REQ_RES_CODE_BUSY) &&
+	       (timeout > 0)) {
+		msleep(200 + hw->my_epid * 20);
+			timeout -= (200 + hw->my_epid * 20);
+
+		res_buf->unshare_buffer.length = 0;
+		res_buf->unshare_buffer.code = 0;
+
+		ret =
+		fjes_hw_issue_request_command(hw, FJES_CMD_REQ_UNSHARE_BUFFER);
+	}
+
+	result = 0;
+
+	if (res_buf->unshare_buffer.length !=
+			FJES_DEV_COMMAND_UNSHARE_BUFFER_RES_LEN) {
+		result = -ENOMSG;
+	} else if (ret == FJES_CMD_STATUS_NORMAL) {
+		switch (res_buf->unshare_buffer.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			clear_bit(dest_epid, &hw->hw_info.buffer_share_bit);
+			break;
+		case FJES_CMD_REQ_RES_CODE_BUSY:
+			result = -EBUSY;
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
+		case FJES_CMD_STATUS_ERROR_STATUS:
+		default:
+			result = -EPERM;
+			break;
+		}
+	}
+
+	return result;
+}
+
 void fjes_hw_set_irqmask(struct fjes_hw *hw,
 			 enum REG_ICTL_MASK intr_mask, bool mask)
 {
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index df30d3d..5fb175c 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -35,11 +35,13 @@ struct fjes_hw;
 
 #define FJES_DEVICE_RESET_TIMEOUT  ((17 + 1) * 3) /* sec */
 #define FJES_COMMAND_REQ_TIMEOUT  (5 + 1) /* sec */
+#define FJES_COMMAND_REQ_BUFF_TIMEOUT	(8 * 3) /* sec */
 
 #define FJES_CMD_REQ_ERR_INFO_PARAM  (0x0001)
 #define FJES_CMD_REQ_ERR_INFO_STATUS (0x0002)
 
 #define FJES_CMD_REQ_RES_CODE_NORMAL (0)
+#define FJES_CMD_REQ_RES_CODE_BUSY   (1)
 
 #define EP_BUFFER_SIZE \
 	(((sizeof(union ep_buffer_info) + (128 * (64 * 1024))) \
@@ -60,6 +62,9 @@ struct fjes_hw;
 #define FJES_DEV_COMMAND_INFO_RES_LEN(epnum) (8 + 2 * (epnum))
 #define FJES_DEV_COMMAND_SHARE_BUFFER_REQ_LEN(txb, rxb) \
 	(24 + (8 * ((txb) / EP_BUFFER_INFO_SIZE + (rxb) / EP_BUFFER_INFO_SIZE)))
+#define FJES_DEV_COMMAND_SHARE_BUFFER_RES_LEN	(8)
+#define FJES_DEV_COMMAND_UNSHARE_BUFFER_REQ_LEN	(8)
+#define FJES_DEV_COMMAND_UNSHARE_BUFFER_RES_LEN	(8)
 
 #define FJES_DEV_REQ_BUF_SIZE(maxep) \
 	FJES_DEV_COMMAND_SHARE_BUFFER_REQ_LEN(EP_BUFFER_SIZE, EP_BUFFER_SIZE)
@@ -267,7 +272,9 @@ int fjes_hw_init(struct fjes_hw *);
 void fjes_hw_exit(struct fjes_hw *);
 int fjes_hw_reset(struct fjes_hw *);
 int fjes_hw_request_info(struct fjes_hw *);
-
+int fjes_hw_register_buff_addr(struct fjes_hw *, int,
+			       struct ep_share_mem_info *);
+int fjes_hw_unregister_buff_addr(struct fjes_hw *, int);
 void fjes_hw_init_command_registers(struct fjes_hw *,
 				    struct fjes_device_command_param *);
 void fjes_hw_setup_epbuf(struct epbuf_handler *, u8 *, u32);
-- 
1.8.3.1
