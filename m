From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/4] Try 2: Modify bcm43xx-d80211 to use wireless statistics
Date: Wed, 23 Aug 2006 22:02:12 -0500
Message-ID: <44ED16B4.6040503@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:10441 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030218AbWHXDCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:02:15 -0400
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches modify bcm43xx-d80211 to use the wireless statics added in patch 1.

Signed-Off-By: Larry Finger@lwfinger.net>

======================================

diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h 
b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
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
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c 
b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 6366020..e1b77ae 100644
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
@@ -4421,6 +4413,7 @@ #endif
  	ieee->host_gen_beacon_template = 1;
  	ieee->rx_includes_fcs = 1;
  	ieee->monitor_during_oper = 1;
+	ieee->maxssi = BCM43xx_RX_MAX_SSI;
  	ieee->tx = bcm43xx_net_hard_start_xmit;
  	ieee->open = bcm43xx_net_open;
  	ieee->stop = bcm43xx_net_stop;
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c 
b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
index 3f86079..d2a2777 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
@@ -475,7 +475,9 @@ void bcm43xx_rx(struct bcm43xx_private *
  	 */

  	memset(&status, 0, sizeof(status));
-	status.ssi = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
+	status.noise = bcm->stats.link_noise;
+	status.ssi = rxhdr->rssi;
+	status.signal = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
  					      !!(rxflags1 & BCM43xx_RXHDR_FLAGS1_2053RSSIADJ),
  					      !!(rxflags3 & BCM43xx_RXHDR_FLAGS3_2050RSSIADJ));
  	if (is_ofdm)
