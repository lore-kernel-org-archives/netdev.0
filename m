From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] adm8211: Fix compilation for d80211 hwmode API change
Date: Fri, 15 Dec 2006 20:44:05 +0100
Message-ID: <200612152044.05268.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	flamingice@sourmilk.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49019
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313AbWLOTo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 14:44:26 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes compilation for the d80211 hwmode API change.

Signed-off-by: Michael Buesch <mb@bu3sch.de>


Index: jbenc-dscape/drivers/net/wireless/d80211/adm8211/adm8211.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/adm8211/adm8211.c	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/adm8211/adm8211.c	2006-12-15 18:50:44.000000000 +0100
@@ -2034,8 +2034,6 @@ static int __devinit adm8211_probe(struc
 	dev->channel_change_time = 1000;
 	dev->maxssi = ADM8211_RX_MAX_SSI;// FIXME - This is an approximation
 
-	dev->num_modes = 1;
-	dev->modes = priv->modes;
 	priv->modes[0].mode = MODE_IEEE80211B;
 	/* channel info filled in by adm8211_read_eeprom */
 	memcpy(priv->rates, adm8211_rates, sizeof(adm8211_rates));
@@ -2073,12 +2071,20 @@ static int __devinit adm8211_probe(struc
 		printk(KERN_ERR "%s (adm8211): Cannot register hardware\n", pci_name(pdev));
 		goto err_free_desc;
 	}
+	err = ieee80211_register_hwmode(dev, &priv->modes[0]);
+	if (err) {
+		printk(KERN_ERR "%s (adm8211): Cannot register hwmode\n", pci_name(pdev));
+		goto err_unreg_hw;
+	}
 
 	printk(KERN_INFO "wiphy%d: hwaddr " MAC_FMT ", Rev 0x%02x\n",
 	       dev->index, MAC_ARG(dev->perm_addr), priv->revid);
 
 	return 0;
 
+ err_unreg_hw:
+	ieee80211_unregister_hw(dev);
+
  err_free_desc:
 	pci_free_consistent(pdev,
 			    sizeof(struct adm8211_desc) * priv->rx_ring_size +
Index: jbenc-dscape/drivers/net/wireless/d80211/adm8211/adm8211.h
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/adm8211/adm8211.h	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/adm8211/adm8211.h	2006-12-15 18:43:57.000000000 +0100
@@ -532,7 +532,7 @@ struct adm8211_priv {
 	unsigned cur_tx, dirty_tx, cur_rx;
 
 	struct ieee80211_low_level_stats stats;
-	struct ieee80211_hw_modes modes[1];
+	struct ieee80211_hw_mode modes[1];
 	struct ieee80211_rate rates[ARRAY_SIZE(adm8211_rates)];
 	int mode;
 

-- 
Greetings Michael.
