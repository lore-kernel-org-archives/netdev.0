From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/3] cxgb4vf: Check if rx checksum offload is enabled, while reading hardware calculated checksum
Date: Wed, 7 May 2014 18:01:04 +0530
Message-ID: <1399465864-17737-4-git-send-email-hariprasad@chelsio.com>
References: <1399465864-17737-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dm@chelsio.com>, <leedom@chelsio.com>,
	<kumaras@chelsio.com>, <nirranjan@chelsio.com>,
	<santosh@chelsio.com>, Hariprasad Shenai <hariprasad@chelsio.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28987 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755877AbaEGM3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 08:29:40 -0400
In-Reply-To: <1399465864-17737-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 9cfa4b4..adebbf8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1510,7 +1510,8 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 {
 	struct sk_buff *skb;
 	const struct cpl_rx_pkt *pkt = (void *)rsp;
-	bool csum_ok = pkt->csum_calc && !pkt->err_vec;
+	bool csum_ok = pkt->csum_calc && !pkt->err_vec &&
+		       (rspq->netdev->features & NETIF_F_RXCSUM);
 	struct sge_eth_rxq *rxq = container_of(rspq, struct sge_eth_rxq, rspq);
 
 	/*
@@ -1538,8 +1539,8 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, const __be64 *rsp,
 	skb_record_rx_queue(skb, rspq->idx);
 	rxq->stats.pkts++;
 
-	if (csum_ok && (rspq->netdev->features & NETIF_F_RXCSUM) &&
-	    !pkt->err_vec && (be32_to_cpu(pkt->l2info) & (RXF_UDP|RXF_TCP))) {
+	if (csum_ok && !pkt->err_vec &&
+	    (be32_to_cpu(pkt->l2info) & (RXF_UDP|RXF_TCP))) {
 		if (!pkt->ip_frag)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		else {
-- 
1.8.4
