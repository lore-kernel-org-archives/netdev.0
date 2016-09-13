From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4vf: don't offload Rx checksums for IPv6 fragments
Date: Tue, 13 Sep 2016 12:44:59 +0530
Message-ID: <1473750899-12866-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
        Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:34166 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751198AbcIMHJ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 03:09:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The checksum provided by the device doesn't include the L3 headers,
as IPv6 expects

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index c8fd4f8fe1fa..4d4b94a8969a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1648,14 +1648,15 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 
 	if (csum_ok && !pkt->err_vec &&
 	    (be32_to_cpu(pkt->l2info) & (RXF_UDP_F | RXF_TCP_F))) {
-		if (!pkt->ip_frag)
+		if (!pkt->ip_frag) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
-		else {
+			rxq->stats.rx_cso++;
+		} else if (pkt->l2info & htonl(F_RXF_IP)) {
 			__sum16 c = (__force __sum16)pkt->csum;
 			skb->csum = csum_unfold(c);
 			skb->ip_summed = CHECKSUM_COMPLETE;
+			rxq->stats.rx_cso++;
 		}
-		rxq->stats.rx_cso++;
 	} else
 		skb_checksum_none_assert(skb);
 
-- 
2.3.4
