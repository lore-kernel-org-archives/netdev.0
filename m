From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2009-02-11
Date: Wed, 11 Feb 2009 14:12:12 -0500
Message-ID: <20090211191212.GA7033@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a few more intended for 2.6.29.  The ath5k one is already in
-next, but it turns-out to affect 2.6.29 as well.  The two zd1211rw ones
are one-liners that enable new hardware for that driver.

The iwlwifi patch corrects a problem (introduced by the previous iwlwifi
fix) that disables the iwlwifi devices after suspend/resume.  It will
conflict with what is already in -next -- just take the hunks that are
already in -next and ignore the hunks introduced here.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 7b7a799d664a46eec6cb7de200c90f40730497a7:
  Meelis Roos (1):
        sunhme: Fix Quattro HME irq registration on proble failures

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bob Copeland (1):
      ath5k: fix bf->skb==NULL panic in ath5k_tasklet_rx

Hin-Tak Leung (2):
      zd1211rw: adding 0ace:0xa211 as a ZD1211 device
      zd1211rw: treat MAXIM_NEW_RF(0x08) as UW2453_RF(0x09) for TP-Link WN322/422G

Johannes Berg (1):
      mac80211: restrict to AP in outgoing interface heuristic

Reinette Chatre (1):
      iwlwifi: fix suspend/resume and its usage of pci saved state

 drivers/net/wireless/ath5k/base.c           |   85 +++++++++++++++++----------
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   15 ++++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   15 ++++-
 drivers/net/wireless/zd1211rw/zd_rf.c       |    1 +
 drivers/net/wireless/zd1211rw/zd_usb.c      |    1 +
 net/mac80211/tx.c                           |    2 +
 6 files changed, 83 insertions(+), 36 deletions(-)

diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index a533ed6..1d77ee9 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -1098,6 +1098,42 @@ ath5k_hw_to_driver_rix(struct ath5k_softc *sc, int hw_rix)
 * Buffers setup *
 \***************/
 
