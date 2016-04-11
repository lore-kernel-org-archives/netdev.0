From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 01/11] fjes: Add trace-gathering facility
Date: Mon, 11 Apr 2016 17:09:57 +0900
Message-ID: <1460362197-15033-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:13832 "EHLO
	mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbcDKISb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:18:31 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 54F04AC01FF
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 17:18:15 +0900 (JST)
In-Reply-To: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces trace-gathering facility via ioctl.
This data is useful for debugging this module and firmware.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_hw.c    | 140 ++++++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_hw.h    |  16 ++++
 drivers/net/fjes/fjes_ioctl.h |  86 +++++++++++++++++++++
 drivers/net/fjes/fjes_main.c  | 171 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 413 insertions(+)
 create mode 100644 drivers/net/fjes/fjes_ioctl.h

diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index b103adb..0b0795e 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -1121,3 +1121,143 @@ static void fjes_hw_epstop_task(struct work_struct *work)
 		}
 	}
 }
+
+int fjes_hw_alloc_trace_buf(struct fjes_hw *hw, u64 trace_size, u32 mode)
+{
+	if (trace_size % EP_TRACE_PAGE_SIZE)
+		return -EINVAL;
+
+	if (FJES_DEV_COMMAND_START_TRACE_REQ_LEN(trace_size) >
+	    hw->hw_info.req_buf_size)
+		return -EINVAL;
+
+	hw->hw_info.trace = vmalloc(trace_size);
+	if (!hw->hw_info.trace)
+		return -ENOMEM;
+
+	hw->hw_info.trace_size = trace_size;
+	hw->trace_mode = mode;
+
+	return 0;
+}
+
+void fjes_hw_free_trace_buf(struct fjes_hw *hw)
+{
+	vfree(hw->hw_info.trace);
+	hw->hw_info.trace = NULL;
+	hw->hw_info.trace_size = 0;
+	hw->trace_mode = 0;
+}
+
+bool fjes_hw_trace_is_started(struct fjes_hw *hw)
+{
+	return hw->trace_started;
+}
+
+int fjes_hw_start_trace(struct fjes_hw *hw)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	enum fjes_dev_command_response_e ret;
+	int page_count;
+	int result = 0;
+	void *addr;
+	int i;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+
+	req_buf->start_trace.length =
+		FJES_DEV_COMMAND_START_TRACE_REQ_LEN(hw->hw_info.trace_size);
+	req_buf->start_trace.mode = hw->trace_mode;
+	req_buf->start_trace.buffer_len = hw->hw_info.trace_size;
+	page_count = hw->hw_info.trace_size / EP_TRACE_PAGE_SIZE;
+
+	for (i = 0; i < page_count; i++) {
+		addr = ((u8 *)hw->hw_info.trace) + i * EP_TRACE_PAGE_SIZE;
+		req_buf->start_trace.buffer[i] =
+			(__le64)(page_to_phys(vmalloc_to_page(addr)) +
+			offset_in_page(addr));
+	}
+	res_buf->start_trace.length = 0;
+	res_buf->start_trace.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_START_TRACE);
+
+	if (res_buf->start_trace.length !=
+	    FJES_DEV_COMMAND_START_TRACE_RES_LEN)
+		result = -ENOMSG;
+	else if (ret == FJES_CMD_STATUS_NORMAL) {
+		switch (res_buf->start_trace.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			hw->trace_started = true;
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
+int fjes_hw_stop_trace(struct fjes_hw *hw)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	enum fjes_dev_command_response_e ret;
+	int result = 0;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+	req_buf->stop_trace.length = FJES_DEV_COMMAND_STOP_TRACE_RES_LEN;
+	res_buf->stop_trace.length = 0;
+	res_buf->stop_trace.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_STOP_TRACE);
+
+	if (res_buf->stop_trace.length != FJES_DEV_COMMAND_STOP_TRACE_RES_LEN) {
+		result = -ENOMSG;
+	} else if (ret == FJES_CMD_STATUS_NORMAL) {
+		switch (res_buf->stop_trace.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			hw->trace_started = false;
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
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index 6d57b89..38be7d9 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -32,6 +32,7 @@ struct fjes_hw;
 
 #define EP_BUFFER_SUPPORT_VLAN_MAX 4
 #define EP_BUFFER_INFO_SIZE 4096
+#define EP_TRACE_PAGE_SIZE 4096
 
 #define FJES_DEVICE_RESET_TIMEOUT  ((17 + 1) * 3) /* sec */
 #define FJES_COMMAND_REQ_TIMEOUT  (5 + 1) /* sec */
@@ -93,6 +94,11 @@ struct fjes_hw;
 #define FJES_DEV_RES_BUF_SIZE(maxep) \
 	FJES_DEV_COMMAND_INFO_RES_LEN(maxep)
 
+#define FJES_DEV_COMMAND_START_TRACE_REQ_LEN(byte) (16 + (8 * (byte) / EP_TRACE_PAGE_SIZE))
+#define FJES_DEV_COMMAND_START_TRACE_RES_LEN (8)
+#define FJES_DEV_COMMAND_STOP_TRACE_REQ_LEN (4)
+#define FJES_DEV_COMMAND_STOP_TRACE_RES_LEN (8)
+
 /* Frame & MTU */
 struct esmem_frame {
 	__le32 frame_size;
@@ -172,6 +178,8 @@ enum fjes_dev_command_request_type {
 	FJES_CMD_REQ_INFO		= 0x0001,
 	FJES_CMD_REQ_SHARE_BUFFER	= 0x0002,
 	FJES_CMD_REQ_UNSHARE_BUFFER	= 0x0004,
+	FJES_CMD_REQ_START_TRACE        = 0x0100,
+	FJES_CMD_REQ_STOP_TRACE         = 0x0200,
 };
 
 /* parameter for command control */
@@ -299,6 +307,9 @@ struct fjes_hw {
 	u8 *base;
 
 	struct fjes_hw_info hw_info;
+
+	bool trace_started;
+	u32 trace_mode;
 };
 
 int fjes_hw_init(struct fjes_hw *);
@@ -331,4 +342,9 @@ void *fjes_hw_epbuf_rx_curpkt_get_addr(struct epbuf_handler *, size_t *);
 void fjes_hw_epbuf_rx_curpkt_drop(struct epbuf_handler *);
 int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *, void *, size_t);
 
+int fjes_hw_alloc_trace_buf(struct fjes_hw *, u64, u32);
+void fjes_hw_free_trace_buf(struct fjes_hw *);
+bool fjes_hw_trace_is_started(struct fjes_hw *);
+int fjes_hw_start_trace(struct fjes_hw *);
+int fjes_hw_stop_trace(struct fjes_hw *);
 #endif /* FJES_HW_H_ */
diff --git a/drivers/net/fjes/fjes_ioctl.h b/drivers/net/fjes/fjes_ioctl.h
new file mode 100644
index 0000000..35adfda
--- /dev/null
+++ b/drivers/net/fjes/fjes_ioctl.h
@@ -0,0 +1,86 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+#ifndef FJES_IOCTL_H_
+#define FJES_IOCTL_H_
+
+#define FJES_IOCTL_TRACE_START		(SIOCDEVPRIVATE + 1)
+#define FJES_IOCTL_TRACE_STOP		(SIOCDEVPRIVATE + 2)
+#define FJES_IOCTL_TRACE_GETCFG		(SIOCDEVPRIVATE + 3)
+
+struct fjes_ioctl_trace_start_req_val {
+	u32	mode;
+	u32	reserved;
+	u64	trace_size;
+};
+
+struct fjes_ioctl_trace_stop_req_val {
+	u64	trace_buff_size;
+};
+
+union fjes_ioctl_trace_req_val {
+	struct fjes_ioctl_trace_start_req_val	start;
+	struct fjes_ioctl_trace_stop_req_val	stop;
+};
+
+struct fjes_ioctl_trace_start_res_val {
+	u32	err_code;
+	u32	reserved;
+};
+
+struct fjes_ioctl_trace_getcfg_res_val {
+	u32	err_code;
+	u32	mode;
+	u64	trace_size;
+};
+
+struct fjes_ioctl_trace_stop_res_val {
+	u32	err_code;
+	u32	reserve;
+	u64	written_size;
+	u16	trace_data_buff[];
+};
+
+union fjes_ioctl_trace_res_val {
+	struct fjes_ioctl_trace_start_res_val	start;
+	struct fjes_ioctl_trace_getcfg_res_val	getcfg;
+	struct fjes_ioctl_trace_stop_res_val	stop;
+};
+
+struct fjes_ioctl_trace_param {
+	union fjes_ioctl_trace_req_val	req;
+	union fjes_ioctl_trace_res_val	res;
+};
+
+#define FJES_IOCTL_TRACE_START_ERR_NORMAL		(0x0000)
+#define FJES_IOCTL_TRACE_START_ERR_BUSY			(0x0001)
+#define FJES_IOCTL_TRACE_START_ERR_PARAM		(0x0100)
+#define FJES_IOCTL_TRACE_START_ERR_ALREADY_STARTED	(0x0200)
+#define FJES_IOCTL_TRACE_START_ERR_MEMORY		(0x0400)
+
+#define FJES_IOCTL_TRACE_STOP_ERR_NORMAL		(0x0000)
+#define FJES_IOCTL_TRACE_STOP_ERR_BUSY			(0x0001)
+#define FJES_IOCTL_TRACE_STOP_ERR_BEFORE_START		(0x0300)
+
+#define FJES_IOCTL_TRACE_GETCFG_ERR_NORMAL		(0x0000)
+#define FJES_IOCTL_TRACE_GETCFG_ERR_BEFORE_START	(0x0300)
+
+#endif /* FJES_IOCTL_H_ */
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 0ddb54f..bc6e31d 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -27,6 +27,7 @@
 #include <linux/interrupt.h>
 
 #include "fjes.h"
+#include "fjes_ioctl.h"
 
 #define MAJ 1
 #define MIN 0
@@ -61,6 +62,7 @@ fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
 static int fjes_change_mtu(struct net_device *, int);
 static int fjes_vlan_rx_add_vid(struct net_device *, __be16 proto, u16);
 static int fjes_vlan_rx_kill_vid(struct net_device *, __be16 proto, u16);
+static int fjes_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void fjes_tx_retry(struct net_device *);
 
 static int fjes_acpi_add(struct acpi_device *);
@@ -242,6 +244,7 @@ static const struct net_device_ops fjes_netdev_ops = {
 	.ndo_tx_timeout		= fjes_tx_retry,
 	.ndo_vlan_rx_add_vid	= fjes_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = fjes_vlan_rx_kill_vid,
+	.ndo_do_ioctl		= fjes_ioctl,
 };
 
 /* fjes_open - Called when a network interface is made active */
@@ -820,6 +823,174 @@ static int fjes_vlan_rx_kill_vid(struct net_device *netdev,
 	return 0;
 }
 
+static int fjes_ioctl_trace_start(struct net_device *netdev, struct ifreq *rq)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_ioctl_trace_param param;
+	struct fjes_hw *hw = &adapter->hw;
+	u64 trace_size;
+	int ret = 0;
+	u32 mode;
+
+	if (copy_from_user(&param, rq->ifr_data, sizeof(param)))
+		return -EFAULT;
+
+	if (fjes_hw_trace_is_started(hw)) {
+		param.res.start.err_code =
+			FJES_IOCTL_TRACE_START_ERR_ALREADY_STARTED;
+	}
+
+	trace_size = param.req.start.trace_size;
+	mode = param.req.start.mode;
+
+	ret = fjes_hw_alloc_trace_buf(hw, trace_size, mode);
+	switch (ret) {
+	case 0:
+		break;
+	case -EINVAL:
+		param.res.start.err_code = FJES_IOCTL_TRACE_START_ERR_PARAM;
+		goto out;
+	case -ENOMEM:
+		param.res.start.err_code = FJES_IOCTL_TRACE_START_ERR_MEMORY;
+		goto out;
+	default:
+		break;
+	}
+
+	mutex_lock(&hw->hw_info.lock);
+	ret = fjes_hw_start_trace(hw);
+	mutex_unlock(&hw->hw_info.lock);
+
+	switch (ret) {
+	case 0:
+		param.res.start.err_code = FJES_IOCTL_TRACE_START_ERR_NORMAL;
+		break;
+	case -ENOMSG:
+	case -EBUSY:
+		param.res.start.err_code = FJES_IOCTL_TRACE_START_ERR_BUSY;
+		break;
+	default:
+		param.res.start.err_code =
+			hw->hw_info.res_buf->start_trace.code;
+		break;
+	}
+
+out:
+	if (copy_to_user(rq->ifr_data, &param, sizeof(param)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int fjes_ioctl_trace_stop(struct net_device *netdev, struct ifreq *rq)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_ioctl_trace_param param;
+	struct fjes_hw *hw = &adapter->hw;
+	struct es_device_trace *trace;
+	u32 start_trace_buff_size;
+	u32 stop_trace_buff_size;
+	bool trace_done = false;
+	u32 buff_size;
+	int ret;
+
+	if (copy_from_user(&param, rq->ifr_data, sizeof(param)))
+		return -EFAULT;
+
+	if (!fjes_hw_trace_is_started(hw)) {
+		param.res.stop.err_code =
+			FJES_IOCTL_TRACE_STOP_ERR_BEFORE_START;
+		goto out;
+	}
+
+	mutex_lock(&hw->hw_info.lock);
+	ret = fjes_hw_stop_trace(hw);
+	mutex_unlock(&hw->hw_info.lock);
+
+	switch (ret) {
+	case 0:
+		param.res.stop.err_code = FJES_IOCTL_TRACE_STOP_ERR_NORMAL;
+		trace_done = true;
+		break;
+	case -ENOMSG:
+	case -EBUSY:
+		param.res.stop.err_code = FJES_IOCTL_TRACE_STOP_ERR_BUSY;
+		break;
+	default:
+		param.res.stop.err_code = hw->hw_info.res_buf->stop_trace.code;
+		break;
+	}
+
+out:
+	if (copy_to_user(rq->ifr_data, &param, sizeof(param))) {
+		if (trace_done)
+			fjes_hw_free_trace_buf(hw);
+		return -EFAULT;
+	}
+
+	if (!trace_done)
+		return 0;
+
+	start_trace_buff_size = hw->hw_info.trace_size;
+	stop_trace_buff_size = param.req.stop.trace_buff_size;
+
+	trace = hw->hw_info.trace;
+	buff_size = min(start_trace_buff_size, stop_trace_buff_size);
+
+	param.res.stop.written_size = buff_size;
+	ret = copy_to_user(rq->ifr_data, &param,
+			   sizeof(union fjes_ioctl_trace_req_val) +
+			   sizeof(struct fjes_ioctl_trace_stop_res_val));
+
+	ret = copy_to_user((rq->ifr_data +
+			    sizeof(union fjes_ioctl_trace_req_val) +
+			    sizeof(struct fjes_ioctl_trace_stop_res_val)),
+			   trace,
+			   buff_size);
+
+	fjes_hw_free_trace_buf(hw);
+
+	return ret;
+}
+
+static int fjes_ioctl_trace_getcfg(struct net_device *netdev, struct ifreq *rq)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_ioctl_trace_param param;
+	struct fjes_hw *hw = &adapter->hw;
+
+	if (copy_from_user(&param, rq->ifr_data, sizeof(param)))
+		return -EFAULT;
+
+	if (fjes_hw_trace_is_started(hw)) {
+		param.res.getcfg.err_code = FJES_IOCTL_TRACE_GETCFG_ERR_NORMAL;
+		param.res.getcfg.mode = hw->trace_mode;
+		param.res.getcfg.trace_size = hw->hw_info.trace_size;
+	} else {
+		param.res.getcfg.err_code =
+			FJES_IOCTL_TRACE_GETCFG_ERR_BEFORE_START;
+	}
+
+	if (copy_to_user(rq->ifr_data, &param, sizeof(param)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int fjes_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
+{
+	switch (cmd) {
+	case FJES_IOCTL_TRACE_START:
+		return fjes_ioctl_trace_start(netdev, rq);
+	case FJES_IOCTL_TRACE_STOP:
+		return fjes_ioctl_trace_stop(netdev, rq);
+	case FJES_IOCTL_TRACE_GETCFG:
+		return fjes_ioctl_trace_getcfg(netdev, rq);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static void fjes_txrx_stop_req_irq(struct fjes_adapter *adapter,
 				   int src_epid)
 {
-- 
2.4.3
