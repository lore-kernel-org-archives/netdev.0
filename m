From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx-d80211: measure the channel change time
Date: Wed, 3 May 2006 21:05:53 +0200
Message-ID: <200605032105.53694.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44979
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750740AbWECTBP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 15:01:15 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Measure the channel change time with the
bcm43xx tsf timer and remove the guesswork constant. ;)

Tests on my 4306 show that the time comes damn
close to reality.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-05-03 18:12:27.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-05-03 20:51:24.000000000 +0200
@@ -354,6 +354,33 @@
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, status);
 }
 
+static void bcm43xx_measure_channel_change_time(struct bcm43xx_private *bcm)
+{
+	struct bcm43xx_radioinfo *radio;
+	u64 start, stop;
+	unsigned long flags;
+	u8 oldchan, testchan;
+
+	/* We (ab)use the bcm43xx TSF timer to measure the time needed
+	 * to switch channels. This information is handed over to
+	 * the ieee80211 subsystem.
+	 * Time is measured in microseconds.
+	 */
+
+	bcm43xx_lock_mmio(bcm, flags);
+	radio = bcm43xx_current_radio(bcm);
+	oldchan = radio->channel;
+	testchan = (oldchan == 6) ? 7 : 6;
+	bcm43xx_tsf_read(bcm, &start);
+	bcm43xx_radio_selectchannel(bcm, testchan, 0);
+	bcm43xx_tsf_read(bcm, &stop);
+	bcm43xx_radio_selectchannel(bcm, oldchan, 0);
+	bcm43xx_unlock_mmio(bcm, flags);
+
+	assert(stop > start);
+	bcm->ieee->channel_change_time = stop - start;
+}
+
 static
 void bcm43xx_macfilter_set(struct bcm43xx_private *bcm,
 			   u16 offset,
@@ -3706,6 +3733,7 @@
 	dprintk(KERN_INFO PFX "80211 cores initialized\n");
 	bcm43xx_setup_modes(bcm);
 	bcm43xx_security_init(bcm);
+	bcm43xx_measure_channel_change_time(bcm);
 	ieee80211_update_hw(bcm->net_dev, bcm->ieee);
 	ieee80211_netif_oper(bcm->net_dev, NETIF_ATTACH);
 	ieee80211_netif_oper(bcm->net_dev, NETIF_START);
@@ -4329,7 +4357,6 @@
 	ieee->host_gen_beacon = 1;
 	ieee->rx_includes_fcs = 1;
 	ieee->monitor_during_oper = 1;
-	ieee->channel_change_time = 20000;
 	ieee->tx = bcm43xx_net_hard_start_xmit;
 	ieee->open = bcm43xx_net_open;
 	ieee->stop = bcm43xx_net_stop;

-- 
Greetings Michael.
