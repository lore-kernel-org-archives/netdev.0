From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 3/6] fjes: Add tracepoints in fjes driver
Date: Tue, 11 Oct 2016 17:55:13 +0900
Message-ID: <1476176113-18815-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1476176047-18670-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym02.jp.fujitsu.com ([211.128.242.41]:33626 "EHLO
        mgwym02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752632AbcJKJRX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 05:17:23 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
        by yt-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 2909DAC0173
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 18:06:08 +0900 (JST)
In-Reply-To: <1476176047-18670-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tracepoints in fjes driver.
This is useful for debugging purpose.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/Makefile     |   2 +-
 drivers/net/fjes/fjes_hw.c    |  25 +++-
 drivers/net/fjes/fjes_main.c  |   5 +
 drivers/net/fjes/fjes_trace.c |  30 ++++
 drivers/net/fjes/fjes_trace.h | 312 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 370 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/fjes/fjes_trace.c
 create mode 100644 drivers/net/fjes/fjes_trace.h

diff --git a/drivers/net/fjes/Makefile b/drivers/net/fjes/Makefile
index 523e3d7..6705d1b 100644
--- a/drivers/net/fjes/Makefile
+++ b/drivers/net/fjes/Makefile
@@ -27,4 +27,4 @@
 
 obj-$(CONFIG_FUJITSU_ES) += fjes.o
 
-fjes-objs := fjes_main.o fjes_hw.o fjes_ethtool.o
+fjes-objs := fjes_main.o fjes_hw.o fjes_ethtool.o fjes_trace.o
diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index 82b56e8..dba59dc 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -21,6 +21,7 @@
 
 #include "fjes_hw.h"
 #include "fjes.h"
+#include "fjes_trace.h"
 
 static void fjes_hw_update_zone_task(struct work_struct *);
 static void fjes_hw_epstop_task(struct work_struct *);
@@ -371,7 +372,7 @@ fjes_hw_issue_request_command(struct fjes_hw *hw,
 	enum fjes_dev_command_response_e ret = FJES_CMD_STATUS_UNKNOWN;
 	union REG_CR cr;
 	union REG_CS cs;
-	int timeout;
+	int timeout = FJES_COMMAND_REQ_TIMEOUT * 1000;
 
 	cr.reg = 0;
 	cr.bits.req_start = 1;
@@ -408,6 +409,8 @@ fjes_hw_issue_request_command(struct fjes_hw *hw,
 		}
 	}
 
+	trace_fjes_hw_issue_request_command(&cr, &cs, timeout, ret);
+
 	return ret;
 }
 
@@ -427,11 +430,13 @@ int fjes_hw_request_info(struct fjes_hw *hw)
 	res_buf->info.code = 0;
 
 	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_INFO);
