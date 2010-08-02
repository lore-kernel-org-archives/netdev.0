From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 2/9] cxgb4: don't offload Rx checksums for IPv6 fragments
Date: Mon,  2 Aug 2010 16:19:17 -0700
Message-ID: <1280791164-14181-3-git-send-email-dm@chelsio.com>
References: <1280791164-14181-1-git-send-email-dm@chelsio.com>
 <1280791164-14181-2-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:1801 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab0HBXTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:19:25 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o72NJPVj025629
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 16:19:25 -0700
In-Reply-To: <1280791164-14181-2-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The checksum provided by the device doesn't include the L3 headers,
as IPv6 expects.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/sge.c    |    7 ++++---
 drivers/net/cxgb4/t4_msg.h |    2 ++
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 4388f72..304302a 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -1593,14 +1593,15 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 
 	if (csum_ok && (pi->rx_offload & RX_CSO) &&
 	    (pkt->l2info & htonl(RXF_UDP | RXF_TCP))) {
-		if (!pkt->ip_frag)
+		if (!pkt->ip_frag) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
-		else {
+			rxq->stats.rx_cso++;
+		} else if (pkt->l2info & htonl(RXF_IP)) {
 			__sum16 c = (__force __sum16)pkt->csum;
 			skb->csum = csum_unfold(c);
 			skb->ip_summed = CHECKSUM_COMPLETE;
+			rxq->stats.rx_cso++;
 		}
-		rxq->stats.rx_cso++;
 	} else
 		skb->ip_summed = CHECKSUM_NONE;
 
diff --git a/drivers/net/cxgb4/t4_msg.h b/drivers/net/cxgb4/t4_msg.h
index 623932b..a550d0c 100644
--- a/drivers/net/cxgb4/t4_msg.h
+++ b/drivers/net/cxgb4/t4_msg.h
@@ -529,6 +529,8 @@ struct cpl_rx_pkt {
 	__be32 l2info;
 #define RXF_UDP (1 << 22)
 #define RXF_TCP (1 << 23)
+#define RXF_IP  (1 << 24)
+#define RXF_IP6 (1 << 25)
 	__be16 hdr_len;
 	__be16 err_vec;
 };
-- 
1.5.4

