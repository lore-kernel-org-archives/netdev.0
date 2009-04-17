From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-04-17
Date: Fri, 17 Apr 2009 15:54:07 -0400
Message-ID: <20090417195407.GC3291@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36371 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbZDQUAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 16:00:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is a big batch of fixes for the 2.6.30 kernels.  Some are more
important than others and a few are a little bit large, but I think
they are all wortwhile for this point of the cycle.  There are some
USB ID additions, a small user-visible typo fix, a P54_LEDS patch
that should have been included in an earlier patch that is already
in 2.6.30, and a number of fixes that are more self-evident.

Please let me know if there are problems!

Thanks,

John

P.S.  Most of these have had at least one cycle in -next as well...

---

The following changes since commit 3664090e199f10cb0282097faae8f8ca58c1e4ae:
  Atsushi Nemoto (1):
        phylib: Fix delay argument of schedule_delayed_work

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (5):
      p54: replace MAC80211_LEDS with P54_LEDS in p54.h
      p54spi: fix locking warning in p54spi_op_tx
      ar9170: add Cace Airpcap NX usb_id
      p54usb: add Telsey 802.11g USB2.0 Adapter
      ar9170usb: add ZyXEL NWD271N

Dan Williams (1):
      airo: queue SIOCSIWAUTH-requested auth mode change for next commit

Gerrit Renker (1):
      mac80211: Fragmentation threshold (typo)

Herton Ronaldo Krzesinski (1):
      rt2x00: prevent double kfree when failing to register hardware

Ivo van Doorn (1):
      rt2x00: Add rt73usb USB IDs

Jamie Lentin (1):
      at76c50x-usb: Add device ID for OQO model 01+

Johannes Berg (7):
      mac80211: correct wext transmit power handler
      fix iwl3945 registration regression
      ar9170: fix struct layout on arm
      mac80211: avoid crashing when no scan sdata
      cfg80211: copy hold when replacing BSS
      cfg80211: do not replace BSS structs
      mac80211: validate TIM IE length

Luis R. Rodriguez (1):
      cfg80211: fix NULL pointer deference in reg_device_remove()

Masakazu Mokuno (1):
      net/ps3: Fix wireless AP connect error handling

Michael Buesch (4):
      b43: Poison RX buffers
      b43: Refresh RX poison on buffer recycling
      b43: Do radio lock assertion in software
      mac80211: quiet beacon loss messages

Pavel Roskin (2):
      ath9k: fix access to a freed skb in ath_rx_tasklet()
      orinoco: correct timeout logic in __orinoco_hw_set_tkip_key()

Philip Rakity (1):
      libertas: don't leak skb on receive error

Vasanthakumar Thiagarajan (1):
      mac80211: Fix bug in getting rx status for frames pending in reorder buffer

 drivers/net/ps3_gelic_wireless.c            |    3 ++
 drivers/net/wireless/airo.c                 |    2 +-
 drivers/net/wireless/ar9170/hw.h            |    8 ++--
 drivers/net/wireless/ar9170/usb.c           |    4 ++
 drivers/net/wireless/at76c50x-usb.c         |    2 +
 drivers/net/wireless/ath9k/recv.c           |    4 ++-
 drivers/net/wireless/b43/dma.c              |   50 +++++++++++++++++++++-----
 drivers/net/wireless/b43/main.c             |    5 +++
 drivers/net/wireless/b43/phy_common.c       |   16 ++++++--
 drivers/net/wireless/b43/phy_common.h       |    4 ++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    2 +
 drivers/net/wireless/libertas/rx.c          |    2 +
 drivers/net/wireless/orinoco/hw.c           |    8 ++---
 drivers/net/wireless/p54/p54.h              |   12 +++---
 drivers/net/wireless/p54/p54spi.c           |   25 +++++++------
 drivers/net/wireless/p54/p54usb.c           |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c     |    4 +--
 drivers/net/wireless/rt2x00/rt73usb.c       |    2 +
 net/mac80211/main.c                         |    2 +-
 net/mac80211/mlme.c                         |   26 ++++++++++----
 net/mac80211/rx.c                           |   13 +++++--
 net/mac80211/wext.c                         |   43 ++++++++++++++++++-----
 net/wireless/core.h                         |    2 +-
 net/wireless/reg.c                          |    5 ++-
 net/wireless/scan.c                         |   40 +++++++++++++++++----
 25 files changed, 207 insertions(+), 78 deletions(-)

diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wireless.c
index a5ac2bd..4f3ada6 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -2101,6 +2101,9 @@ static int gelic_wl_associate_bss(struct gelic_wl_info *wl,
 	if (ret) {
 		pr_debug("%s: WEP/WPA setup failed %d\n", __func__,
 			 ret);
+		ret = -EPERM;
+		gelic_wl_send_iwap_event(wl, NULL);
+		goto out;
 	}
 
 	/* start association */
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index f21a617..c36d3a3 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -6713,11 +6713,11 @@ static int airo_set_auth(struct net_device *dev,
 				local->config.authType = AUTH_ENCRYPT;
 			} else
 				return -EINVAL;
-			break;
 
 			/* Commit the changes to flags if needed */
 			if (local->config.authType != currentAuthType)
 				set_bit (FLAG_COMMIT, &local->flags);
+			break;
 		}
 
 	case IW_AUTH_WPA_ENABLED:
