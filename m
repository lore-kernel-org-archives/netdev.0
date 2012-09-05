From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: [V2 PATCH 6/9] csiostor: Chelsio FCoE offload driver submission (headers part 1).
Date: Wed,  5 Sep 2012 18:03:59 +0530
Message-ID: <1346848442-4573-7-git-send-email-naresh@chelsio.com>
References: <1346848442-4573-1-git-send-email-naresh@chelsio.com>
Cc: netdev@vger.kernel.org, naresh@chelsio.com, chethan@chelsio.com
To: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9120 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753908Ab2IEHAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 03:00:38 -0400
In-Reply-To: <1346848442-4573-1-git-send-email-naresh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains the first set of the header files for csiostor driver.

Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
---
V2:
- Removed csio_fcoe_proto.h, using defines from include/scsi/fc instead.
- Removed driver-specific return values, using errno values instead.
- Retained CSIO_INC_STATS, since it is useful in multiple places and
  the name of the structure has been standardized to make use of this macro.
- Removed csio_deq_from_head(), replaced it inline with calls from list.h.
- Removed csio_deq_from_tail().
- Replaced state machine macros with static functions.
- Capitalizing macros with CPP keys.

 drivers/scsi/csiostor/csio_defs.h     |  113 ++++++
 drivers/scsi/csiostor/csio_hw.h       |  666 +++++++++++++++++++++++++++++++++
 drivers/scsi/csiostor/csio_init.h     |  158 ++++++++
 drivers/scsi/csiostor/t4fw_api_stor.h |  578 ++++++++++++++++++++++++++++
 4 files changed, 1515 insertions(+), 0 deletions(-)
 create mode 100644 drivers/scsi/csiostor/csio_defs.h
 create mode 100644 drivers/scsi/csiostor/csio_hw.h
 create mode 100644 drivers/scsi/csiostor/csio_init.h
 create mode 100644 drivers/scsi/csiostor/t4fw_api_stor.h

