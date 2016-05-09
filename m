From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 01/14] qed: Add CONFIG_QED_SRIOV
Date: Mon, 9 May 2016 16:19:10 +0300
Message-ID: <1462799963-23547-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:19055 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751631AbcEINTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 09:19:53 -0400
In-Reply-To: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for a new Kconfig option for qed* driver which would allow
[eventually] the support in VFs.

This patch adds the necessary logic in the PF to learn about the possible
VFs it will have to support [Based on PCI configuration space and HW],
and prepare a database with an entry per-VF as infrastructure for future
interaction with said VFs.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/Kconfig         |  10 +
 drivers/net/ethernet/qlogic/qed/Makefile    |   1 +
 drivers/net/ethernet/qlogic/qed/qed.h       |   7 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c   |  19 ++
 drivers/net/ethernet/qlogic/qed/qed_hw.c    |  11 +
 drivers/net/ethernet/qlogic/qed/qed_hw.h    |  10 +
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 366 ++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h | 185 ++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h    |  41 ++++
 9 files changed, 650 insertions(+)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_sriov.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_sriov.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_vf.h

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index c0a11b5..680d8c7 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -98,6 +98,16 @@ config QED
 	---help---
 	  This enables the support for ...
 
+config QED_SRIOV
+	bool "QLogic QED 25/40/100Gb SR-IOV support"
+	depends on QED && PCI_IOV
+	default y
+	---help---
+	  This configuration parameter enables Single Root Input Output
+	  Virtualization support for QED devices.
+	  This allows for virtual function acceleration in virtualized
+	  environments.
+
 config QEDE
 	tristate "QLogic QED 25/40/100Gb Ethernet NIC"
 	depends on QED
diff --git a/drivers/net/ethernet/qlogic/qed/Makefile b/drivers/net/ethernet/qlogic/qed/Makefile
index aafa669..e11a809 100644
--- a/drivers/net/ethernet/qlogic/qed/Makefile
+++ b/drivers/net/ethernet/qlogic/qed/Makefile
@@ -3,3 +3,4 @@ obj-$(CONFIG_QED) := qed.o
 qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o qed_init_ops.o \
 	 qed_int.o qed_main.o qed_mcp.o qed_sp_commands.o qed_spq.o qed_l2.o \
 	 qed_selftest.o
+qed-$(CONFIG_QED_SRIOV) += qed_sriov.o
diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index cceac32..2e067c7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -152,6 +152,7 @@ enum QED_RESOURCES {
 
 enum QED_FEATURE {
 	QED_PF_L2_QUE,
+	QED_VF,
 	QED_MAX_FEATURES,
 };
 
@@ -360,6 +361,7 @@ struct qed_hwfn {
 	/* True if the driver requests for the link */
 	bool				b_drv_link_init;
 
+	struct qed_pf_iov		*pf_iov_info;
 	struct qed_mcp_info		*mcp_info;
 
 	struct qed_hw_cid_data		*p_tx_cids;
@@ -484,6 +486,10 @@ struct qed_dev {
 	u8				num_hwfns;
 	struct qed_hwfn			hwfns[MAX_HWFNS_PER_DEVICE];
 
+	/* SRIOV */
+	struct qed_hw_sriov_info *p_iov_info;
+#define IS_QED_SRIOV(cdev)              (!!(cdev)->p_iov_info)
+
 	unsigned long			tunn_mode;
 	u32				drv_type;
 
@@ -514,6 +520,7 @@ struct qed_dev {
 	const struct firmware		*firmware;
 };
 
+#define NUM_OF_VFS(dev)         MAX_NUM_VFS_BB
 #define NUM_OF_SBS(dev)         MAX_SB_PER_PATH_BB
 #define NUM_OF_ENG_PFS(dev)     MAX_NUM_PFS_BB
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index b500c86..7a359c4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -30,6 +30,7 @@
 #include "qed_mcp.h"
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
+#include "qed_sriov.h"
 
 /* API common to all protocols */
 enum BAR_ID {
@@ -136,6 +137,7 @@ void qed_resc_free(struct qed_dev *cdev)
 		qed_eq_free(p_hwfn, p_hwfn->p_eq);
 		qed_consq_free(p_hwfn, p_hwfn->p_consq);
 		qed_int_free(p_hwfn);
+		qed_iov_free(p_hwfn);
 		qed_dmae_info_free(p_hwfn);
 	}
 }
@@ -316,6 +318,10 @@ int qed_resc_alloc(struct qed_dev *cdev)
 		if (rc)
 			goto alloc_err;
 
+		rc = qed_iov_alloc(p_hwfn);
+		if (rc)
+			goto alloc_err;
+
 		/* EQ */
 		p_eq = qed_eq_alloc(p_hwfn, 256);
 		if (!p_eq) {
@@ -373,6 +379,8 @@ void qed_resc_setup(struct qed_dev *cdev)
 		       p_hwfn->mcp_info->mfw_mb_length);
 
 		qed_int_setup(p_hwfn, p_hwfn->p_main_ptt);
+
+		qed_iov_setup(p_hwfn, p_hwfn->p_main_ptt);
 	}
 }
 
