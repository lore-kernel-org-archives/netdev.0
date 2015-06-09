From: Praveen Madhavan <praveenm@chelsio.com>
Subject: [PATCH 1/3] csiostor:Add devlog mailbox support.
Date: Tue,  9 Jun 2015 18:44:44 +0530
Message-ID: <1433855686-15768-2-git-send-email-praveenm@chelsio.com>
References: <1433855686-15768-1-git-send-email-praveenm@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com,
	hariprasad@chelsio.com, praveenm@chelsio.com, varun@chelsio.com,
	rajesh.kumar@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1433855686-15768-1-git-send-email-praveenm@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds devlog mailbox support required for
debugfs.

Signed-off-by: Praveen Madhavan <praveenm@chelsio.com>
---
 drivers/scsi/csiostor/csio_hw.c | 72 +++++++++++++++++++++++++++++++++++++++--
 drivers/scsi/csiostor/csio_hw.h | 12 +++++++
 drivers/scsi/csiostor/csio_mb.c | 60 ++++++++++++++++++++++------------
 drivers/scsi/csiostor/csio_mb.h | 17 ++++++----
 4 files changed, 131 insertions(+), 30 deletions(-)

diff --git a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
index 2e66f34..6101154 100644
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -134,6 +134,7 @@ csio_hw_wait_op_done_val(struct csio_hw *hw, int reg, uint32_t mask,
 			 int polarity, int attempts, int delay, uint32_t *valp)
 {
 	uint32_t val;
+
 	while (1) {
 		val = csio_rd_reg32(hw, reg);
 
@@ -261,9 +262,10 @@ static int
 csio_hw_get_vpd_keyword_val(const struct t4_vpd_hdr *v, const char *kw)
 {
 	int32_t i;
-	int32_t offset , len;
+	int32_t offset, len;
 	const uint8_t *buf = &v->id_tag;
 	const uint8_t *vpdr_len = &v->vpdr_tag;
+
 	offset = sizeof(struct t4_vpd_hdr);
 	len =  (uint16_t)vpdr_len[1] + ((uint16_t)vpdr_len[2] << 8);
 
@@ -271,7 +273,7 @@ csio_hw_get_vpd_keyword_val(const struct t4_vpd_hdr *v, const char *kw)
 		return -EINVAL;
 
 	for (i = offset; (i + VPD_INFO_FLD_HDR_SIZE) <= (offset + len);) {
-		if (memcmp(buf + i , kw, 2) == 0) {
+		if (memcmp(buf + i, kw, 2) == 0) {
 			i += VPD_INFO_FLD_HDR_SIZE;
 			return i;
 		}
@@ -1403,6 +1405,53 @@ out:
 	return rv;
 }
 
+/**
+ *	csio_get_devlog - Read firmware devlog parameters
+ *	@hw: HW module
+ *
+ */
+static int
+csio_get_devlog(struct csio_hw *hw)
+{
+	struct	csio_mb	*mbp;
+	struct	fw_devlog_cmd	*rsp;
+	enum	fw_retval	retval;
+	uint32_t devlog_meminfo;
+
+	mbp = mempool_alloc(hw->mb_mempool, GFP_ATOMIC);
+	if (!mbp) {
+		CSIO_INC_STATS(hw, n_err_nomem);
+		return -ENOMEM;
+	}
+
+	/* Get device log parameters */
+	csio_mb_devlog(hw, mbp, CSIO_MB_DEFAULT_TMO, NULL);
+
+	if (csio_mb_issue(hw, mbp)) {
+		csio_err(hw, "Issue of DEVLOG cmd failed!\n");
+		mempool_free(mbp, hw->mb_mempool);
+		return -EINVAL;
+	}
+
+	retval = csio_mb_fw_retval(mbp);
+	if (retval != FW_SUCCESS) {
+		csio_err(hw, "DEVLOG cmd returned 0x%x!\n", retval);
+		mempool_free(mbp, hw->mb_mempool);
+		return -EINVAL;
+	}
+
+	rsp = (struct fw_devlog_cmd *)(mbp->mb);
+	devlog_meminfo = ntohl(rsp->memtype_devlog_memaddr16_devlog);
+	hw->devlog.memtype = FW_DEVLOG_CMD_MEMTYPE_DEVLOG_G(devlog_meminfo);
+	hw->devlog.start =
+		FW_DEVLOG_CMD_MEMADDR16_DEVLOG_G(devlog_meminfo) << 4;
+	hw->devlog.size = ntohl(rsp->memsize_devlog);
+
+	mempool_free(mbp, hw->mb_mempool);
+
+	return SUCCESS;
+}
+
 /*
  * csio_enable_ports - Bring up all available ports.
  * @hw: HW module.
@@ -1996,7 +2045,7 @@ csio_hw_flash_fw(struct csio_hw *hw, int *reset)
 	struct fw_info *fw_info;
 	struct fw_hdr *card_fw;
 	struct pci_dev *pci_dev = hw->pdev;
-	struct device *dev = &pci_dev->dev ;
+	struct device *dev = &pci_dev->dev;
 	const u8 *fw_data = NULL;
 	unsigned int fw_size = 0;
 
@@ -2065,6 +2114,9 @@ csio_hw_configure(struct csio_hw *hw)
 		goto out;
 	}
 
+	/* Set CIMLA size */
+	hw->params.cim_la_size = CIMLA_SIZE;
+
 	/* Set PCIe completion timeout to 4 seconds */
 	if (pci_is_pcie(hw->pdev))
 		pcie_capability_clear_and_set_word(hw->pdev, PCI_EXP_DEVCTL2,
@@ -2090,6 +2142,17 @@ csio_hw_configure(struct csio_hw *hw)
 	if (rv != 0)
 		goto out;
 
+	/*
+	 * Read firmware device log parameters.  We really need to find a way
+	 * to get these parameters initialized with some default values (which
+	 * are likely to be correct) for the case where we either don't
+	 * attache to the firmware or it's crashed when we probe the adapter.
+	 * That way we'll still be able to perform early firmware startup
+	 * debugging ...  If the request to get the Firmware's Device Log
+	 * parameters fails, we'll live so we don't make that a fatal error.
+	 */
+	csio_get_devlog(hw);
+
 	csio_hw_get_fw_version(hw, &hw->fwrev);
 	csio_hw_get_tp_version(hw, &hw->tp_vers);
 	if (csio_is_hw_master(hw) && hw->fw_state != CSIO_DEV_STATE_INIT) {
@@ -3420,6 +3483,7 @@ void
 csio_evtq_flush(struct csio_hw *hw)
 {
 	uint32_t count;
+
 	count = 30;
 	while (hw->flags & CSIO_HWF_FWEVT_PENDING && count--) {
 		spin_unlock_irq(&hw->lock);
@@ -3861,6 +3925,7 @@ csio_hw_set_description(struct csio_hw *hw, uint16_t ven_id, uint16_t dev_id)
 			       32);
 		} else {
 			char tempName[32] = "Chelsio FCoE Controller";
+
 			memcpy(hw->model_desc, tempName, 32);
 		}
 	}
@@ -3883,6 +3948,7 @@ csio_hw_init(struct csio_hw *hw)
 	INIT_LIST_HEAD(&hw->sm.sm_list);
 	csio_init_state(&hw->sm, csio_hws_uninit);
 	spin_lock_init(&hw->lock);
+	spin_lock_init(&hw->stats_lock);
 	INIT_LIST_HEAD(&hw->sln_head);
 
 	/* Get the PCI vendor & device id */
diff --git a/drivers/scsi/csiostor/csio_hw.h b/drivers/scsi/csiostor/csio_hw.h
index 029bef8..2ababe0 100644
--- a/drivers/scsi/csiostor/csio_hw.h
+++ b/drivers/scsi/csiostor/csio_hw.h
@@ -249,6 +249,15 @@ struct pci_params {
 	uint8_t    width;
 };
 
+/*
+ * Firmware device log.
+ */
+struct devlog_params {
+	uint32_t memtype;	/* which memory (EDC0, EDC1, MC) */
+	uint32_t start;		/* start of log in firmware memory */
+	uint32_t size;		/* size of log */
+};
+
 /* User configurable hw parameters */
 struct csio_hw_params {
 	uint32_t		sf_size;		/* serial flash
@@ -259,6 +268,7 @@ struct csio_hw_params {
 	uint32_t		log_level;		/* Module-level for
 							 * debug log.
 							 */
+	uint32_t		cim_la_size;
 };
 
 struct csio_vpd {
@@ -495,6 +505,8 @@ struct csio_hw {
 
 	struct dentry		*debugfs_root;		/* Debug FS */
 	struct csio_hw_stats	stats;			/* Hw statistics */
+	spinlock_t		stats_lock;		/* Stats lock */
+	struct devlog_params    devlog;                 /* FW device log */
 };
 
 /* Register access macros */
diff --git a/drivers/scsi/csiostor/csio_mb.c b/drivers/scsi/csiostor/csio_mb.c
index 9451787..0351d9f 100644
--- a/drivers/scsi/csiostor/csio_mb.c
+++ b/drivers/scsi/csiostor/csio_mb.c
@@ -75,7 +75,7 @@ csio_mb_fw_retval(struct csio_mb *mbp)
 void
 csio_mb_hello(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 	      uint32_t m_mbox, uint32_t a_mbox, enum csio_dev_master master,
-	      void (*cbfn) (struct csio_hw *, struct csio_mb *))
+	      void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_hello_cmd *cmdp = (struct fw_hello_cmd *)(mbp->mb);
 
@@ -138,7 +138,7 @@ csio_mb_process_hello_rsp(struct csio_hw *hw, struct csio_mb *mbp,
  */
 void
 csio_mb_bye(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
-	    void (*cbfn) (struct csio_hw *, struct csio_mb *))
+	    void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_bye_cmd *cmdp = (struct fw_bye_cmd *)(mbp->mb);
 
@@ -161,7 +161,7 @@ csio_mb_bye(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 void
 csio_mb_reset(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 	      int reset, int halt,
-	      void (*cbfn) (struct csio_hw *, struct csio_mb *))
+	      void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_reset_cmd *cmdp = (struct fw_reset_cmd *)(mbp->mb);
 
@@ -264,6 +264,7 @@ void
 csio_mb_ldst(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo, int reg)
 {
 	struct fw_ldst_cmd *ldst_cmd = (struct fw_ldst_cmd *)(mbp->mb);
+
 	CSIO_INIT_MBP(mbp, ldst_cmd, tmo, hw, NULL, 1);
 
 	/*
@@ -299,7 +300,7 @@ csio_mb_ldst(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo, int reg)
 void
 csio_mb_caps_config(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 		    bool wr, bool init, bool tgt, bool cofld,
-		    void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		    void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_caps_config_cmd *cmdp =
 				(struct fw_caps_config_cmd *)(mbp->mb);
@@ -345,7 +346,7 @@ csio_mb_caps_config(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 void
 csio_mb_port(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 	     uint8_t portid, bool wr, uint32_t fc, uint16_t caps,
-	     void (*cbfn) (struct csio_hw *, struct csio_mb *))
+	     void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_port_cmd *cmdp = (struct fw_port_cmd *)(mbp->mb);
 	unsigned int lfc = 0, mdi = FW_PORT_CAP_MDI_V(FW_PORT_CAP_MDI_AUTO);
@@ -410,7 +411,7 @@ csio_mb_process_read_port_rsp(struct csio_hw *hw, struct csio_mb *mbp,
  */
 void
 csio_mb_initialize(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
-		   void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		   void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_initialize_cmd *cmdp = (struct fw_initialize_cmd *)(mbp->mb);
 
@@ -438,7 +439,7 @@ csio_mb_initialize(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 static void
 csio_mb_iq_alloc(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 		 uint32_t mb_tmo, struct csio_iq_params *iq_params,
-		 void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		 void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_iq_cmd *cmdp = (struct fw_iq_cmd *)(mbp->mb);
 
@@ -484,7 +485,7 @@ static void
 csio_mb_iq_write(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 		 uint32_t mb_tmo, bool cascaded_req,
 		 struct csio_iq_params *iq_params,
-		 void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		 void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_iq_cmd *cmdp = (struct fw_iq_cmd *)(mbp->mb);
 
@@ -566,7 +567,7 @@ csio_mb_iq_write(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 void
 csio_mb_iq_alloc_write(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 		       uint32_t mb_tmo, struct csio_iq_params *iq_params,
-		       void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		       void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	csio_mb_iq_alloc(hw, mbp, priv, mb_tmo, iq_params, cbfn);
 	csio_mb_iq_write(hw, mbp, priv, mb_tmo, true, iq_params, cbfn);
@@ -617,7 +618,7 @@ csio_mb_iq_alloc_write_rsp(struct csio_hw *hw, struct csio_mb *mbp,
 void
 csio_mb_iq_free(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 		uint32_t mb_tmo, struct csio_iq_params *iq_params,
-		void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_iq_cmd *cmdp = (struct fw_iq_cmd *)(mbp->mb);
 
@@ -653,7 +654,7 @@ csio_mb_iq_free(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 static void
 csio_mb_eq_ofld_alloc(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 		uint32_t mb_tmo, struct csio_eq_params *eq_ofld_params,
-		void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_eq_ofld_cmd *cmdp = (struct fw_eq_ofld_cmd *)(mbp->mb);
 
@@ -690,7 +691,7 @@ static void
 csio_mb_eq_ofld_write(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 		      uint32_t mb_tmo, bool cascaded_req,
 		      struct csio_eq_params *eq_ofld_params,
-		      void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		      void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_eq_ofld_cmd *cmdp = (struct fw_eq_ofld_cmd *)(mbp->mb);
 
@@ -751,7 +752,7 @@ void
 csio_mb_eq_ofld_alloc_write(struct csio_hw *hw, struct csio_mb *mbp,
 			    void *priv, uint32_t mb_tmo,
 			    struct csio_eq_params *eq_ofld_params,
-			    void (*cbfn) (struct csio_hw *, struct csio_mb *))
+			    void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	csio_mb_eq_ofld_alloc(hw, mbp, priv, mb_tmo, eq_ofld_params, cbfn);
 	csio_mb_eq_ofld_write(hw, mbp, priv, mb_tmo, true,
@@ -803,7 +804,7 @@ csio_mb_eq_ofld_alloc_write_rsp(struct csio_hw *hw,
 void
 csio_mb_eq_ofld_free(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 		     uint32_t mb_tmo, struct csio_eq_params *eq_ofld_params,
-		     void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		     void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_eq_ofld_cmd *cmdp = (struct fw_eq_ofld_cmd *)(mbp->mb);
 
@@ -834,7 +835,7 @@ void
 csio_write_fcoe_link_cond_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 			uint32_t mb_tmo, uint8_t port_id, uint32_t sub_opcode,
 			uint8_t cos, bool link_status, uint32_t fcfi,
-			void (*cbfn) (struct csio_hw *, struct csio_mb *))
+			void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_fcoe_link_cmd *cmdp =
 				(struct fw_fcoe_link_cmd *)(mbp->mb);
@@ -868,7 +869,7 @@ csio_write_fcoe_link_cond_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 void
 csio_fcoe_read_res_info_init_mb(struct csio_hw *hw, struct csio_mb *mbp,
 			uint32_t mb_tmo,
-			void (*cbfn) (struct csio_hw *, struct csio_mb *))
+			void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_fcoe_res_info_cmd *cmdp =
 			(struct fw_fcoe_res_info_cmd *)(mbp->mb);
@@ -903,7 +904,7 @@ void
 csio_fcoe_vnp_alloc_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 		uint32_t mb_tmo, uint32_t fcfi, uint32_t vnpi, uint16_t iqid,
 		uint8_t vnport_wwnn[8],	uint8_t vnport_wwpn[8],
-		void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_fcoe_vnp_cmd *cmdp =
 			(struct fw_fcoe_vnp_cmd *)(mbp->mb);
@@ -944,7 +945,7 @@ csio_fcoe_vnp_alloc_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 void
 csio_fcoe_vnp_read_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 		uint32_t mb_tmo, uint32_t fcfi, uint32_t vnpi,
-		void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_fcoe_vnp_cmd *cmdp =
 			(struct fw_fcoe_vnp_cmd *)(mbp->mb);
@@ -973,7 +974,7 @@ csio_fcoe_vnp_read_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 void
 csio_fcoe_vnp_free_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 		uint32_t mb_tmo, uint32_t fcfi, uint32_t vnpi,
-		void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_fcoe_vnp_cmd *cmdp =
 			(struct fw_fcoe_vnp_cmd *)(mbp->mb);
@@ -1004,7 +1005,7 @@ csio_fcoe_vnp_free_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 void
 csio_fcoe_read_fcf_init_mb(struct csio_lnode *ln, struct csio_mb *mbp,
 		uint32_t mb_tmo, uint32_t portid, uint32_t fcfi,
-		void (*cbfn) (struct csio_hw *, struct csio_mb *))
+		void (*cbfn)(struct csio_hw *, struct csio_mb *))
 {
 	struct fw_fcoe_fcf_cmd *cmdp =
 			(struct fw_fcoe_fcf_cmd *)(mbp->mb);
@@ -1095,6 +1096,25 @@ csio_mb_process_portparams_rsp(struct csio_hw *hw,
 	}
 }
 
+/*
+ *	csio_mb_devlog - Initializes the mailbox for devlog cmd.
+ *	@hw: The HW structure
+ *	@mbp: Mailbox structure to initialize
+ *	@mb_tmo: Mailbox time-out period (in ms).
+ *	@cbfn: The call-back function
+ */
+void
+csio_mb_devlog(struct csio_hw *hw, struct csio_mb *mbp, uint32_t mb_tmo,
+			void (*cbfn)(struct csio_hw *, struct csio_mb *))
+{
+	struct fw_devlog_cmd *cmdp = (struct fw_devlog_cmd *) (mbp->mb);
+
+	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, hw, cbfn,  1);
+	cmdp->op_to_write = htonl(FW_CMD_OP_V(FW_DEVLOG_CMD) |
+		FW_CMD_REQUEST_F | FW_CMD_READ_F);
+	cmdp->retval_len16 = htonl(FW_LEN16(*cmdp));
+}
+
 /* Entry points/APIs for MB module					     */
 /*
  * csio_mb_intr_enable - Enable Interrupts from mailboxes.
diff --git a/drivers/scsi/csiostor/csio_mb.h b/drivers/scsi/csiostor/csio_mb.h
index 1bc82d0..a5532ea 100644
--- a/drivers/scsi/csiostor/csio_mb.h
+++ b/drivers/scsi/csiostor/csio_mb.h
@@ -128,7 +128,7 @@ struct csio_mb {
 	struct completion	cmplobj;		/* MB Completion
 							 * object
 							 */
-	void			(*mb_cbfn) (struct csio_hw *, struct csio_mb *);
+	void			(*mb_cbfn)(struct csio_hw *, struct csio_mb *);
 							/* Callback fn */
 	void			*priv;			/* Owner private ptr */
 };
@@ -174,7 +174,7 @@ void csio_mb_params(struct csio_hw *, struct csio_mb *, uint32_t, unsigned int,
 		    void (*)(struct csio_hw *, struct csio_mb *));
 
 void csio_mb_process_read_params_rsp(struct csio_hw *, struct csio_mb *,
-				enum fw_retval *, unsigned int , u32 *);
+				enum fw_retval *, unsigned int, u32 *);
 
 void csio_mb_ldst(struct csio_hw *hw, struct csio_mb *mbp, uint32_t tmo,
 		  int reg);
@@ -212,7 +212,7 @@ void csio_mb_eq_ofld_alloc_write_rsp(struct csio_hw *, struct csio_mb *,
 				     enum fw_retval *, struct csio_eq_params *);
 
 void csio_mb_eq_ofld_free(struct csio_hw *, struct csio_mb *, void *,
-			  uint32_t , struct csio_eq_params *,
+			  uint32_t, struct csio_eq_params *,
 			  void (*) (struct csio_hw *, struct csio_mb *));
 
 void csio_fcoe_read_res_info_init_mb(struct csio_hw *, struct csio_mb *,
@@ -224,21 +224,21 @@ void csio_write_fcoe_link_cond_init_mb(struct csio_lnode *, struct csio_mb *,
 			void (*) (struct csio_hw *, struct csio_mb *));
 
 void csio_fcoe_vnp_alloc_init_mb(struct csio_lnode *, struct csio_mb *,
-			uint32_t, uint32_t , uint32_t , uint16_t,
+			uint32_t, uint32_t, uint32_t, uint16_t,
 			uint8_t [8], uint8_t [8],
 			void (*) (struct csio_hw *, struct csio_mb *));
 
 void csio_fcoe_vnp_read_init_mb(struct csio_lnode *, struct csio_mb *,
-			uint32_t, uint32_t , uint32_t ,
+			uint32_t, uint32_t, uint32_t,
 			void (*) (struct csio_hw *, struct csio_mb *));
 
 void csio_fcoe_vnp_free_init_mb(struct csio_lnode *, struct csio_mb *,
-			uint32_t , uint32_t, uint32_t ,
+			uint32_t, uint32_t, uint32_t,
 			void (*) (struct csio_hw *, struct csio_mb *));
 
 void csio_fcoe_read_fcf_init_mb(struct csio_lnode *, struct csio_mb *,
 			uint32_t, uint32_t, uint32_t,
-			void (*cbfn) (struct csio_hw *, struct csio_mb *));
+			void (*cbfn)(struct csio_hw *, struct csio_mb *));
 
 void csio_fcoe_read_portparams_init_mb(struct csio_hw *hw,
 			struct csio_mb *mbp, uint32_t mb_tmo,
@@ -250,6 +250,9 @@ void csio_mb_process_portparams_rsp(struct csio_hw *hw, struct csio_mb *mbp,
 				struct fw_fcoe_port_cmd_params *portparams,
 				struct fw_fcoe_port_stats *portstats);
 
+void csio_mb_devlog(struct csio_hw *hw, struct csio_mb *mbp, uint32_t mb_tmo,
+			void (*cbfn)(struct csio_hw *, struct csio_mb *));
+
 /* MB module functions */
 int csio_mbm_init(struct csio_mbm *, struct csio_hw *,
 			    void (*)(uintptr_t));
-- 
2.0.2

