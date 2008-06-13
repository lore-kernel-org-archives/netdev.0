From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-06-13
Date: Fri, 13 Jun 2008 16:57:29 -0400
Message-ID: <20080613205729.GA23676@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756766AbYFMVC5@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Another round of fixes intended for 2.6.26.  Please let me know if there
are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit ec0a196626bd12e0ba108d7daa6d95a4fb25c2c5:
  David S. Miller (1):
        tcp: Revert 'process defer accept as established' changes.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Abhijeet Kolekar (1):
      mac80211 : fix for iwconfig in ad-hoc mode

Gertjan van Wingerde (1):
      rt2x00: Restrict DMA to 32-bit addresses.

Ivo van Doorn (2):
      rt2x00: Don't kill guardian_urb when it wasn't created
      rt2x00: Add D-link DWA111 support

Michael Buesch (3):
      b43: Fix possible NULL pointer dereference in DMA code
      b43: Fix noise calculation WARN_ON
      ssb: Fix coherent DMA mask for PCI devices

Randy Dunlap (2):
      rt2x00: INPUT build failure
      rt2x00: LEDS build failure

Tomas Winkler (1):
      mac80211: add missing new line in debug print HT_DEBUG

 drivers/net/wireless/b43/b43.h          |    1 -
 drivers/net/wireless/b43/dma.c          |   65 +++++++++++++++----------------
 drivers/net/wireless/b43/main.c         |   16 +++++---
 drivers/net/wireless/rt2x00/Kconfig     |   19 +++++----
 drivers/net/wireless/rt2x00/rt2x00pci.c |    3 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c |    6 +++
 drivers/net/wireless/rt2x00/rt73usb.c   |    1 +
 drivers/ssb/main.c                      |   12 ++++-
 net/mac80211/wext.c                     |    3 +-
 net/mac80211/wme.c                      |    2 +-
 10 files changed, 72 insertions(+), 56 deletions(-)

diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index dfa4bdd..d3db298 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -630,7 +630,6 @@ struct b43_pio {
 
 /* Context information for a noise calculation (Link Quality). */
 struct b43_noise_calculation {
-	u8 channel_at_start;
 	bool calculation_running;
 	u8 nr_samples;
 	s8 samples[8][4];
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 6dcbb3c..e23f2f1 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -795,24 +795,49 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 {
 	struct b43_dmaring *ring;
 	int err;
-	int nr_slots;
 	dma_addr_t dma_test;
 
 	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 	if (!ring)
 		goto out;
-	ring->type = type;
 
-	nr_slots = B43_RXRING_SLOTS;
+	ring->nr_slots = B43_RXRING_SLOTS;
 	if (for_tx)
-		nr_slots = B43_TXRING_SLOTS;
+		ring->nr_slots = B43_TXRING_SLOTS;
 
-	ring->meta = kcalloc(nr_slots, sizeof(struct b43_dmadesc_meta),
+	ring->meta = kcalloc(ring->nr_slots, sizeof(struct b43_dmadesc_meta),
 			     GFP_KERNEL);
 	if (!ring->meta)
 		goto err_kfree_ring;
+
+	ring->type = type;
+	ring->dev = dev;
+	ring->mmio_base = b43_dmacontroller_base(type, controller_index);
+	ring->index = controller_index;
+	if (type == B43_DMA_64BIT)
+		ring->ops = &dma64_ops;
+	else
+		ring->ops = &dma32_ops;
 	if (for_tx) {
-		ring->txhdr_cache = kcalloc(nr_slots,
+		ring->tx = 1;
+		ring->current_slot = -1;
+	} else {
+		if (ring->index == 0) {
+			ring->rx_buffersize = B43_DMA0_RX_BUFFERSIZE;
+			ring->frameoffset = B43_DMA0_RX_FRAMEOFFSET;
+		} else if (ring->index == 3) {
+			ring->rx_buffersize = B43_DMA3_RX_BUFFERSIZE;
+			ring->frameoffset = B43_DMA3_RX_FRAMEOFFSET;
+		} else
+			B43_WARN_ON(1);
+	}
+	spin_lock_init(&ring->lock);
+#ifdef CONFIG_B43_DEBUG
+	ring->last_injected_overflow = jiffies;
+#endif
+
+	if (for_tx) {
+		ring->txhdr_cache = kcalloc(ring->nr_slots,
 					    b43_txhdr_size(dev),
 					    GFP_KERNEL);
 		if (!ring->txhdr_cache)
@@ -828,7 +853,7 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 					  b43_txhdr_size(dev), 1)) {
 			/* ugh realloc */
 			kfree(ring->txhdr_cache);
-			ring->txhdr_cache = kcalloc(nr_slots,
+			ring->txhdr_cache = kcalloc(ring->nr_slots,
 						    b43_txhdr_size(dev),
 						    GFP_KERNEL | GFP_DMA);
 			if (!ring->txhdr_cache)
@@ -853,32 +878,6 @@ struct b43_dmaring *b43_setup_dmaring(struct b43_wldev *dev,
 				 DMA_TO_DEVICE);
 	}
 
-	ring->dev = dev;
-	ring->nr_slots = nr_slots;
-	ring->mmio_base = b43_dmacontroller_base(type, controller_index);
-	ring->index = controller_index;
-	if (type == B43_DMA_64BIT)
-		ring->ops = &dma64_ops;
-	else
-		ring->ops = &dma32_ops;
-	if (for_tx) {
-		ring->tx = 1;
-		ring->current_slot = -1;
-	} else {
-		if (ring->index == 0) {
-			ring->rx_buffersize = B43_DMA0_RX_BUFFERSIZE;
-			ring->frameoffset = B43_DMA0_RX_FRAMEOFFSET;
-		} else if (ring->index == 3) {
-			ring->rx_buffersize = B43_DMA3_RX_BUFFERSIZE;
-			ring->frameoffset = B43_DMA3_RX_FRAMEOFFSET;
-		} else
-			B43_WARN_ON(1);
-	}
-	spin_lock_init(&ring->lock);
-#ifdef CONFIG_B43_DEBUG
-	ring->last_injected_overflow = jiffies;
-#endif
-
 	err = alloc_ringmemory(ring);
 	if (err)
 		goto err_kfree_txhdr_cache;
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 6c3d9ea..fa4b0d8 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -1145,7 +1145,6 @@ static void b43_generate_noise_sample(struct b43_wldev *dev)
 	b43_jssi_write(dev, 0x7F7F7F7F);
 	b43_write32(dev, B43_MMIO_MACCMD,
 		    b43_read32(dev, B43_MMIO_MACCMD) | B43_MACCMD_BGNOISE);
-	B43_WARN_ON(dev->noisecalc.channel_at_start != dev->phy.channel);
 }
 
 static void b43_calculate_link_quality(struct b43_wldev *dev)
@@ -1154,7 +1153,6 @@ static void b43_calculate_link_quality(struct b43_wldev *dev)
 
 	if (dev->noisecalc.calculation_running)
 		return;
-	dev->noisecalc.channel_at_start = dev->phy.channel;
 	dev->noisecalc.calculation_running = 1;
 	dev->noisecalc.nr_samples = 0;
 
@@ -1171,9 +1169,16 @@ static void handle_irq_noise(struct b43_wldev *dev)
 
 	/* Bottom half of Link Quality calculation. */
 
+	/* Possible race condition: It might be possible that the user
+	 * changed to a different channel in the meantime since we
+	 * started the calculation. We ignore that fact, since it's
+	 * not really that much of a problem. The background noise is
+	 * an estimation only anyway. Slightly wrong results will get damped
+	 * by the averaging of the 8 sample rounds. Additionally the
+	 * value is shortlived. So it will be replaced by the next noise
+	 * calculation round soon. */
+
 	B43_WARN_ON(!dev->noisecalc.calculation_running);
-	if (dev->noisecalc.channel_at_start != phy->channel)
-		goto drop_calculation;
 	*((__le32 *)noise) = cpu_to_le32(b43_jssi_read(dev));
 	if (noise[0] == 0x7F || noise[1] == 0x7F ||
 	    noise[2] == 0x7F || noise[3] == 0x7F)
@@ -1214,11 +1219,10 @@ static void handle_irq_noise(struct b43_wldev *dev)
 			average -= 48;
 
 		dev->stats.link_noise = average;
-	      drop_calculation:
 		dev->noisecalc.calculation_running = 0;
 		return;
 	}
-      generate_new:
+generate_new:
 	b43_generate_noise_sample(dev);
 }
 
diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/rt2x00/Kconfig
index ab1029e..2d61187 100644
--- a/drivers/net/wireless/rt2x00/Kconfig
+++ b/drivers/net/wireless/rt2x00/Kconfig
@@ -32,12 +32,13 @@ config RT2X00_LIB_FIRMWARE
 config RT2X00_LIB_RFKILL
 	boolean
 	depends on RT2X00_LIB
+	depends on INPUT
 	select RFKILL
 	select INPUT_POLLDEV
 
 config RT2X00_LIB_LEDS
 	boolean
-	depends on RT2X00_LIB
+	depends on RT2X00_LIB && NEW_LEDS
 
 config RT2400PCI
 	tristate "Ralink rt2400 pci/pcmcia support"
@@ -51,7 +52,7 @@ config RT2400PCI
 
 config RT2400PCI_RFKILL
 	bool "RT2400 rfkill support"
-	depends on RT2400PCI
+	depends on RT2400PCI && INPUT
 	select RT2X00_LIB_RFKILL
 	---help---
 	  This adds support for integrated rt2400 devices that feature a
@@ -60,7 +61,7 @@ config RT2400PCI_RFKILL
 
 config RT2400PCI_LEDS
 	bool "RT2400 leds support"
-	depends on RT2400PCI
+	depends on RT2400PCI && NEW_LEDS
 	select LEDS_CLASS
 	select RT2X00_LIB_LEDS
 	---help---
@@ -78,7 +79,7 @@ config RT2500PCI
 
 config RT2500PCI_RFKILL
 	bool "RT2500 rfkill support"
-	depends on RT2500PCI
+	depends on RT2500PCI && INPUT
 	select RT2X00_LIB_RFKILL
 	---help---
 	  This adds support for integrated rt2500 devices that feature a
@@ -87,7 +88,7 @@ config RT2500PCI_RFKILL
 
 config RT2500PCI_LEDS
 	bool "RT2500 leds support"
-	depends on RT2500PCI
+	depends on RT2500PCI && NEW_LEDS
 	select LEDS_CLASS
 	select RT2X00_LIB_LEDS
 	---help---
@@ -107,7 +108,7 @@ config RT61PCI
 
 config RT61PCI_RFKILL
 	bool "RT61 rfkill support"
-	depends on RT61PCI
+	depends on RT61PCI && INPUT
 	select RT2X00_LIB_RFKILL
 	---help---
 	  This adds support for integrated rt61 devices that feature a
@@ -116,7 +117,7 @@ config RT61PCI_RFKILL
 
 config RT61PCI_LEDS
 	bool "RT61 leds support"
-	depends on RT61PCI
+	depends on RT61PCI && NEW_LEDS
 	select LEDS_CLASS
 	select RT2X00_LIB_LEDS
 	---help---
@@ -133,7 +134,7 @@ config RT2500USB
 
 config RT2500USB_LEDS
 	bool "RT2500 leds support"
-	depends on RT2500USB
+	depends on RT2500USB && NEW_LEDS
 	select LEDS_CLASS
 	select RT2X00_LIB_LEDS
 	---help---
@@ -152,7 +153,7 @@ config RT73USB
 
 config RT73USB_LEDS
 	bool "RT73 leds support"
-	depends on RT73USB
+	depends on RT73USB && NEW_LEDS
 	select LEDS_CLASS
 	select RT2X00_LIB_LEDS
 	---help---
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index 971af25..60893de 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -412,8 +412,7 @@ int rt2x00pci_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	if (pci_set_mwi(pci_dev))
 		ERROR_PROBE("MWI not available.\n");
 
-	if (pci_set_dma_mask(pci_dev, DMA_64BIT_MASK) &&
-	    pci_set_dma_mask(pci_dev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pci_dev, DMA_32BIT_MASK)) {
 		ERROR_PROBE("PCI DMA not supported.\n");
 		retval = -EIO;
 		goto exit_disable_device;
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index 5a33167..e5ceae8 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -362,6 +362,12 @@ void rt2x00usb_disable_radio(struct rt2x00_dev *rt2x00dev)
 		}
 	}
 
+	/*
+	 * Kill guardian urb (if required by driver).
+	 */
+	if (!test_bit(DRIVER_REQUIRE_BEACON_GUARD, &rt2x00dev->flags))
+		return;
+
 	for (i = 0; i < rt2x00dev->bcn->limit; i++) {
 		priv_bcn = rt2x00dev->bcn->entries[i].priv_data;
 		usb_kill_urb(priv_bcn->urb);
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index da19a3a..fff8386 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2131,6 +2131,7 @@ static struct usb_device_id rt73usb_device_table[] = {
 	/* D-Link */
 	{ USB_DEVICE(0x07d1, 0x3c03), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x07d1, 0x3c04), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x07d1, 0x3c06), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x07d1, 0x3c07), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Gemtek */
 	{ USB_DEVICE(0x15a9, 0x0004), USB_DEVICE_DATA(&rt73usb_ops) },
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 7cf8851..d184f2a 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -1168,15 +1168,21 @@ EXPORT_SYMBOL(ssb_dma_translation);
 int ssb_dma_set_mask(struct ssb_device *ssb_dev, u64 mask)
 {
 	struct device *dma_dev = ssb_dev->dma_dev;
+	int err = 0;
 
 #ifdef CONFIG_SSB_PCIHOST
-	if (ssb_dev->bus->bustype == SSB_BUSTYPE_PCI)
-		return dma_set_mask(dma_dev, mask);
+	if (ssb_dev->bus->bustype == SSB_BUSTYPE_PCI) {
+		err = pci_set_dma_mask(ssb_dev->bus->host_pci, mask);
+		if (err)
+			return err;
+		err = pci_set_consistent_dma_mask(ssb_dev->bus->host_pci, mask);
+		return err;
+	}
 #endif
 	dma_dev->coherent_dma_mask = mask;
 	dma_dev->dma_mask = &dma_dev->coherent_dma_mask;
 
-	return 0;
+	return err;
 }
 EXPORT_SYMBOL(ssb_dma_set_mask);
 
diff --git a/net/mac80211/wext.c b/net/mac80211/wext.c
index a8bb8e3..6106cb7 100644
--- a/net/mac80211/wext.c
+++ b/net/mac80211/wext.c
@@ -496,7 +496,8 @@ static int ieee80211_ioctl_giwap(struct net_device *dev,
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->vif.type == IEEE80211_IF_TYPE_STA ||
 	    sdata->vif.type == IEEE80211_IF_TYPE_IBSS) {
-		if (sdata->u.sta.state == IEEE80211_ASSOCIATED) {
+		if (sdata->u.sta.state == IEEE80211_ASSOCIATED ||
+		    sdata->u.sta.state == IEEE80211_IBSS_JOINED) {
 			ap_addr->sa_family = ARPHRD_ETHER;
 			memcpy(&ap_addr->sa_data, sdata->u.sta.bssid, ETH_ALEN);
 			return 0;
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index dc1598b..635b996 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -673,7 +673,7 @@ int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
 #ifdef CONFIG_MAC80211_HT_DEBUG
 			if (net_ratelimit())
 				printk(KERN_DEBUG "allocated aggregation queue"
-					" %d tid %d addr %s pool=0x%lX",
+					" %d tid %d addr %s pool=0x%lX\n",
 					i, tid, print_mac(mac, sta->addr),
 					q->qdisc_pool[0]);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
-- 
John W. Linville
linville@tuxdriver.com
