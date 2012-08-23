From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: [PATCH 7/8] csiostor: Chelsio FCoE offload driver submission (headers part 2).
Date: Fri, 24 Aug 2012 03:57:52 +0530
Message-ID: <1345760873-12101-8-git-send-email-naresh@chelsio.com>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
Cc: netdev@vger.kernel.org, naresh@chelsio.com, chethan@chelsio.com
To: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the second set of the header files for csiostor driver.

Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
---
 drivers/scsi/csiostor/csio_lnode.h    |  244 ++++++++++++++
 drivers/scsi/csiostor/csio_mb.h       |  278 ++++++++++++++++
 drivers/scsi/csiostor/csio_rnode.h    |  142 ++++++++
 drivers/scsi/csiostor/csio_scsi.h     |  332 +++++++++++++++++++
 drivers/scsi/csiostor/csio_wr.h       |  519 +++++++++++++++++++++++++++++
 drivers/scsi/csiostor/t4fw_api_stor.h |  578 +++++++++++++++++++++++++++++++++
 6 files changed, 2093 insertions(+), 0 deletions(-)
 create mode 100644 drivers/scsi/csiostor/csio_lnode.h
 create mode 100644 drivers/scsi/csiostor/csio_mb.h
 create mode 100644 drivers/scsi/csiostor/csio_rnode.h
 create mode 100644 drivers/scsi/csiostor/csio_scsi.h
 create mode 100644 drivers/scsi/csiostor/csio_wr.h
 create mode 100644 drivers/scsi/csiostor/t4fw_api_stor.h

