From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull from 'upstream-fixes' branch of wireless-2.6
Date: Tue, 28 Nov 2006 14:40:21 -0500
Message-ID: <20061128194016.GE16533@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:9994 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S936069AbWK1Tkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 14:40:45 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 0579e303553655245e8a6616bd8b4428b07d63a2:
  Linus Torvalds:
        Merge branch 'for-linus' of git://git.kernel.org/.../drzeus/mmc

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

John W. Linville:
      Revert "zd1211rw: Removed unneeded packed attributes"

Michael Buesch:
      softmac: remove netif_tx_disable when scanning

Ulrich Kunitz:
      zd1211rw: Fix of a locking bug

Zhu Yi:
      ieee80211: Fix kernel panic when QoS is enabled

 drivers/net/wireless/zd1211rw/zd_ieee80211.h  |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c        |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.h        |    4 ++--
 drivers/net/wireless/zd1211rw/zd_usb.c        |   26 +++++++++++++------------
 drivers/net/wireless/zd1211rw/zd_usb.h        |   14 +++++++------
 net/ieee80211/ieee80211_tx.c                  |    4 ++--
 net/ieee80211/softmac/ieee80211softmac_scan.c |    2 --
 7 files changed, 26 insertions(+), 28 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_ieee80211.h b/drivers/net/wireless/zd1211rw/zd_ieee80211.h
index f63245b..3632989 100644
--- a/drivers/net/wireless/zd1211rw/zd_ieee80211.h
+++ b/drivers/net/wireless/zd1211rw/zd_ieee80211.h
@@ -64,7 +64,7 @@ struct cck_plcp_header {
 	u8 service;
 	__le16 length;
 	__le16 crc16;
-};
+} __attribute__((packed));
 
 static inline u8 zd_cck_plcp_header_rate(const struct cck_plcp_header *header)
 {
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index a7d29bd..e5fedf9 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -721,7 +721,7 @@ struct zd_rt_hdr {
 	u8  rt_rate;
 	u16 rt_channel;
 	u16 rt_chbitmask;
-};
+} __attribute__((packed));
 
 static void fill_rt_header(void *buffer, struct zd_mac *mac,
 	                   const struct ieee80211_rx_stats *stats,
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.h b/drivers/net/wireless/zd1211rw/zd_mac.h
index b8ea3de..e4dd40a 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -82,7 +82,7 @@ #define ZD_PLCP_HEADER_SIZE		5
 struct rx_length_info {
 	__le16 length[3];
 	__le16 tag;
-};
+} __attribute__((packed));
 
 #define RX_LENGTH_INFO_TAG		0x697e
 
@@ -93,7 +93,7 @@ struct rx_status {
 	u8 signal_quality_ofdm;
 	u8 decryption_type;
 	u8 frame_status;
-};
+} __attribute__((packed));
 
 /* rx_status field decryption_type */
 #define ZD_RX_NO_WEP	0
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 3faaeb2..a15b095 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -366,15 +366,6 @@ error:
 	return r;
 }
 
-static void disable_read_regs_int(struct zd_usb *usb)
-{
-	struct zd_usb_interrupt *intr = &usb->intr;
-
-	spin_lock(&intr->lock);
-	intr->read_regs_enabled = 0;
-	spin_unlock(&intr->lock);
-}
-
 #define urb_dev(urb) (&(urb)->dev->dev)
 
 static inline void handle_regs_int(struct urb *urb)
