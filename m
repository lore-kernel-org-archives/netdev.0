From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6 (use this one)
Date: Thu, 10 Jan 2008 16:30:34 -0500
Message-ID: <20080110213034.GI3109@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[2nd try -- turns-out the Mattis Nissler patch needed an extra tweak.
It will probably also cause build breakage when you rebase since
rt2x00lib_txdone(...) becomes rt2x00pci_txdone(rt2x00dev,...) in 2.6.25,
so FYI... :-)

This also includes another patch (the "4 byte boundary" one) which
is already in your upstream branch.  So, beware of that one too. :-)]

Jeff,

Three more fixes for 2.6.24.  The one from Mattias Nissler is already
in your upstream tree...FYI.

Let me know if there are problems!

Thanks,

John

---

Individual patches available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-jgarzik/

---

The following changes since commit 3ce54450461bad18bbe1f9f5aa3ecd2f8e8d1235:
  Linus Torvalds (1):
        Linux 2.6.24-rc7

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Ivo van Doorn (2):
      rt2x00: Corectly initialize rt2500usb MAC
      rt2x00: Put 802.11 data on 4 byte boundary

Mattias Nissler (1):
      rt2x00: Allow rt61 to catch up after a missing tx report

 drivers/net/wireless/rt2x00/rt2500usb.c |    2 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c |   20 ++++++++++++++++----
 drivers/net/wireless/rt2x00/rt2x00usb.c |   17 +++++++++++++++--
 drivers/net/wireless/rt2x00/rt61pci.c   |   12 ++++++++++++
 4 files changed, 44 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 50775f9..18b1f91 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -257,7 +257,7 @@ static const struct rt2x00debug rt2500usb_rt2x00debug = {
 static void rt2500usb_config_mac_addr(struct rt2x00_dev *rt2x00dev,
 				      __le32 *mac)
 {
-	rt2500usb_register_multiwrite(rt2x00dev, MAC_CSR2, &mac,
+	rt2500usb_register_multiwrite(rt2x00dev, MAC_CSR2, mac,
 				      (3 * sizeof(__le16)));
 }
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index 2780df0..6d5d9ab 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -124,7 +124,10 @@ void rt2x00pci_rxdone(struct rt2x00_dev *rt2x00dev)
 	struct data_entry *entry;
 	struct data_desc *rxd;
 	struct sk_buff *skb;
+	struct ieee80211_hdr *hdr;
 	struct rxdata_entry_desc desc;
+	int header_size;
+	int align;
 	u32 word;
 
 	while (1) {
@@ -138,17 +141,26 @@ void rt2x00pci_rxdone(struct rt2x00_dev *rt2x00dev)
 		memset(&desc, 0x00, sizeof(desc));
 		rt2x00dev->ops->lib->fill_rxdone(entry, &desc);
 
+		hdr = (struct ieee80211_hdr *)entry->data_addr;
+		header_size =
+		    ieee80211_get_hdrlen(le16_to_cpu(hdr->frame_control));
+
+		/*
+		 * The data behind the ieee80211 header must be
+		 * aligned on a 4 byte boundary.
+		 */
+		align = NET_IP_ALIGN + (2 * (header_size % 4 == 0));
+
 		/*
 		 * Allocate the sk_buffer, initialize it and copy
 		 * all data into it.
 		 */
-		skb = dev_alloc_skb(desc.size + NET_IP_ALIGN);
+		skb = dev_alloc_skb(desc.size + align);
 		if (!skb)
 			return;
 
-		skb_reserve(skb, NET_IP_ALIGN);
-		skb_put(skb, desc.size);
-		memcpy(skb->data, entry->data_addr, desc.size);
+		skb_reserve(skb, align);
+		memcpy(skb_put(skb, desc.size), entry->data_addr, desc.size);
 
 		/*
 		 * Send the frame to rt2x00lib for further processing.
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index 1f5675d..ab4797e 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -221,7 +221,9 @@ static void rt2x00usb_interrupt_rxdone(struct urb *urb)
 	struct data_ring *ring = entry->ring;
 	struct rt2x00_dev *rt2x00dev = ring->rt2x00dev;
 	struct sk_buff *skb;
+	struct ieee80211_hdr *hdr;
 	struct rxdata_entry_desc desc;
+	int header_size;
 	int frame_size;
 
 	if (!test_bit(DEVICE_ENABLED_RADIO, &rt2x00dev->flags) ||
@@ -253,9 +255,20 @@ static void rt2x00usb_interrupt_rxdone(struct urb *urb)
 	skb_put(skb, frame_size);
 
 	/*
-	 * Trim the skb_buffer to only contain the valid
-	 * frame data (so ignore the device's descriptor).
+	 * The data behind the ieee80211 header must be
+	 * aligned on a 4 byte boundary.
+	 * After that trim the entire buffer down to only
+	 * contain the valid frame data excluding the device
+	 * descriptor.
 	 */
+	hdr = (struct ieee80211_hdr *)entry->skb->data;
+	header_size =
+	    ieee80211_get_hdrlen(le16_to_cpu(hdr->frame_control));
+
+	if (header_size % 4 == 0) {
+		skb_push(entry->skb, 2);
+		memmove(entry->skb->data, entry->skb->data + 2, skb->len - 2);
+	}
 	skb_trim(entry->skb, desc.size);
 
 	/*
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index 01dbef1..ecae968 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -1738,6 +1738,7 @@ static void rt61pci_txdone(struct rt2x00_dev *rt2x00dev)
 {
 	struct data_ring *ring;
 	struct data_entry *entry;
+	struct data_entry *entry_done;
 	struct data_desc *txd;
 	u32 word;
 	u32 reg;
@@ -1791,6 +1792,17 @@ static void rt61pci_txdone(struct rt2x00_dev *rt2x00dev)
 		    !rt2x00_get_field32(word, TXD_W0_VALID))
 			return;
 
+		entry_done = rt2x00_get_data_entry_done(ring);
+		while (entry != entry_done) {
+			/* Catch up. Just report any entries we missed as
+			 * failed. */
+			WARNING(rt2x00dev,
+				"TX status report missed for entry %p\n",
+				entry_done);
+			rt2x00lib_txdone(entry_done, TX_FAIL_OTHER, 0);
+			entry_done = rt2x00_get_data_entry_done(ring);
+		}
+
 		/*
 		 * Obtain the status about this packet.
 		 */
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
