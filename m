From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-11-25
Date: Tue, 25 Nov 2008 17:08:24 -0500
Message-ID: <20081125220824.GB25962@tuxdriver.com>
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

These fixes are intended for 2.6.28.  Included are a build fix,
a security issue (debugfs permissions), a fixup to a previous patch
from Johannes to correct some DMA API usage, a fix to prevent mac80211
from allowing the use of IBSS mode on channels that don't allow it,
an ath5k fix to limit wakeups when not associate, and some ath9k DMA
fixes for a problem that led to disk corruption...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 7e56b5d698707a9934833c47b24d78fb0bcaf764:
  Catalin Marinas (1):
        net: Fix memory leak in the proto_register function

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Abhijeet Kolekar (1):
      mac80211 : Fix setting ad-hoc mode and non-ibss channel

Cheng Renquan (1):
      ath5k: fix Security issue in DebugFS part of ath5k

Ingo Molnar (1):
      net/wireless/reg.c: fix bad WARN_ON in if statement

Johannes Berg (1):
      iwlagn: fix DMA sync

Luis R. Rodriguez (2):
      ath9k: Fix SW-IOMMU bounce buffer starvation
      ath9k: correct expected max RX buffer size

Martin Xu (1):
      ath5k: disable beacon filter when station is not associated

 drivers/net/wireless/ath5k/base.c      |   35 +++++++++++++++++++++++++++++++-
 drivers/net/wireless/ath5k/base.h      |    1 +
 drivers/net/wireless/ath5k/debug.c     |   10 ++++----
 drivers/net/wireless/ath9k/beacon.c    |   10 ++++----
 drivers/net/wireless/ath9k/recv.c      |   19 ++++++++++++----
 drivers/net/wireless/iwlwifi/iwl-agn.c |    8 ++++--
 net/mac80211/wext.c                    |    8 +++++++
 net/wireless/reg.c                     |    4 +-
 8 files changed, 74 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index cfd4d05..2d14255 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -240,6 +240,10 @@ static u64 ath5k_get_tsf(struct ieee80211_hw *hw);
 static void ath5k_reset_tsf(struct ieee80211_hw *hw);
 static int ath5k_beacon_update(struct ieee80211_hw *hw,
 		struct sk_buff *skb);
+static void ath5k_bss_info_changed(struct ieee80211_hw *hw,
+		struct ieee80211_vif *vif,
+		struct ieee80211_bss_conf *bss_conf,
+		u32 changes);
 
 static struct ieee80211_ops ath5k_hw_ops = {
 	.tx 		= ath5k_tx,
@@ -256,6 +260,7 @@ static struct ieee80211_ops ath5k_hw_ops = {
 	.get_tx_stats 	= ath5k_get_tx_stats,
 	.get_tsf 	= ath5k_get_tsf,
 	.reset_tsf 	= ath5k_reset_tsf,
+	.bss_info_changed = ath5k_bss_info_changed,
 };
 
 /*
@@ -2942,7 +2947,7 @@ static void ath5k_configure_filter(struct ieee80211_hw *hw,
 		sc->opmode != NL80211_IFTYPE_MESH_POINT &&
 		test_bit(ATH_STAT_PROMISC, sc->status))
 		rfilt |= AR5K_RX_FILTER_PROM;
-	if (sc->opmode == NL80211_IFTYPE_STATION ||
+	if ((sc->opmode == NL80211_IFTYPE_STATION && sc->assoc) ||
 		sc->opmode == NL80211_IFTYPE_ADHOC) {
 		rfilt |= AR5K_RX_FILTER_BEACON;
 	}
@@ -3083,4 +3088,32 @@ ath5k_beacon_update(struct ieee80211_hw *hw, struct sk_buff *skb)
 end:
 	return ret;
 }
+static void
+set_beacon_filter(struct ieee80211_hw *hw, bool enable)
+{
+	struct ath5k_softc *sc = hw->priv;
+	struct ath5k_hw *ah = sc->ah;
+	u32 rfilt;
+	rfilt = ath5k_hw_get_rx_filter(ah);
+	if (enable)
+		rfilt |= AR5K_RX_FILTER_BEACON;
+	else
+		rfilt &= ~AR5K_RX_FILTER_BEACON;
+	ath5k_hw_set_rx_filter(ah, rfilt);
+	sc->filter_flags = rfilt;
+}
 
+static void ath5k_bss_info_changed(struct ieee80211_hw *hw,
+				    struct ieee80211_vif *vif,
+				    struct ieee80211_bss_conf *bss_conf,
+				    u32 changes)
+{
+	struct ath5k_softc *sc = hw->priv;
+	if (changes & BSS_CHANGED_ASSOC) {
+		mutex_lock(&sc->lock);
+		sc->assoc = bss_conf->assoc;
+		if (sc->opmode == NL80211_IFTYPE_STATION)
+			set_beacon_filter(hw, sc->assoc);
+		mutex_unlock(&sc->lock);
+	}
+}
diff --git a/drivers/net/wireless/ath5k/base.h b/drivers/net/wireless/ath5k/base.h
index 06d1054..facc60d 100644
--- a/drivers/net/wireless/ath5k/base.h
+++ b/drivers/net/wireless/ath5k/base.h
@@ -179,6 +179,7 @@ struct ath5k_softc {
 
 	struct timer_list	calib_tim;	/* calibration timer */
 	int 			power_level;	/* Requested tx power in dbm */
+	bool			assoc;		/* assocate state */
 };
 
 #define ath5k_hw_hasbssidmask(_ah) \
