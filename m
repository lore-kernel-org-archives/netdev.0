From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] Add wireless statics to bcm43xx-d80211
Date: Mon, 14 Aug 2006 08:29:08 -0500
Message-ID: <44E07AA4.8040309@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090507070202060705010505"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:55977 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750846AbWHNN3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 09:29:07 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090507070202060705010505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch implements wireless statistics for bcm43xx using the d80211 stack.It 
also sets a framework for the implementation in other drivers that use the 
d80211 code. The component parts have been circulated on the netdev mailing 
list, and all suggested changes have been incorporated. The specific changes are 
as follows:

1. Add new variables to struct ieee80211_rx_status to contain the
latest values for signal, noise, and the maximum value of the received
ssi. These could be u8's, but I left them as integers in case other
drivers needed larger values.

2. Add new variables to struct ieee80211_local to contain the link_quality and 
noise.Again these could be u8's for bcm43xx.

3. Add last_signal, last_noise and max_rssi to struct sta_info.

4. Remove link_quality and add link_noise to struct bcm43xx_stats.

5. Remove the bogus calculation of link_quality and save the value of link_noise 
in the new variable bcm->stats.link_noise.

6. In bcm43xx_xmit.c, store the new variables in status for transmission to 
ieee80211.

7. In ieee80211_rx_h_sta_process, transfer the new status variables into struct 
sta_info.

8. Add the appropriate range parameters and routine ieee80211_get_wireless_stats 
to ieee80211_ioctl.c.

The patch is submitted as an attachment to preserve white space.

Signed-Off-By: Larry Finger <Larry.Finger.lwfinger.net>


--------------090507070202060705010505
Content-Type: text/plain;
 name="patch_stats"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_stats"

diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
index a0faeca..75174f9 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
@@ -27,6 +27,8 @@ #define BCM43xx_IRQWAIT_MAX_RETRIES	50
 
 #define BCM43xx_IO_SIZE			8192
 
+#define BCM43xx_RX_MAX_SSI		60
+
 /* Active Core PCI Configuration Register. */
 #define BCM43xx_PCICFG_ACTIVE_CORE	0x80
 /* SPROM control register. */
