From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Tue, 8 Jan 2008 00:15:23 -0500
Message-ID: <20080108051523.GB3125@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2376 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756639AbYAHFuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 00:50:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

One more fix for 2.6.24.  Without this b43 passes the wrong channel
number and frequency to mac80211 for received frames.  The patch
is a little big, but it is mostly some definitions related to other
definitions used in the fix itself.

Let me know if this is a problem!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-jgarzik

---

The following changes since commit 3ce54450461bad18bbe1f9f5aa3ecd2f8e8d1235:
  Linus Torvalds (1):
        Linux 2.6.24-rc7

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Michael Buesch (1):
      b43: Fix rxheader channel parsing

 drivers/net/wireless/b43/b43.h  |    2 +
 drivers/net/wireless/b43/main.h |   20 ++---------
 drivers/net/wireless/b43/xmit.c |   27 +++++++++++-----
 drivers/net/wireless/b43/xmit.h |   65 +++++++++++++++++++++-----------------
 4 files changed, 61 insertions(+), 53 deletions(-)

diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index a28ad23..7b6fc1a 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -273,6 +273,8 @@ enum {
 #define B43_PHYTYPE_A			0x00
 #define B43_PHYTYPE_B			0x01
 #define B43_PHYTYPE_G			0x02
+#define B43_PHYTYPE_N			0x04
+#define B43_PHYTYPE_LP			0x05
 
 /* PHYRegisters */
 #define B43_PHY_ILT_A_CTRL		0x0072
diff --git a/drivers/net/wireless/b43/main.h b/drivers/net/wireless/b43/main.h
index 284d17d..08e2e56 100644
--- a/drivers/net/wireless/b43/main.h
+++ b/drivers/net/wireless/b43/main.h
@@ -39,11 +39,11 @@
 #define PAD_BYTES(nr_bytes)		P4D_BYTES( __LINE__ , (nr_bytes))
 
 /* Lightweight function to convert a frequency (in Mhz) to a channel number. */
-static inline u8 b43_freq_to_channel_a(int freq)
+static inline u8 b43_freq_to_channel_5ghz(int freq)
 {
 	return ((freq - 5000) / 5);
 }
-static inline u8 b43_freq_to_channel_bg(int freq)
+static inline u8 b43_freq_to_channel_2ghz(int freq)
 {
 	u8 channel;
 
@@ -54,19 +54,13 @@ static inline u8 b43_freq_to_channel_bg(int freq)
 
 	return channel;
 }
-static inline u8 b43_freq_to_channel(struct b43_wldev *dev, int freq)
-{
-	if (dev->phy.type == B43_PHYTYPE_A)
-		return b43_freq_to_channel_a(freq);
-	return b43_freq_to_channel_bg(freq);
-}
 
 /* Lightweight function to convert a channel number to a frequency (in Mhz). */
-static inline int b43_channel_to_freq_a(u8 channel)
+static inline int b43_channel_to_freq_5ghz(u8 channel)
 {
 	return (5000 + (5 * channel));
 }
-static inline int b43_channel_to_freq_bg(u8 channel)
+static inline int b43_channel_to_freq_2ghz(u8 channel)
 {
 	int freq;
 
@@ -77,12 +71,6 @@ static inline int b43_channel_to_freq_bg(u8 channel)
 
 	return freq;
 }
-static inline int b43_channel_to_freq(struct b43_wldev *dev, u8 channel)
-{
-	if (dev->phy.type == B43_PHYTYPE_A)
-		return b43_channel_to_freq_a(channel);
-	return b43_channel_to_freq_bg(channel);
-}
 
 static inline int b43_is_cck_rate(int rate)
 {
diff --git a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/b43/xmit.c
index 0bd6f8a..3307ba1 100644
--- a/drivers/net/wireless/b43/xmit.c
+++ b/drivers/net/wireless/b43/xmit.c
@@ -531,21 +531,32 @@ void b43_rx(struct b43_wldev *dev, struct sk_buff *skb, const void *_rxhdr)
 	switch (chanstat & B43_RX_CHAN_PHYTYPE) {
 	case B43_PHYTYPE_A:
 		status.phymode = MODE_IEEE80211A;
-		status.freq = chanid;
-		status.channel = b43_freq_to_channel_a(chanid);
-		break;
-	case B43_PHYTYPE_B:
-		status.phymode = MODE_IEEE80211B;
-		status.freq = chanid + 2400;
-		status.channel = b43_freq_to_channel_bg(chanid + 2400);
+		B43_WARN_ON(1);
+		/* FIXME: We don't really know which value the "chanid" contains.
+		 *        So the following assignment might be wrong. */
+		status.channel = chanid;
+		status.freq = b43_channel_to_freq_5ghz(status.channel);
 		break;
 	case B43_PHYTYPE_G:
 		status.phymode = MODE_IEEE80211G;
+		/* chanid is the radio channel cookie value as used
+		 * to tune the radio. */
 		status.freq = chanid + 2400;
-		status.channel = b43_freq_to_channel_bg(chanid + 2400);
+		status.channel = b43_freq_to_channel_2ghz(status.freq);
+		break;
+	case B43_PHYTYPE_N:
+		status.phymode = 0xDEAD /*FIXME MODE_IEEE80211N*/;
+		/* chanid is the SHM channel cookie. Which is the plain
+		 * channel number in b43. */
+		status.channel = chanid;
+		if (chanstat & B43_RX_CHAN_5GHZ)
+			status.freq = b43_freq_to_channel_5ghz(status.freq);
+		else
+			status.freq = b43_freq_to_channel_2ghz(status.freq);
 		break;
 	default:
 		B43_WARN_ON(1);
+		goto drop;
 	}
 
 	dev->stats.last_rx = jiffies;
diff --git a/drivers/net/wireless/b43/xmit.h b/drivers/net/wireless/b43/xmit.h
index 03bddd2..6dc0793 100644
--- a/drivers/net/wireless/b43/xmit.h
+++ b/drivers/net/wireless/b43/xmit.h
@@ -142,49 +142,56 @@ struct b43_rxhdr_fw4 {
 } __attribute__ ((__packed__));
 
 /* PHY RX Status 0 */
-#define B43_RX_PHYST0_GAINCTL	0x4000	/* Gain Control */
-#define B43_RX_PHYST0_PLCPHCF	0x0200
-#define B43_RX_PHYST0_PLCPFV	0x0100
-#define B43_RX_PHYST0_SHORTPRMBL	0x0080	/* Received with Short Preamble */
+#define B43_RX_PHYST0_GAINCTL		0x4000 /* Gain Control */
+#define B43_RX_PHYST0_PLCPHCF		0x0200
+#define B43_RX_PHYST0_PLCPFV		0x0100
+#define B43_RX_PHYST0_SHORTPRMBL	0x0080 /* Received with Short Preamble */
 #define B43_RX_PHYST0_LCRS		0x0040
-#define B43_RX_PHYST0_ANT		0x0020	/* Antenna */
-#define B43_RX_PHYST0_UNSRATE	0x0010
+#define B43_RX_PHYST0_ANT		0x0020 /* Antenna */
+#define B43_RX_PHYST0_UNSRATE		0x0010
 #define B43_RX_PHYST0_CLIP		0x000C
 #define B43_RX_PHYST0_CLIP_SHIFT	2
-#define B43_RX_PHYST0_FTYPE		0x0003	/* Frame type */
-#define  B43_RX_PHYST0_CCK		0x0000	/* Frame type: CCK */
-#define  B43_RX_PHYST0_OFDM		0x0001	/* Frame type: OFDM */
-#define  B43_RX_PHYST0_PRE_N	0x0002	/* Pre-standard N-PHY frame */
-#define  B43_RX_PHYST0_STD_N	0x0003	/* Standard N-PHY frame */
+#define B43_RX_PHYST0_FTYPE		0x0003 /* Frame type */
+#define  B43_RX_PHYST0_CCK		0x0000 /* Frame type: CCK */
+#define  B43_RX_PHYST0_OFDM		0x0001 /* Frame type: OFDM */
+#define  B43_RX_PHYST0_PRE_N		0x0002 /* Pre-standard N-PHY frame */
+#define  B43_RX_PHYST0_STD_N		0x0003 /* Standard N-PHY frame */
 
 /* PHY RX Status 2 */
-#define B43_RX_PHYST2_LNAG		0xC000	/* LNA Gain */
+#define B43_RX_PHYST2_LNAG		0xC000 /* LNA Gain */
 #define B43_RX_PHYST2_LNAG_SHIFT	14
-#define B43_RX_PHYST2_PNAG		0x3C00	/* PNA Gain */
+#define B43_RX_PHYST2_PNAG		0x3C00 /* PNA Gain */
 #define B43_RX_PHYST2_PNAG_SHIFT	10
-#define B43_RX_PHYST2_FOFF		0x03FF	/* F offset */
+#define B43_RX_PHYST2_FOFF		0x03FF /* F offset */
 
 /* PHY RX Status 3 */
-#define B43_RX_PHYST3_DIGG		0x1800	/* DIG Gain */
+#define B43_RX_PHYST3_DIGG		0x1800 /* DIG Gain */
 #define B43_RX_PHYST3_DIGG_SHIFT	11
-#define B43_RX_PHYST3_TRSTATE	0x0400	/* TR state */
+#define B43_RX_PHYST3_TRSTATE		0x0400 /* TR state */
 
 /* MAC RX Status */
-#define B43_RX_MAC_BEACONSENT	0x00008000	/* Beacon send flag */
-#define B43_RX_MAC_KEYIDX		0x000007E0	/* Key index */
-#define B43_RX_MAC_KEYIDX_SHIFT	5
-#define B43_RX_MAC_DECERR		0x00000010	/* Decrypt error */
-#define B43_RX_MAC_DEC		0x00000008	/* Decryption attempted */
-#define B43_RX_MAC_PADDING		0x00000004	/* Pad bytes present */
-#define B43_RX_MAC_RESP		0x00000002	/* Response frame transmitted */
-#define B43_RX_MAC_FCSERR		0x00000001	/* FCS error */
+#define B43_RX_MAC_RXST_VALID		0x01000000 /* PHY RXST valid */
+#define B43_RX_MAC_TKIP_MICERR		0x00100000 /* TKIP MIC error */
+#define B43_RX_MAC_TKIP_MICATT		0x00080000 /* TKIP MIC attempted */
+#define B43_RX_MAC_AGGTYPE		0x00060000 /* Aggregation type */
+#define B43_RX_MAC_AGGTYPE_SHIFT	17
+#define B43_RX_MAC_AMSDU		0x00010000 /* A-MSDU mask */
+#define B43_RX_MAC_BEACONSENT		0x00008000 /* Beacon sent flag */
+#define B43_RX_MAC_KEYIDX		0x000007E0 /* Key index */
+#define B43_RX_MAC_KEYIDX_SHIFT		5
+#define B43_RX_MAC_DECERR		0x00000010 /* Decrypt error */
+#define B43_RX_MAC_DEC			0x00000008 /* Decryption attempted */
+#define B43_RX_MAC_PADDING		0x00000004 /* Pad bytes present */
+#define B43_RX_MAC_RESP			0x00000002 /* Response frame transmitted */
+#define B43_RX_MAC_FCSERR		0x00000001 /* FCS error */
 
 /* RX channel */
-#define B43_RX_CHAN_GAIN		0xFC00	/* Gain */
-#define B43_RX_CHAN_GAIN_SHIFT	10
-#define B43_RX_CHAN_ID		0x03FC	/* Channel ID */
-#define B43_RX_CHAN_ID_SHIFT	2
-#define B43_RX_CHAN_PHYTYPE		0x0003	/* PHY type */
+#define B43_RX_CHAN_40MHZ		0x1000 /* 40 Mhz channel width */
+#define B43_RX_CHAN_5GHZ		0x0800 /* 5 Ghz band */
+#define B43_RX_CHAN_ID			0x07F8 /* Channel ID */
+#define B43_RX_CHAN_ID_SHIFT		3
+#define B43_RX_CHAN_PHYTYPE		0x0007 /* PHY type */
+
 
 u8 b43_plcp_get_ratecode_cck(const u8 bitrate);
 u8 b43_plcp_get_ratecode_ofdm(const u8 bitrate);
-- 
John W. Linville
linville@tuxdriver.com
