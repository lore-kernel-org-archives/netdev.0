From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/5] cxgb4: Updates for T5 SGE's Egress Congestion Threshold
Date: Thu, 13 Mar 2014 20:50:49 +0530
Message-ID: <1394724050-9291-5-git-send-email-hariprasad@chelsio.com>
References: <1394724050-9291-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, swise@opengridcomputing.com,
	leedom@chelsio.com, santosh@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12654 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754344AbaCMP3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 11:29:22 -0400
In-Reply-To: <1394724050-9291-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c     | 18 +++++++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |  6 ++++++
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 054bb03..a7c56b3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2776,8 +2776,8 @@ static int t4_sge_init_hard(struct adapter *adap)
 int t4_sge_init(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
-	u32 sge_control;
-	int ret;
+	u32 sge_control, sge_conm_ctrl;
+	int ret, egress_threshold;
 
 	/*
 	 * Ingress Padding Boundary and Egress Status Page Size are set up by
@@ -2802,10 +2802,18 @@ int t4_sge_init(struct adapter *adap)
 	 * SGE's Egress Congestion Threshold.  If it isn't, then we can get
 	 * stuck waiting for new packets while the SGE is waiting for us to
 	 * give it more Free List entries.  (Note that the SGE's Egress
-	 * Congestion Threshold is in units of 2 Free List pointers.)
+	 * Congestion Threshold is in units of 2 Free List pointers.) For T4,
+	 * there was only a single field to control this.  For T5 there's the
+	 * original field which now only applies to Unpacked Mode Free List
+	 * buffers and a new field which only applies to Packed Mode Free List
+	 * buffers.
 	 */
-	s->fl_starve_thres
-		= EGRTHRESHOLD_GET(t4_read_reg(adap, SGE_CONM_CTRL))*2 + 1;
+	sge_conm_ctrl = t4_read_reg(adap, SGE_CONM_CTRL);
+	if (is_t4(adap->params.chip))
+		egress_threshold = EGRTHRESHOLD_GET(sge_conm_ctrl);
+	else
+		egress_threshold = EGRTHRESHOLDPACKING_GET(sge_conm_ctrl);
+	s->fl_starve_thres = 2*egress_threshold + 1;
 
 	setup_timer(&s->rx_timer, sge_rx_timer_cb, (unsigned long)adap);
 	setup_timer(&s->tx_timer, sge_tx_timer_cb, (unsigned long)adap);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 33cf9ef..225ad8a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -230,6 +230,12 @@
 #define  EGRTHRESHOLD(x)     ((x) << EGRTHRESHOLDshift)
 #define  EGRTHRESHOLD_GET(x) (((x) & EGRTHRESHOLD_MASK) >> EGRTHRESHOLDshift)
 
+#define EGRTHRESHOLDPACKING_MASK	0x3fU
+#define EGRTHRESHOLDPACKING_SHIFT	14
+#define EGRTHRESHOLDPACKING(x)		((x) << EGRTHRESHOLDPACKING_SHIFT)
+#define EGRTHRESHOLDPACKING_GET(x)	(((x) >> EGRTHRESHOLDPACKING_SHIFT) & \
+					  EGRTHRESHOLDPACKING_MASK)
+
 #define SGE_DBFIFO_STATUS 0x10a4
 #define  HP_INT_THRESH_SHIFT 28
 #define  HP_INT_THRESH_MASK  0xfU
-- 
1.8.4
