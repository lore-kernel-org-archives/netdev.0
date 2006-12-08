From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 02/22] ixgb: Maybe stop TX if not enough free descriptors
Date: Fri, 08 Dec 2006 15:02:48 -0800
Message-ID: <20061208230248.30109.66455.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4354 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761254AbWLHWwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:52:06 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A similar patch to commit 65c7973fa5b46b024f38be208aa477e8daf9a603
but now for ixgb.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb.h         |    1 +
 drivers/net/ixgb/ixgb_ethtool.c |    1 +
 drivers/net/ixgb/ixgb_main.c    |   37 ++++++++++++++++++++++++++++++++++---
 3 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 50ffe90..f4aba43 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -171,6 +171,7 @@ struct ixgb_adapter {
 
 	/* TX */
 	struct ixgb_desc_ring tx_ring ____cacheline_aligned_in_smp;
+	unsigned int restart_queue;
 	unsigned long timeo_start;
 	uint32_t tx_cmd_type;
 	uint64_t hw_csum_tx_good;
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index cd22523..82c044d 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -79,6 +79,7 @@ static struct ixgb_stats ixgb_gstrings_s
 	{"tx_window_errors", IXGB_STAT(net_stats.tx_window_errors)},
 	{"tx_deferred_ok", IXGB_STAT(stats.dc)},
 	{"tx_timeout_count", IXGB_STAT(tx_timeout_count) },
+	{"tx_restart_queue", IXGB_STAT(restart_queue) },
 	{"rx_long_length_errors", IXGB_STAT(stats.roc)},
 	{"rx_short_length_errors", IXGB_STAT(stats.ruc)},
 #ifdef NETIF_F_TSO
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index ebc9d71..9522d5e 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1414,6 +1414,37 @@ ixgb_tx_queue(struct ixgb_adapter *adapt
 	IXGB_WRITE_REG(&adapter->hw, TDT, i);
 }
 
+static int __ixgb_maybe_stop_tx(struct net_device *netdev, int size)
+{
+	struct ixgb_adapter *adapter = netdev_priv(netdev);
+	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
+
+	netif_stop_queue(netdev);
+	/* Herbert's original patch had:
+	 *  smp_mb__after_netif_stop_queue();
+	 * but since that doesn't exist yet, just open code it. */
+	smp_mb();
+
+	/* We need to check again in a case another CPU has just
+	 * made room available. */
+	if (likely(IXGB_DESC_UNUSED(tx_ring) < size))
+		return -EBUSY;
+
+	/* A reprieve! */
+	netif_start_queue(netdev);
+	++adapter->restart_queue;
+	return 0;
+}
+
+static int ixgb_maybe_stop_tx(struct net_device *netdev,
+                              struct ixgb_desc_ring *tx_ring, int size)
+{
+	if (likely(IXGB_DESC_UNUSED(tx_ring) >= size))
+		return 0;
+	return __ixgb_maybe_stop_tx(netdev, size);
+}
+
+
 /* Tx Descriptors needed, worst case */
 #define TXD_USE_COUNT(S) (((S) >> IXGB_MAX_TXD_PWR) + \
 			 (((S) & (IXGB_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
@@ -1447,7 +1478,8 @@ ixgb_xmit_frame(struct sk_buff *skb, str
 	spin_lock_irqsave(&adapter->tx_lock, flags);
 #endif
 
-	if(unlikely(IXGB_DESC_UNUSED(&adapter->tx_ring) < DESC_NEEDED)) {
+	if (unlikely(ixgb_maybe_stop_tx(netdev, &adapter->tx_ring,
+                     DESC_NEEDED))) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return NETDEV_TX_BUSY;
@@ -1485,8 +1517,7 @@ ixgb_xmit_frame(struct sk_buff *skb, str
 
 #ifdef NETIF_F_LLTX
 	/* Make sure there is space in the ring for the next send. */
-	if(unlikely(IXGB_DESC_UNUSED(&adapter->tx_ring) < DESC_NEEDED))
-		netif_stop_queue(netdev);
+	ixgb_maybe_stop_tx(netdev, &adapter->tx_ring, DESC_NEEDED);
 
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 



---
Auke Kok <auke-jan.h.kok@intel.com>
