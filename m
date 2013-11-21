From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 08/13] bna: CQ Read Fix
Date: Wed, 20 Nov 2013 21:54:12 -0800
Message-ID: <1385013257-32745-9-git-send-email-rmody@brocade.com>
References: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:43087 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750805Ab3KUGau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:30:50 -0500
In-Reply-To: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Valid bit check for completion needs read fence so that it does not get
reordered with other loads.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 6ae1d9a..cfdcfb6 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -605,7 +605,11 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 	cq = ccb->sw_q;
 	cmpl = &cq[ccb->producer_index];
 
-	while (cmpl->valid && (packets < budget)) {
+	while (packets < budget) {
+		if (!cmpl->valid)
+			break;
+		rmb();
+
 		BNA_UPDATE_PKT_CNT(pkt_rt, ntohs(cmpl->length));
 
 		if (bna_is_small_rxq(cmpl->rxq_id))
@@ -645,6 +649,7 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 
 				if (!next_cmpl->valid)
 					break;
+				mb();
 
 				len = ntohs(next_cmpl->length);
 				flags = ntohl(next_cmpl->flags);
-- 
1.8.2.3
