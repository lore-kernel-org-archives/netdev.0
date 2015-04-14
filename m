From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/5] cxgb4: Freelist starving threshold varies from adapter to adapter
Date: Wed, 15 Apr 2015 02:02:31 +0530
Message-ID: <1429043554-8744-3-git-send-email-hariprasad@chelsio.com>
References: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:1350 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755508AbbDNPUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 11:20:40 -0400
In-Reply-To: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fl_starv_thres could be different from adapter to adapter, don't use
hardcoded values

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 900c642..e0cfce8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -121,12 +121,6 @@
 #define NOMEM_TMR_IDX (SGE_NTIMERS - 1)
 
 /*
- * An FL with <= FL_STARVE_THRES buffers is starving and a periodic timer will
- * attempt to refill it.
- */
-#define FL_STARVE_THRES 4
-
-/*
  * Suspend an Ethernet Tx queue with fewer available descriptors than this.
  * This is the same as calc_tx_descs() for a TSO packet with
  * nr_frags == MAX_SKB_FRAGS.
@@ -248,9 +242,21 @@ static inline unsigned int fl_cap(const struct sge_fl *fl)
 	return fl->size - 8;   /* 1 descriptor = 8 buffers */
 }
 
-static inline bool fl_starving(const struct sge_fl *fl)
+/**
+ *	fl_starving - return whether a Free List is starving.
+ *	@adapter: pointer to the adapter
+ *	@fl: the Free List
+ *
+ *	Tests specified Free List to see whether the number of buffers
+ *	available to the hardware has falled below our "starvation"
+ *	threshold.
+ */
+static inline bool fl_starving(const struct adapter *adapter,
+			       const struct sge_fl *fl)
 {
-	return fl->avail - fl->pend_cred <= FL_STARVE_THRES;
+	const struct sge *s = &adapter->sge;
+
+	return fl->avail - fl->pend_cred <= s->fl_starve_thres;
 }
 
 static int map_skb(struct device *dev, const struct sk_buff *skb,
@@ -655,7 +661,7 @@ out:	cred = q->avail - cred;
 	q->pend_cred += cred;
 	ring_fl_db(adap, q);
 
-	if (unlikely(fl_starving(q))) {
+	if (unlikely(fl_starving(adap, q))) {
 		smp_wmb();
 		set_bit(q->cntxt_id - adap->sge.egr_start,
 			adap->sge.starving_fl);
@@ -2248,7 +2254,7 @@ static void sge_rx_timer_cb(unsigned long data)
 			clear_bit(id, s->starving_fl);
 			smp_mb__after_atomic();
 
-			if (fl_starving(fl)) {
+			if (fl_starving(adap, fl)) {
 				rxq = container_of(fl, struct sge_eth_rxq, fl);
 				if (napi_reschedule(&rxq->rspq.napi))
 					fl->starving++;
-- 
2.3.4
