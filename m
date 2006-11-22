From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 3/3] bcm43xx: API update
Date: Wed, 22 Nov 2006 20:25:48 +0100
Message-ID: <1164223548.5934.29.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
	 <1163979143.9216.14.camel@johannes.berg>
	 <20061120201402.76e69e46@griffin.suse.cz>
	 <1164223133.5934.19.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60054 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1756718AbWKVT1e
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 14:27:34 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <1164223133.5934.19.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Slight API changes in d80211 due to the introduction of wiphy.

--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-11-22 20:10:14.859711991 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-11-22 20:11:13.679711991 +0100
@@ -308,7 +308,8 @@ void bcm43xx_debugfs_add_device(struct b
 
 	bcm->dfsentry = e;
 
-	snprintf(devdir, sizeof(devdir), "wiphy%d", bcm->ieee->index);
+	/* FIXME: should cfg80211 provide a debugfs dir that follows the renaming? */
+	snprintf(devdir, sizeof(devdir), "wiphy%d", bcm->ieee->wiphy->wiphy_index);
 	e->subdir = debugfs_create_dir(devdir, fs.root);
 	e->dentry_tsf = debugfs_create_file("tsf", 0666, e->subdir,
 	                                    bcm, &tsf_fops);
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-11-22 20:10:14.969711991 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-11-22 20:11:13.689711991 +0100
@@ -3179,7 +3179,8 @@ bcm->wlcore = active_core;
 		goto error;
 
 	bcm43xx_macfilter_clear(bcm, BCM43xx_MACFILTER_ASSOC);
-	bcm43xx_macfilter_set(bcm, BCM43xx_MACFILTER_SELF, (u8 *)(bcm->ieee->perm_addr));
+	bcm43xx_macfilter_set(bcm, BCM43xx_MACFILTER_SELF,
+			      (u8 *)(bcm->ieee->wiphy->perm_addr));
 	bcm43xx_security_init(bcm);
 	bcm43xx_measure_channel_change_time(bcm);
 	ieee80211_update_hw(bcm->ieee);
@@ -3446,9 +3447,9 @@ bcm->wlcore = bcm->wlcores[i];
 
 	/* Set the MAC address in the networking subsystem */
 	if (is_valid_ether_addr(bcm->sprom.r1.et1mac))
-		memcpy(bcm->ieee->perm_addr, bcm->sprom.r1.et1mac, 6);
+		SET_IEEE80211_PERM_ADDR(bcm->ieee, bcm->sprom.r1.et1mac);
 	else
-		memcpy(bcm->ieee->perm_addr, bcm->sprom.r1.il0mac, 6);
+		SET_IEEE80211_PERM_ADDR(bcm->ieee, bcm->sprom.r1.il0mac);
 	bcm43xx_setup_modes(bcm);
 
 	assert(err == 0);
@@ -3969,7 +3970,7 @@ static int __devinit bcm43xx_init_one(st
 		       IEEE80211_HW_WEP_INCLUDE_IV;
 	hw->maxssi = BCM43xx_RX_MAX_SSI;
 	hw->queues = 1;
-	hw->dev = &pdev->dev;
+	SET_IEEE80211_DEV(hw, &pdev->dev);
 
 	/* initialize the bcm43xx_private struct */
 	bcm = bcm43xx_priv(hw);


