From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH v2 net-next 21/22] csiostor: Header file modifications for chip support and bug fixes.
Date: Thu, 14 Mar 2013 20:39:07 +0530
Message-ID: <1363273748-25330-22-git-send-email-vipul@chelsio.com>
References: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com, vipul@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9391 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757791Ab3CNPQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 11:16:39 -0400
In-Reply-To: <1363273748-25330-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvind Bhushan <arvindb@chelsio.com>

This patch defines the common operations to support multiple chips. It
includes common header file modifications to support the current chips
(T4 and T5). It also includes the following bug fixes:
- reconfirms the rnode state after an implicit logo.
- corrects the stats array size.
- sets up and checks flags correctly when coming up as master and finding
the card initialized

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Arvind Bhushan <arvindb@chelsio.com>
Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
---
v2: Replaced #ifdef with portable interface wmb in ring_tx_db

 drivers/scsi/csiostor/csio_hw_chip.h |  175 ++++++++++++++++++++++++++++++++++
 drivers/scsi/csiostor/csio_lnode.h   |    2 +-
 drivers/scsi/csiostor/csio_rnode.c   |   10 ++-
 drivers/scsi/csiostor/csio_rnode.h   |    2 +-
 drivers/scsi/csiostor/csio_wr.c      |   41 +++++---
 5 files changed, 212 insertions(+), 18 deletions(-)
 create mode 100644 drivers/scsi/csiostor/csio_hw_chip.h

