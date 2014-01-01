From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 4/5] alx: add alx_get_stats operation
Date: Thu,  2 Jan 2014 00:40:27 +0100
Message-ID: <1388619628-3373-5-git-send-email-sd@queasysnail.net>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:55164 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754769AbaAAXog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jan 2014 18:44:36 -0500
In-Reply-To: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ethernet/atheros/alx/alx.h  |  3 +++
 drivers/net/ethernet/atheros/alx/main.c | 44 +++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
index d71103d..8fc93c5 100644
--- a/drivers/net/ethernet/atheros/alx/alx.h
+++ b/drivers/net/ethernet/atheros/alx/alx.h
@@ -106,6 +106,9 @@ struct alx_priv {
 	u16 msg_enable;
 
 	bool msi;
+
+	/* protects hw.stats */
+	spinlock_t stats_lock;
 };
 
 extern const struct ethtool_ops alx_ethtool_ops;
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index c3c4c26..d825e38 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1166,10 +1166,54 @@ static void alx_poll_controller(struct net_device *netdev)
 }
 #endif
 
+static struct net_device_stats *alx_get_stats(struct net_device *netdev)
+{
+	struct alx_priv *alx = netdev_priv(netdev);
+	struct net_device_stats *net_stats = &netdev->stats;
+	struct alx_hw_stats *hw_stats = &alx->hw.stats;
+
+	spin_lock(&alx->stats_lock);
+
+	__alx_update_hw_stats(&alx->hw);
+
+	net_stats->tx_packets = hw_stats->tx_ok;
+	net_stats->tx_bytes   = hw_stats->tx_byte_cnt;
+	net_stats->rx_packets = hw_stats->rx_ok;
+	net_stats->rx_bytes   = hw_stats->rx_byte_cnt;
+	net_stats->multicast  = hw_stats->rx_mcast;
+	net_stats->collisions = hw_stats->tx_single_col +
+				hw_stats->tx_multi_col * 2 +
+				hw_stats->tx_late_col + hw_stats->tx_abort_col;
+
+	net_stats->rx_errors  = hw_stats->rx_frag + hw_stats->rx_fcs_err +
+				hw_stats->rx_len_err + hw_stats->rx_ov_sz +
+				hw_stats->rx_ov_rrd + hw_stats->rx_align_err;
+
+	net_stats->rx_fifo_errors   = hw_stats->rx_ov_rxf;
+	net_stats->rx_length_errors = hw_stats->rx_len_err;
+	net_stats->rx_crc_errors    = hw_stats->rx_fcs_err;
+	net_stats->rx_frame_errors  = hw_stats->rx_align_err;
+	net_stats->rx_over_errors   = hw_stats->rx_ov_rrd + hw_stats->rx_ov_rxf;
+
+	net_stats->rx_missed_errors = hw_stats->rx_ov_rrd + hw_stats->rx_ov_rxf;
+
+	net_stats->tx_errors = hw_stats->tx_late_col + hw_stats->tx_abort_col +
+			       hw_stats->tx_underrun + hw_stats->tx_trunc;
+
+	net_stats->tx_aborted_errors = hw_stats->tx_abort_col;
+	net_stats->tx_fifo_errors    = hw_stats->tx_underrun;
+	net_stats->tx_window_errors  = hw_stats->tx_late_col;
+
+	spin_unlock(&alx->stats_lock);
+
+	return net_stats;
+}
+
 static const struct net_device_ops alx_netdev_ops = {
 	.ndo_open               = alx_open,
 	.ndo_stop               = alx_stop,
 	.ndo_start_xmit         = alx_start_xmit,
+	.ndo_get_stats          = alx_get_stats,
 	.ndo_set_rx_mode        = alx_set_rx_mode,
 	.ndo_validate_addr      = eth_validate_addr,
 	.ndo_set_mac_address    = alx_set_mac_address,
-- 
1.8.5.2
