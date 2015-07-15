From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 1/2] enic: add adaptive coalescing intr for intx and msi poll
Date: Wed, 15 Jul 2015 15:34:39 +0530
Message-ID: <1436954680-10248-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:59117 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991AbbGOKFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2015 06:05:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adaptive interrupt coalescing is available for msix. This patch adds the support
for msi poll. Interface for adaptive interrupt coalescing is already added in
driver. We just did not enable it for legacy intr & msi.

enic_calc_int_moderation() & enic_set_int_moderation() are defined as static
after enic_poll. Since enic_poll needs it, move both of these function
definitions above enic_poll. No change in functionality.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 135 ++++++++++++++--------------
 1 file changed, 67 insertions(+), 68 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 918a8e4..8f646e4 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1149,6 +1149,64 @@ static int enic_rq_service(struct vnic_dev *vdev, struct cq_desc *cq_desc,
 	return 0;
 }
 
+static void enic_set_int_moderation(struct enic *enic, struct vnic_rq *rq)
+{
+	unsigned int intr = enic_msix_rq_intr(enic, rq->index);
+	struct vnic_cq *cq = &enic->cq[enic_cq_rq(enic, rq->index)];
+	u32 timer = cq->tobe_rx_coal_timeval;
+
+	if (cq->tobe_rx_coal_timeval != cq->cur_rx_coal_timeval) {
+		vnic_intr_coalescing_timer_set(&enic->intr[intr], timer);
+		cq->cur_rx_coal_timeval = cq->tobe_rx_coal_timeval;
+	}
+}
+
+static void enic_calc_int_moderation(struct enic *enic, struct vnic_rq *rq)
+{
+	struct enic_rx_coal *rx_coal = &enic->rx_coalesce_setting;
+	struct vnic_cq *cq = &enic->cq[enic_cq_rq(enic, rq->index)];
+	struct vnic_rx_bytes_counter *pkt_size_counter = &cq->pkt_size_counter;
+	int index;
+	u32 timer;
+	u32 range_start;
+	u32 traffic;
+	u64 delta;
+	ktime_t now = ktime_get();
+
+	delta = ktime_us_delta(now, cq->prev_ts);
+	if (delta < ENIC_AIC_TS_BREAK)
+		return;
+	cq->prev_ts = now;
+
+	traffic = pkt_size_counter->large_pkt_bytes_cnt +
+		  pkt_size_counter->small_pkt_bytes_cnt;
+	/* The table takes Mbps
+	 * traffic *= 8    => bits
+	 * traffic *= (10^6 / delta)    => bps
+	 * traffic /= 10^6     => Mbps
+	 *
+	 * Combining, traffic *= (8 / delta)
+	 */
+
+	traffic <<= 3;
+	traffic = delta > UINT_MAX ? 0 : traffic / (u32)delta;
+
+	for (index = 0; index < ENIC_MAX_COALESCE_TIMERS; index++)
+		if (traffic < mod_table[index].rx_rate)
+			break;
+	range_start = (pkt_size_counter->small_pkt_bytes_cnt >
+		       pkt_size_counter->large_pkt_bytes_cnt << 1) ?
+		      rx_coal->small_pkt_range_start :
+		      rx_coal->large_pkt_range_start;
+	timer = range_start + ((rx_coal->range_end - range_start) *
+			       mod_table[index].range_percent / 100);
+	/* Damping */
+	cq->tobe_rx_coal_timeval = (timer + cq->tobe_rx_coal_timeval) >> 1;
+
+	pkt_size_counter->large_pkt_bytes_cnt = 0;
+	pkt_size_counter->small_pkt_bytes_cnt = 0;
+}
+
 static int enic_poll(struct napi_struct *napi, int budget)
 {
 	struct net_device *netdev = napi->dev;
@@ -1199,6 +1257,11 @@ static int enic_poll(struct napi_struct *napi, int budget)
 
 	if (err)
 		rq_work_done = rq_work_to_do;
+	if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
+		/* Call the function which refreshes the intr coalescing timer
+		 * value based on the traffic.
+		 */
+		enic_calc_int_moderation(enic, &enic->rq[0]);
 
 	if (rq_work_done < rq_work_to_do) {
 
@@ -1207,70 +1270,14 @@ static int enic_poll(struct napi_struct *napi, int budget)
 		 */
 
 		napi_complete(napi);
+		if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
+			enic_set_int_moderation(enic, &enic->rq[0]);
 		vnic_intr_unmask(&enic->intr[intr]);
 	}
 
 	return rq_work_done;
 }
 