+	trace_fjes_hw_request_info(hw, res_buf);
 
 	result = 0;
 
 	if (FJES_DEV_COMMAND_INFO_RES_LEN((*hw->hw_info.max_epid)) !=
 		res_buf->info.length) {
+		trace_fjes_hw_request_info_err("Invalid res_buf");
 		result = -ENOMSG;
 	} else if (ret == FJES_CMD_STATUS_NORMAL) {
 		switch (res_buf->info.code) {
@@ -448,6 +453,7 @@ int fjes_hw_request_info(struct fjes_hw *hw)
 			result = -EPERM;
 			break;
 		case FJES_CMD_STATUS_TIMEOUT:
+			trace_fjes_hw_request_info_err("Timeout");
 			result = -EBUSY;
 			break;
 		case FJES_CMD_STATUS_ERROR_PARAM:
@@ -512,6 +518,8 @@ int fjes_hw_register_buff_addr(struct fjes_hw *hw, int dest_epid,
 	res_buf->share_buffer.length = 0;
 	res_buf->share_buffer.code = 0;
 
+	trace_fjes_hw_register_buff_addr_req(req_buf, buf_pair);
+
 	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_SHARE_BUFFER);
 
 	timeout = FJES_COMMAND_REQ_BUFF_TIMEOUT * 1000;
@@ -532,16 +540,20 @@ int fjes_hw_register_buff_addr(struct fjes_hw *hw, int dest_epid,
 
 	result = 0;
 
+	trace_fjes_hw_register_buff_addr(res_buf, timeout);
+
 	if (res_buf->share_buffer.length !=
-			FJES_DEV_COMMAND_SHARE_BUFFER_RES_LEN)
+			FJES_DEV_COMMAND_SHARE_BUFFER_RES_LEN) {
+		trace_fjes_hw_register_buff_addr_err("Invalid res_buf");
 		result = -ENOMSG;
-	else if (ret == FJES_CMD_STATUS_NORMAL) {
+	} else if (ret == FJES_CMD_STATUS_NORMAL) {
 		switch (res_buf->share_buffer.code) {
 		case FJES_CMD_REQ_RES_CODE_NORMAL:
 			result = 0;
 			set_bit(dest_epid, &hw->hw_info.buffer_share_bit);
 			break;
 		case FJES_CMD_REQ_RES_CODE_BUSY:
+			trace_fjes_hw_register_buff_addr_err("Busy Timeout");
 			result = -EBUSY;
 			break;
 		default:
@@ -554,6 +566,7 @@ int fjes_hw_register_buff_addr(struct fjes_hw *hw, int dest_epid,
 			result = -EPERM;
 			break;
 		case FJES_CMD_STATUS_TIMEOUT:
+			trace_fjes_hw_register_buff_addr_err("Timeout");
 			result = -EBUSY;
 			break;
 		case FJES_CMD_STATUS_ERROR_PARAM:
@@ -595,6 +608,7 @@ int fjes_hw_unregister_buff_addr(struct fjes_hw *hw, int dest_epid)
 	res_buf->unshare_buffer.length = 0;
 	res_buf->unshare_buffer.code = 0;
 
+	trace_fjes_hw_unregister_buff_addr_req(req_buf);
 	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_UNSHARE_BUFFER);
 
 	timeout = FJES_COMMAND_REQ_BUFF_TIMEOUT * 1000;
@@ -616,8 +630,11 @@ int fjes_hw_unregister_buff_addr(struct fjes_hw *hw, int dest_epid)
 
 	result = 0;
 
+	trace_fjes_hw_unregister_buff_addr(res_buf, timeout);
+
 	if (res_buf->unshare_buffer.length !=
 			FJES_DEV_COMMAND_UNSHARE_BUFFER_RES_LEN) {
+		trace_fjes_hw_unregister_buff_addr_err("Invalid res_buf");
 		result = -ENOMSG;
 	} else if (ret == FJES_CMD_STATUS_NORMAL) {
 		switch (res_buf->unshare_buffer.code) {
@@ -626,6 +643,7 @@ int fjes_hw_unregister_buff_addr(struct fjes_hw *hw, int dest_epid)
 			clear_bit(dest_epid, &hw->hw_info.buffer_share_bit);
 			break;
 		case FJES_CMD_REQ_RES_CODE_BUSY:
+			trace_fjes_hw_unregister_buff_addr_err("Busy Timeout");
 			result = -EBUSY;
 			break;
 		default:
@@ -638,6 +656,7 @@ int fjes_hw_unregister_buff_addr(struct fjes_hw *hw, int dest_epid)
 			result = -EPERM;
 			break;
 		case FJES_CMD_STATUS_TIMEOUT:
+			trace_fjes_hw_unregister_buff_addr_err("Timeout");
 			result = -EBUSY;
 			break;
 		case FJES_CMD_STATUS_ERROR_PARAM:
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 03e2383..4c135ae 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -27,6 +27,7 @@
 #include <linux/interrupt.h>
 
 #include "fjes.h"
+#include "fjes_trace.h"
 
 #define MAJ 1
 #define MIN 1
@@ -904,6 +905,7 @@ static void fjes_txrx_stop_req_irq(struct fjes_adapter *adapter,
 	unsigned long flags;
 
 	status = fjes_hw_get_partner_ep_status(hw, src_epid);
+	trace_fjes_txrx_stop_req_irq_pre(hw, src_epid, status);
 	switch (status) {
 	case EP_PARTNER_UNSHARE:
 	case EP_PARTNER_COMPLETE:
@@ -934,6 +936,7 @@ static void fjes_txrx_stop_req_irq(struct fjes_adapter *adapter,
 		}
 		break;
 	}
+	trace_fjes_txrx_stop_req_irq_post(hw, src_epid);
 }
 
 static void fjes_stop_req_irq(struct fjes_adapter *adapter, int src_epid)
@@ -945,6 +948,7 @@ static void fjes_stop_req_irq(struct fjes_adapter *adapter, int src_epid)
 	set_bit(src_epid, &hw->hw_info.buffer_unshare_reserve_bit);
 
 	status = fjes_hw_get_partner_ep_status(hw, src_epid);
+	trace_fjes_stop_req_irq_pre(hw, src_epid, status);
 	switch (status) {
 	case EP_PARTNER_WAITING:
 		spin_lock_irqsave(&hw->rx_status_lock, flags);
@@ -968,6 +972,7 @@ static void fjes_stop_req_irq(struct fjes_adapter *adapter, int src_epid)
 			queue_work(adapter->control_wq, &hw->epstop_task);
 		break;
 	}
+	trace_fjes_stop_req_irq_post(hw, src_epid);
 }
 
 static void fjes_update_zone_irq(struct fjes_adapter *adapter,
diff --git a/drivers/net/fjes/fjes_trace.c b/drivers/net/fjes/fjes_trace.c
new file mode 100644
index 0000000..066fa76
--- /dev/null
+++ b/drivers/net/fjes/fjes_trace.c
@@ -0,0 +1,30 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015-2016 FUJITSU LIMITED
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
+#include <linux/module.h>
+
+#ifndef __CHECKER__
+#include "fjes_hw.h"
+
+#define CREATE_TRACE_POINTS
+#include "fjes_trace.h"
+
+#endif /* __CHECKER__ */
diff --git a/drivers/net/fjes/fjes_trace.h b/drivers/net/fjes/fjes_trace.h
new file mode 100644
index 0000000..32f9752
--- /dev/null
+++ b/drivers/net/fjes/fjes_trace.h
@@ -0,0 +1,312 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015-2016 FUJITSU LIMITED
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
+#if !defined(FJES_TRACE_H_) || defined(TRACE_HEADER_MULTI_READ)
+#define FJES_TRACE_H_
+
+#include <linux/types.h>
+#include <linux/tracepoint.h>
+
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM fjes
+
+/* tracepoints for fjes_hw.c */
+
+TRACE_EVENT(fjes_hw_issue_request_command,
+	TP_PROTO(union REG_CR *cr, union REG_CS *cs, int timeout,
+		 enum fjes_dev_command_response_e ret),
+	TP_ARGS(cr, cs, timeout, ret),
+	TP_STRUCT__entry(
+		__field(u16, cr_req)
+		__field(u8, cr_error)
+		__field(u16, cr_err_info)
+		__field(u8, cr_req_start)
+		__field(u16, cs_req)
+		__field(u8, cs_busy)
+		__field(u8, cs_complete)
+		__field(int, timeout)
+		__field(int, ret);
+	),
+	TP_fast_assign(
+		__entry->cr_req = cr->bits.req_code;
+		__entry->cr_error = cr->bits.error;
+		__entry->cr_err_info = cr->bits.err_info;
+		__entry->cr_req_start = cr->bits.req_start;
+		__entry->cs_req = cs->bits.req_code;
+		__entry->cs_busy = cs->bits.busy;
+		__entry->cs_complete = cs->bits.complete;
+		__entry->timeout = timeout;
+		__entry->ret = ret;
+	),
+	TP_printk("CR=[req=%04x, error=%u, err_info=%04x, req_start=%u], CS=[req=%04x, busy=%u, complete=%u], timeout=%d, ret=%d",
+		  __entry->cr_req, __entry->cr_error, __entry->cr_err_info,
+		  __entry->cr_req_start, __entry->cs_req, __entry->cs_busy,
+		  __entry->cs_complete, __entry->timeout, __entry->ret)
+);
+
+TRACE_EVENT(fjes_hw_request_info,
+	TP_PROTO(struct fjes_hw *hw, union fjes_device_command_res *res_buf),
+	TP_ARGS(hw, res_buf),
+	TP_STRUCT__entry(
+		__field(int, length)
+		__field(int, code)
+		__dynamic_array(u8, zone, hw->max_epid)
+		__dynamic_array(u8, status, hw->max_epid)
+	),
+	TP_fast_assign(
+		int x;
+
+		__entry->length = res_buf->info.length;
+		__entry->code = res_buf->info.code;
+		for (x = 0; x < hw->max_epid; x++) {
+			*((u8 *)__get_dynamic_array(zone) + x) =
+					res_buf->info.info[x].zone;
+			*((u8 *)__get_dynamic_array(status) + x) =
+					res_buf->info.info[x].es_status;
+		}
+	),
+	TP_printk("res_buf=[length=%d, code=%d, es_zones=%s, es_status=%s]",
+		  __entry->length, __entry->code,
+		  __print_array(__get_dynamic_array(zone),
+				__get_dynamic_array_len(zone) / sizeof(u8),
+				sizeof(u8)),
+		  __print_array(__get_dynamic_array(status),
+				__get_dynamic_array_len(status) / sizeof(u8),
+				sizeof(u8)))
+);
+
+TRACE_EVENT(fjes_hw_request_info_err,
+	TP_PROTO(char *err),
+	TP_ARGS(err),
+	TP_STRUCT__entry(
+		__string(err, err)
+	),
+	TP_fast_assign(
+		__assign_str(err, err);
+	),
+	TP_printk("%s", __get_str(err))
+);
+
+TRACE_EVENT(fjes_hw_register_buff_addr_req,
+	TP_PROTO(union fjes_device_command_req *req_buf,
+		 struct ep_share_mem_info *buf_pair),
+	TP_ARGS(req_buf, buf_pair),
+	TP_STRUCT__entry(
+		__field(int, length)
+		__field(int, epid)
+		__field(phys_addr_t, tx)
+		__field(size_t,	tx_size)
+		__field(phys_addr_t, rx)
+		__field(size_t,	rx_size)
+	),
+	TP_fast_assign(
+		void *tx, *rx;
+
+		tx = (void *)buf_pair->tx.buffer;
+		rx = (void *)buf_pair->rx.buffer;
+		__entry->length = req_buf->share_buffer.length;
+		__entry->epid = req_buf->share_buffer.epid;
+		__entry->tx_size = buf_pair->tx.size;
+		__entry->rx_size = buf_pair->rx.size;
+		__entry->tx = (phys_addr_t)(page_to_phys(vmalloc_to_page(tx)) +
+					    offset_in_page(tx));
+		__entry->rx = (phys_addr_t)(page_to_phys(vmalloc_to_page(rx)) +
+					    offset_in_page(rx));
+	),
+	TP_printk("req_buf=[length=%d, epid=%d], TX=[phy=%p, size=%zu], RX=[phy=%p, size=%zu]",
+		  __entry->length, __entry->epid,
+		  (void *)__entry->tx, __entry->tx_size,
+		  (void *)__entry->rx, __entry->rx_size)
+);
+
+TRACE_EVENT(fjes_hw_register_buff_addr,
+	TP_PROTO(union fjes_device_command_res *res_buf, int timeout),
+	TP_ARGS(res_buf, timeout),
+	TP_STRUCT__entry(
+		__field(int, length)
+		__field(int, code)
+		__field(int, timeout)
+	),
+	TP_fast_assign(
+		__entry->length = res_buf->share_buffer.length;
+		__entry->code = res_buf->share_buffer.code;
+		__entry->timeout = timeout;
+	),
+	TP_printk("res_buf=[length=%d, code=%d], timeout=%d",
+		  __entry->length, __entry->code, __entry->timeout)
+);
+
+TRACE_EVENT(fjes_hw_register_buff_addr_err,
+	TP_PROTO(char *err),
+	TP_ARGS(err),
+	TP_STRUCT__entry(
+		__string(err, err)
+	),
+	TP_fast_assign(
+		__assign_str(err, err);
+	),
+	TP_printk("%s", __get_str(err))
+);
+
+TRACE_EVENT(fjes_hw_unregister_buff_addr_req,
+	TP_PROTO(union fjes_device_command_req *req_buf),
+	TP_ARGS(req_buf),
+	TP_STRUCT__entry(
+		__field(int, length)
+		__field(int, epid)
+	),
+	TP_fast_assign(
+		__entry->length = req_buf->unshare_buffer.length;
+		__entry->epid = req_buf->unshare_buffer.epid;
+	),
+	TP_printk("req_buf=[length=%d, epid=%d]",
+		  __entry->length, __entry->epid)
+);
+
+TRACE_EVENT(fjes_hw_unregister_buff_addr,
+	TP_PROTO(union fjes_device_command_res *res_buf, int timeout),
+	TP_ARGS(res_buf, timeout),
+	TP_STRUCT__entry(
+		__field(int, length)
+		__field(int, code)
+		__field(int, timeout)
+	),
+	TP_fast_assign(
+		__entry->length = res_buf->unshare_buffer.length;
+		__entry->code = res_buf->unshare_buffer.code;
+		__entry->timeout = timeout;
+	),
+	TP_printk("res_buf=[length=%d, code=%d], timeout=%d",
+		  __entry->length, __entry->code, __entry->timeout)
+);
+
+TRACE_EVENT(fjes_hw_unregister_buff_addr_err,
+	TP_PROTO(char *err),
+	TP_ARGS(err),
+	TP_STRUCT__entry(
+		__string(err, err)
+	),
+	TP_fast_assign(
+		__assign_str(err, err);
+	),
+	TP_printk("%s", __get_str(err))
+);
+
+/* tracepoints for fjes_main.c */
+
+TRACE_EVENT(fjes_txrx_stop_req_irq_pre,
+	TP_PROTO(struct fjes_hw *hw, int src_epid,
+		 enum ep_partner_status status),
+	TP_ARGS(hw, src_epid, status),
+	TP_STRUCT__entry(
+		__field(int, src_epid)
+		__field(enum ep_partner_status, status)
+		__field(u8, ep_status)
+		__field(unsigned long, txrx_stop_req_bit)
+		__field(u16, rx_status)
+	),
+	TP_fast_assign(
+		__entry->src_epid = src_epid;
+		__entry->status = status;
+		__entry->ep_status = hw->hw_info.share->ep_status[src_epid];
+		__entry->txrx_stop_req_bit = hw->txrx_stop_req_bit;
+		__entry->rx_status =
+			hw->ep_shm_info[src_epid].tx.info->v1i.rx_status;
+	),
+	TP_printk("epid=%d, partner_status=%d, ep_status=%x, txrx_stop_req_bit=%016lx, tx.rx_status=%08x",
+		  __entry->src_epid, __entry->status, __entry->ep_status,
+		  __entry->txrx_stop_req_bit, __entry->rx_status)
+);
+
+TRACE_EVENT(fjes_txrx_stop_req_irq_post,
+	TP_PROTO(struct fjes_hw *hw, int src_epid),
+	TP_ARGS(hw, src_epid),
+	TP_STRUCT__entry(
+		__field(int, src_epid)
+		__field(u8, ep_status)
+		__field(unsigned long, txrx_stop_req_bit)
+		__field(u16, rx_status)
+	),
+	TP_fast_assign(
+		__entry->src_epid = src_epid;
+		__entry->ep_status = hw->hw_info.share->ep_status[src_epid];
+		__entry->txrx_stop_req_bit = hw->txrx_stop_req_bit;
+		__entry->rx_status = hw->ep_shm_info[src_epid].tx.info->v1i.rx_status;
+	),
+	TP_printk("epid=%d, ep_status=%x, txrx_stop_req_bit=%016lx, tx.rx_status=%08x",
+		  __entry->src_epid, __entry->ep_status,
+		  __entry->txrx_stop_req_bit, __entry->rx_status)
+);
+
+TRACE_EVENT(fjes_stop_req_irq_pre,
+	TP_PROTO(struct fjes_hw *hw, int src_epid,
+		 enum ep_partner_status status),
+	TP_ARGS(hw, src_epid, status),
+	TP_STRUCT__entry(
+		__field(int, src_epid)
+		__field(enum ep_partner_status, status)
+		__field(u8, ep_status)
+		__field(unsigned long, txrx_stop_req_bit)
+		__field(u16, rx_status)
+	),
+	TP_fast_assign(
+		__entry->src_epid = src_epid;
+		__entry->status = status;
+		__entry->ep_status = hw->hw_info.share->ep_status[src_epid];
+		__entry->txrx_stop_req_bit = hw->txrx_stop_req_bit;
+		__entry->rx_status =
+			hw->ep_shm_info[src_epid].tx.info->v1i.rx_status;
+	),
+	TP_printk("epid=%d, partner_status=%d, ep_status=%x, txrx_stop_req_bit=%016lx, tx.rx_status=%08x",
+		  __entry->src_epid, __entry->status, __entry->ep_status,
+		  __entry->txrx_stop_req_bit, __entry->rx_status)
+);
+
+TRACE_EVENT(fjes_stop_req_irq_post,
+	TP_PROTO(struct fjes_hw *hw, int src_epid),
+	TP_ARGS(hw, src_epid),
+	TP_STRUCT__entry(
+		__field(int, src_epid)
+		__field(u8, ep_status)
+		__field(unsigned long, txrx_stop_req_bit)
+		__field(u16, rx_status)
+	),
+	TP_fast_assign(
+		__entry->src_epid = src_epid;
+		__entry->ep_status = hw->hw_info.share->ep_status[src_epid];
+		__entry->txrx_stop_req_bit = hw->txrx_stop_req_bit;
+		__entry->rx_status =
+			hw->ep_shm_info[src_epid].tx.info->v1i.rx_status;
+	),
+	TP_printk("epid=%d, ep_status=%x, txrx_stop_req_bit=%016lx, tx.rx_status=%08x",
+		  __entry->src_epid, __entry->ep_status,
+		  __entry->txrx_stop_req_bit, __entry->rx_status)
+);
+
+#endif /* FJES_TRACE_H_ */
+
+#undef TRACE_INCLUDE_PATH
+#undef TRACE_INCLUDE_FILE
+#define TRACE_INCLUDE_PATH ../../../drivers/net/fjes
+#define TRACE_INCLUDE_FILE fjes_trace
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
-- 
2.6.6
