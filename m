From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 2/4] bcm43xx-d80211: Add wireless statistics
Date: Thu, 02 Nov 2006 12:46:48 -0600
Message-ID: <454A3D18.mail4RZ1BSPL3@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	rt2400-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

These patches modify bcm43xx-d80211 to use the wireless statics added in patch 1.

Signed-Off-By: Larry Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

Please apply to wireless-dev


Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
@@ -27,6 +27,8 @@
 
 #define BCM43xx_IO_SIZE			8192
 
+#define BCM43xx_RX_MAX_SSI		60
+
 /* MMIO offsets */
 #define BCM43xx_MMIO_DMA0_REASON	0x20
 #define BCM43xx_MMIO_DMA0_IRQ_MASK	0x24
@@ -610,7 +612,7 @@ struct bcm43xx_noise_calculation {
 };
 
 struct bcm43xx_stats {
-	u8 link_quality;
+	u8 link_noise;
 	/* Store the last TX/RX times here for updating the leds. */
 	unsigned long last_tx;
 	unsigned long last_rx;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -1199,15 +1199,7 @@ static void handle_irq_noise(struct bcm4
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
@@ -3981,6 +3973,7 @@ static int __devinit bcm43xx_init_one(st
 	ieee->host_gen_beacon_template = 1;
 	ieee->rx_includes_fcs = 0;
 	ieee->monitor_during_oper = 1;
+	ieee->maxssi = BCM43xx_RX_MAX_SSI;
 	ieee->tx = bcm43xx_net_hard_start_xmit;
 	ieee->open = bcm43xx_net_open;
 	ieee->stop = bcm43xx_net_stop;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
@@ -678,10 +678,12 @@ void bcm43xx_rx(struct bcm43xx_private *
 		status.flag |= RX_FLAG_DECRYPTED;
 	}
 
-	status.ssi = bcm43xx_rssi_postprocess(bcm, jssi,
+	status.signal = bcm43xx_rssi_postprocess(bcm, jssi,
 					      (phystat0 & BCM43xx_RX_PHYST0_OFDM),
 					      (phystat0 & BCM43xx_RX_PHYST0_GAINCTL),
 					      (phystat3 & BCM43xx_RX_PHYST3_TRSTATE));
+	status.noise = bcm->stats.link_noise;
+	status.ssi = jssi;
 	if (phystat0 & BCM43xx_RX_PHYST0_OFDM)
 		status.rate = bcm43xx_plcp_get_bitrate_ofdm(plcp);
 	else
