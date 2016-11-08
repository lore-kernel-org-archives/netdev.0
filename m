From: Manish Rangankar <manish.rangankar@cavium.com>
Subject: [PATCH v2 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver framework.
Date: Mon, 7 Nov 2016 22:57:00 -0800
Message-ID: <1478588223-16183-4-git-send-email-manish.rangankar@cavium.com>
References: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>,
        <QLogic-Storage-Upstream@cavium.com>, <Yuval.Mintz@cavium.com>
To: <martin.petersen@oracle.com>, <lduncan@suse.com>,
        <cleech@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0067.outbound.protection.outlook.com ([104.47.38.67]:52179
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932852AbcKHJdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Nov 2016 04:33:16 -0500
In-Reply-To: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The QLogic FastLinQ Driver for iSCSI (qedi) is the iSCSI specific module
for 41000 Series Converged Network Adapters by QLogic.

This patch consists of following changes:
  - MAINTAINERS Makefile and Kconfig changes for qedi,
  - PCI driver registration,
  - iSCSI host level initialization,
  - Debugfs and log level infrastructure.

Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
Signed-off-by: Arun Easi <arun.easi@cavium.com>
Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
---
 MAINTAINERS                         |    6 +
 drivers/net/ethernet/qlogic/Kconfig |   12 -
 drivers/scsi/Kconfig                |    1 +
 drivers/scsi/Makefile               |    1 +
 drivers/scsi/qedi/Kconfig           |   10 +
 drivers/scsi/qedi/Makefile          |    5 +
 drivers/scsi/qedi/qedi.h            |  291 +++++++
 drivers/scsi/qedi/qedi_dbg.c        |  143 ++++
 drivers/scsi/qedi/qedi_dbg.h        |  144 ++++
 drivers/scsi/qedi/qedi_debugfs.c    |  244 ++++++
 drivers/scsi/qedi/qedi_hsi.h        |   52 ++
 drivers/scsi/qedi/qedi_main.c       | 1616 +++++++++++++++++++++++++++++++++++
 drivers/scsi/qedi/qedi_sysfs.c      |   52 ++
 drivers/scsi/qedi/qedi_version.h    |   14 +
 14 files changed, 2579 insertions(+), 12 deletions(-)
 create mode 100644 drivers/scsi/qedi/Kconfig
 create mode 100644 drivers/scsi/qedi/Makefile
 create mode 100644 drivers/scsi/qedi/qedi.h
 create mode 100644 drivers/scsi/qedi/qedi_dbg.c
 create mode 100644 drivers/scsi/qedi/qedi_dbg.h
 create mode 100644 drivers/scsi/qedi/qedi_debugfs.c
 create mode 100644 drivers/scsi/qedi/qedi_hsi.h
 create mode 100644 drivers/scsi/qedi/qedi_main.c
 create mode 100644 drivers/scsi/qedi/qedi_sysfs.c
 create mode 100644 drivers/scsi/qedi/qedi_version.h

diff --git a/MAINTAINERS b/MAINTAINERS
index e5c17a9..04eec14 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9934,6 +9934,12 @@ F:	drivers/net/ethernet/qlogic/qed/
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
diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index 2832570..3cfd105 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -113,16 +113,4 @@ config QED_RDMA
 config QED_ISCSI
 	bool
 
-config QEDI
-	tristate "QLogic QED 25/40/100Gb iSCSI driver"
-	depends on QED
-	select QED_LL2
-	select QED_ISCSI
-	default n
-	---help---
-	  This provides a temporary node that allows the compilation
-	  and logical testing of the hardware offload iSCSI support
-	  for QLogic QED. This would be replaced by the 'real' option
-	  once the QEDI driver is added [+relocated].
-
 endif # NET_VENDOR_QLOGIC
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
index 0000000..92136a3
--- /dev/null
+++ b/drivers/scsi/qedi/qedi.h
@@ -0,0 +1,291 @@
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
+#define MIN_NUM_CPUS_MSIX(x)	min(x->msix_count, num_online_cpus())
+
+#define QEDI_LOCAL_PORT_MIN     60000
+#define QEDI_LOCAL_PORT_MAX     61024
+#define QEDI_LOCAL_PORT_RANGE   (QEDI_LOCAL_PORT_MAX - QEDI_LOCAL_PORT_MIN)
+#define QEDI_LOCAL_PORT_INVALID	0xffff
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
+	u64 hw_p_cpuq;
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
index 0000000..b03d9af
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
+	if (!(debug & QEDI_LOG_WARN))
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
+	if (!(debug & QEDI_LOG_NOTICE))
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
+	if (!(debug & level))
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
index 0000000..5beb3ec
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
+extern uint debug;
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
+void qedi_dbg_err(struct qedi_dbg_ctx *, const char *, u32,
+		  const char *, ...);
+void qedi_dbg_warn(struct qedi_dbg_ctx *, const char *, u32,
+		   const char *, ...);
+void qedi_dbg_notice(struct qedi_dbg_ctx *, const char *, u32,
+		     const char *, ...);
+void qedi_dbg_info(struct qedi_dbg_ctx *, const char *, u32, u32,
+		   const char *, ...);
+
+struct Scsi_Host;
+
+struct sysfs_bin_attrs {
+	char *name;
+	struct bin_attribute *attr;
+};
+
+int qedi_create_sysfs_attr(struct Scsi_Host *,
+			   struct sysfs_bin_attrs *);
+void qedi_remove_sysfs_attr(struct Scsi_Host *,
+			    struct sysfs_bin_attrs *);
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
+void qedi_dbg_host_init(struct qedi_dbg_ctx *,
+			struct qedi_debugfs_ops *,
+			const struct file_operations *);
+void qedi_dbg_host_exit(struct qedi_dbg_ctx *);
+void qedi_dbg_init(char *);
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
diff --git a/drivers/scsi/qedi/qedi_main.c b/drivers/scsi/qedi/qedi_main.c
new file mode 100644
index 0000000..5845dc9
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_main.c
@@ -0,0 +1,1616 @@
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
+
+static uint fw_debug;
+module_param(fw_debug, uint, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(fw_debug, " Firmware debug level 0(default) to 3");
+
+static uint int_mode;
+module_param(int_mode, uint, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(int_mode,
+		 " Force interrupt mode other than MSI-X: (1 INT#x; 2 MSI)");
+
+uint debug = QEDI_LOG_WARN | QEDI_LOG_SCSI_TM;
+module_param(debug, uint, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(debug, " Default debug level");
+
+const struct qed_iscsi_ops *qedi_ops;
+static struct scsi_transport_template *qedi_scsi_transport;
+static struct pci_driver qedi_pci_driver;
+static DEFINE_PER_CPU(struct qedi_percpu_s, qedi_percpu);
+/* Static function declaration */
+static int qedi_alloc_global_queues(struct qedi_ctx *qedi);
+static void qedi_free_global_queues(struct qedi_ctx *qedi);
+static struct qedi_cmd *qedi_get_cmd_from_tid(struct qedi_ctx *qedi, u32 tid);
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
+static enum qed_int_mode qedi_int_mode_to_enum(void)
+{
+	switch (int_mode) {
+	case 0: return QED_INT_MODE_MSIX;
+	case 1: return QED_INT_MODE_INTA;
+	case 2: return QED_INT_MODE_MSI;
+	default:
+		QEDI_ERR(NULL, "Unknown qede_int_mode=%08x; "
+			 "Defaulting to MSI-x\n", int_mode);
+		return QED_INT_MODE_MSIX;
+	}
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
+	qedi->pf_params.iscsi_pf_params.debug_mode = fw_debug;
+
+	for (log_page_size = 0 ; log_page_size < 32 ; log_page_size++) {
+		if ((1 << log_page_size) == PAGE_SIZE)
+			break;
+	}
+	qedi->pf_params.iscsi_pf_params.log_page_size = log_page_size;
+
+	qedi->pf_params.iscsi_pf_params.glbl_q_params_addr = qedi->hw_p_cpuq;
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
+	sp_params.int_mode = qedi_int_mode_to_enum();
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
index 0000000..a2cc3ed
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
+static DEVICE_ATTR(port_state, S_IRUGO, qedi_show_port_state, NULL);
+static DEVICE_ATTR(speed, S_IRUGO, qedi_show_speed, NULL);
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
