From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 07/12] bna: CQ Read Fix
Date: Tue, 17 Dec 2013 17:07:37 -0800
Message-ID: <1387328862-27213-8-git-send-email-rmody@brocade.com>
References: <1387328862-27213-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:42885 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752286Ab3LRBIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 20:08:40 -0500
In-Reply-To: <1387328862-27213-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Valid bit check for completion needs read fence, so that it does not get
reordered with other loads.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 03fa4a6..7394d46 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -601,7 +601,18 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 	cq = ccb->sw_q;
 	cmpl = &cq[ccb->producer_index];
 
-	while (cmpl->valid && (packets < budget)) {
+	while (packets < budget) {
+		if (!cmpl->valid)
+			break;
+		/* The 'valid' field is set by the adapter, only after writing
+		 * the other fields of completion entry. Hence, do not load
+		 * other fields of completion entry *before* the 'valid' is
+		 * loaded. Adding the rmb() here prevents the compiler and/or
+		 * CPU from reordering the reads which would potentially result
+		 * in reading stale values in completion entry.
+		 */
+		rmb();
+
 		BNA_UPDATE_PKT_CNT(pkt_rt, ntohs(cmpl->length));
 
 		if (bna_is_small_rxq(cmpl->rxq_id))
@@ -641,6 +652,16 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 
 				if (!next_cmpl->valid)
 					break;
+				/* The 'valid' field is set by the adapter, only
+				 * after writing the other fields of completion
+				 * entry. Hence, do not load other fields of
+				 * completion entry *before* the 'valid' is
+				 * loaded. Adding the rmb() here prevents the
+				 * compiler and/or CPU from reordering the reads
+				 * which would potentially result in reading
+				 * stale values in completion entry.
+				 */
+				rmb();
 
 				len = ntohs(next_cmpl->length);
 				flags = ntohl(next_cmpl->flags);
-- 
1.8.2.3