diff --git a/drivers/net/wireless/ar9170/hw.h b/drivers/net/wireless/ar9170/hw.h
index 13091bd..53e250a 100644
--- a/drivers/net/wireless/ar9170/hw.h
+++ b/drivers/net/wireless/ar9170/hw.h
@@ -310,7 +310,7 @@ struct ar9170_tx_control {
 
 struct ar9170_rx_head {
 	u8 plcp[12];
-};
+} __packed;
 
 struct ar9170_rx_tail {
 	union {
@@ -318,16 +318,16 @@ struct ar9170_rx_tail {
 			u8 rssi_ant0, rssi_ant1, rssi_ant2,
 			   rssi_ant0x, rssi_ant1x, rssi_ant2x,
 			   rssi_combined;
-		};
+		} __packed;
 		u8 rssi[7];
-	};
+	} __packed;
 
 	u8 evm_stream0[6], evm_stream1[6];
 	u8 phy_err;
 	u8 SAidx, DAidx;
 	u8 error;
 	u8 status;
-};
+} __packed;
 
 #define AR9170_ENC_ALG_NONE			0x0
 #define AR9170_ENC_ALG_WEP64			0x1
diff --git a/drivers/net/wireless/ar9170/usb.c b/drivers/net/wireless/ar9170/usb.c
index ad29684..c9e422e 100644
--- a/drivers/net/wireless/ar9170/usb.c
+++ b/drivers/net/wireless/ar9170/usb.c
@@ -59,6 +59,8 @@ static struct usb_device_id ar9170_usb_ids[] = {
 	{ USB_DEVICE(0x0cf3, 0x9170) },
 	/* Atheros TG121N */
 	{ USB_DEVICE(0x0cf3, 0x1001) },
+	/* Cace Airpcap NX */
+	{ USB_DEVICE(0xcace, 0x0300) },
 	/* D-Link DWA 160A */
 	{ USB_DEVICE(0x07d1, 0x3c10) },
 	/* Netgear WNDA3100 */
@@ -67,6 +69,8 @@ static struct usb_device_id ar9170_usb_ids[] = {
 	{ USB_DEVICE(0x0846, 0x9001) },
 	/* Zydas ZD1221 */
 	{ USB_DEVICE(0x0ace, 0x1221) },
+	/* ZyXEL NWD271N */
+	{ USB_DEVICE(0x0586, 0x3417) },
 	/* Z-Com UB81 BG */
 	{ USB_DEVICE(0x0cde, 0x0023) },
 	/* Z-Com UB82 ABG */
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 0c02f1c..744f4f4 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -250,6 +250,8 @@ static struct usb_device_id dev_table[] = {
 	{ USB_DEVICE(0x03eb, 0x7617), USB_DEVICE_DATA(BOARD_505A) },
 	/* Siemens Gigaset USB WLAN Adapter 11 */
 	{ USB_DEVICE(0x1690, 0x0701), USB_DEVICE_DATA(BOARD_505A) },
+	/* OQO Model 01+ Internal Wi-Fi */
+	{ USB_DEVICE(0x1557, 0x0002), USB_DEVICE_DATA(BOARD_505A) },
 	/*
 	 * at76c505amx-rfmd
 	 */
diff --git a/drivers/net/wireless/ath9k/recv.c b/drivers/net/wireless/ath9k/recv.c
index 71cb18d..dd1f301 100644
--- a/drivers/net/wireless/ath9k/recv.c
+++ b/drivers/net/wireless/ath9k/recv.c
@@ -493,6 +493,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush)
 	int hdrlen, padsize, retval;
 	bool decrypt_error = false;
 	u8 keyix;
+	__le16 fc;
 
 	spin_lock_bh(&sc->rx.rxbuflock);
 
@@ -606,6 +607,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush)
 		/* see if any padding is done by the hw and remove it */
 		hdr = (struct ieee80211_hdr *)skb->data;
 		hdrlen = ieee80211_get_hdrlen_from_skb(skb);
+		fc = hdr->frame_control;
 
 		/* The MAC header is padded to have 32-bit boundary if the
 		 * packet payload is non-zero. The general calculation for
@@ -690,7 +692,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush)
 			sc->rx.rxotherant = 0;
 		}
 
-		if (ieee80211_is_beacon(hdr->frame_control) &&
+		if (ieee80211_is_beacon(fc) &&
 				(sc->sc_flags & SC_OP_WAIT_FOR_BEACON)) {
 			sc->sc_flags &= ~SC_OP_WAIT_FOR_BEACON;
 			ath9k_hw_setpower(sc->sc_ah, ATH9K_PM_NETWORK_SLEEP);
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index e228c1d..eae680b 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -555,11 +555,32 @@ address_error:
 	return 1;
 }
 
+static bool b43_rx_buffer_is_poisoned(struct b43_dmaring *ring, struct sk_buff *skb)
+{
+	unsigned char *f = skb->data + ring->frameoffset;
+
+	return ((f[0] & f[1] & f[2] & f[3] & f[4] & f[5] & f[6] & f[7]) == 0xFF);
+}
+
+static void b43_poison_rx_buffer(struct b43_dmaring *ring, struct sk_buff *skb)
+{
+	struct b43_rxhdr_fw4 *rxhdr;
+	unsigned char *frame;
+
+	/* This poisons the RX buffer to detect DMA failures. */
+
+	rxhdr = (struct b43_rxhdr_fw4 *)(skb->data);
+	rxhdr->frame_len = 0;
+
+	B43_WARN_ON(ring->rx_buffersize < ring->frameoffset + sizeof(struct b43_plcp_hdr6) + 2);
+	frame = skb->data + ring->frameoffset;
+	memset(frame, 0xFF, sizeof(struct b43_plcp_hdr6) + 2 /* padding */);
+}
+
 static int setup_rx_descbuffer(struct b43_dmaring *ring,
 			       struct b43_dmadesc_generic *desc,
 			       struct b43_dmadesc_meta *meta, gfp_t gfp_flags)
 {
-	struct b43_rxhdr_fw4 *rxhdr;
 	dma_addr_t dmaaddr;
 	struct sk_buff *skb;
 
@@ -568,6 +589,7 @@ static int setup_rx_descbuffer(struct b43_dmaring *ring,
 	skb = __dev_alloc_skb(ring->rx_buffersize, gfp_flags);
 	if (unlikely(!skb))
 		return -ENOMEM;
+	b43_poison_rx_buffer(ring, skb);
 	dmaaddr = map_descbuffer(ring, skb->data, ring->rx_buffersize, 0);
 	if (b43_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize, 0)) {
 		/* ugh. try to realloc in zone_dma */
@@ -578,6 +600,7 @@ static int setup_rx_descbuffer(struct b43_dmaring *ring,
 		skb = __dev_alloc_skb(ring->rx_buffersize, gfp_flags);
 		if (unlikely(!skb))
 			return -ENOMEM;
+		b43_poison_rx_buffer(ring, skb);
 		dmaaddr = map_descbuffer(ring, skb->data,
 					 ring->rx_buffersize, 0);
 		if (b43_dma_mapping_error(ring, dmaaddr, ring->rx_buffersize, 0)) {
@@ -592,9 +615,6 @@ static int setup_rx_descbuffer(struct b43_dmaring *ring,
 	ring->ops->fill_descriptor(ring, desc, dmaaddr,
 				   ring->rx_buffersize, 0, 0, 0);
 
-	rxhdr = (struct b43_rxhdr_fw4 *)(skb->data);
-	rxhdr->frame_len = 0;
-
 	return 0;
 }
 
@@ -1483,12 +1503,17 @@ static void dma_rx(struct b43_dmaring *ring, int *slot)
 			len = le16_to_cpu(rxhdr->frame_len);
 		} while (len == 0 && i++ < 5);
 		if (unlikely(len == 0)) {
-			/* recycle the descriptor buffer. */
-			sync_descbuffer_for_device(ring, meta->dmaaddr,
-						   ring->rx_buffersize);
-			goto drop;
+			dmaaddr = meta->dmaaddr;
+			goto drop_recycle_buffer;
 		}
 	}
+	if (unlikely(b43_rx_buffer_is_poisoned(ring, skb))) {
+		/* Something went wrong with the DMA.
+		 * The device did not touch the buffer and did not overwrite the poison. */
+		b43dbg(ring->dev->wl, "DMA RX: Dropping poisoned buffer.\n");
+		dmaaddr = meta->dmaaddr;
+		goto drop_recycle_buffer;
+	}
 	if (unlikely(len > ring->rx_buffersize)) {
 		/* The data did not fit into one descriptor buffer
 		 * and is split over multiple buffers.
@@ -1501,6 +1526,7 @@ static void dma_rx(struct b43_dmaring *ring, int *slot)
 		while (1) {
 			desc = ops->idx2desc(ring, *slot, &meta);
 			/* recycle the descriptor buffer. */
+			b43_poison_rx_buffer(ring, meta->skb);
 			sync_descbuffer_for_device(ring, meta->dmaaddr,
 						   ring->rx_buffersize);
 			*slot = next_slot(ring, *slot);
@@ -1519,8 +1545,7 @@ static void dma_rx(struct b43_dmaring *ring, int *slot)
 	err = setup_rx_descbuffer(ring, desc, meta, GFP_ATOMIC);
 	if (unlikely(err)) {
 		b43dbg(ring->dev->wl, "DMA RX: setup_rx_descbuffer() failed\n");
-		sync_descbuffer_for_device(ring, dmaaddr, ring->rx_buffersize);
-		goto drop;
+		goto drop_recycle_buffer;
 	}
 
 	unmap_descbuffer(ring, dmaaddr, ring->rx_buffersize, 0);
@@ -1530,6 +1555,11 @@ static void dma_rx(struct b43_dmaring *ring, int *slot)
 	b43_rx(ring->dev, skb, rxhdr);
 drop:
 	return;
+
+drop_recycle_buffer:
+	/* Poison and recycle the RX buffer. */
+	b43_poison_rx_buffer(ring, skb);
+	sync_descbuffer_for_device(ring, dmaaddr, ring->rx_buffersize);
 }
 
 void b43_dma_rx(struct b43_dmaring *ring)
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 4896e08..79b685e 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -3974,6 +3974,11 @@ static void setup_struct_phy_for_init(struct b43_wldev *dev,
 	phy->next_txpwr_check_time = jiffies;
 	/* PHY TX errors counter. */
 	atomic_set(&phy->txerr_cnt, B43_PHY_TX_BADNESS_LIMIT);
+
+#if B43_DEBUG
+	phy->phy_locked = 0;
+	phy->radio_locked = 0;
+#endif
 }
 
 static void setup_struct_wldev_for_init(struct b43_wldev *dev)
diff --git a/drivers/net/wireless/b43/phy_common.c b/drivers/net/wireless/b43/phy_common.c
index 026b61c..e176b6e 100644
--- a/drivers/net/wireless/b43/phy_common.c
+++ b/drivers/net/wireless/b43/phy_common.c
@@ -131,12 +131,16 @@ void b43_radio_lock(struct b43_wldev *dev)
 {
 	u32 macctl;
 
+#if B43_DEBUG
+	B43_WARN_ON(dev->phy.radio_locked);
+	dev->phy.radio_locked = 1;
+#endif
+
 	macctl = b43_read32(dev, B43_MMIO_MACCTL);
-	B43_WARN_ON(macctl & B43_MACCTL_RADIOLOCK);
 	macctl |= B43_MACCTL_RADIOLOCK;
 	b43_write32(dev, B43_MMIO_MACCTL, macctl);
-	/* Commit the write and wait for the device
-	 * to exit any radio register access. */
+	/* Commit the write and wait for the firmware
+	 * to finish any radio register access. */
 	b43_read32(dev, B43_MMIO_MACCTL);
 	udelay(10);
 }
@@ -145,11 +149,15 @@ void b43_radio_unlock(struct b43_wldev *dev)
 {
 	u32 macctl;
 
+#if B43_DEBUG
+	B43_WARN_ON(!dev->phy.radio_locked);
+	dev->phy.radio_locked = 0;
+#endif
+
 	/* Commit any write */
 	b43_read16(dev, B43_MMIO_PHY_VER);
 	/* unlock */
 	macctl = b43_read32(dev, B43_MMIO_MACCTL);
-	B43_WARN_ON(!(macctl & B43_MACCTL_RADIOLOCK));
 	macctl &= ~B43_MACCTL_RADIOLOCK;
 	b43_write32(dev, B43_MMIO_MACCTL, macctl);
 }
diff --git a/drivers/net/wireless/b43/phy_common.h b/drivers/net/wireless/b43/phy_common.h
index c9f5430..b2d9910 100644
--- a/drivers/net/wireless/b43/phy_common.h
+++ b/drivers/net/wireless/b43/phy_common.h
@@ -245,8 +245,10 @@ struct b43_phy {
 	atomic_t txerr_cnt;
 
 #ifdef CONFIG_B43_DEBUG
-	/* PHY registers locked by b43_phy_lock()? */
+	/* PHY registers locked (w.r.t. firmware) */
 	bool phy_locked;
+	/* Radio registers locked (w.r.t. firmware) */
+	bool radio_locked;
 #endif /* B43_DEBUG */
 };
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index ce72928..8d738d7 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -4913,6 +4913,8 @@ static int iwl3945_setup_mac(struct iwl_priv *priv)
 
 	hw->wiphy->custom_regulatory = true;
 
+	hw->wiphy->max_scan_ssids = 1; /* WILL FIX */
+
 	/* Default value; 4 EDCA QOS priorities */
 	hw->queues = 4;
 
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index 63d7e19..8e66977 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -170,6 +170,7 @@ int lbs_process_rxed_packet(struct lbs_private *priv, struct sk_buff *skb)
 		lbs_deb_rx("rx err: frame received with bad length\n");
 		dev->stats.rx_length_errors++;
 		ret = 0;
+		dev_kfree_skb(skb);
 		goto done;
 	}
 
@@ -181,6 +182,7 @@ int lbs_process_rxed_packet(struct lbs_private *priv, struct sk_buff *skb)
 		lbs_pr_alert("rxpd not ok\n");
 		dev->stats.rx_errors++;
 		ret = 0;
+		dev_kfree_skb(skb);
 		goto done;
 	}
 
