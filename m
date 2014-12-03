From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/4] cxgb4/cxgb4vf: Add code to calculate T5 BAR2 Offsets for SGE Queue Registers
Date: Wed,  3 Dec 2014 19:32:52 +0530
Message-ID: <1417615374-12961-3-git-send-email-hariprasad@chelsio.com>
References: <1417615374-12961-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:57238
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752186AbaLCN5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 08:57:12 -0500
In-Reply-To: <1417615374-12961-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new Common Code facilities for calculating T5 BAR2 Offsets for SGE Queue
Registers. This new code can handle situations where

    Queues Per Page * SGE BAR2 Queue Register Area Size > Page Size

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   16 +++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  120 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   12 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    8 ++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   98 ++++++++++++++++-
 5 files changed, 247 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index e8b09bb..40905c6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -222,6 +222,12 @@ struct tp_err_stats {
 	u32 ofldCongDefer;
 };
 
+struct sge_params {
+	u32 hps;			/* host page size for our PF/VF */
+	u32 eq_qpp;			/* egress queues/page for our PF/VF */
+	u32 iq_qpp;			/* egress queues/page for our PF/VF */
+};
+
 struct tp_params {
 	unsigned int ntxchan;        /* # of Tx channels */
 	unsigned int tre;            /* log2 of core clocks per TP tick */
@@ -285,6 +291,7 @@ enum chip_type {
 };
 
 struct adapter_params {
+	struct sge_params sge;
 	struct tp_params  tp;
 	struct vpd_params vpd;
 	struct pci_params pci;
@@ -995,6 +1002,15 @@ int t4_prep_fw(struct adapter *adap, struct fw_info *fw_info,
 	       const u8 *fw_data, unsigned int fw_size,
 	       struct fw_hdr *card_fw, enum dev_state state, int *reset);
 int t4_prep_adapter(struct adapter *adapter);
+
+enum t4_bar2_qtype { T4_BAR2_QTYPE_EGRESS, T4_BAR2_QTYPE_INGRESS };
+int t4_bar2_sge_qregs(struct adapter *adapter,
+		      unsigned int qid,
+		      enum t4_bar2_qtype qtype,
+		      u64 *pbar2_qoffset,
+		      unsigned int *pbar2_qid);
+
+int t4_init_sge_params(struct adapter *adapter);
 int t4_init_tp_params(struct adapter *adap);
 int t4_filter_field_shift(const struct adapter *adap, int filter_sel);
 int t4_port_init(struct adapter *adap, int mbox, int pf, int vf);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 7975d26..3f8876f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4003,6 +4003,126 @@ int t4_prep_adapter(struct adapter *adapter)
 }
 
 /**
+ *	t4_bar2_sge_qregs - return BAR2 SGE Queue register information
+ *	@adapter: the adapter
+ *	@qid: the Queue ID
+ *	@qtype: the Ingress or Egress type for @qid
+ *	@pbar2_qoffset: BAR2 Queue Offset
+ *	@pbar2_qid: BAR2 Queue ID or 0 for Queue ID inferred SGE Queues
+ *
+ *	Returns the BAR2 SGE Queue Registers information associated with the
+ *	indicated Absolute Queue ID.  These are passed back in return value
+ *	pointers.  @qtype should be T4_BAR2_QTYPE_EGRESS for Egress Queue
+ *	and T4_BAR2_QTYPE_INGRESS for Ingress Queues.
+ *
+ *	This may return an error which indicates that BAR2 SGE Queue
+ *	registers aren't available.  If an error is not returned, then the
+ *	following values are returned:
+ *
+ *	  *@pbar2_qoffset: the BAR2 Offset of the @qid Registers
+ *	  *@pbar2_qid: the BAR2 SGE Queue ID or 0 of @qid
+ *
+ *	If the returned BAR2 Queue ID is 0, then BAR2 SGE registers which
+ *	require the "Inferred Queue ID" ability may be used.  E.g. the
+ *	Write Combining Doorbell Buffer. If the BAR2 Queue ID is not 0,
+ *	then these "Inferred Queue ID" register may not be used.
+ */
+int t4_bar2_sge_qregs(struct adapter *adapter,
+		      unsigned int qid,
+		      enum t4_bar2_qtype qtype,
+		      u64 *pbar2_qoffset,
+		      unsigned int *pbar2_qid)
+{
+	unsigned int page_shift, page_size, qpp_shift, qpp_mask;
+	u64 bar2_page_offset, bar2_qoffset;
+	unsigned int bar2_qid, bar2_qid_offset, bar2_qinferred;
+
+	/* T4 doesn't support BAR2 SGE Queue registers.
+	 */
+	if (is_t4(adapter->params.chip))
+		return -EINVAL;
+
+	/* Get our SGE Page Size parameters.
+	 */
+	page_shift = adapter->params.sge.hps + 10;
+	page_size = 1 << page_shift;
+
+	/* Get the right Queues per Page parameters for our Queue.
+	 */
+	qpp_shift = (qtype == T4_BAR2_QTYPE_EGRESS
+		     ? adapter->params.sge.eq_qpp
+		     : adapter->params.sge.iq_qpp);
+	qpp_mask = (1 << qpp_shift) - 1;
+
+	/*  Calculate the basics of the BAR2 SGE Queue register area:
+	 *  o The BAR2 page the Queue registers will be in.
+	 *  o The BAR2 Queue ID.
+	 *  o The BAR2 Queue ID Offset into the BAR2 page.
+	 */
+	bar2_page_offset = ((qid >> qpp_shift) << page_shift);
+	bar2_qid = qid & qpp_mask;
+	bar2_qid_offset = bar2_qid * SGE_UDB_SIZE;
+
+	/* If the BAR2 Queue ID Offset is less than the Page Size, then the
+	 * hardware will infer the Absolute Queue ID simply from the writes to
+	 * the BAR2 Queue ID Offset within the BAR2 Page (and we need to use a
+	 * BAR2 Queue ID of 0 for those writes).  Otherwise, we'll simply
+	 * write to the first BAR2 SGE Queue Area within the BAR2 Page with
+	 * the BAR2 Queue ID and the hardware will infer the Absolute Queue ID
+	 * from the BAR2 Page and BAR2 Queue ID.
+	 *
+	 * One important censequence of this is that some BAR2 SGE registers
+	 * have a "Queue ID" field and we can write the BAR2 SGE Queue ID
+	 * there.  But other registers synthesize the SGE Queue ID purely
+	 * from the writes to the registers -- the Write Combined Doorbell
+	 * Buffer is a good example.  These BAR2 SGE Registers are only
+	 * available for those BAR2 SGE Register areas where the SGE Absolute
+	 * Queue ID can be inferred from simple writes.
+	 */
+	bar2_qoffset = bar2_page_offset;
+	bar2_qinferred = (bar2_qid_offset < page_size);
+	if (bar2_qinferred) {
+		bar2_qoffset += bar2_qid_offset;
+		bar2_qid = 0;
+	}
+
+	*pbar2_qoffset = bar2_qoffset;
+	*pbar2_qid = bar2_qid;
+	return 0;
+}
+
+/**
+ *	t4_init_sge_params - initialize adap->params.sge
+ *	@adapter: the adapter
+ *
+ *	Initialize various fields of the adapter's SGE Parameters structure.
+ */
+int t4_init_sge_params(struct adapter *adapter)
+{
+	struct sge_params *sge_params = &adapter->params.sge;
+	u32 hps, qpp;
+	unsigned int s_hps, s_qpp;
+
+	/* Extract the SGE Page Size for our PF.
+	 */
+	hps = t4_read_reg(adapter, SGE_HOST_PAGE_SIZE);
+	s_hps = (HOSTPAGESIZEPF0_S +
+		 (HOSTPAGESIZEPF1_S - HOSTPAGESIZEPF0_S) * adapter->fn);
+	sge_params->hps = ((hps >> s_hps) & HOSTPAGESIZEPF0_M);
+
+	/* Extract the SGE Egress and Ingess Queues Per Page for our PF.
+	 */
+	s_qpp = (QUEUESPERPAGEPF0_S +
+		(QUEUESPERPAGEPF1_S - QUEUESPERPAGEPF0_S) * adapter->fn);
+	qpp = t4_read_reg(adapter, SGE_EGRESS_QUEUES_PER_PAGE_PF);
+	sge_params->eq_qpp = ((qpp >> s_qpp) & QUEUESPERPAGEPF0_MASK);
+	qpp = t4_read_reg(adapter, SGE_INGRESS_QUEUES_PER_PAGE_PF);
+	sge_params->iq_qpp = ((qpp >> s_qpp) & QUEUESPERPAGEPF0_MASK);
+
+	return 0;
+}
+
+/**
  *      t4_init_tp_params - initialize adap->params.tp
  *      @adap: the adapter
  *
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 1efc862..d7bd34e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -155,13 +155,13 @@
 #define  HOSTPAGESIZEPF2_SHIFT  8
 #define  HOSTPAGESIZEPF2(x)     ((x) << HOSTPAGESIZEPF2_SHIFT)
 
-#define  HOSTPAGESIZEPF1_MASK   0x0000000fU
-#define  HOSTPAGESIZEPF1_SHIFT  4
-#define  HOSTPAGESIZEPF1(x)     ((x) << HOSTPAGESIZEPF1_SHIFT)
+#define  HOSTPAGESIZEPF1_M	0x0000000fU
+#define  HOSTPAGESIZEPF1_S	4
+#define  HOSTPAGESIZEPF1(x)     ((x) << HOSTPAGESIZEPF1_S)
 
-#define  HOSTPAGESIZEPF0_MASK   0x0000000fU
-#define  HOSTPAGESIZEPF0_SHIFT  0
-#define  HOSTPAGESIZEPF0(x)     ((x) << HOSTPAGESIZEPF0_SHIFT)
+#define  HOSTPAGESIZEPF0_M	0x0000000fU
+#define  HOSTPAGESIZEPF0_S	0
+#define  HOSTPAGESIZEPF0(x)     ((x) << HOSTPAGESIZEPF0_S)
 
 #define SGE_EGRESS_QUEUES_PER_PAGE_PF 0x1010
 #define SGE_EGRESS_QUEUES_PER_PAGE_VF_A 0x1014
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index 6d6a956..8d3237f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -138,6 +138,7 @@ struct sge_params {
 	u32 sge_host_page_size;		/* PF0-7 page sizes */
 	u32 sge_egress_queues_per_page;	/* PF0-7 egress queues/page */
 	u32 sge_ingress_queues_per_page;/* PF0-7 ingress queues/page */
+	u32 sge_vf_hps;                 /* host page size for our vf */
 	u32 sge_vf_eq_qpp;		/* egress queues/page for our VF */
 	u32 sge_vf_iq_qpp;		/* ingress queues/page for our VF */
 	u32 sge_fl_buffer_size[16];	/* free list buffer sizes */
@@ -282,6 +283,13 @@ int t4vf_port_init(struct adapter *, int);
 int t4vf_fw_reset(struct adapter *);
 int t4vf_set_params(struct adapter *, unsigned int, const u32 *, const u32 *);
 
+enum t4_bar2_qtype { T4_BAR2_QTYPE_EGRESS, T4_BAR2_QTYPE_INGRESS };
+int t4_bar2_sge_qregs(struct adapter *adapter,
+		      unsigned int qid,
+		      enum t4_bar2_qtype qtype,
+		      u64 *pbar2_qoffset,
+		      unsigned int *pbar2_qid);
+
 int t4vf_get_sge_params(struct adapter *);
 int t4vf_get_vpd_params(struct adapter *);
 int t4vf_get_dev_params(struct adapter *);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 03ab19e..02e8833 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -430,6 +430,95 @@ int t4vf_set_params(struct adapter *adapter, unsigned int nparams,
 }
 
 /**
+ *	t4_bar2_sge_qregs - return BAR2 SGE Queue register information
+ *	@adapter: the adapter
+ *	@qid: the Queue ID
+ *	@qtype: the Ingress or Egress type for @qid
+ *	@pbar2_qoffset: BAR2 Queue Offset
+ *	@pbar2_qid: BAR2 Queue ID or 0 for Queue ID inferred SGE Queues
+ *
+ *	Returns the BAR2 SGE Queue Registers information associated with the
+ *	indicated Absolute Queue ID.  These are passed back in return value
+ *	pointers.  @qtype should be T4_BAR2_QTYPE_EGRESS for Egress Queue
+ *	and T4_BAR2_QTYPE_INGRESS for Ingress Queues.
+ *
+ *	This may return an error which indicates that BAR2 SGE Queue
+ *	registers aren't available.  If an error is not returned, then the
+ *	following values are returned:
+ *
+ *	  *@pbar2_qoffset: the BAR2 Offset of the @qid Registers
+ *	  *@pbar2_qid: the BAR2 SGE Queue ID or 0 of @qid
+ *
+ *	If the returned BAR2 Queue ID is 0, then BAR2 SGE registers which
+ *	require the "Inferred Queue ID" ability may be used.  E.g. the
+ *	Write Combining Doorbell Buffer. If the BAR2 Queue ID is not 0,
+ *	then these "Inferred Queue ID" register may not be used.
+ */
+int t4_bar2_sge_qregs(struct adapter *adapter,
+		      unsigned int qid,
+		      enum t4_bar2_qtype qtype,
+		      u64 *pbar2_qoffset,
+		      unsigned int *pbar2_qid)
+{
+	unsigned int page_shift, page_size, qpp_shift, qpp_mask;
+	u64 bar2_page_offset, bar2_qoffset;
+	unsigned int bar2_qid, bar2_qid_offset, bar2_qinferred;
+
+	/* T4 doesn't support BAR2 SGE Queue registers.
+	 */
+	if (is_t4(adapter->params.chip))
+		return -EINVAL;
+
+	/* Get our SGE Page Size parameters.
+	 */
+	page_shift = adapter->params.sge.sge_vf_hps + 10;
+	page_size = 1 << page_shift;
+
+	/* Get the right Queues per Page parameters for our Queue.
+	 */
+	qpp_shift = (qtype == T4_BAR2_QTYPE_EGRESS
+		     ? adapter->params.sge.sge_vf_eq_qpp
+		     : adapter->params.sge.sge_vf_iq_qpp);
+	qpp_mask = (1 << qpp_shift) - 1;
+
+	/* Calculate the basics of the BAR2 SGE Queue register area:
+	 *  o The BAR2 page the Queue registers will be in.
+	 *  o The BAR2 Queue ID.
+	 *  o The BAR2 Queue ID Offset into the BAR2 page.
+	 */
+	bar2_page_offset = ((qid >> qpp_shift) << page_shift);
+	bar2_qid = qid & qpp_mask;
+	bar2_qid_offset = bar2_qid * SGE_UDB_SIZE;
+
+	/* If the BAR2 Queue ID Offset is less than the Page Size, then the
+	 * hardware will infer the Absolute Queue ID simply from the writes to
+	 * the BAR2 Queue ID Offset within the BAR2 Page (and we need to use a
+	 * BAR2 Queue ID of 0 for those writes).  Otherwise, we'll simply
+	 * write to the first BAR2 SGE Queue Area within the BAR2 Page with
+	 * the BAR2 Queue ID and the hardware will infer the Absolute Queue ID
+	 * from the BAR2 Page and BAR2 Queue ID.
+	 *
+	 * One important censequence of this is that some BAR2 SGE registers
+	 * have a "Queue ID" field and we can write the BAR2 SGE Queue ID
+	 * there.  But other registers synthesize the SGE Queue ID purely
+	 * from the writes to the registers -- the Write Combined Doorbell
+	 * Buffer is a good example.  These BAR2 SGE Registers are only
+	 * available for those BAR2 SGE Register areas where the SGE Absolute
+	 * Queue ID can be inferred from simple writes.
+	 */
+	bar2_qoffset = bar2_page_offset;
+	bar2_qinferred = (bar2_qid_offset < page_size);
+	if (bar2_qinferred) {
+		bar2_qoffset += bar2_qid_offset;
+		bar2_qid = 0;
+	}
+
+	*pbar2_qoffset = bar2_qoffset;
+	*pbar2_qid = bar2_qid;
+	return 0;
+}
+
+/**
  *	t4vf_get_sge_params - retrieve adapter Scatter gather Engine parameters
  *	@adapter: the adapter
  *
@@ -507,7 +596,7 @@ int t4vf_get_sge_params(struct adapter *adapter)
 	 */
 	if (!is_t4(adapter->params.chip)) {
 		u32 whoami;
-		unsigned int pf, s_qpp;
+		unsigned int pf, s_hps, s_qpp;
 
 		params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
 			     FW_PARAMS_PARAM_XYZ_V(
@@ -533,6 +622,13 @@ int t4vf_get_sge_params(struct adapter *adapter)
 		whoami = t4_read_reg(adapter,
 				     T4VF_PL_BASE_ADDR + A_PL_VF_WHOAMI);
 		pf = SOURCEPF_GET(whoami);
+
+		s_hps = (HOSTPAGESIZEPF0_S +
+			 (HOSTPAGESIZEPF1_S - HOSTPAGESIZEPF0_S) * pf);
+		sge_params->sge_vf_hps =
+			((sge_params->sge_host_page_size >> s_hps)
+			 & HOSTPAGESIZEPF0_M);
+
 		s_qpp = (QUEUESPERPAGEPF0_S +
 			 (QUEUESPERPAGEPF1_S - QUEUESPERPAGEPF0_S) * pf);
 		sge_params->sge_vf_eq_qpp =
-- 
1.7.1
