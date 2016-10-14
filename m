From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next v2 4/6] fjes: ethtool -w and -W support for fjes driver
Date: Fri, 14 Oct 2016 20:27:45 +0900
Message-ID: <1476444465-28856-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1476444345-28673-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:11459 "EHLO
        mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752221AbcJNLis (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 07:38:48 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
        by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 32B81AC0075
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 20:38:45 +0900 (JST)
In-Reply-To: <1476444345-28673-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds implementation of supporting
ethtool -w and -W for fjes driver.

You can enable and disable firmware debug mode by
using ethtool -W, and also retrieve firmware
activity information by using ethtool -w.

This is useful for debugging.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_ethtool.c |  63 ++++++++++++++++++
 drivers/net/fjes/fjes_hw.c      | 137 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_hw.h      |  15 +++++
 drivers/net/fjes/fjes_trace.h   |  69 ++++++++++++++++++++
 4 files changed, 284 insertions(+)

diff --git a/drivers/net/fjes/fjes_ethtool.c b/drivers/net/fjes/fjes_ethtool.c
index 68ef287..6575f88 100644
--- a/drivers/net/fjes/fjes_ethtool.c
+++ b/drivers/net/fjes/fjes_ethtool.c
@@ -235,6 +235,66 @@ static void fjes_get_regs(struct net_device *netdev,
 	regs_buff[36] = rd32(XSCT_ICTL);
 }
 
+static int fjes_set_dump(struct net_device *netdev, struct ethtool_dump *dump)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+	int ret = 0;
+
+	if (dump->flag) {
+		if (hw->debug_mode)
+			return -EPERM;
+
+		hw->debug_mode = dump->flag;
+
+		/* enable debug mode */
+		mutex_lock(&hw->hw_info.lock);
+		ret = fjes_hw_start_debug(hw);
+		mutex_unlock(&hw->hw_info.lock);
+
+		if (ret)
+			hw->debug_mode = 0;
+	} else {
+		if (!hw->debug_mode)
+			return -EPERM;
+
+		/* disable debug mode */
+		mutex_lock(&hw->hw_info.lock);
+		ret = fjes_hw_stop_debug(hw);
+		mutex_unlock(&hw->hw_info.lock);
+	}
+
+	return ret;
+}
+
+static int fjes_get_dump_flag(struct net_device *netdev,
+			      struct ethtool_dump *dump)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+
+	dump->len = hw->hw_info.trace_size;
+	dump->version = 1;
+	dump->flag = hw->debug_mode;
+
+	return 0;
+}
+
+static int fjes_get_dump_data(struct net_device *netdev,
+			      struct ethtool_dump *dump, void *buf)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+	int ret = 0;
+
+	if (hw->hw_info.trace)
+		memcpy(buf, hw->hw_info.trace, hw->hw_info.trace_size);
+	else
+		ret = -EPERM;
+
+	return ret;
+}
+
 static const struct ethtool_ops fjes_ethtool_ops = {
 		.get_settings		= fjes_get_settings,
 		.get_drvinfo		= fjes_get_drvinfo,
@@ -243,6 +303,9 @@ static const struct ethtool_ops fjes_ethtool_ops = {
 		.get_sset_count   = fjes_get_sset_count,
 		.get_regs		= fjes_get_regs,
 		.get_regs_len		= fjes_get_regs_len,
+		.set_dump		= fjes_set_dump,
+		.get_dump_flag		= fjes_get_dump_flag,
+		.get_dump_data		= fjes_get_dump_data,
 };
 
 void fjes_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index dba59dc..9c652c0 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -343,6 +343,9 @@ int fjes_hw_init(struct fjes_hw *hw)
 
 	ret = fjes_hw_setup(hw);
 
+	hw->hw_info.trace = vzalloc(FJES_DEBUG_BUFFER_SIZE);
+	hw->hw_info.trace_size = FJES_DEBUG_BUFFER_SIZE;
+
 	return ret;
 }
 
@@ -351,6 +354,18 @@ void fjes_hw_exit(struct fjes_hw *hw)
 	int ret;
 
 	if (hw->base) {
+
+		if (hw->debug_mode) {
+			/* disable debug mode */
+			mutex_lock(&hw->hw_info.lock);
+			fjes_hw_stop_debug(hw);
+			mutex_unlock(&hw->hw_info.lock);
+		}
+		vfree(hw->hw_info.trace);
+		hw->hw_info.trace = NULL;
+		hw->hw_info.trace_size = 0;
+		hw->debug_mode = 0;
+
 		ret = fjes_hw_reset(hw);
 		if (ret)
 			pr_err("%s: reset error", __func__);
@@ -1175,3 +1190,125 @@ static void fjes_hw_epstop_task(struct work_struct *work)
 		}
 	}
 }
