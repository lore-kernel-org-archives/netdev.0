From: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: [PATCH] SIW: Debugging and Tracing
Date: Tue,  5 Oct 2010 08:55:42 +0200
Message-ID: <1286261742-5269-1-git-send-email-bmt@zurich.ibm.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

---
 drivers/infiniband/hw/siw/siw_debug.c |  198 +++++++++++++++++++++++++++++++++
 drivers/infiniband/hw/siw/siw_debug.h |  159 ++++++++++++++++++++++++++
 2 files changed, 357 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/hw/siw/siw_debug.c
 create mode 100644 drivers/infiniband/hw/siw/siw_debug.h

diff --git a/drivers/infiniband/hw/siw/siw_debug.c b/drivers/infiniband/hw/siw/siw_debug.c
new file mode 100644
index 0000000..6340272
--- /dev/null
+++ b/drivers/infiniband/hw/siw/siw_debug.c
@@ -0,0 +1,198 @@
+/*
+ * Software iWARP device driver for Linux
+ *
+ * Authors: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
+ *          Fredy Neeser <nfd-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
+ *
+ * Copyright (c) 2008-2010, IBM Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ *   Redistribution and use in source and binary forms, with or
+ *   without modification, are permitted provided that the following
+ *   conditions are met:
+ *
+ *   - Redistributions of source code must retain the above copyright notice,
+ *     this list of conditions and the following disclaimer.
+ *
+ *   - Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *
+ *   - Neither the name of IBM nor the names of its contributors may be
+ *     used to endorse or promote products derived from this software without
+ *     specific prior written permission.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <net/tcp.h>
+
+#include <rdma/iw_cm.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_umem.h>
+#include <rdma/ib_smi.h>
+#include <rdma/ib_user_verbs.h>
+
+#include "siw.h"
+#include "siw_obj.h"
+
+
+void siw_print_qp_attr_mask(enum ib_qp_attr_mask attr_mask, char *msg)
+{
+	printk(KERN_INFO "-------- %s -------\n", msg);
+	if (IB_QP_STATE & attr_mask)
+		printk(KERN_INFO "IB_QP_STATE\n");
+	if (IB_QP_CUR_STATE & attr_mask)
+		printk(KERN_INFO "IB_QP_CUR_STATE\n");
+	if (IB_QP_EN_SQD_ASYNC_NOTIFY & attr_mask)
+		printk(KERN_INFO "IB_QP_EN_SQD_ASYNC_NOTIFY\n");
+	if (IB_QP_ACCESS_FLAGS & attr_mask)
+		printk(KERN_INFO "IB_QP_ACCESS_FLAGS\n");
+	if (IB_QP_PKEY_INDEX & attr_mask)
+		printk(KERN_INFO "IB_QP_PKEY_INDEX\n");
+	if (IB_QP_PORT & attr_mask)
+		printk(KERN_INFO "IB_QP_PORT\n");
+	if (IB_QP_QKEY & attr_mask)
+		printk(KERN_INFO "IB_QP_QKEY\n");
+	if (IB_QP_AV & attr_mask)
+		printk(KERN_INFO "IB_QP_AV\n");
+	if (IB_QP_PATH_MTU & attr_mask)
+		printk(KERN_INFO "IB_QP_PATH_MTU\n");
+	if (IB_QP_TIMEOUT & attr_mask)
+		printk(KERN_INFO "IB_QP_TIMEOUT\n");
+	if (IB_QP_RETRY_CNT & attr_mask)
+		printk(KERN_INFO "IB_QP_RETRY_CNT\n");
+	if (IB_QP_RNR_RETRY & attr_mask)
+		printk(KERN_INFO "IB_QP_RNR_RETRY\n");
+	if (IB_QP_RQ_PSN & attr_mask)
+		printk(KERN_INFO "IB_QP_RQ_PSN\n");
+	if (IB_QP_MAX_QP_RD_ATOMIC & attr_mask)
+		printk(KERN_INFO "IB_QP_MAX_QP_RD_ATOMIC\n");
+	if (IB_QP_ALT_PATH & attr_mask)
+		printk(KERN_INFO "IB_QP_ALT_PATH\n");
+	if (IB_QP_MIN_RNR_TIMER & attr_mask)
+		printk(KERN_INFO "IB_QP_MIN_RNR_TIMER\n");
+	if (IB_QP_SQ_PSN & attr_mask)
+		printk(KERN_INFO "IB_QP_SQ_PSN\n");
+	if (IB_QP_MAX_DEST_RD_ATOMIC & attr_mask)
+		printk(KERN_INFO "IB_QP_MAX_DEST_RD_ATOMIC\n");
+	if (IB_QP_PATH_MIG_STATE & attr_mask)
+		printk(KERN_INFO "IB_QP_PATH_MIG_STATE\n");
+	if (IB_QP_CAP & attr_mask)
+		printk(KERN_INFO "IB_QP_CAP\n");
+	if (IB_QP_DEST_QPN & attr_mask)
+		printk(KERN_INFO "IB_QP_DEST_QPN\n");
+	printk(KERN_INFO "-------- %s -(end)-\n", msg);
+}
+
+
+void siw_print_hdr(union iwarp_hdrs *hdr, int qp_id, char *msg)
+{
+	switch (hdr->ctrl.opcode) {
+
+	case RDMAP_RDMA_WRITE:
+		printk(KERN_INFO "QP%04d %s(WRITE, MPA len %d): %08x %016llx\n",
+			qp_id, msg, ntohs(hdr->ctrl.mpa_len),
+			hdr->rwrite.sink_stag, hdr->rwrite.sink_to);
+		break;
+
+	case RDMAP_RDMA_READ_REQ:
+		printk(KERN_INFO "QP%04d %s(RREQ, MPA len %d): %08x %08x "
+			"%08x %08x %016llx %08x %08x %016llx\n", qp_id, msg,
+			ntohs(hdr->ctrl.mpa_len),
+			hdr->rreq.ddp_qn, hdr->rreq.ddp_msn,
+			hdr->rreq.ddp_mo, hdr->rreq.sink_stag,
+			hdr->rreq.sink_to, hdr->rreq.read_size,
+			hdr->rreq.source_stag, hdr->rreq.source_to);
+
+		break;
+	case RDMAP_RDMA_READ_RESP:
+		printk(KERN_INFO "QP%04d %s(RRESP, MPA len %d): %08x %016llx\n",
+			qp_id, msg, ntohs(hdr->ctrl.mpa_len),
+			hdr->rresp.sink_stag, hdr->rresp.sink_to);
+		break;
+
+	case RDMAP_SEND:
+		printk(KERN_INFO "QP%04d %s(SEND, MPA len %d): %08x %08x "
+			"%08x\n", qp_id, msg, ntohs(hdr->ctrl.mpa_len),
+			hdr->send.ddp_qn, hdr->send.ddp_msn, hdr->send.ddp_mo);
+		break;
+
+	case RDMAP_SEND_INVAL:
+		printk(KERN_INFO "QP%04d %s(S_INV, MPA len %d): %08x %08x "
+			"%08x\n", qp_id, msg, ntohs(hdr->ctrl.mpa_len),
+			hdr->send.ddp_qn, hdr->send.ddp_msn,
+			hdr->send.ddp_mo);
+		break;
+
+	case RDMAP_SEND_SE:
+		printk(KERN_INFO "QP%04d %s(S_SE, MPA len %d): %08x %08x "
+			"%08x\n", qp_id, msg, ntohs(hdr->ctrl.mpa_len),
+			hdr->send.ddp_qn, hdr->send.ddp_msn,
+			hdr->send.ddp_mo);
+		break;
+
+	case RDMAP_SEND_SE_INVAL:
+		printk(KERN_INFO "QP%04d %s(S_SE_INV, MPA len %d): %08x %08x "
+			"%08x\n", qp_id, msg, ntohs(hdr->ctrl.mpa_len),
+			hdr->send.ddp_qn, hdr->send.ddp_msn,
+			hdr->send.ddp_mo);
+		break;
+
+	case RDMAP_TERMINATE:
+		printk(KERN_INFO "QP%04d %s(TERM, MPA len %d):\n", qp_id, msg,
+			ntohs(hdr->ctrl.mpa_len));
+		break;
+
+	default:
+		printk(KERN_INFO "QP%04d %s ?????\n", qp_id, msg);
+		break;
+	}
+}
+
+void siw_print_rctx(struct siw_iwarp_rx *rctx)
+{
+	printk(KERN_INFO "---RX Context-->\n");
+	siw_print_hdr(&rctx->hdr, RX_QPID(rctx), "\nCurrent Pkt:\t");
+	printk(KERN_INFO "Skbuf State:\tp:0x%p, new:%d, off:%d, copied:%d\n",
+		rctx->skb, rctx->skb_new, rctx->skb_offset, rctx->skb_copied);
+	printk(KERN_INFO "FPDU State:\trx_state:%d,\n\t\trcvd:%d, rem:%d, "
+		"pad:%d\n", rctx->state, rctx->fpdu_part_rcvd,
+		rctx->fpdu_part_rem, rctx->pad);
+	printk(KERN_INFO "Rx Mem:\t\tp:0x%p, chunk:0x%p,\n\t\tp_ix:%d, "
+		"p_off:%d, stag:0x%08x, mem_id:%d\n",
+		rctx->dest.wqe, rctx->umem_chunk, rctx->pg_idx, rctx->pg_off,
+		rctx->ddp_stag, rctx->ddp_stag >> 8);
+	printk(KERN_INFO "DDP State:\tprev_op:%d, first_seg:%d, "
+		"more_segs:%d\n", rctx->prev_ddp_opcode, rctx->first_ddp_seg,
+		rctx->more_ddp_segs);
+	printk(KERN_INFO "MPA State:\tlen:%d, crc_enabled:%d, crc:0x%x\n",
+		rctx->hdr.ctrl.mpa_len, rctx->crc_enabled, rctx->trailer.crc);
+	printk(KERN_INFO "<---------------\n");
+}
+
+#if DPRINT_MASK > 0
+char ib_qp_state_to_string[IB_QPS_ERR+1][sizeof "RESET"] = {
+	[IB_QPS_RESET]	= "RESET",
+	[IB_QPS_INIT]	= "INIT",
+	[IB_QPS_RTR]	= "RTR",
+	[IB_QPS_RTS]	= "RTS",
+	[IB_QPS_SQD]	= "SQD",
+	[IB_QPS_SQE]	= "SQE",
+	[IB_QPS_ERR]	= "ERR"
+};
+#endif
diff --git a/drivers/infiniband/hw/siw/siw_debug.h b/drivers/infiniband/hw/siw/siw_debug.h
new file mode 100644
index 0000000..58615fd
--- /dev/null
+++ b/drivers/infiniband/hw/siw/siw_debug.h
@@ -0,0 +1,159 @@
+/*
+ * Software iWARP device driver for Linux
+ *
+ * Authors: Fredy Neeser <nfd-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
+ *
+ * Copyright (c) 2008-2010, IBM Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ *   Redistribution and use in source and binary forms, with or
+ *   without modification, are permitted provided that the following
+ *   conditions are met:
+ *
+ *   - Redistributions of source code must retain the above copyright notice,
+ *     this list of conditions and the following disclaimer.
+ *
+ *   - Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *
+ *   - Neither the name of IBM nor the names of its contributors may be
+ *     used to endorse or promote products derived from this software without
+ *     specific prior written permission.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef _SIW_DEBUG_H
+#define _SIW_DEBUG_H
+
+#include <linux/uaccess.h>
+#include <linux/hardirq.h>	/* in_interrupt() */
+
+/*
+ * dprint: Selective debug printing
+ *
+ * Use an OR combination of DBG_* as dbgcat in dprint*(dbgcat,...)
+ * to assign debug messages to categories:
+ *
+ * dbgcat	Debug message belongs to category
+ * -----------------------------------------------------------------------------
+ * DBG_ON	Always on, for really important events or error conditions
+ * DBG_TMP	Temporarily on for fine-grained debugging
+ * DBQ_OBJ	Object management (object construction/destruction/refcounting)
+ * DBG_MM	Memory management
+ * DBG_EH	Event handling (completion events and asynchronous events)
+ * DBG_CM	Connection management, QP states
+ * DBG_WR	Work requests
+ * DBG_TX	iWARP TX path
+ * DBG_RX	iWARP RX path
+ * DBG_SK	Socket operations
+ * DBG_KT	Kernel threads
+ * DBG_IRQ	Interrupt context (SoftIRQ or HardIRQ)
+ * DBG_DM	Device management
+ * DBG_HDR	Packet HDRs
+ * DBG_ALL	All categories above
+ */
+#define DBG_ON		0x00000001
+#define DBG_TMP		0x00000002
+#define DBG_OBJ		0x00000004
+#define DBG_MM		0x00000008
+#define DBG_EH		0x00000010
+#define DBG_CM		0x00000020
+#define DBG_WR		0x00000040
+#define DBG_TX		0x00000080
+#define DBG_RX		0x00000100
+#define DBG_SK		0x00000200
+#define DBG_KT		0x00000400
+#define DBG_IRQ		0x00000800
+#define DBG_DM		0x00001000
+#define DBG_HDR		0x00002000
+#define DBG_ALL		(DBG_IRQ|DBG_KT|DBG_SK|DBG_RX|DBG_TX|DBG_WR|\
+DBG_CM|DBG_EH|DBG_MM|DBG_OBJ|DBG_TMP|DBG_DM|DBG_ON|DBG_HDR)
+#define DBG_ALL_NOHDR	(DBG_IRQ|DBG_KT|DBG_SK|DBG_RX|DBG_TX|DBG_WR|\
+DBG_CM|DBG_EH|DBG_MM|DBG_OBJ|DBG_TMP|DBG_DM|DBG_ON)
+#define DBG_CTRL	(DBG_ON|DBG_CM|DBG_DM)
+
+/*
+ * Set DPRINT_MASK to tailor your debugging needs:
+ *
+ * DPRINT_MASK value		Enables debug messages for
+ * ---------------------------------------------------------------------
+ * DBG_ON			Important events / error conditions only
+ *				(minimum number of debug messages)
+ * OR-ed combination of DBG_*	Selective debugging
+ * DBG_KT|DBG_ON		Kernel threads
+ * DBG_ALL			All categories
+ */
+#define DPRINT_MASK	0
+
+extern void siw_print_hdr(union iwarp_hdrs *, int, char *);
+extern void siw_print_rctx(struct siw_iwarp_rx *);
+extern void siw_print_qp_attr_mask(enum ib_qp_attr_mask, char *);
+
+#if DPRINT_MASK > 0
+
+/**
+ * dprint - Selective debug print for process, SoftIRQ or HardIRQ context
+ *
+ * Debug print with selectable debug categories,
+ * starting with header
+ * - "( pid /cpu) __func__" for process context
+ * - "( irq /cpu) __func__" for IRQ context
+ *
+ * @dbgcat	: Set of debug categories (OR-ed combination of DBG_* above),
+ *		  to which this debug message is assigned.
+ * @fmt		: printf compliant format string
+ * @args	: printf compliant argument list
+ */
+#define dprint(dbgcat, fmt, args...)					\
+	do {								\
+		if ((dbgcat) & DPRINT_MASK) {				\
+			if (!in_interrupt())				\
+				printk(KERN_INFO "(%5d/%1d) %s" fmt,	\
+					current->pid,			\
+					current_thread_info()->cpu,	\
+					__func__, ## args);		\
+			else						\
+				printk(KERN_INFO "( irq /%1d) %s" fmt,	\
+					current_thread_info()->cpu,	\
+					__func__, ## args);		\
+		}							\
+	} while (0)
+
+
+#define siw_dprint_rctx(r)	siw_print_rctx(r)
+extern char ib_qp_state_to_string[IB_QPS_ERR+1][sizeof "RESET"];
+
+#else
+#define dprint(dbgcat, fmt, args...)	do { } while (0)
+#define siw_dprint_rctx(r)	do { } while (0)
+#endif
+
+
+#if DPRINT_MASK & DBG_HDR
+#define siw_dprint_hdr(h, i, m)	siw_print_hdr(h, i, m)
+#else
+#define siw_dprint_hdr(h, i, m)	do { } while (0)
+#endif
+
+#if DPRINT_MASK & DBG_CM
+#define siw_dprint_qp_attr_mask(mask)\
+		siw_print_qp_attr_mask(mask, (char *)__func__)
+#else
+#define siw_dprint_qp_attr_mask(mask)	do { } while (0)
+#endif
+
+#endif
-- 
1.5.4.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