diff --git a/drivers/net/wireless/orinoco/hw.c b/drivers/net/wireless/orinoco/hw.c
index 081428d..632fac8 100644
--- a/drivers/net/wireless/orinoco/hw.c
+++ b/drivers/net/wireless/orinoco/hw.c
@@ -372,15 +372,13 @@ int __orinoco_hw_set_tkip_key(hermes_t *hw, int key_idx, int set_tx,
 	}
 
 	/* Wait upto 100ms for tx queue to empty */
-	k = 100;
-	do {
-		k--;
+	for (k = 100; k > 0; k--) {
 		udelay(1000);
 		ret = hermes_read_wordrec(hw, USER_BAP, HERMES_RID_TXQUEUEEMPTY,
 					  &xmitting);
-		if (ret)
+		if (ret || !xmitting)
 			break;
-	} while ((k > 0) && xmitting);
+	}
 
 	if (k == 0)
 		ret = -ETIMEDOUT;
diff --git a/drivers/net/wireless/p54/p54.h b/drivers/net/wireless/p54/p54.h
index 2dda5fe..ecf8b6e 100644
--- a/drivers/net/wireless/p54/p54.h
+++ b/drivers/net/wireless/p54/p54.h
@@ -14,9 +14,9 @@
  * published by the Free Software Foundation.
  */
 
