From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Fix of signal strength and quality measurement
Date: Tue, 29 Aug 2006 23:50:29 +0100 (BST)
Message-ID: <20060829225029.7BC257B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:41894 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S965154AbWH2WsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 18:48:18 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

Caused by a documentation issue I mixed up fields of the zd_status
structure. This patch fixes it and improves also the average
computation, which is now using only measurements of packets sent
by the access point.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_chip.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++---------------
 zd_mac.c  |   43 +++++++++++++++++++++++++++++++++++--------
 zd_mac.h  |   11 +++++++----
 3 files changed, 88 insertions(+), 27 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -1435,9 +1435,43 @@ static int ofdm_qual_db(u8 status_qualit
 			break;
 	}
 
+	switch (rate) {
+	case ZD_OFDM_RATE_6M:
+	case ZD_OFDM_RATE_9M:
+		i += 3;
+		break;
+	case ZD_OFDM_RATE_12M:
+	case ZD_OFDM_RATE_18M:
+		i += 5;
+		break;
+	case ZD_OFDM_RATE_24M:
+	case ZD_OFDM_RATE_36M:
+		i += 9;
+		break;
+	case ZD_OFDM_RATE_48M:
+	case ZD_OFDM_RATE_54M:
+		i += 15;
+		break;
+	default:
+		return -EINVAL;
+	}
+
 	return i;
 }
 
