From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2009-10-08
Date: Thu, 8 Oct 2009 18:34:54 -0400
Message-ID: <20091008223454.GB2798@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another batch of fixes intended for 2.6.32.  Most of them are
short, self-contained and more-or-less obvious.  Most of them have been
baking in -next for several days.

The b43 patch from Albert Herranz looks big, but most of it is moving a
structure definition within a header file.  It also changes some DMA
buffers from stack to heap allocation.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit a4d63a943735efa30270ce70716d43323fd40f02:
  Thomas Chou (1):
        ethoc: limit the number of buffers to 128

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Albert Herranz (1):
      b43: do not stack-allocate pio rx/tx header and tail buffers

Bjorn Helgaas (1):
      iwlwifi: use %pM for formatted MAC addresses

Jay Sternberg (1):
      iwlwifi: incorrect method used for finding valid OTP blocks

Johannes Berg (2):
      mac80211: fix vlan and optimise RX
      cfg80211: fix netns error unwinding bug

Larry Finger (1):
      b43: Fix PPC crash in rfkill polling on unload

Michael Buesch (2):
      b43: Don't use struct wldev after detach.
      b43: Protect sanity check against physical device removal

Reinette Chatre (2):
      iwlwifi: fix compile warning
      iwlagn: fix compile warning in iwl5000_gain_computation

Roel Kluin (2):
      mac80211: fix ADM8211_SYNCTL_RFtype define
      mac80211: use kfree_skb() to free struct sk_buff pointers

Wey-Yi Guy (1):
      iwlwifi: fix EEPROM enhance tx power offset

 drivers/net/wireless/adm8211.h              |    2 +-
 drivers/net/wireless/b43/b43.h              |  168 +++++++++++++++------------
 drivers/net/wireless/b43/leds.c             |    4 +-
 drivers/net/wireless/b43/leds.h             |    4 +-
 drivers/net/wireless/b43/main.c             |    7 +-
 drivers/net/wireless/b43/pio.c              |   78 ++++++------
 drivers/net/wireless/b43/xmit.c             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c   |   23 ++--
 drivers/net/wireless/iwlwifi/iwl-eeprom.h   |   20 ++--
 drivers/net/wireless/iwlwifi/iwl-rx.c       |    2 +-
 net/mac80211/rx.c                           |   10 ++-
 net/mac80211/sta_info.c                     |    2 +
 net/mac80211/tx.c                           |    3 +-
 net/mac80211/util.c                         |    4 +-
 net/wireless/nl80211.c                      |    3 +-
 19 files changed, 184 insertions(+), 156 deletions(-)

