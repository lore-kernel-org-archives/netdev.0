From: Manish Rangankar <manish.rangankar@cavium.com>
Subject: [PATCH v3 3/3] qedi: Add QLogic FastLinQ offload iSCSI driver framework.
Date: Thu, 1 Dec 2016 00:21:08 -0800
Message-ID: <1480580468-31567-4-git-send-email-manish.rangankar@cavium.com>
References: <1480580468-31567-1-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>,
        <QLogic-Storage-Upstream@cavium.com>, <Yuval.Mintz@cavium.com>
To: <martin.petersen@oracle.com>, <lduncan@suse.com>,
        <cleech@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0075.outbound.protection.outlook.com ([104.47.32.75]:13750
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751510AbcLAIzE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 03:55:04 -0500
In-Reply-To: <1480580468-31567-1-git-send-email-manish.rangankar@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The QLogic FastLinQ Driver for iSCSI (qedi) is the iSCSI specific module
for 41000 Series Converged Network Adapters by QLogic.

This patch consists of following changes:
  - MAINTAINERS Makefile and Kconfig changes for qedi,
  - PCI driver registration,
  - iSCSI host level initialization,
  - Debugfs and log level infrastructure.

Below indiviual changes are merged into this commit,
  qedi: Add LL2 iSCSI interface for offload iSCSI.
  qedi: Add support for iSCSI session management.
  qedi: Add support for data path.

Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
Signed-off-by: Arun Easi <arun.easi@cavium.com>
Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
Reviewed-by: Johannes Thumshirn <jthumshirn@suse.de>
Reviewed-by: Hannes Reinecke <hare@suse.de>
Reviewed-by: Martin K. Petersen <martin.petersen@oracle.com>
---
 MAINTAINERS                      |    6 +
 drivers/scsi/Kconfig             |    1 +
 drivers/scsi/Makefile            |    1 +
 drivers/scsi/qedi/Kconfig        |   10 +
 drivers/scsi/qedi/Makefile       |    5 +
 drivers/scsi/qedi/qedi.h         |  364 ++++++
 drivers/scsi/qedi/qedi_dbg.c     |  143 +++
 drivers/scsi/qedi/qedi_dbg.h     |  144 +++
 drivers/scsi/qedi/qedi_debugfs.c |  244 ++++
 drivers/scsi/qedi/qedi_fw.c      | 2378 ++++++++++++++++++++++++++++++++++++++
 drivers/scsi/qedi/qedi_gbl.h     |   73 ++
 drivers/scsi/qedi/qedi_hsi.h     |   52 +
 drivers/scsi/qedi/qedi_iscsi.c   | 1624 ++++++++++++++++++++++++++
 drivers/scsi/qedi/qedi_iscsi.h   |  232 ++++
 drivers/scsi/qedi/qedi_main.c    | 2127 ++++++++++++++++++++++++++++++++++
 drivers/scsi/qedi/qedi_sysfs.c   |   52 +
 drivers/scsi/qedi/qedi_version.h |   14 +
 17 files changed, 7470 insertions(+)
 create mode 100644 drivers/scsi/qedi/Kconfig
 create mode 100644 drivers/scsi/qedi/Makefile
 create mode 100644 drivers/scsi/qedi/qedi.h
 create mode 100644 drivers/scsi/qedi/qedi_dbg.c
 create mode 100644 drivers/scsi/qedi/qedi_dbg.h
 create mode 100644 drivers/scsi/qedi/qedi_debugfs.c
 create mode 100644 drivers/scsi/qedi/qedi_fw.c
 create mode 100644 drivers/scsi/qedi/qedi_gbl.h
 create mode 100644 drivers/scsi/qedi/qedi_hsi.h
 create mode 100644 drivers/scsi/qedi/qedi_iscsi.c
 create mode 100644 drivers/scsi/qedi/qedi_iscsi.h
 create mode 100644 drivers/scsi/qedi/qedi_main.c
 create mode 100644 drivers/scsi/qedi/qedi_sysfs.c
 create mode 100644 drivers/scsi/qedi/qedi_version.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 5196538..e05608d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9949,6 +9949,12 @@ F:	drivers/net/ethernet/qlogic/qed/
 F:	include/linux/qed/
 F:	drivers/net/ethernet/qlogic/qede/
 
+QLOGIC QL41xxx ISCSI DRIVER
+M:	QLogic-Storage-Upstream@cavium.com
+L:	linux-scsi@vger.kernel.org
+S:	Supported
+F:	drivers/scsi/qedi/
+
 QNX4 FILESYSTEM
 M:	Anders Larsen <al@alarsen.net>
 W:	http://www.alarsen.net/linux/qnx4fs/
diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
index 3e2bdb9..5cf03db 100644
--- a/drivers/scsi/Kconfig
+++ b/drivers/scsi/Kconfig
@@ -1254,6 +1254,7 @@ config SCSI_QLOGICPTI
 
 source "drivers/scsi/qla2xxx/Kconfig"
 source "drivers/scsi/qla4xxx/Kconfig"
+source "drivers/scsi/qedi/Kconfig"
 
 config SCSI_LPFC
 	tristate "Emulex LightPulse Fibre Channel Support"
diff --git a/drivers/scsi/Makefile b/drivers/scsi/Makefile
index 38d938d..da9e312 100644
--- a/drivers/scsi/Makefile
+++ b/drivers/scsi/Makefile
@@ -132,6 +132,7 @@ obj-$(CONFIG_PS3_ROM)		+= ps3rom.o
 obj-$(CONFIG_SCSI_CXGB3_ISCSI)	+= libiscsi.o libiscsi_tcp.o cxgbi/
 obj-$(CONFIG_SCSI_CXGB4_ISCSI)	+= libiscsi.o libiscsi_tcp.o cxgbi/
 obj-$(CONFIG_SCSI_BNX2_ISCSI)	+= libiscsi.o bnx2i/
+obj-$(CONFIG_QEDI)          += libiscsi.o qedi/
 obj-$(CONFIG_BE2ISCSI)		+= libiscsi.o be2iscsi/
 obj-$(CONFIG_SCSI_ESAS2R)	+= esas2r/
 obj-$(CONFIG_SCSI_PMCRAID)	+= pmcraid.o
diff --git a/drivers/scsi/qedi/Kconfig b/drivers/scsi/qedi/Kconfig
new file mode 100644
index 0000000..23ca8a2
--- /dev/null
+++ b/drivers/scsi/qedi/Kconfig
@@ -0,0 +1,10 @@
+config QEDI
+	tristate "QLogic QEDI 25/40/100Gb iSCSI Initiator Driver Support"
+	depends on PCI && SCSI
+	depends on QED
+	select SCSI_ISCSI_ATTRS
+	select QED_LL2
+	select QED_ISCSI
+	---help---
+	This driver supports iSCSI offload for the QLogic FastLinQ
+	41000 Series Converged Network Adapters.
diff --git a/drivers/scsi/qedi/Makefile b/drivers/scsi/qedi/Makefile
new file mode 100644
index 0000000..2b3e16b
--- /dev/null
+++ b/drivers/scsi/qedi/Makefile
@@ -0,0 +1,5 @@
+obj-$(CONFIG_QEDI) := qedi.o
+qedi-y := qedi_main.o qedi_iscsi.o qedi_fw.o qedi_sysfs.o \
+	    qedi_dbg.o
+
+qedi-$(CONFIG_DEBUG_FS) += qedi_debugfs.o
diff --git a/drivers/scsi/qedi/qedi.h b/drivers/scsi/qedi/qedi.h
new file mode 100644
index 0000000..5ca3e8c
--- /dev/null
+++ b/drivers/scsi/qedi/qedi.h
@@ -0,0 +1,364 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QEDI_H_
+#define _QEDI_H_
+
+#define __PREVENT_QED_HSI__
+
+#include <scsi/scsi_transport_iscsi.h>
+#include <scsi/libiscsi.h>
+#include <scsi/scsi_host.h>
+#include <linux/uio_driver.h>
+
+#include "qedi_hsi.h"
+#include <linux/qed/qed_if.h>
+#include "qedi_dbg.h"
+#include <linux/qed/qed_iscsi_if.h>
+#include <linux/qed/qed_ll2_if.h>
+#include "qedi_version.h"
+
+#define QEDI_MODULE_NAME		"qedi"
+
+struct qedi_endpoint;
+
+/*
+ * PCI function probe defines
+ */
+#define QEDI_MODE_NORMAL	0
+#define QEDI_MODE_RECOVERY	1
+
+#define ISCSI_WQE_SET_PTU_INVALIDATE	1
+#define QEDI_MAX_ISCSI_TASK		4096
+#define QEDI_MAX_TASK_NUM		0x0FFF
+#define QEDI_MAX_ISCSI_CONNS_PER_HBA	1024
+#define QEDI_ISCSI_MAX_BDS_PER_CMD	256	/* Firmware max BDs is 256 */
+#define MAX_OUSTANDING_TASKS_PER_CON	1024
+
+#define QEDI_MAX_BD_LEN		0xffff
+#define QEDI_BD_SPLIT_SZ	0x1000
+#define QEDI_PAGE_SIZE		4096
+#define QEDI_FAST_SGE_COUNT	4
+/* MAX Length for cached SGL */
+#define MAX_SGLEN_FOR_CACHESGL	((1U << 16) - 1)
+
+#define MAX_NUM_MSIX_PF         8
+#define MIN_NUM_CPUS_MSIX(x)	min((x)->msix_count, num_online_cpus())
+
+#define QEDI_LOCAL_PORT_MIN     60000
+#define QEDI_LOCAL_PORT_MAX     61024
+#define QEDI_LOCAL_PORT_RANGE   (QEDI_LOCAL_PORT_MAX - QEDI_LOCAL_PORT_MIN)
+#define QEDI_LOCAL_PORT_INVALID	0xffff
+#define TX_RX_RING		16
+#define RX_RING			(TX_RX_RING - 1)
+#define LL2_SINGLE_BUF_SIZE	0x400
+#define QEDI_PAGE_SIZE		4096
+#define QEDI_PAGE_ALIGN(addr)	ALIGN(addr, QEDI_PAGE_SIZE)
+#define QEDI_PAGE_MASK		(~((QEDI_PAGE_SIZE) - 1))
+
+#define QEDI_PAGE_SIZE		4096
+#define QEDI_PATH_HANDLE	0xFE0000000UL
+
+struct qedi_uio_ctrl {
+	/* meta data */
+	u32 uio_hsi_version;
+
+	/* user writes */
+	u32 host_tx_prod;
+	u32 host_rx_cons;
+	u32 host_rx_bd_cons;
+	u32 host_tx_pkt_len;
+	u32 host_rx_cons_cnt;
+
+	/* driver writes */
+	u32 hw_tx_cons;
+	u32 hw_rx_prod;
+	u32 hw_rx_bd_prod;
+	u32 hw_rx_prod_cnt;
+
+	/* other */
+	u8 mac_addr[6];
+	u8 reserve[2];
+};
+
+struct qedi_rx_bd {
+	u32 rx_pkt_index;
+	u32 rx_pkt_len;
+	u16 vlan_id;
+};
+
+#define QEDI_RX_DESC_CNT	(QEDI_PAGE_SIZE / sizeof(struct qedi_rx_bd))
+#define QEDI_MAX_RX_DESC_CNT	(QEDI_RX_DESC_CNT - 1)
+#define QEDI_NUM_RX_BD		(QEDI_RX_DESC_CNT * 1)
+#define QEDI_MAX_RX_BD		(QEDI_NUM_RX_BD - 1)
+
+#define QEDI_NEXT_RX_IDX(x)	((((x) & (QEDI_MAX_RX_DESC_CNT)) ==	\
+				  (QEDI_MAX_RX_DESC_CNT - 1)) ?		\
+				 (x) + 2 : (x) + 1)
+
+struct qedi_uio_dev {
+	struct uio_info		qedi_uinfo;
+	u32			uio_dev;
+	struct list_head	list;
+
+	u32			ll2_ring_size;
+	void			*ll2_ring;
+
+	u32			ll2_buf_size;
+	void			*ll2_buf;
+
+	void			*rx_pkt;
+	void			*tx_pkt;
+
+	struct qedi_ctx		*qedi;
+	struct pci_dev		*pdev;
+	void			*uctrl;
+};
+
+/* List to maintain the skb pointers */
+struct skb_work_list {
+	struct list_head list;
+	struct sk_buff *skb;
+	u16 vlan_id;
+};
+
+/* Queue sizes in number of elements */
+#define QEDI_SQ_SIZE		MAX_OUSTANDING_TASKS_PER_CON
+#define QEDI_CQ_SIZE		2048
+#define QEDI_CMDQ_SIZE		QEDI_MAX_ISCSI_TASK
+#define QEDI_PROTO_CQ_PROD_IDX	0
+
+struct qedi_glbl_q_params {
+	u64 hw_p_cq;	/* Completion queue PBL */
+	u64 hw_p_rq;	/* Request queue PBL */
+	u64 hw_p_cmdq;	/* Command queue PBL */
+};
+
+struct global_queue {
+	union iscsi_cqe *cq;
+	dma_addr_t cq_dma;
+	u32 cq_mem_size;
+	u32 cq_cons_idx; /* Completion queue consumer index */
+
+	void *cq_pbl;
+	dma_addr_t cq_pbl_dma;
+	u32 cq_pbl_size;
+
+};
+
+struct qedi_fastpath {
+	struct qed_sb_info	*sb_info;
+	u16			sb_id;
+#define QEDI_NAME_SIZE		16
+	char			name[QEDI_NAME_SIZE];
+	struct qedi_ctx         *qedi;
+};
+
+/* Used to pass fastpath information needed to process CQEs */
+struct qedi_io_work {
+	struct list_head list;
+	struct iscsi_cqe_solicited cqe;
+	u16	que_idx;
+};
+
+/**
+ * struct iscsi_cid_queue - Per adapter iscsi cid queue
+ *
+ * @cid_que_base:           queue base memory
+ * @cid_que:                queue memory pointer
+ * @cid_q_prod_idx:         produce index
+ * @cid_q_cons_idx:         consumer index
+ * @cid_q_max_idx:          max index. used to detect wrap around condition
+ * @cid_free_cnt:           queue size
+ * @conn_cid_tbl:           iscsi cid to conn structure mapping table
+ *
+ * Per adapter iSCSI CID Queue
+ */
+struct iscsi_cid_queue {
+	void *cid_que_base;
+	u32 *cid_que;
+	u32 cid_q_prod_idx;
+	u32 cid_q_cons_idx;
+	u32 cid_q_max_idx;
+	u32 cid_free_cnt;
+	struct qedi_conn **conn_cid_tbl;
+};
+
+struct qedi_portid_tbl {
+	spinlock_t      lock;	/* Port id lock */
+	u16             start;
+	u16             max;
+	u16             next;
+	unsigned long   *table;
+};
+
+struct qedi_itt_map {
+	__le32	itt;
+	struct qedi_cmd *p_cmd;
+};
+
+/* I/O tracing entry */
+#define QEDI_IO_TRACE_SIZE             2048
+struct qedi_io_log {
+#define QEDI_IO_TRACE_REQ              0
+#define QEDI_IO_TRACE_RSP              1
+	u8 direction;
+	u16 task_id;
+	u32 cid;
+	u32 port_id;	/* Remote port fabric ID */
+	int lun;
+	u8 op;		/* SCSI CDB */
+	u8 lba[4];
+	unsigned int bufflen;	/* SCSI buffer length */
+	unsigned int sg_count;	/* Number of SG elements */
+	u8 fast_sgs;		/* number of fast sgls */
+	u8 slow_sgs;		/* number of slow sgls */
+	u8 cached_sgs;		/* number of cached sgls */
+	int result;		/* Result passed back to mid-layer */
+	unsigned long jiffies;	/* Time stamp when I/O logged */
+	int refcount;		/* Reference count for task id */
+	unsigned int blk_req_cpu; /* CPU that the task is queued on by
+				   * blk layer
+				   */
+	unsigned int req_cpu;	/* CPU that the task is queued on */
+	unsigned int intr_cpu;	/* Interrupt CPU that the task is received on */
+	unsigned int blk_rsp_cpu;/* CPU that task is actually processed and
+				  * returned to blk layer
+				  */
+	bool cached_sge;
+	bool slow_sge;
+	bool fast_sge;
+};
+
+/* Number of entries in BDQ */
+#define QEDI_BDQ_NUM		256
+#define QEDI_BDQ_BUF_SIZE	256
+
+/* DMA coherent buffers for BDQ */
+struct qedi_bdq_buf {
+	void *buf_addr;
+	dma_addr_t buf_dma;
+};
+
+/* Main port level struct */
+struct qedi_ctx {
+	struct qedi_dbg_ctx dbg_ctx;
+	struct Scsi_Host *shost;
+	struct pci_dev *pdev;
+	struct qed_dev *cdev;
+	struct qed_dev_iscsi_info dev_info;
+	struct qed_int_info int_info;
+	struct qedi_glbl_q_params *p_cpuq;
+	struct global_queue **global_queues;
+	/* uio declaration */
+	struct qedi_uio_dev *udev;
+	struct list_head ll2_skb_list;
+	spinlock_t ll2_lock;	/* Light L2 lock */
+	spinlock_t hba_lock;	/* per port lock */
+	struct task_struct *ll2_recv_thread;
+	unsigned long flags;
+#define UIO_DEV_OPENED		1
+#define QEDI_IOTHREAD_WAKE	2
+#define QEDI_IN_RECOVERY	5
+#define QEDI_IN_OFFLINE		6
+
+	u8 mac[ETH_ALEN];
+	u32 src_ip[4];
+	u8 ip_type;
+
+	/* Physical address of above array */
+	dma_addr_t hw_p_cpuq;
+
+	struct qedi_bdq_buf bdq[QEDI_BDQ_NUM];
+	void *bdq_pbl;
+	dma_addr_t bdq_pbl_dma;
+	size_t bdq_pbl_mem_size;
+	void *bdq_pbl_list;
+	dma_addr_t bdq_pbl_list_dma;
+	u8 bdq_pbl_list_num_entries;
+	void __iomem *bdq_primary_prod;
+	void __iomem *bdq_secondary_prod;
+	u16 bdq_prod_idx;
+	u16 rq_num_entries;
+
+	u32 msix_count;
+	u32 max_sqes;
+	u8 num_queues;
+	u32 max_active_conns;
+
+	struct iscsi_cid_queue cid_que;
+	struct qedi_endpoint **ep_tbl;
+	struct qedi_portid_tbl lcl_port_tbl;
+
+	/* Rx fast path intr context */
+	struct qed_sb_info	*sb_array;
+	struct qedi_fastpath	*fp_array;
+	struct qed_iscsi_tid	tasks;
+
+#define QEDI_LINK_DOWN		0
+#define QEDI_LINK_UP		1
+	atomic_t link_state;
+
+#define QEDI_RESERVE_TASK_ID	0
+#define MAX_ISCSI_TASK_ENTRIES	4096
+#define QEDI_INVALID_TASK_ID	(MAX_ISCSI_TASK_ENTRIES + 1)
+	unsigned long task_idx_map[MAX_ISCSI_TASK_ENTRIES / BITS_PER_LONG];
+	struct qedi_itt_map *itt_map;
+	u16 tid_reuse_count[QEDI_MAX_ISCSI_TASK];
+	struct qed_pf_params pf_params;
+
+	struct workqueue_struct *tmf_thread;
+	struct workqueue_struct *offload_thread;
+
+	u16 ll2_mtu;
+
+	struct workqueue_struct *dpc_wq;
+
+	spinlock_t task_idx_lock;	/* To protect gbl context */
+	s32 last_tidx_alloc;
+	s32 last_tidx_clear;
+
+	struct qedi_io_log io_trace_buf[QEDI_IO_TRACE_SIZE];
+	spinlock_t io_trace_lock;	/* prtect trace Log buf */
+	u16 io_trace_idx;
+	unsigned int intr_cpu;
+	u32 cached_sgls;
+	bool use_cached_sge;
+	u32 slow_sgls;
+	bool use_slow_sge;
+	u32 fast_sgls;
+	bool use_fast_sge;
+
+	atomic_t num_offloads;
+};
+
+struct qedi_work {
+	struct list_head list;
+	struct qedi_ctx *qedi;
+	union iscsi_cqe cqe;
+	u16     que_idx;
+	bool is_solicited;
+};
+
+struct qedi_percpu_s {
+	struct task_struct *iothread;
+	struct list_head work_list;
+	spinlock_t p_work_lock;		/* Per cpu worker lock */
+};
+
+static inline void *qedi_get_task_mem(struct qed_iscsi_tid *info, u32 tid)
+{
+	return (info->blocks[tid / info->num_tids_per_block] +
+		(tid % info->num_tids_per_block) * info->size);
+}
+
+#define QEDI_U64_HI(val) ((u32)(((u64)(val)) >> 32))
+#define QEDI_U64_LO(val) ((u32)(((u64)(val)) & 0xffffffff))
+
+#endif /* _QEDI_H_ */
diff --git a/drivers/scsi/qedi/qedi_dbg.c b/drivers/scsi/qedi/qedi_dbg.c
new file mode 100644
index 0000000..2bdedb9
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_dbg.c
@@ -0,0 +1,143 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include "qedi_dbg.h"
+#include <linux/vmalloc.h>
+
+void
+qedi_dbg_err(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
+	     const char *fmt, ...)
+{
+	va_list va;
+	struct va_format vaf;
+	char nfunc[32];
+
+	memset(nfunc, 0, sizeof(nfunc));
+	memcpy(nfunc, func, sizeof(nfunc) - 1);
+
+	va_start(va, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &va;
+
+	if (likely(qedi) && likely(qedi->pdev))
+		pr_err("[%s]:[%s:%d]:%d: %pV", dev_name(&qedi->pdev->dev),
+		       nfunc, line, qedi->host_no, &vaf);
+	else
+		pr_err("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
+
+	va_end(va);
+}
+
+void
+qedi_dbg_warn(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
+	      const char *fmt, ...)
+{
+	va_list va;
+	struct va_format vaf;
+	char nfunc[32];
+
+	memset(nfunc, 0, sizeof(nfunc));
+	memcpy(nfunc, func, sizeof(nfunc) - 1);
+
+	va_start(va, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &va;
+
+	if (!(qedi_dbg_log & QEDI_LOG_WARN))
+		return;
+
+	if (likely(qedi) && likely(qedi->pdev))
+		pr_warn("[%s]:[%s:%d]:%d: %pV", dev_name(&qedi->pdev->dev),
+			nfunc, line, qedi->host_no, &vaf);
+	else
+		pr_warn("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
+
+	va_end(va);
+}
+
+void
+qedi_dbg_notice(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
+		const char *fmt, ...)
+{
+	va_list va;
+	struct va_format vaf;
+	char nfunc[32];
+
+	memset(nfunc, 0, sizeof(nfunc));
+	memcpy(nfunc, func, sizeof(nfunc) - 1);
+
+	va_start(va, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &va;
+
+	if (!(qedi_dbg_log & QEDI_LOG_NOTICE))
+		return;
+
+	if (likely(qedi) && likely(qedi->pdev))
+		pr_notice("[%s]:[%s:%d]:%d: %pV",
+			  dev_name(&qedi->pdev->dev), nfunc, line,
+			  qedi->host_no, &vaf);
+	else
+		pr_notice("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
+
+	va_end(va);
+}
+
+void
+qedi_dbg_info(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
+	      u32 level, const char *fmt, ...)
+{
+	va_list va;
+	struct va_format vaf;
+	char nfunc[32];
+
+	memset(nfunc, 0, sizeof(nfunc));
+	memcpy(nfunc, func, sizeof(nfunc) - 1);
+
+	va_start(va, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &va;
+
+	if (!(qedi_dbg_log & level))
+		return;
+
+	if (likely(qedi) && likely(qedi->pdev))
+		pr_info("[%s]:[%s:%d]:%d: %pV", dev_name(&qedi->pdev->dev),
+			nfunc, line, qedi->host_no, &vaf);
+	else
+		pr_info("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
+
+	va_end(va);
+}
+
+int
+qedi_create_sysfs_attr(struct Scsi_Host *shost, struct sysfs_bin_attrs *iter)
+{
+	int ret = 0;
+
+	for (; iter->name; iter++) {
+		ret = sysfs_create_bin_file(&shost->shost_gendev.kobj,
+					    iter->attr);
+		if (ret)
+			pr_err("Unable to create sysfs %s attr, err(%d).\n",
+			       iter->name, ret);
+	}
+	return ret;
+}
+
+void
+qedi_remove_sysfs_attr(struct Scsi_Host *shost, struct sysfs_bin_attrs *iter)
+{
+	for (; iter->name; iter++)
+		sysfs_remove_bin_file(&shost->shost_gendev.kobj, iter->attr);
+}
diff --git a/drivers/scsi/qedi/qedi_dbg.h b/drivers/scsi/qedi/qedi_dbg.h
new file mode 100644
index 0000000..c55572b
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_dbg.h
@@ -0,0 +1,144 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QEDI_DBG_H_
+#define _QEDI_DBG_H_
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/compiler.h>
+#include <linux/string.h>
+#include <linux/version.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <scsi/scsi_transport.h>
+#include <scsi/scsi_transport_iscsi.h>
+#include <linux/fs.h>
+
+#define __PREVENT_QED_HSI__
+#include <linux/qed/common_hsi.h>
+#include <linux/qed/qed_if.h>
+
+extern uint qedi_dbg_log;
+
+/* Debug print level definitions */
+#define QEDI_LOG_DEFAULT	0x1		/* Set default logging mask */
+#define QEDI_LOG_INFO		0x2		/* Informational logs,
+						 * MAC address, WWPN, WWNN
+						 */
+#define QEDI_LOG_DISC		0x4		/* Init, discovery, rport */
+#define QEDI_LOG_LL2		0x8		/* LL2, VLAN logs */
+#define QEDI_LOG_CONN		0x10		/* Connection setup, cleanup */
+#define QEDI_LOG_EVT		0x20		/* Events, link, mtu */
+#define QEDI_LOG_TIMER		0x40		/* Timer events */
+#define QEDI_LOG_MP_REQ		0x80		/* Middle Path (MP) logs */
+#define QEDI_LOG_SCSI_TM	0x100		/* SCSI Aborts, Task Mgmt */
+#define QEDI_LOG_UNSOL		0x200		/* unsolicited event logs */
+#define QEDI_LOG_IO		0x400		/* scsi cmd, completion */
+#define QEDI_LOG_MQ		0x800		/* Multi Queue logs */
+#define QEDI_LOG_BSG		0x1000		/* BSG logs */
+#define QEDI_LOG_DEBUGFS	0x2000		/* debugFS logs */
+#define QEDI_LOG_LPORT		0x4000		/* lport logs */
+#define QEDI_LOG_ELS		0x8000		/* ELS logs */
+#define QEDI_LOG_NPIV		0x10000		/* NPIV logs */
+#define QEDI_LOG_SESS		0x20000		/* Conection setup, cleanup */
+#define QEDI_LOG_UIO		0x40000		/* iSCSI UIO logs */
+#define QEDI_LOG_TID		0x80000         /* FW TID context acquire,
+						 * free
+						 */
+#define QEDI_TRACK_TID		0x100000        /* Track TID state. To be
+						 * enabled only at module load
+						 * and not run-time.
+						 */
+#define QEDI_TRACK_CMD_LIST    0x300000        /* Track active cmd list nodes,
+						* done with reference to TID,
+						* hence TRACK_TID also enabled.
+						*/
+#define QEDI_LOG_NOTICE		0x40000000	/* Notice logs */
+#define QEDI_LOG_WARN		0x80000000	/* Warning logs */
+
+/* Debug context structure */
+struct qedi_dbg_ctx {
+	unsigned int host_no;
+	struct pci_dev *pdev;
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *bdf_dentry;
+#endif
+};
+
+#define QEDI_ERR(pdev, fmt, ...)	\
+		qedi_dbg_err(pdev, __func__, __LINE__, fmt, ## __VA_ARGS__)
+#define QEDI_WARN(pdev, fmt, ...)	\
+		qedi_dbg_warn(pdev, __func__, __LINE__, fmt, ## __VA_ARGS__)
+#define QEDI_NOTICE(pdev, fmt, ...)	\
+		qedi_dbg_notice(pdev, __func__, __LINE__, fmt, ## __VA_ARGS__)
+#define QEDI_INFO(pdev, level, fmt, ...)	\
+		qedi_dbg_info(pdev, __func__, __LINE__, level, fmt,	\
+			      ## __VA_ARGS__)
+
+void qedi_dbg_err(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
+		  const char *fmt, ...);
+void qedi_dbg_warn(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
+		   const char *fmt, ...);
+void qedi_dbg_notice(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
+		     const char *fmt, ...);
+void qedi_dbg_info(struct qedi_dbg_ctx *qedi, const char *func, u32 line,
+		   u32 info, const char *fmt, ...);
+
+struct Scsi_Host;
+
+struct sysfs_bin_attrs {
+	char *name;
+	struct bin_attribute *attr;
+};
+
+int qedi_create_sysfs_attr(struct Scsi_Host *shost,
+			   struct sysfs_bin_attrs *iter);
+void qedi_remove_sysfs_attr(struct Scsi_Host *shost,
+			    struct sysfs_bin_attrs *iter);
+
+#ifdef CONFIG_DEBUG_FS
+/* DebugFS related code */
+struct qedi_list_of_funcs {
+	char *oper_str;
+	ssize_t (*oper_func)(struct qedi_dbg_ctx *qedi);
+};
+
+struct qedi_debugfs_ops {
+	char *name;
+	struct qedi_list_of_funcs *qedi_funcs;
+};
+
+#define qedi_dbg_fileops(drv, ops) \
+{ \
+	.owner  = THIS_MODULE, \
+	.open   = simple_open, \
+	.read   = drv##_dbg_##ops##_cmd_read, \
+	.write  = drv##_dbg_##ops##_cmd_write \
+}
+
+/* Used for debugfs sequential files */
+#define qedi_dbg_fileops_seq(drv, ops) \
+{ \
+	.owner = THIS_MODULE, \
+	.open = drv##_dbg_##ops##_open, \
+	.read = seq_read, \
+	.llseek = seq_lseek, \
+	.release = single_release, \
+}
+
+void qedi_dbg_host_init(struct qedi_dbg_ctx *qedi,
+			struct qedi_debugfs_ops *dops,
+			const struct file_operations *fops);
+void qedi_dbg_host_exit(struct qedi_dbg_ctx *qedi);
+void qedi_dbg_init(char *drv_name);
+void qedi_dbg_exit(void);
+#endif /* CONFIG_DEBUG_FS */
+
+#endif /* _QEDI_DBG_H_ */
diff --git a/drivers/scsi/qedi/qedi_debugfs.c b/drivers/scsi/qedi/qedi_debugfs.c
new file mode 100644
index 0000000..9559362
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_debugfs.c
@@ -0,0 +1,244 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include "qedi.h"
+#include "qedi_dbg.h"
+
+#include <linux/uaccess.h>
+#include <linux/debugfs.h>
+#include <linux/module.h>
+
+int do_not_recover;
+static struct dentry *qedi_dbg_root;
+
+void
+qedi_dbg_host_init(struct qedi_dbg_ctx *qedi,
+		   struct qedi_debugfs_ops *dops,
+		   const struct file_operations *fops)
+{
+	char host_dirname[32];
+	struct dentry *file_dentry = NULL;
+
+	sprintf(host_dirname, "host%u", qedi->host_no);
+	qedi->bdf_dentry = debugfs_create_dir(host_dirname, qedi_dbg_root);
+	if (!qedi->bdf_dentry)
+		return;
+
+	while (dops) {
+		if (!(dops->name))
+			break;
+
+		file_dentry = debugfs_create_file(dops->name, 0600,
+						  qedi->bdf_dentry, qedi,
+						  fops);
+		if (!file_dentry) {
+			QEDI_INFO(qedi, QEDI_LOG_DEBUGFS,
+				  "Debugfs entry %s creation failed\n",
+				  dops->name);
+			debugfs_remove_recursive(qedi->bdf_dentry);
+			return;
+		}
+		dops++;
+		fops++;
+	}
+}
+
+void
+qedi_dbg_host_exit(struct qedi_dbg_ctx *qedi)
+{
+	debugfs_remove_recursive(qedi->bdf_dentry);
+	qedi->bdf_dentry = NULL;
+}
+
+void
+qedi_dbg_init(char *drv_name)
+{
+	qedi_dbg_root = debugfs_create_dir(drv_name, NULL);
+	if (!qedi_dbg_root)
+		QEDI_INFO(NULL, QEDI_LOG_DEBUGFS, "Init of debugfs failed\n");
+}
+
+void
+qedi_dbg_exit(void)
+{
+	debugfs_remove_recursive(qedi_dbg_root);
+	qedi_dbg_root = NULL;
+}
+
+static ssize_t
+qedi_dbg_do_not_recover_enable(struct qedi_dbg_ctx *qedi_dbg)
+{
+	if (!do_not_recover)
+		do_not_recover = 1;
+
+	QEDI_INFO(qedi_dbg, QEDI_LOG_DEBUGFS, "do_not_recover=%d\n",
+		  do_not_recover);
+	return 0;
+}
+
+static ssize_t
+qedi_dbg_do_not_recover_disable(struct qedi_dbg_ctx *qedi_dbg)
+{
+	if (do_not_recover)
+		do_not_recover = 0;
+
+	QEDI_INFO(qedi_dbg, QEDI_LOG_DEBUGFS, "do_not_recover=%d\n",
+		  do_not_recover);
+	return 0;
+}
+
+static struct qedi_list_of_funcs qedi_dbg_do_not_recover_ops[] = {
+	{ "enable", qedi_dbg_do_not_recover_enable },
+	{ "disable", qedi_dbg_do_not_recover_disable },
+	{ NULL, NULL }
+};
+
+struct qedi_debugfs_ops qedi_debugfs_ops[] = {
+	{ "gbl_ctx", NULL },
+	{ "do_not_recover", qedi_dbg_do_not_recover_ops},
+	{ "io_trace", NULL },
+	{ NULL, NULL }
+};
+
+static ssize_t
+qedi_dbg_do_not_recover_cmd_write(struct file *filp, const char __user *buffer,
+				  size_t count, loff_t *ppos)
+{
+	size_t cnt = 0;
+	struct qedi_dbg_ctx *qedi_dbg =
+			(struct qedi_dbg_ctx *)filp->private_data;
+	struct qedi_list_of_funcs *lof = qedi_dbg_do_not_recover_ops;
+
+	if (*ppos)
+		return 0;
+
+	while (lof) {
+		if (!(lof->oper_str))
+			break;
+
+		if (!strncmp(lof->oper_str, buffer, strlen(lof->oper_str))) {
+			cnt = lof->oper_func(qedi_dbg);
+			break;
+		}
+
+		lof++;
+	}
+	return (count - cnt);
+}
+
+static ssize_t
+qedi_dbg_do_not_recover_cmd_read(struct file *filp, char __user *buffer,
+				 size_t count, loff_t *ppos)
+{
+	size_t cnt = 0;
+
+	if (*ppos)
+		return 0;
+
+	cnt = sprintf(buffer, "do_not_recover=%d\n", do_not_recover);
+	cnt = min_t(int, count, cnt - *ppos);
+	*ppos += cnt;
+	return cnt;
+}
+
+static int
+qedi_gbl_ctx_show(struct seq_file *s, void *unused)
+{
+	struct qedi_fastpath *fp = NULL;
+	struct qed_sb_info *sb_info = NULL;
+	struct status_block *sb = NULL;
+	struct global_queue *que = NULL;
+	int id;
+	u16 prod_idx;
+	struct qedi_ctx *qedi = s->private;
+	unsigned long flags;
+
+	seq_puts(s, " DUMP CQ CONTEXT:\n");
+
+	for (id = 0; id < MIN_NUM_CPUS_MSIX(qedi); id++) {
+		spin_lock_irqsave(&qedi->hba_lock, flags);
+		seq_printf(s, "=========FAST CQ PATH [%d] ==========\n", id);
+		fp = &qedi->fp_array[id];
+		sb_info = fp->sb_info;
+		sb = sb_info->sb_virt;
+		prod_idx = (sb->pi_array[QEDI_PROTO_CQ_PROD_IDX] &
+			    STATUS_BLOCK_PROD_INDEX_MASK);
+		seq_printf(s, "SB PROD IDX: %d\n", prod_idx);
+		que = qedi->global_queues[fp->sb_id];
+		seq_printf(s, "DRV CONS IDX: %d\n", que->cq_cons_idx);
+		seq_printf(s, "CQ complete host memory: %d\n", fp->sb_id);
+		seq_puts(s, "=========== END ==================\n\n\n");
+		spin_unlock_irqrestore(&qedi->hba_lock, flags);
+	}
+	return 0;
+}
+
+static int
+qedi_dbg_gbl_ctx_open(struct inode *inode, struct file *file)
+{
+	struct qedi_dbg_ctx *qedi_dbg = inode->i_private;
+	struct qedi_ctx *qedi = container_of(qedi_dbg, struct qedi_ctx,
+					     dbg_ctx);
+
+	return single_open(file, qedi_gbl_ctx_show, qedi);
+}
+
+static int
+qedi_io_trace_show(struct seq_file *s, void *unused)
+{
+	int id, idx = 0;
+	struct qedi_ctx *qedi = s->private;
+	struct qedi_io_log *io_log;
+	unsigned long flags;
+
+	seq_puts(s, " DUMP IO LOGS:\n");
+	spin_lock_irqsave(&qedi->io_trace_lock, flags);
+	idx = qedi->io_trace_idx;
+	for (id = 0; id < QEDI_IO_TRACE_SIZE; id++) {
+		io_log = &qedi->io_trace_buf[idx];
+		seq_printf(s, "iodir-%d:", io_log->direction);
+		seq_printf(s, "tid-0x%x:", io_log->task_id);
+		seq_printf(s, "cid-0x%x:", io_log->cid);
+		seq_printf(s, "lun-%d:", io_log->lun);
+		seq_printf(s, "op-0x%02x:", io_log->op);
+		seq_printf(s, "0x%02x%02x%02x%02x:", io_log->lba[0],
+			   io_log->lba[1], io_log->lba[2], io_log->lba[3]);
+		seq_printf(s, "buflen-%d:", io_log->bufflen);
+		seq_printf(s, "sgcnt-%d:", io_log->sg_count);
+		seq_printf(s, "res-0x%08x:", io_log->result);
+		seq_printf(s, "jif-%lu:", io_log->jiffies);
+		seq_printf(s, "blk_req_cpu-%d:", io_log->blk_req_cpu);
+		seq_printf(s, "req_cpu-%d:", io_log->req_cpu);
+		seq_printf(s, "intr_cpu-%d:", io_log->intr_cpu);
+		seq_printf(s, "blk_rsp_cpu-%d\n", io_log->blk_rsp_cpu);
+
+		idx++;
+		if (idx == QEDI_IO_TRACE_SIZE)
+			idx = 0;
+	}
+	spin_unlock_irqrestore(&qedi->io_trace_lock, flags);
+	return 0;
+}
+
+static int
+qedi_dbg_io_trace_open(struct inode *inode, struct file *file)
+{
+	struct qedi_dbg_ctx *qedi_dbg = inode->i_private;
+	struct qedi_ctx *qedi = container_of(qedi_dbg, struct qedi_ctx,
+					     dbg_ctx);
+
+	return single_open(file, qedi_io_trace_show, qedi);
+}
+
+const struct file_operations qedi_dbg_fops[] = {
+	qedi_dbg_fileops_seq(qedi, gbl_ctx),
+	qedi_dbg_fileops(qedi, do_not_recover),
+	qedi_dbg_fileops_seq(qedi, io_trace),
+	{ NULL, NULL },
+};
diff --git a/drivers/scsi/qedi/qedi_fw.c b/drivers/scsi/qedi/qedi_fw.c
new file mode 100644
index 0000000..b1d3904
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_fw.c
@@ -0,0 +1,2378 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/blkdev.h>
+#include <scsi/scsi_tcq.h>
+#include <linux/delay.h>
+
+#include "qedi.h"
+#include "qedi_iscsi.h"
+#include "qedi_gbl.h"
+
+static int qedi_send_iscsi_tmf(struct qedi_conn *qedi_conn,
+			       struct iscsi_task *mtask);
+
+void qedi_iscsi_unmap_sg_list(struct qedi_cmd *cmd)
+{
+	struct scsi_cmnd *sc = cmd->scsi_cmd;
+
+	if (cmd->io_tbl.sge_valid && sc) {
+		cmd->io_tbl.sge_valid = 0;
+		scsi_dma_unmap(sc);
+	}
+}
+
+static void qedi_process_logout_resp(struct qedi_ctx *qedi,
+				     union iscsi_cqe *cqe,
+				     struct iscsi_task *task,
+				     struct qedi_conn *qedi_conn)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_logout_rsp *resp_hdr;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_logout_response_hdr *cqe_logout_response;
+	struct qedi_cmd *cmd;
+
+	cmd = (struct qedi_cmd *)task->dd_data;
+	cqe_logout_response = &cqe->cqe_common.iscsi_hdr.logout_response;
+	spin_lock(&session->back_lock);
+	resp_hdr = (struct iscsi_logout_rsp *)&qedi_conn->gen_pdu.resp_hdr;
+	memset(resp_hdr, 0, sizeof(struct iscsi_hdr));
+	resp_hdr->opcode = cqe_logout_response->opcode;
+	resp_hdr->flags = cqe_logout_response->flags;
+	resp_hdr->hlength = 0;
+
+	resp_hdr->itt = build_itt(cqe->cqe_solicited.itid, conn->session->age);
+	resp_hdr->statsn = cpu_to_be32(cqe_logout_response->stat_sn);
+	resp_hdr->exp_cmdsn = cpu_to_be32(cqe_logout_response->exp_cmd_sn);
+	resp_hdr->max_cmdsn = cpu_to_be32(cqe_logout_response->max_cmd_sn);
+
+	resp_hdr->t2wait = cpu_to_be32(cqe_logout_response->time2wait);
+	resp_hdr->t2retain = cpu_to_be32(cqe_logout_response->time2retain);
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_TID,
+		  "Freeing tid=0x%x for cid=0x%x\n",
+		  cmd->task_id, qedi_conn->iscsi_conn_id);
+
+	if (likely(cmd->io_cmd_in_list)) {
+		cmd->io_cmd_in_list = false;
+		list_del_init(&cmd->io_cmd);
+		qedi_conn->active_cmd_count--;
+	} else {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+			  "Active cmd list node already deleted, tid=0x%x, cid=0x%x, io_cmd_node=%p\n",
+			  cmd->task_id, qedi_conn->iscsi_conn_id,
+			  &cmd->io_cmd);
+	}
+
+	cmd->state = RESPONSE_RECEIVED;
+	qedi_clear_task_idx(qedi, cmd->task_id);
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)resp_hdr, NULL, 0);
+
+	spin_unlock(&session->back_lock);
+}
+
+static void qedi_process_text_resp(struct qedi_ctx *qedi,
+				   union iscsi_cqe *cqe,
+				   struct iscsi_task *task,
+				   struct qedi_conn *qedi_conn)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_task_context *task_ctx;
+	struct iscsi_text_rsp *resp_hdr_ptr;
+	struct iscsi_text_response_hdr *cqe_text_response;
+	struct qedi_cmd *cmd;
+	int pld_len;
+	u32 *tmp;
+
+	cmd = (struct qedi_cmd *)task->dd_data;
+	task_ctx = qedi_get_task_mem(&qedi->tasks, cmd->task_id);
+
+	cqe_text_response = &cqe->cqe_common.iscsi_hdr.text_response;
+	spin_lock(&session->back_lock);
+	resp_hdr_ptr =  (struct iscsi_text_rsp *)&qedi_conn->gen_pdu.resp_hdr;
+	memset(resp_hdr_ptr, 0, sizeof(struct iscsi_hdr));
+	resp_hdr_ptr->opcode = cqe_text_response->opcode;
+	resp_hdr_ptr->flags = cqe_text_response->flags;
+	resp_hdr_ptr->hlength = 0;
+
+	hton24(resp_hdr_ptr->dlength,
+	       (cqe_text_response->hdr_second_dword &
+		ISCSI_TEXT_RESPONSE_HDR_DATA_SEG_LEN_MASK));
+	tmp = (u32 *)resp_hdr_ptr->dlength;
+
+	resp_hdr_ptr->itt = build_itt(cqe->cqe_solicited.itid,
+				      conn->session->age);
+	resp_hdr_ptr->ttt = cqe_text_response->ttt;
+	resp_hdr_ptr->statsn = cpu_to_be32(cqe_text_response->stat_sn);
+	resp_hdr_ptr->exp_cmdsn = cpu_to_be32(cqe_text_response->exp_cmd_sn);
+	resp_hdr_ptr->max_cmdsn = cpu_to_be32(cqe_text_response->max_cmd_sn);
+
+	pld_len = cqe_text_response->hdr_second_dword &
+		  ISCSI_TEXT_RESPONSE_HDR_DATA_SEG_LEN_MASK;
+	qedi_conn->gen_pdu.resp_wr_ptr = qedi_conn->gen_pdu.resp_buf + pld_len;
+
+	memset(task_ctx, '\0', sizeof(*task_ctx));
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_TID,
+		  "Freeing tid=0x%x for cid=0x%x\n",
+		  cmd->task_id, qedi_conn->iscsi_conn_id);
+
+	if (likely(cmd->io_cmd_in_list)) {
+		cmd->io_cmd_in_list = false;
+		list_del_init(&cmd->io_cmd);
+		qedi_conn->active_cmd_count--;
+	} else {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+			  "Active cmd list node already deleted, tid=0x%x, cid=0x%x, io_cmd_node=%p\n",
+			  cmd->task_id, qedi_conn->iscsi_conn_id,
+			  &cmd->io_cmd);
+	}
+
+	cmd->state = RESPONSE_RECEIVED;
+	qedi_clear_task_idx(qedi, cmd->task_id);
+
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)resp_hdr_ptr,
+			     qedi_conn->gen_pdu.resp_buf,
+			     (qedi_conn->gen_pdu.resp_wr_ptr -
+			      qedi_conn->gen_pdu.resp_buf));
+	spin_unlock(&session->back_lock);
+}
+
+static void qedi_tmf_resp_work(struct work_struct *work)
+{
+	struct qedi_cmd *qedi_cmd =
+				container_of(work, struct qedi_cmd, tmf_work);
+	struct qedi_conn *qedi_conn = qedi_cmd->conn;
+	struct qedi_ctx *qedi = qedi_conn->qedi;
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_tm_rsp *resp_hdr_ptr;
+	struct iscsi_cls_session *cls_sess;
+	int rval = 0;
+
+	set_bit(QEDI_CONN_FW_CLEANUP, &qedi_conn->flags);
+	resp_hdr_ptr =  (struct iscsi_tm_rsp *)qedi_cmd->tmf_resp_buf;
+	cls_sess = iscsi_conn_to_session(qedi_conn->cls_conn);
+
+	iscsi_block_session(session->cls_session);
+	rval = qedi_cleanup_all_io(qedi, qedi_conn, qedi_cmd->task, true);
+	if (rval) {
+		clear_bit(QEDI_CONN_FW_CLEANUP, &qedi_conn->flags);
+		qedi_clear_task_idx(qedi, qedi_cmd->task_id);
+		iscsi_unblock_session(session->cls_session);
+		return;
+	}
+
+	iscsi_unblock_session(session->cls_session);
+	qedi_clear_task_idx(qedi, qedi_cmd->task_id);
+
+	spin_lock(&session->back_lock);
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)resp_hdr_ptr, NULL, 0);
+	spin_unlock(&session->back_lock);
+	kfree(resp_hdr_ptr);
+	clear_bit(QEDI_CONN_FW_CLEANUP, &qedi_conn->flags);
+}
+
+static void qedi_process_tmf_resp(struct qedi_ctx *qedi,
+				  union iscsi_cqe *cqe,
+				  struct iscsi_task *task,
+				  struct qedi_conn *qedi_conn)
+
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_tmf_response_hdr *cqe_tmp_response;
+	struct iscsi_tm_rsp *resp_hdr_ptr;
+	struct iscsi_tm *tmf_hdr;
+	struct qedi_cmd *qedi_cmd = NULL;
+	u32 *tmp;
+
+	cqe_tmp_response = &cqe->cqe_common.iscsi_hdr.tmf_response;
+
+	qedi_cmd = task->dd_data;
+	qedi_cmd->tmf_resp_buf = kzalloc(sizeof(*resp_hdr_ptr), GFP_KERNEL);
+	if (!qedi_cmd->tmf_resp_buf) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Failed to allocate resp buf, cid=0x%x\n",
+			  qedi_conn->iscsi_conn_id);
+		return;
+	}
+
+	spin_lock(&session->back_lock);
+	resp_hdr_ptr =  (struct iscsi_tm_rsp *)qedi_cmd->tmf_resp_buf;
+	memset(resp_hdr_ptr, 0, sizeof(struct iscsi_tm_rsp));
+
+	/* Fill up the header */
+	resp_hdr_ptr->opcode = cqe_tmp_response->opcode;
+	resp_hdr_ptr->flags = cqe_tmp_response->hdr_flags;
+	resp_hdr_ptr->response = cqe_tmp_response->hdr_response;
+	resp_hdr_ptr->hlength = 0;
+
+	hton24(resp_hdr_ptr->dlength,
+	       (cqe_tmp_response->hdr_second_dword &
+		ISCSI_TMF_RESPONSE_HDR_DATA_SEG_LEN_MASK));
+	tmp = (u32 *)resp_hdr_ptr->dlength;
+	resp_hdr_ptr->itt = build_itt(cqe->cqe_solicited.itid,
+				      conn->session->age);
+	resp_hdr_ptr->statsn = cpu_to_be32(cqe_tmp_response->stat_sn);
+	resp_hdr_ptr->exp_cmdsn  = cpu_to_be32(cqe_tmp_response->exp_cmd_sn);
+	resp_hdr_ptr->max_cmdsn = cpu_to_be32(cqe_tmp_response->max_cmd_sn);
+
+	tmf_hdr = (struct iscsi_tm *)qedi_cmd->task->hdr;
+
+	if (likely(qedi_cmd->io_cmd_in_list)) {
+		qedi_cmd->io_cmd_in_list = false;
+		list_del_init(&qedi_cmd->io_cmd);
+		qedi_conn->active_cmd_count--;
+	}
+
+	if (((tmf_hdr->flags & ISCSI_FLAG_TM_FUNC_MASK) ==
+	      ISCSI_TM_FUNC_LOGICAL_UNIT_RESET) ||
+	    ((tmf_hdr->flags & ISCSI_FLAG_TM_FUNC_MASK) ==
+	      ISCSI_TM_FUNC_TARGET_WARM_RESET) ||
+	    ((tmf_hdr->flags & ISCSI_FLAG_TM_FUNC_MASK) ==
+	      ISCSI_TM_FUNC_TARGET_COLD_RESET)) {
+		INIT_WORK(&qedi_cmd->tmf_work, qedi_tmf_resp_work);
+		queue_work(qedi->tmf_thread, &qedi_cmd->tmf_work);
+		goto unblock_sess;
+	}
+
+	qedi_clear_task_idx(qedi, qedi_cmd->task_id);
+
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)resp_hdr_ptr, NULL, 0);
+	kfree(resp_hdr_ptr);
+
+unblock_sess:
+	spin_unlock(&session->back_lock);
+}
+
+static void qedi_process_login_resp(struct qedi_ctx *qedi,
+				    union iscsi_cqe *cqe,
+				    struct iscsi_task *task,
+				    struct qedi_conn *qedi_conn)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_task_context *task_ctx;
+	struct iscsi_login_rsp *resp_hdr_ptr;
+	struct iscsi_login_response_hdr *cqe_login_response;
+	struct qedi_cmd *cmd;
+	int pld_len;
+	u32 *tmp;
+
+	cmd = (struct qedi_cmd *)task->dd_data;
+
+	cqe_login_response = &cqe->cqe_common.iscsi_hdr.login_response;
+	task_ctx = qedi_get_task_mem(&qedi->tasks, cmd->task_id);
+
+	spin_lock(&session->back_lock);
+	resp_hdr_ptr =  (struct iscsi_login_rsp *)&qedi_conn->gen_pdu.resp_hdr;
+	memset(resp_hdr_ptr, 0, sizeof(struct iscsi_login_rsp));
+	resp_hdr_ptr->opcode = cqe_login_response->opcode;
+	resp_hdr_ptr->flags = cqe_login_response->flags_attr;
+	resp_hdr_ptr->hlength = 0;
+
+	hton24(resp_hdr_ptr->dlength,
+	       (cqe_login_response->hdr_second_dword &
+		ISCSI_LOGIN_RESPONSE_HDR_DATA_SEG_LEN_MASK));
+	tmp = (u32 *)resp_hdr_ptr->dlength;
+	resp_hdr_ptr->itt = build_itt(cqe->cqe_solicited.itid,
+				      conn->session->age);
+	resp_hdr_ptr->tsih = cqe_login_response->tsih;
+	resp_hdr_ptr->statsn = cpu_to_be32(cqe_login_response->stat_sn);
+	resp_hdr_ptr->exp_cmdsn = cpu_to_be32(cqe_login_response->exp_cmd_sn);
+	resp_hdr_ptr->max_cmdsn = cpu_to_be32(cqe_login_response->max_cmd_sn);
+	resp_hdr_ptr->status_class = cqe_login_response->status_class;
+	resp_hdr_ptr->status_detail = cqe_login_response->status_detail;
+	pld_len = cqe_login_response->hdr_second_dword &
+		  ISCSI_LOGIN_RESPONSE_HDR_DATA_SEG_LEN_MASK;
+	qedi_conn->gen_pdu.resp_wr_ptr = qedi_conn->gen_pdu.resp_buf + pld_len;
+
+	if (likely(cmd->io_cmd_in_list)) {
+		cmd->io_cmd_in_list = false;
+		list_del_init(&cmd->io_cmd);
+		qedi_conn->active_cmd_count--;
+	}
+
+	memset(task_ctx, '\0', sizeof(*task_ctx));
+
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)resp_hdr_ptr,
+			     qedi_conn->gen_pdu.resp_buf,
+			     (qedi_conn->gen_pdu.resp_wr_ptr -
+			     qedi_conn->gen_pdu.resp_buf));
+
+	spin_unlock(&session->back_lock);
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_TID,
+		  "Freeing tid=0x%x for cid=0x%x\n",
+		  cmd->task_id, qedi_conn->iscsi_conn_id);
+	cmd->state = RESPONSE_RECEIVED;
+	qedi_clear_task_idx(qedi, cmd->task_id);
+}
+
+static void qedi_get_rq_bdq_buf(struct qedi_ctx *qedi,
+				struct iscsi_cqe_unsolicited *cqe,
+				char *ptr, int len)
+{
+	u16 idx = 0;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "pld_len [%d], bdq_prod_idx [%d], idx [%d]\n",
+		  len, qedi->bdq_prod_idx,
+		  (qedi->bdq_prod_idx % qedi->rq_num_entries));
+
+	/* Obtain buffer address from rqe_opaque */
+	idx = cqe->rqe_opaque.lo;
+	if ((idx < 0) || (idx > (QEDI_BDQ_NUM - 1))) {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "wrong idx %d returned by FW, dropping the unsolicited pkt\n",
+			  idx);
+		return;
+	}
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "rqe_opaque.lo [0x%p], rqe_opaque.hi [0x%p], idx [%d]\n",
+		  cqe->rqe_opaque.lo, cqe->rqe_opaque.hi, idx);
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "unsol_cqe_type = %d\n", cqe->unsol_cqe_type);
+	switch (cqe->unsol_cqe_type) {
+	case ISCSI_CQE_UNSOLICITED_SINGLE:
+	case ISCSI_CQE_UNSOLICITED_FIRST:
+		if (len)
+			memcpy(ptr, (void *)qedi->bdq[idx].buf_addr, len);
+		break;
+	case ISCSI_CQE_UNSOLICITED_MIDDLE:
+	case ISCSI_CQE_UNSOLICITED_LAST:
+		break;
+	default:
+		break;
+	}
+}
+
+static void qedi_put_rq_bdq_buf(struct qedi_ctx *qedi,
+				struct iscsi_cqe_unsolicited *cqe,
+				int count)
+{
+	u16 tmp;
+	u16 idx = 0;
+	struct scsi_bd *pbl;
+
+	/* Obtain buffer address from rqe_opaque */
+	idx = cqe->rqe_opaque.lo;
+	if ((idx < 0) || (idx > (QEDI_BDQ_NUM - 1))) {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "wrong idx %d returned by FW, dropping the unsolicited pkt\n",
+			  idx);
+		return;
+	}
+
+	pbl = (struct scsi_bd *)qedi->bdq_pbl;
+	pbl += (qedi->bdq_prod_idx % qedi->rq_num_entries);
+	pbl->address.hi = cpu_to_le32(QEDI_U64_HI(qedi->bdq[idx].buf_dma));
+	pbl->address.lo = cpu_to_le32(QEDI_U64_LO(qedi->bdq[idx].buf_dma));
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "pbl [0x%p] pbl->address hi [0x%llx] lo [0x%llx] idx [%d]\n",
+		  pbl, pbl->address.hi, pbl->address.lo, idx);
+	pbl->opaque.hi = 0;
+	pbl->opaque.lo = cpu_to_le32(QEDI_U64_LO(idx));
+
+	/* Increment producer to let f/w know we've handled the frame */
+	qedi->bdq_prod_idx += count;
+
+	writew(qedi->bdq_prod_idx, qedi->bdq_primary_prod);
+	tmp = readw(qedi->bdq_primary_prod);
+
+	writew(qedi->bdq_prod_idx, qedi->bdq_secondary_prod);
+	tmp = readw(qedi->bdq_secondary_prod);
+}
+
+static void qedi_unsol_pdu_adjust_bdq(struct qedi_ctx *qedi,
+				      struct iscsi_cqe_unsolicited *cqe,
+				      u32 pdu_len, u32 num_bdqs,
+				      char *bdq_data)
+{
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "num_bdqs [%d]\n", num_bdqs);
+
+	qedi_get_rq_bdq_buf(qedi, cqe, bdq_data, pdu_len);
+	qedi_put_rq_bdq_buf(qedi, cqe, (num_bdqs + 1));
+}
+
+static int qedi_process_nopin_mesg(struct qedi_ctx *qedi,
+				   union iscsi_cqe *cqe,
+				   struct iscsi_task *task,
+				   struct qedi_conn *qedi_conn, u16 que_idx)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_nop_in_hdr *cqe_nop_in;
+	struct iscsi_nopin *hdr;
+	struct qedi_cmd *cmd;
+	int tgt_async_nop = 0;
+	u32 lun[2];
+	u32 pdu_len, num_bdqs;
+	char bdq_data[QEDI_BDQ_BUF_SIZE];
+	unsigned long flags;
+
+	spin_lock_bh(&session->back_lock);
+	cqe_nop_in = &cqe->cqe_common.iscsi_hdr.nop_in;
+
+	pdu_len = cqe_nop_in->hdr_second_dword &
+		  ISCSI_NOP_IN_HDR_DATA_SEG_LEN_MASK;
+	num_bdqs = pdu_len / QEDI_BDQ_BUF_SIZE;
+
+	hdr = (struct iscsi_nopin *)&qedi_conn->gen_pdu.resp_hdr;
+	memset(hdr, 0, sizeof(struct iscsi_hdr));
+	hdr->opcode = cqe_nop_in->opcode;
+	hdr->max_cmdsn = cpu_to_be32(cqe_nop_in->max_cmd_sn);
+	hdr->exp_cmdsn = cpu_to_be32(cqe_nop_in->exp_cmd_sn);
+	hdr->statsn = cpu_to_be32(cqe_nop_in->stat_sn);
+	hdr->ttt = cpu_to_be32(cqe_nop_in->ttt);
+
+	if (cqe->cqe_common.cqe_type == ISCSI_CQE_TYPE_UNSOLICITED) {
+		spin_lock_irqsave(&qedi->hba_lock, flags);
+		qedi_unsol_pdu_adjust_bdq(qedi, &cqe->cqe_unsolicited,
+					  pdu_len, num_bdqs, bdq_data);
+		hdr->itt = RESERVED_ITT;
+		tgt_async_nop = 1;
+		spin_unlock_irqrestore(&qedi->hba_lock, flags);
+		goto done;
+	}
+
+	/* Response to one of our nop-outs */
+	if (task) {
+		cmd = task->dd_data;
+		hdr->flags = ISCSI_FLAG_CMD_FINAL;
+		hdr->itt = build_itt(cqe->cqe_solicited.itid,
+				     conn->session->age);
+		lun[0] = 0xffffffff;
+		lun[1] = 0xffffffff;
+		memcpy(&hdr->lun, lun, sizeof(struct scsi_lun));
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_TID,
+			  "Freeing tid=0x%x for cid=0x%x\n",
+			  cmd->task_id, qedi_conn->iscsi_conn_id);
+		cmd->state = RESPONSE_RECEIVED;
+		spin_lock(&qedi_conn->list_lock);
+		if (likely(cmd->io_cmd_in_list)) {
+			cmd->io_cmd_in_list = false;
+			list_del_init(&cmd->io_cmd);
+			qedi_conn->active_cmd_count--;
+		}
+
+		spin_unlock(&qedi_conn->list_lock);
+		qedi_clear_task_idx(qedi, cmd->task_id);
+	}
+
+done:
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)hdr, bdq_data, pdu_len);
+
+	spin_unlock_bh(&session->back_lock);
+	return tgt_async_nop;
+}
+
+static void qedi_process_async_mesg(struct qedi_ctx *qedi,
+				    union iscsi_cqe *cqe,
+				    struct iscsi_task *task,
+				    struct qedi_conn *qedi_conn,
+				    u16 que_idx)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_async_msg_hdr *cqe_async_msg;
+	struct iscsi_async *resp_hdr;
+	u32 lun[2];
+	u32 pdu_len, num_bdqs;
+	char bdq_data[QEDI_BDQ_BUF_SIZE];
+	unsigned long flags;
+
+	spin_lock_bh(&session->back_lock);
+
+	cqe_async_msg = &cqe->cqe_common.iscsi_hdr.async_msg;
+	pdu_len = cqe_async_msg->hdr_second_dword &
+		ISCSI_ASYNC_MSG_HDR_DATA_SEG_LEN_MASK;
+	num_bdqs = pdu_len / QEDI_BDQ_BUF_SIZE;
+
+	if (cqe->cqe_common.cqe_type == ISCSI_CQE_TYPE_UNSOLICITED) {
+		spin_lock_irqsave(&qedi->hba_lock, flags);
+		qedi_unsol_pdu_adjust_bdq(qedi, &cqe->cqe_unsolicited,
+					  pdu_len, num_bdqs, bdq_data);
+		spin_unlock_irqrestore(&qedi->hba_lock, flags);
+	}
+
+	resp_hdr = (struct iscsi_async *)&qedi_conn->gen_pdu.resp_hdr;
+	memset(resp_hdr, 0, sizeof(struct iscsi_hdr));
+	resp_hdr->opcode = cqe_async_msg->opcode;
+	resp_hdr->flags = 0x80;
+
+	lun[0] = cpu_to_be32(cqe_async_msg->lun.lo);
+	lun[1] = cpu_to_be32(cqe_async_msg->lun.hi);
+	memcpy(&resp_hdr->lun, lun, sizeof(struct scsi_lun));
+	resp_hdr->exp_cmdsn = cpu_to_be32(cqe_async_msg->exp_cmd_sn);
+	resp_hdr->max_cmdsn = cpu_to_be32(cqe_async_msg->max_cmd_sn);
+	resp_hdr->statsn = cpu_to_be32(cqe_async_msg->stat_sn);
+
+	resp_hdr->async_event = cqe_async_msg->async_event;
+	resp_hdr->async_vcode = cqe_async_msg->async_vcode;
+
+	resp_hdr->param1 = cpu_to_be16(cqe_async_msg->param1_rsrv);
+	resp_hdr->param2 = cpu_to_be16(cqe_async_msg->param2_rsrv);
+	resp_hdr->param3 = cpu_to_be16(cqe_async_msg->param3_rsrv);
+
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)resp_hdr, bdq_data,
+			     pdu_len);
+
+	spin_unlock_bh(&session->back_lock);
+}
+
+static void qedi_process_reject_mesg(struct qedi_ctx *qedi,
+				     union iscsi_cqe *cqe,
+				     struct iscsi_task *task,
+				     struct qedi_conn *qedi_conn,
+				     uint16_t que_idx)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_reject_hdr *cqe_reject;
+	struct iscsi_reject *hdr;
+	u32 pld_len, num_bdqs;
+	unsigned long flags;
+
+	spin_lock_bh(&session->back_lock);
+	cqe_reject = &cqe->cqe_common.iscsi_hdr.reject;
+	pld_len = cqe_reject->hdr_second_dword &
+		  ISCSI_REJECT_HDR_DATA_SEG_LEN_MASK;
+	num_bdqs = pld_len / QEDI_BDQ_BUF_SIZE;
+
+	if (cqe->cqe_common.cqe_type == ISCSI_CQE_TYPE_UNSOLICITED) {
+		spin_lock_irqsave(&qedi->hba_lock, flags);
+		qedi_unsol_pdu_adjust_bdq(qedi, &cqe->cqe_unsolicited,
+					  pld_len, num_bdqs, conn->data);
+		spin_unlock_irqrestore(&qedi->hba_lock, flags);
+	}
+	hdr = (struct iscsi_reject *)&qedi_conn->gen_pdu.resp_hdr;
+	memset(hdr, 0, sizeof(struct iscsi_hdr));
+	hdr->opcode = cqe_reject->opcode;
+	hdr->reason = cqe_reject->hdr_reason;
+	hdr->flags = cqe_reject->hdr_flags;
+	hton24(hdr->dlength, (cqe_reject->hdr_second_dword &
+			      ISCSI_REJECT_HDR_DATA_SEG_LEN_MASK));
+	hdr->max_cmdsn = cpu_to_be32(cqe_reject->max_cmd_sn);
+	hdr->exp_cmdsn = cpu_to_be32(cqe_reject->exp_cmd_sn);
+	hdr->statsn = cpu_to_be32(cqe_reject->stat_sn);
+	hdr->ffffffff = cpu_to_be32(0xffffffff);
+
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)hdr,
+			     conn->data, pld_len);
+	spin_unlock_bh(&session->back_lock);
+}
+
+static void qedi_scsi_completion(struct qedi_ctx *qedi,
+				 union iscsi_cqe *cqe,
+				 struct iscsi_task *task,
+				 struct iscsi_conn *conn)
+{
+	struct scsi_cmnd *sc_cmd;
+	struct qedi_cmd *cmd = task->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_scsi_rsp *hdr;
+	struct iscsi_data_in_hdr *cqe_data_in;
+	int datalen = 0;
+	struct qedi_conn *qedi_conn;
+	u32 iscsi_cid;
+	bool mark_cmd_node_deleted = false;
+	u8 cqe_err_bits = 0;
+
+	iscsi_cid  = cqe->cqe_common.conn_id;
+	qedi_conn = qedi->cid_que.conn_cid_tbl[iscsi_cid];
+
+	cqe_data_in = &cqe->cqe_common.iscsi_hdr.data_in;
+	cqe_err_bits =
+		cqe->cqe_common.error_bitmap.error_bits.cqe_error_status_bits;
+
+	spin_lock_bh(&session->back_lock);
+	/* get the scsi command */
+	sc_cmd = cmd->scsi_cmd;
+
+	if (!sc_cmd) {
+		QEDI_WARN(&qedi->dbg_ctx, "sc_cmd is NULL!\n");
+		goto error;
+	}
+
+	if (!sc_cmd->SCp.ptr) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "SCp.ptr is NULL, returned in another context.\n");
+		goto error;
+	}
+
+	if (!sc_cmd->request) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "sc_cmd->request is NULL, sc_cmd=%p.\n",
+			  sc_cmd);
+		goto error;
+	}
+
+	if (!sc_cmd->request->special) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "request->special is NULL so request not valid, sc_cmd=%p.\n",
+			  sc_cmd);
+		goto error;
+	}
+
+	if (!sc_cmd->request->q) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "request->q is NULL so request is not valid, sc_cmd=%p.\n",
+			  sc_cmd);
+		goto error;
+	}
+
+	qedi_iscsi_unmap_sg_list(cmd);
+
+	hdr = (struct iscsi_scsi_rsp *)task->hdr;
+	hdr->opcode = cqe_data_in->opcode;
+	hdr->max_cmdsn = cpu_to_be32(cqe_data_in->max_cmd_sn);
+	hdr->exp_cmdsn = cpu_to_be32(cqe_data_in->exp_cmd_sn);
+	hdr->itt = build_itt(cqe->cqe_solicited.itid, conn->session->age);
+	hdr->response = cqe_data_in->reserved1;
+	hdr->cmd_status = cqe_data_in->status_rsvd;
+	hdr->flags = cqe_data_in->flags;
+	hdr->residual_count = cpu_to_be32(cqe_data_in->residual_count);
+
+	if (hdr->cmd_status == SAM_STAT_CHECK_CONDITION) {
+		datalen = cqe_data_in->reserved2 &
+			  ISCSI_COMMON_HDR_DATA_SEG_LEN_MASK;
+		memcpy((char *)conn->data, (char *)cmd->sense_buffer, datalen);
+	}
+
+	/* If f/w reports data underrun err then set residual to IO transfer
+	 * length, set Underrun flag and clear Overrun flag explicitly
+	 */
+	if (unlikely(cqe_err_bits &&
+		     GET_FIELD(cqe_err_bits, CQE_ERROR_BITMAP_UNDER_RUN_ERR))) {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+			  "Under flow itt=0x%x proto flags=0x%x tid=0x%x cid 0x%x fw resid 0x%x sc dlen 0x%x\n",
+			  hdr->itt, cqe_data_in->flags, cmd->task_id,
+			  qedi_conn->iscsi_conn_id, hdr->residual_count,
+			  scsi_bufflen(sc_cmd));
+		hdr->residual_count = cpu_to_be32(scsi_bufflen(sc_cmd));
+		hdr->flags |= ISCSI_FLAG_CMD_UNDERFLOW;
+		hdr->flags &= (~ISCSI_FLAG_CMD_OVERFLOW);
+	}
+
+	spin_lock(&qedi_conn->list_lock);
+	if (likely(cmd->io_cmd_in_list)) {
+		cmd->io_cmd_in_list = false;
+		list_del_init(&cmd->io_cmd);
+		qedi_conn->active_cmd_count--;
+		mark_cmd_node_deleted = true;
+	}
+	spin_unlock(&qedi_conn->list_lock);
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_TID,
+		  "Freeing tid=0x%x for cid=0x%x\n",
+		  cmd->task_id, qedi_conn->iscsi_conn_id);
+	cmd->state = RESPONSE_RECEIVED;
+	if (qedi_io_tracing)
+		qedi_trace_io(qedi, task, cmd->task_id, QEDI_IO_TRACE_RSP);
+
+	qedi_clear_task_idx(qedi, cmd->task_id);
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)hdr,
+			     conn->data, datalen);
+error:
+	spin_unlock_bh(&session->back_lock);
+}
+
+static void qedi_mtask_completion(struct qedi_ctx *qedi,
+				  union iscsi_cqe *cqe,
+				  struct iscsi_task *task,
+				  struct qedi_conn *conn, uint16_t que_idx)
+{
+	struct iscsi_conn *iscsi_conn;
+	u32 hdr_opcode;
+
+	hdr_opcode = cqe->cqe_common.iscsi_hdr.common.hdr_first_byte;
+	iscsi_conn = conn->cls_conn->dd_data;
+
+	switch (hdr_opcode) {
+	case ISCSI_OPCODE_SCSI_RESPONSE:
+	case ISCSI_OPCODE_DATA_IN:
+		qedi_scsi_completion(qedi, cqe, task, iscsi_conn);
+		break;
+	case ISCSI_OPCODE_LOGIN_RESPONSE:
+		qedi_process_login_resp(qedi, cqe, task, conn);
+		break;
+	case ISCSI_OPCODE_TMF_RESPONSE:
+		qedi_process_tmf_resp(qedi, cqe, task, conn);
+		break;
+	case ISCSI_OPCODE_TEXT_RESPONSE:
+		qedi_process_text_resp(qedi, cqe, task, conn);
+		break;
+	case ISCSI_OPCODE_LOGOUT_RESPONSE:
+		qedi_process_logout_resp(qedi, cqe, task, conn);
+		break;
+	case ISCSI_OPCODE_NOP_IN:
+		qedi_process_nopin_mesg(qedi, cqe, task, conn, que_idx);
+		break;
+	default:
+		QEDI_ERR(&qedi->dbg_ctx, "unknown opcode\n");
+	}
+}
+
+static void qedi_process_nopin_local_cmpl(struct qedi_ctx *qedi,
+					  struct iscsi_cqe_solicited *cqe,
+					  struct iscsi_task *task,
+					  struct qedi_conn *qedi_conn)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct qedi_cmd *cmd = task->dd_data;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_UNSOL,
+		  "itid=0x%x, cmd task id=0x%x\n",
+		  cqe->itid, cmd->task_id);
+
+	cmd->state = RESPONSE_RECEIVED;
+	qedi_clear_task_idx(qedi, cmd->task_id);
+
+	spin_lock_bh(&session->back_lock);
+	__iscsi_put_task(task);
+	spin_unlock_bh(&session->back_lock);
+}
+
+static void qedi_process_cmd_cleanup_resp(struct qedi_ctx *qedi,
+					  struct iscsi_cqe_solicited *cqe,
+					  struct iscsi_task *task,
+					  struct iscsi_conn *conn)
+{
+	struct qedi_work_map *work, *work_tmp;
+	u32 proto_itt = cqe->itid;
+	u32 ptmp_itt = 0;
+	itt_t protoitt = 0;
+	int found = 0;
+	struct qedi_cmd *qedi_cmd = NULL;
+	u32 rtid = 0;
+	u32 iscsi_cid;
+	struct qedi_conn *qedi_conn;
+	struct qedi_cmd *cmd_new, *dbg_cmd;
+	struct iscsi_task *mtask;
+	struct iscsi_tm *tmf_hdr = NULL;
+
+	iscsi_cid = cqe->conn_id;
+	qedi_conn = qedi->cid_que.conn_cid_tbl[iscsi_cid];
+
+	/* Based on this itt get the corresponding qedi_cmd */
+	spin_lock_bh(&qedi_conn->tmf_work_lock);
+	list_for_each_entry_safe(work, work_tmp, &qedi_conn->tmf_work_list,
+				 list) {
+		if (work->rtid == proto_itt) {
+			/* We found the command */
+			qedi_cmd = work->qedi_cmd;
+			if (!qedi_cmd->list_tmf_work) {
+				QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+					  "TMF work not found, cqe->tid=0x%x, cid=0x%x\n",
+					  proto_itt, qedi_conn->iscsi_conn_id);
+				WARN_ON(1);
+			}
+			found = 1;
+			mtask = qedi_cmd->task;
+			tmf_hdr = (struct iscsi_tm *)mtask->hdr;
+			rtid = work->rtid;
+
+			list_del_init(&work->list);
+			kfree(work);
+			qedi_cmd->list_tmf_work = NULL;
+		}
+	}
+	spin_unlock_bh(&qedi_conn->tmf_work_lock);
+
+	if (found) {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+			  "TMF work, cqe->tid=0x%x, tmf flags=0x%x, cid=0x%x\n",
+			  proto_itt, tmf_hdr->flags, qedi_conn->iscsi_conn_id);
+
+		if ((tmf_hdr->flags & ISCSI_FLAG_TM_FUNC_MASK) ==
+		    ISCSI_TM_FUNC_ABORT_TASK) {
+			spin_lock_bh(&conn->session->back_lock);
+
+			protoitt = build_itt(get_itt(tmf_hdr->rtt),
+					     conn->session->age);
+			task = iscsi_itt_to_task(conn, protoitt);
+
+			spin_unlock_bh(&conn->session->back_lock);
+
+			if (!task) {
+				QEDI_NOTICE(&qedi->dbg_ctx,
+					    "IO task completed, tmf rtt=0x%x, cid=0x%x\n",
+					    get_itt(tmf_hdr->rtt),
+					    qedi_conn->iscsi_conn_id);
+				return;
+			}
+
+			dbg_cmd = task->dd_data;
+
+			QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+				  "Abort tmf rtt=0x%x, i/o itt=0x%x, i/o tid=0x%x, cid=0x%x\n",
+				  get_itt(tmf_hdr->rtt), get_itt(task->itt),
+				  dbg_cmd->task_id, qedi_conn->iscsi_conn_id);
+
+			if (qedi_cmd->state == CLEANUP_WAIT_FAILED)
+				qedi_cmd->state = CLEANUP_RECV;
+
+			qedi_clear_task_idx(qedi_conn->qedi, rtid);
+
+			spin_lock(&qedi_conn->list_lock);
+			list_del_init(&dbg_cmd->io_cmd);
+			qedi_conn->active_cmd_count--;
+			spin_unlock(&qedi_conn->list_lock);
+			qedi_cmd->state = CLEANUP_RECV;
+			wake_up_interruptible(&qedi_conn->wait_queue);
+		}
+	} else if (qedi_conn->cmd_cleanup_req > 0) {
+		spin_lock_bh(&conn->session->back_lock);
+		qedi_get_proto_itt(qedi, cqe->itid, &ptmp_itt);
+		protoitt = build_itt(ptmp_itt, conn->session->age);
+		task = iscsi_itt_to_task(conn, protoitt);
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+			  "cleanup io itid=0x%x, protoitt=0x%x, cmd_cleanup_cmpl=%d, cid=0x%x\n",
+			  cqe->itid, protoitt, qedi_conn->cmd_cleanup_cmpl,
+			  qedi_conn->iscsi_conn_id);
+
+		spin_unlock_bh(&conn->session->back_lock);
+		if (!task) {
+			QEDI_NOTICE(&qedi->dbg_ctx,
+				    "task is null, itid=0x%x, cid=0x%x\n",
+				    cqe->itid, qedi_conn->iscsi_conn_id);
+			return;
+		}
+		qedi_conn->cmd_cleanup_cmpl++;
+		wake_up(&qedi_conn->wait_queue);
+		cmd_new = task->dd_data;
+
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_TID,
+			  "Freeing tid=0x%x for cid=0x%x\n",
+			  cqe->itid, qedi_conn->iscsi_conn_id);
+		qedi_clear_task_idx(qedi_conn->qedi, cqe->itid);
+
+	} else {
+		qedi_get_proto_itt(qedi, cqe->itid, &ptmp_itt);
+		protoitt = build_itt(ptmp_itt, conn->session->age);
+		task = iscsi_itt_to_task(conn, protoitt);
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Delayed or untracked cleanup response, itt=0x%x, tid=0x%x, cid=0x%x, task=%p\n",
+			 protoitt, cqe->itid, qedi_conn->iscsi_conn_id, task);
+		WARN_ON(1);
+	}
+}
+
+void qedi_fp_process_cqes(struct qedi_work *work)
+{
+	struct qedi_ctx *qedi = work->qedi;
+	union iscsi_cqe *cqe = &work->cqe;
+	struct iscsi_task *task = NULL;
+	struct iscsi_nopout *nopout_hdr;
+	struct qedi_conn *q_conn;
+	struct iscsi_conn *conn;
+	struct qedi_cmd *qedi_cmd;
+	u32 comp_type;
+	u32 iscsi_cid;
+	u32 hdr_opcode;
+	u16 que_idx = work->que_idx;
+	u8 cqe_err_bits = 0;
+
+	comp_type = cqe->cqe_common.cqe_type;
+	hdr_opcode = cqe->cqe_common.iscsi_hdr.common.hdr_first_byte;
+	cqe_err_bits =
+		cqe->cqe_common.error_bitmap.error_bits.cqe_error_status_bits;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "fw_cid=0x%x, cqe type=0x%x, opcode=0x%x\n",
+		  cqe->cqe_common.conn_id, comp_type, hdr_opcode);
+
+	if (comp_type >= MAX_ISCSI_CQES_TYPE) {
+		QEDI_WARN(&qedi->dbg_ctx, "Invalid CqE type\n");
+		return;
+	}
+
+	iscsi_cid  = cqe->cqe_common.conn_id;
+	q_conn = qedi->cid_que.conn_cid_tbl[iscsi_cid];
+	if (!q_conn) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "Session no longer exists for cid=0x%x!!\n",
+			  iscsi_cid);
+		return;
+	}
+
+	conn = q_conn->cls_conn->dd_data;
+
+	if (unlikely(cqe_err_bits &&
+		     GET_FIELD(cqe_err_bits,
+			       CQE_ERROR_BITMAP_DATA_DIGEST_ERR))) {
+		iscsi_conn_failure(conn, ISCSI_ERR_DATA_DGST);
+		return;
+	}
+
+	switch (comp_type) {
+	case ISCSI_CQE_TYPE_SOLICITED:
+	case ISCSI_CQE_TYPE_SOLICITED_WITH_SENSE:
+		qedi_cmd = container_of(work, struct qedi_cmd, cqe_work);
+		task = qedi_cmd->task;
+		if (!task) {
+			QEDI_WARN(&qedi->dbg_ctx, "task is NULL\n");
+			return;
+		}
+
+		/* Process NOPIN local completion */
+		nopout_hdr = (struct iscsi_nopout *)task->hdr;
+		if ((nopout_hdr->itt == RESERVED_ITT) &&
+		    (cqe->cqe_solicited.itid != (u16)RESERVED_ITT)) {
+			qedi_process_nopin_local_cmpl(qedi, &cqe->cqe_solicited,
+						      task, q_conn);
+		} else {
+			cqe->cqe_solicited.itid =
+					       qedi_get_itt(cqe->cqe_solicited);
+			/* Process other solicited responses */
+			qedi_mtask_completion(qedi, cqe, task, q_conn, que_idx);
+		}
+		break;
+	case ISCSI_CQE_TYPE_UNSOLICITED:
+		switch (hdr_opcode) {
+		case ISCSI_OPCODE_NOP_IN:
+			qedi_process_nopin_mesg(qedi, cqe, task, q_conn,
+						que_idx);
+			break;
+		case ISCSI_OPCODE_ASYNC_MSG:
+			qedi_process_async_mesg(qedi, cqe, task, q_conn,
+						que_idx);
+			break;
+		case ISCSI_OPCODE_REJECT:
+			qedi_process_reject_mesg(qedi, cqe, task, q_conn,
+						 que_idx);
+			break;
+		}
+		goto exit_fp_process;
+	case ISCSI_CQE_TYPE_DUMMY:
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM, "Dummy CqE\n");
+		goto exit_fp_process;
+	case ISCSI_CQE_TYPE_TASK_CLEANUP:
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM, "CleanUp CqE\n");
+		qedi_process_cmd_cleanup_resp(qedi, &cqe->cqe_solicited, task,
+					      conn);
+		goto exit_fp_process;
+	default:
+		QEDI_ERR(&qedi->dbg_ctx, "Error cqe.\n");
+		break;
+	}
+
+exit_fp_process:
+	return;
+}
+
+static void qedi_add_to_sq(struct qedi_conn *qedi_conn, struct iscsi_task *task,
+			   u16 tid, uint16_t ptu_invalidate, int is_cleanup)
+{
+	struct iscsi_wqe *wqe;
+	struct iscsi_wqe_field *cont_field;
+	struct qedi_endpoint *ep;
+	struct scsi_cmnd *sc = task->sc;
+	struct iscsi_login_req *login_hdr;
+	struct qedi_cmd *cmd = task->dd_data;
+
+	login_hdr = (struct iscsi_login_req *)task->hdr;
+	ep = qedi_conn->ep;
+	wqe = &ep->sq[ep->sq_prod_idx];
+
+	memset(wqe, 0, sizeof(*wqe));
+
+	ep->sq_prod_idx++;
+	ep->fw_sq_prod_idx++;
+	if (ep->sq_prod_idx == QEDI_SQ_SIZE)
+		ep->sq_prod_idx = 0;
+
+	if (is_cleanup) {
+		SET_FIELD(wqe->flags, ISCSI_WQE_WQE_TYPE,
+			  ISCSI_WQE_TYPE_TASK_CLEANUP);
+		wqe->task_id = tid;
+		return;
+	}
+
+	if (ptu_invalidate) {
+		SET_FIELD(wqe->flags, ISCSI_WQE_PTU_INVALIDATE,
+			  ISCSI_WQE_SET_PTU_INVALIDATE);
+	}
+
+	cont_field = &wqe->cont_prevtid_union.cont_field;
+
+	switch (task->hdr->opcode & ISCSI_OPCODE_MASK) {
+	case ISCSI_OP_LOGIN:
+	case ISCSI_OP_TEXT:
+		SET_FIELD(wqe->flags, ISCSI_WQE_WQE_TYPE,
+			  ISCSI_WQE_TYPE_MIDDLE_PATH);
+		SET_FIELD(wqe->flags, ISCSI_WQE_NUM_FAST_SGES,
+			  1);
+		cont_field->contlen_cdbsize_field = ntoh24(login_hdr->dlength);
+		break;
+	case ISCSI_OP_LOGOUT:
+	case ISCSI_OP_NOOP_OUT:
+	case ISCSI_OP_SCSI_TMFUNC:
+		 SET_FIELD(wqe->flags, ISCSI_WQE_WQE_TYPE,
+			   ISCSI_WQE_TYPE_NORMAL);
+		break;
+	default:
+		if (!sc)
+			break;
+
+		SET_FIELD(wqe->flags, ISCSI_WQE_WQE_TYPE,
+			  ISCSI_WQE_TYPE_NORMAL);
+		cont_field->contlen_cdbsize_field =
+				(sc->sc_data_direction == DMA_TO_DEVICE) ?
+				scsi_bufflen(sc) : 0;
+		if (cmd->use_slowpath)
+			SET_FIELD(wqe->flags, ISCSI_WQE_NUM_FAST_SGES, 0);
+		else
+			SET_FIELD(wqe->flags, ISCSI_WQE_NUM_FAST_SGES,
+				  (sc->sc_data_direction ==
+				   DMA_TO_DEVICE) ?
+				  min((u16)QEDI_FAST_SGE_COUNT,
+				      (u16)cmd->io_tbl.sge_valid) : 0);
+		break;
+	}
+
+	wqe->task_id = tid;
+	/* Make sure SQ data is coherent */
+	wmb();
+}
+
+static void qedi_ring_doorbell(struct qedi_conn *qedi_conn)
+{
+	struct iscsi_db_data dbell = { 0 };
+
+	dbell.agg_flags = 0;
+
+	dbell.params |= DB_DEST_XCM << ISCSI_DB_DATA_DEST_SHIFT;
+	dbell.params |= DB_AGG_CMD_SET << ISCSI_DB_DATA_AGG_CMD_SHIFT;
+	dbell.params |=
+		   DQ_XCM_ISCSI_SQ_PROD_CMD << ISCSI_DB_DATA_AGG_VAL_SEL_SHIFT;
+
+	dbell.sq_prod = qedi_conn->ep->fw_sq_prod_idx;
+	writel(*(u32 *)&dbell, qedi_conn->ep->p_doorbell);
+
+	/* Make sure fw write idx is coherent, and include both memory barriers
+	 * as a failsafe as for some architectures the call is the same but on
+	 * others they are two different assembly operations.
+	 */
+	wmb();
+	mmiowb();
+	QEDI_INFO(&qedi_conn->qedi->dbg_ctx, QEDI_LOG_MP_REQ,
+		  "prod_idx=0x%x, fw_prod_idx=0x%x, cid=0x%x\n",
+		  qedi_conn->ep->sq_prod_idx, qedi_conn->ep->fw_sq_prod_idx,
+		  qedi_conn->iscsi_conn_id);
+}
+
+int qedi_send_iscsi_login(struct qedi_conn *qedi_conn,
+			  struct iscsi_task *task)
+{
+	struct qedi_ctx *qedi = qedi_conn->qedi;
+	struct iscsi_task_context *fw_task_ctx;
+	struct iscsi_login_req *login_hdr;
+	struct iscsi_login_req_hdr *fw_login_req = NULL;
+	struct iscsi_cached_sge_ctx *cached_sge = NULL;
+	struct iscsi_sge *single_sge = NULL;
+	struct iscsi_sge *req_sge = NULL;
+	struct iscsi_sge *resp_sge = NULL;
+	struct qedi_cmd *qedi_cmd;
+	s16 ptu_invalidate = 0;
+	s16 tid = 0;
+
+	req_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.req_bd_tbl;
+	resp_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.resp_bd_tbl;
+	qedi_cmd = (struct qedi_cmd *)task->dd_data;
+	login_hdr = (struct iscsi_login_req *)task->hdr;
+
+	tid = qedi_get_task_idx(qedi);
+	if (tid == -1)
+		return -ENOMEM;
+
+	fw_task_ctx = qedi_get_task_mem(&qedi->tasks, tid);
+	memset(fw_task_ctx, 0, sizeof(struct iscsi_task_context));
+
+	qedi_cmd->task_id = tid;
+
+	/* Ystorm context */
+	fw_login_req = &fw_task_ctx->ystorm_st_context.pdu_hdr.login_req;
+	fw_login_req->opcode = login_hdr->opcode;
+	fw_login_req->version_min = login_hdr->min_version;
+	fw_login_req->version_max = login_hdr->max_version;
+	fw_login_req->flags_attr = login_hdr->flags;
+	fw_login_req->isid_tabc = *((u16 *)login_hdr->isid + 2);
+	fw_login_req->isid_d = *((u32 *)login_hdr->isid);
+	fw_login_req->tsih = login_hdr->tsih;
+	qedi_update_itt_map(qedi, tid, task->itt, qedi_cmd);
+	fw_login_req->itt = qedi_set_itt(tid, get_itt(task->itt));
+	fw_login_req->cid = qedi_conn->iscsi_conn_id;
+	fw_login_req->cmd_sn = be32_to_cpu(login_hdr->cmdsn);
+	fw_login_req->exp_stat_sn = be32_to_cpu(login_hdr->exp_statsn);
+	fw_login_req->exp_stat_sn = 0;
+
+	if (qedi->tid_reuse_count[tid] == QEDI_MAX_TASK_NUM) {
+		ptu_invalidate = 1;
+		qedi->tid_reuse_count[tid] = 0;
+	}
+
+	fw_task_ctx->ystorm_st_context.state.reuse_count =
+						qedi->tid_reuse_count[tid];
+	fw_task_ctx->mstorm_st_context.reuse_count =
+						qedi->tid_reuse_count[tid]++;
+	cached_sge =
+	       &fw_task_ctx->ystorm_st_context.state.sgl_ctx_union.cached_sge;
+	cached_sge->sge.sge_len = req_sge->sge_len;
+	cached_sge->sge.sge_addr.lo = (u32)(qedi_conn->gen_pdu.req_dma_addr);
+	cached_sge->sge.sge_addr.hi =
+			     (u32)((u64)qedi_conn->gen_pdu.req_dma_addr >> 32);
+
+	/* Mstorm context */
+	single_sge = &fw_task_ctx->mstorm_st_context.sgl_union.single_sge;
+	fw_task_ctx->mstorm_st_context.task_type = 0x2;
+	fw_task_ctx->mstorm_ag_context.task_cid = (u16)qedi_conn->iscsi_conn_id;
+	single_sge->sge_addr.lo = resp_sge->sge_addr.lo;
+	single_sge->sge_addr.hi = resp_sge->sge_addr.hi;
+	single_sge->sge_len = resp_sge->sge_len;
+
+	SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+		  ISCSI_MFLAGS_SINGLE_SGE, 1);
+	SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+		  ISCSI_MFLAGS_SLOW_IO, 0);
+	fw_task_ctx->mstorm_st_context.sgl_size = 1;
+	fw_task_ctx->mstorm_st_context.rem_task_size = resp_sge->sge_len;
+
+	/* Ustorm context */
+	fw_task_ctx->ustorm_st_context.rem_rcv_len = resp_sge->sge_len;
+	fw_task_ctx->ustorm_st_context.exp_data_transfer_len =
+						ntoh24(login_hdr->dlength);
+	fw_task_ctx->ustorm_st_context.exp_data_sn = 0;
+	fw_task_ctx->ustorm_st_context.cq_rss_number = 0;
+	fw_task_ctx->ustorm_st_context.task_type = 0x2;
+	fw_task_ctx->ustorm_ag_context.icid = (u16)qedi_conn->iscsi_conn_id;
+	fw_task_ctx->ustorm_ag_context.exp_data_acked =
+						 ntoh24(login_hdr->dlength);
+	SET_FIELD(fw_task_ctx->ustorm_ag_context.flags1,
+		  USTORM_ISCSI_TASK_AG_CTX_R2T2RECV, 1);
+	SET_FIELD(fw_task_ctx->ustorm_st_context.flags,
+		  USTORM_ISCSI_TASK_ST_CTX_LOCAL_COMP, 0);
+
+	spin_lock(&qedi_conn->list_lock);
+	list_add_tail(&qedi_cmd->io_cmd, &qedi_conn->active_cmd_list);
+	qedi_cmd->io_cmd_in_list = true;
+	qedi_conn->active_cmd_count++;
+	spin_unlock(&qedi_conn->list_lock);
+
+	qedi_add_to_sq(qedi_conn, task, tid, ptu_invalidate, false);
+	qedi_ring_doorbell(qedi_conn);
+	return 0;
+}
+
+int qedi_send_iscsi_logout(struct qedi_conn *qedi_conn,
+			   struct iscsi_task *task)
+{
+	struct qedi_ctx *qedi = qedi_conn->qedi;
+	struct iscsi_logout_req_hdr *fw_logout_req = NULL;
+	struct iscsi_task_context *fw_task_ctx = NULL;
+	struct iscsi_logout *logout_hdr = NULL;
+	struct qedi_cmd *qedi_cmd = NULL;
+	s16  tid = 0;
+	s16 ptu_invalidate = 0;
+
+	qedi_cmd = (struct qedi_cmd *)task->dd_data;
+	logout_hdr = (struct iscsi_logout *)task->hdr;
+
+	tid = qedi_get_task_idx(qedi);
+	if (tid == -1)
+		return -ENOMEM;
+
+	fw_task_ctx = qedi_get_task_mem(&qedi->tasks, tid);
+
+	memset(fw_task_ctx, 0, sizeof(struct iscsi_task_context));
+	qedi_cmd->task_id = tid;
+
+	/* Ystorm context */
+	fw_logout_req = &fw_task_ctx->ystorm_st_context.pdu_hdr.logout_req;
+	fw_logout_req->opcode = ISCSI_OPCODE_LOGOUT_REQUEST;
+	fw_logout_req->reason_code = 0x80 | logout_hdr->flags;
+	qedi_update_itt_map(qedi, tid, task->itt, qedi_cmd);
+	fw_logout_req->itt = qedi_set_itt(tid, get_itt(task->itt));
+	fw_logout_req->exp_stat_sn = be32_to_cpu(logout_hdr->exp_statsn);
+	fw_logout_req->cmd_sn = be32_to_cpu(logout_hdr->cmdsn);
+
+	if (qedi->tid_reuse_count[tid] == QEDI_MAX_TASK_NUM) {
+		ptu_invalidate = 1;
+		qedi->tid_reuse_count[tid] = 0;
+	}
+	fw_task_ctx->ystorm_st_context.state.reuse_count =
+						  qedi->tid_reuse_count[tid];
+	fw_task_ctx->mstorm_st_context.reuse_count =
+						qedi->tid_reuse_count[tid]++;
+	fw_logout_req->cid = qedi_conn->iscsi_conn_id;
+	fw_task_ctx->ystorm_st_context.state.buffer_offset[0] = 0;
+
+	/* Mstorm context */
+	fw_task_ctx->mstorm_st_context.task_type = ISCSI_TASK_TYPE_MIDPATH;
+	fw_task_ctx->mstorm_ag_context.task_cid = (u16)qedi_conn->iscsi_conn_id;
+
+	/* Ustorm context */
+	fw_task_ctx->ustorm_st_context.rem_rcv_len = 0;
+	fw_task_ctx->ustorm_st_context.exp_data_transfer_len = 0;
+	fw_task_ctx->ustorm_st_context.exp_data_sn = 0;
+	fw_task_ctx->ustorm_st_context.task_type =  ISCSI_TASK_TYPE_MIDPATH;
+	fw_task_ctx->ustorm_st_context.cq_rss_number = 0;
+
+	SET_FIELD(fw_task_ctx->ustorm_st_context.flags,
+		  USTORM_ISCSI_TASK_ST_CTX_LOCAL_COMP, 0);
+	SET_FIELD(fw_task_ctx->ustorm_st_context.reg1.reg1_map,
+		  ISCSI_REG1_NUM_FAST_SGES, 0);
+
+	fw_task_ctx->ustorm_ag_context.icid = (u16)qedi_conn->iscsi_conn_id;
+	SET_FIELD(fw_task_ctx->ustorm_ag_context.flags1,
+		  USTORM_ISCSI_TASK_AG_CTX_R2T2RECV, 1);
+
+	spin_lock(&qedi_conn->list_lock);
+	list_add_tail(&qedi_cmd->io_cmd, &qedi_conn->active_cmd_list);
+	qedi_cmd->io_cmd_in_list = true;
+	qedi_conn->active_cmd_count++;
+	spin_unlock(&qedi_conn->list_lock);
+
+	qedi_add_to_sq(qedi_conn, task, tid, ptu_invalidate, false);
+	qedi_ring_doorbell(qedi_conn);
+
+	return 0;
+}
+
+int qedi_cleanup_all_io(struct qedi_ctx *qedi, struct qedi_conn *qedi_conn,
+			struct iscsi_task *task, bool in_recovery)
+{
+	int rval;
+	struct iscsi_task *ctask;
+	struct qedi_cmd *cmd, *cmd_tmp;
+	struct iscsi_tm *tmf_hdr;
+	unsigned int lun = 0;
+	bool lun_reset = false;
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+
+	/* From recovery, task is NULL or from tmf resp valid task */
+	if (task) {
+		tmf_hdr = (struct iscsi_tm *)task->hdr;
+
+		if ((tmf_hdr->flags & ISCSI_FLAG_TM_FUNC_MASK) ==
+			ISCSI_TM_FUNC_LOGICAL_UNIT_RESET) {
+			lun_reset = true;
+			lun = scsilun_to_int(&tmf_hdr->lun);
+		}
+	}
+
+	qedi_conn->cmd_cleanup_req = 0;
+	qedi_conn->cmd_cleanup_cmpl = 0;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+		  "active_cmd_count=%d, cid=0x%x, in_recovery=%d, lun_reset=%d\n",
+		  qedi_conn->active_cmd_count, qedi_conn->iscsi_conn_id,
+		  in_recovery, lun_reset);
+
+	if (lun_reset)
+		spin_lock_bh(&session->back_lock);
+
+	spin_lock(&qedi_conn->list_lock);
+
+	list_for_each_entry_safe(cmd, cmd_tmp, &qedi_conn->active_cmd_list,
+				 io_cmd) {
+		ctask = cmd->task;
+		if (ctask == task)
+			continue;
+
+		if (lun_reset) {
+			if (cmd->scsi_cmd && cmd->scsi_cmd->device) {
+				QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+					  "tid=0x%x itt=0x%x scsi_cmd_ptr=%p device=%p task_state=%d cmd_state=0%x cid=0x%x\n",
+					  cmd->task_id, get_itt(ctask->itt),
+					  cmd->scsi_cmd, cmd->scsi_cmd->device,
+					  ctask->state, cmd->state,
+					  qedi_conn->iscsi_conn_id);
+				if (cmd->scsi_cmd->device->lun != lun)
+					continue;
+			}
+		}
+		qedi_conn->cmd_cleanup_req++;
+		qedi_iscsi_cleanup_task(ctask, true);
+
+		list_del_init(&cmd->io_cmd);
+		qedi_conn->active_cmd_count--;
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "Deleted active cmd list node io_cmd=%p, cid=0x%x\n",
+			  &cmd->io_cmd, qedi_conn->iscsi_conn_id);
+	}
+
+	spin_unlock(&qedi_conn->list_lock);
+
+	if (lun_reset)
+		spin_unlock_bh(&session->back_lock);
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+		  "cmd_cleanup_req=%d, cid=0x%x\n",
+		  qedi_conn->cmd_cleanup_req,
+		  qedi_conn->iscsi_conn_id);
+
+	rval  = wait_event_interruptible_timeout(qedi_conn->wait_queue,
+						 ((qedi_conn->cmd_cleanup_req ==
+						 qedi_conn->cmd_cleanup_cmpl) ||
+						 qedi_conn->ep),
+						 5 * HZ);
+	if (rval) {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+			  "i/o cmd_cleanup_req=%d, equal to cmd_cleanup_cmpl=%d, cid=0x%x\n",
+			  qedi_conn->cmd_cleanup_req,
+			  qedi_conn->cmd_cleanup_cmpl,
+			  qedi_conn->iscsi_conn_id);
+
+		return 0;
+	}
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+		  "i/o cmd_cleanup_req=%d, not equal to cmd_cleanup_cmpl=%d, cid=0x%x\n",
+		  qedi_conn->cmd_cleanup_req,
+		  qedi_conn->cmd_cleanup_cmpl,
+		  qedi_conn->iscsi_conn_id);
+
+	iscsi_host_for_each_session(qedi->shost,
+				    qedi_mark_device_missing);
+	qedi_ops->common->drain(qedi->cdev);
+
+	/* Enable IOs for all other sessions except current.*/
+	if (!wait_event_interruptible_timeout(qedi_conn->wait_queue,
+					      (qedi_conn->cmd_cleanup_req ==
+					       qedi_conn->cmd_cleanup_cmpl),
+					      5 * HZ)) {
+		iscsi_host_for_each_session(qedi->shost,
+					    qedi_mark_device_available);
+		return -1;
+	}
+
+	iscsi_host_for_each_session(qedi->shost,
+				    qedi_mark_device_available);
+
+	return 0;
+}
+
+void qedi_clearsq(struct qedi_ctx *qedi, struct qedi_conn *qedi_conn,
+		  struct iscsi_task *task)
+{
+	struct qedi_endpoint *qedi_ep;
+	int rval;
+
+	qedi_ep = qedi_conn->ep;
+	qedi_conn->cmd_cleanup_req = 0;
+	qedi_conn->cmd_cleanup_cmpl = 0;
+
+	if (!qedi_ep) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "Cannot proceed, ep already disconnected, cid=0x%x\n",
+			  qedi_conn->iscsi_conn_id);
+		return;
+	}
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+		  "Clearing SQ for cid=0x%x, conn=%p, ep=%p\n",
+		  qedi_conn->iscsi_conn_id, qedi_conn, qedi_ep);
+
+	qedi_ops->clear_sq(qedi->cdev, qedi_ep->handle);
+
+	rval = qedi_cleanup_all_io(qedi, qedi_conn, task, true);
+	if (rval) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "fatal error, need hard reset, cid=0x%x\n",
+			 qedi_conn->iscsi_conn_id);
+		WARN_ON(1);
+	}
+}
+
+static int qedi_wait_for_cleanup_request(struct qedi_ctx *qedi,
+					 struct qedi_conn *qedi_conn,
+					 struct iscsi_task *task,
+					 struct qedi_cmd *qedi_cmd,
+					 struct qedi_work_map *list_work)
+{
+	struct qedi_cmd *cmd = (struct qedi_cmd *)task->dd_data;
+	int wait;
+
+	wait  = wait_event_interruptible_timeout(qedi_conn->wait_queue,
+						 ((qedi_cmd->state ==
+						   CLEANUP_RECV) ||
+						 ((qedi_cmd->type == TYPEIO) &&
+						  (cmd->state ==
+						   RESPONSE_RECEIVED))),
+						 5 * HZ);
+	if (!wait) {
+		qedi_cmd->state = CLEANUP_WAIT_FAILED;
+
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+			  "Cleanup timedout tid=0x%x, issue connection recovery, cid=0x%x\n",
+			  cmd->task_id, qedi_conn->iscsi_conn_id);
+
+		return -1;
+	}
+	return 0;
+}
+
+static void qedi_tmf_work(struct work_struct *work)
+{
+	struct qedi_cmd *qedi_cmd =
+		container_of(work, struct qedi_cmd, tmf_work);
+	struct qedi_conn *qedi_conn = qedi_cmd->conn;
+	struct qedi_ctx *qedi = qedi_conn->qedi;
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_cls_session *cls_sess;
+	struct qedi_work_map *list_work = NULL;
+	struct iscsi_task *mtask;
+	struct qedi_cmd *cmd;
+	struct iscsi_task *ctask;
+	struct iscsi_tm *tmf_hdr;
+	s16 rval = 0;
+	s16 tid = 0;
+
+	mtask = qedi_cmd->task;
+	tmf_hdr = (struct iscsi_tm *)mtask->hdr;
+	cls_sess = iscsi_conn_to_session(qedi_conn->cls_conn);
+	set_bit(QEDI_CONN_FW_CLEANUP, &qedi_conn->flags);
+
+	ctask = iscsi_itt_to_task(conn, tmf_hdr->rtt);
+	if (!ctask || !ctask->sc) {
+		QEDI_ERR(&qedi->dbg_ctx, "Task already completed\n");
+		goto abort_ret;
+	}
+
+	cmd = (struct qedi_cmd *)ctask->dd_data;
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+		  "Abort tmf rtt=0x%x, cmd itt=0x%x, cmd tid=0x%x, cid=0x%x\n",
+		  get_itt(tmf_hdr->rtt), get_itt(ctask->itt), cmd->task_id,
+		  qedi_conn->iscsi_conn_id);
+
+	if (do_not_recover) {
+		QEDI_ERR(&qedi->dbg_ctx, "DONT SEND CLEANUP/ABORT %d\n",
+			 do_not_recover);
+		goto abort_ret;
+	}
+
+	list_work = kzalloc(sizeof(*list_work), GFP_ATOMIC);
+	if (!list_work) {
+		QEDI_ERR(&qedi->dbg_ctx, "Memory alloction failed\n");
+		goto abort_ret;
+	}
+
+	qedi_cmd->type = TYPEIO;
+	list_work->qedi_cmd = qedi_cmd;
+	list_work->rtid = cmd->task_id;
+	list_work->state = QEDI_WORK_SCHEDULED;
+	qedi_cmd->list_tmf_work = list_work;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+		  "Queue tmf work=%p, list node=%p, cid=0x%x, tmf flags=0x%x\n",
+		  list_work->ptr_tmf_work, list_work, qedi_conn->iscsi_conn_id,
+		  tmf_hdr->flags);
+
+	spin_lock_bh(&qedi_conn->tmf_work_lock);
+	list_add_tail(&list_work->list, &qedi_conn->tmf_work_list);
+	spin_unlock_bh(&qedi_conn->tmf_work_lock);
+
+	qedi_iscsi_cleanup_task(ctask, false);
+
+	rval = qedi_wait_for_cleanup_request(qedi, qedi_conn, ctask, qedi_cmd,
+					     list_work);
+	if (rval == -1) {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+			  "FW cleanup got escalated, cid=0x%x\n",
+			  qedi_conn->iscsi_conn_id);
+		goto ldel_exit;
+	}
+
+	tid = qedi_get_task_idx(qedi);
+	if (tid == -1) {
+		QEDI_ERR(&qedi->dbg_ctx, "Invalid tid, cid=0x%x\n",
+			 qedi_conn->iscsi_conn_id);
+		goto ldel_exit;
+	}
+
+	qedi_cmd->task_id = tid;
+	qedi_send_iscsi_tmf(qedi_conn, qedi_cmd->task);
+
+abort_ret:
+	clear_bit(QEDI_CONN_FW_CLEANUP, &qedi_conn->flags);
+	return;
+
+ldel_exit:
+	spin_lock_bh(&qedi_conn->tmf_work_lock);
+	if (!qedi_cmd->list_tmf_work) {
+		list_del_init(&list_work->list);
+		qedi_cmd->list_tmf_work = NULL;
+		kfree(list_work);
+	}
+	spin_unlock_bh(&qedi_conn->tmf_work_lock);
+
+	spin_lock(&qedi_conn->list_lock);
+	list_del_init(&cmd->io_cmd);
+	qedi_conn->active_cmd_count--;
+	spin_unlock(&qedi_conn->list_lock);
+
+	clear_bit(QEDI_CONN_FW_CLEANUP, &qedi_conn->flags);
+}
+
+static int qedi_send_iscsi_tmf(struct qedi_conn *qedi_conn,
+			       struct iscsi_task *mtask)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct qedi_ctx *qedi = qedi_conn->qedi;
+	struct iscsi_task_context *fw_task_ctx;
+	struct iscsi_tmf_request_hdr *fw_tmf_request;
+	struct iscsi_sge *single_sge;
+	struct qedi_cmd *qedi_cmd;
+	struct qedi_cmd *cmd;
+	struct iscsi_task *ctask;
+	struct iscsi_tm *tmf_hdr;
+	struct iscsi_sge *req_sge;
+	struct iscsi_sge *resp_sge;
+	u32 lun[2];
+	s16 tid = 0, ptu_invalidate = 0;
+
+	req_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.req_bd_tbl;
+	resp_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.resp_bd_tbl;
+	qedi_cmd = (struct qedi_cmd *)mtask->dd_data;
+	tmf_hdr = (struct iscsi_tm *)mtask->hdr;
+
+	tid = qedi_cmd->task_id;
+	qedi_update_itt_map(qedi, tid, mtask->itt, qedi_cmd);
+
+	fw_task_ctx = qedi_get_task_mem(&qedi->tasks, tid);
+	memset(fw_task_ctx, 0, sizeof(struct iscsi_task_context));
+
+	fw_tmf_request = &fw_task_ctx->ystorm_st_context.pdu_hdr.tmf_request;
+	fw_tmf_request->itt = qedi_set_itt(tid, get_itt(mtask->itt));
+	fw_tmf_request->cmd_sn = be32_to_cpu(tmf_hdr->cmdsn);
+
+	memcpy(lun, &tmf_hdr->lun, sizeof(struct scsi_lun));
+	fw_tmf_request->lun.lo = be32_to_cpu(lun[0]);
+	fw_tmf_request->lun.hi = be32_to_cpu(lun[1]);
+
+	if (qedi->tid_reuse_count[tid] == QEDI_MAX_TASK_NUM) {
+		ptu_invalidate = 1;
+		qedi->tid_reuse_count[tid] = 0;
+	}
+	fw_task_ctx->ystorm_st_context.state.reuse_count =
+						qedi->tid_reuse_count[tid];
+	fw_task_ctx->mstorm_st_context.reuse_count =
+						qedi->tid_reuse_count[tid]++;
+
+	if ((tmf_hdr->flags & ISCSI_FLAG_TM_FUNC_MASK) ==
+	     ISCSI_TM_FUNC_ABORT_TASK) {
+		ctask = iscsi_itt_to_task(conn, tmf_hdr->rtt);
+		if (!ctask || !ctask->sc) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "Could not get reference task\n");
+			return 0;
+		}
+		cmd = (struct qedi_cmd *)ctask->dd_data;
+		fw_tmf_request->rtt =
+				qedi_set_itt(cmd->task_id,
+					     get_itt(tmf_hdr->rtt));
+	} else {
+		fw_tmf_request->rtt = ISCSI_RESERVED_TAG;
+	}
+
+	fw_tmf_request->opcode = tmf_hdr->opcode;
+	fw_tmf_request->function = tmf_hdr->flags;
+	fw_tmf_request->hdr_second_dword = ntoh24(tmf_hdr->dlength);
+	fw_tmf_request->ref_cmd_sn = be32_to_cpu(tmf_hdr->refcmdsn);
+
+	single_sge = &fw_task_ctx->mstorm_st_context.sgl_union.single_sge;
+	fw_task_ctx->mstorm_st_context.task_type = ISCSI_TASK_TYPE_MIDPATH;
+	fw_task_ctx->mstorm_ag_context.task_cid = (u16)qedi_conn->iscsi_conn_id;
+	single_sge->sge_addr.lo = resp_sge->sge_addr.lo;
+	single_sge->sge_addr.hi = resp_sge->sge_addr.hi;
+	single_sge->sge_len = resp_sge->sge_len;
+
+	SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+		  ISCSI_MFLAGS_SINGLE_SGE, 1);
+	SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+		  ISCSI_MFLAGS_SLOW_IO, 0);
+	fw_task_ctx->mstorm_st_context.sgl_size = 1;
+	fw_task_ctx->mstorm_st_context.rem_task_size = resp_sge->sge_len;
+
+	/* Ustorm context */
+	fw_task_ctx->ustorm_st_context.rem_rcv_len = 0;
+	fw_task_ctx->ustorm_st_context.exp_data_transfer_len = 0;
+	fw_task_ctx->ustorm_st_context.exp_data_sn = 0;
+	fw_task_ctx->ustorm_st_context.task_type =  ISCSI_TASK_TYPE_MIDPATH;
+	fw_task_ctx->ustorm_st_context.cq_rss_number = 0;
+
+	SET_FIELD(fw_task_ctx->ustorm_st_context.flags,
+		  USTORM_ISCSI_TASK_ST_CTX_LOCAL_COMP, 0);
+	SET_FIELD(fw_task_ctx->ustorm_st_context.reg1.reg1_map,
+		  ISCSI_REG1_NUM_FAST_SGES, 0);
+
+	fw_task_ctx->ustorm_ag_context.icid = (u16)qedi_conn->iscsi_conn_id;
+	SET_FIELD(fw_task_ctx->ustorm_ag_context.flags1,
+		  USTORM_ISCSI_TASK_AG_CTX_R2T2RECV, 1);
+	fw_task_ctx->ustorm_st_context.lun.lo = be32_to_cpu(lun[0]);
+	fw_task_ctx->ustorm_st_context.lun.hi = be32_to_cpu(lun[1]);
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+		  "Add TMF to SQ, tmf tid=0x%x, itt=0x%x, cid=0x%x\n",
+		  tid,  mtask->itt, qedi_conn->iscsi_conn_id);
+
+	spin_lock(&qedi_conn->list_lock);
+	list_add_tail(&qedi_cmd->io_cmd, &qedi_conn->active_cmd_list);
+	qedi_cmd->io_cmd_in_list = true;
+	qedi_conn->active_cmd_count++;
+	spin_unlock(&qedi_conn->list_lock);
+
+	qedi_add_to_sq(qedi_conn, mtask, tid, ptu_invalidate, false);
+	qedi_ring_doorbell(qedi_conn);
+	return 0;
+}
+
+int qedi_iscsi_abort_work(struct qedi_conn *qedi_conn,
+			  struct iscsi_task *mtask)
+{
+	struct qedi_ctx *qedi = qedi_conn->qedi;
+	struct iscsi_tm *tmf_hdr;
+	struct qedi_cmd *qedi_cmd = (struct qedi_cmd *)mtask->dd_data;
+	s16 tid = 0;
+
+	tmf_hdr = (struct iscsi_tm *)mtask->hdr;
+	qedi_cmd->task = mtask;
+
+	/* If abort task then schedule the work and return */
+	if ((tmf_hdr->flags & ISCSI_FLAG_TM_FUNC_MASK) ==
+	    ISCSI_TM_FUNC_ABORT_TASK) {
+		qedi_cmd->state = CLEANUP_WAIT;
+		INIT_WORK(&qedi_cmd->tmf_work, qedi_tmf_work);
+		queue_work(qedi->tmf_thread, &qedi_cmd->tmf_work);
+
+	} else if (((tmf_hdr->flags & ISCSI_FLAG_TM_FUNC_MASK) ==
+		    ISCSI_TM_FUNC_LOGICAL_UNIT_RESET) ||
+		   ((tmf_hdr->flags & ISCSI_FLAG_TM_FUNC_MASK) ==
+		    ISCSI_TM_FUNC_TARGET_WARM_RESET) ||
+		   ((tmf_hdr->flags & ISCSI_FLAG_TM_FUNC_MASK) ==
+		    ISCSI_TM_FUNC_TARGET_COLD_RESET)) {
+		tid = qedi_get_task_idx(qedi);
+		if (tid == -1) {
+			QEDI_ERR(&qedi->dbg_ctx, "Invalid tid, cid=0x%x\n",
+				 qedi_conn->iscsi_conn_id);
+			return -1;
+		}
+		qedi_cmd->task_id = tid;
+
+		qedi_send_iscsi_tmf(qedi_conn, qedi_cmd->task);
+
+	} else {
+		QEDI_ERR(&qedi->dbg_ctx, "Invalid tmf, cid=0x%x\n",
+			 qedi_conn->iscsi_conn_id);
+		return -1;
+	}
+
+	return 0;
+}
+
+int qedi_send_iscsi_text(struct qedi_conn *qedi_conn,
+			 struct iscsi_task *task)
+{
+	struct qedi_ctx *qedi = qedi_conn->qedi;
+	struct iscsi_task_context *fw_task_ctx;
+	struct iscsi_text_request_hdr *fw_text_request;
+	struct iscsi_cached_sge_ctx *cached_sge;
+	struct iscsi_sge *single_sge;
+	struct qedi_cmd *qedi_cmd;
+	/* For 6.5 hdr iscsi_hdr */
+	struct iscsi_text *text_hdr;
+	struct iscsi_sge *req_sge;
+	struct iscsi_sge *resp_sge;
+	s16 ptu_invalidate = 0;
+	s16 tid = 0;
+
+	req_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.req_bd_tbl;
+	resp_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.resp_bd_tbl;
+	qedi_cmd = (struct qedi_cmd *)task->dd_data;
+	text_hdr = (struct iscsi_text *)task->hdr;
+
+	tid = qedi_get_task_idx(qedi);
+	if (tid == -1)
+		return -ENOMEM;
+
+	fw_task_ctx = qedi_get_task_mem(&qedi->tasks, tid);
+	memset(fw_task_ctx, 0, sizeof(struct iscsi_task_context));
+
+	qedi_cmd->task_id = tid;
+
+	/* Ystorm context */
+	fw_text_request =
+			&fw_task_ctx->ystorm_st_context.pdu_hdr.text_request;
+	fw_text_request->opcode = text_hdr->opcode;
+	fw_text_request->flags_attr = text_hdr->flags;
+
+	qedi_update_itt_map(qedi, tid, task->itt, qedi_cmd);
+	fw_text_request->itt = qedi_set_itt(tid, get_itt(task->itt));
+	fw_text_request->ttt = text_hdr->ttt;
+	fw_text_request->cmd_sn = be32_to_cpu(text_hdr->cmdsn);
+	fw_text_request->exp_stat_sn = be32_to_cpu(text_hdr->exp_statsn);
+	fw_text_request->hdr_second_dword = ntoh24(text_hdr->dlength);
+
+	if (qedi->tid_reuse_count[tid] == QEDI_MAX_TASK_NUM) {
+		ptu_invalidate = 1;
+		qedi->tid_reuse_count[tid] = 0;
+	}
+	fw_task_ctx->ystorm_st_context.state.reuse_count =
+						     qedi->tid_reuse_count[tid];
+	fw_task_ctx->mstorm_st_context.reuse_count =
+						   qedi->tid_reuse_count[tid]++;
+
+	cached_sge =
+	       &fw_task_ctx->ystorm_st_context.state.sgl_ctx_union.cached_sge;
+	cached_sge->sge.sge_len = req_sge->sge_len;
+	cached_sge->sge.sge_addr.lo = (u32)(qedi_conn->gen_pdu.req_dma_addr);
+	cached_sge->sge.sge_addr.hi =
+			      (u32)((u64)qedi_conn->gen_pdu.req_dma_addr >> 32);
+
+	/* Mstorm context */
+	single_sge = &fw_task_ctx->mstorm_st_context.sgl_union.single_sge;
+	fw_task_ctx->mstorm_st_context.task_type = 0x2;
+	fw_task_ctx->mstorm_ag_context.task_cid = (u16)qedi_conn->iscsi_conn_id;
+	single_sge->sge_addr.lo = resp_sge->sge_addr.lo;
+	single_sge->sge_addr.hi = resp_sge->sge_addr.hi;
+	single_sge->sge_len = resp_sge->sge_len;
+
+	SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+		  ISCSI_MFLAGS_SINGLE_SGE, 1);
+	SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+		  ISCSI_MFLAGS_SLOW_IO, 0);
+	fw_task_ctx->mstorm_st_context.sgl_size = 1;
+	fw_task_ctx->mstorm_st_context.rem_task_size = resp_sge->sge_len;
+
+	/* Ustorm context */
+	fw_task_ctx->ustorm_ag_context.exp_data_acked =
+						      ntoh24(text_hdr->dlength);
+	fw_task_ctx->ustorm_st_context.rem_rcv_len = resp_sge->sge_len;
+	fw_task_ctx->ustorm_st_context.exp_data_transfer_len =
+						      ntoh24(text_hdr->dlength);
+	fw_task_ctx->ustorm_st_context.exp_data_sn =
+					      be32_to_cpu(text_hdr->exp_statsn);
+	fw_task_ctx->ustorm_st_context.cq_rss_number = 0;
+	fw_task_ctx->ustorm_st_context.task_type = 0x2;
+	fw_task_ctx->ustorm_ag_context.icid = (u16)qedi_conn->iscsi_conn_id;
+	SET_FIELD(fw_task_ctx->ustorm_ag_context.flags1,
+		  USTORM_ISCSI_TASK_AG_CTX_R2T2RECV, 1);
+
+	/*  Add command in active command list */
+	spin_lock(&qedi_conn->list_lock);
+	list_add_tail(&qedi_cmd->io_cmd, &qedi_conn->active_cmd_list);
+	qedi_cmd->io_cmd_in_list = true;
+	qedi_conn->active_cmd_count++;
+	spin_unlock(&qedi_conn->list_lock);
+
+	qedi_add_to_sq(qedi_conn, task, tid, ptu_invalidate, false);
+	qedi_ring_doorbell(qedi_conn);
+
+	return 0;
+}
+
+int qedi_send_iscsi_nopout(struct qedi_conn *qedi_conn,
+			   struct iscsi_task *task,
+			   char *datap, int data_len, int unsol)
+{
+	struct qedi_ctx *qedi = qedi_conn->qedi;
+	struct iscsi_task_context *fw_task_ctx;
+	struct iscsi_nop_out_hdr *fw_nop_out;
+	struct qedi_cmd *qedi_cmd;
+	/* For 6.5 hdr iscsi_hdr */
+	struct iscsi_nopout *nopout_hdr;
+	struct iscsi_cached_sge_ctx *cached_sge;
+	struct iscsi_sge *single_sge;
+	struct iscsi_sge *req_sge;
+	struct iscsi_sge *resp_sge;
+	u32 lun[2];
+	s16 ptu_invalidate = 0;
+	s16 tid = 0;
+
+	req_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.req_bd_tbl;
+	resp_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.resp_bd_tbl;
+	qedi_cmd = (struct qedi_cmd *)task->dd_data;
+	nopout_hdr = (struct iscsi_nopout *)task->hdr;
+
+	tid = qedi_get_task_idx(qedi);
+	if (tid == -1) {
+		QEDI_WARN(&qedi->dbg_ctx, "Invalid tid\n");
+		return -ENOMEM;
+	}
+
+	fw_task_ctx = qedi_get_task_mem(&qedi->tasks, tid);
+
+	memset(fw_task_ctx, 0, sizeof(struct iscsi_task_context));
+	qedi_cmd->task_id = tid;
+
+	/* Ystorm context */
+	fw_nop_out = &fw_task_ctx->ystorm_st_context.pdu_hdr.nop_out;
+	SET_FIELD(fw_nop_out->flags_attr, ISCSI_NOP_OUT_HDR_CONST1, 1);
+	SET_FIELD(fw_nop_out->flags_attr, ISCSI_NOP_OUT_HDR_RSRV, 0);
+
+	memcpy(lun, &nopout_hdr->lun, sizeof(struct scsi_lun));
+	fw_nop_out->lun.lo = be32_to_cpu(lun[0]);
+	fw_nop_out->lun.hi = be32_to_cpu(lun[1]);
+
+	qedi_update_itt_map(qedi, tid, task->itt, qedi_cmd);
+
+	if (nopout_hdr->ttt != ISCSI_TTT_ALL_ONES) {
+		fw_nop_out->itt = be32_to_cpu(nopout_hdr->itt);
+		fw_nop_out->ttt = be32_to_cpu(nopout_hdr->ttt);
+		fw_task_ctx->ystorm_st_context.state.buffer_offset[0] = 0;
+		fw_task_ctx->ystorm_st_context.state.local_comp = 1;
+		SET_FIELD(fw_task_ctx->ustorm_st_context.flags,
+			  USTORM_ISCSI_TASK_ST_CTX_LOCAL_COMP, 1);
+	} else {
+		fw_nop_out->itt = qedi_set_itt(tid, get_itt(task->itt));
+		fw_nop_out->ttt = ISCSI_TTT_ALL_ONES;
+		fw_task_ctx->ystorm_st_context.state.buffer_offset[0] = 0;
+
+		spin_lock(&qedi_conn->list_lock);
+		list_add_tail(&qedi_cmd->io_cmd, &qedi_conn->active_cmd_list);
+		qedi_cmd->io_cmd_in_list = true;
+		qedi_conn->active_cmd_count++;
+		spin_unlock(&qedi_conn->list_lock);
+	}
+
+	fw_nop_out->opcode = ISCSI_OPCODE_NOP_OUT;
+	fw_nop_out->cmd_sn = be32_to_cpu(nopout_hdr->cmdsn);
+	fw_nop_out->exp_stat_sn = be32_to_cpu(nopout_hdr->exp_statsn);
+
+	cached_sge =
+	       &fw_task_ctx->ystorm_st_context.state.sgl_ctx_union.cached_sge;
+	cached_sge->sge.sge_len = req_sge->sge_len;
+	cached_sge->sge.sge_addr.lo = (u32)(qedi_conn->gen_pdu.req_dma_addr);
+	cached_sge->sge.sge_addr.hi =
+			(u32)((u64)qedi_conn->gen_pdu.req_dma_addr >> 32);
+
+	/* Mstorm context */
+	fw_task_ctx->mstorm_st_context.task_type = ISCSI_TASK_TYPE_MIDPATH;
+	fw_task_ctx->mstorm_ag_context.task_cid = (u16)qedi_conn->iscsi_conn_id;
+
+	single_sge = &fw_task_ctx->mstorm_st_context.sgl_union.single_sge;
+	single_sge->sge_addr.lo = resp_sge->sge_addr.lo;
+	single_sge->sge_addr.hi = resp_sge->sge_addr.hi;
+	single_sge->sge_len = resp_sge->sge_len;
+	fw_task_ctx->mstorm_st_context.rem_task_size = resp_sge->sge_len;
+
+	if (qedi->tid_reuse_count[tid] == QEDI_MAX_TASK_NUM) {
+		ptu_invalidate = 1;
+		qedi->tid_reuse_count[tid] = 0;
+	}
+	fw_task_ctx->ystorm_st_context.state.reuse_count =
+						qedi->tid_reuse_count[tid];
+	fw_task_ctx->mstorm_st_context.reuse_count =
+						qedi->tid_reuse_count[tid]++;
+	/* Ustorm context */
+	fw_task_ctx->ustorm_st_context.rem_rcv_len = resp_sge->sge_len;
+	fw_task_ctx->ustorm_st_context.exp_data_transfer_len = data_len;
+	fw_task_ctx->ustorm_st_context.exp_data_sn = 0;
+	fw_task_ctx->ustorm_st_context.task_type =  ISCSI_TASK_TYPE_MIDPATH;
+	fw_task_ctx->ustorm_st_context.cq_rss_number = 0;
+
+	SET_FIELD(fw_task_ctx->ustorm_st_context.reg1.reg1_map,
+		  ISCSI_REG1_NUM_FAST_SGES, 0);
+
+	fw_task_ctx->ustorm_ag_context.icid = (u16)qedi_conn->iscsi_conn_id;
+	SET_FIELD(fw_task_ctx->ustorm_ag_context.flags1,
+		  USTORM_ISCSI_TASK_AG_CTX_R2T2RECV, 1);
+
+	fw_task_ctx->ustorm_st_context.lun.lo = be32_to_cpu(lun[0]);
+	fw_task_ctx->ustorm_st_context.lun.hi = be32_to_cpu(lun[1]);
+
+	qedi_add_to_sq(qedi_conn, task, tid, ptu_invalidate, false);
+	qedi_ring_doorbell(qedi_conn);
+	return 0;
+}
+
+static int qedi_split_bd(struct qedi_cmd *cmd, u64 addr, int sg_len,
+			 int bd_index)
+{
+	struct iscsi_sge *bd = cmd->io_tbl.sge_tbl;
+	int frag_size, sg_frags;
+
+	sg_frags = 0;
+
+	while (sg_len) {
+		if (addr % QEDI_PAGE_SIZE)
+			frag_size =
+				   (QEDI_PAGE_SIZE - (addr % QEDI_PAGE_SIZE));
+		else
+			frag_size = (sg_len > QEDI_BD_SPLIT_SZ) ? 0 :
+				    (sg_len % QEDI_BD_SPLIT_SZ);
+
+		if (frag_size == 0)
+			frag_size = QEDI_BD_SPLIT_SZ;
+
+		bd[bd_index + sg_frags].sge_addr.lo = (addr & 0xffffffff);
+		bd[bd_index + sg_frags].sge_addr.hi = (addr >> 32);
+		bd[bd_index + sg_frags].sge_len = (u16)frag_size;
+		QEDI_INFO(&cmd->conn->qedi->dbg_ctx, QEDI_LOG_IO,
+			  "split sge %d: addr=%llx, len=%x",
+			  (bd_index + sg_frags), addr, frag_size);
+
+		addr += (u64)frag_size;
+		sg_frags++;
+		sg_len -= frag_size;
+	}
+	return sg_frags;
+}
+
+static int qedi_map_scsi_sg(struct qedi_ctx *qedi, struct qedi_cmd *cmd)
+{
+	struct scsi_cmnd *sc = cmd->scsi_cmd;
+	struct iscsi_sge *bd = cmd->io_tbl.sge_tbl;
+	struct scatterlist *sg;
+	int byte_count = 0;
+	int bd_count = 0;
+	int sg_count;
+	int sg_len;
+	int sg_frags;
+	u64 addr, end_addr;
+	int i;
+
+	WARN_ON(scsi_sg_count(sc) > QEDI_ISCSI_MAX_BDS_PER_CMD);
+
+	sg_count = dma_map_sg(&qedi->pdev->dev, scsi_sglist(sc),
+			      scsi_sg_count(sc), sc->sc_data_direction);
+
+	/*
+	 * New condition to send single SGE as cached-SGL.
+	 * Single SGE with length less than 64K.
+	 */
+	sg = scsi_sglist(sc);
+	if ((sg_count == 1) && (sg_dma_len(sg) <= MAX_SGLEN_FOR_CACHESGL)) {
+		sg_len = sg_dma_len(sg);
+		addr = (u64)sg_dma_address(sg);
+
+		bd[bd_count].sge_addr.lo = (addr & 0xffffffff);
+		bd[bd_count].sge_addr.hi = (addr >> 32);
+		bd[bd_count].sge_len = (u16)sg_len;
+
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_IO,
+			  "single-cashed-sgl: bd_count:%d addr=%llx, len=%x",
+			  sg_count, addr, sg_len);
+
+		return ++bd_count;
+	}
+
+	scsi_for_each_sg(sc, sg, sg_count, i) {
+		sg_len = sg_dma_len(sg);
+		addr = (u64)sg_dma_address(sg);
+		end_addr = (addr + sg_len);
+
+		/*
+		 * first sg elem in the 'list',
+		 * check if end addr is page-aligned.
+		 */
+		if ((i == 0) && (sg_count > 1) && (end_addr % QEDI_PAGE_SIZE))
+			cmd->use_slowpath = true;
+
+		/*
+		 * last sg elem in the 'list',
+		 * check if start addr is page-aligned.
+		 */
+		else if ((i == (sg_count - 1)) &&
+			 (sg_count > 1) && (addr % QEDI_PAGE_SIZE))
+			cmd->use_slowpath = true;
+
+		/*
+		 * middle sg elements in list,
+		 * check if start and end addr is page-aligned
+		 */
+		else if ((i != 0) && (i != (sg_count - 1)) &&
+			 ((addr % QEDI_PAGE_SIZE) ||
+			 (end_addr % QEDI_PAGE_SIZE)))
+			cmd->use_slowpath = true;
+
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_IO, "sg[%d] size=0x%x",
+			  i, sg_len);
+
+		if (sg_len > QEDI_BD_SPLIT_SZ) {
+			sg_frags = qedi_split_bd(cmd, addr, sg_len, bd_count);
+		} else {
+			sg_frags = 1;
+			bd[bd_count].sge_addr.lo = addr & 0xffffffff;
+			bd[bd_count].sge_addr.hi = addr >> 32;
+			bd[bd_count].sge_len = sg_len;
+		}
+		byte_count += sg_len;
+		bd_count += sg_frags;
+	}
+
+	if (byte_count != scsi_bufflen(sc))
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "byte_count = %d != scsi_bufflen = %d\n", byte_count,
+			 scsi_bufflen(sc));
+	else
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_IO, "byte_count = %d\n",
+			  byte_count);
+
+	WARN_ON(byte_count != scsi_bufflen(sc));
+
+	return bd_count;
+}
+
+static void qedi_iscsi_map_sg_list(struct qedi_cmd *cmd)
+{
+	int bd_count;
+	struct scsi_cmnd *sc = cmd->scsi_cmd;
+
+	if (scsi_sg_count(sc)) {
+		bd_count  = qedi_map_scsi_sg(cmd->conn->qedi, cmd);
+		if (bd_count == 0)
+			return;
+	} else {
+		struct iscsi_sge *bd = cmd->io_tbl.sge_tbl;
+
+		bd[0].sge_addr.lo = 0;
+		bd[0].sge_addr.hi = 0;
+		bd[0].sge_len = 0;
+		bd_count = 0;
+	}
+	cmd->io_tbl.sge_valid = bd_count;
+}
+
+static void qedi_cpy_scsi_cdb(struct scsi_cmnd *sc, u32 *dstp)
+{
+	u32 dword;
+	int lpcnt;
+	u8 *srcp;
+
+	lpcnt = sc->cmd_len / sizeof(dword);
+	srcp = (u8 *)sc->cmnd;
+	while (lpcnt--) {
+		memcpy(&dword, (const void *)srcp, 4);
+		*dstp = cpu_to_be32(dword);
+		srcp += 4;
+		dstp++;
+	}
+	if (sc->cmd_len & 0x3) {
+		dword = (u32)srcp[0] | ((u32)srcp[1] << 8);
+		*dstp = cpu_to_be32(dword);
+	}
+}
+
+void qedi_trace_io(struct qedi_ctx *qedi, struct iscsi_task *task,
+		   u16 tid, int8_t direction)
+{
+	struct qedi_io_log *io_log;
+	struct iscsi_conn *conn = task->conn;
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct scsi_cmnd *sc_cmd = task->sc;
+	unsigned long flags;
+	u8 op;
+
+	spin_lock_irqsave(&qedi->io_trace_lock, flags);
+
+	io_log = &qedi->io_trace_buf[qedi->io_trace_idx];
+	io_log->direction = direction;
+	io_log->task_id = tid;
+	io_log->cid = qedi_conn->iscsi_conn_id;
+	io_log->lun = sc_cmd->device->lun;
+	io_log->op = sc_cmd->cmnd[0];
+	op = sc_cmd->cmnd[0];
+	io_log->lba[0] = sc_cmd->cmnd[2];
+	io_log->lba[1] = sc_cmd->cmnd[3];
+	io_log->lba[2] = sc_cmd->cmnd[4];
+	io_log->lba[3] = sc_cmd->cmnd[5];
+	io_log->bufflen = scsi_bufflen(sc_cmd);
+	io_log->sg_count = scsi_sg_count(sc_cmd);
+	io_log->fast_sgs = qedi->fast_sgls;
+	io_log->cached_sgs = qedi->cached_sgls;
+	io_log->slow_sgs = qedi->slow_sgls;
+	io_log->cached_sge = qedi->use_cached_sge;
+	io_log->slow_sge = qedi->use_slow_sge;
+	io_log->fast_sge = qedi->use_fast_sge;
+	io_log->result = sc_cmd->result;
+	io_log->jiffies = jiffies;
+	io_log->blk_req_cpu = smp_processor_id();
+
+	if (direction == QEDI_IO_TRACE_REQ) {
+		/* For requests we only care about the submission CPU */
+		io_log->req_cpu = smp_processor_id() % qedi->num_queues;
+		io_log->intr_cpu = 0;
+		io_log->blk_rsp_cpu = 0;
+	} else if (direction == QEDI_IO_TRACE_RSP) {
+		io_log->req_cpu = smp_processor_id() % qedi->num_queues;
+		io_log->intr_cpu = qedi->intr_cpu;
+		io_log->blk_rsp_cpu = smp_processor_id();
+	}
+
+	qedi->io_trace_idx++;
+	if (qedi->io_trace_idx == QEDI_IO_TRACE_SIZE)
+		qedi->io_trace_idx = 0;
+
+	qedi->use_cached_sge = false;
+	qedi->use_slow_sge = false;
+	qedi->use_fast_sge = false;
+
+	spin_unlock_irqrestore(&qedi->io_trace_lock, flags);
+}
+
+int qedi_iscsi_send_ioreq(struct iscsi_task *task)
+{
+	struct iscsi_conn *conn = task->conn;
+	struct iscsi_session *session = conn->session;
+	struct Scsi_Host *shost = iscsi_session_to_shost(session->cls_session);
+	struct qedi_ctx *qedi = iscsi_host_priv(shost);
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct qedi_cmd *cmd = task->dd_data;
+	struct scsi_cmnd *sc = task->sc;
+	struct iscsi_task_context *fw_task_ctx;
+	struct iscsi_cached_sge_ctx *cached_sge;
+	struct iscsi_phys_sgl_ctx *phys_sgl;
+	struct iscsi_virt_sgl_ctx *virt_sgl;
+	struct ystorm_iscsi_task_st_ctx *yst_cxt;
+	struct mstorm_iscsi_task_st_ctx *mst_cxt;
+	struct iscsi_sgl *sgl_struct;
+	struct iscsi_sge *single_sge;
+	struct iscsi_scsi_req *hdr = (struct iscsi_scsi_req *)task->hdr;
+	struct iscsi_sge *bd = cmd->io_tbl.sge_tbl;
+	enum iscsi_task_type task_type;
+	struct iscsi_cmd_hdr *fw_cmd;
+	u32 lun[2];
+	u32 exp_data;
+	u16 cq_idx = smp_processor_id() % qedi->num_queues;
+	s16 ptu_invalidate = 0;
+	s16 tid = 0;
+	u8 num_fast_sgs;
+
+	tid = qedi_get_task_idx(qedi);
+	if (tid == -1)
+		return -ENOMEM;
+
+	qedi_iscsi_map_sg_list(cmd);
+
+	int_to_scsilun(sc->device->lun, (struct scsi_lun *)lun);
+	fw_task_ctx = qedi_get_task_mem(&qedi->tasks, tid);
+
+	memset(fw_task_ctx, 0, sizeof(struct iscsi_task_context));
+	cmd->task_id = tid;
+
+	/* Ystorm context */
+	fw_cmd = &fw_task_ctx->ystorm_st_context.pdu_hdr.cmd;
+	SET_FIELD(fw_cmd->flags_attr, ISCSI_CMD_HDR_ATTR, ISCSI_ATTR_SIMPLE);
+
+	if (sc->sc_data_direction == DMA_TO_DEVICE) {
+		if (conn->session->initial_r2t_en) {
+			exp_data = min((conn->session->imm_data_en *
+					conn->max_xmit_dlength),
+				       conn->session->first_burst);
+			exp_data = min(exp_data, scsi_bufflen(sc));
+			fw_task_ctx->ustorm_ag_context.exp_data_acked =
+							  cpu_to_le32(exp_data);
+		} else {
+			fw_task_ctx->ustorm_ag_context.exp_data_acked =
+			      min(conn->session->first_burst, scsi_bufflen(sc));
+		}
+
+		SET_FIELD(fw_cmd->flags_attr, ISCSI_CMD_HDR_WRITE, 1);
+		task_type = ISCSI_TASK_TYPE_INITIATOR_WRITE;
+	} else {
+		if (scsi_bufflen(sc))
+			SET_FIELD(fw_cmd->flags_attr, ISCSI_CMD_HDR_READ, 1);
+		task_type = ISCSI_TASK_TYPE_INITIATOR_READ;
+	}
+
+	fw_cmd->lun.lo = be32_to_cpu(lun[0]);
+	fw_cmd->lun.hi = be32_to_cpu(lun[1]);
+
+	qedi_update_itt_map(qedi, tid, task->itt, cmd);
+	fw_cmd->itt = qedi_set_itt(tid, get_itt(task->itt));
+	fw_cmd->expected_transfer_length = scsi_bufflen(sc);
+	fw_cmd->cmd_sn = be32_to_cpu(hdr->cmdsn);
+	fw_cmd->opcode = hdr->opcode;
+	qedi_cpy_scsi_cdb(sc, (u32 *)fw_cmd->cdb);
+
+	/* Mstorm context */
+	fw_task_ctx->mstorm_st_context.sense_db.lo = (u32)cmd->sense_buffer_dma;
+	fw_task_ctx->mstorm_st_context.sense_db.hi =
+					(u32)((u64)cmd->sense_buffer_dma >> 32);
+	fw_task_ctx->mstorm_ag_context.task_cid = qedi_conn->iscsi_conn_id;
+	fw_task_ctx->mstorm_st_context.task_type = task_type;
+
+	if (qedi->tid_reuse_count[tid] == QEDI_MAX_TASK_NUM) {
+		ptu_invalidate = 1;
+		qedi->tid_reuse_count[tid] = 0;
+	}
+	fw_task_ctx->ystorm_st_context.state.reuse_count =
+						     qedi->tid_reuse_count[tid];
+	fw_task_ctx->mstorm_st_context.reuse_count =
+						   qedi->tid_reuse_count[tid]++;
+
+	/* Ustorm context */
+	fw_task_ctx->ustorm_st_context.rem_rcv_len = scsi_bufflen(sc);
+	fw_task_ctx->ustorm_st_context.exp_data_transfer_len = scsi_bufflen(sc);
+	fw_task_ctx->ustorm_st_context.exp_data_sn =
+						   be32_to_cpu(hdr->exp_statsn);
+	fw_task_ctx->ustorm_st_context.task_type = task_type;
+	fw_task_ctx->ustorm_st_context.cq_rss_number = cq_idx;
+	fw_task_ctx->ustorm_ag_context.icid = (u16)qedi_conn->iscsi_conn_id;
+
+	SET_FIELD(fw_task_ctx->ustorm_ag_context.flags1,
+		  USTORM_ISCSI_TASK_AG_CTX_R2T2RECV, 1);
+	SET_FIELD(fw_task_ctx->ustorm_st_context.flags,
+		  USTORM_ISCSI_TASK_ST_CTX_LOCAL_COMP, 0);
+
+	num_fast_sgs = (cmd->io_tbl.sge_valid ?
+			min((u16)QEDI_FAST_SGE_COUNT,
+			    (u16)cmd->io_tbl.sge_valid) : 0);
+	SET_FIELD(fw_task_ctx->ustorm_st_context.reg1.reg1_map,
+		  ISCSI_REG1_NUM_FAST_SGES, num_fast_sgs);
+
+	fw_task_ctx->ustorm_st_context.lun.lo = be32_to_cpu(lun[0]);
+	fw_task_ctx->ustorm_st_context.lun.hi = be32_to_cpu(lun[1]);
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_IO, "Total sge count [%d]\n",
+		  cmd->io_tbl.sge_valid);
+
+	yst_cxt = &fw_task_ctx->ystorm_st_context;
+	mst_cxt = &fw_task_ctx->mstorm_st_context;
+	/* Tx path */
+	if (task_type == ISCSI_TASK_TYPE_INITIATOR_WRITE) {
+		/* not considering  superIO or FastIO */
+		if (cmd->io_tbl.sge_valid == 1) {
+			cached_sge = &yst_cxt->state.sgl_ctx_union.cached_sge;
+			cached_sge->sge.sge_addr.lo = bd[0].sge_addr.lo;
+			cached_sge->sge.sge_addr.hi = bd[0].sge_addr.hi;
+			cached_sge->sge.sge_len = bd[0].sge_len;
+			qedi->cached_sgls++;
+		} else if ((cmd->io_tbl.sge_valid != 1) && cmd->use_slowpath) {
+			SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+				  ISCSI_MFLAGS_SLOW_IO, 1);
+			SET_FIELD(fw_task_ctx->ustorm_st_context.reg1.reg1_map,
+				  ISCSI_REG1_NUM_FAST_SGES, 0);
+			phys_sgl = &yst_cxt->state.sgl_ctx_union.phys_sgl;
+			phys_sgl->sgl_base.lo = (u32)(cmd->io_tbl.sge_tbl_dma);
+			phys_sgl->sgl_base.hi =
+				     (u32)((u64)cmd->io_tbl.sge_tbl_dma >> 32);
+			phys_sgl->sgl_size = cmd->io_tbl.sge_valid;
+			qedi->slow_sgls++;
+		} else if ((cmd->io_tbl.sge_valid != 1) && !cmd->use_slowpath) {
+			SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+				  ISCSI_MFLAGS_SLOW_IO, 0);
+			SET_FIELD(fw_task_ctx->ustorm_st_context.reg1.reg1_map,
+				  ISCSI_REG1_NUM_FAST_SGES,
+				  min((u16)QEDI_FAST_SGE_COUNT,
+				      (u16)cmd->io_tbl.sge_valid));
+			virt_sgl = &yst_cxt->state.sgl_ctx_union.virt_sgl;
+			virt_sgl->sgl_base.lo = (u32)(cmd->io_tbl.sge_tbl_dma);
+			virt_sgl->sgl_base.hi =
+				      (u32)((u64)cmd->io_tbl.sge_tbl_dma >> 32);
+			virt_sgl->sgl_initial_offset =
+				 (u32)bd[0].sge_addr.lo & (QEDI_PAGE_SIZE - 1);
+			qedi->fast_sgls++;
+		}
+		fw_task_ctx->mstorm_st_context.sgl_size = cmd->io_tbl.sge_valid;
+		fw_task_ctx->mstorm_st_context.rem_task_size = scsi_bufflen(sc);
+	} else {
+	/* Rx path */
+		if (cmd->io_tbl.sge_valid == 1) {
+			SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+				  ISCSI_MFLAGS_SLOW_IO, 0);
+			SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+				  ISCSI_MFLAGS_SINGLE_SGE, 1);
+			single_sge = &mst_cxt->sgl_union.single_sge;
+			single_sge->sge_addr.lo = bd[0].sge_addr.lo;
+			single_sge->sge_addr.hi = bd[0].sge_addr.hi;
+			single_sge->sge_len = bd[0].sge_len;
+			qedi->cached_sgls++;
+		} else if ((cmd->io_tbl.sge_valid != 1) && cmd->use_slowpath) {
+			sgl_struct = &mst_cxt->sgl_union.sgl_struct;
+			sgl_struct->sgl_addr.lo =
+						(u32)(cmd->io_tbl.sge_tbl_dma);
+			sgl_struct->sgl_addr.hi =
+				     (u32)((u64)cmd->io_tbl.sge_tbl_dma >> 32);
+			SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+				  ISCSI_MFLAGS_SLOW_IO, 1);
+			SET_FIELD(fw_task_ctx->ustorm_st_context.reg1.reg1_map,
+				  ISCSI_REG1_NUM_FAST_SGES, 0);
+			sgl_struct->updated_sge_size = 0;
+			sgl_struct->updated_sge_offset = 0;
+			qedi->slow_sgls++;
+		} else if ((cmd->io_tbl.sge_valid != 1) && !cmd->use_slowpath) {
+			sgl_struct = &mst_cxt->sgl_union.sgl_struct;
+			sgl_struct->sgl_addr.lo =
+						(u32)(cmd->io_tbl.sge_tbl_dma);
+			sgl_struct->sgl_addr.hi =
+				     (u32)((u64)cmd->io_tbl.sge_tbl_dma >> 32);
+			sgl_struct->byte_offset =
+				(u32)bd[0].sge_addr.lo & (QEDI_PAGE_SIZE - 1);
+			SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+				  ISCSI_MFLAGS_SLOW_IO, 0);
+			SET_FIELD(fw_task_ctx->ustorm_st_context.reg1.reg1_map,
+				  ISCSI_REG1_NUM_FAST_SGES, 0);
+			sgl_struct->updated_sge_size = 0;
+			sgl_struct->updated_sge_offset = 0;
+			qedi->fast_sgls++;
+		}
+		fw_task_ctx->mstorm_st_context.sgl_size = cmd->io_tbl.sge_valid;
+		fw_task_ctx->mstorm_st_context.rem_task_size = scsi_bufflen(sc);
+	}
+
+	if (cmd->io_tbl.sge_valid == 1)
+		/* Singel-SGL */
+		qedi->use_cached_sge = true;
+	else {
+		if (cmd->use_slowpath)
+			qedi->use_slow_sge = true;
+		else
+			qedi->use_fast_sge = true;
+	}
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_IO,
+		  "%s: %s-SGL: num_sges=0x%x first-sge-lo=0x%x first-sge-hi=0x%x",
+		  (task_type == ISCSI_TASK_TYPE_INITIATOR_WRITE) ?
+		  "Write " : "Read ", (cmd->io_tbl.sge_valid == 1) ?
+		  "Single" : (cmd->use_slowpath ? "SLOW" : "FAST"),
+		  (u16)cmd->io_tbl.sge_valid, (u32)(cmd->io_tbl.sge_tbl_dma),
+		  (u32)((u64)cmd->io_tbl.sge_tbl_dma >> 32));
+
+	/*  Add command in active command list */
+	spin_lock(&qedi_conn->list_lock);
+	list_add_tail(&cmd->io_cmd, &qedi_conn->active_cmd_list);
+	cmd->io_cmd_in_list = true;
+	qedi_conn->active_cmd_count++;
+	spin_unlock(&qedi_conn->list_lock);
+
+	qedi_add_to_sq(qedi_conn, task, tid, ptu_invalidate, false);
+	qedi_ring_doorbell(qedi_conn);
+	if (qedi_io_tracing)
+		qedi_trace_io(qedi, task, tid, QEDI_IO_TRACE_REQ);
+
+	return 0;
+}
+
+int qedi_iscsi_cleanup_task(struct iscsi_task *task, bool mark_cmd_node_deleted)
+{
+	struct iscsi_conn *conn = task->conn;
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct qedi_cmd *cmd = task->dd_data;
+	s16 ptu_invalidate = 0;
+
+	QEDI_INFO(&qedi_conn->qedi->dbg_ctx, QEDI_LOG_SCSI_TM,
+		  "issue cleanup tid=0x%x itt=0x%x task_state=%d cmd_state=0%x cid=0x%x\n",
+		  cmd->task_id, get_itt(task->itt), task->state,
+		  cmd->state, qedi_conn->iscsi_conn_id);
+
+	qedi_add_to_sq(qedi_conn, task, cmd->task_id, ptu_invalidate, true);
+	qedi_ring_doorbell(qedi_conn);
+
+	return 0;
+}
diff --git a/drivers/scsi/qedi/qedi_gbl.h b/drivers/scsi/qedi/qedi_gbl.h
new file mode 100644
index 0000000..8e488de
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_gbl.h
@@ -0,0 +1,73 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QEDI_GBL_H_
+#define _QEDI_GBL_H_
+
+#include "qedi_iscsi.h"
+
+extern uint qedi_io_tracing;
+extern int do_not_recover;
+extern struct scsi_host_template qedi_host_template;
+extern struct iscsi_transport qedi_iscsi_transport;
+extern const struct qed_iscsi_ops *qedi_ops;
+extern struct qedi_debugfs_ops qedi_debugfs_ops;
+extern const struct file_operations qedi_dbg_fops;
+extern struct device_attribute *qedi_shost_attrs[];
+
+int qedi_alloc_sq(struct qedi_ctx *qedi, struct qedi_endpoint *ep);
+void qedi_free_sq(struct qedi_ctx *qedi, struct qedi_endpoint *ep);
+
+int qedi_send_iscsi_login(struct qedi_conn *qedi_conn,
+			  struct iscsi_task *task);
+int qedi_send_iscsi_logout(struct qedi_conn *qedi_conn,
+			   struct iscsi_task *task);
+int qedi_iscsi_abort_work(struct qedi_conn *qedi_conn,
+			  struct iscsi_task *mtask);
+int qedi_send_iscsi_text(struct qedi_conn *qedi_conn,
+			 struct iscsi_task *task);
+int qedi_send_iscsi_nopout(struct qedi_conn *qedi_conn,
+			   struct iscsi_task *task,
+			   char *datap, int data_len, int unsol);
+int qedi_iscsi_send_ioreq(struct iscsi_task *task);
+int qedi_get_task_idx(struct qedi_ctx *qedi);
+void qedi_clear_task_idx(struct qedi_ctx *qedi, int idx);
+int qedi_iscsi_cleanup_task(struct iscsi_task *task,
+			    bool mark_cmd_node_deleted);
+void qedi_iscsi_unmap_sg_list(struct qedi_cmd *cmd);
+void qedi_update_itt_map(struct qedi_ctx *qedi, u32 tid, u32 proto_itt,
+			 struct qedi_cmd *qedi_cmd);
+void qedi_get_proto_itt(struct qedi_ctx *qedi, u32 tid, u32 *proto_itt);
+void qedi_get_task_tid(struct qedi_ctx *qedi, u32 itt, int16_t *tid);
+void qedi_process_iscsi_error(struct qedi_endpoint *ep,
+			      struct async_data *data);
+void qedi_start_conn_recovery(struct qedi_ctx *qedi,
+			      struct qedi_conn *qedi_conn);
+struct qedi_conn *qedi_get_conn_from_id(struct qedi_ctx *qedi, u32 iscsi_cid);
+void qedi_process_tcp_error(struct qedi_endpoint *ep, struct async_data *data);
+void qedi_mark_device_missing(struct iscsi_cls_session *cls_session);
+void qedi_mark_device_available(struct iscsi_cls_session *cls_session);
+void qedi_reset_host_mtu(struct qedi_ctx *qedi, u16 mtu);
+int qedi_recover_all_conns(struct qedi_ctx *qedi);
+void qedi_fp_process_cqes(struct qedi_work *work);
+int qedi_cleanup_all_io(struct qedi_ctx *qedi,
+			struct qedi_conn *qedi_conn,
+			struct iscsi_task *task, bool in_recovery);
+void qedi_trace_io(struct qedi_ctx *qedi, struct iscsi_task *task,
+		   u16 tid, int8_t direction);
+int qedi_alloc_id(struct qedi_portid_tbl *id_tbl, u16 id);
+u16 qedi_alloc_new_id(struct qedi_portid_tbl *id_tbl);
+void qedi_free_id(struct qedi_portid_tbl *id_tbl, u16 id);
+int qedi_create_sysfs_ctx_attr(struct qedi_ctx *qedi);
+void qedi_remove_sysfs_ctx_attr(struct qedi_ctx *qedi);
+void qedi_clearsq(struct qedi_ctx *qedi,
+		  struct qedi_conn *qedi_conn,
+		  struct iscsi_task *task);
+
+#endif
diff --git a/drivers/scsi/qedi/qedi_hsi.h b/drivers/scsi/qedi/qedi_hsi.h
new file mode 100644
index 0000000..8ca44c7
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_hsi.h
@@ -0,0 +1,52 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+#ifndef __QEDI_HSI__
+#define __QEDI_HSI__
+/*
+ * Add include to common target
+ */
+#include <linux/qed/common_hsi.h>
+
+/*
+ * Add include to common storage target
+ */
+#include <linux/qed/storage_common.h>
+
+/*
+ * Add include to common TCP target
+ */
+#include <linux/qed/tcp_common.h>
+
+/*
+ * Add include to common iSCSI target for both eCore and protocol driver
+ */
+#include <linux/qed/iscsi_common.h>
+
+/*
+ * iSCSI CMDQ element
+ */
+struct iscsi_cmdqe {
+	__le16 conn_id;
+	u8 invalid_command;
+	u8 cmd_hdr_type;
+	__le32 reserved1[2];
+	__le32 cmd_payload[13];
+};
+
+/*
+ * iSCSI CMD header type
+ */
+enum iscsi_cmd_hdr_type {
+	ISCSI_CMD_HDR_TYPE_BHS_ONLY /* iSCSI BHS with no expected AHS */,
+	ISCSI_CMD_HDR_TYPE_BHS_W_AHS /* iSCSI BHS with expected AHS */,
+	ISCSI_CMD_HDR_TYPE_AHS /* iSCSI AHS */,
+	MAX_ISCSI_CMD_HDR_TYPE
+};
+
+#endif /* __QEDI_HSI__ */
diff --git a/drivers/scsi/qedi/qedi_iscsi.c b/drivers/scsi/qedi/qedi_iscsi.c
new file mode 100644
index 0000000..d6a2054
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_iscsi.c
@@ -0,0 +1,1624 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/blkdev.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <scsi/scsi_tcq.h>
+
+#include "qedi.h"
+#include "qedi_iscsi.h"
+#include "qedi_gbl.h"
+
+int qedi_recover_all_conns(struct qedi_ctx *qedi)
+{
+	struct qedi_conn *qedi_conn;
+	int i;
+
+	for (i = 0; i < qedi->max_active_conns; i++) {
+		qedi_conn = qedi_get_conn_from_id(qedi, i);
+		if (!qedi_conn)
+			continue;
+
+		qedi_start_conn_recovery(qedi, qedi_conn);
+	}
+
+	return SUCCESS;
+}
+
+static int qedi_eh_host_reset(struct scsi_cmnd *cmd)
+{
+	struct Scsi_Host *shost = cmd->device->host;
+	struct qedi_ctx *qedi;
+
+	qedi = iscsi_host_priv(shost);
+
+	return qedi_recover_all_conns(qedi);
+}
+
+struct scsi_host_template qedi_host_template = {
+	.module = THIS_MODULE,
+	.name = "QLogic QEDI 25/40/100Gb iSCSI Initiator Driver",
+	.proc_name = QEDI_MODULE_NAME,
+	.queuecommand = iscsi_queuecommand,
+	.eh_abort_handler = iscsi_eh_abort,
+	.eh_device_reset_handler = iscsi_eh_device_reset,
+	.eh_target_reset_handler = iscsi_eh_recover_target,
+	.eh_host_reset_handler = qedi_eh_host_reset,
+	.target_alloc = iscsi_target_alloc,
+	.change_queue_depth = scsi_change_queue_depth,
+	.can_queue = QEDI_MAX_ISCSI_TASK,
+	.this_id = -1,
+	.sg_tablesize = QEDI_ISCSI_MAX_BDS_PER_CMD,
+	.max_sectors = 0xffff,
+	.cmd_per_lun = 128,
+	.use_clustering = ENABLE_CLUSTERING,
+	.shost_attrs = qedi_shost_attrs,
+};
+
+static void qedi_conn_free_login_resources(struct qedi_ctx *qedi,
+					   struct qedi_conn *qedi_conn)
+{
+	if (qedi_conn->gen_pdu.resp_bd_tbl) {
+		dma_free_coherent(&qedi->pdev->dev, QEDI_PAGE_SIZE,
+				  qedi_conn->gen_pdu.resp_bd_tbl,
+				  qedi_conn->gen_pdu.resp_bd_dma);
+		qedi_conn->gen_pdu.resp_bd_tbl = NULL;
+	}
+
+	if (qedi_conn->gen_pdu.req_bd_tbl) {
+		dma_free_coherent(&qedi->pdev->dev, QEDI_PAGE_SIZE,
+				  qedi_conn->gen_pdu.req_bd_tbl,
+				  qedi_conn->gen_pdu.req_bd_dma);
+		qedi_conn->gen_pdu.req_bd_tbl = NULL;
+	}
+
+	if (qedi_conn->gen_pdu.resp_buf) {
+		dma_free_coherent(&qedi->pdev->dev,
+				  ISCSI_DEF_MAX_RECV_SEG_LEN,
+				  qedi_conn->gen_pdu.resp_buf,
+				  qedi_conn->gen_pdu.resp_dma_addr);
+		qedi_conn->gen_pdu.resp_buf = NULL;
+	}
+
+	if (qedi_conn->gen_pdu.req_buf) {
+		dma_free_coherent(&qedi->pdev->dev,
+				  ISCSI_DEF_MAX_RECV_SEG_LEN,
+				  qedi_conn->gen_pdu.req_buf,
+				  qedi_conn->gen_pdu.req_dma_addr);
+		qedi_conn->gen_pdu.req_buf = NULL;
+	}
+}
+
+static int qedi_conn_alloc_login_resources(struct qedi_ctx *qedi,
+					   struct qedi_conn *qedi_conn)
+{
+	qedi_conn->gen_pdu.req_buf =
+		dma_alloc_coherent(&qedi->pdev->dev,
+				   ISCSI_DEF_MAX_RECV_SEG_LEN,
+				   &qedi_conn->gen_pdu.req_dma_addr,
+				   GFP_KERNEL);
+	if (!qedi_conn->gen_pdu.req_buf)
+		goto login_req_buf_failure;
+
+	qedi_conn->gen_pdu.req_buf_size = 0;
+	qedi_conn->gen_pdu.req_wr_ptr = qedi_conn->gen_pdu.req_buf;
+
+	qedi_conn->gen_pdu.resp_buf =
+		dma_alloc_coherent(&qedi->pdev->dev,
+				   ISCSI_DEF_MAX_RECV_SEG_LEN,
+				   &qedi_conn->gen_pdu.resp_dma_addr,
+				   GFP_KERNEL);
+	if (!qedi_conn->gen_pdu.resp_buf)
+		goto login_resp_buf_failure;
+
+	qedi_conn->gen_pdu.resp_buf_size = ISCSI_DEF_MAX_RECV_SEG_LEN;
+	qedi_conn->gen_pdu.resp_wr_ptr = qedi_conn->gen_pdu.resp_buf;
+
+	qedi_conn->gen_pdu.req_bd_tbl =
+		dma_alloc_coherent(&qedi->pdev->dev, QEDI_PAGE_SIZE,
+				   &qedi_conn->gen_pdu.req_bd_dma, GFP_KERNEL);
+	if (!qedi_conn->gen_pdu.req_bd_tbl)
+		goto login_req_bd_tbl_failure;
+
+	qedi_conn->gen_pdu.resp_bd_tbl =
+		dma_alloc_coherent(&qedi->pdev->dev, QEDI_PAGE_SIZE,
+				   &qedi_conn->gen_pdu.resp_bd_dma,
+				   GFP_KERNEL);
+	if (!qedi_conn->gen_pdu.resp_bd_tbl)
+		goto login_resp_bd_tbl_failure;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SESS,
+		  "Allocation successful, cid=0x%x\n",
+		  qedi_conn->iscsi_conn_id);
+	return 0;
+
+login_resp_bd_tbl_failure:
+	dma_free_coherent(&qedi->pdev->dev, QEDI_PAGE_SIZE,
+			  qedi_conn->gen_pdu.req_bd_tbl,
+			  qedi_conn->gen_pdu.req_bd_dma);
+	qedi_conn->gen_pdu.req_bd_tbl = NULL;
+
+login_req_bd_tbl_failure:
+	dma_free_coherent(&qedi->pdev->dev, ISCSI_DEF_MAX_RECV_SEG_LEN,
+			  qedi_conn->gen_pdu.resp_buf,
+			  qedi_conn->gen_pdu.resp_dma_addr);
+	qedi_conn->gen_pdu.resp_buf = NULL;
+login_resp_buf_failure:
+	dma_free_coherent(&qedi->pdev->dev, ISCSI_DEF_MAX_RECV_SEG_LEN,
+			  qedi_conn->gen_pdu.req_buf,
+			  qedi_conn->gen_pdu.req_dma_addr);
+	qedi_conn->gen_pdu.req_buf = NULL;
+login_req_buf_failure:
+	iscsi_conn_printk(KERN_ERR, qedi_conn->cls_conn->dd_data,
+			  "login resource alloc failed!!\n");
+	return -ENOMEM;
+}
+
+static void qedi_destroy_cmd_pool(struct qedi_ctx *qedi,
+				  struct iscsi_session *session)
+{
+	int i;
+
+	for (i = 0; i < session->cmds_max; i++) {
+		struct iscsi_task *task = session->cmds[i];
+		struct qedi_cmd *cmd = task->dd_data;
+
+		if (cmd->io_tbl.sge_tbl)
+			dma_free_coherent(&qedi->pdev->dev,
+					  QEDI_ISCSI_MAX_BDS_PER_CMD *
+					  sizeof(struct iscsi_sge),
+					  cmd->io_tbl.sge_tbl,
+					  cmd->io_tbl.sge_tbl_dma);
+
+		if (cmd->sense_buffer)
+			dma_free_coherent(&qedi->pdev->dev,
+					  SCSI_SENSE_BUFFERSIZE,
+					  cmd->sense_buffer,
+					  cmd->sense_buffer_dma);
+	}
+}
+
+static int qedi_alloc_sget(struct qedi_ctx *qedi, struct iscsi_session *session,
+			   struct qedi_cmd *cmd)
+{
+	struct qedi_io_bdt *io = &cmd->io_tbl;
+	struct iscsi_sge *sge;
+
+	io->sge_tbl = dma_alloc_coherent(&qedi->pdev->dev,
+					 QEDI_ISCSI_MAX_BDS_PER_CMD *
+					 sizeof(*sge),
+					 &io->sge_tbl_dma, GFP_KERNEL);
+	if (!io->sge_tbl) {
+		iscsi_session_printk(KERN_ERR, session,
+				     "Could not allocate BD table.\n");
+		return -ENOMEM;
+	}
+
+	io->sge_valid = 0;
+	return 0;
+}
+
+static int qedi_setup_cmd_pool(struct qedi_ctx *qedi,
+			       struct iscsi_session *session)
+{
+	int i;
+
+	for (i = 0; i < session->cmds_max; i++) {
+		struct iscsi_task *task = session->cmds[i];
+		struct qedi_cmd *cmd = task->dd_data;
+
+		task->hdr = &cmd->hdr;
+		task->hdr_max = sizeof(struct iscsi_hdr);
+
+		if (qedi_alloc_sget(qedi, session, cmd))
+			goto free_sgets;
+
+		cmd->sense_buffer = dma_alloc_coherent(&qedi->pdev->dev,
+						       SCSI_SENSE_BUFFERSIZE,
+						       &cmd->sense_buffer_dma,
+						       GFP_KERNEL);
+		if (!cmd->sense_buffer)
+			goto free_sgets;
+	}
+
+	return 0;
+
+free_sgets:
+	qedi_destroy_cmd_pool(qedi, session);
+	return -ENOMEM;
+}
+
+static struct iscsi_cls_session *
+qedi_session_create(struct iscsi_endpoint *ep, u16 cmds_max,
+		    u16 qdepth, uint32_t initial_cmdsn)
+{
+	struct Scsi_Host *shost;
+	struct iscsi_cls_session *cls_session;
+	struct qedi_ctx *qedi;
+	struct qedi_endpoint *qedi_ep;
+
+	if (!ep)
+		return NULL;
+
+	qedi_ep = ep->dd_data;
+	shost = qedi_ep->qedi->shost;
+	qedi = iscsi_host_priv(shost);
+
+	if (cmds_max > qedi->max_sqes)
+		cmds_max = qedi->max_sqes;
+	else if (cmds_max < QEDI_SQ_WQES_MIN)
+		cmds_max = QEDI_SQ_WQES_MIN;
+
+	cls_session = iscsi_session_setup(&qedi_iscsi_transport, shost,
+					  cmds_max, 0, sizeof(struct qedi_cmd),
+					  initial_cmdsn, ISCSI_MAX_TARGET);
+	if (!cls_session) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Failed to setup session for ep=%p\n", qedi_ep);
+		return NULL;
+	}
+
+	if (qedi_setup_cmd_pool(qedi, cls_session->dd_data)) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Failed to setup cmd pool for ep=%p\n", qedi_ep);
+		goto session_teardown;
+	}
+
+	return cls_session;
+
+session_teardown:
+	iscsi_session_teardown(cls_session);
+	return NULL;
+}
+
+static void qedi_session_destroy(struct iscsi_cls_session *cls_session)
+{
+	struct iscsi_session *session = cls_session->dd_data;
+	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
+	struct qedi_ctx *qedi = iscsi_host_priv(shost);
+
+	qedi_destroy_cmd_pool(qedi, session);
+	iscsi_session_teardown(cls_session);
+}
+
+static struct iscsi_cls_conn *
+qedi_conn_create(struct iscsi_cls_session *cls_session, uint32_t cid)
+{
+	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
+	struct qedi_ctx *qedi = iscsi_host_priv(shost);
+	struct iscsi_cls_conn *cls_conn;
+	struct qedi_conn *qedi_conn;
+	struct iscsi_conn *conn;
+
+	cls_conn = iscsi_conn_setup(cls_session, sizeof(*qedi_conn),
+				    cid);
+	if (!cls_conn) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "conn_new: iscsi conn setup failed, cid=0x%x, cls_sess=%p!\n",
+			 cid, cls_session);
+		return NULL;
+	}
+
+	conn = cls_conn->dd_data;
+	qedi_conn = conn->dd_data;
+	qedi_conn->cls_conn = cls_conn;
+	qedi_conn->qedi = qedi;
+	qedi_conn->ep = NULL;
+	qedi_conn->active_cmd_count = 0;
+	INIT_LIST_HEAD(&qedi_conn->active_cmd_list);
+	spin_lock_init(&qedi_conn->list_lock);
+
+	if (qedi_conn_alloc_login_resources(qedi, qedi_conn)) {
+		iscsi_conn_printk(KERN_ALERT, conn,
+				  "conn_new: login resc alloc failed, cid=0x%x, cls_sess=%p!!\n",
+				   cid, cls_session);
+		goto free_conn;
+	}
+
+	return cls_conn;
+
+free_conn:
+	iscsi_conn_teardown(cls_conn);
+	return NULL;
+}
+
+void qedi_mark_device_missing(struct iscsi_cls_session *cls_session)
+{
+	iscsi_block_session(cls_session);
+}
+
+void qedi_mark_device_available(struct iscsi_cls_session *cls_session)
+{
+	iscsi_unblock_session(cls_session);
+}
+
+static int qedi_bind_conn_to_iscsi_cid(struct qedi_ctx *qedi,
+				       struct qedi_conn *qedi_conn)
+{
+	u32 iscsi_cid = qedi_conn->iscsi_conn_id;
+
+	if (qedi->cid_que.conn_cid_tbl[iscsi_cid]) {
+		iscsi_conn_printk(KERN_ALERT, qedi_conn->cls_conn->dd_data,
+				  "conn bind - entry #%d not free\n",
+				  iscsi_cid);
+		return -EBUSY;
+	}
+
+	qedi->cid_que.conn_cid_tbl[iscsi_cid] = qedi_conn;
+	return 0;
+}
+
+struct qedi_conn *qedi_get_conn_from_id(struct qedi_ctx *qedi, u32 iscsi_cid)
+{
+	if (!qedi->cid_que.conn_cid_tbl) {
+		QEDI_ERR(&qedi->dbg_ctx, "missing conn<->cid table\n");
+		return NULL;
+
+	} else if (iscsi_cid >= qedi->max_active_conns) {
+		QEDI_ERR(&qedi->dbg_ctx, "wrong cid #%d\n", iscsi_cid);
+		return NULL;
+	}
+	return qedi->cid_que.conn_cid_tbl[iscsi_cid];
+}
+
+static int qedi_conn_bind(struct iscsi_cls_session *cls_session,
+			  struct iscsi_cls_conn *cls_conn,
+			  u64 transport_fd, int is_leading)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
+	struct qedi_ctx *qedi = iscsi_host_priv(shost);
+	struct qedi_endpoint *qedi_ep;
+	struct iscsi_endpoint *ep;
+
+	ep = iscsi_lookup_endpoint(transport_fd);
+	if (!ep)
+		return -EINVAL;
+
+	qedi_ep = ep->dd_data;
+	if ((qedi_ep->state == EP_STATE_TCP_FIN_RCVD) ||
+	    (qedi_ep->state == EP_STATE_TCP_RST_RCVD))
+		return -EINVAL;
+
+	if (iscsi_conn_bind(cls_session, cls_conn, is_leading))
+		return -EINVAL;
+
+	qedi_ep->conn = qedi_conn;
+	qedi_conn->ep = qedi_ep;
+	qedi_conn->iscsi_conn_id = qedi_ep->iscsi_cid;
+	qedi_conn->fw_cid = qedi_ep->fw_cid;
+	qedi_conn->cmd_cleanup_req = 0;
+	qedi_conn->cmd_cleanup_cmpl = 0;
+
+	if (qedi_bind_conn_to_iscsi_cid(qedi, qedi_conn))
+		return -EINVAL;
+
+	spin_lock_init(&qedi_conn->tmf_work_lock);
+	INIT_LIST_HEAD(&qedi_conn->tmf_work_list);
+	init_waitqueue_head(&qedi_conn->wait_queue);
+	return 0;
+}
+
+static int qedi_iscsi_update_conn(struct qedi_ctx *qedi,
+				  struct qedi_conn *qedi_conn)
+{
+	struct qed_iscsi_params_update *conn_info;
+	struct iscsi_cls_conn *cls_conn = qedi_conn->cls_conn;
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct qedi_endpoint *qedi_ep;
+	int rval;
+
+	qedi_ep = qedi_conn->ep;
+
+	conn_info = kzalloc(sizeof(*conn_info), GFP_KERNEL);
+	if (!conn_info) {
+		QEDI_ERR(&qedi->dbg_ctx, "memory alloc failed\n");
+		return -ENOMEM;
+	}
+
+	conn_info->update_flag = 0;
+
+	if (conn->hdrdgst_en)
+		SET_FIELD(conn_info->update_flag,
+			  ISCSI_CONN_UPDATE_RAMROD_PARAMS_HD_EN, true);
+	if (conn->datadgst_en)
+		SET_FIELD(conn_info->update_flag,
+			  ISCSI_CONN_UPDATE_RAMROD_PARAMS_DD_EN, true);
+	if (conn->session->initial_r2t_en)
+		SET_FIELD(conn_info->update_flag,
+			  ISCSI_CONN_UPDATE_RAMROD_PARAMS_INITIAL_R2T,
+			  true);
+	if (conn->session->imm_data_en)
+		SET_FIELD(conn_info->update_flag,
+			  ISCSI_CONN_UPDATE_RAMROD_PARAMS_IMMEDIATE_DATA,
+			  true);
+
+	conn_info->max_seq_size = conn->session->max_burst;
+	conn_info->max_recv_pdu_length = conn->max_recv_dlength;
+	conn_info->max_send_pdu_length = conn->max_xmit_dlength;
+	conn_info->first_seq_length = conn->session->first_burst;
+	conn_info->exp_stat_sn = conn->exp_statsn;
+
+	rval = qedi_ops->update_conn(qedi->cdev, qedi_ep->handle,
+				     conn_info);
+	if (rval) {
+		rval = -ENXIO;
+		QEDI_ERR(&qedi->dbg_ctx, "Could not update connection\n");
+		goto update_conn_err;
+	}
+
+	kfree(conn_info);
+	rval = 0;
+
+update_conn_err:
+	return rval;
+}
+
+static u16 qedi_calc_mss(u16 pmtu, u8 is_ipv6, u8 tcp_ts_en, u8 vlan_en)
+{
+	u16 mss = 0;
+	u16 hdrs = TCP_HDR_LEN;
+
+	if (is_ipv6)
+		hdrs += IPV6_HDR_LEN;
+	else
+		hdrs += IPV4_HDR_LEN;
+
+	if (vlan_en)
+		hdrs += VLAN_LEN;
+
+	mss = pmtu - hdrs;
+
+	if (tcp_ts_en)
+		mss -= TCP_OPTION_LEN;
+
+	if (!mss)
+		mss = DEF_MSS;
+
+	return mss;
+}
+
+static int qedi_iscsi_offload_conn(struct qedi_endpoint *qedi_ep)
+{
+	struct qedi_ctx *qedi = qedi_ep->qedi;
+	struct qed_iscsi_params_offload *conn_info;
+	int rval;
+	int i;
+
+	conn_info = kzalloc(sizeof(*conn_info), GFP_KERNEL);
+	if (!conn_info) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Failed to allocate memory ep=%p\n", qedi_ep);
+		return -ENOMEM;
+	}
+
+	ether_addr_copy(conn_info->src.mac, qedi_ep->src_mac);
+	ether_addr_copy(conn_info->dst.mac, qedi_ep->dst_mac);
+
+	conn_info->src.ip[0] = ntohl(qedi_ep->src_addr[0]);
+	conn_info->dst.ip[0] = ntohl(qedi_ep->dst_addr[0]);
+
+	if (qedi_ep->ip_type == TCP_IPV4) {
+		conn_info->ip_version = 0;
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "After ntohl: src_addr=%pI4, dst_addr=%pI4\n",
+			  qedi_ep->src_addr, qedi_ep->dst_addr);
+	} else {
+		for (i = 1; i < 4; i++) {
+			conn_info->src.ip[i] = ntohl(qedi_ep->src_addr[i]);
+			conn_info->dst.ip[i] = ntohl(qedi_ep->dst_addr[i]);
+		}
+
+		conn_info->ip_version = 1;
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "After ntohl: src_addr=%pI6, dst_addr=%pI6\n",
+			  qedi_ep->src_addr, qedi_ep->dst_addr);
+	}
+
+	conn_info->src.port = qedi_ep->src_port;
+	conn_info->dst.port = qedi_ep->dst_port;
+
+	conn_info->layer_code = ISCSI_SLOW_PATH_LAYER_CODE;
+	conn_info->sq_pbl_addr = qedi_ep->sq_pbl_dma;
+	conn_info->vlan_id = qedi_ep->vlan_id;
+
+	SET_FIELD(conn_info->tcp_flags, TCP_OFFLOAD_PARAMS_TS_EN, 1);
+	SET_FIELD(conn_info->tcp_flags, TCP_OFFLOAD_PARAMS_DA_EN, 1);
+	SET_FIELD(conn_info->tcp_flags, TCP_OFFLOAD_PARAMS_DA_CNT_EN, 1);
+	SET_FIELD(conn_info->tcp_flags, TCP_OFFLOAD_PARAMS_KA_EN, 1);
+
+	conn_info->default_cq = (qedi_ep->fw_cid % 8);
+
+	conn_info->ka_max_probe_cnt = DEF_KA_MAX_PROBE_COUNT;
+	conn_info->dup_ack_theshold = 3;
+	conn_info->rcv_wnd = 65535;
+	conn_info->cwnd = DEF_MAX_CWND;
+
+	conn_info->ss_thresh = 65535;
+	conn_info->srtt = 300;
+	conn_info->rtt_var = 150;
+	conn_info->flow_label = 0;
+	conn_info->ka_timeout = DEF_KA_TIMEOUT;
+	conn_info->ka_interval = DEF_KA_INTERVAL;
+	conn_info->max_rt_time = DEF_MAX_RT_TIME;
+	conn_info->ttl = DEF_TTL;
+	conn_info->tos_or_tc = DEF_TOS;
+	conn_info->remote_port = qedi_ep->dst_port;
+	conn_info->local_port = qedi_ep->src_port;
+
+	conn_info->mss = qedi_calc_mss(qedi_ep->pmtu,
+				       (qedi_ep->ip_type == TCP_IPV6),
+				       1, (qedi_ep->vlan_id != 0));
+
+	conn_info->rcv_wnd_scale = 4;
+	conn_info->ts_ticks_per_second = 1000;
+	conn_info->da_timeout_value = 200;
+	conn_info->ack_frequency = 2;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+		  "Default cq index [%d], mss [%d]\n",
+		  conn_info->default_cq, conn_info->mss);
+
+	rval = qedi_ops->offload_conn(qedi->cdev, qedi_ep->handle, conn_info);
+	if (rval)
+		QEDI_ERR(&qedi->dbg_ctx, "offload_conn returned %d, ep=%p\n",
+			 rval, qedi_ep);
+
+	kfree(conn_info);
+	return rval;
+}
+
+static int qedi_conn_start(struct iscsi_cls_conn *cls_conn)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct qedi_ctx *qedi;
+	int rval;
+
+	qedi = qedi_conn->qedi;
+
+	rval = qedi_iscsi_update_conn(qedi, qedi_conn);
+	if (rval) {
+		iscsi_conn_printk(KERN_ALERT, conn,
+				  "conn_start: FW oflload conn failed.\n");
+		rval = -EINVAL;
+		goto start_err;
+	}
+
+	clear_bit(QEDI_CONN_FW_CLEANUP, &qedi_conn->flags);
+	qedi_conn->abrt_conn = 0;
+
+	rval = iscsi_conn_start(cls_conn);
+	if (rval) {
+		iscsi_conn_printk(KERN_ALERT, conn,
+				  "iscsi_conn_start: FW oflload conn failed!!\n");
+	}
+
+start_err:
+	return rval;
+}
+
+static void qedi_conn_destroy(struct iscsi_cls_conn *cls_conn)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct Scsi_Host *shost;
+	struct qedi_ctx *qedi;
+
+	shost = iscsi_session_to_shost(iscsi_conn_to_session(cls_conn));
+	qedi = iscsi_host_priv(shost);
+
+	qedi_conn_free_login_resources(qedi, qedi_conn);
+	iscsi_conn_teardown(cls_conn);
+}
+
+static int qedi_ep_get_param(struct iscsi_endpoint *ep,
+			     enum iscsi_param param, char *buf)
+{
+	struct qedi_endpoint *qedi_ep = ep->dd_data;
+	int len;
+
+	if (!qedi_ep)
+		return -ENOTCONN;
+
+	switch (param) {
+	case ISCSI_PARAM_CONN_PORT:
+		len = sprintf(buf, "%hu\n", qedi_ep->dst_port);
+		break;
+	case ISCSI_PARAM_CONN_ADDRESS:
+		if (qedi_ep->ip_type == TCP_IPV4)
+			len = sprintf(buf, "%pI4\n", qedi_ep->dst_addr);
+		else
+			len = sprintf(buf, "%pI6\n", qedi_ep->dst_addr);
+		break;
+	default:
+		return -ENOTCONN;
+	}
+
+	return len;
+}
+
+static int qedi_host_get_param(struct Scsi_Host *shost,
+			       enum iscsi_host_param param, char *buf)
+{
+	struct qedi_ctx *qedi;
+	int len;
+
+	qedi = iscsi_host_priv(shost);
+
+	switch (param) {
+	case ISCSI_HOST_PARAM_HWADDRESS:
+		len = sysfs_format_mac(buf, qedi->mac, 6);
+		break;
+	case ISCSI_HOST_PARAM_NETDEV_NAME:
+		len = sprintf(buf, "host%d\n", shost->host_no);
+		break;
+	case ISCSI_HOST_PARAM_IPADDRESS:
+		if (qedi->ip_type == TCP_IPV4)
+			len = sprintf(buf, "%pI4\n", qedi->src_ip);
+		else
+			len = sprintf(buf, "%pI6\n", qedi->src_ip);
+		break;
+	default:
+		return iscsi_host_get_param(shost, param, buf);
+	}
+
+	return len;
+}
+
+static void qedi_conn_get_stats(struct iscsi_cls_conn *cls_conn,
+				struct iscsi_stats *stats)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct qed_iscsi_stats iscsi_stats;
+	struct Scsi_Host *shost;
+	struct qedi_ctx *qedi;
+
+	shost = iscsi_session_to_shost(iscsi_conn_to_session(cls_conn));
+	qedi = iscsi_host_priv(shost);
+	qedi_ops->get_stats(qedi->cdev, &iscsi_stats);
+
+	conn->txdata_octets = iscsi_stats.iscsi_tx_bytes_cnt;
+	conn->rxdata_octets = iscsi_stats.iscsi_rx_bytes_cnt;
+	conn->dataout_pdus_cnt = (uint32_t)iscsi_stats.iscsi_tx_data_pdu_cnt;
+	conn->datain_pdus_cnt = (uint32_t)iscsi_stats.iscsi_rx_data_pdu_cnt;
+	conn->r2t_pdus_cnt = (uint32_t)iscsi_stats.iscsi_rx_r2t_pdu_cnt;
+
+	stats->txdata_octets = conn->txdata_octets;
+	stats->rxdata_octets = conn->rxdata_octets;
+	stats->scsicmd_pdus = conn->scsicmd_pdus_cnt;
+	stats->dataout_pdus = conn->dataout_pdus_cnt;
+	stats->scsirsp_pdus = conn->scsirsp_pdus_cnt;
+	stats->datain_pdus = conn->datain_pdus_cnt;
+	stats->r2t_pdus = conn->r2t_pdus_cnt;
+	stats->tmfcmd_pdus = conn->tmfcmd_pdus_cnt;
+	stats->tmfrsp_pdus = conn->tmfrsp_pdus_cnt;
+	stats->digest_err = 0;
+	stats->timeout_err = 0;
+	strcpy(stats->custom[0].desc, "eh_abort_cnt");
+	stats->custom[0].value = conn->eh_abort_cnt;
+	stats->custom_length = 1;
+}
+
+static void qedi_iscsi_prep_generic_pdu_bd(struct qedi_conn *qedi_conn)
+{
+	struct iscsi_sge *bd_tbl;
+
+	bd_tbl = (struct iscsi_sge *)qedi_conn->gen_pdu.req_bd_tbl;
+
+	bd_tbl->sge_addr.hi =
+		(u32)((u64)qedi_conn->gen_pdu.req_dma_addr >> 32);
+	bd_tbl->sge_addr.lo = (u32)qedi_conn->gen_pdu.req_dma_addr;
+	bd_tbl->sge_len = qedi_conn->gen_pdu.req_wr_ptr -
+				qedi_conn->gen_pdu.req_buf;
+	bd_tbl->reserved0 = 0;
+	bd_tbl = (struct iscsi_sge  *)qedi_conn->gen_pdu.resp_bd_tbl;
+	bd_tbl->sge_addr.hi =
+			(u32)((u64)qedi_conn->gen_pdu.resp_dma_addr >> 32);
+	bd_tbl->sge_addr.lo = (u32)qedi_conn->gen_pdu.resp_dma_addr;
+	bd_tbl->sge_len = ISCSI_DEF_MAX_RECV_SEG_LEN;
+	bd_tbl->reserved0 = 0;
+}
+
+static int qedi_iscsi_send_generic_request(struct iscsi_task *task)
+{
+	struct qedi_cmd *cmd = task->dd_data;
+	struct qedi_conn *qedi_conn = cmd->conn;
+	char *buf;
+	int data_len;
+	int rc = 0;
+
+	qedi_iscsi_prep_generic_pdu_bd(qedi_conn);
+	switch (task->hdr->opcode & ISCSI_OPCODE_MASK) {
+	case ISCSI_OP_LOGIN:
+		qedi_send_iscsi_login(qedi_conn, task);
+		break;
+	case ISCSI_OP_NOOP_OUT:
+		data_len = qedi_conn->gen_pdu.req_buf_size;
+		buf = qedi_conn->gen_pdu.req_buf;
+		if (data_len)
+			rc = qedi_send_iscsi_nopout(qedi_conn, task,
+						    buf, data_len, 1);
+		else
+			rc = qedi_send_iscsi_nopout(qedi_conn, task,
+						    NULL, 0, 1);
+		break;
+	case ISCSI_OP_LOGOUT:
+		rc = qedi_send_iscsi_logout(qedi_conn, task);
+		break;
+	case ISCSI_OP_SCSI_TMFUNC:
+		rc = qedi_iscsi_abort_work(qedi_conn, task);
+		break;
+	case ISCSI_OP_TEXT:
+		rc = qedi_send_iscsi_text(qedi_conn, task);
+		break;
+	default:
+		iscsi_conn_printk(KERN_ALERT, qedi_conn->cls_conn->dd_data,
+				  "unsupported op 0x%x\n", task->hdr->opcode);
+	}
+
+	return rc;
+}
+
+static int qedi_mtask_xmit(struct iscsi_conn *conn, struct iscsi_task *task)
+{
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct qedi_cmd *cmd = task->dd_data;
+
+	memset(qedi_conn->gen_pdu.req_buf, 0, ISCSI_DEF_MAX_RECV_SEG_LEN);
+
+	qedi_conn->gen_pdu.req_buf_size = task->data_count;
+
+	if (task->data_count) {
+		memcpy(qedi_conn->gen_pdu.req_buf, task->data,
+		       task->data_count);
+		qedi_conn->gen_pdu.req_wr_ptr =
+			qedi_conn->gen_pdu.req_buf + task->data_count;
+	}
+
+	cmd->conn = conn->dd_data;
+	cmd->scsi_cmd = NULL;
+	return qedi_iscsi_send_generic_request(task);
+}
+
+static int qedi_task_xmit(struct iscsi_task *task)
+{
+	struct iscsi_conn *conn = task->conn;
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct qedi_cmd *cmd = task->dd_data;
+	struct scsi_cmnd *sc = task->sc;
+
+	cmd->state = 0;
+	cmd->task = NULL;
+	cmd->use_slowpath = false;
+	cmd->conn = qedi_conn;
+	cmd->task = task;
+	cmd->io_cmd_in_list = false;
+	INIT_LIST_HEAD(&cmd->io_cmd);
+
+	if (!sc)
+		return qedi_mtask_xmit(conn, task);
+
+	cmd->scsi_cmd = sc;
+	return qedi_iscsi_send_ioreq(task);
+}
+
+static struct iscsi_endpoint *
+qedi_ep_connect(struct Scsi_Host *shost, struct sockaddr *dst_addr,
+		int non_blocking)
+{
+	struct qedi_ctx *qedi;
+	struct iscsi_endpoint *ep;
+	struct qedi_endpoint *qedi_ep;
+	struct sockaddr_in *addr;
+	struct sockaddr_in6 *addr6;
+	struct qed_dev *cdev  =  NULL;
+	struct qedi_uio_dev *udev = NULL;
+	struct iscsi_path path_req;
+	u32 msg_type = ISCSI_KEVENT_IF_DOWN;
+	u32 iscsi_cid = QEDI_CID_RESERVED;
+	u16 len = 0;
+	char *buf = NULL;
+	int ret;
+
+	if (!shost) {
+		ret = -ENXIO;
+		QEDI_ERR(NULL, "shost is NULL\n");
+		return ERR_PTR(ret);
+	}
+
+	if (do_not_recover) {
+		ret = -ENOMEM;
+		return ERR_PTR(ret);
+	}
+
+	qedi = iscsi_host_priv(shost);
+	cdev = qedi->cdev;
+	udev = qedi->udev;
+
+	if (test_bit(QEDI_IN_OFFLINE, &qedi->flags) ||
+	    test_bit(QEDI_IN_RECOVERY, &qedi->flags)) {
+		ret = -ENOMEM;
+		return ERR_PTR(ret);
+	}
+
+	ep = iscsi_create_endpoint(sizeof(struct qedi_endpoint));
+	if (!ep) {
+		QEDI_ERR(&qedi->dbg_ctx, "endpoint create fail\n");
+		ret = -ENOMEM;
+		return ERR_PTR(ret);
+	}
+	qedi_ep = ep->dd_data;
+	memset(qedi_ep, 0, sizeof(struct qedi_endpoint));
+	qedi_ep->state = EP_STATE_IDLE;
+	qedi_ep->iscsi_cid = (u32)-1;
+	qedi_ep->qedi = qedi;
+
+	if (dst_addr->sa_family == AF_INET) {
+		addr = (struct sockaddr_in *)dst_addr;
+		memcpy(qedi_ep->dst_addr, &addr->sin_addr.s_addr,
+		       sizeof(struct in_addr));
+		qedi_ep->dst_port = ntohs(addr->sin_port);
+		qedi_ep->ip_type = TCP_IPV4;
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "dst_addr=%pI4, dst_port=%u\n",
+			  qedi_ep->dst_addr, qedi_ep->dst_port);
+	} else if (dst_addr->sa_family == AF_INET6) {
+		addr6 = (struct sockaddr_in6 *)dst_addr;
+		memcpy(qedi_ep->dst_addr, &addr6->sin6_addr,
+		       sizeof(struct in6_addr));
+		qedi_ep->dst_port = ntohs(addr6->sin6_port);
+		qedi_ep->ip_type = TCP_IPV6;
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "dst_addr=%pI6, dst_port=%u\n",
+			  qedi_ep->dst_addr, qedi_ep->dst_port);
+	} else {
+		QEDI_ERR(&qedi->dbg_ctx, "Invalid endpoint\n");
+	}
+
+	if (atomic_read(&qedi->link_state) != QEDI_LINK_UP) {
+		QEDI_WARN(&qedi->dbg_ctx, "qedi link down\n");
+		ret = -ENXIO;
+		goto ep_conn_exit;
+	}
+
+	ret = qedi_alloc_sq(qedi, qedi_ep);
+	if (ret)
+		goto ep_conn_exit;
+
+	ret = qedi_ops->acquire_conn(qedi->cdev, &qedi_ep->handle,
+				     &qedi_ep->fw_cid, &qedi_ep->p_doorbell);
+
+	if (ret) {
+		QEDI_ERR(&qedi->dbg_ctx, "Could not acquire connection\n");
+		ret = -ENXIO;
+		goto ep_free_sq;
+	}
+
+	iscsi_cid = qedi_ep->handle;
+	qedi_ep->iscsi_cid = iscsi_cid;
+
+	init_waitqueue_head(&qedi_ep->ofld_wait);
+	init_waitqueue_head(&qedi_ep->tcp_ofld_wait);
+	qedi_ep->state = EP_STATE_OFLDCONN_START;
+	qedi->ep_tbl[iscsi_cid] = qedi_ep;
+
+	buf = (char *)&path_req;
+	len = sizeof(path_req);
+	memset(&path_req, 0, len);
+
+	msg_type = ISCSI_KEVENT_PATH_REQ;
+	path_req.handle = (u64)qedi_ep->iscsi_cid;
+	path_req.pmtu = qedi->ll2_mtu;
+	qedi_ep->pmtu = qedi->ll2_mtu;
+	if (qedi_ep->ip_type == TCP_IPV4) {
+		memcpy(&path_req.dst.v4_addr, &qedi_ep->dst_addr,
+		       sizeof(struct in_addr));
+		path_req.ip_addr_len = 4;
+	} else {
+		memcpy(&path_req.dst.v6_addr, &qedi_ep->dst_addr,
+		       sizeof(struct in6_addr));
+		path_req.ip_addr_len = 16;
+	}
+
+	ret = iscsi_offload_mesg(shost, &qedi_iscsi_transport, msg_type, buf,
+				 len);
+	if (ret) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "iscsi_offload_mesg() failed for cid=0x%x ret=%d\n",
+			 iscsi_cid, ret);
+		goto ep_rel_conn;
+	}
+
+	atomic_inc(&qedi->num_offloads);
+	return ep;
+
+ep_rel_conn:
+	qedi->ep_tbl[iscsi_cid] = NULL;
+	ret = qedi_ops->release_conn(qedi->cdev, qedi_ep->handle);
+	if (ret)
+		QEDI_WARN(&qedi->dbg_ctx, "release_conn returned %d\n",
+			  ret);
+ep_free_sq:
+	qedi_free_sq(qedi, qedi_ep);
+ep_conn_exit:
+	iscsi_destroy_endpoint(ep);
+	return ERR_PTR(ret);
+}
+
+static int qedi_ep_poll(struct iscsi_endpoint *ep, int timeout_ms)
+{
+	struct qedi_endpoint *qedi_ep;
+	int ret = 0;
+
+	if (do_not_recover)
+		return 1;
+
+	qedi_ep = ep->dd_data;
+	if (qedi_ep->state == EP_STATE_IDLE ||
+	    qedi_ep->state == EP_STATE_OFLDCONN_FAILED)
+		return -1;
+
+	if (qedi_ep->state == EP_STATE_OFLDCONN_COMPL)
+		ret = 1;
+
+	ret = wait_event_interruptible_timeout(qedi_ep->ofld_wait,
+					       QEDI_OFLD_WAIT_STATE(qedi_ep),
+					       msecs_to_jiffies(timeout_ms));
+
+	if (qedi_ep->state == EP_STATE_OFLDCONN_FAILED)
+		ret = -1;
+
+	if (ret > 0)
+		return 1;
+	else if (!ret)
+		return 0;
+	else
+		return ret;
+}
+
+static void qedi_cleanup_active_cmd_list(struct qedi_conn *qedi_conn)
+{
+	struct qedi_cmd *cmd, *cmd_tmp;
+
+	list_for_each_entry_safe(cmd, cmd_tmp, &qedi_conn->active_cmd_list,
+				 io_cmd) {
+		list_del_init(&cmd->io_cmd);
+		qedi_conn->active_cmd_count--;
+	}
+}
+
+static void qedi_ep_disconnect(struct iscsi_endpoint *ep)
+{
+	struct qedi_endpoint *qedi_ep;
+	struct qedi_conn *qedi_conn = NULL;
+	struct iscsi_conn *conn = NULL;
+	struct qedi_ctx *qedi;
+	int ret = 0;
+	int wait_delay = 20 * HZ;
+	int abrt_conn = 0;
+	int count = 10;
+
+	qedi_ep = ep->dd_data;
+	qedi = qedi_ep->qedi;
+
+	flush_work(&qedi_ep->offload_work);
+
+	if (qedi_ep->conn) {
+		qedi_conn = qedi_ep->conn;
+		conn = qedi_conn->cls_conn->dd_data;
+		iscsi_suspend_queue(conn);
+		abrt_conn = qedi_conn->abrt_conn;
+
+		while (count--)	{
+			if (!test_bit(QEDI_CONN_FW_CLEANUP,
+				      &qedi_conn->flags)) {
+				break;
+			}
+			msleep(1000);
+		}
+
+		if (test_bit(QEDI_IN_RECOVERY, &qedi->flags)) {
+			if (do_not_recover) {
+				QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+					  "Do not recover cid=0x%x\n",
+					  qedi_ep->iscsi_cid);
+				goto ep_exit_recover;
+			}
+			QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+				  "Reset recovery cid=0x%x, qedi_ep=%p, state=0x%x\n",
+				  qedi_ep->iscsi_cid, qedi_ep, qedi_ep->state);
+			qedi_cleanup_active_cmd_list(qedi_conn);
+			goto ep_release_conn;
+		}
+	}
+
+	if (do_not_recover)
+		goto ep_exit_recover;
+
+	switch (qedi_ep->state) {
+	case EP_STATE_OFLDCONN_START:
+		goto ep_release_conn;
+	case EP_STATE_OFLDCONN_FAILED:
+			break;
+	case EP_STATE_OFLDCONN_COMPL:
+		if (unlikely(!qedi_conn))
+			break;
+
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+			  "Active cmd count=%d, abrt_conn=%d, ep state=0x%x, cid=0x%x, qedi_conn=%p\n",
+			  qedi_conn->active_cmd_count, abrt_conn,
+			  qedi_ep->state,
+			  qedi_ep->iscsi_cid,
+			  qedi_ep->conn
+			  );
+
+		if (!qedi_conn->active_cmd_count)
+			abrt_conn = 0;
+		else
+			abrt_conn = 1;
+
+		if (abrt_conn)
+			qedi_clearsq(qedi, qedi_conn, NULL);
+		break;
+	default:
+		break;
+	}
+
+	qedi_ep->state = EP_STATE_DISCONN_START;
+	ret = qedi_ops->destroy_conn(qedi->cdev, qedi_ep->handle, abrt_conn);
+	if (ret) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "destroy_conn failed returned %d\n", ret);
+	} else {
+		ret = wait_event_interruptible_timeout(
+					qedi_ep->tcp_ofld_wait,
+					(qedi_ep->state !=
+					 EP_STATE_DISCONN_START),
+					wait_delay);
+		if ((ret <= 0) || (qedi_ep->state == EP_STATE_DISCONN_START)) {
+			QEDI_WARN(&qedi->dbg_ctx,
+				  "Destroy conn timedout or interrupted, ret=%d, delay=%d, cid=0x%x\n",
+				  ret, wait_delay, qedi_ep->iscsi_cid);
+		}
+	}
+
+ep_release_conn:
+	ret = qedi_ops->release_conn(qedi->cdev, qedi_ep->handle);
+	if (ret)
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "release_conn returned %d, cid=0x%x\n",
+			  ret, qedi_ep->iscsi_cid);
+ep_exit_recover:
+	qedi_ep->state = EP_STATE_IDLE;
+	qedi->ep_tbl[qedi_ep->iscsi_cid] = NULL;
+	qedi->cid_que.conn_cid_tbl[qedi_ep->iscsi_cid] = NULL;
+	qedi_free_id(&qedi->lcl_port_tbl, qedi_ep->src_port);
+	qedi_free_sq(qedi, qedi_ep);
+
+	if (qedi_conn)
+		qedi_conn->ep = NULL;
+
+	qedi_ep->conn = NULL;
+	qedi_ep->qedi = NULL;
+	atomic_dec(&qedi->num_offloads);
+
+	iscsi_destroy_endpoint(ep);
+}
+
+static int qedi_data_avail(struct qedi_ctx *qedi, u16 vlanid)
+{
+	struct qed_dev *cdev = qedi->cdev;
+	struct qedi_uio_dev *udev;
+	struct qedi_uio_ctrl *uctrl;
+	struct sk_buff *skb;
+	u32 len;
+	int rc = 0;
+
+	udev = qedi->udev;
+	if (!udev) {
+		QEDI_ERR(&qedi->dbg_ctx, "udev is NULL.\n");
+		return -EINVAL;
+	}
+
+	uctrl = (struct qedi_uio_ctrl *)udev->uctrl;
+	if (!uctrl) {
+		QEDI_ERR(&qedi->dbg_ctx, "uctlr is NULL.\n");
+		return -EINVAL;
+	}
+
+	len = uctrl->host_tx_pkt_len;
+	if (!len) {
+		QEDI_ERR(&qedi->dbg_ctx, "Invalid len %u\n", len);
+		return -EINVAL;
+	}
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (!skb) {
+		QEDI_ERR(&qedi->dbg_ctx, "alloc_skb failed\n");
+		return -EINVAL;
+	}
+
+	skb_put(skb, len);
+	memcpy(skb->data, udev->tx_pkt, len);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	if (vlanid)
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlanid);
+
+	rc = qedi_ops->ll2->start_xmit(cdev, skb);
+	if (rc) {
+		QEDI_ERR(&qedi->dbg_ctx, "ll2 start_xmit returned %d\n",
+			 rc);
+		kfree_skb(skb);
+	}
+
+	uctrl->host_tx_pkt_len = 0;
+	uctrl->hw_tx_cons++;
+
+	return rc;
+}
+
+static void qedi_offload_work(struct work_struct *work)
+{
+	struct qedi_endpoint *qedi_ep =
+		container_of(work, struct qedi_endpoint, offload_work);
+	struct qedi_ctx *qedi;
+	int wait_delay = 20 * HZ;
+	int ret;
+
+	qedi = qedi_ep->qedi;
+
+	ret = qedi_iscsi_offload_conn(qedi_ep);
+	if (ret) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "offload error: iscsi_cid=%u, qedi_ep=%p, ret=%d\n",
+			 qedi_ep->iscsi_cid, qedi_ep, ret);
+		qedi_ep->state = EP_STATE_OFLDCONN_FAILED;
+		return;
+	}
+
+	ret = wait_event_interruptible_timeout(qedi_ep->tcp_ofld_wait,
+					       (qedi_ep->state ==
+					       EP_STATE_OFLDCONN_COMPL),
+					       wait_delay);
+	if ((ret <= 0) || (qedi_ep->state != EP_STATE_OFLDCONN_COMPL)) {
+		qedi_ep->state = EP_STATE_OFLDCONN_FAILED;
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Offload conn TIMEOUT iscsi_cid=%u, qedi_ep=%p\n",
+			 qedi_ep->iscsi_cid, qedi_ep);
+	}
+}
+
+static int qedi_set_path(struct Scsi_Host *shost, struct iscsi_path *path_data)
+{
+	struct qedi_ctx *qedi;
+	struct qedi_endpoint *qedi_ep;
+	int ret = 0;
+	u32 iscsi_cid;
+	u16 port_id = 0;
+
+	if (!shost) {
+		ret = -ENXIO;
+		QEDI_ERR(NULL, "shost is NULL\n");
+		return ret;
+	}
+
+	if (strcmp(shost->hostt->proc_name, "qedi")) {
+		ret = -ENXIO;
+		QEDI_ERR(NULL, "shost %s is invalid\n",
+			 shost->hostt->proc_name);
+		return ret;
+	}
+
+	qedi = iscsi_host_priv(shost);
+	if (path_data->handle == QEDI_PATH_HANDLE) {
+		ret = qedi_data_avail(qedi, path_data->vlan_id);
+		goto set_path_exit;
+	}
+
+	iscsi_cid = (u32)path_data->handle;
+	qedi_ep = qedi->ep_tbl[iscsi_cid];
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "iscsi_cid=0x%x, qedi_ep=%p\n", iscsi_cid, qedi_ep);
+
+	if (!is_valid_ether_addr(&path_data->mac_addr[0])) {
+		QEDI_NOTICE(&qedi->dbg_ctx, "dst mac NOT VALID\n");
+		ret = -EIO;
+		goto set_path_exit;
+	}
+
+	ether_addr_copy(&qedi_ep->src_mac[0], &qedi->mac[0]);
+	ether_addr_copy(&qedi_ep->dst_mac[0], &path_data->mac_addr[0]);
+
+	qedi_ep->vlan_id = path_data->vlan_id;
+	if (path_data->pmtu < DEF_PATH_MTU) {
+		qedi_ep->pmtu = qedi->ll2_mtu;
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+			  "MTU cannot be %u, using default MTU %u\n",
+			   path_data->pmtu, qedi_ep->pmtu);
+	}
+
+	if (path_data->pmtu != qedi->ll2_mtu) {
+		if (path_data->pmtu > JUMBO_MTU) {
+			ret = -EINVAL;
+			QEDI_ERR(NULL, "Invalid MTU %u\n", path_data->pmtu);
+			goto set_path_exit;
+		}
+
+		qedi_reset_host_mtu(qedi, path_data->pmtu);
+		qedi_ep->pmtu = qedi->ll2_mtu;
+	}
+
+	port_id = qedi_ep->src_port;
+	if (port_id >= QEDI_LOCAL_PORT_MIN &&
+	    port_id < QEDI_LOCAL_PORT_MAX) {
+		if (qedi_alloc_id(&qedi->lcl_port_tbl, port_id))
+			port_id = 0;
+	} else {
+		port_id = 0;
+	}
+
+	if (!port_id) {
+		port_id = qedi_alloc_new_id(&qedi->lcl_port_tbl);
+		if (port_id == QEDI_LOCAL_PORT_INVALID) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "Failed to allocate port id for iscsi_cid=0x%x\n",
+				 iscsi_cid);
+			ret = -ENOMEM;
+			goto set_path_exit;
+		}
+	}
+
+	qedi_ep->src_port = port_id;
+
+	if (qedi_ep->ip_type == TCP_IPV4) {
+		memcpy(&qedi_ep->src_addr[0], &path_data->src.v4_addr,
+		       sizeof(struct in_addr));
+		memcpy(&qedi->src_ip[0], &path_data->src.v4_addr,
+		       sizeof(struct in_addr));
+		qedi->ip_type = TCP_IPV4;
+
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "src addr:port=%pI4:%u, dst addr:port=%pI4:%u\n",
+			  qedi_ep->src_addr, qedi_ep->src_port,
+			  qedi_ep->dst_addr, qedi_ep->dst_port);
+	} else {
+		memcpy(&qedi_ep->src_addr[0], &path_data->src.v6_addr,
+		       sizeof(struct in6_addr));
+		memcpy(&qedi->src_ip[0], &path_data->src.v6_addr,
+		       sizeof(struct in6_addr));
+		qedi->ip_type = TCP_IPV6;
+
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "src addr:port=%pI6:%u, dst addr:port=%pI6:%u\n",
+			  qedi_ep->src_addr, qedi_ep->src_port,
+			  qedi_ep->dst_addr, qedi_ep->dst_port);
+	}
+
+	INIT_WORK(&qedi_ep->offload_work, qedi_offload_work);
+	queue_work(qedi->offload_thread, &qedi_ep->offload_work);
+
+	ret = 0;
+
+set_path_exit:
+	return ret;
+}
+
+static umode_t qedi_attr_is_visible(int param_type, int param)
+{
+	switch (param_type) {
+	case ISCSI_HOST_PARAM:
+		switch (param) {
+		case ISCSI_HOST_PARAM_NETDEV_NAME:
+		case ISCSI_HOST_PARAM_HWADDRESS:
+		case ISCSI_HOST_PARAM_IPADDRESS:
+			return 0444;
+		default:
+			return 0;
+		}
+	case ISCSI_PARAM:
+		switch (param) {
+		case ISCSI_PARAM_MAX_RECV_DLENGTH:
+		case ISCSI_PARAM_MAX_XMIT_DLENGTH:
+		case ISCSI_PARAM_HDRDGST_EN:
+		case ISCSI_PARAM_DATADGST_EN:
+		case ISCSI_PARAM_CONN_ADDRESS:
+		case ISCSI_PARAM_CONN_PORT:
+		case ISCSI_PARAM_EXP_STATSN:
+		case ISCSI_PARAM_PERSISTENT_ADDRESS:
+		case ISCSI_PARAM_PERSISTENT_PORT:
+		case ISCSI_PARAM_PING_TMO:
+		case ISCSI_PARAM_RECV_TMO:
+		case ISCSI_PARAM_INITIAL_R2T_EN:
+		case ISCSI_PARAM_MAX_R2T:
+		case ISCSI_PARAM_IMM_DATA_EN:
+		case ISCSI_PARAM_FIRST_BURST:
+		case ISCSI_PARAM_MAX_BURST:
+		case ISCSI_PARAM_PDU_INORDER_EN:
+		case ISCSI_PARAM_DATASEQ_INORDER_EN:
+		case ISCSI_PARAM_ERL:
+		case ISCSI_PARAM_TARGET_NAME:
+		case ISCSI_PARAM_TPGT:
+		case ISCSI_PARAM_USERNAME:
+		case ISCSI_PARAM_PASSWORD:
+		case ISCSI_PARAM_USERNAME_IN:
+		case ISCSI_PARAM_PASSWORD_IN:
+		case ISCSI_PARAM_FAST_ABORT:
+		case ISCSI_PARAM_ABORT_TMO:
+		case ISCSI_PARAM_LU_RESET_TMO:
+		case ISCSI_PARAM_TGT_RESET_TMO:
+		case ISCSI_PARAM_IFACE_NAME:
+		case ISCSI_PARAM_INITIATOR_NAME:
+		case ISCSI_PARAM_BOOT_ROOT:
+		case ISCSI_PARAM_BOOT_NIC:
+		case ISCSI_PARAM_BOOT_TARGET:
+			return 0444;
+		default:
+			return 0;
+		}
+	}
+
+	return 0;
+}
+
+static void qedi_cleanup_task(struct iscsi_task *task)
+{
+	if (!task->sc || task->state == ISCSI_TASK_PENDING) {
+		QEDI_INFO(NULL, QEDI_LOG_IO, "Returning ref_cnt=%d\n",
+			  atomic_read(&task->refcount));
+		return;
+	}
+
+	qedi_iscsi_unmap_sg_list(task->dd_data);
+}
+
+struct iscsi_transport qedi_iscsi_transport = {
+	.owner = THIS_MODULE,
+	.name = QEDI_MODULE_NAME,
+	.caps = CAP_RECOVERY_L0 | CAP_HDRDGST | CAP_MULTI_R2T | CAP_DATADGST |
+		CAP_DATA_PATH_OFFLOAD | CAP_TEXT_NEGO,
+	.create_session = qedi_session_create,
+	.destroy_session = qedi_session_destroy,
+	.create_conn = qedi_conn_create,
+	.bind_conn = qedi_conn_bind,
+	.start_conn = qedi_conn_start,
+	.stop_conn = iscsi_conn_stop,
+	.destroy_conn = qedi_conn_destroy,
+	.set_param = iscsi_set_param,
+	.get_ep_param = qedi_ep_get_param,
+	.get_conn_param = iscsi_conn_get_param,
+	.get_session_param = iscsi_session_get_param,
+	.get_host_param = qedi_host_get_param,
+	.send_pdu = iscsi_conn_send_pdu,
+	.get_stats = qedi_conn_get_stats,
+	.xmit_task = qedi_task_xmit,
+	.cleanup_task = qedi_cleanup_task,
+	.session_recovery_timedout = iscsi_session_recovery_timedout,
+	.ep_connect = qedi_ep_connect,
+	.ep_poll = qedi_ep_poll,
+	.ep_disconnect = qedi_ep_disconnect,
+	.set_path = qedi_set_path,
+	.attr_is_visible = qedi_attr_is_visible,
+};
+
+void qedi_start_conn_recovery(struct qedi_ctx *qedi,
+			      struct qedi_conn *qedi_conn)
+{
+	struct iscsi_cls_session *cls_sess;
+	struct iscsi_cls_conn *cls_conn;
+	struct iscsi_conn *conn;
+
+	cls_conn = qedi_conn->cls_conn;
+	conn = cls_conn->dd_data;
+	cls_sess = iscsi_conn_to_session(cls_conn);
+
+	if (iscsi_is_session_online(cls_sess)) {
+		qedi_conn->abrt_conn = 1;
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Failing connection, state=0x%x, cid=0x%x\n",
+			 conn->session->state, qedi_conn->iscsi_conn_id);
+		iscsi_conn_failure(qedi_conn->cls_conn->dd_data,
+				   ISCSI_ERR_CONN_FAILED);
+	}
+}
+
+static const struct {
+	enum iscsi_error_types error_code;
+	char *err_string;
+} qedi_iscsi_error[] = {
+	{ ISCSI_STATUS_NONE,
+	  "tcp_error none"
+	},
+	{ ISCSI_CONN_ERROR_TASK_CID_MISMATCH,
+	  "task cid mismatch"
+	},
+	{ ISCSI_CONN_ERROR_TASK_NOT_VALID,
+	  "invalid task"
+	},
+	{ ISCSI_CONN_ERROR_RQ_RING_IS_FULL,
+	  "rq ring full"
+	},
+	{ ISCSI_CONN_ERROR_CMDQ_RING_IS_FULL,
+	  "cmdq ring full"
+	},
+	{ ISCSI_CONN_ERROR_HQE_CACHING_FAILED,
+	  "sge caching failed"
+	},
+	{ ISCSI_CONN_ERROR_HEADER_DIGEST_ERROR,
+	  "hdr digest error"
+	},
+	{ ISCSI_CONN_ERROR_LOCAL_COMPLETION_ERROR,
+	  "local cmpl error"
+	},
+	{ ISCSI_CONN_ERROR_DATA_OVERRUN,
+	  "invalid task"
+	},
+	{ ISCSI_CONN_ERROR_OUT_OF_SGES_ERROR,
+	  "out of sge error"
+	},
+	{ ISCSI_CONN_ERROR_TCP_SEG_PROC_IP_OPTIONS_ERROR,
+	  "tcp seg ip options error"
+	},
+	{ ISCSI_CONN_ERROR_TCP_IP_FRAGMENT_ERROR,
+	  "tcp ip fragment error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_AHS_LEN,
+	  "AHS len protocol error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_ITT_OUT_OF_RANGE,
+	  "itt out of range error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DATA_SEG_LEN_EXCEEDS_PDU_SIZE,
+	  "data seg more than pdu size"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_INVALID_OPCODE,
+	  "invalid opcode"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_INVALID_OPCODE_BEFORE_UPDATE,
+	  "invalid opcode before update"
+	},
+	{ ISCSI_CONN_ERROR_UNVALID_NOPIN_DSL,
+	  "unexpected opcode"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_R2T_CARRIES_NO_DATA,
+	  "r2t carries no data"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DATA_SN,
+	  "data sn error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DATA_IN_TTT,
+	  "data TTT error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_R2T_TTT,
+	  "r2t TTT error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_R2T_BUFFER_OFFSET,
+	  "buffer offset error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_BUFFER_OFFSET_OOO,
+	  "buffer offset ooo"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_R2T_SN,
+	  "data seg len 0"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DESIRED_DATA_TRNS_LEN_0,
+	  "data xer len error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DESIRED_DATA_TRNS_LEN_1,
+	  "data xer len1 error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DESIRED_DATA_TRNS_LEN_2,
+	  "data xer len2 error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_LUN,
+	  "protocol lun error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_F_BIT_ZERO,
+	  "f bit zero error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_EXP_STAT_SN,
+	  "exp stat sn error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DSL_NOT_ZERO,
+	  "dsl not zero error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_INVALID_DSL,
+	  "invalid dsl"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DATA_SEG_LEN_TOO_BIG,
+	  "data seg len too big"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_OUTSTANDING_R2T_COUNT,
+	  "outstanding r2t count error"
+	},
+	{ ISCSI_CONN_ERROR_SENSE_DATA_LENGTH,
+	  "sense datalen error"
+	},
+};
+
+char *qedi_get_iscsi_error(enum iscsi_error_types err_code)
+{
+	int i;
+	char *msg = NULL;
+
+	for (i = 0; i < ARRAY_SIZE(qedi_iscsi_error); i++) {
+		if (qedi_iscsi_error[i].error_code == err_code) {
+			msg = qedi_iscsi_error[i].err_string;
+			break;
+		}
+	}
+	return msg;
+}
+
+void qedi_process_iscsi_error(struct qedi_endpoint *ep, struct async_data *data)
+{
+	struct qedi_conn *qedi_conn;
+	struct qedi_ctx *qedi;
+	char warn_notice[] = "iscsi_warning";
+	char error_notice[] = "iscsi_error";
+	char unknown_msg[] = "Unknown error";
+	char *message;
+	int need_recovery = 0;
+	u32 err_mask = 0;
+	char *msg;
+
+	if (!ep)
+		return;
+
+	qedi_conn = ep->conn;
+	if (!qedi_conn)
+		return;
+
+	qedi = ep->qedi;
+
+	QEDI_ERR(&qedi->dbg_ctx, "async event iscsi error:0x%x\n",
+		 data->error_code);
+
+	if (err_mask) {
+		need_recovery = 0;
+		message = warn_notice;
+	} else {
+		need_recovery = 1;
+		message = error_notice;
+	}
+
+	msg = qedi_get_iscsi_error(data->error_code);
+	if (!msg) {
+		need_recovery = 0;
+		msg = unknown_msg;
+	}
+
+	iscsi_conn_printk(KERN_ALERT,
+			  qedi_conn->cls_conn->dd_data,
+			  "qedi: %s - %s\n", message, msg);
+
+	if (need_recovery)
+		qedi_start_conn_recovery(qedi_conn->qedi, qedi_conn);
+}
+
+void qedi_process_tcp_error(struct qedi_endpoint *ep, struct async_data *data)
+{
+	struct qedi_conn *qedi_conn;
+
+	if (!ep)
+		return;
+
+	qedi_conn = ep->conn;
+	if (!qedi_conn)
+		return;
+
+	QEDI_ERR(&ep->qedi->dbg_ctx, "async event TCP error:0x%x\n",
+		 data->error_code);
+
+	qedi_start_conn_recovery(qedi_conn->qedi, qedi_conn);
+}
diff --git a/drivers/scsi/qedi/qedi_iscsi.h b/drivers/scsi/qedi/qedi_iscsi.h
new file mode 100644
index 0000000..d3c06bb
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_iscsi.h
@@ -0,0 +1,232 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QEDI_ISCSI_H_
+#define _QEDI_ISCSI_H_
+
+#include <linux/socket.h>
+#include <linux/completion.h>
+#include "qedi.h"
+
+#define ISCSI_MAX_SESS_PER_HBA	4096
+
+#define DEF_KA_TIMEOUT		7200000
+#define DEF_KA_INTERVAL		10000
+#define DEF_KA_MAX_PROBE_COUNT	10
+#define DEF_TOS			0
+#define DEF_TTL			0xfe
+#define DEF_SND_SEQ_SCALE	0
+#define DEF_RCV_BUF		0xffff
+#define DEF_SND_BUF		0xffff
+#define DEF_SEED		0
+#define DEF_MAX_RT_TIME		8000
+#define DEF_MAX_DA_COUNT        2
+#define DEF_SWS_TIMER		1000
+#define DEF_MAX_CWND		2
+#define DEF_PATH_MTU		1500
+#define DEF_MSS			1460
+#define DEF_LL2_MTU		1560
+#define JUMBO_MTU		9000
+
+#define MIN_MTU         576 /* rfc 793 */
+#define IPV4_HDR_LEN    20
+#define IPV6_HDR_LEN    40
+#define TCP_HDR_LEN     20
+#define TCP_OPTION_LEN  12
+#define VLAN_LEN         4
+
+enum {
+	EP_STATE_IDLE                   = 0x0,
+	EP_STATE_ACQRCONN_START         = 0x1,
+	EP_STATE_ACQRCONN_COMPL         = 0x2,
+	EP_STATE_OFLDCONN_START         = 0x4,
+	EP_STATE_OFLDCONN_COMPL         = 0x8,
+	EP_STATE_DISCONN_START          = 0x10,
+	EP_STATE_DISCONN_COMPL          = 0x20,
+	EP_STATE_CLEANUP_START          = 0x40,
+	EP_STATE_CLEANUP_CMPL           = 0x80,
+	EP_STATE_TCP_FIN_RCVD           = 0x100,
+	EP_STATE_TCP_RST_RCVD           = 0x200,
+	EP_STATE_LOGOUT_SENT            = 0x400,
+	EP_STATE_LOGOUT_RESP_RCVD       = 0x800,
+	EP_STATE_CLEANUP_FAILED         = 0x1000,
+	EP_STATE_OFLDCONN_FAILED        = 0x2000,
+	EP_STATE_CONNECT_FAILED         = 0x4000,
+	EP_STATE_DISCONN_TIMEDOUT       = 0x8000,
+};
+
+struct qedi_conn;
+
+struct qedi_endpoint {
+	struct qedi_ctx *qedi;
+	u32 dst_addr[4];
+	u32 src_addr[4];
+	u16 src_port;
+	u16 dst_port;
+	u16 vlan_id;
+	u16 pmtu;
+	u8 src_mac[ETH_ALEN];
+	u8 dst_mac[ETH_ALEN];
+	u8 ip_type;
+	int state;
+	wait_queue_head_t ofld_wait;
+	wait_queue_head_t tcp_ofld_wait;
+	u32 iscsi_cid;
+	/* identifier of the connection from qed */
+	u32 handle;
+	u32 fw_cid;
+	void __iomem *p_doorbell;
+
+	/* Send queue management */
+	struct iscsi_wqe *sq;
+	dma_addr_t sq_dma;
+
+	u16 sq_prod_idx;
+	u16 fw_sq_prod_idx;
+	u16 sq_con_idx;
+	u32 sq_mem_size;
+
+	void *sq_pbl;
+	dma_addr_t sq_pbl_dma;
+	u32 sq_pbl_size;
+	struct qedi_conn *conn;
+	struct work_struct offload_work;
+};
+
+#define QEDI_SQ_WQES_MIN	16
+
+struct qedi_io_bdt {
+	struct iscsi_sge *sge_tbl;
+	dma_addr_t sge_tbl_dma;
+	u16 sge_valid;
+};
+
+/**
+ * struct generic_pdu_resc - login pdu resource structure
+ *
+ * @req_buf:            driver buffer used to stage payload associated with
+ *                      the login request
+ * @req_dma_addr:       dma address for iscsi login request payload buffer
+ * @req_buf_size:       actual login request payload length
+ * @req_wr_ptr:         pointer into login request buffer when next data is
+ *                      to be written
+ * @resp_hdr:           iscsi header where iscsi login response header is to
+ *                      be recreated
+ * @resp_buf:           buffer to stage login response payload
+ * @resp_dma_addr:      login response payload buffer dma address
+ * @resp_buf_size:      login response paylod length
+ * @resp_wr_ptr:        pointer into login response buffer when next data is
+ *                      to be written
+ * @req_bd_tbl:         iscsi login request payload BD table
+ * @req_bd_dma:         login request BD table dma address
+ * @resp_bd_tbl:        iscsi login response payload BD table
+ * @resp_bd_dma:        login request BD table dma address
+ *
+ * following structure defines buffer info for generic pdus such as iSCSI Login,
+ *      Logout and NOP
+ */
+struct generic_pdu_resc {
+	char *req_buf;
+	dma_addr_t req_dma_addr;
+	u32 req_buf_size;
+	char *req_wr_ptr;
+	struct iscsi_hdr resp_hdr;
+	char *resp_buf;
+	dma_addr_t resp_dma_addr;
+	u32 resp_buf_size;
+	char *resp_wr_ptr;
+	char *req_bd_tbl;
+	dma_addr_t req_bd_dma;
+	char *resp_bd_tbl;
+	dma_addr_t resp_bd_dma;
+};
+
+struct qedi_conn {
+	struct iscsi_cls_conn *cls_conn;
+	struct qedi_ctx *qedi;
+	struct qedi_endpoint *ep;
+	struct list_head active_cmd_list;
+	spinlock_t list_lock;		/* internal conn lock */
+	u32 active_cmd_count;
+	u32 cmd_cleanup_req;
+	u32 cmd_cleanup_cmpl;
+
+	u32 iscsi_conn_id;
+	int itt;
+	int abrt_conn;
+#define QEDI_CID_RESERVED	0x5AFF
+	u32 fw_cid;
+	/*
+	 * Buffer for login negotiation process
+	 */
+	struct generic_pdu_resc gen_pdu;
+
+	struct list_head tmf_work_list;
+	wait_queue_head_t wait_queue;
+	spinlock_t tmf_work_lock;	/* tmf work lock */
+	unsigned long flags;
+#define QEDI_CONN_FW_CLEANUP	1
+};
+
+struct qedi_cmd {
+	struct list_head io_cmd;
+	bool io_cmd_in_list;
+	struct iscsi_hdr hdr;
+	struct qedi_conn *conn;
+	struct scsi_cmnd *scsi_cmd;
+	struct scatterlist *sg;
+	struct qedi_io_bdt io_tbl;
+	struct iscsi_task_context request;
+	unsigned char *sense_buffer;
+	dma_addr_t sense_buffer_dma;
+	u16 task_id;
+
+	/* field populated for tmf work queue */
+	struct iscsi_task *task;
+	struct work_struct tmf_work;
+	int state;
+#define CLEANUP_WAIT	1
+#define CLEANUP_RECV	2
+#define CLEANUP_WAIT_FAILED	3
+#define CLEANUP_NOT_REQUIRED	4
+#define LUN_RESET_RESPONSE_RECEIVED	5
+#define RESPONSE_RECEIVED	6
+
+	int type;
+#define TYPEIO		1
+#define TYPERESET	2
+
+	struct qedi_work_map *list_tmf_work;
+	/* slowpath management */
+	bool use_slowpath;
+
+	struct iscsi_tm_rsp *tmf_resp_buf;
+	struct qedi_work cqe_work;
+};
+
+struct qedi_work_map {
+	struct list_head list;
+	struct qedi_cmd *qedi_cmd;
+	int rtid;
+
+	int state;
+#define QEDI_WORK_QUEUED	1
+#define QEDI_WORK_SCHEDULED	2
+#define QEDI_WORK_EXIT		3
+
+	struct work_struct *ptr_tmf_work;
+};
+
+#define qedi_set_itt(task_id, itt) ((u32)(((task_id) & 0xffff) | ((itt) << 16)))
+#define qedi_get_itt(cqe) (cqe.iscsi_hdr.cmd.itt >> 16)
+
+#define QEDI_OFLD_WAIT_STATE(q) ((q)->state == EP_STATE_OFLDCONN_FAILED || \
+				(q)->state == EP_STATE_OFLDCONN_COMPL)
+
+#endif /* _QEDI_ISCSI_H_ */
diff --git a/drivers/scsi/qedi/qedi_main.c b/drivers/scsi/qedi/qedi_main.c
new file mode 100644
index 0000000..19ead8d
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_main.c
@@ -0,0 +1,2127 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/kernel.h>
+#include <linux/if_arp.h>
+#include <scsi/iscsi_if.h>
+#include <linux/inet.h>
+#include <net/arp.h>
+#include <linux/list.h>
+#include <linux/kthread.h>
+#include <linux/mm.h>
+#include <linux/if_vlan.h>
+#include <linux/cpu.h>
+
+#include <scsi/scsi_cmnd.h>
+#include <scsi/scsi_device.h>
+#include <scsi/scsi_eh.h>
+#include <scsi/scsi_host.h>
+#include <scsi/scsi.h>
+
+#include "qedi.h"
+#include "qedi_gbl.h"
+#include "qedi_iscsi.h"
+
+static uint qedi_fw_debug;
+module_param(qedi_fw_debug, uint, 0644);
+MODULE_PARM_DESC(qedi_fw_debug, " Firmware debug level 0(default) to 3");
+
+uint qedi_dbg_log = QEDI_LOG_WARN | QEDI_LOG_SCSI_TM;
+module_param(qedi_dbg_log, uint, 0644);
+MODULE_PARM_DESC(qedi_dbg_log, " Default debug level");
+
+uint qedi_io_tracing;
+module_param(qedi_io_tracing, uint, 0644);
+MODULE_PARM_DESC(qedi_io_tracing,
+		 " Enable logging of SCSI requests/completions into trace buffer. (default off).");
+
+const struct qed_iscsi_ops *qedi_ops;
+static struct scsi_transport_template *qedi_scsi_transport;
+static struct pci_driver qedi_pci_driver;
+static DEFINE_PER_CPU(struct qedi_percpu_s, qedi_percpu);
+static LIST_HEAD(qedi_udev_list);
+/* Static function declaration */
+static int qedi_alloc_global_queues(struct qedi_ctx *qedi);
+static void qedi_free_global_queues(struct qedi_ctx *qedi);
+static struct qedi_cmd *qedi_get_cmd_from_tid(struct qedi_ctx *qedi, u32 tid);
+static void qedi_reset_uio_rings(struct qedi_uio_dev *udev);
+static void qedi_ll2_free_skbs(struct qedi_ctx *qedi);
+
+static int qedi_iscsi_event_cb(void *context, u8 fw_event_code, void *fw_handle)
+{
+	struct qedi_ctx *qedi;
+	struct qedi_endpoint *qedi_ep;
+	struct async_data *data;
+	int rval = 0;
+
+	if (!context || !fw_handle) {
+		QEDI_ERR(NULL, "Recv event with ctx NULL\n");
+		return -EINVAL;
+	}
+
+	qedi = (struct qedi_ctx *)context;
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+		  "Recv Event %d fw_handle %p\n", fw_event_code, fw_handle);
+
+	data = (struct async_data *)fw_handle;
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+		  "cid=0x%x tid=0x%x err-code=0x%x fw-dbg-param=0x%x\n",
+		   data->cid, data->itid, data->error_code,
+		   data->fw_debug_param);
+
+	qedi_ep = qedi->ep_tbl[data->cid];
+
+	if (!qedi_ep) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "Cannot process event, ep already disconnected, cid=0x%x\n",
+			   data->cid);
+		WARN_ON(1);
+		return -ENODEV;
+	}
+
+	switch (fw_event_code) {
+	case ISCSI_EVENT_TYPE_ASYN_CONNECT_COMPLETE:
+		if (qedi_ep->state == EP_STATE_OFLDCONN_START)
+			qedi_ep->state = EP_STATE_OFLDCONN_COMPL;
+
+		wake_up_interruptible(&qedi_ep->tcp_ofld_wait);
+		break;
+	case ISCSI_EVENT_TYPE_ASYN_TERMINATE_DONE:
+		qedi_ep->state = EP_STATE_DISCONN_COMPL;
+		wake_up_interruptible(&qedi_ep->tcp_ofld_wait);
+		break;
+	case ISCSI_EVENT_TYPE_ISCSI_CONN_ERROR:
+		qedi_process_iscsi_error(qedi_ep, data);
+		break;
+	case ISCSI_EVENT_TYPE_ASYN_ABORT_RCVD:
+	case ISCSI_EVENT_TYPE_ASYN_SYN_RCVD:
+	case ISCSI_EVENT_TYPE_ASYN_MAX_RT_TIME:
+	case ISCSI_EVENT_TYPE_ASYN_MAX_RT_CNT:
+	case ISCSI_EVENT_TYPE_ASYN_MAX_KA_PROBES_CNT:
+	case ISCSI_EVENT_TYPE_ASYN_FIN_WAIT2:
+	case ISCSI_EVENT_TYPE_TCP_CONN_ERROR:
+		qedi_process_tcp_error(qedi_ep, data);
+		break;
+	default:
+		QEDI_ERR(&qedi->dbg_ctx, "Recv Unknown Event %u\n",
+			 fw_event_code);
+	}
+
+	return rval;
+}
+
+static int qedi_uio_open(struct uio_info *uinfo, struct inode *inode)
+{
+	struct qedi_uio_dev *udev = uinfo->priv;
+	struct qedi_ctx *qedi = udev->qedi;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (udev->uio_dev != -1)
+		return -EBUSY;
+
+	rtnl_lock();
+	udev->uio_dev = iminor(inode);
+	qedi_reset_uio_rings(udev);
+	set_bit(UIO_DEV_OPENED, &qedi->flags);
+	rtnl_unlock();
+
+	return 0;
+}
+
+static int qedi_uio_close(struct uio_info *uinfo, struct inode *inode)
+{
+	struct qedi_uio_dev *udev = uinfo->priv;
+	struct qedi_ctx *qedi = udev->qedi;
+
+	udev->uio_dev = -1;
+	clear_bit(UIO_DEV_OPENED, &qedi->flags);
+	qedi_ll2_free_skbs(qedi);
+	return 0;
+}
+
+static void __qedi_free_uio_rings(struct qedi_uio_dev *udev)
+{
+	if (udev->ll2_ring) {
+		free_page((unsigned long)udev->ll2_ring);
+		udev->ll2_ring = NULL;
+	}
+
+	if (udev->ll2_buf) {
+		free_pages((unsigned long)udev->ll2_buf, 2);
+		udev->ll2_buf = NULL;
+	}
+}
+
+static void __qedi_free_uio(struct qedi_uio_dev *udev)
+{
+	uio_unregister_device(&udev->qedi_uinfo);
+
+	__qedi_free_uio_rings(udev);
+
+	pci_dev_put(udev->pdev);
+	kfree(udev->uctrl);
+	kfree(udev);
+}
+
+static void qedi_free_uio(struct qedi_uio_dev *udev)
+{
+	if (!udev)
+		return;
+
+	list_del_init(&udev->list);
+	__qedi_free_uio(udev);
+}
+
+static void qedi_reset_uio_rings(struct qedi_uio_dev *udev)
+{
+	struct qedi_ctx *qedi = NULL;
+	struct qedi_uio_ctrl *uctrl = NULL;
+
+	qedi = udev->qedi;
+	uctrl = udev->uctrl;
+
+	spin_lock_bh(&qedi->ll2_lock);
+	uctrl->host_rx_cons = 0;
+	uctrl->hw_rx_prod = 0;
+	uctrl->hw_rx_bd_prod = 0;
+	uctrl->host_rx_bd_cons = 0;
+
+	memset(udev->ll2_ring, 0, udev->ll2_ring_size);
+	memset(udev->ll2_buf, 0, udev->ll2_buf_size);
+	spin_unlock_bh(&qedi->ll2_lock);
+}
+
+static int __qedi_alloc_uio_rings(struct qedi_uio_dev *udev)
+{
+	int rc = 0;
+
+	if (udev->ll2_ring || udev->ll2_buf)
+		return rc;
+
+	/* Allocating memory for LL2 ring  */
+	udev->ll2_ring_size = QEDI_PAGE_SIZE;
+	udev->ll2_ring = (void *)get_zeroed_page(GFP_KERNEL | __GFP_COMP);
+	if (!udev->ll2_ring) {
+		rc = -ENOMEM;
+		goto exit_alloc_ring;
+	}
+
+	/* Allocating memory for Tx/Rx pkt buffer */
+	udev->ll2_buf_size = TX_RX_RING * LL2_SINGLE_BUF_SIZE;
+	udev->ll2_buf_size = QEDI_PAGE_ALIGN(udev->ll2_buf_size);
+	udev->ll2_buf = (void *)__get_free_pages(GFP_KERNEL | __GFP_COMP |
+						 __GFP_ZERO, 2);
+	if (!udev->ll2_buf) {
+		rc = -ENOMEM;
+		goto exit_alloc_buf;
+	}
+	return rc;
+
+exit_alloc_buf:
+	free_page((unsigned long)udev->ll2_ring);
+	udev->ll2_ring = NULL;
+exit_alloc_ring:
+	return rc;
+}
+
+static int qedi_alloc_uio_rings(struct qedi_ctx *qedi)
+{
+	struct qedi_uio_dev *udev = NULL;
+	struct qedi_uio_ctrl *uctrl = NULL;
+	int rc = 0;
+
+	list_for_each_entry(udev, &qedi_udev_list, list) {
+		if (udev->pdev == qedi->pdev) {
+			udev->qedi = qedi;
+			if (__qedi_alloc_uio_rings(udev)) {
+				udev->qedi = NULL;
+				return -ENOMEM;
+			}
+			qedi->udev = udev;
+			return 0;
+		}
+	}
+
+	udev = kzalloc(sizeof(*udev), GFP_KERNEL);
+	if (!udev) {
+		rc = -ENOMEM;
+		goto err_udev;
+	}
+
+	uctrl = kzalloc(sizeof(*uctrl), GFP_KERNEL);
+	if (!uctrl) {
+		rc = -ENOMEM;
+		goto err_uctrl;
+	}
+
+	udev->uio_dev = -1;
+
+	udev->qedi = qedi;
+	udev->pdev = qedi->pdev;
+	udev->uctrl = uctrl;
+
+	rc = __qedi_alloc_uio_rings(udev);
+	if (rc)
+		goto err_uio_rings;
+
+	list_add(&udev->list, &qedi_udev_list);
+
+	pci_dev_get(udev->pdev);
+	qedi->udev = udev;
+
+	udev->tx_pkt = udev->ll2_buf;
+	udev->rx_pkt = udev->ll2_buf + LL2_SINGLE_BUF_SIZE;
+	return 0;
+
+ err_uio_rings:
+	kfree(uctrl);
+ err_uctrl:
+	kfree(udev);
+ err_udev:
+	return -ENOMEM;
+}
+
+static int qedi_init_uio(struct qedi_ctx *qedi)
+{
+	struct qedi_uio_dev *udev = qedi->udev;
+	struct uio_info *uinfo;
+	int ret = 0;
+
+	if (!udev)
+		return -ENOMEM;
+
+	uinfo = &udev->qedi_uinfo;
+
+	uinfo->mem[0].addr = (unsigned long)udev->uctrl;
+	uinfo->mem[0].size = sizeof(struct qedi_uio_ctrl);
+	uinfo->mem[0].memtype = UIO_MEM_LOGICAL;
+
+	uinfo->mem[1].addr = (unsigned long)udev->ll2_ring;
+	uinfo->mem[1].size = udev->ll2_ring_size;
+	uinfo->mem[1].memtype = UIO_MEM_LOGICAL;
+
+	uinfo->mem[2].addr = (unsigned long)udev->ll2_buf;
+	uinfo->mem[2].size = udev->ll2_buf_size;
+	uinfo->mem[2].memtype = UIO_MEM_LOGICAL;
+
+	uinfo->name = "qedi_uio";
+	uinfo->version = QEDI_MODULE_VERSION;
+	uinfo->irq = UIO_IRQ_CUSTOM;
+
+	uinfo->open = qedi_uio_open;
+	uinfo->release = qedi_uio_close;
+
+	if (udev->uio_dev == -1) {
+		if (!uinfo->priv) {
+			uinfo->priv = udev;
+
+			ret = uio_register_device(&udev->pdev->dev, uinfo);
+			if (ret) {
+				QEDI_ERR(&qedi->dbg_ctx,
+					 "UIO registration failed\n");
+			}
+		}
+	}
+
+	return ret;
+}
+
+static int qedi_alloc_and_init_sb(struct qedi_ctx *qedi,
+				  struct qed_sb_info *sb_info, u16 sb_id)
+{
+	struct status_block *sb_virt;
+	dma_addr_t sb_phys;
+	int ret;
+
+	sb_virt = dma_alloc_coherent(&qedi->pdev->dev,
+				     sizeof(struct status_block), &sb_phys,
+				     GFP_KERNEL);
+	if (!sb_virt) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Status block allocation failed for id = %d.\n",
+			  sb_id);
+		return -ENOMEM;
+	}
+
+	ret = qedi_ops->common->sb_init(qedi->cdev, sb_info, sb_virt, sb_phys,
+				       sb_id, QED_SB_TYPE_STORAGE);
+	if (ret) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Status block initialization failed for id = %d.\n",
+			  sb_id);
+		return ret;
+	}
+
+	return 0;
+}
+
+static void qedi_free_sb(struct qedi_ctx *qedi)
+{
+	struct qed_sb_info *sb_info;
+	int id;
+
+	for (id = 0; id < MIN_NUM_CPUS_MSIX(qedi); id++) {
+		sb_info = &qedi->sb_array[id];
+		if (sb_info->sb_virt)
+			dma_free_coherent(&qedi->pdev->dev,
+					  sizeof(*sb_info->sb_virt),
+					  (void *)sb_info->sb_virt,
+					  sb_info->sb_phys);
+	}
+}
+
+static void qedi_free_fp(struct qedi_ctx *qedi)
+{
+	kfree(qedi->fp_array);
+	kfree(qedi->sb_array);
+}
+
+static void qedi_destroy_fp(struct qedi_ctx *qedi)
+{
+	qedi_free_sb(qedi);
+	qedi_free_fp(qedi);
+}
+
+static int qedi_alloc_fp(struct qedi_ctx *qedi)
+{
+	int ret = 0;
+
+	qedi->fp_array = kcalloc(MIN_NUM_CPUS_MSIX(qedi),
+				 sizeof(struct qedi_fastpath), GFP_KERNEL);
+	if (!qedi->fp_array) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "fastpath fp array allocation failed.\n");
+		return -ENOMEM;
+	}
+
+	qedi->sb_array = kcalloc(MIN_NUM_CPUS_MSIX(qedi),
+				 sizeof(struct qed_sb_info), GFP_KERNEL);
+	if (!qedi->sb_array) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "fastpath sb array allocation failed.\n");
+		ret = -ENOMEM;
+		goto free_fp;
+	}
+
+	return ret;
+
+free_fp:
+	qedi_free_fp(qedi);
+	return ret;
+}
+
+static void qedi_int_fp(struct qedi_ctx *qedi)
+{
+	struct qedi_fastpath *fp;
+	int id;
+
+	memset(qedi->fp_array, 0, MIN_NUM_CPUS_MSIX(qedi) *
+	       sizeof(*qedi->fp_array));
+	memset(qedi->sb_array, 0, MIN_NUM_CPUS_MSIX(qedi) *
+	       sizeof(*qedi->sb_array));
+
+	for (id = 0; id < MIN_NUM_CPUS_MSIX(qedi); id++) {
+		fp = &qedi->fp_array[id];
+		fp->sb_info = &qedi->sb_array[id];
+		fp->sb_id = id;
+		fp->qedi = qedi;
+		snprintf(fp->name, sizeof(fp->name), "%s-fp-%d",
+			 "qedi", id);
+
+		/* fp_array[i] ---- irq cookie
+		 * So init data which is needed in int ctx
+		 */
+	}
+}
+
+static int qedi_prepare_fp(struct qedi_ctx *qedi)
+{
+	struct qedi_fastpath *fp;
+	int id, ret = 0;
+
+	ret = qedi_alloc_fp(qedi);
+	if (ret)
+		goto err;
+
+	qedi_int_fp(qedi);
+
+	for (id = 0; id < MIN_NUM_CPUS_MSIX(qedi); id++) {
+		fp = &qedi->fp_array[id];
+		ret = qedi_alloc_and_init_sb(qedi, fp->sb_info, fp->sb_id);
+		if (ret) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "SB allocation and initialization failed.\n");
+			ret = -EIO;
+			goto err_init;
+		}
+	}
+
+	return 0;
+
+err_init:
+	qedi_free_sb(qedi);
+	qedi_free_fp(qedi);
+err:
+	return ret;
+}
+
+static int qedi_setup_cid_que(struct qedi_ctx *qedi)
+{
+	int i;
+
+	qedi->cid_que.cid_que_base = kmalloc_array(qedi->max_active_conns,
+						   sizeof(u32), GFP_KERNEL);
+	if (!qedi->cid_que.cid_que_base)
+		return -ENOMEM;
+
+	qedi->cid_que.conn_cid_tbl = kmalloc_array(qedi->max_active_conns,
+						   sizeof(struct qedi_conn *),
+						   GFP_KERNEL);
+	if (!qedi->cid_que.conn_cid_tbl) {
+		kfree(qedi->cid_que.cid_que_base);
+		qedi->cid_que.cid_que_base = NULL;
+		return -ENOMEM;
+	}
+
+	qedi->cid_que.cid_que = (u32 *)qedi->cid_que.cid_que_base;
+	qedi->cid_que.cid_q_prod_idx = 0;
+	qedi->cid_que.cid_q_cons_idx = 0;
+	qedi->cid_que.cid_q_max_idx = qedi->max_active_conns;
+	qedi->cid_que.cid_free_cnt = qedi->max_active_conns;
+
+	for (i = 0; i < qedi->max_active_conns; i++) {
+		qedi->cid_que.cid_que[i] = i;
+		qedi->cid_que.conn_cid_tbl[i] = NULL;
+	}
+
+	return 0;
+}
+
+static void qedi_release_cid_que(struct qedi_ctx *qedi)
+{
+	kfree(qedi->cid_que.cid_que_base);
+	qedi->cid_que.cid_que_base = NULL;
+
+	kfree(qedi->cid_que.conn_cid_tbl);
+	qedi->cid_que.conn_cid_tbl = NULL;
+}
+
+static int qedi_init_id_tbl(struct qedi_portid_tbl *id_tbl, u16 size,
+			    u16 start_id, u16 next)
+{
+	id_tbl->start = start_id;
+	id_tbl->max = size;
+	id_tbl->next = next;
+	spin_lock_init(&id_tbl->lock);
+	id_tbl->table = kzalloc(DIV_ROUND_UP(size, 32) * 4, GFP_KERNEL);
+	if (!id_tbl->table)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void qedi_free_id_tbl(struct qedi_portid_tbl *id_tbl)
+{
+	kfree(id_tbl->table);
+	id_tbl->table = NULL;
+}
+
+int qedi_alloc_id(struct qedi_portid_tbl *id_tbl, u16 id)
+{
+	int ret = -1;
+
+	id -= id_tbl->start;
+	if (id >= id_tbl->max)
+		return ret;
+
+	spin_lock(&id_tbl->lock);
+	if (!test_bit(id, id_tbl->table)) {
+		set_bit(id, id_tbl->table);
+		ret = 0;
+	}
+	spin_unlock(&id_tbl->lock);
+	return ret;
+}
+
+u16 qedi_alloc_new_id(struct qedi_portid_tbl *id_tbl)
+{
+	u16 id;
+
+	spin_lock(&id_tbl->lock);
+	id = find_next_zero_bit(id_tbl->table, id_tbl->max, id_tbl->next);
+	if (id >= id_tbl->max) {
+		id = QEDI_LOCAL_PORT_INVALID;
+		if (id_tbl->next != 0) {
+			id = find_first_zero_bit(id_tbl->table, id_tbl->next);
+			if (id >= id_tbl->next)
+				id = QEDI_LOCAL_PORT_INVALID;
+		}
+	}
+
+	if (id < id_tbl->max) {
+		set_bit(id, id_tbl->table);
+		id_tbl->next = (id + 1) & (id_tbl->max - 1);
+		id += id_tbl->start;
+	}
+
+	spin_unlock(&id_tbl->lock);
+
+	return id;
+}
+
+void qedi_free_id(struct qedi_portid_tbl *id_tbl, u16 id)
+{
+	if (id == QEDI_LOCAL_PORT_INVALID)
+		return;
+
+	id -= id_tbl->start;
+	if (id >= id_tbl->max)
+		return;
+
+	clear_bit(id, id_tbl->table);
+}
+
+static void qedi_cm_free_mem(struct qedi_ctx *qedi)
+{
+	kfree(qedi->ep_tbl);
+	qedi->ep_tbl = NULL;
+	qedi_free_id_tbl(&qedi->lcl_port_tbl);
+}
+
+static int qedi_cm_alloc_mem(struct qedi_ctx *qedi)
+{
+	u16 port_id;
+
+	qedi->ep_tbl = kzalloc((qedi->max_active_conns *
+				sizeof(struct qedi_endpoint *)), GFP_KERNEL);
+	if (!qedi->ep_tbl)
+		return -ENOMEM;
+	port_id = prandom_u32() % QEDI_LOCAL_PORT_RANGE;
+	if (qedi_init_id_tbl(&qedi->lcl_port_tbl, QEDI_LOCAL_PORT_RANGE,
+			     QEDI_LOCAL_PORT_MIN, port_id)) {
+		qedi_cm_free_mem(qedi);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static struct qedi_ctx *qedi_host_alloc(struct pci_dev *pdev)
+{
+	struct Scsi_Host *shost;
+	struct qedi_ctx *qedi = NULL;
+
+	shost = iscsi_host_alloc(&qedi_host_template,
+				 sizeof(struct qedi_ctx), 0);
+	if (!shost) {
+		QEDI_ERR(NULL, "Could not allocate shost\n");
+		goto exit_setup_shost;
+	}
+
+	shost->max_id = QEDI_MAX_ISCSI_CONNS_PER_HBA;
+	shost->max_channel = 0;
+	shost->max_lun = ~0;
+	shost->max_cmd_len = 16;
+	shost->transportt = qedi_scsi_transport;
+
+	qedi = iscsi_host_priv(shost);
+	memset(qedi, 0, sizeof(*qedi));
+	qedi->shost = shost;
+	qedi->dbg_ctx.host_no = shost->host_no;
+	qedi->pdev = pdev;
+	qedi->dbg_ctx.pdev = pdev;
+	qedi->max_active_conns = ISCSI_MAX_SESS_PER_HBA;
+	qedi->max_sqes = QEDI_SQ_SIZE;
+
+	if (shost_use_blk_mq(shost))
+		shost->nr_hw_queues = MIN_NUM_CPUS_MSIX(qedi);
+
+	pci_set_drvdata(pdev, qedi);
+
+exit_setup_shost:
+	return qedi;
+}
+
+static int qedi_ll2_rx(void *cookie, struct sk_buff *skb, u32 arg1, u32 arg2)
+{
+	struct qedi_ctx *qedi = (struct qedi_ctx *)cookie;
+	struct qedi_uio_dev *udev;
+	struct qedi_uio_ctrl *uctrl;
+	struct skb_work_list *work;
+	u32 prod;
+
+	if (!qedi) {
+		QEDI_ERR(NULL, "qedi is NULL\n");
+		return -1;
+	}
+
+	if (!test_bit(UIO_DEV_OPENED, &qedi->flags)) {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_UIO,
+			  "UIO DEV is not opened\n");
+		kfree_skb(skb);
+		return 0;
+	}
+
+	udev = qedi->udev;
+	uctrl = udev->uctrl;
+
+	work = kzalloc(sizeof(*work), GFP_ATOMIC);
+	if (!work) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "Could not allocate work so dropping frame.\n");
+		kfree_skb(skb);
+		return 0;
+	}
+
+	INIT_LIST_HEAD(&work->list);
+	work->skb = skb;
+
+	if (skb_vlan_tag_present(skb))
+		work->vlan_id = skb_vlan_tag_get(skb);
+
+	if (work->vlan_id)
+		__vlan_insert_tag(work->skb, htons(ETH_P_8021Q), work->vlan_id);
+
+	spin_lock_bh(&qedi->ll2_lock);
+	list_add_tail(&work->list, &qedi->ll2_skb_list);
+
+	++uctrl->hw_rx_prod_cnt;
+	prod = (uctrl->hw_rx_prod + 1) % RX_RING;
+	if (prod != uctrl->host_rx_cons) {
+		uctrl->hw_rx_prod = prod;
+		spin_unlock_bh(&qedi->ll2_lock);
+		wake_up_process(qedi->ll2_recv_thread);
+		return 0;
+	}
+
+	spin_unlock_bh(&qedi->ll2_lock);
+	return 0;
+}
+
+/* map this skb to iscsiuio mmaped region */
+static int qedi_ll2_process_skb(struct qedi_ctx *qedi, struct sk_buff *skb,
+				u16 vlan_id)
+{
+	struct qedi_uio_dev *udev = NULL;
+	struct qedi_uio_ctrl *uctrl = NULL;
+	struct qedi_rx_bd rxbd;
+	struct qedi_rx_bd *p_rxbd;
+	u32 rx_bd_prod;
+	void *pkt;
+	int len = 0;
+
+	if (!qedi) {
+		QEDI_ERR(NULL, "qedi is NULL\n");
+		return -1;
+	}
+
+	udev = qedi->udev;
+	uctrl = udev->uctrl;
+	pkt = udev->rx_pkt + (uctrl->hw_rx_prod * LL2_SINGLE_BUF_SIZE);
+	len = min_t(u32, skb->len, (u32)LL2_SINGLE_BUF_SIZE);
+	memcpy(pkt, skb->data, len);
+
+	memset(&rxbd, 0, sizeof(rxbd));
+	rxbd.rx_pkt_index = uctrl->hw_rx_prod;
+	rxbd.rx_pkt_len = len;
+	rxbd.vlan_id = vlan_id;
+
+	uctrl->hw_rx_bd_prod = (uctrl->hw_rx_bd_prod + 1) % QEDI_NUM_RX_BD;
+	rx_bd_prod = uctrl->hw_rx_bd_prod;
+	p_rxbd = (struct qedi_rx_bd *)udev->ll2_ring;
+	p_rxbd += rx_bd_prod;
+
+	memcpy(p_rxbd, &rxbd, sizeof(rxbd));
+
+	/* notify the iscsiuio about new packet */
+	uio_event_notify(&udev->qedi_uinfo);
+
+	return 0;
+}
+
+static void qedi_ll2_free_skbs(struct qedi_ctx *qedi)
+{
+	struct skb_work_list *work, *work_tmp;
+
+	spin_lock_bh(&qedi->ll2_lock);
+	list_for_each_entry_safe(work, work_tmp, &qedi->ll2_skb_list, list) {
+		list_del(&work->list);
+		if (work->skb)
+			kfree_skb(work->skb);
+		kfree(work);
+	}
+	spin_unlock_bh(&qedi->ll2_lock);
+}
+
+static int qedi_ll2_recv_thread(void *arg)
+{
+	struct qedi_ctx *qedi = (struct qedi_ctx *)arg;
+	struct skb_work_list *work, *work_tmp;
+
+	set_user_nice(current, -20);
+
+	while (!kthread_should_stop()) {
+		spin_lock_bh(&qedi->ll2_lock);
+		list_for_each_entry_safe(work, work_tmp, &qedi->ll2_skb_list,
+					 list) {
+			list_del(&work->list);
+			qedi_ll2_process_skb(qedi, work->skb, work->vlan_id);
+			kfree_skb(work->skb);
+			kfree(work);
+		}
+		set_current_state(TASK_INTERRUPTIBLE);
+		spin_unlock_bh(&qedi->ll2_lock);
+		schedule();
+	}
+
+	__set_current_state(TASK_RUNNING);
+	return 0;
+}
+
+static int qedi_set_iscsi_pf_param(struct qedi_ctx *qedi)
+{
+	u8 num_sq_pages;
+	u32 log_page_size;
+	int rval = 0;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_DISC, "Min number of MSIX %d\n",
+		  MIN_NUM_CPUS_MSIX(qedi));
+
+	num_sq_pages = (MAX_OUSTANDING_TASKS_PER_CON * 8) / PAGE_SIZE;
+
+	qedi->num_queues = MIN_NUM_CPUS_MSIX(qedi);
+
+	memset(&qedi->pf_params.iscsi_pf_params, 0,
+	       sizeof(qedi->pf_params.iscsi_pf_params));
+
+	qedi->p_cpuq = pci_alloc_consistent(qedi->pdev,
+			qedi->num_queues * sizeof(struct qedi_glbl_q_params),
+			&qedi->hw_p_cpuq);
+	if (!qedi->p_cpuq) {
+		QEDI_ERR(&qedi->dbg_ctx, "pci_alloc_consistent fail\n");
+		rval = -1;
+		goto err_alloc_mem;
+	}
+
+	rval = qedi_alloc_global_queues(qedi);
+	if (rval) {
+		QEDI_ERR(&qedi->dbg_ctx, "Global queue allocation failed.\n");
+		rval = -1;
+		goto err_alloc_mem;
+	}
+
+	qedi->pf_params.iscsi_pf_params.num_cons = QEDI_MAX_ISCSI_CONNS_PER_HBA;
+	qedi->pf_params.iscsi_pf_params.num_tasks = QEDI_MAX_ISCSI_TASK;
+	qedi->pf_params.iscsi_pf_params.half_way_close_timeout = 10;
+	qedi->pf_params.iscsi_pf_params.num_sq_pages_in_ring = num_sq_pages;
+	qedi->pf_params.iscsi_pf_params.num_r2tq_pages_in_ring = num_sq_pages;
+	qedi->pf_params.iscsi_pf_params.num_uhq_pages_in_ring = num_sq_pages;
+	qedi->pf_params.iscsi_pf_params.num_queues = qedi->num_queues;
+	qedi->pf_params.iscsi_pf_params.debug_mode = qedi_fw_debug;
+
+	for (log_page_size = 0 ; log_page_size < 32 ; log_page_size++) {
+		if ((1 << log_page_size) == PAGE_SIZE)
+			break;
+	}
+	qedi->pf_params.iscsi_pf_params.log_page_size = log_page_size;
+
+	qedi->pf_params.iscsi_pf_params.glbl_q_params_addr =
+							   (u64)qedi->hw_p_cpuq;
+
+	/* RQ BDQ initializations.
+	 * rq_num_entries: suggested value for Initiator is 16 (4KB RQ)
+	 * rqe_log_size: 8 for 256B RQE
+	 */
+	qedi->pf_params.iscsi_pf_params.rqe_log_size = 8;
+	/* BDQ address and size */
+	qedi->pf_params.iscsi_pf_params.bdq_pbl_base_addr[BDQ_ID_RQ] =
+							qedi->bdq_pbl_list_dma;
+	qedi->pf_params.iscsi_pf_params.bdq_pbl_num_entries[BDQ_ID_RQ] =
+						qedi->bdq_pbl_list_num_entries;
+	qedi->pf_params.iscsi_pf_params.rq_buffer_size = QEDI_BDQ_BUF_SIZE;
+
+	/* cq_num_entries: num_tasks + rq_num_entries */
+	qedi->pf_params.iscsi_pf_params.cq_num_entries = 2048;
+
+	qedi->pf_params.iscsi_pf_params.gl_rq_pi = QEDI_PROTO_CQ_PROD_IDX;
+	qedi->pf_params.iscsi_pf_params.gl_cmd_pi = 1;
+	qedi->pf_params.iscsi_pf_params.ooo_enable = 1;
+
+err_alloc_mem:
+	return rval;
+}
+
+/* Free DMA coherent memory for array of queue pointers we pass to qed */
+static void qedi_free_iscsi_pf_param(struct qedi_ctx *qedi)
+{
+	size_t size = 0;
+
+	if (qedi->p_cpuq) {
+		size = qedi->num_queues * sizeof(struct qedi_glbl_q_params);
+		pci_free_consistent(qedi->pdev, size, qedi->p_cpuq,
+				    qedi->hw_p_cpuq);
+	}
+
+	qedi_free_global_queues(qedi);
+
+	kfree(qedi->global_queues);
+}
+
+static void qedi_link_update(void *dev, struct qed_link_output *link)
+{
+	struct qedi_ctx *qedi = (struct qedi_ctx *)dev;
+
+	if (link->link_up) {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO, "Link Up event.\n");
+		atomic_set(&qedi->link_state, QEDI_LINK_UP);
+	} else {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+			  "Link Down event.\n");
+		atomic_set(&qedi->link_state, QEDI_LINK_DOWN);
+	}
+}
+
+static struct qed_iscsi_cb_ops qedi_cb_ops = {
+	{
+		.link_update =		qedi_link_update,
+	}
+};
+
+static int qedi_queue_cqe(struct qedi_ctx *qedi, union iscsi_cqe *cqe,
+			  u16 que_idx, struct qedi_percpu_s *p)
+{
+	struct qedi_work *qedi_work;
+	struct qedi_conn *q_conn;
+	struct iscsi_conn *conn;
+	struct qedi_cmd *qedi_cmd;
+	u32 iscsi_cid;
+	int rc = 0;
+
+	iscsi_cid  = cqe->cqe_common.conn_id;
+	q_conn = qedi->cid_que.conn_cid_tbl[iscsi_cid];
+	if (!q_conn) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "Session no longer exists for cid=0x%x!!\n",
+			  iscsi_cid);
+		return -1;
+	}
+	conn = q_conn->cls_conn->dd_data;
+
+	switch (cqe->cqe_common.cqe_type) {
+	case ISCSI_CQE_TYPE_SOLICITED:
+	case ISCSI_CQE_TYPE_SOLICITED_WITH_SENSE:
+		qedi_cmd = qedi_get_cmd_from_tid(qedi, cqe->cqe_solicited.itid);
+		if (!qedi_cmd) {
+			rc = -1;
+			break;
+		}
+		INIT_LIST_HEAD(&qedi_cmd->cqe_work.list);
+		qedi_cmd->cqe_work.qedi = qedi;
+		memcpy(&qedi_cmd->cqe_work.cqe, cqe, sizeof(union iscsi_cqe));
+		qedi_cmd->cqe_work.que_idx = que_idx;
+		qedi_cmd->cqe_work.is_solicited = true;
+		list_add_tail(&qedi_cmd->cqe_work.list, &p->work_list);
+		break;
+	case ISCSI_CQE_TYPE_UNSOLICITED:
+	case ISCSI_CQE_TYPE_DUMMY:
+	case ISCSI_CQE_TYPE_TASK_CLEANUP:
+		qedi_work = kzalloc(sizeof(*qedi_work), GFP_ATOMIC);
+		if (!qedi_work) {
+			rc = -1;
+			break;
+		}
+		INIT_LIST_HEAD(&qedi_work->list);
+		qedi_work->qedi = qedi;
+		memcpy(&qedi_work->cqe, cqe, sizeof(union iscsi_cqe));
+		qedi_work->que_idx = que_idx;
+		qedi_work->is_solicited = false;
+		list_add_tail(&qedi_work->list, &p->work_list);
+		break;
+	default:
+		rc = -1;
+		QEDI_ERR(&qedi->dbg_ctx, "FW Error cqe.\n");
+	}
+	return rc;
+}
+
+static bool qedi_process_completions(struct qedi_fastpath *fp)
+{
+	struct qedi_ctx *qedi = fp->qedi;
+	struct qed_sb_info *sb_info = fp->sb_info;
+	struct status_block *sb = sb_info->sb_virt;
+	struct qedi_percpu_s *p = NULL;
+	struct global_queue *que;
+	u16 prod_idx;
+	unsigned long flags;
+	union iscsi_cqe *cqe;
+	int cpu;
+	int ret;
+
+	/* Get the current firmware producer index */
+	prod_idx = sb->pi_array[QEDI_PROTO_CQ_PROD_IDX];
+
+	if (prod_idx >= QEDI_CQ_SIZE)
+		prod_idx = prod_idx % QEDI_CQ_SIZE;
+
+	que = qedi->global_queues[fp->sb_id];
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_IO,
+		  "Before: global queue=%p prod_idx=%d cons_idx=%d, sb_id=%d\n",
+		  que, prod_idx, que->cq_cons_idx, fp->sb_id);
+
+	qedi->intr_cpu = fp->sb_id;
+	cpu = smp_processor_id();
+	p = &per_cpu(qedi_percpu, cpu);
+
+	if (unlikely(!p->iothread))
+		WARN_ON(1);
+
+	spin_lock_irqsave(&p->p_work_lock, flags);
+	while (que->cq_cons_idx != prod_idx) {
+		cqe = &que->cq[que->cq_cons_idx];
+
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_IO,
+			  "cqe=%p prod_idx=%d cons_idx=%d.\n",
+			  cqe, prod_idx, que->cq_cons_idx);
+
+		ret = qedi_queue_cqe(qedi, cqe, fp->sb_id, p);
+		if (ret)
+			continue;
+
+		que->cq_cons_idx++;
+		if (que->cq_cons_idx == QEDI_CQ_SIZE)
+			que->cq_cons_idx = 0;
+	}
+	wake_up_process(p->iothread);
+	spin_unlock_irqrestore(&p->p_work_lock, flags);
+
+	return true;
+}
+
+static bool qedi_fp_has_work(struct qedi_fastpath *fp)
+{
+	struct qedi_ctx *qedi = fp->qedi;
+	struct global_queue *que;
+	struct qed_sb_info *sb_info = fp->sb_info;
+	struct status_block *sb = sb_info->sb_virt;
+	u16 prod_idx;
+
+	barrier();
+
+	/* Get the current firmware producer index */
+	prod_idx = sb->pi_array[QEDI_PROTO_CQ_PROD_IDX];
+
+	/* Get the pointer to the global CQ this completion is on */
+	que = qedi->global_queues[fp->sb_id];
+
+	/* prod idx wrap around uint16 */
+	if (prod_idx >= QEDI_CQ_SIZE)
+		prod_idx = prod_idx % QEDI_CQ_SIZE;
+
+	return (que->cq_cons_idx != prod_idx);
+}
+
+/* MSI-X fastpath handler code */
+static irqreturn_t qedi_msix_handler(int irq, void *dev_id)
+{
+	struct qedi_fastpath *fp = dev_id;
+	struct qedi_ctx *qedi = fp->qedi;
+	bool wake_io_thread = true;
+
+	qed_sb_ack(fp->sb_info, IGU_INT_DISABLE, 0);
+
+process_again:
+	wake_io_thread = qedi_process_completions(fp);
+	if (wake_io_thread) {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_DISC,
+			  "process already running\n");
+	}
+
+	if (qedi_fp_has_work(fp) == 0)
+		qed_sb_update_sb_idx(fp->sb_info);
+
+	/* Check for more work */
+	rmb();
+
+	if (qedi_fp_has_work(fp) == 0)
+		qed_sb_ack(fp->sb_info, IGU_INT_ENABLE, 1);
+	else
+		goto process_again;
+
+	return IRQ_HANDLED;
+}
+
+/* simd handler for MSI/INTa */
+static void qedi_simd_int_handler(void *cookie)
+{
+	/* Cookie is qedi_ctx struct */
+	struct qedi_ctx *qedi = (struct qedi_ctx *)cookie;
+
+	QEDI_WARN(&qedi->dbg_ctx, "qedi=%p.\n", qedi);
+}
+
+#define QEDI_SIMD_HANDLER_NUM		0
+static void qedi_sync_free_irqs(struct qedi_ctx *qedi)
+{
+	int i;
+
+	if (qedi->int_info.msix_cnt) {
+		for (i = 0; i < qedi->int_info.used_cnt; i++) {
+			synchronize_irq(qedi->int_info.msix[i].vector);
+			irq_set_affinity_hint(qedi->int_info.msix[i].vector,
+					      NULL);
+			free_irq(qedi->int_info.msix[i].vector,
+				 &qedi->fp_array[i]);
+		}
+	} else {
+		qedi_ops->common->simd_handler_clean(qedi->cdev,
+						     QEDI_SIMD_HANDLER_NUM);
+	}
+
+	qedi->int_info.used_cnt = 0;
+	qedi_ops->common->set_fp_int(qedi->cdev, 0);
+}
+
+static int qedi_request_msix_irq(struct qedi_ctx *qedi)
+{
+	int i, rc, cpu;
+
+	cpu = cpumask_first(cpu_online_mask);
+	for (i = 0; i < MIN_NUM_CPUS_MSIX(qedi); i++) {
+		rc = request_irq(qedi->int_info.msix[i].vector,
+				 qedi_msix_handler, 0, "qedi",
+				 &qedi->fp_array[i]);
+
+		if (rc) {
+			QEDI_WARN(&qedi->dbg_ctx, "request_irq failed.\n");
+			qedi_sync_free_irqs(qedi);
+			return rc;
+		}
+		qedi->int_info.used_cnt++;
+		rc = irq_set_affinity_hint(qedi->int_info.msix[i].vector,
+					   get_cpu_mask(cpu));
+		cpu = cpumask_next(cpu, cpu_online_mask);
+	}
+
+	return 0;
+}
+
+static int qedi_setup_int(struct qedi_ctx *qedi)
+{
+	int rc = 0;
+
+	rc = qedi_ops->common->set_fp_int(qedi->cdev, num_online_cpus());
+	rc = qedi_ops->common->get_fp_int(qedi->cdev, &qedi->int_info);
+	if (rc)
+		goto exit_setup_int;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_DISC,
+		  "Number of msix_cnt = 0x%x num of cpus = 0x%x\n",
+		   qedi->int_info.msix_cnt, num_online_cpus());
+
+	if (qedi->int_info.msix_cnt) {
+		rc = qedi_request_msix_irq(qedi);
+		goto exit_setup_int;
+	} else {
+		qedi_ops->common->simd_handler_config(qedi->cdev, &qedi,
+						      QEDI_SIMD_HANDLER_NUM,
+						      qedi_simd_int_handler);
+		qedi->int_info.used_cnt = 1;
+	}
+
+exit_setup_int:
+	return rc;
+}
+
+static void qedi_free_bdq(struct qedi_ctx *qedi)
+{
+	int i;
+
+	if (qedi->bdq_pbl_list)
+		dma_free_coherent(&qedi->pdev->dev, PAGE_SIZE,
+				  qedi->bdq_pbl_list, qedi->bdq_pbl_list_dma);
+
+	if (qedi->bdq_pbl)
+		dma_free_coherent(&qedi->pdev->dev, qedi->bdq_pbl_mem_size,
+				  qedi->bdq_pbl, qedi->bdq_pbl_dma);
+
+	for (i = 0; i < QEDI_BDQ_NUM; i++) {
+		if (qedi->bdq[i].buf_addr) {
+			dma_free_coherent(&qedi->pdev->dev, QEDI_BDQ_BUF_SIZE,
+					  qedi->bdq[i].buf_addr,
+					  qedi->bdq[i].buf_dma);
+		}
+	}
+}
+
+static void qedi_free_global_queues(struct qedi_ctx *qedi)
+{
+	int i;
+	struct global_queue **gl = qedi->global_queues;
+
+	for (i = 0; i < qedi->num_queues; i++) {
+		if (!gl[i])
+			continue;
+
+		if (gl[i]->cq)
+			dma_free_coherent(&qedi->pdev->dev, gl[i]->cq_mem_size,
+					  gl[i]->cq, gl[i]->cq_dma);
+		if (gl[i]->cq_pbl)
+			dma_free_coherent(&qedi->pdev->dev, gl[i]->cq_pbl_size,
+					  gl[i]->cq_pbl, gl[i]->cq_pbl_dma);
+
+		kfree(gl[i]);
+	}
+	qedi_free_bdq(qedi);
+}
+
+static int qedi_alloc_bdq(struct qedi_ctx *qedi)
+{
+	int i;
+	struct scsi_bd *pbl;
+	u64 *list;
+	dma_addr_t page;
+
+	/* Alloc dma memory for BDQ buffers */
+	for (i = 0; i < QEDI_BDQ_NUM; i++) {
+		qedi->bdq[i].buf_addr =
+				dma_alloc_coherent(&qedi->pdev->dev,
+						   QEDI_BDQ_BUF_SIZE,
+						   &qedi->bdq[i].buf_dma,
+						   GFP_KERNEL);
+		if (!qedi->bdq[i].buf_addr) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "Could not allocate BDQ buffer %d.\n", i);
+			return -ENOMEM;
+		}
+	}
+
+	/* Alloc dma memory for BDQ page buffer list */
+	qedi->bdq_pbl_mem_size = QEDI_BDQ_NUM * sizeof(struct scsi_bd);
+	qedi->bdq_pbl_mem_size = ALIGN(qedi->bdq_pbl_mem_size, PAGE_SIZE);
+	qedi->rq_num_entries = qedi->bdq_pbl_mem_size / sizeof(struct scsi_bd);
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN, "rq_num_entries = %d.\n",
+		  qedi->rq_num_entries);
+
+	qedi->bdq_pbl = dma_alloc_coherent(&qedi->pdev->dev,
+					   qedi->bdq_pbl_mem_size,
+					   &qedi->bdq_pbl_dma, GFP_KERNEL);
+	if (!qedi->bdq_pbl) {
+		QEDI_ERR(&qedi->dbg_ctx, "Could not allocate BDQ PBL.\n");
+		return -ENOMEM;
+	}
+
+	/*
+	 * Populate BDQ PBL with physical and virtual address of individual
+	 * BDQ buffers
+	 */
+	pbl = (struct scsi_bd  *)qedi->bdq_pbl;
+	for (i = 0; i < QEDI_BDQ_NUM; i++) {
+		pbl->address.hi =
+				cpu_to_le32(QEDI_U64_HI(qedi->bdq[i].buf_dma));
+		pbl->address.lo =
+				cpu_to_le32(QEDI_U64_LO(qedi->bdq[i].buf_dma));
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "pbl [0x%p] pbl->address hi [0x%llx] lo [0x%llx], idx [%d]\n",
+			  pbl, pbl->address.hi, pbl->address.lo, i);
+		pbl->opaque.hi = 0;
+		pbl->opaque.lo = cpu_to_le32(QEDI_U64_LO(i));
+		pbl++;
+	}
+
+	/* Allocate list of PBL pages */
+	qedi->bdq_pbl_list = dma_alloc_coherent(&qedi->pdev->dev,
+						PAGE_SIZE,
+						&qedi->bdq_pbl_list_dma,
+						GFP_KERNEL);
+	if (!qedi->bdq_pbl_list) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Could not allocate list of PBL pages.\n");
+		return -ENOMEM;
+	}
+	memset(qedi->bdq_pbl_list, 0, PAGE_SIZE);
+
+	/*
+	 * Now populate PBL list with pages that contain pointers to the
+	 * individual buffers.
+	 */
+	qedi->bdq_pbl_list_num_entries = qedi->bdq_pbl_mem_size / PAGE_SIZE;
+	list = (u64 *)qedi->bdq_pbl_list;
+	page = qedi->bdq_pbl_list_dma;
+	for (i = 0; i < qedi->bdq_pbl_list_num_entries; i++) {
+		*list = qedi->bdq_pbl_dma;
+		list++;
+		page += PAGE_SIZE;
+	}
+
+	return 0;
+}
+
+static int qedi_alloc_global_queues(struct qedi_ctx *qedi)
+{
+	u32 *list;
+	int i;
+	int status = 0, rc;
+	u32 *pbl;
+	dma_addr_t page;
+	int num_pages;
+
+	/*
+	 * Number of global queues (CQ / RQ). This should
+	 * be <= number of available MSIX vectors for the PF
+	 */
+	if (!qedi->num_queues) {
+		QEDI_ERR(&qedi->dbg_ctx, "No MSI-X vectors available!\n");
+		return 1;
+	}
+
+	/* Make sure we allocated the PBL that will contain the physical
+	 * addresses of our queues
+	 */
+	if (!qedi->p_cpuq) {
+		status = 1;
+		goto mem_alloc_failure;
+	}
+
+	qedi->global_queues = kzalloc((sizeof(struct global_queue *) *
+				       qedi->num_queues), GFP_KERNEL);
+	if (!qedi->global_queues) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Unable to allocate global queues array ptr memory\n");
+		return -ENOMEM;
+	}
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_DISC,
+		  "qedi->global_queues=%p.\n", qedi->global_queues);
+
+	/* Allocate DMA coherent buffers for BDQ */
+	rc = qedi_alloc_bdq(qedi);
+	if (rc)
+		goto mem_alloc_failure;
+
+	/* Allocate a CQ and an associated PBL for each MSI-X
+	 * vector.
+	 */
+	for (i = 0; i < qedi->num_queues; i++) {
+		qedi->global_queues[i] =
+					kzalloc(sizeof(*qedi->global_queues[0]),
+						GFP_KERNEL);
+		if (!qedi->global_queues[i]) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "Unable to allocation global queue %d.\n", i);
+			goto mem_alloc_failure;
+		}
+
+		qedi->global_queues[i]->cq_mem_size =
+		    (QEDI_CQ_SIZE + 8) * sizeof(union iscsi_cqe);
+		qedi->global_queues[i]->cq_mem_size =
+		    (qedi->global_queues[i]->cq_mem_size +
+		    (QEDI_PAGE_SIZE - 1));
+
+		qedi->global_queues[i]->cq_pbl_size =
+		    (qedi->global_queues[i]->cq_mem_size /
+		    QEDI_PAGE_SIZE) * sizeof(void *);
+		qedi->global_queues[i]->cq_pbl_size =
+		    (qedi->global_queues[i]->cq_pbl_size +
+		    (QEDI_PAGE_SIZE - 1));
+
+		qedi->global_queues[i]->cq =
+		    dma_alloc_coherent(&qedi->pdev->dev,
+				       qedi->global_queues[i]->cq_mem_size,
+				       &qedi->global_queues[i]->cq_dma,
+				       GFP_KERNEL);
+
+		if (!qedi->global_queues[i]->cq) {
+			QEDI_WARN(&qedi->dbg_ctx,
+				  "Could not allocate cq.\n");
+			status = -ENOMEM;
+			goto mem_alloc_failure;
+		}
+		memset(qedi->global_queues[i]->cq, 0,
+		       qedi->global_queues[i]->cq_mem_size);
+
+		qedi->global_queues[i]->cq_pbl =
+		    dma_alloc_coherent(&qedi->pdev->dev,
+				       qedi->global_queues[i]->cq_pbl_size,
+				       &qedi->global_queues[i]->cq_pbl_dma,
+				       GFP_KERNEL);
+
+		if (!qedi->global_queues[i]->cq_pbl) {
+			QEDI_WARN(&qedi->dbg_ctx,
+				  "Could not allocate cq PBL.\n");
+			status = -ENOMEM;
+			goto mem_alloc_failure;
+		}
+		memset(qedi->global_queues[i]->cq_pbl, 0,
+		       qedi->global_queues[i]->cq_pbl_size);
+
+		/* Create PBL */
+		num_pages = qedi->global_queues[i]->cq_mem_size /
+		    QEDI_PAGE_SIZE;
+		page = qedi->global_queues[i]->cq_dma;
+		pbl = (u32 *)qedi->global_queues[i]->cq_pbl;
+
+		while (num_pages--) {
+			*pbl = (u32)page;
+			pbl++;
+			*pbl = (u32)((u64)page >> 32);
+			pbl++;
+			page += QEDI_PAGE_SIZE;
+		}
+	}
+
+	list = (u32 *)qedi->p_cpuq;
+
+	/*
+	 * The list is built as follows: CQ#0 PBL pointer, RQ#0 PBL pointer,
+	 * CQ#1 PBL pointer, RQ#1 PBL pointer, etc.  Each PBL pointer points
+	 * to the physical address which contains an array of pointers to the
+	 * physical addresses of the specific queue pages.
+	 */
+	for (i = 0; i < qedi->num_queues; i++) {
+		*list = (u32)qedi->global_queues[i]->cq_pbl_dma;
+		list++;
+		*list = (u32)((u64)qedi->global_queues[i]->cq_pbl_dma >> 32);
+		list++;
+
+		*list = (u32)0;
+		list++;
+		*list = (u32)((u64)0 >> 32);
+		list++;
+	}
+
+	return 0;
+
+mem_alloc_failure:
+	qedi_free_global_queues(qedi);
+	return status;
+}
+
+int qedi_alloc_sq(struct qedi_ctx *qedi, struct qedi_endpoint *ep)
+{
+	int rval = 0;
+	u32 *pbl;
+	dma_addr_t page;
+	int num_pages;
+
+	if (!ep)
+		return -EIO;
+
+	/* Calculate appropriate queue and PBL sizes */
+	ep->sq_mem_size = QEDI_SQ_SIZE * sizeof(struct iscsi_wqe);
+	ep->sq_mem_size += QEDI_PAGE_SIZE - 1;
+
+	ep->sq_pbl_size = (ep->sq_mem_size / QEDI_PAGE_SIZE) * sizeof(void *);
+	ep->sq_pbl_size = ep->sq_pbl_size + QEDI_PAGE_SIZE;
+
+	ep->sq = dma_alloc_coherent(&qedi->pdev->dev, ep->sq_mem_size,
+				    &ep->sq_dma, GFP_KERNEL);
+	if (!ep->sq) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "Could not allocate send queue.\n");
+		rval = -ENOMEM;
+		goto out;
+	}
+	memset(ep->sq, 0, ep->sq_mem_size);
+
+	ep->sq_pbl = dma_alloc_coherent(&qedi->pdev->dev, ep->sq_pbl_size,
+					&ep->sq_pbl_dma, GFP_KERNEL);
+	if (!ep->sq_pbl) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "Could not allocate send queue PBL.\n");
+		rval = -ENOMEM;
+		goto out_free_sq;
+	}
+	memset(ep->sq_pbl, 0, ep->sq_pbl_size);
+
+	/* Create PBL */
+	num_pages = ep->sq_mem_size / QEDI_PAGE_SIZE;
+	page = ep->sq_dma;
+	pbl = (u32 *)ep->sq_pbl;
+
+	while (num_pages--) {
+		*pbl = (u32)page;
+		pbl++;
+		*pbl = (u32)((u64)page >> 32);
+		pbl++;
+		page += QEDI_PAGE_SIZE;
+	}
+
+	return rval;
+
+out_free_sq:
+	dma_free_coherent(&qedi->pdev->dev, ep->sq_mem_size, ep->sq,
+			  ep->sq_dma);
+out:
+	return rval;
+}
+
+void qedi_free_sq(struct qedi_ctx *qedi, struct qedi_endpoint *ep)
+{
+	if (ep->sq_pbl)
+		dma_free_coherent(&qedi->pdev->dev, ep->sq_pbl_size, ep->sq_pbl,
+				  ep->sq_pbl_dma);
+	if (ep->sq)
+		dma_free_coherent(&qedi->pdev->dev, ep->sq_mem_size, ep->sq,
+				  ep->sq_dma);
+}
+
+int qedi_get_task_idx(struct qedi_ctx *qedi)
+{
+	s16 tmp_idx;
+
+again:
+	tmp_idx = find_first_zero_bit(qedi->task_idx_map,
+				      MAX_ISCSI_TASK_ENTRIES);
+
+	if (tmp_idx >= MAX_ISCSI_TASK_ENTRIES) {
+		QEDI_ERR(&qedi->dbg_ctx, "FW task context pool is full.\n");
+		tmp_idx = -1;
+		goto err_idx;
+	}
+
+	if (test_and_set_bit(tmp_idx, qedi->task_idx_map))
+		goto again;
+
+err_idx:
+	return tmp_idx;
+}
+
+void qedi_clear_task_idx(struct qedi_ctx *qedi, int idx)
+{
+	if (!test_and_clear_bit(idx, qedi->task_idx_map)) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "FW task context, already cleared, tid=0x%x\n", idx);
+		WARN_ON(1);
+	}
+}
+
+void qedi_update_itt_map(struct qedi_ctx *qedi, u32 tid, u32 proto_itt,
+			 struct qedi_cmd *cmd)
+{
+	qedi->itt_map[tid].itt = proto_itt;
+	qedi->itt_map[tid].p_cmd = cmd;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "update itt map tid=0x%x, with proto itt=0x%x\n", tid,
+		  qedi->itt_map[tid].itt);
+}
+
+void qedi_get_task_tid(struct qedi_ctx *qedi, u32 itt, s16 *tid)
+{
+	u16 i;
+
+	for (i = 0; i < MAX_ISCSI_TASK_ENTRIES; i++) {
+		if (qedi->itt_map[i].itt == itt) {
+			*tid = i;
+			QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+				  "Ref itt=0x%x, found at tid=0x%x\n",
+				  itt, *tid);
+			return;
+		}
+	}
+
+	WARN_ON(1);
+}
+
+void qedi_get_proto_itt(struct qedi_ctx *qedi, u32 tid, u32 *proto_itt)
+{
+	*proto_itt = qedi->itt_map[tid].itt;
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "Get itt map tid [0x%x with proto itt[0x%x]",
+		  tid, *proto_itt);
+}
+
+struct qedi_cmd *qedi_get_cmd_from_tid(struct qedi_ctx *qedi, u32 tid)
+{
+	struct qedi_cmd *cmd = NULL;
+
+	if (tid > MAX_ISCSI_TASK_ENTRIES)
+		return NULL;
+
+	cmd = qedi->itt_map[tid].p_cmd;
+	if (cmd->task_id != tid)
+		return NULL;
+
+	qedi->itt_map[tid].p_cmd = NULL;
+
+	return cmd;
+}
+
+static int qedi_alloc_itt(struct qedi_ctx *qedi)
+{
+	qedi->itt_map = kcalloc(MAX_ISCSI_TASK_ENTRIES,
+				sizeof(struct qedi_itt_map), GFP_KERNEL);
+	if (!qedi->itt_map) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Unable to allocate itt map array memory\n");
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+static void qedi_free_itt(struct qedi_ctx *qedi)
+{
+	kfree(qedi->itt_map);
+}
+
+static struct qed_ll2_cb_ops qedi_ll2_cb_ops = {
+	.rx_cb = qedi_ll2_rx,
+	.tx_cb = NULL,
+};
+
+static int qedi_percpu_io_thread(void *arg)
+{
+	struct qedi_percpu_s *p = arg;
+	struct qedi_work *work, *tmp;
+	unsigned long flags;
+	LIST_HEAD(work_list);
+
+	set_user_nice(current, -20);
+
+	while (!kthread_should_stop()) {
+		spin_lock_irqsave(&p->p_work_lock, flags);
+		while (!list_empty(&p->work_list)) {
+			list_splice_init(&p->work_list, &work_list);
+			spin_unlock_irqrestore(&p->p_work_lock, flags);
+
+			list_for_each_entry_safe(work, tmp, &work_list, list) {
+				list_del_init(&work->list);
+				qedi_fp_process_cqes(work);
+				if (!work->is_solicited)
+					kfree(work);
+			}
+			cond_resched();
+			spin_lock_irqsave(&p->p_work_lock, flags);
+		}
+		set_current_state(TASK_INTERRUPTIBLE);
+		spin_unlock_irqrestore(&p->p_work_lock, flags);
+		schedule();
+	}
+	__set_current_state(TASK_RUNNING);
+
+	return 0;
+}
+
+static void qedi_percpu_thread_create(unsigned int cpu)
+{
+	struct qedi_percpu_s *p;
+	struct task_struct *thread;
+
+	p = &per_cpu(qedi_percpu, cpu);
+
+	thread = kthread_create_on_node(qedi_percpu_io_thread, (void *)p,
+					cpu_to_node(cpu),
+					"qedi_thread/%d", cpu);
+	if (likely(!IS_ERR(thread))) {
+		kthread_bind(thread, cpu);
+		p->iothread = thread;
+		wake_up_process(thread);
+	}
+}
+
+static void qedi_percpu_thread_destroy(unsigned int cpu)
+{
+	struct qedi_percpu_s *p;
+	struct task_struct *thread;
+	struct qedi_work *work, *tmp;
+
+	p = &per_cpu(qedi_percpu, cpu);
+	spin_lock_bh(&p->p_work_lock);
+	thread = p->iothread;
+	p->iothread = NULL;
+
+	list_for_each_entry_safe(work, tmp, &p->work_list, list) {
+		list_del_init(&work->list);
+		qedi_fp_process_cqes(work);
+		if (!work->is_solicited)
+			kfree(work);
+	}
+
+	spin_unlock_bh(&p->p_work_lock);
+	if (thread)
+		kthread_stop(thread);
+}
+
+static int qedi_cpu_callback(struct notifier_block *nfb,
+			     unsigned long action, void *hcpu)
+{
+	unsigned int cpu = (unsigned long)hcpu;
+
+	switch (action) {
+	case CPU_ONLINE:
+	case CPU_ONLINE_FROZEN:
+		QEDI_ERR(NULL, "CPU %d online.\n", cpu);
+		qedi_percpu_thread_create(cpu);
+		break;
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
+		QEDI_ERR(NULL, "CPU %d offline.\n", cpu);
+		qedi_percpu_thread_destroy(cpu);
+		break;
+	default:
+		break;
+	}
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block qedi_cpu_notifier = {
+	.notifier_call = qedi_cpu_callback,
+};
+
+void qedi_reset_host_mtu(struct qedi_ctx *qedi, u16 mtu)
+{
+	struct qed_ll2_params params;
+
+	qedi_recover_all_conns(qedi);
+
+	qedi_ops->ll2->stop(qedi->cdev);
+	qedi_ll2_free_skbs(qedi);
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO, "old MTU %u, new MTU %u\n",
+		  qedi->ll2_mtu, mtu);
+	memset(&params, 0, sizeof(params));
+	qedi->ll2_mtu = mtu;
+	params.mtu = qedi->ll2_mtu + IPV6_HDR_LEN + TCP_HDR_LEN;
+	params.drop_ttl0_packets = 0;
+	params.rx_vlan_stripping = 1;
+	ether_addr_copy(params.ll2_mac_address, qedi->dev_info.common.hw_mac);
+	qedi_ops->ll2->start(qedi->cdev, &params);
+}
+
+static void __qedi_remove(struct pci_dev *pdev, int mode)
+{
+	struct qedi_ctx *qedi = pci_get_drvdata(pdev);
+
+	if (qedi->tmf_thread) {
+		flush_workqueue(qedi->tmf_thread);
+		destroy_workqueue(qedi->tmf_thread);
+		qedi->tmf_thread = NULL;
+	}
+
+	if (qedi->offload_thread) {
+		flush_workqueue(qedi->offload_thread);
+		destroy_workqueue(qedi->offload_thread);
+		qedi->offload_thread = NULL;
+	}
+
+#ifdef CONFIG_DEBUG_FS
+	qedi_dbg_host_exit(&qedi->dbg_ctx);
+#endif
+	if (!test_bit(QEDI_IN_OFFLINE, &qedi->flags))
+		qedi_ops->common->set_power_state(qedi->cdev, PCI_D0);
+
+	qedi_sync_free_irqs(qedi);
+
+	if (!test_bit(QEDI_IN_OFFLINE, &qedi->flags)) {
+		qedi_ops->stop(qedi->cdev);
+		qedi_ops->ll2->stop(qedi->cdev);
+	}
+
+	if (mode == QEDI_MODE_NORMAL)
+		qedi_free_iscsi_pf_param(qedi);
+
+	if (!test_bit(QEDI_IN_OFFLINE, &qedi->flags)) {
+		qedi_ops->common->slowpath_stop(qedi->cdev);
+		qedi_ops->common->remove(qedi->cdev);
+	}
+
+	qedi_destroy_fp(qedi);
+
+	if (mode == QEDI_MODE_NORMAL) {
+		qedi_release_cid_que(qedi);
+		qedi_cm_free_mem(qedi);
+		qedi_free_uio(qedi->udev);
+		qedi_free_itt(qedi);
+
+		iscsi_host_remove(qedi->shost);
+		iscsi_host_free(qedi->shost);
+
+		if (qedi->ll2_recv_thread) {
+			kthread_stop(qedi->ll2_recv_thread);
+			qedi->ll2_recv_thread = NULL;
+		}
+		qedi_ll2_free_skbs(qedi);
+	}
+}
+
+static int __qedi_probe(struct pci_dev *pdev, int mode)
+{
+	struct qedi_ctx *qedi;
+	struct qed_ll2_params params;
+	u32 dp_module = 0;
+	u8 dp_level = 0;
+	bool is_vf = false;
+	char host_buf[16];
+	struct qed_link_params link_params;
+	struct qed_slowpath_params sp_params;
+	struct qed_probe_params qed_params;
+	void *task_start, *task_end;
+	int rc;
+	u16 tmp;
+
+	if (mode != QEDI_MODE_RECOVERY) {
+		qedi = qedi_host_alloc(pdev);
+		if (!qedi) {
+			rc = -ENOMEM;
+			goto exit_probe;
+		}
+	} else {
+		qedi = pci_get_drvdata(pdev);
+	}
+
+	memset(&qed_params, 0, sizeof(qed_params));
+	qed_params.protocol = QED_PROTOCOL_ISCSI;
+	qed_params.dp_module = dp_module;
+	qed_params.dp_level = dp_level;
+	qed_params.is_vf = is_vf;
+	qedi->cdev = qedi_ops->common->probe(pdev, &qed_params);
+	if (!qedi->cdev) {
+		rc = -ENODEV;
+		QEDI_ERR(&qedi->dbg_ctx, "Cannot initialize hardware\n");
+		goto free_host;
+	}
+
+	qedi->msix_count = MAX_NUM_MSIX_PF;
+	atomic_set(&qedi->link_state, QEDI_LINK_DOWN);
+
+	if (mode != QEDI_MODE_RECOVERY) {
+		rc = qedi_set_iscsi_pf_param(qedi);
+		if (rc) {
+			rc = -ENOMEM;
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "Set iSCSI pf param fail\n");
+			goto free_host;
+		}
+	}
+
+	qedi_ops->common->update_pf_params(qedi->cdev, &qedi->pf_params);
+
+	rc = qedi_prepare_fp(qedi);
+	if (rc) {
+		QEDI_ERR(&qedi->dbg_ctx, "Cannot start slowpath.\n");
+		goto free_pf_params;
+	}
+
+	/* Start the Slowpath-process */
+	memset(&sp_params, 0, sizeof(struct qed_slowpath_params));
+	sp_params.int_mode = QED_INT_MODE_MSIX;
+	sp_params.drv_major = QEDI_DRIVER_MAJOR_VER;
+	sp_params.drv_minor = QEDI_DRIVER_MINOR_VER;
+	sp_params.drv_rev = QEDI_DRIVER_REV_VER;
+	sp_params.drv_eng = QEDI_DRIVER_ENG_VER;
+	strlcpy(sp_params.name, "qedi iSCSI", QED_DRV_VER_STR_SIZE);
+	rc = qedi_ops->common->slowpath_start(qedi->cdev, &sp_params);
+	if (rc) {
+		QEDI_ERR(&qedi->dbg_ctx, "Cannot start slowpath\n");
+		goto stop_hw;
+	}
+
+	/* update_pf_params needs to be called before and after slowpath
+	 * start
+	 */
+	qedi_ops->common->update_pf_params(qedi->cdev, &qedi->pf_params);
+
+	qedi_setup_int(qedi);
+	if (rc)
+		goto stop_iscsi_func;
+
+	qedi_ops->common->set_power_state(qedi->cdev, PCI_D0);
+
+	/* Learn information crucial for qedi to progress */
+	rc = qedi_ops->fill_dev_info(qedi->cdev, &qedi->dev_info);
+	if (rc)
+		goto stop_iscsi_func;
+
+	/* Record BDQ producer doorbell addresses */
+	qedi->bdq_primary_prod = qedi->dev_info.primary_dbq_rq_addr;
+	qedi->bdq_secondary_prod = qedi->dev_info.secondary_bdq_rq_addr;
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_DISC,
+		  "BDQ primary_prod=%p secondary_prod=%p.\n",
+		  qedi->bdq_primary_prod,
+		  qedi->bdq_secondary_prod);
+
+	/*
+	 * We need to write the number of BDs in the BDQ we've preallocated so
+	 * the f/w will do a prefetch and we'll get an unsolicited CQE when a
+	 * packet arrives.
+	 */
+	qedi->bdq_prod_idx = QEDI_BDQ_NUM;
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_DISC,
+		  "Writing %d to primary and secondary BDQ doorbell registers.\n",
+		  qedi->bdq_prod_idx);
+	writew(qedi->bdq_prod_idx, qedi->bdq_primary_prod);
+	tmp = readw(qedi->bdq_primary_prod);
+	writew(qedi->bdq_prod_idx, qedi->bdq_secondary_prod);
+	tmp = readw(qedi->bdq_secondary_prod);
+
+	ether_addr_copy(qedi->mac, qedi->dev_info.common.hw_mac);
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_DISC, "MAC address is %pM.\n",
+		  qedi->mac);
+
+	sprintf(host_buf, "host_%d", qedi->shost->host_no);
+	qedi_ops->common->set_id(qedi->cdev, host_buf, QEDI_MODULE_VERSION);
+
+	qedi_ops->register_ops(qedi->cdev, &qedi_cb_ops, qedi);
+
+	memset(&params, 0, sizeof(params));
+	params.mtu = DEF_PATH_MTU + IPV6_HDR_LEN + TCP_HDR_LEN;
+	qedi->ll2_mtu = DEF_PATH_MTU;
+	params.drop_ttl0_packets = 0;
+	params.rx_vlan_stripping = 1;
+	ether_addr_copy(params.ll2_mac_address, qedi->dev_info.common.hw_mac);
+
+	if (mode != QEDI_MODE_RECOVERY) {
+		/* set up rx path */
+		INIT_LIST_HEAD(&qedi->ll2_skb_list);
+		spin_lock_init(&qedi->ll2_lock);
+		/* start qedi context */
+		spin_lock_init(&qedi->hba_lock);
+		spin_lock_init(&qedi->task_idx_lock);
+	}
+	qedi_ops->ll2->register_cb_ops(qedi->cdev, &qedi_ll2_cb_ops, qedi);
+	qedi_ops->ll2->start(qedi->cdev, &params);
+
+	if (mode != QEDI_MODE_RECOVERY) {
+		qedi->ll2_recv_thread = kthread_run(qedi_ll2_recv_thread,
+						    (void *)qedi,
+						    "qedi_ll2_thread");
+	}
+
+	rc = qedi_ops->start(qedi->cdev, &qedi->tasks,
+			     qedi, qedi_iscsi_event_cb);
+	if (rc) {
+		rc = -ENODEV;
+		QEDI_ERR(&qedi->dbg_ctx, "Cannot start iSCSI function\n");
+		goto stop_slowpath;
+	}
+
+	task_start = qedi_get_task_mem(&qedi->tasks, 0);
+	task_end = qedi_get_task_mem(&qedi->tasks, MAX_TID_BLOCKS_ISCSI - 1);
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_DISC,
+		  "Task context start=%p, end=%p block_size=%u.\n",
+		   task_start, task_end, qedi->tasks.size);
+
+	memset(&link_params, 0, sizeof(link_params));
+	link_params.link_up = true;
+	rc = qedi_ops->common->set_link(qedi->cdev, &link_params);
+	if (rc) {
+		QEDI_WARN(&qedi->dbg_ctx, "Link set up failed.\n");
+		atomic_set(&qedi->link_state, QEDI_LINK_DOWN);
+	}
+
+#ifdef CONFIG_DEBUG_FS
+	qedi_dbg_host_init(&qedi->dbg_ctx, &qedi_debugfs_ops,
+			   &qedi_dbg_fops);
+#endif
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+		  "QLogic FastLinQ iSCSI Module qedi %s, FW %d.%d.%d.%d\n",
+		  QEDI_MODULE_VERSION, FW_MAJOR_VERSION, FW_MINOR_VERSION,
+		  FW_REVISION_VERSION, FW_ENGINEERING_VERSION);
+
+	if (mode == QEDI_MODE_NORMAL) {
+		if (iscsi_host_add(qedi->shost, &pdev->dev)) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "Could not add iscsi host\n");
+			rc = -ENOMEM;
+			goto remove_host;
+		}
+
+		/* Allocate uio buffers */
+		rc = qedi_alloc_uio_rings(qedi);
+		if (rc) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "UIO alloc ring failed err=%d\n", rc);
+			goto remove_host;
+		}
+
+		rc = qedi_init_uio(qedi);
+		if (rc) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "UIO init failed, err=%d\n", rc);
+			goto free_uio;
+		}
+
+		/* host the array on iscsi_conn */
+		rc = qedi_setup_cid_que(qedi);
+		if (rc) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "Could not setup cid que\n");
+			goto free_uio;
+		}
+
+		rc = qedi_cm_alloc_mem(qedi);
+		if (rc) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "Could not alloc cm memory\n");
+			goto free_cid_que;
+		}
+
+		rc = qedi_alloc_itt(qedi);
+		if (rc) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "Could not alloc itt memory\n");
+			goto free_cid_que;
+		}
+
+		sprintf(host_buf, "host_%d", qedi->shost->host_no);
+		qedi->tmf_thread = create_singlethread_workqueue(host_buf);
+		if (!qedi->tmf_thread) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "Unable to start tmf thread!\n");
+			rc = -ENODEV;
+			goto free_cid_que;
+		}
+
+		sprintf(host_buf, "qedi_ofld%d", qedi->shost->host_no);
+		qedi->offload_thread = create_workqueue(host_buf);
+		if (!qedi->offload_thread) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "Unable to start offload thread!\n");
+			rc = -ENODEV;
+			goto free_cid_que;
+		}
+
+		/* F/w needs 1st task context memory entry for performance */
+		set_bit(QEDI_RESERVE_TASK_ID, qedi->task_idx_map);
+		atomic_set(&qedi->num_offloads, 0);
+	}
+
+	return 0;
+
+free_cid_que:
+	qedi_release_cid_que(qedi);
+free_uio:
+	qedi_free_uio(qedi->udev);
+remove_host:
+#ifdef CONFIG_DEBUG_FS
+	qedi_dbg_host_exit(&qedi->dbg_ctx);
+#endif
+	iscsi_host_remove(qedi->shost);
+stop_iscsi_func:
+	qedi_ops->stop(qedi->cdev);
+stop_slowpath:
+	qedi_ops->common->slowpath_stop(qedi->cdev);
+stop_hw:
+	qedi_ops->common->remove(qedi->cdev);
+free_pf_params:
+	qedi_free_iscsi_pf_param(qedi);
+free_host:
+	iscsi_host_free(qedi->shost);
+exit_probe:
+	return rc;
+}
+
+static int qedi_probe(struct pci_dev *pdev, const struct pci_device_id *id)
+{
+	return __qedi_probe(pdev, QEDI_MODE_NORMAL);
+}
+
+static void qedi_remove(struct pci_dev *pdev)
+{
+	__qedi_remove(pdev, QEDI_MODE_NORMAL);
+}
+
+static struct pci_device_id qedi_pci_tbl[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, 0x165E) },
+	{ 0 },
+};
+MODULE_DEVICE_TABLE(pci, qedi_pci_tbl);
+
+static struct pci_driver qedi_pci_driver = {
+	.name = QEDI_MODULE_NAME,
+	.id_table = qedi_pci_tbl,
+	.probe = qedi_probe,
+	.remove = qedi_remove,
+};
+
+static int __init qedi_init(void)
+{
+	int rc = 0;
+	int ret;
+	struct qedi_percpu_s *p;
+	unsigned int cpu = 0;
+
+	qedi_ops = qed_get_iscsi_ops();
+	if (!qedi_ops) {
+		QEDI_ERR(NULL, "Failed to get qed iSCSI operations\n");
+		rc = -EINVAL;
+		goto exit_qedi_init_0;
+	}
+
+#ifdef CONFIG_DEBUG_FS
+	qedi_dbg_init("qedi");
+#endif
+
+	qedi_scsi_transport = iscsi_register_transport(&qedi_iscsi_transport);
+	if (!qedi_scsi_transport) {
+		QEDI_ERR(NULL, "Could not register qedi transport");
+		rc = -ENOMEM;
+		goto exit_qedi_init_1;
+	}
+
+	register_hotcpu_notifier(&qedi_cpu_notifier);
+
+	ret = pci_register_driver(&qedi_pci_driver);
+	if (ret) {
+		QEDI_ERR(NULL, "Failed to register driver\n");
+		rc = -EINVAL;
+		goto exit_qedi_init_2;
+	}
+
+	for_each_possible_cpu(cpu) {
+		p = &per_cpu(qedi_percpu, cpu);
+		INIT_LIST_HEAD(&p->work_list);
+		spin_lock_init(&p->p_work_lock);
+		p->iothread = NULL;
+	}
+
+	for_each_online_cpu(cpu)
+		qedi_percpu_thread_create(cpu);
+
+	return rc;
+
+exit_qedi_init_2:
+	iscsi_unregister_transport(&qedi_iscsi_transport);
+exit_qedi_init_1:
+#ifdef CONFIG_DEBUG_FS
+	qedi_dbg_exit();
+#endif
+	qed_put_iscsi_ops();
+exit_qedi_init_0:
+	return rc;
+}
+
+static void __exit qedi_cleanup(void)
+{
+	unsigned int cpu = 0;
+
+	for_each_online_cpu(cpu)
+		qedi_percpu_thread_destroy(cpu);
+
+	pci_unregister_driver(&qedi_pci_driver);
+	unregister_hotcpu_notifier(&qedi_cpu_notifier);
+	iscsi_unregister_transport(&qedi_iscsi_transport);
+
+#ifdef CONFIG_DEBUG_FS
+	qedi_dbg_exit();
+#endif
+	qed_put_iscsi_ops();
+}
+
+MODULE_DESCRIPTION("QLogic FastLinQ 4xxxx iSCSI Module");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("QLogic Corporation");
+MODULE_VERSION(QEDI_MODULE_VERSION);
+module_init(qedi_init);
+module_exit(qedi_cleanup);
diff --git a/drivers/scsi/qedi/qedi_sysfs.c b/drivers/scsi/qedi/qedi_sysfs.c
new file mode 100644
index 0000000..b10c48b
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_sysfs.c
@@ -0,0 +1,52 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include "qedi.h"
+#include "qedi_gbl.h"
+#include "qedi_iscsi.h"
+#include "qedi_dbg.h"
+
+static inline struct qedi_ctx *qedi_dev_to_hba(struct device *dev)
+{
+	struct Scsi_Host *shost = class_to_shost(dev);
+
+	return iscsi_host_priv(shost);
+}
+
+static ssize_t qedi_show_port_state(struct device *dev,
+				    struct device_attribute *attr,
+				    char *buf)
+{
+	struct qedi_ctx *qedi = qedi_dev_to_hba(dev);
+
+	if (atomic_read(&qedi->link_state) == QEDI_LINK_UP)
+		return sprintf(buf, "Online\n");
+	else
+		return sprintf(buf, "Linkdown\n");
+}
+
+static ssize_t qedi_show_speed(struct device *dev,
+			       struct device_attribute *attr, char *buf)
+{
+	struct qedi_ctx *qedi = qedi_dev_to_hba(dev);
+	struct qed_link_output if_link;
+
+	qedi_ops->common->get_link(qedi->cdev, &if_link);
+
+	return sprintf(buf, "%d Gbit\n", if_link.speed / 1000);
+}
+
+static DEVICE_ATTR(port_state, 0444, qedi_show_port_state, NULL);
+static DEVICE_ATTR(speed, 0444, qedi_show_speed, NULL);
+
+struct device_attribute *qedi_shost_attrs[] = {
+	&dev_attr_port_state,
+	&dev_attr_speed,
+	NULL
+};
diff --git a/drivers/scsi/qedi/qedi_version.h b/drivers/scsi/qedi/qedi_version.h
new file mode 100644
index 0000000..9543a1b
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_version.h
@@ -0,0 +1,14 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#define QEDI_MODULE_VERSION	"8.10.3.0"
+#define QEDI_DRIVER_MAJOR_VER		8
+#define QEDI_DRIVER_MINOR_VER		10
+#define QEDI_DRIVER_REV_VER		3
+#define QEDI_DRIVER_ENG_VER		0
-- 
1.8.3.1