-#ifdef CONFIG_MAC80211_LEDS
+#ifdef CONFIG_P54_LEDS
 #include <linux/leds.h>
-#endif /* CONFIG_MAC80211_LEDS */
+#endif /* CONFIG_P54_LEDS */
 
 enum p54_control_frame_types {
 	P54_CONTROL_TYPE_SETUP = 0,
@@ -116,7 +116,7 @@ enum fw_state {
 	FW_STATE_RESETTING,
 };
 
-#ifdef CONFIG_MAC80211_LEDS
+#ifdef CONFIG_P54_LEDS
 
 #define P54_LED_MAX_NAME_LEN 31
 
@@ -129,7 +129,7 @@ struct p54_led_dev {
 	unsigned int registered;
 };
 
-#endif /* CONFIG_MAC80211_LEDS */
+#endif /* CONFIG_P54_LEDS */
 
 struct p54_common {
 	struct ieee80211_hw *hw;
@@ -177,10 +177,10 @@ struct p54_common {
 	u8 privacy_caps;
 	u8 rx_keycache_size;
 	/* LED management */
-	#ifdef CONFIG_MAC80211_LEDS
+#ifdef CONFIG_P54_LEDS
 	struct p54_led_dev assoc_led;
 	struct p54_led_dev tx_led;
-	#endif /* CONFIG_MAC80211_LEDS */
+#endif /* CONFIG_P54_LEDS */
 	u16 softled_state;		/* bit field of glowing LEDs */
 };
 
diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
index 2b222aa..d1fe577 100644
--- a/drivers/net/wireless/p54/p54spi.c
+++ b/drivers/net/wireless/p54/p54spi.c
@@ -457,9 +457,10 @@ static int p54spi_wq_tx(struct p54s_priv *priv)
 	struct ieee80211_tx_info *info;
 	struct p54_tx_info *minfo;
 	struct p54s_tx_info *dinfo;
+	unsigned long flags;
 	int ret = 0;
 
-	spin_lock_bh(&priv->tx_lock);
+	spin_lock_irqsave(&priv->tx_lock, flags);
 
 	while (!list_empty(&priv->tx_pending)) {
 		entry = list_entry(priv->tx_pending.next,
@@ -467,7 +468,7 @@ static int p54spi_wq_tx(struct p54s_priv *priv)
 
 		list_del_init(&entry->tx_list);
 
-		spin_unlock_bh(&priv->tx_lock);
+		spin_unlock_irqrestore(&priv->tx_lock, flags);
 
 		dinfo = container_of((void *) entry, struct p54s_tx_info,
 				     tx_list);
@@ -479,16 +480,14 @@ static int p54spi_wq_tx(struct p54s_priv *priv)
 
 		ret = p54spi_tx_frame(priv, skb);
 
-		spin_lock_bh(&priv->tx_lock);
-
 		if (ret < 0) {
 			p54_free_skb(priv->hw, skb);
-			goto out;
+			return ret;
 		}
-	}
 
-out:
-	spin_unlock_bh(&priv->tx_lock);
+		spin_lock_irqsave(&priv->tx_lock, flags);
+	}
+	spin_unlock_irqrestore(&priv->tx_lock, flags);
 	return ret;
 }
 
@@ -498,12 +497,13 @@ static void p54spi_op_tx(struct ieee80211_hw *dev, struct sk_buff *skb)
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct p54_tx_info *mi = (struct p54_tx_info *) info->rate_driver_data;
 	struct p54s_tx_info *di = (struct p54s_tx_info *) mi->data;
+	unsigned long flags;
 
 	BUILD_BUG_ON(sizeof(*di) > sizeof((mi->data)));
 
-	spin_lock_bh(&priv->tx_lock);
+	spin_lock_irqsave(&priv->tx_lock, flags);
 	list_add_tail(&di->tx_list, &priv->tx_pending);
-	spin_unlock_bh(&priv->tx_lock);
+	spin_unlock_irqrestore(&priv->tx_lock, flags);
 
 	queue_work(priv->hw->workqueue, &priv->work);
 }
