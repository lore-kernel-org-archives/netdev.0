From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-davem' branch of wireless-2.6
Date: Mon, 17 Dec 2007 15:55:40 -0500
Message-ID: <20071217205540.GH3121@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3003 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932779AbXLQV3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 16:29:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

A few more patches for 2.6.25...  Note that there are a few one-line
patches to some drivers to support a new flag used for timestamps in
radiotap headers for mac80211, and a couple others related to the new
scan capabilities stuff added to WEXT in order to better support hidden
SSIDs for wpa_supplicant/NetworkManager.  I'll CC Jeff as well...

Let me know if there are any problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem

---

The following changes since commit e75bf3477c0d63cdd1f49f91a90816e4360ffc23:
  Joe Perches (1):
        [PARISC]: Fix build after ipv4_is_*() changes.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem

Dan Williams (1):
      introduce WEXT scan capabilities

Johannes Berg (2):
      mac80211: conditionally include timestamp in radiotap information
      wireless: make drivers include the TSF RX flag where appropriate

 drivers/net/wireless/b43/xmit.c            |    1 +
 drivers/net/wireless/b43legacy/xmit.c      |    1 +
 drivers/net/wireless/hostap/hostap_ioctl.c |    3 ++
 drivers/net/wireless/ipw2200.c             |    2 +
 drivers/net/wireless/p54common.c           |    1 +
 drivers/net/wireless/rtl8187_dev.c         |    1 +
 include/linux/wireless.h                   |   13 +++++++
 include/net/mac80211.h                     |    3 ++
 net/mac80211/ieee80211_ioctl.c             |    2 +
 net/mac80211/rx.c                          |   48 ++++++++++++++++++---------
 10 files changed, 59 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/b43/xmit.c
index 0bd6f8a..77b3690 100644
--- a/drivers/net/wireless/b43/xmit.c
+++ b/drivers/net/wireless/b43/xmit.c
@@ -526,6 +526,7 @@ void b43_rx(struct b43_wldev *dev, struct sk_buff *skb, const void *_rxhdr)
 		status.rate = b43_plcp_get_bitrate_cck(plcp);
 	status.antenna = !!(phystat0 & B43_RX_PHYST0_ANT);
 	status.mactime = mactime;
