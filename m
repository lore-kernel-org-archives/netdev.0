From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 01/18] ipw2200: Exponential averaging for signal and noise Level
Date: Thu, 13 Apr 2006 17:19:02 +0800
Message-ID: <20060413091902.GA28695@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:54192 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S964839AbWDMJ0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:26:08 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces sliding averaging by exponential averaging for
reporting the wireless statistics for signal and noise level for ipw2200.
See details from: http://www.ces.clemson.edu/linux/ipw2200_averages.shtml

Signed-off-by: Bill Moss <bmoss@clemson.edu>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   34 ++++++++++++++++++++--------------
 drivers/net/wireless/ipw2200.h |    6 ++----
 2 files changed, 22 insertions(+), 18 deletions(-)

1864e427f7b49b5dc9e419f2c6b02ea8b682ead7
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 9dce522..77caeac 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -3771,6 +3771,13 @@ static void inline average_init(struct a
 	memset(avg, 0, sizeof(*avg));
 }
 
+#define DEPTH_RSSI 8
+#define DEPTH_NOISE 16
+static s16 exponential_average(s16 prev_avg, s16 val, u8 depth)
+{
+	return ((depth-1)*prev_avg +  val)/depth;
+}
+
 static void average_add(struct average *avg, s16 val)
 {
 	avg->sum -= avg->entries[avg->pos];
@@ -3800,8 +3807,8 @@ static void ipw_reset_stats(struct ipw_p
 	priv->quality = 0;
 
 	average_init(&priv->average_missed_beacons);
-	average_init(&priv->average_rssi);
-	average_init(&priv->average_noise);
+	priv->exp_avg_rssi = -60;
+	priv->exp_avg_noise = -85 + 0x100;
 
 	priv->last_rate = 0;
 	priv->last_missed_beacons = 0;
@@ -4008,7 +4015,7 @@ static void ipw_gather_stats(struct ipw_
 	IPW_DEBUG_STATS("Tx quality   : %3d%% (%u errors, %u packets)\n",
 			tx_quality, tx_failures_delta, tx_packets_delta);
 
-	rssi = average_value(&priv->average_rssi);
+	rssi = priv->exp_avg_rssi;
 	signal_quality =
 	    (100 *
 	     (priv->ieee->perfect_rssi - priv->ieee->worst_rssi) *
@@ -4023,7 +4030,7 @@ static void ipw_gather_stats(struct ipw_
 	else if (signal_quality < 1)
 		signal_quality = 0;
 
-	IPW_DEBUG_STATS("Signal level : %3d%% (%d dBm)\n",
+	IPW_ERROR("Signal level : %3d%% (%d dBm)\n",
 			signal_quality, rssi);
 
 	quality = min(beacon_quality,
@@ -4577,11 +4584,10 @@ static void ipw_rx_notification(struct i
 
 	case HOST_NOTIFICATION_NOISE_STATS:{
 			if (notif->size == sizeof(u32)) {
-				priv->last_noise =
-				    (u8) (le32_to_cpu(notif->u.noise.value) &
-					  0xff);
-				average_add(&priv->average_noise,
-					    priv->last_noise);
+				priv->exp_avg_noise =
+				    exponential_average(priv->exp_avg_noise,
+				    (u8) (le32_to_cpu(notif->u.noise.value) & 0xff),
+				    DEPTH_NOISE);
 				break;
 			}
 
@@ -7840,9 +7846,9 @@ static void ipw_rx(struct ipw_priv *priv
 				if (network_packet && priv->assoc_network) {
 					priv->assoc_network->stats.rssi =
 					    stats.rssi;
-					average_add(&priv->average_rssi,
-						    stats.rssi);
-					priv->last_rx_rssi = stats.rssi;
+					priv->exp_avg_rssi =
+					    exponential_average(priv->exp_avg_rssi,
+					    stats.rssi, DEPTH_RSSI);
 				}
 
 				IPW_DEBUG_RX("Frame: len=%u\n",
@@ -9582,8 +9588,8 @@ static struct iw_statistics *ipw_get_wir
 	}
 
 	wstats->qual.qual = priv->quality;
-	wstats->qual.level = average_value(&priv->average_rssi);
-	wstats->qual.noise = average_value(&priv->average_noise);
+	wstats->qual.level = priv->exp_avg_rssi;
+	wstats->qual.noise = priv->exp_avg_noise;
 	wstats->qual.updated = IW_QUAL_QUAL_UPDATED | IW_QUAL_LEVEL_UPDATED |
 	    IW_QUAL_NOISE_UPDATED | IW_QUAL_DBM;
 
diff --git a/drivers/net/wireless/ipw2200.h b/drivers/net/wireless/ipw2200.h
index 4b98049..1f2cab3 100644
--- a/drivers/net/wireless/ipw2200.h
+++ b/drivers/net/wireless/ipw2200.h
@@ -1153,11 +1153,9 @@ struct ipw_priv {
 	u32 config;
 	u32 capability;
 
-	u8 last_rx_rssi;
-	u8 last_noise;
 	struct average average_missed_beacons;
-	struct average average_rssi;
-	struct average average_noise;
+	s16 exp_avg_rssi;
+	s16 exp_avg_noise;
 	u32 port_type;
 	int rx_bufs_min;	  /**< minimum number of bufs in Rx queue */
 	int rx_pend_max;	  /**< maximum pending buffers for one IRQ */
-- 
1.2.6