diff --git a/drivers/scsi/csiostor/csio_defs.h b/drivers/scsi/csiostor/csio_defs.h
new file mode 100644
index 0000000..5a82f63
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_defs.h
@@ -0,0 +1,113 @@
+/*
+ * This file is part of the Chelsio FCoE driver for Linux.
+ *
+ * Copyright (c) 2008-2012 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
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
+#ifndef __CSIO_DEFS_H__
+#define __CSIO_DEFS_H__
+
+#include <linux/kernel.h>
+#include <linux/stddef.h>
+#include <linux/timer.h>
+#include <linux/list.h>
+#include <linux/bug.h>
+#include <linux/pci.h>
+#include <linux/jiffies.h>
+
+#define CSIO_ROUNDUP(__v, __r)		(((__v) + (__r) - 1) / (__r))
+#define CSIO_INVALID_IDX		0xFFFFFFFF
+#define CSIO_INC_STATS(elem, val)	((elem)->stats.val++)
+#define CSIO_DEC_STATS(elem, val)	((elem)->stats.val--)
+#define CSIO_VALID_WWN(__n)		((*__n >> 4) == 0x5 ? true : false)
+#define CSIO_DID_MASK			0xFFFFFF
+#define CSIO_WORD_TO_BYTE		4
+
+static inline int
+csio_list_deleted(struct list_head *list)
+{
+	return ((list->next == list) && (list->prev == list));
+}
+
+#define csio_list_next(elem)	(((struct list_head *)(elem))->next)
+#define csio_list_prev(elem)	(((struct list_head *)(elem))->prev)
+
+/* State machine */
+typedef void (*csio_sm_state_t)(void *, uint32_t);
+
+struct csio_sm {
+	struct list_head	sm_list;
+	csio_sm_state_t		sm_state;
+};
+
+static inline void
+csio_set_state(void *smp, void *state)
+{
+	((struct csio_sm *)smp)->sm_state = (csio_sm_state_t)state;
+}
+
+static inline void
+csio_init_state(struct csio_sm *smp, void *state)
+{
+	csio_set_state(smp, state);
+}
+
+static inline void
+csio_post_event(void *smp, uint32_t evt)
+{
+	((struct csio_sm *)smp)->sm_state(smp, evt);
+}
+
+static inline csio_sm_state_t
+csio_get_state(void *smp)
+{
+	return ((struct csio_sm *)smp)->sm_state;
+}
+
+static inline bool
+csio_match_state(void *smp, void *state)
+{
+	return (csio_get_state(smp) == (csio_sm_state_t)state);
+}
+
+#define	CSIO_ASSERT(cond)						\
+do {									\
+	if (unlikely(!((cond))))					\
+		BUG();                                                  \
+} while (0)
+
+#ifdef __CSIO_DEBUG__
+#define CSIO_DB_ASSERT(__c)		CSIO_ASSERT((__c))
+#else
+#define CSIO_DB_ASSERT(__c)
+#endif
+
+#endif /* ifndef __CSIO_DEFS_H__ */
diff --git a/drivers/scsi/csiostor/csio_hw.h b/drivers/scsi/csiostor/csio_hw.h
new file mode 100644
index 0000000..a58fdc9
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_hw.h
@@ -0,0 +1,666 @@
+/*
+ * This file is part of the Chelsio FCoE driver for Linux.
+ *
+ * Copyright (c) 2008-2012 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
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
+#ifndef __CSIO_HW_H__
+#define __CSIO_HW_H__
+
+#include <linux/kernel.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/workqueue.h>
+#include <linux/compiler.h>
+#include <linux/cdev.h>
+#include <linux/list.h>
+#include <linux/mempool.h>
+#include <linux/io.h>
+#include <linux/spinlock_types.h>
+#include <scsi/scsi_transport_fc.h>
+
+#include "csio_wr.h"
+#include "csio_mb.h"
+#include "csio_scsi.h"
+#include "csio_defs.h"
+#include "t4_regs.h"
+#include "t4_msg.h"
+
+/*
+ * An error value used by host. Should not clash with FW defined return values.
+ */
+#define	FW_HOSTERROR			255
+
+#define CSIO_FW_FNAME		"cxgb4/t4fw.bin"
+#define CSIO_CF_FNAME		"cxgb4/t4-config.txt"
+
+#define FW_VERSION_MAJOR	1
+#define FW_VERSION_MINOR	2
+#define FW_VERSION_MICRO	8
+
+#define CSIO_HW_NAME		"Chelsio FCoE Adapter"
+#define CSIO_MAX_PFN		8
+#define CSIO_MAX_PPORTS		4
+
+#define CSIO_MAX_LUN		0xFFFF
+#define CSIO_MAX_QUEUE		2048
+#define CSIO_MAX_CMD_PER_LUN	32
+#define CSIO_MAX_DDP_BUF_SIZE	(1024 * 1024)
+#define CSIO_MAX_SECTOR_SIZE	128
+
+/* Interrupts */
+#define CSIO_EXTRA_MSI_IQS	2	/* Extra iqs for INTX/MSI mode
+					 * (Forward intr iq + fw iq) */
+#define CSIO_EXTRA_VECS		2	/* non-data + FW evt */
+#define CSIO_MAX_SCSI_CPU	128
+#define CSIO_MAX_SCSI_QSETS	(CSIO_MAX_SCSI_CPU * CSIO_MAX_PPORTS)
+#define CSIO_MAX_MSIX_VECS	(CSIO_MAX_SCSI_QSETS + CSIO_EXTRA_VECS)
+
+/* Queues */
+enum {
+	CSIO_INTR_WRSIZE = 128,
+	CSIO_INTR_IQSIZE = ((CSIO_MAX_MSIX_VECS + 1) * CSIO_INTR_WRSIZE),
+	CSIO_FWEVT_WRSIZE = 128,
+	CSIO_FWEVT_IQLEN = 128,
+	CSIO_FWEVT_FLBUFS = 64,
+	CSIO_FWEVT_IQSIZE = (CSIO_FWEVT_WRSIZE * CSIO_FWEVT_IQLEN),
+	CSIO_HW_NIQ = 1,
+	CSIO_HW_NFLQ = 1,
+	CSIO_HW_NEQ = 1,
+	CSIO_HW_NINTXQ = 1,
+};
+
+struct csio_msix_entries {
+	unsigned short	vector;		/* Vector assigned by pci_enable_msix */
+	void		*dev_id;	/* Priv object associated w/ this msix*/
+	char		desc[24];	/* Description of this vector */
+};
+
+struct csio_scsi_qset {
+	int		iq_idx;		/* Ingress index */
+	int		eq_idx;		/* Egress index */
+	uint32_t	intr_idx;	/* MSIX Vector index */
+};
+
+struct csio_scsi_cpu_info {
+	int16_t	max_cpus;
+};
+
+extern int csio_dbg_level;
+extern int csio_force_master;
+extern unsigned int csio_port_mask;
+extern int csio_msi;
+
+#define CSIO_VENDOR_ID				0x1425
+#define CSIO_ASIC_DEVID_PROTO_MASK		0xFF00
+#define CSIO_ASIC_DEVID_TYPE_MASK		0x00FF
+#define CSIO_FPGA				0xA000
+#define CSIO_T4_FCOE_ASIC			0x4600
+
+#define CSIO_GLBL_INTR_MASK		(CIM | MPS | PL | PCIE | MC | EDC0 | \
+					 EDC1 | LE | TP | MA | PM_TX | PM_RX | \
+					 ULP_RX | CPL_SWITCH | SGE | \
+					 ULP_TX | SF)
+
+/*
+ * Hard parameters used to initialize the card in the absence of a
+ * configuration file.
+ */
+enum {
+	/* General */
+	CSIO_SGE_DBFIFO_INT_THRESH	= 10,
+
+	CSIO_SGE_RX_DMA_OFFSET		= 2,
+
+	CSIO_SGE_FLBUF_SIZE1		= 65536,
+	CSIO_SGE_FLBUF_SIZE2		= 1536,
+	CSIO_SGE_FLBUF_SIZE3		= 9024,
+	CSIO_SGE_FLBUF_SIZE4		= 9216,
+	CSIO_SGE_FLBUF_SIZE5		= 2048,
+	CSIO_SGE_FLBUF_SIZE6		= 128,
+	CSIO_SGE_FLBUF_SIZE7		= 8192,
+	CSIO_SGE_FLBUF_SIZE8		= 16384,
+
+	CSIO_SGE_TIMER_VAL_0		= 5,
+	CSIO_SGE_TIMER_VAL_1		= 10,
+	CSIO_SGE_TIMER_VAL_2		= 20,
+	CSIO_SGE_TIMER_VAL_3		= 50,
+	CSIO_SGE_TIMER_VAL_4		= 100,
+	CSIO_SGE_TIMER_VAL_5		= 200,
+
+	CSIO_SGE_INT_CNT_VAL_0		= 1,
+	CSIO_SGE_INT_CNT_VAL_1		= 4,
+	CSIO_SGE_INT_CNT_VAL_2		= 8,
+	CSIO_SGE_INT_CNT_VAL_3		= 16,
+
+	/* Storage specific - used by FW_PFVF_CMD */
+	CSIO_WX_CAPS			= FW_CMD_CAP_PF, /* w/x all */
+	CSIO_R_CAPS			= FW_CMD_CAP_PF, /* r all */
+	CSIO_NVI			= 4,
+	CSIO_NIQ_FLINT			= 34,
+	CSIO_NETH_CTRL			= 32,
+	CSIO_NEQ			= 66,
+	CSIO_NEXACTF			= 32,
+	CSIO_CMASK			= FW_PFVF_CMD_CMASK_MASK,
+	CSIO_PMASK			= FW_PFVF_CMD_PMASK_MASK,
+};
+
+/* Slowpath events */
+enum csio_evt {
+	CSIO_EVT_FW  = 0,	/* FW event */
+	CSIO_EVT_MBX,		/* MBX event */
+	CSIO_EVT_SCN,		/* State change notification */
+	CSIO_EVT_DEV_LOSS,	/* Device loss event */
+	CSIO_EVT_MAX,		/* Max supported event */
+};
+
+#define CSIO_EVT_MSG_SIZE	512
+#define CSIO_EVTQ_SIZE		512
+
+/* Event msg  */
+struct csio_evt_msg {
+	struct list_head	list;	/* evt queue*/
+	enum csio_evt		type;
+	uint8_t			data[CSIO_EVT_MSG_SIZE];
+};
+
+enum {
+	EEPROMVSIZE    = 32768, /* Serial EEPROM virtual address space size */
+	SERNUM_LEN     = 16,    /* Serial # length */
+	EC_LEN         = 16,    /* E/C length */
+	ID_LEN         = 16,    /* ID length */
+	TRACE_LEN      = 112,   /* length of trace data and mask */
+};
+
+enum {
+	SF_PAGE_SIZE = 256,           /* serial flash page size */
+	SF_SEC_SIZE = 64 * 1024,      /* serial flash sector size */
+	SF_SIZE = SF_SEC_SIZE * 16,   /* serial flash size */
+};
+
+enum { MEM_EDC0, MEM_EDC1, MEM_MC };
+
+enum {
+	MEMWIN0_APERTURE = 2048,
+	MEMWIN0_BASE     = 0x1b800,
+	MEMWIN1_APERTURE = 32768,
+	MEMWIN1_BASE     = 0x28000,
+	MEMWIN2_APERTURE = 65536,
+	MEMWIN2_BASE     = 0x30000,
+};
+
+/* serial flash and firmware constants */
+enum {
+	SF_ATTEMPTS = 10,             /* max retries for SF operations */
+
+	/* flash command opcodes */
+	SF_PROG_PAGE    = 2,          /* program page */
+	SF_WR_DISABLE   = 4,          /* disable writes */
+	SF_RD_STATUS    = 5,          /* read status register */
+	SF_WR_ENABLE    = 6,          /* enable writes */
+	SF_RD_DATA_FAST = 0xb,        /* read flash */
+	SF_RD_ID	= 0x9f,	      /* read ID */
+	SF_ERASE_SECTOR = 0xd8,       /* erase sector */
+
+	FW_START_SEC = 8,             /* first flash sector for FW */
+	FW_END_SEC = 15,              /* last flash sector for FW */
+	FW_IMG_START = FW_START_SEC * SF_SEC_SIZE,
+	FW_MAX_SIZE = (FW_END_SEC - FW_START_SEC + 1) * SF_SEC_SIZE,
+
+	FLASH_CFG_MAX_SIZE    = 0x10000 , /* max size of the flash config file*/
+	FLASH_CFG_OFFSET      = 0x1f0000,
+	FLASH_CFG_START_SEC   = FLASH_CFG_OFFSET / SF_SEC_SIZE,
+	FPGA_FLASH_CFG_OFFSET = 0xf0000 , /* if FPGA mode, then cfg file is
+					   * at 1MB - 64KB */
+	FPGA_FLASH_CFG_START_SEC  = FPGA_FLASH_CFG_OFFSET / SF_SEC_SIZE,
+};
+
+/*
+ * Flash layout.
+ */
+#define FLASH_START(start)	((start) * SF_SEC_SIZE)
+#define FLASH_MAX_SIZE(nsecs)	((nsecs) * SF_SEC_SIZE)
+
+enum {
+	/*
+	 * Location of firmware image in FLASH.
+	 */
+	FLASH_FW_START_SEC = 8,
+	FLASH_FW_NSECS = 8,
+	FLASH_FW_START = FLASH_START(FLASH_FW_START_SEC),
+	FLASH_FW_MAX_SIZE = FLASH_MAX_SIZE(FLASH_FW_NSECS),
+
+};
+
+#undef FLASH_START
+#undef FLASH_MAX_SIZE
+
+/* Management module */
+enum {
+	CSIO_MGMT_EQ_WRSIZE = 512,
+	CSIO_MGMT_IQ_WRSIZE = 128,
+	CSIO_MGMT_EQLEN = 64,
+	CSIO_MGMT_IQLEN = 64,
+};
+
+#define CSIO_MGMT_EQSIZE	(CSIO_MGMT_EQLEN * CSIO_MGMT_EQ_WRSIZE)
+#define CSIO_MGMT_IQSIZE	(CSIO_MGMT_IQLEN * CSIO_MGMT_IQ_WRSIZE)
+
+/* mgmt module stats */
+struct csio_mgmtm_stats {
+	uint32_t	n_abort_req;		/* Total abort request */
+	uint32_t	n_abort_rsp;		/* Total abort response */
+	uint32_t	n_close_req;		/* Total close request */
+	uint32_t	n_close_rsp;		/* Total close response */
+	uint32_t	n_err;			/* Total Errors */
+	uint32_t	n_drop;			/* Total request dropped */
+	uint32_t	n_active;		/* Count of active_q */
+	uint32_t	n_cbfn;			/* Count of cbfn_q */
+};
+
+/* MGMT module */
+struct csio_mgmtm {
+	struct	csio_hw		*hw;		/* Pointer to HW moduel */
+	int			eq_idx;		/* Egress queue index */
+	int			iq_idx;		/* Ingress queue index */
+	int			msi_vec;	/* MSI vector */
+	struct list_head	active_q;	/* Outstanding ELS/CT */
+	struct list_head	abort_q;	/* Outstanding abort req */
+	struct list_head	cbfn_q;		/* Completion queue */
+	struct list_head	mgmt_req_freelist; /* Free poll of reqs */
+						/* ELSCT request freelist*/
+	struct timer_list	mgmt_timer;	/* MGMT timer */
+	struct csio_mgmtm_stats stats;		/* ELS/CT stats */
+};
+
+struct csio_adap_desc {
+	char model_no[16];
+	char description[32];
+};
+
+struct pci_params {
+	uint16_t   vendor_id;
+	uint16_t   device_id;
+	uint32_t   vpd_cap_addr;
+	uint16_t   speed;
+	uint8_t    width;
+};
+
+/* User configurable hw parameters */
+struct csio_hw_params {
+	uint32_t		sf_size;		/* serial flash
+							 * size in bytes
+							 */
+	uint32_t		sf_nsec;		/* # of flash sectors */
+	struct pci_params	pci;
+	uint32_t		log_level;		/* Module-level for
+							 * debug log.
+							 */
+};
+
+struct csio_vpd {
+	uint32_t cclk;
+	uint8_t ec[EC_LEN + 1];
+	uint8_t sn[SERNUM_LEN + 1];
+	uint8_t id[ID_LEN + 1];
+};
+
+struct csio_pport {
+	uint16_t	pcap;
+	uint8_t		portid;
+	uint8_t		link_status;
+	uint16_t	link_speed;
+	uint8_t		mac[6];
+	uint8_t		mod_type;
+	uint8_t		rsvd1;
+	uint8_t		rsvd2;
+	uint8_t		rsvd3;
+};
+
+/* fcoe resource information */
+struct csio_fcoe_res_info {
+	uint16_t	e_d_tov;
+	uint16_t	r_a_tov_seq;
+	uint16_t	r_a_tov_els;
+	uint16_t	r_r_tov;
+	uint32_t	max_xchgs;
+	uint32_t	max_ssns;
+	uint32_t	used_xchgs;
+	uint32_t	used_ssns;
+	uint32_t	max_fcfs;
+	uint32_t	max_vnps;
+	uint32_t	used_fcfs;
+	uint32_t	used_vnps;
+};
+
+/* HW State machine Events */
+enum csio_hw_ev {
+	CSIO_HWE_CFG = (uint32_t)1, /* Starts off the State machine */
+	CSIO_HWE_INIT,	         /* Config done, start Init      */
+	CSIO_HWE_INIT_DONE,      /* Init Mailboxes sent, HW ready */
+	CSIO_HWE_FATAL,		 /* Fatal error during initialization */
+	CSIO_HWE_PCIERR_DETECTED,/* PCI error recovery detetced */
+	CSIO_HWE_PCIERR_SLOT_RESET, /* Slot reset after PCI recoviery */
+	CSIO_HWE_PCIERR_RESUME,  /* Resume after PCI error recovery */
+	CSIO_HWE_QUIESCED,	 /* HBA quiesced */
+	CSIO_HWE_HBA_RESET,      /* HBA reset requested */
+	CSIO_HWE_HBA_RESET_DONE, /* HBA reset completed */
+	CSIO_HWE_FW_DLOAD,       /* FW download requested */
+	CSIO_HWE_PCI_REMOVE,     /* PCI de-instantiation */
+	CSIO_HWE_SUSPEND,        /* HW suspend for Online(hot) replacement */
+	CSIO_HWE_RESUME,         /* HW resume for Online(hot) replacement */
+	CSIO_HWE_MAX,		 /* Max HW event */
+};
+
+/* hw stats */
+struct csio_hw_stats {
+	uint32_t	n_evt_activeq;	/* Number of event in active Q */
+	uint32_t	n_evt_freeq;	/* Number of event in free Q */
+	uint32_t	n_evt_drop;	/* Number of event droped */
+	uint32_t	n_evt_unexp;	/* Number of unexpected events */
+	uint32_t	n_pcich_offline;/* Number of pci channel offline */
+	uint32_t	n_lnlkup_miss;  /* Number of lnode lookup miss */
+	uint32_t	n_cpl_fw6_msg;	/* Number of cpl fw6 message*/
+	uint32_t	n_cpl_fw6_pld;	/* Number of cpl fw6 payload*/
+	uint32_t	n_cpl_unexp;	/* Number of unexpected cpl */
+	uint32_t	n_mbint_unexp;	/* Number of unexpected mbox */
+					/* interrupt */
+	uint32_t	n_plint_unexp;	/* Number of unexpected PL */
+					/* interrupt */
+	uint32_t	n_plint_cnt;	/* Number of PL interrupt */
+	uint32_t	n_int_stray;	/* Number of stray interrupt */
+	uint32_t	n_err;		/* Number of hw errors */
+	uint32_t	n_err_fatal;	/* Number of fatal errors */
+	uint32_t	n_err_nomem;	/* Number of memory alloc failure */
+	uint32_t	n_err_io;	/* Number of IO failure */
+	enum csio_hw_ev	n_evt_sm[CSIO_HWE_MAX];	/* Number of sm events */
+	uint64_t	n_reset_start;  /* Start time after the reset */
+	uint32_t	rsvd1;
+};
+
+/* Defines for hw->flags */
+#define CSIO_HWF_MASTER			0x00000001	/* This is the Master
+							 * function for the
+							 * card.
+							 */
+#define	CSIO_HWF_HW_INTR_ENABLED	0x00000002	/* Are HW Interrupt
+							 * enable bit set?
+							 */
+#define	CSIO_HWF_FWEVT_PENDING		0x00000004	/* FW events pending */
+#define	CSIO_HWF_Q_MEM_ALLOCED		0x00000008	/* Queues have been
+							 * allocated memory.
+							 */
+#define	CSIO_HWF_Q_FW_ALLOCED		0x00000010	/* Queues have been
+							 * allocated in FW.
+							 */
+#define CSIO_HWF_VPD_VALID		0x00000020	/* Valid VPD copied */
+#define CSIO_HWF_DEVID_CACHED		0X00000040	/* PCI vendor & device
+							 * id cached */
+#define	CSIO_HWF_FWEVT_STOP		0x00000080	/* Stop processing
+							 * FW events
+							 */
+#define CSIO_HWF_USING_SOFT_PARAMS	0x00000100      /* Using FW config
+							 * params
+							 */
+#define	CSIO_HWF_HOST_INTR_ENABLED	0x00000200	/* Are host interrupts
+							 * enabled?
+							 */
+
+#define csio_is_hw_intr_enabled(__hw)	\
+				((__hw)->flags & CSIO_HWF_HW_INTR_ENABLED)
+#define csio_is_host_intr_enabled(__hw)	\
+				((__hw)->flags & CSIO_HWF_HOST_INTR_ENABLED)
+#define csio_is_hw_master(__hw)		((__hw)->flags & CSIO_HWF_MASTER)
+#define csio_is_valid_vpd(__hw)		((__hw)->flags & CSIO_HWF_VPD_VALID)
+#define csio_is_dev_id_cached(__hw)	((__hw)->flags & CSIO_HWF_DEVID_CACHED)
+#define csio_valid_vpd_copied(__hw)	((__hw)->flags |= CSIO_HWF_VPD_VALID)
+#define csio_dev_id_cached(__hw)	((__hw)->flags |= CSIO_HWF_DEVID_CACHED)
+
+/* Defines for intr_mode */
+enum csio_intr_mode {
+	CSIO_IM_NONE = 0,
+	CSIO_IM_INTX = 1,
+	CSIO_IM_MSI  = 2,
+	CSIO_IM_MSIX = 3,
+};
+
+/* Master HW structure: One per function */
+struct csio_hw {
+	struct csio_sm		sm;			/* State machine: should
+							 * be the 1st member.
+							 */
+	spinlock_t		lock;			/* Lock for hw */
+
+	struct csio_scsim	scsim;			/* SCSI module*/
+	struct csio_wrm		wrm;			/* Work request module*/
+	struct pci_dev		*pdev;			/* PCI device */
+
+	void __iomem		*regstart;		/* Virtual address of
+							 * register map
+							 */
+	/* SCSI queue sets */
+	uint32_t		num_sqsets;		/* Number of SCSI
+							 * queue sets */
+	uint32_t		num_scsi_msix_cpus;	/* Number of CPUs that
+							 * will be used
+							 * for ingress
+							 * processing.
+							 */
+
+	struct csio_scsi_qset	sqset[CSIO_MAX_PPORTS][CSIO_MAX_SCSI_CPU];
+	struct csio_scsi_cpu_info scsi_cpu_info[CSIO_MAX_PPORTS];
+
+	uint32_t		evtflag;		/* Event flag  */
+	uint32_t		flags;			/* HW flags */
+
+	struct csio_mgmtm	mgmtm;			/* management module */
+	struct csio_mbm		mbm;			/* Mailbox module */
+
+	/* Lnodes */
+	uint32_t		num_lns;		/* Number of lnodes */
+	struct csio_lnode	*rln;			/* Root lnode */
+	struct list_head	sln_head;		/* Sibling node list
+							 * list
+							 */
+	int			intr_iq_idx;		/* Forward interrupt
+							 * queue.
+							 */
+	int			fwevt_iq_idx;		/* FW evt queue */
+	struct work_struct	evtq_work;		/* Worker thread for
+							 * HW events.
+							 */
+	struct list_head	evt_free_q;		/* freelist of evt
+							 * elements
+							 */
+	struct list_head	evt_active_q;		/* active evt queue*/
+
+	/* board related info */
+	char			name[32];
+	char			hw_ver[16];
+	char			model_desc[32];
+	char			drv_version[32];
+	char			fwrev_str[32];
+	uint32_t		optrom_ver;
+	uint32_t		fwrev;
+	uint32_t		tp_vers;
+	char			chip_ver;
+	uint32_t		cfg_finiver;
+	uint32_t		cfg_finicsum;
+	uint32_t		cfg_cfcsum;
+	uint8_t			cfg_csum_status;
+	uint8_t			cfg_store;
+	enum csio_dev_state	fw_state;
+	struct csio_vpd		vpd;
+
+	uint8_t			pfn;			/* Physical Function
+							 * number
+							 */
+	uint32_t		port_vec;		/* Port vector */
+	uint8_t			num_pports;		/* Number of physical
+							 * ports.
+							 */
+	uint8_t			rst_retries;		/* Reset retries */
+	uint8_t			cur_evt;		/* current s/m evt */
+	uint8_t			prev_evt;		/* Previous s/m evt */
+	uint32_t		dev_num;		/* device number */
+	struct csio_pport	pport[CSIO_MAX_PPORTS];	/* Ports (XGMACs) */
+	struct csio_hw_params	params;			/* Hw parameters */
+
+	struct pci_pool		*scsi_pci_pool;		/* PCI pool for SCSI */
+	mempool_t		*mb_mempool;		/* Mailbox memory pool*/
+	mempool_t		*rnode_mempool;		/* rnode memory pool */
+
+	/* Interrupt */
+	enum csio_intr_mode	intr_mode;		/* INTx, MSI, MSIX */
+	uint32_t		fwevt_intr_idx;		/* FW evt MSIX/interrupt
+							 * index
+							 */
+	uint32_t		nondata_intr_idx;	/* nondata MSIX/intr
+							 * idx
+							 */
+
+	uint8_t			cfg_neq;		/* FW configured no of
+							 * egress queues
+							 */
+	uint8_t			cfg_niq;		/* FW configured no of
+							 * iq queues.
+							 */
+
+	struct csio_fcoe_res_info  fres_info;		/* Fcoe resource info */
+
+	/* MSIX vectors */
+	struct csio_msix_entries msix_entries[CSIO_MAX_MSIX_VECS];
+
+	struct dentry		*debugfs_root;		/* Debug FS */
+	struct csio_hw_stats	stats;			/* Hw statistics */
+};
+
+/* Register access macros */
+#define csio_reg(_b, _r)		((_b) + (_r))
+
+#define	csio_rd_reg8(_h, _r)		readb(csio_reg((_h)->regstart, (_r)))
+#define	csio_rd_reg16(_h, _r)		readw(csio_reg((_h)->regstart, (_r)))
+#define	csio_rd_reg32(_h, _r)		readl(csio_reg((_h)->regstart, (_r)))
+#define	csio_rd_reg64(_h, _r)		readq(csio_reg((_h)->regstart, (_r)))
+
+#define	csio_wr_reg8(_h, _v, _r)	writeb((_v), \
+						csio_reg((_h)->regstart, (_r)))
+#define	csio_wr_reg16(_h, _v, _r)	writew((_v), \
+						csio_reg((_h)->regstart, (_r)))
+#define	csio_wr_reg32(_h, _v, _r)	writel((_v), \
+						csio_reg((_h)->regstart, (_r)))
+#define	csio_wr_reg64(_h, _v, _r)	writeq((_v), \
+						csio_reg((_h)->regstart, (_r)))
+
+void csio_set_reg_field(struct csio_hw *, uint32_t, uint32_t, uint32_t);
+
+/* Core clocks <==> uSecs */
+static inline uint32_t
+csio_core_ticks_to_us(struct csio_hw *hw, uint32_t ticks)
+{
+	/* add Core Clock / 2 to round ticks to nearest uS */
+	return (ticks * 1000 + hw->vpd.cclk/2) / hw->vpd.cclk;
+}
+
+static inline uint32_t
+csio_us_to_core_ticks(struct csio_hw *hw, uint32_t us)
+{
+	return (us * hw->vpd.cclk) / 1000;
+}
+
+/* Easy access macros */
+#define csio_hw_to_wrm(hw)		((struct csio_wrm *)(&(hw)->wrm))
+#define csio_hw_to_mbm(hw)		((struct csio_mbm *)(&(hw)->mbm))
+#define csio_hw_to_scsim(hw)		((struct csio_scsim *)(&(hw)->scsim))
+#define csio_hw_to_mgmtm(hw)		((struct csio_mgmtm *)(&(hw)->mgmtm))
+
+#define CSIO_PCI_BUS(hw)		((hw)->pdev->bus->number)
+#define CSIO_PCI_DEV(hw)		(PCI_SLOT((hw)->pdev->devfn))
+#define CSIO_PCI_FUNC(hw)		(PCI_FUNC((hw)->pdev->devfn))
+
+#define csio_set_fwevt_intr_idx(_h, _i)		((_h)->fwevt_intr_idx = (_i))
+#define csio_get_fwevt_intr_idx(_h)		((_h)->fwevt_intr_idx)
+#define csio_set_nondata_intr_idx(_h, _i)	((_h)->nondata_intr_idx = (_i))
+#define csio_get_nondata_intr_idx(_h)		((_h)->nondata_intr_idx)
+
+/* Printing/logging */
+#define CSIO_DEVID(__dev)		((__dev)->dev_num)
+#define CSIO_DEVID_LO(__dev)		(CSIO_DEVID((__dev)) & 0xFFFF)
+#define CSIO_DEVID_HI(__dev)		((CSIO_DEVID((__dev)) >> 16) & 0xFFFF)
+
+#define csio_info(__hw, __fmt, ...)					\
+			dev_info(&(__hw)->pdev->dev, __fmt, ##__VA_ARGS__)
+
+#define csio_fatal(__hw, __fmt, ...)					\
+			dev_crit(&(__hw)->pdev->dev, __fmt, ##__VA_ARGS__)
+
+#define csio_err(__hw, __fmt, ...)					\
+			dev_err(&(__hw)->pdev->dev, __fmt, ##__VA_ARGS__)
+
+#define csio_warn(__hw, __fmt, ...)					\
+			dev_warn(&(__hw)->pdev->dev, __fmt, ##__VA_ARGS__)
+
+#ifdef __CSIO_DEBUG__
+#define csio_dbg(__hw, __fmt, ...)					\
+			csio_info((__hw), __fmt, ##__VA_ARGS__);
+#else
+#define csio_dbg(__hw, __fmt, ...)
+#endif
+
+int csio_mgmt_req_lookup(struct csio_mgmtm *, struct csio_ioreq *);
+void csio_hw_intr_disable(struct csio_hw *);
+int csio_hw_slow_intr_handler(struct csio_hw *hw);
+int csio_hw_start(struct csio_hw *);
+int csio_hw_stop(struct csio_hw *);
+int csio_hw_reset(struct csio_hw *);
+int csio_is_hw_ready(struct csio_hw *);
+int csio_is_hw_removing(struct csio_hw *);
+
+int csio_fwevtq_handler(struct csio_hw *);
+void csio_evtq_worker(struct work_struct *);
+int csio_enqueue_evt(struct csio_hw *hw, enum csio_evt type,
+				void *evt_msg, uint16_t len);
+void csio_evtq_flush(struct csio_hw *hw);
+
+int csio_request_irqs(struct csio_hw *);
+void csio_intr_enable(struct csio_hw *);
+void csio_intr_disable(struct csio_hw *, bool);
+
+struct csio_lnode *csio_lnode_alloc(struct csio_hw *);
+int csio_config_queues(struct csio_hw *);
+
+int csio_hw_mc_read(struct csio_hw *, uint32_t,
+			      uint32_t *, uint64_t *);
+int csio_hw_edc_read(struct csio_hw *, int, uint32_t, uint32_t *,
+			       uint64_t *);
+int csio_hw_init(struct csio_hw *);
+void csio_hw_exit(struct csio_hw *);
+#endif /* ifndef __CSIO_HW_H__ */
diff --git a/drivers/scsi/csiostor/csio_init.h b/drivers/scsi/csiostor/csio_init.h
new file mode 100644
index 0000000..0838fd7
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_init.h
@@ -0,0 +1,158 @@
+/*
+ * This file is part of the Chelsio FCoE driver for Linux.
+ *
+ * Copyright (c) 2008-2012 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
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
+#ifndef __CSIO_INIT_H__
+#define __CSIO_INIT_H__
+
+#include <linux/pci.h>
+#include <linux/if_ether.h>
+#include <scsi/scsi.h>
+#include <scsi/scsi_device.h>
+#include <scsi/scsi_host.h>
+#include <scsi/scsi_transport_fc.h>
+
+#include "csio_scsi.h"
+#include "csio_lnode.h"
+#include "csio_rnode.h"
+#include "csio_hw.h"
+
+#define CSIO_DRV_AUTHOR			"Chelsio Communications"
+#define CSIO_DRV_LICENSE		"Dual BSD/GPL"
+#define CSIO_DRV_DESC			"Chelsio FCoE driver"
+#define CSIO_DRV_VERSION		"1.0.0"
+
+#define CSIO_DEVICE(devid, idx)					\
+{ PCI_VENDOR_ID_CHELSIO, (devid), PCI_ANY_ID, PCI_ANY_ID, 0, 0, (idx) }
+
+#define CSIO_IS_T4_FPGA(_dev)		(((_dev) == CSIO_DEVID_PE10K) ||\
+					 ((_dev) == CSIO_DEVID_PE10K_PF1))
+
+/* FCoE device IDs */
+#define CSIO_DEVID_PE10K		0xA000
+#define CSIO_DEVID_PE10K_PF1		0xA001
+#define CSIO_DEVID_T440DBG_FCOE		0x4600
+#define CSIO_DEVID_T420CR_FCOE		0x4601
+#define CSIO_DEVID_T422CR_FCOE		0x4602
+#define CSIO_DEVID_T440CR_FCOE		0x4603
+#define CSIO_DEVID_T420BCH_FCOE		0x4604
+#define CSIO_DEVID_T440BCH_FCOE		0x4605
+#define CSIO_DEVID_T440CH_FCOE		0x4606
+#define CSIO_DEVID_T420SO_FCOE		0x4607
+#define CSIO_DEVID_T420CX_FCOE		0x4608
+#define CSIO_DEVID_T420BT_FCOE		0x4609
+#define CSIO_DEVID_T404BT_FCOE		0x460A
+#define CSIO_DEVID_B420_FCOE		0x460B
+#define CSIO_DEVID_B404_FCOE		0x460C
+#define CSIO_DEVID_T480CR_FCOE		0x460D
+#define CSIO_DEVID_T440LPCR_FCOE	0x460E
+
+extern struct fc_function_template csio_fc_transport_funcs;
+extern struct fc_function_template csio_fc_transport_vport_funcs;
+
+void csio_fchost_attr_init(struct csio_lnode *);
+
+/* INTx handlers */
+void csio_scsi_intx_handler(struct csio_hw *, void *, uint32_t,
+			       struct csio_fl_dma_buf *, void *);
+
+void csio_fwevt_intx_handler(struct csio_hw *, void *, uint32_t,
+				struct csio_fl_dma_buf *, void *);
+
+/* Common os lnode APIs */
+void csio_lnodes_block_request(struct csio_hw *);
+void csio_lnodes_unblock_request(struct csio_hw *);
+void csio_lnodes_block_by_port(struct csio_hw *, uint8_t);
+void csio_lnodes_unblock_by_port(struct csio_hw *, uint8_t);
+
+struct csio_lnode *csio_shost_init(struct csio_hw *, struct device *, bool,
+					struct csio_lnode *);
+void csio_shost_exit(struct csio_lnode *);
+void csio_lnodes_exit(struct csio_hw *, bool);
+
+static inline struct Scsi_Host *
+csio_ln_to_shost(struct csio_lnode *ln)
+{
+	return container_of((void *)ln, struct Scsi_Host, hostdata[0]);
+}
+
+/* SCSI -- locking version of get/put ioreqs  */
+static inline struct csio_ioreq *
+csio_get_scsi_ioreq_lock(struct csio_hw *hw, struct csio_scsim *scsim)
+{
+	struct csio_ioreq *ioreq;
+	unsigned long flags;
+
+	spin_lock_irqsave(&scsim->freelist_lock, flags);
+	ioreq = csio_get_scsi_ioreq(scsim);
+	spin_unlock_irqrestore(&scsim->freelist_lock, flags);
+
+	return ioreq;
+}
+
+static inline void
+csio_put_scsi_ioreq_lock(struct csio_hw *hw, struct csio_scsim *scsim,
+			 struct csio_ioreq *ioreq)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&scsim->freelist_lock, flags);
+	csio_put_scsi_ioreq(scsim, ioreq);
+	spin_unlock_irqrestore(&scsim->freelist_lock, flags);
+}
+
+/* Called in interrupt context */
+static inline void
+csio_put_scsi_ioreq_list_lock(struct csio_hw *hw, struct csio_scsim *scsim,
+			      struct list_head *reqlist, int n)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&scsim->freelist_lock, flags);
+	csio_put_scsi_ioreq_list(scsim, reqlist, n);
+	spin_unlock_irqrestore(&scsim->freelist_lock, flags);
+}
+
+/* Called in interrupt context */
+static inline void
+csio_put_scsi_ddp_list_lock(struct csio_hw *hw, struct csio_scsim *scsim,
+			      struct list_head *reqlist, int n)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&hw->lock, flags);
+	csio_put_scsi_ddp_list(scsim, reqlist, n);
+	spin_unlock_irqrestore(&hw->lock, flags);
+}
+
+#endif /* ifndef __CSIO_INIT_H__ */
diff --git a/drivers/scsi/csiostor/t4fw_api_stor.h b/drivers/scsi/csiostor/t4fw_api_stor.h
new file mode 100644
index 0000000..b96903a
--- /dev/null
+++ b/drivers/scsi/csiostor/t4fw_api_stor.h
@@ -0,0 +1,578 @@
+/*
+ * This file is part of the Chelsio FCoE driver for Linux.
+ *
+ * Copyright (c) 2009-2010 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
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
+#ifndef _T4FW_API_STOR_H_
+#define _T4FW_API_STOR_H_
+
+
+/******************************************************************************
+ *   R E T U R N   V A L U E S
+ ********************************/
+
+enum fw_retval {
+	FW_SUCCESS		= 0,	/* completed sucessfully */
+	FW_EPERM		= 1,	/* operation not permitted */
+	FW_ENOENT		= 2,	/* no such file or directory */
+	FW_EIO			= 5,	/* input/output error; hw bad */
+	FW_ENOEXEC		= 8,	/* exec format error; inv microcode */
+	FW_EAGAIN		= 11,	/* try again */
+	FW_ENOMEM		= 12,	/* out of memory */
+	FW_EFAULT		= 14,	/* bad address; fw bad */
+	FW_EBUSY		= 16,	/* resource busy */
+	FW_EEXIST		= 17,	/* file exists */
+	FW_EINVAL		= 22,	/* invalid argument */
+	FW_ENOSPC		= 28,	/* no space left on device */
+	FW_ENOSYS		= 38,	/* functionality not implemented */
+	FW_EPROTO		= 71,	/* protocol error */
+	FW_EADDRINUSE		= 98,	/* address already in use */
+	FW_EADDRNOTAVAIL	= 99,	/* cannot assigned requested address */
+	FW_ENETDOWN		= 100,	/* network is down */
+	FW_ENETUNREACH		= 101,	/* network is unreachable */
+	FW_ENOBUFS		= 105,	/* no buffer space available */
+	FW_ETIMEDOUT		= 110,	/* timeout */
+	FW_EINPROGRESS		= 115,	/* fw internal */
+	FW_SCSI_ABORT_REQUESTED	= 128,	/* */
+	FW_SCSI_ABORT_TIMEDOUT	= 129,	/* */
+	FW_SCSI_ABORTED		= 130,	/* */
+	FW_SCSI_CLOSE_REQUESTED	= 131,	/* */
+	FW_ERR_LINK_DOWN	= 132,	/* */
+	FW_RDEV_NOT_READY	= 133,	/* */
+	FW_ERR_RDEV_LOST	= 134,	/* */
+	FW_ERR_RDEV_LOGO	= 135,	/* */
+	FW_FCOE_NO_XCHG		= 136,	/* */
+	FW_SCSI_RSP_ERR		= 137,	/* */
+	FW_ERR_RDEV_IMPL_LOGO	= 138,	/* */
+	FW_SCSI_UNDER_FLOW_ERR  = 139,	/* */
+	FW_SCSI_OVER_FLOW_ERR   = 140,	/* */
+	FW_SCSI_DDP_ERR		= 141,	/* DDP error*/
+	FW_SCSI_TASK_ERR	= 142,	/* No SCSI tasks available */
+};
+
+enum fw_fcoe_link_sub_op {
+	FCOE_LINK_DOWN	= 0x0,
+	FCOE_LINK_UP	= 0x1,
+	FCOE_LINK_COND	= 0x2,
+};
+
+enum fw_fcoe_link_status {
+	FCOE_LINKDOWN	= 0x0,
+	FCOE_LINKUP	= 0x1,
+};
+
+enum fw_ofld_prot {
+	PROT_FCOE	= 0x1,
+	PROT_ISCSI	= 0x2,
+};
+
+enum rport_type_fcoe {
+	FLOGI_VFPORT	= 0x1,		/* 0xfffffe */
+	FDISC_VFPORT	= 0x2,		/* 0xfffffe */
+	NS_VNPORT	= 0x3,		/* 0xfffffc */
+	REG_FC4_VNPORT	= 0x4,		/* any FC4 type VN_PORT */
+	REG_VNPORT	= 0x5,		/* 0xfffxxx - non FC4 port in switch */
+	FDMI_VNPORT	= 0x6,		/* 0xfffffa */
+	FAB_CTLR_VNPORT	= 0x7,		/* 0xfffffd */
+};
+
+enum event_cause_fcoe {
+	PLOGI_ACC_RCVD		= 0x01,
+	PLOGI_RJT_RCVD		= 0x02,
+	PLOGI_RCVD		= 0x03,
+	PLOGO_RCVD		= 0x04,
+	PRLI_ACC_RCVD		= 0x05,
+	PRLI_RJT_RCVD		= 0x06,
+	PRLI_RCVD		= 0x07,
+	PRLO_RCVD		= 0x08,
+	NPORT_ID_CHGD		= 0x09,
+	FLOGO_RCVD		= 0x0a,
+	CLR_VIRT_LNK_RCVD	= 0x0b,
+	FLOGI_ACC_RCVD		= 0x0c,
+	FLOGI_RJT_RCVD		= 0x0d,
+	FDISC_ACC_RCVD		= 0x0e,
+	FDISC_RJT_RCVD		= 0x0f,
+	FLOGI_TMO_MAX_RETRY	= 0x10,
+	IMPL_LOGO_ADISC_ACC	= 0x11,
+	IMPL_LOGO_ADISC_RJT	= 0x12,
+	IMPL_LOGO_ADISC_CNFLT	= 0x13,
+	PRLI_TMO		= 0x14,
+	ADISC_TMO		= 0x15,
+	RSCN_DEV_LOST		= 0x16,
+	SCR_ACC_RCVD		= 0x17,
+	ADISC_RJT_RCVD		= 0x18,
+	LOGO_SNT		= 0x19,
+	PROTO_ERR_IMPL_LOGO	= 0x1a,
+};
+
+enum fcoe_cmn_type {
+	FCOE_ELS,
+	FCOE_CT,
+	FCOE_SCSI_CMD,
+	FCOE_UNSOL_ELS,
+};
+
+enum fw_wr_stor_opcodes {
+	FW_RDEV_WR                     = 0x38,
+	FW_FCOE_ELS_CT_WR              = 0x30,
+	FW_SCSI_WRITE_WR               = 0x31,
+	FW_SCSI_READ_WR                = 0x32,
+	FW_SCSI_CMD_WR                 = 0x33,
+	FW_SCSI_ABRT_CLS_WR            = 0x34,
+};
+
+struct fw_rdev_wr {
+	__be32 op_to_immdlen;
+	__be32 alloc_to_len16;
+	__be64 cookie;
+	u8     protocol;
+	u8     event_cause;
+	u8     cur_state;
+	u8     prev_state;
+	__be32 flags_to_assoc_flowid;
+	union rdev_entry {
+		struct fcoe_rdev_entry {
+			__be32 flowid;
+			u8     protocol;
+			u8     event_cause;
+			u8     flags;
+			u8     rjt_reason;
+			u8     cur_login_st;
+			u8     prev_login_st;
+			__be16 rcv_fr_sz;
+			u8     rd_xfer_rdy_to_rport_type;
+			u8     vft_to_qos;
+			u8     org_proc_assoc_to_acc_rsp_code;
+			u8     enh_disc_to_tgt;
+			u8     wwnn[8];
+			u8     wwpn[8];
+			__be16 iqid;
+			u8     fc_oui[3];
+			u8     r_id[3];
+		} fcoe_rdev;
+		struct iscsi_rdev_entry {
+			__be32 flowid;
+			u8     protocol;
+			u8     event_cause;
+			u8     flags;
+			u8     r3;
+			__be16 iscsi_opts;
+			__be16 tcp_opts;
+			__be16 ip_opts;
+			__be16 max_rcv_len;
+			__be16 max_snd_len;
+			__be16 first_brst_len;
+			__be16 max_brst_len;
+			__be16 r4;
+			__be16 def_time2wait;
+			__be16 def_time2ret;
+			__be16 nop_out_intrvl;
+			__be16 non_scsi_to;
+			__be16 isid;
+			__be16 tsid;
+			__be16 port;
+			__be16 tpgt;
+			u8     r5[6];
+			__be16 iqid;
+		} iscsi_rdev;
+	} u;
+};
+
+#define FW_RDEV_WR_FLOWID_GET(x)	(((x) >> 8) & 0xfffff)
+#define FW_RDEV_WR_ASSOC_FLOWID_GET(x)	(((x) >> 0) & 0xfffff)
+#define FW_RDEV_WR_RPORT_TYPE_GET(x)	(((x) >> 0) & 0x1f)
+#define FW_RDEV_WR_NPIV_GET(x)		(((x) >> 6) & 0x1)
+#define FW_RDEV_WR_CLASS_GET(x)		(((x) >> 4) & 0x3)
+#define FW_RDEV_WR_TASK_RETRY_ID_GET(x)	(((x) >> 5) & 0x1)
+#define FW_RDEV_WR_RETRY_GET(x)		(((x) >> 4) & 0x1)
+#define FW_RDEV_WR_CONF_CMPL_GET(x)	(((x) >> 3) & 0x1)
+#define FW_RDEV_WR_INI_GET(x)		(((x) >> 1) & 0x1)
+#define FW_RDEV_WR_TGT_GET(x)		(((x) >> 0) & 0x1)
+
+struct fw_fcoe_els_ct_wr {
+	__be32 op_immdlen;
+	__be32 flowid_len16;
+	__be64 cookie;
+	__be16 iqid;
+	u8     tmo_val;
+	u8     els_ct_type;
+	u8     ctl_pri;
+	u8     cp_en_class;
+	__be16 xfer_cnt;
+	u8     fl_to_sp;
+	u8     l_id[3];
+	u8     r5;
+	u8     r_id[3];
+	__be64 rsp_dmaaddr;
+	__be32 rsp_dmalen;
+	__be32 r6;
+};
+
+#define FW_FCOE_ELS_CT_WR_OPCODE(x)		((x) << 24)
+#define FW_FCOE_ELS_CT_WR_OPCODE_GET(x)		(((x) >> 24) & 0xff)
+#define FW_FCOE_ELS_CT_WR_IMMDLEN(x)		((x) << 0)
+#define FW_FCOE_ELS_CT_WR_IMMDLEN_GET(x)	(((x) >> 0) & 0xff)
+#define FW_FCOE_ELS_CT_WR_SP(x)			((x) << 0)
+
+struct fw_scsi_write_wr {
+	__be32 op_immdlen;
+	__be32 flowid_len16;
+	__be64 cookie;
+	__be16 iqid;
+	u8     tmo_val;
+	u8     use_xfer_cnt;
+	union fw_scsi_write_priv {
+		struct fcoe_write_priv {
+			u8   ctl_pri;
+			u8   cp_en_class;
+			u8   r3_lo[2];
+		} fcoe;
+		struct iscsi_write_priv {
+			u8   r3[4];
+		} iscsi;
+	} u;
+	__be32 xfer_cnt;
+	__be32 ini_xfer_cnt;
+	__be64 rsp_dmaaddr;
+	__be32 rsp_dmalen;
+	__be32 r4;
+};
+
+#define FW_SCSI_WRITE_WR_IMMDLEN(x)	((x) << 0)
+
+struct fw_scsi_read_wr {
+	__be32 op_immdlen;
+	__be32 flowid_len16;
+	__be64 cookie;
+	__be16 iqid;
+	u8     tmo_val;
+	u8     use_xfer_cnt;
+	union fw_scsi_read_priv {
+		struct fcoe_read_priv {
+			u8   ctl_pri;
+			u8   cp_en_class;
+			u8   r3_lo[2];
+		} fcoe;
+		struct iscsi_read_priv {
+			u8   r3[4];
+		} iscsi;
+	} u;
+	__be32 xfer_cnt;
+	__be32 ini_xfer_cnt;
+	__be64 rsp_dmaaddr;
+	__be32 rsp_dmalen;
+	__be32 r4;
+};
+
+#define FW_SCSI_READ_WR_IMMDLEN(x)	((x) << 0)
+
+struct fw_scsi_cmd_wr {
+	__be32 op_immdlen;
+	__be32 flowid_len16;
+	__be64 cookie;
+	__be16 iqid;
+	u8     tmo_val;
+	u8     r3;
+	union fw_scsi_cmd_priv {
+		struct fcoe_cmd_priv {
+			u8   ctl_pri;
+			u8   cp_en_class;
+			u8   r4_lo[2];
+		} fcoe;
+		struct iscsi_cmd_priv {
+			u8   r4[4];
+		} iscsi;
+	} u;
+	u8     r5[8];
+	__be64 rsp_dmaaddr;
+	__be32 rsp_dmalen;
+	__be32 r6;
+};
+
+#define FW_SCSI_CMD_WR_IMMDLEN(x)	((x) << 0)
+
+#define SCSI_ABORT 0
+#define SCSI_CLOSE 1
+
+struct fw_scsi_abrt_cls_wr {
+	__be32 op_immdlen;
+	__be32 flowid_len16;
+	__be64 cookie;
+	__be16 iqid;
+	u8     tmo_val;
+	u8     sub_opcode_to_chk_all_io;
+	u8     r3[4];
+	__be64 t_cookie;
+};
+
+#define FW_SCSI_ABRT_CLS_WR_SUB_OPCODE(x)	((x) << 2)
+#define FW_SCSI_ABRT_CLS_WR_SUB_OPCODE_GET(x)	(((x) >> 2) & 0x3f)
+#define FW_SCSI_ABRT_CLS_WR_CHK_ALL_IO(x)	((x) << 0)
+
+enum fw_cmd_stor_opcodes {
+	FW_FCOE_RES_INFO_CMD           = 0x31,
+	FW_FCOE_LINK_CMD               = 0x32,
+	FW_FCOE_VNP_CMD                = 0x33,
+	FW_FCOE_SPARAMS_CMD            = 0x35,
+	FW_FCOE_STATS_CMD              = 0x37,
+	FW_FCOE_FCF_CMD                = 0x38,
+};
+
+struct fw_fcoe_res_info_cmd {
+	__be32 op_to_read;
+	__be32 retval_len16;
+	__be16 e_d_tov;
+	__be16 r_a_tov_seq;
+	__be16 r_a_tov_els;
+	__be16 r_r_tov;
+	__be32 max_xchgs;
+	__be32 max_ssns;
+	__be32 used_xchgs;
+	__be32 used_ssns;
+	__be32 max_fcfs;
+	__be32 max_vnps;
+	__be32 used_fcfs;
+	__be32 used_vnps;
+};
+
+struct fw_fcoe_link_cmd {
+	__be32 op_to_portid;
+	__be32 retval_len16;
+	__be32 sub_opcode_fcfi;
+	u8     r3;
+	u8     lstatus;
+	__be16 flags;
+	u8     r4;
+	u8     set_vlan;
+	__be16 vlan_id;
+	__be32 vnpi_pkd;
+	__be16 r6;
+	u8     phy_mac[6];
+	u8     vnport_wwnn[8];
+	u8     vnport_wwpn[8];
+};
+
+#define FW_FCOE_LINK_CMD_PORTID(x)	((x) << 0)
+#define FW_FCOE_LINK_CMD_PORTID_GET(x)	(((x) >> 0) & 0xf)
+#define FW_FCOE_LINK_CMD_SUB_OPCODE(x)  ((x) << 24U)
+#define FW_FCOE_LINK_CMD_FCFI(x)	((x) << 0)
+#define FW_FCOE_LINK_CMD_FCFI_GET(x)	(((x) >> 0) & 0xffffff)
+#define FW_FCOE_LINK_CMD_VNPI_GET(x)	(((x) >> 0) & 0xfffff)
+
+struct fw_fcoe_vnp_cmd {
+	__be32 op_to_fcfi;
+	__be32 alloc_to_len16;
+	__be32 gen_wwn_to_vnpi;
+	__be32 vf_id;
+	__be16 iqid;
+	u8   vnport_mac[6];
+	u8   vnport_wwnn[8];
+	u8   vnport_wwpn[8];
+	u8   cmn_srv_parms[16];
+	u8   clsp_word_0_1[8];
+};
+
+#define FW_FCOE_VNP_CMD_FCFI(x)		((x) << 0)
+#define FW_FCOE_VNP_CMD_ALLOC		(1U << 31)
+#define FW_FCOE_VNP_CMD_FREE		(1U << 30)
+#define FW_FCOE_VNP_CMD_MODIFY		(1U << 29)
+#define FW_FCOE_VNP_CMD_GEN_WWN		(1U << 22)
+#define FW_FCOE_VNP_CMD_VFID_EN		(1U << 20)
+#define FW_FCOE_VNP_CMD_VNPI(x)		((x) << 0)
+#define FW_FCOE_VNP_CMD_VNPI_GET(x)	(((x) >> 0) & 0xfffff)
+
+struct fw_fcoe_sparams_cmd {
+	__be32 op_to_portid;
+	__be32 retval_len16;
+	u8     r3[7];
+	u8     cos;
+	u8     lport_wwnn[8];
+	u8     lport_wwpn[8];
+	u8     cmn_srv_parms[16];
+	u8     cls_srv_parms[16];
+};
+
+#define FW_FCOE_SPARAMS_CMD_PORTID(x)	((x) << 0)
+
+struct fw_fcoe_stats_cmd {
+	__be32 op_to_flowid;
+	__be32 free_to_len16;
+	union fw_fcoe_stats {
+		struct fw_fcoe_stats_ctl {
+			u8   nstats_port;
+			u8   port_valid_ix;
+			__be16 r6;
+			__be32 r7;
+			__be64 stat0;
+			__be64 stat1;
+			__be64 stat2;
+			__be64 stat3;
+			__be64 stat4;
+			__be64 stat5;
+		} ctl;
+		struct fw_fcoe_port_stats {
+			__be64 tx_bcast_bytes;
+			__be64 tx_bcast_frames;
+			__be64 tx_mcast_bytes;
+			__be64 tx_mcast_frames;
+			__be64 tx_ucast_bytes;
+			__be64 tx_ucast_frames;
+			__be64 tx_drop_frames;
+			__be64 tx_offload_bytes;
+			__be64 tx_offload_frames;
+			__be64 rx_bcast_bytes;
+			__be64 rx_bcast_frames;
+			__be64 rx_mcast_bytes;
+			__be64 rx_mcast_frames;
+			__be64 rx_ucast_bytes;
+			__be64 rx_ucast_frames;
+			__be64 rx_err_frames;
+		} port_stats;
+		struct fw_fcoe_fcf_stats {
+			__be32 fip_tx_bytes;
+			__be32 fip_tx_fr;
+			__be64 fcf_ka;
+			__be64 mcast_adv_rcvd;
+			__be16 ucast_adv_rcvd;
+			__be16 sol_sent;
+			__be16 vlan_req;
+			__be16 vlan_rpl;
+			__be16 clr_vlink;
+			__be16 link_down;
+			__be16 link_up;
+			__be16 logo;
+			__be16 flogi_req;
+			__be16 flogi_rpl;
+			__be16 fdisc_req;
+			__be16 fdisc_rpl;
+			__be16 fka_prd_chg;
+			__be16 fc_map_chg;
+			__be16 vfid_chg;
+			u8   no_fka_req;
+			u8   no_vnp;
+		} fcf_stats;
+		struct fw_fcoe_pcb_stats {
+			__be64 tx_bytes;
+			__be64 tx_frames;
+			__be64 rx_bytes;
+			__be64 rx_frames;
+			__be32 vnp_ka;
+			__be32 unsol_els_rcvd;
+			__be64 unsol_cmd_rcvd;
+			__be16 implicit_logo;
+			__be16 flogi_inv_sparm;
+			__be16 fdisc_inv_sparm;
+			__be16 flogi_rjt;
+			__be16 fdisc_rjt;
+			__be16 no_ssn;
+			__be16 mac_flt_fail;
+			__be16 inv_fr_rcvd;
+		} pcb_stats;
+		struct fw_fcoe_scb_stats {
+			__be64 tx_bytes;
+			__be64 tx_frames;
+			__be64 rx_bytes;
+			__be64 rx_frames;
+			__be32 host_abrt_req;
+			__be32 adap_auto_abrt;
+			__be32 adap_abrt_rsp;
+			__be32 host_ios_req;
+			__be16 ssn_offl_ios;
+			__be16 ssn_not_rdy_ios;
+			u8   rx_data_ddp_err;
+			u8   ddp_flt_set_err;
+			__be16 rx_data_fr_err;
+			u8   bad_st_abrt_req;
+			u8   no_io_abrt_req;
+			u8   abort_tmo;
+			u8   abort_tmo_2;
+			__be32 abort_req;
+			u8   no_ppod_res_tmo;
+			u8   bp_tmo;
+			u8   adap_auto_cls;
+			u8   no_io_cls_req;
+			__be32 host_cls_req;
+			__be64 unsol_cmd_rcvd;
+			__be32 plogi_req_rcvd;
+			__be32 prli_req_rcvd;
+			__be16 logo_req_rcvd;
+			__be16 prlo_req_rcvd;
+			__be16 plogi_rjt_rcvd;
+			__be16 prli_rjt_rcvd;
+			__be32 adisc_req_rcvd;
+			__be32 rscn_rcvd;
+			__be32 rrq_req_rcvd;
+			__be32 unsol_els_rcvd;
+			u8   adisc_rjt_rcvd;
+			u8   scr_rjt;
+			u8   ct_rjt;
+			u8   inval_bls_rcvd;
+			__be32 ba_rjt_rcvd;
+		} scb_stats;
+	} u;
+};
+
+#define FW_FCOE_STATS_CMD_FLOWID(x)	((x) << 0)
+#define FW_FCOE_STATS_CMD_FREE		(1U << 30)
+#define FW_FCOE_STATS_CMD_NSTATS(x)	((x) << 4)
+#define FW_FCOE_STATS_CMD_PORT(x)	((x) << 0)
+#define FW_FCOE_STATS_CMD_PORT_VALID	(1U << 7)
+#define FW_FCOE_STATS_CMD_IX(x)		((x) << 0)
+
+struct fw_fcoe_fcf_cmd {
+	__be32 op_to_fcfi;
+	__be32 retval_len16;
+	__be16 priority_pkd;
+	u8     mac[6];
+	u8     name_id[8];
+	u8     fabric[8];
+	__be16 vf_id;
+	__be16 max_fcoe_size;
+	u8     vlan_id;
+	u8     fc_map[3];
+	__be32 fka_adv;
+	__be32 r6;
+	u8     r7_hi;
+	u8     fpma_to_portid;
+	u8     spma_mac[6];
+	__be64 r8;
+};
+
+#define FW_FCOE_FCF_CMD_FCFI(x)		((x) << 0)
+#define FW_FCOE_FCF_CMD_FCFI_GET(x)	(((x) >> 0) & 0xfffff)
+#define FW_FCOE_FCF_CMD_PRIORITY_GET(x)	(((x) >> 0) & 0xff)
+#define FW_FCOE_FCF_CMD_FPMA_GET(x)	(((x) >> 6) & 0x1)
+#define FW_FCOE_FCF_CMD_SPMA_GET(x)	(((x) >> 5) & 0x1)
+#define FW_FCOE_FCF_CMD_LOGIN_GET(x)	(((x) >> 4) & 0x1)
+#define FW_FCOE_FCF_CMD_PORTID_GET(x)	(((x) >> 0) & 0xf)
+
+#endif /* _T4FW_API_STOR_H_ */
-- 
1.7.1