@@ -1156,10 +1147,19 @@ static void prepare_read_regs_int(struct
 {
 	struct zd_usb_interrupt *intr = &usb->intr;
 
-	spin_lock(&intr->lock);
+	spin_lock_irq(&intr->lock);
 	intr->read_regs_enabled = 1;
 	INIT_COMPLETION(intr->read_regs.completion);
-	spin_unlock(&intr->lock);
+	spin_unlock_irq(&intr->lock);
+}
+
+static void disable_read_regs_int(struct zd_usb *usb)
+{
+	struct zd_usb_interrupt *intr = &usb->intr;
+
+	spin_lock_irq(&intr->lock);
+	intr->read_regs_enabled = 0;
+	spin_unlock_irq(&intr->lock);
 }
 
 static int get_results(struct zd_usb *usb, u16 *values,
@@ -1171,7 +1171,7 @@ static int get_results(struct zd_usb *us
 	struct read_regs_int *rr = &intr->read_regs;
 	struct usb_int_regs *regs = (struct usb_int_regs *)rr->buffer;
 
-	spin_lock(&intr->lock);
+	spin_lock_irq(&intr->lock);
 
 	r = -EIO;
 	/* The created block size seems to be larger than expected.
@@ -1204,7 +1204,7 @@ static int get_results(struct zd_usb *us
 
 	r = 0;
 error_unlock:
-	spin_unlock(&intr->lock);
+	spin_unlock_irq(&intr->lock);
 	return r;
 }
 
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.h b/drivers/net/wireless/zd1211rw/zd_usb.h
index e81a2d3..317d37c 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -74,17 +74,17 @@ enum control_requests {
 struct usb_req_read_regs {
 	__le16 id;
 	__le16 addr[0];
-};
+} __attribute__((packed));
 
 struct reg_data {
 	__le16 addr;
 	__le16 value;
-};
+} __attribute__((packed));
 
 struct usb_req_write_regs {
 	__le16 id;
 	struct reg_data reg_writes[0];
-};
+} __attribute__((packed));
 
 enum {
 	RF_IF_LE = 0x02,
@@ -101,7 +101,7 @@ struct usb_req_rfwrite {
 	/* RF2595: 24 */
 	__le16 bit_values[0];
 	/* (CR203 & ~(RF_IF_LE | RF_CLK | RF_DATA)) | (bit ? RF_DATA : 0) */
-};
+} __attribute__((packed));
 
 /* USB interrupt */
 
@@ -118,12 +118,12 @@ enum usb_int_flags {
 struct usb_int_header {
 	u8 type;	/* must always be 1 */
 	u8 id;
-};
+} __attribute__((packed));
 
 struct usb_int_regs {
 	struct usb_int_header hdr;
 	struct reg_data regs[0];
-};
+} __attribute__((packed));
 
 struct usb_int_retry_fail {
 	struct usb_int_header hdr;
@@ -131,7 +131,7 @@ struct usb_int_retry_fail {
 	u8 _dummy;
 	u8 addr[ETH_ALEN];
 	u8 ibss_wakeup_dest;
-};
+} __attribute__((packed));
 
 struct read_regs_int {
 	struct completion completion;
diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index ae25449..854fc13 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -390,7 +390,7 @@ int ieee80211_xmit(struct sk_buff *skb, 
 		 * this stack is providing the full 802.11 header, one will
 		 * eventually be affixed to this fragment -- so we must account
 		 * for it when determining the amount of payload space. */
-		bytes_per_frag = frag_size - IEEE80211_3ADDR_LEN;
+		bytes_per_frag = frag_size - hdr_len;
 		if (ieee->config &
 		    (CFG_IEEE80211_COMPUTE_FCS | CFG_IEEE80211_RESERVE_FCS))
 			bytes_per_frag -= IEEE80211_FCS_LEN;
@@ -412,7 +412,7 @@ int ieee80211_xmit(struct sk_buff *skb, 
 	} else {
 		nr_frags = 1;
 		bytes_per_frag = bytes_last_frag = bytes;
-		frag_size = bytes + IEEE80211_3ADDR_LEN;
+		frag_size = bytes + hdr_len;
 	}
 
 	rts_required = (frag_size > ieee->rts
diff --git a/net/ieee80211/softmac/ieee80211softmac_scan.c b/net/ieee80211/softmac/ieee80211softmac_scan.c
index d31cf77..ad67368 100644
--- a/net/ieee80211/softmac/ieee80211softmac_scan.c
+++ b/net/ieee80211/softmac/ieee80211softmac_scan.c
@@ -47,7 +47,6 @@ ieee80211softmac_start_scan(struct ieee8
 	sm->scanning = 1;
 	spin_unlock_irqrestore(&sm->lock, flags);
 
-	netif_tx_disable(sm->ieee->dev);
 	ret = sm->start_scan(sm->dev);
 	if (ret) {
 		spin_lock_irqsave(&sm->lock, flags);
@@ -248,7 +247,6 @@ void ieee80211softmac_scan_finished(stru
 		if (net)
 			sm->set_channel(sm->dev, net->channel);
 	}
-	netif_wake_queue(sm->ieee->dev);
 	ieee80211softmac_call_events(sm, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, NULL);
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_scan_finished);
-- 
John W. Linville
linville@tuxdriver.com
