From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 1/6] cxgb4: Make sure that Freelist size is larger than Egress Congestion Threshold
Date: Tue,  5 May 2015 14:59:51 +0530
Message-ID: <1430818196-26508-2-git-send-email-hariprasad@chelsio.com>
References: <1430818196-26508-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19081 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751251AbbEEERY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 00:17:24 -0400
In-Reply-To: <1430818196-26508-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to make sure that the Free List Size, in pointers, is at
least 2 Egress Queue Units (8 pointers/each) larger than the SGE's Egress
Congestion Threshold (in pointers).

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c   | 9 +++++++++
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c | 6 +++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 0d2edda..517d5b4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2473,6 +2473,15 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	c.iqaddr = cpu_to_be64(iq->phys_addr);
 
 	if (fl) {
+		/* Allocate the ring for the hardware free list (with space
+		 * for its status page) along with the associated software
+		 * descriptor ring.  The free list size needs to be a multiple
+		 * of the Egress Queue Unit and at least 2 Egress Units larger
+		 * than the SGE's Egress Congrestion Threshold
+		 * (fl_starve_thres - 1).
+		 */
+		if (fl->size < s->fl_starve_thres - 1 + 2 * 8)
+			fl->size = s->fl_starve_thres - 1 + 2 * 8;
 		fl->size = roundup(fl->size, 8);
 		fl->desc = alloc_ring(adap->pdev_dev, fl->size, sizeof(__be64),
 				      sizeof(struct rx_sw_desc), &fl->addr,
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 482f6de..cc92c69 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -2243,8 +2243,12 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 		 * Allocate the ring for the hardware free list (with space
 		 * for its status page) along with the associated software
 		 * descriptor ring.  The free list size needs to be a multiple
-		 * of the Egress Queue Unit.
+		 * of the Egress Queue Unit and at least 2 Egress Units larger
+		 * than the SGE's Egress Congrestion Threshold
+		 * (fl_starve_thres - 1).
 		 */
+		if (fl->size < s->fl_starve_thres - 1 + 2 * FL_PER_EQ_UNIT)
+			fl->size = s->fl_starve_thres - 1 + 2 * FL_PER_EQ_UNIT;
 		fl->size = roundup(fl->size, FL_PER_EQ_UNIT);
 		fl->desc = alloc_ring(adapter->pdev_dev, fl->size,
 				      sizeof(__be64), sizeof(struct rx_sw_desc),
-- 
2.3.4
