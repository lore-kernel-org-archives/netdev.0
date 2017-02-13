From: "Dupuis, Chad" <chad.dupuis@cavium.com>
Subject: [PATCH V4 2/2] qedf: Add QLogic FastLinQ offload FCoE driver framework.
Date: Mon, 13 Feb 2017 11:17:01 -0800
Message-ID: <1487013421-27006-3-git-send-email-chad.dupuis@cavium.com>
References: <1487013421-27006-1-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <fcoe-devel@open-fcoe.org>,
        <netdev@vger.kernel.org>, <yuval.mintz@cavium.com>,
        <QLogic-Storage-Upstream@cavium.com>
To: <martin.petersen@oracle.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1487013421-27006-1-git-send-email-chad.dupuis@cavium.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dupuis, Chad" <chad.dupuis@cavium.com>

The QLogic FastLinQ Driver for FCoE (qedf) is the FCoE specific module for 41000
Series Converged Network Adapters by QLogic. This patch consists of following
changes:

- MAINTAINERS Makefile and Kconfig changes for qedf
- PCI driver registration
- libfc/fcoe host level initialization
- SCSI host template initialization and callbacks
- Debugfs and log level infrastructure
- Link handling
- Firmware interface structures
- QED core module initialization
- Light L2 interface callbacks
- I/O request initialization
- Firmware I/O completion handling
- Firmware ELS request/response handling
- FIP request/response handled by the driver itself

Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
Signed-off-by: Arun Easi <arun.easi@cavium.com>
Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
---
 MAINTAINERS                      |    6 +
 drivers/scsi/Kconfig             |    1 +
 drivers/scsi/Makefile            |    1 +
 drivers/scsi/qedf/Kconfig        |   11 +
 drivers/scsi/qedf/Makefile       |    5 +
 drivers/scsi/qedf/qedf.h         |  545 +++++++
 drivers/scsi/qedf/qedf_attr.c    |  165 ++
 drivers/scsi/qedf/qedf_dbg.c     |  195 +++
 drivers/scsi/qedf/qedf_dbg.h     |  154 ++
 drivers/scsi/qedf/qedf_debugfs.c |  460 ++++++
 drivers/scsi/qedf/qedf_els.c     |  949 +++++++++++
 drivers/scsi/qedf/qedf_fip.c     |  269 +++
 drivers/scsi/qedf/qedf_hsi.h     |  422 +++++
 drivers/scsi/qedf/qedf_io.c      | 2282 ++++++++++++++++++++++++++
 drivers/scsi/qedf/qedf_main.c    | 3336 ++++++++++++++++++++++++++++++++++++++
 drivers/scsi/qedf/qedf_version.h |   15 +
 16 files changed, 8816 insertions(+)
 create mode 100644 drivers/scsi/qedf/Kconfig
 create mode 100644 drivers/scsi/qedf/Makefile
 create mode 100644 drivers/scsi/qedf/qedf.h
 create mode 100644 drivers/scsi/qedf/qedf_attr.c
 create mode 100644 drivers/scsi/qedf/qedf_dbg.c
 create mode 100644 drivers/scsi/qedf/qedf_dbg.h
 create mode 100644 drivers/scsi/qedf/qedf_debugfs.c
 create mode 100644 drivers/scsi/qedf/qedf_els.c
 create mode 100644 drivers/scsi/qedf/qedf_fip.c
 create mode 100644 drivers/scsi/qedf/qedf_hsi.h
 create mode 100644 drivers/scsi/qedf/qedf_io.c
 create mode 100644 drivers/scsi/qedf/qedf_main.c
 create mode 100644 drivers/scsi/qedf/qedf_version.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 5e637e2..b503900 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10181,6 +10181,12 @@ L:	linux-scsi@vger.kernel.org
 S:	Supported
 F:	drivers/scsi/qedi/
 
+QLOGIC QL41xxx FCOE DRIVER
+M:	QLogic-Storage-Upstream@cavium.com
+L:	linux-scsi@vger.kernel.org
+S:	Supported
+F:	drivers/scsi/qedf/
+
 QNX4 FILESYSTEM
 M:	Anders Larsen <al@alarsen.net>
 W:	http://www.alarsen.net/linux/qnx4fs/
diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
index a4f6b0d..e9fce78b 100644
--- a/drivers/scsi/Kconfig
+++ b/drivers/scsi/Kconfig
@@ -1234,6 +1234,7 @@ config SCSI_QLOGICPTI
 source "drivers/scsi/qla2xxx/Kconfig"
 source "drivers/scsi/qla4xxx/Kconfig"
 source "drivers/scsi/qedi/Kconfig"
+source "drivers/scsi/qedf/Kconfig"
 
 config SCSI_LPFC
 	tristate "Emulex LightPulse Fibre Channel Support"
diff --git a/drivers/scsi/Makefile b/drivers/scsi/Makefile
index 736b774..fc28555 100644
--- a/drivers/scsi/Makefile
+++ b/drivers/scsi/Makefile
@@ -41,6 +41,7 @@ obj-$(CONFIG_FCOE)		+= fcoe/
 obj-$(CONFIG_FCOE_FNIC)		+= fnic/
 obj-$(CONFIG_SCSI_SNIC)		+= snic/
 obj-$(CONFIG_SCSI_BNX2X_FCOE)	+= libfc/ fcoe/ bnx2fc/