+static
+struct sk_buff *ath5k_rx_skb_alloc(struct ath5k_softc *sc, dma_addr_t *skb_addr)
+{
+	struct sk_buff *skb;
+	unsigned int off;
+
+	/*
+	 * Allocate buffer with headroom_needed space for the
+	 * fake physical layer header at the start.
+	 */
+	skb = dev_alloc_skb(sc->rxbufsize + sc->cachelsz - 1);
+
+	if (!skb) {
+		ATH5K_ERR(sc, "can't alloc skbuff of size %u\n",
+				sc->rxbufsize + sc->cachelsz - 1);
+		return NULL;
+	}
+	/*
+	 * Cache-line-align.  This is important (for the
+	 * 5210 at least) as not doing so causes bogus data
+	 * in rx'd frames.
+	 */
+	off = ((unsigned long)skb->data) % sc->cachelsz;
+	if (off != 0)
+		skb_reserve(skb, sc->cachelsz - off);
+
+	*skb_addr = pci_map_single(sc->pdev,
+		skb->data, sc->rxbufsize, PCI_DMA_FROMDEVICE);
+	if (unlikely(pci_dma_mapping_error(sc->pdev, *skb_addr))) {
+		ATH5K_ERR(sc, "%s: DMA mapping failed\n", __func__);
+		dev_kfree_skb(skb);
+		return NULL;
+	}
+	return skb;
+}
+
 static int
 ath5k_rxbuf_setup(struct ath5k_softc *sc, struct ath5k_buf *bf)
 {
@@ -1105,37 +1141,11 @@ ath5k_rxbuf_setup(struct ath5k_softc *sc, struct ath5k_buf *bf)
 	struct sk_buff *skb = bf->skb;
 	struct ath5k_desc *ds;
 
-	if (likely(skb == NULL)) {
-		unsigned int off;
-
-		/*
-		 * Allocate buffer with headroom_needed space for the
-		 * fake physical layer header at the start.
-		 */
-		skb = dev_alloc_skb(sc->rxbufsize + sc->cachelsz - 1);
-		if (unlikely(skb == NULL)) {
-			ATH5K_ERR(sc, "can't alloc skbuff of size %u\n",
-					sc->rxbufsize + sc->cachelsz - 1);
+	if (!skb) {
+		skb = ath5k_rx_skb_alloc(sc, &bf->skbaddr);
+		if (!skb)
 			return -ENOMEM;
-		}
-		/*
-		 * Cache-line-align.  This is important (for the
-		 * 5210 at least) as not doing so causes bogus data
-		 * in rx'd frames.
-		 */
-		off = ((unsigned long)skb->data) % sc->cachelsz;
-		if (off != 0)
-			skb_reserve(skb, sc->cachelsz - off);
-
 		bf->skb = skb;
-		bf->skbaddr = pci_map_single(sc->pdev,
-			skb->data, sc->rxbufsize, PCI_DMA_FROMDEVICE);
-		if (unlikely(pci_dma_mapping_error(sc->pdev, bf->skbaddr))) {
-			ATH5K_ERR(sc, "%s: DMA mapping failed\n", __func__);
-			dev_kfree_skb(skb);
-			bf->skb = NULL;
-			return -ENOMEM;
-		}
 	}
 
 	/*
@@ -1664,7 +1674,8 @@ ath5k_tasklet_rx(unsigned long data)
 {
 	struct ieee80211_rx_status rxs = {};
 	struct ath5k_rx_status rs = {};
-	struct sk_buff *skb;
+	struct sk_buff *skb, *next_skb;
+	dma_addr_t next_skb_addr;
 	struct ath5k_softc *sc = (void *)data;
 	struct ath5k_buf *bf, *bf_last;
 	struct ath5k_desc *ds;
@@ -1749,10 +1760,17 @@ ath5k_tasklet_rx(unsigned long data)
 				goto next;
 		}
 accept:
+		next_skb = ath5k_rx_skb_alloc(sc, &next_skb_addr);
+
+		/*
+		 * If we can't replace bf->skb with a new skb under memory
+		 * pressure, just skip this packet
+		 */
+		if (!next_skb)
+			goto next;
+
 		pci_unmap_single(sc->pdev, bf->skbaddr, sc->rxbufsize,
 				PCI_DMA_FROMDEVICE);
-		bf->skb = NULL;
-
 		skb_put(skb, rs.rs_datalen);
 
 		/* The MAC header is padded to have 32-bit boundary if the
@@ -1825,6 +1843,9 @@ accept:
 			ath5k_check_ibss_tsf(sc, skb, &rxs);
 
 		__ieee80211_rx(sc->hw, skb, &rxs);
+
+		bf->skb = next_skb;
+		bf->skbaddr = next_skb_addr;
 next:
 		list_move_tail(&bf->list, &sc->rxbuf);
 	} while (ath5k_rxbuf_setup(sc, bf) == 0);
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index c01ea48..36bafeb 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -4042,7 +4042,19 @@ static int iwl_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 		priv->is_open = 1;
 	}
 
-	pci_save_state(pdev);
+	/* pci driver assumes state will be saved in this function.
+	 * pci state is saved and device disabled when interface is
+	 * stopped, so at this time pci device will always be disabled -
+	 * whether interface was started or not. saving pci state now will
+	 * cause saved state be that of a disabled device, which will cause
+	 * problems during resume in that we will end up with a disabled device.
+	 *
+	 * indicate that the current saved state (from when interface was
+	 * stopped) is valid. if interface was never up at time of suspend
+	 * then the saved state will still be valid as it was saved during
+	 * .probe. */
+	pdev->state_saved = true;
+
 	pci_set_power_state(pdev, PCI_D3hot);
 
 	return 0;
@@ -4053,7 +4065,6 @@ static int iwl_pci_resume(struct pci_dev *pdev)
 	struct iwl_priv *priv = pci_get_drvdata(pdev);
 
 	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
 
 	if (priv->is_open)
 		iwl_mac_start(priv->hw);
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 5b44d32..93be74a 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -8143,7 +8143,19 @@ static int iwl3945_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 		priv->is_open = 1;
 	}
 
-	pci_save_state(pdev);
+	/* pci driver assumes state will be saved in this function.
+	 * pci state is saved and device disabled when interface is
+	 * stopped, so at this time pci device will always be disabled -
+	 * whether interface was started or not. saving pci state now will
+	 * cause saved state be that of a disabled device, which will cause
+	 * problems during resume in that we will end up with a disabled device.
+	 *
+	 * indicate that the current saved state (from when interface was
+	 * stopped) is valid. if interface was never up at time of suspend
+	 * then the saved state will still be valid as it was saved during
+	 * .probe. */
+	pdev->state_saved = true;
+
 	pci_set_power_state(pdev, PCI_D3hot);
 
 	return 0;
@@ -8154,7 +8166,6 @@ static int iwl3945_pci_resume(struct pci_dev *pdev)
 	struct iwl3945_priv *priv = pci_get_drvdata(pdev);
 
 	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
 
 	if (priv->is_open)
 		iwl3945_mac_start(priv->hw);
diff --git a/drivers/net/wireless/zd1211rw/zd_rf.c b/drivers/net/wireless/zd1211rw/zd_rf.c
index 7207bfd..c875ee0 100644
--- a/drivers/net/wireless/zd1211rw/zd_rf.c
+++ b/drivers/net/wireless/zd1211rw/zd_rf.c
@@ -86,6 +86,7 @@ int zd_rf_init_hw(struct zd_rf *rf, u8 type)
 	case AL7230B_RF:
 		r = zd_rf_init_al7230b(rf);
 		break;
+	case MAXIM_NEW_RF:
 	case UW2453_RF:
 		r = zd_rf_init_uw2453(rf);
 		break;
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 17527f7..f0e5e94 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -37,6 +37,7 @@
 static struct usb_device_id usb_ids[] = {
 	/* ZD1211 */
 	{ USB_DEVICE(0x0ace, 0x1211), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0ace, 0xa211), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x07b8, 0x6001), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x126f, 0xa006), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x6891, 0xa727), .driver_info = DEVICE_ZD1211 },
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 4278e54..94de503 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1343,6 +1343,8 @@ int ieee80211_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 						list) {
 				if (!netif_running(sdata->dev))
 					continue;
+				if (sdata->vif.type != NL80211_IFTYPE_AP)
+					continue;
 				if (compare_ether_addr(sdata->dev->dev_addr,
 						       hdr->addr2)) {
 					dev_hold(sdata->dev);
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