+	status.flag |= RX_FLAG_TSFT;
 
 	chanid = (chanstat & B43_RX_CHAN_ID) >> B43_RX_CHAN_ID_SHIFT;
 	switch (chanstat & B43_RX_CHAN_PHYTYPE) {
diff --git a/drivers/net/wireless/b43legacy/xmit.c b/drivers/net/wireless/b43legacy/xmit.c
index fa1e656..b71cc94 100644
--- a/drivers/net/wireless/b43legacy/xmit.c
+++ b/drivers/net/wireless/b43legacy/xmit.c
@@ -532,6 +532,7 @@ void b43legacy_rx(struct b43legacy_wldev *dev,
 		status.rate = b43legacy_plcp_get_bitrate_cck(plcp);
 	status.antenna = !!(phystat0 & B43legacy_RX_PHYST0_ANT);
 	status.mactime = mactime;
+	status.flag |= RX_FLAG_TSFT;
 
 	chanid = (chanstat & B43legacy_RX_CHAN_ID) >>
 		  B43legacy_RX_CHAN_ID_SHIFT;
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index d8f5efc..3a57d48 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -1089,6 +1089,9 @@ static int prism2_ioctl_giwrange(struct net_device *dev,
 	range->enc_capa = IW_ENC_CAPA_WPA | IW_ENC_CAPA_WPA2 |
 		IW_ENC_CAPA_CIPHER_TKIP | IW_ENC_CAPA_CIPHER_CCMP;
 
+	if (local->sta_fw_ver >= PRISM2_FW_VER(1,3,1))
+		range->scan_capa = IW_SCAN_CAPA_ESSID;
+
 	return 0;
 }
 
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 54f44e5..e30ad24 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -8901,6 +8901,8 @@ static int ipw_wx_get_range(struct net_device *dev,
 	range->enc_capa = IW_ENC_CAPA_WPA | IW_ENC_CAPA_WPA2 |
 		IW_ENC_CAPA_CIPHER_TKIP | IW_ENC_CAPA_CIPHER_CCMP;
 
+	range->scan_capa = IW_SCAN_CAPA_ESSID | IW_SCAN_CAPA_TYPE;
+
 	IPW_DEBUG_WX("GET Range\n");
 	return 0;
 }
diff --git a/drivers/net/wireless/p54common.c b/drivers/net/wireless/p54common.c
index 1437db0..5f8d898 100644
--- a/drivers/net/wireless/p54common.c
+++ b/drivers/net/wireless/p54common.c
@@ -314,6 +314,7 @@ static void p54_rx_data(struct ieee80211_hw *dev, struct sk_buff *skb)
 	rx_status.phymode = MODE_IEEE80211G;
 	rx_status.antenna = hdr->antenna;
 	rx_status.mactime = le64_to_cpu(hdr->timestamp);
+	rx_status.flag |= RX_FLAG_TSFT;
 
 	skb_pull(skb, sizeof(*hdr));
 	skb_trim(skb, le16_to_cpu(hdr->len));
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index e454ae8..b23191f 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -225,6 +225,7 @@ static void rtl8187_rx_cb(struct urb *urb)
 	rx_status.channel = dev->conf.channel;
 	rx_status.phymode = dev->conf.phymode;
 	rx_status.mactime = le64_to_cpu(hdr->mac_time);
+	rx_status.flag |= RX_FLAG_TSFT;
 	if (flags & (1 << 13))
 		rx_status.flag |= RX_FLAG_FAILED_FCS_CRC;
 	ieee80211_rx_irqsafe(dev, skb, &rx_status);
diff --git a/include/linux/wireless.h b/include/linux/wireless.h
index 0987aa7..74e84ca 100644
--- a/include/linux/wireless.h
+++ b/include/linux/wireless.h
@@ -541,6 +541,16 @@
 /* Maximum size of returned data */
 #define IW_SCAN_MAX_DATA	4096	/* In bytes */
 
+/* Scan capability flags - in (struct iw_range *)->scan_capa */
+#define IW_SCAN_CAPA_NONE		0x00
+#define IW_SCAN_CAPA_ESSID		0x01
+#define IW_SCAN_CAPA_BSSID		0x02
+#define IW_SCAN_CAPA_CHANNEL	0x04
+#define IW_SCAN_CAPA_MODE		0x08
+#define IW_SCAN_CAPA_RATE		0x10
+#define IW_SCAN_CAPA_TYPE		0x20
+#define IW_SCAN_CAPA_TIME		0x40
+
 /* Max number of char in custom event - use multiple of them if needed */
 #define IW_CUSTOM_MAX		256	/* In bytes */
 
@@ -963,6 +973,9 @@ struct	iw_range
 	__u16		old_num_channels;
 	__u8		old_num_frequency;
 
+	/* Scan capabilities */
+	__u8		scan_capa; 	/* IW_SCAN_CAPA_* bit field */
+
 	/* Wireless event capability bitmasks */
 	__u32		event_capa[6];
 
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 0d67b33..3bd970f 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -350,6 +350,8 @@ struct ieee80211_tx_control {
  *	the frame.
  * @RX_FLAG_FAILED_PLCP_CRC: Set this flag if the PCLP check failed on
  *	the frame.
+ * @RX_FLAG_TSFT: The timestamp passed in the RX status (@mactime field)
+ *	is valid.
  */
 enum mac80211_rx_flags {
 	RX_FLAG_MMIC_ERROR	= 1<<0,
@@ -359,6 +361,7 @@ enum mac80211_rx_flags {
 	RX_FLAG_IV_STRIPPED	= 1<<4,
 	RX_FLAG_FAILED_FCS_CRC	= 1<<5,
 	RX_FLAG_FAILED_PLCP_CRC = 1<<6,
+	RX_FLAG_TSFT		= 1<<7,
 };
 
 /**
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 646e2f2..0c52ed8 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -218,6 +218,8 @@ static int ieee80211_ioctl_giwrange(struct net_device *dev,
 	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWAP);
 	IW_EVENT_CAPA_SET(range->event_capa, SIOCGIWSCAN);
 
+	range->scan_capa |= IW_SCAN_CAPA_ESSID;
+
 	return 0;
 }
 
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index c6a6177..b12d019 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -79,8 +79,9 @@ ieee80211_rx_monitor(struct ieee80211_local *local, struct sk_buff *origskb,
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_rate *rate;
 	int needed_headroom = 0;
-	struct ieee80211_rtap_hdr {
-		struct ieee80211_radiotap_header hdr;
+	struct ieee80211_radiotap_header *rthdr;
+	__le64 *rttsft = NULL;
+	struct ieee80211_rtap_fixed_data {
 		u8 flags;
 		u8 rate;
 		__le16 chan_freq;
@@ -88,7 +89,7 @@ ieee80211_rx_monitor(struct ieee80211_local *local, struct sk_buff *origskb,
 		u8 antsignal;
 		u8 padding_for_rxflags;
 		__le16 rx_flags;
-	} __attribute__ ((packed)) *rthdr;
+	} __attribute__ ((packed)) *rtfixed;
 	struct sk_buff *skb, *skb2;
 	struct net_device *prev_dev = NULL;
 	int present_fcs_len = 0;
@@ -105,7 +106,8 @@ ieee80211_rx_monitor(struct ieee80211_local *local, struct sk_buff *origskb,
 	if (status->flag & RX_FLAG_RADIOTAP)
 		rtap_len = ieee80211_get_radiotap_len(origskb->data);
 	else
-		needed_headroom = sizeof(*rthdr);
+		/* room for radiotap header, always present fields and TSFT */
+		needed_headroom = sizeof(*rthdr) + sizeof(*rtfixed) + 8;
 
 	if (local->hw.flags & IEEE80211_HW_RX_INCLUDES_FCS)
 		present_fcs_len = FCS_LEN;
@@ -133,7 +135,7 @@ ieee80211_rx_monitor(struct ieee80211_local *local, struct sk_buff *origskb,
 		 * them allocate enough headroom to start with.
 		 */
 		if (skb_headroom(skb) < needed_headroom &&
-		    pskb_expand_head(skb, sizeof(*rthdr), 0, GFP_ATOMIC)) {
+		    pskb_expand_head(skb, needed_headroom, 0, GFP_ATOMIC)) {
 			dev_kfree_skb(skb);
 			return NULL;
 		}
@@ -152,42 +154,56 @@ ieee80211_rx_monitor(struct ieee80211_local *local, struct sk_buff *origskb,
 
 	/* if necessary, prepend radiotap information */
 	if (!(status->flag & RX_FLAG_RADIOTAP)) {
+		rtfixed = (void *) skb_push(skb, sizeof(*rtfixed));
+		rtap_len = sizeof(*rthdr) + sizeof(*rtfixed);
+		if (status->flag & RX_FLAG_TSFT) {
+			rttsft = (void *) skb_push(skb, sizeof(*rttsft));
+			rtap_len += 8;
+		}
 		rthdr = (void *) skb_push(skb, sizeof(*rthdr));
 		memset(rthdr, 0, sizeof(*rthdr));
-		rthdr->hdr.it_len = cpu_to_le16(sizeof(*rthdr));
-		rthdr->hdr.it_present =
+		memset(rtfixed, 0, sizeof(*rtfixed));
+		rthdr->it_present =
 			cpu_to_le32((1 << IEEE80211_RADIOTAP_FLAGS) |
 				    (1 << IEEE80211_RADIOTAP_RATE) |
 				    (1 << IEEE80211_RADIOTAP_CHANNEL) |
 				    (1 << IEEE80211_RADIOTAP_DB_ANTSIGNAL) |
 				    (1 << IEEE80211_RADIOTAP_RX_FLAGS));
-		rthdr->flags = local->hw.flags & IEEE80211_HW_RX_INCLUDES_FCS ?
-			       IEEE80211_RADIOTAP_F_FCS : 0;
+		rtfixed->flags = 0;
+		if (local->hw.flags & IEEE80211_HW_RX_INCLUDES_FCS)
+			rtfixed->flags |= IEEE80211_RADIOTAP_F_FCS;
+
+		if (rttsft) {
+			*rttsft = cpu_to_le64(status->mactime);
+			rthdr->it_present |=
+				cpu_to_le32(1 << IEEE80211_RADIOTAP_TSFT);
+		}
 
 		/* FIXME: when radiotap gets a 'bad PLCP' flag use it here */
-		rthdr->rx_flags = 0;
+		rtfixed->rx_flags = 0;
 		if (status->flag &
 		    (RX_FLAG_FAILED_FCS_CRC | RX_FLAG_FAILED_PLCP_CRC))
-			rthdr->rx_flags |=
+			rtfixed->rx_flags |=
 				cpu_to_le16(IEEE80211_RADIOTAP_F_RX_BADFCS);
 
 		rate = ieee80211_get_rate(local, status->phymode,
 					  status->rate);
 		if (rate)
-			rthdr->rate = rate->rate / 5;
+			rtfixed->rate = rate->rate / 5;
 
-		rthdr->chan_freq = cpu_to_le16(status->freq);
+		rtfixed->chan_freq = cpu_to_le16(status->freq);
 
 		if (status->phymode == MODE_IEEE80211A)
-			rthdr->chan_flags =
+			rtfixed->chan_flags =
 				cpu_to_le16(IEEE80211_CHAN_OFDM |
 					    IEEE80211_CHAN_5GHZ);
 		else
-			rthdr->chan_flags =
+			rtfixed->chan_flags =
 				cpu_to_le16(IEEE80211_CHAN_DYN |
 					    IEEE80211_CHAN_2GHZ);
 
-		rthdr->antsignal = status->ssi;
+		rtfixed->antsignal = status->ssi;
+		rthdr->it_len = cpu_to_le16(rtap_len);
 	}
 
 	skb_set_mac_header(skb, 0);
-- 
John W. Linville
linville@tuxdriver.com