diff --git a/drivers/net/wireless/adm8211.h b/drivers/net/wireless/adm8211.h
index 4f6ab13..b07e4d3 100644
--- a/drivers/net/wireless/adm8211.h
+++ b/drivers/net/wireless/adm8211.h
@@ -266,7 +266,7 @@ do {								\
 #define ADM8211_SYNCTL_CS1	(1 << 28)
 #define ADM8211_SYNCTL_CAL	(1 << 27)
 #define ADM8211_SYNCTL_SELCAL	(1 << 26)
-#define ADM8211_SYNCTL_RFtype	((1 << 24) || (1 << 23) || (1 << 22))
+#define ADM8211_SYNCTL_RFtype	((1 << 24) | (1 << 23) | (1 << 22))
 #define ADM8211_SYNCTL_RFMD	(1 << 22)
 #define ADM8211_SYNCTL_GENERAL	(0x7 << 22)
 /* SYNCTL 21:0 Data (Si4126: 18-bit data, 4-bit address) */
diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index fa1549a..6607162 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -607,82 +607,7 @@ struct b43_qos_params {
 	struct ieee80211_tx_queue_params p;
 };
 
-struct b43_wldev;
-
-/* Data structure for the WLAN parts (802.11 cores) of the b43 chip. */
-struct b43_wl {
-	/* Pointer to the active wireless device on this chip */
-	struct b43_wldev *current_dev;
-	/* Pointer to the ieee80211 hardware data structure */
-	struct ieee80211_hw *hw;
-
-	/* Global driver mutex. Every operation must run with this mutex locked. */
-	struct mutex mutex;
-	/* Hard-IRQ spinlock. This lock protects things used in the hard-IRQ
-	 * handler, only. This basically is just the IRQ mask register. */
-	spinlock_t hardirq_lock;
-
-	/* The number of queues that were registered with the mac80211 subsystem
-	 * initially. This is a backup copy of hw->queues in case hw->queues has
-	 * to be dynamically lowered at runtime (Firmware does not support QoS).
-	 * hw->queues has to be restored to the original value before unregistering
-	 * from the mac80211 subsystem. */
-	u16 mac80211_initially_registered_queues;
-
-	/* We can only have one operating interface (802.11 core)
-	 * at a time. General information about this interface follows.
-	 */
-
-	struct ieee80211_vif *vif;
-	/* The MAC address of the operating interface. */
-	u8 mac_addr[ETH_ALEN];
-	/* Current BSSID */
-	u8 bssid[ETH_ALEN];
-	/* Interface type. (NL80211_IFTYPE_XXX) */
-	int if_type;
-	/* Is the card operating in AP, STA or IBSS mode? */
-	bool operating;
-	/* filter flags */
-	unsigned int filter_flags;
-	/* Stats about the wireless interface */
-	struct ieee80211_low_level_stats ieee_stats;
-
-#ifdef CONFIG_B43_HWRNG
-	struct hwrng rng;
-	bool rng_initialized;
-	char rng_name[30 + 1];
-#endif /* CONFIG_B43_HWRNG */
-
-	/* List of all wireless devices on this chip */
-	struct list_head devlist;
-	u8 nr_devs;
-
-	bool radiotap_enabled;
-	bool radio_enabled;
-
-	/* The beacon we are currently using (AP or IBSS mode). */
-	struct sk_buff *current_beacon;
-	bool beacon0_uploaded;
-	bool beacon1_uploaded;
-	bool beacon_templates_virgin; /* Never wrote the templates? */
-	struct work_struct beacon_update_trigger;
-
-	/* The current QOS parameters for the 4 queues. */
-	struct b43_qos_params qos_params[4];
-
-	/* Work for adjustment of the transmission power.
-	 * This is scheduled when we determine that the actual TX output
-	 * power doesn't match what we want. */
-	struct work_struct txpower_adjust_work;
-
-	/* Packet transmit work */
-	struct work_struct tx_work;
-	/* Queue of packets to be transmitted. */
-	struct sk_buff_head tx_queue;
-
-	/* The device LEDs. */
-	struct b43_leds leds;
-};
+struct b43_wl;
 
 /* The type of the firmware file. */
 enum b43_firmware_file_type {
@@ -824,6 +749,97 @@ struct b43_wldev {
 #endif
 };
 
+/*
+ * Include goes here to avoid a dependency problem.
+ * A better fix would be to integrate xmit.h into b43.h.
+ */
+#include "xmit.h"
+
+/* Data structure for the WLAN parts (802.11 cores) of the b43 chip. */
+struct b43_wl {
+	/* Pointer to the active wireless device on this chip */
+	struct b43_wldev *current_dev;
+	/* Pointer to the ieee80211 hardware data structure */
+	struct ieee80211_hw *hw;
+
+	/* Global driver mutex. Every operation must run with this mutex locked. */
+	struct mutex mutex;
+	/* Hard-IRQ spinlock. This lock protects things used in the hard-IRQ
+	 * handler, only. This basically is just the IRQ mask register. */
+	spinlock_t hardirq_lock;
+
+	/* The number of queues that were registered with the mac80211 subsystem
+	 * initially. This is a backup copy of hw->queues in case hw->queues has
+	 * to be dynamically lowered at runtime (Firmware does not support QoS).
+	 * hw->queues has to be restored to the original value before unregistering
+	 * from the mac80211 subsystem. */
+	u16 mac80211_initially_registered_queues;
+
+	/* We can only have one operating interface (802.11 core)
+	 * at a time. General information about this interface follows.
+	 */
+
+	struct ieee80211_vif *vif;
+	/* The MAC address of the operating interface. */
+	u8 mac_addr[ETH_ALEN];
+	/* Current BSSID */
+	u8 bssid[ETH_ALEN];
+	/* Interface type. (NL80211_IFTYPE_XXX) */
+	int if_type;
+	/* Is the card operating in AP, STA or IBSS mode? */
+	bool operating;
+	/* filter flags */
+	unsigned int filter_flags;
+	/* Stats about the wireless interface */
+	struct ieee80211_low_level_stats ieee_stats;
+
+#ifdef CONFIG_B43_HWRNG
+	struct hwrng rng;
+	bool rng_initialized;
+	char rng_name[30 + 1];
+#endif /* CONFIG_B43_HWRNG */
+
+	/* List of all wireless devices on this chip */
+	struct list_head devlist;
+	u8 nr_devs;
+
+	bool radiotap_enabled;
+	bool radio_enabled;
+
+	/* The beacon we are currently using (AP or IBSS mode). */
+	struct sk_buff *current_beacon;
+	bool beacon0_uploaded;
+	bool beacon1_uploaded;
+	bool beacon_templates_virgin; /* Never wrote the templates? */
+	struct work_struct beacon_update_trigger;
+
+	/* The current QOS parameters for the 4 queues. */
+	struct b43_qos_params qos_params[4];
+
+	/* Work for adjustment of the transmission power.
+	 * This is scheduled when we determine that the actual TX output
+	 * power doesn't match what we want. */
+	struct work_struct txpower_adjust_work;
+
+	/* Packet transmit work */
+	struct work_struct tx_work;
+	/* Queue of packets to be transmitted. */
+	struct sk_buff_head tx_queue;
+
+	/* The device LEDs. */
+	struct b43_leds leds;
+
+#ifdef CONFIG_B43_PIO
+	/*
+	 * RX/TX header/tail buffers used by the frame transmit functions.
+	 */
+	struct b43_rxhdr_fw4 rxhdr;
+	struct b43_txhdr txhdr;
+	u8 rx_tail[4];
+	u8 tx_tail[4];
+#endif /* CONFIG_B43_PIO */
+};
+
 static inline struct b43_wl *hw_to_b43_wl(struct ieee80211_hw *hw)
 {
 	return hw->priv;
diff --git a/drivers/net/wireless/b43/leds.c b/drivers/net/wireless/b43/leds.c
index fbe3d4f..1e8dba4 100644
--- a/drivers/net/wireless/b43/leds.c
+++ b/drivers/net/wireless/b43/leds.c
@@ -348,9 +348,9 @@ void b43_leds_register(struct b43_wldev *dev)
 	}
 }
 
-void b43_leds_unregister(struct b43_wldev *dev)
+void b43_leds_unregister(struct b43_wl *wl)
 {
-	struct b43_leds *leds = &dev->wl->leds;
+	struct b43_leds *leds = &wl->leds;
 
 	b43_unregister_led(&leds->led_tx);
 	b43_unregister_led(&leds->led_rx);
diff --git a/drivers/net/wireless/b43/leds.h b/drivers/net/wireless/b43/leds.h
index 9592e4c..4c56187 100644
--- a/drivers/net/wireless/b43/leds.h
+++ b/drivers/net/wireless/b43/leds.h
@@ -60,7 +60,7 @@ enum b43_led_behaviour {
 };
 
 void b43_leds_register(struct b43_wldev *dev);
-void b43_leds_unregister(struct b43_wldev *dev);
+void b43_leds_unregister(struct b43_wl *wl);
 void b43_leds_init(struct b43_wldev *dev);
 void b43_leds_exit(struct b43_wldev *dev);
 void b43_leds_stop(struct b43_wldev *dev);
@@ -76,7 +76,7 @@ struct b43_leds {
 static inline void b43_leds_register(struct b43_wldev *dev)
 {
 }
-static inline void b43_leds_unregister(struct b43_wldev *dev)
+static inline void b43_leds_unregister(struct b43_wl *wl)
 {
 }
 static inline void b43_leds_init(struct b43_wldev *dev)
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 9b907a3..df6b26a 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -3874,6 +3874,7 @@ static struct b43_wldev * b43_wireless_core_stop(struct b43_wldev *dev)
 {
 	struct b43_wl *wl = dev->wl;
 	struct b43_wldev *orig_dev;
+	u32 mask;
 
 redo:
 	if (!dev || b43_status(dev) < B43_STAT_STARTED)
@@ -3920,7 +3921,8 @@ redo:
 			goto redo;
 		return dev;
 	}
-	B43_WARN_ON(b43_read32(dev, B43_MMIO_GEN_IRQ_MASK));
+	mask = b43_read32(dev, B43_MMIO_GEN_IRQ_MASK);
+	B43_WARN_ON(mask != 0xFFFFFFFF && mask);
 
 	/* Drain the TX queue */
 	while (skb_queue_len(&wl->tx_queue))
@@ -4499,6 +4501,7 @@ static void b43_op_stop(struct ieee80211_hw *hw)
 
 	cancel_work_sync(&(wl->beacon_update_trigger));
 
+	wiphy_rfkill_stop_polling(hw->wiphy);
 	mutex_lock(&wl->mutex);
 	if (b43_status(dev) >= B43_STAT_STARTED) {
 		dev = b43_wireless_core_stop(dev);
@@ -4997,7 +5000,7 @@ static void b43_remove(struct ssb_device *dev)
 
 	if (list_empty(&wl->devlist)) {
 		b43_rng_exit(wl);
-		b43_leds_unregister(wldev);
+		b43_leds_unregister(wl);
 		/* Last core on the chip unregistered.
 		 * We can destroy common struct b43_wl.
 		 */
diff --git a/drivers/net/wireless/b43/pio.c b/drivers/net/wireless/b43/pio.c
index 9c13979..dbbf0d1 100644
--- a/drivers/net/wireless/b43/pio.c
+++ b/drivers/net/wireless/b43/pio.c
@@ -331,6 +331,7 @@ static u16 tx_write_2byte_queue(struct b43_pio_txqueue *q,
 				unsigned int data_len)
 {
 	struct b43_wldev *dev = q->dev;
+	struct b43_wl *wl = dev->wl;
 	const u8 *data = _data;
 
 	ctl |= B43_PIO_TXCTL_WRITELO | B43_PIO_TXCTL_WRITEHI;
@@ -340,13 +341,12 @@ static u16 tx_write_2byte_queue(struct b43_pio_txqueue *q,
 			q->mmio_base + B43_PIO_TXDATA,
 			sizeof(u16));
 	if (data_len & 1) {
-		u8 tail[2] = { 0, };
-
 		/* Write the last byte. */
 		ctl &= ~B43_PIO_TXCTL_WRITEHI;
 		b43_piotx_write16(q, B43_PIO_TXCTL, ctl);
-		tail[0] = data[data_len - 1];
-		ssb_block_write(dev->dev, tail, 2,
+		wl->tx_tail[0] = data[data_len - 1];
+		wl->tx_tail[1] = 0;
+		ssb_block_write(dev->dev, wl->tx_tail, 2,
 				q->mmio_base + B43_PIO_TXDATA,
 				sizeof(u16));
 	}
@@ -381,6 +381,7 @@ static u32 tx_write_4byte_queue(struct b43_pio_txqueue *q,
 				unsigned int data_len)
 {
 	struct b43_wldev *dev = q->dev;
+	struct b43_wl *wl = dev->wl;
 	const u8 *data = _data;
 
 	ctl |= B43_PIO8_TXCTL_0_7 | B43_PIO8_TXCTL_8_15 |
@@ -391,29 +392,31 @@ static u32 tx_write_4byte_queue(struct b43_pio_txqueue *q,
 			q->mmio_base + B43_PIO8_TXDATA,
 			sizeof(u32));
 	if (data_len & 3) {
-		u8 tail[4] = { 0, };
-
+		wl->tx_tail[3] = 0;
 		/* Write the last few bytes. */
 		ctl &= ~(B43_PIO8_TXCTL_8_15 | B43_PIO8_TXCTL_16_23 |
 			 B43_PIO8_TXCTL_24_31);
 		switch (data_len & 3) {
 		case 3:
 			ctl |= B43_PIO8_TXCTL_16_23 | B43_PIO8_TXCTL_8_15;
-			tail[0] = data[data_len - 3];
-			tail[1] = data[data_len - 2];
-			tail[2] = data[data_len - 1];
+			wl->tx_tail[0] = data[data_len - 3];
+			wl->tx_tail[1] = data[data_len - 2];
+			wl->tx_tail[2] = data[data_len - 1];
 			break;
 		case 2:
 			ctl |= B43_PIO8_TXCTL_8_15;
-			tail[0] = data[data_len - 2];
-			tail[1] = data[data_len - 1];
+			wl->tx_tail[0] = data[data_len - 2];
+			wl->tx_tail[1] = data[data_len - 1];
+			wl->tx_tail[2] = 0;
 			break;
 		case 1:
-			tail[0] = data[data_len - 1];
+			wl->tx_tail[0] = data[data_len - 1];
+			wl->tx_tail[1] = 0;
+			wl->tx_tail[2] = 0;
 			break;
 		}
 		b43_piotx_write32(q, B43_PIO8_TXCTL, ctl);
-		ssb_block_write(dev->dev, tail, 4,
+		ssb_block_write(dev->dev, wl->tx_tail, 4,
 				q->mmio_base + B43_PIO8_TXDATA,
 				sizeof(u32));
 	}
@@ -445,8 +448,9 @@ static void pio_tx_frame_4byte_queue(struct b43_pio_txpacket *pack,
 static int pio_tx_frame(struct b43_pio_txqueue *q,
 			struct sk_buff *skb)
 {
+	struct b43_wldev *dev = q->dev;
+	struct b43_wl *wl = dev->wl;
 	struct b43_pio_txpacket *pack;
-	struct b43_txhdr txhdr;
 	u16 cookie;
 	int err;
 	unsigned int hdrlen;
@@ -457,8 +461,8 @@ static int pio_tx_frame(struct b43_pio_txqueue *q,
 			  struct b43_pio_txpacket, list);
 
 	cookie = generate_cookie(q, pack);
-	hdrlen = b43_txhdr_size(q->dev);
-	err = b43_generate_txhdr(q->dev, (u8 *)&txhdr, skb,
+	hdrlen = b43_txhdr_size(dev);
+	err = b43_generate_txhdr(dev, (u8 *)&wl->txhdr, skb,
 				 info, cookie);
 	if (err)
 		return err;
@@ -466,15 +470,15 @@ static int pio_tx_frame(struct b43_pio_txqueue *q,
 	if (info->flags & IEEE80211_TX_CTL_SEND_AFTER_DTIM) {
 		/* Tell the firmware about the cookie of the last
 		 * mcast frame, so it can clear the more-data bit in it. */
-		b43_shm_write16(q->dev, B43_SHM_SHARED,
+		b43_shm_write16(dev, B43_SHM_SHARED,
 				B43_SHM_SH_MCASTCOOKIE, cookie);
 	}
 
 	pack->skb = skb;
 	if (q->rev >= 8)
-		pio_tx_frame_4byte_queue(pack, (const u8 *)&txhdr, hdrlen);
+		pio_tx_frame_4byte_queue(pack, (const u8 *)&wl->txhdr, hdrlen);
 	else
-		pio_tx_frame_2byte_queue(pack, (const u8 *)&txhdr, hdrlen);
+		pio_tx_frame_2byte_queue(pack, (const u8 *)&wl->txhdr, hdrlen);
 
 	/* Remove it from the list of available packet slots.
 	 * It will be put back when we receive the status report. */
@@ -614,14 +618,14 @@ void b43_pio_get_tx_stats(struct b43_wldev *dev,
 static bool pio_rx_frame(struct b43_pio_rxqueue *q)
 {
 	struct b43_wldev *dev = q->dev;
-	struct b43_rxhdr_fw4 rxhdr;
+	struct b43_wl *wl = dev->wl;
 	u16 len;
 	u32 macstat;
 	unsigned int i, padding;
 	struct sk_buff *skb;
 	const char *err_msg = NULL;
 
-	memset(&rxhdr, 0, sizeof(rxhdr));
+	memset(&wl->rxhdr, 0, sizeof(wl->rxhdr));
 
 	/* Check if we have data and wait for it to get ready. */
 	if (q->rev >= 8) {
@@ -659,16 +663,16 @@ data_ready:
 
 	/* Get the preamble (RX header) */
 	if (q->rev >= 8) {
-		ssb_block_read(dev->dev, &rxhdr, sizeof(rxhdr),
+		ssb_block_read(dev->dev, &wl->rxhdr, sizeof(wl->rxhdr),
 			       q->mmio_base + B43_PIO8_RXDATA,
 			       sizeof(u32));
 	} else {
-		ssb_block_read(dev->dev, &rxhdr, sizeof(rxhdr),
+		ssb_block_read(dev->dev, &wl->rxhdr, sizeof(wl->rxhdr),
 			       q->mmio_base + B43_PIO_RXDATA,
 			       sizeof(u16));
 	}
 	/* Sanity checks. */
-	len = le16_to_cpu(rxhdr.frame_len);
+	len = le16_to_cpu(wl->rxhdr.frame_len);
 	if (unlikely(len > 0x700)) {
 		err_msg = "len > 0x700";
 		goto rx_error;
@@ -678,7 +682,7 @@ data_ready:
 		goto rx_error;
 	}
 
-	macstat = le32_to_cpu(rxhdr.mac_status);
+	macstat = le32_to_cpu(wl->rxhdr.mac_status);
 	if (macstat & B43_RX_MAC_FCSERR) {
 		if (!(q->dev->wl->filter_flags & FIF_FCSFAIL)) {
 			/* Drop frames with failed FCS. */
@@ -703,24 +707,22 @@ data_ready:
 			       q->mmio_base + B43_PIO8_RXDATA,
 			       sizeof(u32));
 		if (len & 3) {
-			u8 tail[4] = { 0, };
-
 			/* Read the last few bytes. */
-			ssb_block_read(dev->dev, tail, 4,
+			ssb_block_read(dev->dev, wl->rx_tail, 4,
 				       q->mmio_base + B43_PIO8_RXDATA,
 				       sizeof(u32));
 			switch (len & 3) {
 			case 3:
-				skb->data[len + padding - 3] = tail[0];
-				skb->data[len + padding - 2] = tail[1];
-				skb->data[len + padding - 1] = tail[2];
+				skb->data[len + padding - 3] = wl->rx_tail[0];
+				skb->data[len + padding - 2] = wl->rx_tail[1];
+				skb->data[len + padding - 1] = wl->rx_tail[2];
 				break;
 			case 2:
-				skb->data[len + padding - 2] = tail[0];
-				skb->data[len + padding - 1] = tail[1];
+				skb->data[len + padding - 2] = wl->rx_tail[0];
+				skb->data[len + padding - 1] = wl->rx_tail[1];
 				break;
 			case 1:
-				skb->data[len + padding - 1] = tail[0];
+				skb->data[len + padding - 1] = wl->rx_tail[0];
 				break;
 			}
 		}
@@ -729,17 +731,15 @@ data_ready:
 			       q->mmio_base + B43_PIO_RXDATA,
 			       sizeof(u16));
 		if (len & 1) {
-			u8 tail[2] = { 0, };
-
 			/* Read the last byte. */
-			ssb_block_read(dev->dev, tail, 2,
+			ssb_block_read(dev->dev, wl->rx_tail, 2,
 				       q->mmio_base + B43_PIO_RXDATA,
 				       sizeof(u16));
-			skb->data[len + padding - 1] = tail[0];
+			skb->data[len + padding - 1] = wl->rx_tail[0];
 		}
 	}
 
-	b43_rx(q->dev, skb, &rxhdr);
+	b43_rx(q->dev, skb, &wl->rxhdr);
 
 	return 1;
 
diff --git a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/b43/xmit.c
index ac9f600..892573b 100644
--- a/drivers/net/wireless/b43/xmit.c
+++ b/drivers/net/wireless/b43/xmit.c
@@ -27,7 +27,7 @@
 
 */
 
-#include "xmit.h"
+#include "b43.h"
 #include "phy_common.h"
 #include "dma.h"
 #include "pio.h"
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
index a16bd41..cbb0585 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
@@ -702,7 +702,7 @@ static void rs_get_rate(void *priv_r, struct ieee80211_sta *sta,
 		u8 sta_id = iwl_find_station(priv, hdr->addr1);
 
 		if (sta_id == IWL_INVALID_STATION) {
-			IWL_DEBUG_RATE(priv, "LQ: ADD station %pm\n",
+			IWL_DEBUG_RATE(priv, "LQ: ADD station %pM\n",
 				       hdr->addr1);
 			sta_id = iwl_add_station(priv, hdr->addr1, false,
 				CMD_ASYNC, NULL);
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index e70c5b0..231c833 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -610,7 +610,7 @@ static void iwl3945_rx_reply_rx(struct iwl_priv *priv,
 	if (rx_status.band == IEEE80211_BAND_5GHZ)
 		rx_status.rate_idx -= IWL_FIRST_OFDM_RATE;
 
-	rx_status.antenna = le16_to_cpu(rx_hdr->phy_flags &
+	rx_status.antenna = (le16_to_cpu(rx_hdr->phy_flags) &
 					RX_RES_PHY_FLAGS_ANTENNA_MSK) >> 4;
 
 	/* set the preamble flag if appropriate */
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index eb08f44..524e7e4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -317,7 +317,7 @@ static void iwl5000_gain_computation(struct iwl_priv *priv,
 			(s32)average_noise[i])) / 1500;
 		/* bound gain by 2 bits value max, 3rd bit is sign */
 		data->delta_gain_code[i] =
-			min(abs(delta_g), CHAIN_NOISE_MAX_DELTA_GAIN_CODE);
+			min(abs(delta_g), (long) CHAIN_NOISE_MAX_DELTA_GAIN_CODE);
 
 		if (delta_g < 0)
 			/* set negative sign */
diff --git a/drivers/net/wireless/iwlwifi/iwl-commands.h b/drivers/net/wireless/iwlwifi/iwl-commands.h
index 2c5c88f..4afaf77 100644
--- a/drivers/net/wireless/iwlwifi/iwl-commands.h
+++ b/drivers/net/wireless/iwlwifi/iwl-commands.h
@@ -1154,7 +1154,7 @@ struct iwl_wep_cmd {
 #define RX_RES_PHY_FLAGS_MOD_CCK_MSK		cpu_to_le16(1 << 1)
 #define RX_RES_PHY_FLAGS_SHORT_PREAMBLE_MSK	cpu_to_le16(1 << 2)
 #define RX_RES_PHY_FLAGS_NARROW_BAND_MSK	cpu_to_le16(1 << 3)
-#define RX_RES_PHY_FLAGS_ANTENNA_MSK		cpu_to_le16(0xf0)
+#define RX_RES_PHY_FLAGS_ANTENNA_MSK		0xf0
 #define RX_RES_PHY_FLAGS_ANTENNA_POS		4
 
 #define RX_RES_STATUS_SEC_TYPE_MSK	(0x7 << 8)
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom.c b/drivers/net/wireless/iwlwifi/iwl-eeprom.c
index 3d2b93a..e14c995 100644
--- a/drivers/net/wireless/iwlwifi/iwl-eeprom.c
+++ b/drivers/net/wireless/iwlwifi/iwl-eeprom.c
@@ -410,7 +410,6 @@ static int iwl_find_otp_image(struct iwl_priv *priv,
 					u16 *validblockaddr)
 {
 	u16 next_link_addr = 0, link_value = 0, valid_addr;
-	int ret = 0;
 	int usedblocks = 0;
 
 	/* set addressing mode to absolute to traverse the link list */
@@ -430,29 +429,29 @@ static int iwl_find_otp_image(struct iwl_priv *priv,
 		 * check for more block on the link list
 		 */
 		valid_addr = next_link_addr;
-		next_link_addr = link_value;
+		next_link_addr = link_value * sizeof(u16);
 		IWL_DEBUG_INFO(priv, "OTP blocks %d addr 0x%x\n",
 			       usedblocks, next_link_addr);
 		if (iwl_read_otp_word(priv, next_link_addr, &link_value))
 			return -EINVAL;
 		if (!link_value) {
 			/*
-			 * reach the end of link list,
+			 * reach the end of link list, return success and
 			 * set address point to the starting address
 			 * of the image
 			 */
-			goto done;
+			*validblockaddr = valid_addr;
+			/* skip first 2 bytes (link list pointer) */
+			*validblockaddr += 2;
+			return 0;
 		}
 		/* more in the link list, continue */
 		usedblocks++;
-	} while (usedblocks < priv->cfg->max_ll_items);
-	/* OTP full, use last block */
-	IWL_DEBUG_INFO(priv, "OTP is full, use last block\n");
-done:
-	*validblockaddr = valid_addr;
-	/* skip first 2 bytes (link list pointer) */
-	*validblockaddr += 2;
-	return ret;
+	} while (usedblocks <= priv->cfg->max_ll_items);
+
+	/* OTP has no valid blocks */
+	IWL_DEBUG_INFO(priv, "OTP has no valid blocks\n");
+	return -EINVAL;
 }
 
 /**
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom.h b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
index 6b68db7..80b9e45 100644
--- a/drivers/net/wireless/iwlwifi/iwl-eeprom.h
+++ b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
@@ -220,35 +220,35 @@ struct iwl_eeprom_enhanced_txpwr {
  * Section 10: 2.4 GHz 40MHz channels: 132, 44 (_above_)
  */
 /* 2.4 GHz band: CCK */
-#define EEPROM_LB_CCK_20_COMMON       ((0xAA)\
+#define EEPROM_LB_CCK_20_COMMON       ((0xA8)\
 		| INDIRECT_ADDRESS | INDIRECT_REGULATORY)   /* 8 bytes */
 /* 2.4 GHz band: 20MHz-Legacy, 20MHz-HT, 40MHz-HT */
-#define EEPROM_LB_OFDM_COMMON       ((0xB2)\
+#define EEPROM_LB_OFDM_COMMON       ((0xB0)\
 		| INDIRECT_ADDRESS | INDIRECT_REGULATORY)   /* 24 bytes */
 /* 5.2 GHz band: 20MHz-Legacy, 20MHz-HT, 40MHz-HT */
-#define EEPROM_HB_OFDM_COMMON       ((0xCA)\
+#define EEPROM_HB_OFDM_COMMON       ((0xC8)\
 		| INDIRECT_ADDRESS | INDIRECT_REGULATORY)   /* 24 bytes */
 /* 2.4GHz band channels:
  *	1Legacy, 1HT, 2Legacy, 2HT, 10Legacy, 10HT, 11Legacy, 11HT */
-#define EEPROM_LB_OFDM_20_BAND       ((0xE2)\
+#define EEPROM_LB_OFDM_20_BAND       ((0xE0)\
 		| INDIRECT_ADDRESS | INDIRECT_REGULATORY)   /* 64 bytes */
 /* 2.4 GHz band HT40 channels: (1,+1) (2,+1) (6,+1) (7,+1) (9,+1) */
-#define EEPROM_LB_OFDM_HT40_BAND       ((0x122)\
+#define EEPROM_LB_OFDM_HT40_BAND       ((0x120)\
 		| INDIRECT_ADDRESS | INDIRECT_REGULATORY)   /* 40 bytes */
 /* 5.2GHz band channels: 36Legacy, 36HT, 64Legacy, 64HT, 100Legacy, 100HT */
-#define EEPROM_HB_OFDM_20_BAND       ((0x14A)\
+#define EEPROM_HB_OFDM_20_BAND       ((0x148)\
 		| INDIRECT_ADDRESS | INDIRECT_REGULATORY)   /* 48 bytes */
 /* 5.2 GHz band HT40 channels: (36,+1) (60,+1) (100,+1) */
-#define EEPROM_HB_OFDM_HT40_BAND       ((0x17A)\
+#define EEPROM_HB_OFDM_HT40_BAND       ((0x178)\
 		| INDIRECT_ADDRESS | INDIRECT_REGULATORY)   /* 24 bytes */
 /* 2.4 GHz band, channnel 13: Legacy, HT */
-#define EEPROM_LB_OFDM_20_CHANNEL_13       ((0x192)\
+#define EEPROM_LB_OFDM_20_CHANNEL_13       ((0x190)\
 		| INDIRECT_ADDRESS | INDIRECT_REGULATORY)   /* 16 bytes */
 /* 5.2 GHz band, channnel 140: Legacy, HT */
-#define EEPROM_HB_OFDM_20_CHANNEL_140       ((0x1A2)\
+#define EEPROM_HB_OFDM_20_CHANNEL_140       ((0x1A0)\
 		| INDIRECT_ADDRESS | INDIRECT_REGULATORY)   /* 16 bytes */
 /* 5.2 GHz band, HT40 channnels (132,+1) (44,+1) */
-#define EEPROM_HB_OFDM_HT40_BAND_1       ((0x1B2)\
+#define EEPROM_HB_OFDM_HT40_BAND_1       ((0x1B0)\
 		| INDIRECT_ADDRESS | INDIRECT_REGULATORY)   /* 16 bytes */
 
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-rx.c b/drivers/net/wireless/iwlwifi/iwl-rx.c
index 8e1bb53..493626b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-rx.c
@@ -1044,7 +1044,7 @@ void iwl_rx_reply_rx(struct iwl_priv *priv,
 	 * as a bitmask.
 	 */
 	rx_status.antenna =
-		le16_to_cpu(phy_res->phy_flags & RX_RES_PHY_FLAGS_ANTENNA_MSK)
+		(le16_to_cpu(phy_res->phy_flags) & RX_RES_PHY_FLAGS_ANTENNA_MSK)
 		>> RX_RES_PHY_FLAGS_ANTENNA_POS;
 
 	/* set the preamble flag if appropriate */
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index c01588f..865fbc0 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2164,11 +2164,17 @@ static void __ieee80211_rx_handle_packet(struct ieee80211_hw *hw,
 
 	skb = rx.skb;
 
-	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
+	if (rx.sdata && ieee80211_is_data(hdr->frame_control)) {
+		rx.flags |= IEEE80211_RX_RA_MATCH;
+		prepares = prepare_for_handlers(rx.sdata, &rx, hdr);
+		if (prepares)
+			prev = rx.sdata;
+	} else list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 		if (!netif_running(sdata->dev))
 			continue;
 
-		if (sdata->vif.type == NL80211_IFTYPE_MONITOR)
+		if (sdata->vif.type == NL80211_IFTYPE_MONITOR ||
+		    sdata->vif.type == NL80211_IFTYPE_AP_VLAN)
 			continue;
 
 		rx.flags |= IEEE80211_RX_RA_MATCH;
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index eec0014..594f231 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -361,6 +361,7 @@ int sta_info_insert(struct sta_info *sta)
 					     u.ap);
 
 		drv_sta_notify(local, &sdata->vif, STA_NOTIFY_ADD, &sta->sta);
+		sdata = sta->sdata;
 	}
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
@@ -496,6 +497,7 @@ static void __sta_info_unlink(struct sta_info **sta)
 
 		drv_sta_notify(local, &sdata->vif, STA_NOTIFY_REMOVE,
 			       &(*sta)->sta);
+		sdata = (*sta)->sdata;
 	}
 
 	if (ieee80211_vif_is_mesh(&sdata->vif)) {
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index fd40282..db4bda6 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1704,7 +1704,8 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 	if (!is_multicast_ether_addr(hdr.addr1)) {
 		rcu_read_lock();
 		sta = sta_info_get(local, hdr.addr1);
-		if (sta)
+		/* XXX: in the future, use sdata to look up the sta */
+		if (sta && sta->sdata == sdata)
 			sta_flags = get_sta_flags(sta);
 		rcu_read_unlock();
 	}
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index dd65643..aeb65b3 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -339,7 +339,7 @@ void ieee80211_add_pending_skb(struct ieee80211_local *local,
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 
 	if (WARN_ON(!info->control.vif)) {
-		kfree(skb);
+		kfree_skb(skb);
 		return;
 	}
 
@@ -367,7 +367,7 @@ int ieee80211_add_pending_skbs(struct ieee80211_local *local,
 		struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 
 		if (WARN_ON(!info->control.vif)) {
-			kfree(skb);
+			kfree_skb(skb);
 			continue;
 		}
 
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index eddab09..ca3c92a 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -4029,7 +4029,7 @@ static int nl80211_wiphy_netns(struct sk_buff *skb, struct genl_info *info)
 	rdev = cfg80211_get_dev_from_info(info);
 	if (IS_ERR(rdev)) {
 		err = PTR_ERR(rdev);
-		goto out;
+		goto out_rtnl;
 	}
 
 	net = get_net_ns_by_pid(pid);
@@ -4049,6 +4049,7 @@ static int nl80211_wiphy_netns(struct sk_buff *skb, struct genl_info *info)
 	put_net(net);
  out:
 	cfg80211_unlock_rdev(rdev);
+ out_rtnl:
 	rtnl_unlock();
 	return err;
 }
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
