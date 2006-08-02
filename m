From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Wed, 2 Aug 2006 17:56:30 -0400
Message-ID: <20060802215625.GA5084@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:20233 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932250AbWHBV4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 17:56:51 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 49b1e3ea19b1c95c2f012b8331ffb3b169e4c042:
  Linus Torvalds:
        Merge branch 'merge' of git://git.kernel.org/.../paulus/powerpc

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Daniel Drake:
      zd1211rw: Pass more management frame types up to host
      zd1211rw: Fix software encryption/decryption
      zd1211rw: Remove bogus assert

Ulrich Kunitz:
      zd1211rw: Fixes radiotap header
      zd1211rw: Fixed endianess issue with length info tag detection
      zd1211rw: Packet filter fix for managed (STA) mode

 drivers/net/wireless/zd1211rw/zd_chip.c |    4 ++--
 drivers/net/wireless/zd1211rw/zd_chip.h |   10 ++++++----
 drivers/net/wireless/zd1211rw/zd_mac.c  |   16 ++++++++--------
 drivers/net/wireless/zd1211rw/zd_usb.c  |    7 +++----
 4 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index efc9c4b..da9d06b 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -797,7 +797,7 @@ static int zd1211_hw_init_hmac(struct zd
 		{ CR_ADDA_MBIAS_WARMTIME,	0x30000808 },
 		{ CR_ZD1211_RETRY_MAX,		0x2 },
 		{ CR_SNIFFER_ON,		0 },
-		{ CR_RX_FILTER,			AP_RX_FILTER },
+		{ CR_RX_FILTER,			STA_RX_FILTER },
 		{ CR_GROUP_HASH_P1,		0x00 },
 		{ CR_GROUP_HASH_P2,		0x80000000 },
 		{ CR_REG1,			0xa4 },
@@ -844,7 +844,7 @@ static int zd1211b_hw_init_hmac(struct z
 		{ CR_ZD1211B_AIFS_CTL2,		0x008C003C },
 		{ CR_ZD1211B_TXOP,		0x01800824 },
 		{ CR_SNIFFER_ON,		0 },
-		{ CR_RX_FILTER,			AP_RX_FILTER },
+		{ CR_RX_FILTER,			STA_RX_FILTER },
 		{ CR_GROUP_HASH_P1,		0x00 },
 		{ CR_GROUP_HASH_P2,		0x80000000 },
 		{ CR_REG1,			0xa4 },
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index 8051210..069d2b4 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -461,10 +461,15 @@ #define CR_UNDERRUN_CNT			CTL_REG(0x0688
 
 #define CR_RX_FILTER			CTL_REG(0x068c)
 #define RX_FILTER_ASSOC_RESPONSE	0x0002
+#define RX_FILTER_REASSOC_RESPONSE	0x0008
 #define RX_FILTER_PROBE_RESPONSE	0x0020
 #define RX_FILTER_BEACON		0x0100
+#define RX_FILTER_DISASSOC		0x0400
 #define RX_FILTER_AUTH			0x0800
-/* Sniff modus sets filter to 0xfffff */
+#define AP_RX_FILTER			0x0400feff
+#define STA_RX_FILTER			0x0000ffff
+
+/* Monitor mode sets filter to 0xfffff */
 
 #define CR_ACK_TIMEOUT_EXT		CTL_REG(0x0690)
 #define CR_BCN_FIFO_SEMAPHORE		CTL_REG(0x0694)
@@ -546,9 +551,6 @@ #define CR_ZD1211B_AIFS_CTL2		CTL_REG(0x
 #define CR_ZD1211B_TXOP			CTL_REG(0x0b20)
 #define CR_ZD1211B_RETRY_MAX		CTL_REG(0x0b28)
 
-#define AP_RX_FILTER			0x0400feff
-#define STA_RX_FILTER			0x0000ffff
-
 #define CWIN_SIZE			0x007f043f
 
 
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 3bdc54d..d6f3e02 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -108,7 +108,9 @@ int zd_mac_init_hw(struct zd_mac *mac, u
 	if (r)
 		goto disable_int;
 
-	r = zd_set_encryption_type(chip, NO_WEP);
+	/* We must inform the device that we are doing encryption/decryption in
+	 * software at the moment. */
+	r = zd_set_encryption_type(chip, ENC_SNIFFER);
 	if (r)
 		goto disable_int;
 
@@ -136,10 +138,8 @@ static int reset_mode(struct zd_mac *mac
 {
 	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 	struct zd_ioreq32 ioreqs[3] = {
-		{ CR_RX_FILTER, RX_FILTER_BEACON|RX_FILTER_PROBE_RESPONSE|
-			        RX_FILTER_AUTH|RX_FILTER_ASSOC_RESPONSE },
+		{ CR_RX_FILTER, STA_RX_FILTER },
 		{ CR_SNIFFER_ON, 0U },
-		{ CR_ENCRYPTION_TYPE, NO_WEP },
 	};
 
 	if (ieee->iw_mode == IW_MODE_MONITOR) {
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
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 72f9052..6320984 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -323,7 +323,6 @@ static void disable_read_regs_int(struct
 {
 	struct zd_usb_interrupt *intr = &usb->intr;
 
-	ZD_ASSERT(in_interrupt());
 	spin_lock(&intr->lock);
 	intr->read_regs_enabled = 0;
 	spin_unlock(&intr->lock);
@@ -545,11 +544,11 @@ static void handle_rx_packet(struct zd_u
 	 * be padded. Unaligned access might also happen if the length_info
 	 * structure is not present.
 	 */
-	if (get_unaligned(&length_info->tag) == RX_LENGTH_INFO_TAG) {
+	if (get_unaligned(&length_info->tag) == cpu_to_le16(RX_LENGTH_INFO_TAG))
+	{
 		unsigned int l, k, n;
 		for (i = 0, l = 0;; i++) {
-			k = le16_to_cpu(get_unaligned(
-				&length_info->length[i]));
+			k = le16_to_cpu(get_unaligned(&length_info->length[i]));
 			n = l+k;
 			if (n > length)
 				return;
-- 
John W. Linville
linville@tuxdriver.com
