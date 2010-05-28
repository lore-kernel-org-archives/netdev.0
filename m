From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-05-28
Date: Fri, 28 May 2010 14:09:53 -0400
Message-ID: <20100528180952.GC2405@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a few small fixes intended for 2.6.35.  Included are a null
pointer dereference fix, and a use-after-free fix, as well as some more
minor stuff.  It also include the revert of a earlier patch that I
inadvertantly merged out of order, effectively creating a bug rather
than fixing one.  The reverted patch will now be pointed at 2.6.36
instead.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 045de01a174d9f0734f657eb4b3313d89b4fd5ad:
  Scott Feldman (1):
        netlink: bug fix: wrong size was calculated for vfinfo list blob

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (1):
      ar9170usb: fix read from freed driver context

Christoph Fritz (1):
      ssb: fix NULL ptr deref when pcihost_wrapper is used

Johannes Berg (1):
      mac80211: make a function static

John W. Linville (1):
      Revert "rt2x00: Fix rt2800usb TX descriptor writing."

Justin P. Mattock (1):
      ath9k: Fix ath_print in xmit for hardware reset.

Prarit Bhargava (1):
      libertas: fix uninitialized variable warning

Vasanthakumar Thiagarajan (1):
      ath9k: Fix bug in the way "bf_tx_aborted" of struct ath_buf is used

 drivers/net/wireless/ath/ar9170/usb.c   |   14 ++++++++++++--
 drivers/net/wireless/ath/ath9k/xmit.c   |    6 ++++--
 drivers/net/wireless/libertas/rx.c      |    5 ++---
 drivers/net/wireless/rt2x00/rt2800usb.c |    2 +-
 drivers/ssb/pci.c                       |    9 ++++++---
 drivers/ssb/sprom.c                     |    1 +
 net/mac80211/chan.c                     |    2 +-
 7 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/ath/ar9170/usb.c b/drivers/net/wireless/ath/ar9170/usb.c
index 82ab532..a93dc18 100644
--- a/drivers/net/wireless/ath/ar9170/usb.c
+++ b/drivers/net/wireless/ath/ar9170/usb.c
@@ -739,17 +739,27 @@ err_out:
 static void ar9170_usb_firmware_failed(struct ar9170_usb *aru)
 {
 	struct device *parent = aru->udev->dev.parent;
+	struct usb_device *udev;
+
+	/*
+	 * Store a copy of the usb_device pointer locally.
+	 * This is because device_release_driver initiates
+	 * ar9170_usb_disconnect, which in turn frees our
+	 * driver context (aru).
+	 */
+	udev = aru->udev;
 
 	complete(&aru->firmware_loading_complete);
 
 	/* unbind anything failed */
 	if (parent)
 		device_lock(parent);
-	device_release_driver(&aru->udev->dev);
+
+	device_release_driver(&udev->dev);
 	if (parent)
 		device_unlock(parent);
 
-	usb_put_dev(aru->udev);
+	usb_put_dev(udev);
 }
 
 static void ar9170_usb_firmware_finish(const struct firmware *fw, void *context)
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 3db1917..859aa4a 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1198,7 +1198,7 @@ void ath_drain_all_txq(struct ath_softc *sc, bool retry_tx)
 		int r;
 
 		ath_print(common, ATH_DBG_FATAL,
-			  "Unable to stop TxDMA. Reset HAL!\n");
+			  "Failed to stop TX DMA. Resetting hardware!\n");
 
 		spin_lock_bh(&sc->sc_resetlock);
 		r = ath9k_hw_reset(ah, sc->sc_ah->curchan, false);
@@ -1728,6 +1728,8 @@ static int ath_tx_setup_buffer(struct ieee80211_hw *hw, struct ath_buf *bf,
 	} else
 		bf->bf_isnullfunc = false;
 
+	bf->bf_tx_aborted = false;
+
 	return 0;
 }
 
