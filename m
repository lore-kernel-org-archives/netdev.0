From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv2 net-next 04/31] cxgb4: Updates for T5 SGE's Egress Congestion Threshold
Date: Mon,  3 Mar 2014 12:10:48 +0530
Message-ID: <1393828875-13452-5-git-send-email-hariprasad@chelsio.com>
References: <1393828875-13452-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393828875-13452-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kumar Sanghvi <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

Based on original work by Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

Signed-off-by: Kumar Sanghvi <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c     |   18 +++++++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |    6 ++++++
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 809ab60..e0376cd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2777,8 +2777,8 @@ static int t4_sge_init_hard(struct adapter *adap)
 int t4_sge_init(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
-	u32 sge_control;
-	int ret;
+	u32 sge_control, sge_conm_ctrl;
+	int ret, egress_threshold;
 
 	/*
 	 * Ingress Padding Boundary and Egress Status Page Size are set up by
@@ -2803,10 +2803,18 @@ int t4_sge_init(struct adapter *adap)
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
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