@@ -604,6 +604,7 @@ out:
 static void p54spi_op_stop(struct ieee80211_hw *dev)
 {
 	struct p54s_priv *priv = dev->priv;
+	unsigned long flags;
 
 	if (mutex_lock_interruptible(&priv->mutex)) {
 		/* FIXME: how to handle this error? */
@@ -615,9 +616,9 @@ static void p54spi_op_stop(struct ieee80211_hw *dev)
 	cancel_work_sync(&priv->work);
 
 	p54spi_power_off(priv);
-	spin_lock_bh(&priv->tx_lock);
+	spin_lock_irqsave(&priv->tx_lock, flags);
 	INIT_LIST_HEAD(&priv->tx_pending);
-	spin_unlock_bh(&priv->tx_lock);
+	spin_unlock_irqrestore(&priv->tx_lock, flags);
 
 	priv->fw_state = FW_STATE_OFF;
 	mutex_unlock(&priv->mutex);
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index da6640a..6cc6cbc 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -71,6 +71,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x1260, 0xee22)},	/* SMC 2862W-G version 2 */
 	{USB_DEVICE(0x13b1, 0x000a)},	/* Linksys WUSB54G ver 2 */
 	{USB_DEVICE(0x13B1, 0x000C)},	/* Linksys WUSB54AG */