+obj-$(CONFIG_QEDF)		+= qedf/
 obj-$(CONFIG_ISCSI_TCP) 	+= libiscsi.o	libiscsi_tcp.o iscsi_tcp.o
 obj-$(CONFIG_INFINIBAND_ISER) 	+= libiscsi.o
 obj-$(CONFIG_ISCSI_BOOT_SYSFS)	+= iscsi_boot_sysfs.o
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
index 0000000..64e9f50
--- /dev/null
+++ b/drivers/scsi/qedf/Makefile
@@ -0,0 +1,5 @@
+obj-$(CONFIG_QEDF) := qedf.o
+qedf-y = qedf_dbg.o qedf_main.o qedf_io.o qedf_fip.o \
+	 qedf_attr.o qedf_els.o
+
+qedf-$(CONFIG_DEBUG_FS) += qedf_debugfs.o
diff --git a/drivers/scsi/qedf/qedf.h b/drivers/scsi/qedf/qedf.h
new file mode 100644
index 0000000..96346a1
--- /dev/null
+++ b/drivers/scsi/qedf/qedf.h
@@ -0,0 +1,545 @@
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
+extern struct workqueue_struct *qedf_io_wq;
+
+struct qedf_rport {
+	spinlock_t rport_lock;
+#define QEDF_RPORT_SESSION_READY 1
+#define QEDF_RPORT_UPLOADING_CONNECTION	2
+	unsigned long flags;
+	unsigned long retry_delay_timestamp;
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
+	struct list_head peers;
+};
+
+/* Used to contain LL2 skb's in ll2_skb_list */
+struct qedf_skb_work {
+	struct work_struct work;
+	struct sk_buff *skb;
+	struct qedf_ctx *qedf;
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
+	struct work_struct work;
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
+	struct list_head fcports;
+	atomic_t num_offloads;
+	unsigned int curr_conn_id;
+	struct workqueue_struct *ll2_recv_wq;
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
+#define QEDF_DBG_STOP_IO		6
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
+	set_bit(QEDF_DBG_STOP_IO, &qedf->flags);
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
+	struct fcoe_cqe *cqe, struct qedf_ioreq *io_req);
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
+extern void qedf_restart_rport(struct qedf_rport *fcport);
+extern int qedf_send_rec(struct qedf_ioreq *orig_io_req);
+extern int qedf_post_io_req(struct qedf_rport *fcport,
+	struct qedf_ioreq *io_req);
+extern void qedf_process_seq_cleanup_compl(struct qedf_ctx *qedf,
+	struct fcoe_cqe *cqe, struct qedf_ioreq *io_req);
+extern int qedf_send_flogi(struct qedf_ctx *qedf);
+extern void qedf_fp_io_handler(struct work_struct *work);
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
index 0000000..e023f5d
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_dbg.c
@@ -0,0 +1,195 @@
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
+		goto ret;
+
+	if (likely(qedf) && likely(qedf->pdev))
+		pr_warn("[%s]:[%s:%d]:%d: %pV", dev_name(&(qedf->pdev->dev)),
+			nfunc, line, qedf->host_no, &vaf);
+	else
+		pr_warn("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
+
+ret:
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
+		goto ret;
+
+	if (likely(qedf) && likely(qedf->pdev))
+		pr_notice("[%s]:[%s:%d]:%d: %pV",
+			  dev_name(&(qedf->pdev->dev)), nfunc, line,
+			  qedf->host_no, &vaf);
+	else
+		pr_notice("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
+
+ret:
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
+		goto ret;
+
+	if (likely(qedf) && likely(qedf->pdev))
+		pr_info("[%s]:[%s:%d]:%d: %pV", dev_name(&(qedf->pdev->dev)),
+			nfunc, line, qedf->host_no, &vaf);
+	else
+		pr_info("[0000:00:00.0]:[%s:%d]: %pV", nfunc, line, &vaf);
+
+ret:
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
index 0000000..23bd706
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_dbg.h
@@ -0,0 +1,154 @@
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
+extern void qedf_dbg_err(struct qedf_dbg_ctx *qedf, const char *func, u32 line,
+			  const char *fmt, ...);
+extern void qedf_dbg_warn(struct qedf_dbg_ctx *qedf, const char *func, u32 line,
+			   const char *, ...);
+extern void qedf_dbg_notice(struct qedf_dbg_ctx *qedf, const char *func,
+			    u32 line, const char *, ...);
+extern void qedf_dbg_info(struct qedf_dbg_ctx *qedf, const char *func, u32 line,
+			  u32 info, const char *fmt, ...);
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
+extern int qedf_alloc_grc_dump_buf(uint8_t **buf, uint32_t len);
+extern void qedf_free_grc_dump_buf(uint8_t **buf);
+extern int qedf_get_grc_dump(struct qed_dev *cdev,
+			     const struct qed_common_ops *common, uint8_t **buf,
+			     uint32_t *grcsize);
+extern void qedf_uevent_emit(struct Scsi_Host *shost, u32 code, char *msg);
+extern int qedf_create_sysfs_attr(struct Scsi_Host *shost,
+				   struct sysfs_bin_attrs *iter);
+extern void qedf_remove_sysfs_attr(struct Scsi_Host *shost,
+				    struct sysfs_bin_attrs *iter);
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
index 0000000..cb08b62
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_debugfs.c
@@ -0,0 +1,460 @@
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
+	struct qedf_ctx *qedf = container_of(qedf_dbg,
+	    struct qedf_ctx, dbg_ctx);
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
+		set_bit(QEDF_DBG_STOP_IO, &qedf->flags);
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
+	struct qedf_ctx *qedf = container_of(qedf_dbg,
+	    struct qedf_ctx, dbg_ctx);
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
+
+	seq_printf(s, "cmg_mgr free io_reqs: %d\n",
+	    atomic_read(&qedf->cmd_mgr->free_list_cnt));
+	seq_printf(s, "slow SGEs: %d\n", qedf->slow_sge_ios);
+	seq_printf(s, "single SGEs: %d\n", qedf->single_sge_ios);
+	seq_printf(s, "fast SGEs: %d\n\n", qedf->fast_sge_ios);
+
+	seq_puts(s, "Offloaded ports:\n\n");
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(fcport, &qedf->fcports, peers) {
+		rdata = fcport->rdata;
+		if (rdata == NULL)
+			continue;
+		seq_printf(s, "%06x: free_sqes: %d, num_active_ios: %d\n",
+		    rdata->ids.port_id, atomic_read(&fcport->free_sqes),
+		    atomic_read(&fcport->num_active_ios));
+	}
+	rcu_read_unlock();
+
+	return 0;
+}
+
+static int
+qedf_dbg_driver_stats_open(struct inode *inode, struct file *file)
+{
+	struct qedf_dbg_ctx *qedf_dbg = inode->i_private;
+	struct qedf_ctx *qedf = container_of(qedf_dbg,
+	    struct qedf_ctx, dbg_ctx);
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
+	struct qedf_ctx *qedf = container_of(qedf_dbg,
+	    struct qedf_ctx, dbg_ctx);
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
diff --git a/drivers/scsi/qedf/qedf_els.c b/drivers/scsi/qedf/qedf_els.c
new file mode 100644
index 0000000..78f1c25
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_els.c
@@ -0,0 +1,949 @@
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
+/* It's assumed that the lock is held when calling this function. */
+static int qedf_initiate_els(struct qedf_rport *fcport, unsigned int op,
+	void *data, uint32_t data_len,
+	void (*cb_func)(struct qedf_els_cb_arg *cb_arg),
+	struct qedf_els_cb_arg *cb_arg, uint32_t timer_msec)
+{
+	struct qedf_ctx *qedf = fcport->qedf;
+	struct fc_lport *lport = qedf->lport;
+	struct qedf_ioreq *els_req;
+	struct qedf_mp_req *mp_req;
+	struct fc_frame_header *fc_hdr;
+	struct fcoe_task_context *task;
+	int rc = 0;
+	uint32_t did, sid;
+	uint16_t xid;
+	uint32_t start_time = jiffies / HZ;
+	uint32_t current_time;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "Sending ELS\n");
+
+	rc = fc_remote_port_chkready(fcport->rport);
+	if (rc) {
+		QEDF_ERR(&(qedf->dbg_ctx), "els 0x%x: rport not ready\n", op);
+		rc = -EAGAIN;
+		goto els_err;
+	}
+	if (lport->state != LPORT_ST_READY || !(lport->link_up)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "els 0x%x: link is not ready\n",
+			  op);
+		rc = -EAGAIN;
+		goto els_err;
+	}
+
+	if (!(test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags))) {
+		QEDF_ERR(&(qedf->dbg_ctx), "els 0x%x: fcport not ready\n", op);
+		rc = -EINVAL;
+		goto els_err;
+	}
+
+retry_els:
+	els_req = qedf_alloc_cmd(fcport, QEDF_ELS);
+	if (!els_req) {
+		current_time = jiffies / HZ;
+		if ((current_time - start_time) > 10) {
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+				   "els: Failed els 0x%x\n", op);
+			rc = -ENOMEM;
+			goto els_err;
+		}
+		mdelay(20 * USEC_PER_MSEC);
+		goto retry_els;
+	}
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "initiate_els els_req = "
+		   "0x%p cb_arg = %p xid = %x\n", els_req, cb_arg,
+		   els_req->xid);
+	els_req->sc_cmd = NULL;
+	els_req->cmd_type = QEDF_ELS;
+	els_req->fcport = fcport;
+	els_req->cb_func = cb_func;
+	cb_arg->io_req = els_req;
+	cb_arg->op = op;
+	els_req->cb_arg = cb_arg;
+	els_req->data_xfer_len = data_len;
+
+	/* Record which cpu this request is associated with */
+	els_req->cpu = smp_processor_id();
+
+	mp_req = (struct qedf_mp_req *)&(els_req->mp_req);
+	rc = qedf_init_mp_req(els_req);
+	if (rc) {
+		QEDF_ERR(&(qedf->dbg_ctx), "ELS MP request init failed\n");
+		kref_put(&els_req->refcount, qedf_release_cmd);
+		goto els_err;
+	} else {
+		rc = 0;
+	}
+
+	/* Fill ELS Payload */
+	if ((op >= ELS_LS_RJT) && (op <= ELS_AUTH_ELS)) {
+		memcpy(mp_req->req_buf, data, data_len);
+	} else {
+		QEDF_ERR(&(qedf->dbg_ctx), "Invalid ELS op 0x%x\n", op);
+		els_req->cb_func = NULL;
+		els_req->cb_arg = NULL;
+		kref_put(&els_req->refcount, qedf_release_cmd);
+		rc = -EINVAL;
+	}
+
+	if (rc)
+		goto els_err;
+
+	/* Fill FC header */
+	fc_hdr = &(mp_req->req_fc_hdr);
+
+	did = fcport->rdata->ids.port_id;
+	sid = fcport->sid;
+
+	__fc_fill_fc_hdr(fc_hdr, FC_RCTL_ELS_REQ, sid, did,
+			   FC_TYPE_ELS, FC_FC_FIRST_SEQ | FC_FC_END_SEQ |
+			   FC_FC_SEQ_INIT, 0);
+
+	/* Obtain exchange id */
+	xid = els_req->xid;
+
+	/* Initialize task context for this IO request */
+	task = qedf_get_task_mem(&qedf->tasks, xid);
+	qedf_init_mp_task(els_req, task);
+
+	/* Put timer on original I/O request */
+	if (timer_msec)
+		qedf_cmd_timer_set(qedf, els_req, timer_msec);
+
+	qedf_add_to_sq(fcport, xid, 0, FCOE_TASK_TYPE_MIDPATH, 0);
+
+	/* Ring doorbell */
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "Ringing doorbell for ELS "
+		   "req\n");
+	qedf_ring_doorbell(fcport);
+els_err:
+	return rc;
+}
+
+void qedf_process_els_compl(struct qedf_ctx *qedf, struct fcoe_cqe *cqe,
+	struct qedf_ioreq *els_req)
+{
+	struct fcoe_task_context *task_ctx;
+	struct scsi_cmnd *sc_cmd;
+	uint16_t xid;
+	struct fcoe_cqe_midpath_info *mp_info;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "Entered with xid = 0x%x"
+		   " cmd_type = %d.\n", els_req->xid, els_req->cmd_type);
+
+	/* Kill the ELS timer */
+	cancel_delayed_work(&els_req->timeout_work);
+
+	xid = els_req->xid;
+	task_ctx = qedf_get_task_mem(&qedf->tasks, xid);
+	sc_cmd = els_req->sc_cmd;
+
+	/* Get ELS response length from CQE */
+	mp_info = &cqe->cqe_info.midpath_info;
+	els_req->mp_req.resp_len = mp_info->data_placement_size;
+
+	/* Parse ELS response */
+	if ((els_req->cb_func) && (els_req->cb_arg)) {
+		els_req->cb_func(els_req->cb_arg);
+		els_req->cb_arg = NULL;
+	}
+
+	kref_put(&els_req->refcount, qedf_release_cmd);
+}
+
+static void qedf_rrq_compl(struct qedf_els_cb_arg *cb_arg)
+{
+	struct qedf_ioreq *orig_io_req;
+	struct qedf_ioreq *rrq_req;
+	struct qedf_ctx *qedf;
+	int refcount;
+
+	rrq_req = cb_arg->io_req;
+	qedf = rrq_req->fcport->qedf;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "Entered.\n");
+
+	orig_io_req = cb_arg->aborted_io_req;
+
+	if (!orig_io_req)
+		goto out_free;
+
+	if (rrq_req->event != QEDF_IOREQ_EV_ELS_TMO &&
+	    rrq_req->event != QEDF_IOREQ_EV_ELS_ERR_DETECT)
+		cancel_delayed_work_sync(&orig_io_req->timeout_work);
+
+	refcount = atomic_read(&orig_io_req->refcount.refcount);
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "rrq_compl: orig io = %p,"
+		   " orig xid = 0x%x, rrq_xid = 0x%x, refcount=%d\n",
+		   orig_io_req, orig_io_req->xid, rrq_req->xid, refcount);
+
+	/* This should return the aborted io_req to the command pool */
+	if (orig_io_req)
+		kref_put(&orig_io_req->refcount, qedf_release_cmd);
+
+out_free:
+	kfree(cb_arg);
+}
+
+/* Assumes kref is already held by caller */
+int qedf_send_rrq(struct qedf_ioreq *aborted_io_req)
+{
+
+	struct fc_els_rrq rrq;
+	struct qedf_rport *fcport;
+	struct fc_lport *lport;
+	struct qedf_els_cb_arg *cb_arg = NULL;
+	struct qedf_ctx *qedf;
+	uint32_t sid;
+	uint32_t r_a_tov;
+	int rc;
+
+	if (!aborted_io_req) {
+		QEDF_ERR(NULL, "abort_io_req is NULL.\n");
+		return -EINVAL;
+	}
+
+	fcport = aborted_io_req->fcport;
+
+	/* Check that fcport is still offloaded */
+	if (!(test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags))) {
+		QEDF_ERR(NULL, "fcport is no longer offloaded.\n");
+		return -EINVAL;
+	}
+
+	if (!fcport->qedf) {
+		QEDF_ERR(NULL, "fcport->qedf is NULL.\n");
+		return -EINVAL;
+	}
+
+	qedf = fcport->qedf;
+	lport = qedf->lport;
+	sid = fcport->sid;
+	r_a_tov = lport->r_a_tov;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "Sending RRQ orig "
+		   "io = %p, orig_xid = 0x%x\n", aborted_io_req,
+		   aborted_io_req->xid);
+	memset(&rrq, 0, sizeof(rrq));
+
+	cb_arg = kzalloc(sizeof(struct qedf_els_cb_arg), GFP_NOIO);
+	if (!cb_arg) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Unable to allocate cb_arg for "
+			  "RRQ\n");
+		rc = -ENOMEM;
+		goto rrq_err;
+	}
+
+	cb_arg->aborted_io_req = aborted_io_req;
+
+	rrq.rrq_cmd = ELS_RRQ;
+	hton24(rrq.rrq_s_id, sid);
+	rrq.rrq_ox_id = htons(aborted_io_req->xid);
+	rrq.rrq_rx_id =
+	    htons(aborted_io_req->task->tstorm_st_context.read_write.rx_id);
+
+	rc = qedf_initiate_els(fcport, ELS_RRQ, &rrq, sizeof(rrq),
+	    qedf_rrq_compl, cb_arg, r_a_tov);
+
+rrq_err:
+	if (rc) {
+		QEDF_ERR(&(qedf->dbg_ctx), "RRQ failed - release orig io "
+			  "req 0x%x\n", aborted_io_req->xid);
+		kfree(cb_arg);
+		kref_put(&aborted_io_req->refcount, qedf_release_cmd);
+	}
+	return rc;
+}
+
+static void qedf_process_l2_frame_compl(struct qedf_rport *fcport,
+					struct fc_frame *fp,
+					u16 l2_oxid)
+{
+	struct fc_lport *lport = fcport->qedf->lport;
+	struct fc_frame_header *fh;
+	u32 crc;
+
+	fh = (struct fc_frame_header *)fc_frame_header_get(fp);
+
+	/* Set the OXID we return to what libfc used */
+	if (l2_oxid != FC_XID_UNKNOWN)
+		fh->fh_ox_id = htons(l2_oxid);
+
+	/* Setup header fields */
+	fh->fh_r_ctl = FC_RCTL_ELS_REP;
+	fh->fh_type = FC_TYPE_ELS;
+	/* Last sequence, end sequence */
+	fh->fh_f_ctl[0] = 0x98;
+	hton24(fh->fh_d_id, lport->port_id);
+	hton24(fh->fh_s_id, fcport->rdata->ids.port_id);
+	fh->fh_rx_id = 0xffff;
+
+	/* Set frame attributes */
+	crc = fcoe_fc_crc(fp);
+	fc_frame_init(fp);
+	fr_dev(fp) = lport;
+	fr_sof(fp) = FC_SOF_I3;
+	fr_eof(fp) = FC_EOF_T;
+	fr_crc(fp) = cpu_to_le32(~crc);
+
+	/* Send completed request to libfc */
+	fc_exch_recv(lport, fp);
+}
+
+/*
+ * In instances where an ELS command times out we may need to restart the
+ * rport by logging out and then logging back in.
+ */
+void qedf_restart_rport(struct qedf_rport *fcport)
+{
+	struct fc_lport *lport;
+	struct fc_rport_priv *rdata;
+	u32 port_id;
+
+	if (!fcport)
+		return;
+
+	rdata = fcport->rdata;
+	if (rdata) {
+		lport = fcport->qedf->lport;
+		port_id = rdata->ids.port_id;
+		QEDF_ERR(&(fcport->qedf->dbg_ctx),
+		    "LOGO port_id=%x.\n", port_id);
+		fc_rport_logoff(rdata);
+		/* Recreate the rport and log back in */
+		rdata = fc_rport_create(lport, port_id);
+		if (rdata)
+			fc_rport_login(rdata);
+	}
+}
+
+static void qedf_l2_els_compl(struct qedf_els_cb_arg *cb_arg)
+{
+	struct qedf_ioreq *els_req;
+	struct qedf_rport *fcport;
+	struct qedf_mp_req *mp_req;
+	struct fc_frame *fp;
+	struct fc_frame_header *fh, *mp_fc_hdr;
+	void *resp_buf, *fc_payload;
+	u32 resp_len;
+	u16 l2_oxid;
+
+	l2_oxid = cb_arg->l2_oxid;
+	els_req = cb_arg->io_req;
+
+	if (!els_req) {
+		QEDF_ERR(NULL, "els_req is NULL.\n");
+		goto free_arg;
+	}
+
+	/*
+	 * If we are flushing the command just free the cb_arg as none of the
+	 * response data will be valid.
+	 */
+	if (els_req->event == QEDF_IOREQ_EV_ELS_FLUSH)
+		goto free_arg;
+
+	fcport = els_req->fcport;
+	mp_req = &(els_req->mp_req);
+	mp_fc_hdr = &(mp_req->resp_fc_hdr);
+	resp_len = mp_req->resp_len;
+	resp_buf = mp_req->resp_buf;
+
+	/*
+	 * If a middle path ELS command times out, don't try to return
+	 * the command but rather do any internal cleanup and then libfc
+	 * timeout the command and clean up its internal resources.
+	 */
+	if (els_req->event == QEDF_IOREQ_EV_ELS_TMO) {
+		/*
+		 * If ADISC times out, libfc will timeout the exchange and then
+		 * try to send a PLOGI which will timeout since the session is
+		 * still offloaded.  Force libfc to logout the session which
+		 * will offload the connection and allow the PLOGI response to
+		 * flow over the LL2 path.
+		 */
+		if (cb_arg->op == ELS_ADISC)
+			qedf_restart_rport(fcport);
+		return;
+	}
+
+	if (sizeof(struct fc_frame_header) + resp_len > QEDF_PAGE_SIZE) {
+		QEDF_ERR(&(fcport->qedf->dbg_ctx), "resp_len is "
+		   "beyond page size.\n");
+		goto free_arg;
+	}
+
+	fp = fc_frame_alloc(fcport->qedf->lport, resp_len);
+	if (!fp) {
+		QEDF_ERR(&(fcport->qedf->dbg_ctx),
+		    "fc_frame_alloc failure.\n");
+		return;
+	}
+
+	/* Copy frame header from firmware into fp */
+	fh = (struct fc_frame_header *)fc_frame_header_get(fp);
+	memcpy(fh, mp_fc_hdr, sizeof(struct fc_frame_header));
+
+	/* Copy payload from firmware into fp */
+	fc_payload = fc_frame_payload_get(fp, resp_len);
+	memcpy(fc_payload, resp_buf, resp_len);
+
+	QEDF_INFO(&(fcport->qedf->dbg_ctx), QEDF_LOG_ELS,
+	    "Completing OX_ID 0x%x back to libfc.\n", l2_oxid);
+	qedf_process_l2_frame_compl(fcport, fp, l2_oxid);
+
+free_arg:
+	kfree(cb_arg);
+}
+
+int qedf_send_adisc(struct qedf_rport *fcport, struct fc_frame *fp)
+{
+	struct fc_els_adisc *adisc;
+	struct fc_frame_header *fh;
+	struct fc_lport *lport = fcport->qedf->lport;
+	struct qedf_els_cb_arg *cb_arg = NULL;
+	struct qedf_ctx *qedf;
+	uint32_t r_a_tov = lport->r_a_tov;
+	int rc;
+
+	qedf = fcport->qedf;
+	fh = fc_frame_header_get(fp);
+
+	cb_arg = kzalloc(sizeof(struct qedf_els_cb_arg), GFP_NOIO);
+	if (!cb_arg) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Unable to allocate cb_arg for "
+			  "ADISC\n");
+		rc = -ENOMEM;
+		goto adisc_err;
+	}
+	cb_arg->l2_oxid = ntohs(fh->fh_ox_id);
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+	    "Sending ADISC ox_id=0x%x.\n", cb_arg->l2_oxid);
+
+	adisc = fc_frame_payload_get(fp, sizeof(*adisc));
+
+	rc = qedf_initiate_els(fcport, ELS_ADISC, adisc, sizeof(*adisc),
+	    qedf_l2_els_compl, cb_arg, r_a_tov);
+
+adisc_err:
+	if (rc) {
+		QEDF_ERR(&(qedf->dbg_ctx), "ADISC failed.\n");
+		kfree(cb_arg);
+	}
+	return rc;
+}
+
+static void qedf_srr_compl(struct qedf_els_cb_arg *cb_arg)
+{
+	struct qedf_ioreq *orig_io_req;
+	struct qedf_ioreq *srr_req;
+	struct qedf_mp_req *mp_req;
+	struct fc_frame_header *mp_fc_hdr, *fh;
+	struct fc_frame *fp;
+	void *resp_buf, *fc_payload;
+	u32 resp_len;
+	struct fc_lport *lport;
+	struct qedf_ctx *qedf;
+	int refcount;
+	u8 opcode;
+
+	srr_req = cb_arg->io_req;
+	qedf = srr_req->fcport->qedf;
+	lport = qedf->lport;
+
+	orig_io_req = cb_arg->aborted_io_req;
+
+	if (!orig_io_req)
+		goto out_free;
+
+	clear_bit(QEDF_CMD_SRR_SENT, &orig_io_req->flags);
+
+	if (srr_req->event != QEDF_IOREQ_EV_ELS_TMO &&
+	    srr_req->event != QEDF_IOREQ_EV_ELS_ERR_DETECT)
+		cancel_delayed_work_sync(&orig_io_req->timeout_work);
+
+	refcount = atomic_read(&orig_io_req->refcount.refcount);
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "Entered: orig_io=%p,"
+		   " orig_io_xid=0x%x, rec_xid=0x%x, refcount=%d\n",
+		   orig_io_req, orig_io_req->xid, srr_req->xid, refcount);
+
+	/* If a SRR times out, simply free resources */
+	if (srr_req->event == QEDF_IOREQ_EV_ELS_TMO)
+		goto out_free;
+
+	/* Normalize response data into struct fc_frame */
+	mp_req = &(srr_req->mp_req);
+	mp_fc_hdr = &(mp_req->resp_fc_hdr);
+	resp_len = mp_req->resp_len;
+	resp_buf = mp_req->resp_buf;
+
+	fp = fc_frame_alloc(lport, resp_len);
+	if (!fp) {
+		QEDF_ERR(&(qedf->dbg_ctx),
+		    "fc_frame_alloc failure.\n");
+		goto out_free;
+	}
+
+	/* Copy frame header from firmware into fp */
+	fh = (struct fc_frame_header *)fc_frame_header_get(fp);
+	memcpy(fh, mp_fc_hdr, sizeof(struct fc_frame_header));
+
+	/* Copy payload from firmware into fp */
+	fc_payload = fc_frame_payload_get(fp, resp_len);
+	memcpy(fc_payload, resp_buf, resp_len);
+
+	opcode = fc_frame_payload_op(fp);
+	switch (opcode) {
+	case ELS_LS_ACC:
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+		    "SRR success.\n");
+		break;
+	case ELS_LS_RJT:
+		QEDF_INFO(&qedf->dbg_ctx, QEDF_LOG_ELS,
+		    "SRR rejected.\n");
+		qedf_initiate_abts(orig_io_req, true);
+		break;
+	}
+
+	fc_frame_free(fp);
+out_free:
+	/* Put reference for original command since SRR completed */
+	kref_put(&orig_io_req->refcount, qedf_release_cmd);
+	kfree(cb_arg);
+}
+
+static int qedf_send_srr(struct qedf_ioreq *orig_io_req, u32 offset, u8 r_ctl)
+{
+	struct fcp_srr srr;
+	struct qedf_ctx *qedf;
+	struct qedf_rport *fcport;
+	struct fc_lport *lport;
+	struct qedf_els_cb_arg *cb_arg = NULL;
+	u32 sid, r_a_tov;
+	int rc;
+
+	if (!orig_io_req) {
+		QEDF_ERR(NULL, "orig_io_req is NULL.\n");
+		return -EINVAL;
+	}
+
+	fcport = orig_io_req->fcport;
+
+	/* Check that fcport is still offloaded */
+	if (!(test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags))) {
+		QEDF_ERR(NULL, "fcport is no longer offloaded.\n");
+		return -EINVAL;
+	}
+
+	if (!fcport->qedf) {
+		QEDF_ERR(NULL, "fcport->qedf is NULL.\n");
+		return -EINVAL;
+	}
+
+	/* Take reference until SRR command completion */
+	kref_get(&orig_io_req->refcount);
+
+	qedf = fcport->qedf;
+	lport = qedf->lport;
+	sid = fcport->sid;
+	r_a_tov = lport->r_a_tov;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "Sending SRR orig_io=%p, "
+		   "orig_xid=0x%x\n", orig_io_req, orig_io_req->xid);
+	memset(&srr, 0, sizeof(srr));
+
+	cb_arg = kzalloc(sizeof(struct qedf_els_cb_arg), GFP_NOIO);
+	if (!cb_arg) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Unable to allocate cb_arg for "
+			  "SRR\n");
+		rc = -ENOMEM;
+		goto srr_err;
+	}
+
+	cb_arg->aborted_io_req = orig_io_req;
+
+	srr.srr_op = ELS_SRR;
+	srr.srr_ox_id = htons(orig_io_req->xid);
+	srr.srr_rx_id = htons(orig_io_req->rx_id);
+	srr.srr_rel_off = htonl(offset);
+	srr.srr_r_ctl = r_ctl;
+
+	rc = qedf_initiate_els(fcport, ELS_SRR, &srr, sizeof(srr),
+	    qedf_srr_compl, cb_arg, r_a_tov);
+
+srr_err:
+	if (rc) {
+		QEDF_ERR(&(qedf->dbg_ctx), "SRR failed - release orig_io_req"
+			  "=0x%x\n", orig_io_req->xid);
+		kfree(cb_arg);
+		/* If we fail to queue SRR, send ABTS to orig_io */
+		qedf_initiate_abts(orig_io_req, true);
+		kref_put(&orig_io_req->refcount, qedf_release_cmd);
+	} else
+		/* Tell other threads that SRR is in progress */
+		set_bit(QEDF_CMD_SRR_SENT, &orig_io_req->flags);
+
+	return rc;
+}
+
+static void qedf_initiate_seq_cleanup(struct qedf_ioreq *orig_io_req,
+	u32 offset, u8 r_ctl)
+{
+	struct qedf_rport *fcport;
+	unsigned long flags;
+	struct qedf_els_cb_arg *cb_arg;
+
+	fcport = orig_io_req->fcport;
+
+	QEDF_INFO(&(fcport->qedf->dbg_ctx), QEDF_LOG_ELS,
+	    "Doing sequence cleanup for xid=0x%x offset=%u.\n",
+	    orig_io_req->xid, offset);
+
+	cb_arg = kzalloc(sizeof(struct qedf_els_cb_arg), GFP_NOIO);
+	if (!cb_arg) {
+		QEDF_ERR(&(fcport->qedf->dbg_ctx), "Unable to allocate cb_arg "
+			  "for sequence cleanup\n");
+		return;
+	}
+
+	/* Get reference for cleanup request */
+	kref_get(&orig_io_req->refcount);
+
+	orig_io_req->cmd_type = QEDF_SEQ_CLEANUP;
+	cb_arg->offset = offset;
+	cb_arg->r_ctl = r_ctl;
+	orig_io_req->cb_arg = cb_arg;
+
+	qedf_cmd_timer_set(fcport->qedf, orig_io_req,
+	    QEDF_CLEANUP_TIMEOUT * HZ);
+
+	spin_lock_irqsave(&fcport->rport_lock, flags);
+
+	qedf_add_to_sq(fcport, orig_io_req->xid, 0,
+	    FCOE_TASK_TYPE_SEQUENCE_CLEANUP, offset);
+	qedf_ring_doorbell(fcport);
+
+	spin_unlock_irqrestore(&fcport->rport_lock, flags);
+}
+
+void qedf_process_seq_cleanup_compl(struct qedf_ctx *qedf,
+	struct fcoe_cqe *cqe, struct qedf_ioreq *io_req)
+{
+	int rc;
+	struct qedf_els_cb_arg *cb_arg;
+
+	cb_arg = io_req->cb_arg;
+
+	/* If we timed out just free resources */
+	if (io_req->event == QEDF_IOREQ_EV_ELS_TMO || !cqe)
+		goto free;
+
+	/* Kill the timer we put on the request */
+	cancel_delayed_work_sync(&io_req->timeout_work);
+
+	rc = qedf_send_srr(io_req, cb_arg->offset, cb_arg->r_ctl);
+	if (rc)
+		QEDF_ERR(&(qedf->dbg_ctx), "Unable to send SRR, I/O will "
+		    "abort, xid=0x%x.\n", io_req->xid);
+free:
+	kfree(cb_arg);
+	kref_put(&io_req->refcount, qedf_release_cmd);
+}
+
+static bool qedf_requeue_io_req(struct qedf_ioreq *orig_io_req)
+{
+	struct qedf_rport *fcport;
+	struct qedf_ioreq *new_io_req;
+	unsigned long flags;
+	bool rc = false;
+
+	fcport = orig_io_req->fcport;
+	if (!fcport) {
+		QEDF_ERR(NULL, "fcport is NULL.\n");
+		goto out;
+	}
+
+	if (!orig_io_req->sc_cmd) {
+		QEDF_ERR(&(fcport->qedf->dbg_ctx), "sc_cmd is NULL for "
+		    "xid=0x%x.\n", orig_io_req->xid);
+		goto out;
+	}
+
+	new_io_req = qedf_alloc_cmd(fcport, QEDF_SCSI_CMD);
+	if (!new_io_req) {
+		QEDF_ERR(&(fcport->qedf->dbg_ctx), "Could not allocate new "
+		    "io_req.\n");
+		goto out;
+	}
+
+	new_io_req->sc_cmd = orig_io_req->sc_cmd;
+
+	/*
+	 * This keeps the sc_cmd struct from being returned to the tape
+	 * driver and being requeued twice. We do need to put a reference
+	 * for the original I/O request since we will not do a SCSI completion
+	 * for it.
+	 */
+	orig_io_req->sc_cmd = NULL;
+	kref_put(&orig_io_req->refcount, qedf_release_cmd);
+
+	spin_lock_irqsave(&fcport->rport_lock, flags);
+
+	/* kref for new command released in qedf_post_io_req on error */
+	if (qedf_post_io_req(fcport, new_io_req)) {
+		QEDF_ERR(&(fcport->qedf->dbg_ctx), "Unable to post io_req\n");
+		/* Return SQE to pool */
+		atomic_inc(&fcport->free_sqes);
+	} else {
+		QEDF_INFO(&(fcport->qedf->dbg_ctx), QEDF_LOG_ELS,
+		    "Reissued SCSI command from  orig_xid=0x%x on "
+		    "new_xid=0x%x.\n", orig_io_req->xid, new_io_req->xid);
+		/*
+		 * Abort the original I/O but do not return SCSI command as
+		 * it has been reissued on another OX_ID.
+		 */
+		spin_unlock_irqrestore(&fcport->rport_lock, flags);
+		qedf_initiate_abts(orig_io_req, false);
+		goto out;
+	}
+
+	spin_unlock_irqrestore(&fcport->rport_lock, flags);
+out:
+	return rc;
+}
+
+
+static void qedf_rec_compl(struct qedf_els_cb_arg *cb_arg)
+{
+	struct qedf_ioreq *orig_io_req;
+	struct qedf_ioreq *rec_req;
+	struct qedf_mp_req *mp_req;
+	struct fc_frame_header *mp_fc_hdr, *fh;
+	struct fc_frame *fp;
+	void *resp_buf, *fc_payload;
+	u32 resp_len;
+	struct fc_lport *lport;
+	struct qedf_ctx *qedf;
+	int refcount;
+	enum fc_rctl r_ctl;
+	struct fc_els_ls_rjt *rjt;
+	struct fc_els_rec_acc *acc;
+	u8 opcode;
+	u32 offset, e_stat;
+	struct scsi_cmnd *sc_cmd;
+	bool srr_needed = false;
+
+	rec_req = cb_arg->io_req;
+	qedf = rec_req->fcport->qedf;
+	lport = qedf->lport;
+
+	orig_io_req = cb_arg->aborted_io_req;
+
+	if (!orig_io_req)
+		goto out_free;
+
+	if (rec_req->event != QEDF_IOREQ_EV_ELS_TMO &&
+	    rec_req->event != QEDF_IOREQ_EV_ELS_ERR_DETECT)
+		cancel_delayed_work_sync(&orig_io_req->timeout_work);
+
+	refcount = atomic_read(&orig_io_req->refcount.refcount);
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "Entered: orig_io=%p,"
+		   " orig_io_xid=0x%x, rec_xid=0x%x, refcount=%d\n",
+		   orig_io_req, orig_io_req->xid, rec_req->xid, refcount);
+
+	/* If a REC times out, free resources */
+	if (rec_req->event == QEDF_IOREQ_EV_ELS_TMO)
+		goto out_free;
+
+	/* Normalize response data into struct fc_frame */
+	mp_req = &(rec_req->mp_req);
+	mp_fc_hdr = &(mp_req->resp_fc_hdr);
+	resp_len = mp_req->resp_len;
+	acc = resp_buf = mp_req->resp_buf;
+
+	fp = fc_frame_alloc(lport, resp_len);
+	if (!fp) {
+		QEDF_ERR(&(qedf->dbg_ctx),
+		    "fc_frame_alloc failure.\n");
+		goto out_free;
+	}
+
+	/* Copy frame header from firmware into fp */
+	fh = (struct fc_frame_header *)fc_frame_header_get(fp);
+	memcpy(fh, mp_fc_hdr, sizeof(struct fc_frame_header));
+
+	/* Copy payload from firmware into fp */
+	fc_payload = fc_frame_payload_get(fp, resp_len);
+	memcpy(fc_payload, resp_buf, resp_len);
+
+	opcode = fc_frame_payload_op(fp);
+	if (opcode == ELS_LS_RJT) {
+		rjt = fc_frame_payload_get(fp, sizeof(*rjt));
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+		    "Received LS_RJT for REC: er_reason=0x%x, "
+		    "er_explan=0x%x.\n", rjt->er_reason, rjt->er_explan);
+		/*
+		 * The following response(s) mean that we need to reissue the
+		 * request on another exchange.  We need to do this without
+		 * informing the upper layers lest it cause an application
+		 * error.
+		 */
+		if ((rjt->er_reason == ELS_RJT_LOGIC ||
+		    rjt->er_reason == ELS_RJT_UNAB) &&
+		    rjt->er_explan == ELS_EXPL_OXID_RXID) {
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+			    "Handle CMD LOST case.\n");
+			qedf_requeue_io_req(orig_io_req);
+		}
+	} else if (opcode == ELS_LS_ACC) {
+		offset = ntohl(acc->reca_fc4value);
+		e_stat = ntohl(acc->reca_e_stat);
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+		    "Received LS_ACC for REC: offset=0x%x, e_stat=0x%x.\n",
+		    offset, e_stat);
+		if (e_stat & ESB_ST_SEQ_INIT)  {
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+			    "Target has the seq init\n");
+			goto out_free_frame;
+		}
+		sc_cmd = orig_io_req->sc_cmd;
+		if (!sc_cmd) {
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+			    "sc_cmd is NULL for xid=0x%x.\n",
+			    orig_io_req->xid);
+			goto out_free_frame;
+		}
+		/* SCSI write case */
+		if (sc_cmd->sc_data_direction == DMA_TO_DEVICE) {
+			if (offset == orig_io_req->data_xfer_len) {
+				QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+				    "WRITE - response lost.\n");
+				r_ctl = FC_RCTL_DD_CMD_STATUS;
+				srr_needed = true;
+				offset = 0;
+			} else {
+				QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+				    "WRITE - XFER_RDY/DATA lost.\n");
+				r_ctl = FC_RCTL_DD_DATA_DESC;
+				/* Use data from warning CQE instead of REC */
+				offset = orig_io_req->tx_buf_off;
+			}
+		/* SCSI read case */
+		} else {
+			if (orig_io_req->rx_buf_off ==
+			    orig_io_req->data_xfer_len) {
+				QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+				    "READ - response lost.\n");
+				srr_needed = true;
+				r_ctl = FC_RCTL_DD_CMD_STATUS;
+				offset = 0;
+			} else {
+				QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+				    "READ - DATA lost.\n");
+				/*
+				 * For read case we always set the offset to 0
+				 * for sequence recovery task.
+				 */
+				offset = 0;
+				r_ctl = FC_RCTL_DD_SOL_DATA;
+			}
+		}
+
+		if (srr_needed)
+			qedf_send_srr(orig_io_req, offset, r_ctl);
+		else
+			qedf_initiate_seq_cleanup(orig_io_req, offset, r_ctl);
+	}
+
+out_free_frame:
+	fc_frame_free(fp);
+out_free:
+	/* Put reference for original command since REC completed */
+	kref_put(&orig_io_req->refcount, qedf_release_cmd);
+	kfree(cb_arg);
+}
+
+/* Assumes kref is already held by caller */
+int qedf_send_rec(struct qedf_ioreq *orig_io_req)
+{
+
+	struct fc_els_rec rec;
+	struct qedf_rport *fcport;
+	struct fc_lport *lport;
+	struct qedf_els_cb_arg *cb_arg = NULL;
+	struct qedf_ctx *qedf;
+	uint32_t sid;
+	uint32_t r_a_tov;
+	int rc;
+
+	if (!orig_io_req) {
+		QEDF_ERR(NULL, "orig_io_req is NULL.\n");
+		return -EINVAL;
+	}
+
+	fcport = orig_io_req->fcport;
+
+	/* Check that fcport is still offloaded */
+	if (!test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags)) {
+		QEDF_ERR(NULL, "fcport is no longer offloaded.\n");
+		return -EINVAL;
+	}
+
+	if (!fcport->qedf) {
+		QEDF_ERR(NULL, "fcport->qedf is NULL.\n");
+		return -EINVAL;
+	}
+
+	/* Take reference until REC command completion */
+	kref_get(&orig_io_req->refcount);
+
+	qedf = fcport->qedf;
+	lport = qedf->lport;
+	sid = fcport->sid;
+	r_a_tov = lport->r_a_tov;
+
+	memset(&rec, 0, sizeof(rec));
+
+	cb_arg = kzalloc(sizeof(struct qedf_els_cb_arg), GFP_NOIO);
+	if (!cb_arg) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Unable to allocate cb_arg for "
+			  "REC\n");
+		rc = -ENOMEM;
+		goto rec_err;
+	}
+
+	cb_arg->aborted_io_req = orig_io_req;
+
+	rec.rec_cmd = ELS_REC;
+	hton24(rec.rec_s_id, sid);
+	rec.rec_ox_id = htons(orig_io_req->xid);
+	rec.rec_rx_id =
+	    htons(orig_io_req->task->tstorm_st_context.read_write.rx_id);
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS, "Sending REC orig_io=%p, "
+	   "orig_xid=0x%x rx_id=0x%x\n", orig_io_req,
+	   orig_io_req->xid, rec.rec_rx_id);
+	rc = qedf_initiate_els(fcport, ELS_REC, &rec, sizeof(rec),
+	    qedf_rec_compl, cb_arg, r_a_tov);
+
+rec_err:
+	if (rc) {
+		QEDF_ERR(&(qedf->dbg_ctx), "REC failed - release orig_io_req"
+			  "=0x%x\n", orig_io_req->xid);
+		kfree(cb_arg);
+		kref_put(&orig_io_req->refcount, qedf_release_cmd);
+	}
+	return rc;
+}
diff --git a/drivers/scsi/qedf/qedf_fip.c b/drivers/scsi/qedf/qedf_fip.c
new file mode 100644
index 0000000..868d423
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_fip.c
@@ -0,0 +1,269 @@
+/*
+ *  QLogic FCoE Offload Driver
+ *  Copyright (c) 2016 Cavium Inc.
+ *
+ *  This software is available under the terms of the GNU General Public License
+ *  (GPL) Version 2, available from the file COPYING in the main directory of
+ *  this source tree.
+ */
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include "qedf.h"
+
+extern const struct qed_fcoe_ops *qed_ops;
+/*
+ * FIP VLAN functions that will eventually move to libfcoe.
+ */
+
+void qedf_fcoe_send_vlan_req(struct qedf_ctx *qedf)
+{
+	struct sk_buff *skb;
+	char *eth_fr;
+	int fr_len;
+	struct fip_vlan *vlan;
+#define MY_FIP_ALL_FCF_MACS        ((__u8[6]) { 1, 0x10, 0x18, 1, 0, 2 })
+	static u8 my_fcoe_all_fcfs[ETH_ALEN] = MY_FIP_ALL_FCF_MACS;
+
+	skb = dev_alloc_skb(sizeof(struct fip_vlan));
+	if (!skb)
+		return;
+
+	fr_len = sizeof(*vlan);
+	eth_fr = (char *)skb->data;
+	vlan = (struct fip_vlan *)eth_fr;
+
+	memset(vlan, 0, sizeof(*vlan));
+	ether_addr_copy(vlan->eth.h_source, qedf->mac);
+	ether_addr_copy(vlan->eth.h_dest, my_fcoe_all_fcfs);
+	vlan->eth.h_proto = htons(ETH_P_FIP);
+
+	vlan->fip.fip_ver = FIP_VER_ENCAPS(FIP_VER);
+	vlan->fip.fip_op = htons(FIP_OP_VLAN);
+	vlan->fip.fip_subcode = FIP_SC_VL_REQ;
+	vlan->fip.fip_dl_len = htons(sizeof(vlan->desc) / FIP_BPW);
+
+	vlan->desc.mac.fd_desc.fip_dtype = FIP_DT_MAC;
+	vlan->desc.mac.fd_desc.fip_dlen = sizeof(vlan->desc.mac) / FIP_BPW;
+	ether_addr_copy(vlan->desc.mac.fd_mac, qedf->mac);
+
+	vlan->desc.wwnn.fd_desc.fip_dtype = FIP_DT_NAME;
+	vlan->desc.wwnn.fd_desc.fip_dlen = sizeof(vlan->desc.wwnn) / FIP_BPW;
+	put_unaligned_be64(qedf->lport->wwnn, &vlan->desc.wwnn.fd_wwn);
+
+	skb_put(skb, sizeof(*vlan));
+	skb->protocol = htons(ETH_P_FIP);
+	skb_reset_mac_header(skb);
+	skb_reset_network_header(skb);
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "Sending FIP VLAN "
+		   "request.");
+
+	if (atomic_read(&qedf->link_state) != QEDF_LINK_UP) {
+		QEDF_WARN(&(qedf->dbg_ctx), "Cannot send vlan request "
+		    "because link is not up.\n");
+
+		kfree_skb(skb);
+		return;
+	}
+	qed_ops->ll2->start_xmit(qedf->cdev, skb);
+}
+
+static void qedf_fcoe_process_vlan_resp(struct qedf_ctx *qedf,
+	struct sk_buff *skb)
+{
+	struct fip_header *fiph;
+	struct fip_desc *desc;
+	u16 vid = 0;
+	ssize_t rlen;
+	size_t dlen;
+
+	fiph = (struct fip_header *)(((void *)skb->data) + 2 * ETH_ALEN + 2);
+
+	rlen = ntohs(fiph->fip_dl_len) * 4;
+	desc = (struct fip_desc *)(fiph + 1);
+	while (rlen > 0) {
+		dlen = desc->fip_dlen * FIP_BPW;
+		switch (desc->fip_dtype) {
+		case FIP_DT_VLAN:
+			vid = ntohs(((struct fip_vlan_desc *)desc)->fd_vlan);
+			break;
+		}
+		desc = (struct fip_desc *)((char *)desc + dlen);
+		rlen -= dlen;
+	}
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "VLAN response, "
+		   "vid=0x%x.\n", vid);
+
+	if (vid > 0 && qedf->vlan_id != vid) {
+		qedf_set_vlan_id(qedf, vid);
+
+		/* Inform waiter that it's ok to call fcoe_ctlr_link up() */
+		complete(&qedf->fipvlan_compl);
+	}
+}
+
+void qedf_fip_send(struct fcoe_ctlr *fip, struct sk_buff *skb)
+{
+	struct qedf_ctx *qedf = container_of(fip, struct qedf_ctx, ctlr);
+	struct ethhdr *eth_hdr;
+	struct vlan_ethhdr *vlan_hdr;
+	struct fip_header *fiph;
+	u16 op, vlan_tci = 0;
+	u8 sub;
+
+	if (!test_bit(QEDF_LL2_STARTED, &qedf->flags)) {
+		QEDF_WARN(&(qedf->dbg_ctx), "LL2 not started\n");
+		kfree_skb(skb);
+		return;
+	}
+
+	fiph = (struct fip_header *) ((void *)skb->data + 2 * ETH_ALEN + 2);
+	eth_hdr = (struct ethhdr *)skb_mac_header(skb);
+	op = ntohs(fiph->fip_op);
+	sub = fiph->fip_subcode;
+
+	if (!qedf->vlan_hw_insert) {
+		vlan_hdr = (struct vlan_ethhdr *)skb_push(skb, sizeof(*vlan_hdr)
+		    - sizeof(*eth_hdr));
+		memcpy(vlan_hdr, eth_hdr, 2 * ETH_ALEN);
+		vlan_hdr->h_vlan_proto = htons(ETH_P_8021Q);
+		vlan_hdr->h_vlan_encapsulated_proto = eth_hdr->h_proto;
+		vlan_hdr->h_vlan_TCI = vlan_tci =  htons(qedf->vlan_id);
+	}
+
+	/* Update eth_hdr since we added a VLAN tag */
+	eth_hdr = (struct ethhdr *)skb_mac_header(skb);
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_LL2, "FIP frame send: "
+	    "dest=%pM op=%x sub=%x vlan=%04x.", eth_hdr->h_dest, op, sub,
+	    ntohs(vlan_tci));
+	if (qedf_dump_frames)
+		print_hex_dump(KERN_WARNING, "fip ", DUMP_PREFIX_OFFSET, 16, 1,
+		    skb->data, skb->len, false);
+
+	qed_ops->ll2->start_xmit(qedf->cdev, skb);
+}
+
+/* Process incoming FIP frames. */
+void qedf_fip_recv(struct qedf_ctx *qedf, struct sk_buff *skb)
+{
+	struct ethhdr *eth_hdr;
+	struct fip_header *fiph;
+	struct fip_desc *desc;
+	struct fip_mac_desc *mp;
+	struct fip_wwn_desc *wp;
+	struct fip_vn_desc *vp;
+	size_t rlen, dlen;
+	uint32_t cvl_port_id;
+	__u8 cvl_mac[ETH_ALEN];
+	u16 op;
+	u8 sub;
+
+	eth_hdr = (struct ethhdr *)skb_mac_header(skb);
+	fiph = (struct fip_header *) ((void *)skb->data + 2 * ETH_ALEN + 2);
+	op = ntohs(fiph->fip_op);
+	sub = fiph->fip_subcode;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_LL2, "FIP frame received: "
+	    "skb=%p fiph=%p source=%pM op=%x sub=%x", skb, fiph,
+	    eth_hdr->h_source, op, sub);
+	if (qedf_dump_frames)
+		print_hex_dump(KERN_WARNING, "fip ", DUMP_PREFIX_OFFSET, 16, 1,
+		    skb->data, skb->len, false);
+
+	/* Handle FIP VLAN resp in the driver */
+	if (op == FIP_OP_VLAN && sub == FIP_SC_VL_NOTE) {
+		qedf_fcoe_process_vlan_resp(qedf, skb);
+		qedf->vlan_hw_insert = 0;
+		kfree_skb(skb);
+	} else if (op == FIP_OP_CTRL && sub == FIP_SC_CLR_VLINK) {
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "Clear virtual "
+			   "link received.\n");
+
+		/* Check that an FCF has been selected by fcoe */
+		if (qedf->ctlr.sel_fcf == NULL) {
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+			    "Dropping CVL since FCF has not been selected "
+			    "yet.");
+			return;
+		}
+
+		cvl_port_id = 0;
+		memset(cvl_mac, 0, ETH_ALEN);
+		/*
+		 * We need to loop through the CVL descriptors to determine
+		 * if we want to reset the fcoe link
+		 */
+		rlen = ntohs(fiph->fip_dl_len) * FIP_BPW;
+		desc = (struct fip_desc *)(fiph + 1);
+		while (rlen >= sizeof(*desc)) {
+			dlen = desc->fip_dlen * FIP_BPW;
+			switch (desc->fip_dtype) {
+			case FIP_DT_MAC:
+				mp = (struct fip_mac_desc *)desc;
+				QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_LL2,
+				    "fd_mac=%pM.\n", __func__, mp->fd_mac);
+				ether_addr_copy(cvl_mac, mp->fd_mac);
+				break;
+			case FIP_DT_NAME:
+				wp = (struct fip_wwn_desc *)desc;
+				QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_LL2,
+				    "fc_wwpn=%016llx.\n",
+				    get_unaligned_be64(&wp->fd_wwn));
+				break;
+			case FIP_DT_VN_ID:
+				vp = (struct fip_vn_desc *)desc;
+				QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_LL2,
+				    "fd_fc_id=%x.\n", ntoh24(vp->fd_fc_id));
+				cvl_port_id = ntoh24(vp->fd_fc_id);
+				break;
+			default:
+				/* Ignore anything else */
+				break;
+			}
+			desc = (struct fip_desc *)((char *)desc + dlen);
+			rlen -= dlen;
+		}
+
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_LL2,
+		    "cvl_port_id=%06x cvl_mac=%pM.\n", cvl_port_id,
+		    cvl_mac);
+		if (cvl_port_id == qedf->lport->port_id &&
+		    ether_addr_equal(cvl_mac,
+		    qedf->ctlr.sel_fcf->fcf_mac)) {
+			fcoe_ctlr_link_down(&qedf->ctlr);
+			qedf_wait_for_upload(qedf);
+			fcoe_ctlr_link_up(&qedf->ctlr);
+		}
+		kfree_skb(skb);
+	} else {
+		/* Everything else is handled by libfcoe */
+		__skb_pull(skb, ETH_HLEN);
+		fcoe_ctlr_recv(&qedf->ctlr, skb);
+	}
+}
+
+void qedf_update_src_mac(struct fc_lport *lport, u8 *addr)
+{
+	struct qedf_ctx *qedf = lport_priv(lport);
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC,
+	    "Setting data_src_addr=%pM.\n", addr);
+	ether_addr_copy(qedf->data_src_addr, addr);
+}
+
+u8 *qedf_get_src_mac(struct fc_lport *lport)
+{
+	u8 mac[ETH_ALEN];
+	u8 port_id[3];
+	struct qedf_ctx *qedf = lport_priv(lport);
+
+	/* We need to use the lport port_id to create the data_src_addr */
+	if (is_zero_ether_addr(qedf->data_src_addr)) {
+		hton24(port_id, lport->port_id);
+		fc_fcoe_set_mac(mac, port_id);
+		qedf->ctlr.update_mac(lport, mac);
+	}
+	return qedf->data_src_addr;
+}
diff --git a/drivers/scsi/qedf/qedf_hsi.h b/drivers/scsi/qedf/qedf_hsi.h
new file mode 100644
index 0000000..dfd65de
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_hsi.h
@@ -0,0 +1,422 @@
+/*
+ *  QLogic FCoE Offload Driver
+ *  Copyright (c) 2016 Cavium Inc.
+ *
+ *  This software is available under the terms of the GNU General Public License
+ *  (GPL) Version 2, available from the file COPYING in the main directory of
+ *  this source tree.
+ */
+#ifndef __QEDF_HSI__
+#define __QEDF_HSI__
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
+ * Add include to common fcoe target for both eCore and protocol driver
+ */
+#include <linux/qed/fcoe_common.h>
+
+
+/*
+ * FCoE CQ element ABTS information
+ */
+struct fcoe_abts_info {
+	u8 r_ctl /* R_CTL in the ABTS response frame */;
+	u8 reserved0;
+	__le16 rx_id;
+	__le32 reserved2[2];
+	__le32 fc_payload[3] /* ABTS FC payload response frame */;
+};
+
+
+/*
+ * FCoE class type
+ */
+enum fcoe_class_type {
+	FCOE_TASK_CLASS_TYPE_3,
+	FCOE_TASK_CLASS_TYPE_2,
+	MAX_FCOE_CLASS_TYPE
+};
+
+
+/*
+ * FCoE CMDQ element control information
+ */
+struct fcoe_cmdqe_control {
+	__le16 conn_id;
+	u8 num_additional_cmdqes;
+	u8 cmdType;
+	/* true for ABTS request cmdqe. used in Target mode */
+#define FCOE_CMDQE_CONTROL_ABTSREQCMD_MASK  0x1
+#define FCOE_CMDQE_CONTROL_ABTSREQCMD_SHIFT 0
+#define FCOE_CMDQE_CONTROL_RESERVED1_MASK   0x7F
+#define FCOE_CMDQE_CONTROL_RESERVED1_SHIFT  1
+	u8 reserved2[4];
+};
+
+/*
+ * FCoE control + payload CMDQ element
+ */
+struct fcoe_cmdqe {
+	struct fcoe_cmdqe_control hdr;
+	u8 fc_header[24];
+	__le32 fcp_cmd_payload[8];
+};
+
+
+
+/*
+ * FCP RSP flags
+ */
+struct fcoe_fcp_rsp_flags {
+	u8 flags;
+#define FCOE_FCP_RSP_FLAGS_FCP_RSP_LEN_VALID_MASK  0x1
+#define FCOE_FCP_RSP_FLAGS_FCP_RSP_LEN_VALID_SHIFT 0
+#define FCOE_FCP_RSP_FLAGS_FCP_SNS_LEN_VALID_MASK  0x1
+#define FCOE_FCP_RSP_FLAGS_FCP_SNS_LEN_VALID_SHIFT 1
+#define FCOE_FCP_RSP_FLAGS_FCP_RESID_OVER_MASK     0x1
+#define FCOE_FCP_RSP_FLAGS_FCP_RESID_OVER_SHIFT    2
+#define FCOE_FCP_RSP_FLAGS_FCP_RESID_UNDER_MASK    0x1
+#define FCOE_FCP_RSP_FLAGS_FCP_RESID_UNDER_SHIFT   3
+#define FCOE_FCP_RSP_FLAGS_FCP_CONF_REQ_MASK       0x1
+#define FCOE_FCP_RSP_FLAGS_FCP_CONF_REQ_SHIFT      4
+#define FCOE_FCP_RSP_FLAGS_FCP_BIDI_FLAGS_MASK     0x7
+#define FCOE_FCP_RSP_FLAGS_FCP_BIDI_FLAGS_SHIFT    5
+};
+
+/*
+ * FCoE CQ element response information
+ */
+struct fcoe_cqe_rsp_info {
+	struct fcoe_fcp_rsp_flags rsp_flags;
+	u8 scsi_status_code;
+	__le16 retry_delay_timer;
+	__le32 fcp_resid;
+	__le32 fcp_sns_len;
+	__le32 fcp_rsp_len;
+	__le16 rx_id;
+	u8 fw_error_flags;
+#define FCOE_CQE_RSP_INFO_FW_UNDERRUN_MASK  0x1 /* FW detected underrun */
+#define FCOE_CQE_RSP_INFO_FW_UNDERRUN_SHIFT 0
+#define FCOE_CQE_RSP_INFO_RESREVED_MASK     0x7F
+#define FCOE_CQE_RSP_INFO_RESREVED_SHIFT    1
+	u8 reserved;
+	__le32 fw_residual /* Residual bytes calculated by FW */;
+};
+
+/*
+ * FCoE CQ element Target completion information
+ */
+struct fcoe_cqe_target_info {
+	__le16 rx_id;
+	__le16 reserved0;
+	__le32 reserved1[5];
+};
+
+/*
+ * FCoE error/warning reporting entry
+ */
+struct fcoe_err_report_entry {
+	__le32 err_warn_bitmap_lo /* Error bitmap lower 32 bits */;
+	__le32 err_warn_bitmap_hi /* Error bitmap higher 32 bits */;
+	/* Buffer offset the beginning of the Sequence last transmitted */
+	__le32 tx_buf_off;
+	/* Buffer offset from the beginning of the Sequence last received */
+	__le32 rx_buf_off;
+	__le16 rx_id /* RX_ID of the associated task */;
+	__le16 reserved1;
+	__le32 reserved2;
+};
+
+/*
+ * FCoE CQ element middle path information
+ */
+struct fcoe_cqe_midpath_info {
+	__le32 data_placement_size;
+	__le16 rx_id;
+	__le16 reserved0;
+	__le32 reserved1[4];
+};
+
+/*
+ * FCoE CQ element unsolicited information
+ */
+struct fcoe_unsolic_info {
+	/* BD information: Physical address and opaque data */
+	struct scsi_bd bd_info;
+	__le16 conn_id /* Connection ID the frame is associated to */;
+	__le16 pkt_len /* Packet length */;
+	u8 reserved1[4];
+};
+
+/*
+ * FCoE warning reporting entry
+ */
+struct fcoe_warning_report_entry {
+	/* BD information: Physical address and opaque data */
+	struct scsi_bd bd_info;
+	/* Buffer offset the beginning of the Sequence last transmitted */
+	__le32 buf_off;
+	__le16 rx_id /* RX_ID of the associated task */;
+	__le16 reserved1;
+};
+
+/*
+ * FCoE CQ element information
+ */
+union fcoe_cqe_info {
+	struct fcoe_cqe_rsp_info rsp_info /* Response completion information */;
+	/* Target completion information */
+	struct fcoe_cqe_target_info target_info;
+	/* Error completion information */
+	struct fcoe_err_report_entry err_info;
+	struct fcoe_abts_info abts_info /* ABTS completion information */;
+	/* Middle path completion information */
+	struct fcoe_cqe_midpath_info midpath_info;
+	/* Unsolicited packet completion information */
+	struct fcoe_unsolic_info unsolic_info;
+	/* Warning completion information (Rec Tov expiration) */
+	struct fcoe_warning_report_entry warn_info;
+};
+
+/*
+ * FCoE CQ element
+ */
+struct fcoe_cqe {
+	__le32 cqe_data;
+	/* The task identifier (OX_ID) to be completed */
+#define FCOE_CQE_TASK_ID_MASK    0xFFFF
+#define FCOE_CQE_TASK_ID_SHIFT   0
+	/*
+	 * The CQE type: 0x0 Indicating on a pending work request completion.
+	 * 0x1 - Indicating on an unsolicited event notification. use enum
+	 * fcoe_cqe_type  (use enum fcoe_cqe_type)
+	 */
+#define FCOE_CQE_CQE_TYPE_MASK   0xF
+#define FCOE_CQE_CQE_TYPE_SHIFT  16
+#define FCOE_CQE_RESERVED0_MASK  0xFFF
+#define FCOE_CQE_RESERVED0_SHIFT 20
+	__le16 reserved1;
+	__le16 fw_cq_prod;
+	union fcoe_cqe_info cqe_info;
+};
+
+/*
+ * FCoE CQE type
+ */
+enum fcoe_cqe_type {
+	/* solicited response on a R/W or middle-path SQE */
+	FCOE_GOOD_COMPLETION_CQE_TYPE,
+	FCOE_UNSOLIC_CQE_TYPE /* unsolicited packet, RQ consumed */,
+	FCOE_ERROR_DETECTION_CQE_TYPE /* timer expiration, validation error */,
+	FCOE_WARNING_CQE_TYPE /* rec_tov or rr_tov timer expiration */,
+	FCOE_EXCH_CLEANUP_CQE_TYPE /* task cleanup completed */,
+	FCOE_ABTS_CQE_TYPE /* ABTS received and task cleaned */,
+	FCOE_DUMMY_CQE_TYPE /* just increment SQ CONS */,
+	/* Task was completed wight after sending a pkt to the target */
+	FCOE_LOCAL_COMP_CQE_TYPE,
+	MAX_FCOE_CQE_TYPE
+};
+
+
+/*
+ * FCoE device type
+ */
+enum fcoe_device_type {
+	FCOE_TASK_DEV_TYPE_DISK,
+	FCOE_TASK_DEV_TYPE_TAPE,
+	MAX_FCOE_DEVICE_TYPE
+};
+
+
+
+
+/*
+ * FCoE fast path error codes
+ */
+enum fcoe_fp_error_warning_code {
+	FCOE_ERROR_CODE_XFER_OOO_RO /* XFER error codes */,
+	FCOE_ERROR_CODE_XFER_RO_NOT_ALIGNED,
+	FCOE_ERROR_CODE_XFER_NULL_BURST_LEN,
+	FCOE_ERROR_CODE_XFER_RO_GREATER_THAN_DATA2TRNS,
+	FCOE_ERROR_CODE_XFER_INVALID_PAYLOAD_SIZE,
+	FCOE_ERROR_CODE_XFER_TASK_TYPE_NOT_WRITE,
+	FCOE_ERROR_CODE_XFER_PEND_XFER_SET,
+	FCOE_ERROR_CODE_XFER_OPENED_SEQ,
+	FCOE_ERROR_CODE_XFER_FCTL,
+	FCOE_ERROR_CODE_FCP_RSP_BIDI_FLAGS_SET /* FCP RSP error codes */,
+	FCOE_ERROR_CODE_FCP_RSP_INVALID_LENGTH_FIELD,
+	FCOE_ERROR_CODE_FCP_RSP_INVALID_SNS_FIELD,
+	FCOE_ERROR_CODE_FCP_RSP_INVALID_PAYLOAD_SIZE,
+	FCOE_ERROR_CODE_FCP_RSP_PEND_XFER_SET,
+	FCOE_ERROR_CODE_FCP_RSP_OPENED_SEQ,
+	FCOE_ERROR_CODE_FCP_RSP_FCTL,
+	FCOE_ERROR_CODE_FCP_RSP_LAST_SEQ_RESET,
+	FCOE_ERROR_CODE_FCP_RSP_CONF_REQ_NOT_SUPPORTED_YET,
+	FCOE_ERROR_CODE_DATA_OOO_RO /* FCP DATA error codes */,
+	FCOE_ERROR_CODE_DATA_EXCEEDS_DEFINED_MAX_FRAME_SIZE,
+	FCOE_ERROR_CODE_DATA_EXCEEDS_DATA2TRNS,
+	FCOE_ERROR_CODE_DATA_SOFI3_SEQ_ACTIVE_SET,
+	FCOE_ERROR_CODE_DATA_SOFN_SEQ_ACTIVE_RESET,
+	FCOE_ERROR_CODE_DATA_EOFN_END_SEQ_SET,
+	FCOE_ERROR_CODE_DATA_EOFT_END_SEQ_RESET,
+	FCOE_ERROR_CODE_DATA_TASK_TYPE_NOT_READ,
+	FCOE_ERROR_CODE_DATA_FCTL_INITIATIR,
+	FCOE_ERROR_CODE_MIDPATH_INVALID_TYPE /* Middle path error codes */,
+	FCOE_ERROR_CODE_MIDPATH_SOFI3_SEQ_ACTIVE_SET,
+	FCOE_ERROR_CODE_MIDPATH_SOFN_SEQ_ACTIVE_RESET,
+	FCOE_ERROR_CODE_MIDPATH_EOFN_END_SEQ_SET,
+	FCOE_ERROR_CODE_MIDPATH_EOFT_END_SEQ_RESET,
+	FCOE_ERROR_CODE_MIDPATH_REPLY_FCTL,
+	FCOE_ERROR_CODE_MIDPATH_INVALID_REPLY,
+	FCOE_ERROR_CODE_MIDPATH_ELS_REPLY_RCTL,
+	FCOE_ERROR_CODE_COMMON_MIDDLE_FRAME_WITH_PAD /* Common error codes */,
+	FCOE_ERROR_CODE_COMMON_SEQ_INIT_IN_TCE,
+	FCOE_ERROR_CODE_COMMON_FC_HDR_RX_ID_MISMATCH,
+	FCOE_ERROR_CODE_COMMON_INCORRECT_SEQ_CNT,
+	FCOE_ERROR_CODE_COMMON_DATA_FC_HDR_FCP_TYPE_MISMATCH,
+	FCOE_ERROR_CODE_COMMON_DATA_NO_MORE_SGES,
+	FCOE_ERROR_CODE_COMMON_OPTIONAL_FC_HDR,
+	FCOE_ERROR_CODE_COMMON_READ_TCE_OX_ID_TOO_BIG,
+	FCOE_ERROR_CODE_COMMON_DATA_WAS_NOT_TRANSMITTED,
+	FCOE_ERROR_CODE_COMMON_TASK_DDF_RCTL_INFO_FIELD,
+	FCOE_ERROR_CODE_COMMON_TASK_INVALID_RCTL,
+	FCOE_ERROR_CODE_COMMON_TASK_RCTL_GENERAL_MISMATCH,
+	FCOE_ERROR_CODE_E_D_TOV_TIMER_EXPIRATION /* Timer error codes */,
+	FCOE_WARNING_CODE_REC_TOV_TIMER_EXPIRATION /* Timer error codes */,
+	FCOE_ERROR_CODE_RR_TOV_TIMER_EXPIRATION /* Timer error codes */,
+	/* ABTSrsp pckt arrived unexpected */
+	FCOE_ERROR_CODE_ABTS_REPLY_UNEXPECTED,
+	FCOE_ERROR_CODE_TARGET_MODE_FCP_RSP,
+	FCOE_ERROR_CODE_TARGET_MODE_FCP_XFER,
+	FCOE_ERROR_CODE_TARGET_MODE_DATA_TASK_TYPE_NOT_WRITE,
+	FCOE_ERROR_CODE_DATA_FCTL_TARGET,
+	FCOE_ERROR_CODE_TARGET_DATA_SIZE_NO_MATCH_XFER,
+	FCOE_ERROR_CODE_TARGET_DIF_CRC_CHECKSUM_ERROR,
+	FCOE_ERROR_CODE_TARGET_DIF_REF_TAG_ERROR,
+	FCOE_ERROR_CODE_TARGET_DIF_APP_TAG_ERROR,
+	MAX_FCOE_FP_ERROR_WARNING_CODE
+};
+
+
+/*
+ * FCoE RESPQ element
+ */
+struct fcoe_respqe {
+	__le16 ox_id /* OX_ID that is located in the FCP_RSP FC header */;
+	__le16 rx_id /* RX_ID that is located in the FCP_RSP FC header */;
+	__le32 additional_info;
+/* PARAM that is located in the FCP_RSP FC header */
+#define FCOE_RESPQE_PARAM_MASK            0xFFFFFF
+#define FCOE_RESPQE_PARAM_SHIFT           0
+/* Indication whther its Target-auto-rsp mode or not */
+#define FCOE_RESPQE_TARGET_AUTO_RSP_MASK  0xFF
+#define FCOE_RESPQE_TARGET_AUTO_RSP_SHIFT 24
+};
+
+
+/*
+ * FCoE slow path error codes
+ */
+enum fcoe_sp_error_code {
+	/* Error codes for Error Reporting in slow path flows */
+	FCOE_ERROR_CODE_SLOW_PATH_TOO_MANY_FUNCS,
+	FCOE_ERROR_SLOW_PATH_CODE_NO_LICENSE,
+	MAX_FCOE_SP_ERROR_CODE
+};
+
+
+/*
+ * FCoE SQE request type
+ */
+enum fcoe_sqe_request_type {
+	SEND_FCOE_CMD,
+	SEND_FCOE_MIDPATH,
+	SEND_FCOE_ABTS_REQUEST,
+	FCOE_EXCHANGE_CLEANUP,
+	FCOE_SEQUENCE_RECOVERY,
+	SEND_FCOE_XFER_RDY,
+	SEND_FCOE_RSP,
+	SEND_FCOE_RSP_WITH_SENSE_DATA,
+	SEND_FCOE_TARGET_DATA,
+	SEND_FCOE_INITIATOR_DATA,
+	/*
+	 * Xfer Continuation (==1) ready to be sent. Previous XFERs data
+	 * received successfully.
+	 */
+	SEND_FCOE_XFER_CONTINUATION_RDY,
+	SEND_FCOE_TARGET_ABTS_RSP,
+	MAX_FCOE_SQE_REQUEST_TYPE
+};
+
+
+/*
+ * FCoE task TX state
+ */
+enum fcoe_task_tx_state {
+	/* Initiate state after driver has initialized the task */
+	FCOE_TASK_TX_STATE_NORMAL,
+	/* Updated by TX path after complete transmitting unsolicited packet */
+	FCOE_TASK_TX_STATE_UNSOLICITED_COMPLETED,
+	/*
+	 * Updated by TX path after start processing the task requesting the
+	 * cleanup/abort operation
+	 */
+	FCOE_TASK_TX_STATE_CLEAN_REQ,
+	FCOE_TASK_TX_STATE_ABTS /* Updated by TX path during abort procedure */,
+	/* Updated by TX path during exchange cleanup procedure */
+	FCOE_TASK_TX_STATE_EXCLEANUP,
+	/*
+	 * Updated by TX path during exchange cleanup continuation task
+	 * procedure
+	 */
+	FCOE_TASK_TX_STATE_EXCLEANUP_TARGET_WRITE_CONT,
+	/* Updated by TX path during exchange cleanup first xfer procedure */
+	FCOE_TASK_TX_STATE_EXCLEANUP_TARGET_WRITE,
+	/* Updated by TX path during exchange cleanup read task in Target */
+	FCOE_TASK_TX_STATE_EXCLEANUP_TARGET_READ_OR_RSP,
+	/* Updated by TX path during target exchange cleanup procedure */
+	FCOE_TASK_TX_STATE_EXCLEANUP_TARGET_WRITE_LAST_CYCLE,
+	/* Updated by TX path during sequence recovery procedure */
+	FCOE_TASK_TX_STATE_SEQRECOVERY,
+	MAX_FCOE_TASK_TX_STATE
+};
+
+
+/*
+ * FCoE task type
+ */
+enum fcoe_task_type {
+	FCOE_TASK_TYPE_WRITE_INITIATOR,
+	FCOE_TASK_TYPE_READ_INITIATOR,
+	FCOE_TASK_TYPE_MIDPATH,
+	FCOE_TASK_TYPE_UNSOLICITED,
+	FCOE_TASK_TYPE_ABTS,
+	FCOE_TASK_TYPE_EXCHANGE_CLEANUP,
+	FCOE_TASK_TYPE_SEQUENCE_CLEANUP,
+	FCOE_TASK_TYPE_WRITE_TARGET,
+	FCOE_TASK_TYPE_READ_TARGET,
+	FCOE_TASK_TYPE_RSP,
+	FCOE_TASK_TYPE_RSP_SENSE_DATA,
+	FCOE_TASK_TYPE_ABTS_TARGET,
+	FCOE_TASK_TYPE_ENUM_SIZE,
+	MAX_FCOE_TASK_TYPE
+};
+
+struct scsi_glbl_queue_entry {
+	/* Start physical address for the RQ (receive queue) PBL. */
+	struct regpair rq_pbl_addr;
+	/* Start physical address for the CQ (completion queue) PBL. */
+	struct regpair cq_pbl_addr;
+	/* Start physical address for the CMDQ (command queue) PBL. */
+	struct regpair cmdq_pbl_addr;
+};
+
+#endif /* __QEDF_HSI__ */
diff --git a/drivers/scsi/qedf/qedf_io.c b/drivers/scsi/qedf/qedf_io.c
new file mode 100644
index 0000000..486c045
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_io.c
@@ -0,0 +1,2282 @@
+/*
+ *  QLogic FCoE Offload Driver
+ *  Copyright (c) 2016 Cavium Inc.
+ *
+ *  This software is available under the terms of the GNU General Public License
+ *  (GPL) Version 2, available from the file COPYING in the main directory of
+ *  this source tree.
+ */
+#include <linux/spinlock.h>
+#include <linux/vmalloc.h>
+#include "qedf.h"
+#include <scsi/scsi_tcq.h>
+
+void qedf_cmd_timer_set(struct qedf_ctx *qedf, struct qedf_ioreq *io_req,
+	unsigned int timer_msec)
+{
+	queue_delayed_work(qedf->timer_work_queue, &io_req->timeout_work,
+	    msecs_to_jiffies(timer_msec));
+}
+
+static void qedf_cmd_timeout(struct work_struct *work)
+{
+
+	struct qedf_ioreq *io_req =
+	    container_of(work, struct qedf_ioreq, timeout_work.work);
+	struct qedf_ctx *qedf = io_req->fcport->qedf;
+	struct qedf_rport *fcport = io_req->fcport;
+	u8 op = 0;
+
+	switch (io_req->cmd_type) {
+	case QEDF_ABTS:
+		QEDF_ERR((&qedf->dbg_ctx), "ABTS timeout, xid=0x%x.\n",
+		    io_req->xid);
+		/* Cleanup timed out ABTS */
+		qedf_initiate_cleanup(io_req, true);
+		complete(&io_req->abts_done);
+
+		/*
+		 * Need to call kref_put for reference taken when initiate_abts
+		 * was called since abts_compl won't be called now that we've
+		 * cleaned up the task.
+		 */
+		kref_put(&io_req->refcount, qedf_release_cmd);
+
+		/*
+		 * Now that the original I/O and the ABTS are complete see
+		 * if we need to reconnect to the target.
+		 */
+		qedf_restart_rport(fcport);
+		break;
+	case QEDF_ELS:
+		kref_get(&io_req->refcount);
+		/*
+		 * Don't attempt to clean an ELS timeout as any subseqeunt
+		 * ABTS or cleanup requests just hang.  For now just free
+		 * the resources of the original I/O and the RRQ
+		 */
+		QEDF_ERR(&(qedf->dbg_ctx), "ELS timeout, xid=0x%x.\n",
+			  io_req->xid);
+		io_req->event = QEDF_IOREQ_EV_ELS_TMO;
+		/* Call callback function to complete command */
+		if (io_req->cb_func && io_req->cb_arg) {
+			op = io_req->cb_arg->op;
+			io_req->cb_func(io_req->cb_arg);
+			io_req->cb_arg = NULL;
+		}
+		qedf_initiate_cleanup(io_req, true);
+		kref_put(&io_req->refcount, qedf_release_cmd);
+		break;
+	case QEDF_SEQ_CLEANUP:
+		QEDF_ERR(&(qedf->dbg_ctx), "Sequence cleanup timeout, "
+		    "xid=0x%x.\n", io_req->xid);
+		qedf_initiate_cleanup(io_req, true);
+		io_req->event = QEDF_IOREQ_EV_ELS_TMO;
+		qedf_process_seq_cleanup_compl(qedf, NULL, io_req);
+		break;
+	default:
+		break;
+	}
+}
+
+void qedf_cmd_mgr_free(struct qedf_cmd_mgr *cmgr)
+{
+	struct io_bdt *bdt_info;
+	struct qedf_ctx *qedf = cmgr->qedf;
+	size_t bd_tbl_sz;
+	u16 min_xid = QEDF_MIN_XID;
+	u16 max_xid = (FCOE_PARAMS_NUM_TASKS - 1);
+	int num_ios;
+	int i;
+	struct qedf_ioreq *io_req;
+
+	num_ios = max_xid - min_xid + 1;
+
+	/* Free fcoe_bdt_ctx structures */
+	if (!cmgr->io_bdt_pool)
+		goto free_cmd_pool;
+
+	bd_tbl_sz = QEDF_MAX_BDS_PER_CMD * sizeof(struct fcoe_sge);
+	for (i = 0; i < num_ios; i++) {
+		bdt_info = cmgr->io_bdt_pool[i];
+		if (bdt_info->bd_tbl) {
+			dma_free_coherent(&qedf->pdev->dev, bd_tbl_sz,
+			    bdt_info->bd_tbl, bdt_info->bd_tbl_dma);
+			bdt_info->bd_tbl = NULL;
+		}
+	}
+
+	/* Destroy io_bdt pool */
+	for (i = 0; i < num_ios; i++) {
+		kfree(cmgr->io_bdt_pool[i]);
+		cmgr->io_bdt_pool[i] = NULL;
+	}
+
+	kfree(cmgr->io_bdt_pool);
+	cmgr->io_bdt_pool = NULL;
+
+free_cmd_pool:
+
+	for (i = 0; i < num_ios; i++) {
+		io_req = &cmgr->cmds[i];
+		/* Make sure we free per command sense buffer */
+		if (io_req->sense_buffer)
+			dma_free_coherent(&qedf->pdev->dev,
+			    QEDF_SCSI_SENSE_BUFFERSIZE, io_req->sense_buffer,
+			    io_req->sense_buffer_dma);
+		cancel_delayed_work_sync(&io_req->rrq_work);
+	}
+
+	/* Free command manager itself */
+	vfree(cmgr);
+}
+
+static void qedf_handle_rrq(struct work_struct *work)
+{
+	struct qedf_ioreq *io_req =
+	    container_of(work, struct qedf_ioreq, rrq_work.work);
+
+	qedf_send_rrq(io_req);
+
+}
+
+struct qedf_cmd_mgr *qedf_cmd_mgr_alloc(struct qedf_ctx *qedf)
+{
+	struct qedf_cmd_mgr *cmgr;
+	struct io_bdt *bdt_info;
+	struct qedf_ioreq *io_req;
+	u16 xid;
+	int i;
+	int num_ios;
+	u16 min_xid = QEDF_MIN_XID;
+	u16 max_xid = (FCOE_PARAMS_NUM_TASKS - 1);
+
+	/* Make sure num_queues is already set before calling this function */
+	if (!qedf->num_queues) {
+		QEDF_ERR(&(qedf->dbg_ctx), "num_queues is not set.\n");
+		return NULL;
+	}
+
+	if (max_xid <= min_xid || max_xid == FC_XID_UNKNOWN) {
+		QEDF_WARN(&(qedf->dbg_ctx), "Invalid min_xid 0x%x and "
+			   "max_xid 0x%x.\n", min_xid, max_xid);
+		return NULL;
+	}
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "min xid 0x%x, max xid "
+		   "0x%x.\n", min_xid, max_xid);
+
+	num_ios = max_xid - min_xid + 1;
+
+	cmgr = vzalloc(sizeof(struct qedf_cmd_mgr));
+	if (!cmgr) {
+		QEDF_WARN(&(qedf->dbg_ctx), "Failed to alloc cmd mgr.\n");
+		return NULL;
+	}
+
+	cmgr->qedf = qedf;
+	spin_lock_init(&cmgr->lock);
+
+	/*
+	 * Initialize list of qedf_ioreq.
+	 */
+	xid = QEDF_MIN_XID;
+
+	for (i = 0; i < num_ios; i++) {
+		io_req = &cmgr->cmds[i];
+		INIT_DELAYED_WORK(&io_req->timeout_work, qedf_cmd_timeout);
+
+		io_req->xid = xid++;
+
+		INIT_DELAYED_WORK(&io_req->rrq_work, qedf_handle_rrq);
+
+		/* Allocate DMA memory to hold sense buffer */
+		io_req->sense_buffer = dma_alloc_coherent(&qedf->pdev->dev,
+		    QEDF_SCSI_SENSE_BUFFERSIZE, &io_req->sense_buffer_dma,
+		    GFP_KERNEL);
+		if (!io_req->sense_buffer)
+			goto mem_err;
+	}
+
+	/* Allocate pool of io_bdts - one for each qedf_ioreq */
+	cmgr->io_bdt_pool = kmalloc_array(num_ios, sizeof(struct io_bdt *),
+	    GFP_KERNEL);
+
+	if (!cmgr->io_bdt_pool) {
+		QEDF_WARN(&(qedf->dbg_ctx), "Failed to alloc io_bdt_pool.\n");
+		goto mem_err;
+	}
+
+	for (i = 0; i < num_ios; i++) {
+		cmgr->io_bdt_pool[i] = kmalloc(sizeof(struct io_bdt),
+		    GFP_KERNEL);
+		if (!cmgr->io_bdt_pool[i]) {
+			QEDF_WARN(&(qedf->dbg_ctx), "Failed to alloc "
+				   "io_bdt_pool[%d].\n", i);
+			goto mem_err;
+		}
+	}
+
+	for (i = 0; i < num_ios; i++) {
+		bdt_info = cmgr->io_bdt_pool[i];
+		bdt_info->bd_tbl = dma_alloc_coherent(&qedf->pdev->dev,
+		    QEDF_MAX_BDS_PER_CMD * sizeof(struct fcoe_sge),
+		    &bdt_info->bd_tbl_dma, GFP_KERNEL);
+		if (!bdt_info->bd_tbl) {
+			QEDF_WARN(&(qedf->dbg_ctx), "Failed to alloc "
+				   "bdt_tbl[%d].\n", i);
+			goto mem_err;
+		}
+	}
+	atomic_set(&cmgr->free_list_cnt, num_ios);
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+	    "cmgr->free_list_cnt=%d.\n",
+	    atomic_read(&cmgr->free_list_cnt));
+
+	return cmgr;
+
+mem_err:
+	qedf_cmd_mgr_free(cmgr);
+	return NULL;
+}
+
+struct qedf_ioreq *qedf_alloc_cmd(struct qedf_rport *fcport, u8 cmd_type)
+{
+	struct qedf_ctx *qedf = fcport->qedf;
+	struct qedf_cmd_mgr *cmd_mgr = qedf->cmd_mgr;
+	struct qedf_ioreq *io_req = NULL;
+	struct io_bdt *bd_tbl;
+	u16 xid;
+	uint32_t free_sqes;
+	int i;
+	unsigned long flags;
+
+	free_sqes = atomic_read(&fcport->free_sqes);
+
+	if (!free_sqes) {
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Returning NULL, free_sqes=%d.\n ",
+		    free_sqes);
+		goto out_failed;
+	}
+
+	/* Limit the number of outstanding R/W tasks */
+	if ((atomic_read(&fcport->num_active_ios) >=
+	    NUM_RW_TASKS_PER_CONNECTION)) {
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Returning NULL, num_active_ios=%d.\n",
+		    atomic_read(&fcport->num_active_ios));
+		goto out_failed;
+	}
+
+	/* Limit global TIDs certain tasks */
+	if (atomic_read(&cmd_mgr->free_list_cnt) <= GBL_RSVD_TASKS) {
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Returning NULL, free_list_cnt=%d.\n",
+		    atomic_read(&cmd_mgr->free_list_cnt));
+		goto out_failed;
+	}
+
+	spin_lock_irqsave(&cmd_mgr->lock, flags);
+	for (i = 0; i < FCOE_PARAMS_NUM_TASKS; i++) {
+		io_req = &cmd_mgr->cmds[cmd_mgr->idx];
+		cmd_mgr->idx++;
+		if (cmd_mgr->idx == FCOE_PARAMS_NUM_TASKS)
+			cmd_mgr->idx = 0;
+
+		/* Check to make sure command was previously freed */
+		if (!test_bit(QEDF_CMD_OUTSTANDING, &io_req->flags))
+			break;
+	}
+
+	if (i == FCOE_PARAMS_NUM_TASKS) {
+		spin_unlock_irqrestore(&cmd_mgr->lock, flags);
+		goto out_failed;
+	}
+
+	set_bit(QEDF_CMD_OUTSTANDING, &io_req->flags);
+	spin_unlock_irqrestore(&cmd_mgr->lock, flags);
+
+	atomic_inc(&fcport->num_active_ios);
+	atomic_dec(&fcport->free_sqes);
+	xid = io_req->xid;
+	atomic_dec(&cmd_mgr->free_list_cnt);
+
+	io_req->cmd_mgr = cmd_mgr;
+	io_req->fcport = fcport;
+
+	/* Hold the io_req against deletion */
+	kref_init(&io_req->refcount);
+
+	/* Bind io_bdt for this io_req */
+	/* Have a static link between io_req and io_bdt_pool */
+	bd_tbl = io_req->bd_tbl = cmd_mgr->io_bdt_pool[xid];
+	if (bd_tbl == NULL) {
+		QEDF_ERR(&(qedf->dbg_ctx), "bd_tbl is NULL, xid=%x.\n", xid);
+		kref_put(&io_req->refcount, qedf_release_cmd);
+		goto out_failed;
+	}
+	bd_tbl->io_req = io_req;
+	io_req->cmd_type = cmd_type;
+
+	/* Reset sequence offset data */
+	io_req->rx_buf_off = 0;
+	io_req->tx_buf_off = 0;
+	io_req->rx_id = 0xffff; /* No OX_ID */
+
+	return io_req;
+
+out_failed:
+	/* Record failure for stats and return NULL to caller */
+	qedf->alloc_failures++;
+	return NULL;
+}
+
+static void qedf_free_mp_resc(struct qedf_ioreq *io_req)
+{
+	struct qedf_mp_req *mp_req = &(io_req->mp_req);
+	struct qedf_ctx *qedf = io_req->fcport->qedf;
+	uint64_t sz = sizeof(struct fcoe_sge);
+
+	/* clear tm flags */
+	mp_req->tm_flags = 0;
+	if (mp_req->mp_req_bd) {
+		dma_free_coherent(&qedf->pdev->dev, sz,
+		    mp_req->mp_req_bd, mp_req->mp_req_bd_dma);
+		mp_req->mp_req_bd = NULL;
+	}
+	if (mp_req->mp_resp_bd) {
+		dma_free_coherent(&qedf->pdev->dev, sz,
+		    mp_req->mp_resp_bd, mp_req->mp_resp_bd_dma);
+		mp_req->mp_resp_bd = NULL;
+	}
+	if (mp_req->req_buf) {
+		dma_free_coherent(&qedf->pdev->dev, QEDF_PAGE_SIZE,
+		    mp_req->req_buf, mp_req->req_buf_dma);
+		mp_req->req_buf = NULL;
+	}
+	if (mp_req->resp_buf) {
+		dma_free_coherent(&qedf->pdev->dev, QEDF_PAGE_SIZE,
+		    mp_req->resp_buf, mp_req->resp_buf_dma);
+		mp_req->resp_buf = NULL;
+	}
+}
+
+void qedf_release_cmd(struct kref *ref)
+{
+	struct qedf_ioreq *io_req =
+	    container_of(ref, struct qedf_ioreq, refcount);
+	struct qedf_cmd_mgr *cmd_mgr = io_req->cmd_mgr;
+	struct qedf_rport *fcport = io_req->fcport;
+
+	if (io_req->cmd_type == QEDF_ELS ||
+	    io_req->cmd_type == QEDF_TASK_MGMT_CMD)
+		qedf_free_mp_resc(io_req);
+
+	atomic_inc(&cmd_mgr->free_list_cnt);
+	atomic_dec(&fcport->num_active_ios);
+	if (atomic_read(&fcport->num_active_ios) < 0)
+		QEDF_WARN(&(fcport->qedf->dbg_ctx), "active_ios < 0.\n");
+
+	/* Increment task retry identifier now that the request is released */
+	io_req->task_retry_identifier++;
+
+	clear_bit(QEDF_CMD_OUTSTANDING, &io_req->flags);
+}
+
+static int qedf_split_bd(struct qedf_ioreq *io_req, u64 addr, int sg_len,
+	int bd_index)
+{
+	struct fcoe_sge *bd = io_req->bd_tbl->bd_tbl;
+	int frag_size, sg_frags;
+
+	sg_frags = 0;
+	while (sg_len) {
+		if (sg_len > QEDF_BD_SPLIT_SZ)
+			frag_size = QEDF_BD_SPLIT_SZ;
+		else
+			frag_size = sg_len;
+		bd[bd_index + sg_frags].sge_addr.lo = U64_LO(addr);
+		bd[bd_index + sg_frags].sge_addr.hi = U64_HI(addr);
+		bd[bd_index + sg_frags].size = (uint16_t)frag_size;
+
+		addr += (u64)frag_size;
+		sg_frags++;
+		sg_len -= frag_size;
+	}
+	return sg_frags;
+}
+
+static int qedf_map_sg(struct qedf_ioreq *io_req)
+{
+	struct scsi_cmnd *sc = io_req->sc_cmd;
+	struct Scsi_Host *host = sc->device->host;
+	struct fc_lport *lport = shost_priv(host);
+	struct qedf_ctx *qedf = lport_priv(lport);
+	struct fcoe_sge *bd = io_req->bd_tbl->bd_tbl;
+	struct scatterlist *sg;
+	int byte_count = 0;
+	int sg_count = 0;
+	int bd_count = 0;
+	int sg_frags;
+	unsigned int sg_len;
+	u64 addr, end_addr;
+	int i;
+
+	sg_count = dma_map_sg(&qedf->pdev->dev, scsi_sglist(sc),
+	    scsi_sg_count(sc), sc->sc_data_direction);
+
+	sg = scsi_sglist(sc);
+
+	/*
+	 * New condition to send single SGE as cached-SGL with length less
+	 * than 64k.
+	 */
+	if ((sg_count == 1) && (sg_dma_len(sg) <=
+	    QEDF_MAX_SGLEN_FOR_CACHESGL)) {
+		sg_len = sg_dma_len(sg);
+		addr = (u64)sg_dma_address(sg);
+
+		bd[bd_count].sge_addr.lo = (addr & 0xffffffff);
+		bd[bd_count].sge_addr.hi = (addr >> 32);
+		bd[bd_count].size = (u16)sg_len;
+
+		return ++bd_count;
+	}
+
+	scsi_for_each_sg(sc, sg, sg_count, i) {
+		sg_len = sg_dma_len(sg);
+		addr = (u64)sg_dma_address(sg);
+		end_addr = (u64)(addr + sg_len);
+
+		/*
+		 * First s/g element in the list so check if the end_addr
+		 * is paged aligned. Also check to make sure the length is
+		 * at least page size.
+		 */
+		if ((i == 0) && (sg_count > 1) &&
+		    ((end_addr % QEDF_PAGE_SIZE) ||
+		    sg_len < QEDF_PAGE_SIZE))
+			io_req->use_slowpath = true;
+		/*
+		 * Last s/g element so check if the start address is paged
+		 * aligned.
+		 */
+		else if ((i == (sg_count - 1)) && (sg_count > 1) &&
+		    (addr % QEDF_PAGE_SIZE))
+			io_req->use_slowpath = true;
+		/*
+		 * Intermediate s/g element so check if start and end address
+		 * is page aligned.
+		 */
+		else if ((i != 0) && (i != (sg_count - 1)) &&
+		    ((addr % QEDF_PAGE_SIZE) || (end_addr % QEDF_PAGE_SIZE)))
+			io_req->use_slowpath = true;
+
+		if (sg_len > QEDF_MAX_BD_LEN) {
+			sg_frags = qedf_split_bd(io_req, addr, sg_len,
+			    bd_count);
+		} else {
+			sg_frags = 1;
+			bd[bd_count].sge_addr.lo = U64_LO(addr);
+			bd[bd_count].sge_addr.hi  = U64_HI(addr);
+			bd[bd_count].size = (uint16_t)sg_len;
+		}
+
+		bd_count += sg_frags;
+		byte_count += sg_len;
+	}
+
+	if (byte_count != scsi_bufflen(sc))
+		QEDF_ERR(&(qedf->dbg_ctx), "byte_count = %d != "
+			  "scsi_bufflen = %d, task_id = 0x%x.\n", byte_count,
+			   scsi_bufflen(sc), io_req->xid);
+
+	return bd_count;
+}
+
+static int qedf_build_bd_list_from_sg(struct qedf_ioreq *io_req)
+{
+	struct scsi_cmnd *sc = io_req->sc_cmd;
+	struct fcoe_sge *bd = io_req->bd_tbl->bd_tbl;
+	int bd_count;
+
+	if (scsi_sg_count(sc)) {
+		bd_count = qedf_map_sg(io_req);
+		if (bd_count == 0)
+			return -ENOMEM;
+	} else {
+		bd_count = 0;
+		bd[0].sge_addr.lo = bd[0].sge_addr.hi = 0;
+		bd[0].size = 0;
+	}
+	io_req->bd_tbl->bd_valid = bd_count;
+
+	return 0;
+}
+
+static void qedf_build_fcp_cmnd(struct qedf_ioreq *io_req,
+				  struct fcp_cmnd *fcp_cmnd)
+{
+	struct scsi_cmnd *sc_cmd = io_req->sc_cmd;
+
+	/* fcp_cmnd is 32 bytes */
+	memset(fcp_cmnd, 0, FCP_CMND_LEN);
+
+	/* 8 bytes: SCSI LUN info */
+	int_to_scsilun(sc_cmd->device->lun,
+			(struct scsi_lun *)&fcp_cmnd->fc_lun);
+
+	/* 4 bytes: flag info */
+	fcp_cmnd->fc_pri_ta = 0;
+	fcp_cmnd->fc_tm_flags = io_req->mp_req.tm_flags;
+	fcp_cmnd->fc_flags = io_req->io_req_flags;
+	fcp_cmnd->fc_cmdref = 0;
+
+	/* Populate data direction */
+	if (sc_cmd->sc_data_direction == DMA_TO_DEVICE)
+		fcp_cmnd->fc_flags |= FCP_CFL_WRDATA;
+	else if (sc_cmd->sc_data_direction == DMA_FROM_DEVICE)
+		fcp_cmnd->fc_flags |= FCP_CFL_RDDATA;
+
+	fcp_cmnd->fc_pri_ta = FCP_PTA_SIMPLE;
+
+	/* 16 bytes: CDB information */
+	memcpy(fcp_cmnd->fc_cdb, sc_cmd->cmnd, sc_cmd->cmd_len);
+
+	/* 4 bytes: FCP data length */
+	fcp_cmnd->fc_dl = htonl(io_req->data_xfer_len);
+
+}
+
+static void  qedf_init_task(struct qedf_rport *fcport, struct fc_lport *lport,
+	struct qedf_ioreq *io_req, u32 *ptu_invalidate,
+	struct fcoe_task_context *task_ctx)
+{
+	enum fcoe_task_type task_type;
+	struct scsi_cmnd *sc_cmd = io_req->sc_cmd;
+	struct io_bdt *bd_tbl = io_req->bd_tbl;
+	union fcoe_data_desc_ctx *data_desc;
+	u32 *fcp_cmnd;
+	u32 tmp_fcp_cmnd[8];
+	int cnt, i;
+	int bd_count;
+	struct qedf_ctx *qedf = fcport->qedf;
+	uint16_t cq_idx = smp_processor_id() % qedf->num_queues;
+	u8 tmp_sgl_mode = 0;
+	u8 mst_sgl_mode = 0;
+
+	memset(task_ctx, 0, sizeof(struct fcoe_task_context));
+	io_req->task = task_ctx;
+
+	if (sc_cmd->sc_data_direction == DMA_TO_DEVICE)
+		task_type = FCOE_TASK_TYPE_WRITE_INITIATOR;
+	else
+		task_type = FCOE_TASK_TYPE_READ_INITIATOR;
+
+	/* Y Storm context */
+	task_ctx->ystorm_st_context.expect_first_xfer = 1;
+	task_ctx->ystorm_st_context.data_2_trns_rem = io_req->data_xfer_len;
+	/* Check if this is required */
+	task_ctx->ystorm_st_context.ox_id = io_req->xid;
+	task_ctx->ystorm_st_context.task_rety_identifier =
+	    io_req->task_retry_identifier;
+
+	/* T Storm ag context */
+	SET_FIELD(task_ctx->tstorm_ag_context.flags0,
+	    TSTORM_FCOE_TASK_AG_CTX_CONNECTION_TYPE, PROTOCOLID_FCOE);
+	task_ctx->tstorm_ag_context.icid = (u16)fcport->fw_cid;
+
+	/* T Storm st context */
+	SET_FIELD(task_ctx->tstorm_st_context.read_write.flags,
+	    FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_EXP_FIRST_FRAME,
+	    1);
+	task_ctx->tstorm_st_context.read_write.rx_id = 0xffff;
+
+	task_ctx->tstorm_st_context.read_only.dev_type =
+	    FCOE_TASK_DEV_TYPE_DISK;
+	task_ctx->tstorm_st_context.read_only.conf_supported = 0;
+	task_ctx->tstorm_st_context.read_only.cid = fcport->fw_cid;
+
+	/* Completion queue for response. */
+	task_ctx->tstorm_st_context.read_only.glbl_q_num = cq_idx;
+	task_ctx->tstorm_st_context.read_only.fcp_cmd_trns_size =
+	    io_req->data_xfer_len;
+	task_ctx->tstorm_st_context.read_write.e_d_tov_exp_timeout_val =
+	    lport->e_d_tov;
+
+	task_ctx->ustorm_ag_context.global_cq_num = cq_idx;
+	io_req->fp_idx = cq_idx;
+
+	bd_count = bd_tbl->bd_valid;
+	if (task_type == FCOE_TASK_TYPE_WRITE_INITIATOR) {
+		/* Setup WRITE task */
+		struct fcoe_sge *fcoe_bd_tbl = bd_tbl->bd_tbl;
+
+		task_ctx->ystorm_st_context.task_type =
+		    FCOE_TASK_TYPE_WRITE_INITIATOR;
+		data_desc = &task_ctx->ystorm_st_context.data_desc;
+
+		if (io_req->use_slowpath) {
+			SET_FIELD(task_ctx->ystorm_st_context.sgl_mode,
+			    YSTORM_FCOE_TASK_ST_CTX_TX_SGL_MODE,
+			    FCOE_SLOW_SGL);
+			data_desc->slow.base_sgl_addr.lo =
+			    U64_LO(bd_tbl->bd_tbl_dma);
+			data_desc->slow.base_sgl_addr.hi =
+			    U64_HI(bd_tbl->bd_tbl_dma);
+			data_desc->slow.remainder_num_sges = bd_count;
+			data_desc->slow.curr_sge_off = 0;
+			data_desc->slow.curr_sgl_index = 0;
+			qedf->slow_sge_ios++;
+			io_req->sge_type = QEDF_IOREQ_SLOW_SGE;
+		} else {
+			SET_FIELD(task_ctx->ystorm_st_context.sgl_mode,
+			    YSTORM_FCOE_TASK_ST_CTX_TX_SGL_MODE,
+			    (bd_count <= 4) ? (enum fcoe_sgl_mode)bd_count :
+			    FCOE_MUL_FAST_SGES);
+
+			if (bd_count == 1) {
+				data_desc->single_sge.sge_addr.lo =
+				    fcoe_bd_tbl->sge_addr.lo;
+				data_desc->single_sge.sge_addr.hi =
+				    fcoe_bd_tbl->sge_addr.hi;
+				data_desc->single_sge.size =
+				    fcoe_bd_tbl->size;
+				data_desc->single_sge.is_valid_sge = 0;
+				qedf->single_sge_ios++;
+				io_req->sge_type = QEDF_IOREQ_SINGLE_SGE;
+			} else {
+				data_desc->fast.sgl_start_addr.lo =
+				    U64_LO(bd_tbl->bd_tbl_dma);
+				data_desc->fast.sgl_start_addr.hi =
+				    U64_HI(bd_tbl->bd_tbl_dma);
+				data_desc->fast.sgl_byte_offset =
+				    data_desc->fast.sgl_start_addr.lo &
+				    (QEDF_PAGE_SIZE - 1);
+				if (data_desc->fast.sgl_byte_offset > 0)
+					QEDF_ERR(&(qedf->dbg_ctx),
+					    "byte_offset=%u for xid=0x%x.\n",
+					    io_req->xid,
+					    data_desc->fast.sgl_byte_offset);
+				data_desc->fast.task_reuse_cnt =
+				    io_req->reuse_count;
+				io_req->reuse_count++;
+				if (io_req->reuse_count == QEDF_MAX_REUSE) {
+					*ptu_invalidate = 1;
+					io_req->reuse_count = 0;
+				}
+				qedf->fast_sge_ios++;
+				io_req->sge_type = QEDF_IOREQ_FAST_SGE;
+			}
+		}
+
+		/* T Storm context */
+		task_ctx->tstorm_st_context.read_only.task_type =
+		    FCOE_TASK_TYPE_WRITE_INITIATOR;
+
+		/* M Storm context */
+		tmp_sgl_mode = GET_FIELD(task_ctx->ystorm_st_context.sgl_mode,
+		    YSTORM_FCOE_TASK_ST_CTX_TX_SGL_MODE);
+		SET_FIELD(task_ctx->mstorm_st_context.non_fp.tx_rx_sgl_mode,
+		    FCOE_MSTORM_FCOE_TASK_ST_CTX_NON_FP_TX_SGL_MODE,
+		    tmp_sgl_mode);
+
+	} else {
+		/* Setup READ task */
+
+		/* M Storm context */
+		struct fcoe_sge *fcoe_bd_tbl = bd_tbl->bd_tbl;
+
+		data_desc = &task_ctx->mstorm_st_context.fp.data_desc;
+		task_ctx->mstorm_st_context.fp.data_2_trns_rem =
+		    io_req->data_xfer_len;
+
+		if (io_req->use_slowpath) {
+			SET_FIELD(
+			    task_ctx->mstorm_st_context.non_fp.tx_rx_sgl_mode,
+			    FCOE_MSTORM_FCOE_TASK_ST_CTX_NON_FP_RX_SGL_MODE,
+			    FCOE_SLOW_SGL);
+			data_desc->slow.base_sgl_addr.lo =
+			    U64_LO(bd_tbl->bd_tbl_dma);
+			data_desc->slow.base_sgl_addr.hi =
+			    U64_HI(bd_tbl->bd_tbl_dma);
+			data_desc->slow.remainder_num_sges =
+			    bd_count;
+			data_desc->slow.curr_sge_off = 0;
+			data_desc->slow.curr_sgl_index = 0;
+			qedf->slow_sge_ios++;
+			io_req->sge_type = QEDF_IOREQ_SLOW_SGE;
+		} else {
+			SET_FIELD(
+			    task_ctx->mstorm_st_context.non_fp.tx_rx_sgl_mode,
+			    FCOE_MSTORM_FCOE_TASK_ST_CTX_NON_FP_RX_SGL_MODE,
+			    (bd_count <= 4) ? (enum fcoe_sgl_mode)bd_count :
+			    FCOE_MUL_FAST_SGES);
+
+			if (bd_count == 1) {
+				data_desc->single_sge.sge_addr.lo =
+				    fcoe_bd_tbl->sge_addr.lo;
+				data_desc->single_sge.sge_addr.hi =
+				    fcoe_bd_tbl->sge_addr.hi;
+				data_desc->single_sge.size =
+				    fcoe_bd_tbl->size;
+				data_desc->single_sge.is_valid_sge = 0;
+				qedf->single_sge_ios++;
+				io_req->sge_type = QEDF_IOREQ_SINGLE_SGE;
+			} else {
+				data_desc->fast.sgl_start_addr.lo =
+				    U64_LO(bd_tbl->bd_tbl_dma);
+				data_desc->fast.sgl_start_addr.hi =
+				    U64_HI(bd_tbl->bd_tbl_dma);
+				data_desc->fast.sgl_byte_offset = 0;
+				data_desc->fast.task_reuse_cnt =
+				    io_req->reuse_count;
+				io_req->reuse_count++;
+				if (io_req->reuse_count == QEDF_MAX_REUSE) {
+					*ptu_invalidate = 1;
+					io_req->reuse_count = 0;
+				}
+				qedf->fast_sge_ios++;
+				io_req->sge_type = QEDF_IOREQ_FAST_SGE;
+			}
+		}
+
+		/* Y Storm context */
+		task_ctx->ystorm_st_context.expect_first_xfer = 0;
+		task_ctx->ystorm_st_context.task_type =
+		    FCOE_TASK_TYPE_READ_INITIATOR;
+
+		/* T Storm context */
+		task_ctx->tstorm_st_context.read_only.task_type =
+		    FCOE_TASK_TYPE_READ_INITIATOR;
+		mst_sgl_mode = GET_FIELD(
+		    task_ctx->mstorm_st_context.non_fp.tx_rx_sgl_mode,
+		    FCOE_MSTORM_FCOE_TASK_ST_CTX_NON_FP_RX_SGL_MODE);
+		SET_FIELD(task_ctx->tstorm_st_context.read_write.flags,
+		    FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_RX_SGL_MODE,
+		    mst_sgl_mode);
+	}
+
+	/* fill FCP_CMND IU */
+	fcp_cmnd = (u32 *)task_ctx->ystorm_st_context.tx_info_union.fcp_cmd_payload.opaque;
+	qedf_build_fcp_cmnd(io_req, (struct fcp_cmnd *)&tmp_fcp_cmnd);
+
+	/* Swap fcp_cmnd since FC is big endian */
+	cnt = sizeof(struct fcp_cmnd) / sizeof(u32);
+
+	for (i = 0; i < cnt; i++) {
+		*fcp_cmnd = cpu_to_be32(tmp_fcp_cmnd[i]);
+		fcp_cmnd++;
+	}
+
+	/* M Storm context - Sense buffer */
+	task_ctx->mstorm_st_context.non_fp.rsp_buf_addr.lo =
+		U64_LO(io_req->sense_buffer_dma);
+	task_ctx->mstorm_st_context.non_fp.rsp_buf_addr.hi =
+		U64_HI(io_req->sense_buffer_dma);
+}
+
+void qedf_init_mp_task(struct qedf_ioreq *io_req,
+	struct fcoe_task_context *task_ctx)
+{
+	struct qedf_mp_req *mp_req = &(io_req->mp_req);
+	struct qedf_rport *fcport = io_req->fcport;
+	struct qedf_ctx *qedf = io_req->fcport->qedf;
+	struct fc_frame_header *fc_hdr;
+	enum fcoe_task_type task_type = 0;
+	union fcoe_data_desc_ctx *data_desc;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "Initializing MP task "
+		   "for cmd_type = %d\n", io_req->cmd_type);
+
+	qedf->control_requests++;
+
+	/* Obtain task_type */
+	if ((io_req->cmd_type == QEDF_TASK_MGMT_CMD) ||
+	    (io_req->cmd_type == QEDF_ELS)) {
+		task_type = FCOE_TASK_TYPE_MIDPATH;
+	} else if (io_req->cmd_type == QEDF_ABTS) {
+		task_type = FCOE_TASK_TYPE_ABTS;
+	}
+
+	memset(task_ctx, 0, sizeof(struct fcoe_task_context));
+
+	/* Setup the task from io_req for easy reference */
+	io_req->task = task_ctx;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "task type = %d\n",
+		   task_type);
+
+	/* YSTORM only */
+	{
+		/* Initialize YSTORM task context */
+		struct fcoe_tx_mid_path_params *task_fc_hdr =
+		    &task_ctx->ystorm_st_context.tx_info_union.tx_params.mid_path;
+		memset(task_fc_hdr, 0, sizeof(struct fcoe_tx_mid_path_params));
+		task_ctx->ystorm_st_context.task_rety_identifier =
+		    io_req->task_retry_identifier;
+
+		/* Init SGL parameters */
+		if ((task_type == FCOE_TASK_TYPE_MIDPATH) ||
+		    (task_type == FCOE_TASK_TYPE_UNSOLICITED)) {
+			data_desc = &task_ctx->ystorm_st_context.data_desc;
+			data_desc->slow.base_sgl_addr.lo =
+			    U64_LO(mp_req->mp_req_bd_dma);
+			data_desc->slow.base_sgl_addr.hi =
+			    U64_HI(mp_req->mp_req_bd_dma);
+			data_desc->slow.remainder_num_sges = 1;
+			data_desc->slow.curr_sge_off = 0;
+			data_desc->slow.curr_sgl_index = 0;
+		}
+
+		fc_hdr = &(mp_req->req_fc_hdr);
+		if (task_type == FCOE_TASK_TYPE_MIDPATH) {
+			fc_hdr->fh_ox_id = io_req->xid;
+			fc_hdr->fh_rx_id = htons(0xffff);
+		} else if (task_type == FCOE_TASK_TYPE_UNSOLICITED) {
+			fc_hdr->fh_rx_id = io_req->xid;
+		}
+
+		/* Fill FC Header into middle path buffer */
+		task_fc_hdr->parameter = fc_hdr->fh_parm_offset;
+		task_fc_hdr->r_ctl = fc_hdr->fh_r_ctl;
+		task_fc_hdr->type = fc_hdr->fh_type;
+		task_fc_hdr->cs_ctl = fc_hdr->fh_cs_ctl;
+		task_fc_hdr->df_ctl = fc_hdr->fh_df_ctl;
+		task_fc_hdr->rx_id = fc_hdr->fh_rx_id;
+		task_fc_hdr->ox_id = fc_hdr->fh_ox_id;
+
+		task_ctx->ystorm_st_context.data_2_trns_rem =
+		    io_req->data_xfer_len;
+		task_ctx->ystorm_st_context.task_type = task_type;
+	}
+
+	/* TSTORM ONLY */
+	{
+		task_ctx->tstorm_ag_context.icid = (u16)fcport->fw_cid;
+		task_ctx->tstorm_st_context.read_only.cid = fcport->fw_cid;
+		/* Always send middle-path repsonses on CQ #0 */
+		task_ctx->tstorm_st_context.read_only.glbl_q_num = 0;
+		io_req->fp_idx = 0;
+		SET_FIELD(task_ctx->tstorm_ag_context.flags0,
+		    TSTORM_FCOE_TASK_AG_CTX_CONNECTION_TYPE,
+		    PROTOCOLID_FCOE);
+		task_ctx->tstorm_st_context.read_only.task_type = task_type;
+		SET_FIELD(task_ctx->tstorm_st_context.read_write.flags,
+		    FCOE_TSTORM_FCOE_TASK_ST_CTX_READ_WRITE_EXP_FIRST_FRAME,
+		    1);
+		task_ctx->tstorm_st_context.read_write.rx_id = 0xffff;
+	}
+
+	/* MSTORM only */
+	{
+		if (task_type == FCOE_TASK_TYPE_MIDPATH) {
+			/* Initialize task context */
+			data_desc = &task_ctx->mstorm_st_context.fp.data_desc;
+
+			/* Set cache sges address and length */
+			data_desc->slow.base_sgl_addr.lo =
+			    U64_LO(mp_req->mp_resp_bd_dma);
+			data_desc->slow.base_sgl_addr.hi =
+			    U64_HI(mp_req->mp_resp_bd_dma);
+			data_desc->slow.remainder_num_sges = 1;
+			data_desc->slow.curr_sge_off = 0;
+			data_desc->slow.curr_sgl_index = 0;
+
+			/*
+			 * Also need to fil in non-fastpath response address
+			 * for middle path commands.
+			 */
+			task_ctx->mstorm_st_context.non_fp.rsp_buf_addr.lo =
+			    U64_LO(mp_req->mp_resp_bd_dma);
+			task_ctx->mstorm_st_context.non_fp.rsp_buf_addr.hi =
+			    U64_HI(mp_req->mp_resp_bd_dma);
+		}
+	}
+
+	/* USTORM ONLY */
+	{
+		task_ctx->ustorm_ag_context.global_cq_num = 0;
+	}
+
+	/* I/O stats. Middle path commands always use slow SGEs */
+	qedf->slow_sge_ios++;
+	io_req->sge_type = QEDF_IOREQ_SLOW_SGE;
+}
+
+void qedf_add_to_sq(struct qedf_rport *fcport, u16 xid, u32 ptu_invalidate,
+	enum fcoe_task_type req_type, u32 offset)
+{
+	struct fcoe_wqe *sqe;
+	uint16_t total_sqe = (fcport->sq_mem_size)/(sizeof(struct fcoe_wqe));
+
+	sqe = &fcport->sq[fcport->sq_prod_idx];
+
+	fcport->sq_prod_idx++;
+	fcport->fw_sq_prod_idx++;
+	if (fcport->sq_prod_idx == total_sqe)
+		fcport->sq_prod_idx = 0;
+
+	switch (req_type) {
+	case FCOE_TASK_TYPE_WRITE_INITIATOR:
+	case FCOE_TASK_TYPE_READ_INITIATOR:
+		SET_FIELD(sqe->flags, FCOE_WQE_REQ_TYPE, SEND_FCOE_CMD);
+		if (ptu_invalidate)
+			SET_FIELD(sqe->flags, FCOE_WQE_INVALIDATE_PTU, 1);
+		break;
+	case FCOE_TASK_TYPE_MIDPATH:
+		SET_FIELD(sqe->flags, FCOE_WQE_REQ_TYPE, SEND_FCOE_MIDPATH);
+		break;
+	case FCOE_TASK_TYPE_ABTS:
+		SET_FIELD(sqe->flags, FCOE_WQE_REQ_TYPE,
+		    SEND_FCOE_ABTS_REQUEST);
+		break;
+	case FCOE_TASK_TYPE_EXCHANGE_CLEANUP:
+		SET_FIELD(sqe->flags, FCOE_WQE_REQ_TYPE,
+		     FCOE_EXCHANGE_CLEANUP);
+		break;
+	case FCOE_TASK_TYPE_SEQUENCE_CLEANUP:
+		SET_FIELD(sqe->flags, FCOE_WQE_REQ_TYPE,
+		    FCOE_SEQUENCE_RECOVERY);
+		/* NOTE: offset param only used for sequence recovery */
+		sqe->additional_info_union.seq_rec_updated_offset = offset;
+		break;
+	case FCOE_TASK_TYPE_UNSOLICITED:
+		break;
+	default:
+		break;
+	}
+
+	sqe->task_id = xid;
+
+	/* Make sure SQ data is coherent */
+	wmb();
+
+}
+
+void qedf_ring_doorbell(struct qedf_rport *fcport)
+{
+	struct fcoe_db_data dbell = { 0 };
+
+	dbell.agg_flags = 0;
+
+	dbell.params |= DB_DEST_XCM << FCOE_DB_DATA_DEST_SHIFT;
+	dbell.params |= DB_AGG_CMD_SET << FCOE_DB_DATA_AGG_CMD_SHIFT;
+	dbell.params |= DQ_XCM_FCOE_SQ_PROD_CMD <<
+	    FCOE_DB_DATA_AGG_VAL_SEL_SHIFT;
+
+	dbell.sq_prod = fcport->fw_sq_prod_idx;
+	writel(*(u32 *)&dbell, fcport->p_doorbell);
+	/* Make sure SQ index is updated so f/w prcesses requests in order */
+	wmb();
+	mmiowb();
+}
+
+static void qedf_trace_io(struct qedf_rport *fcport, struct qedf_ioreq *io_req,
+			  int8_t direction)
+{
+	struct qedf_ctx *qedf = fcport->qedf;
+	struct qedf_io_log *io_log;
+	struct scsi_cmnd *sc_cmd = io_req->sc_cmd;
+	unsigned long flags;
+	uint8_t op;
+
+	spin_lock_irqsave(&qedf->io_trace_lock, flags);
+
+	io_log = &qedf->io_trace_buf[qedf->io_trace_idx];
+	io_log->direction = direction;
+	io_log->task_id = io_req->xid;
+	io_log->port_id = fcport->rdata->ids.port_id;
+	io_log->lun = sc_cmd->device->lun;
+	io_log->op = op = sc_cmd->cmnd[0];
+	io_log->lba[0] = sc_cmd->cmnd[2];
+	io_log->lba[1] = sc_cmd->cmnd[3];
+	io_log->lba[2] = sc_cmd->cmnd[4];
+	io_log->lba[3] = sc_cmd->cmnd[5];
+	io_log->bufflen = scsi_bufflen(sc_cmd);
+	io_log->sg_count = scsi_sg_count(sc_cmd);
+	io_log->result = sc_cmd->result;
+	io_log->jiffies = jiffies;
+	io_log->refcount = atomic_read(&io_req->refcount.refcount);
+
+	if (direction == QEDF_IO_TRACE_REQ) {
+		/* For requests we only care abot the submission CPU */
+		io_log->req_cpu = io_req->cpu;
+		io_log->int_cpu = 0;
+		io_log->rsp_cpu = 0;
+	} else if (direction == QEDF_IO_TRACE_RSP) {
+		io_log->req_cpu = io_req->cpu;
+		io_log->int_cpu = io_req->int_cpu;
+		io_log->rsp_cpu = smp_processor_id();
+	}
+
+	io_log->sge_type = io_req->sge_type;
+
+	qedf->io_trace_idx++;
+	if (qedf->io_trace_idx == QEDF_IO_TRACE_SIZE)
+		qedf->io_trace_idx = 0;
+
+	spin_unlock_irqrestore(&qedf->io_trace_lock, flags);
+}
+
+int qedf_post_io_req(struct qedf_rport *fcport, struct qedf_ioreq *io_req)
+{
+	struct scsi_cmnd *sc_cmd = io_req->sc_cmd;
+	struct Scsi_Host *host = sc_cmd->device->host;
+	struct fc_lport *lport = shost_priv(host);
+	struct qedf_ctx *qedf = lport_priv(lport);
+	struct fcoe_task_context *task_ctx;
+	u16 xid;
+	enum fcoe_task_type req_type = 0;
+	u32 ptu_invalidate = 0;
+
+	/* Initialize rest of io_req fileds */
+	io_req->data_xfer_len = scsi_bufflen(sc_cmd);
+	sc_cmd->SCp.ptr = (char *)io_req;
+	io_req->use_slowpath = false; /* Assume fast SGL by default */
+
+	/* Record which cpu this request is associated with */
+	io_req->cpu = smp_processor_id();
+
+	if (sc_cmd->sc_data_direction == DMA_FROM_DEVICE) {
+		req_type = FCOE_TASK_TYPE_READ_INITIATOR;
+		io_req->io_req_flags = QEDF_READ;
+		qedf->input_requests++;
+	} else if (sc_cmd->sc_data_direction == DMA_TO_DEVICE) {
+		req_type = FCOE_TASK_TYPE_WRITE_INITIATOR;
+		io_req->io_req_flags = QEDF_WRITE;
+		qedf->output_requests++;
+	} else {
+		io_req->io_req_flags = 0;
+		qedf->control_requests++;
+	}
+
+	xid = io_req->xid;
+
+	/* Build buffer descriptor list for firmware from sg list */
+	if (qedf_build_bd_list_from_sg(io_req)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "BD list creation failed.\n");
+		kref_put(&io_req->refcount, qedf_release_cmd);
+		return -EAGAIN;
+	}
+
+	/* Get the task context */
+	task_ctx = qedf_get_task_mem(&qedf->tasks, xid);
+	if (!task_ctx) {
+		QEDF_WARN(&(qedf->dbg_ctx), "task_ctx is NULL, xid=%d.\n",
+			   xid);
+		kref_put(&io_req->refcount, qedf_release_cmd);
+		return -EINVAL;
+	}
+
+	qedf_init_task(fcport, lport, io_req, &ptu_invalidate, task_ctx);
+
+	if (!test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Session not offloaded yet.\n");
+		kref_put(&io_req->refcount, qedf_release_cmd);
+	}
+
+	/* Obtain free SQ entry */
+	qedf_add_to_sq(fcport, xid, ptu_invalidate, req_type, 0);
+
+	/* Ring doorbell */
+	qedf_ring_doorbell(fcport);
+
+	if (qedf_io_tracing && io_req->sc_cmd)
+		qedf_trace_io(fcport, io_req, QEDF_IO_TRACE_REQ);
+
+	return false;
+}
+
+int
+qedf_queuecommand(struct Scsi_Host *host, struct scsi_cmnd *sc_cmd)
+{
+	struct fc_lport *lport = shost_priv(host);
+	struct qedf_ctx *qedf = lport_priv(lport);
+	struct fc_rport *rport = starget_to_rport(scsi_target(sc_cmd->device));
+	struct fc_rport_libfc_priv *rp = rport->dd_data;
+	struct qedf_rport *fcport = rport->dd_data;
+	struct qedf_ioreq *io_req;
+	int rc = 0;
+	int rval;
+	unsigned long flags = 0;
+
+
+	if (test_bit(QEDF_UNLOADING, &qedf->flags) ||
+	    test_bit(QEDF_DBG_STOP_IO, &qedf->flags)) {
+		sc_cmd->result = DID_NO_CONNECT << 16;
+		sc_cmd->scsi_done(sc_cmd);
+		return 0;
+	}
+
+	rval = fc_remote_port_chkready(rport);
+	if (rval) {
+		sc_cmd->result = rval;
+		sc_cmd->scsi_done(sc_cmd);
+		return 0;
+	}
+
+	/* Retry command if we are doing a qed drain operation */
+	if (test_bit(QEDF_DRAIN_ACTIVE, &qedf->flags)) {
+		rc = SCSI_MLQUEUE_HOST_BUSY;
+		goto exit_qcmd;
+	}
+
+	if (lport->state != LPORT_ST_READY ||
+	    atomic_read(&qedf->link_state) != QEDF_LINK_UP) {
+		rc = SCSI_MLQUEUE_HOST_BUSY;
+		goto exit_qcmd;
+	}
+
+	/* rport and tgt are allocated together, so tgt should be non-NULL */
+	fcport = (struct qedf_rport *)&rp[1];
+
+	if (!test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags)) {
+		/*
+		 * Session is not offloaded yet. Let SCSI-ml retry
+		 * the command.
+		 */
+		rc = SCSI_MLQUEUE_TARGET_BUSY;
+		goto exit_qcmd;
+	}
+	if (fcport->retry_delay_timestamp) {
+		if (time_after(jiffies, fcport->retry_delay_timestamp)) {
+			fcport->retry_delay_timestamp = 0;
+		} else {
+			/* If retry_delay timer is active, flow off the ML */
+			rc = SCSI_MLQUEUE_TARGET_BUSY;
+			goto exit_qcmd;
+		}
+	}
+
+	io_req = qedf_alloc_cmd(fcport, QEDF_SCSI_CMD);
+	if (!io_req) {
+		rc = SCSI_MLQUEUE_HOST_BUSY;
+		goto exit_qcmd;
+	}
+
+	io_req->sc_cmd = sc_cmd;
+
+	/* Take fcport->rport_lock for posting to fcport send queue */
+	spin_lock_irqsave(&fcport->rport_lock, flags);
+	if (qedf_post_io_req(fcport, io_req)) {
+		QEDF_WARN(&(qedf->dbg_ctx), "Unable to post io_req\n");
+		/* Return SQE to pool */
+		atomic_inc(&fcport->free_sqes);
+		rc = SCSI_MLQUEUE_HOST_BUSY;
+	}
+	spin_unlock_irqrestore(&fcport->rport_lock, flags);
+
+exit_qcmd:
+	return rc;
+}
+
+static void qedf_parse_fcp_rsp(struct qedf_ioreq *io_req,
+				 struct fcoe_cqe_rsp_info *fcp_rsp)
+{
+	struct scsi_cmnd *sc_cmd = io_req->sc_cmd;
+	struct qedf_ctx *qedf = io_req->fcport->qedf;
+	u8 rsp_flags = fcp_rsp->rsp_flags.flags;
+	int fcp_sns_len = 0;
+	int fcp_rsp_len = 0;
+	uint8_t *rsp_info, *sense_data;
+
+	io_req->fcp_status = FC_GOOD;
+	io_req->fcp_resid = 0;
+	if (rsp_flags & (FCOE_FCP_RSP_FLAGS_FCP_RESID_OVER |
+	    FCOE_FCP_RSP_FLAGS_FCP_RESID_UNDER))
+		io_req->fcp_resid = fcp_rsp->fcp_resid;
+
+	io_req->scsi_comp_flags = rsp_flags;
+	CMD_SCSI_STATUS(sc_cmd) = io_req->cdb_status =
+	    fcp_rsp->scsi_status_code;
+
+	if (rsp_flags &
+	    FCOE_FCP_RSP_FLAGS_FCP_RSP_LEN_VALID)
+		fcp_rsp_len = fcp_rsp->fcp_rsp_len;
+
+	if (rsp_flags &
+	    FCOE_FCP_RSP_FLAGS_FCP_SNS_LEN_VALID)
+		fcp_sns_len = fcp_rsp->fcp_sns_len;
+
+	io_req->fcp_rsp_len = fcp_rsp_len;
+	io_req->fcp_sns_len = fcp_sns_len;
+	rsp_info = sense_data = io_req->sense_buffer;
+
+	/* fetch fcp_rsp_code */
+	if ((fcp_rsp_len == 4) || (fcp_rsp_len == 8)) {
+		/* Only for task management function */
+		io_req->fcp_rsp_code = rsp_info[3];
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "fcp_rsp_code = %d\n", io_req->fcp_rsp_code);
+		/* Adjust sense-data location. */
+		sense_data += fcp_rsp_len;
+	}
+
+	if (fcp_sns_len > SCSI_SENSE_BUFFERSIZE) {
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Truncating sense buffer\n");
+		fcp_sns_len = SCSI_SENSE_BUFFERSIZE;
+	}
+
+	memset(sc_cmd->sense_buffer, 0, SCSI_SENSE_BUFFERSIZE);
+	if (fcp_sns_len)
+		memcpy(sc_cmd->sense_buffer, sense_data,
+		    fcp_sns_len);
+}
+
+static void qedf_unmap_sg_list(struct qedf_ctx *qedf, struct qedf_ioreq *io_req)
+{
+	struct scsi_cmnd *sc = io_req->sc_cmd;
+
+	if (io_req->bd_tbl->bd_valid && sc && scsi_sg_count(sc)) {
+		dma_unmap_sg(&qedf->pdev->dev, scsi_sglist(sc),
+		    scsi_sg_count(sc), sc->sc_data_direction);
+		io_req->bd_tbl->bd_valid = 0;
+	}
+}
+
+void qedf_scsi_completion(struct qedf_ctx *qedf, struct fcoe_cqe *cqe,
+	struct qedf_ioreq *io_req)
+{
+	u16 xid, rval;
+	struct fcoe_task_context *task_ctx;
+	struct scsi_cmnd *sc_cmd;
+	struct fcoe_cqe_rsp_info *fcp_rsp;
+	struct qedf_rport *fcport;
+	int refcount;
+	u16 scope, qualifier = 0;
+	u8 fw_residual_flag = 0;
+
+	if (!io_req)
+		return;
+	if (!cqe)
+		return;
+
+	xid = io_req->xid;
+	task_ctx = qedf_get_task_mem(&qedf->tasks, xid);
+	sc_cmd = io_req->sc_cmd;
+	fcp_rsp = &cqe->cqe_info.rsp_info;
+
+	if (!sc_cmd) {
+		QEDF_WARN(&(qedf->dbg_ctx), "sc_cmd is NULL!\n");
+		return;
+	}
+
+	if (!sc_cmd->SCp.ptr) {
+		QEDF_WARN(&(qedf->dbg_ctx), "SCp.ptr is NULL, returned in "
+		    "another context.\n");
+		return;
+	}
+
+	if (!sc_cmd->request) {
+		QEDF_WARN(&(qedf->dbg_ctx), "sc_cmd->request is NULL, "
+		    "sc_cmd=%p.\n", sc_cmd);
+		return;
+	}
+
+	if (!sc_cmd->request->special) {
+		QEDF_WARN(&(qedf->dbg_ctx), "request->special is NULL so "
+		    "request not valid, sc_cmd=%p.\n", sc_cmd);
+		return;
+	}
+
+	if (!sc_cmd->request->q) {
+		QEDF_WARN(&(qedf->dbg_ctx), "request->q is NULL so request "
+		   "is not valid, sc_cmd=%p.\n", sc_cmd);
+		return;
+	}
+
+	fcport = io_req->fcport;
+
+	qedf_parse_fcp_rsp(io_req, fcp_rsp);
+
+	qedf_unmap_sg_list(qedf, io_req);
+
+	/* Check for FCP transport error */
+	if (io_req->fcp_rsp_len > 3 && io_req->fcp_rsp_code) {
+		QEDF_ERR(&(qedf->dbg_ctx),
+		    "FCP I/O protocol failure xid=0x%x fcp_rsp_len=%d "
+		    "fcp_rsp_code=%d.\n", io_req->xid, io_req->fcp_rsp_len,
+		    io_req->fcp_rsp_code);
+		sc_cmd->result = DID_BUS_BUSY << 16;
+		goto out;
+	}
+
+	fw_residual_flag = GET_FIELD(cqe->cqe_info.rsp_info.fw_error_flags,
+	    FCOE_CQE_RSP_INFO_FW_UNDERRUN);
+	if (fw_residual_flag) {
+		QEDF_ERR(&(qedf->dbg_ctx),
+		    "Firmware detected underrun: xid=0x%x fcp_rsp.flags=0x%02x "
+		    "fcp_resid=%d fw_residual=0x%x.\n", io_req->xid,
+		    fcp_rsp->rsp_flags.flags, io_req->fcp_resid,
+		    cqe->cqe_info.rsp_info.fw_residual);
+
+		if (io_req->cdb_status == 0)
+			sc_cmd->result = (DID_ERROR << 16) | io_req->cdb_status;
+		else
+			sc_cmd->result = (DID_OK << 16) | io_req->cdb_status;
+
+		/* Abort the command since we did not get all the data */
+		init_completion(&io_req->abts_done);
+		rval = qedf_initiate_abts(io_req, true);
+		if (rval) {
+			QEDF_ERR(&(qedf->dbg_ctx), "Failed to queue ABTS.\n");
+			sc_cmd->result = (DID_ERROR << 16) | io_req->cdb_status;
+		}
+
+		/*
+		 * Set resid to the whole buffer length so we won't try to resue
+		 * any previously data.
+		 */
+		scsi_set_resid(sc_cmd, scsi_bufflen(sc_cmd));
+		goto out;
+	}
+
+	switch (io_req->fcp_status) {
+	case FC_GOOD:
+		if (io_req->cdb_status == 0) {
+			/* Good I/O completion */
+			sc_cmd->result = DID_OK << 16;
+		} else {
+			refcount = atomic_read(&io_req->refcount.refcount);
+			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+			    "%d:0:%d:%d xid=0x%0x op=0x%02x "
+			    "lba=%02x%02x%02x%02x cdb_status=%d "
+			    "fcp_resid=0x%x refcount=%d.\n",
+			    qedf->lport->host->host_no, sc_cmd->device->id,
+			    sc_cmd->device->lun, io_req->xid,
+			    sc_cmd->cmnd[0], sc_cmd->cmnd[2], sc_cmd->cmnd[3],
+			    sc_cmd->cmnd[4], sc_cmd->cmnd[5],
+			    io_req->cdb_status, io_req->fcp_resid,
+			    refcount);
+			sc_cmd->result = (DID_OK << 16) | io_req->cdb_status;
+
+			if (io_req->cdb_status == SAM_STAT_TASK_SET_FULL ||
+			    io_req->cdb_status == SAM_STAT_BUSY) {
+				/*
+				 * Check whether we need to set retry_delay at
+				 * all based on retry_delay module parameter
+				 * and the status qualifier.
+				 */
+
+				/* Upper 2 bits */
+				scope = fcp_rsp->retry_delay_timer & 0xC000;
+				/* Lower 14 bits */
+				qualifier = fcp_rsp->retry_delay_timer & 0x3FFF;
+
+				if (qedf_retry_delay &&
+				    scope > 0 && qualifier > 0 &&
+				    qualifier <= 0x3FEF) {
+					/* Check we don't go over the max */
+					if (qualifier > QEDF_RETRY_DELAY_MAX)
+						qualifier =
+						    QEDF_RETRY_DELAY_MAX;
+					fcport->retry_delay_timestamp =
+					    jiffies + (qualifier * HZ / 10);
+				}
+			}
+		}
+		if (io_req->fcp_resid)
+			scsi_set_resid(sc_cmd, io_req->fcp_resid);
+		break;
+	default:
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO, "fcp_status=%d.\n",
+			   io_req->fcp_status);
+		break;
+	}
+
+out:
+	if (qedf_io_tracing)
+		qedf_trace_io(fcport, io_req, QEDF_IO_TRACE_RSP);
+
+	io_req->sc_cmd = NULL;
+	sc_cmd->SCp.ptr =  NULL;
+	sc_cmd->scsi_done(sc_cmd);
+	kref_put(&io_req->refcount, qedf_release_cmd);
+}
+
+/* Return a SCSI command in some other context besides a normal completion */
+void qedf_scsi_done(struct qedf_ctx *qedf, struct qedf_ioreq *io_req,
+	int result)
+{
+	u16 xid;
+	struct scsi_cmnd *sc_cmd;
+	int refcount;
+
+	if (!io_req)
+		return;
+
+	xid = io_req->xid;
+	sc_cmd = io_req->sc_cmd;
+
+	if (!sc_cmd) {
+		QEDF_WARN(&(qedf->dbg_ctx), "sc_cmd is NULL!\n");
+		return;
+	}
+
+	if (!sc_cmd->SCp.ptr) {
+		QEDF_WARN(&(qedf->dbg_ctx), "SCp.ptr is NULL, returned in "
+		    "another context.\n");
+		return;
+	}
+
+	qedf_unmap_sg_list(qedf, io_req);
+
+	sc_cmd->result = result << 16;
+	refcount = atomic_read(&io_req->refcount.refcount);
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO, "%d:0:%d:%d: Completing "
+	    "sc_cmd=%p result=0x%08x op=0x%02x lba=0x%02x%02x%02x%02x, "
+	    "allowed=%d retries=%d refcount=%d.\n",
+	    qedf->lport->host->host_no, sc_cmd->device->id,
+	    sc_cmd->device->lun, sc_cmd, sc_cmd->result, sc_cmd->cmnd[0],
+	    sc_cmd->cmnd[2], sc_cmd->cmnd[3], sc_cmd->cmnd[4],
+	    sc_cmd->cmnd[5], sc_cmd->allowed, sc_cmd->retries,
+	    refcount);
+
+	/*
+	 * Set resid to the whole buffer length so we won't try to resue any
+	 * previously read data
+	 */
+	scsi_set_resid(sc_cmd, scsi_bufflen(sc_cmd));
+
+	if (qedf_io_tracing)
+		qedf_trace_io(io_req->fcport, io_req, QEDF_IO_TRACE_RSP);
+
+	io_req->sc_cmd = NULL;
+	sc_cmd->SCp.ptr = NULL;
+	sc_cmd->scsi_done(sc_cmd);
+	kref_put(&io_req->refcount, qedf_release_cmd);
+}
+
+/*
+ * Handle warning type CQE completions. This is mainly used for REC timer
+ * popping.
+ */
+void qedf_process_warning_compl(struct qedf_ctx *qedf, struct fcoe_cqe *cqe,
+	struct qedf_ioreq *io_req)
+{
+	int rval, i;
+	struct qedf_rport *fcport = io_req->fcport;
+	u64 err_warn_bit_map;
+	u8 err_warn = 0xff;
+
+	if (!cqe)
+		return;
+
+	QEDF_ERR(&(io_req->fcport->qedf->dbg_ctx), "Warning CQE, "
+		  "xid=0x%x\n", io_req->xid);
+	QEDF_ERR(&(io_req->fcport->qedf->dbg_ctx),
+		  "err_warn_bitmap=%08x:%08x\n",
+		  le32_to_cpu(cqe->cqe_info.err_info.err_warn_bitmap_hi),
+		  le32_to_cpu(cqe->cqe_info.err_info.err_warn_bitmap_lo));
+	QEDF_ERR(&(io_req->fcport->qedf->dbg_ctx), "tx_buff_off=%08x, "
+		  "rx_buff_off=%08x, rx_id=%04x\n",
+		  le32_to_cpu(cqe->cqe_info.err_info.tx_buf_off),
+		  le32_to_cpu(cqe->cqe_info.err_info.rx_buf_off),
+		  le32_to_cpu(cqe->cqe_info.err_info.rx_id));
+
+	/* Normalize the error bitmap value to an just an unsigned int */
+	err_warn_bit_map = (u64)
+	    ((u64)cqe->cqe_info.err_info.err_warn_bitmap_hi << 32) |
+	    (u64)cqe->cqe_info.err_info.err_warn_bitmap_lo;
+	for (i = 0; i < 64; i++) {
+		if (err_warn_bit_map & (u64)((u64)1 << i)) {
+			err_warn = i;
+			break;
+		}
+	}
+
+	/* Check if REC TOV expired if this is a tape device */
+	if (fcport->dev_type == QEDF_RPORT_TYPE_TAPE) {
+		if (err_warn ==
+		    FCOE_WARNING_CODE_REC_TOV_TIMER_EXPIRATION) {
+			QEDF_ERR(&(qedf->dbg_ctx), "REC timer expired.\n");
+			if (!test_bit(QEDF_CMD_SRR_SENT, &io_req->flags)) {
+				io_req->rx_buf_off =
+				    cqe->cqe_info.err_info.rx_buf_off;
+				io_req->tx_buf_off =
+				    cqe->cqe_info.err_info.tx_buf_off;
+				io_req->rx_id = cqe->cqe_info.err_info.rx_id;
+				rval = qedf_send_rec(io_req);
+				/*
+				 * We only want to abort the io_req if we
+				 * can't queue the REC command as we want to
+				 * keep the exchange open for recovery.
+				 */
+				if (rval)
+					goto send_abort;
+			}
+			return;
+		}
+	}
+
+send_abort:
+	init_completion(&io_req->abts_done);
+	rval = qedf_initiate_abts(io_req, true);
+	if (rval)
+		QEDF_ERR(&(qedf->dbg_ctx), "Failed to queue ABTS.\n");
+}
+
+/* Cleanup a command when we receive an error detection completion */
+void qedf_process_error_detect(struct qedf_ctx *qedf, struct fcoe_cqe *cqe,
+	struct qedf_ioreq *io_req)
+{
+	int rval;
+
+	if (!cqe)
+		return;
+
+	QEDF_ERR(&(io_req->fcport->qedf->dbg_ctx), "Error detection CQE, "
+		  "xid=0x%x\n", io_req->xid);
+	QEDF_ERR(&(io_req->fcport->qedf->dbg_ctx),
+		  "err_warn_bitmap=%08x:%08x\n",
+		  le32_to_cpu(cqe->cqe_info.err_info.err_warn_bitmap_hi),
+		  le32_to_cpu(cqe->cqe_info.err_info.err_warn_bitmap_lo));
+	QEDF_ERR(&(io_req->fcport->qedf->dbg_ctx), "tx_buff_off=%08x, "
+		  "rx_buff_off=%08x, rx_id=%04x\n",
+		  le32_to_cpu(cqe->cqe_info.err_info.tx_buf_off),
+		  le32_to_cpu(cqe->cqe_info.err_info.rx_buf_off),
+		  le32_to_cpu(cqe->cqe_info.err_info.rx_id));
+
+	if (qedf->stop_io_on_error) {
+		qedf_stop_all_io(qedf);
+		return;
+	}
+
+	init_completion(&io_req->abts_done);
+	rval = qedf_initiate_abts(io_req, true);
+	if (rval)
+		QEDF_ERR(&(qedf->dbg_ctx), "Failed to queue ABTS.\n");
+}
+
+static void qedf_flush_els_req(struct qedf_ctx *qedf,
+	struct qedf_ioreq *els_req)
+{
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+	    "Flushing ELS request xid=0x%x refcount=%d.\n", els_req->xid,
+	    atomic_read(&els_req->refcount.refcount));
+
+	/*
+	 * Need to distinguish this from a timeout when calling the
+	 * els_req->cb_func.
+	 */
+	els_req->event = QEDF_IOREQ_EV_ELS_FLUSH;
+
+	/* Cancel the timer */
+	cancel_delayed_work_sync(&els_req->timeout_work);
+
+	/* Call callback function to complete command */
+	if (els_req->cb_func && els_req->cb_arg) {
+		els_req->cb_func(els_req->cb_arg);
+		els_req->cb_arg = NULL;
+	}
+
+	/* Release kref for original initiate_els */
+	kref_put(&els_req->refcount, qedf_release_cmd);
+}
+
+/* A value of -1 for lun is a wild card that means flush all
+ * active SCSI I/Os for the target.
+ */
+void qedf_flush_active_ios(struct qedf_rport *fcport, int lun)
+{
+	struct qedf_ioreq *io_req;
+	struct qedf_ctx *qedf;
+	struct qedf_cmd_mgr *cmd_mgr;
+	int i, rc;
+
+	if (!fcport)
+		return;
+
+	qedf = fcport->qedf;
+	cmd_mgr = qedf->cmd_mgr;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO, "Flush active i/o's.\n");
+
+	for (i = 0; i < FCOE_PARAMS_NUM_TASKS; i++) {
+		io_req = &cmd_mgr->cmds[i];
+
+		if (!io_req)
+			continue;
+		if (io_req->fcport != fcport)
+			continue;
+		if (io_req->cmd_type == QEDF_ELS) {
+			rc = kref_get_unless_zero(&io_req->refcount);
+			if (!rc) {
+				QEDF_ERR(&(qedf->dbg_ctx),
+				    "Could not get kref for io_req=0x%p.\n",
+				    io_req);
+				continue;
+			}
+			qedf_flush_els_req(qedf, io_req);
+			/*
+			 * Release the kref and go back to the top of the
+			 * loop.
+			 */
+			goto free_cmd;
+		}
+
+		if (!io_req->sc_cmd)
+			continue;
+		if (lun > 0) {
+			if (io_req->sc_cmd->device->lun !=
+			    (u64)lun)
+				continue;
+		}
+
+		/*
+		 * Use kref_get_unless_zero in the unlikely case the command
+		 * we're about to flush was completed in the normal SCSI path
+		 */
+		rc = kref_get_unless_zero(&io_req->refcount);
+		if (!rc) {
+			QEDF_ERR(&(qedf->dbg_ctx), "Could not get kref for "
+			    "io_req=0x%p\n", io_req);
+			continue;
+		}
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO,
+		    "Cleanup xid=0x%x.\n", io_req->xid);
+
+		/* Cleanup task and return I/O mid-layer */
+		qedf_initiate_cleanup(io_req, true);
+
+free_cmd:
+		kref_put(&io_req->refcount, qedf_release_cmd);
+	}
+}
+
+/*
+ * Initiate a ABTS middle path command. Note that we don't have to initialize
+ * the task context for an ABTS task.
+ */
+int qedf_initiate_abts(struct qedf_ioreq *io_req, bool return_scsi_cmd_on_abts)
+{
+	struct fc_lport *lport;
+	struct qedf_rport *fcport = io_req->fcport;
+	struct fc_rport_priv *rdata = fcport->rdata;
+	struct qedf_ctx *qedf = fcport->qedf;
+	u16 xid;
+	u32 r_a_tov = 0;
+	int rc = 0;
+	unsigned long flags;
+
+	r_a_tov = rdata->r_a_tov;
+	lport = qedf->lport;
+
+	if (!test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "tgt not offloaded\n");
+		rc = 1;
+		goto abts_err;
+	}
+
+	if (lport->state != LPORT_ST_READY || !(lport->link_up)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "link is not ready\n");
+		rc = 1;
+		goto abts_err;
+	}
+
+	if (atomic_read(&qedf->link_down_tmo_valid) > 0) {
+		QEDF_ERR(&(qedf->dbg_ctx), "link_down_tmo active.\n");
+		rc = 1;
+		goto abts_err;
+	}
+
+	/* Ensure room on SQ */
+	if (!atomic_read(&fcport->free_sqes)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "No SQ entries available\n");
+		rc = 1;
+		goto abts_err;
+	}
+
+
+	kref_get(&io_req->refcount);
+
+	xid = io_req->xid;
+	qedf->control_requests++;
+	qedf->packet_aborts++;
+
+	/* Set the return CPU to be the same as the request one */
+	io_req->cpu = smp_processor_id();
+
+	/* Set the command type to abort */
+	io_req->cmd_type = QEDF_ABTS;
+	io_req->return_scsi_cmd_on_abts = return_scsi_cmd_on_abts;
+
+	set_bit(QEDF_CMD_IN_ABORT, &io_req->flags);
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_SCSI_TM, "ABTS io_req xid = "
+		   "0x%x\n", xid);
+
+	qedf_cmd_timer_set(qedf, io_req, QEDF_ABORT_TIMEOUT * HZ);
+
+	spin_lock_irqsave(&fcport->rport_lock, flags);
+
+	/* Add ABTS to send queue */
+	qedf_add_to_sq(fcport, xid, 0, FCOE_TASK_TYPE_ABTS, 0);
+
+	/* Ring doorbell */
+	qedf_ring_doorbell(fcport);
+
+	spin_unlock_irqrestore(&fcport->rport_lock, flags);
+
+	return rc;
+abts_err:
+	/*
+	 * If the ABTS task fails to queue then we need to cleanup the
+	 * task at the firmware.
+	 */
+	qedf_initiate_cleanup(io_req, return_scsi_cmd_on_abts);
+	return rc;
+}
+
+void qedf_process_abts_compl(struct qedf_ctx *qedf, struct fcoe_cqe *cqe,
+	struct qedf_ioreq *io_req)
+{
+	uint32_t r_ctl;
+	uint16_t xid;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_SCSI_TM, "Entered with xid = "
+		   "0x%x cmd_type = %d\n", io_req->xid, io_req->cmd_type);
+
+	cancel_delayed_work(&io_req->timeout_work);
+
+	xid = io_req->xid;
+	r_ctl = cqe->cqe_info.abts_info.r_ctl;
+
+	switch (r_ctl) {
+	case FC_RCTL_BA_ACC:
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_SCSI_TM,
+		    "ABTS response - ACC Send RRQ after R_A_TOV\n");
+		io_req->event = QEDF_IOREQ_EV_ABORT_SUCCESS;
+		/*
+		 * Dont release this cmd yet. It will be relesed
+		 * after we get RRQ response
+		 */
+		kref_get(&io_req->refcount);
+		queue_delayed_work(qedf->dpc_wq, &io_req->rrq_work,
+		    msecs_to_jiffies(qedf->lport->r_a_tov));
+		break;
+	/* For error cases let the cleanup return the command */
+	case FC_RCTL_BA_RJT:
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_SCSI_TM,
+		   "ABTS response - RJT\n");
+		io_req->event = QEDF_IOREQ_EV_ABORT_FAILED;
+		break;
+	default:
+		QEDF_ERR(&(qedf->dbg_ctx), "Unknown ABTS response\n");
+		break;
+	}
+
+	clear_bit(QEDF_CMD_IN_ABORT, &io_req->flags);
+
+	if (io_req->sc_cmd) {
+		if (io_req->return_scsi_cmd_on_abts)
+			qedf_scsi_done(qedf, io_req, DID_ERROR);
+	}
+
+	/* Notify eh_abort handler that ABTS is complete */
+	complete(&io_req->abts_done);
+
+	kref_put(&io_req->refcount, qedf_release_cmd);
+}
+
+int qedf_init_mp_req(struct qedf_ioreq *io_req)
+{
+	struct qedf_mp_req *mp_req;
+	struct fcoe_sge *mp_req_bd;
+	struct fcoe_sge *mp_resp_bd;
+	struct qedf_ctx *qedf = io_req->fcport->qedf;
+	dma_addr_t addr;
+	uint64_t sz;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_MP_REQ, "Entered.\n");
+
+	mp_req = (struct qedf_mp_req *)&(io_req->mp_req);
+	memset(mp_req, 0, sizeof(struct qedf_mp_req));
+
+	if (io_req->cmd_type != QEDF_ELS) {
+		mp_req->req_len = sizeof(struct fcp_cmnd);
+		io_req->data_xfer_len = mp_req->req_len;
+	} else
+		mp_req->req_len = io_req->data_xfer_len;
+
+	mp_req->req_buf = dma_alloc_coherent(&qedf->pdev->dev, QEDF_PAGE_SIZE,
+	    &mp_req->req_buf_dma, GFP_KERNEL);
+	if (!mp_req->req_buf) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Unable to alloc MP req buffer\n");
+		qedf_free_mp_resc(io_req);
+		return -ENOMEM;
+	}
+
+	mp_req->resp_buf = dma_alloc_coherent(&qedf->pdev->dev,
+	    QEDF_PAGE_SIZE, &mp_req->resp_buf_dma, GFP_KERNEL);
+	if (!mp_req->resp_buf) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Unable to alloc TM resp "
+			  "buffer\n");
+		qedf_free_mp_resc(io_req);
+		return -ENOMEM;
+	}
+
+	/* Allocate and map mp_req_bd and mp_resp_bd */
+	sz = sizeof(struct fcoe_sge);
+	mp_req->mp_req_bd = dma_alloc_coherent(&qedf->pdev->dev, sz,
+	    &mp_req->mp_req_bd_dma, GFP_KERNEL);
+	if (!mp_req->mp_req_bd) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Unable to alloc MP req bd\n");
+		qedf_free_mp_resc(io_req);
+		return -ENOMEM;
+	}
+
+	mp_req->mp_resp_bd = dma_alloc_coherent(&qedf->pdev->dev, sz,
+	    &mp_req->mp_resp_bd_dma, GFP_KERNEL);
+	if (!mp_req->mp_resp_bd) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Unable to alloc MP resp bd\n");
+		qedf_free_mp_resc(io_req);
+		return -ENOMEM;
+	}
+
+	/* Fill bd table */
+	addr = mp_req->req_buf_dma;
+	mp_req_bd = mp_req->mp_req_bd;
+	mp_req_bd->sge_addr.lo = U64_LO(addr);
+	mp_req_bd->sge_addr.hi = U64_HI(addr);
+	mp_req_bd->size = QEDF_PAGE_SIZE;
+
+	/*
+	 * MP buffer is either a task mgmt command or an ELS.
+	 * So the assumption is that it consumes a single bd
+	 * entry in the bd table
+	 */
+	mp_resp_bd = mp_req->mp_resp_bd;
+	addr = mp_req->resp_buf_dma;
+	mp_resp_bd->sge_addr.lo = U64_LO(addr);
+	mp_resp_bd->sge_addr.hi = U64_HI(addr);
+	mp_resp_bd->size = QEDF_PAGE_SIZE;
+
+	return 0;
+}
+
+/*
+ * Last ditch effort to clear the port if it's stuck. Used only after a
+ * cleanup task times out.
+ */
+static void qedf_drain_request(struct qedf_ctx *qedf)
+{
+	if (test_bit(QEDF_DRAIN_ACTIVE, &qedf->flags)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "MCP drain already active.\n");
+		return;
+	}
+
+	/* Set bit to return all queuecommand requests as busy */
+	set_bit(QEDF_DRAIN_ACTIVE, &qedf->flags);
+
+	/* Call qed drain request for function. Should be synchronous */
+	qed_ops->common->drain(qedf->cdev);
+
+	/* Settle time for CQEs to be returned */
+	msleep(100);
+
+	/* Unplug and continue */
+	clear_bit(QEDF_DRAIN_ACTIVE, &qedf->flags);
+}
+
+/*
+ * Returns SUCCESS if the cleanup task does not timeout, otherwise return
+ * FAILURE.
+ */
+int qedf_initiate_cleanup(struct qedf_ioreq *io_req,
+	bool return_scsi_cmd_on_abts)
+{
+	struct qedf_rport *fcport;
+	struct qedf_ctx *qedf;
+	uint16_t xid;
+	struct fcoe_task_context *task;
+	int tmo = 0;
+	int rc = SUCCESS;
+	unsigned long flags;
+
+	fcport = io_req->fcport;
+	if (!fcport) {
+		QEDF_ERR(NULL, "fcport is NULL.\n");
+		return SUCCESS;
+	}
+
+	qedf = fcport->qedf;
+	if (!qedf) {
+		QEDF_ERR(NULL, "qedf is NULL.\n");
+		return SUCCESS;
+	}
+
+	if (!test_bit(QEDF_CMD_OUTSTANDING, &io_req->flags) ||
+	    test_bit(QEDF_CMD_IN_CLEANUP, &io_req->flags)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "io_req xid=0x%x already in "
+			  "cleanup processing or already completed.\n",
+			  io_req->xid);
+		return SUCCESS;
+	}
+
+	/* Ensure room on SQ */
+	if (!atomic_read(&fcport->free_sqes)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "No SQ entries available\n");
+		return FAILED;
+	}
+
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO, "Entered xid=0x%x\n",
+	    io_req->xid);
+
+	/* Cleanup cmds re-use the same TID as the original I/O */
+	xid = io_req->xid;
+	io_req->cmd_type = QEDF_CLEANUP;
+	io_req->return_scsi_cmd_on_abts = return_scsi_cmd_on_abts;
+
+	/* Set the return CPU to be the same as the request one */
+	io_req->cpu = smp_processor_id();
+
+	set_bit(QEDF_CMD_IN_CLEANUP, &io_req->flags);
+
+	task = qedf_get_task_mem(&qedf->tasks, xid);
+
+	init_completion(&io_req->tm_done);
+
+	/* Obtain free SQ entry */
+	spin_lock_irqsave(&fcport->rport_lock, flags);
+	qedf_add_to_sq(fcport, xid, 0, FCOE_TASK_TYPE_EXCHANGE_CLEANUP, 0);
+
+	/* Ring doorbell */
+	qedf_ring_doorbell(fcport);
+	spin_unlock_irqrestore(&fcport->rport_lock, flags);
+
+	tmo = wait_for_completion_timeout(&io_req->tm_done,
+	    QEDF_CLEANUP_TIMEOUT * HZ);
+
+	if (!tmo) {
+		rc = FAILED;
+		/* Timeout case */
+		QEDF_ERR(&(qedf->dbg_ctx), "Cleanup command timeout, "
+			  "xid=%x.\n", io_req->xid);
+		clear_bit(QEDF_CMD_IN_CLEANUP, &io_req->flags);
+		/* Issue a drain request if cleanup task times out */
+		QEDF_ERR(&(qedf->dbg_ctx), "Issuing MCP drain request.\n");
+		qedf_drain_request(qedf);
+	}
+
+	if (io_req->sc_cmd) {
+		if (io_req->return_scsi_cmd_on_abts)
+			qedf_scsi_done(qedf, io_req, DID_ERROR);
+	}
+
+	if (rc == SUCCESS)
+		io_req->event = QEDF_IOREQ_EV_CLEANUP_SUCCESS;
+	else
+		io_req->event = QEDF_IOREQ_EV_CLEANUP_FAILED;
+
+	return rc;
+}
+
+void qedf_process_cleanup_compl(struct qedf_ctx *qedf, struct fcoe_cqe *cqe,
+	struct qedf_ioreq *io_req)
+{
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_IO, "Entered xid = 0x%x\n",
+		   io_req->xid);
+
+	clear_bit(QEDF_CMD_IN_CLEANUP, &io_req->flags);
+
+	/* Complete so we can finish cleaning up the I/O */
+	complete(&io_req->tm_done);
+}
+
+static int qedf_execute_tmf(struct qedf_rport *fcport, struct scsi_cmnd *sc_cmd,
+	uint8_t tm_flags)
+{
+	struct qedf_ioreq *io_req;
+	struct qedf_mp_req *tm_req;
+	struct fcoe_task_context *task;
+	struct fc_frame_header *fc_hdr;
+	struct fcp_cmnd *fcp_cmnd;
+	struct qedf_ctx *qedf = fcport->qedf;
+	int rc = 0;
+	uint16_t xid;
+	uint32_t sid, did;
+	int tmo = 0;
+	unsigned long flags;
+
+	if (!sc_cmd) {
+		QEDF_ERR(&(qedf->dbg_ctx), "invalid arg\n");
+		return FAILED;
+	}
+
+	if (!(test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags))) {
+		QEDF_ERR(&(qedf->dbg_ctx), "fcport not offloaded\n");
+		rc = FAILED;
+		return FAILED;
+	}
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_SCSI_TM, "portid = 0x%x "
+		   "tm_flags = %d\n", fcport->rdata->ids.port_id, tm_flags);
+
+	io_req = qedf_alloc_cmd(fcport, QEDF_TASK_MGMT_CMD);
+	if (!io_req) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Failed TMF");
+		rc = -EAGAIN;
+		goto reset_tmf_err;
+	}
+
+	/* Initialize rest of io_req fields */
+	io_req->sc_cmd = sc_cmd;
+	io_req->fcport = fcport;
+	io_req->cmd_type = QEDF_TASK_MGMT_CMD;
+
+	/* Set the return CPU to be the same as the request one */
+	io_req->cpu = smp_processor_id();
+
+	tm_req = (struct qedf_mp_req *)&(io_req->mp_req);
+
+	rc = qedf_init_mp_req(io_req);
+	if (rc == FAILED) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Task mgmt MP request init "
+			  "failed\n");
+		kref_put(&io_req->refcount, qedf_release_cmd);
+		goto reset_tmf_err;
+	}
+
+	/* Set TM flags */
+	io_req->io_req_flags = 0;
+	tm_req->tm_flags = tm_flags;
+
+	/* Default is to return a SCSI command when an error occurs */
+	io_req->return_scsi_cmd_on_abts = true;
+
+	/* Fill FCP_CMND */
+	qedf_build_fcp_cmnd(io_req, (struct fcp_cmnd *)tm_req->req_buf);
+	fcp_cmnd = (struct fcp_cmnd *)tm_req->req_buf;
+	memset(fcp_cmnd->fc_cdb, 0, FCP_CMND_LEN);
+	fcp_cmnd->fc_dl = 0;
+
+	/* Fill FC header */
+	fc_hdr = &(tm_req->req_fc_hdr);
+	sid = fcport->sid;
+	did = fcport->rdata->ids.port_id;
+	__fc_fill_fc_hdr(fc_hdr, FC_RCTL_DD_UNSOL_CMD, sid, did,
+			   FC_TYPE_FCP, FC_FC_FIRST_SEQ | FC_FC_END_SEQ |
+			   FC_FC_SEQ_INIT, 0);
+	/* Obtain exchange id */
+	xid = io_req->xid;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_SCSI_TM, "TMF io_req xid = "
+		   "0x%x\n", xid);
+
+	/* Initialize task context for this IO request */
+	task = qedf_get_task_mem(&qedf->tasks, xid);
+	qedf_init_mp_task(io_req, task);
+
+	init_completion(&io_req->tm_done);
+
+	/* Obtain free SQ entry */
+	spin_lock_irqsave(&fcport->rport_lock, flags);
+	qedf_add_to_sq(fcport, xid, 0, FCOE_TASK_TYPE_MIDPATH, 0);
+
+	/* Ring doorbell */
+	qedf_ring_doorbell(fcport);
+	spin_unlock_irqrestore(&fcport->rport_lock, flags);
+
+	tmo = wait_for_completion_timeout(&io_req->tm_done,
+	    QEDF_TM_TIMEOUT * HZ);
+
+	if (!tmo) {
+		rc = FAILED;
+		QEDF_ERR(&(qedf->dbg_ctx), "wait for tm_cmpl timeout!\n");
+	} else {
+		/* Check TMF response code */
+		if (io_req->fcp_rsp_code == 0)
+			rc = SUCCESS;
+		else
+			rc = FAILED;
+	}
+
+	if (tm_flags == FCP_TMF_LUN_RESET)
+		qedf_flush_active_ios(fcport, (int)sc_cmd->device->lun);
+	else
+		qedf_flush_active_ios(fcport, -1);
+
+	kref_put(&io_req->refcount, qedf_release_cmd);
+
+	if (rc != SUCCESS) {
+		QEDF_ERR(&(qedf->dbg_ctx), "task mgmt command failed...\n");
+		rc = FAILED;
+	} else {
+		QEDF_ERR(&(qedf->dbg_ctx), "task mgmt command success...\n");
+		rc = SUCCESS;
+	}
+reset_tmf_err:
+	return rc;
+}
+
+int qedf_initiate_tmf(struct scsi_cmnd *sc_cmd, u8 tm_flags)
+{
+	struct fc_rport *rport = starget_to_rport(scsi_target(sc_cmd->device));
+	struct fc_rport_libfc_priv *rp = rport->dd_data;
+	struct qedf_rport *fcport = (struct qedf_rport *)&rp[1];
+	struct qedf_ctx *qedf;
+	struct fc_lport *lport;
+	int rc = SUCCESS;
+	int rval;
+
+	rval = fc_remote_port_chkready(rport);
+
+	if (rval) {
+		QEDF_ERR(NULL, "device_reset rport not ready\n");
+		rc = FAILED;
+		goto tmf_err;
+	}
+
+	if (fcport == NULL) {
+		QEDF_ERR(NULL, "device_reset: rport is NULL\n");
+		rc = FAILED;
+		goto tmf_err;
+	}
+
+	qedf = fcport->qedf;
+	lport = qedf->lport;
+
+	if (test_bit(QEDF_UNLOADING, &qedf->flags) ||
+	    test_bit(QEDF_DBG_STOP_IO, &qedf->flags)) {
+		rc = SUCCESS;
+		goto tmf_err;
+	}
+
+	if (lport->state != LPORT_ST_READY || !(lport->link_up)) {
+		QEDF_ERR(&(qedf->dbg_ctx), "link is not ready\n");
+		rc = FAILED;
+		goto tmf_err;
+	}
+
+	rc = qedf_execute_tmf(fcport, sc_cmd, tm_flags);
+
+tmf_err:
+	return rc;
+}
+
+void qedf_process_tmf_compl(struct qedf_ctx *qedf, struct fcoe_cqe *cqe,
+	struct qedf_ioreq *io_req)
+{
+	struct fcoe_cqe_rsp_info *fcp_rsp;
+	struct fcoe_cqe_midpath_info *mp_info;
+
+
+	/* Get TMF response length from CQE */
+	mp_info = &cqe->cqe_info.midpath_info;
+	io_req->mp_req.resp_len = mp_info->data_placement_size;
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_SCSI_TM,
+	    "Response len is %d.\n", io_req->mp_req.resp_len);
+
+	fcp_rsp = &cqe->cqe_info.rsp_info;
+	qedf_parse_fcp_rsp(io_req, fcp_rsp);
+
+	io_req->sc_cmd = NULL;
+	complete(&io_req->tm_done);
+}
+
+void qedf_process_unsol_compl(struct qedf_ctx *qedf, uint16_t que_idx,
+	struct fcoe_cqe *cqe)
+{
+	unsigned long flags;
+	uint16_t tmp;
+	uint16_t pktlen = cqe->cqe_info.unsolic_info.pkt_len;
+	u32 payload_len, crc;
+	struct fc_frame_header *fh;
+	struct fc_frame *fp;
+	struct qedf_io_work *io_work;
+	u32 bdq_idx;
+	void *bdq_addr;
+
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_UNSOL,
+	    "address.hi=%x address.lo=%x opaque_data.hi=%x "
+	    "opaque_data.lo=%x bdq_prod_idx=%u len=%u.\n",
+	    le32_to_cpu(cqe->cqe_info.unsolic_info.bd_info.address.hi),
+	    le32_to_cpu(cqe->cqe_info.unsolic_info.bd_info.address.lo),
+	    le32_to_cpu(cqe->cqe_info.unsolic_info.bd_info.opaque.hi),
+	    le32_to_cpu(cqe->cqe_info.unsolic_info.bd_info.opaque.lo),
+	    qedf->bdq_prod_idx, pktlen);
+
+	bdq_idx = le32_to_cpu(cqe->cqe_info.unsolic_info.bd_info.opaque.lo);
+	if (bdq_idx >= QEDF_BDQ_SIZE) {
+		QEDF_ERR(&(qedf->dbg_ctx), "bdq_idx is out of range %d.\n",
+		    bdq_idx);
+		goto increment_prod;
+	}
+
+	bdq_addr = qedf->bdq[bdq_idx].buf_addr;
+	if (!bdq_addr) {
+		QEDF_ERR(&(qedf->dbg_ctx), "bdq_addr is NULL, dropping "
+		    "unsolicited packet.\n");
+		goto increment_prod;
+	}
+
+	if (qedf_dump_frames) {
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_UNSOL,
+		    "BDQ frame is at addr=%p.\n", bdq_addr);
+		print_hex_dump(KERN_WARNING, "bdq ", DUMP_PREFIX_OFFSET, 16, 1,
+		    (void *)bdq_addr, pktlen, false);
+	}
+
+	/* Allocate frame */
+	payload_len = pktlen - sizeof(struct fc_frame_header);
+	fp = fc_frame_alloc(qedf->lport, payload_len);
+	if (!fp) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Could not allocate fp.\n");
+		goto increment_prod;
+	}
+
+	/* Copy data from BDQ buffer into fc_frame struct */
+	fh = (struct fc_frame_header *)fc_frame_header_get(fp);
+	memcpy(fh, (void *)bdq_addr, pktlen);
+
+	/* Initialize the frame so libfc sees it as a valid frame */
+	crc = fcoe_fc_crc(fp);
+	fc_frame_init(fp);
+	fr_dev(fp) = qedf->lport;
+	fr_sof(fp) = FC_SOF_I3;
+	fr_eof(fp) = FC_EOF_T;
+	fr_crc(fp) = cpu_to_le32(~crc);
+
+	/*
+	 * We need to return the frame back up to libfc in a non-atomic
+	 * context
+	 */
+	io_work = mempool_alloc(qedf->io_mempool, GFP_ATOMIC);
+	if (!io_work) {
+		QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate "
+			   "work for I/O completion.\n");
+		fc_frame_free(fp);
+		goto increment_prod;
+	}
+	memset(io_work, 0, sizeof(struct qedf_io_work));
+
+	INIT_WORK(&io_work->work, qedf_fp_io_handler);
+
+	/* Copy contents of CQE for deferred processing */
+	memcpy(&io_work->cqe, cqe, sizeof(struct fcoe_cqe));
+
+	io_work->qedf = qedf;
+	io_work->fp = fp;
+
+	queue_work_on(smp_processor_id(), qedf_io_wq, &io_work->work);
+increment_prod:
+	spin_lock_irqsave(&qedf->hba_lock, flags);
+
+	/* Increment producer to let f/w know we've handled the frame */
+	qedf->bdq_prod_idx++;
+
+	/* Producer index wraps at uint16_t boundary */
+	if (qedf->bdq_prod_idx == 0xffff)
+		qedf->bdq_prod_idx = 0;
+
+	writew(qedf->bdq_prod_idx, qedf->bdq_primary_prod);
+	tmp = readw(qedf->bdq_primary_prod);
+	writew(qedf->bdq_prod_idx, qedf->bdq_secondary_prod);
+	tmp = readw(qedf->bdq_secondary_prod);
+
+	spin_unlock_irqrestore(&qedf->hba_lock, flags);
+}
diff --git a/drivers/scsi/qedf/qedf_main.c b/drivers/scsi/qedf/qedf_main.c
new file mode 100644
index 0000000..d9d7a86
--- /dev/null
+++ b/drivers/scsi/qedf/qedf_main.c
@@ -0,0 +1,3336 @@
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
+struct workqueue_struct *qedf_io_wq;
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
+	if (IS_ERR(fp)) {
+		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
+		    "fp has IS_ERR() set.\n");
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
+struct qedf_tmp_rdata_item {
+	struct fc_rport_priv *rdata;
+	struct list_head list;
+};
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
+	struct qedf_tmp_rdata_item *rdata_item, *tmp_rdata_item;
+	bool rc;
+	int retries = 30;
+	int rval, i;
+	struct list_head rdata_login_list;
+
+	INIT_LIST_HEAD(&rdata_login_list);
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
+	rcu_read_lock();
+	list_for_each_entry_rcu(fcport, &qedf->fcports, peers) {
+		rdata = fcport->rdata;
+		if (rdata == NULL)
+			continue;
+		rdata_item = kzalloc(sizeof(struct qedf_tmp_rdata_item),
+		    GFP_ATOMIC);
+		if (!rdata_item)
+			continue;
+		if (kref_get_unless_zero(&rdata->kref)) {
+			rdata_item->rdata = rdata;
+			list_add(&rdata_item->list, &rdata_login_list);
+		} else
+			kfree(rdata_item);
+	}
+	rcu_read_unlock();
+	/*
+	 * Do the fc_rport_login outside of the rcu lock so we don't take a
+	 * mutex in an atomic context.
+	 */
+	list_for_each_entry_safe(rdata_item, tmp_rdata_item, &rdata_login_list,
+	    list) {
+		list_del(&rdata_item->list);
+		fc_rport_login(rdata_item->rdata);
+		kref_put(&rdata_item->rdata->kref, fc_rport_destroy);
+		kfree(rdata_item);
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
+	    test_bit(QEDF_UNLOADING, &qedf->flags) ||
+	    test_bit(QEDF_DBG_STOP_IO, &qedf->flags))
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
+static struct qedf_rport *qedf_fcport_lookup(struct qedf_ctx *qedf, u32 port_id)
+{
+	struct qedf_rport *fcport;
+	struct fc_rport_priv *rdata;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(fcport, &qedf->fcports, peers) {
+		rdata = fcport->rdata;
+		if (rdata == NULL)
+			continue;
+		if (rdata->ids.port_id == port_id) {
+			rcu_read_unlock();
+			return fcport;
+		}
+	}
+	rcu_read_unlock();
+
+	/* Return NULL to caller to let them know fcport was not found */
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
+	fcport = qedf_fcport_lookup(qedf, ntoh24(fh->fh_d_id));
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
+	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_CONN, "Cleaning up portid=%06x.\n",
+	    fcport->rdata->ids.port_id);
+
+	/* Flush any remaining i/o's before we upload the connection */
+	qedf_flush_active_ios(fcport, -1);
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
+	unsigned long flags;
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
+		if (atomic_read(&qedf->num_offloads) >= QEDF_MAX_SESSIONS) {
+			QEDF_ERR(&(qedf->dbg_ctx), "Not offloading "
+			    "portid=0x%x as max number of offloaded sessions "
+			    "reached.\n", rdata->ids.port_id);
+			return;
+		}
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
+		/* Add fcport to list of qedf_ctx list of offloaded ports */
+		spin_lock_irqsave(&qedf->hba_lock, flags);
+		list_add_rcu(&fcport->peers, &qedf->fcports);
+		spin_unlock_irqrestore(&qedf->hba_lock, flags);
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
+		/* Only free this fcport if it is offloaded already */
+		if (test_bit(QEDF_RPORT_SESSION_READY, &fcport->flags)) {
+			set_bit(QEDF_RPORT_UPLOADING_CONNECTION, &fcport->flags);
+			qedf_cleanup_fcport(qedf, fcport);
+
+			/*
+			 * Remove fcport to list of qedf_ctx list of offloaded
+			 * ports
+			 */
+			spin_lock_irqsave(&qedf->hba_lock, flags);
+			list_del_rcu(&fcport->peers);
+			spin_unlock_irqrestore(&qedf->hba_lock, flags);
+
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
+	vport_qedf->pdev = base_qedf->pdev;
+	vport_qedf->cmd_mgr = base_qedf->cmd_mgr;
+	init_completion(&vport_qedf->flogi_compl);
+	INIT_LIST_HEAD(&vport_qedf->fcports);
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
+	qedf_stats->fcp_input_megabytes +=
+	    do_div(fw_fcoe_stats->fcoe_rx_byte_cnt, 1000000);
+	qedf_stats->fcp_output_megabytes +=
+	    do_div(fw_fcoe_stats->fcoe_tx_byte_cnt, 1000000);
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
+	/* Be sure all responses have been written to PI */
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
+	struct qedf_io_work *io_work;
+	int num_handled = 0;
+	unsigned int cpu;
+	struct qedf_ioreq *io_req = NULL;
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
+		io_work = mempool_alloc(qedf->io_mempool, GFP_ATOMIC);
+		if (!io_work) {
+			QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate "
+				   "work for I/O completion.\n");
+			continue;
+		}
+		memset(io_work, 0, sizeof(struct qedf_io_work));
+
+		INIT_WORK(&io_work->work, qedf_fp_io_handler);
+
+		/* Copy contents of CQE for deferred processing */
+		memcpy(&io_work->cqe, cqe, sizeof(struct fcoe_cqe));
+
+		io_work->qedf = fp->qedf;
+		io_work->fp = NULL; /* Only used for unsolicited frames */
+
+		queue_work_on(cpu, qedf_io_wq, &io_work->work);
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
+
+			/* Check for more work */
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
+	}
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
+	fcport = qedf_fcport_lookup(qedf, ntoh24(fh->fh_d_id));
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
+static void qedf_ll2_process_skb(struct work_struct *work)
+{
+	struct qedf_skb_work *skb_work =
+	    container_of(work, struct qedf_skb_work, work);
+	struct qedf_ctx *qedf = skb_work->qedf;
+	struct sk_buff *skb = skb_work->skb;
+	struct ethhdr *eh;
+
+	if (!qedf) {
+		QEDF_ERR(NULL, "qedf is NULL\n");
+		goto err_out;
+	}
+
+	eh = (struct ethhdr *)skb->data;
+
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
+	kfree(skb_work);
+	return;
+}
+
+static int qedf_ll2_rx(void *cookie, struct sk_buff *skb,
+	u32 arg1, u32 arg2)
+{
+	struct qedf_ctx *qedf = (struct qedf_ctx *)cookie;
+	struct qedf_skb_work *skb_work;
+
+	skb_work = kzalloc(sizeof(struct qedf_skb_work), GFP_ATOMIC);
+	if (!skb_work) {
+		QEDF_WARN(&(qedf->dbg_ctx), "Could not allocate skb_work so "
+			   "dropping frame.\n");
+		kfree_skb(skb);
+		return 0;
+	}
+
+	INIT_WORK(&skb_work->work, qedf_ll2_process_skb);
+	skb_work->skb = skb;
+	skb_work->qedf = qedf;
+	queue_work(qedf->ll2_recv_wq, &skb_work->work);
+
+	return 0;
+}
+
+static struct qed_ll2_cb_ops qedf_ll2_cb_ops = {
+	.rx_cb = qedf_ll2_rx,
+	.tx_cb = NULL,
+};
+
+/* Main thread to process I/O completions */
+void qedf_fp_io_handler(struct work_struct *work)
+{
+	struct qedf_io_work *io_work =
+	    container_of(work, struct qedf_io_work, work);
+	u32 comp_type;
+
+	/*
+	 * Deferred part of unsolicited CQE sends
+	 * frame to libfc.
+	 */
+	comp_type = (io_work->cqe.cqe_data >>
+	    FCOE_CQE_CQE_TYPE_SHIFT) &
+	    FCOE_CQE_CQE_TYPE_MASK;
+	if (comp_type == FCOE_UNSOLIC_CQE_TYPE &&
+	    io_work->fp)
+		fc_exch_recv(io_work->qedf->lport, io_work->fp);
+	else
+		qedf_process_cqe(io_work->qedf, &io_work->cqe);
+
+	kfree(io_work);
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
+	int rc = -EINVAL;
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
+		INIT_LIST_HEAD(&qedf->fcports);
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
+	 * 	status block allocation
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
+	qedf->ll2_recv_wq =
+		create_singlethread_workqueue(host_buf);
+	if (!qedf->ll2_recv_wq) {
+		QEDF_ERR(&(qedf->dbg_ctx), "Failed to LL2 workqueue.\n");
+		goto err7;
+	}
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
+	if (qedf->ll2_recv_wq)
+		destroy_workqueue(qedf->ll2_recv_wq);
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
+	if (qedf->ll2_recv_wq)
+		destroy_workqueue(qedf->ll2_recv_wq);
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
+ * Module Init/Remove
+ */
+
+static int __init qedf_init(void)
+{
+	int ret;
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
+	qedf_io_wq = create_workqueue("qedf_io_wq");
+	if (!qedf_io_wq) {
+		QEDF_ERR(NULL, "Could not create qedf_io_wq.\n");
+		goto err4;
+	}
+
+	qedf_cb_ops.get_login_failures = qedf_get_login_failures;
+
+	ret = pci_register_driver(&qedf_pci_driver);
+	if (ret) {
+		QEDF_ERR(NULL, "Failed to register driver\n");
+		goto err5;
+	}
+
+	return 0;
+
+err5:
+	destroy_workqueue(qedf_io_wq);
+err4:
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
+	pci_unregister_driver(&qedf_pci_driver);
+
+	destroy_workqueue(qedf_io_wq);
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
