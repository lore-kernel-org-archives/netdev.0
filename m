From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Added error stats update
Date: Mon, 29 Jan 2007 01:00:03 +0000 (GMT)
Message-ID: <20070129010003.09E827B40A1@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:25811 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933021AbXA2A76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 19:59:58 -0500
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

Added update of network device error statistics.

Based on earlier work by Maxime Austruy.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_mac.c |   37 ++++++++++++++++++++++++++++++++-----
 zd_usb.c |    9 +++++++++
 2 files changed, 41 insertions(+), 5 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -903,16 +903,21 @@ static int fill_ctrlset(struct zd_mac *m
 static int zd_mac_tx(struct zd_mac *mac, struct ieee80211_txb *txb, int pri)
 {
 	int i, r;
+	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 
 	for (i = 0; i < txb->nr_frags; i++) {
 		struct sk_buff *skb = txb->fragments[i];
 
 		r = fill_ctrlset(mac, txb, i);
-		if (r)
+		if (r) {
+			ieee->stats.tx_dropped++;
 			return r;
+		}
 		r = zd_usb_tx(&mac->chip.usb, skb->data, skb->len);
-		if (r)
+		if (r) {
+			ieee->stats.tx_dropped++;
 			return r;
+		}
 	}
 
 	/* FIXME: shouldn't this be handled by the upper layers? */
@@ -1062,9 +1067,23 @@ static int fill_rx_stats(struct ieee8021
 
 	*pstatus = status = zd_tail(buffer, length, sizeof(struct rx_status));
 	if (status->frame_status & ZD_RX_ERROR) {
-		/* FIXME: update? */
+		struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
+		ieee->stats.rx_errors++;
+		if (status->frame_status & ZD_RX_TIMEOUT_ERROR)
+			ieee->stats.rx_missed_errors++;
+		else if (status->frame_status & ZD_RX_FIFO_OVERRUN_ERROR)
+			ieee->stats.rx_fifo_errors++;
+		else if (status->frame_status & ZD_RX_DECRYPTION_ERROR)
+			ieee->ieee_stats.rx_discards_undecryptable++;
+		else if (status->frame_status & ZD_RX_CRC32_ERROR) {
+			ieee->stats.rx_crc_errors++;
+			ieee->ieee_stats.rx_fcs_errors++;
+		}
+		else if (status->frame_status & ZD_RX_CRC16_ERROR)
+			ieee->stats.rx_crc_errors++;
 		return -EINVAL;
 	}
+
 	memset(stats, 0, sizeof(struct ieee80211_rx_stats));
 	stats->len = length - (ZD_PLCP_HEADER_SIZE + IEEE80211_FCS_LEN +
 		               + sizeof(struct rx_status));
@@ -1093,6 +1112,8 @@ static void zd_mac_rx(struct zd_mac *mac
 	if (skb->len < ZD_PLCP_HEADER_SIZE + IEEE80211_1ADDR_LEN +
 	               IEEE80211_FCS_LEN + sizeof(struct rx_status))
 	{
+		ieee->stats.rx_errors++;
+		ieee->stats.rx_length_errors++;
 		dev_dbg_f(zd_mac_dev(mac), "Packet with length %u to small.\n",
 			 skb->len);
 		goto free_skb;
@@ -1100,7 +1121,9 @@ static void zd_mac_rx(struct zd_mac *mac
 
 	r = fill_rx_stats(&stats, &status, mac, skb->data, skb->len);
 	if (r) {
-		/* Only packets with rx errors are included here. */
+		/* Only packets with rx errors are included here.
+		 * The error stats have already been set in fill_rx_stats.
+		 */
 		goto free_skb;
 	}
 
@@ -1113,8 +1136,10 @@ static void zd_mac_rx(struct zd_mac *mac
 
 	r = filter_rx(ieee, skb->data, skb->len, &stats);
 	if (r <= 0) {
-		if (r < 0)
+		if (r < 0) {
+			ieee->stats.rx_errors++;
 			dev_dbg_f(zd_mac_dev(mac), "Error in packet.\n");
+		}
 		goto free_skb;
 	}
 
@@ -1145,7 +1170,9 @@ int zd_mac_rx_irq(struct zd_mac *mac, co
 
 	skb = dev_alloc_skb(sizeof(struct zd_rt_hdr) + length);
 	if (!skb) {
+		struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 		dev_warn(zd_mac_dev(mac), "Could not allocate skb.\n");
+		ieee->stats.rx_dropped++;
 		return -ENOMEM;
 	}
 	skb_reserve(skb, sizeof(struct zd_rt_hdr));
Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -313,6 +313,12 @@ out:
 
 static inline void handle_retry_failed_int(struct urb *urb)
 {
+	struct zd_usb *usb = urb->context;
+	struct zd_mac *mac = zd_usb_to_mac(usb);
+	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
+
+	ieee->stats.tx_errors++;
+	ieee->ieee_stats.tx_retry_limit_exceeded++;
 	dev_dbg_f(urb_dev(urb), "retry failed interrupt\n");
 }
 
@@ -487,6 +493,9 @@ static void handle_rx_packet(struct zd_u
 
 	if (length < sizeof(struct rx_length_info)) {
 		/* It's not a complete packet anyhow. */
+		struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
+		ieee->stats.rx_errors++;
+		ieee->stats.rx_length_errors++;
 		return;
 	}
 	length_info = (struct rx_length_info *)
