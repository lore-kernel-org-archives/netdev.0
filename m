From: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC 2/5] qedf: Add QLogic FastLinQ offload FCoE
	driver framework.
Date: Fri, 23 Dec 2016 11:17:05 -0800
Message-ID: <1482520628-24207-3-git-send-email-chad.dupuis@cavium.com>
References: <1482520628-24207-1-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 QLogic-Storage-Upstream-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <1482520628-24207-1-git-send-email-chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://lists.open-fcoe.org/mailman/options/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/fcoe-devel/>
List-Post: <mailto:fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open-fcoe.org/mailman/listinfo/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: "fcoe-devel" <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

The QLogic FastLinQ Driver for FCoE (qedf) is the FCoE specific module
for 41000 Series Converged Network Adapters by QLogic.

This patch consists of following changes:
  - MAINTAINERS Makefile and Kconfig changes for qedf
  - PCI driver registration
  - libfc/fcoe host level initialization
  - SCSI host template initialization and callbacks
  - Debugfs and log level infrastructure
  - Link handling
  - Firmware interface structures
  - QED core module initialization
  - Light L2 interface callbacks

Signed-off-by: Nilesh Javali <nilesh.javali-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Manish Rangankar <manish.rangankar-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Saurav Kashyap <saurav.kashyap-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Chad Dupuis <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 MAINTAINERS                      |    6 +
 drivers/scsi/Kconfig             |    1 +
 drivers/scsi/qedf/Kconfig        |   11 +
 drivers/scsi/qedf/Makefile       |    5 +
 drivers/scsi/qedf/qedf.h         |  555 ++++++
 drivers/scsi/qedf/qedf_attr.c    |  165 ++
 drivers/scsi/qedf/qedf_dbg.c     |  192 +++
 drivers/scsi/qedf/qedf_dbg.h     |  153 ++
 drivers/scsi/qedf/qedf_debugfs.c |  472 +++++
 drivers/scsi/qedf/qedf_main.c    | 3519 ++++++++++++++++++++++++++++++++++++++
 drivers/scsi/qedf/qedf_version.h |   15 +
 11 files changed, 5094 insertions(+)
 create mode 100644 drivers/scsi/qedf/Kconfig
 create mode 100644 drivers/scsi/qedf/Makefile
 create mode 100644 drivers/scsi/qedf/qedf.h
 create mode 100644 drivers/scsi/qedf/qedf_attr.c
 create mode 100644 drivers/scsi/qedf/qedf_dbg.c
 create mode 100644 drivers/scsi/qedf/qedf_dbg.h
 create mode 100644 drivers/scsi/qedf/qedf_debugfs.c
 create mode 100644 drivers/scsi/qedf/qedf_main.c
 create mode 100644 drivers/scsi/qedf/qedf_version.h

diff --git a/MAINTAINERS b/MAINTAINERS
index f6eb97b..085d8a0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10136,6 +10136,12 @@ F:	drivers/net/ethernet/qlogic/qed/
 F:	include/linux/qed/
 F:	drivers/net/ethernet/qlogic/qede/
 
+QLOGIC QL41xxx FCoE DRIVER
+M:	QLogic-Storage-Upstream-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
+L:	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+S:	Supported
+F:	drivers/scsi/qedf/
+
 QNX4 FILESYSTEM
 M:	Anders Larsen <al-V9/YLgxv/GvR7s880joybQ@public.gmane.org>
 W:	http://www.alarsen.net/linux/qnx4fs/
diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
index dfa9334..0c69a2d 100644
--- a/drivers/scsi/Kconfig
+++ b/drivers/scsi/Kconfig
@@ -1233,6 +1233,7 @@ config SCSI_QLOGICPTI
 
 source "drivers/scsi/qla2xxx/Kconfig"
 source "drivers/scsi/qla4xxx/Kconfig"
+source "drivers/scsi/qedf/Kconfig"
 
 config SCSI_LPFC
 	tristate "Emulex LightPulse Fibre Channel Support"
