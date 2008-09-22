From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-09-22
Date: Mon, 22 Sep 2008 18:06:19 -0400
Message-ID: <20080922220619.GD3660@tuxdriver.com>
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

Here are a few more for 2.6.27.  The ath9k patches fix an oops and a
kernel.org bugzilla (11570).  The zd1211rw patch is just a PCI ID --
hopefully that is not still outside the lines even at this stage.

Please let me know if there are problems!

Thanks,

John

P.S.  This will create a merge conflict in -next.  I have done a sample
resolve of the merge here:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git merge-test

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit ad55dcaff0e34269f86975ce2ea0da22e9eb74a1:
  Alexander Duyck (1):
        netdev: simple_tx_hash shouldn't hash inside fragments

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Senthil Balasubramanian (2):
      ath9k: connectivity is lost after Group rekeying is done
      ath9k: Fix IRQ nobody cared issue with ath9k

born.into.silence-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org (1):
      wireless: zd1211rw: add device ID fix wifi dongle "trust nw-3100"

 drivers/net/wireless/ath9k/core.c      |    4 ++--
 drivers/net/wireless/ath9k/core.h      |    1 -
 drivers/net/wireless/ath9k/main.c      |   12 ++++++++----
 drivers/net/wireless/ath9k/xmit.c      |    6 +++---
 drivers/net/wireless/zd1211rw/zd_usb.c |    1 +
 5 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/ath9k/core.c b/drivers/net/wireless/ath9k/core.c
index f6c4528..c049593 100644
--- a/drivers/net/wireless/ath9k/core.c
+++ b/drivers/net/wireless/ath9k/core.c
@@ -294,8 +294,6 @@ static int ath_stop(struct ath_softc *sc)
 	 * hardware is gone (invalid).
 	 */
 
-	if (!sc->sc_invalid)
-		ath9k_hw_set_interrupts(ah, 0);
 	ath_draintxq(sc, false);
 	if (!sc->sc_invalid) {
 		ath_stoprecv(sc);
@@ -1336,6 +1334,8 @@ void ath_deinit(struct ath_softc *sc)
 
 	DPRINTF(sc, ATH_DBG_CONFIG, "%s\n", __func__);
 
+	tasklet_kill(&sc->intr_tq);
+	tasklet_kill(&sc->bcon_tasklet);
 	ath_stop(sc);
 	if (!sc->sc_invalid)
 		ath9k_hw_setpower(sc->sc_ah, ATH9K_PM_AWAKE);
diff --git a/drivers/net/wireless/ath9k/core.h b/drivers/net/wireless/ath9k/core.h
index 4ee695b..2f84093 100644
--- a/drivers/net/wireless/ath9k/core.h
+++ b/drivers/net/wireless/ath9k/core.h
@@ -974,7 +974,6 @@ struct ath_softc {
 	u32 sc_keymax;		/* size of key cache */
 	DECLARE_BITMAP(sc_keymap, ATH_KEYMAX);	/* key use bit map */
 	u8 sc_splitmic;		/* split TKIP MIC keys */
-	int sc_keytype;
 
 	/* RX */
 	struct list_head sc_rxbuf;
diff --git a/drivers/net/wireless/ath9k/main.c b/drivers/net/wireless/ath9k/main.c
index 99badf1..acebdf1 100644
--- a/drivers/net/wireless/ath9k/main.c
+++ b/drivers/net/wireless/ath9k/main.c
@@ -206,8 +206,6 @@ static int ath_key_config(struct ath_softc *sc,
 	if (!ret)
 		return -EIO;
 
-	if (mac)
-		sc->sc_keytype = hk.kv_type;
 	return 0;
 }
 
@@ -778,7 +776,6 @@ static int ath9k_set_key(struct ieee80211_hw *hw,
 	case DISABLE_KEY:
 		ath_key_delete(sc, key);
 		clear_bit(key->keyidx, sc->sc_keymap);
-		sc->sc_keytype = ATH9K_CIPHER_CLR;
 		break;
 	default:
 		ret = -EINVAL;
@@ -1414,10 +1411,17 @@ static void ath_pci_remove(struct pci_dev *pdev)
 {
 	struct ieee80211_hw *hw = pci_get_drvdata(pdev);
 	struct ath_softc *sc = hw->priv;
+	enum ath9k_int status;
 
-	if (pdev->irq)
+	if (pdev->irq) {
+		ath9k_hw_set_interrupts(sc->sc_ah, 0);
+		/* clear the ISR */
+		ath9k_hw_getisr(sc->sc_ah, &status);
+		sc->sc_invalid = 1;
 		free_irq(pdev->irq, sc);
+	}
 	ath_detach(sc);
+
 	pci_iounmap(pdev, sc->mem);
 	pci_release_region(pdev, 0);
 	pci_disable_device(pdev);
diff --git a/drivers/net/wireless/ath9k/xmit.c b/drivers/net/wireless/ath9k/xmit.c
index 550129f..8b332e1 100644
--- a/drivers/net/wireless/ath9k/xmit.c
+++ b/drivers/net/wireless/ath9k/xmit.c
@@ -315,11 +315,11 @@ static int ath_tx_prepare(struct ath_softc *sc,
 		txctl->keyix = tx_info->control.hw_key->hw_key_idx;
 		txctl->frmlen += tx_info->control.icv_len;
 
-		if (sc->sc_keytype == ATH9K_CIPHER_WEP)
+		if (tx_info->control.hw_key->alg == ALG_WEP)
 			txctl->keytype = ATH9K_KEY_TYPE_WEP;
-		else if (sc->sc_keytype == ATH9K_CIPHER_TKIP)
+		else if (tx_info->control.hw_key->alg == ALG_TKIP)
 			txctl->keytype = ATH9K_KEY_TYPE_TKIP;
-		else if (sc->sc_keytype == ATH9K_CIPHER_AES_CCM)
+		else if (tx_info->control.hw_key->alg == ALG_CCMP)
 			txctl->keytype = ATH9K_KEY_TYPE_AES;
 	}
 
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index da8b743..a60ae86 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -58,6 +58,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0586, 0x3407), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x129b, 0x1666), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x157e, 0x300a), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0105, 0x145f), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