diff --git a/drivers/net/wireless/ath5k/debug.c b/drivers/net/wireless/ath5k/debug.c
index 19980cb..ccaeb5c 100644
--- a/drivers/net/wireless/ath5k/debug.c
+++ b/drivers/net/wireless/ath5k/debug.c
@@ -417,19 +417,19 @@ ath5k_debug_init_device(struct ath5k_softc *sc)
 	sc->debug.debugfs_phydir = debugfs_create_dir(wiphy_name(sc->hw->wiphy),
 				ath5k_global_debugfs);
 
-	sc->debug.debugfs_debug = debugfs_create_file("debug", 0666,
+	sc->debug.debugfs_debug = debugfs_create_file("debug", S_IWUSR | S_IRUGO,
 				sc->debug.debugfs_phydir, sc, &fops_debug);
 
-	sc->debug.debugfs_registers = debugfs_create_file("registers", 0444,
+	sc->debug.debugfs_registers = debugfs_create_file("registers", S_IRUGO,
 				sc->debug.debugfs_phydir, sc, &fops_registers);
 
-	sc->debug.debugfs_tsf = debugfs_create_file("tsf", 0666,
+	sc->debug.debugfs_tsf = debugfs_create_file("tsf", S_IWUSR | S_IRUGO,
 				sc->debug.debugfs_phydir, sc, &fops_tsf);
 
-	sc->debug.debugfs_beacon = debugfs_create_file("beacon", 0666,
+	sc->debug.debugfs_beacon = debugfs_create_file("beacon", S_IWUSR | S_IRUGO,
 				sc->debug.debugfs_phydir, sc, &fops_beacon);
 
-	sc->debug.debugfs_reset = debugfs_create_file("reset", 0222,
+	sc->debug.debugfs_reset = debugfs_create_file("reset", S_IWUSR,
 				sc->debug.debugfs_phydir, sc, &fops_reset);
 }
 
diff --git a/drivers/net/wireless/ath9k/beacon.c b/drivers/net/wireless/ath9k/beacon.c
index 9e15c30..4dd1c1b 100644
--- a/drivers/net/wireless/ath9k/beacon.c
+++ b/drivers/net/wireless/ath9k/beacon.c
@@ -170,7 +170,7 @@ static struct ath_buf *ath_beacon_generate(struct ath_softc *sc, int if_id)
 	skb = (struct sk_buff *)bf->bf_mpdu;
 	if (skb) {
 		pci_unmap_single(sc->pdev, bf->bf_dmacontext,
-				 skb_end_pointer(skb) - skb->head,
+				 skb->len,
 				 PCI_DMA_TODEVICE);
 	}
 
@@ -193,7 +193,7 @@ static struct ath_buf *ath_beacon_generate(struct ath_softc *sc, int if_id)
 
 	bf->bf_buf_addr = bf->bf_dmacontext =
 		pci_map_single(sc->pdev, skb->data,
-			       skb_end_pointer(skb) - skb->head,
+			       skb->len,
 			       PCI_DMA_TODEVICE);
 
 	skb = ieee80211_get_buffered_bc(sc->hw, avp->av_if_data);
@@ -352,7 +352,7 @@ int ath_beacon_alloc(struct ath_softc *sc, int if_id)
 	if (bf->bf_mpdu != NULL) {
 		skb = (struct sk_buff *)bf->bf_mpdu;
 		pci_unmap_single(sc->pdev, bf->bf_dmacontext,
-				 skb_end_pointer(skb) - skb->head,
+				 skb->len,
 				 PCI_DMA_TODEVICE);
 		dev_kfree_skb_any(skb);
 		bf->bf_mpdu = NULL;
@@ -412,7 +412,7 @@ int ath_beacon_alloc(struct ath_softc *sc, int if_id)
 
 	bf->bf_buf_addr = bf->bf_dmacontext =
 		pci_map_single(sc->pdev, skb->data,
-			       skb_end_pointer(skb) - skb->head,
+			       skb->len,
 			       PCI_DMA_TODEVICE);
 	bf->bf_mpdu = skb;
 
@@ -439,7 +439,7 @@ void ath_beacon_return(struct ath_softc *sc, struct ath_vap *avp)
 		if (bf->bf_mpdu != NULL) {
 			struct sk_buff *skb = (struct sk_buff *)bf->bf_mpdu;
 			pci_unmap_single(sc->pdev, bf->bf_dmacontext,
-					 skb_end_pointer(skb) - skb->head,
+					 skb->len,
 					 PCI_DMA_TODEVICE);
 			dev_kfree_skb_any(skb);
 			bf->bf_mpdu = NULL;
diff --git a/drivers/net/wireless/ath9k/recv.c b/drivers/net/wireless/ath9k/recv.c
index 4983402..504a044 100644
--- a/drivers/net/wireless/ath9k/recv.c
+++ b/drivers/net/wireless/ath9k/recv.c
@@ -49,10 +49,12 @@ static void ath_rx_buf_link(struct ath_softc *sc, struct ath_buf *bf)
 	ASSERT(skb != NULL);
 	ds->ds_vdata = skb->data;
 
-	/* setup rx descriptors */
+	/* setup rx descriptors. The sc_rxbufsize here tells the harware
+	 * how much data it can DMA to us and that we are prepared
+	 * to process */
 	ath9k_hw_setuprxdesc(ah,
 			     ds,
-			     skb_tailroom(skb),   /* buffer size */
+			     sc->sc_rxbufsize,
 			     0);
 
 	if (sc->sc_rxlink == NULL)
@@ -398,6 +400,13 @@ static struct sk_buff *ath_rxbuf_alloc(struct ath_softc *sc,
 	 * in rx'd frames.
 	 */
 
+	/* Note: the kernel can allocate a value greater than
+	 * what we ask it to give us. We really only need 4 KB as that
+	 * is this hardware supports and in fact we need at least 3849
+	 * as that is the MAX AMSDU size this hardware supports.
+	 * Unfortunately this means we may get 8 KB here from the
+	 * kernel... and that is actually what is observed on some
+	 * systems :( */
 	skb = dev_alloc_skb(len + sc->sc_cachelsz - 1);
 	if (skb != NULL) {
 		off = ((unsigned long) skb->data) % sc->sc_cachelsz;
@@ -456,7 +465,7 @@ static int ath_rx_indicate(struct ath_softc *sc,
 	if (nskb != NULL) {
 		bf->bf_mpdu = nskb;
 		bf->bf_buf_addr = pci_map_single(sc->pdev, nskb->data,
-					 skb_end_pointer(nskb) - nskb->head,
+					 sc->sc_rxbufsize,
 					 PCI_DMA_FROMDEVICE);
 		bf->bf_dmacontext = bf->bf_buf_addr;
 		ATH_RX_CONTEXT(nskb)->ctx_rxbuf = bf;
@@ -542,7 +551,7 @@ int ath_rx_init(struct ath_softc *sc, int nbufs)
 
 			bf->bf_mpdu = skb;
 			bf->bf_buf_addr = pci_map_single(sc->pdev, skb->data,
-					 skb_end_pointer(skb) - skb->head,
+					 sc->sc_rxbufsize,
 					 PCI_DMA_FROMDEVICE);
 			bf->bf_dmacontext = bf->bf_buf_addr;
 			ATH_RX_CONTEXT(skb)->ctx_rxbuf = bf;
@@ -1007,7 +1016,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush)
 
 		pci_dma_sync_single_for_cpu(sc->pdev,
 					    bf->bf_buf_addr,
-					    skb_tailroom(skb),
+					    sc->sc_rxbufsize,
 					    PCI_DMA_FROMDEVICE);
 		pci_unmap_single(sc->pdev,
 				 bf->bf_buf_addr,
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 444c5cc..c4c0371 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -1384,9 +1384,11 @@ void iwl_rx_handle(struct iwl_priv *priv)
 
 		rxq->queue[i] = NULL;
 
-		pci_dma_sync_single_for_cpu(priv->pci_dev, rxb->aligned_dma_addr,
-					    priv->hw_params.rx_buf_size,
-					    PCI_DMA_FROMDEVICE);
+		dma_sync_single_range_for_cpu(
+				&priv->pci_dev->dev, rxb->real_dma_addr,
+				rxb->aligned_dma_addr - rxb->real_dma_addr,
+				priv->hw_params.rx_buf_size,
+				PCI_DMA_FROMDEVICE);
 		pkt = (struct iwl_rx_packet *)rxb->skb->data;
 
 		/* Reclaim a command buffer only if this packet is a response
diff --git a/net/mac80211/wext.c b/net/mac80211/wext.c
index 742f811..ab4ddba 100644
--- a/net/mac80211/wext.c
+++ b/net/mac80211/wext.c
@@ -271,6 +271,7 @@ static int ieee80211_ioctl_siwmode(struct net_device *dev,
 				   __u32 *mode, char *extra)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = sdata->local;
 	int type;
 
 	if (sdata->vif.type == NL80211_IFTYPE_AP_VLAN)
@@ -281,6 +282,13 @@ static int ieee80211_ioctl_siwmode(struct net_device *dev,
 		type = NL80211_IFTYPE_STATION;
 		break;
 	case IW_MODE_ADHOC:
+		/* Setting ad-hoc mode on non ibss channel is not
+		 * supported.
+		 */
+		if (local->oper_channel &&
+		    (local->oper_channel->flags & IEEE80211_CHAN_NO_IBSS))
+			return -EOPNOTSUPP;
+
 		type = NL80211_IFTYPE_ADHOC;
 		break;
 	case IW_MODE_REPEAT:
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 626dbb6..eb3b1a9 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -343,9 +343,9 @@ static int ignore_request(struct wiphy *wiphy, enum reg_set_by set_by,
 				return 0;
 			return -EALREADY;
 		}
-		if (WARN_ON(!is_alpha2_set(alpha2) || !is_an_alpha2(alpha2)),
+		if (WARN(!is_alpha2_set(alpha2) || !is_an_alpha2(alpha2),
 				"Invalid Country IE regulatory hint passed "
-				"to the wireless core\n")
+				"to the wireless core\n"))
 			return -EINVAL;
 		/* We ignore Country IE hints for now, as we haven't yet
 		 * added the dot11MultiDomainCapabilityEnabled flag
-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