@@ -1238,6 +1246,13 @@ qed_get_hw_info(struct qed_hwfn *p_hwfn,
 	u32 port_mode;
 	int rc;
 
+	/* Since all information is common, only first hwfns should do this */
+	if (IS_LEAD_HWFN(p_hwfn)) {
+		rc = qed_iov_hw_info(p_hwfn);
+		if (rc)
+			return rc;
+	}
+
 	/* Read the port mode */
 	port_mode = qed_rd(p_hwfn, p_ptt,
 			   CNIG_REG_NW_PORT_MODE_BB_B0);
@@ -1397,6 +1412,8 @@ static int qed_hw_prepare_single(struct qed_hwfn *p_hwfn,
 
 	return rc;
 err2:
+	if (IS_LEAD_HWFN(p_hwfn))
+		qed_iov_free_hw_info(p_hwfn->cdev);
 	qed_mcp_free(p_hwfn);
 err1:
 	qed_hw_hwfn_free(p_hwfn);
@@ -1463,6 +1480,8 @@ void qed_hw_remove(struct qed_dev *cdev)
 		qed_hw_hwfn_free(p_hwfn);
 		qed_mcp_free(p_hwfn);
 	}
+
+	qed_iov_free_hw_info(cdev);
 }
 
 int qed_chain_alloc(struct qed_dev *cdev,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.c b/drivers/net/ethernet/qlogic/qed/qed_hw.c
index a95a3e4..a8cf96c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hw.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.c
@@ -338,6 +338,17 @@ void qed_port_unpretend(struct qed_hwfn *p_hwfn,
 	       *(u32 *)&p_ptt->pxp.pretend);
 }
 