+	{USB_DEVICE(0x1413, 0x5400)},   /* Telsey 802.11g USB2.0 Adapter */
 	{USB_DEVICE(0x1435, 0x0427)},	/* Inventel UR054G */
 	{USB_DEVICE(0x2001, 0x3704)},	/* DLink DWL-G122 rev A2 */
 	{USB_DEVICE(0x413c, 0x8102)},	/* Spinnaker DUT */
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 05f94e2..5752aaa 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -646,10 +646,8 @@ static int rt2x00lib_probe_hw(struct rt2x00_dev *rt2x00dev)
 	 * Register HW.
 	 */
 	status = ieee80211_register_hw(rt2x00dev->hw);
-	if (status) {
-		rt2x00lib_remove_hw(rt2x00dev);
+	if (status)
 		return status;
-	}
 
 	set_bit(DEVICE_STATE_REGISTERED_HW, &rt2x00dev->flags);
 
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index 420fff4..853b2b2 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2369,6 +2369,8 @@ static struct usb_device_id rt73usb_device_table[] = {
 	/* Buffalo */
 	{ USB_DEVICE(0x0411, 0x00d8), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x0411, 0x00f4), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x0411, 0x0116), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x0411, 0x0119), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* CNet */
 	{ USB_DEVICE(0x1371, 0x9022), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x1371, 0x9032), USB_DEVICE_DATA(&rt73usb_ops) },
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index a6f1d8a..fbcbed6 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -258,7 +258,7 @@ int ieee80211_hw_config(struct ieee80211_local *local, u32 changed)
 			(chan->max_power - local->power_constr_level) :
 			chan->max_power;
 
-	if (local->user_power_level)
+	if (local->user_power_level >= 0)
 		power = min(power, local->user_power_level);
 
 	if (local->hw.conf.power_level != power) {
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 7ecda9d..1619e0c 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -441,6 +441,9 @@ static bool ieee80211_check_tim(struct ieee802_11_elems *elems, u16 aid)
 	u8 index, indexn1, indexn2;
 	struct ieee80211_tim_ie *tim = (struct ieee80211_tim_ie *) elems->tim;
 
+	if (unlikely(!tim || elems->tim_len < 4))
+		return false;
+
 	aid &= 0x3fff;
 	index = aid / 8;
 	mask  = 1 << (aid & 7);
@@ -945,9 +948,13 @@ void ieee80211_beacon_loss_work(struct work_struct *work)
 			     u.mgd.beacon_loss_work);
 	struct ieee80211_if_managed *ifmgd = &sdata->u.mgd;
 
-	printk(KERN_DEBUG "%s: driver reports beacon loss from AP %pM "
-	       "- sending probe request\n", sdata->dev->name,
-	       sdata->u.mgd.bssid);
+#ifdef CONFIG_MAC80211_VERBOSE_DEBUG
+	if (net_ratelimit()) {
+		printk(KERN_DEBUG "%s: driver reports beacon loss from AP %pM "
+		       "- sending probe request\n", sdata->dev->name,
+		       sdata->u.mgd.bssid);
+	}
+#endif
 
 	ifmgd->flags |= IEEE80211_STA_PROBEREQ_POLL;
 	ieee80211_send_probe_req(sdata, ifmgd->bssid, ifmgd->ssid,
@@ -1007,9 +1014,13 @@ static void ieee80211_associated(struct ieee80211_sub_if_data *sdata)
 	      (local->hw.conf.flags & IEEE80211_CONF_PS)) &&
 	    time_after(jiffies,
 		       ifmgd->last_beacon + IEEE80211_MONITORING_INTERVAL)) {
-		printk(KERN_DEBUG "%s: beacon loss from AP %pM "
-		       "- sending probe request\n",
-		       sdata->dev->name, ifmgd->bssid);
+#ifdef CONFIG_MAC80211_VERBOSE_DEBUG
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "%s: beacon loss from AP %pM "
+			       "- sending probe request\n",
+			       sdata->dev->name, ifmgd->bssid);
+		}
+#endif
 		ifmgd->flags |= IEEE80211_STA_PROBEREQ_POLL;
 		ieee80211_send_probe_req(sdata, ifmgd->bssid, ifmgd->ssid,
 					 ifmgd->ssid_len, NULL, 0);
