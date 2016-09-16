From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 1/2] cxgb4: advertise support for FR_NSMR_TPTE_WR
Date: Fri, 16 Sep 2016 07:54:49 -0700
Message-ID: <94698e9617e4efa507f895eabe9acedae34b8bf5.1474037695.git.swise@opengridcomputing.com>
References: <cover.1474037695.git.swise@opengridcomputing.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
To: dledford@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:49727 "EHLO
        smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935339AbcIPO7P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 10:59:15 -0400
In-Reply-To: <cover.1474037695.git.swise@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Query firmware for the FW_PARAMS_PARAM_DEV_RI_FR_NSMR_TPTE_WR parameter.
If it exists and is 1, then advertise support for FR_NSMR_TPTE_WR to
the ULDs.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      | 1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 7 +++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  | 1 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   | 1 +
 4 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 2e2aa9f..65207b3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -346,6 +346,7 @@ struct adapter_params {
 
 	unsigned int max_ordird_qp;       /* Max read depth per RDMA QP */
 	unsigned int max_ird_adapter;     /* Max read depth per adapter */
+	bool fr_nsmr_tpte_wr_support;	  /* FW support for FR_NSMR_TPTE_WR */
 };
 
 /* State needed to monitor the forward progress of SGE Ingress DMA activities
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c762a8c..37e0c82 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2517,6 +2517,7 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	lli.max_ird_adapter = adap->params.max_ird_adapter;
 	lli.ulptx_memwrite_dsgl = adap->params.ulptx_memwrite_dsgl;
 	lli.nodeid = dev_to_node(adap->pdev_dev);
+	lli.fr_nsmr_tpte_wr_support = adap->params.fr_nsmr_tpte_wr_support;
 
 	handle = ulds[uld].add(&lli);
 	if (IS_ERR(handle)) {
@@ -4016,6 +4017,12 @@ static int adap_init0(struct adapter *adap)
 		adap->params.ulptx_memwrite_dsgl = (ret == 0 && val[0] != 0);
 	}
 
+	/* See if FW supports FW_RI_FR_NSMR_TPTE_WR work request */
+	params[0] = FW_PARAM_DEV(RI_FR_NSMR_TPTE_WR);
+	ret = t4_query_params(adap, adap->mbox, adap->pf, 0,
+			      1, params, val);
+	adap->params.fr_nsmr_tpte_wr_support = (ret == 0 && val[0] != 0);
+
 	/*
 	 * Get device capabilities so we can determine what resources we need
 	 * to manage.
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index f3c58aa..42e73f7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -280,6 +280,7 @@ struct cxgb4_lld_info {
 	unsigned int iscsi_llimit;	     /* chip's iscsi region llimit */
 	void **iscsi_ppm;		     /* iscsi page pod manager */
 	int nodeid;			     /* device numa node id */
+	bool fr_nsmr_tpte_wr_support;	     /* FW supports FR_NSMR_TPTE_WR */
 };
 
 struct cxgb4_uld_info {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index a89b307..9164d20 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1119,6 +1119,7 @@ enum fw_params_param_dev {
 	FW_PARAMS_PARAM_DEV_MAXIRD_ADAPTER = 0x14, /* max supported adap IRD */
 	FW_PARAMS_PARAM_DEV_ULPTX_MEMWRITE_DSGL = 0x17,
 	FW_PARAMS_PARAM_DEV_FWCACHE = 0x18,
+	FW_PARAMS_PARAM_DEV_RI_FR_NSMR_TPTE_WR	= 0x1C,
 };
 
 /*
-- 
2.7.0
