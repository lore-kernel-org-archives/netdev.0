From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/11] sfc: Fix interface statistics running
 backward
Date: Thu, 12 Jul 2012 00:18:55 +0100
Message-ID: <1342048735.2613.69.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19068 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751253Ab2GKXS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 19:18:58 -0400
In-Reply-To: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some interface statistics are computed in such a way that they can
sometimes decrease (and even underflow).  Since the computed value
will never be greater than the true value, we fix this by only storing
the computed value when it increases.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon_xmac.c |   12 ++++++------
 drivers/net/ethernet/sfc/nic.h         |   18 ++++++++++++++++++
 drivers/net/ethernet/sfc/siena.c       |    8 ++++----
 3 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon_xmac.c b/drivers/net/ethernet/sfc/falcon_xmac.c
index 6106ef1..8333865 100644
--- a/drivers/net/ethernet/sfc/falcon_xmac.c
+++ b/drivers/net/ethernet/sfc/falcon_xmac.c
@@ -341,12 +341,12 @@ void falcon_update_stats_xmac(struct efx_nic *efx)
 	FALCON_STAT(efx, XgTxIpSrcErrPkt, tx_ip_src_error);
 
 	/* Update derived statistics */
-	mac_stats->tx_good_bytes =
-		(mac_stats->tx_bytes - mac_stats->tx_bad_bytes -
-		 mac_stats->tx_control * 64);
-	mac_stats->rx_bad_bytes =
-		(mac_stats->rx_bytes - mac_stats->rx_good_bytes -
-		 mac_stats->rx_control * 64);
+	efx_update_diff_stat(&mac_stats->tx_good_bytes,
+			     mac_stats->tx_bytes - mac_stats->tx_bad_bytes -
+			     mac_stats->tx_control * 64);
+	efx_update_diff_stat(&mac_stats->rx_bad_bytes,
+			     mac_stats->rx_bytes - mac_stats->rx_good_bytes -
+			     mac_stats->rx_control * 64);
 }
 
 void falcon_poll_xmac(struct efx_nic *efx)
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index f48ccf6..bab5cd9 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -294,6 +294,24 @@ extern bool falcon_xmac_check_fault(struct efx_nic *efx);
 extern int falcon_reconfigure_xmac(struct efx_nic *efx);
 extern void falcon_update_stats_xmac(struct efx_nic *efx);
 
+/* Some statistics are computed as A - B where A and B each increase
+ * linearly with some hardware counter(s) and the counters are read
+ * asynchronously.  If the counters contributing to B are always read
+ * after those contributing to A, the computed value may be lower than
+ * the true value by some variable amount, and may decrease between
+ * subsequent computations.
+ *
+ * We should never allow statistics to decrease or to exceed the true
+ * value.  Since the computed value will never be greater than the
+ * true value, we can achieve this by only storing the computed value
+ * when it increases.
+ */
+static inline void efx_update_diff_stat(u64 *stat, u64 diff)
+{
+	if ((s64)(diff - *stat) > 0)
+		*stat = diff;
+}
+
 /* Interrupts and test events */
 extern int efx_nic_init_interrupt(struct efx_nic *efx);
 extern void efx_nic_enable_interrupts(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 2354886..6bafd21 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -458,8 +458,8 @@ static int siena_try_update_nic_stats(struct efx_nic *efx)
 
 	MAC_STAT(tx_bytes, TX_BYTES);
 	MAC_STAT(tx_bad_bytes, TX_BAD_BYTES);
-	mac_stats->tx_good_bytes = (mac_stats->tx_bytes -
-				    mac_stats->tx_bad_bytes);
+	efx_update_diff_stat(&mac_stats->tx_good_bytes,
+			     mac_stats->tx_bytes - mac_stats->tx_bad_bytes);
 	MAC_STAT(tx_packets, TX_PKTS);
 	MAC_STAT(tx_bad, TX_BAD_FCS_PKTS);
 	MAC_STAT(tx_pause, TX_PAUSE_PKTS);
@@ -492,8 +492,8 @@ static int siena_try_update_nic_stats(struct efx_nic *efx)
 	MAC_STAT(tx_ip_src_error, TX_IP_SRC_ERR_PKTS);
 	MAC_STAT(rx_bytes, RX_BYTES);
 	MAC_STAT(rx_bad_bytes, RX_BAD_BYTES);
-	mac_stats->rx_good_bytes = (mac_stats->rx_bytes -
-				    mac_stats->rx_bad_bytes);
+	efx_update_diff_stat(&mac_stats->rx_good_bytes,
+			     mac_stats->rx_bytes - mac_stats->rx_bad_bytes);
 	MAC_STAT(rx_packets, RX_PKTS);
 	MAC_STAT(rx_good, RX_GOOD_PKTS);
 	MAC_STAT(rx_bad, RX_BAD_FCS_PKTS);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