@@ -2105,12 +2116,13 @@ void ieee80211_dynamic_ps_enable_work(struct work_struct *work)
 	struct ieee80211_local *local =
 		container_of(work, struct ieee80211_local,
 			     dynamic_ps_enable_work);
+	/* XXX: using scan_sdata is completely broken! */
 	struct ieee80211_sub_if_data *sdata = local->scan_sdata;
 
 	if (local->hw.conf.flags & IEEE80211_CONF_PS)
 		return;
 
-	if (local->hw.flags & IEEE80211_HW_PS_NULLFUNC_STACK)
+	if (local->hw.flags & IEEE80211_HW_PS_NULLFUNC_STACK && sdata)
 		ieee80211_send_nullfunc(local, sdata, 1);
 
 	local->hw.conf.flags |= IEEE80211_CONF_PS;
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 64ebe66..5fa7aed 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -29,6 +29,7 @@
 static u8 ieee80211_sta_manage_reorder_buf(struct ieee80211_hw *hw,
 					   struct tid_ampdu_rx *tid_agg_rx,
 					   struct sk_buff *skb,
+					   struct ieee80211_rx_status *status,
 					   u16 mpdu_seq_num,
 					   int bar_req);
 /*
@@ -1688,7 +1689,7 @@ ieee80211_rx_h_ctrl(struct ieee80211_rx_data *rx)
 		/* manage reordering buffer according to requested */
 		/* sequence number */
 		rcu_read_lock();