-static void enic_set_int_moderation(struct enic *enic, struct vnic_rq *rq)
-{
-	unsigned int intr = enic_msix_rq_intr(enic, rq->index);
-	struct vnic_cq *cq = &enic->cq[enic_cq_rq(enic, rq->index)];
-	u32 timer = cq->tobe_rx_coal_timeval;
-
-	if (cq->tobe_rx_coal_timeval != cq->cur_rx_coal_timeval) {
-		vnic_intr_coalescing_timer_set(&enic->intr[intr], timer);
-		cq->cur_rx_coal_timeval = cq->tobe_rx_coal_timeval;
-	}
-}
-
-static void enic_calc_int_moderation(struct enic *enic, struct vnic_rq *rq)
-{
-	struct enic_rx_coal *rx_coal = &enic->rx_coalesce_setting;
-	struct vnic_cq *cq = &enic->cq[enic_cq_rq(enic, rq->index)];
-	struct vnic_rx_bytes_counter *pkt_size_counter = &cq->pkt_size_counter;
-	int index;
-	u32 timer;
-	u32 range_start;
-	u32 traffic;
-	u64 delta;
-	ktime_t now = ktime_get();
-
-	delta = ktime_us_delta(now, cq->prev_ts);
-	if (delta < ENIC_AIC_TS_BREAK)
-		return;
-	cq->prev_ts = now;
-
-	traffic = pkt_size_counter->large_pkt_bytes_cnt +
-		  pkt_size_counter->small_pkt_bytes_cnt;
-	/* The table takes Mbps
-	 * traffic *= 8    => bits
-	 * traffic *= (10^6 / delta)    => bps
-	 * traffic /= 10^6     => Mbps
-	 *
-	 * Combining, traffic *= (8 / delta)
-	 */
-
-	traffic <<= 3;
-	traffic = delta > UINT_MAX ? 0 : traffic / (u32)delta;
-
-	for (index = 0; index < ENIC_MAX_COALESCE_TIMERS; index++)
-		if (traffic < mod_table[index].rx_rate)
-			break;
-	range_start = (pkt_size_counter->small_pkt_bytes_cnt >
-		       pkt_size_counter->large_pkt_bytes_cnt << 1) ?
-		      rx_coal->small_pkt_range_start :
-		      rx_coal->large_pkt_range_start;
-	timer = range_start + ((rx_coal->range_end - range_start) *
-			       mod_table[index].range_percent / 100);
-	/* Damping */
-	cq->tobe_rx_coal_timeval = (timer + cq->tobe_rx_coal_timeval) >> 1;
-
-	pkt_size_counter->large_pkt_bytes_cnt = 0;
-	pkt_size_counter->small_pkt_bytes_cnt = 0;
-}
-
 #ifdef CONFIG_RFS_ACCEL
 static void enic_free_rx_cpu_rmap(struct enic *enic)
 {
@@ -1407,10 +1414,8 @@ static int enic_poll_msix_rq(struct napi_struct *napi, int budget)
 	if (err)
 		work_done = work_to_do;
 	if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
-		/* Call the function which refreshes
-		 * the intr coalescing timer value based on
-		 * the traffic.  This is supported only in
-		 * the case of MSI-x mode
+		/* Call the function which refreshes the intr coalescing timer
+		 * value based on the traffic.
 		 */
 		enic_calc_int_moderation(enic, &enic->rq[rq]);
 
@@ -1569,12 +1574,6 @@ static void enic_set_rx_coal_setting(struct enic *enic)
 	int index = -1;
 	struct enic_rx_coal *rx_coal = &enic->rx_coalesce_setting;
 
-	/* If intr mode is not MSIX, do not do adaptive coalescing */
-	if (VNIC_DEV_INTR_MODE_MSIX != vnic_dev_get_intr_mode(enic->vdev)) {
-		netdev_info(enic->netdev, "INTR mode is not MSIX, Not initializing adaptive coalescing");
-		return;
-	}
-
 	/* 1. Read the link speed from fw
 	 * 2. Pick the default range for the speed
 	 * 3. Update it in enic->rx_coalesce_setting
-- 
2.4.5