@@ -623,7 +625,7 @@ struct bcm43xx_noise_calculation {
 };
 
 struct bcm43xx_stats {
-	u8 link_quality;
+	u8 link_noise;
 	/* Store the last TX/RX times here for updating the leds. */
 	unsigned long last_tx;
 	unsigned long last_rx;
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 6366020..7f0e0f6 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -1506,15 +1506,7 @@ static void handle_irq_noise(struct bcm4
 		else
 			average -= 48;
 
-		if (average > -65)
-			bcm->stats.link_quality = 0;
-		else if (average > -75)
-			bcm->stats.link_quality = 1;
-		else if (average > -85)
-			bcm->stats.link_quality = 2;
-		else
-			bcm->stats.link_quality = 3;
-//		dprintk(KERN_INFO PFX "Link Quality: %u (avg was %d)\n", bcm->stats.link_quality, average);
+		bcm->stats.link_noise = average;
 drop_calculation:
 		bcm->noisecalc.calculation_running = 0;
 		return;
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
index 3f86079..90776b2 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
@@ -475,7 +475,10 @@ void bcm43xx_rx(struct bcm43xx_private *
 	 */
 
 	memset(&status, 0, sizeof(status));
-	status.ssi = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
+	status.noise = bcm->stats.link_noise;
+	status.ssi = rxhdr->rssi;
+	status.maxssi = BCM43xx_RX_MAX_SSI;
+	status.signal = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
 					      !!(rxflags1 & BCM43xx_RXHDR_FLAGS1_2053RSSIADJ),
 					      !!(rxflags3 & BCM43xx_RXHDR_FLAGS3_2050RSSIADJ));
 	if (is_ofdm)
diff --git a/include/net/d80211.h b/include/net/d80211.h
index ba5cb4c..8479b58 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -205,6 +205,9 @@ struct ieee80211_rx_status {
         int channel;
         int phymode;
         int ssi;
+	int maxssi;
+	int signal;
+	int noise;
         int antenna;
         int rate;
         int flag;
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 11804d5..0eef4a3 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -3174,6 +3174,9 @@ ieee80211_rx_h_sta_process(struct ieee80
 	sta->rx_fragments++;
 	sta->rx_bytes += rx->skb->len;
 	sta->last_rssi = rx->u.rx.status->ssi;
+	sta->last_signal = rx->u.rx.status->signal;
+	sta->last_noise = rx->u.rx.status->noise;
+	sta->max_rssi = rx->u.rx.status->maxssi;
 
 	if (!(rx->fc & IEEE80211_FCTL_MOREFRAGS)) {
 		/* Change STA power saving mode only in the end of a frame
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index bdaaf5e..5e0ec45 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -337,6 +337,9 @@ struct ieee80211_local {
 	struct net_device *apdev; /* wlan#ap - management frames (hostapd) */
 	int open_count;
 	int monitors;
+	int link_quality;
+	int noise;
+	struct iw_statistics wstats;
 	struct ieee80211_conf conf;
 
 	int dev_index;
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index b983716..5352b66 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1580,6 +1580,16 @@ static int ieee80211_ioctl_giwrange(stru
 	range->min_frag = 256;
 	range->max_frag = 2346;
 
+	range->max_qual.qual = 100;
+	range->max_qual.level = 152;  /* set floor at -104 dBm (152 - 256) */
+	range->max_qual.noise = 152;
+	range->max_qual.updated = IW_QUAL_ALL_UPDATED;
+
+	range->avg_qual.qual = 50;
+	range->avg_qual.level = 0;
+	range->avg_qual.noise = 0;
+	range->avg_qual.updated = IW_QUAL_ALL_UPDATED;
+
 	return 0;
 }
 
@@ -3018,6 +3028,39 @@ static int ieee80211_ioctl_giwauth(struc
 	return ret;
 }
 
+/* Get wireless statistics.  Called by /proc/net/wireless and by SIOCGIWSTATS */
+static struct iw_statistics *ieee80211_get_wireless_stats(struct net_device *net_dev)
+{
+	struct ieee80211_local *local = net_dev->ieee80211_ptr;
+	struct iw_statistics * wstats = &local->wstats;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(net_dev);
+	struct sta_info *sta;
+	static int tmp_level = 0;
+	static int tmp_qual = 0;
+
+	sta = sta_info_get(local, sdata->u.wds.remote_addr);
+	if (!sta) {
+		wstats->discard.fragment = 0;
+		wstats->discard.misc = 0;
+		wstats->qual.qual = 0;
+		wstats->qual.level = 0;
+		wstats->qual.noise = 0;
+		wstats->qual.updated |= IW_QUAL_ALL_INVALID;
+	} else {
+		if (!tmp_level) {       /* get initial values */
+			tmp_level = sta->last_signal;
+			tmp_qual = sta->last_rssi;
+		} else {                        /* smooth results */
+			tmp_level = (15 * tmp_level + sta->last_signal)/16;
+			tmp_qual = (15 * tmp_qual + sta->last_rssi)/16;
+		}
+		wstats->qual.level = tmp_level;
+		wstats->qual.qual = 100*tmp_qual/sta->max_rssi;
+		wstats->qual.noise = sta->last_noise;
+		wstats->qual.updated = IW_QUAL_ALL_UPDATED | IW_QUAL_DBM;
+	}
+	return wstats;
+}
 
 static int ieee80211_ioctl_siwencodeext(struct net_device *dev,
 					struct iw_request_info *info,
@@ -3183,6 +3226,7 @@ const struct iw_handler_def ieee80211_iw
 	.standard	= (iw_handler *) ieee80211_handler,
 	.private	= (iw_handler *) ieee80211_private_handler,
 	.private_args	= (struct iw_priv_args *) ieee80211_ioctl_priv,
+	.get_wireless_stats = ieee80211_get_wireless_stats,
 };
 
 /* Wireless handlers for master interface */
diff --git a/net/d80211/sta_info.h b/net/d80211/sta_info.h
index 70334e5..4d4169e 100644
--- a/net/d80211/sta_info.h
+++ b/net/d80211/sta_info.h
@@ -82,6 +82,9 @@ struct sta_info {
 	unsigned long rx_dropped; /* number of dropped MPDUs from this STA */
 
 	int last_rssi; /* RSSI of last received frame from this STA */
+	int last_signal; /* signal of last received frame from this STA */
+	int last_noise; /* noise of last received frame from this STA */
+	int max_rssi; /* maximum value of RSSI for this STA */
 	int last_ack_rssi[3]; /* RSSI of last received ACKs from this STA */
 	unsigned long last_ack;
         int channel_use;

--------------090507070202060705010505--
