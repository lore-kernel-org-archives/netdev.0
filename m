From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 4/9] cxgb4: get on-chip queue info from FW and create a memory window for them
Date: Mon,  2 Aug 2010 16:19:19 -0700
Message-ID: <1280791164-14181-5-git-send-email-dm@chelsio.com>
References: <1280791164-14181-1-git-send-email-dm@chelsio.com>
 <1280791164-14181-2-git-send-email-dm@chelsio.com>
 <1280791164-14181-3-git-send-email-dm@chelsio.com>
 <1280791164-14181-4-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13708 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250Ab0HBXTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:19:25 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o72NJP2L025632
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 16:19:25 -0700
In-Reply-To: <1280791164-14181-4-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get info about the availability of Tx on-chip queues from FW and if they
are supported set up a memory window for them.  iw_cxgb4 will be using them.
Move the existing window setup later in the init sequence, after we have
collected the new info.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   24 ++++++++++++++++++++++--
 drivers/net/cxgb4/cxgb4_uld.h  |    4 ++++
 drivers/net/cxgb4/t4_regs.h    |    1 +
 drivers/net/cxgb4/t4fw_api.h   |    2 ++
 4 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 0af6d67..47e8936 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2897,6 +2897,21 @@ static void setup_memwin(struct adapter *adap)
 	t4_write_reg(adap, PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_BASE_WIN, 2),
 		     (bar0 + MEMWIN2_BASE) | BIR(0) |
 		     WINDOW(ilog2(MEMWIN2_APERTURE) - 10));
+	if (adap->vres.ocq.size) {
+		unsigned int start, sz_kb;
+
+		start = pci_resource_start(adap->pdev, 2) +
+			OCQ_WIN_OFFSET(adap->pdev, &adap->vres);
+		sz_kb = roundup_pow_of_two(adap->vres.ocq.size) >> 10;
+		t4_write_reg(adap,
+			     PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_BASE_WIN, 3),
+			     start | BIR(1) | WINDOW(ilog2(sz_kb)));
+		t4_write_reg(adap,
+			     PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_OFFSET, 3),
+			     adap->vres.ocq.start);
+		t4_read_reg(adap,
+			    PCIE_MEM_ACCESS_REG(PCIE_MEM_ACCESS_OFFSET, 3));
+	}
 }
 
 static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
@@ -2954,7 +2969,6 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 	t4_write_reg(adap, TP_PIO_ADDR, TP_INGRESS_CONFIG);
 	v = t4_read_reg(adap, TP_PIO_DATA);
 	t4_write_reg(adap, TP_PIO_DATA, v & ~CSUM_HAS_PSEUDO_HDR);
-	setup_memwin(adap);
 	return 0;
 }
 
@@ -3073,13 +3087,17 @@ static int adap_init0(struct adapter *adap)
 		params[1] = FW_PARAM_PFVF(SQRQ_END);
 		params[2] = FW_PARAM_PFVF(CQ_START);
 		params[3] = FW_PARAM_PFVF(CQ_END);
-		ret = t4_query_params(adap, 0, 0, 0, 4, params, val);
+		params[4] = FW_PARAM_PFVF(OCQ_START);
+		params[5] = FW_PARAM_PFVF(OCQ_END);
+		ret = t4_query_params(adap, 0, 0, 0, 6, params, val);
 		if (ret < 0)
 			goto bye;
 		adap->vres.qp.start = val[0];
 		adap->vres.qp.size = val[1] - val[0] + 1;
 		adap->vres.cq.start = val[2];
 		adap->vres.cq.size = val[3] - val[2] + 1;
+		adap->vres.ocq.start = val[4];
+		adap->vres.ocq.size = val[5] - val[4] + 1;
 	}
 	if (c.iscsicaps) {
 		params[0] = FW_PARAM_PFVF(ISCSI_START);
@@ -3139,6 +3157,7 @@ static int adap_init0(struct adapter *adap)
 	}
 #endif
 
+	setup_memwin(adap);
 	return 0;
 
 	/*
@@ -3221,6 +3240,7 @@ static pci_ers_result_t eeh_slot_reset(struct pci_dev *pdev)
 
 	t4_load_mtus(adap, adap->params.mtus, adap->params.a_wnd,
 		     adap->params.b_wnd);
+	setup_memwin(adap);
 	if (cxgb_up(adap))
 		return PCI_ERS_RESULT_DISCONNECT;
 	return PCI_ERS_RESULT_RECOVERED;
diff --git a/drivers/net/cxgb4/cxgb4_uld.h b/drivers/net/cxgb4/cxgb4_uld.h
index 0dc0866..85d74e7 100644
--- a/drivers/net/cxgb4/cxgb4_uld.h
+++ b/drivers/net/cxgb4/cxgb4_uld.h
@@ -187,8 +187,12 @@ struct cxgb4_virt_res {                      /* virtualized HW resources */
 	struct cxgb4_range pbl;
 	struct cxgb4_range qp;
 	struct cxgb4_range cq;
+	struct cxgb4_range ocq;
 };
 
+#define OCQ_WIN_OFFSET(pdev, vres) \
+	(pci_resource_len((pdev), 2) - roundup_pow_of_two((vres)->ocq.size))
+
 /*
  * Block of information the LLD provides to ULDs attaching to a device.
  */
diff --git a/drivers/net/cxgb4/t4_regs.h b/drivers/net/cxgb4/t4_regs.h
index bf21c14..0adc5bc 100644
--- a/drivers/net/cxgb4/t4_regs.h
+++ b/drivers/net/cxgb4/t4_regs.h
@@ -232,6 +232,7 @@
 #define  WINDOW_MASK     0x000000ffU
 #define  WINDOW_SHIFT    0
 #define  WINDOW(x)       ((x) << WINDOW_SHIFT)
+#define PCIE_MEM_ACCESS_OFFSET 0x306c
 
 #define PCIE_CORE_UTL_SYSTEM_BUS_AGENT_STATUS 0x5908
 #define  RNPP 0x80000000U
diff --git a/drivers/net/cxgb4/t4fw_api.h b/drivers/net/cxgb4/t4fw_api.h
index ca45df8..0969f2f 100644
--- a/drivers/net/cxgb4/t4fw_api.h
+++ b/drivers/net/cxgb4/t4fw_api.h
@@ -485,6 +485,8 @@ enum fw_params_param_pfvf {
 	FW_PARAMS_PARAM_PFVF_SCHEDCLASS_ETH = 0x20,
 	FW_PARAMS_PARAM_PFVF_VIID       = 0x24,
 	FW_PARAMS_PARAM_PFVF_CPMASK     = 0x25,
+	FW_PARAMS_PARAM_PFVF_OCQ_START  = 0x26,
+	FW_PARAMS_PARAM_PFVF_OCQ_END    = 0x27,
 };
 
 /*
-- 
1.5.4

