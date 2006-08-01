From: Ulrich Kunitz <kune@deine-taler.de>
Subject: [PATCH 1/6] zd1211rw: Fixes radiotap header
Date: Tue, 01 Aug 2006 23:43:30 +0200
Message-ID: <11544686152332-git-send-email-kune@deine-taler.de>
References: <1154468615618-git-send-email-kune@deine-taler.de>
Reply-To: Ulrich Kunitz <kune@deine-taler.de>
Cc: netdev@vger.kernel.org, dsd@gentoo.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:26308 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751056AbWHAVng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 17:43:36 -0400
To: linville@tuxdriver.com
In-Reply-To: <1154468615618-git-send-email-kune@deine-taler.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There has been a problem in the radiotap header. Monitor mode
works now with tcpdump 3.94 + libpcap 0.9.4. ethereal 0.99.0 +
libpcap 0.9.4 is broken, because it doesn't find the right offset
for the IEEE 802.11 header.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
---
 drivers/net/wireless/zd1211rw/zd_mac.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 3bdc54d..b394303 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -713,10 +713,10 @@ static int zd_mac_tx(struct zd_mac *mac,
 struct zd_rt_hdr {
 	struct ieee80211_radiotap_header rt_hdr;
 	u8  rt_flags;
+	u8  rt_rate;
 	u16 rt_channel;
 	u16 rt_chbitmask;
-	u16 rt_rate;
-};
+} __attribute__((packed));
 
 static void fill_rt_header(void *buffer, struct zd_mac *mac,
 	                   const struct ieee80211_rx_stats *stats,
@@ -735,14 +735,14 @@ static void fill_rt_header(void *buffer,
 	if (status->decryption_type & (ZD_RX_WEP64|ZD_RX_WEP128|ZD_RX_WEP256))
 		hdr->rt_flags |= IEEE80211_RADIOTAP_F_WEP;
 
+	hdr->rt_rate = stats->rate / 5;
+
 	/* FIXME: 802.11a */
 	hdr->rt_channel = cpu_to_le16(ieee80211chan2mhz(
 		                             _zd_chip_get_channel(&mac->chip)));
 	hdr->rt_chbitmask = cpu_to_le16(IEEE80211_CHAN_2GHZ |
 		((status->frame_status & ZD_RX_FRAME_MODULATION_MASK) ==
 		ZD_RX_OFDM ? IEEE80211_CHAN_OFDM : IEEE80211_CHAN_CCK));
-
-	hdr->rt_rate = stats->rate / 5;
 }
 
 /* Returns 1 if the data packet is for us and 0 otherwise. */
-- 
1.4.1

