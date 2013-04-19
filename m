From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 1/3] qlge: Fix receive path to drop error frames
Date: Fri, 19 Apr 2013 01:49:52 -0400
Message-ID: <1366350594-21973-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1366350594-21973-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:44188 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754039Ab3DSGNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 02:13:49 -0400
In-Reply-To: <1366350594-21973-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

o Fix the driver to drop error frames in the receive path
o Update error counter which was not getting incremented

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   36 +++++++++++++++++++++-----
 1 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index b13ab54..8033555 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1434,11 +1434,13 @@ map_error:
 }
 
 /* Categorizing receive firmware frame errors */
-static void ql_categorize_rx_err(struct ql_adapter *qdev, u8 rx_err)
+static void ql_categorize_rx_err(struct ql_adapter *qdev, u8 rx_err,
+				 struct rx_ring *rx_ring)
 {
 	struct nic_stats *stats = &qdev->nic_stats;
 
 	stats->rx_err_count++;
+	rx_ring->rx_errors++;
 
 	switch (rx_err & IB_MAC_IOCB_RSP_ERR_MASK) {
 	case IB_MAC_IOCB_RSP_ERR_CODE_ERR:
@@ -1474,6 +1476,12 @@ static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
 	struct bq_desc *lbq_desc = ql_get_curr_lchunk(qdev, rx_ring);
 	struct napi_struct *napi = &rx_ring->napi;
 
+	/* Frame error, so drop the packet. */
+	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
+		ql_categorize_rx_err(qdev, ib_mac_rsp->flags2, rx_ring);
+		put_page(lbq_desc->p.pg_chunk.page);
+		return;
+	}
 	napi->dev = qdev->ndev;
 
 	skb = napi_get_frags(napi);
@@ -1529,6 +1537,12 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 	addr = lbq_desc->p.pg_chunk.va;
 	prefetch(addr);
 
+	/* Frame error, so drop the packet. */
+	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
+		ql_categorize_rx_err(qdev, ib_mac_rsp->flags2, rx_ring);
+		goto err_out;
+	}
+
 	/* The max framesize filter on this chip is set higher than
 	 * MTU since FCoE uses 2k frames.
 	 */
@@ -1614,6 +1628,13 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 	memcpy(skb_put(new_skb, length), skb->data, length);
 	skb = new_skb;
 
+	/* Frame error, so drop the packet. */
+	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
+		ql_categorize_rx_err(qdev, ib_mac_rsp->flags2, rx_ring);
+		dev_kfree_skb_any(skb);
+		return;
+	}
+
 	/* loopback self test for ethtool */
 	if (test_bit(QL_SELFTEST, &qdev->flags)) {
 		ql_check_lb_frame(qdev, skb);
@@ -1919,6 +1940,13 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 		return;
 	}
 
+	/* Frame error, so drop the packet. */
+	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
+		ql_categorize_rx_err(qdev, ib_mac_rsp->flags2, rx_ring);
+		dev_kfree_skb_any(skb);
+		return;
+	}
+
 	/* The max framesize filter on this chip is set higher than
 	 * MTU since FCoE uses 2k frames.
 	 */
@@ -2000,12 +2028,6 @@ static unsigned long ql_process_mac_rx_intr(struct ql_adapter *qdev,
 
 	QL_DUMP_IB_MAC_RSP(ib_mac_rsp);
 
-	/* Frame error, so drop the packet. */
-	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
-		ql_categorize_rx_err(qdev, ib_mac_rsp->flags2);
-		return (unsigned long)length;
-	}
-
 	if (ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HV) {
 		/* The data and headers are split into
 		 * separate buffers.
-- 
1.7.6.rc1.1.g2c162b