diff --git a/drivers/scsi/csiostor/csio_hw_chip.h b/drivers/scsi/csiostor/csio_hw_chip.h
new file mode 100644
index 0000000..bca0de6
--- /dev/null
+++ b/drivers/scsi/csiostor/csio_hw_chip.h
@@ -0,0 +1,175 @@
+/*
+ * This file is part of the Chelsio FCoE driver for Linux.
+ *
+ * Copyright (c) 2008-2013 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
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
+#ifndef __CSIO_HW_CHIP_H__
+#define __CSIO_HW_CHIP_H__
+
+#include "csio_defs.h"
+
+/* FCoE device IDs for T4 */
+#define CSIO_DEVID_T440DBG_FCOE			0x4600
+#define CSIO_DEVID_T420CR_FCOE			0x4601
+#define CSIO_DEVID_T422CR_FCOE			0x4602
+#define CSIO_DEVID_T440CR_FCOE			0x4603
+#define CSIO_DEVID_T420BCH_FCOE			0x4604
+#define CSIO_DEVID_T440BCH_FCOE			0x4605
+#define CSIO_DEVID_T440CH_FCOE			0x4606
+#define CSIO_DEVID_T420SO_FCOE			0x4607
+#define CSIO_DEVID_T420CX_FCOE			0x4608
+#define CSIO_DEVID_T420BT_FCOE			0x4609
+#define CSIO_DEVID_T404BT_FCOE			0x460A
+#define CSIO_DEVID_B420_FCOE			0x460B
+#define CSIO_DEVID_B404_FCOE			0x460C
+#define CSIO_DEVID_T480CR_FCOE			0x460D
+#define CSIO_DEVID_T440LPCR_FCOE		0x460E
+#define CSIO_DEVID_AMSTERDAM_T4_FCOE		0x460F
+#define CSIO_DEVID_HUAWEI_T480_FCOE		0x4680
+#define CSIO_DEVID_HUAWEI_T440_FCOE		0x4681
+#define CSIO_DEVID_HUAWEI_STG310_FCOE		0x4682
+#define CSIO_DEVID_ACROMAG_XMC_XAUI		0x4683
+#define CSIO_DEVID_ACROMAG_XMC_SFP_FCOE		0x4684
+#define CSIO_DEVID_QUANTA_MEZZ_SFP_FCOE		0x4685
+#define CSIO_DEVID_HUAWEI_10GT_FCOE		0x4686
+#define CSIO_DEVID_HUAWEI_T440_TOE_FCOE		0x4687
+
+/* FCoE device IDs for T5 */
+#define CSIO_DEVID_T580DBG_FCOE			0x5600
+#define CSIO_DEVID_T520CR_FCOE			0x5601
+#define CSIO_DEVID_T522CR_FCOE			0x5602
+#define CSIO_DEVID_T540CR_FCOE			0x5603
+#define CSIO_DEVID_T520BCH_FCOE			0x5604
+#define CSIO_DEVID_T540BCH_FCOE			0x5605
+#define CSIO_DEVID_T540CH_FCOE			0x5606
+#define CSIO_DEVID_T520SO_FCOE			0x5607
+#define CSIO_DEVID_T520CX_FCOE			0x5608
+#define CSIO_DEVID_T520BT_FCOE			0x5609
+#define CSIO_DEVID_T504BT_FCOE			0x560A
+#define CSIO_DEVID_B520_FCOE			0x560B
+#define CSIO_DEVID_B504_FCOE			0x560C
+#define CSIO_DEVID_T580CR2_FCOE			0x560D
+#define CSIO_DEVID_T540LPCR_FCOE		0x560E
+#define CSIO_DEVID_AMSTERDAM_T5_FCOE		0x560F
+#define CSIO_DEVID_T580LPCR_FCOE		0x5610
+#define CSIO_DEVID_T520LLCR_FCOE		0x5611
+#define CSIO_DEVID_T560CR_FCOE			0x5612
+#define CSIO_DEVID_T580CR_FCOE			0x5613
+
+/* Define MACRO values */
+#define CSIO_HW_T4				0x4000
+#define CSIO_T4_FCOE_ASIC			0x4600
+#define CSIO_HW_T5				0x5000
+#define CSIO_T5_FCOE_ASIC			0x5600
+#define CSIO_HW_CHIP_MASK			0xF000
+#define T4_REGMAP_SIZE				(160 * 1024)
+#define T5_REGMAP_SIZE				(332 * 1024)
+#define FW_FNAME_T4				"cxgb4/t4fw.bin"
+#define FW_FNAME_T5				"cxgb4/t5fw.bin"
+#define FW_CFG_NAME_T4				"cxgb4/t4-config.txt"
+#define FW_CFG_NAME_T5				"cxgb4/t5-config.txt"
+
+/* Define static functions */
+static inline int csio_is_t4(uint16_t chip)
+{
+	return (chip == CSIO_HW_T4);
+}
+
+static inline int csio_is_t5(uint16_t chip)
+{
+	return (chip == CSIO_HW_T5);
+}
+
+/* Define MACRO DEFINITIONS */
+#define CSIO_DEVICE(devid, idx)						\
+	{ PCI_VENDOR_ID_CHELSIO, (devid), PCI_ANY_ID, PCI_ANY_ID, 0, 0, (idx) }
+
+#define CSIO_HW_PIDX(hw, index)						\
+	(csio_is_t4(hw->chip_id) ? (PIDX(index)) :			\
+					(PIDX_T5(index) | DBTYPE(1U)))
+
+#define CSIO_HW_LP_INT_THRESH(hw, val)					\
+	(csio_is_t4(hw->chip_id) ? (LP_INT_THRESH(val)) :		\
+					(V_LP_INT_THRESH_T5(val)))
+
+#define CSIO_HW_M_LP_INT_THRESH(hw)					\
+	(csio_is_t4(hw->chip_id) ? (LP_INT_THRESH_MASK) : (M_LP_INT_THRESH_T5))
+
+#define CSIO_MAC_INT_CAUSE_REG(hw, port)				\
+	(csio_is_t4(hw->chip_id) ? (PORT_REG(port, XGMAC_PORT_INT_CAUSE)) : \
+				(T5_PORT_REG(port, MAC_PORT_INT_CAUSE)))
+
+#define FW_VERSION_MAJOR(hw) (csio_is_t4(hw->chip_id) ? 1 : 0)
+#define FW_VERSION_MINOR(hw) (csio_is_t4(hw->chip_id) ? 2 : 0)
+#define FW_VERSION_MICRO(hw) (csio_is_t4(hw->chip_id) ? 8 : 0)
+
+#define CSIO_FW_FNAME(hw)						\
+	(csio_is_t4(hw->chip_id) ? FW_FNAME_T4 : FW_FNAME_T5)
+
+#define CSIO_CF_FNAME(hw)						\
+	(csio_is_t4(hw->chip_id) ? FW_CFG_NAME_T4 : FW_CFG_NAME_T5)
+
+/* Declare ENUMS */
+enum { MEM_EDC0, MEM_EDC1, MEM_MC, MEM_MC0 = MEM_MC, MEM_MC1 };
+
+enum {
+	MEMWIN_APERTURE = 2048,
+	MEMWIN_BASE     = 0x1b800,
+	MEMWIN_CSIOSTOR = 6,		/* PCI-e Memory Window access */
+};
+
+/* Slow path handlers */
+struct intr_info {
+	unsigned int mask;       /* bits to check in interrupt status */
+	const char *msg;         /* message to print or NULL */
+	short stat_idx;          /* stat counter to increment or -1 */
+	unsigned short fatal;    /* whether the condition reported is fatal */
+};
+
+/* T4/T5 Chip specific ops */
+struct csio_hw;
+struct csio_hw_chip_ops {
+	int (*chip_set_mem_win)(struct csio_hw *, uint32_t);
+	void (*chip_pcie_intr_handler)(struct csio_hw *);
+	uint32_t (*chip_flash_cfg_addr)(struct csio_hw *);
+	int (*chip_mc_read)(struct csio_hw *, int, uint32_t,
+					__be32 *, uint64_t *);
+	int (*chip_edc_read)(struct csio_hw *, int, uint32_t,
+					__be32 *, uint64_t *);
+	int (*chip_memory_rw)(struct csio_hw *, u32, int, u32,
+					u32, uint32_t *, int);
+	void (*chip_dfs_create_ext_mem)(struct csio_hw *);
+};
+
+extern struct csio_hw_chip_ops t4_ops;
+extern struct csio_hw_chip_ops t5_ops;
+
+#endif /* #ifndef __CSIO_HW_CHIP_H__ */
diff --git a/drivers/scsi/csiostor/csio_lnode.h b/drivers/scsi/csiostor/csio_lnode.h
index 8d84988..0f9c041 100644
--- a/drivers/scsi/csiostor/csio_lnode.h
+++ b/drivers/scsi/csiostor/csio_lnode.h
@@ -114,7 +114,7 @@ struct csio_lnode_stats {
 	uint32_t	n_rnode_match;  /* matched rnode */
 	uint32_t	n_dev_loss_tmo; /* Device loss timeout */
 	uint32_t	n_fdmi_err;	/* fdmi err */
-	uint32_t	n_evt_fw[RSCN_DEV_LOST];	/* fw events */
+	uint32_t	n_evt_fw[PROTO_ERR_IMPL_LOGO];	/* fw events */
 	enum csio_ln_ev	n_evt_sm[CSIO_LNE_MAX_EVENT];	/* State m/c events */
 	uint32_t	n_rnode_alloc;	/* rnode allocated */
 	uint32_t	n_rnode_free;	/* rnode freed */
diff --git a/drivers/scsi/csiostor/csio_rnode.c b/drivers/scsi/csiostor/csio_rnode.c
index 51c6a38..e9c3b04 100644
--- a/drivers/scsi/csiostor/csio_rnode.c
+++ b/drivers/scsi/csiostor/csio_rnode.c
@@ -302,7 +302,7 @@ csio_confirm_rnode(struct csio_lnode *ln, uint32_t rdev_flowid,
 {
 	uint8_t rport_type;
 	struct csio_rnode *rn, *match_rn;
-	uint32_t vnp_flowid;
+	uint32_t vnp_flowid = 0;
 	__be32 *port_id;
 
 	port_id = (__be32 *)&rdevp->r_id[0];
@@ -350,6 +350,14 @@ csio_confirm_rnode(struct csio_lnode *ln, uint32_t rdev_flowid,
 			 * Else, go ahead and alloc a new rnode.
 			 */
 			if (!memcmp(csio_rn_wwpn(match_rn), rdevp->wwpn, 8)) {
+				if (rn == match_rn)
+					goto found_rnode;
+				csio_ln_dbg(ln,
+					    "nport_id:x%x and wwpn:%llx"
+					    " match for ssni:x%x\n",
+					    rn->nport_id,
+					    wwn_to_u64(rdevp->wwpn),
+					    rdev_flowid);
 				if (csio_is_rnode_ready(rn)) {
 					csio_ln_warn(ln,
 						     "rnode is already"
diff --git a/drivers/scsi/csiostor/csio_rnode.h b/drivers/scsi/csiostor/csio_rnode.h
index a3b434c..6594009 100644
--- a/drivers/scsi/csiostor/csio_rnode.h
+++ b/drivers/scsi/csiostor/csio_rnode.h
@@ -63,7 +63,7 @@ struct csio_rnode_stats {
 	uint32_t	n_err_nomem;	/* error nomem */
 	uint32_t	n_evt_unexp;	/* unexpected event */
 	uint32_t	n_evt_drop;	/* unexpected event */
-	uint32_t	n_evt_fw[RSCN_DEV_LOST];	/* fw events */
+	uint32_t	n_evt_fw[PROTO_ERR_IMPL_LOGO];	/* fw events */
 	enum csio_rn_ev	n_evt_sm[CSIO_RNFE_MAX_EVENT];	/* State m/c events */
 	uint32_t	n_lun_rst;	/* Number of resets of
 					 * of LUNs under this
diff --git a/drivers/scsi/csiostor/csio_wr.c b/drivers/scsi/csiostor/csio_wr.c
index c32df1b..713e77d 100644
--- a/drivers/scsi/csiostor/csio_wr.c
+++ b/drivers/scsi/csiostor/csio_wr.c
@@ -1331,14 +1331,21 @@ csio_wr_fixup_host_params(struct csio_hw *hw)
 
 	/* FL BUFFER SIZE#0 is Page size i,e already aligned to cache line */
 	csio_wr_reg32(hw, PAGE_SIZE, SGE_FL_BUFFER_SIZE0);
-	csio_wr_reg32(hw,
-		      (csio_rd_reg32(hw, SGE_FL_BUFFER_SIZE2) +
-		      sge->csio_fl_align - 1) & ~(sge->csio_fl_align - 1),
-		      SGE_FL_BUFFER_SIZE2);
-	csio_wr_reg32(hw,
-		      (csio_rd_reg32(hw, SGE_FL_BUFFER_SIZE3) +
-		      sge->csio_fl_align - 1) & ~(sge->csio_fl_align - 1),
-		      SGE_FL_BUFFER_SIZE3);
+
+	/*
+	 * If using hard params, the following will get set correctly
+	 * in csio_wr_set_sge().
+	 */
+	if (hw->flags & CSIO_HWF_USING_SOFT_PARAMS) {
+		csio_wr_reg32(hw,
+			(csio_rd_reg32(hw, SGE_FL_BUFFER_SIZE2) +
+			sge->csio_fl_align - 1) & ~(sge->csio_fl_align - 1),
+			SGE_FL_BUFFER_SIZE2);
+		csio_wr_reg32(hw,
+			(csio_rd_reg32(hw, SGE_FL_BUFFER_SIZE3) +
+			sge->csio_fl_align - 1) & ~(sge->csio_fl_align - 1),
+			SGE_FL_BUFFER_SIZE3);
+	}
 
 	csio_wr_reg32(hw, HPZ0(PAGE_SHIFT - 12), ULP_RX_TDDP_PSZ);
 
@@ -1470,8 +1477,10 @@ csio_wr_set_sge(struct csio_hw *hw)
 	/* SGE_FL_BUFFER_SIZE0 is set up by csio_wr_fixup_host_params(). */
 
 	CSIO_SET_FLBUF_SIZE(hw, 1, CSIO_SGE_FLBUF_SIZE1);
-	CSIO_SET_FLBUF_SIZE(hw, 2, CSIO_SGE_FLBUF_SIZE2);
-	CSIO_SET_FLBUF_SIZE(hw, 3, CSIO_SGE_FLBUF_SIZE3);
+	csio_wr_reg32(hw, (CSIO_SGE_FLBUF_SIZE2 + sge->csio_fl_align - 1)
+		      & ~(sge->csio_fl_align - 1), SGE_FL_BUFFER_SIZE2);
+	csio_wr_reg32(hw, (CSIO_SGE_FLBUF_SIZE3 + sge->csio_fl_align - 1)
+		      & ~(sge->csio_fl_align - 1), SGE_FL_BUFFER_SIZE3);
 	CSIO_SET_FLBUF_SIZE(hw, 4, CSIO_SGE_FLBUF_SIZE4);
 	CSIO_SET_FLBUF_SIZE(hw, 5, CSIO_SGE_FLBUF_SIZE5);
 	CSIO_SET_FLBUF_SIZE(hw, 6, CSIO_SGE_FLBUF_SIZE6);
@@ -1522,22 +1531,24 @@ void
 csio_wr_sge_init(struct csio_hw *hw)
 {
 	/*
-	 * If we are master:
+	 * If we are master and chip is not initialized:
 	 *    - If we plan to use the config file, we need to fixup some
 	 *      host specific registers, and read the rest of the SGE
 	 *      configuration.
 	 *    - If we dont plan to use the config file, we need to initialize
 	 *      SGE entirely, including fixing the host specific registers.
+	 * If we are master and chip is initialized, just read and work off of
+	 *	the already initialized SGE values.
 	 * If we arent the master, we are only allowed to read and work off of
 	 *      the already initialized SGE values.
 	 *
 	 * Therefore, before calling this function, we assume that the master-
-	 * ship of the card, and whether to use config file or not, have
-	 * already been decided. In other words, CSIO_HWF_USING_SOFT_PARAMS and
-	 * CSIO_HWF_MASTER should be set/unset.
+	 * ship of the card, state and whether to use config file or not, have
+	 * already been decided.
 	 */
 	if (csio_is_hw_master(hw)) {
-		csio_wr_fixup_host_params(hw);
+		if (hw->fw_state != CSIO_DEV_STATE_INIT)
+			csio_wr_fixup_host_params(hw);
 
 		if (hw->flags & CSIO_HWF_USING_SOFT_PARAMS)
 			csio_wr_get_sge(hw);
-- 
1.7.1
