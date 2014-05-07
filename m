From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/3] cxgb4: Check if rx checksum offload is enabled, while reading hardware calculated checksum
Date: Wed, 7 May 2014 18:01:03 +0530
Message-ID: <1399465864-17737-3-git-send-email-hariprasad@chelsio.com>
References: <1399465864-17737-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dm@chelsio.com>, <leedom@chelsio.com>,
	<kumaras@chelsio.com>, <nirranjan@chelsio.com>,
	<santosh@chelsio.com>, Hariprasad Shenai <hariprasad@chelsio.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22202 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932181AbaEGM3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 08:29:37 -0400
In-Reply-To: <1399465864-17737-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index ca95cf2..cced1a3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1697,7 +1697,8 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 		return handle_trace_pkt(q->adap, si);
 
 	pkt = (const struct cpl_rx_pkt *)rsp;
-	csum_ok = pkt->csum_calc && !pkt->err_vec;
+	csum_ok = pkt->csum_calc && !pkt->err_vec &&
+		  (q->netdev->features & NETIF_F_RXCSUM);
 	if ((pkt->l2info & htonl(RXF_TCP)) &&
 	    (q->netdev->features & NETIF_F_GRO) && csum_ok && !pkt->ip_frag) {
 		do_gro(rxq, si, pkt);
@@ -1720,8 +1721,7 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 
 	rxq->stats.pkts++;
 
-	if (csum_ok && (q->netdev->features & NETIF_F_RXCSUM) &&
-	    (pkt->l2info & htonl(RXF_UDP | RXF_TCP))) {
+	if (csum_ok && (pkt->l2info & htonl(RXF_UDP | RXF_TCP))) {
 		if (!pkt->ip_frag) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			rxq->stats.rx_cso++;
-- 
1.8.4
