From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 10/12] bna: TX Queue Depth Fix
Date: Tue, 30 Aug 2011 18:27:46 -0700
Message-ID: <1314754068-31978-11-git-send-email-rmody@brocade.com>
References: <1314754068-31978-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:53390 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754641Ab1HaB2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 21:28:22 -0400
In-Reply-To: <1314754068-31978-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_buff unmap_array grows greater than 65536 (x2) with Tx ring of 65536.
Reducing TXQ depth and safe(max) acking of Tx events to 32768 (same as Rx).
Add defines for TX and RX queue depths.

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.h         |    4 ++++
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    8 ++++----
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 0c9d736..6c42c14 100644
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
index 96ff700..4842224 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -418,10 +418,10 @@ bnad_get_ringparam(struct net_device *netdev,
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
@@ -445,13 +445,13 @@ bnad_set_ringparam(struct net_device *netdev,
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