diff --git a/drivers/scsi/csiostor/csio_lnode.h b/drivers/scsi/csiostor/csio_lnode.h
new file mode 100644
index 0000000..5845856
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_lnode.h
@@ -0,0 +1,244 @@
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
+#ifndef __CSIO_LNODE_H__
+#define __CSIO_LNODE_H__
+
+#include <linux/kref.h>
+#include <linux/timer.h>
+#include <linux/workqueue.h>
+
+
+#include "csio_defs.h"
+#include "csio_hw.h"
+#include "csio_fcoe_proto.h"
+
+#define CSIO_FCOE_MAX_NPIV	128
+#define CSIO_FCOE_MAX_RNODES	2048
+
+extern int csio_fcoe_rnodes;
+extern int csio_fdmi_enable;
+
+/* State machine evets */
+enum csio_ln_ev {
+	CSIO_LNE_NONE = (uint32_t)0,
+	CSIO_LNE_LINKUP,
+	CSIO_LNE_FAB_INIT_DONE,
+	CSIO_LNE_LINK_DOWN,
+	CSIO_LNE_DOWN_LINK,
+	CSIO_LNE_LOGO,
+	CSIO_LNE_CLOSE,
+	CSIO_LNE_MAX_EVENT,
+};
+
+
+struct csio_fcf_info {
+	struct list_head	list;
+	uint8_t			priority;
+	uint8_t			mac[6];
+	uint8_t			name_id[8];
+	uint8_t			fabric[8];
+	uint16_t		vf_id;
+	uint8_t			vlan_id;
+	uint16_t		max_fcoe_size;
+	uint8_t			fc_map[3];
+	uint32_t		fka_adv;
+	uint32_t		fcfi;
+	uint8_t			get_next:1;
+	uint8_t			link_aff:1;
+	uint8_t			fpma:1;
+	uint8_t			spma:1;
+	uint8_t			login:1;
+	uint8_t			portid;
+	uint8_t			spma_mac[6];
+	struct kref		kref;
+};
+
+/* Defines for flags */
+#define	CSIO_LNF_FIPSUPP		0x00000001	/* Fip Supported */
+#define	CSIO_LNF_NPIVSUPP		0x00000002	/* NPIV supported */
+#define CSIO_LNF_LINK_ENABLE		0x00000004	/* Link enabled */
+#define	CSIO_LNF_FDMI_ENABLE		0x00000008	/* FDMI support */
+
+/* Transport events */
+enum csio_ln_fc_evt {
+	CSIO_LN_FC_LINKUP = 1,
+	CSIO_LN_FC_LINKDOWN,
+	CSIO_LN_FC_RSCN,
+	CSIO_LN_FC_ATTRIB_UPDATE,
+};
+
+/* Lnode stats */
+struct csio_lnode_stats {
+	uint32_t	n_link_up;	/* Link down */
+	uint32_t	n_link_down;	/* Link up */
+	uint32_t	n_err;		/* error */
+	uint32_t	n_err_nomem;	/* memory not available */
+	uint32_t	n_inval_parm;   /* Invalid parameters */
+	uint32_t	n_evt_unexp;	/* unexpected event */
+	uint32_t	n_evt_drop;	/* dropped event */
+	uint32_t	n_rnode_match;  /* matched rnode */
+	uint32_t	n_dev_loss_tmo; /* Device loss timeout */
+	uint32_t	n_fdmi_err;	/* fdmi err */
+	uint32_t	n_evt_fw[RSCN_DEV_LOST];	/* fw events */
+	enum csio_ln_ev	n_evt_sm[CSIO_LNE_MAX_EVENT];	/* State m/c events */
+	uint32_t	n_rnode_alloc;	/* rnode allocated */
+	uint32_t	n_rnode_free;	/* rnode freed */
+	uint32_t	n_rnode_nomem;	/* rnode alloc failure */
+	uint32_t        n_input_requests; /* Input Requests */
+	uint32_t        n_output_requests; /* Output Requests */
+	uint32_t        n_control_requests; /* Control Requests */
+	uint32_t        n_input_bytes; /* Input Bytes */
+	uint32_t        n_output_bytes; /* Output Bytes */
+	uint32_t	rsvd1;
+};
+
+/* Common Lnode params */
+struct csio_lnode_params {
+	uint32_t	ra_tov;
+	uint32_t	fcfi;
+	uint32_t	log_level;	/* Module level for debugging */
+};
+
+/* Lnode */
+struct csio_lnode {
+	struct csio_sm		sm;		/* State machine + sibling
+						 * lnode list.
+						 */
+	struct csio_hw		*hwp;		/* Pointer to the HW module */
+	uint8_t			portid;		/* Port ID */
+	uint8_t			rsvd1;
+	uint16_t		rsvd2;
+	uint32_t		dev_num;	/* Device number */
+	uint32_t		flags;		/* Flags */
+	struct list_head	fcf_lsthead;	/* FCF entries */
+	struct csio_fcf_info	*fcfinfo;	/* FCF in use */
+	struct csio_ioreq	*mgmt_req;	/* MGMT request */
+
+	/* FCoE identifiers */
+	uint8_t			mac[6];
+	uint32_t		nport_id;
+	struct csio_service_parms ln_sparm;	/* Service parms */
+
+	/* Firmware identifiers */
+	uint32_t		fcf_flowid;	/*fcf flowid */
+	uint32_t		vnp_flowid;
+	uint16_t		ssn_cnt;	/* Registered Session */
+	uint8_t			cur_evt;	/* Current event */
+	uint8_t			prev_evt;	/* Previous event */
+
+	/* Children */
+	struct list_head	cln_head;	/* Head of the children lnode
+						 * list.
+						 */
+	uint32_t		num_vports;	/* Total NPIV/children LNodes*/
+	struct csio_lnode	*pln;		/* Parent lnode of child
+						 * lnodes.
+						 */
+	struct list_head	cmpl_q;		/* Pending I/Os on this lnode */
+
+	/* Remote node information */
+	struct list_head	rnhead;		/* Head of rnode list */
+	uint32_t		num_reg_rnodes;	/* Number of rnodes registered
+						 * with the host.
+						 */
+	uint32_t		n_scsi_tgts;	/* Number of scsi targets
+						 * found
+						 */
+	uint32_t		last_scan_ntgts;/* Number of scsi targets
+						 * found per last scan.
+						 */
+	uint32_t		tgt_scan_tick;	/* timer started after
+						 * new tgt found
+						 */
+	/* FC transport data */
+	struct fc_vport		*fc_vport;
+	struct fc_host_statistics fch_stats;
+
+	struct csio_lnode_stats stats;		/* Common lnode stats */
+	struct csio_lnode_params params;	/* Common lnode params */
+};
+
+#define	csio_lnode_to_hw(ln)	((ln)->hwp)
+#define csio_root_lnode(ln)	(csio_lnode_to_hw((ln))->rln)
+#define csio_parent_lnode(ln)	((ln)->pln)
+#define	csio_ln_flowid(ln)	((ln)->vnp_flowid)
+#define csio_ln_wwpn(ln)	((ln)->ln_sparm.wwpn)
+#define csio_ln_wwnn(ln)	((ln)->ln_sparm.wwnn)
+
+#define csio_is_root_ln(ln)	(((ln) == csio_root_lnode((ln))) ? 1 : 0)
+#define csio_is_phys_ln(ln)	(((ln)->pln == NULL) ? 1 : 0)
+#define csio_is_npiv_ln(ln)	(((ln)->pln != NULL) ? 1 : 0)
+
+
+#define csio_ln_dbg(_ln, _fmt, ...)	\
+	csio_dbg(_ln->hwp, "%x:%x "_fmt, CSIO_DEVID_HI(_ln), \
+		 CSIO_DEVID_LO(_ln), ##__VA_ARGS__);
+
+#define csio_ln_err(_ln, _fmt, ...)	\
+	csio_err(_ln->hwp, "%x:%x "_fmt, CSIO_DEVID_HI(_ln), \
+		 CSIO_DEVID_LO(_ln), ##__VA_ARGS__);
+
+#define csio_ln_warn(_ln, _fmt, ...)	\
+	csio_warn(_ln->hwp, "%x:%x "_fmt, CSIO_DEVID_HI(_ln), \
+		 CSIO_DEVID_LO(_ln), ##__VA_ARGS__);
+
+/* HW->Lnode notifications */
+enum csio_ln_notify {
+	CSIO_LN_NOTIFY_HWREADY = 1,
+	CSIO_LN_NOTIFY_HWSTOP,
+	CSIO_LN_NOTIFY_HWREMOVE,
+	CSIO_LN_NOTIFY_HWRESET,
+};
+
+void csio_fcoe_fwevt_handler(struct csio_hw *,  __u8 cpl_op, __be64 *);
+int csio_is_lnode_ready(struct csio_lnode *);
+void csio_lnode_state_to_str(struct csio_lnode *ln, int8_t *str);
+struct csio_lnode *csio_lnode_lookup_by_wwpn(struct csio_hw *, uint8_t *);
+csio_retval_t csio_get_phy_port_stats(struct csio_hw *, uint8_t ,
+				      struct fw_fcoe_port_stats *);
+int csio_scan_done(struct csio_lnode *, unsigned long, unsigned long,
+		   unsigned long, unsigned long);
+void csio_notify_lnodes(struct csio_hw *, enum csio_ln_notify);
+void csio_disable_lnodes(struct csio_hw *, uint8_t, bool);
+void csio_lnode_async_event(struct csio_lnode *, enum csio_ln_fc_evt);
+csio_retval_t csio_ln_fdmi_start(struct csio_lnode *, void *);
+csio_retval_t csio_lnode_start(struct csio_lnode *);
+void csio_lnode_stop(struct csio_lnode *);
+void csio_lnode_close(struct csio_lnode *);
+csio_retval_t csio_lnode_init(struct csio_lnode *, struct csio_hw *,
+			      struct csio_lnode *);
+void csio_lnode_exit(struct csio_lnode *);
+
+#endif /* ifndef __CSIO_LNODE_H__ */
diff --git a/drivers/scsi/csiostor/csio_mb.h b/drivers/scsi/csiostor/csio_mb.h
new file mode 100644
index 0000000..f3e578b
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_mb.h
@@ -0,0 +1,278 @@
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
+#ifndef __CSIO_MB_H__
+#define __CSIO_MB_H__
+
+#include <linux/timer.h>
+#include <linux/completion.h>
+
+#include "t4fw_api.h"
+#include "t4fw_api_stor.h"
+#include "csio_defs.h"
+
+#define CSIO_STATS_OFFSET (2)
+#define CSIO_NUM_STATS_PER_MB (6)
+
+struct fw_fcoe_port_cmd_params {
+	uint8_t		portid;
+	uint8_t		idx;
+	uint8_t		nstats;
+};
+
+#define CSIO_DUMP_MB(__hw, __num, __mb)					\
+	csio_dbg(__hw, "\t%llx %llx %llx %llx %llx %llx %llx %llx\n",	\
+		(unsigned long long)csio_rd_reg64(__hw, __mb),		\
+		(unsigned long long)csio_rd_reg64(__hw, __mb + 8),	\
+		(unsigned long long)csio_rd_reg64(__hw, __mb + 16),	\
+		(unsigned long long)csio_rd_reg64(__hw, __mb + 24),	\
+		(unsigned long long)csio_rd_reg64(__hw, __mb + 32),	\
+		(unsigned long long)csio_rd_reg64(__hw, __mb + 40),	\
+		(unsigned long long)csio_rd_reg64(__hw, __mb + 48),	\
+		(unsigned long long)csio_rd_reg64(__hw, __mb + 56))
+
+#define CSIO_MB_MAX_REGS	8
+#define CSIO_MAX_MB_SIZE	64
+#define CSIO_MB_POLL_FREQ	5		/*  5 ms */
+#define CSIO_MB_DEFAULT_TMO	FW_CMD_MAX_TIMEOUT
+
+/* Device master in HELLO command */
+enum csio_dev_master { CSIO_MASTER_CANT, CSIO_MASTER_MAY, CSIO_MASTER_MUST };
+
+enum csio_mb_owner { CSIO_MBOWNER_NONE, CSIO_MBOWNER_FW, CSIO_MBOWNER_PL };
+
+enum csio_dev_state {
+	CSIO_DEV_STATE_UNINIT,
+	CSIO_DEV_STATE_INIT,
+	CSIO_DEV_STATE_ERR
+};
+
+#define FW_PARAM_DEV(param) \
+	(FW_PARAMS_MNEM(FW_PARAMS_MNEM_DEV) | \
+	 FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_DEV_##param))
+
+#define FW_PARAM_PFVF(param) \
+	(FW_PARAMS_MNEM(FW_PARAMS_MNEM_PFVF) | \
+	 FW_PARAMS_PARAM_X(FW_PARAMS_PARAM_PFVF_##param)|  \
+	 FW_PARAMS_PARAM_Y(0) | \
+	 FW_PARAMS_PARAM_Z(0))
+
+enum {
+	PAUSE_RX      = 1 << 0,
+	PAUSE_TX      = 1 << 1,
+	PAUSE_AUTONEG = 1 << 2
+};
+
+#define CSIO_INIT_MBP(__mbp, __cp,  __tmo, __priv, __fn, __clear)	\
+do {									\
+	if (__clear)							\
+		memset((__cp), 0,					\
+			    CSIO_MB_MAX_REGS * sizeof(__be64));		\
+	INIT_LIST_HEAD(&(__mbp)->list);					\
+	(__mbp)->tmo		= (__tmo);				\
+	(__mbp)->priv		= (void *)(__priv);			\
+	(__mbp)->mb_cbfn	= (__fn);				\
+	(__mbp)->mb_size	= sizeof(*(__cp));			\
+} while (0)
+
+struct csio_mbm_stats {
+	uint32_t	n_req;		/* number of mbox req */
+	uint32_t	n_rsp;		/* number of mbox rsp */
+	uint32_t	n_activeq;	/* number of mbox req active Q */
+	uint32_t	n_cbfnq;	/* number of mbox req cbfn Q */
+	uint32_t	n_tmo;		/* number of mbox timeout */
+	uint32_t	n_cancel;	/* number of mbox cancel */
+	uint32_t	n_err;		/* number of mbox error */
+};
+
+/* Driver version of Mailbox */
+struct csio_mb {
+	struct list_head	list;			/* for req/resp */
+							/* queue in driver */
+	__be64			mb[CSIO_MB_MAX_REGS];	/* MB in HW format */
+	int			mb_size;		/* Size of this
+							 * mailbox.
+							 */
+	uint32_t		tmo;			/* Timeout */
+	struct completion	cmplobj;		/* MB Completion
+							 * object
+							 */
+	void			(*mb_cbfn) (struct csio_hw *, struct csio_mb *);
+							/* Callback fn */
+	void			*priv;			/* Owner private ptr */
+};
+
+struct csio_mbm {
+	uint32_t		a_mbox;			/* Async mbox num */
+	uint32_t		intr_idx;		/* Interrupt index */
+	struct timer_list	timer;			/* Mbox timer */
+	struct list_head	req_q;			/* Mbox request queue */
+	struct list_head	cbfn_q;			/* Mbox completion q */
+	struct csio_mb		*mcurrent;		/* Current mailbox */
+	uint32_t		req_q_cnt;		/* Outstanding mbox
+							 * cmds
+							 */
+	struct csio_mbm_stats	stats;			/* Statistics */
+};
+
+#define csio_set_mb_intr_idx(_m, _i)	((_m)->intr_idx = (_i))
+#define csio_get_mb_intr_idx(_m)	((_m)->intr_idx)
+
+struct csio_iq_params;
+struct csio_eq_params;
+
+enum fw_retval csio_mb_fw_retval(struct csio_mb *);
+
+/* MB helpers */
+void csio_mb_hello(struct csio_hw *, struct csio_mb *, uint32_t,
+		   uint32_t, uint32_t, enum csio_dev_master,
+		   void (*)(struct csio_hw *, struct csio_mb *));
+
+void csio_mb_process_hello_rsp(struct csio_hw *, struct csio_mb *,
+			       enum fw_retval *, enum csio_dev_state *,
+			       uint8_t *);
+
+void csio_mb_bye(struct csio_hw *, struct csio_mb *, uint32_t,
+		 void (*)(struct csio_hw *, struct csio_mb *));
+
+void csio_mb_reset(struct csio_hw *, struct csio_mb *, uint32_t, int, int,
+		   void (*)(struct csio_hw *, struct csio_mb *));
+
+void csio_mb_params(struct csio_hw *, struct csio_mb *, uint32_t, unsigned int,
+		    unsigned int, unsigned int, const u32 *, u32 *, bool,
+		    void (*)(struct csio_hw *, struct csio_mb *));
+
+void csio_mb_process_read_params_rsp(struct csio_hw *, struct csio_mb *,
+				enum fw_retval *, unsigned int , u32 *);
+
+void csio_mb_ldst(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
+		  int reg);
+
+void csio_mb_caps_config(struct csio_hw *, struct csio_mb *, uint32_t,
+			    bool, bool, bool, bool,
+			    void (*)(struct csio_hw *, struct csio_mb *));
+
+void csio_rss_glb_config(struct csio_hw *, struct csio_mb *,
+			 uint32_t, uint8_t, unsigned int,
+			 void (*)(struct csio_hw *, struct csio_mb *));
+
+void csio_mb_pfvf(struct csio_hw *, struct csio_mb *, uint32_t,
+		  unsigned int, unsigned int, unsigned int,
+		  unsigned int, unsigned int, unsigned int,
+		  unsigned int, unsigned int, unsigned int,
+		  unsigned int, unsigned int, unsigned int,
+		  unsigned int, void (*) (struct csio_hw *, struct csio_mb *));
+
+void csio_mb_port(struct csio_hw *, struct csio_mb *, uint32_t,
+		  uint8_t, bool, uint32_t, uint16_t,
+		  void (*) (struct csio_hw *, struct csio_mb *));
+
+void csio_mb_process_read_port_rsp(struct csio_hw *, struct csio_mb *,
+				   enum fw_retval *, uint16_t *);
+
+void csio_mb_initialize(struct csio_hw *, struct csio_mb *, uint32_t,
+			void (*)(struct csio_hw *, struct csio_mb *));
+
+void csio_mb_iq_alloc_write(struct csio_hw *, struct csio_mb *, void *,
+			uint32_t, struct csio_iq_params *,
+			void (*) (struct csio_hw *, struct csio_mb *));
+
+void csio_mb_iq_alloc_write_rsp(struct csio_hw *, struct csio_mb *,
+				enum fw_retval *, struct csio_iq_params *);
+
+void csio_mb_iq_free(struct csio_hw *, struct csio_mb *, void *,
+		     uint32_t, struct csio_iq_params *,
+		     void (*) (struct csio_hw *, struct csio_mb *));
+
+void csio_mb_eq_ofld_alloc_write(struct csio_hw *, struct csio_mb *, void *,
+				 uint32_t, struct csio_eq_params *,
+				 void (*) (struct csio_hw *, struct csio_mb *));
+
+void csio_mb_eq_ofld_alloc_write_rsp(struct csio_hw *, struct csio_mb *,
+				     enum fw_retval *, struct csio_eq_params *);
+
+void csio_mb_eq_ofld_free(struct csio_hw *, struct csio_mb *, void *,
+			  uint32_t , struct csio_eq_params *,
+			  void (*) (struct csio_hw *, struct csio_mb *));
+
+void csio_fcoe_read_res_info_init_mb(struct csio_hw *, struct csio_mb *,
+			uint32_t,
+			void (*) (struct csio_hw *, struct csio_mb *));
+
+void csio_write_fcoe_link_cond_init_mb(struct csio_lnode *, struct csio_mb *,
+			uint32_t, uint8_t, uint32_t, uint8_t, bool, uint32_t,
+			void (*) (struct csio_hw *, struct csio_mb *));
+
+void csio_fcoe_vnp_alloc_init_mb(struct csio_lnode *, struct csio_mb *,
+			uint32_t, uint32_t , uint32_t , uint16_t,
+			uint8_t [8], uint8_t [8],
+			void (*) (struct csio_hw *, struct csio_mb *));
+
+void csio_fcoe_vnp_read_init_mb(struct csio_lnode *, struct csio_mb *,
+			uint32_t, uint32_t , uint32_t ,
+			void (*) (struct csio_hw *, struct csio_mb *));
+
+void csio_fcoe_vnp_free_init_mb(struct csio_lnode *, struct csio_mb *,
+			uint32_t , uint32_t, uint32_t ,
+			void (*) (struct csio_hw *, struct csio_mb *));
+
+void csio_fcoe_read_fcf_init_mb(struct csio_lnode *, struct csio_mb *,
+			uint32_t, uint32_t, uint32_t,
+			void (*cbfn) (struct csio_hw *, struct csio_mb *));
+
+void csio_fcoe_read_portparams_init_mb(struct csio_hw *hw,
+			struct csio_mb *mbp, uint32_t mb_tmo,
+			struct fw_fcoe_port_cmd_params *portparams,
+			void (*cbfn)(struct csio_hw *, struct csio_mb *));
+
+void csio_mb_process_portparams_rsp(struct csio_hw *hw, struct csio_mb *mbp,
+				enum fw_retval *retval,
+				struct fw_fcoe_port_cmd_params *portparams,
+				struct fw_fcoe_port_stats *portstats);
+
+/* MB module functions */
+csio_retval_t csio_mbm_init(struct csio_mbm *, struct csio_hw *,
+			    void (*)(uintptr_t));
+void csio_mbm_exit(struct csio_mbm *);
+void csio_mb_intr_enable(struct csio_hw *);
+void csio_mb_intr_disable(struct csio_hw *);
+
+csio_retval_t csio_mb_issue(struct csio_hw *, struct csio_mb *);
+void csio_mb_completions(struct csio_hw *, struct list_head *);
+csio_retval_t csio_mb_fwevt_handler(struct csio_hw *, __be64 *);
+csio_retval_t csio_mb_isr_handler(struct csio_hw *);
+struct csio_mb *csio_mb_tmo_handler(struct csio_hw *);
+void csio_mb_cancel_all(struct csio_hw *, struct list_head *);
+
+#endif /* ifndef __CSIO_MB_H__ */
diff --git a/drivers/scsi/csiostor/csio_rnode.h b/drivers/scsi/csiostor/csio_rnode.h
new file mode 100644
index 0000000..99f0cd1
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_rnode.h
@@ -0,0 +1,142 @@
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
+#ifndef __CSIO_RNODE_H__
+#define __CSIO_RNODE_H__
+
+#include "csio_defs.h"
+#include "csio_fcoe_proto.h"
+
+/* State machine evets */
+enum csio_rn_ev {
+	CSIO_RNFE_NONE = (uint32_t)0,			/* None */
+	CSIO_RNFE_LOGGED_IN,				/* [N/F]Port login
+							 * complete.
+							 */
+	CSIO_RNFE_PRLI_DONE,				/* PRLI completed */
+	CSIO_RNFE_PLOGI_RECV,				/* Received PLOGI */
+	CSIO_RNFE_PRLI_RECV,				/* Received PLOGI */
+	CSIO_RNFE_LOGO_RECV,				/* Received LOGO */
+	CSIO_RNFE_PRLO_RECV,				/* Received PRLO */
+	CSIO_RNFE_DOWN,					/* Rnode is down */
+	CSIO_RNFE_CLOSE,				/* Close rnode */
+	CSIO_RNFE_NAME_MISSING,				/* Rnode name missing
+							 * in name server.
+							 */
+	CSIO_RNFE_MAX_EVENT,
+};
+
+/* rnode stats */
+struct csio_rnode_stats {
+	uint32_t	n_err;		/* error */
+	uint32_t	n_err_inval;	/* invalid parameter */
+	uint32_t	n_err_nomem;	/* error nomem */
+	uint32_t	n_evt_unexp;	/* unexpected event */
+	uint32_t	n_evt_drop;	/* unexpected event */
+	uint32_t	n_evt_fw[RSCN_DEV_LOST];	/* fw events */
+	enum csio_rn_ev	n_evt_sm[CSIO_RNFE_MAX_EVENT];	/* State m/c events */
+	uint32_t	n_lun_rst;	/* Number of resets of
+					 * of LUNs under this
+					 * target
+					 */
+	uint32_t	n_lun_rst_fail;	/* Number of LUN reset
+					 * failures.
+					 */
+	uint32_t	n_tgt_rst;	/* Number of target resets */
+	uint32_t	n_tgt_rst_fail;	/* Number of target reset
+					 * failures.
+					 */
+};
+
+/* Defines for rnode role */
+#define	CSIO_RNFR_INITIATOR	0x1
+#define	CSIO_RNFR_TARGET	0x2
+#define CSIO_RNFR_FABRIC	0x4
+#define	CSIO_RNFR_NS		0x8
+#define CSIO_RNFR_NPORT		0x10
+
+struct csio_rnode {
+	struct csio_sm		sm;			/* State machine -
+							 * should be the
+							 * 1st member
+							 */
+	struct csio_lnode	*lnp;			/* Pointer to owning
+							 * Lnode */
+	uint32_t		flowid;			/* Firmware ID */
+	struct list_head	host_cmpl_q;		/* SCSI IOs
+							 * pending to completed
+							 * to Mid-layer.
+							 */
+	/* FC identifiers for remote node */
+	uint32_t		nport_id;
+	uint16_t		fcp_flags;		/* FCP Flags */
+	uint8_t			cur_evt;		/* Current event */
+	uint8_t			prev_evt;		/* Previous event */
+	uint32_t		role;			/* Fabric/Target/
+							 * Initiator/NS
+							 */
+	struct fcoe_rdev_entry		*rdev_entry;	/* Rdev entry */
+	struct csio_service_parms	rn_sparm;
+
+	/* FC transport attributes */
+	struct fc_rport		*rport;		/* FC transport rport */
+	uint32_t		supp_classes;	/* Supported FC classes */
+	uint32_t		maxframe_size;	/* Max Frame size */
+	uint32_t		scsi_id;	/* Transport given SCSI id */
+
+	struct csio_rnode_stats	stats;		/* Common rnode stats */
+};
+
+#define csio_rn_flowid(rn)			((rn)->flowid)
+#define csio_rn_wwpn(rn)			((rn)->rn_sparm.wwpn)
+#define csio_rn_wwnn(rn)			((rn)->rn_sparm.wwnn)
+#define csio_rnode_to_lnode(rn)			((rn)->lnp)
+
+int csio_is_rnode_ready(struct csio_rnode *rn);
+void csio_rnode_state_to_str(struct csio_rnode *rn, int8_t *str);
+
+struct csio_rnode *csio_rnode_lookup_portid(struct csio_lnode *, uint32_t);
+struct csio_rnode *csio_confirm_rnode(struct csio_lnode *,
+					  uint32_t, struct fcoe_rdev_entry *);
+
+void csio_rnode_fwevt_handler(struct csio_rnode *rn, uint8_t fwevt);
+
+void csio_put_rnode(struct csio_lnode *ln, struct csio_rnode *rn);
+
+void csio_reg_rnode(struct csio_rnode *);
+void csio_unreg_rnode(struct csio_rnode *);
+
+void csio_rnode_devloss_handler(struct csio_rnode *);
+
+#endif /* ifndef __CSIO_RNODE_H__ */
diff --git a/drivers/scsi/csiostor/csio_scsi.h b/drivers/scsi/csiostor/csio_scsi.h
new file mode 100644
index 0000000..c0aa2fb
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_scsi.h
@@ -0,0 +1,332 @@
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
+#ifndef __CSIO_SCSI_H__
+#define __CSIO_SCSI_H__
+
+#include <linux/spinlock_types.h>
+#include <linux/completion.h>
+#include <scsi/scsi.h>
+#include <scsi/scsi_cmnd.h>
+#include <scsi/scsi_device.h>
+#include <scsi/scsi_host.h>
+#include <scsi/scsi_eh.h>
+#include <scsi/scsi_tcq.h>
+
+#include "csio_defs.h"
+#include "csio_wr.h"
+
+extern struct scsi_host_template csio_fcoe_shost_template;
+extern struct scsi_host_template csio_fcoe_shost_vport_template;
+
+extern int csio_scsi_eqsize;
+extern int csio_scsi_iqlen;
+extern int csio_scsi_ioreqs;
+extern uint32_t csio_max_scan_tmo;
+extern uint32_t csio_delta_scan_tmo;
+extern int csio_lun_qdepth;
+
+/*
+ **************************** NOTE *******************************
+ * How do we calculate MAX FCoE SCSI SGEs? Here is the math:
+ * Max Egress WR size = 512 bytes
+ * One SCSI egress WR has the following fixed no of bytes:
+ *      48 (sizeof(struct fw_scsi_write[read]_wr)) - FW WR
+ *    + 32 (sizeof(struct csio_fcp_cmnd)) - Immediate FCP_CMD
+ *    ------
+ *      80
+ *    ------
+ * That leaves us with 512 - 96 = 432 bytes for data SGE. Using
+ * struct ulptx_sgl header for the SGE consumes:
+ *	- 4 bytes for cmnd_sge.
+ *	- 12 bytes for the first SGL.
+ * That leaves us with 416 bytes for the remaining SGE pairs. Which is
+ * is 416 / 24 (size(struct ulptx_sge_pair)) = 17 SGE pairs,
+ * or 34 SGEs. Adding the first SGE fetches us 35 SGEs.
+ */
+#define CSIO_SCSI_MAX_SGE		35
+#define CSIO_SCSI_ABRT_TMO_MS		60000
+#define CSIO_SCSI_LUNRST_TMO_MS		60000
+#define CSIO_SCSI_TM_POLL_MS		2000	/* should be less than
+						 * all TM timeouts.
+						 */
+#define CSIO_SCSI_IQ_WRSZ		128
+#define CSIO_SCSI_IQSIZE		(csio_scsi_iqlen * CSIO_SCSI_IQ_WRSZ)
+
+/* Reference to scsi_cmnd */
+#define csio_scsi_cmnd(req)		((req)->scratch1)
+
+struct csio_scsi_stats {
+	uint64_t		n_tot_success;	/* Total number of good I/Os */
+	uint32_t		n_rn_nr_error;	/* No. of remote-node-not-
+						 * ready errors
+						 */
+	uint32_t		n_hw_nr_error;	/* No. of hw-module-not-
+						 * ready errors
+						 */
+	uint32_t		n_dmamap_error;	/* No. of DMA map erros */
+	uint32_t		n_unsupp_sge_error; /* No. of too-many-SGes
+						     * errors.
+						     */
+	uint32_t		n_no_req_error;	/* No. of Out-of-ioreqs error */
+	uint32_t		n_busy_error;	/* No. of CSIO_BUSY errors */
+	uint32_t		n_hosterror;	/* No. of FW_HOSTERROR I/O */
+	uint32_t		n_rsperror;	/* No. of response errors */
+	uint32_t		n_autosense;	/* No. of auto sense replies */
+	uint32_t		n_ovflerror;	/* No. of overflow errors */
+	uint32_t		n_unflerror;	/* No. of underflow errors */
+	uint32_t		n_rdev_nr_error;/* No. of rdev not
+						 * ready errors
+						 */
+	uint32_t		n_rdev_lost_error;/* No. of rdev lost errors */
+	uint32_t		n_rdev_logo_error;/* No. of rdev logo errors */
+	uint32_t		n_link_down_error;/* No. of link down errors */
+	uint32_t		n_no_xchg_error; /* No. no exchange error */
+	uint32_t		n_unknown_error;/* No. of unhandled errors */
+	uint32_t		n_aborted;	/* No. of aborted I/Os */
+	uint32_t		n_abrt_timedout; /* No. of abort timedouts */
+	uint32_t		n_abrt_fail;	/* No. of abort failures */
+	uint32_t		n_abrt_dups;	/* No. of duplicate aborts */
+	uint32_t		n_abrt_race_comp; /* No. of aborts that raced
+						   * with completions.
+						   */
+	uint32_t		n_abrt_busy_error;/* No. of abort failures
+						   * due to CSIO_BUSY.
+						   */
+	uint32_t		n_closed;	/* No. of closed I/Os */
+	uint32_t		n_cls_busy_error; /* No. of close failures
+						   * due to CSIO_BUSY.
+						   */
+	uint32_t		n_active;	/* No. of IOs in active_q */
+	uint32_t		n_tm_active;	/* No. of TMs in active_q */
+	uint32_t		n_wcbfn;	/* No. of I/Os in worker
+						 * cbfn q
+						 */
+	uint32_t		n_free_ioreq;	/* No. of freelist entries */
+	uint32_t		n_free_ddp;	/* No. of DDP freelist */
+	uint32_t		n_unaligned;	/* No. of Unaligned SGls */
+	uint32_t		n_inval_cplop;	/* No. invalid CPL op's in IQ */
+	uint32_t		n_inval_scsiop;	/* No. invalid scsi op's in IQ*/
+};
+
+struct csio_scsim {
+	struct csio_hw		*hw;		/* Pointer to HW moduel */
+	uint8_t			max_sge;	/* Max SGE */
+	uint8_t			proto_cmd_len;	/* Proto specific SCSI
+						 * cmd length
+						 */
+	uint16_t		proto_rsp_len;	/* Proto specific SCSI
+						 * response length
+						 */
+	spinlock_t		freelist_lock;	/* Lock for ioreq freelist */
+	struct list_head	active_q;	/* Outstanding SCSI I/Os */
+	struct list_head	ioreq_freelist;	/* Free list of ioreq's */
+	struct list_head	ddp_freelist;	/* DDP descriptor freelist */
+	struct csio_scsi_stats	stats;		/* This module's statistics */
+};
+
+/* State machine defines */
+enum csio_scsi_ev {
+	CSIO_SCSIE_START_IO = 1,		/* Start a regular SCSI IO */
+	CSIO_SCSIE_START_TM,			/* Start a TM IO */
+	CSIO_SCSIE_COMPLETED,			/* IO Completed */
+	CSIO_SCSIE_ABORT,			/* Abort IO */
+	CSIO_SCSIE_ABORTED,			/* IO Aborted */
+	CSIO_SCSIE_CLOSE,			/* Close exchange */
+	CSIO_SCSIE_CLOSED,			/* Exchange closed */
+	CSIO_SCSIE_DRVCLEANUP,			/* Driver wants to manually
+						 * cleanup this I/O.
+						 */
+};
+
+enum csio_scsi_lev {
+	CSIO_LEV_ALL = 1,
+	CSIO_LEV_LNODE,
+	CSIO_LEV_RNODE,
+	CSIO_LEV_LUN,
+};
+
+struct csio_scsi_level_data {
+	enum csio_scsi_lev	level;
+	struct csio_rnode	*rnode;
+	struct csio_lnode	*lnode;
+	uint64_t		oslun;
+};
+
+static inline struct csio_ioreq *
+csio_get_scsi_ioreq(struct csio_scsim *scm)
+{
+	struct csio_ioreq *ioreq = NULL;
+
+	csio_deq_from_head(&scm->ioreq_freelist, &ioreq);
+	if (ioreq)
+		csio_dec_stats(scm, n_free_ioreq);
+
+	return ioreq;
+}
+
+static inline void
+csio_put_scsi_ioreq(struct csio_scsim *scm, struct csio_ioreq *ioreq)
+{
+	list_add_tail(&ioreq->sm.sm_list, &scm->ioreq_freelist);
+	csio_inc_stats(scm, n_free_ioreq);
+}
+
+static inline void
+csio_put_scsi_ioreq_list(struct csio_scsim *scm, struct list_head *reqlist,
+			 int n)
+{
+	list_splice_init(reqlist, &scm->ioreq_freelist);
+	scm->stats.n_free_ioreq += n;
+}
+
+static inline struct csio_dma_buf *
+csio_get_scsi_ddp(struct csio_scsim *scm)
+{
+	struct csio_dma_buf *ddp = NULL;
+
+	csio_deq_from_head(&scm->ddp_freelist, &ddp);
+	if (ddp)
+		csio_dec_stats(scm, n_free_ddp);
+
+	return ddp;
+}
+
+static inline void
+csio_put_scsi_ddp(struct csio_scsim *scm, struct csio_dma_buf *ddp)
+{
+	list_add_tail(&ddp->list, &scm->ddp_freelist);
+	csio_inc_stats(scm, n_free_ddp);
+}
+
+static inline void
+csio_put_scsi_ddp_list(struct csio_scsim *scm, struct list_head *reqlist,
+			 int n)
+{
+	list_splice_tail_init(reqlist, &scm->ddp_freelist);
+	scm->stats.n_free_ddp += n;
+}
+
+static inline void
+csio_scsi_completed(struct csio_ioreq *ioreq, struct list_head *cbfn_q)
+{
+	csio_post_event(&ioreq->sm, CSIO_SCSIE_COMPLETED);
+	if (csio_list_deleted(&ioreq->sm.sm_list))
+		list_add_tail(&ioreq->sm.sm_list, cbfn_q);
+}
+
+static inline void
+csio_scsi_aborted(struct csio_ioreq *ioreq, struct list_head *cbfn_q)
+{
+	csio_post_event(&ioreq->sm, CSIO_SCSIE_ABORTED);
+	list_add_tail(&ioreq->sm.sm_list, cbfn_q);
+}
+
+static inline void
+csio_scsi_closed(struct csio_ioreq *ioreq, struct list_head *cbfn_q)
+{
+	csio_post_event(&ioreq->sm, CSIO_SCSIE_CLOSED);
+	list_add_tail(&ioreq->sm.sm_list, cbfn_q);
+}
+
+static inline void
+csio_scsi_drvcleanup(struct csio_ioreq *ioreq)
+{
+	csio_post_event(&ioreq->sm, CSIO_SCSIE_DRVCLEANUP);
+}
+
+/*
+ * csio_scsi_start_io - Kick starts the IO SM.
+ * @req: io request SM.
+ *
+ * needs to be called with lock held.
+ */
+static inline csio_retval_t
+csio_scsi_start_io(struct csio_ioreq *ioreq)
+{
+	csio_post_event(&ioreq->sm, CSIO_SCSIE_START_IO);
+	return ioreq->drv_status;
+}
+
+/*
+ * csio_scsi_start_tm - Kicks off the Task management IO SM.
+ * @req: io request SM.
+ *
+ * needs to be called with lock held.
+ */
+static inline csio_retval_t
+csio_scsi_start_tm(struct csio_ioreq *ioreq)
+{
+	csio_post_event(&ioreq->sm, CSIO_SCSIE_START_TM);
+	return ioreq->drv_status;
+}
+
+/*
+ * csio_scsi_abort - Abort an IO request
+ * @req: io request SM.
+ *
+ * needs to be called with lock held.
+ */
+static inline csio_retval_t
+csio_scsi_abort(struct csio_ioreq *ioreq)
+{
+	csio_post_event(&ioreq->sm, CSIO_SCSIE_ABORT);
+	return ioreq->drv_status;
+}
+
+/*
+ * csio_scsi_close - Close an IO request
+ * @req: io request SM.
+ *
+ * needs to be called with lock held.
+ */
+static inline csio_retval_t
+csio_scsi_close(struct csio_ioreq *ioreq)
+{
+	csio_post_event(&ioreq->sm, CSIO_SCSIE_CLOSE);
+	return ioreq->drv_status;
+}
+
+void csio_scsi_cleanup_io_q(struct csio_scsim *, struct list_head *);
+csio_retval_t csio_scsim_cleanup_io(struct csio_scsim *, bool abort);
+csio_retval_t csio_scsim_cleanup_io_lnode(struct csio_scsim *,
+					  struct csio_lnode *);
+struct csio_ioreq *csio_scsi_cmpl_handler(struct csio_hw *, void *, uint32_t,
+					  struct csio_fl_dma_buf *,
+					  void *, uint8_t **);
+csio_retval_t csio_scsi_qconfig(struct csio_hw *);
+csio_retval_t csio_scsim_init(struct csio_scsim *, struct csio_hw *);
+void csio_scsim_exit(struct csio_scsim *);
+
+#endif /* __CSIO_SCSI_H__ */
diff --git a/drivers/scsi/csiostor/csio_wr.h b/drivers/scsi/csiostor/csio_wr.h
new file mode 100644
index 0000000..004a914
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_wr.h
@@ -0,0 +1,519 @@
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
+#ifndef __CSIO_WR_H__
+#define __CSIO_WR_H__
+
+#include <linux/cache.h>
+
+#include "csio_defs.h"
+#include "t4fw_api.h"
+#include "t4fw_api_stor.h"
+
+/*
+ * SGE register field values.
+ */
+#define X_INGPCIEBOUNDARY_32B		0
+#define X_INGPCIEBOUNDARY_64B		1
+#define X_INGPCIEBOUNDARY_128B		2
+#define X_INGPCIEBOUNDARY_256B		3
+#define X_INGPCIEBOUNDARY_512B		4
+#define X_INGPCIEBOUNDARY_1024B		5
+#define X_INGPCIEBOUNDARY_2048B		6
+#define X_INGPCIEBOUNDARY_4096B		7
+
+/* GTS register */
+#define X_TIMERREG_COUNTER0		0
+#define X_TIMERREG_COUNTER1		1
+#define X_TIMERREG_COUNTER2		2
+#define X_TIMERREG_COUNTER3		3
+#define X_TIMERREG_COUNTER4		4
+#define X_TIMERREG_COUNTER5		5
+#define X_TIMERREG_RESTART_COUNTER	6
+#define X_TIMERREG_UPDATE_CIDX		7
+
+/*
+ * Egress Context field values
+ */
+#define X_FETCHBURSTMIN_16B		0
+#define X_FETCHBURSTMIN_32B		1
+#define X_FETCHBURSTMIN_64B		2
+#define X_FETCHBURSTMIN_128B		3
+
+#define X_FETCHBURSTMAX_64B		0
+#define X_FETCHBURSTMAX_128B		1
+#define X_FETCHBURSTMAX_256B		2
+#define X_FETCHBURSTMAX_512B		3
+
+#define X_HOSTFCMODE_NONE		0
+#define X_HOSTFCMODE_INGRESS_QUEUE	1
+#define X_HOSTFCMODE_STATUS_PAGE	2
+#define X_HOSTFCMODE_BOTH		3
+
+/*
+ * Ingress Context field values
+ */
+#define X_UPDATESCHEDULING_TIMER	0
+#define X_UPDATESCHEDULING_COUNTER_OPTTIMER	1
+
+#define X_UPDATEDELIVERY_NONE		0
+#define X_UPDATEDELIVERY_INTERRUPT	1
+#define X_UPDATEDELIVERY_STATUS_PAGE	2
+#define X_UPDATEDELIVERY_BOTH		3
+
+#define X_INTERRUPTDESTINATION_PCIE	0
+#define X_INTERRUPTDESTINATION_IQ	1
+
+#define X_RSPD_TYPE_FLBUF		0
+#define X_RSPD_TYPE_CPL			1
+#define X_RSPD_TYPE_INTR		2
+
+/* WR status is at the same position as retval in a CMD header */
+#define csio_wr_status(_wr)		\
+		(FW_CMD_RETVAL_GET(ntohl(((struct fw_cmd_hdr *)(_wr))->lo)))
+
+struct csio_hw;
+
+extern int csio_intr_coalesce_cnt;
+extern int csio_intr_coalesce_time;
+
+/* Ingress queue params */
+struct csio_iq_params {
+
+	uint8_t		iq_start:1;
+	uint8_t		iq_stop:1;
+	uint8_t		pfn:3;
+
+	uint8_t		vfn;
+
+	uint16_t	physiqid;
+	uint16_t	iqid;
+
+	uint16_t	fl0id;
+	uint16_t	fl1id;
+
+	uint8_t		viid;
+
+	uint8_t		type;
+	uint8_t		iqasynch;
+	uint8_t		reserved4;
+
+	uint8_t		iqandst;
+	uint8_t		iqanus;
+	uint8_t		iqanud;
+
+	uint16_t	iqandstindex;
+
+	uint8_t		iqdroprss;
+	uint8_t		iqpciech;
+	uint8_t		iqdcaen;
+
+	uint8_t		iqdcacpu;
+	uint8_t		iqintcntthresh;
+	uint8_t		iqo;
+
+	uint8_t		iqcprio;
+	uint8_t		iqesize;
+
+	uint16_t	iqsize;
+
+	uint64_t	iqaddr;
+
+	uint8_t		iqflintiqhsen;
+	uint8_t		reserved5;
+	uint8_t		iqflintcongen;
+	uint8_t		iqflintcngchmap;
+
+	uint32_t	reserved6;
+
+	uint8_t		fl0hostfcmode;
+	uint8_t		fl0cprio;
+	uint8_t		fl0paden;
+	uint8_t		fl0packen;
+	uint8_t		fl0congen;
+	uint8_t		fl0dcaen;
+
+	uint8_t		fl0dcacpu;
+	uint8_t		fl0fbmin;
+
+	uint8_t		fl0fbmax;
+	uint8_t		fl0cidxfthresho;
+	uint8_t		fl0cidxfthresh;
+
+	uint16_t	fl0size;
+
+	uint64_t	fl0addr;
+
+	uint64_t	reserved7;
+
+	uint8_t		fl1hostfcmode;
+	uint8_t		fl1cprio;
+	uint8_t		fl1paden;
+	uint8_t		fl1packen;
+	uint8_t		fl1congen;
+	uint8_t		fl1dcaen;
+
+	uint8_t		fl1dcacpu;
+	uint8_t		fl1fbmin;
+
+	uint8_t		fl1fbmax;
+	uint8_t		fl1cidxfthresho;
+	uint8_t		fl1cidxfthresh;
+
+	uint16_t	fl1size;
+
+	uint64_t	fl1addr;
+};
+
+/* Egress queue params */
+struct csio_eq_params {
+
+	uint8_t		pfn;
+	uint8_t		vfn;
+
+	uint8_t		eqstart:1;
+	uint8_t		eqstop:1;
+
+	uint16_t        physeqid;
+	uint32_t	eqid;
+
+	uint8_t		hostfcmode:2;
+	uint8_t		cprio:1;
+	uint8_t		pciechn:3;
+
+	uint16_t	iqid;
+
+	uint8_t		dcaen:1;
+	uint8_t		dcacpu:5;
+
+	uint8_t		fbmin:3;
+	uint8_t		fbmax:3;
+
+	uint8_t		cidxfthresho:1;
+	uint8_t		cidxfthresh:3;
+
+	uint16_t	eqsize;
+
+	uint64_t	eqaddr;
+};
+
+struct csio_dma_buf {
+	struct list_head	list;
+	void			*vaddr;		/* Virtual address */
+	dma_addr_t		paddr;		/* Physical address */
+	uint32_t		len;		/* Buffer size */
+};
+
+/* Defines for csio_ioreq->datadir */
+enum {
+	CSIO_IOREQF_DMA_BIDI	= 0x0,
+	CSIO_IOREQF_DMA_WRITE	= 0x1,
+	CSIO_IOREQF_DMA_READ	= 0x2,
+	CSIO_IOREQF_DMA_NONE	= 0x4,
+};
+
+/* Generic I/O request structure */
+struct csio_ioreq {
+	struct csio_sm		sm;		/* SM, List
+						 * should be the first member
+						 */
+	int			iq_idx;		/* Ingress queue index */
+	int			eq_idx;		/* Egress queue index */
+	uint32_t		nsge;		/* Number of SG elements */
+	uint32_t		tmo;		/* Driver timeout */
+	uint32_t		datadir;	/* Data direction */
+	struct csio_dma_buf	dma_buf;	/* Req/resp DMA buffers */
+	uint16_t		wr_status;	/* WR completion status */
+	uint16_t		drv_status;	/* Driver internal status */
+	struct csio_lnode	*lnode;		/* Owner lnode */
+	struct csio_rnode	*rnode;		/* Src/destination rnode */
+	void (*io_cbfn) (struct csio_hw *, struct csio_ioreq *);
+						/* completion callback */
+	void			*scratch1;	/* Scratch area 1.
+						 */
+	void			*scratch2;	/* Scratch area 2. */
+	struct list_head	gen_list;	/* Any list associated with
+						 * this ioreq.
+						 */
+	uint64_t		fw_handle;	/* Unique handle passed
+						 * to FW
+						 */
+	uint8_t			dcopy;		/* Data copy required */
+	uint8_t			reserved1;
+	uint16_t		reserved2;
+	struct completion	cmplobj;	/* ioreq completion object */
+} ____cacheline_aligned_in_smp;
+
+/*
+ * Egress status page for egress cidx updates
+ */
+struct csio_qstatus_page {
+	__be32 qid;
+	__be16 cidx;
+	__be16 pidx;
+};
+
+
+enum {
+	CSIO_MAX_FLBUF_PER_IQWR = 4,
+	CSIO_QCREDIT_SZ  = 64,			/* pidx/cidx increments
+						 * in bytes
+						 */
+	CSIO_MAX_QID = 0xFFFF,
+	CSIO_MAX_IQ = 128,
+
+	CSIO_SGE_NTIMERS = 6,
+	CSIO_SGE_NCOUNTERS = 4,
+	CSIO_SGE_FL_SIZE_REGS = 16,
+};
+
+/* Defines for type */
+enum {
+	CSIO_EGRESS	= 1,
+	CSIO_INGRESS	= 2,
+	CSIO_FREELIST	= 3,
+};
+
+/*
+ * Structure for footer (last 2 flits) of Ingress Queue Entry.
+ */
+struct csio_iqwr_footer {
+	__be32			hdrbuflen_pidx;
+	__be32			pldbuflen_qid;
+	union {
+		u8		type_gen;
+		__be64		last_flit;
+	} u;
+};
+
+#define IQWRF_NEWBUF		(1 << 31)
+#define IQWRF_LEN_GET(x)	(((x) >> 0) & 0x7fffffffU)
+#define IQWRF_GEN_SHIFT		7
+#define IQWRF_TYPE_GET(x)	(((x) >> 4) & 0x3U)
+
+
+/*
+ * WR pair:
+ * ========
+ * A WR can start towards the end of a queue, and then continue at the
+ * beginning, since the queue is considered to be circular. This will
+ * require a pair of address/len to be passed back to the caller -
+ * hence the Work request pair structure.
+ */
+struct csio_wr_pair {
+	void			*addr1;
+	uint32_t		size1;
+	void			*addr2;
+	uint32_t		size2;
+};
+
+/*
+ * The following structure is used by ingress processing to return the
+ * free list buffers to consumers.
+ */
+struct csio_fl_dma_buf {
+	struct csio_dma_buf	flbufs[CSIO_MAX_FLBUF_PER_IQWR];
+						/* Freelist DMA buffers */
+	int			offset;		/* Offset within the
+						 * first FL buf.
+						 */
+	uint32_t		totlen;		/* Total length */
+	uint8_t			defer_free;	/* Free of buffer can
+						 * deferred
+						 */
+};
+
+/* Data-types */
+typedef void (*iq_handler_t)(struct csio_hw *, void *, uint32_t,
+			     struct csio_fl_dma_buf *, void *);
+
+struct csio_iq {
+	uint16_t		iqid;		/* Queue ID */
+	uint16_t		physiqid;	/* Physical Queue ID */
+	uint16_t		genbit;		/* Generation bit,
+						 * initially set to 1
+						 */
+	int			flq_idx;	/* Freelist queue index */
+	iq_handler_t		iq_intx_handler; /* IQ INTx handler routine */
+};
+
+struct csio_eq {
+	uint16_t		eqid;		/* Qid */
+	uint16_t		physeqid;	/* Physical Queue ID */
+};
+
+struct csio_fl {
+	uint16_t		flid;		/* Qid */
+	uint16_t		packen;		/* Packing enabled? */
+	int			offset;		/* Offset within FL buf */
+	int			sreg;		/* Size register */
+	struct csio_dma_buf	*bufs;		/* Free list buffer ptr array
+						 * indexed using flq->cidx/pidx
+						 */
+};
+
+struct csio_qstats {
+	uint32_t	n_tot_reqs;		/* Total no. of Requests */
+	uint32_t	n_tot_rsps;		/* Total no. of responses */
+	uint32_t	n_qwrap;		/* Queue wraps */
+	uint32_t	n_eq_wr_split;		/* Number of split EQ WRs */
+	uint32_t	n_qentry;		/* Queue entry */
+	uint32_t	n_qempty;		/* Queue empty */
+	uint32_t	n_qfull;		/* Queue fulls */
+	uint32_t	n_rsp_unknown;		/* Unknown response type */
+	uint32_t	n_stray_comp;		/* Stray completion intr */
+	uint32_t	n_flq_refill;		/* Number of FL refills */
+};
+
+/* Queue metadata */
+struct csio_q {
+	uint16_t		type;		/* Type: Ingress/Egress/FL */
+	uint16_t		pidx;		/* producer index */
+	uint16_t		cidx;		/* consumer index */
+	uint16_t		inc_idx;	/* Incremental index */
+	uint32_t		wr_sz;		/* Size of all WRs in this q
+						 * if fixed
+						 */
+	void			*vstart;	/* Base virtual address
+						 * of queue
+						 */
+	void			*vwrap;		/* Virtual end address to
+						 * wrap around at
+						 */
+	uint32_t		credits;	/* Size of queue in credits */
+	void			*owner;		/* Owner */
+	union {					/* Queue contexts */
+		struct csio_iq	iq;
+		struct csio_eq	eq;
+		struct csio_fl	fl;
+	} un;
+
+	dma_addr_t		pstart;		/* Base physical address of
+						 * queue
+						 */
+	uint32_t		portid;		/* PCIE Channel */
+	uint32_t		size;		/* Size of queue in bytes */
+	struct csio_qstats	stats;		/* Statistics */
+} ____cacheline_aligned_in_smp;
+
+struct csio_sge {
+	uint32_t	csio_fl_align;		/* Calculated and cached
+						 * for fast path
+						 */
+	uint32_t	sge_control;		/* padding, boundaries,
+						 * lengths, etc.
+						 */
+	uint32_t	sge_host_page_size;	/* Host page size */
+	uint32_t	sge_fl_buf_size[CSIO_SGE_FL_SIZE_REGS];
+						/* free list buffer sizes */
+	uint16_t	timer_val[CSIO_SGE_NTIMERS];
+	uint8_t		counter_val[CSIO_SGE_NCOUNTERS];
+};
+
+/* Work request module */
+struct csio_wrm {
+	int			num_q;		/* Number of queues */
+	struct csio_q		**q_arr;	/* Array of queue pointers
+						 * allocated dynamically
+						 * based on configured values
+						 */
+	uint32_t		fw_iq_start;	/* Start ID of IQ for this fn*/
+	uint32_t		fw_eq_start;	/* Start ID of EQ for this fn*/
+	struct csio_q		*intr_map[CSIO_MAX_IQ];
+						/* IQ-id to IQ map table. */
+	int			free_qidx;	/* queue idx of free queue */
+	struct csio_sge		sge;		/* SGE params */
+};
+
+#define csio_get_q(__hw, __idx)		((__hw)->wrm.q_arr[__idx])
+#define	csio_q_type(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->type)
+#define	csio_q_pidx(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->pidx)
+#define	csio_q_cidx(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->cidx)
+#define	csio_q_inc_idx(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->inc_idx)
+#define	csio_q_vstart(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->vstart)
+#define	csio_q_pstart(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->pstart)
+#define	csio_q_size(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->size)
+#define	csio_q_credits(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->credits)
+#define	csio_q_portid(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->portid)
+#define	csio_q_wr_sz(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->wr_sz)
+#define	csio_q_iqid(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->un.iq.iqid)
+#define csio_q_physiqid(__hw, __idx)					\
+				((__hw)->wrm.q_arr[(__idx)]->un.iq.physiqid)
+#define csio_q_iq_flq_idx(__hw, __idx)					\
+				((__hw)->wrm.q_arr[(__idx)]->un.iq.flq_idx)
+#define	csio_q_eqid(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->un.eq.eqid)
+#define	csio_q_flid(__hw, __idx)	((__hw)->wrm.q_arr[(__idx)]->un.fl.flid)
+
+#define csio_q_physeqid(__hw, __idx)					\
+				((__hw)->wrm.q_arr[(__idx)]->un.eq.physeqid)
+#define csio_iq_has_fl(__iq)		((__iq)->un.iq.flq_idx != -1)
+#define csio_q_owner(__hw, __idx)       ((__hw)->wrm.q_arr[(__idx)]->owner)
+
+#define csio_q_iq_to_flid(__hw, __iq_idx)				\
+	csio_q_flid((__hw), (__hw)->wrm.q_arr[(__iq_qidx)]->un.iq.flq_idx)
+#define csio_q_set_intr_map(__hw, __iq_idx, __rel_iq_id)		\
+		(__hw)->wrm.intr_map[__rel_iq_id] = csio_get_q(__hw, __iq_idx)
+
+struct csio_mb;
+
+int csio_wr_alloc_q(struct csio_hw *, uint32_t, uint32_t,
+		    uint16_t, void *, uint32_t, int, iq_handler_t);
+csio_retval_t csio_wr_iq_create(struct csio_hw *, void *, int,
+				uint32_t, uint8_t, bool,
+				void (*)(struct csio_hw *, struct csio_mb *));
+csio_retval_t csio_wr_eq_create(struct csio_hw *, void *, int, int, uint8_t,
+				void (*)(struct csio_hw *, struct csio_mb *));
+csio_retval_t csio_wr_destroy_queues(struct csio_hw *, bool cmd);
+
+
+csio_retval_t csio_wr_get(struct csio_hw *, int, uint32_t,
+			  struct csio_wr_pair *);
+void csio_wr_copy_to_wrp(void *, struct csio_wr_pair *, uint32_t, uint32_t);
+csio_retval_t csio_wr_issue(struct csio_hw *, int, bool);
+csio_retval_t csio_wr_process_iq(struct csio_hw *, struct csio_q *,
+				 void (*)(struct csio_hw *, void *,
+					  uint32_t, struct csio_fl_dma_buf *,
+					  void *),
+				 void *);
+csio_retval_t csio_wr_process_iq_idx(struct csio_hw *, int,
+				 void (*)(struct csio_hw *, void *,
+					  uint32_t, struct csio_fl_dma_buf *,
+					  void *),
+				 void *);
+
+void csio_wr_sge_init(struct csio_hw *);
+csio_retval_t csio_wrm_init(struct csio_wrm *, struct csio_hw *);
+void csio_wrm_exit(struct csio_wrm *, struct csio_hw *);
+
+#endif /* ifndef __CSIO_WR_H__ */
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