diff --git a/drivers/scsi/qedf/Kconfig b/drivers/scsi/qedf/Kconfig
new file mode 100644
index 0000000..943f5ee
--- /dev/null
+++ b/drivers/scsi/qedf/Kconfig
@@ -0,0 +1,11 @@
+config QEDF
+	tristate "QLogic QEDF 25/40/100Gb FCoE Initiator Driver Support"
+	depends on PCI && SCSI
+	depends on QED
+        depends on LIBFC
+        depends on LIBFCOE
+	select QED_LL2
+	select QED_FCOE
+	---help---
+	This driver supports FCoE offload for the QLogic FastLinQ
+	41000 Series Converged Network Adapters.
diff --git a/drivers/scsi/qedf/Makefile b/drivers/scsi/qedf/Makefile
new file mode 100644
index 0000000..b2077d5
--- /dev/null
+++ b/drivers/scsi/qedf/Makefile
@@ -0,0 +1,5 @@
+obj-$(CONFIG_QEDF) := qedf.o
+qedf-objs = qedf_dbg.o qedf_main.o qedf_io.o qedf_fip.o \
+	    qedf_attr.o qedf_els.o
+
+qedf-$(CONFIG_DEBUG_FS) += qedf_debugfs.o
diff --git a/drivers/scsi/qedf/qedf.h b/drivers/scsi/qedf/qedf.h
new file mode 100644
index 0000000..279ec25
--- /dev/null
+++ b/drivers/scsi/qedf/qedf.h
@@ -0,0 +1,555 @@
+/*
+ *  QLogic FCoE Offload Driver
+ *  Copyright (c) 2016 Cavium Inc.
+ *
+ *  This software is available under the terms of the GNU General Public License
+ *  (GPL) Version 2, available from the file COPYING in the main directory of
+ *  this source tree.
+ */
+#ifndef _QEDFC_H_
+#define _QEDFC_H_
+
+#include <scsi/libfcoe.h>
+#include <scsi/libfc.h>
+#include <scsi/fc/fc_fip.h>
+#include <scsi/fc/fc_fc2.h>
+#include <scsi/scsi_tcq.h>
+#include <scsi/fc_encode.h>
+#include <linux/version.h>
+
+
+/* qedf_hsi.h needs to before included any qed includes */
+#include "qedf_hsi.h"
+
+#include <linux/qed/qed_if.h>
+#include <linux/qed/qed_fcoe_if.h>
+#include <linux/qed/qed_ll2_if.h>
+#include "qedf_version.h"
+#include "qedf_dbg.h"
+
+/* Helpers to extract upper and lower 32-bits of pointer */
+#define U64_HI(val) ((u32)(((u64)(val)) >> 32))
+#define U64_LO(val) ((u32)(((u64)(val)) & 0xffffffff))
+
+#define QEDF_DESCR "QLogic FCoE Offload Driver"
+#define QEDF_MODULE_NAME "qedf"
+
+#define QEDF_MIN_XID		0
+#define QEDF_MAX_SCSI_XID	(NUM_TASKS_PER_CONNECTION - 1)
+#define QEDF_MAX_ELS_XID	4095
+#define QEDF_FLOGI_RETRY_CNT	3
+#define QEDF_RPORT_RETRY_CNT	255
+#define QEDF_MAX_SESSIONS	1024
+#define QEDF_MAX_PAYLOAD	2048
+#define QEDF_MAX_BDS_PER_CMD	256
+#define QEDF_MAX_BD_LEN		0xffff
+#define QEDF_BD_SPLIT_SZ	0x1000
+#define QEDF_PAGE_SIZE		4096
+#define QED_HW_DMA_BOUNDARY     0xfff
+#define QEDF_MAX_SGLEN_FOR_CACHESGL		((1U << 16) - 1)
+#define QEDF_MFS		(QEDF_MAX_PAYLOAD + \
+	sizeof(struct fc_frame_header))
+#define QEDF_MAX_NPIV		64
+#define QEDF_TM_TIMEOUT		10
+#define QEDF_ABORT_TIMEOUT	10
+#define QEDF_CLEANUP_TIMEOUT	10
+#define QEDF_MAX_CDB_LEN	16
+
+#define UPSTREAM_REMOVE		1
+#define UPSTREAM_KEEP		1
+
+struct qedf_mp_req {
+	uint8_t tm_flags;
+
+	uint32_t req_len;
+	void *req_buf;
+	dma_addr_t req_buf_dma;
+	struct fcoe_sge *mp_req_bd;
+	dma_addr_t mp_req_bd_dma;
+	struct fc_frame_header req_fc_hdr;
+
+	uint32_t resp_len;
+	void *resp_buf;
+	dma_addr_t resp_buf_dma;
+	struct fcoe_sge *mp_resp_bd;
+	dma_addr_t mp_resp_bd_dma;
+	struct fc_frame_header resp_fc_hdr;
+};
+
+struct qedf_els_cb_arg {
+	struct qedf_ioreq *aborted_io_req;
+	struct qedf_ioreq *io_req;
+	u8 op; /* Used to keep track of ELS op */
+	uint16_t l2_oxid;
+	u32 offset; /* Used for sequence cleanup */
+	u8 r_ctl; /* Used for sequence cleanup */
+};
+
+enum qedf_ioreq_event {
+	QEDF_IOREQ_EV_ABORT_SUCCESS,
+	QEDF_IOREQ_EV_ABORT_FAILED,
+	QEDF_IOREQ_EV_SEND_RRQ,
+	QEDF_IOREQ_EV_ELS_TMO,
+	QEDF_IOREQ_EV_ELS_ERR_DETECT,
+	QEDF_IOREQ_EV_ELS_FLUSH,
+	QEDF_IOREQ_EV_CLEANUP_SUCCESS,
+	QEDF_IOREQ_EV_CLEANUP_FAILED,
+};
+
+#define FC_GOOD		0
+#define FCOE_FCP_RSP_FLAGS_FCP_RESID_OVER	(0x1<<2)
+#define FCOE_FCP_RSP_FLAGS_FCP_RESID_UNDER	(0x1<<3)
+#define CMD_SCSI_STATUS(Cmnd)			((Cmnd)->SCp.Status)
+#define FCOE_FCP_RSP_FLAGS_FCP_RSP_LEN_VALID	(0x1<<0)
+#define FCOE_FCP_RSP_FLAGS_FCP_SNS_LEN_VALID	(0x1<<1)
+struct qedf_ioreq {
+	struct list_head link;
+	uint16_t xid;
+	struct scsi_cmnd *sc_cmd;
+	bool use_slowpath; /* Use slow SGL for this I/O */
+#define QEDF_SCSI_CMD		1
+#define QEDF_TASK_MGMT_CMD	2
+#define QEDF_ABTS		3
+#define QEDF_ELS		4
+#define QEDF_CLEANUP		5
+#define QEDF_SEQ_CLEANUP	6
+	u8 cmd_type;
+#define QEDF_CMD_OUTSTANDING		0x0
+#define QEDF_CMD_IN_ABORT		0x1
+#define QEDF_CMD_IN_CLEANUP		0x2
+#define QEDF_CMD_SRR_SENT		0x3
+	u8 io_req_flags;
+	struct qedf_rport *fcport;
+	unsigned long flags;
+	enum qedf_ioreq_event event;
+	size_t data_xfer_len;
+	struct kref refcount;
+	struct qedf_cmd_mgr *cmd_mgr;
+	struct io_bdt *bd_tbl;
+	struct delayed_work timeout_work;
+	struct completion tm_done;
+	struct completion abts_done;
+	struct fcoe_task_context *task;
+	int idx;
+/*
+ * Need to allocate enough room for both sense data and FCP response data
+ * which has a max length of 8 bytes according to spec.
+ */
+#define QEDF_SCSI_SENSE_BUFFERSIZE	(SCSI_SENSE_BUFFERSIZE + 8)
+	uint8_t *sense_buffer;
+	dma_addr_t sense_buffer_dma;
+	u32 fcp_resid;
+	u32 fcp_rsp_len;
+	u32 fcp_sns_len;
+	u8 cdb_status;
+	u8 fcp_status;
+	u8 fcp_rsp_code;
+	u8 scsi_comp_flags;
+#define QEDF_MAX_REUSE		0xfff
+	u16 reuse_count;
+	struct qedf_mp_req mp_req;
+	void (*cb_func)(struct qedf_els_cb_arg *cb_arg);
+	struct qedf_els_cb_arg *cb_arg;
+	int fp_idx;
+	unsigned int cpu;
+	unsigned int int_cpu;
+#define QEDF_IOREQ_SLOW_SGE		0
+#define QEDF_IOREQ_SINGLE_SGE		1
+#define QEDF_IOREQ_FAST_SGE		2
+	u8 sge_type;
+	struct delayed_work rrq_work;
+
+	/* Used for sequence level recovery; i.e. REC/SRR */
+	uint32_t rx_buf_off;
+	uint32_t tx_buf_off;
+	uint32_t rx_id;
+	uint32_t task_retry_identifier;
+
+	/*
+	 * Used to tell if we need to return a SCSI command
+	 * during some form of error processing.
+	 */
+	bool return_scsi_cmd_on_abts;
+};
+
+struct qedf_percpu_iothread_s {
+	struct task_struct *iothread;
+	struct list_head work_list;
+	spinlock_t work_lock;
+	uint64_t requests;
+	uint64_t responses;
+};
+
+struct qedf_rport {
+	spinlock_t rport_lock;
+#define QEDF_RPORT_SESSION_READY 1
+#define QEDF_RPORT_UPLOADING_CONNECTION	2
+	unsigned long flags;
+	unsigned long retry_delay_timestamp;
+	int conn_id;
+	struct fc_rport *rport;
+	struct fc_rport_priv *rdata;
+	struct qedf_ctx *qedf;
+	u32 handle; /* Handle from qed */
+	u32 fw_cid; /* fw_cid from qed */
+	void __iomem *p_doorbell;
+	/* Send queue management */
+	atomic_t free_sqes;
+	atomic_t num_active_ios;
+	struct fcoe_wqe *sq;
+	dma_addr_t sq_dma;
+	u16 sq_prod_idx;
+	u16 fw_sq_prod_idx;
+	u16 sq_con_idx;
+	u32 sq_mem_size;
+	void *sq_pbl;
+	dma_addr_t sq_pbl_dma;
+	u32 sq_pbl_size;
+	u32 sid;
+#define	QEDF_RPORT_TYPE_DISK		1
+#define	QEDF_RPORT_TYPE_TAPE		2
+	uint dev_type; /* Disk or tape */
+};
+
+/* Used to contain LL2 skb's in ll2_skb_list */
+struct qedf_skb_work {
+	struct list_head list;
+	struct sk_buff *skb;
+};
+
+struct qedf_fastpath {
+#define	QEDF_SB_ID_NULL		0xffff
+	u16		sb_id;
+	struct qed_sb_info	*sb_info;
+	struct qedf_ctx *qedf;
+	/* Keep track of number of completions on this fastpath */
+	unsigned long completions;
+	uint32_t cq_num_entries;
+};
+
+/* Used to pass fastpath information needed to process CQEs */
+struct qedf_io_work {
+	struct list_head list;
+	struct fcoe_cqe cqe;
+	struct qedf_ctx *qedf;
+	struct fc_frame *fp;
+};
+
+struct qedf_glbl_q_params {
+	u64	hw_p_cq;	/* Completion queue PBL */
+	u64	hw_p_rq;	/* Request queue PBL */
+	u64	hw_p_cmdq;	/* Command queue PBL */
+};
+
+struct global_queue {
+	struct fcoe_cqe *cq;
+	dma_addr_t cq_dma;
+	u32 cq_mem_size;
+	u32 cq_cons_idx; /* Completion queue consumer index */
+	u32 cq_prod_idx;
+
+	void *cq_pbl;
+	dma_addr_t cq_pbl_dma;
+	u32 cq_pbl_size;
+};
+
+/* I/O tracing entry */
+#define QEDF_IO_TRACE_SIZE		2048
+struct qedf_io_log {
+#define QEDF_IO_TRACE_REQ		0
+#define QEDF_IO_TRACE_RSP		1
+	uint8_t direction;
+	uint16_t task_id;
+	uint32_t port_id; /* Remote port fabric ID */
+	int lun;
+	char op; /* SCSI CDB */
+	uint8_t lba[4];
+	unsigned int bufflen; /* SCSI buffer length */
+	unsigned int sg_count; /* Number of SG elements */
+	int result; /* Result passed back to mid-layer */
+	unsigned long jiffies; /* Time stamp when I/O logged */
+	int refcount; /* Reference count for task id */
+	unsigned int req_cpu; /* CPU that the task is queued on */
+	unsigned int int_cpu; /* Interrupt CPU that the task is received on */
+	unsigned int rsp_cpu; /* CPU that task is returned on */
+	u8 sge_type; /* Did we take the slow, single or fast SGE path */
+};
+
+/* Number of entries in BDQ */
+#define QEDF_BDQ_SIZE			256
+#define QEDF_BDQ_BUF_SIZE		2072
+
+/* DMA coherent buffers for BDQ */
+struct qedf_bdq_buf {
+	void *buf_addr;
+	dma_addr_t buf_dma;
+};
+
+/* Main adapter struct */
+struct qedf_ctx {
+	struct qedf_dbg_ctx dbg_ctx;
+	struct fcoe_ctlr ctlr;
+	struct fc_lport *lport;
+	u8 data_src_addr[ETH_ALEN];
+#define QEDF_LINK_DOWN		0
+#define QEDF_LINK_UP		1
+	atomic_t link_state;
+#define QEDF_DCBX_PENDING	0
+#define QEDF_DCBX_DONE		1
+	atomic_t dcbx;
+	uint16_t max_scsi_xid;
+	uint16_t max_els_xid;
+#define QEDF_NULL_VLAN_ID	-1
+#define QEDF_FALLBACK_VLAN	1002
+#define QEDF_DEFAULT_PRIO	3
+	int vlan_id;
+	uint vlan_hw_insert:1;
+	struct qed_dev *cdev;
+	struct qed_dev_fcoe_info dev_info;
+	struct qed_int_info int_info;
+	uint16_t last_command;
+	spinlock_t hba_lock;
+	struct pci_dev *pdev;
+	u64 wwnn;
+	u64 wwpn;
+	u8 __aligned(16) mac[ETH_ALEN];
+	struct qedf_rport *fcports[QEDF_MAX_SESSIONS];
+	atomic_t num_offloads;
+	unsigned int curr_conn_id;
+	spinlock_t ll2_lock;
+	struct list_head ll2_skb_list;
+	struct task_struct *ll2_recv_thread;
+	struct workqueue_struct *link_update_wq;
+	struct delayed_work link_update;
+	struct delayed_work link_recovery;
+	struct completion flogi_compl;
+	struct completion fipvlan_compl;
+
+	/*
+	 * Used to tell if we're in the window where we are waiting for
+	 * the link to come back up before informting fcoe that the link is
+	 * done.
+	 */
+	atomic_t link_down_tmo_valid;
+#define QEDF_TIMER_INTERVAL		(1 * HZ)
+	struct timer_list timer; /* One second book keeping timer */
+#define QEDF_DRAIN_ACTIVE		1
+#define QEDF_LL2_STARTED		2
+#define QEDF_UNLOADING			3
+#define QEDF_GRCDUMP_CAPTURE		4
+#define QEDF_IN_RECOVERY		5
+	unsigned long flags; /* Miscellaneous state flags */
+	int fipvlan_retries;
+	u8 num_queues;
+	struct global_queue **global_queues;
+	/* Pointer to array of queue structures */
+	struct qedf_glbl_q_params *p_cpuq;
+	/* Physical address of array of queue structures */
+	dma_addr_t hw_p_cpuq;
+
+	struct qedf_bdq_buf bdq[QEDF_BDQ_SIZE];
+	void *bdq_pbl;
+	dma_addr_t bdq_pbl_dma;
+	size_t bdq_pbl_mem_size;
+	void *bdq_pbl_list;
+	dma_addr_t bdq_pbl_list_dma;
+	u8 bdq_pbl_list_num_entries;
+	void __iomem *bdq_primary_prod;
+	void __iomem *bdq_secondary_prod;
+	uint16_t bdq_prod_idx;
+
+	/* Structure for holding all the fastpath for this qedf_ctx */
+	struct qedf_fastpath *fp_array;
+	struct qed_fcoe_tid tasks;
+	struct qedf_cmd_mgr *cmd_mgr;
+	/* Holds the PF parameters we pass to qed to start he FCoE function */
+	struct qed_pf_params pf_params;
+	/* Used to time middle path ELS and TM commands */
+	struct workqueue_struct *timer_work_queue;
+
+#define QEDF_IO_WORK_MIN		64
+	mempool_t *io_mempool;
+	struct workqueue_struct *dpc_wq;
+
+	u32 slow_sge_ios;
+	u32 fast_sge_ios;
+	u32 single_sge_ios;
+
+	uint8_t	*grcdump;
+	uint32_t grcdump_size;
+
+	struct qedf_io_log io_trace_buf[QEDF_IO_TRACE_SIZE];
+	spinlock_t io_trace_lock;
+	uint16_t io_trace_idx;
+
+	bool stop_io_on_error;
+
+	u32 flogi_cnt;
+	u32 flogi_failed;
+
+	/* Used for fc statistics */
+	u64 input_requests;
+	u64 output_requests;
+	u64 control_requests;
+	u64 packet_aborts;
+	u64 alloc_failures;
+};
+
+/*
+ * 4 regs size $$KEEP_ENDIANNESS$$
+ */
+
+struct io_bdt {
+	struct qedf_ioreq *io_req;
+	struct fcoe_sge *bd_tbl;
+	dma_addr_t bd_tbl_dma;
+	u16 bd_valid;
+};
+
+struct qedf_cmd_mgr {
+	struct qedf_ctx *qedf;
+	u16 idx;
+	struct io_bdt **io_bdt_pool;
+#define FCOE_PARAMS_NUM_TASKS		4096
+	struct qedf_ioreq cmds[FCOE_PARAMS_NUM_TASKS];
+	spinlock_t lock;
+	atomic_t free_list_cnt;
+};
+
+/* Stolen from qed_cxt_api.h and adapted for qed_fcoe_info
+ * Usage:
+ *
+ * void *ptr;
+ * ptr = qedf_get_task_mem(&qedf->tasks, 128);
+ */
+static inline void *qedf_get_task_mem(struct qed_fcoe_tid *info, u32 tid)
+{
+	return (void *)(info->blocks[tid / info->num_tids_per_block] +
+			(tid % info->num_tids_per_block) * info->size);
+}
+
+static inline void qedf_stop_all_io(struct qedf_ctx *qedf)
+{
+	set_bit(QEDF_UNLOADING, &qedf->flags);
+}
+
+/*
+ * Externs
+ */
+#define QEDF_DEFAULT_LOG_MASK		0x3CFB6
+extern const struct qed_fcoe_ops *qed_ops;
+extern uint qedf_dump_frames;
+extern uint qedf_io_tracing;
+extern uint qedf_stop_io_on_error;
+extern uint qedf_link_down_tmo;
+#define QEDF_RETRY_DELAY_MAX		20 /* 2 seconds */
+extern bool qedf_retry_delay;
+extern uint qedf_debug;
+
+extern struct qedf_cmd_mgr *qedf_cmd_mgr_alloc(struct qedf_ctx *qedf);
+extern void qedf_cmd_mgr_free(struct qedf_cmd_mgr *cmgr);
+extern int qedf_queuecommand(struct Scsi_Host *host,
+	struct scsi_cmnd *sc_cmd);
+extern void qedf_fip_send(struct fcoe_ctlr *fip, struct sk_buff *skb);
+extern void qedf_update_src_mac(struct fc_lport *lport, u8 *addr);
+extern u8 *qedf_get_src_mac(struct fc_lport *lport);
+extern void qedf_fip_recv(struct qedf_ctx *qedf, struct sk_buff *skb);
+extern void qedf_fcoe_send_vlan_req(struct qedf_ctx *qedf);
+extern void qedf_scsi_completion(struct qedf_ctx *qedf, struct fcoe_cqe *cqe,
+	struct qedf_ioreq *io_req);
+extern void qedf_process_warning_compl(struct qedf_ctx *qedf,
+	struct fcoe_cqe *cqe,struct qedf_ioreq *io_req);
+extern void qedf_process_error_detect(struct qedf_ctx *qedf,
+	struct fcoe_cqe *cqe, struct qedf_ioreq *io_req);
+extern void qedf_flush_active_ios(struct qedf_rport *fcport, int lun);
+extern void qedf_release_cmd(struct kref *ref);
+extern int qedf_initiate_abts(struct qedf_ioreq *io_req,
+	bool return_scsi_cmd_on_abts);
+extern void qedf_process_abts_compl(struct qedf_ctx *qedf, struct fcoe_cqe *cqe,
+	struct qedf_ioreq *io_req);
+extern struct qedf_ioreq *qedf_alloc_cmd(struct qedf_rport *fcport,
+	u8 cmd_type);
+
+extern struct device_attribute *qedf_host_attrs[];
+extern void qedf_cmd_timer_set(struct qedf_ctx *qedf, struct qedf_ioreq *io_req,
+	unsigned int timer_msec);
+extern int qedf_init_mp_req(struct qedf_ioreq *io_req);
+extern void qedf_init_mp_task(struct qedf_ioreq *io_req,
+	struct fcoe_task_context *task_ctx);
+extern void qedf_add_to_sq(struct qedf_rport *fcport, u16 xid,
+	u32 ptu_invalidate, enum fcoe_task_type req_type, u32 offset);
+extern void qedf_ring_doorbell(struct qedf_rport *fcport);
+extern void qedf_process_els_compl(struct qedf_ctx *qedf, struct fcoe_cqe *cqe,
+	struct qedf_ioreq *els_req);
+extern int qedf_send_rrq(struct qedf_ioreq *aborted_io_req);
+extern int qedf_send_adisc(struct qedf_rport *fcport, struct fc_frame *fp);
+extern int qedf_initiate_cleanup(struct qedf_ioreq *io_req,
+	bool return_scsi_cmd_on_abts);
+extern void qedf_process_cleanup_compl(struct qedf_ctx *qedf,
+	struct fcoe_cqe *cqe, struct qedf_ioreq *io_req);
+extern int qedf_initiate_tmf(struct scsi_cmnd *sc_cmd, u8 tm_flags);
+extern void qedf_process_tmf_compl(struct qedf_ctx *qedf, struct fcoe_cqe *cqe,
+	struct qedf_ioreq *io_req);
+extern void qedf_process_cqe(struct qedf_ctx *qedf, struct fcoe_cqe *cqe);
+extern void qedf_scsi_done(struct qedf_ctx *qedf, struct qedf_ioreq *io_req,
+	int result);
+extern void qedf_set_vlan_id(struct qedf_ctx *qedf, int vlan_id);
+extern void qedf_create_sysfs_ctx_attr(struct qedf_ctx *qedf);
+extern void qedf_remove_sysfs_ctx_attr(struct qedf_ctx *qedf);
+extern void qedf_capture_grc_dump(struct qedf_ctx *qedf);
+extern void qedf_wait_for_upload(struct qedf_ctx *qedf);
+extern void qedf_process_unsol_compl(struct qedf_ctx *qedf, uint16_t que_idx,
+	struct fcoe_cqe *cqe);
+extern void qedf_inc_percpu_requests(unsigned long cpu);
+extern void qedf_restart_rport(struct qedf_rport *fcport);
+extern int qedf_send_rec(struct qedf_ioreq *orig_io_req);
+extern int qedf_post_io_req(struct qedf_rport *fcport,
+	struct qedf_ioreq *io_req);
+extern void qedf_process_seq_cleanup_compl(struct qedf_ctx *qedf,
+	struct fcoe_cqe *cqe, struct qedf_ioreq *io_req);
+extern int qedf_send_flogi(struct qedf_ctx *qedf);
+
+#define FCOE_WORD_TO_BYTE  4
+#define QEDF_MAX_TASK_NUM	0xFFFF
+
+struct fip_vlan {
+	struct ethhdr eth;
+	struct fip_header fip;
+	struct {
+		struct fip_mac_desc mac;
+		struct fip_wwn_desc wwnn;
+	} desc;
+};
+
+/* SQ/CQ Sizes */
+#define GBL_RSVD_TASKS			16
+#define NUM_TASKS_PER_CONNECTION	1024
+#define NUM_RW_TASKS_PER_CONNECTION	512
+#define FCOE_PARAMS_CQ_NUM_ENTRIES	FCOE_PARAMS_NUM_TASKS
+
+#define FCOE_PARAMS_CMDQ_NUM_ENTRIES	FCOE_PARAMS_NUM_TASKS
+#define SQ_NUM_ENTRIES			NUM_TASKS_PER_CONNECTION
+
+#define QEDF_FCOE_PARAMS_GL_RQ_PI              0
+#define QEDF_FCOE_PARAMS_GL_CMD_PI             1
+
+#define QEDF_READ                     (1 << 1)
+#define QEDF_WRITE                    (1 << 0)
+#define MAX_FIBRE_LUNS			0xffffffff
+
+#define QEDF_MAX_NUM_CQS		8
+
+/*
+ * PCI function probe defines
+ */
+/* Probe/remove called during normal PCI probe */
+#define	QEDF_MODE_NORMAL		0
+/* Probe/remove called from qed error recovery */
+#define QEDF_MODE_RECOVERY		1
+
+#define SUPPORTED_25000baseKR_Full    (1<<27)
+#define SUPPORTED_50000baseKR2_Full   (1<<28)
+#define SUPPORTED_100000baseKR4_Full  (1<<29)
+#define SUPPORTED_100000baseCR4_Full  (1<<30)
+
+#endif
diff --git a/drivers/scsi/qedf/qedf_attr.c b/drivers/scsi/qedf/qedf_attr.c
new file mode 100644
index 0000000..4772061
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_attr.c
@@ -0,0 +1,165 @@
+/*
+ *  QLogic FCoE Offload Driver
+ *  Copyright (c) 2016 Cavium Inc.
+ *
+ *  This software is available under the terms of the GNU General Public License
+ *  (GPL) Version 2, available from the file COPYING in the main directory of
+ *  this source tree.
+ */
+#include "qedf.h"
+
+static ssize_t
+qedf_fcoe_mac_show(struct device *dev,
+	struct device_attribute *attr, char *buf)
+{
+	struct fc_lport *lport = shost_priv(class_to_shost(dev));
+	u32 port_id;
+	u8 lport_src_id[3];
+	u8 fcoe_mac[6];
+
+	port_id = fc_host_port_id(lport->host);
+	lport_src_id[2] = (port_id & 0x000000FF);
+	lport_src_id[1] = (port_id & 0x0000FF00) >> 8;
+	lport_src_id[0] = (port_id & 0x00FF0000) >> 16;
+	fc_fcoe_set_mac(fcoe_mac, lport_src_id);
+
+	return scnprintf(buf, PAGE_SIZE, "%pM\n", fcoe_mac);
+}
+
+static DEVICE_ATTR(fcoe_mac, S_IRUGO, qedf_fcoe_mac_show, NULL);
+
+struct device_attribute *qedf_host_attrs[] = {
+	&dev_attr_fcoe_mac,
+	NULL,
+};
+
+extern const struct qed_fcoe_ops *qed_ops;
+
+inline bool qedf_is_vport(struct qedf_ctx *qedf)
+{
+	return (!(qedf->lport->vport == NULL));
+}
+
+/* Get base qedf for physical port from vport */
+static struct qedf_ctx *qedf_get_base_qedf(struct qedf_ctx *qedf)
+{
+	struct fc_lport *lport;
+	struct fc_lport *base_lport;
+
+	if (!(qedf_is_vport(qedf)))
+		return NULL;
+
+	lport = qedf->lport;
+	base_lport = shost_priv(vport_to_shost(lport->vport));
+	return (struct qedf_ctx *)(lport_priv(base_lport));
+}
+
+void qedf_capture_grc_dump(struct qedf_ctx *qedf)
+{
+	struct qedf_ctx *base_qedf;
+
+	/* Make sure we use the base qedf to take the GRC dump */
+	if (qedf_is_vport(qedf))
+		base_qedf = qedf_get_base_qedf(qedf);
+	else
+		base_qedf = qedf;
+
+	if (test_bit(QEDF_GRCDUMP_CAPTURE, &base_qedf->flags)) {
+		QEDF_INFO(&(base_qedf->dbg_ctx), QEDF_LOG_INFO,
+		    "GRC Dump already captured.\n");
+		return;
+	}
+
+
+	qedf_get_grc_dump(base_qedf->cdev, qed_ops->common,
+	    &base_qedf->grcdump, &base_qedf->grcdump_size);
+	QEDF_ERR(&(base_qedf->dbg_ctx), "GRC Dump captured.\n");
+	set_bit(QEDF_GRCDUMP_CAPTURE, &base_qedf->flags);
+	qedf_uevent_emit(base_qedf->lport->host, QEDF_UEVENT_CODE_GRCDUMP,
+	    NULL);
+}
+
+static ssize_t
+qedf_sysfs_read_grcdump(struct file *filep, struct kobject *kobj,
+			struct bin_attribute *ba, char *buf, loff_t off,
+			size_t count)
+{
+	ssize_t ret = 0;
+	struct fc_lport *lport = shost_priv(dev_to_shost(container_of(kobj,
+							struct device, kobj)));
+	struct qedf_ctx *qedf = lport_priv(lport);
+
+	if (test_bit(QEDF_GRCDUMP_CAPTURE, &qedf->flags)) {
+		ret = memory_read_from_buffer(buf, count, &off,
+		    qedf->grcdump, qedf->grcdump_size);
+	} else {
+		QEDF_ERR(&(qedf->dbg_ctx), "GRC Dump not captured!\n");
+	}
+
+	return ret;
+}
+
+static ssize_t
+qedf_sysfs_write_grcdump(struct file *filep, struct kobject *kobj,
+			struct bin_attribute *ba, char *buf, loff_t off,
+			size_t count)
+{
+	struct fc_lport *lport = NULL;
+	struct qedf_ctx *qedf = NULL;
+	long reading;
+	int ret = 0;
+	char msg[40];
+
+	if (off != 0)
+		return ret;
+
+
+	lport = shost_priv(dev_to_shost(container_of(kobj,
+	    struct device, kobj)));
+	qedf = lport_priv(lport);
+
+	buf[1] = 0;
+	ret = kstrtol(buf, 10, &reading);
+	if (ret) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Invalid input, err(%d)\n", ret);
+		return ret;
+	}
+
+	memset(msg, 0, sizeof(msg));
+	switch (reading) {
+	case 0:
+		memset(qedf->grcdump, 0, qedf->grcdump_size);
+		clear_bit(QEDF_GRCDUMP_CAPTURE, &qedf->flags);
+		break;
+	case 1:
+		qedf_capture_grc_dump(qedf);
+		break;
+	}
+
+	return count;
+}
+
+static struct bin_attribute sysfs_grcdump_attr = {
+	.attr = {
+		.name = "grcdump",
+		.mode = S_IRUSR | S_IWUSR,
+	},
+	.size = 0,
+	.read = qedf_sysfs_read_grcdump,
+	.write = qedf_sysfs_write_grcdump,
+};
+
+static struct sysfs_bin_attrs bin_file_entries[] = {
+	{"grcdump", &sysfs_grcdump_attr},
+	{NULL},
+};
+
+void qedf_create_sysfs_ctx_attr(struct qedf_ctx *qedf)
+{
+	qedf_create_sysfs_attr(qedf->lport->host, bin_file_entries);
+}
+
+void qedf_remove_sysfs_ctx_attr(struct qedf_ctx *qedf)
+{
+	qedf_remove_sysfs_attr(qedf->lport->host, bin_file_entries);
+}
diff --git a/drivers/scsi/qedf/qedf_dbg.c b/drivers/scsi/qedf/qedf_dbg.c
new file mode 100644
index 0000000..2b1adda
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_dbg.c
@@ -0,0 +1,192 @@
+/*
+ *  QLogic FCoE Offload Driver
+ *  Copyright (c) 2016 Cavium Inc.
+ *
+ *  This software is available under the terms of the GNU General Public License
+ *  (GPL) Version 2, available from the file COPYING in the main directory of
+ *  this source tree.
+ */
+#include "qedf_dbg.h"
+#include <linux/vmalloc.h>
+
+void
+qedf_dbg_err(struct qedf_dbg_ctx *qedf, const char *func, u32 line,
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
+	if (likely(qedf) && likely(qedf->pdev))
+		pr_err("[%s]:[%s:%d]:%d: %pV", dev_name(&(qedf->pdev->dev)),
+			nfunc, line, qedf->host_no, &vaf);
+	else
+		pr_err("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
+
+	va_end(va);
+}
+
+void
+qedf_dbg_warn(struct qedf_dbg_ctx *qedf, const char *func, u32 line,
+	       const char *fmt, ...)
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
+	if (!(qedf_debug & QEDF_LOG_WARN))
+		return;
+
+	if (likely(qedf) && likely(qedf->pdev))
+		pr_warn("[%s]:[%s:%d]:%d: %pV", dev_name(&(qedf->pdev->dev)),
+			nfunc, line, qedf->host_no, &vaf);
+	else
+		pr_warn("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
+
+	va_end(va);
+}
+
+void
+qedf_dbg_notice(struct qedf_dbg_ctx *qedf, const char *func, u32 line,
+		 const char *fmt, ...)
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
+	if (!(qedf_debug & QEDF_LOG_NOTICE))
+		return;
+
+	if (likely(qedf) && likely(qedf->pdev))
+		pr_notice("[%s]:[%s:%d]:%d: %pV",
+			  dev_name(&(qedf->pdev->dev)), nfunc, line,
+			  qedf->host_no, &vaf);
+	else
+		pr_notice("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
+
+	va_end(va);
+}
+
+void
+qedf_dbg_info(struct qedf_dbg_ctx *qedf, const char *func, u32 line,
+	       u32 level, const char *fmt, ...)
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
+	if (!(qedf_debug & level))
+		return;
+
+	if (likely(qedf) && likely(qedf->pdev))
+		pr_info("[%s]:[%s:%d]:%d: %pV", dev_name(&(qedf->pdev->dev)),
+			nfunc, line, qedf->host_no, &vaf);
+	else
+		pr_info("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
+
+	va_end(va);
+}
+
+int
+qedf_alloc_grc_dump_buf(u8 **buf, uint32_t len)
+{
+		*buf = vmalloc(len);
+		if (!(*buf))
+			return -ENOMEM;
+
+		memset(*buf, 0, len);
+		return 0;
+}
+
+void
+qedf_free_grc_dump_buf(uint8_t **buf)
+{
+		vfree(*buf);
+		*buf = NULL;
+}
+
+int
+qedf_get_grc_dump(struct qed_dev *cdev, const struct qed_common_ops *common,
+		   u8 **buf, uint32_t *grcsize)
+{
+	if (!*buf)
+		return -EINVAL;
+
+	return common->dbg_grc(cdev, *buf, grcsize);
+}
+
+void
+qedf_uevent_emit(struct Scsi_Host *shost, u32 code, char *msg)
+{
+	char event_string[40];
+	char *envp[] = {event_string, NULL};
+
+	memset(event_string, 0, sizeof(event_string));
+	switch (code) {
+	case QEDF_UEVENT_CODE_GRCDUMP:
+		if (msg)
+			strncpy(event_string, msg, strlen(msg));
+		else
+			sprintf(event_string, "GRCDUMP=%u", shost->host_no);
+		break;
+	default:
+		/* do nothing */
+		break;
+	}
+
+	kobject_uevent_env(&shost->shost_gendev.kobj, KOBJ_CHANGE, envp);
+}
+
+int
+qedf_create_sysfs_attr(struct Scsi_Host *shost, struct sysfs_bin_attrs *iter)
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
+qedf_remove_sysfs_attr(struct Scsi_Host *shost, struct sysfs_bin_attrs *iter)
+{
+	for (; iter->name; iter++)
+		sysfs_remove_bin_file(&shost->shost_gendev.kobj, iter->attr);
+}
diff --git a/drivers/scsi/qedf/qedf_dbg.h b/drivers/scsi/qedf/qedf_dbg.h
new file mode 100644
index 0000000..672a348
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_dbg.h
@@ -0,0 +1,153 @@
+/*
+ *  QLogic FCoE Offload Driver
+ *  Copyright (c) 2016 Cavium Inc.
+ *
+ *  This software is available under the terms of the GNU General Public License
+ *  (GPL) Version 2, available from the file COPYING in the main directory of
+ *  this source tree.
+ */
+#ifndef _QEDF_DBG_H_
+#define _QEDF_DBG_H_
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/compiler.h>
+#include <linux/string.h>
+#include <linux/version.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <scsi/scsi_transport.h>
+#include <linux/fs.h>
+
+#include <linux/qed/common_hsi.h>
+#include <linux/qed/qed_if.h>
+
+extern uint qedf_debug;
+
+/* Debug print level definitions */
+#define QEDF_LOG_DEFAULT	0x1		/* Set default logging mask */
+#define QEDF_LOG_INFO		0x2		/*
+						 * Informational logs,
+						 * MAC address, WWPN, WWNN
+						 */
+#define QEDF_LOG_DISC		0x4		/* Init, discovery, rport */
+#define QEDF_LOG_LL2		0x8		/* LL2, VLAN logs */
+#define QEDF_LOG_CONN		0x10		/* Connection setup, cleanup */
+#define QEDF_LOG_EVT		0x20		/* Events, link, mtu */
+#define QEDF_LOG_TIMER		0x40		/* Timer events */
+#define QEDF_LOG_MP_REQ	0x80		/* Middle Path (MP) logs */
+#define QEDF_LOG_SCSI_TM	0x100		/* SCSI Aborts, Task Mgmt */
+#define QEDF_LOG_UNSOL		0x200		/* unsolicited event logs */
+#define QEDF_LOG_IO		0x400		/* scsi cmd, completion */
+#define QEDF_LOG_MQ		0x800		/* Multi Queue logs */
+#define QEDF_LOG_BSG		0x1000		/* BSG logs */
+#define QEDF_LOG_DEBUGFS	0x2000		/* debugFS logs */
+#define QEDF_LOG_LPORT		0x4000		/* lport logs */
+#define QEDF_LOG_ELS		0x8000		/* ELS logs */
+#define QEDF_LOG_NPIV		0x10000		/* NPIV logs */
+#define QEDF_LOG_SESS		0x20000		/* Conection setup, cleanup */
+#define QEDF_LOG_TID		0x80000         /*
+						 * FW TID context acquire
+						 * free
+						 */
+#define QEDF_TRACK_TID		0x100000        /*
+						 * Track TID state. To be
+						 * enabled only at module load
+						 * and not run-time.
+						 */
+#define QEDF_TRACK_CMD_LIST    0x300000        /*
+						* Track active cmd list nodes,
+						* done with reference to TID,
+						* hence TRACK_TID also enabled.
+						*/
+#define QEDF_LOG_NOTICE	0x40000000	/* Notice logs */
+#define QEDF_LOG_WARN		0x80000000	/* Warning logs */
+
+/* Debug context structure */
+struct qedf_dbg_ctx {
+	unsigned int host_no;
+	struct pci_dev *pdev;
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *bdf_dentry;
+#endif
+};
+
+#define QEDF_ERR(pdev, fmt, ...)	\
+		qedf_dbg_err(pdev, __func__, __LINE__, fmt, ## __VA_ARGS__)
+#define QEDF_WARN(pdev, fmt, ...)	\
+		qedf_dbg_warn(pdev, __func__, __LINE__, fmt, ## __VA_ARGS__)
+#define QEDF_NOTICE(pdev, fmt, ...)	\
+		qedf_dbg_notice(pdev, __func__, __LINE__, fmt, ## __VA_ARGS__)
+#define QEDF_INFO(pdev, level, fmt, ...)	\
+		qedf_dbg_info(pdev, __func__, __LINE__, level, fmt,	\
+			      ## __VA_ARGS__)
+
+extern void qedf_dbg_err(struct qedf_dbg_ctx *, const char *, u32,
+			  const char *, ...);
+extern void qedf_dbg_warn(struct qedf_dbg_ctx *, const char *, u32,
+			   const char *, ...);
+extern void qedf_dbg_notice(struct qedf_dbg_ctx *, const char *, u32,
+			     const char *, ...);
+extern void qedf_dbg_info(struct qedf_dbg_ctx *, const char *, u32, u32,
+			   const char *, ...);
+
+/* GRC Dump related defines */
+
+struct Scsi_Host;
+
+#define QEDF_UEVENT_CODE_GRCDUMP 0
+
+struct sysfs_bin_attrs {
+	char *name;
+	struct bin_attribute *attr;
+};
+
+extern int qedf_alloc_grc_dump_buf(uint8_t **, uint32_t);
+extern void qedf_free_grc_dump_buf(uint8_t **);
+extern int qedf_get_grc_dump(struct qed_dev *, const struct qed_common_ops *,
+			      uint8_t **, uint32_t *);
+extern void qedf_uevent_emit(struct Scsi_Host *, u32, char *);
+extern int qedf_create_sysfs_attr(struct Scsi_Host *,
+				   struct sysfs_bin_attrs *);
+extern void qedf_remove_sysfs_attr(struct Scsi_Host *,
+				    struct sysfs_bin_attrs *);
+
+#ifdef CONFIG_DEBUG_FS
+/* DebugFS related code */
+struct qedf_list_of_funcs {
+	char *oper_str;
+	ssize_t (*oper_func)(struct qedf_dbg_ctx *qedf);
+};
+
+struct qedf_debugfs_ops {
+	char *name;
+	struct qedf_list_of_funcs *qedf_funcs;
+};
+
+#define qedf_dbg_fileops(drv, ops) \
+{ \
+	.owner  = THIS_MODULE, \
+	.open   = simple_open, \
+	.read   = drv##_dbg_##ops##_cmd_read, \
+	.write  = drv##_dbg_##ops##_cmd_write \
+}
+
+/* Used for debugfs sequential files */
+#define qedf_dbg_fileops_seq(drv, ops) \
+{ \
+	.owner = THIS_MODULE, \
+	.open = drv##_dbg_##ops##_open, \
+	.read = seq_read, \
+	.llseek = seq_lseek, \
+	.release = single_release, \
+}
+
+extern void qedf_dbg_host_init(struct qedf_dbg_ctx *qedf,
+				struct qedf_debugfs_ops *dops,
+				struct file_operations *fops);
+extern void qedf_dbg_host_exit(struct qedf_dbg_ctx *qedf);
+extern void qedf_dbg_init(char *drv_name);
+extern void qedf_dbg_exit(void);
+#endif /* CONFIG_DEBUG_FS */
+
+#endif /* _QEDF_DBG_H_ */
diff --git a/drivers/scsi/qedf/qedf_debugfs.c b/drivers/scsi/qedf/qedf_debugfs.c
new file mode 100644
index 0000000..6a28026
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_debugfs.c
@@ -0,0 +1,472 @@
+/*
+ *  QLogic FCoE Offload Driver
+ *  Copyright (c) 2016 QLogic Corporation
+ *
+ *  This software is available under the terms of the GNU General Public License
+ *  (GPL) Version 2, available from the file COPYING in the main directory of
+ *  this source tree.
+ */
+#ifdef CONFIG_DEBUG_FS
+
+#include <linux/uaccess.h>
+#include <linux/debugfs.h>
+#include <linux/module.h>
+
+#include "qedf.h"
+#include "qedf_dbg.h"
+
+static struct dentry *qedf_dbg_root;
+
+/**
+ * qedf_dbg_host_init - setup the debugfs file for the pf
+ * @pf: the pf that is starting up
+ **/
+void
+qedf_dbg_host_init(struct qedf_dbg_ctx *qedf,
+		    struct qedf_debugfs_ops *dops,
+		    struct file_operations *fops)
+{
+	char host_dirname[32];
+	struct dentry *file_dentry = NULL;
+
+	QEDF_INFO(qedf, QEDF_LOG_DEBUGFS, "Creating debugfs host node\n");
+	/* create pf dir */
+	sprintf(host_dirname, "host%u", qedf->host_no);
+	qedf->bdf_dentry = debugfs_create_dir(host_dirname, qedf_dbg_root);
+	if (!qedf->bdf_dentry)
+		return;
+
+	/* create debugfs files */
+	while (dops) {
+		if (!(dops->name))
+			break;
+
+		file_dentry = debugfs_create_file(dops->name, 0600,
+						  qedf->bdf_dentry, qedf,
+						  fops);
+		if (!file_dentry) {
+			QEDF_INFO(qedf, QEDF_LOG_DEBUGFS,
+				   "Debugfs entry %s creation failed\n",
+				   dops->name);
+			debugfs_remove_recursive(qedf->bdf_dentry);
+			return;
+		}
+		dops++;
+		fops++;
+	}
+}
+
+/**
+ * qedf_dbg_host_exit - clear out the pf's debugfs entries
+ * @pf: the pf that is stopping
+ **/
+void
+qedf_dbg_host_exit(struct qedf_dbg_ctx *qedf)
+{
+	QEDF_INFO(qedf, QEDF_LOG_DEBUGFS, "Destroying debugfs host "
+		   "entry\n");
+	/* remove debugfs  entries of this PF */
+	debugfs_remove_recursive(qedf->bdf_dentry);
+	qedf->bdf_dentry = NULL;
+}
+
+/**
+ * qedf_dbg_init - start up debugfs for the driver
+ **/
+void
+qedf_dbg_init(char *drv_name)
+{
+	QEDF_INFO(NULL, QEDF_LOG_DEBUGFS, "Creating debugfs root node\n");
+
+	/* create qed dir in root of debugfs. NULL means debugfs root */
+	qedf_dbg_root = debugfs_create_dir(drv_name, NULL);
+	if (!qedf_dbg_root)
+		QEDF_INFO(NULL, QEDF_LOG_DEBUGFS, "Init of debugfs "
+			   "failed\n");
+}
+
+/**
+ * qedf_dbg_exit - clean out the driver's debugfs entries
+ **/
+void
+qedf_dbg_exit(void)
+{
+	QEDF_INFO(NULL, QEDF_LOG_DEBUGFS, "Destroying debugfs root "
+		   "entry\n");
+
+	/* remove qed dir in root of debugfs */
+	debugfs_remove_recursive(qedf_dbg_root);
+	qedf_dbg_root = NULL;
+}
+
+struct qedf_debugfs_ops qedf_debugfs_ops[] = {
+	{ "fp_int", NULL },
+	{ "io_trace", NULL },
+	{ "debug", NULL },
+	{ "stop_io_on_error", NULL},
+	{ "driver_stats", NULL},
+	{ "clear_stats", NULL},
+	{ "offload_stats", NULL},
+	/* This must be last */
+	{ NULL, NULL }
+};
+
+DECLARE_PER_CPU(struct qedf_percpu_iothread_s, qedf_percpu_iothreads);
+
+static ssize_t
+qedf_dbg_fp_int_cmd_read(struct file *filp, char __user *buffer, size_t count,
+			 loff_t *ppos)
+{
+	size_t cnt = 0;
+	int id;
+	struct qedf_fastpath *fp = NULL;
+	struct qedf_dbg_ctx *qedf_dbg =
+				(struct qedf_dbg_ctx *)filp->private_data;
+	struct qedf_ctx *qedf = container_of(qedf_dbg,
+	    struct qedf_ctx, dbg_ctx);
+	struct qedf_percpu_iothread_s *iothread;
+	unsigned int cpu;
+
+	QEDF_INFO(qedf_dbg, QEDF_LOG_DEBUGFS, "entered\n");
+
+	cnt = sprintf(buffer, "\nFastpath I/O completions\n\n");
+
+	for (id = 0; id < qedf->num_queues; id++) {
+		fp = &(qedf->fp_array[id]);
+		if (fp->sb_id == QEDF_SB_ID_NULL)
+			continue;
+		cnt += sprintf((buffer + cnt), "#%d: %lu\n", id,
+			       fp->completions);
+	}
+
+	cnt += sprintf(buffer + cnt, "\nPer CPU Stats\n\n");
+
+	for_each_online_cpu(cpu) {
+		iothread = &per_cpu(qedf_percpu_iothreads, cpu);
+		cnt += sprintf((buffer + cnt),
+		    "#%u: requests=%llu responses=%llu\n",
+		    cpu, iothread->requests, iothread->responses);
+	}
+
+	cnt = min_t(int, count, cnt - *ppos);
+	*ppos += cnt;
+	return cnt;
+}
+
+static ssize_t
+qedf_dbg_fp_int_cmd_write(struct file *filp, const char __user *buffer,
+			  size_t count, loff_t *ppos)
+{
+	if (!count || *ppos)
+		return 0;
+
+	return count;
+}
+
+static ssize_t
+qedf_dbg_debug_cmd_read(struct file *filp, char __user *buffer, size_t count,
+			loff_t *ppos)
+{
+	int cnt;
+	struct qedf_dbg_ctx *qedf =
+				(struct qedf_dbg_ctx *)filp->private_data;
+
+	QEDF_INFO(qedf, QEDF_LOG_DEBUGFS, "entered\n");
+	cnt = sprintf(buffer, "debug mask = 0x%x\n", qedf_debug);
+
+	cnt = min_t(int, count, cnt - *ppos);
+	*ppos += cnt;
+	return cnt;
+}
+
+static ssize_t
+qedf_dbg_debug_cmd_write(struct file *filp, const char __user *buffer,
+			 size_t count, loff_t *ppos)
+{
+	uint32_t val;
+	void *kern_buf;
+	int rval;
+	struct qedf_dbg_ctx *qedf =
+	    (struct qedf_dbg_ctx *)filp->private_data;
+
+	if (!count || *ppos)
+		return 0;
+
+	kern_buf = memdup_user(buffer, count);
+	if (IS_ERR(kern_buf))
+		return PTR_ERR(kern_buf);
+
+	rval = kstrtouint(kern_buf, 10, &val);
+	kfree(kern_buf);
+	if (rval)
+		return rval;
+
+	if (val == 1)
+		qedf_debug = QEDF_DEFAULT_LOG_MASK;
+	else
+		qedf_debug = val;
+
+	QEDF_INFO(qedf, QEDF_LOG_DEBUGFS, "Setting debug=0x%x.\n", val);
+	return count;
+}
+
+static ssize_t
+qedf_dbg_stop_io_on_error_cmd_read(struct file *filp, char __user *buffer,
+				   size_t count, loff_t *ppos)
+{
+	int cnt;
+	struct qedf_dbg_ctx *qedf_dbg =
+				(struct qedf_dbg_ctx *)filp->private_data;
+	struct qedf_ctx *qedf = container_of(qedf_dbg, struct qedf_ctx, dbg_ctx);
+
+	QEDF_INFO(qedf_dbg, QEDF_LOG_DEBUGFS, "entered\n");
+	cnt = sprintf(buffer, "%s\n",
+	    qedf->stop_io_on_error ? "true" : "false");
+
+	cnt = min_t(int, count, cnt - *ppos);
+	*ppos += cnt;
+	return cnt;
+}
+
+static ssize_t
+qedf_dbg_stop_io_on_error_cmd_write(struct file *filp,
+				    const char __user *buffer, size_t count,
+				    loff_t *ppos)
+{
+	void *kern_buf;
+	struct qedf_dbg_ctx *qedf_dbg =
+				(struct qedf_dbg_ctx *)filp->private_data;
+	struct qedf_ctx *qedf = container_of(qedf_dbg, struct qedf_ctx,
+	    dbg_ctx);
+
+	QEDF_INFO(qedf_dbg, QEDF_LOG_DEBUGFS, "entered\n");
+
+	if (!count || *ppos)
+		return 0;
+
+	kern_buf = memdup_user(buffer, 6);
+	if (IS_ERR(kern_buf))
+		return PTR_ERR(kern_buf);
+
+	if (strncmp(kern_buf, "false", 5) == 0)
+		qedf->stop_io_on_error = false;
+	else if (strncmp(kern_buf, "true", 4) == 0)
+		qedf->stop_io_on_error = true;
+	else if (strncmp(kern_buf, "now", 3) == 0)
+		/* Trigger from user to stop all I/O on this host */
+		set_bit(QEDF_UNLOADING, &qedf->flags);
+
+	kfree(kern_buf);
+	return count;
+}
+
+static int
+qedf_io_trace_show(struct seq_file *s, void *unused)
+{
+	int i, idx = 0;
+	struct qedf_ctx *qedf = s->private;
+	struct qedf_dbg_ctx *qedf_dbg = &qedf->dbg_ctx;
+	struct qedf_io_log *io_log;
+	unsigned long flags;
+
+	if (!qedf_io_tracing) {
+		seq_puts(s, "I/O tracing not enabled.\n");
+		goto out;
+	}
+
+	QEDF_INFO(qedf_dbg, QEDF_LOG_DEBUGFS, "entered\n");
+
+	spin_lock_irqsave(&qedf->io_trace_lock, flags);
+	idx = qedf->io_trace_idx;
+	for (i = 0; i < QEDF_IO_TRACE_SIZE; i++) {
+		io_log = &qedf->io_trace_buf[idx];
+		seq_printf(s, "%d:", io_log->direction);
+		seq_printf(s, "0x%x:", io_log->task_id);
+		seq_printf(s, "0x%06x:", io_log->port_id);
+		seq_printf(s, "%d:", io_log->lun);
+		seq_printf(s, "0x%02x:", io_log->op);
+		seq_printf(s, "0x%02x%02x%02x%02x:", io_log->lba[0],
+		    io_log->lba[1], io_log->lba[2], io_log->lba[3]);
+		seq_printf(s, "%d:", io_log->bufflen);
+		seq_printf(s, "%d:", io_log->sg_count);
+		seq_printf(s, "0x%08x:", io_log->result);
+		seq_printf(s, "%lu:", io_log->jiffies);
+		seq_printf(s, "%d:", io_log->refcount);
+		seq_printf(s, "%d:", io_log->req_cpu);
+		seq_printf(s, "%d:", io_log->int_cpu);
+		seq_printf(s, "%d:", io_log->rsp_cpu);
+		seq_printf(s, "%d\n", io_log->sge_type);
+
+		idx++;
+		if (idx == QEDF_IO_TRACE_SIZE)
+			idx = 0;
+	}
+	spin_unlock_irqrestore(&qedf->io_trace_lock, flags);
+
+out:
+	return 0;
+}
+
+static int
+qedf_dbg_io_trace_open(struct inode *inode, struct file *file)
+{
+	struct qedf_dbg_ctx *qedf_dbg = inode->i_private;
+	struct qedf_ctx *qedf = container_of(qedf_dbg, struct qedf_ctx, dbg_ctx);
+
+	return single_open(file, qedf_io_trace_show, qedf);
+}
+
+static int
+qedf_driver_stats_show(struct seq_file *s, void *unused)
+{
+	struct qedf_ctx *qedf = s->private;
+	struct qedf_rport *fcport;
+	struct fc_rport_priv *rdata;
+	unsigned long flags;
+	int i;
+
+	seq_printf(s, "cmg_mgr free io_reqs: %d\n",
+	    atomic_read(&qedf->cmd_mgr->free_list_cnt));
+	seq_printf(s, "slow SGEs: %d\n", qedf->slow_sge_ios);
+	seq_printf(s, "single SGEs: %d\n", qedf->single_sge_ios);
+	seq_printf(s, "fast SGEs: %d\n\n", qedf->fast_sge_ios);
+
+	seq_puts(s, "Offloaded ports:\n\n");
+
+	spin_lock_irqsave(&qedf->hba_lock, flags);
+	for (i = 0; i < QEDF_MAX_SESSIONS; i++) {
+		fcport = qedf->fcports[i];
+		if (fcport == NULL)
+			continue;
+		rdata = fcport->rdata;
+		if (rdata == NULL)
+			continue;
+		seq_printf(s, "%06x: free_sqes: %d, num_active_ios: %d\n",
+		    rdata->ids.port_id, atomic_read(&fcport->free_sqes),
+		    atomic_read(&fcport->num_active_ios));
+	}
+	spin_unlock_irqrestore(&qedf->hba_lock, flags);
+
+	return 0;
+}
+
+static int
+qedf_dbg_driver_stats_open(struct inode *inode, struct file *file)
+{
+	struct qedf_dbg_ctx *qedf_dbg = inode->i_private;
+	struct qedf_ctx *qedf = container_of(qedf_dbg, struct qedf_ctx, dbg_ctx);
+
+	return single_open(file, qedf_driver_stats_show, qedf);
+}
+
+static ssize_t
+qedf_dbg_clear_stats_cmd_read(struct file *filp, char __user *buffer,
+				   size_t count, loff_t *ppos)
+{
+	int cnt = 0;
+
+	/* Essentially a read stub */
+	cnt = min_t(int, count, cnt - *ppos);
+	*ppos += cnt;
+	return cnt;
+}
+
+static ssize_t
+qedf_dbg_clear_stats_cmd_write(struct file *filp,
+				    const char __user *buffer, size_t count,
+				    loff_t *ppos)
+{
+	struct qedf_dbg_ctx *qedf_dbg =
+				(struct qedf_dbg_ctx *)filp->private_data;
+	struct qedf_ctx *qedf = container_of(qedf_dbg, struct qedf_ctx,
+	    dbg_ctx);
+
+	QEDF_INFO(qedf_dbg, QEDF_LOG_DEBUGFS, "Clearing stat counters.\n");
+
+	if (!count || *ppos)
+		return 0;
+
+	/* Clear stat counters exposed by 'stats' node */
+	qedf->slow_sge_ios = 0;
+	qedf->single_sge_ios = 0;
+	qedf->fast_sge_ios = 0;
+
+	return count;
+}
+
+static int
+qedf_offload_stats_show(struct seq_file *s, void *unused)
+{
+	struct qedf_ctx *qedf = s->private;
+	struct qed_fcoe_stats *fw_fcoe_stats;
+
+	fw_fcoe_stats = kmalloc(sizeof(struct qed_fcoe_stats), GFP_KERNEL);
+	if (!fw_fcoe_stats) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Could not allocate memory for "
+		    "fw_fcoe_stats.\n");
+		goto out;
+	}
+
+	/* Query firmware for offload stats */
+	qed_ops->get_stats(qedf->cdev, fw_fcoe_stats);
+
+	seq_printf(s, "fcoe_rx_byte_cnt=%llu\n"
+	    "fcoe_rx_data_pkt_cnt=%llu\n"
+	    "fcoe_rx_xfer_pkt_cnt=%llu\n"
+	    "fcoe_rx_other_pkt_cnt=%llu\n"
+	    "fcoe_silent_drop_pkt_cmdq_full_cnt=%u\n"
+	    "fcoe_silent_drop_pkt_crc_error_cnt=%u\n"
+	    "fcoe_silent_drop_pkt_task_invalid_cnt=%u\n"
+	    "fcoe_silent_drop_total_pkt_cnt=%u\n"
+	    "fcoe_silent_drop_pkt_rq_full_cnt=%u\n"
+	    "fcoe_tx_byte_cnt=%llu\n"
+	    "fcoe_tx_data_pkt_cnt=%llu\n"
+	    "fcoe_tx_xfer_pkt_cnt=%llu\n"
+	    "fcoe_tx_other_pkt_cnt=%llu\n",
+	    fw_fcoe_stats->fcoe_rx_byte_cnt,
+	    fw_fcoe_stats->fcoe_rx_data_pkt_cnt,
+	    fw_fcoe_stats->fcoe_rx_xfer_pkt_cnt,
+	    fw_fcoe_stats->fcoe_rx_other_pkt_cnt,
+	    fw_fcoe_stats->fcoe_silent_drop_pkt_cmdq_full_cnt,
+	    fw_fcoe_stats->fcoe_silent_drop_pkt_crc_error_cnt,
+	    fw_fcoe_stats->fcoe_silent_drop_pkt_task_invalid_cnt,
+	    fw_fcoe_stats->fcoe_silent_drop_total_pkt_cnt,
+	    fw_fcoe_stats->fcoe_silent_drop_pkt_rq_full_cnt,
+	    fw_fcoe_stats->fcoe_tx_byte_cnt,
+	    fw_fcoe_stats->fcoe_tx_data_pkt_cnt,
+	    fw_fcoe_stats->fcoe_tx_xfer_pkt_cnt,
+	    fw_fcoe_stats->fcoe_tx_other_pkt_cnt);
+
+	kfree(fw_fcoe_stats);
+out:
+	return 0;
+}
+
+static int
+qedf_dbg_offload_stats_open(struct inode *inode, struct file *file)
+{
+	struct qedf_dbg_ctx *qedf_dbg = inode->i_private;
+	struct qedf_ctx *qedf = container_of(qedf_dbg, struct qedf_ctx, dbg_ctx);
+
+	return single_open(file, qedf_offload_stats_show, qedf);
+}
+
+
+const struct file_operations qedf_dbg_fops[] = {
+	qedf_dbg_fileops(qedf, fp_int),
+	qedf_dbg_fileops_seq(qedf, io_trace),
+	qedf_dbg_fileops(qedf, debug),
+	qedf_dbg_fileops(qedf, stop_io_on_error),
+	qedf_dbg_fileops_seq(qedf, driver_stats),
+	qedf_dbg_fileops(qedf, clear_stats),
+	qedf_dbg_fileops_seq(qedf, offload_stats),
+	/* This must be last */
+	{ NULL, NULL },
+};
+
+#else /* CONFIG_DEBUG_FS */
+void qedf_dbg_host_init(struct qedf_dbg_ctx *);
+void qedf_dbg_host_exit(struct qedf_dbg_ctx *);
+void qedf_dbg_init(char *);
+void qedf_dbg_exit(void);
+#endif /* CONFIG_DEBUG_FS */
diff --git a/drivers/scsi/qedf/qedf_main.c b/drivers/scsi/qedf/qedf_main.c
new file mode 100644
index 0000000..074fe41
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_main.c
@@ -0,0 +1,3519 @@
+/*
+ *  QLogic FCoE Offload Driver
+ *  Copyright (c) 2016 Cavium Inc.
+ *
+ *  This software is available under the terms of the GNU General Public License
+ *  (GPL) Version 2, available from the file COPYING in the main directory of
+ *  this source tree.
+ */
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/highmem.h>
+#include <linux/crc32.h>
+#include <linux/interrupt.h>
+#include <linux/list.h>
+#include <linux/kthread.h>
+#include <scsi/libfc.h>
+#include <scsi/scsi_host.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/cpu.h>
+#include "qedf.h"
+
+const struct qed_fcoe_ops *qed_ops;
+
+static int qedf_probe(struct pci_dev *pdev, const struct pci_device_id *id);
+static void qedf_remove(struct pci_dev *pdev);
+
+extern struct qedf_debugfs_ops qedf_debugfs_ops;
+extern struct file_operations qedf_dbg_fops;
+
+/*
+ * Driver module parameters.
+ */
+static unsigned int qedf_dev_loss_tmo = 60;
+module_param_named(dev_loss_tmo, qedf_dev_loss_tmo, int, S_IRUGO);
+MODULE_PARM_DESC(dev_loss_tmo,  " dev_loss_tmo setting for attached "
+	"remote ports (default 60)");
+
+uint qedf_debug = QEDF_LOG_INFO;
+module_param_named(debug, qedf_debug, uint, S_IRUGO);
+MODULE_PARM_DESC(qedf_debug, " Debug mask. Pass '1' to enable default debugging"
+	" mask");
+
+static uint qedf_fipvlan_retries = 30;
+module_param_named(fipvlan_retries, qedf_fipvlan_retries, int, S_IRUGO);
+MODULE_PARM_DESC(fipvlan_retries, " Number of FIP VLAN requests to attempt "
+	"before giving up (default 30)");
+
+static uint qedf_fallback_vlan = QEDF_FALLBACK_VLAN;
+module_param_named(fallback_vlan, qedf_fallback_vlan, int, S_IRUGO);
+MODULE_PARM_DESC(fallback_vlan, " VLAN ID to try if fip vlan request fails "
+	"(default 1002).");
+
+static uint qedf_default_prio = QEDF_DEFAULT_PRIO;
+module_param_named(default_prio, qedf_default_prio, int, S_IRUGO);
+MODULE_PARM_DESC(default_prio, " Default 802.1q priority for FIP and FCoE"
+	" traffic (default 3).");
+
+uint qedf_dump_frames;
+module_param_named(dump_frames, qedf_dump_frames, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(dump_frames, " Print the skb data of FIP and FCoE frames "
+	"(default off)");
+
+static uint qedf_queue_depth;
+module_param_named(queue_depth, qedf_queue_depth, int, S_IRUGO);
+MODULE_PARM_DESC(queue_depth, " Sets the queue depth for all LUNs discovered "
+	"by the qedf driver. Default is 0 (use OS default).");
+
+uint qedf_io_tracing;
+module_param_named(io_tracing, qedf_io_tracing, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(io_tracing, " Enable logging of SCSI requests/completions "
+	"into trace buffer. (default off).");
+
+static uint qedf_max_lun = MAX_FIBRE_LUNS;
+module_param_named(max_lun, qedf_max_lun, int, S_IRUGO);
+MODULE_PARM_DESC(max_lun, " Sets the maximum luns per target that the driver "
+	"supports. (default 0xffffffff)");
+
+uint qedf_link_down_tmo;
+module_param_named(link_down_tmo, qedf_link_down_tmo, int, S_IRUGO);
+MODULE_PARM_DESC(link_down_tmo, " Delays informing the fcoe transport that the "
+	"link is down by N seconds.");
+
+bool qedf_retry_delay;
+module_param_named(retry_delay, qedf_retry_delay, bool, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(retry_delay, " Enable/disable handling of FCP_RSP IU retry "
+	"delay handling (default off).");
+
+static uint qedf_dp_module;
+module_param_named(dp_module, qedf_dp_module, uint, S_IRUGO);
+MODULE_PARM_DESC(dp_module, " bit flags control for verbose printk passed "
+	"qed module during probe.");
+
+static uint qedf_dp_level;
+module_param_named(dp_level, qedf_dp_level, uint, S_IRUGO);
+MODULE_PARM_DESC(dp_level, " printk verbosity control passed to qed module  "
+	"during probe (0-3: 0 more verbose).");
+
+
+DEFINE_PER_CPU(struct qedf_percpu_iothread_s, qedf_percpu_iothreads);
+
+static struct fcoe_percpu_s qedf_global;
+static DEFINE_SPINLOCK(qedf_global_lock);
+
+static struct kmem_cache *qedf_io_work_cache;
+
+void qedf_set_vlan_id(struct qedf_ctx *qedf, int vlan_id)
+{
+	qedf->vlan_id = vlan_id;
+	qedf->vlan_id |= qedf_default_prio << VLAN_PRIO_SHIFT;
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "Setting vlan_id=%04x "
+		   "prio=%d.\n", vlan_id, qedf_default_prio);
+}
+
+/* Returns true if we have a valid vlan, false otherwise */
+static bool qedf_initiate_fipvlan_req(struct qedf_ctx *qedf)
+{
+	int rc;
+
+	if (atomic_read(&qedf->link_state) != QEDF_LINK_UP) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Link not up.\n");
+		return  false;
+	}
+
+	while (qedf->fipvlan_retries--) {
+		if (qedf->vlan_id > 0)
+			return true;
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+			   "Retry %d.\n", qedf->fipvlan_retries);
+		init_completion(&qedf->fipvlan_compl);
+		qedf_fcoe_send_vlan_req(qedf);
+		rc = wait_for_completion_timeout(&qedf->fipvlan_compl,
+		    1 * HZ);
+		if (rc > 0) {
+			fcoe_ctlr_link_up(&qedf->ctlr);
+			return true;
+		}
+	}
+
+	return false;
+}
+
+static void qedf_handle_link_update(struct work_struct *work)
+{
+	struct qedf_ctx *qedf =
+	    container_of(work, struct qedf_ctx, link_update.work);
+	int rc;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "Entered.\n");
+
+	if (atomic_read(&qedf->link_state) == QEDF_LINK_UP) {
+		rc = qedf_initiate_fipvlan_req(qedf);
+		if (rc)
+			return;
+		/*
+		 * If we get here then we never received a repsonse to our
+		 * fip vlan request so set the vlan_id to the default and
+		 * tell FCoE that the link is up
+		 */
+		QEDF_WARN(&(qedf->dbg_ctx), "Did not receive FIP VLAN "
+			   "response, falling back to default VLAN %d.\n",
+			   qedf_fallback_vlan);
+		qedf_set_vlan_id(qedf, QEDF_FALLBACK_VLAN);
+
+		/*
+		 * Zero out data_src_addr so we'll update it with the new
+		 * lport port_id
+		 */
+		eth_zero_addr(qedf->data_src_addr);
+		fcoe_ctlr_link_up(&qedf->ctlr);
+	} else if (atomic_read(&qedf->link_state) == QEDF_LINK_DOWN) {
+		/*
+		 * If we hit here and link_down_tmo_valid is still 1 it means
+		 * that link_down_tmo timed out so set it to 0 to make sure any
+		 * other readers have accurate state.
+		 */
+		atomic_set(&qedf->link_down_tmo_valid, 0);
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+		    "Calling fcoe_ctlr_link_down().\n");
+		fcoe_ctlr_link_down(&qedf->ctlr);
+		qedf_wait_for_upload(qedf);
+		/* Reset the number of FIP VLAN retries */
+		qedf->fipvlan_retries = qedf_fipvlan_retries;
+	}
+}
+
+static void qedf_flogi_resp(struct fc_seq *seq, struct fc_frame *fp,
+	void *arg)
+{
+	struct fc_exch *exch = fc_seq_exch(seq);
+	struct fc_lport *lport = exch->lp;
+	struct qedf_ctx *qedf = lport_priv(lport);
+
+	if (!qedf) {
+		QEDF_ERR(NULL, "qedf is NULL.\n");
+		return;
+	}
+
+	/*
+	 * If ERR_PTR is set then don't try to stat anything as it will cause
+	 * a crash when we access fp.
+	 */
+	if (fp == ERR_PTR(-FC_EX_TIMEOUT) ||
+	    fp == ERR_PTR(-FC_EX_CLOSED)) {
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+		    "fp has ERR_PTR() set.\n");
+		goto skip_stat;
+	}
+
+	/* Log stats for FLOGI reject */
+	if (fc_frame_payload_op(fp) == ELS_LS_RJT)
+		qedf->flogi_failed++;
+
+	/* Complete flogi_compl so we can proceed to sending ADISCs */
+	complete(&qedf->flogi_compl);
+
+skip_stat:
+	/* Report response to libfc */
+	fc_lport_flogi_resp(seq, fp, lport);
+}
+
+static struct fc_seq *qedf_elsct_send(struct fc_lport *lport, u32 did,
+	struct fc_frame *fp, unsigned int op,
+	void (*resp)(struct fc_seq *,
+	struct fc_frame *,
+	void *),
+	void *arg, u32 timeout)
+{
+	struct qedf_ctx *qedf = lport_priv(lport);
+
+	/*
+	 * Intercept FLOGI for statistic purposes. Note we use the resp
+	 * callback to tell if this is really a flogi.
+	 */
+	if (resp == fc_lport_flogi_resp) {
+		qedf->flogi_cnt++;
+		return fc_elsct_send(lport, did, fp, op, qedf_flogi_resp,
+		    arg, timeout);
+	}
+
+	return fc_elsct_send(lport, did, fp, op, resp, arg, timeout);
+}
+
+int qedf_send_flogi(struct qedf_ctx *qedf)
+{
+	struct fc_lport *lport;
+	struct fc_frame *fp;
+
+	lport = qedf->lport;
+
+	if (!lport->tt.elsct_send)
+		return -EINVAL;
+
+	fp = fc_frame_alloc(lport, sizeof(struct fc_els_flogi));
+	if (!fp) {
+		QEDF_ERR(&(qedf->dbg_ctx), "fc_frame_alloc failed.\n");
+		return -ENOMEM;
+	}
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+	    "Sending FLOGI to reestablish session with switch.\n");
+	lport->tt.elsct_send(lport, FC_FID_FLOGI, fp,
+	    ELS_FLOGI, qedf_flogi_resp, lport, lport->r_a_tov);
+
+	init_completion(&qedf->flogi_compl);
+
+	return 0;
+}
+
+/*
+ * This function is called if link_down_tmo is in use.  If we get a link up and
+ * link_down_tmo has not expired then use just FLOGI/ADISC to recover our
+ * sessions with targets.  Otherwise, just call fcoe_ctlr_link_up().
+ */
+static void qedf_link_recovery(struct work_struct *work)
+{
+	struct qedf_ctx *qedf =
+	    container_of(work, struct qedf_ctx, link_recovery.work);
+	struct qedf_rport *fcport;
+	struct fc_rport_priv *rdata;
+	bool rc;
+	int retries = 30;
+	int rval, i;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+	    "Link down tmo did not expire.\n");
+
+	/*
+	 * Essentially reset the fcoe_ctlr here without affecting the state
+	 * of the libfc structs.
+	 */
+	qedf->ctlr.state = FIP_ST_LINK_WAIT;
+	fcoe_ctlr_link_down(&qedf->ctlr);
+
+	/*
+	 * Bring the link up before we send the fipvlan request so libfcoe
+	 * can select a new fcf in parallel
+	 */
+	fcoe_ctlr_link_up(&qedf->ctlr);
+
+	/* Since the link when down and up to verify which vlan we're on */
+	qedf->fipvlan_retries = qedf_fipvlan_retries;
+	rc = qedf_initiate_fipvlan_req(qedf);
+	if (!rc)
+		return;
+
+	/*
+	 * We need to wait for an FCF to be selected due to the
+	 * fcoe_ctlr_link_up other the FLOGI will be rejected.
+	 */
+	while (retries > 0) {
+		if (qedf->ctlr.sel_fcf) {
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+			    "FCF reselected, proceeding with FLOGI.\n");
+			break;
+		}
+		msleep(500);
+		retries--;
+	}
+
+	if (retries < 1) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Exhausted retries waiting for "
+		    "FCF selection.\n");
+		return;
+	}
+
+	rval = qedf_send_flogi(qedf);
+	if (rval)
+		return;
+
+	/* Wait for FLOGI completion before proceeding with sending ADISCs */
+	i = wait_for_completion_timeout(&qedf->flogi_compl,
+	    qedf->lport->r_a_tov);
+	if (i == 0) {
+		QEDF_ERR(&(qedf->dbg_ctx), "FLOGI timed out.\n");
+		return;
+	}
+
+	/*
+	 * Call lport->tt.rport_login which will cause libfc to send an
+	 * ADISC since the rport is in state ready.
+	 */
+	for (i = 0; i < QEDF_MAX_SESSIONS; i++) {
+		fcport = qedf->fcports[i];
+		if (fcport == NULL)
+			continue;
+		rdata = fcport->rdata;
+		if (rdata == NULL)
+			continue;
+		fc_rport_login(rdata);
+	}
+}
+
+static void qedf_update_link_speed(struct qedf_ctx *qedf,
+	struct qed_link_output *link)
+{
+	struct fc_lport *lport = qedf->lport;
+
+	lport->link_speed = FC_PORTSPEED_UNKNOWN;
+	lport->link_supported_speeds = FC_PORTSPEED_UNKNOWN;
+
+	/* Set fc_host link speed */
+	switch (link->speed) {
+	case 10000:
+		lport->link_speed = FC_PORTSPEED_10GBIT;
+		break;
+	case 25000:
+		lport->link_speed = FC_PORTSPEED_25GBIT;
+		break;
+	case 40000:
+		lport->link_speed = FC_PORTSPEED_40GBIT;
+		break;
+	case 50000:
+		lport->link_speed = FC_PORTSPEED_50GBIT;
+		break;
+	case 100000:
+		lport->link_speed = FC_PORTSPEED_100GBIT;
+		break;
+	default:
+		lport->link_speed = FC_PORTSPEED_UNKNOWN;
+		break;
+	}
+
+	/*
+	 * Set supported link speed by querying the supported
+	 * capabilities of the link.
+	 */
+	if (link->supported_caps & SUPPORTED_10000baseKR_Full)
+		lport->link_supported_speeds |= FC_PORTSPEED_10GBIT;
+	if (link->supported_caps & SUPPORTED_25000baseKR_Full)
+		lport->link_supported_speeds |= FC_PORTSPEED_25GBIT;
+	if (link->supported_caps & SUPPORTED_40000baseLR4_Full)
+		lport->link_supported_speeds |= FC_PORTSPEED_40GBIT;
+	if (link->supported_caps & SUPPORTED_50000baseKR2_Full)
+		lport->link_supported_speeds |= FC_PORTSPEED_50GBIT;
+	if (link->supported_caps & SUPPORTED_100000baseKR4_Full)
+		lport->link_supported_speeds |= FC_PORTSPEED_100GBIT;
+	fc_host_supported_speeds(lport->host) = lport->link_supported_speeds;
+}
+
+static void qedf_link_update(void *dev, struct qed_link_output *link)
+{
+	struct qedf_ctx *qedf = (struct qedf_ctx *)dev;
+
+	if (link->link_up) {
+		QEDF_ERR(&(qedf->dbg_ctx), "LINK UP (%d GB/s).\n",
+		    link->speed / 1000);
+
+		/* Cancel any pending link down work */
+		cancel_delayed_work(&qedf->link_update);
+
+		atomic_set(&qedf->link_state, QEDF_LINK_UP);
+		qedf_update_link_speed(qedf, link);
+
+		if (atomic_read(&qedf->dcbx) == QEDF_DCBX_DONE) {
+			QEDF_ERR(&(qedf->dbg_ctx), "DCBx done.\n");
+			if (atomic_read(&qedf->link_down_tmo_valid) > 0)
+				queue_delayed_work(qedf->link_update_wq,
+				    &qedf->link_recovery, 0);
+			else
+				queue_delayed_work(qedf->link_update_wq,
+				    &qedf->link_update, 0);
+			atomic_set(&qedf->link_down_tmo_valid, 0);
+		}
+
+	} else {
+		QEDF_ERR(&(qedf->dbg_ctx), "LINK DOWN.\n");
+
+		atomic_set(&qedf->link_state, QEDF_LINK_DOWN);
+		atomic_set(&qedf->dcbx, QEDF_DCBX_PENDING);
+		/*
+		 * Flag that we're waiting for the link to come back up before
+		 * informing the fcoe layer of the event.
+		 */
+		if (qedf_link_down_tmo > 0) {
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+			    "Starting link down tmo.\n");
+			atomic_set(&qedf->link_down_tmo_valid, 1);
+		}
+		qedf->vlan_id  = 0;
+		qedf_update_link_speed(qedf, link);
+		queue_delayed_work(qedf->link_update_wq, &qedf->link_update,
+		    qedf_link_down_tmo * HZ);
+	}
+}
+
+
+static void qedf_dcbx_handler(void *dev, struct qed_dcbx_get *get, u32 mib_type)
+{
+	struct qedf_ctx *qedf = (struct qedf_ctx *)dev;
+
+	QEDF_ERR(&(qedf->dbg_ctx), "DCBx event valid=%d enabled=%d fcoe "
+	    "prio=%d.\n", get->operational.valid, get->operational.enabled,
+	    get->operational.app_prio.fcoe);
+
+	if (get->operational.enabled && get->operational.valid) {
+		/* If DCBX was already negotiated on link up then just exit */
+		if (atomic_read(&qedf->dcbx) == QEDF_DCBX_DONE) {
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+			    "DCBX already set on link up.\n");
+			return;
+		}
+
+		atomic_set(&qedf->dcbx, QEDF_DCBX_DONE);
+
+		if (atomic_read(&qedf->link_state) == QEDF_LINK_UP) {
+			if (atomic_read(&qedf->link_down_tmo_valid) > 0)
+				queue_delayed_work(qedf->link_update_wq,
+				    &qedf->link_recovery, 0);
+			else
+				queue_delayed_work(qedf->link_update_wq,
+				    &qedf->link_update, 0);
+			atomic_set(&qedf->link_down_tmo_valid, 0);
+		}
+	}
+
+}
+
+static u32 qedf_get_login_failures(void *cookie)
+{
+	struct qedf_ctx *qedf;
+
+	qedf = (struct qedf_ctx *)cookie;
+	return qedf->flogi_failed;
+}
+
+static struct qed_fcoe_cb_ops qedf_cb_ops = {
+	{
+		.link_update = qedf_link_update,
+		.dcbx_aen = qedf_dcbx_handler,
+	}
+};
+
+/*
+ * Various transport templates.
+ */
+
+static struct scsi_transport_template *qedf_fc_transport_template;
+static struct scsi_transport_template *qedf_fc_vport_transport_template;
+
+/*
+ * SCSI EH handlers
+ */
+static int qedf_eh_abort(struct scsi_cmnd *sc_cmd)
+{
+	struct fc_rport *rport = starget_to_rport(scsi_target(sc_cmd->device));
+	struct fc_rport_libfc_priv *rp = rport->dd_data;
+	struct qedf_rport *fcport;
+	struct fc_lport *lport;
+	struct qedf_ctx *qedf;
+	struct qedf_ioreq *io_req;
+	int rc = FAILED;
+	int rval;
+
+	if (fc_remote_port_chkready(rport)) {
+		QEDF_ERR(NULL, "rport not ready\n");
+		goto out;
+	}
+
+	lport = shost_priv(sc_cmd->device->host);
+	qedf = (struct qedf_ctx *)lport_priv(lport);
+
+	if ((lport->state != LPORT_ST_READY) || !(lport->link_up)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "link not ready.\n");
+		goto out;
+	}
+
+	fcport = (struct qedf_rport *)&rp[1];
+
+	io_req = (struct qedf_ioreq *)sc_cmd->SCp.ptr;
+	if (!io_req) {
+		QEDF_ERR(&(qedf->dbg_ctx), "io_req is NULL.\n");
+		rc = SUCCESS;
+		goto out;
+	}
+
+	if (!test_bit(QEDF_CMD_OUTSTANDING, &io_req->flags) ||
+	    test_bit(QEDF_CMD_IN_CLEANUP, &io_req->flags) ||
+	    test_bit(QEDF_CMD_IN_ABORT, &io_req->flags)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "io_req xid=0x%x already in "
+			  "cleanup or abort processing or already "
+			  "completed.\n", io_req->xid);
+		rc = SUCCESS;
+		goto out;
+	}
+
+	QEDF_ERR(&(qedf->dbg_ctx), "Aborting io_req sc_cmd=%p xid=0x%x "
+		  "fp_idx=%d.\n", sc_cmd, io_req->xid, io_req->fp_idx);
+
+	if (qedf->stop_io_on_error) {
+		qedf_stop_all_io(qedf);
+		rc = SUCCESS;
+		goto out;
+	}
+
+	init_completion(&io_req->abts_done);
+	rval = qedf_initiate_abts(io_req, true);
+	if (rval) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Failed to queue ABTS.\n");
+		goto out;
+	}
+
+	wait_for_completion(&io_req->abts_done);
+
+	if (io_req->event == QEDF_IOREQ_EV_ABORT_SUCCESS ||
+	    io_req->event == QEDF_IOREQ_EV_ABORT_FAILED ||
+	    io_req->event == QEDF_IOREQ_EV_CLEANUP_SUCCESS) {
+		/*
+		 * If we get a reponse to the abort this is success from
+		 * the perspective that all references to the command have
+		 * been removed from the driver and firmware
+		 */
+		rc = SUCCESS;
+	} else {
+		/* If the abort and cleanup failed then return a failure */
+		rc = FAILED;
+	}
+
+	if (rc == SUCCESS)
+		QEDF_ERR(&(qedf->dbg_ctx), "ABTS succeeded, xid=0x%x.\n",
+			  io_req->xid);
+	else
+		QEDF_ERR(&(qedf->dbg_ctx), "ABTS failed, xid=0x%x.\n",
+			  io_req->xid);
+
+out:
+	return rc;
+}
+
+static int qedf_eh_target_reset(struct scsi_cmnd *sc_cmd)
+{
+	QEDF_ERR(NULL, "TARGET RESET Issued...");
+	return qedf_initiate_tmf(sc_cmd, FCP_TMF_TGT_RESET);
+}
+
+static int qedf_eh_device_reset(struct scsi_cmnd *sc_cmd)
+{
+	QEDF_ERR(NULL, "LUN RESET Issued...\n");
+	return qedf_initiate_tmf(sc_cmd, FCP_TMF_LUN_RESET);
+}
+
+void qedf_wait_for_upload(struct qedf_ctx *qedf)
+{
+	while (1) {
+		if (atomic_read(&qedf->num_offloads))
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+			    "Waiting for all uploads to complete.\n");
+		else
+			break;
+		msleep(500);
+	}
+}
+
+/* Reset the host by gracefully logging out and then logging back in */
+static int qedf_eh_host_reset(struct scsi_cmnd *sc_cmd)
+{
+	struct fc_lport *lport;
+	struct qedf_ctx *qedf;
+
+	lport = shost_priv(sc_cmd->device->host);
+
+	if (lport->vport) {
+		QEDF_ERR(NULL, "Cannot issue host reset on NPIV port.\n");
+		return SUCCESS;
+	}
+
+	qedf = (struct qedf_ctx *)lport_priv(lport);
+
+	if (atomic_read(&qedf->link_state) == QEDF_LINK_DOWN ||
+	    test_bit(QEDF_UNLOADING, &qedf->flags))
+		return FAILED;
+
+	QEDF_ERR(&(qedf->dbg_ctx), "HOST RESET Issued...");
+
+	/* For host reset, essentially do a soft link up/down */
+	atomic_set(&qedf->link_state, QEDF_LINK_DOWN);
+	atomic_set(&qedf->dcbx, QEDF_DCBX_PENDING);
+	queue_delayed_work(qedf->link_update_wq, &qedf->link_update,
+	    0);
+	qedf_wait_for_upload(qedf);
+	atomic_set(&qedf->link_state, QEDF_LINK_UP);
+	qedf->vlan_id  = 0;
+	queue_delayed_work(qedf->link_update_wq, &qedf->link_update,
+	    0);
+
+	return SUCCESS;
+}
+
+static int qedf_slave_configure(struct scsi_device *sdev)
+{
+	if (qedf_queue_depth) {
+		scsi_change_queue_depth(sdev, qedf_queue_depth);
+	}
+
+	return 0;
+}
+
+static struct scsi_host_template qedf_host_template = {
+	.module 	= THIS_MODULE,
+	.name 		= QEDF_MODULE_NAME,
+	.this_id 	= -1,
+	.cmd_per_lun 	= 3,
+	.use_clustering = ENABLE_CLUSTERING,
+	.max_sectors 	= 0xffff,
+	.queuecommand 	= qedf_queuecommand,
+	.shost_attrs	= qedf_host_attrs,
+	.eh_abort_handler	= qedf_eh_abort,
+	.eh_device_reset_handler = qedf_eh_device_reset, /* lun reset */
+	.eh_target_reset_handler = qedf_eh_target_reset, /* target reset */
+	.eh_host_reset_handler  = qedf_eh_host_reset,
+	.slave_configure	= qedf_slave_configure,
+	.dma_boundary = QED_HW_DMA_BOUNDARY,
+	.sg_tablesize = QEDF_MAX_BDS_PER_CMD,
+	.can_queue = FCOE_PARAMS_NUM_TASKS,
+};
+
+static int qedf_get_paged_crc_eof(struct sk_buff *skb, int tlen)
+{
+	int rc;
+
+	spin_lock(&qedf_global_lock);
+	rc = fcoe_get_paged_crc_eof(skb, tlen, &qedf_global);
+	spin_unlock(&qedf_global_lock);
+
+	return rc;
+}
+
+/* Assumes qedf->hba_lock held by caller */
+static struct qedf_rport *qedf_fcport_lookup(struct qedf_ctx *qedf, u32 port_id)
+{
+	int i;
+	struct qedf_rport *fcport;
+	struct fc_rport_priv *rdata;
+
+	for (i = 0; i < QEDF_MAX_SESSIONS; i++) {
+		fcport = qedf->fcports[i];
+		if (fcport == NULL)
+			continue;
+		rdata = fcport->rdata;
+		if (rdata == NULL)
+			continue;
+		if (rdata->ids.port_id == port_id)
+			return fcport;
+	}
+	return NULL;
+}
+
+/* Transmits an ELS frame over an offloaded session */
+static int qedf_xmit_l2_frame(struct qedf_rport *fcport, struct fc_frame *fp)
+{
+	struct fc_frame_header *fh;
+	int rc = 0;
+
+	fh = fc_frame_header_get(fp);
+	if ((fh->fh_type == FC_TYPE_ELS) &&
+	    (fh->fh_r_ctl == FC_RCTL_ELS_REQ)) {
+		switch (fc_frame_payload_op(fp)) {
+		case ELS_ADISC:
+			qedf_send_adisc(fcport, fp);
+			rc = 1;
+			break;
+		}
+	}
+
+	return rc;
+}
+
+/**
+ * qedf_xmit - qedf FCoE frame transmit function
+ *
+ */
+static int qedf_xmit(struct fc_lport *lport, struct fc_frame *fp)
+{
+	struct fc_lport		*base_lport;
+	struct qedf_ctx		*qedf;
+	struct ethhdr		*eh;
+	struct fcoe_crc_eof	*cp;
+	struct sk_buff		*skb;
+	struct fc_frame_header	*fh;
+	struct fcoe_hdr		*hp;
+	u8			sof, eof;
+	u32			crc;
+	unsigned int		hlen, tlen, elen;
+	int			wlen;
+	struct fc_stats		*stats;
+	struct fc_lport *tmp_lport;
+	struct fc_lport *vn_port = NULL;
+	struct qedf_rport *fcport;
+	int rc;
+	u16 vlan_tci = 0;
+	unsigned long flags;
+
+	qedf = (struct qedf_ctx *)lport_priv(lport);
+
+	fh = fc_frame_header_get(fp);
+	skb = fp_skb(fp);
+
+	/* Filter out traffic to other NPIV ports on the same host */
+	if (lport->vport)
+		base_lport = shost_priv(vport_to_shost(lport->vport));
+	else
+		base_lport = lport;
+
+	/* Flag if the destination is the base port */
+	if (base_lport->port_id == ntoh24(fh->fh_d_id)) {
+		vn_port = base_lport;
+	} else {
+		/* Got through the list of vports attached to the base_lport
+		 * and see if we have a match with the destination address.
+		 */
+		list_for_each_entry(tmp_lport, &base_lport->vports, list) {
+			if (tmp_lport->port_id == ntoh24(fh->fh_d_id)) {
+				vn_port = tmp_lport;
+				break;
+			}
+		}
+	}
+	if (vn_port && ntoh24(fh->fh_d_id) != FC_FID_FLOGI) {
+		struct fc_rport_priv *rdata = NULL;
+
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_LL2,
+		    "Dropping FCoE frame to %06x.\n", ntoh24(fh->fh_d_id));
+		kfree_skb(skb);
+		rdata = fc_rport_lookup(lport, ntoh24(fh->fh_d_id));
+		if (rdata)
+			rdata->retries = lport->max_rport_retry_count;
+		return -EINVAL;
+	}
+	/* End NPIV filtering */
+
+	if (!qedf->ctlr.sel_fcf) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	if (!test_bit(QEDF_LL2_STARTED, &qedf->flags)) {
+		QEDF_WARN(&(qedf->dbg_ctx), "LL2 not started\n");
+		kfree_skb(skb);
+		return 0;
+	}
+
+	if (atomic_read(&qedf->link_state) != QEDF_LINK_UP) {
+		QEDF_WARN(&(qedf->dbg_ctx), "qedf link down\n");
+		kfree_skb(skb);
+		return 0;
+	}
+
+	if (unlikely(fh->fh_r_ctl == FC_RCTL_ELS_REQ)) {
+		if (fcoe_ctlr_els_send(&qedf->ctlr, lport, skb))
+			return 0;
+	}
+
+	/* Check to see if this needs to be sent on an offloaded session */
+	spin_lock_irqsave(&qedf->hba_lock, flags);
+	fcport = qedf_fcport_lookup(qedf, ntoh24(fh->fh_d_id));
+	spin_unlock_irqrestore(&qedf->hba_lock, flags);
+
+	if (fcport && test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags)) {
+		rc = qedf_xmit_l2_frame(fcport, fp);
+		/*
+		 * If the frame was successfully sent over the middle path
+		 * then do not try to also send it over the LL2 path
+		 */
+		if (rc)
+			return 0;
+	}
+
+	sof = fr_sof(fp);
+	eof = fr_eof(fp);
+
+	elen = sizeof(struct ethhdr);
+	hlen = sizeof(struct fcoe_hdr);
+	tlen = sizeof(struct fcoe_crc_eof);
+	wlen = (skb->len - tlen + sizeof(crc)) / FCOE_WORD_TO_BYTE;
+
+	skb->ip_summed = CHECKSUM_NONE;
+	crc = fcoe_fc_crc(fp);
+
+	/* copy port crc and eof to the skb buff */
+	if (skb_is_nonlinear(skb)) {
+		skb_frag_t *frag;
+
+		if (qedf_get_paged_crc_eof(skb, tlen)) {
+			kfree_skb(skb);
+			return -ENOMEM;
+		}
+		frag = &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
+		cp = kmap_atomic(skb_frag_page(frag)) + frag->page_offset;
+	} else {
+		cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
+	}
+
+	memset(cp, 0, sizeof(*cp));
+	cp->fcoe_eof = eof;
+	cp->fcoe_crc32 = cpu_to_le32(~crc);
+	if (skb_is_nonlinear(skb)) {
+		kunmap_atomic(cp);
+		cp = NULL;
+	}
+
+
+	/* adjust skb network/transport offsets to match mac/fcoe/port */
+	skb_push(skb, elen + hlen);
+	skb_reset_mac_header(skb);
+	skb_reset_network_header(skb);
+	skb->mac_len = elen;
+	skb->protocol = htons(ETH_P_FCOE);
+
+	__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), qedf->vlan_id);
+
+	/* fill up mac and fcoe headers */
+	eh = eth_hdr(skb);
+	eh->h_proto = htons(ETH_P_FCOE);
+	if (qedf->ctlr.map_dest)
+		fc_fcoe_set_mac(eh->h_dest, fh->fh_d_id);
+	else
+		/* insert GW address */
+		ether_addr_copy(eh->h_dest, qedf->ctlr.dest_addr);
+
+	/* Set the source MAC address */
+	fc_fcoe_set_mac(eh->h_source, fh->fh_s_id);
+
+	hp = (struct fcoe_hdr *)(eh + 1);
+	memset(hp, 0, sizeof(*hp));
+	if (FC_FCOE_VER)
+		FC_FCOE_ENCAPS_VER(hp, FC_FCOE_VER);
+	hp->fcoe_sof = sof;
+
+	/*update tx stats */
+	stats = per_cpu_ptr(lport->stats, get_cpu());
+	stats->TxFrames++;
+	stats->TxWords += wlen;
+	put_cpu();
+
+	/* Get VLAN ID from skb for printing purposes */
+	__vlan_hwaccel_get_tag(skb, &vlan_tci);
+
+	/* send down to lld */
+	fr_dev(fp) = lport;
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_LL2, "FCoE frame send: "
+	    "src=%06x dest=%06x r_ctl=%x type=%x vlan=%04x.\n",
+	    ntoh24(fh->fh_s_id), ntoh24(fh->fh_d_id), fh->fh_r_ctl, fh->fh_type,
+	    vlan_tci);
+	if (qedf_dump_frames)
+		print_hex_dump(KERN_WARNING, "fcoe: ", DUMP_PREFIX_OFFSET, 16,
+		    1, skb->data, skb->len, false);
+	qed_ops->ll2->start_xmit(qedf->cdev, skb);
+
+	return 0;
+}
+
+static int qedf_alloc_sq(struct qedf_ctx *qedf, struct qedf_rport *fcport)
+{
+	int rval = 0;
+	u32 *pbl;
+	dma_addr_t page;
+	int num_pages;
+
+	/* Calculate appropriate queue and PBL sizes */
+	fcport->sq_mem_size = SQ_NUM_ENTRIES * sizeof(struct fcoe_wqe);
+	fcport->sq_mem_size = ALIGN(fcport->sq_mem_size, QEDF_PAGE_SIZE);
+	fcport->sq_pbl_size = (fcport->sq_mem_size / QEDF_PAGE_SIZE) *
+	    sizeof(void *);
+	fcport->sq_pbl_size = fcport->sq_pbl_size + QEDF_PAGE_SIZE;
+
+	fcport->sq = dma_alloc_coherent(&qedf->pdev->dev, fcport->sq_mem_size,
+	    &fcport->sq_dma, GFP_KERNEL);
+	if (!fcport->sq) {
+		QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate send "
+			   "queue.\n");
+		rval = 1;
+		goto out;
+	}
+	memset(fcport->sq, 0, fcport->sq_mem_size);
+
+	fcport->sq_pbl = dma_alloc_coherent(&qedf->pdev->dev,
+	    fcport->sq_pbl_size, &fcport->sq_pbl_dma, GFP_KERNEL);
+	if (!fcport->sq_pbl) {
+		QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate send "
+			   "queue PBL.\n");
+		rval = 1;
+		goto out_free_sq;
+	}
+	memset(fcport->sq_pbl, 0, fcport->sq_pbl_size);
+
+	/* Create PBL */
+	num_pages = fcport->sq_mem_size / QEDF_PAGE_SIZE;
+	page = fcport->sq_dma;
+	pbl = (u32 *)fcport->sq_pbl;
+
+	while (num_pages--) {
+		*pbl = U64_LO(page);
+		pbl++;
+		*pbl = U64_HI(page);
+		pbl++;
+		page += QEDF_PAGE_SIZE;
+	}
+
+	return rval;
+
+out_free_sq:
+	dma_free_coherent(&qedf->pdev->dev, fcport->sq_mem_size, fcport->sq,
+	    fcport->sq_dma);
+out:
+	return rval;
+}
+
+static void qedf_free_sq(struct qedf_ctx *qedf, struct qedf_rport *fcport)
+{
+	if (fcport->sq_pbl)
+		dma_free_coherent(&qedf->pdev->dev, fcport->sq_pbl_size,
+		    fcport->sq_pbl, fcport->sq_pbl_dma);
+	if (fcport->sq)
+		dma_free_coherent(&qedf->pdev->dev, fcport->sq_mem_size,
+		    fcport->sq, fcport->sq_dma);
+}
+
+/*
+ * Allocate a cookie into the qedf_ctx rport list.  Assumes the hba lock
+ * is held on entry.
+ */
+static int qedf_alloc_conn_id(struct qedf_ctx *qedf, struct qedf_rport *fcport)
+{
+	int i;
+
+	for (i = 0; i < QEDF_MAX_SESSIONS; i++) {
+		qedf->curr_conn_id++;
+		if (qedf->curr_conn_id == QEDF_MAX_SESSIONS)
+			qedf->curr_conn_id = 0;
+		if (qedf->fcports[qedf->curr_conn_id] == NULL) {
+			qedf->fcports[qedf->curr_conn_id] = fcport;
+			fcport->conn_id = qedf->curr_conn_id;
+			break;
+		}
+	}
+	if (i == QEDF_MAX_SESSIONS)
+		return -1;
+	else
+		return 0;
+}
+
+static int qedf_offload_connection(struct qedf_ctx *qedf,
+	struct qedf_rport *fcport)
+{
+	struct qed_fcoe_params_offload conn_info;
+	u32 port_id;
+	u8 lport_src_id[3];
+	int rval;
+	uint16_t total_sqe = (fcport->sq_mem_size / sizeof(struct fcoe_wqe));
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN, "Offloading connection "
+		   "portid=%06x.\n", fcport->rdata->ids.port_id);
+	rval = qed_ops->acquire_conn(qedf->cdev, &fcport->handle,
+	    &fcport->fw_cid, &fcport->p_doorbell);
+	if (rval) {
+		QEDF_WARN(&(qedf->dbg_ctx), "Could not acquire connection "
+			   "for portid=%06x.\n", fcport->rdata->ids.port_id);
+		rval = 1; /* For some reason qed returns 0 on failure here */
+		goto out;
+	}
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN, "portid=%06x "
+		   "fw_cid=%08x handle=%d.\n", fcport->rdata->ids.port_id,
+		   fcport->fw_cid, fcport->handle);
+
+	memset(&conn_info, 0, sizeof(struct qed_fcoe_params_offload));
+
+	/* Fill in the offload connection info */
+	conn_info.sq_pbl_addr = fcport->sq_pbl_dma;
+
+	conn_info.sq_curr_page_addr = (dma_addr_t)(*(u64 *)fcport->sq_pbl);
+	conn_info.sq_next_page_addr =
+	    (dma_addr_t)(*(u64 *)(fcport->sq_pbl + 8));
+
+	/* Need to use our FCoE MAC for the offload session */
+	port_id = fc_host_port_id(qedf->lport->host);
+	lport_src_id[2] = (port_id & 0x000000FF);
+	lport_src_id[1] = (port_id & 0x0000FF00) >> 8;
+	lport_src_id[0] = (port_id & 0x00FF0000) >> 16;
+	fc_fcoe_set_mac(conn_info.src_mac, lport_src_id);
+
+	ether_addr_copy(conn_info.dst_mac, qedf->ctlr.dest_addr);
+
+	conn_info.tx_max_fc_pay_len = fcport->rdata->maxframe_size;
+	conn_info.e_d_tov_timer_val = qedf->lport->e_d_tov / 20;
+	conn_info.rec_tov_timer_val = 3; /* I think this is what E3 was */
+	conn_info.rx_max_fc_pay_len = fcport->rdata->maxframe_size;
+
+	/* Set VLAN data */
+	conn_info.vlan_tag = qedf->vlan_id <<
+	    FCOE_CONN_OFFLOAD_RAMROD_DATA_VLAN_ID_SHIFT;
+	conn_info.vlan_tag |=
+	    qedf_default_prio << FCOE_CONN_OFFLOAD_RAMROD_DATA_PRIORITY_SHIFT;
+	conn_info.flags |= (FCOE_CONN_OFFLOAD_RAMROD_DATA_B_VLAN_FLAG_MASK <<
+	    FCOE_CONN_OFFLOAD_RAMROD_DATA_B_VLAN_FLAG_SHIFT);
+
+	/* Set host port source id */
+	port_id = fc_host_port_id(qedf->lport->host);
+	fcport->sid = port_id;
+	conn_info.s_id.addr_hi = (port_id & 0x000000FF);
+	conn_info.s_id.addr_mid = (port_id & 0x0000FF00) >> 8;
+	conn_info.s_id.addr_lo = (port_id & 0x00FF0000) >> 16;
+
+	conn_info.max_conc_seqs_c3 = fcport->rdata->max_seq;
+
+	/* Set remote port destination id */
+	port_id = fcport->rdata->rport->port_id;
+	conn_info.d_id.addr_hi = (port_id & 0x000000FF);
+	conn_info.d_id.addr_mid = (port_id & 0x0000FF00) >> 8;
+	conn_info.d_id.addr_lo = (port_id & 0x00FF0000) >> 16;
+
+	conn_info.def_q_idx = 0; /* Default index for send queue? */
+
+	/* Set FC-TAPE specific flags if needed */
+	if (fcport->dev_type == QEDF_RPORT_TYPE_TAPE) {
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN,
+		    "Enable CONF, REC for portid=%06x.\n",
+		    fcport->rdata->ids.port_id);
+		conn_info.flags |= 1 <<
+		    FCOE_CONN_OFFLOAD_RAMROD_DATA_B_CONF_REQ_SHIFT;
+		conn_info.flags |=
+		    ((fcport->rdata->sp_features & FC_SP_FT_SEQC) ? 1 : 0) <<
+		    FCOE_CONN_OFFLOAD_RAMROD_DATA_B_REC_VALID_SHIFT;
+	}
+
+	rval = qed_ops->offload_conn(qedf->cdev, fcport->handle, &conn_info);
+	if (rval) {
+		QEDF_WARN(&(qedf->dbg_ctx), "Could not offload connection "
+			   "for portid=%06x.\n", fcport->rdata->ids.port_id);
+		goto out_free_conn;
+	} else
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN, "Offload "
+			   "succeeded portid=%06x total_sqe=%d.\n",
+			   fcport->rdata->ids.port_id, total_sqe);
+
+	spin_lock_init(&fcport->rport_lock);
+	atomic_set(&fcport->free_sqes, total_sqe);
+	return 0;
+out_free_conn:
+	qed_ops->release_conn(qedf->cdev, fcport->handle);
+out:
+	return rval;
+}
+
+#define QEDF_TERM_BUFF_SIZE		10
+static void qedf_upload_connection(struct qedf_ctx *qedf,
+	struct qedf_rport *fcport)
+{
+	void *term_params;
+	dma_addr_t term_params_dma;
+
+	/* Term params needs to be a DMA coherent buffer as qed shared the
+	 * physical DMA address with the firmware. The buffer may be used in
+	 * the receive path so we may eventually have to move this.
+	 */
+	term_params = dma_alloc_coherent(&qedf->pdev->dev, QEDF_TERM_BUFF_SIZE,
+		&term_params_dma, GFP_KERNEL);
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN, "Uploading connection "
+		   "port_id=%06x.\n", fcport->rdata->ids.port_id);
+
+	qed_ops->destroy_conn(qedf->cdev, fcport->handle, term_params_dma);
+	qed_ops->release_conn(qedf->cdev, fcport->handle);
+
+	dma_free_coherent(&qedf->pdev->dev, QEDF_TERM_BUFF_SIZE, term_params,
+	    term_params_dma);
+}
+
+static void qedf_cleanup_fcport(struct qedf_ctx *qedf,
+	struct qedf_rport *fcport)
+{
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN, "Clearing conn_id=%u "
+		   "for portid=%06x.\n", fcport->conn_id,
+		   fcport->rdata->ids.port_id);
+
+	/* Flush any remaining i/o's before we upload the connection */
+	qedf_flush_active_ios(fcport, -1);
+
+	spin_lock(&qedf->hba_lock);
+	qedf->fcports[fcport->conn_id] = NULL;
+	fcport->conn_id = -1;
+	spin_unlock(&qedf->hba_lock);
+
+	if (test_and_clear_bit(QEDF_RPORT_SESSION_READY, &fcport->flags))
+		qedf_upload_connection(qedf, fcport);
+	qedf_free_sq(qedf, fcport);
+	fcport->rdata = NULL;
+	fcport->qedf = NULL;
+}
+
+/**
+ * This event_callback is called after successful completion of libfc
+ * initiated target login. qedf can proceed with initiating the session
+ * establishment.
+ */
+static void qedf_rport_event_handler(struct fc_lport *lport,
+				struct fc_rport_priv *rdata,
+				enum fc_rport_event event)
+{
+	struct qedf_ctx *qedf = lport_priv(lport);
+	struct fc_rport *rport = rdata->rport;
+	struct fc_rport_libfc_priv *rp;
+	struct qedf_rport *fcport;
+	u32 port_id;
+	int rval;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "event = %d, "
+		   "port_id = 0x%x\n", event, rdata->ids.port_id);
+
+	switch (event) {
+	case RPORT_EV_READY:
+		if (!rport) {
+			QEDF_WARN(&(qedf->dbg_ctx), "rport is NULL.\n");
+			break;
+		}
+
+		rp = rport->dd_data;
+		fcport = (struct qedf_rport *)&rp[1];
+		fcport->qedf = qedf;
+
+		/*
+		 * Don't try to offload the session again. Can happen when we
+		 * get an ADISC
+		 */
+		if (test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags)) {
+			QEDF_WARN(&(qedf->dbg_ctx), "Session already "
+				   "offloaded, portid=0x%x.\n",
+				   rdata->ids.port_id);
+			return;
+		}
+
+		/*
+		 * Set the connection id to -1 so we know if we ever assigned
+		 * one to the fcport.
+		 */
+		fcport->conn_id = -1;
+
+		if (rport->port_id == FC_FID_DIR_SERV) {
+			/*
+			 * qedf_rport structure doesn't exist for
+			 * directory server.
+			 * We should not come here, as lport will
+			 * take care of fabric login
+			 */
+			QEDF_WARN(&(qedf->dbg_ctx), "rport struct does not "
+			    "exist for dir server port_id=%x\n",
+			    rdata->ids.port_id);
+			break;
+		}
+
+		if (rdata->spp_type != FC_TYPE_FCP) {
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+			    "Not offlading since since spp type isn't FCP\n");
+			break;
+		}
+		if (!(rdata->ids.roles & FC_RPORT_ROLE_FCP_TARGET)) {
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+			    "Not FCP target so not offloading\n");
+			break;
+		}
+
+		spin_lock(&qedf->hba_lock);
+		rval = qedf_alloc_conn_id(qedf, fcport);
+		spin_unlock(&qedf->hba_lock);
+
+		if (rval) {
+			QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate "
+				   "conn_id for port %06x.\n",
+				   rdata->ids.port_id);
+			break;
+		}
+
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+			   "Assigned conn_id=%u to port_id=%06x.\n",
+			    fcport->conn_id, rdata->ids.port_id);
+
+		fcport->rdata = rdata;
+		fcport->rport = rport;
+
+		rval = qedf_alloc_sq(qedf, fcport);
+		if (rval) {
+			qedf_cleanup_fcport(qedf, fcport);
+			break;
+		}
+
+		/* Set device type */
+		if (rdata->flags & FC_RP_FLAGS_RETRY &&
+		    rdata->ids.roles & FC_RPORT_ROLE_FCP_TARGET &&
+		    !(rdata->ids.roles & FC_RPORT_ROLE_FCP_INITIATOR)) {
+			fcport->dev_type = QEDF_RPORT_TYPE_TAPE;
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+			    "portid=%06x is a TAPE device.\n",
+			    rdata->ids.port_id);
+		} else {
+			fcport->dev_type = QEDF_RPORT_TYPE_DISK;
+		}
+
+		rval = qedf_offload_connection(qedf, fcport);
+		if (rval) {
+			qedf_cleanup_fcport(qedf, fcport);
+			break;
+		}
+
+		/*
+		 * Set the session ready bit to let everyone know that this
+		 * connection is ready for I/O
+		 */
+		set_bit(QEDF_RPORT_SESSION_READY, &fcport->flags);
+		atomic_inc(&qedf->num_offloads);
+
+		break;
+	case RPORT_EV_LOGO:
+	case RPORT_EV_FAILED:
+	case RPORT_EV_STOP:
+		port_id = rdata->ids.port_id;
+		if (port_id == FC_FID_DIR_SERV)
+			break;
+
+		if (!rport) {
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+			    "port_id=%x - rport notcreated Yet!!\n", port_id);
+			break;
+		}
+		rp = rport->dd_data;
+		/*
+		 * Perform session upload. Note that rdata->peers is already
+		 * removed from disc->rports list before we get this event.
+		 */
+		fcport = (struct qedf_rport *)&rp[1];
+
+		/*
+		 * Only free the conn_id if this fcport was initialized with
+		 * one.
+		 */
+		if (fcport->conn_id > -1) {
+			set_bit(QEDF_RPORT_UPLOADING_CONNECTION, &fcport->flags);
+			qedf_cleanup_fcport(qedf, fcport);
+			clear_bit(QEDF_RPORT_UPLOADING_CONNECTION,
+			    &fcport->flags);
+			atomic_dec(&qedf->num_offloads);
+		}
+
+		break;
+
+	case RPORT_EV_NONE:
+		break;
+	}
+}
+
+static void qedf_abort_io(struct fc_lport *lport)
+{
+	/* NO-OP but need to fill in the template */
+}
+
+static void qedf_fcp_cleanup(struct fc_lport *lport)
+{
+	/*
+	 * NO-OP but need to fill in template to prevent a NULL
+	 * function pointer dereference during link down. I/Os
+	 * will be flushed when port is uploaded.
+	 */
+}
+
+static struct libfc_function_template qedf_lport_template = {
+	.frame_send		= qedf_xmit,
+	.fcp_abort_io		= qedf_abort_io,
+	.fcp_cleanup		= qedf_fcp_cleanup,
+	.rport_event_callback	= qedf_rport_event_handler,
+	.elsct_send		= qedf_elsct_send,
+};
+
+static void qedf_fcoe_ctlr_setup(struct qedf_ctx *qedf)
+{
+	fcoe_ctlr_init(&qedf->ctlr, FIP_ST_AUTO);
+
+	qedf->ctlr.send = qedf_fip_send;
+	qedf->ctlr.update_mac = qedf_update_src_mac;
+	qedf->ctlr.get_src_addr = qedf_get_src_mac;
+	ether_addr_copy(qedf->ctlr.ctl_src_addr, qedf->mac);
+}
+
+static int qedf_lport_setup(struct qedf_ctx *qedf)
+{
+	struct fc_lport *lport = qedf->lport;
+
+	lport->link_up = 0;
+	lport->max_retry_count = QEDF_FLOGI_RETRY_CNT;
+	lport->max_rport_retry_count = QEDF_RPORT_RETRY_CNT;
+	lport->service_params = (FCP_SPPF_INIT_FCN | FCP_SPPF_RD_XRDY_DIS |
+	    FCP_SPPF_RETRY | FCP_SPPF_CONF_COMPL);
+	lport->boot_time = jiffies;
+	lport->e_d_tov = 2 * 1000;
+	lport->r_a_tov = 10 * 1000;
+
+	/* Set NPIV support */
+	lport->does_npiv = 1;
+	fc_host_max_npiv_vports(lport->host) = QEDF_MAX_NPIV;
+
+	fc_set_wwnn(lport, qedf->wwnn);
+	fc_set_wwpn(lport, qedf->wwpn);
+
+	fcoe_libfc_config(lport, &qedf->ctlr, &qedf_lport_template, 0);
+
+	/* Allocate the exchange manager */
+	fc_exch_mgr_alloc(lport, FC_CLASS_3, qedf->max_scsi_xid + 1,
+	    qedf->max_els_xid, NULL);
+
+	if (fc_lport_init_stats(lport))
+		return -ENOMEM;
+
+	/* Finish lport config */
+	fc_lport_config(lport);
+
+	/* Set max frame size */
+	fc_set_mfs(lport, QEDF_MFS);
+	fc_host_maxframe_size(lport->host) = lport->mfs;
+
+	/* Set default dev_loss_tmo based on module parameter */
+	fc_host_dev_loss_tmo(lport->host) = qedf_dev_loss_tmo;
+
+	/* Set symbolic node name */
+	snprintf(fc_host_symbolic_name(lport->host), 256,
+	    "QLogic %s v%s", QEDF_MODULE_NAME, QEDF_VERSION);
+
+	return 0;
+}
+
+/*
+ * NPIV functions
+ */
+
+static int qedf_vport_libfc_config(struct fc_vport *vport,
+	struct fc_lport *lport)
+{
+	lport->link_up = 0;
+	lport->qfull = 0;
+	lport->max_retry_count = QEDF_FLOGI_RETRY_CNT;
+	lport->max_rport_retry_count = QEDF_RPORT_RETRY_CNT;
+	lport->service_params = (FCP_SPPF_INIT_FCN | FCP_SPPF_RD_XRDY_DIS |
+	    FCP_SPPF_RETRY | FCP_SPPF_CONF_COMPL);
+	lport->boot_time = jiffies;
+	lport->e_d_tov = 2 * 1000;
+	lport->r_a_tov = 10 * 1000;
+	lport->does_npiv = 1; /* Temporary until we add NPIV support */
+
+	/* Allocate stats for vport */
+	if (fc_lport_init_stats(lport))
+		return -ENOMEM;
+
+	/* Finish lport config */
+	fc_lport_config(lport);
+
+	/* offload related configuration */
+	lport->crc_offload = 0;
+	lport->seq_offload = 0;
+	lport->lro_enabled = 0;
+	lport->lro_xid = 0;
+	lport->lso_max = 0;
+
+	return 0;
+}
+
+static int qedf_vport_create(struct fc_vport *vport, bool disabled)
+{
+	struct Scsi_Host *shost = vport_to_shost(vport);
+	struct fc_lport *n_port = shost_priv(shost);
+	struct fc_lport *vn_port;
+	struct qedf_ctx *base_qedf = lport_priv(n_port);
+	struct qedf_ctx *vport_qedf;
+	int i;
+
+	char buf[32];
+	int rc = 0;
+
+	rc = fcoe_validate_vport_create(vport);
+	if (rc) {
+		fcoe_wwn_to_str(vport->port_name, buf, sizeof(buf));
+		QEDF_WARN(&(base_qedf->dbg_ctx), "Failed to create vport, "
+			   "WWPN (0x%s) already exists.\n", buf);
+		goto err1;
+	}
+
+	if (atomic_read(&base_qedf->link_state) != QEDF_LINK_UP) {
+		QEDF_WARN(&(base_qedf->dbg_ctx), "Cannot create vport "
+			   "because link is not up.\n");
+		rc = -EIO;
+		goto err1;
+	}
+
+	vn_port = libfc_vport_create(vport, sizeof(struct qedf_ctx));
+	if (!vn_port) {
+		QEDF_WARN(&(base_qedf->dbg_ctx), "Could not create lport "
+			   "for vport.\n");
+		rc = -ENOMEM;
+		goto err1;
+	}
+
+	fcoe_wwn_to_str(vport->port_name, buf, sizeof(buf));
+	QEDF_ERR(&(base_qedf->dbg_ctx), "Creating NPIV port, WWPN=%s.\n",
+	    buf);
+
+	/* Copy some fields from base_qedf */
+	vport_qedf = lport_priv(vn_port);
+	memcpy(vport_qedf, base_qedf, sizeof(struct qedf_ctx));
+
+	/* Set qedf data specific to this vport */
+	vport_qedf->lport = vn_port;
+	/* Use same hba_lock as base_qedf */
+	vport_qedf->hba_lock = base_qedf->hba_lock;
+	/* Purge any fcport info from base_qedf */
+	for (i = 0; i < QEDF_MAX_SESSIONS; i++)
+		vport_qedf->fcports[i] = NULL;
+	vport_qedf->pdev = base_qedf->pdev;
+	vport_qedf->cmd_mgr = base_qedf->cmd_mgr;
+	init_completion(&vport_qedf->flogi_compl);
+
+	rc = qedf_vport_libfc_config(vport, vn_port);
+	if (rc) {
+		QEDF_ERR(&(base_qedf->dbg_ctx), "Could not allocate memory "
+		    "for lport stats.\n");
+		goto err2;
+	}
+
+	fc_set_wwnn(vn_port, vport->node_name);
+	fc_set_wwpn(vn_port, vport->port_name);
+	vport_qedf->wwnn = vn_port->wwnn;
+	vport_qedf->wwpn = vn_port->wwpn;
+
+	vn_port->host->transportt = qedf_fc_vport_transport_template;
+	vn_port->host->can_queue = QEDF_MAX_ELS_XID;
+	vn_port->host->max_lun = qedf_max_lun;
+	vn_port->host->sg_tablesize = QEDF_MAX_BDS_PER_CMD;
+	vn_port->host->max_cmd_len = QEDF_MAX_CDB_LEN;
+
+	rc = scsi_add_host(vn_port->host, &vport->dev);
+	if (rc) {
+		QEDF_WARN(&(base_qedf->dbg_ctx), "Error adding Scsi_Host.\n");
+		goto err2;
+	}
+
+	/* Set default dev_loss_tmo based on module parameter */
+	fc_host_dev_loss_tmo(vn_port->host) = qedf_dev_loss_tmo;
+
+	/* Init libfc stuffs */
+	memcpy(&vn_port->tt, &qedf_lport_template,
+		sizeof(qedf_lport_template));
+	fc_exch_init(vn_port);
+	fc_elsct_init(vn_port);
+	fc_lport_init(vn_port);
+	fc_disc_init(vn_port);
+	fc_disc_config(vn_port, vn_port);
+
+
+	/* Allocate the exchange manager */
+	shost = vport_to_shost(vport);
+	n_port = shost_priv(shost);
+	fc_exch_mgr_list_clone(n_port, vn_port);
+
+	/* Set max frame size */
+	fc_set_mfs(vn_port, QEDF_MFS);
+
+	fc_host_port_type(vn_port->host) = FC_PORTTYPE_UNKNOWN;
+
+	if (disabled) {
+		fc_vport_set_state(vport, FC_VPORT_DISABLED);
+	} else {
+		vn_port->boot_time = jiffies;
+		fc_fabric_login(vn_port);
+		fc_vport_setlink(vn_port);
+	}
+
+	QEDF_INFO(&(base_qedf->dbg_ctx), QEDF_LOG_NPIV, "vn_port=%p.\n",
+		   vn_port);
+
+	/* Set up debug context for vport */
+	vport_qedf->dbg_ctx.host_no = vn_port->host->host_no;
+	vport_qedf->dbg_ctx.pdev = base_qedf->pdev;
+
+err2:
+	scsi_host_put(vn_port->host);
+err1:
+	return rc;
+}
+
+static int qedf_vport_destroy(struct fc_vport *vport)
+{
+	struct Scsi_Host *shost = vport_to_shost(vport);
+	struct fc_lport *n_port = shost_priv(shost);
+	struct fc_lport *vn_port = vport->dd_data;
+
+	mutex_lock(&n_port->lp_mutex);
+	list_del(&vn_port->list);
+	mutex_unlock(&n_port->lp_mutex);
+
+	fc_fabric_logoff(vn_port);
+	fc_lport_destroy(vn_port);
+
+	/* Detach from scsi-ml */
+	fc_remove_host(vn_port->host);
+	scsi_remove_host(vn_port->host);
+
+	/*
+	 * Only try to release the exchange manager if the vn_port
+	 * configuration is complete.
+	 */
+	if (vn_port->state == LPORT_ST_READY)
+		fc_exch_mgr_free(vn_port);
+
+	/* Free memory used by statistical counters */
+	fc_lport_free_stats(vn_port);
+
+	/* Release Scsi_Host */
+	if (vn_port->host)
+		scsi_host_put(vn_port->host);
+
+	return 0;
+}
+
+static int qedf_vport_disable(struct fc_vport *vport, bool disable)
+{
+	struct fc_lport *lport = vport->dd_data;
+
+	if (disable) {
+		fc_vport_set_state(vport, FC_VPORT_DISABLED);
+		fc_fabric_logoff(lport);
+	} else {
+		lport->boot_time = jiffies;
+		fc_fabric_login(lport);
+		fc_vport_setlink(lport);
+	}
+	return 0;
+}
+
+/*
+ * During removal we need to wait for all the vports associated with a port
+ * to be destroyed so we avoid a race condition where libfc is still trying
+ * to reap vports while the driver remove function has already reaped the
+ * driver contexts associated with the physical port.
+ */
+static void qedf_wait_for_vport_destroy(struct qedf_ctx *qedf)
+{
+	struct fc_host_attrs *fc_host = shost_to_fc_host(qedf->lport->host);
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_NPIV,
+	    "Entered.\n");
+	while (fc_host->npiv_vports_inuse > 0) {
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_NPIV,
+		    "Waiting for all vports to be reaped.\n");
+		msleep(1000);
+	}
+}
+
+/**
+ * qedf_fcoe_reset - Resets the fcoe
+ *
+ * @shost: shost the reset is from
+ *
+ * Returns: always 0
+ */
+static int qedf_fcoe_reset(struct Scsi_Host *shost)
+{
+	struct fc_lport *lport = shost_priv(shost);
+
+	fc_fabric_logoff(lport);
+	fc_fabric_login(lport);
+	return 0;
+}
+
+static struct fc_host_statistics *qedf_fc_get_host_stats(struct Scsi_Host
+	*shost)
+{
+	struct fc_host_statistics *qedf_stats;
+	struct fc_lport *lport = shost_priv(shost);
+	struct qedf_ctx *qedf = lport_priv(lport);
+	struct qed_fcoe_stats *fw_fcoe_stats;
+
+	qedf_stats = fc_get_host_stats(shost);
+
+	/* We don't collect offload stats for specific NPIV ports */
+	if (lport->vport)
+		goto out;
+
+	fw_fcoe_stats = kmalloc(sizeof(struct qed_fcoe_stats), GFP_KERNEL);
+	if (!fw_fcoe_stats) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Could not allocate memory for "
+		    "fw_fcoe_stats.\n");
+		goto out;
+	}
+
+	/* Query firmware for offload stats */
+	qed_ops->get_stats(qedf->cdev, fw_fcoe_stats);
+
+	/*
+	 * The expectation is that we add our offload stats to the stats
+	 * being maintained by libfc each time the fc_get_host_status callback
+	 * is invoked. The additions are not carried over for each call to
+	 * the fc_get_host_stats callback.
+	 */
+	qedf_stats->tx_frames += fw_fcoe_stats->fcoe_tx_data_pkt_cnt +
+	    fw_fcoe_stats->fcoe_tx_xfer_pkt_cnt +
+	    fw_fcoe_stats->fcoe_tx_other_pkt_cnt;
+	qedf_stats->rx_frames += fw_fcoe_stats->fcoe_rx_data_pkt_cnt +
+	    fw_fcoe_stats->fcoe_rx_xfer_pkt_cnt +
+	    fw_fcoe_stats->fcoe_rx_other_pkt_cnt;
+	qedf_stats->fcp_input_megabytes += fw_fcoe_stats->fcoe_rx_byte_cnt /
+	    1000000;
+	qedf_stats->fcp_output_megabytes += fw_fcoe_stats->fcoe_tx_byte_cnt /
+	    1000000;
+	qedf_stats->rx_words += fw_fcoe_stats->fcoe_rx_byte_cnt / 4;
+	qedf_stats->tx_words += fw_fcoe_stats->fcoe_tx_byte_cnt / 4;
+	qedf_stats->invalid_crc_count +=
+	    fw_fcoe_stats->fcoe_silent_drop_pkt_crc_error_cnt;
+	qedf_stats->dumped_frames =
+	    fw_fcoe_stats->fcoe_silent_drop_total_pkt_cnt;
+	qedf_stats->error_frames +=
+	    fw_fcoe_stats->fcoe_silent_drop_total_pkt_cnt;
+	qedf_stats->fcp_input_requests += qedf->input_requests;
+	qedf_stats->fcp_output_requests += qedf->output_requests;
+	qedf_stats->fcp_control_requests += qedf->control_requests;
+	qedf_stats->fcp_packet_aborts += qedf->packet_aborts;
+	qedf_stats->fcp_frame_alloc_failures += qedf->alloc_failures;
+
+	kfree(fw_fcoe_stats);
+out:
+	return qedf_stats;
+}
+
+static struct fc_function_template qedf_fc_transport_fn = {
+	.show_host_node_name = 1,
+	.show_host_port_name = 1,
+	.show_host_supported_classes = 1,
+	.show_host_supported_fc4s = 1,
+	.show_host_active_fc4s = 1,
+	.show_host_maxframe_size = 1,
+
+	.show_host_port_id = 1,
+	.show_host_supported_speeds = 1,
+	.get_host_speed = fc_get_host_speed,
+	.show_host_speed = 1,
+	.show_host_port_type = 1,
+	.get_host_port_state = fc_get_host_port_state,
+	.show_host_port_state = 1,
+	.show_host_symbolic_name = 1,
+
+	/*
+	 * Tell FC transport to allocate enough space to store the backpointer
+	 * for the associate qedf_rport struct.
+	 */
+	.dd_fcrport_size = (sizeof(struct fc_rport_libfc_priv) +
+				sizeof(struct qedf_rport)),
+	.show_rport_maxframe_size = 1,
+	.show_rport_supported_classes = 1,
+	.show_host_fabric_name = 1,
+	.show_starget_node_name = 1,
+	.show_starget_port_name = 1,
+	.show_starget_port_id = 1,
+	.set_rport_dev_loss_tmo = fc_set_rport_loss_tmo,
+	.show_rport_dev_loss_tmo = 1,
+	.get_fc_host_stats = qedf_fc_get_host_stats,
+	.issue_fc_host_lip = qedf_fcoe_reset,
+	.vport_create = qedf_vport_create,
+	.vport_delete = qedf_vport_destroy,
+	.vport_disable = qedf_vport_disable,
+	.bsg_request = fc_lport_bsg_request,
+};
+
+static struct fc_function_template qedf_fc_vport_transport_fn = {
+	.show_host_node_name = 1,
+	.show_host_port_name = 1,
+	.show_host_supported_classes = 1,
+	.show_host_supported_fc4s = 1,
+	.show_host_active_fc4s = 1,
+	.show_host_maxframe_size = 1,
+	.show_host_port_id = 1,
+	.show_host_supported_speeds = 1,
+	.get_host_speed = fc_get_host_speed,
+	.show_host_speed = 1,
+	.show_host_port_type = 1,
+	.get_host_port_state = fc_get_host_port_state,
+	.show_host_port_state = 1,
+	.show_host_symbolic_name = 1,
+	.dd_fcrport_size = (sizeof(struct fc_rport_libfc_priv) +
+				sizeof(struct qedf_rport)),
+	.show_rport_maxframe_size = 1,
+	.show_rport_supported_classes = 1,
+	.show_host_fabric_name = 1,
+	.show_starget_node_name = 1,
+	.show_starget_port_name = 1,
+	.show_starget_port_id = 1,
+	.set_rport_dev_loss_tmo = fc_set_rport_loss_tmo,
+	.show_rport_dev_loss_tmo = 1,
+	.get_fc_host_stats = fc_get_host_stats,
+	.issue_fc_host_lip = qedf_fcoe_reset,
+	.bsg_request = fc_lport_bsg_request,
+};
+
+static bool qedf_fp_has_work(struct qedf_fastpath *fp)
+{
+	struct qedf_ctx *qedf = fp->qedf;
+	struct global_queue *que;
+	struct qed_sb_info *sb_info = fp->sb_info;
+	struct status_block *sb = sb_info->sb_virt;
+	u16 prod_idx;
+
+	/* Get the pointer to the global CQ this completion is on */
+	que = qedf->global_queues[fp->sb_id];
+
+	rmb();
+
+	/* Get the current firmware producer index */
+	prod_idx = sb->pi_array[QEDF_FCOE_PARAMS_GL_RQ_PI];
+
+	return (que->cq_prod_idx != prod_idx);
+}
+
+/*
+ * Interrupt handler code.
+ */
+
+/* Process completion queue and copy CQE contents for deferred processesing
+ *
+ * Return true if we should wake the I/O thread, false if not.
+ */
+static bool qedf_process_completions(struct qedf_fastpath *fp)
+{
+	struct qedf_ctx *qedf = fp->qedf;
+	struct qed_sb_info *sb_info = fp->sb_info;
+	struct status_block *sb = sb_info->sb_virt;
+	struct global_queue *que;
+	u16 prod_idx;
+	struct fcoe_cqe *cqe;
+	struct qedf_io_work *work;
+	unsigned long flags;
+	int num_handled = 0;
+	unsigned int cpu;
+	struct qedf_ioreq *io_req = NULL;
+	struct qedf_percpu_iothread_s *iothread;
+	u16 xid;
+	u16 new_cqes;
+	u32 comp_type;
+
+	/* Get the current firmware producer index */
+	prod_idx = sb->pi_array[QEDF_FCOE_PARAMS_GL_RQ_PI];
+
+	/* Get the pointer to the global CQ this completion is on */
+	que = qedf->global_queues[fp->sb_id];
+
+	/* Calculate the amount of new elements since last processing */
+	new_cqes = (prod_idx >= que->cq_prod_idx) ?
+	    (prod_idx - que->cq_prod_idx) :
+	    0x10000 - que->cq_prod_idx + prod_idx;
+
+	/* Save producer index */
+	que->cq_prod_idx = prod_idx;
+
+	while (new_cqes) {
+		fp->completions++;
+		num_handled++;
+		cqe = &que->cq[que->cq_cons_idx];
+
+		comp_type = (cqe->cqe_data >> FCOE_CQE_CQE_TYPE_SHIFT) &
+		    FCOE_CQE_CQE_TYPE_MASK;
+
+		/*
+		 * Process unsolicited CQEs directly in the interrupt handler
+		 * sine we need the fastpath ID
+		 */
+		if (comp_type == FCOE_UNSOLIC_CQE_TYPE) {
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_UNSOL,
+			   "Unsolicated CQE.\n");
+			qedf_process_unsol_compl(qedf, fp->sb_id, cqe);
+			/*
+			 * Don't add a work list item.  Increment consumer
+			 * consumer index and move on.
+			 */
+			goto inc_idx;
+		}
+
+		xid = cqe->cqe_data & FCOE_CQE_TASK_ID_MASK;
+		io_req = &qedf->cmd_mgr->cmds[xid];
+
+		/*
+		 * Figure out which percpu thread we should queue this I/O
+		 * on.
+		 */
+		if (!io_req)
+			/* If there is not io_req assocated with this CQE
+			 * just queue it on CPU 0
+			 */
+			cpu = 0;
+		else {
+			cpu = io_req->cpu;
+			io_req->int_cpu = smp_processor_id();
+		}
+
+		work = mempool_alloc(qedf->io_mempool, GFP_ATOMIC);
+		if (!work) {
+			QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate "
+				   "work for I/O completion.\n");
+			continue;
+		}
+		memset(work, 0, sizeof(struct qedf_io_work));
+
+		INIT_LIST_HEAD(&work->list);
+
+		/* Copy contents of CQE for deferred processing */
+		memcpy(&work->cqe, cqe, sizeof(struct fcoe_cqe));
+
+		work->qedf = fp->qedf;
+		work->fp = NULL; /* Only used for unsolicited frames */
+
+		iothread = &per_cpu(qedf_percpu_iothreads, cpu);
+		spin_lock_irqsave(&iothread->work_lock, flags);
+		list_add_tail(&work->list, &iothread->work_list);
+		spin_unlock_irqrestore(&iothread->work_lock, flags);
+		wake_up_process(iothread->iothread);
+
+inc_idx:
+		que->cq_cons_idx++;
+		if (que->cq_cons_idx == fp->cq_num_entries)
+			que->cq_cons_idx = 0;
+		new_cqes--;
+	}
+
+	return true;
+}
+
+
+/* MSI-X fastpath handler code */
+static irqreturn_t qedf_msix_handler(int irq, void *dev_id)
+{
+	struct qedf_fastpath *fp = dev_id;
+
+	if (!fp) {
+		QEDF_ERR(NULL, "fp is null.\n");
+		return IRQ_HANDLED;
+	}
+	if (!fp->sb_info) {
+		QEDF_ERR(NULL, "fp->sb_info in null.");
+		return IRQ_HANDLED;
+	}
+
+	/*
+	 * Disable interrupts for this status block while we process new
+	 * completions
+	 */
+	qed_sb_ack(fp->sb_info, IGU_INT_DISABLE, 0 /*do not update*/);
+
+	while (1) {
+		qedf_process_completions(fp);
+
+		if (qedf_fp_has_work(fp) == 0) {
+			/* Update the sb information */
+			qed_sb_update_sb_idx(fp->sb_info);
+			rmb();
+
+			if (qedf_fp_has_work(fp) == 0) {
+				/* Re-enable interrupts */
+				qed_sb_ack(fp->sb_info, IGU_INT_ENABLE, 1);
+				return IRQ_HANDLED;
+			}
+		}
+	}
+
+	/* Do we ever want to break out of above loop? */
+	return IRQ_HANDLED;
+}
+
+/* simd handler for MSI/INTa */
+static void qedf_simd_int_handler(void *cookie)
+{
+	/* Cookie is qedf_ctx struct */
+	struct qedf_ctx *qedf = (struct qedf_ctx *)cookie;
+
+	QEDF_WARN(&(qedf->dbg_ctx), "qedf=%p.\n", qedf);
+}
+
+#define QEDF_SIMD_HANDLER_NUM		0
+static void qedf_sync_free_irqs(struct qedf_ctx *qedf)
+{
+	int i;
+
+	if (qedf->int_info.msix_cnt) {
+		for (i = 0; i < qedf->int_info.used_cnt; i++) {
+			synchronize_irq(qedf->int_info.msix[i].vector);
+			irq_set_affinity_hint(qedf->int_info.msix[i].vector,
+			    NULL);
+			irq_set_affinity_notifier(qedf->int_info.msix[i].vector,
+			    NULL);
+			free_irq(qedf->int_info.msix[i].vector,
+			    &qedf->fp_array[i]);
+		}
+	} else
+		qed_ops->common->simd_handler_clean(qedf->cdev,
+		    QEDF_SIMD_HANDLER_NUM);
+
+	qedf->int_info.used_cnt = 0;
+	qed_ops->common->set_fp_int(qedf->cdev, 0);
+}
+
+static int qedf_request_msix_irq(struct qedf_ctx *qedf)
+{
+	int i, rc, cpu;
+
+	cpu = cpumask_first(cpu_online_mask);
+	for (i = 0; i < qedf->num_queues; i++) {
+		rc = request_irq(qedf->int_info.msix[i].vector,
+		    qedf_msix_handler, 0, "qedf", &qedf->fp_array[i]);
+
+		if (rc) {
+			QEDF_WARN(&(qedf->dbg_ctx), "request_irq failed.\n");
+			qedf_sync_free_irqs(qedf);
+			return rc;
+		}
+
+		qedf->int_info.used_cnt++;
+		rc = irq_set_affinity_hint(qedf->int_info.msix[i].vector,
+		    get_cpu_mask(cpu));
+		cpu = cpumask_next(cpu, cpu_online_mask);
+	 }
+
+	return 0;
+}
+
+static int qedf_setup_int(struct qedf_ctx *qedf)
+{
+	int rc = 0;
+
+	/*
+	 * Learn interrupt configuration
+	 */
+	rc = qed_ops->common->set_fp_int(qedf->cdev, num_online_cpus());
+
+	rc  = qed_ops->common->get_fp_int(qedf->cdev, &qedf->int_info);
+	if (rc)
+		return 0;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "Number of msix_cnt = "
+		   "0x%x num of cpus = 0x%x\n", qedf->int_info.msix_cnt,
+		   num_online_cpus());
+
+	if (qedf->int_info.msix_cnt)
+		return qedf_request_msix_irq(qedf);
+
+	qed_ops->common->simd_handler_config(qedf->cdev, &qedf,
+	    QEDF_SIMD_HANDLER_NUM, qedf_simd_int_handler);
+	qedf->int_info.used_cnt = 1;
+
+	return 0;
+}
+
+/* Main function for libfc frame reception */
+static void qedf_recv_frame(struct qedf_ctx *qedf,
+	struct sk_buff *skb)
+{
+	u32 fr_len;
+	struct fc_lport *lport;
+	struct fc_frame_header *fh;
+	struct fcoe_crc_eof crc_eof;
+	struct fc_frame *fp;
+	u8 *mac = NULL;
+	u8 *dest_mac = NULL;
+	struct fcoe_hdr *hp;
+	struct qedf_rport *fcport;
+	unsigned long flags;
+
+	lport = qedf->lport;
+	if (lport == NULL || lport->state == LPORT_ST_DISABLED) {
+		QEDF_WARN(NULL, "Invalid lport struct or lport disabled.\n");
+		kfree_skb(skb);
+		return;
+	}
+
+	if (skb_is_nonlinear(skb))
+		skb_linearize(skb);
+	mac = eth_hdr(skb)->h_source;
+	dest_mac = eth_hdr(skb)->h_dest;
+
+	/* Pull the header */
+	hp = (struct fcoe_hdr *)skb->data;
+	fh = (struct fc_frame_header *) skb_transport_header(skb);
+	skb_pull(skb, sizeof(struct fcoe_hdr));
+	fr_len = skb->len - sizeof(struct fcoe_crc_eof);
+
+	fp = (struct fc_frame *)skb;
+	fc_frame_init(fp);
+	fr_dev(fp) = lport;
+	fr_sof(fp) = hp->fcoe_sof;
+	if (skb_copy_bits(skb, fr_len, &crc_eof, sizeof(crc_eof))) {
+		kfree_skb(skb);
+		return;
+	}
+	fr_eof(fp) = crc_eof.fcoe_eof;
+	fr_crc(fp) = crc_eof.fcoe_crc32;
+	if (pskb_trim(skb, fr_len)) {
+		kfree_skb(skb);
+		return;
+	}
+
+	fh = fc_frame_header_get(fp);
+
+	if (fh->fh_r_ctl == FC_RCTL_DD_SOL_DATA &&
+	    fh->fh_type == FC_TYPE_FCP) {
+		/* Drop FCP data. We dont this in L2 path */
+		kfree_skb(skb);
+		return;
+	}
+	if (fh->fh_r_ctl == FC_RCTL_ELS_REQ &&
+	    fh->fh_type == FC_TYPE_ELS) {
+		switch (fc_frame_payload_op(fp)) {
+		case ELS_LOGO:
+			if (ntoh24(fh->fh_s_id) == FC_FID_FLOGI) {
+				/* drop non-FIP LOGO */
+				kfree_skb(skb);
+				return;
+			}
+			break;
+		}
+	}
+
+	if (fh->fh_r_ctl == FC_RCTL_BA_ABTS) {
+		/* Drop incoming ABTS */
+		kfree_skb(skb);
+		return;
+	}
+
+	/*
+	 * If a connection is uploading, drop incoming FCoE frames as there
+	 * is a small window where we could try to return a frame while libfc
+	 * is trying to clean things up.
+	 */
+
+	/* Get fcport associated with d_id if it exists */
+	spin_lock_irqsave(&qedf->hba_lock, flags);
+	fcport = qedf_fcport_lookup(qedf, ntoh24(fh->fh_d_id));
+	spin_unlock_irqrestore(&qedf->hba_lock, flags);
+
+	if (fcport && test_bit(QEDF_RPORT_UPLOADING_CONNECTION,
+	    &fcport->flags)) {
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_LL2,
+		    "Connection uploading, dropping fp=%p.\n", fp);
+		kfree_skb(skb);
+		return;
+	}
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_LL2, "FCoE frame receive: "
+	    "skb=%p fp=%p src=%06x dest=%06x r_ctl=%x fh_type=%x.\n", skb, fp,
+	    ntoh24(fh->fh_s_id), ntoh24(fh->fh_d_id), fh->fh_r_ctl,
+	    fh->fh_type);
+	if (qedf_dump_frames)
+		print_hex_dump(KERN_WARNING, "fcoe: ", DUMP_PREFIX_OFFSET, 16,
+		    1, skb->data, skb->len, false);
+	fc_exch_recv(lport, fp);
+}
+
+
+static int qedf_ll2_rx(void *cookie, struct sk_buff *skb,
+	u32 arg1, u32 arg2)
+{
+	struct qedf_ctx *qedf = (struct qedf_ctx *)cookie;
+	struct qedf_skb_work *work;
+	unsigned long flags;
+
+	work = kzalloc(sizeof(struct qedf_skb_work), GFP_ATOMIC);
+	if (!work) {
+		QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate work so "
+			   "dropping frame.\n");
+		kfree_skb(skb);
+		return 0;
+	}
+
+	INIT_LIST_HEAD(&work->list);
+	work->skb = skb;
+	spin_lock_irqsave(&qedf->ll2_lock, flags);
+	list_add_tail(&work->list, &qedf->ll2_skb_list);
+	spin_unlock_irqrestore(&qedf->ll2_lock, flags);
+	wake_up_process(qedf->ll2_recv_thread);
+
+	return 0;
+}
+
+static struct qed_ll2_cb_ops qedf_ll2_cb_ops = {
+	.rx_cb = qedf_ll2_rx,
+	.tx_cb = NULL,
+};
+
+static int qedf_ll2_process_skb(struct qedf_ctx *qedf, struct sk_buff *skb)
+{
+	struct ethhdr *eh;
+
+	if (!qedf) {
+		QEDF_ERR(NULL, "qedf is NULL\n");
+		goto err_out;
+	}
+
+	eh = (struct ethhdr *)skb->data;
+	/* Undo VLAN encapsulation */
+	if (eh->h_proto == htons(ETH_P_8021Q)) {
+		memmove((u8 *)eh + VLAN_HLEN, eh, ETH_ALEN * 2);
+		eh = (struct ethhdr *)skb_pull(skb, VLAN_HLEN);
+		skb_reset_mac_header(skb);
+	}
+
+	/*
+	 * Process either a FIP frame or FCoE frame based on the
+	 * protocol value.  If it's not either just drop the
+	 * frame.
+	 */
+	if (eh->h_proto == htons(ETH_P_FIP)) {
+		qedf_fip_recv(qedf, skb);
+		goto out;
+	} else if (eh->h_proto == htons(ETH_P_FCOE)) {
+		__skb_pull(skb, ETH_HLEN);
+		qedf_recv_frame(qedf, skb);
+		goto out;
+	} else
+		goto err_out;
+
+err_out:
+	kfree_skb(skb);
+out:
+	return 0;
+}
+
+/* Main thread to process skb's from light-L2 interface */
+static int qedf_ll2_recv_thread(void *arg)
+{
+	struct qedf_ctx *qedf = (struct qedf_ctx *)arg;
+	struct qedf_skb_work *work, *work_tmp;
+	unsigned long flags;
+
+	set_user_nice(current, -20);
+	set_current_state(TASK_INTERRUPTIBLE);
+
+	while (!kthread_should_stop()) {
+		schedule();
+		if (!list_empty(&qedf->ll2_skb_list)) {
+			list_for_each_entry_safe(work, work_tmp,
+			    &qedf->ll2_skb_list, list) {
+			spin_lock_irqsave(&qedf->ll2_lock, flags);
+				list_del(&work->list);
+				spin_unlock_irqrestore(&qedf->ll2_lock, flags);
+				qedf_ll2_process_skb(qedf, work->skb);
+				kfree(work);
+			}
+		}
+		__set_current_state(TASK_INTERRUPTIBLE);
+	}
+
+	__set_current_state(TASK_RUNNING);
+	return 0;
+}
+
+/* Free any remaining skb's in the LL2 receive list */
+static void qedf_ll2_free_skbs(struct qedf_ctx *qedf)
+{
+	struct qedf_skb_work *work, *work_tmp;
+	unsigned long flags;
+
+	spin_lock_irqsave(&qedf->ll2_lock, flags);
+	list_for_each_entry_safe(work, work_tmp, &qedf->ll2_skb_list, list) {
+		list_del(&work->list);
+		if (work->skb)
+			kfree_skb(work->skb);
+		kfree(work);
+	}
+	spin_unlock_irqrestore(&qedf->ll2_lock, flags);
+}
+
+/* Main thread to process I/O completions */
+static int qedf_fp_io_thread(void *arg)
+{
+	struct qedf_percpu_iothread_s *iothread;
+	struct qedf_io_work *work, *work_tmp;
+	unsigned long flags;
+	u32 comp_type;
+
+	set_current_state(TASK_INTERRUPTIBLE);
+
+	iothread = (struct qedf_percpu_iothread_s *)arg;
+
+	while (!kthread_should_stop()) {
+		schedule();
+		if (!list_empty(&iothread->work_list)) {
+			list_for_each_entry_safe(work, work_tmp,
+			    &iothread->work_list, list) {
+				spin_lock_irqsave(&iothread->work_lock, flags);
+				list_del(&work->list);
+				spin_unlock_irqrestore(&iothread->work_lock,
+				    flags);
+				/* Record the response */
+				iothread->responses++;
+				/*
+				 * Deferred part of unsolicited CQE sends
+				 * frame to libfc.
+				 */
+				comp_type = (work->cqe.cqe_data >>
+				    FCOE_CQE_CQE_TYPE_SHIFT) &
+				    FCOE_CQE_CQE_TYPE_MASK;
+				if (comp_type == FCOE_UNSOLIC_CQE_TYPE &&
+				    work->fp)
+					fc_exch_recv(work->qedf->lport,
+					    work->fp);
+				else
+					qedf_process_cqe(work->qedf,
+					    &work->cqe);
+				mempool_free(work, work->qedf->io_mempool);
+			}
+		} else
+		__set_current_state(TASK_INTERRUPTIBLE);
+	}
+
+	__set_current_state(TASK_RUNNING);
+	return 0;
+}
+
+static int qedf_alloc_and_init_sb(struct qedf_ctx *qedf,
+	struct qed_sb_info *sb_info, u16 sb_id)
+{
+	struct status_block *sb_virt;
+	dma_addr_t sb_phys;
+	int ret;
+
+	sb_virt = dma_alloc_coherent(&qedf->pdev->dev,
+	    sizeof(struct status_block), &sb_phys, GFP_KERNEL);
+
+	if (!sb_virt) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Status block allocation failed "
+			  "for id = %d.\n", sb_id);
+		return -ENOMEM;
+	}
+
+	ret = qed_ops->common->sb_init(qedf->cdev, sb_info, sb_virt, sb_phys,
+	    sb_id, QED_SB_TYPE_STORAGE);
+
+	if (ret) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Status block initialization "
+			  "failed for id = %d.\n", sb_id);
+		return ret;
+	}
+
+	return 0;
+}
+
+static void qedf_free_sb(struct qedf_ctx *qedf, struct qed_sb_info *sb_info)
+{
+	if (sb_info->sb_virt)
+		dma_free_coherent(&qedf->pdev->dev, sizeof(*sb_info->sb_virt),
+		    (void *)sb_info->sb_virt, sb_info->sb_phys);
+}
+
+static void qedf_destroy_sb(struct qedf_ctx *qedf)
+{
+	int id;
+	struct qedf_fastpath *fp = NULL;
+
+	for (id = 0; id < qedf->num_queues; id++) {
+		fp = &(qedf->fp_array[id]);
+		if (fp->sb_id == QEDF_SB_ID_NULL)
+			break;
+		qedf_free_sb(qedf, fp->sb_info);
+		kfree(fp->sb_info);
+	}
+	kfree(qedf->fp_array);
+}
+
+static int qedf_prepare_sb(struct qedf_ctx *qedf)
+{
+	int id;
+	struct qedf_fastpath *fp;
+	int ret;
+
+	qedf->fp_array =
+	    kcalloc(qedf->num_queues, sizeof(struct qedf_fastpath),
+		GFP_KERNEL);
+
+	if (!qedf->fp_array) {
+		QEDF_ERR(&(qedf->dbg_ctx), "fastpath array allocation "
+			  "failed.\n");
+		return -ENOMEM;
+	}
+
+	for (id = 0; id < qedf->num_queues; id++) {
+		fp = &(qedf->fp_array[id]);
+		fp->sb_id = QEDF_SB_ID_NULL;
+		fp->sb_info = kcalloc(1, sizeof(*fp->sb_info), GFP_KERNEL);
+		if (!fp->sb_info) {
+			QEDF_ERR(&(qedf->dbg_ctx), "SB info struct "
+				  "allocation failed.\n");
+			goto err;
+		}
+		ret = qedf_alloc_and_init_sb(qedf, fp->sb_info, id);
+		if (ret) {
+			QEDF_ERR(&(qedf->dbg_ctx), "SB allocation and "
+				  "initialization failed.\n");
+			goto err;
+		}
+		fp->sb_id = id;
+		fp->qedf = qedf;
+		fp->cq_num_entries =
+		    qedf->global_queues[id]->cq_mem_size /
+		    sizeof(struct fcoe_cqe);
+	}
+err:
+	return 0;
+}
+
+void qedf_process_cqe(struct qedf_ctx *qedf, struct fcoe_cqe *cqe)
+{
+	u16 xid;
+	struct qedf_ioreq *io_req;
+	struct qedf_rport *fcport;
+	u32 comp_type;
+
+	comp_type = (cqe->cqe_data >> FCOE_CQE_CQE_TYPE_SHIFT) &
+	    FCOE_CQE_CQE_TYPE_MASK;
+
+	xid = cqe->cqe_data & FCOE_CQE_TASK_ID_MASK;
+	io_req = &qedf->cmd_mgr->cmds[xid];
+
+	/* Completion not for a valid I/O anymore so just return */
+	if (!io_req)
+		return;
+
+	fcport = io_req->fcport;
+
+	if (fcport == NULL) {
+		QEDF_ERR(&(qedf->dbg_ctx), "fcport is NULL.\n");
+		return;
+	}
+
+	/*
+	 * Check that fcport is offloaded.  If it isn't then the spinlock
+	 * isn't valid and shouldn't be taken. We should just return.
+	 */
+	if (!test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Session not offloaded yet.\n");
+		return;
+	}
+
+
+	switch (comp_type) {
+	case FCOE_GOOD_COMPLETION_CQE_TYPE:
+		atomic_inc(&fcport->free_sqes);
+		switch (io_req->cmd_type) {
+		case QEDF_SCSI_CMD:
+			qedf_scsi_completion(qedf, cqe, io_req);
+			break;
+		case QEDF_ELS:
+			qedf_process_els_compl(qedf, cqe, io_req);
+			break;
+		case QEDF_TASK_MGMT_CMD:
+			qedf_process_tmf_compl(qedf, cqe, io_req);
+			break;
+		case QEDF_SEQ_CLEANUP:
+			qedf_process_seq_cleanup_compl(qedf, cqe, io_req);
+			break;
+		}
+		break;
+	case FCOE_ERROR_DETECTION_CQE_TYPE:
+		atomic_inc(&fcport->free_sqes);
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Error detect CQE.\n");
+		qedf_process_error_detect(qedf, cqe, io_req);
+		break;
+	case FCOE_EXCH_CLEANUP_CQE_TYPE:
+		atomic_inc(&fcport->free_sqes);
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Cleanup CQE.\n");
+		qedf_process_cleanup_compl(qedf, cqe, io_req);
+		break;
+	case FCOE_ABTS_CQE_TYPE:
+		atomic_inc(&fcport->free_sqes);
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Abort CQE.\n");
+		qedf_process_abts_compl(qedf, cqe, io_req);
+		break;
+	case FCOE_DUMMY_CQE_TYPE:
+		atomic_inc(&fcport->free_sqes);
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Dummy CQE.\n");
+		break;
+	case FCOE_LOCAL_COMP_CQE_TYPE:
+		atomic_inc(&fcport->free_sqes);
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Local completion CQE.\n");
+		break;
+	case FCOE_WARNING_CQE_TYPE:
+		atomic_inc(&fcport->free_sqes);
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Warning CQE.\n");
+		qedf_process_warning_compl(qedf, cqe, io_req);
+		break;
+	case MAX_FCOE_CQE_TYPE:
+		atomic_inc(&fcport->free_sqes);
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Max FCoE CQE.\n");
+		break;
+	default:
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Default CQE.\n");
+		break;
+	}
+}
+
+static void qedf_free_bdq(struct qedf_ctx *qedf)
+{
+	int i;
+
+	if (qedf->bdq_pbl_list)
+		dma_free_coherent(&qedf->pdev->dev, QEDF_PAGE_SIZE,
+		    qedf->bdq_pbl_list, qedf->bdq_pbl_list_dma);
+
+	if (qedf->bdq_pbl)
+		dma_free_coherent(&qedf->pdev->dev, qedf->bdq_pbl_mem_size,
+		    qedf->bdq_pbl, qedf->bdq_pbl_dma);
+
+	for (i = 0; i < QEDF_BDQ_SIZE; i++) {
+		if (qedf->bdq[i].buf_addr) {
+			dma_free_coherent(&qedf->pdev->dev, QEDF_BDQ_BUF_SIZE,
+			    qedf->bdq[i].buf_addr, qedf->bdq[i].buf_dma);
+		}
+	}
+}
+
+static void qedf_free_global_queues(struct qedf_ctx *qedf)
+{
+	int i;
+	struct global_queue **gl = qedf->global_queues;
+
+	for (i = 0; i < qedf->num_queues; i++) {
+		if (!gl[i])
+			continue;
+
+		if (gl[i]->cq)
+			dma_free_coherent(&qedf->pdev->dev,
+			    gl[i]->cq_mem_size, gl[i]->cq, gl[i]->cq_dma);
+		if (gl[i]->cq_pbl)
+			dma_free_coherent(&qedf->pdev->dev, gl[i]->cq_pbl_size,
+			    gl[i]->cq_pbl, gl[i]->cq_pbl_dma);
+
+		kfree(gl[i]);
+	}
+
+	qedf_free_bdq(qedf);
+}
+
+static int qedf_alloc_bdq(struct qedf_ctx *qedf)
+{
+	int i;
+	struct scsi_bd *pbl;
+	u64 *list;
+	dma_addr_t page;
+
+	/* Alloc dma memory for BDQ buffers */
+	for (i = 0; i < QEDF_BDQ_SIZE; i++) {
+		qedf->bdq[i].buf_addr = dma_alloc_coherent(&qedf->pdev->dev,
+		    QEDF_BDQ_BUF_SIZE, &qedf->bdq[i].buf_dma, GFP_KERNEL);
+		if (!qedf->bdq[i].buf_addr) {
+			QEDF_ERR(&(qedf->dbg_ctx), "Could not allocate BDQ "
+			    "buffer %d.\n", i);
+			return -ENOMEM;
+		}
+	}
+
+	/* Alloc dma memory for BDQ page buffer list */
+	qedf->bdq_pbl_mem_size =
+	    QEDF_BDQ_SIZE * sizeof(struct scsi_bd);
+	qedf->bdq_pbl_mem_size =
+	    ALIGN(qedf->bdq_pbl_mem_size, QEDF_PAGE_SIZE);
+
+	qedf->bdq_pbl = dma_alloc_coherent(&qedf->pdev->dev,
+	    qedf->bdq_pbl_mem_size, &qedf->bdq_pbl_dma, GFP_KERNEL);
+	if (!qedf->bdq_pbl) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Could not allocate BDQ PBL.\n");
+		return -ENOMEM;
+	}
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+	    "BDQ PBL addr=0x%p dma=0x%llx.\n", qedf->bdq_pbl,
+	    qedf->bdq_pbl_dma);
+
+	/*
+	 * Populate BDQ PBL with physical and virtual address of individual
+	 * BDQ buffers
+	 */
+	pbl = (struct scsi_bd *)qedf->bdq_pbl;
+	for (i = 0; i < QEDF_BDQ_SIZE; i++) {
+		pbl->address.hi = cpu_to_le32(U64_HI(qedf->bdq[i].buf_dma));
+		pbl->address.lo = cpu_to_le32(U64_LO(qedf->bdq[i].buf_dma));
+		pbl->opaque.hi = 0;
+		/* Opaque lo data is an index into the BDQ array */
+		pbl->opaque.lo = cpu_to_le32(i);
+		pbl++;
+	}
+
+	/* Allocate list of PBL pages */
+	qedf->bdq_pbl_list = dma_alloc_coherent(&qedf->pdev->dev,
+	    QEDF_PAGE_SIZE, &qedf->bdq_pbl_list_dma, GFP_KERNEL);
+	if (!qedf->bdq_pbl_list) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Could not allocate list of PBL "
+		    "pages.\n");
+		return -ENOMEM;
+	}
+	memset(qedf->bdq_pbl_list, 0, QEDF_PAGE_SIZE);
+
+	/*
+	 * Now populate PBL list with pages that contain pointers to the
+	 * individual buffers.
+	 */
+	qedf->bdq_pbl_list_num_entries = qedf->bdq_pbl_mem_size /
+	    QEDF_PAGE_SIZE;
+	list = (u64 *)qedf->bdq_pbl_list;
+	page = qedf->bdq_pbl_list_dma;
+	for (i = 0; i < qedf->bdq_pbl_list_num_entries; i++) {
+		*list = qedf->bdq_pbl_dma;
+		list++;
+		page += QEDF_PAGE_SIZE;
+	}
+
+	return 0;
+}
+
+static int qedf_alloc_global_queues(struct qedf_ctx *qedf)
+{
+	u32 *list;
+	int i;
+	int status = 0, rc;
+	u32 *pbl;
+	dma_addr_t page;
+	int num_pages;
+
+	/* Allocate and map CQs, RQs */
+	/*
+	 * Number of global queues (CQ / RQ). This should
+	 * be <= number of available MSIX vectors for the PF
+	 */
+	if (!qedf->num_queues) {
+		QEDF_ERR(&(qedf->dbg_ctx), "No MSI-X vectors available!\n");
+		return 1;
+	}
+
+	/*
+	 * Make sure we allocated the PBL that will contain the physical
+	 * addresses of our queues
+	 */
+	if (!qedf->p_cpuq) {
+		status = 1;
+		goto mem_alloc_failure;
+	}
+
+	qedf->global_queues = kzalloc((sizeof(struct global_queue *)
+	    * qedf->num_queues), GFP_KERNEL);
+	if (!qedf->global_queues) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Unable to allocate global "
+			  "queues array ptr memory\n");
+		return -ENOMEM;
+	}
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+		   "qedf->global_queues=%p.\n", qedf->global_queues);
+
+	/* Allocate DMA coherent buffers for BDQ */
+	rc = qedf_alloc_bdq(qedf);
+	if (rc)
+		goto mem_alloc_failure;
+
+	/* Allocate a CQ and an associated PBL for each MSI-X vector */
+	for (i = 0; i < qedf->num_queues; i++) {
+		qedf->global_queues[i] = kzalloc(sizeof(struct global_queue),
+		    GFP_KERNEL);
+		if (!qedf->global_queues[i]) {
+			QEDF_WARN(&(qedf->dbg_ctx), "Unable to allocation "
+				   "global queue %d.\n", i);
+			goto mem_alloc_failure;
+		}
+
+		qedf->global_queues[i]->cq_mem_size =
+		    FCOE_PARAMS_CQ_NUM_ENTRIES * sizeof(struct fcoe_cqe);
+		qedf->global_queues[i]->cq_mem_size =
+		    ALIGN(qedf->global_queues[i]->cq_mem_size, QEDF_PAGE_SIZE);
+
+		qedf->global_queues[i]->cq_pbl_size =
+		    (qedf->global_queues[i]->cq_mem_size /
+		    PAGE_SIZE) * sizeof(void *);
+		qedf->global_queues[i]->cq_pbl_size =
+		    ALIGN(qedf->global_queues[i]->cq_pbl_size, QEDF_PAGE_SIZE);
+
+		qedf->global_queues[i]->cq =
+		    dma_alloc_coherent(&qedf->pdev->dev,
+			qedf->global_queues[i]->cq_mem_size,
+			&qedf->global_queues[i]->cq_dma, GFP_KERNEL);
+
+		if (!qedf->global_queues[i]->cq) {
+			QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate "
+				   "cq.\n");
+			status = -ENOMEM;
+			goto mem_alloc_failure;
+		}
+		memset(qedf->global_queues[i]->cq, 0,
+		    qedf->global_queues[i]->cq_mem_size);
+
+		qedf->global_queues[i]->cq_pbl =
+		    dma_alloc_coherent(&qedf->pdev->dev,
+			qedf->global_queues[i]->cq_pbl_size,
+			&qedf->global_queues[i]->cq_pbl_dma, GFP_KERNEL);
+
+		if (!qedf->global_queues[i]->cq_pbl) {
+			QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate "
+				   "cq PBL.\n");
+			status = -ENOMEM;
+			goto mem_alloc_failure;
+		}
+		memset(qedf->global_queues[i]->cq_pbl, 0,
+		    qedf->global_queues[i]->cq_pbl_size);
+
+		/* Create PBL */
+		num_pages = qedf->global_queues[i]->cq_mem_size /
+		    QEDF_PAGE_SIZE;
+		page = qedf->global_queues[i]->cq_dma;
+		pbl = (u32 *)qedf->global_queues[i]->cq_pbl;
+
+		while (num_pages--) {
+			*pbl = U64_LO(page);
+			pbl++;
+			*pbl = U64_HI(page);
+			pbl++;
+			page += QEDF_PAGE_SIZE;
+		}
+		/* Set the initial consumer index for cq */
+		qedf->global_queues[i]->cq_cons_idx = 0;
+	}
+
+	list = (u32 *)qedf->p_cpuq;
+
+	/*
+	 * The list is built as follows: CQ#0 PBL pointer, RQ#0 PBL pointer,
+	 * CQ#1 PBL pointer, RQ#1 PBL pointer, etc.  Each PBL pointer points
+	 * to the physical address which contains an array of pointers to
+	 * the physical addresses of the specific queue pages.
+	 */
+	for (i = 0; i < qedf->num_queues; i++) {
+		*list = U64_LO(qedf->global_queues[i]->cq_pbl_dma);
+		list++;
+		*list = U64_HI(qedf->global_queues[i]->cq_pbl_dma);
+		list++;
+		*list = U64_LO(0);
+		list++;
+		*list = U64_HI(0);
+		list++;
+	}
+
+	return 0;
+
+mem_alloc_failure:
+	qedf_free_global_queues(qedf);
+	return status;
+}
+
+static int qedf_set_fcoe_pf_param(struct qedf_ctx *qedf)
+{
+	u8 sq_num_pbl_pages;
+	u32 sq_mem_size;
+	u32 cq_mem_size;
+	u32 cq_num_entries;
+	int rval;
+
+	/*
+	 * The number of completion queues/fastpath interrupts/status blocks
+	 * we allocation is the minimum off:
+	 *
+	 * Number of CPUs
+	 * Number of MSI-X vectors
+	 * Max number allocated in hardware (QEDF_MAX_NUM_CQS)
+	 */
+	qedf->num_queues = min((unsigned int)QEDF_MAX_NUM_CQS,
+	    num_online_cpus());
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "Number of CQs is %d.\n",
+		   qedf->num_queues);
+
+	qedf->p_cpuq = pci_alloc_consistent(qedf->pdev,
+	    qedf->num_queues * sizeof(struct qedf_glbl_q_params),
+	    &qedf->hw_p_cpuq);
+
+	if (!qedf->p_cpuq) {
+		QEDF_ERR(&(qedf->dbg_ctx), "pci_alloc_consistent failed.\n");
+		return 1;
+	}
+
+	rval = qedf_alloc_global_queues(qedf);
+	if (rval) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Global queue allocation "
+			  "failed.\n");
+		return 1;
+	}
+
+	/* Calculate SQ PBL size in the same manner as in qedf_sq_alloc() */
+	sq_mem_size = SQ_NUM_ENTRIES * sizeof(struct fcoe_wqe);
+	sq_mem_size = ALIGN(sq_mem_size, QEDF_PAGE_SIZE);
+	sq_num_pbl_pages = (sq_mem_size / QEDF_PAGE_SIZE);
+
+	/* Calculate CQ num entries */
+	cq_mem_size = FCOE_PARAMS_CQ_NUM_ENTRIES * sizeof(struct fcoe_cqe);
+	cq_mem_size = ALIGN(cq_mem_size, QEDF_PAGE_SIZE);
+	cq_num_entries = cq_mem_size / sizeof(struct fcoe_cqe);
+
+	memset(&(qedf->pf_params), 0,
+	    sizeof(qedf->pf_params));
+
+	/* Setup the value for fcoe PF */
+	qedf->pf_params.fcoe_pf_params.num_cons = QEDF_MAX_SESSIONS;
+	qedf->pf_params.fcoe_pf_params.num_tasks = FCOE_PARAMS_NUM_TASKS;
+	qedf->pf_params.fcoe_pf_params.glbl_q_params_addr =
+	    (u64)qedf->hw_p_cpuq;
+	qedf->pf_params.fcoe_pf_params.sq_num_pbl_pages = sq_num_pbl_pages;
+
+	qedf->pf_params.fcoe_pf_params.rq_buffer_log_size = 0;
+
+	qedf->pf_params.fcoe_pf_params.cq_num_entries = cq_num_entries;
+	qedf->pf_params.fcoe_pf_params.num_cqs = qedf->num_queues;
+
+	/* log_page_size: 12 for 4KB pages */
+	qedf->pf_params.fcoe_pf_params.log_page_size = ilog2(QEDF_PAGE_SIZE);
+
+	qedf->pf_params.fcoe_pf_params.mtu = 9000;
+	qedf->pf_params.fcoe_pf_params.gl_rq_pi = QEDF_FCOE_PARAMS_GL_RQ_PI;
+	qedf->pf_params.fcoe_pf_params.gl_cmd_pi = QEDF_FCOE_PARAMS_GL_CMD_PI;
+
+	/* BDQ address and size */
+	qedf->pf_params.fcoe_pf_params.bdq_pbl_base_addr[0] =
+	    qedf->bdq_pbl_list_dma;
+	qedf->pf_params.fcoe_pf_params.bdq_pbl_num_entries[0] =
+	    qedf->bdq_pbl_list_num_entries;
+	qedf->pf_params.fcoe_pf_params.rq_buffer_size = QEDF_BDQ_BUF_SIZE;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+	    "bdq_list=%p bdq_pbl_list_dma=%llx bdq_pbl_list_entries=%d.\n",
+	    qedf->bdq_pbl_list,
+	    qedf->pf_params.fcoe_pf_params.bdq_pbl_base_addr[0],
+	    qedf->pf_params.fcoe_pf_params.bdq_pbl_num_entries[0]);
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+	    "cq_num_entries=%d.\n",
+	    qedf->pf_params.fcoe_pf_params.cq_num_entries);
+
+	return 0;
+}
+
+/* Free DMA coherent memory for array of queue pointers we pass to qed */
+static void qedf_free_fcoe_pf_param(struct qedf_ctx *qedf)
+{
+	size_t size = 0;
+
+	if (qedf->p_cpuq) {
+		size = qedf->num_queues * sizeof(struct qedf_glbl_q_params);
+		pci_free_consistent(qedf->pdev, size, qedf->p_cpuq,
+		    qedf->hw_p_cpuq);
+	}
+
+	qedf_free_global_queues(qedf);
+
+	if (qedf->global_queues)
+		kfree(qedf->global_queues);
+}
+
+/*
+ * PCI driver functions
+ */
+
+static const struct pci_device_id qedf_pci_tbl[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, 0x165c) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, 0x8080) },
+	{0}
+};
+MODULE_DEVICE_TABLE(pci, qedf_pci_tbl);
+
+static struct pci_driver qedf_pci_driver = {
+	.name = QEDF_MODULE_NAME,
+	.id_table = qedf_pci_tbl,
+	.probe = qedf_probe,
+	.remove = qedf_remove,
+};
+
+static int __qedf_probe(struct pci_dev *pdev, int mode)
+{
+	int rc;
+	struct fc_lport *lport;
+	struct qedf_ctx *qedf;
+	struct Scsi_Host *host;
+	bool is_vf = false;
+	struct qed_ll2_params params;
+	char host_buf[20];
+	struct qed_link_params link_params;
+	int status;
+	void *task_start, *task_end;
+	struct qed_slowpath_params slowpath_params;
+	struct qed_probe_params qed_params;
+	u16 tmp;
+
+	/*
+	 * When doing error recovery we didn't reap the lport so don't try
+	 * to reallocate it.
+	 */
+	if (mode != QEDF_MODE_RECOVERY) {
+		lport = libfc_host_alloc(&qedf_host_template,
+		    sizeof(struct qedf_ctx));
+
+		if (!lport) {
+			QEDF_ERR(NULL, "Could not allocate lport.\n");
+			rc = -ENOMEM;
+			goto err0;
+		}
+
+		/* Initialize qedf_ctx */
+		qedf = lport_priv(lport);
+		qedf->lport = lport;
+		qedf->ctlr.lp = lport;
+		qedf->pdev = pdev;
+		qedf->dbg_ctx.pdev = pdev;
+		qedf->dbg_ctx.host_no = lport->host->host_no;
+		spin_lock_init(&qedf->hba_lock);
+		spin_lock_init(&qedf->ll2_lock);
+		INIT_LIST_HEAD(&qedf->ll2_skb_list);
+		qedf->curr_conn_id = QEDF_MAX_SESSIONS - 1;
+		atomic_set(&qedf->num_offloads, 0);
+		qedf->stop_io_on_error = false;
+		pci_set_drvdata(pdev, qedf);
+
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_INFO,
+		   "QLogic FastLinQ FCoE Module qedf %s, "
+		   "FW %d.%d.%d.%d\n", QEDF_VERSION,
+		   FW_MAJOR_VERSION, FW_MINOR_VERSION, FW_REVISION_VERSION,
+		   FW_ENGINEERING_VERSION);
+	} else {
+		/* Init pointers during recovery */
+		qedf = pci_get_drvdata(pdev);
+		lport = qedf->lport;
+	}
+
+	host = lport->host;
+
+	/* Allocate mempool for qedf_io_work structs */
+	qedf->io_mempool = mempool_create_slab_pool(QEDF_IO_WORK_MIN,
+	    qedf_io_work_cache);
+	if (qedf->io_mempool == NULL) {
+		QEDF_ERR(&(qedf->dbg_ctx), "qedf->io_mempool is NULL.\n");
+		goto err1;
+	}
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_INFO, "qedf->io_mempool=%p.\n",
+	    qedf->io_mempool);
+
+	sprintf(host_buf, "qedf_%u_link",
+	    qedf->lport->host->host_no);
+	qedf->link_update_wq = create_singlethread_workqueue(host_buf);
+	INIT_DELAYED_WORK(&qedf->link_update, qedf_handle_link_update);
+	INIT_DELAYED_WORK(&qedf->link_recovery, qedf_link_recovery);
+
+	qedf->fipvlan_retries = qedf_fipvlan_retries;
+
+	/*
+	 * Common probe. Takes care of basic hardware init and pci_*
+	 * functions.
+	 */
+	memset(&qed_params, 0, sizeof(qed_params));
+	qed_params.protocol = QED_PROTOCOL_FCOE;
+	qed_params.dp_module = qedf_dp_module;
+	qed_params.dp_level = qedf_dp_level;
+	qed_params.is_vf = is_vf;
+	qedf->cdev = qed_ops->common->probe(pdev, &qed_params);
+	if (!qedf->cdev) {
+		rc = -ENODEV;
+		goto err1;
+	}
+
+	/* queue allocation code should come here
+	 * order should be
+	 * 	slowpath_start
+	 * 	status block allocation ????
+	 *	interrupt registration (to get min number of queues)
+	 *	set_fcoe_pf_param
+	 *	qed_sp_fcoe_func_start
+	 */
+	rc = qedf_set_fcoe_pf_param(qedf);
+	if (rc) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Cannot set fcoe pf param.\n");
+		goto err2;
+	}
+	qed_ops->common->update_pf_params(qedf->cdev, &qedf->pf_params);
+
+	/* Learn information crucial for qedf to progress */
+	rc = qed_ops->fill_dev_info(qedf->cdev, &qedf->dev_info);
+	if (rc) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Failed to dev info.\n");
+		goto err1;
+	}
+
+	/* Record BDQ producer doorbell addresses */
+	qedf->bdq_primary_prod = qedf->dev_info.primary_dbq_rq_addr;
+	qedf->bdq_secondary_prod = qedf->dev_info.secondary_bdq_rq_addr;
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+	    "BDQ primary_prod=%p secondary_prod=%p.\n", qedf->bdq_primary_prod,
+	    qedf->bdq_secondary_prod);
+
+	qed_ops->register_ops(qedf->cdev, &qedf_cb_ops, qedf);
+
+	rc = qedf_prepare_sb(qedf);
+	if (rc) {
+
+		QEDF_ERR(&(qedf->dbg_ctx), "Cannot start slowpath.\n");
+		goto err2;
+	}
+
+	/* Start the Slowpath-process */
+	slowpath_params.int_mode = QED_INT_MODE_MSIX;
+	slowpath_params.drv_major = QEDF_DRIVER_MAJOR_VER;
+	slowpath_params.drv_minor = QEDF_DRIVER_MINOR_VER;
+	slowpath_params.drv_rev = QEDF_DRIVER_REV_VER;
+	slowpath_params.drv_eng = QEDF_DRIVER_ENG_VER;
+	memcpy(slowpath_params.name, "qedf", QED_DRV_VER_STR_SIZE);
+	rc = qed_ops->common->slowpath_start(qedf->cdev, &slowpath_params);
+	if (rc) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Cannot start slowpath.\n");
+		goto err2;
+	}
+
+	/*
+	 * update_pf_params needs to be called before and after slowpath
+	 * start
+	 */
+	qed_ops->common->update_pf_params(qedf->cdev, &qedf->pf_params);
+
+	/* Setup interrupts */
+	rc = qedf_setup_int(qedf);
+	if (rc)
+		goto err3;
+
+	rc = qed_ops->start(qedf->cdev, &qedf->tasks);
+	if (rc) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Cannot start FCoE function.\n");
+		goto err4;
+	}
+	task_start = qedf_get_task_mem(&qedf->tasks, 0);
+	task_end = qedf_get_task_mem(&qedf->tasks, MAX_TID_BLOCKS_FCOE - 1);
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "Task context start=%p, "
+		   "end=%p block_size=%u.\n", task_start, task_end,
+		   qedf->tasks.size);
+
+	/*
+	 * We need to write the number of BDs in the BDQ we've preallocated so
+	 * the f/w will do a prefetch and we'll get an unsolicited CQE when a
+	 * packet arrives.
+	 */
+	qedf->bdq_prod_idx = QEDF_BDQ_SIZE;
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+	    "Writing %d to primary and secondary BDQ doorbell registers.\n",
+	    qedf->bdq_prod_idx);
+	writew(qedf->bdq_prod_idx, qedf->bdq_primary_prod);
+	tmp = readw(qedf->bdq_primary_prod);
+	writew(qedf->bdq_prod_idx, qedf->bdq_secondary_prod);
+	tmp = readw(qedf->bdq_secondary_prod);
+
+	qed_ops->common->set_power_state(qedf->cdev, PCI_D0);
+
+	/* Now that the dev_info struct has been filled in set the MAC
+	 * address
+	 */
+	ether_addr_copy(qedf->mac, qedf->dev_info.common.hw_mac);
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "MAC address is %pM.\n",
+		   qedf->mac);
+
+	/* Set the WWNN and WWPN based on the MAC address */
+	qedf->wwnn = fcoe_wwn_from_mac(qedf->mac, 1, 0);
+	qedf->wwpn = fcoe_wwn_from_mac(qedf->mac, 2, 0);
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,  "WWNN=%016llx "
+		   "WWPN=%016llx.\n", qedf->wwnn, qedf->wwpn);
+
+	sprintf(host_buf, "host_%d", host->host_no);
+	qed_ops->common->set_id(qedf->cdev, host_buf, QEDF_VERSION);
+
+
+	/* Set xid max values */
+	qedf->max_scsi_xid = QEDF_MAX_SCSI_XID;
+	qedf->max_els_xid = QEDF_MAX_ELS_XID;
+
+	/* Allocate cmd mgr */
+	qedf->cmd_mgr = qedf_cmd_mgr_alloc(qedf);
+	if (!qedf->cmd_mgr) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Failed to allocate cmd mgr.\n");
+		goto err5;
+	}
+
+	if (mode != QEDF_MODE_RECOVERY) {
+		host->transportt = qedf_fc_transport_template;
+		host->can_queue = QEDF_MAX_ELS_XID;
+		host->max_lun = qedf_max_lun;
+		host->max_cmd_len = QEDF_MAX_CDB_LEN;
+		rc = scsi_add_host(host, &pdev->dev);
+		if (rc)
+			goto err6;
+	}
+
+	memset(&params, 0, sizeof(params));
+	params.mtu = 9000;
+	ether_addr_copy(params.ll2_mac_address, qedf->mac);
+
+	/* Start LL2 processing thread */
+	snprintf(host_buf, 20, "qedf_%d_ll2", host->host_no);
+	qedf->ll2_recv_thread = kthread_run(qedf_ll2_recv_thread,
+	    (void *)qedf, host_buf);
+
+#ifdef CONFIG_DEBUG_FS
+	qedf_dbg_host_init(&(qedf->dbg_ctx), &qedf_debugfs_ops,
+			    &qedf_dbg_fops);
+#endif
+
+	/* Start LL2 */
+	qed_ops->ll2->register_cb_ops(qedf->cdev, &qedf_ll2_cb_ops, qedf);
+	rc = qed_ops->ll2->start(qedf->cdev, &params);
+	if (rc) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Could not start Light L2.\n");
+		goto err7;
+	}
+	set_bit(QEDF_LL2_STARTED, &qedf->flags);
+
+	/* hw will be insterting vlan tag*/
+	qedf->vlan_hw_insert = 1;
+	qedf->vlan_id = 0;
+
+	/*
+	 * No need to setup fcoe_ctlr or fc_lport objects during recovery since
+	 * they were not reaped during the unload process.
+	 */
+	if (mode != QEDF_MODE_RECOVERY) {
+		/* Setup imbedded fcoe controller */
+		qedf_fcoe_ctlr_setup(qedf);
+
+		/* Setup lport */
+		rc = qedf_lport_setup(qedf);
+		if (rc) {
+			QEDF_ERR(&(qedf->dbg_ctx),
+			    "qedf_lport_setup failed.\n");
+			goto err7;
+		}
+	}
+
+	sprintf(host_buf, "qedf_%u_timer", qedf->lport->host->host_no);
+	qedf->timer_work_queue =
+		create_singlethread_workqueue(host_buf);
+	if (!qedf->timer_work_queue) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Failed to start timer "
+			  "workqueue.\n");
+		goto err7;
+	}
+
+	/* DPC workqueue is not reaped during recovery unload */
+	if (mode != QEDF_MODE_RECOVERY) {
+		sprintf(host_buf, "qedf_%u_dpc",
+		    qedf->lport->host->host_no);
+		qedf->dpc_wq = create_singlethread_workqueue(host_buf);
+	}
+
+	/*
+	 * GRC dump and sysfs parameters are not reaped during the recovery
+	 * unload process.
+	 */
+	if (mode != QEDF_MODE_RECOVERY) {
+		qedf->grcdump_size = qed_ops->common->dbg_grc_size(qedf->cdev);
+		if (qedf->grcdump_size) {
+			rc = qedf_alloc_grc_dump_buf(&qedf->grcdump,
+			    qedf->grcdump_size);
+			if (rc) {
+				QEDF_ERR(&(qedf->dbg_ctx),
+				    "GRC Dump buffer alloc failed.\n");
+				qedf->grcdump = NULL;
+			}
+
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+			    "grcdump: addr=%p, size=%u.\n",
+			    qedf->grcdump, qedf->grcdump_size);
+		}
+		qedf_create_sysfs_ctx_attr(qedf);
+
+		/* Initialize I/O tracing for this adapter */
+		spin_lock_init(&qedf->io_trace_lock);
+		qedf->io_trace_idx = 0;
+	}
+
+	init_completion(&qedf->flogi_compl);
+
+	memset(&link_params, 0, sizeof(struct qed_link_params));
+	link_params.link_up = true;
+	status = qed_ops->common->set_link(qedf->cdev, &link_params);
+	if (status)
+		QEDF_WARN(&(qedf->dbg_ctx), "set_link failed.\n");
+
+	/* Start/restart discovery */
+	if (mode == QEDF_MODE_RECOVERY)
+		fcoe_ctlr_link_up(&qedf->ctlr);
+	else
+		fc_fabric_login(lport);
+
+	/* All good */
+	return 0;
+
+err7:
+	fc_remove_host(qedf->lport->host);
+	scsi_remove_host(qedf->lport->host);
+#ifdef CONFIG_DEBUG_FS
+	qedf_dbg_host_exit(&(qedf->dbg_ctx));
+#endif
+err6:
+	qedf_cmd_mgr_free(qedf->cmd_mgr);
+err5:
+	qed_ops->stop(qedf->cdev);
+err4:
+	qedf_free_fcoe_pf_param(qedf);
+	qedf_sync_free_irqs(qedf);
+err3:
+	qed_ops->common->slowpath_stop(qedf->cdev);
+err2:
+	qed_ops->common->remove(qedf->cdev);
+err1:
+	scsi_host_put(lport->host);
+err0:
+	return rc;
+}
+
+static int qedf_probe(struct pci_dev *pdev, const struct pci_device_id *id)
+{
+	return __qedf_probe(pdev, QEDF_MODE_NORMAL);
+}
+
+static void __qedf_remove(struct pci_dev *pdev, int mode)
+{
+	struct qedf_ctx *qedf;
+
+	if (!pdev) {
+		QEDF_ERR(NULL, "pdev is NULL.\n");
+		return;
+	}
+
+	qedf = pci_get_drvdata(pdev);
+
+	/*
+	 * Prevent race where we're in board disable work and then try to
+	 * rmmod the module.
+	 */
+	if (test_bit(QEDF_UNLOADING, &qedf->flags)) {
+		QEDF_ERR(&qedf->dbg_ctx, "Already removing PCI function.\n");
+		return;
+	}
+
+	if (mode != QEDF_MODE_RECOVERY)
+		set_bit(QEDF_UNLOADING, &qedf->flags);
+
+	/* Logoff the fabric to upload all connections */
+	if (mode == QEDF_MODE_RECOVERY)
+		fcoe_ctlr_link_down(&qedf->ctlr);
+	else
+		fc_fabric_logoff(qedf->lport);
+	qedf_wait_for_upload(qedf);
+
+#ifdef CONFIG_DEBUG_FS
+	qedf_dbg_host_exit(&(qedf->dbg_ctx));
+#endif
+
+	/* Stop any link update handling */
+	cancel_delayed_work_sync(&qedf->link_update);
+	destroy_workqueue(qedf->link_update_wq);
+	qedf->link_update_wq = NULL;
+
+	if (qedf->timer_work_queue)
+		destroy_workqueue(qedf->timer_work_queue);
+
+	/* Stop Light L2 */
+	clear_bit(QEDF_LL2_STARTED, &qedf->flags);
+	qed_ops->ll2->stop(qedf->cdev);
+	if (qedf->ll2_recv_thread)
+		kthread_stop(qedf->ll2_recv_thread);
+	qedf_ll2_free_skbs(qedf);
+
+	/* Stop fastpath */
+	qedf_sync_free_irqs(qedf);
+	qedf_destroy_sb(qedf);
+
+	/*
+	 * During recovery don't destroy OS constructs that represent the
+	 * physical port.
+	 */
+	if (mode != QEDF_MODE_RECOVERY) {
+		qedf_free_grc_dump_buf(&qedf->grcdump);
+		qedf_remove_sysfs_ctx_attr(qedf);
+
+		/* Remove all SCSI/libfc/libfcoe structures */
+		fcoe_ctlr_destroy(&qedf->ctlr);
+		fc_lport_destroy(qedf->lport);
+		fc_remove_host(qedf->lport->host);
+		scsi_remove_host(qedf->lport->host);
+	}
+
+	qedf_cmd_mgr_free(qedf->cmd_mgr);
+
+	if (mode != QEDF_MODE_RECOVERY) {
+		fc_exch_mgr_free(qedf->lport);
+		fc_lport_free_stats(qedf->lport);
+
+		/* Wait for all vports to be reaped */
+		qedf_wait_for_vport_destroy(qedf);
+	}
+
+	/*
+	 * Now that all connections have been uploaded we can stop the
+	 * rest of the qed operations
+	 */
+	qed_ops->stop(qedf->cdev);
+
+	if (mode != QEDF_MODE_RECOVERY) {
+		if (qedf->dpc_wq) {
+			/* Stop general DPC handling */
+			destroy_workqueue(qedf->dpc_wq);
+			qedf->dpc_wq = NULL;
+		}
+	}
+
+	/* Final shutdown for the board */
+	qedf_free_fcoe_pf_param(qedf);
+	if (mode != QEDF_MODE_RECOVERY) {
+		qed_ops->common->set_power_state(qedf->cdev, PCI_D0);
+		pci_set_drvdata(pdev, NULL);
+	}
+	qed_ops->common->slowpath_stop(qedf->cdev);
+	qed_ops->common->remove(qedf->cdev);
+
+	mempool_destroy(qedf->io_mempool);
+
+	/* Only reap the Scsi_host on a real removal */
+	if (mode != QEDF_MODE_RECOVERY)
+		scsi_host_put(qedf->lport->host);
+}
+
+static void qedf_remove(struct pci_dev *pdev)
+{
+	/* Check to make sure this function wasn't already disabled */
+	if (!atomic_read(&pdev->enable_cnt))
+		return;
+
+	__qedf_remove(pdev, QEDF_MODE_NORMAL);
+}
+
+/*
+ * Per CPU I/O thread initialization code.
+ */
+static void qedf_percpu_iothread_create(unsigned int cpu)
+{
+	struct qedf_percpu_iothread_s *iothread;
+	char io_thread_str[20];
+
+	iothread = &per_cpu(qedf_percpu_iothreads, cpu);
+	sprintf(io_thread_str, "qedf_io_%d", cpu);
+	iothread->iothread = kthread_create(qedf_fp_io_thread,
+		    (void *)iothread, io_thread_str);
+	if (iothread->iothread) {
+		kthread_bind(iothread->iothread, cpu);
+		wake_up_process(iothread->iothread);
+	}
+	QEDF_INFO(NULL, QEDF_LOG_DISC,
+	    "Creating I/O thread for CPU %d at %p.\n", cpu,
+	    iothread->iothread);
+}
+
+/* Free any remaining I/O work items */
+static void qedf_percpu_iothread_flush(struct qedf_percpu_iothread_s *iothread)
+{
+	struct qedf_io_work *work, *work_tmp;
+	unsigned long flags;
+
+	spin_lock_irqsave(&iothread->work_lock, flags);
+	list_for_each_entry_safe(work, work_tmp, &iothread->work_list, list) {
+		list_del(&work->list);
+		kfree(work);
+	}
+	spin_unlock_irqrestore(&iothread->work_lock, flags);
+}
+
+static void qedf_percpu_iothread_destroy(unsigned int cpu)
+{
+	struct qedf_percpu_iothread_s *iothread;
+
+	iothread = &per_cpu(qedf_percpu_iothreads, cpu);
+
+	if (iothread->iothread == NULL)
+		return;
+
+	QEDF_INFO(NULL, QEDF_LOG_DISC,
+	    "Freeing I/O thread for CPU %d.\n", cpu);
+	qedf_percpu_iothread_flush(iothread);
+	if (iothread->iothread) {
+		kthread_stop(iothread->iothread);
+		iothread->iothread = NULL;
+	}
+}
+
+/*
+ * We need to respond to a CPU hotplug events by starting or stopping a
+ * per CPU I/O thread.
+ */
+static int qedf_cpu_callback(struct notifier_block *nfb,
+	unsigned long action, void *hcpu)
+{
+	unsigned int cpu = (unsigned long)hcpu;
+
+	switch (action) {
+	case CPU_ONLINE:
+	case CPU_ONLINE_FROZEN:
+		QEDF_ERR(NULL, "CPU %d online.\n", cpu);
+		qedf_percpu_iothread_create(cpu);
+		break;
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
+		QEDF_ERR(NULL, "CPU %d offline.\n", cpu);
+		qedf_percpu_iothread_destroy(cpu);
+		break;
+	default:
+		break;
+	}
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block qedf_cpu_notifier = {
+	.notifier_call = qedf_cpu_callback,
+};
+
+/*
+ * Module Init/Remove
+ */
+
+static int __init qedf_init(void)
+{
+	int ret;
+	struct qedf_percpu_iothread_s *iothread;
+	unsigned int cpu;
+
+	/* If debug=1 passed, set the default log mask */
+	if (qedf_debug == QEDF_LOG_DEFAULT)
+		qedf_debug = QEDF_DEFAULT_LOG_MASK;
+
+	/* Print driver banner */
+	QEDF_INFO(NULL, QEDF_LOG_INFO, "%s v%s.\n", QEDF_DESCR,
+		   QEDF_VERSION);
+
+	/* Create kmem_cache for qedf_io_work structs */
+	qedf_io_work_cache = kmem_cache_create("qedf_io_work_cache",
+	    sizeof(struct qedf_io_work), 0, SLAB_HWCACHE_ALIGN, NULL);
+	if (qedf_io_work_cache == NULL) {
+		QEDF_ERR(NULL, "qedf_io_work_cache is NULL.\n");
+		goto err1;
+	}
+	QEDF_INFO(NULL, QEDF_LOG_DISC, "qedf_io_work_cache=%p.\n",
+	    qedf_io_work_cache);
+
+	qed_ops = qed_get_fcoe_ops();
+	if (!qed_ops) {
+		QEDF_ERR(NULL, "Failed to get qed fcoe operations\n");
+		goto err1;
+	}
+
+#ifdef CONFIG_DEBUG_FS
+	qedf_dbg_init("qedf");
+#endif
+
+	qedf_fc_transport_template =
+	    fc_attach_transport(&qedf_fc_transport_fn);
+	if (!qedf_fc_transport_template) {
+		QEDF_ERR(NULL, "Could not register with FC transport\n");
+		goto err2;
+	}
+
+	qedf_fc_vport_transport_template =
+		fc_attach_transport(&qedf_fc_vport_transport_fn);
+	if (!qedf_fc_vport_transport_template) {
+		QEDF_ERR(NULL, "Could not register vport template with FC "
+			  "transport\n");
+		goto err3;
+	}
+
+	/* Initialize the per CPU I/O threads */
+	for_each_possible_cpu(cpu) {
+		iothread = &per_cpu(qedf_percpu_iothreads, cpu);
+		INIT_LIST_HEAD(&iothread->work_list);
+		spin_lock_init(&iothread->work_lock);
+	}
+
+	for_each_online_cpu(cpu) {
+		qedf_percpu_iothread_create(cpu);
+	}
+
+	register_hotcpu_notifier(&qedf_cpu_notifier);
+
+	qedf_cb_ops.get_login_failures = qedf_get_login_failures;
+
+	ret = pci_register_driver(&qedf_pci_driver);
+	if (ret) {
+		QEDF_ERR(NULL, "Failed to register driver\n");
+		goto err4;
+	}
+
+	return 0;
+
+err4:
+	/* Release any I/O threads */
+	for_each_online_cpu(cpu) {
+		qedf_percpu_iothread_destroy(cpu);
+	}
+
+	fc_release_transport(qedf_fc_vport_transport_template);
+err3:
+	fc_release_transport(qedf_fc_transport_template);
+err2:
+#ifdef CONFIG_DEBUG_FS
+	qedf_dbg_exit();
+#endif
+	qed_put_fcoe_ops();
+err1:
+	return -EINVAL;
+}
+
+static void __exit qedf_cleanup(void)
+{
+	unsigned int cpu;
+
+	pci_unregister_driver(&qedf_pci_driver);
+
+	unregister_hotcpu_notifier(&qedf_cpu_notifier);
+
+	/* Destroy percpu I/O threads */
+	for_each_online_cpu(cpu) {
+		qedf_percpu_iothread_destroy(cpu);
+	}
+
+	fc_release_transport(qedf_fc_vport_transport_template);
+	fc_release_transport(qedf_fc_transport_template);
+#ifdef CONFIG_DEBUG_FS
+	qedf_dbg_exit();
+#endif
+	qed_put_fcoe_ops();
+
+	kmem_cache_destroy(qedf_io_work_cache);
+}
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("QLogic QEDF 25/40/50/100Gb FCoE Driver");
+MODULE_AUTHOR("QLogic Corporation");
+MODULE_VERSION(QEDF_VERSION);
+module_init(qedf_init);
+module_exit(qedf_cleanup);
diff --git a/drivers/scsi/qedf/qedf_version.h b/drivers/scsi/qedf/qedf_version.h
new file mode 100644
index 0000000..4ae5f53
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_version.h
@@ -0,0 +1,15 @@
+/*
+ *  QLogic FCoE Offload Driver
+ *  Copyright (c) 2016 Cavium Inc.
+ *
+ *  This software is available under the terms of the GNU General Public License
+ *  (GPL) Version 2, available from the file COPYING in the main directory of
+ *  this source tree.
+ */
+
+#define QEDF_VERSION		"8.10.7.0"
+#define QEDF_DRIVER_MAJOR_VER		8
+#define QEDF_DRIVER_MINOR_VER		10
+#define QEDF_DRIVER_REV_VER		7
+#define QEDF_DRIVER_ENG_VER		0
+
-- 
1.8.5.6
