From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4vf: Read correct FL congestion threshold for T5 and T6
Date: Thu, 23 Jul 2015 22:41:14 +0530
Message-ID: <1437671474-30987-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2201 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752407AbbGWL5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 07:57:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VF driver was reading incorrect freelist congestion notification threshold
for FLM queues when packing is enabled for T5 and T6 adapter. Fixing it
now.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |  5 +++++
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c   | 18 ++++++++++++++++--
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 375a825..ed8a8f3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -338,6 +338,11 @@
 #define EGRTHRESHOLDPACKING_G(x) \
 	(((x) >> EGRTHRESHOLDPACKING_S) & EGRTHRESHOLDPACKING_M)
 
+#define T6_EGRTHRESHOLDPACKING_S    16
+#define T6_EGRTHRESHOLDPACKING_M    0xffU
+#define T6_EGRTHRESHOLDPACKING_G(x) \
+	(((x) >> T6_EGRTHRESHOLDPACKING_S) & T6_EGRTHRESHOLDPACKING_M)
+
 #define SGE_TIMESTAMP_LO_A 0x1098
 #define SGE_TIMESTAMP_HI_A 0x109c
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 1d5e77a..fa3786a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -2668,8 +2668,22 @@ int t4vf_sge_init(struct adapter *adapter)
 	 * give it more Free List entries.  (Note that the SGE's Egress
 	 * Congestion Threshold is in units of 2 Free List pointers.)
 	 */
-	s->fl_starve_thres
-		= EGRTHRESHOLD_G(sge_params->sge_congestion_control)*2 + 1;
+	switch (CHELSIO_CHIP_VERSION(adapter->params.chip)) {
+	case CHELSIO_T4:
+		s->fl_starve_thres =
+		   EGRTHRESHOLD_G(sge_params->sge_congestion_control);
+		break;
+	case CHELSIO_T5:
+		s->fl_starve_thres =
+		   EGRTHRESHOLDPACKING_G(sge_params->sge_congestion_control);
+		break;
+	case CHELSIO_T6:
+	default:
+		s->fl_starve_thres =
+		   T6_EGRTHRESHOLDPACKING_G(sge_params->sge_congestion_control);
+		break;
+	}
+	s->fl_starve_thres = s->fl_starve_thres * 2 + 1;
 
 	/*
 	 * Set up tasklet timers.
-- 
2.3.4
