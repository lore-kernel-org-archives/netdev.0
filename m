From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 'fixes' 2008-02-15
Date: Fri, 15 Feb 2008 14:17:51 -0500
Message-ID: <20080215191751.GA3054@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2565 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758632AbYBOTjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 14:39:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

A handful of (mostly) fixes for 2.6.25.  Also included are b43 patches
and their b43legacy counterparts that only add some debugging output
that should aid in diagnosing problems with those drivers.

Let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6/fixes

---

The following changes since commit 19af35546de68c872dcb687613e0902a602cb20e:
  Linus Torvalds (1):
        Linux 2.6.25-rc1

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes

Bruno Randolf (1):
      ath5k: correct padding in tx descriptors

Dan Williams (1):
      ipw2200: fix ucode assertion for RX queue overrun

Gregory Greenman (1):
      iwlwifi: Don't send host commands on rfkill

Ivo van Doorn (1):
      rt2x00: Add new USB ID to rt2500usb

John W. Linville (1):
      wavelan: mark hardware interfacing structures as packed

Jussi Kivilinna (1):
      rndis_wlan: enable stall workaround by link quality instead of link speed

Michael Buesch (4):
      b43: Add driver load messages
      b43: Add firmware information to modinfo
      b43: Fix firmware load message level
      mac80211: Fix initial hardware configuration

Mohamed Abbas (1):
      iwlwifi: earlier rx allocation

Reinette Chatre (2):
      iwlwifi: do not clear GEO_CONFIGURED bit when calling _down
      iwlwifi: only check for association id when associating with AP

Stefano Brivio (4):
      b43legacy: fix DMA for 30/32-bit DMA engines
      b43legacy: add firmware information to modinfo
      b43legacy: fix firmware load message level
      b43legacy: Add driver load messages

Tomas Winkler (1):
      iwlwifi: reverting 'misc wireless annotations' patch for iwlwifi

 drivers/net/wireless/ath5k/base.c           |    4 +-
 drivers/net/wireless/ath5k/hw.c             |   34 +++---
 drivers/net/wireless/b43/b43.h              |    6 +
 drivers/net/wireless/b43/main.c             |   40 ++++++-
 drivers/net/wireless/b43legacy/b43legacy.h  |    4 +
 drivers/net/wireless/b43legacy/dma.c        |  167 +++++++++++++++++----------
 drivers/net/wireless/b43legacy/dma.h        |   33 ++----
 drivers/net/wireless/b43legacy/main.c       |   41 ++++++-
 drivers/net/wireless/ipw2200.c              |   45 ++++++--
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   19 +++-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   17 ++-
 drivers/net/wireless/rndis_wlan.c           |   14 +--
 drivers/net/wireless/rt2x00/rt2500usb.c     |    2 +-
 drivers/net/wireless/wavelan.h              |    6 +-
 net/mac80211/ieee80211.c                    |    5 +-
 15 files changed, 291 insertions(+), 146 deletions(-)

diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index ddc8714..dfdaec0 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -1256,7 +1256,7 @@ ath5k_txbuf_setup(struct ath5k_softc *sc, struct ath5k_buf *bf,
 	if (ctl->flags & IEEE80211_TXCTL_NO_ACK)
 		flags |= AR5K_TXDESC_NOACK;
 
-	pktlen = skb->len + FCS_LEN;
+	pktlen = skb->len;
 
 	if (!(ctl->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT)) {
 		keyidx = ctl->key_idx;
@@ -1952,7 +1952,7 @@ ath5k_beacon_setup(struct ath5k_softc *sc, struct ath5k_buf *bf,
 	}
 
 	ds->ds_data = bf->skbaddr;
-	ret = ah->ah_setup_tx_desc(ah, ds, skb->len + FCS_LEN,
+	ret = ah->ah_setup_tx_desc(ah, ds, skb->len,
 			ieee80211_get_hdrlen_from_skb(skb),
 			AR5K_PKT_TYPE_BEACON, (ctl->power_level * 2), ctl->tx_rate, 1,
 			AR5K_TXKEYIX_INVALID, antenna, flags, 0, 0);
diff --git a/drivers/net/wireless/ath5k/hw.c b/drivers/net/wireless/ath5k/hw.c
index 3a4bf40..1ab57aa 100644
--- a/drivers/net/wireless/ath5k/hw.c
+++ b/drivers/net/wireless/ath5k/hw.c
@@ -3506,7 +3506,7 @@ ath5k_hw_setup_2word_tx_desc(struct ath5k_hw *ah, struct ath5k_desc *desc,
 {
 	u32 frame_type;
 	struct ath5k_hw_2w_tx_desc *tx_desc;
-	unsigned int buff_len;
+	unsigned int frame_len;
 
 	tx_desc = (struct ath5k_hw_2w_tx_desc *)&desc->ds_ctl0;
 
@@ -3537,22 +3537,25 @@ ath5k_hw_setup_2word_tx_desc(struct ath5k_hw *ah, struct ath5k_desc *desc,
 	/* Setup control descriptor */
 
 	/* Verify and set frame length */
-	if (pkt_len & ~AR5K_2W_TX_DESC_CTL0_FRAME_LEN)
+
+	/* remove padding we might have added before */
+	frame_len = pkt_len - (hdr_len & 3) + FCS_LEN;
+
+	if (frame_len & ~AR5K_2W_TX_DESC_CTL0_FRAME_LEN)
 		return -EINVAL;
 
-	tx_desc->tx_control_0 = pkt_len & AR5K_2W_TX_DESC_CTL0_FRAME_LEN;
+	tx_desc->tx_control_0 = frame_len & AR5K_2W_TX_DESC_CTL0_FRAME_LEN;
 
 	/* Verify and set buffer length */
-	buff_len = pkt_len - FCS_LEN;
 
 	/* NB: beacon's BufLen must be a multiple of 4 bytes */
 	if(type == AR5K_PKT_TYPE_BEACON)
-		buff_len = roundup(buff_len, 4);
+		pkt_len = roundup(pkt_len, 4);
 
-	if (buff_len & ~AR5K_2W_TX_DESC_CTL1_BUF_LEN)
+	if (pkt_len & ~AR5K_2W_TX_DESC_CTL1_BUF_LEN)
 		return -EINVAL;
 
-	tx_desc->tx_control_1 = buff_len & AR5K_2W_TX_DESC_CTL1_BUF_LEN;
+	tx_desc->tx_control_1 = pkt_len & AR5K_2W_TX_DESC_CTL1_BUF_LEN;
 
 	/*
 	 * Verify and set header length
@@ -3634,7 +3637,7 @@ static int ath5k_hw_setup_4word_tx_desc(struct ath5k_hw *ah,
 {
 	struct ath5k_hw_4w_tx_desc *tx_desc;
 	struct ath5k_hw_tx_status *tx_status;
-	unsigned int buff_len;
+	unsigned int frame_len;
 
 	ATH5K_TRACE(ah->ah_sc);
 	tx_desc = (struct ath5k_hw_4w_tx_desc *)&desc->ds_ctl0;
@@ -3669,22 +3672,25 @@ static int ath5k_hw_setup_4word_tx_desc(struct ath5k_hw *ah,
 	/* Setup control descriptor */
 
 	/* Verify and set frame length */
-	if (pkt_len & ~AR5K_4W_TX_DESC_CTL0_FRAME_LEN)
+
+	/* remove padding we might have added before */
+	frame_len = pkt_len - (hdr_len & 3) + FCS_LEN;
+
+	if (frame_len & ~AR5K_4W_TX_DESC_CTL0_FRAME_LEN)
 		return -EINVAL;
 
-	tx_desc->tx_control_0 = pkt_len & AR5K_4W_TX_DESC_CTL0_FRAME_LEN;
+	tx_desc->tx_control_0 = frame_len & AR5K_4W_TX_DESC_CTL0_FRAME_LEN;
 
 	/* Verify and set buffer length */
-	buff_len = pkt_len - FCS_LEN;
 
 	/* NB: beacon's BufLen must be a multiple of 4 bytes */
 	if(type == AR5K_PKT_TYPE_BEACON)
-		buff_len = roundup(buff_len, 4);
+		pkt_len = roundup(pkt_len, 4);
 
-	if (buff_len & ~AR5K_4W_TX_DESC_CTL1_BUF_LEN)
+	if (pkt_len & ~AR5K_4W_TX_DESC_CTL1_BUF_LEN)
 		return -EINVAL;
 
-	tx_desc->tx_control_1 = buff_len & AR5K_4W_TX_DESC_CTL1_BUF_LEN;
+	tx_desc->tx_control_1 = pkt_len & AR5K_4W_TX_DESC_CTL1_BUF_LEN;
 
 	tx_desc->tx_control_0 |=
 		AR5K_REG_SM(tx_power, AR5K_4W_TX_DESC_CTL0_XMIT_POWER) |
diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index 08a011f..f13346b 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -14,6 +14,12 @@
 #include "lo.h"
 #include "phy.h"
 
+
+/* The unique identifier of the firmware that's officially supported by
+ * this driver version. */
+#define B43_SUPPORTED_FIRMWARE_ID	"FW13"
+
+
 #ifdef CONFIG_B43_DEBUG
 # define B43_DEBUG	1
 #else
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index ef65c41..51dfce1 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -58,6 +58,8 @@ MODULE_AUTHOR("Stefano Brivio");
 MODULE_AUTHOR("Michael Buesch");
 MODULE_LICENSE("GPL");
 
+MODULE_FIRMWARE(B43_SUPPORTED_FIRMWARE_ID);
+
 
 static int modparam_bad_frames_preempt;
 module_param_named(bad_frames_preempt, modparam_bad_frames_preempt, int, 0444);
@@ -1859,11 +1861,11 @@ static int b43_upload_microcode(struct b43_wldev *dev)
 		err = -EOPNOTSUPP;
 		goto error;
 	}
-	b43dbg(dev->wl, "Loading firmware version %u.%u "
-	       "(20%.2i-%.2i-%.2i %.2i:%.2i:%.2i)\n",
-	       fwrev, fwpatch,
-	       (fwdate >> 12) & 0xF, (fwdate >> 8) & 0xF, fwdate & 0xFF,
-	       (fwtime >> 11) & 0x1F, (fwtime >> 5) & 0x3F, fwtime & 0x1F);
+	b43info(dev->wl, "Loading firmware version %u.%u "
+		"(20%.2i-%.2i-%.2i %.2i:%.2i:%.2i)\n",
+		fwrev, fwpatch,
+		(fwdate >> 12) & 0xF, (fwdate >> 8) & 0xF, fwdate & 0xFF,
+		(fwtime >> 11) & 0x1F, (fwtime >> 5) & 0x3F, fwtime & 0x1F);
 
 	dev->fw.rev = fwrev;
 	dev->fw.patch = fwpatch;
@@ -4200,6 +4202,33 @@ static struct ssb_driver b43_ssb_driver = {
 	.resume		= b43_resume,
 };
 
+static void b43_print_driverinfo(void)
+{
+	const char *feat_pci = "", *feat_pcmcia = "", *feat_nphy = "",
+		   *feat_leds = "", *feat_rfkill = "";
+
+#ifdef CONFIG_B43_PCI_AUTOSELECT
+	feat_pci = "P";
+#endif
+#ifdef CONFIG_B43_PCMCIA
+	feat_pcmcia = "M";
+#endif
+#ifdef CONFIG_B43_NPHY
+	feat_nphy = "N";
+#endif
+#ifdef CONFIG_B43_LEDS
+	feat_leds = "L";
+#endif
+#ifdef CONFIG_B43_RFKILL
+	feat_rfkill = "R";
+#endif
+	printk(KERN_INFO "Broadcom 43xx driver loaded "
+	       "[ Features: %s%s%s%s%s, Firmware-ID: "
+	       B43_SUPPORTED_FIRMWARE_ID " ]\n",
+	       feat_pci, feat_pcmcia, feat_nphy,
+	       feat_leds, feat_rfkill);
+}
+
 static int __init b43_init(void)
 {
 	int err;
@@ -4211,6 +4240,7 @@ static int __init b43_init(void)
 	err = ssb_driver_register(&b43_ssb_driver);
 	if (err)
 		goto err_pcmcia_exit;
+	b43_print_driverinfo();
 
 	return err;
 
diff --git a/drivers/net/wireless/b43legacy/b43legacy.h b/drivers/net/wireless/b43legacy/b43legacy.h
index c80edd2..93d45b7 100644
--- a/drivers/net/wireless/b43legacy/b43legacy.h
+++ b/drivers/net/wireless/b43legacy/b43legacy.h
@@ -23,6 +23,10 @@
 #include "phy.h"
 
 
+/* The unique identifier of the firmware that's officially supported by this
+ * driver version. */
+#define B43legacy_SUPPORTED_FIRMWARE_ID	"FW10"
+
 #define B43legacy_IRQWAIT_MAX_RETRIES	20
 
 #define B43legacy_RX_MAX_SSI		60 /* best guess at max ssi */
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 6e08405..e87b427 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -354,7 +354,8 @@ return 0;
 }
 
 
-u16 b43legacy_dmacontroller_base(int dma64bit, int controller_idx)
+static u16 b43legacy_dmacontroller_base(enum b43legacy_dmatype type,
+					int controller_idx)
 {
 	static const u16 map64[] = {
 		B43legacy_MMIO_DMA64_BASE0,
@@ -373,7 +374,7 @@ u16 b43legacy_dmacontroller_base(int dma64bit, int controller_idx)
 		B43legacy_MMIO_DMA32_BASE5,
 	};
 
-	if (dma64bit) {
+	if (type == B43legacy_DMA_64BIT) {
 		B43legacy_WARN_ON(!(controller_idx >= 0 &&
 				  controller_idx < ARRAY_SIZE(map64)));
 		return map64[controller_idx];
@@ -480,8 +481,9 @@ static void free_ringmemory(struct b43legacy_dmaring *ring)
 }
 
 /* Reset the RX DMA channel */
-int b43legacy_dmacontroller_rx_reset(struct b43legacy_wldev *dev,
-				     u16 mmio_base, int dma64)
+static int b43legacy_dmacontroller_rx_reset(struct b43legacy_wldev *dev,
+					    u16 mmio_base,
+					    enum b43legacy_dmatype type)
 {
 	int i;
 	u32 value;
@@ -489,13 +491,14 @@ int b43legacy_dmacontroller_rx_reset(struct b43legacy_wldev *dev,
 
 	might_sleep();
 
-	offset = dma64 ? B43legacy_DMA64_RXCTL : B43legacy_DMA32_RXCTL;
+	offset = (type == B43legacy_DMA_64BIT) ?
+		 B43legacy_DMA64_RXCTL : B43legacy_DMA32_RXCTL;
 	b43legacy_write32(dev, mmio_base + offset, 0);
 	for (i = 0; i < 10; i++) {
-		offset = dma64 ? B43legacy_DMA64_RXSTATUS :
-			 B43legacy_DMA32_RXSTATUS;
+		offset = (type == B43legacy_DMA_64BIT) ?
+			 B43legacy_DMA64_RXSTATUS : B43legacy_DMA32_RXSTATUS;
 		value = b43legacy_read32(dev, mmio_base + offset);
-		if (dma64) {
+		if (type == B43legacy_DMA_64BIT) {
 			value &= B43legacy_DMA64_RXSTAT;
 			if (value == B43legacy_DMA64_RXSTAT_DISABLED) {
 				i = -1;
@@ -519,8 +522,9 @@ int b43legacy_dmacontroller_rx_reset(struct b43legacy_wldev *dev,
 }
 
 /* Reset the RX DMA channel */
-int b43legacy_dmacontroller_tx_reset(struct b43legacy_wldev *dev,
-				     u16 mmio_base, int dma64)
+static int b43legacy_dmacontroller_tx_reset(struct b43legacy_wldev *dev,
+					    u16 mmio_base,
+					    enum b43legacy_dmatype type)
 {
 	int i;
 	u32 value;
@@ -529,10 +533,10 @@ int b43legacy_dmacontroller_tx_reset(struct b43legacy_wldev *dev,
 	might_sleep();
 
 	for (i = 0; i < 10; i++) {
-		offset = dma64 ? B43legacy_DMA64_TXSTATUS :
-			 B43legacy_DMA32_TXSTATUS;
+		offset = (type == B43legacy_DMA_64BIT) ?
+			 B43legacy_DMA64_TXSTATUS : B43legacy_DMA32_TXSTATUS;
 		value = b43legacy_read32(dev, mmio_base + offset);
-		if (dma64) {
+		if (type == B43legacy_DMA_64BIT) {
 			value &= B43legacy_DMA64_TXSTAT;
 			if (value == B43legacy_DMA64_TXSTAT_DISABLED ||
 			    value == B43legacy_DMA64_TXSTAT_IDLEWAIT ||
@@ -547,13 +551,14 @@ int b43legacy_dmacontroller_tx_reset(struct b43legacy_wldev *dev,
 		}
 		msleep(1);
 	}
-	offset = dma64 ? B43legacy_DMA64_TXCTL : B43legacy_DMA32_TXCTL;
+	offset = (type == B43legacy_DMA_64BIT) ? B43legacy_DMA64_TXCTL :
+						 B43legacy_DMA32_TXCTL;
 	b43legacy_write32(dev, mmio_base + offset, 0);
 	for (i = 0; i < 10; i++) {
-		offset = dma64 ? B43legacy_DMA64_TXSTATUS :
-			 B43legacy_DMA32_TXSTATUS;
+		offset = (type == B43legacy_DMA_64BIT) ?
+			 B43legacy_DMA64_TXSTATUS : B43legacy_DMA32_TXSTATUS;
 		value = b43legacy_read32(dev, mmio_base + offset);
-		if (dma64) {
+		if (type == B43legacy_DMA_64BIT) {
 			value &= B43legacy_DMA64_TXSTAT;
 			if (value == B43legacy_DMA64_TXSTAT_DISABLED) {
 				i = -1;
@@ -578,6 +583,32 @@ int b43legacy_dmacontroller_tx_reset(struct b43legacy_wldev *dev,
 	return 0;
 }
 
+/* Check if a DMA mapping address is invalid. */
+static bool b43legacy_dma_mapping_error(struct b43legacy_dmaring *ring,
+					dma_addr_t addr,
+					size_t buffersize)
+{
+	if (unlikely(dma_mapping_error(addr)))
+		return 1;
+
+	switch (ring->type) {
+	case B43legacy_DMA_30BIT:
+		if ((u64)addr + buffersize > (1ULL << 30))
+			return 1;
+		break;
+	case B43legacy_DMA_32BIT:
+		if ((u64)addr + buffersize > (1ULL << 32))
+			return 1;
+		break;
+	case B43legacy_DMA_64BIT:
+		/* Currently we can't have addresses beyond 64 bits in the kernel. */
+		break;
+	}
+
+	/* The address is OK. */
+	return 0;
+}
+
 static int setup_rx_descbuffer(struct b43legacy_dmaring *ring,
 			       struct b43legacy_dmadesc_generic *desc,
 			       struct b43legacy_dmadesc_meta *meta,
@@ -595,7 +626,7 @@ static int setup_rx_descbuffer(struct b43legacy_dmaring *ring,
 		return -ENOMEM;
 	dmaaddr = map_descbuffer(ring, skb->data,
 				 ring->rx_buffersize, 0);
-	if (dma_mapping_error(dmaaddr)) {
+	if (b43legacy_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize)) {
 		/* ugh. try to realloc in zone_dma */
 		gfp_flags |= GFP_DMA;
 
@@ -608,7 +639,7 @@ static int setup_rx_descbuffer(struct b43legacy_dmaring *ring,
 					 ring->rx_buffersize, 0);
 	}
 
-	if (dma_mapping_error(dmaaddr)) {
+	if (b43legacy_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize)) {
 		dev_kfree_skb_any(skb);
 		return -EIO;
 	}
@@ -674,7 +705,7 @@ static int dmacontroller_setup(struct b43legacy_dmaring *ring)
 	u32 trans = ssb_dma_translation(ring->dev->dev);
 
 	if (ring->tx) {
-		if (ring->dma64) {
+		if (ring->type == B43legacy_DMA_64BIT) {
 			u64 ringbase = (u64)(ring->dmabase);
 
 			addrext = ((ringbase >> 32) & SSB_DMA_TRANSLATION_MASK)
@@ -709,7 +740,7 @@ static int dmacontroller_setup(struct b43legacy_dmaring *ring)
 		err = alloc_initial_descbuffers(ring);
 		if (err)
 			goto out;
-		if (ring->dma64) {
+		if (ring->type == B43legacy_DMA_64BIT) {
 			u64 ringbase = (u64)(ring->dmabase);
 
 			addrext = ((ringbase >> 32) & SSB_DMA_TRANSLATION_MASK)
@@ -760,16 +791,16 @@ static void dmacontroller_cleanup(struct b43legacy_dmaring *ring)
 {
 	if (ring->tx) {
 		b43legacy_dmacontroller_tx_reset(ring->dev, ring->mmio_base,
-						 ring->dma64);
-		if (ring->dma64) {
+						 ring->type);
+		if (ring->type == B43legacy_DMA_64BIT) {
 			b43legacy_dma_write(ring, B43legacy_DMA64_TXRINGLO, 0);
 			b43legacy_dma_write(ring, B43legacy_DMA64_TXRINGHI, 0);
 		} else
 			b43legacy_dma_write(ring, B43legacy_DMA32_TXRING, 0);
 	} else {
 		b43legacy_dmacontroller_rx_reset(ring->dev, ring->mmio_base,
-						 ring->dma64);
-		if (ring->dma64) {
+						 ring->type);
+		if (ring->type == B43legacy_DMA_64BIT) {
 			b43legacy_dma_write(ring, B43legacy_DMA64_RXRINGLO, 0);
 			b43legacy_dma_write(ring, B43legacy_DMA64_RXRINGHI, 0);
 		} else
@@ -824,11 +855,10 @@ static u64 supported_dma_mask(struct b43legacy_wldev *dev)
 
 /* Main initialization function. */
 static
-struct b43legacy_dmaring *b43legacy_setup_dmaring(
-					struct b43legacy_wldev *dev,
-					int controller_index,
-					int for_tx,
-					int dma64)
+struct b43legacy_dmaring *b43legacy_setup_dmaring(struct b43legacy_wldev *dev,
+						  int controller_index,
+						  int for_tx,
+						  enum b43legacy_dmatype type)
 {
 	struct b43legacy_dmaring *ring;
 	int err;
@@ -838,6 +868,7 @@ struct b43legacy_dmaring *b43legacy_setup_dmaring(
 	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 	if (!ring)
 		goto out;
+	ring->type = type;
 
 	nr_slots = B43legacy_RXRING_SLOTS;
 	if (for_tx)
@@ -855,12 +886,12 @@ struct b43legacy_dmaring *b43legacy_setup_dmaring(
 			goto err_kfree_meta;
 
 		/* test for ability to dma to txhdr_cache */
-		dma_test = dma_map_single(dev->dev->dev,
-				ring->txhdr_cache,
-				sizeof(struct b43legacy_txhdr_fw3),
-				DMA_TO_DEVICE);
+		dma_test = dma_map_single(dev->dev->dev, ring->txhdr_cache,
+					  sizeof(struct b43legacy_txhdr_fw3),
+					  DMA_TO_DEVICE);
 
-		if (dma_mapping_error(dma_test)) {
+		if (b43legacy_dma_mapping_error(ring, dma_test,
+					sizeof(struct b43legacy_txhdr_fw3))) {
 			/* ugh realloc */
 			kfree(ring->txhdr_cache);
 			ring->txhdr_cache = kcalloc(nr_slots,
@@ -874,7 +905,8 @@ struct b43legacy_dmaring *b43legacy_setup_dmaring(
 					sizeof(struct b43legacy_txhdr_fw3),
 					DMA_TO_DEVICE);
 
-			if (dma_mapping_error(dma_test))
+			if (b43legacy_dma_mapping_error(ring, dma_test,
+					sizeof(struct b43legacy_txhdr_fw3)))
 				goto err_kfree_txhdr_cache;
 		}
 
@@ -885,11 +917,9 @@ struct b43legacy_dmaring *b43legacy_setup_dmaring(
 
 	ring->dev = dev;
 	ring->nr_slots = nr_slots;
-	ring->mmio_base = b43legacy_dmacontroller_base(dma64,
-						       controller_index);
+	ring->mmio_base = b43legacy_dmacontroller_base(type, controller_index);
 	ring->index = controller_index;
-	ring->dma64 = !!dma64;
-	if (dma64)
+	if (type == B43legacy_DMA_64BIT)
 		ring->ops = &dma64_ops;
 	else
 		ring->ops = &dma32_ops;
@@ -939,10 +969,10 @@ static void b43legacy_destroy_dmaring(struct b43legacy_dmaring *ring)
 	if (!ring)
 		return;
 
-	b43legacydbg(ring->dev->wl, "DMA-%s 0x%04X (%s) max used slots:"
-		     " %d/%d\n", (ring->dma64) ? "64" : "32", ring->mmio_base,
-		     (ring->tx) ? "TX" : "RX",
-		     ring->max_used_slots, ring->nr_slots);
+	b43legacydbg(ring->dev->wl, "DMA-%u 0x%04X (%s) max used slots:"
+		     " %d/%d\n", (unsigned int)(ring->type), ring->mmio_base,
+		     (ring->tx) ? "TX" : "RX", ring->max_used_slots,
+		     ring->nr_slots);
 	/* Device IRQs are disabled prior entering this function,
 	 * so no need to take care of concurrency with rx handler stuff.
 	 */
@@ -988,11 +1018,22 @@ int b43legacy_dma_init(struct b43legacy_wldev *dev)
 	struct b43legacy_dmaring *ring;
 	int err;
 	u64 dmamask;
-	int dma64 = 0;
+	enum b43legacy_dmatype type;
 
 	dmamask = supported_dma_mask(dev);
-	if (dmamask == DMA_64BIT_MASK)
-		dma64 = 1;
+	switch (dmamask) {
+	default:
+		B43legacy_WARN_ON(1);
+	case DMA_30BIT_MASK:
+		type = B43legacy_DMA_30BIT;
+		break;
+	case DMA_32BIT_MASK:
+		type = B43legacy_DMA_32BIT;
+		break;
+	case DMA_64BIT_MASK:
+		type = B43legacy_DMA_64BIT;
+		break;
+	}
 
 	err = ssb_dma_set_mask(dev->dev, dmamask);
 	if (err) {
@@ -1010,52 +1051,50 @@ int b43legacy_dma_init(struct b43legacy_wldev *dev)
 
 	err = -ENOMEM;
 	/* setup TX DMA channels. */
-	ring = b43legacy_setup_dmaring(dev, 0, 1, dma64);
+	ring = b43legacy_setup_dmaring(dev, 0, 1, type);
 	if (!ring)
 		goto out;
 	dma->tx_ring0 = ring;
 
-	ring = b43legacy_setup_dmaring(dev, 1, 1, dma64);
+	ring = b43legacy_setup_dmaring(dev, 1, 1, type);
 	if (!ring)
 		goto err_destroy_tx0;
 	dma->tx_ring1 = ring;
 
-	ring = b43legacy_setup_dmaring(dev, 2, 1, dma64);
+	ring = b43legacy_setup_dmaring(dev, 2, 1, type);
 	if (!ring)
 		goto err_destroy_tx1;
 	dma->tx_ring2 = ring;
 
-	ring = b43legacy_setup_dmaring(dev, 3, 1, dma64);
+	ring = b43legacy_setup_dmaring(dev, 3, 1, type);
 	if (!ring)
 		goto err_destroy_tx2;
 	dma->tx_ring3 = ring;
 
-	ring = b43legacy_setup_dmaring(dev, 4, 1, dma64);
+	ring = b43legacy_setup_dmaring(dev, 4, 1, type);
 	if (!ring)
 		goto err_destroy_tx3;
 	dma->tx_ring4 = ring;
 
-	ring = b43legacy_setup_dmaring(dev, 5, 1, dma64);
+	ring = b43legacy_setup_dmaring(dev, 5, 1, type);
 	if (!ring)
 		goto err_destroy_tx4;
 	dma->tx_ring5 = ring;
 
 	/* setup RX DMA channels. */
-	ring = b43legacy_setup_dmaring(dev, 0, 0, dma64);
+	ring = b43legacy_setup_dmaring(dev, 0, 0, type);
 	if (!ring)
 		goto err_destroy_tx5;
 	dma->rx_ring0 = ring;
 
 	if (dev->dev->id.revision < 5) {
-		ring = b43legacy_setup_dmaring(dev, 3, 0, dma64);
+		ring = b43legacy_setup_dmaring(dev, 3, 0, type);
 		if (!ring)
 			goto err_destroy_rx0;
 		dma->rx_ring3 = ring;
 	}
 
-	b43legacydbg(dev->wl, "%d-bit DMA initialized\n",
-	       (dmamask == DMA_64BIT_MASK) ? 64 :
-	       (dmamask == DMA_32BIT_MASK) ? 32 : 30);
+	b43legacydbg(dev->wl, "%u-bit DMA initialized\n", (unsigned int)type);
 	err = 0;
 out:
 	return err;
@@ -1194,9 +1233,13 @@ static int dma_tx_fragment(struct b43legacy_dmaring *ring,
 	}
 
 	meta_hdr->dmaaddr = map_descbuffer(ring, (unsigned char *)header,
-				       sizeof(struct b43legacy_txhdr_fw3), 1);
-	if (dma_mapping_error(meta_hdr->dmaaddr))
+					   sizeof(struct b43legacy_txhdr_fw3), 1);
+	if (b43legacy_dma_mapping_error(ring, meta_hdr->dmaaddr,
+					sizeof(struct b43legacy_txhdr_fw3))) {
+		ring->current_slot = old_top_slot;
+		ring->used_slots = old_used_slots;
 		return -EIO;
+	}
 	ops->fill_descriptor(ring, desc, meta_hdr->dmaaddr,
 			     sizeof(struct b43legacy_txhdr_fw3), 1, 0, 0);
 
@@ -1211,7 +1254,7 @@ static int dma_tx_fragment(struct b43legacy_dmaring *ring,
 
 	meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
 	/* create a bounce buffer in zone_dma on mapping failure. */
-	if (dma_mapping_error(meta->dmaaddr)) {
+	if (b43legacy_dma_mapping_error(ring, meta->dmaaddr, skb->len)) {
 		bounce_skb = __dev_alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb) {
 			ring->current_slot = old_top_slot;
@@ -1225,7 +1268,7 @@ static int dma_tx_fragment(struct b43legacy_dmaring *ring,
 		skb = bounce_skb;
 		meta->skb = skb;
 		meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
-		if (dma_mapping_error(meta->dmaaddr)) {
+		if (b43legacy_dma_mapping_error(ring, meta->dmaaddr, skb->len)) {
 			ring->current_slot = old_top_slot;
 			ring->used_slots = old_used_slots;
 			err = -EIO;
diff --git a/drivers/net/wireless/b43legacy/dma.h b/drivers/net/wireless/b43legacy/dma.h
index 26f6ab0..2dd488c 100644
--- a/drivers/net/wireless/b43legacy/dma.h
+++ b/drivers/net/wireless/b43legacy/dma.h
@@ -218,6 +218,12 @@ struct b43legacy_dma_ops {
 	void (*set_current_rxslot)(struct b43legacy_dmaring *ring, int slot);
 };
 
+enum b43legacy_dmatype {
+	B43legacy_DMA_30BIT = 30,
+	B43legacy_DMA_32BIT = 32,
+	B43legacy_DMA_64BIT = 64,
+};
+
 struct b43legacy_dmaring {
 	/* Lowlevel DMA ops. */
 	const struct b43legacy_dma_ops *ops;
@@ -250,8 +256,8 @@ struct b43legacy_dmaring {
 	int index;
 	/* Boolean. Is this a TX ring? */
 	bool tx;
-	/* Boolean. 64bit DMA if true, 32bit DMA otherwise. */
-	bool dma64;
+	/* The type of DMA engine used. */
+	enum b43legacy_dmatype type;
 	/* Boolean. Is this ring stopped at ieee80211 level? */
 	bool stopped;
 	/* Lock, only used for TX. */
@@ -284,15 +290,6 @@ void b43legacy_dma_write(struct b43legacy_dmaring *ring,
 int b43legacy_dma_init(struct b43legacy_wldev *dev);
 void b43legacy_dma_free(struct b43legacy_wldev *dev);
 
-int b43legacy_dmacontroller_rx_reset(struct b43legacy_wldev *dev,
-				     u16 dmacontroller_mmio_base,
-				     int dma64);
-int b43legacy_dmacontroller_tx_reset(struct b43legacy_wldev *dev,
-				     u16 dmacontroller_mmio_base,
-				     int dma64);
-
-u16 b43legacy_dmacontroller_base(int dma64bit, int dmacontroller_idx);
-
 void b43legacy_dma_tx_suspend(struct b43legacy_wldev *dev);
 void b43legacy_dma_tx_resume(struct b43legacy_wldev *dev);
 
@@ -320,20 +317,6 @@ void b43legacy_dma_free(struct b43legacy_wldev *dev)
 {
 }
 static inline
-int b43legacy_dmacontroller_rx_reset(struct b43legacy_wldev *dev,
-				     u16 dmacontroller_mmio_base,
-				     int dma64)
-{
-	return 0;
-}
-static inline
-int b43legacy_dmacontroller_tx_reset(struct b43legacy_wldev *dev,
-				     u16 dmacontroller_mmio_base,
-				     int dma64)
-{
-	return 0;
-}
-static inline
 void b43legacy_dma_get_tx_stats(struct b43legacy_wldev *dev,
 				struct ieee80211_tx_queue_stats *stats)
 {
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 53f7f2e..c39de42 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -3,7 +3,7 @@
  *  Broadcom B43legacy wireless driver
  *
  *  Copyright (c) 2005 Martin Langer <martin-langer@gmx.de>
- *  Copyright (c) 2005-2007 Stefano Brivio <stefano.brivio@polimi.it>
+ *  Copyright (c) 2005-2008 Stefano Brivio <stefano.brivio@polimi.it>
  *  Copyright (c) 2005, 2006 Michael Buesch <mb@bu3sch.de>
  *  Copyright (c) 2005 Danny van Dyk <kugelfang@gentoo.org>
  *  Copyright (c) 2005 Andreas Jaggi <andreas.jaggi@waterwave.ch>
@@ -60,6 +60,8 @@ MODULE_AUTHOR("Stefano Brivio");
 MODULE_AUTHOR("Michael Buesch");
 MODULE_LICENSE("GPL");
 
+MODULE_FIRMWARE(B43legacy_SUPPORTED_FIRMWARE_ID);
+
 #if defined(CONFIG_B43LEGACY_DMA) && defined(CONFIG_B43LEGACY_PIO)
 static int modparam_pio;
 module_param_named(pio, modparam_pio, int, 0444);
@@ -1640,10 +1642,11 @@ static int b43legacy_upload_microcode(struct b43legacy_wldev *dev)
 		err = -EOPNOTSUPP;
 		goto error;
 	}
-	b43legacydbg(dev->wl, "Loading firmware version 0x%X, patch level %u "
-	       "(20%.2i-%.2i-%.2i %.2i:%.2i:%.2i)\n", fwrev, fwpatch,
-	       (fwdate >> 12) & 0xF, (fwdate >> 8) & 0xF, fwdate & 0xFF,
-	       (fwtime >> 11) & 0x1F, (fwtime >> 5) & 0x3F, fwtime & 0x1F);
+	b43legacyinfo(dev->wl, "Loading firmware version 0x%X, patch level %u "
+		      "(20%.2i-%.2i-%.2i %.2i:%.2i:%.2i)\n", fwrev, fwpatch,
+		      (fwdate >> 12) & 0xF, (fwdate >> 8) & 0xF, fwdate & 0xFF,
+		      (fwtime >> 11) & 0x1F, (fwtime >> 5) & 0x3F,
+		      fwtime & 0x1F);
 
 	dev->fw.rev = fwrev;
 	dev->fw.patch = fwpatch;
@@ -3806,6 +3809,32 @@ static struct ssb_driver b43legacy_ssb_driver = {
 	.resume		= b43legacy_resume,
 };
 
+static void b43legacy_print_driverinfo(void)
+{
+	const char *feat_pci = "", *feat_leds = "", *feat_rfkill = "",
+		   *feat_pio = "", *feat_dma = "";
+
+#ifdef CONFIG_B43LEGACY_PCI_AUTOSELECT
+	feat_pci = "P";
+#endif
+#ifdef CONFIG_B43LEGACY_LEDS
+	feat_leds = "L";
+#endif
+#ifdef CONFIG_B43LEGACY_RFKILL
+	feat_rfkill = "R";
+#endif
+#ifdef CONFIG_B43LEGACY_PIO
+	feat_pio = "I";
+#endif
+#ifdef CONFIG_B43LEGACY_DMA
+	feat_dma = "D";
+#endif
+	printk(KERN_INFO "Broadcom 43xx driver loaded "
+	       "[ Features: %s%s%s%s%s, Firmware-ID: "
+	       B43legacy_SUPPORTED_FIRMWARE_ID " ]\n",
+	       feat_pci, feat_leds, feat_rfkill, feat_pio, feat_dma);
+}
+
 static int __init b43legacy_init(void)
 {
 	int err;
@@ -3816,6 +3845,8 @@ static int __init b43legacy_init(void)
 	if (err)
 		goto err_dfs_exit;
 
+	b43legacy_print_driverinfo();
+
 	return err;
 
 err_dfs_exit:
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 3e6ad7b..a56d9fc 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -3365,7 +3365,6 @@ static void ipw_rx_queue_reset(struct ipw_priv *priv,
 	/* Set us so that we have processed and used all buffers, but have
 	 * not restocked the Rx queue with fresh buffers */
 	rxq->read = rxq->write = 0;
-	rxq->processed = RX_QUEUE_SIZE - 1;
 	rxq->free_count = 0;
 	spin_unlock_irqrestore(&rxq->lock, flags);
 }
@@ -3607,7 +3606,22 @@ static int ipw_load(struct ipw_priv *priv)
  * Driver allocates buffers of this size for Rx
  */
 
-static inline int ipw_queue_space(const struct clx2_queue *q)
+/**
+ * ipw_rx_queue_space - Return number of free slots available in queue.
+ */
+static int ipw_rx_queue_space(const struct ipw_rx_queue *q)
+{
+	int s = q->read - q->write;
+	if (s <= 0)
+		s += RX_QUEUE_SIZE;
+	/* keep some buffer to not confuse full and empty queue */
+	s -= 2;
+	if (s < 0)
+		s = 0;
+	return s;
+}
+
+static inline int ipw_tx_queue_space(const struct clx2_queue *q)
 {
 	int s = q->last_used - q->first_empty;
 	if (s <= 0)
@@ -4947,7 +4961,7 @@ static int ipw_queue_tx_reclaim(struct ipw_priv *priv,
 		priv->tx_packets++;
 	}
       done:
-	if ((ipw_queue_space(q) > q->low_mark) &&
+	if ((ipw_tx_queue_space(q) > q->low_mark) &&
 	    (qindex >= 0) &&
 	    (priv->status & STATUS_ASSOCIATED) && netif_running(priv->net_dev))
 		netif_wake_queue(priv->net_dev);
@@ -4965,7 +4979,7 @@ static int ipw_queue_tx_hcmd(struct ipw_priv *priv, int hcmd, void *buf,
 	struct clx2_queue *q = &txq->q;
 	struct tfd_frame *tfd;
 
-	if (ipw_queue_space(q) < (sync ? 1 : 2)) {
+	if (ipw_tx_queue_space(q) < (sync ? 1 : 2)) {
 		IPW_ERROR("No space for Tx\n");
 		return -EBUSY;
 	}
@@ -5070,7 +5084,7 @@ static void ipw_rx_queue_restock(struct ipw_priv *priv)
 
 	spin_lock_irqsave(&rxq->lock, flags);
 	write = rxq->write;
-	while ((rxq->write != rxq->processed) && (rxq->free_count)) {
+	while ((ipw_rx_queue_space(rxq) > 0) && (rxq->free_count)) {
 		element = rxq->rx_free.next;
 		rxb = list_entry(element, struct ipw_rx_mem_buffer, list);
 		list_del(element);
@@ -5187,7 +5201,6 @@ static struct ipw_rx_queue *ipw_rx_queue_alloc(struct ipw_priv *priv)
 	/* Set us so that we have processed and used all buffers, but have
 	 * not restocked the Rx queue with fresh buffers */
 	rxq->read = rxq->write = 0;
-	rxq->processed = RX_QUEUE_SIZE - 1;
 	rxq->free_count = 0;
 
 	return rxq;
@@ -8223,13 +8236,17 @@ static void ipw_rx(struct ipw_priv *priv)
 	struct ieee80211_hdr_4addr *header;
 	u32 r, w, i;
 	u8 network_packet;
+	u8 fill_rx = 0;
 	DECLARE_MAC_BUF(mac);
 	DECLARE_MAC_BUF(mac2);
 	DECLARE_MAC_BUF(mac3);
 
 	r = ipw_read32(priv, IPW_RX_READ_INDEX);
 	w = ipw_read32(priv, IPW_RX_WRITE_INDEX);
-	i = (priv->rxq->processed + 1) % RX_QUEUE_SIZE;
+	i = priv->rxq->read;
+
+	if (ipw_rx_queue_space (priv->rxq) > (RX_QUEUE_SIZE / 2))
+		fill_rx = 1;
 
 	while (i != r) {
 		rxb = priv->rxq->queue[i];
@@ -8404,11 +8421,17 @@ static void ipw_rx(struct ipw_priv *priv)
 		list_add_tail(&rxb->list, &priv->rxq->rx_used);
 
 		i = (i + 1) % RX_QUEUE_SIZE;
+
+		/* If there are a lot of unsued frames, restock the Rx queue
+		 * so the ucode won't assert */
+		if (fill_rx) {
+			priv->rxq->read = i;
+			ipw_rx_queue_replenish(priv);
+		}
 	}
 
 	/* Backtrack one entry */
-	priv->rxq->processed = (i ? i : RX_QUEUE_SIZE) - 1;
-
+	priv->rxq->read = i;
 	ipw_rx_queue_restock(priv);
 }
 
@@ -10336,7 +10359,7 @@ static int ipw_tx_skb(struct ipw_priv *priv, struct ieee80211_txb *txb,
 	q->first_empty = ipw_queue_inc_wrap(q->first_empty, q->n_bd);
 	ipw_write32(priv, q->reg_w, q->first_empty);
 
-	if (ipw_queue_space(q) < q->high_mark)
+	if (ipw_tx_queue_space(q) < q->high_mark)
 		netif_stop_queue(priv->net_dev);
 
 	return NETDEV_TX_OK;
@@ -10357,7 +10380,7 @@ static int ipw_net_is_queue_full(struct net_device *dev, int pri)
 	struct clx2_tx_queue *txq = &priv->txq[0];
 #endif				/* CONFIG_IPW2200_QOS */
 
-	if (ipw_queue_space(&txq->q) < txq->q.high_mark)
+	if (ipw_tx_queue_space(&txq->q) < txq->q.high_mark)
 		return 1;
 
 	return 0;
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 5ee1ad6..40b71bc 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -687,6 +687,12 @@ static int iwl3945_enqueue_hcmd(struct iwl3945_priv *priv, struct iwl3945_host_c
 	BUG_ON((fix_size > TFD_MAX_PAYLOAD_SIZE) &&
 	       !(cmd->meta.flags & CMD_SIZE_HUGE));
 
+
+	if (iwl3945_is_rfkill(priv)) {
+		IWL_DEBUG_INFO("Not sending command - RF KILL");
+		return -EIO;
+	}
+
 	if (iwl3945_queue_space(q) < ((cmd->meta.flags & CMD_ASYNC) ? 2 : 1)) {
 		IWL_ERROR("No space for Tx\n");
 		return -ENOSPC;
@@ -1580,7 +1586,7 @@ static inline int iwl3945_eeprom_acquire_semaphore(struct iwl3945_priv *priv)
  */
 int iwl3945_eeprom_init(struct iwl3945_priv *priv)
 {
-	__le16 *e = (__le16 *)&priv->eeprom;
+	u16 *e = (u16 *)&priv->eeprom;
 	u32 gp = iwl3945_read32(priv, CSR_EEPROM_GP);
 	u32 r;
 	int sz = sizeof(priv->eeprom);
@@ -1623,7 +1629,7 @@ int iwl3945_eeprom_init(struct iwl3945_priv *priv)
 			IWL_ERROR("Time out reading EEPROM[%d]", addr);
 			return -ETIMEDOUT;
 		}
-		e[addr / 2] = cpu_to_le16(r >> 16);
+		e[addr / 2] = le16_to_cpu((__force __le16)(r >> 16));
 	}
 
 	return 0;
@@ -2806,7 +2812,8 @@ static int iwl3945_tx_skb(struct iwl3945_priv *priv,
 #endif
 
 	/* drop all data frame if we are not associated */
-	if ((!iwl3945_is_associated(priv) || !priv->assoc_id) &&
+	if ((!iwl3945_is_associated(priv) ||
+	     ((priv->iw_mode == IEEE80211_IF_TYPE_STA) && !priv->assoc_id)) &&
 	    ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA)) {
 		IWL_DEBUG_DROP("Dropping - !iwl3945_is_associated\n");
 		goto drop_unlock;
@@ -4281,7 +4288,7 @@ static void iwl3945_rx_handle(struct iwl3945_priv *priv)
 	int reclaim;
 	unsigned long flags;
 	u8 fill_rx = 0;
-	u32 count = 0;
+	u32 count = 8;
 
 	/* uCode's read index (stored in shared DRAM) indicates the last Rx
 	 * buffer that the driver may process (last buffer filled by ucode). */
@@ -6256,6 +6263,8 @@ static void __iwl3945_down(struct iwl3945_priv *priv)
 					STATUS_RF_KILL_HW |
 			       test_bit(STATUS_RF_KILL_SW, &priv->status) <<
 					STATUS_RF_KILL_SW |
+			       test_bit(STATUS_GEO_CONFIGURED, &priv->status) <<
+					STATUS_GEO_CONFIGURED |
 			       test_bit(STATUS_IN_SUSPEND, &priv->status) <<
 					STATUS_IN_SUSPEND;
 		goto exit;
@@ -6267,6 +6276,8 @@ static void __iwl3945_down(struct iwl3945_priv *priv)
 				STATUS_RF_KILL_HW |
 			test_bit(STATUS_RF_KILL_SW, &priv->status) <<
 				STATUS_RF_KILL_SW |
+			test_bit(STATUS_GEO_CONFIGURED, &priv->status) <<
+				STATUS_GEO_CONFIGURED |
 			test_bit(STATUS_IN_SUSPEND, &priv->status) <<
 				STATUS_IN_SUSPEND |
 			test_bit(STATUS_FW_ERROR, &priv->status) <<
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index f423241..a23d479 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -692,6 +692,11 @@ static int iwl4965_enqueue_hcmd(struct iwl4965_priv *priv, struct iwl4965_host_c
 	BUG_ON((fix_size > TFD_MAX_PAYLOAD_SIZE) &&
 	       !(cmd->meta.flags & CMD_SIZE_HUGE));
 
+	if (iwl4965_is_rfkill(priv)) {
+		IWL_DEBUG_INFO("Not sending command - RF KILL");
+		return -EIO;
+	}
+
 	if (iwl4965_queue_space(q) < ((cmd->meta.flags & CMD_ASYNC) ? 2 : 1)) {
 		IWL_ERROR("No space for Tx\n");
 		return -ENOSPC;
@@ -1654,7 +1659,7 @@ static inline void iwl4965_eeprom_release_semaphore(struct iwl4965_priv *priv)
  */
 int iwl4965_eeprom_init(struct iwl4965_priv *priv)
 {
-	__le16 *e = (__le16 *)&priv->eeprom;
+	u16 *e = (u16 *)&priv->eeprom;
 	u32 gp = iwl4965_read32(priv, CSR_EEPROM_GP);
 	u32 r;
 	int sz = sizeof(priv->eeprom);
@@ -1698,7 +1703,7 @@ int iwl4965_eeprom_init(struct iwl4965_priv *priv)
 			rc = -ETIMEDOUT;
 			goto done;
 		}
-		e[addr / 2] = cpu_to_le16(r >> 16);
+		e[addr / 2] = le16_to_cpu((__force __le16)(r >> 16));
 	}
 	rc = 0;
 
@@ -2935,7 +2940,7 @@ static int iwl4965_tx_skb(struct iwl4965_priv *priv,
 	/* drop all data frame if we are not associated */
 	if (((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA) &&
 	   (!iwl4965_is_associated(priv) ||
-	    !priv->assoc_id ||
+	    ((priv->iw_mode == IEEE80211_IF_TYPE_STA) && !priv->assoc_id) ||
 	    !priv->assoc_station_added)) {
 		IWL_DEBUG_DROP("Dropping - !iwl4965_is_associated\n");
 		goto drop_unlock;
@@ -4664,7 +4669,7 @@ static void iwl4965_rx_handle(struct iwl4965_priv *priv)
 	int reclaim;
 	unsigned long flags;
 	u8 fill_rx = 0;
-	u32 count = 0;
+	u32 count = 8;
 
 	/* uCode's read index (stored in shared DRAM) indicates the last Rx
 	 * buffer that the driver may process (last buffer filled by ucode). */
@@ -6680,6 +6685,8 @@ static void __iwl4965_down(struct iwl4965_priv *priv)
 					STATUS_RF_KILL_HW |
 			       test_bit(STATUS_RF_KILL_SW, &priv->status) <<
 					STATUS_RF_KILL_SW |
+			       test_bit(STATUS_GEO_CONFIGURED, &priv->status) <<
+					STATUS_GEO_CONFIGURED |
 			       test_bit(STATUS_IN_SUSPEND, &priv->status) <<
 					STATUS_IN_SUSPEND;
 		goto exit;
@@ -6691,6 +6698,8 @@ static void __iwl4965_down(struct iwl4965_priv *priv)
 				STATUS_RF_KILL_HW |
 			test_bit(STATUS_RF_KILL_SW, &priv->status) <<
 				STATUS_RF_KILL_SW |
+			test_bit(STATUS_GEO_CONFIGURED, &priv->status) <<
+				STATUS_GEO_CONFIGURED |
 			test_bit(STATUS_IN_SUSPEND, &priv->status) <<
 				STATUS_IN_SUSPEND |
 			test_bit(STATUS_FW_ERROR, &priv->status) <<
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index d3ecf89..8ce2ddf 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -2300,7 +2300,7 @@ static void rndis_update_wireless_stats(struct work_struct *work)
 	struct usbnet *usbdev = priv->usbdev;
 	struct iw_statistics iwstats;
 	__le32 rssi, tmp;
-	int len, ret, bitrate, j;
+	int len, ret, j;
 	unsigned long flags;
 	int update_jiffies = STATS_UPDATE_JIFFIES;
 	void *buf;
@@ -2352,14 +2352,10 @@ static void rndis_update_wireless_stats(struct work_struct *work)
 	if (ret == 0)
 		iwstats.discard.misc += le32_to_cpu(tmp);
 
-	/* Workaround transfer stalls on poor quality links. */
-	len = sizeof(tmp);
-	ret = rndis_query_oid(usbdev, OID_GEN_LINK_SPEED, &tmp, &len);
-	if (ret == 0) {
-		bitrate = le32_to_cpu(tmp) * 100;
-		if (bitrate > 11000000)
-			goto end;
-
+	/* Workaround transfer stalls on poor quality links.
+	 * TODO: find right way to fix these stalls (as stalls do not happen
+	 * with ndiswrapper/windows driver). */
+	if (iwstats.qual.qual <= 25) {
 		/* Decrease stats worker interval to catch stalls.
 		 * faster. Faster than 400-500ms causes packet loss,
 		 * Slower doesn't catch stalls fast enough.
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 86ded40..4ca9730 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -1839,11 +1839,11 @@ static struct usb_device_id rt2500usb_device_table[] = {
 	/* Hercules */
 	{ USB_DEVICE(0x06f8, 0xe000), USB_DEVICE_DATA(&rt2500usb_ops) },
 	/* Melco */
+	{ USB_DEVICE(0x0411, 0x005e), USB_DEVICE_DATA(&rt2500usb_ops) },
 	{ USB_DEVICE(0x0411, 0x0066), USB_DEVICE_DATA(&rt2500usb_ops) },
 	{ USB_DEVICE(0x0411, 0x0067), USB_DEVICE_DATA(&rt2500usb_ops) },
 	{ USB_DEVICE(0x0411, 0x008b), USB_DEVICE_DATA(&rt2500usb_ops) },
 	{ USB_DEVICE(0x0411, 0x0097), USB_DEVICE_DATA(&rt2500usb_ops) },
-
 	/* MSI */
 	{ USB_DEVICE(0x0db0, 0x6861), USB_DEVICE_DATA(&rt2500usb_ops) },
 	{ USB_DEVICE(0x0db0, 0x6865), USB_DEVICE_DATA(&rt2500usb_ops) },
diff --git a/drivers/net/wireless/wavelan.h b/drivers/net/wireless/wavelan.h
index 27172cd..9ab3605 100644
--- a/drivers/net/wireless/wavelan.h
+++ b/drivers/net/wireless/wavelan.h
@@ -85,7 +85,7 @@ union hacs_u
 #define		HASR_MMC_INTR		0x0002	/* Interrupt request from MMC */
 #define		HASR_MMC_BUSY		0x0004	/* MMC busy indication */
 #define		HASR_PSA_BUSY		0x0008	/* LAN parameter storage area busy */
-};
+} __attribute__ ((packed));
 
 typedef struct ha_t	ha_t;
 struct ha_t
@@ -292,7 +292,7 @@ struct mmw_t
 #define	MMW_EXT_ANT_INTERNAL	0x00	/* Internal antenna */
 #define	MMW_EXT_ANT_EXTERNAL	0x03	/* External antenna */
 #define	MMW_EXT_ANT_IQ_TEST	0x1C	/* IQ test pattern (set to 0) */
-};
+} __attribute__ ((packed));
 
 #define	MMW_SIZE	37
 
@@ -347,7 +347,7 @@ struct mmr_t
   unsigned char	mmr_unused4[1];		/* unused */
   unsigned char	mmr_fee_data_l;		/* Read data from EEPROM (low) */
   unsigned char	mmr_fee_data_h;		/* Read data from EEPROM (high) */
-};
+} __attribute__ ((packed));
 
 #define	MMR_SIZE	36
 
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 67b7c75..28bcdf9 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -165,6 +165,7 @@ static int ieee80211_open(struct net_device *dev)
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_if_init_conf conf;
 	int res;
+	bool need_hw_reconfig = 0;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
@@ -218,7 +219,7 @@ static int ieee80211_open(struct net_device *dev)
 			res = local->ops->start(local_to_hw(local));
 		if (res)
 			return res;
-		ieee80211_hw_config(local);
+		need_hw_reconfig = 1;
 		ieee80211_led_radio(local, local->hw.conf.radio_enabled);
 	}
 
@@ -282,6 +283,8 @@ static int ieee80211_open(struct net_device *dev)
 		atomic_inc(&local->iff_promiscs);
 
 	local->open_count++;
+	if (need_hw_reconfig)
+		ieee80211_hw_config(local);
 
 	netif_start_queue(dev);
 
-- 
John W. Linville
linville@tuxdriver.com
