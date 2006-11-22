From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Remove IW_FREQ_AUTO support
Date: Wed, 22 Nov 2006 00:05:30 +0000 (GMT)
Message-ID: <20061122000530.7F4547B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:6761 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1756833AbWKVAFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 19:05:25 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

http://bugzilla.kernel.org/show_bug.cgi?id=7399

zd1211rw's support for IW_FREQ_AUTO is broken: when specified, the driver
tries to change to a channel specified in an uninitialized integer. As 
IW_FREQ_AUTO is hard to implement properly, the solution (at least for now)
is to drop support for it and start ignoring the flags like all other wireless
drivers do.

This has the added advantage that kismet also starts working with zd1211rw,
even though kismet requesting IW_FREQ_AUTO is also a bug (fixed in their svn)

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_ieee80211.c |    3 ---
 zd_mac.c       |   17 ++++-------------
 zd_mac.h       |    6 +-----
 zd_netdev.c    |   13 +------------
 4 files changed, 6 insertions(+), 33 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_ieee80211.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_ieee80211.c
+++ linux/drivers/net/wireless/zd1211rw/zd_ieee80211.c
@@ -133,9 +133,6 @@ int zd_find_channel(u8 *channel, const s
 	int i, r;
 	u32 mhz;
 
-	if (!(freq->flags & IW_FREQ_FIXED))
-		return 0;
-
 	if (freq->m < 1000) {
 		if (freq->m  > NUM_CHANNELS || freq->m == 0)
 			return -EINVAL;
Index: linux/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -317,21 +317,12 @@ int zd_mac_request_channel(struct zd_mac
 		return 0;
 }
 
-int zd_mac_get_channel(struct zd_mac *mac, u8 *channel, u8 *flags)
+u8 zd_mac_get_channel(struct zd_mac *mac)
 {
-	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
+	u8 channel = zd_chip_get_channel(&mac->chip);
 
-	*channel = zd_chip_get_channel(&mac->chip);
-	if (ieee->iw_mode != IW_MODE_INFRA) {
-		spin_lock_irq(&mac->lock);
-		*flags = *channel == mac->requested_channel ?
-			MAC_FIXED_CHANNEL : 0;
-		spin_unlock(&mac->lock);
-	} else {
-		*flags = 0;
-	}
-	dev_dbg_f(zd_mac_dev(mac), "channel %u flags %u\n", *channel, *flags);
-	return 0;
+	dev_dbg_f(zd_mac_dev(mac), "channel %u\n", channel);
+	return channel;
 }
 
 /* If wrong rate is given, we are falling back to the slowest rate: 1MBit/s */
Index: linux/drivers/net/wireless/zd1211rw/zd_mac.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_mac.h
+++ linux/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -116,10 +116,6 @@ struct rx_status {
 #define ZD_RX_CRC16_ERROR		0x40
 #define ZD_RX_ERROR			0x80
 
-enum mac_flags {
-	MAC_FIXED_CHANNEL = 0x01,
-};
-
 struct housekeeping {
 	struct work_struct link_led_work;
 };
@@ -180,7 +176,7 @@ int zd_mac_set_regdomain(struct zd_mac *
 u8 zd_mac_get_regdomain(struct zd_mac *zd_mac);
 
 int zd_mac_request_channel(struct zd_mac *mac, u8 channel);
-int zd_mac_get_channel(struct zd_mac *mac, u8 *channel, u8 *flags);
+u8 zd_mac_get_channel(struct zd_mac *mac);
 
 int zd_mac_set_mode(struct zd_mac *mac, u32 mode);
 int zd_mac_get_mode(struct zd_mac *mac, u32 *mode);
Index: linux/drivers/net/wireless/zd1211rw/zd_netdev.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_netdev.c
+++ linux/drivers/net/wireless/zd1211rw/zd_netdev.c
@@ -107,21 +107,10 @@ static int iw_get_freq(struct net_device
 	           struct iw_request_info *info,
 		   union iwreq_data *req, char *extra)
 {
-	int r;
 	struct zd_mac *mac = zd_netdev_mac(netdev);
 	struct iw_freq *freq = &req->freq;
-	u8 channel;
-	u8 flags;
 
-	r = zd_mac_get_channel(mac, &channel, &flags);
-	if (r)
-		return r;
-
-	freq->flags = (flags & MAC_FIXED_CHANNEL) ?
-		      IW_FREQ_FIXED : IW_FREQ_AUTO;
-	dev_dbg_f(zd_mac_dev(mac), "channel %s\n",
-		  (flags & MAC_FIXED_CHANNEL) ? "fixed" : "auto");
-	return zd_channel_to_freq(freq, channel);
+	return zd_channel_to_freq(freq, zd_mac_get_channel(mac));
 }
 
 static int iw_set_mode(struct net_device *netdev,
