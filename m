From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 1/9] cxgb4vf: small changes to message processing structures/macros
Date: Fri, 25 Jun 2010 15:09:38 -0700
Message-ID: <201006251509.38893.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27106 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166Ab0FYWJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 18:09:39 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5PM9eaG019373
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 15:09:40 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split cpl_tx_pkt_lso into core message structure and encapsulated message,
make RSPD_LEN macro match other response descriptor macros.

Signed-off-by: Casey Leedom
---
 drivers/net/cxgb4/sge.c    |    4 ++--
 drivers/net/cxgb4/t4_hw.h  |    4 +++-
 drivers/net/cxgb4/t4_msg.h |   14 ++++++++++++--
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index d1f8f22..4388f72 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -931,7 +931,7 @@ out_free:	dev_kfree_skb(skb);
 
 	ssi = skb_shinfo(skb);
 	if (ssi->gso_size) {
-		struct cpl_tx_pkt_lso *lso = (void *)wr;
+		struct cpl_tx_pkt_lso_core *lso = (void *)(wr + 1);
 		bool v6 = (ssi->gso_type & SKB_GSO_TCPV6) != 0;
 		int l3hdr_len = skb_network_header_len(skb);
 		int eth_xtra_len = skb_network_offset(skb) - ETH_HLEN;
@@ -1718,7 +1718,7 @@ static int process_responses(struct sge_rspq *q, int 
budget)
 					free_rx_bufs(q->adap, &rxq->fl, 1);
 					q->offset = 0;
 				}
-				len &= RSPD_LEN;
+				len = RSPD_LEN(len);
 			}
 			si.tot_len = len;
 
diff --git a/drivers/net/cxgb4/t4_hw.h b/drivers/net/cxgb4/t4_hw.h
index f886677..98c02be 100644
--- a/drivers/net/cxgb4/t4_hw.h
+++ b/drivers/net/cxgb4/t4_hw.h
@@ -88,11 +88,13 @@ struct rsp_ctrl {
 };
 
 #define RSPD_NEWBUF 0x80000000U
-#define RSPD_LEN    0x7fffffffU
+#define RSPD_LEN(x) (((x) >> 0) & 0x7fffffffU)
+#define RSPD_QID(x) RSPD_LEN(x)
 
 #define RSPD_GEN(x)  ((x) >> 7)
 #define RSPD_TYPE(x) (((x) >> 4) & 3)
 
 #define QINTR_CNT_EN       0x1
 #define QINTR_TIMER_IDX(x) ((x) << 1)
+#define QINTR_TIMER_IDX_GET(x) (((x) << 1) & 0x7)
 #endif /* __T4_HW_H */
diff --git a/drivers/net/cxgb4/t4_msg.h b/drivers/net/cxgb4/t4_msg.h
index 7a981b8..623932b 100644
--- a/drivers/net/cxgb4/t4_msg.h
+++ b/drivers/net/cxgb4/t4_msg.h
@@ -443,8 +443,7 @@ struct cpl_tx_pkt {
 
 #define cpl_tx_pkt_xt cpl_tx_pkt
 
-struct cpl_tx_pkt_lso {
-	WR_HDR;
+struct cpl_tx_pkt_lso_core {
 	__be32 lso_ctrl;
 #define LSO_TCPHDR_LEN(x) ((x) << 0)
 #define LSO_IPHDR_LEN(x)  ((x) << 4)
@@ -460,6 +459,12 @@ struct cpl_tx_pkt_lso {
 	/* encapsulated CPL (TX_PKT, TX_PKT_XT or TX_DATA) follows here */
 };
 
+struct cpl_tx_pkt_lso {
+	WR_HDR;
+	struct cpl_tx_pkt_lso_core c;
+	/* encapsulated CPL (TX_PKT, TX_PKT_XT or TX_DATA) follows here */
+};
+
 struct cpl_iscsi_hdr {
 	union opcode_tid ot;
 	__be16 pdu_len_ddp;
@@ -623,6 +628,11 @@ struct cpl_fw6_msg {
 	__be64 data[4];
 };
 
+/* cpl_fw6_msg.type values */
+enum {
+	FW6_TYPE_CMD_RPL = 0,
+};
+
 enum {
 	ULP_TX_MEM_READ = 2,
 	ULP_TX_MEM_WRITE = 3,