+static int ofdm_qual_percent(u8 status_quality, u8 rate, unsigned int size)
+{
+	int r;
+
+	r = ofdm_qual_db(status_quality, rate, size);
+	ZD_ASSERT(r >= 0);
+	if (r < 0)
+		r = 0;
+
+	r = (r * 100)/29;
+	return r <= 100 ? r : 100;
+}
+
 static unsigned int log10times100(unsigned int x)
 {
 	static const u8 log10[] = {
@@ -1481,31 +1515,28 @@ static int cck_snr_db(u8 status_quality)
 	return r;
 }
 
-static int rx_qual_db(const void *rx_frame, unsigned int size,
-	              const struct rx_status *status)
+static int cck_qual_percent(u8 status_quality)
 {
-	return (status->frame_status&ZD_RX_OFDM) ?
-		ofdm_qual_db(status->signal_quality_ofdm,
-			     zd_ofdm_plcp_header_rate(rx_frame),
-			     size) :
-		cck_snr_db(status->signal_quality_cck);
+	int r;
+
+	r = cck_snr_db(status_quality);
+	r = (100*r)/17;
+	return r <= 100 ? r : 100;
 }
 
 u8 zd_rx_qual_percent(const void *rx_frame, unsigned int size,
 	              const struct rx_status *status)
 {
-	int r = rx_qual_db(rx_frame, size, status);
-	if (r < 0)
-		r = 0;
-	r = (r * 100) / 14;
-	if (r > 100)
-		r = 100;
-	return r;
+	return (status->frame_status&ZD_RX_OFDM) ?
+		ofdm_qual_percent(status->signal_quality_ofdm,
+			          zd_ofdm_plcp_header_rate(rx_frame),
+			          size) :
+		cck_qual_percent(status->signal_quality_cck);
 }
 
 u8 zd_rx_strength_percent(u8 rssi)
 {
-	int r = (rssi*100) / 30;
+	int r = (rssi*100) / 41;
 	if (r > 100)
 		r = 100;
 	return (u8) r;
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -814,13 +814,25 @@ static int filter_rx(struct ieee80211_de
 	return -EINVAL;
 }
 
-static void update_qual_rssi(struct zd_mac *mac, u8 qual_percent, u8 rssi)
+static void update_qual_rssi(struct zd_mac *mac,
+			     const u8 *buffer, unsigned int length,
+			     u8 qual_percent, u8 rssi_percent)
 {
 	unsigned long flags;
+	struct ieee80211_hdr_3addr *hdr;
+	int i;
+
+	hdr = (struct ieee80211_hdr_3addr *)buffer;
+	if (length < offsetof(struct ieee80211_hdr_3addr, addr3))
+		return;
+	if (memcmp(hdr->addr2, zd_mac_to_ieee80211(mac)->bssid, ETH_ALEN) != 0)
+		return;
 
 	spin_lock_irqsave(&mac->lock, flags);
-	mac->qual_average = (7 * mac->qual_average + qual_percent) / 8;
-	mac->rssi_average = (7 * mac->rssi_average + rssi) / 8;
+	i = mac->stats_count % ZD_MAC_STATS_BUFFER_SIZE;
+	mac->qual_buffer[i] = qual_percent;
+	mac->rssi_buffer[i] = rssi_percent;
+	mac->stats_count++;
 	spin_unlock_irqrestore(&mac->lock, flags);
 }
 
@@ -851,7 +863,6 @@ static int fill_rx_stats(struct ieee8021
 	if (stats->rate)
 		stats->mask |= IEEE80211_STATMASK_RATE;
 
-	update_qual_rssi(mac, stats->signal, stats->rssi);
 	return 0;
 }
 
@@ -875,6 +886,8 @@ int zd_mac_rx(struct zd_mac *mac, const 
 		  sizeof(struct rx_status);
 	buffer += ZD_PLCP_HEADER_SIZE;
 
+	update_qual_rssi(mac, buffer, length, stats.signal, stats.rssi);
+
 	r = filter_rx(ieee, buffer, length, &stats);
 	if (r <= 0)
 		return r;
@@ -979,17 +992,31 @@ struct iw_statistics *zd_mac_get_wireles
 {
 	struct zd_mac *mac = zd_netdev_mac(ndev);
 	struct iw_statistics *iw_stats = &mac->iw_stats;
+	unsigned int i, count, qual_total, rssi_total;
 
 	memset(iw_stats, 0, sizeof(struct iw_statistics));
 	/* We are not setting the status, because ieee->state is not updated
 	 * at all and this driver doesn't track authentication state.
 	 */
 	spin_lock_irq(&mac->lock);
-	iw_stats->qual.qual = mac->qual_average;
-	iw_stats->qual.level = mac->rssi_average;
-	iw_stats->qual.updated = IW_QUAL_QUAL_UPDATED|IW_QUAL_LEVEL_UPDATED|
-		                 IW_QUAL_NOISE_INVALID;
+	count = mac->stats_count < ZD_MAC_STATS_BUFFER_SIZE ?
+		mac->stats_count : ZD_MAC_STATS_BUFFER_SIZE;
+	qual_total = rssi_total = 0;
+	for (i = 0; i < count; i++) {
+		qual_total += mac->qual_buffer[i];
+		rssi_total += mac->rssi_buffer[i];
+	}
 	spin_unlock_irq(&mac->lock);
+	iw_stats->qual.updated = IW_QUAL_NOISE_INVALID;
+	if (count > 0) {
+		iw_stats->qual.qual = qual_total / count;
+		iw_stats->qual.level = rssi_total / count;
+		iw_stats->qual.updated |=
+			IW_QUAL_QUAL_UPDATED|IW_QUAL_LEVEL_UPDATED;
+	} else {
+		iw_stats->qual.updated |=
+			IW_QUAL_QUAL_INVALID|IW_QUAL_LEVEL_INVALID;
+	}
 	/* TODO: update counter */
 	return iw_stats;
 }
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -1,4 +1,4 @@
-/* zd_mac.c
+/* zd_mac.h
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -87,9 +87,9 @@ struct rx_length_info {
 #define RX_LENGTH_INFO_TAG		0x697e
 
 struct rx_status {
+	u8 signal_quality_cck;
 	/* rssi */
 	u8 signal_strength;
-	u8 signal_quality_cck;
 	u8 signal_quality_ofdm;
 	u8 decryption_type;
 	u8 frame_status;
@@ -120,14 +120,17 @@ enum mac_flags {
 	MAC_FIXED_CHANNEL = 0x01,
 };
 
+#define ZD_MAC_STATS_BUFFER_SIZE 16
+
 struct zd_mac {
 	struct zd_chip chip;
 	spinlock_t lock;
 	struct net_device *netdev;
 	/* Unlocked reading possible */
 	struct iw_statistics iw_stats;
-	u8 qual_average;
-	u8 rssi_average;
+	unsigned int stats_count;
+	u8 qual_buffer[ZD_MAC_STATS_BUFFER_SIZE];
+	u8 rssi_buffer[ZD_MAC_STATS_BUFFER_SIZE];
 	u8 regdomain;
 	u8 default_regdomain;
 	u8 requested_channel;
