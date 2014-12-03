From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb4vf: Add and initialize some sge params for VF driver
Date: Wed,  3 Dec 2014 19:32:51 +0530
Message-ID: <1417615374-12961-2-git-send-email-hariprasad@chelsio.com>
References: <1417615374-12961-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:57235
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751925AbaLCN5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 08:57:09 -0500
In-Reply-To: <1417615374-12961-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add sge_vf_eq_qpp and sge_vf_iq_qpp to (struct sge_params), initialize
sge_queues_per_page and sge_vf_qpp in t4vf_get_sge_params(), add new
t4vf_prep_adapter() which initializes basic adapter parameters.

Grab both SGE_EGRESS_QUEUES_PER_PAGE_VF and SGE_INGRESS_QUEUES_PER_PAGE_VF
for VF Drivers since we need both to calculate the User Doorbell area
offsets for Egress and Ingress Queues.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   10 ++-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   27 +++++++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |   11 ++-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   77 ++++++++++++++++++++
 4 files changed, 120 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index ccdf8a7..1efc862 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -164,8 +164,13 @@
 #define  HOSTPAGESIZEPF0(x)     ((x) << HOSTPAGESIZEPF0_SHIFT)
 
 #define SGE_EGRESS_QUEUES_PER_PAGE_PF 0x1010
-#define  QUEUESPERPAGEPF0_MASK   0x0000000fU
-#define  QUEUESPERPAGEPF0_GET(x) ((x) & QUEUESPERPAGEPF0_MASK)
+#define SGE_EGRESS_QUEUES_PER_PAGE_VF_A 0x1014
+
+#define QUEUESPERPAGEPF1_S    4
+
+#define QUEUESPERPAGEPF0_S    0
+#define QUEUESPERPAGEPF0_MASK   0x0000000fU
+#define QUEUESPERPAGEPF0_GET(x) ((x) & QUEUESPERPAGEPF0_MASK)
 
 #define QUEUESPERPAGEPF0    0
 #define QUEUESPERPAGEPF1    4
@@ -323,6 +328,7 @@
 #define SGE_DEBUG_DATA_LOW_INDEX_3	0x12cc
 #define SGE_DEBUG_DATA_HIGH_INDEX_10	0x12a8
 #define SGE_INGRESS_QUEUES_PER_PAGE_PF 0x10f4
+#define SGE_INGRESS_QUEUES_PER_PAGE_VF_A 0x10f8
 
 #define S_HP_INT_THRESH    28
 #define M_HP_INT_THRESH 0xfU
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index ad88246..c5425f0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2594,6 +2594,27 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 		goto err_free_adapter;
 	}
 
+	/* Wait for the device to become ready before proceeding ...
+	 */
+	err = t4vf_prep_adapter(adapter);
+	if (err) {
+		dev_err(adapter->pdev_dev, "device didn't become ready:"
+			" err=%d\n", err);
+		goto err_unmap_bar0;
+	}
+
+	/* For T5 and later we want to use the new BAR-based User Doorbells,
+	 * so we need to map BAR2 here ...
+	 */
+	if (!is_t4(adapter->params.chip)) {
+		adapter->bar2 = ioremap_wc(pci_resource_start(pdev, 2),
+					   pci_resource_len(pdev, 2));
+		if (!adapter->bar2) {
+			dev_err(adapter->pdev_dev, "cannot map BAR2 doorbells\n");
+			err = -ENOMEM;
+			goto err_unmap_bar0;
+		}
+	}
 	/*
 	 * Initialize adapter level features.
 	 */
@@ -2786,6 +2807,10 @@ err_free_dev:
 	}
 
 err_unmap_bar:
+	if (!is_t4(adapter->params.chip))
+		iounmap(adapter->bar2);
+
+err_unmap_bar0:
 	iounmap(adapter->regs);
 
 err_free_adapter:
@@ -2856,6 +2881,8 @@ static void cxgb4vf_pci_remove(struct pci_dev *pdev)
 			free_netdev(netdev);
 		}
 		iounmap(adapter->regs);
