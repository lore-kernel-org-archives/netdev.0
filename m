From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next,v4 10/12] bna: Queue Depth and SKB Unmap Array Fix
Date: Tue, 23 Aug 2011 10:56:06 -0700
Message-ID: <1314122168-14314-11-git-send-email-rmody@brocade.com>
References: <1314122168-14314-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:39348 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754352Ab1HWR4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 13:56:48 -0400
In-Reply-To: <1314122168-14314-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - sk_buff unmap_array grows greater than 65536 (x2) with Tx ring of 65536.
   The index used for accessing it is incorrectly declared as u16. It quickly
   wraps around and accesses null sk_buff ptr. So using u32 to handle
   unmap_array.
 - Reducing TXQ depth and safe(max) acking of Tx events to 32768 (same as Rx)

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c         |    4 ++--
 drivers/net/ethernet/brocade/bna/bnad.h         |    4 ++++
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    8 ++++----
 3 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index ccc2cad..16fa435 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -182,8 +182,8 @@ static u32
 bnad_free_txbufs(struct bnad *bnad,
 		 struct bna_tcb *tcb)
 {
-	u32		sent_packets = 0, sent_bytes = 0;
-	u16		wis, unmap_cons, updated_hw_cons;
+	u32		unmap_cons, sent_packets = 0, sent_bytes = 0;
+	u16		wis, updated_hw_cons;
 	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
 	struct bnad_skb_unmap *unmap_array;
 	struct sk_buff		*skb;
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index b31b893..41c984c 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -86,6 +86,10 @@ struct bnad_rx_ctrl {
 #define BNAD_MAX_Q_DEPTH		0x10000
 #define BNAD_MIN_Q_DEPTH		0x200
 
+#define BNAD_MAX_RXQ_DEPTH		(BNAD_MAX_Q_DEPTH / bnad_rxqs_per_cq)
+/* keeping MAX TX and RX Q depth equal */
+#define BNAD_MAX_TXQ_DEPTH		BNAD_MAX_RXQ_DEPTH
+
 #define BNAD_JUMBO_MTU			9000
 
 #define BNAD_NETIF_WAKE_THRESHOLD	8
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 1199f01..e85fb2b 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -407,10 +407,10 @@ bnad_get_ringparam(struct net_device *netdev,
 {
 	struct bnad *bnad = netdev_priv(netdev);
 
-	ringparam->rx_max_pending = BNAD_MAX_Q_DEPTH / bnad_rxqs_per_cq;
+	ringparam->rx_max_pending = BNAD_MAX_RXQ_DEPTH;
 	ringparam->rx_mini_max_pending = 0;
 	ringparam->rx_jumbo_max_pending = 0;
-	ringparam->tx_max_pending = BNAD_MAX_Q_DEPTH;
+	ringparam->tx_max_pending = BNAD_MAX_TXQ_DEPTH;
 
 	ringparam->rx_pending = bnad->rxq_depth;
 	ringparam->rx_mini_max_pending = 0;
@@ -434,13 +434,13 @@ bnad_set_ringparam(struct net_device *netdev,
 	}
 
 	if (ringparam->rx_pending < BNAD_MIN_Q_DEPTH ||
-	    ringparam->rx_pending > BNAD_MAX_Q_DEPTH / bnad_rxqs_per_cq ||
+	    ringparam->rx_pending > BNAD_MAX_RXQ_DEPTH ||
 	    !BNA_POWER_OF_2(ringparam->rx_pending)) {
 		mutex_unlock(&bnad->conf_mutex);
 		return -EINVAL;
 	}
 	if (ringparam->tx_pending < BNAD_MIN_Q_DEPTH ||
-	    ringparam->tx_pending > BNAD_MAX_Q_DEPTH ||
+	    ringparam->tx_pending > BNAD_MAX_TXQ_DEPTH ||
 	    !BNA_POWER_OF_2(ringparam->tx_pending)) {
 		mutex_unlock(&bnad->conf_mutex);
 		return -EINVAL;
-- 
1.7.1

