From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-10-09
Date: Thu, 9 Oct 2014 11:44:02 -0400
Message-ID: <20141009154402.GB13986@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.18 stream!

Andrea Merello makes rtl818x_pci use a more reasonable transmission
rate for HW generated frames.

Fabian Frederick tweaks some kernel-doc bits to avoid warnings.

Larry Finger corrects a possible unaligned access in the rtlwifi code.

Marek Puzyniak avoids a kernel panic in ath9k_hw_reset.

Sujith Manoharan goes for the hat trick -- he fixes a smatch warning
in the shared ath code, he fixes a crash in ath9k, and he corrects
a sequence number assignment problem in ath9k too.

For ease of merging, I pulled the last bits of the wireless tree as well...

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3f08e47291879fb047d7d4464d2beaedfea4eb63:

  rtlwifi: Fix static checker warnings for various drivers (2014-10-02 14:2=
6:32 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
tags/master-2014-10-08

for you to fetch changes up to 1fca350b761631d182c2e8bce530896e66404bc2:

  rtlwifi: Fix possible unaligned array in ether_addr_copy() (2014-10-08 15=
:24:16 -0400)

----------------------------------------------------------------
Andrea Merello (1):
      rtl818x_pci: fix response rate may be incorrect.

Fabian Frederick (1):
      net: rfkill: kernel-doc warning fixes

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless

Larry Finger (1):
      rtlwifi: Fix possible unaligned array in ether_addr_copy()

Marek Puzyniak (1):
      ath9k_htc: avoid kernel panic in ath9k_hw_reset

Sujith Manoharan (3):
      ath: Fix smatch warning
      ath9k: Fix crash in MCC mode
      ath9k: Fix sequence number assignment

 drivers/net/wireless/ath/ath9k/ath9k.h             |  4 ++-
 drivers/net/wireless/ath/ath9k/beacon.c            | 12 ++------
 drivers/net/wireless/ath/ath9k/common-beacon.c     |  5 ++-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |  1 +
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |  2 +-
 drivers/net/wireless/ath/ath9k/main.c              |  4 +--
 drivers/net/wireless/ath/ath9k/tx99.c              |  8 ++++-
 drivers/net/wireless/ath/ath9k/xmit.c              | 34 +++++++++++++-----=
--
 drivers/net/wireless/ath/main.c                    |  8 ++---
 drivers/net/wireless/brcm80211/Kconfig             | 10 ++++++
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   | 10 +++---
 drivers/net/wireless/brcm80211/brcmfmac/bcdc.h     |  7 +++--
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     | 12 ++++++--
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h     |  2 ++
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h   | 11 +++++--
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  | 11 +++++--
 drivers/net/wireless/rtl818x/rtl8180/dev.c         | 36 +++++++++++++++---=
----
 drivers/net/wireless/rtlwifi/wifi.h                |  2 +-
 drivers/nfc/microread/microread.c                  | 16 +++++++---
 drivers/nfc/st21nfca/Makefile                      |  5 +--
 drivers/nfc/st21nfcb/Makefile                      |  5 +--
 net/mac80211/sta_info.c                            |  2 +-
 net/rfkill/core.c                                  |  4 +--
 net/rfkill/rfkill-gpio.c                           |  3 +-
 net/wireless/nl80211.c                             |  6 ++++
 25 files changed, 149 insertions(+), 71 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/=
ath/ath9k/ath9k.h
index bfa0b1518da1..01a7db061c6a 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -294,7 +294,6 @@ struct ath_tx_control {
  *  (axq_qnum).
  */
 struct ath_tx {
-	u16 seq_no;
 	u32 txqsetup;
 	spinlock_t txbuflock;
 	struct list_head txbuf;
@@ -563,6 +562,7 @@ int ath_tx_init(struct ath_softc *sc, int nbufs);
 int ath_txq_update(struct ath_softc *sc, int qnum,
 		   struct ath9k_tx_queue_info *q);
 void ath_update_max_aggr_framelen(struct ath_softc *sc, int queue, int txo=
p);
+void ath_assign_seq(struct ath_common *common, struct sk_buff *skb);
 int ath_tx_start(struct ieee80211_hw *hw, struct sk_buff *skb,
 		 struct ath_tx_control *txctl);
 void ath_tx_cabq(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
@@ -592,6 +592,8 @@ void ath9k_release_buffered_frames(struct ieee80211_hw =
*hw,
 struct ath_vif {
 	struct list_head list;
=20
+	u16 seq_no;
+
 	/* BSS info */
 	u8 bssid[ETH_ALEN];
 	u16 aid;
diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wireless=
/ath/ath9k/beacon.c
index a6af855ef6ed..ecb783beeec2 100644
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -144,16 +144,8 @@ static struct ath_buf *ath9k_beacon_generate(struct ie=
ee80211_hw *hw,
 	mgmt_hdr->u.beacon.timestamp =3D avp->tsf_adjust;
=20
 	info =3D IEEE80211_SKB_CB(skb);
-	if (info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ) {
-		/*
-		 * TODO: make sure the seq# gets assigned properly (vs. other
-		 * TX frames)
-		 */
-		struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *)skb->data;
-		sc->tx.seq_no +=3D 0x10;
-		hdr->seq_ctrl &=3D cpu_to_le16(IEEE80211_SCTL_FRAG);
-		hdr->seq_ctrl |=3D cpu_to_le16(sc->tx.seq_no);
-	}
+
+	ath_assign_seq(common, skb);
=20
 	if (vif->p2p)
 		ath9k_beacon_add_noa(sc, avp, skb);
diff --git a/drivers/net/wireless/ath/ath9k/common-beacon.c b/drivers/net/w=
ireless/ath/ath9k/common-beacon.c
index 733be5178481..6ad44470d0f2 100644
--- a/drivers/net/wireless/ath/ath9k/common-beacon.c
+++ b/drivers/net/wireless/ath/ath9k/common-beacon.c
@@ -57,7 +57,7 @@ int ath9k_cmn_beacon_config_sta(struct ath_hw *ah,
 				 struct ath9k_beacon_state *bs)
 {
 	struct ath_common *common =3D ath9k_hw_common(ah);
-	int dtim_intval, sleepduration;
+	int dtim_intval;
 	u64 tsf;
=20
 	/* No need to configure beacon if we are not associated */
@@ -75,7 +75,6 @@ int ath9k_cmn_beacon_config_sta(struct ath_hw *ah,
 	 * last beacon we received (which may be none).
 	 */
 	dtim_intval =3D conf->intval * conf->dtim_period;
-	sleepduration =3D ah->hw->conf.listen_interval * conf->intval;
=20
 	/*
 	 * Pull nexttbtt forward to reflect the current
@@ -113,7 +112,7 @@ int ath9k_cmn_beacon_config_sta(struct ath_hw *ah,
 	 */
=20
 	bs->bs_sleepduration =3D TU_TO_USEC(roundup(IEEE80211_MS_TO_TU(100),
-						  sleepduration));
+						  conf->intval));
 	if (bs->bs_sleepduration > bs->bs_dtimperiod)
 		bs->bs_sleepduration =3D bs->bs_dtimperiod;
=20
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wi=
reless/ath/ath9k/htc_drv_init.c
index d779f4fa50e3..4014c4be6e79 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -464,6 +464,7 @@ static int ath9k_init_priv(struct ath9k_htc_priv *priv,
 		return -ENOMEM;
=20
 	ah->dev =3D priv->dev;
+	ah->hw =3D priv->hw;
 	ah->hw_version.devid =3D devid;
 	ah->hw_version.usbdev =3D drv_info;
 	ah->ah_flags |=3D AH_USE_EEPROM;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wi=
reless/ath/ath9k/htc_drv_txrx.c
index bb86eb2ffc95..f0484b1b617e 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -978,7 +978,7 @@ static bool ath9k_rx_prepare(struct ath9k_htc_priv *pri=
v,
 	struct ath_hw *ah =3D common->ah;
 	struct ath_htc_rx_status *rxstatus;
 	struct ath_rx_status rx_stats;
-	bool decrypt_error;
+	bool decrypt_error =3D false;
=20
 	if (skb->len < HTC_RX_FRAME_HEADER_SIZE) {
 		ath_err(common, "Corrupted RX frame, dropping (len: %d)\n",
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 9618cb35922d..6f6a974f7fdb 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -502,7 +502,7 @@ irqreturn_t ath_isr(int irq, void *dev)
 	 * touch anything. Note this can happen early
 	 * on if the IRQ is shared.
 	 */
-	if (test_bit(ATH_OP_INVALID, &common->op_flags))
+	if (!ah || test_bit(ATH_OP_INVALID, &common->op_flags))
 		return IRQ_NONE;
=20
 	/* shared irq, not for us */
@@ -2332,7 +2332,7 @@ static void ath9k_remove_chanctx(struct ieee80211_hw =
*hw,
 		conf->def.chan->center_freq);
=20
 	ctx->assigned =3D false;
-	ctx->hw_queue_base =3D -1;
+	ctx->hw_queue_base =3D 0;
 	ath_chanctx_event(sc, NULL, ATH_CHANCTX_EVENT_UNASSIGN);
=20
 	mutex_unlock(&sc->mutex);
diff --git a/drivers/net/wireless/ath/ath9k/tx99.c b/drivers/net/wireless/a=
th/ath9k/tx99.c
index 8a69d08ec55c..40ab65e6882f 100644
--- a/drivers/net/wireless/ath/ath9k/tx99.c
+++ b/drivers/net/wireless/ath/ath9k/tx99.c
@@ -54,6 +54,12 @@ static struct sk_buff *ath9k_build_tx99_skb(struct ath_s=
oftc *sc)
 	struct ieee80211_hdr *hdr;
 	struct ieee80211_tx_info *tx_info;
 	struct sk_buff *skb;
+	struct ath_vif *avp;
+
+	if (!sc->tx99_vif)
+		return NULL;
+
+	avp =3D (struct ath_vif *)sc->tx99_vif->drv_priv;
=20
 	skb =3D alloc_skb(len, GFP_KERNEL);
 	if (!skb)
@@ -71,7 +77,7 @@ static struct sk_buff *ath9k_build_tx99_skb(struct ath_so=
ftc *sc)
 	memcpy(hdr->addr2, hw->wiphy->perm_addr, ETH_ALEN);
 	memcpy(hdr->addr3, hw->wiphy->perm_addr, ETH_ALEN);
=20
-	hdr->seq_ctrl |=3D cpu_to_le16(sc->tx.seq_no);
+	hdr->seq_ctrl |=3D cpu_to_le16(avp->seq_no);
=20
 	tx_info =3D IEEE80211_SKB_CB(skb);
 	memset(tx_info, 0, sizeof(*tx_info));
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 151ae49fa57e..493a183d0aaf 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -2139,6 +2139,28 @@ static struct ath_buf *ath_tx_setup_buffer(struct at=
h_softc *sc,
 	return bf;
 }
=20
+void ath_assign_seq(struct ath_common *common, struct sk_buff *skb)
+{
+	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *) skb->data;
+	struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(skb);
+	struct ieee80211_vif *vif =3D info->control.vif;
+	struct ath_vif *avp;
+
+	if (!(info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ))
+		return;
+
+	if (!vif)
+		return;
+
+	avp =3D (struct ath_vif *)vif->drv_priv;
+
+	if (info->flags & IEEE80211_TX_CTL_FIRST_FRAGMENT)
+		avp->seq_no +=3D 0x10;
+
+	hdr->seq_ctrl &=3D cpu_to_le16(IEEE80211_SCTL_FRAG);
+	hdr->seq_ctrl |=3D cpu_to_le16(avp->seq_no);
+}
+
 static int ath_tx_prepare(struct ieee80211_hw *hw, struct sk_buff *skb,
 			  struct ath_tx_control *txctl)
 {
@@ -2162,17 +2184,7 @@ static int ath_tx_prepare(struct ieee80211_hw *hw, s=
truct sk_buff *skb,
 	if (info->control.hw_key)
 		frmlen +=3D info->control.hw_key->icv_len;
=20
-	/*
-	 * As a temporary workaround, assign seq# here; this will likely need
-	 * to be cleaned up to work better with Beacon transmission and virtual
-	 * BSSes.
-	 */
-	if (info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ) {
-		if (info->flags & IEEE80211_TX_CTL_FIRST_FRAGMENT)
-			sc->tx.seq_no +=3D 0x10;
-		hdr->seq_ctrl &=3D cpu_to_le16(IEEE80211_SCTL_FRAG);
-		hdr->seq_ctrl |=3D cpu_to_le16(sc->tx.seq_no);
-	}
+	ath_assign_seq(ath9k_hw_common(sc->sc_ah), skb);
=20
 	if ((vif && vif->type !=3D NL80211_IFTYPE_AP &&
 	            vif->type !=3D NL80211_IFTYPE_AP_VLAN) ||
diff --git a/drivers/net/wireless/ath/main.c b/drivers/net/wireless/ath/mai=
n.c
index 83f47af19280..338d72337604 100644
--- a/drivers/net/wireless/ath/main.c
+++ b/drivers/net/wireless/ath/main.c
@@ -79,13 +79,13 @@ void ath_printk(const char *level, const struct ath_com=
mon* common,
 	vaf.fmt =3D fmt;
 	vaf.va =3D &args;
=20
-	if (common && common->hw && common->hw->wiphy)
+	if (common && common->hw && common->hw->wiphy) {
 		printk("%sath: %s: %pV",
 		       level, wiphy_name(common->hw->wiphy), &vaf);
-	else
+		trace_ath_log(common->hw->wiphy, &vaf);
+	} else {
 		printk("%sath: %pV", level, &vaf);
-
-	trace_ath_log(common->hw->wiphy, &vaf);
+	}
=20
 	va_end(args);
 }
diff --git a/drivers/net/wireless/brcm80211/Kconfig b/drivers/net/wireless/=
brcm80211/Kconfig
index b8e2561ea645..fe3dc126b149 100644
--- a/drivers/net/wireless/brcm80211/Kconfig
+++ b/drivers/net/wireless/brcm80211/Kconfig
@@ -27,10 +27,17 @@ config BRCMFMAC
 	  one of the bus interface support. If you choose to build a module,
 	  it'll be called brcmfmac.ko.
=20
+config BRCMFMAC_PROTO_BCDC
+	bool
+
+config BRCMFMAC_PROTO_MSGBUF
+	bool
+
 config BRCMFMAC_SDIO
 	bool "SDIO bus interface support for FullMAC driver"
 	depends on (MMC =3D y || MMC =3D BRCMFMAC)
 	depends on BRCMFMAC
+	select BRCMFMAC_PROTO_BCDC
 	select FW_LOADER
 	default y
 	---help---
@@ -42,6 +49,7 @@ config BRCMFMAC_USB
 	bool "USB bus interface support for FullMAC driver"
 	depends on (USB =3D y || USB =3D BRCMFMAC)
 	depends on BRCMFMAC
+	select BRCMFMAC_PROTO_BCDC
 	select FW_LOADER
 	---help---
 	  This option enables the USB bus interface support for Broadcom
@@ -52,6 +60,8 @@ config BRCMFMAC_PCIE
 	bool "PCIE bus interface support for FullMAC driver"
 	depends on BRCMFMAC
 	depends on PCI
+	depends on HAS_DMA
+	select BRCMFMAC_PROTO_MSGBUF
 	select FW_LOADER
 	---help---
 	  This option enables the PCIE bus interface support for Broadcom
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/Makefile b/drivers/net=
/wireless/brcm80211/brcmfmac/Makefile
index c35adf4bc70b..90a977fe9a64 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/Makefile
+++ b/drivers/net/wireless/brcm80211/brcmfmac/Makefile
@@ -30,16 +30,18 @@ brcmfmac-objs +=3D \
 		fwsignal.o \
 		p2p.o \
 		proto.o \
-		bcdc.o \
-		commonring.o \
-		flowring.o \
-		msgbuf.o \
 		dhd_common.o \
 		dhd_linux.o \
 		firmware.o \
 		feature.o \
 		btcoex.o \
 		vendor.o
+brcmfmac-$(CONFIG_BRCMFMAC_PROTO_BCDC) +=3D \
+		bcdc.o
+brcmfmac-$(CONFIG_BRCMFMAC_PROTO_MSGBUF) +=3D \
+		commonring.o \
+		flowring.o \
+		msgbuf.o
 brcmfmac-$(CONFIG_BRCMFMAC_SDIO) +=3D \
 		dhd_sdio.o \
 		bcmsdh.o
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcdc.h b/drivers/net/w=
ireless/brcm80211/brcmfmac/bcdc.h
index 17e8c039ff32..6003179c0ceb 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcdc.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcdc.h
@@ -16,9 +16,12 @@
 #ifndef BRCMFMAC_BCDC_H
 #define BRCMFMAC_BCDC_H
=20
-
+#ifdef CONFIG_BRCMFMAC_PROTO_BCDC
 int brcmf_proto_bcdc_attach(struct brcmf_pub *drvr);
 void brcmf_proto_bcdc_detach(struct brcmf_pub *drvr);
-
+#else
+static inline int brcmf_proto_bcdc_attach(struct brcmf_pub *drvr) { return=
 0; }
+static inline void brcmf_proto_bcdc_detach(struct brcmf_pub *drvr) {}
+#endif
=20
 #endif /* BRCMFMAC_BCDC_H */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c b/drivers/net/w=
ireless/brcm80211/brcmfmac/fweh.c
index 4f1daabc551b..44fc85f68f7a 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
@@ -185,7 +185,13 @@ static void brcmf_fweh_handle_if_event(struct brcmf_pu=
b *drvr,
 		  ifevent->action, ifevent->ifidx, ifevent->bssidx,
 		  ifevent->flags, ifevent->role);
=20
-	if (ifevent->flags & BRCMF_E_IF_FLAG_NOIF) {
+	/* The P2P Device interface event must not be ignored
+	 * contrary to what firmware tells us. The only way to
+	 * distinguish the P2P Device is by looking at the ifidx
+	 * and bssidx received.
+	 */
+	if (!(ifevent->ifidx =3D=3D 0 && ifevent->bssidx =3D=3D 1) &&
+	    (ifevent->flags & BRCMF_E_IF_FLAG_NOIF)) {
 		brcmf_dbg(EVENT, "event can be ignored\n");
 		return;
 	}
@@ -210,12 +216,12 @@ static void brcmf_fweh_handle_if_event(struct brcmf_p=
ub *drvr,
 				return;
 	}
=20
-	if (ifevent->action =3D=3D BRCMF_E_IF_CHANGE)
+	if (ifp && ifevent->action =3D=3D BRCMF_E_IF_CHANGE)
 		brcmf_fws_reset_interface(ifp);
=20
 	err =3D brcmf_fweh_call_event_handler(ifp, emsg->event_code, emsg, data);
=20
-	if (ifevent->action =3D=3D BRCMF_E_IF_DEL) {
+	if (ifp && ifevent->action =3D=3D BRCMF_E_IF_DEL) {
 		brcmf_fws_del_interface(ifp);
 		brcmf_del_if(drvr, ifevent->bssidx);
 	}
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fweh.h b/drivers/net/w=
ireless/brcm80211/brcmfmac/fweh.h
index dd20b1862d44..cbf033f59109 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/fweh.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/fweh.h
@@ -172,6 +172,8 @@ enum brcmf_fweh_event_code {
 #define BRCMF_E_IF_ROLE_STA			0
 #define BRCMF_E_IF_ROLE_AP			1
 #define BRCMF_E_IF_ROLE_WDS			2
+#define BRCMF_E_IF_ROLE_P2P_GO			3
+#define BRCMF_E_IF_ROLE_P2P_CLIENT		4
=20
 /**
  * definitions for event packet validation.
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h b/drivers/net=
/wireless/brcm80211/brcmfmac/msgbuf.h
index f901ae52bf2b..77a51b8c1e12 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h
@@ -15,6 +15,7 @@
 #ifndef BRCMFMAC_MSGBUF_H
 #define BRCMFMAC_MSGBUF_H
=20
+#ifdef CONFIG_BRCMFMAC_PROTO_MSGBUF
=20
 #define BRCMF_H2D_MSGRING_CONTROL_SUBMIT_MAX_ITEM	20
 #define BRCMF_H2D_MSGRING_RXPOST_SUBMIT_MAX_ITEM	256
@@ -32,9 +33,15 @@
=20
=20
 int brcmf_proto_msgbuf_rx_trigger(struct device *dev);
+void brcmf_msgbuf_delete_flowring(struct brcmf_pub *drvr, u8 flowid);
 int brcmf_proto_msgbuf_attach(struct brcmf_pub *drvr);
 void brcmf_proto_msgbuf_detach(struct brcmf_pub *drvr);
-void brcmf_msgbuf_delete_flowring(struct brcmf_pub *drvr, u8 flowid);
-
+#else
+static inline int brcmf_proto_msgbuf_attach(struct brcmf_pub *drvr)
+{
+	return 0;
+}
+static inline void brcmf_proto_msgbuf_detach(struct brcmf_pub *drvr) {}
+#endif
=20
 #endif /* BRCMFMAC_MSGBUF_H */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index e9e18e1566dd..28fa25b509db 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -498,8 +498,11 @@ brcmf_configure_arp_offload(struct brcmf_if *ifp, bool=
 enable)
 static void
 brcmf_cfg80211_update_proto_addr_mode(struct wireless_dev *wdev)
 {
-	struct net_device *ndev =3D wdev->netdev;
-	struct brcmf_if *ifp =3D netdev_priv(ndev);
+	struct brcmf_cfg80211_vif *vif;
+	struct brcmf_if *ifp;
+
+	vif =3D container_of(wdev, struct brcmf_cfg80211_vif, wdev);
+	ifp =3D vif->ifp;
=20
 	if ((wdev->iftype =3D=3D NL80211_IFTYPE_ADHOC) ||
 	    (wdev->iftype =3D=3D NL80211_IFTYPE_AP) ||
@@ -4964,7 +4967,7 @@ static void brcmf_count_20mhz_channels(struct brcmf_c=
fg80211_info *cfg,
 	struct brcmu_chan ch;
 	int i;
=20
-	for (i =3D 0; i <=3D total; i++) {
+	for (i =3D 0; i < total; i++) {
 		ch.chspec =3D (u16)le32_to_cpu(chlist->element[i]);
 		cfg->d11inf.decchspec(&ch);
=20
@@ -5189,6 +5192,7 @@ static int brcmf_enable_bw40_2g(struct brcmf_cfg80211=
_info *cfg)
=20
 		ch.band =3D BRCMU_CHAN_BAND_2G;
 		ch.bw =3D BRCMU_CHAN_BW_40;
+		ch.sb =3D BRCMU_CHAN_SB_NONE;
 		ch.chnum =3D 0;
 		cfg->d11inf.encchspec(&ch);
=20
@@ -5222,6 +5226,7 @@ static int brcmf_enable_bw40_2g(struct brcmf_cfg80211=
_info *cfg)
=20
 			brcmf_update_bw40_channel_flag(&band->channels[j], &ch);
 		}
+		kfree(pbuf);
 	}
 	return err;
 }
diff --git a/drivers/net/wireless/rtl818x/rtl8180/dev.c b/drivers/net/wirel=
ess/rtl818x/rtl8180/dev.c
index ded967aa6ecb..706b844bce00 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
@@ -742,35 +742,49 @@ static void rtl8180_int_disable(struct ieee80211_hw *=
dev)
 }
=20
 static void rtl8180_conf_basic_rates(struct ieee80211_hw *dev,
-			    u32 rates_mask)
+			    u32 basic_mask)
 {
 	struct rtl8180_priv *priv =3D dev->priv;
-
-	u8 max, min;
 	u16 reg;
-
-	max =3D fls(rates_mask) - 1;
-	min =3D ffs(rates_mask) - 1;
+	u32 resp_mask;
+	u8 basic_max;
+	u8 resp_max, resp_min;
+
+	resp_mask =3D basic_mask;
+	/* IEEE80211 says the response rate should be equal to the highest basic
+	 * rate that is not faster than received frame. But it says also that if
+	 * the basic rate set does not contains any rate for the current
+	 * modulation class then mandatory rate set must be used for that
+	 * modulation class. Eventually add OFDM mandatory rates..
+	 */
+	if ((resp_mask & 0xf) =3D=3D resp_mask)
+		resp_mask |=3D 0x150; /* 6, 12, 24Mbps */
=20
 	switch (priv->chip_family) {
=20
 	case RTL818X_CHIP_FAMILY_RTL8180:
 		/* in 8180 this is NOT a BITMAP */
+		basic_max =3D fls(basic_mask) - 1;
 		reg =3D rtl818x_ioread16(priv, &priv->map->BRSR);
 		reg &=3D ~3;
-		reg |=3D max;
+		reg |=3D basic_max;
 		rtl818x_iowrite16(priv, &priv->map->BRSR, reg);
 		break;
=20
 	case RTL818X_CHIP_FAMILY_RTL8185:
+		resp_max =3D fls(resp_mask) - 1;
+		resp_min =3D ffs(resp_mask) - 1;
 		/* in 8185 this is a BITMAP */
-		rtl818x_iowrite16(priv, &priv->map->BRSR, rates_mask);
-		rtl818x_iowrite8(priv, &priv->map->RESP_RATE, (max << 4) | min);
+		rtl818x_iowrite16(priv, &priv->map->BRSR, basic_mask);
+		rtl818x_iowrite8(priv, &priv->map->RESP_RATE, (resp_max << 4) |
+				resp_min);
 		break;
=20
 	case RTL818X_CHIP_FAMILY_RTL8187SE:
-		/* in 8187se this is a BITMAP */
-		rtl818x_iowrite16(priv, &priv->map->BRSR_8187SE, rates_mask);
+		/* in 8187se this is a BITMAP. BRSR reg actually sets
+		 * response rates.
+		 */
+		rtl818x_iowrite16(priv, &priv->map->BRSR_8187SE, resp_mask);
 		break;
 	}
 }
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtl=
wifi/wifi.h
index 976667ae8549..6866dcf24340 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1370,7 +1370,7 @@ struct rtl_mac {
 	bool rdg_en;
=20
 	/*AP*/
-	u8 bssid[6];
+	u8 bssid[ETH_ALEN] __aligned(2);
 	u32 vendor;
 	u8 mcs[16];	/* 16 bytes mcs for HT rates. */
 	u32 basic_rates; /* b/g rates */
diff --git a/drivers/nfc/microread/microread.c b/drivers/nfc/microread/micr=
oread.c
index f868333271aa..963a4a5dc88e 100644
--- a/drivers/nfc/microread/microread.c
+++ b/drivers/nfc/microread/microread.c
@@ -501,9 +501,13 @@ static void microread_target_discovered(struct nfc_hci=
_dev *hdev, u8 gate,
 		targets->sens_res =3D
 			 be16_to_cpu(*(u16 *)&skb->data[MICROREAD_EMCF_A_ATQA]);
 		targets->sel_res =3D skb->data[MICROREAD_EMCF_A_SAK];
-		memcpy(targets->nfcid1, &skb->data[MICROREAD_EMCF_A_UID],
-		       skb->data[MICROREAD_EMCF_A_LEN]);
 		targets->nfcid1_len =3D skb->data[MICROREAD_EMCF_A_LEN];
+		if (targets->nfcid1_len > sizeof(targets->nfcid1)) {
+			r =3D -EINVAL;
+			goto exit_free;
+		}
+		memcpy(targets->nfcid1, &skb->data[MICROREAD_EMCF_A_UID],
+		       targets->nfcid1_len);
 		break;
 	case MICROREAD_GATE_ID_MREAD_ISO_A_3:
 		targets->supported_protocols =3D
@@ -511,9 +515,13 @@ static void microread_target_discovered(struct nfc_hci=
_dev *hdev, u8 gate,
 		targets->sens_res =3D
 			 be16_to_cpu(*(u16 *)&skb->data[MICROREAD_EMCF_A3_ATQA]);
 		targets->sel_res =3D skb->data[MICROREAD_EMCF_A3_SAK];
-		memcpy(targets->nfcid1, &skb->data[MICROREAD_EMCF_A3_UID],
-		       skb->data[MICROREAD_EMCF_A3_LEN]);
 		targets->nfcid1_len =3D skb->data[MICROREAD_EMCF_A3_LEN];
+		if (targets->nfcid1_len > sizeof(targets->nfcid1)) {
+			r =3D -EINVAL;
+			goto exit_free;
+		}
+		memcpy(targets->nfcid1, &skb->data[MICROREAD_EMCF_A3_UID],
+		       targets->nfcid1_len);
 		break;
 	case MICROREAD_GATE_ID_MREAD_ISO_B:
 		targets->supported_protocols =3D NFC_PROTO_ISO14443_B_MASK;
diff --git a/drivers/nfc/st21nfca/Makefile b/drivers/nfc/st21nfca/Makefile
index db7a38ae05f7..7d688f97aa27 100644
--- a/drivers/nfc/st21nfca/Makefile
+++ b/drivers/nfc/st21nfca/Makefile
@@ -2,7 +2,8 @@
 # Makefile for ST21NFCA HCI based NFC driver
 #
=20
-st21nfca_i2c-objs  =3D i2c.o
+st21nfca_hci-objs =3D st21nfca.o st21nfca_dep.o
+obj-$(CONFIG_NFC_ST21NFCA)     +=3D st21nfca_hci.o
=20
-obj-$(CONFIG_NFC_ST21NFCA)     +=3D st21nfca.o st21nfca_dep.o
+st21nfca_i2c-objs  =3D i2c.o
 obj-$(CONFIG_NFC_ST21NFCA_I2C) +=3D st21nfca_i2c.o
diff --git a/drivers/nfc/st21nfcb/Makefile b/drivers/nfc/st21nfcb/Makefile
index 13d9f03b2fea..f4d835dd15f2 100644
--- a/drivers/nfc/st21nfcb/Makefile
+++ b/drivers/nfc/st21nfcb/Makefile
@@ -2,7 +2,8 @@
 # Makefile for ST21NFCB NCI based NFC driver
 #
=20
-st21nfcb_i2c-objs  =3D i2c.o
+st21nfcb_nci-objs =3D ndlc.o st21nfcb.o
+obj-$(CONFIG_NFC_ST21NFCB)     +=3D st21nfcb_nci.o
=20
-obj-$(CONFIG_NFC_ST21NFCB)     +=3D st21nfcb.o ndlc.o
+st21nfcb_i2c-objs =3D i2c.o
 obj-$(CONFIG_NFC_ST21NFCB_I2C) +=3D st21nfcb_i2c.o
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 90395c6b9757..de494df3bab8 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -1823,7 +1823,7 @@ void sta_set_sinfo(struct sta_info *sta, struct stati=
on_info *sinfo)
 		sinfo->bss_param.flags |=3D BSS_PARAM_FLAGS_SHORT_PREAMBLE;
 	if (sdata->vif.bss_conf.use_short_slot)
 		sinfo->bss_param.flags |=3D BSS_PARAM_FLAGS_SHORT_SLOT_TIME;
-	sinfo->bss_param.dtim_period =3D sdata->local->hw.conf.ps_dtim_period;
+	sinfo->bss_param.dtim_period =3D sdata->vif.bss_conf.dtim_period;
 	sinfo->bss_param.beacon_interval =3D sdata->vif.bss_conf.beacon_int;
=20
 	sinfo->sta_flags.set =3D 0;
diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index b3b16c070a7f..fa7cd792791c 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -329,7 +329,7 @@ static atomic_t rfkill_input_disabled =3D ATOMIC_INIT(0=
);
 /**
  * __rfkill_switch_all - Toggle state of all switches of given type
  * @type: type of interfaces to be affected
- * @state: the new state
+ * @blocked: the new state
  *
  * This function sets the state of all switches of given type,
  * unless a specific switch is claimed by userspace (in which case,
@@ -353,7 +353,7 @@ static void __rfkill_switch_all(const enum rfkill_type =
type, bool blocked)
 /**
  * rfkill_switch_all - Toggle state of all switches of given type
  * @type: type of interfaces to be affected
- * @state: the new state
+ * @blocked: the new state
  *
  * Acquires rfkill_global_mutex and calls __rfkill_switch_all(@type, @stat=
e).
  * Please refer to __rfkill_switch_all() for details.
diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 02a86a27fd84..0f62326c0f5e 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -54,7 +54,7 @@ static int rfkill_gpio_set_power(void *data, bool blocked)
 	if (blocked && !IS_ERR(rfkill->clk) && rfkill->clk_enabled)
 		clk_disable(rfkill->clk);
=20
-	rfkill->clk_enabled =3D blocked;
+	rfkill->clk_enabled =3D !blocked;
=20
 	return 0;
 }
@@ -163,6 +163,7 @@ static const struct acpi_device_id rfkill_acpi_match[] =
=3D {
 	{ "LNV4752", RFKILL_TYPE_GPS },
 	{ },
 };
+MODULE_DEVICE_TABLE(acpi, rfkill_acpi_match);
 #endif
=20
 static struct platform_driver rfkill_gpio_driver =3D {
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 4cce3e17964d..cb9f5a44ffad 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -7028,6 +7028,9 @@ void __cfg80211_send_event_skb(struct sk_buff *skb, g=
fp_t gfp)
 	struct nlattr *data =3D ((void **)skb->cb)[2];
 	enum nl80211_multicast_groups mcgrp =3D NL80211_MCGRP_TESTMODE;
=20
+	/* clear CB data for netlink core to own from now on */
+	memset(skb->cb, 0, sizeof(skb->cb));
+
 	nla_nest_end(skb, data);
 	genlmsg_end(skb, hdr);
=20
@@ -9357,6 +9360,9 @@ int cfg80211_vendor_cmd_reply(struct sk_buff *skb)
 	void *hdr =3D ((void **)skb->cb)[1];
 	struct nlattr *data =3D ((void **)skb->cb)[2];
=20
+	/* clear CB data for netlink core to own from now on */
+	memset(skb->cb, 0, sizeof(skb->cb));
+
 	if (WARN_ON(!rdev->cur_cmd_info)) {
 		kfree_skb(skb);
 		return -EINVAL;
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUNq1CAAoJEJctW/TcYTgGzJoP/3yfTxh5ABwKHzutRdLDjWSE
tcIN3lP83pMrPfUgUdRrD2CoQ7n/pVrwiAs3elXV8qx75f9G8/NE9Q7RqbeYc48c
olWHN1NBNa6pyhit3xLxo2fHhzv1WdmBj/z7Oz9a5msQULptrflBnJU5pO7Ve1o+
wnT8g5LNKpDCzLubzOE5oLlSMs7/3DEqC0FRbxQBMv3wfW2BSgapEnbuF8PK0/a+
C99jLIhh0sW4+KzKW4KZmCtNjTb0mceA4TjXuagQJ+1Mpj8AQdTjnylx/Rn9/GhW
eO4mMFkH2BmqB4ARXCagCSV+t8gm8f0H7fbkl/eLMHIAv6jkXGXweKA3D5A6Ocax
NId0H0w0o33AEXYr0BMIZ1O/6WWBKLQnW35YNbFRVRqrALx8sZeHqqeCBY2B67E/
TXi4a36RKpBEHqgofFAxGPpKWZtEs4ZaHk+Hi4wW5bB0rLkaaKZWXhniMxasSjdO
amO6IObVJCQeXyi4wEhaTWzpaLSWhI6ItYGEB3UTMVwLSxHDNQMpe2zmviuVpFf3
Sr/uelL094JaJMX2XaoYTkqrRUEXyjSY7z7Hn1ti44UWKj3Sv/etIJ0hxtSPGVgc
dJG2OeT+/+MH8CCzvY/L4t+/9SBPgVDIb04KpO/enp7FKpIS3o63qKoBguFETRql
/kglaiC4MTZdJ4oKaByU
=XjCF
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--