+
+int fjes_hw_start_debug(struct fjes_hw *hw)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	enum fjes_dev_command_response_e ret;
+	int page_count;
+	int result = 0;
+	void *addr;
+	int i;
+
+	if (!hw->hw_info.trace)
+		return -EPERM;
+	memset(hw->hw_info.trace, 0, FJES_DEBUG_BUFFER_SIZE);
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+
+	req_buf->start_trace.length =
+		FJES_DEV_COMMAND_START_DBG_REQ_LEN(hw->hw_info.trace_size);
+	req_buf->start_trace.mode = hw->debug_mode;
+	req_buf->start_trace.buffer_len = hw->hw_info.trace_size;
+	page_count = hw->hw_info.trace_size / FJES_DEBUG_PAGE_SIZE;
+	for (i = 0; i < page_count; i++) {
+		addr = ((u8 *)hw->hw_info.trace) + i * FJES_DEBUG_PAGE_SIZE;
+		req_buf->start_trace.buffer[i] =
+			(__le64)(page_to_phys(vmalloc_to_page(addr)) +
+			offset_in_page(addr));
+	}
+
+	res_buf->start_trace.length = 0;
+	res_buf->start_trace.code = 0;
+
+	trace_fjes_hw_start_debug_req(req_buf);
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_START_DEBUG);
+	trace_fjes_hw_start_debug(res_buf);
+
+	if (res_buf->start_trace.length !=
+		FJES_DEV_COMMAND_START_DBG_RES_LEN) {
+		result = -ENOMSG;
+		trace_fjes_hw_start_debug_err("Invalid res_buf");
+	} else if (ret == FJES_CMD_STATUS_NORMAL) {
+		switch (res_buf->start_trace.code) {
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
+			trace_fjes_hw_start_debug_err("Busy Timeout");
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
+int fjes_hw_stop_debug(struct fjes_hw *hw)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	enum fjes_dev_command_response_e ret;
+	int result = 0;
+
+	if (!hw->hw_info.trace)
+		return -EPERM;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+	req_buf->stop_trace.length = FJES_DEV_COMMAND_STOP_DBG_REQ_LEN;
+
+	res_buf->stop_trace.length = 0;
+	res_buf->stop_trace.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_STOP_DEBUG);
+	trace_fjes_hw_stop_debug(res_buf);
+
+	if (res_buf->stop_trace.length != FJES_DEV_COMMAND_STOP_DBG_RES_LEN) {
+		trace_fjes_hw_stop_debug_err("Invalid res_buf");
+		result = -ENOMSG;
+	} else if (ret == FJES_CMD_STATUS_NORMAL) {
+		switch (res_buf->stop_trace.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			hw->debug_mode = 0;
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
+			trace_fjes_hw_stop_debug_err("Busy Timeout");
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
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index 205182e..3a6da09 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -33,6 +33,9 @@ struct fjes_hw;
 #define EP_BUFFER_SUPPORT_VLAN_MAX 4
 #define EP_BUFFER_INFO_SIZE 4096
 
+#define FJES_DEBUG_PAGE_SIZE 4096
+#define FJES_DEBUG_BUFFER_SIZE	(16 * FJES_DEBUG_PAGE_SIZE)
+
 #define FJES_DEVICE_RESET_TIMEOUT  ((17 + 1) * 3 * 8) /* sec */
 #define FJES_COMMAND_REQ_TIMEOUT  ((5 + 1) * 3 * 8) /* sec */
 #define FJES_COMMAND_REQ_BUFF_TIMEOUT	(60 * 3) /* sec */
@@ -94,6 +97,12 @@ struct fjes_hw;
 #define FJES_DEV_RES_BUF_SIZE(maxep) \
 	FJES_DEV_COMMAND_INFO_RES_LEN(maxep)
 
+#define FJES_DEV_COMMAND_START_DBG_REQ_LEN(byte) \
+	(16 + (8 * (byte) / FJES_DEBUG_PAGE_SIZE))
+#define FJES_DEV_COMMAND_START_DBG_RES_LEN (8)
+#define FJES_DEV_COMMAND_STOP_DBG_REQ_LEN (4)
+#define FJES_DEV_COMMAND_STOP_DBG_RES_LEN (8)
+
 /* Frame & MTU */
 struct esmem_frame {
 	__le32 frame_size;
@@ -173,6 +182,8 @@ enum fjes_dev_command_request_type {
 	FJES_CMD_REQ_INFO		= 0x0001,
 	FJES_CMD_REQ_SHARE_BUFFER	= 0x0002,
 	FJES_CMD_REQ_UNSHARE_BUFFER	= 0x0004,
+	FJES_CMD_REQ_START_DEBUG	= 0x0100,
+	FJES_CMD_REQ_STOP_DEBUG		= 0x0200,
 };
 
 /* parameter for command control */
@@ -321,6 +332,8 @@ struct fjes_hw {
 	struct fjes_hw_info hw_info;
 
 	spinlock_t rx_status_lock; /* spinlock for rx_status */
+
+	u32 debug_mode;
 };
 
 int fjes_hw_init(struct fjes_hw *);
@@ -353,4 +366,6 @@ void *fjes_hw_epbuf_rx_curpkt_get_addr(struct epbuf_handler *, size_t *);
 void fjes_hw_epbuf_rx_curpkt_drop(struct epbuf_handler *);
 int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *, void *, size_t);
 
+int fjes_hw_start_debug(struct fjes_hw *);
+int fjes_hw_stop_debug(struct fjes_hw *);
 #endif /* FJES_HW_H_ */
diff --git a/drivers/net/fjes/fjes_trace.h b/drivers/net/fjes/fjes_trace.h
index 1f0a489..22e8f1a 100644
--- a/drivers/net/fjes/fjes_trace.h
+++ b/drivers/net/fjes/fjes_trace.h
@@ -209,6 +209,75 @@ TRACE_EVENT(fjes_hw_unregister_buff_addr_err,
 	TP_printk("%s", __get_str(err))
 );
 
+TRACE_EVENT(fjes_hw_start_debug_req,
+	TP_PROTO(union fjes_device_command_req *req_buf),
+	TP_ARGS(req_buf),
+	TP_STRUCT__entry(
+		__field(int, length)
+		__field(int, mode)
+		__field(phys_addr_t, buffer)
+	),
+	TP_fast_assign(
+		__entry->length = req_buf->start_trace.length;
+		__entry->mode = req_buf->start_trace.mode;
+		__entry->buffer = req_buf->start_trace.buffer[0];
+	),
+	TP_printk("req_buf=[length=%d, mode=%d, buffer=%p]",
+		  __entry->length, __entry->mode, (void *)__entry->buffer)
+);
+
+TRACE_EVENT(fjes_hw_start_debug,
+	TP_PROTO(union fjes_device_command_res *res_buf),
+	TP_ARGS(res_buf),
+	TP_STRUCT__entry(
+		__field(int, length)
+		__field(int, code)
+	),
+	TP_fast_assign(
+		__entry->length = res_buf->start_trace.length;
+		__entry->code = res_buf->start_trace.code;
+	),
+	TP_printk("res_buf=[length=%d, code=%d]", __entry->length, __entry->code)
+);
+
+TRACE_EVENT(fjes_hw_start_debug_err,
+	TP_PROTO(char *err),
+	TP_ARGS(err),
+	TP_STRUCT__entry(
+		 __string(err, err)
+	),
+	TP_fast_assign(
+		__assign_str(err, err)
+	),
+	TP_printk("%s", __get_str(err))
+);
+
+TRACE_EVENT(fjes_hw_stop_debug,
+	TP_PROTO(union fjes_device_command_res *res_buf),
+	TP_ARGS(res_buf),
+	TP_STRUCT__entry(
+		__field(int, length)
+		__field(int, code)
+	),
+	TP_fast_assign(
+		__entry->length = res_buf->stop_trace.length;
+		__entry->code = res_buf->stop_trace.code;
+	),
+	TP_printk("res_buf=[length=%d, code=%d]", __entry->length, __entry->code)
+);
+
+TRACE_EVENT(fjes_hw_stop_debug_err,
+	TP_PROTO(char *err),
+	TP_ARGS(err),
+	TP_STRUCT__entry(
+		 __string(err, err)
+	),
+	TP_fast_assign(
+		__assign_str(err, err)
+	),
+	TP_printk("%s", __get_str(err))
+);
+
 /* tracepoints for fjes_main.c */
 
 TRACE_EVENT(fjes_txrx_stop_req_irq_pre,
-- 
2.6.6