+		if (!is_t4(adapter->params.chip))
+			iounmap(adapter->bar2);
 		kfree(adapter);
 	}
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index a608c66..6d6a956 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -135,9 +135,11 @@ struct dev_params {
 struct sge_params {
 	u32 sge_control;		/* padding, boundaries, lengths, etc. */
 	u32 sge_control2;		/* T5: more of the same */
-	u32 sge_host_page_size;		/* RDMA page sizes */
-	u32 sge_queues_per_page;	/* RDMA queues/page */
-	u32 sge_user_mode_limits;	/* limits for BAR2 user mode accesses */
+	u32 sge_host_page_size;		/* PF0-7 page sizes */
+	u32 sge_egress_queues_per_page;	/* PF0-7 egress queues/page */
+	u32 sge_ingress_queues_per_page;/* PF0-7 ingress queues/page */
+	u32 sge_vf_eq_qpp;		/* egress queues/page for our VF */
+	u32 sge_vf_iq_qpp;		/* ingress queues/page for our VF */
 	u32 sge_fl_buffer_size[16];	/* free list buffer sizes */
 	u32 sge_ingress_rx_threshold;	/* RX counter interrupt threshold[4] */
 	u32 sge_congestion_control;     /* congestion thresholds, etc. */
@@ -267,6 +269,8 @@ static inline int t4vf_wr_mbox_ns(struct adapter *adapter, const void *cmd,
 	return t4vf_wr_mbox_core(adapter, cmd, size, rpl, false);
 }
 
+#define CHELSIO_PCI_ID_VER(dev_id)  ((dev_id) >> 12)
+
 static inline int is_t4(enum chip_type chip)
 {
 	return CHELSIO_CHIP_VERSION(chip) == CHELSIO_T4;
@@ -309,5 +313,6 @@ int t4vf_iq_free(struct adapter *, unsigned int, unsigned int, unsigned int,
 int t4vf_eth_eq_free(struct adapter *, unsigned int);
 
 int t4vf_handle_fw_rpl(struct adapter *, const __be64 *);
+int t4vf_prep_adapter(struct adapter *);
 
 #endif /* __T4VF_COMMON_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 624a213..03ab19e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -501,6 +501,48 @@ int t4vf_get_sge_params(struct adapter *adapter)
 	sge_params->sge_ingress_rx_threshold = vals[0];
 	sge_params->sge_congestion_control = vals[1];
 
+	/* For T5 and later we want to use the new BAR2 Doorbells.
+	 * Unfortunately, older firmware didn't allow the this register to be
+	 * read.
+	 */
+	if (!is_t4(adapter->params.chip)) {
+		u32 whoami;
+		unsigned int pf, s_qpp;
+
+		params[0] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
+			     FW_PARAMS_PARAM_XYZ_V(
+				     SGE_EGRESS_QUEUES_PER_PAGE_VF_A));
+		params[1] = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_REG) |
+			     FW_PARAMS_PARAM_XYZ_V(
+				     SGE_INGRESS_QUEUES_PER_PAGE_VF_A));
+		v = t4vf_query_params(adapter, 2, params, vals);
+		if (v != FW_SUCCESS) {
+			dev_warn(adapter->pdev_dev,
+				 "Unable to get VF SGE Queues/Page; "
+				 "probably old firmware.\n");
+			return v;
+		}
+		sge_params->sge_egress_queues_per_page = vals[0];
+		sge_params->sge_ingress_queues_per_page = vals[1];
+
+		/* We need the Queues/Page for our VF.  This is based on the
+		 * PF from which we're instantiated and is indexed in the
+		 * register we just read. Do it once here so other code in
+		 * the driver can just use it.
+		 */
+		whoami = t4_read_reg(adapter,
+				     T4VF_PL_BASE_ADDR + A_PL_VF_WHOAMI);
+		pf = SOURCEPF_GET(whoami);
+		s_qpp = (QUEUESPERPAGEPF0_S +
+			 (QUEUESPERPAGEPF1_S - QUEUESPERPAGEPF0_S) * pf);
+		sge_params->sge_vf_eq_qpp =
+			((sge_params->sge_egress_queues_per_page >> s_qpp)
+			 & QUEUESPERPAGEPF0_MASK);
+		sge_params->sge_vf_iq_qpp =
+			((sge_params->sge_ingress_queues_per_page >> s_qpp)
+			 & QUEUESPERPAGEPF0_MASK);
+	}
+
 	return 0;
 }
 
@@ -1420,3 +1462,38 @@ int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 	}
 	return 0;
 }
+
+/**
+ */
+int t4vf_prep_adapter(struct adapter *adapter)
+{
+	int err;
+	unsigned int chipid;
+
+	/* Wait for the device to become ready before proceeding ...
+	 */
+	err = t4vf_wait_dev_ready(adapter);
+	if (err)
+		return err;
+
+	/* Default port and clock for debugging in case we can't reach
+	 * firmware.
+	 */
+	adapter->params.nports = 1;
+	adapter->params.vfres.pmask = 1;
+	adapter->params.vpd.cclk = 50000;
+
+	adapter->params.chip = 0;
+	switch (CHELSIO_PCI_ID_VER(adapter->pdev->device)) {
+	case CHELSIO_T4:
+		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T4, 0);
+		break;
+
+	case CHELSIO_T5:
+		chipid = G_REV(t4_read_reg(adapter, A_PL_VF_REV));
+		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T5, chipid);
+		break;
+	}
+
+	return 0;
+}
-- 
1.7.1
