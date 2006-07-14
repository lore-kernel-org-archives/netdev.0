From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] Try #2, Improved statistics for bcm43xx-softmac
Date: Fri, 14 Jul 2006 15:42:17 -0500
Message-ID: <44B801A9.1050306@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:49301 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1161300AbWGNUmc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 16:42:32 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This minor patch for wireless-2.6 (softmac) adjusts the parameters of the wireless statistics to 
improve the display of programs such as the "Wireless Network Information" applet of KDE. Thanks to 
Dan Williams and Jean Tourrilhes for valuable help in setting up the return of info in dBm.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

==============================================================

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index 8ffd760..76f7228 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -47,9 +47,8 @@ #include "bcm43xx_phy.h"
  #define BCM43xx_WX_VERSION	18

  #define MAX_WX_STRING		80
-/* FIXME: the next line is a guess as to what the maximum value of RX power
-          (in dBm) might be */
-#define RX_POWER_MAX		-10
++/* FIXME: the next line is a guess as to what the maximum RSSI value might be */
+#define RX_RSSI_MAX		60


  static int bcm43xx_wx_get_name(struct net_device *net_dev,
@@ -230,9 +229,8 @@ static int bcm43xx_wx_get_rangeparams(st
  	range->throughput = 27 * 1000 * 1000;

  	range->max_qual.qual = 100;
-	/* TODO: Real max RSSI */
-	range->max_qual.level = 0;
-	range->max_qual.noise = 0;
+	range->max_qual.level = 152;  /* set floor at -104 dBm (152 - 256) */
+	range->max_qual.noise = 152;
  	range->max_qual.updated = IW_QUAL_ALL_UPDATED;

  	range->avg_qual.qual = 50;
@@ -845,6 +843,7 @@ static struct iw_statistics *bcm43xx_get
  	struct iw_statistics *wstats;
  	struct ieee80211_network *network = NULL;
  	static int tmp_level = 0;
+	static int tmp_qual = 0;
  	unsigned long flags;

  	wstats = &bcm->stats.wstats;
@@ -863,25 +862,28 @@ static struct iw_statistics *bcm43xx_get
  		wstats->qual.level = 0;
  		wstats->qual.noise = 0;
  		wstats->qual.updated = 7;
-		wstats->qual.updated |= IW_QUAL_ALL_UPDATED;
+		wstats->qual.updated |= IW_QUAL_ALL_UPDATED | IW_QUAL_DBM;
  		return wstats;
  	}
  	/* fill in the real statistics when iface associated */
  	spin_lock_irqsave(&mac->ieee->lock, flags);
  	list_for_each_entry(network, &mac->ieee->network_list, list) {
  		if (!memcmp(mac->associnfo.bssid, network->bssid, ETH_ALEN)) {
-			if (!tmp_level)		/* get initial value */
-				tmp_level = network->stats.rssi;
-			else			/* smooth results */
-				tmp_level = (7 * tmp_level + network->stats.rssi)/8;
+			if (!tmp_level)	{	/* get initial values */
+				tmp_level = network->stats.signal;
+				tmp_qual = network->stats.rssi;
+			} else {			/* smooth results */
+				tmp_level = (15 * tmp_level + network->stats.signal)/16;
+				tmp_qual = (15 * tmp_qual + network->stats.rssi)/16;
+			}
  			break;
  		}
  	}
  	spin_unlock_irqrestore(&mac->ieee->lock, flags);
  	wstats->qual.level = tmp_level;
-	wstats->qual.qual = 100 + tmp_level - RX_POWER_MAX; // TODO: get the real signal quality
+	wstats->qual.qual = 100*tmp_qual/RX_RSSI_MAX;
  	wstats->qual.noise = bcm->stats.noise;
-	wstats->qual.updated = IW_QUAL_ALL_UPDATED;
+	wstats->qual.updated = IW_QUAL_ALL_UPDATED | IW_QUAL_DBM;
  	wstats->discard.code = bcm->ieee->ieee_stats.rx_discards_undecryptable;
  	wstats->discard.retries = bcm->ieee->ieee_stats.tx_retry_limit_exceeded;
  	wstats->discard.nwid = bcm->ieee->ieee_stats.tx_discards_wrong_sa;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
index 6dbd855..c0efbfe 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -492,16 +492,15 @@ int bcm43xx_rx(struct bcm43xx_private *b

  	memset(&stats, 0, sizeof(stats));
  	stats.mac_time = le16_to_cpu(rxhdr->mactime);
-	stats.rssi = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
+	stats.rssi = rxhdr->rssi;
+	stats.signal = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
  					      !!(rxflags1 & BCM43xx_RXHDR_FLAGS1_2053RSSIADJ),
  					      !!(rxflags3 & BCM43xx_RXHDR_FLAGS3_2050RSSIADJ));
-	stats.signal = rxhdr->signal_quality;	//FIXME
  //TODO	stats.noise =
  	if (is_ofdm)
  		stats.rate = bcm43xx_plcp_get_bitrate_ofdm(plcp);
  	else
  		stats.rate = bcm43xx_plcp_get_bitrate_cck(plcp);
-//printk("RX ofdm %d, rate == %u\n", is_ofdm, stats.rate);
  	stats.received_channel = radio->channel;
  //TODO	stats.control =
  	stats.mask = IEEE80211_STATMASK_SIGNAL |

================================================================
