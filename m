From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx: Fix array overrun in bcm43xx_geo_init
Date: Fri, 5 May 2006 17:23:51 +0200
Message-ID: <200605051723.51609.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Stefano Brivio <st3@riseup.net>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47501
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751146AbWEEPSL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 11:18:11 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The problem here is that the bcm34xx driver and the ieee80211
stack do not agree on what channels are possible for 802.11a.
The ieee80211 stack only wants channels between 34 and 165, while
the bcm43xx driver accepts anything from 0 to 200. I made the
bcm43xx driver comply with the ieee80211 stack expectations, by
using the proper constants.

Signed-off-by: Jean Delvare <jdelvare@suse.de>

[mb]: Reduce stack usage by kzalloc-ing ieee80211_geo

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 17:01:08.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 17:19:59.000000000 +0200
@@ -939,9 +939,9 @@
 	return 0;
 }
 
-static void bcm43xx_geo_init(struct bcm43xx_private *bcm)
+static int bcm43xx_geo_init(struct bcm43xx_private *bcm)
 {
-	struct ieee80211_geo geo;
+	struct ieee80211_geo *geo;
 	struct ieee80211_channel *chan;
 	int have_a = 0, have_bg = 0;
 	int i;
@@ -949,7 +949,10 @@
 	struct bcm43xx_phyinfo *phy;
 	const char *iso_country;
 
-	memset(&geo, 0, sizeof(geo));
+	geo = kzalloc(sizeof(*geo), GFP_KERNEL);
+	if (!geo)
+		return -ENOMEM;
+
 	for (i = 0; i < bcm->nr_80211_available; i++) {
 		phy = &(bcm->core_80211_ext[i].phy);
 		switch (phy->type) {
@@ -967,31 +970,36 @@
 	iso_country = bcm43xx_locale_iso(bcm->sprom.locale);
 
  	if (have_a) {
-		for (i = 0, channel = 0; channel < 201; channel++) {
-			chan = &geo.a[i++];
+		for (i = 0, channel = IEEE80211_52GHZ_MIN_CHANNEL;
+		      channel <= IEEE80211_52GHZ_MAX_CHANNEL; channel++) {
+			chan = &geo->a[i++];
 			chan->freq = bcm43xx_channel_to_freq_a(channel);
 			chan->channel = channel;
 		}
-		geo.a_channels = i;
+		geo->a_channels = i;
 	}
 	if (have_bg) {
-		for (i = 0, channel = 1; channel < 15; channel++) {
-			chan = &geo.bg[i++];
+		for (i = 0, channel = IEEE80211_24GHZ_MIN_CHANNEL;
+		      channel <= IEEE80211_24GHZ_MAX_CHANNEL; channel++) {
+			chan = &geo->bg[i++];
 			chan->freq = bcm43xx_channel_to_freq_bg(channel);
 			chan->channel = channel;
 		}
-		geo.bg_channels = i;
+		geo->bg_channels = i;
 	}
-	memcpy(geo.name, iso_country, 2);
+	memcpy(geo->name, iso_country, 2);
 	if (0 /*TODO: Outdoor use only */)
-		geo.name[2] = 'O';
+		geo->name[2] = 'O';
 	else if (0 /*TODO: Indoor use only */)
-		geo.name[2] = 'I';
+		geo->name[2] = 'I';
 	else
-		geo.name[2] = ' ';
-	geo.name[3] = '\0';
+		geo->name[2] = ' ';
+	geo->name[3] = '\0';
+
+	ieee80211_set_geo(bcm->ieee, geo);
+	kfree(geo);
 
-	ieee80211_set_geo(bcm->ieee, &geo);
+	return 0;
 }
 
 /* DummyTransmission function, as documented on 
@@ -3464,6 +3472,9 @@
 			goto err_80211_unwind;
 		bcm43xx_wireless_core_disable(bcm);
 	}
+	err = bcm43xx_geo_init(bcm);
+	if (err)
+		goto err_80211_unwind;
 	bcm43xx_pctl_set_crystal(bcm, 0);
 
 	/* Set the MAC address in the networking subsystem */
@@ -3472,8 +3483,6 @@
 	else
 		memcpy(bcm->net_dev->dev_addr, bcm->sprom.il0macaddr, 6);
 
-	bcm43xx_geo_init(bcm);
-
 	snprintf(bcm->nick, IW_ESSID_MAX_SIZE,
 		 "Broadcom %04X", bcm->chip_id);
 
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.h	2006-05-01 17:42:02.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.h	2006-05-05 17:01:33.000000000 +0200
@@ -118,12 +118,14 @@
 static inline
 int bcm43xx_is_valid_channel_a(u8 channel)
 {
-	return (channel <= 200);
+	return (channel >= IEEE80211_52GHZ_MIN_CHANNEL
+	       && channel <= IEEE80211_52GHZ_MAX_CHANNEL);
 }
 static inline
 int bcm43xx_is_valid_channel_bg(u8 channel)
 {
-	return (channel >= 1 && channel <= 14);
+	return (channel >= IEEE80211_24GHZ_MIN_CHANNEL
+	       && channel <= IEEE80211_24GHZ_MAX_CHANNEL);
 }
 static inline
 int bcm43xx_is_valid_channel(struct bcm43xx_private *bcm,

-- 
Greetings Michael.
