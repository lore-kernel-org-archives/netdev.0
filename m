From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/8] cxgb4: Query firmware for T5 ULPTX MEMWRITE DSGL capabilities
Date: Tue, 18 Feb 2014 17:56:12 +0530
Message-ID: <1392726375-32001-6-git-send-email-hariprasad@chelsio.com>
References: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31324 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755342AbaBRNgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 08:36:10 -0500
In-Reply-To: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Query firmware to see whether we're allowed to use T5 ULPTX MEMWRITE DSGL
capabilities.  Also pass that information to Upper Layer Drivers via the
new (struct cxgb4_lld_info).ulptx_memwrite_dsgl boolean.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 16 ++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  1 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  1 +
 4 files changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 028b5e5..944f2cb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -308,6 +308,7 @@ struct adapter_params {
 	unsigned char bypass;
 
 	unsigned int ofldq_wr_cred;
+	bool ulptx_memwrite_dsgl;          /* use of T5 DSGL allowed */
 };
 
 #include "t4fw_api.h"
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 1cc9b4d..0e3e98e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3776,6 +3776,7 @@ static void uld_attach(struct adapter *adap, unsigned int uld)
 	lli.dbfifo_int_thresh = dbfifo_int_thresh;
 	lli.sge_pktshift = adap->sge.pktshift;
 	lli.enable_fw_ofld_conn = adap->flags & FW_OFLD_CONN;
+	lli.ulptx_memwrite_dsgl = adap->params.ulptx_memwrite_dsgl;
 
 	handle = ulds[uld].add(&lli);
 	if (IS_ERR(handle)) {
@@ -5381,6 +5382,21 @@ static int adap_init0(struct adapter *adap)
 	(void) t4_set_params(adap, adap->mbox, adap->fn, 0, 1, params, val);
 
 	/*
+	 * Find out whether we're allowed to use the T5+ ULPTX MEMWRITE DSGL
+	 * capability.  Earlier versions of the firmware didn't have the
+	 * ULPTX_MEMWRITE_DSGL so we'll interpret a query failure as no
+	 * permission to use ULPTX MEMWRITE DSGL.
+	 */
+	if (is_t4(adap->params.chip)) {
+		adap->params.ulptx_memwrite_dsgl = false;
+	} else {
+		params[0] = FW_PARAM_DEV(ULPTX_MEMWRITE_DSGL);
+		ret = t4_query_params(adap, adap->mbox, adap->fn, 0,
+				      1, params, val);
+		adap->params.ulptx_memwrite_dsgl = (ret == 0 && val[0] != 0);
+	}
+
+	/*
 	 * Get device capabilities so we can determine what resources we need
 	 * to manage.
 	 */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 4dd0a82..e274a04 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -253,6 +253,7 @@ struct cxgb4_lld_info {
 					     /*	packet data */
 	bool enable_fw_ofld_conn;            /* Enable connection through fw */
 					     /* WR */
+	bool ulptx_memwrite_dsgl;            /* use of T5 DSGL allowed */
 };
 
 struct cxgb4_uld_info {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index af6e124..9cc973f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -932,6 +932,7 @@ enum fw_params_param_dev {
 	FW_PARAMS_PARAM_DEV_FWREV = 0x0B,
 	FW_PARAMS_PARAM_DEV_TPREV = 0x0C,
 	FW_PARAMS_PARAM_DEV_CF = 0x0D,
+	FW_PARAMS_PARAM_DEV_ULPTX_MEMWRITE_DSGL = 0x17,
 };
 
 /*
-- 
1.8.0
