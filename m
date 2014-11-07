From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 3/3] cxgb4vf: FL Starvation Threshold needs to be larger than the SGE's Egress Congestion Threshold
Date: Fri,  7 Nov 2014 17:06:31 +0530
Message-ID: <1415360191-25395-4-git-send-email-hariprasad@chelsio.com>
References: <1415360191-25395-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:34373
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751934AbaKGLay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 06:30:54 -0500
In-Reply-To: <1415360191-25395-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free List Starvation Threshold needs to be larger than the SGE's Egress
Congestion Threshold or we'll end up in a mutual stall where the driver waits
for Ingress Packets to drive replacing Free List Pointers and the SGE waits for
Free List Pointers before pushing Ingress Packets to the host.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   16 ++++++++++------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    1 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |    5 ++++-
 3 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index cd5b789..fdd078d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -94,12 +94,6 @@ enum {
 	MAX_TIMER_TX_RECLAIM = 100,
 
 	/*
-	 * An FL with <= FL_STARVE_THRES buffers is starving and a periodic
-	 * timer will attempt to refill it.
-	 */
-	FL_STARVE_THRES = 4,
-
-	/*
 	 * Suspend an Ethernet TX queue with fewer available descriptors than
 	 * this.  We always want to have room for a maximum sized packet:
 	 * inline immediate data + MAX_SKB_FRAGS. This is the same as
@@ -2490,6 +2484,16 @@ int t4vf_sge_init(struct adapter *adapter)
 		s->fl_align = max(ingpadboundary, ingpackboundary);
 	}
 
+	/* A FL with <= fl_starve_thres buffers is starving and a periodic
+	 * timer will attempt to refill it.  This needs to be larger than the
+	 * SGE's Egress Congestion Threshold.  If it isn't, then we can get
+	 * stuck waiting for new packets while the SGE is waiting for us to
+	 * give it more Free List entries.  (Note that the SGE's Egress
+	 * Congestion Threshold is in units of 2 Free List pointers.)
+	 */
+	s->fl_starve_thres
+		= EGRTHRESHOLD_GET(sge_params->sge_congestion_control)*2 + 1;
+
 	/*
 	 * Set up tasklet timers.
 	 */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index b5c301d..4b6a6d1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -140,6 +140,7 @@ struct sge_params {
 	u32 sge_user_mode_limits;	/* limits for BAR2 user mode accesses */
 	u32 sge_fl_buffer_size[16];	/* free list buffer sizes */
 	u32 sge_ingress_rx_threshold;	/* RX counter interrupt threshold[4] */
+	u32 sge_congestion_control;     /* congestion thresholds, etc. */
 	u32 sge_timer_value_0_and_1;	/* interrupt coalescing timer values */
 	u32 sge_timer_value_2_and_3;
 	u32 sge_timer_value_4_and_5;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index dc30d28..1e896b9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -493,10 +493,13 @@ int t4vf_get_sge_params(struct adapter *adapter)
 
 	params[0] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
 		     FW_PARAMS_PARAM_XYZ(SGE_INGRESS_RX_THRESHOLD));
-	v = t4vf_query_params(adapter, 1, params, vals);
+	params[1] = (FW_PARAMS_MNEM(FW_PARAMS_MNEM_REG) |
+		     FW_PARAMS_PARAM_XYZ(SGE_CONM_CTRL));
+	v = t4vf_query_params(adapter, 2, params, vals);
 	if (v)
 		return v;
 	sge_params->sge_ingress_rx_threshold = vals[0];
+	sge_params->sge_congestion_control = vals[1];
 
 	return 0;
 }
-- 
1.7.1