-		ieee80211_sta_manage_reorder_buf(hw, tid_agg_rx, NULL,
+		ieee80211_sta_manage_reorder_buf(hw, tid_agg_rx, NULL, NULL,
 						 start_seq_num, 1);
 		rcu_read_unlock();
 		return RX_DROP_UNUSABLE;
@@ -2293,6 +2294,7 @@ static inline u16 seq_sub(u16 sq1, u16 sq2)
 static u8 ieee80211_sta_manage_reorder_buf(struct ieee80211_hw *hw,
 					   struct tid_ampdu_rx *tid_agg_rx,
 					   struct sk_buff *skb,
+					   struct ieee80211_rx_status *rxstatus,
 					   u16 mpdu_seq_num,
 					   int bar_req)
 {
@@ -2374,6 +2376,8 @@ static u8 ieee80211_sta_manage_reorder_buf(struct ieee80211_hw *hw,
 
 	/* put the frame in the reordering buffer */
 	tid_agg_rx->reorder_buf[index] = skb;
+	memcpy(tid_agg_rx->reorder_buf[index]->cb, rxstatus,
+	       sizeof(*rxstatus));
 	tid_agg_rx->stored_mpdu_num++;
 	/* release the buffer until next missing frame */
 	index = seq_sub(tid_agg_rx->head_seq_num, tid_agg_rx->ssn)
@@ -2399,7 +2403,8 @@ static u8 ieee80211_sta_manage_reorder_buf(struct ieee80211_hw *hw,
 }
 
 static u8 ieee80211_rx_reorder_ampdu(struct ieee80211_local *local,
-				     struct sk_buff *skb)
+				     struct sk_buff *skb,
+				     struct ieee80211_rx_status *status)
 {
 	struct ieee80211_hw *hw = &local->hw;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
@@ -2448,7 +2453,7 @@ static u8 ieee80211_rx_reorder_ampdu(struct ieee80211_local *local,
 
 	/* according to mpdu sequence number deal with reordering buffer */
 	mpdu_seq_num = (sc & IEEE80211_SCTL_SEQ) >> 4;
-	ret = ieee80211_sta_manage_reorder_buf(hw, tid_agg_rx, skb,
+	ret = ieee80211_sta_manage_reorder_buf(hw, tid_agg_rx, skb, status,
 						mpdu_seq_num, 0);
  end_reorder:
 	return ret;
@@ -2512,7 +2517,7 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 		return;
 	}
 
-	if (!ieee80211_rx_reorder_ampdu(local, skb))
+	if (!ieee80211_rx_reorder_ampdu(local, skb, status))
 		__ieee80211_rx_handle_packet(hw, skb, status, rate);
 
 	rcu_read_unlock();
diff --git a/net/mac80211/wext.c b/net/mac80211/wext.c
index deb4ece..959aa83 100644
--- a/net/mac80211/wext.c
+++ b/net/mac80211/wext.c
@@ -417,6 +417,7 @@ static int ieee80211_ioctl_siwtxpower(struct net_device *dev,
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_channel* chan = local->hw.conf.channel;
+	bool reconf = false;
 	u32 reconf_flags = 0;
 	int new_power_level;
 
@@ -427,14 +428,38 @@ static int ieee80211_ioctl_siwtxpower(struct net_device *dev,
 	if (!chan)
 		return -EINVAL;
 
-	if (data->txpower.fixed)
-		new_power_level = min(data->txpower.value, chan->max_power);
-	else /* Automatic power level setting */
-		new_power_level = chan->max_power;
+	/* only change when not disabling */
+	if (!data->txpower.disabled) {
+		if (data->txpower.fixed) {
+			if (data->txpower.value < 0)
+				return -EINVAL;
+			new_power_level = data->txpower.value;
+			/*
+			 * Debatable, but we cannot do a fixed power
+			 * level above the regulatory constraint.
+			 * Use "iwconfig wlan0 txpower 15dBm" instead.
+			 */
+			if (new_power_level > chan->max_power)
+				return -EINVAL;
+		} else {
+			/*
+			 * Automatic power level setting, max being the value
+			 * passed in from userland.
+			 */
+			if (data->txpower.value < 0)
+				new_power_level = -1;
+			else
+				new_power_level = data->txpower.value;
+		}
+
+		reconf = true;
 
-	local->user_power_level = new_power_level;
-	if (local->hw.conf.power_level != new_power_level)
-		reconf_flags |= IEEE80211_CONF_CHANGE_POWER;
+		/*
+		 * ieee80211_hw_config() will limit to the channel's
+		 * max power and possibly power constraint from AP.
+		 */
+		local->user_power_level = new_power_level;
+	}
 
 	if (local->hw.conf.radio_enabled != !(data->txpower.disabled)) {
 		local->hw.conf.radio_enabled = !(data->txpower.disabled);
@@ -442,7 +467,7 @@ static int ieee80211_ioctl_siwtxpower(struct net_device *dev,
 		ieee80211_led_radio(local, local->hw.conf.radio_enabled);
 	}
 
-	if (reconf_flags)
+	if (reconf || reconf_flags)
 		ieee80211_hw_config(local, reconf_flags);
 
 	return 0;
@@ -530,7 +555,7 @@ static int ieee80211_ioctl_giwfrag(struct net_device *dev,
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 
 	frag->value = local->fragmentation_threshold;
-	frag->disabled = (frag->value >= IEEE80211_MAX_RTS_THRESHOLD);
+	frag->disabled = (frag->value >= IEEE80211_MAX_FRAG_THRESHOLD);
 	frag->fixed = 1;
 
 	return 0;
diff --git a/net/wireless/core.h b/net/wireless/core.h
index d43daa2..0a592e4 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -90,7 +90,7 @@ struct cfg80211_internal_bss {
 	struct rb_node rbn;
 	unsigned long ts;
 	struct kref ref;
-	bool hold;
+	bool hold, ies_allocated;
 
 	/* must be last because of priv member */
 	struct cfg80211_bss pub;
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 6327e16..6c1993d 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -2095,11 +2095,12 @@ int set_regdom(const struct ieee80211_regdomain *rd)
 /* Caller must hold cfg80211_mutex */
 void reg_device_remove(struct wiphy *wiphy)
 {
-	struct wiphy *request_wiphy;
+	struct wiphy *request_wiphy = NULL;
 
 	assert_cfg80211_lock();
 
-	request_wiphy = wiphy_idx_to_wiphy(last_request->wiphy_idx);
+	if (last_request)
+		request_wiphy = wiphy_idx_to_wiphy(last_request->wiphy_idx);
 
 	kfree(wiphy->regd);
 	if (!last_request || !request_wiphy)
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 2a00e36..2ae65b3 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -58,6 +58,10 @@ static void bss_release(struct kref *ref)
 	bss = container_of(ref, struct cfg80211_internal_bss, ref);
 	if (bss->pub.free_priv)
 		bss->pub.free_priv(&bss->pub);
+
+	if (bss->ies_allocated)
+		kfree(bss->pub.information_elements);
+
 	kfree(bss);
 }
 
@@ -360,19 +364,41 @@ cfg80211_bss_update(struct cfg80211_registered_device *dev,
 
 	found = rb_find_bss(dev, res);
 
-	if (found && overwrite) {
-		list_replace(&found->list, &res->list);
-		rb_replace_node(&found->rbn, &res->rbn,
-				&dev->bss_tree);
-		kref_put(&found->ref, bss_release);
-		found = res;
-	} else if (found) {
+	if (found) {
 		kref_get(&found->ref);
 		found->pub.beacon_interval = res->pub.beacon_interval;
 		found->pub.tsf = res->pub.tsf;
 		found->pub.signal = res->pub.signal;
 		found->pub.capability = res->pub.capability;
 		found->ts = res->ts;
+
+		/* overwrite IEs */
+		if (overwrite) {
+			size_t used = dev->wiphy.bss_priv_size + sizeof(*res);
+			size_t ielen = res->pub.len_information_elements;
+
+			if (ksize(found) >= used + ielen) {
+				memcpy(found->pub.information_elements,
+				       res->pub.information_elements, ielen);
+				found->pub.len_information_elements = ielen;
+			} else {
+				u8 *ies = found->pub.information_elements;
+
+				if (found->ies_allocated) {
+					if (ksize(ies) < ielen)
+						ies = krealloc(ies, ielen,
+							       GFP_ATOMIC);
+				} else
+					ies = kmalloc(ielen, GFP_ATOMIC);
+
+				if (ies) {
+					memcpy(ies, res->pub.information_elements, ielen);
+					found->ies_allocated = true;
+					found->pub.information_elements = ies;
+				}
+			}
+		}
+
 		kref_put(&res->ref, bss_release);
 	} else {
 		/* this "consumes" the reference */
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