@@ -1989,7 +1991,7 @@ static int ath_tx_num_badfrms(struct ath_softc *sc, struct ath_buf *bf,
 	int nbad = 0;
 	int isaggr = 0;
 
-	if (bf->bf_tx_aborted)
+	if (bf->bf_lastbf->bf_tx_aborted)
 		return 0;
 
 	isaggr = bf_isaggr(bf);
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index a115bfa..7a377f5 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -329,9 +329,8 @@ static int process_rxed_802_11_packet(struct lbs_private *priv,
 	/* create the exported radio header */
 
 	/* radiotap header */
-	radiotap_hdr.hdr.it_version = 0;
-	/* XXX must check this value for pad */
-	radiotap_hdr.hdr.it_pad = 0;
+	memset(&radiotap_hdr, 0, sizeof(radiotap_hdr));
+	/* XXX must check radiotap_hdr.hdr.it_pad for pad */
 	radiotap_hdr.hdr.it_len = cpu_to_le16 (sizeof(struct rx_radiotap_hdr));
 	radiotap_hdr.hdr.it_present = cpu_to_le32 (RX_RADIOTAP_PRESENT);
 	radiotap_hdr.rate = convert_mv_rate_to_radiotap(prxpd->rx_rate);
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index 6991613..0f8b84b 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -413,7 +413,7 @@ static void rt2800usb_write_tx_desc(struct rt2x00_dev *rt2x00dev,
 	 */
 	rt2x00_desc_read(txi, 0, &word);
 	rt2x00_set_field32(&word, TXINFO_W0_USB_DMA_TX_PKT_LEN,
-			   skb->len - TXINFO_DESC_SIZE);
+			   skb->len + TXWI_DESC_SIZE);
 	rt2x00_set_field32(&word, TXINFO_W0_WIV,
 			   !test_bit(ENTRY_TXD_ENCRYPT_IV, &txdesc->flags));
 	rt2x00_set_field32(&word, TXINFO_W0_QSEL, 2);
diff --git a/drivers/ssb/pci.c b/drivers/ssb/pci.c
index 989e275..6dcda86 100644
--- a/drivers/ssb/pci.c
+++ b/drivers/ssb/pci.c
@@ -625,9 +625,12 @@ static int ssb_pci_sprom_get(struct ssb_bus *bus,
 		ssb_printk(KERN_ERR PFX "No SPROM available!\n");
 		return -ENODEV;
 	}
-
-	bus->sprom_offset = (bus->chipco.dev->id.revision < 31) ?
-		SSB_SPROM_BASE1 : SSB_SPROM_BASE31;
+	if (bus->chipco.dev) {	/* can be unavailible! */
+		bus->sprom_offset = (bus->chipco.dev->id.revision < 31) ?
+			SSB_SPROM_BASE1 : SSB_SPROM_BASE31;
+	} else {
+		bus->sprom_offset = SSB_SPROM_BASE1;
+	}
 
 	buf = kcalloc(SSB_SPROMSIZE_WORDS_R123, sizeof(u16), GFP_KERNEL);
 	if (!buf)
diff --git a/drivers/ssb/sprom.c b/drivers/ssb/sprom.c
index 007bc3a..4f7cc8d 100644
--- a/drivers/ssb/sprom.c
+++ b/drivers/ssb/sprom.c
@@ -185,6 +185,7 @@ bool ssb_is_sprom_available(struct ssb_bus *bus)
 	/* this routine differs from specs as we do not access SPROM directly
 	   on PCMCIA */
 	if (bus->bustype == SSB_BUSTYPE_PCI &&
+	    bus->chipco.dev &&	/* can be unavailible! */
 	    bus->chipco.dev->id.revision >= 31)
 		return bus->chipco.capabilities & SSB_CHIPCO_CAP_SPROM;
 
diff --git a/net/mac80211/chan.c b/net/mac80211/chan.c
index 5d218c5..32be11e 100644
--- a/net/mac80211/chan.c
+++ b/net/mac80211/chan.c
@@ -5,7 +5,7 @@
 #include <linux/nl80211.h>
 #include "ieee80211_i.h"
 
-enum ieee80211_chan_mode
+static enum ieee80211_chan_mode
 __ieee80211_get_channel_mode(struct ieee80211_local *local,
 			     struct ieee80211_sub_if_data *ignore)
 {
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