+u32 qed_vfid_to_concrete(struct qed_hwfn *p_hwfn, u8 vfid)
+{
+	u32 concrete_fid = 0;
+
+	SET_FIELD(concrete_fid, PXP_CONCRETE_FID_PFID, p_hwfn->rel_pf_id);
+	SET_FIELD(concrete_fid, PXP_CONCRETE_FID_VFID, vfid);
+	SET_FIELD(concrete_fid, PXP_CONCRETE_FID_VFVALID, 1);
+
+	return concrete_fid;
+}
+
 /* DMAE */
 static void qed_dmae_opcode(struct qed_hwfn *p_hwfn,
 			    const u8 is_src_type_grc,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.h b/drivers/net/ethernet/qlogic/qed/qed_hw.h
index e56d433..4367363 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hw.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.h
@@ -221,6 +221,16 @@ void qed_port_unpretend(struct qed_hwfn *p_hwfn,
 			struct qed_ptt *p_ptt);
 
 /**
+ * @brief qed_vfid_to_concrete - build a concrete FID for a
+ *        given VF ID
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param vfid
+ */
+u32 qed_vfid_to_concrete(struct qed_hwfn *p_hwfn, u8 vfid);
+
+/**
  * @brief qed_dmae_idx_to_go_cmd - map the idx to dmae cmd
  * this is declared here since other files will require it.
  * @param idx
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
new file mode 100644
index 0000000..685e3fa
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -0,0 +1,366 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include "qed_hw.h"
+#include "qed_int.h"
+#include "qed_reg_addr.h"
+#include "qed_sriov.h"
+#include "qed_vf.h"
+
+bool qed_iov_is_valid_vfid(struct qed_hwfn *p_hwfn,
+			   int rel_vf_id, bool b_enabled_only)
+{
+	if (!p_hwfn->pf_iov_info) {
+		DP_NOTICE(p_hwfn->cdev, "No iov info\n");
+		return false;
+	}
+
+	if ((rel_vf_id >= p_hwfn->cdev->p_iov_info->total_vfs) ||
+	    (rel_vf_id < 0))
+		return false;
+
+	if ((!p_hwfn->pf_iov_info->vfs_array[rel_vf_id].b_init) &&
+	    b_enabled_only)
+		return false;
+
+	return true;
+}
+
+static int qed_iov_pci_cfg_info(struct qed_dev *cdev)
+{
+	struct qed_hw_sriov_info *iov = cdev->p_iov_info;
+	int pos = iov->pos;
+
+	DP_VERBOSE(cdev, QED_MSG_IOV, "sriov ext pos %d\n", pos);
+	pci_read_config_word(cdev->pdev, pos + PCI_SRIOV_CTRL, &iov->ctrl);
+
+	pci_read_config_word(cdev->pdev,
+			     pos + PCI_SRIOV_TOTAL_VF, &iov->total_vfs);
+	pci_read_config_word(cdev->pdev,
+			     pos + PCI_SRIOV_INITIAL_VF, &iov->initial_vfs);
+
+	pci_read_config_word(cdev->pdev, pos + PCI_SRIOV_NUM_VF, &iov->num_vfs);
+	if (iov->num_vfs) {
+		DP_VERBOSE(cdev,
+			   QED_MSG_IOV,
+			   "Number of VFs are already set to non-zero value. Ignoring PCI configuration value\n");
+		iov->num_vfs = 0;
+	}
+
+	pci_read_config_word(cdev->pdev,
+			     pos + PCI_SRIOV_VF_OFFSET, &iov->offset);
+
+	pci_read_config_word(cdev->pdev,
+			     pos + PCI_SRIOV_VF_STRIDE, &iov->stride);
+
+	pci_read_config_word(cdev->pdev,
+			     pos + PCI_SRIOV_VF_DID, &iov->vf_device_id);
+
+	pci_read_config_dword(cdev->pdev,
+			      pos + PCI_SRIOV_SUP_PGSIZE, &iov->pgsz);
+
+	pci_read_config_dword(cdev->pdev, pos + PCI_SRIOV_CAP, &iov->cap);
+
+	pci_read_config_byte(cdev->pdev, pos + PCI_SRIOV_FUNC_LINK, &iov->link);
+
+	DP_VERBOSE(cdev,
+		   QED_MSG_IOV,
+		   "IOV info: nres %d, cap 0x%x, ctrl 0x%x, total %d, initial %d, num vfs %d, offset %d, stride %d, page size 0x%x\n",
+		   iov->nres,
+		   iov->cap,
+		   iov->ctrl,
+		   iov->total_vfs,
+		   iov->initial_vfs,
+		   iov->nr_virtfn, iov->offset, iov->stride, iov->pgsz);
+
+	/* Some sanity checks */
+	if (iov->num_vfs > NUM_OF_VFS(cdev) ||
+	    iov->total_vfs > NUM_OF_VFS(cdev)) {
+		/* This can happen only due to a bug. In this case we set
+		 * num_vfs to zero to avoid memory corruption in the code that
+		 * assumes max number of vfs
+		 */
+		DP_NOTICE(cdev,
+			  "IOV: Unexpected number of vfs set: %d setting num_vf to zero\n",
+			  iov->num_vfs);
+
+		iov->num_vfs = 0;
+		iov->total_vfs = 0;
+	}
+
+	return 0;
+}
+
+static void qed_iov_clear_vf_igu_blocks(struct qed_hwfn *p_hwfn,
+					struct qed_ptt *p_ptt)
+{
+	struct qed_igu_block *p_sb;
+	u16 sb_id;
+	u32 val;
+
+	if (!p_hwfn->hw_info.p_igu_info) {
+		DP_ERR(p_hwfn,
+		       "qed_iov_clear_vf_igu_blocks IGU Info not initialized\n");
+		return;
+	}
+
+	for (sb_id = 0; sb_id < QED_MAPPING_MEMORY_SIZE(p_hwfn->cdev);
+	     sb_id++) {
+		p_sb = &p_hwfn->hw_info.p_igu_info->igu_map.igu_blocks[sb_id];
+		if ((p_sb->status & QED_IGU_STATUS_FREE) &&
+		    !(p_sb->status & QED_IGU_STATUS_PF)) {
+			val = qed_rd(p_hwfn, p_ptt,
+				     IGU_REG_MAPPING_MEMORY + sb_id * 4);
+			SET_FIELD(val, IGU_MAPPING_LINE_VALID, 0);
+			qed_wr(p_hwfn, p_ptt,
+			       IGU_REG_MAPPING_MEMORY + 4 * sb_id, val);
+		}
+	}
+}
+
+static void qed_iov_setup_vfdb(struct qed_hwfn *p_hwfn)
+{
+	struct qed_hw_sriov_info *p_iov = p_hwfn->cdev->p_iov_info;
+	struct qed_pf_iov *p_iov_info = p_hwfn->pf_iov_info;
+	struct qed_bulletin_content *p_bulletin_virt;
+	dma_addr_t req_p, rply_p, bulletin_p;
+	union pfvf_tlvs *p_reply_virt_addr;
+	union vfpf_tlvs *p_req_virt_addr;
+	u8 idx = 0;
+
+	memset(p_iov_info->vfs_array, 0, sizeof(p_iov_info->vfs_array));
+
+	p_req_virt_addr = p_iov_info->mbx_msg_virt_addr;
+	req_p = p_iov_info->mbx_msg_phys_addr;
+	p_reply_virt_addr = p_iov_info->mbx_reply_virt_addr;
+	rply_p = p_iov_info->mbx_reply_phys_addr;
+	p_bulletin_virt = p_iov_info->p_bulletins;
+	bulletin_p = p_iov_info->bulletins_phys;
+	if (!p_req_virt_addr || !p_reply_virt_addr || !p_bulletin_virt) {
+		DP_ERR(p_hwfn,
+		       "qed_iov_setup_vfdb called without allocating mem first\n");
+		return;
+	}
+
+	for (idx = 0; idx < p_iov->total_vfs; idx++) {
+		struct qed_vf_info *vf = &p_iov_info->vfs_array[idx];
+		u32 concrete;
+
+		vf->vf_mbx.req_virt = p_req_virt_addr + idx;
+		vf->vf_mbx.req_phys = req_p + idx * sizeof(union vfpf_tlvs);
+		vf->vf_mbx.reply_virt = p_reply_virt_addr + idx;
+		vf->vf_mbx.reply_phys = rply_p + idx * sizeof(union pfvf_tlvs);
+
+		vf->state = VF_STOPPED;
+		vf->b_init = false;
+
+		vf->bulletin.phys = idx *
+				    sizeof(struct qed_bulletin_content) +
+				    bulletin_p;
+		vf->bulletin.p_virt = p_bulletin_virt + idx;
+		vf->bulletin.size = sizeof(struct qed_bulletin_content);
+
+		vf->relative_vf_id = idx;
+		vf->abs_vf_id = idx + p_iov->first_vf_in_pf;
+		concrete = qed_vfid_to_concrete(p_hwfn, vf->abs_vf_id);
+		vf->concrete_fid = concrete;
+		vf->opaque_fid = (p_hwfn->hw_info.opaque_fid & 0xff) |
+				 (vf->abs_vf_id << 8);
+		vf->vport_id = idx + 1;
+	}
+}
+
+static int qed_iov_allocate_vfdb(struct qed_hwfn *p_hwfn)
+{
+	struct qed_pf_iov *p_iov_info = p_hwfn->pf_iov_info;
+	void **p_v_addr;
+	u16 num_vfs = 0;
+
+	num_vfs = p_hwfn->cdev->p_iov_info->total_vfs;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+		   "qed_iov_allocate_vfdb for %d VFs\n", num_vfs);
+
+	/* Allocate PF Mailbox buffer (per-VF) */
+	p_iov_info->mbx_msg_size = sizeof(union vfpf_tlvs) * num_vfs;
+	p_v_addr = &p_iov_info->mbx_msg_virt_addr;
+	*p_v_addr = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+				       p_iov_info->mbx_msg_size,
+				       &p_iov_info->mbx_msg_phys_addr,
+				       GFP_KERNEL);
+	if (!*p_v_addr)
+		return -ENOMEM;
+
+	/* Allocate PF Mailbox Reply buffer (per-VF) */
+	p_iov_info->mbx_reply_size = sizeof(union pfvf_tlvs) * num_vfs;
+	p_v_addr = &p_iov_info->mbx_reply_virt_addr;
+	*p_v_addr = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+				       p_iov_info->mbx_reply_size,
+				       &p_iov_info->mbx_reply_phys_addr,
+				       GFP_KERNEL);
+	if (!*p_v_addr)
+		return -ENOMEM;
+
+	p_iov_info->bulletins_size = sizeof(struct qed_bulletin_content) *
+				     num_vfs;
+	p_v_addr = &p_iov_info->p_bulletins;
+	*p_v_addr = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+				       p_iov_info->bulletins_size,
+				       &p_iov_info->bulletins_phys,
+				       GFP_KERNEL);
+	if (!*p_v_addr)
+		return -ENOMEM;
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "PF's Requests mailbox [%p virt 0x%llx phys],  Response mailbox [%p virt 0x%llx phys] Bulletins [%p virt 0x%llx phys]\n",
+		   p_iov_info->mbx_msg_virt_addr,
+		   (u64) p_iov_info->mbx_msg_phys_addr,
+		   p_iov_info->mbx_reply_virt_addr,
+		   (u64) p_iov_info->mbx_reply_phys_addr,
+		   p_iov_info->p_bulletins, (u64) p_iov_info->bulletins_phys);
+
+	return 0;
+}
+
+static void qed_iov_free_vfdb(struct qed_hwfn *p_hwfn)
+{
+	struct qed_pf_iov *p_iov_info = p_hwfn->pf_iov_info;
+
+	if (p_hwfn->pf_iov_info->mbx_msg_virt_addr)
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  p_iov_info->mbx_msg_size,
+				  p_iov_info->mbx_msg_virt_addr,
+				  p_iov_info->mbx_msg_phys_addr);
+
+	if (p_hwfn->pf_iov_info->mbx_reply_virt_addr)
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  p_iov_info->mbx_reply_size,
+				  p_iov_info->mbx_reply_virt_addr,
+				  p_iov_info->mbx_reply_phys_addr);
+
+	if (p_iov_info->p_bulletins)
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  p_iov_info->bulletins_size,
+				  p_iov_info->p_bulletins,
+				  p_iov_info->bulletins_phys);
+}
+
+int qed_iov_alloc(struct qed_hwfn *p_hwfn)
+{
+	struct qed_pf_iov *p_sriov;
+
+	if (!IS_PF_SRIOV(p_hwfn)) {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "No SR-IOV - no need for IOV db\n");
+		return 0;
+	}
+
+	p_sriov = kzalloc(sizeof(*p_sriov), GFP_KERNEL);
+	if (!p_sriov) {
+		DP_NOTICE(p_hwfn, "Failed to allocate `struct qed_sriov'\n");
+		return -ENOMEM;
+	}
+
+	p_hwfn->pf_iov_info = p_sriov;
+
+	return qed_iov_allocate_vfdb(p_hwfn);
+}
+
+void qed_iov_setup(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	if (!IS_PF_SRIOV(p_hwfn) || !IS_PF_SRIOV_ALLOC(p_hwfn))
+		return;
+
+	qed_iov_setup_vfdb(p_hwfn);
+	qed_iov_clear_vf_igu_blocks(p_hwfn, p_ptt);
+}
+
+void qed_iov_free(struct qed_hwfn *p_hwfn)
+{
+	if (IS_PF_SRIOV_ALLOC(p_hwfn)) {
+		qed_iov_free_vfdb(p_hwfn);
+		kfree(p_hwfn->pf_iov_info);
+	}
+}
+
+void qed_iov_free_hw_info(struct qed_dev *cdev)
+{
+	kfree(cdev->p_iov_info);
+	cdev->p_iov_info = NULL;
+}
+
+int qed_iov_hw_info(struct qed_hwfn *p_hwfn)
+{
+	struct qed_dev *cdev = p_hwfn->cdev;
+	int pos;
+	int rc;
+
+	/* Learn the PCI configuration */
+	pos = pci_find_ext_capability(p_hwfn->cdev->pdev,
+				      PCI_EXT_CAP_ID_SRIOV);
+	if (!pos) {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV, "No PCIe IOV support\n");
+		return 0;
+	}
+
+	/* Allocate a new struct for IOV information */
+	cdev->p_iov_info = kzalloc(sizeof(*cdev->p_iov_info), GFP_KERNEL);
+	if (!cdev->p_iov_info) {
+		DP_NOTICE(p_hwfn, "Can't support IOV due to lack of memory\n");
+		return -ENOMEM;
+	}
+	cdev->p_iov_info->pos = pos;
+
+	rc = qed_iov_pci_cfg_info(cdev);
+	if (rc)
+		return rc;
+
+	/* We want PF IOV to be synonemous with the existance of p_iov_info;
+	 * In case the capability is published but there are no VFs, simply
+	 * de-allocate the struct.
+	 */
+	if (!cdev->p_iov_info->total_vfs) {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "IOV capabilities, but no VFs are published\n");
+		kfree(cdev->p_iov_info);
+		cdev->p_iov_info = NULL;
+		return 0;
+	}
+
+	/* Calculate the first VF index - this is a bit tricky; Basically,
+	 * VFs start at offset 16 relative to PF0, and 2nd engine VFs begin
+	 * after the first engine's VFs.
+	 */
+	cdev->p_iov_info->first_vf_in_pf = p_hwfn->cdev->p_iov_info->offset +
+					   p_hwfn->abs_pf_id - 16;
+	if (QED_PATH_ID(p_hwfn))
+		cdev->p_iov_info->first_vf_in_pf -= MAX_NUM_VFS_BB;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+		   "First VF in hwfn 0x%08x\n",
+		   cdev->p_iov_info->first_vf_in_pf);
+
+	return 0;
+}
+
+u16 qed_iov_get_next_active_vf(struct qed_hwfn *p_hwfn, u16 rel_vf_id)
+{
+	struct qed_hw_sriov_info *p_iov = p_hwfn->cdev->p_iov_info;
+	u16 i;
+
+	if (!p_iov)
+		goto out;
+
+	for (i = rel_vf_id; i < p_iov->total_vfs; i++)
+		if (qed_iov_is_valid_vfid(p_hwfn, rel_vf_id, true))
+			return i;
+
+out:
+	return MAX_NUM_VFS;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
new file mode 100644
index 0000000..0ac5619
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -0,0 +1,185 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_SRIOV_H
+#define _QED_SRIOV_H
+#include <linux/types.h>
+#include "qed_vf.h"
+#define QED_VF_ARRAY_LENGTH (3)
+
+#define IS_VF(cdev)             ((cdev)->b_is_vf)
+#define IS_PF(cdev)             (!((cdev)->b_is_vf))
+#ifdef CONFIG_QED_SRIOV
+#define IS_PF_SRIOV(p_hwfn)     (!!((p_hwfn)->cdev->p_iov_info))
+#else
+#define IS_PF_SRIOV(p_hwfn)     (0)
+#endif
+#define IS_PF_SRIOV_ALLOC(p_hwfn)       (!!((p_hwfn)->pf_iov_info))
+
+/* This struct is part of qed_dev and contains data relevant to all hwfns;
+ * Initialized only if SR-IOV cpabability is exposed in PCIe config space.
+ */
+struct qed_hw_sriov_info {
+	int pos;		/* capability position */
+	int nres;		/* number of resources */
+	u32 cap;		/* SR-IOV Capabilities */
+	u16 ctrl;		/* SR-IOV Control */
+	u16 total_vfs;		/* total VFs associated with the PF */
+	u16 num_vfs;		/* number of vfs that have been started */
+	u16 initial_vfs;	/* initial VFs associated with the PF */
+	u16 nr_virtfn;		/* number of VFs available */
+	u16 offset;		/* first VF Routing ID offset */
+	u16 stride;		/* following VF stride */
+	u16 vf_device_id;	/* VF device id */
+	u32 pgsz;		/* page size for BAR alignment */
+	u8 link;		/* Function Dependency Link */
+
+	u32 first_vf_in_pf;
+};
+
+/* This mailbox is maintained per VF in its PF contains all information
+ * required for sending / receiving a message.
+ */
+struct qed_iov_vf_mbx {
+	union vfpf_tlvs *req_virt;
+	dma_addr_t req_phys;
+	union pfvf_tlvs *reply_virt;
+	dma_addr_t reply_phys;
+};
+
+enum vf_state {
+	VF_STOPPED		/* VF, Stopped */
+};
+
+/* PFs maintain an array of this structure, per VF */
+struct qed_vf_info {
+	struct qed_iov_vf_mbx vf_mbx;
+	enum vf_state state;
+	bool b_init;
+
+	struct qed_bulletin bulletin;
+	dma_addr_t vf_bulletin;
+
+	u32 concrete_fid;
+	u16 opaque_fid;
+
+	u8 vport_id;
+	u8 relative_vf_id;
+	u8 abs_vf_id;
+#define QED_VF_ABS_ID(p_hwfn, p_vf)	(QED_PATH_ID(p_hwfn) ?		      \
+					 (p_vf)->abs_vf_id + MAX_NUM_VFS_BB : \
+					 (p_vf)->abs_vf_id)
+};
+
+/* This structure is part of qed_hwfn and used only for PFs that have sriov
+ * capability enabled.
+ */
+struct qed_pf_iov {
+	struct qed_vf_info vfs_array[MAX_NUM_VFS];
+	u64 pending_events[QED_VF_ARRAY_LENGTH];
+	u64 pending_flr[QED_VF_ARRAY_LENGTH];
+
+	/* Allocate message address continuosuly and split to each VF */
+	void *mbx_msg_virt_addr;
+	dma_addr_t mbx_msg_phys_addr;
+	u32 mbx_msg_size;
+	void *mbx_reply_virt_addr;
+	dma_addr_t mbx_reply_phys_addr;
+	u32 mbx_reply_size;
+	void *p_bulletins;
+	dma_addr_t bulletins_phys;
+	u32 bulletins_size;
+};
+
+#ifdef CONFIG_QED_SRIOV
+/**
+ * @brief - Given a VF index, return index of next [including that] active VF.
+ *
+ * @param p_hwfn
+ * @param rel_vf_id
+ *
+ * @return MAX_NUM_VFS in case no further active VFs, otherwise index.
+ */
+u16 qed_iov_get_next_active_vf(struct qed_hwfn *p_hwfn, u16 rel_vf_id);
+
+/**
+ * @brief Read sriov related information and allocated resources
+ *  reads from configuraiton space, shmem, etc.
+ *
+ * @param p_hwfn
+ *
+ * @return int
+ */
+int qed_iov_hw_info(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_iov_alloc - allocate sriov related resources
+ *
+ * @param p_hwfn
+ *
+ * @return int
+ */
+int qed_iov_alloc(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief qed_iov_setup - setup sriov related resources
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ */
+void qed_iov_setup(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
+
+/**
+ * @brief qed_iov_free - free sriov related resources
+ *
+ * @param p_hwfn
+ */
+void qed_iov_free(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief free sriov related memory that was allocated during hw_prepare
+ *
+ * @param cdev
+ */
+void qed_iov_free_hw_info(struct qed_dev *cdev);
+#else
+static inline u16 qed_iov_get_next_active_vf(struct qed_hwfn *p_hwfn,
+					     u16 rel_vf_id)
+{
+	return MAX_NUM_VFS;
+}
+
+static inline int qed_iov_hw_info(struct qed_hwfn *p_hwfn)
+{
+	return 0;
+}
+
+static inline int qed_iov_alloc(struct qed_hwfn *p_hwfn)
+{
+	return 0;
+}
+
+static inline void qed_iov_setup(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+}
+
+static inline void qed_iov_free(struct qed_hwfn *p_hwfn)
+{
+}
+
+static inline void qed_iov_free_hw_info(struct qed_dev *cdev)
+{
+}
+#endif
+
+#define qed_for_each_vf(_p_hwfn, _i)			  \
+	for (_i = qed_iov_get_next_active_vf(_p_hwfn, 0); \
+	     _i < MAX_NUM_VFS;				  \
+	     _i = qed_iov_get_next_active_vf(_p_hwfn, _i + 1))
+
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
new file mode 100644
index 0000000..7c78f01
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -0,0 +1,41 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_VF_H
+#define _QED_VF_H
+
+#define TLV_BUFFER_SIZE                 1024
+struct tlv_buffer_size {
+	u8 tlv_buffer[TLV_BUFFER_SIZE];
+};
+
+union vfpf_tlvs {
+	struct tlv_buffer_size tlv_buf_size;
+};
+
+union pfvf_tlvs {
+	struct tlv_buffer_size tlv_buf_size;
+};
+
+struct qed_bulletin_content {
+	/* crc of structure to ensure is not in mid-update */
+	u32 crc;
+
+	u32 version;
+
+	/* bitmap indicating which fields hold valid values */
+	aligned_u64 valid_bitmap;
+};
+
+struct qed_bulletin {
+	dma_addr_t phys;
+	struct qed_bulletin_content *p_virt;
+	u32 size;
+};
+
+#endif
-- 
1.9.3
