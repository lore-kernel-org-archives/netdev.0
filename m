From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2012-04-18
Date: Wed, 18 Apr 2012 14:43:20 -0400
Message-ID: <20120418184320.GA2436@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit dbd717e37bf1409fd250d13aef2cab07bcae8c88

Dave,

Another batch of fixes intended for 3.4...

First up, we have a minor signedness fix for libertas from Amitkumar
Karwar.  Next, Arend gives us a brcm80211 fix for correctly enabling
Tx FIFOs on channels 12 and 13.  Bing Zhao gives us some register
address corrections for mwifiex.  Felix give us a trio of fixes --
one for ath9k to wake the hardware properly from full sleep, one for
mac80211 to properly handle packets in cooked monitor mode, and one
for ensuring that the proper HT mode selection is honored.

Hauke gives us a bcma fix for handling the lack of an sprom.  Jonathon
Bither gives us an ath5k fix for a missing THIS_MODULE build issue,
and another ath5k fix for an io mapping leak.  Lukasz Kucharczyk
fixes a bitwise check in cfg80211, and Sujith gives us an ath9k fix
for assigning sequence numbers for fragmented frames.  Finally, we
have a MAINTAINERS change from Wey-Yi Guy -- congrats to Johannes
Berg for taking the lead on iwlwifi. :-)

Please let me know if there are problems!

John

---

The following changes since commit 9fe5642f4a3b13beb43c2633db7df22dd9d99250:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jk=
irsher/net (2012-04-17 22:58:52 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Amitkumar Karwar (1):
      libertas: fix signedness bug in lbs_auth_to_authtype()

Arend van Spriel (1):
      brcm80211: smac: resume transmit fifo upon receiving frames

Bing Zhao (1):
      mwifiex: update pcie8766 scratch register addresses

Felix Fietkau (3):
      ath9k: wake up the hardware from full sleep when idle is turned off
      mac80211: fix truncated packets in cooked monitor rx
      mac80211: fix logic error in ibss channel type check

Hauke Mehrtens (1):
      bcma: use fallback sprom if no on chip sprom is available

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jonathan Bither (2):
      ath5k: fix undefined 'THIS_MODULE'
      ath5k: unmap io memory on probe failure

Lukasz Kucharczyk (1):
      cfg80211: fix interface combinations check.

Sujith Manoharan (1):
      ath9k: Fix TX fragmentation

Wey-Yi Guy (1):
      MAINTAINERS: Add maintainer for iwlwifi

 MAINTAINERS                                    |    1 +
 drivers/bcma/sprom.c                           |    7 +++++--
 drivers/net/wireless/ath/ath5k/ahb.c           |    7 +++++--
 drivers/net/wireless/ath/ath9k/main.c          |    9 ++++++++-
 drivers/net/wireless/ath/ath9k/xmit.c          |   10 +++++++++-
 drivers/net/wireless/brcm80211/brcmsmac/main.c |    8 ++++++++
 drivers/net/wireless/libertas/cfg.c            |    9 +++++++--
 drivers/net/wireless/mwifiex/pcie.h            |   18 +++++++++---------
 net/mac80211/ibss.c                            |    4 ++--
 net/mac80211/rx.c                              |   10 ++++++----
 net/wireless/util.c                            |    2 +-
 11 files changed, 61 insertions(+), 24 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7cef7be..f11ac47 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3592,6 +3592,7 @@ S:	Supported
 F:	drivers/net/wireless/iwlegacy/
=20
 INTEL WIRELESS WIFI LINK (iwlwifi)
+M:	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 M:	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 M:	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
diff --git a/drivers/bcma/sprom.c b/drivers/bcma/sprom.c
index cdcf75c..3e2a600 100644
--- a/drivers/bcma/sprom.c
+++ b/drivers/bcma/sprom.c
@@ -404,16 +404,19 @@ int bcma_sprom_get(struct bcma_bus *bus)
 		return -EOPNOTSUPP;
=20
 	if (!bcma_sprom_ext_available(bus)) {
+		bool sprom_onchip;
+
 		/*
 		 * External SPROM takes precedence so check
 		 * on-chip OTP only when no external SPROM
 		 * is present.
 		 */
-		if (bcma_sprom_onchip_available(bus)) {
+		sprom_onchip =3D bcma_sprom_onchip_available(bus);
+		if (sprom_onchip) {
 			/* determine offset */
 			offset =3D bcma_sprom_onchip_offset(bus);
 		}
-		if (!offset) {
+		if (!offset || !sprom_onchip) {
 			/*
 			 * Maybe there is no SPROM on the device?
 			 * Now we ask the arch code if there is some sprom
diff --git a/drivers/net/wireless/ath/ath5k/ahb.c b/drivers/net/wireless/at=
h/ath5k/ahb.c
index 8faa129..8c50d9d 100644
--- a/drivers/net/wireless/ath/ath5k/ahb.c
+++ b/drivers/net/wireless/ath/ath5k/ahb.c
@@ -19,6 +19,7 @@
 #include <linux/nl80211.h>
 #include <linux/platform_device.h>
 #include <linux/etherdevice.h>
+#include <linux/export.h>
 #include <ar231x_platform.h>
 #include "ath5k.h"
 #include "debug.h"
@@ -119,7 +120,7 @@ static int ath_ahb_probe(struct platform_device *pdev)
 	if (res =3D=3D NULL) {
 		dev_err(&pdev->dev, "no IRQ resource found\n");
 		ret =3D -ENXIO;
-		goto err_out;
+		goto err_iounmap;
 	}
=20
 	irq =3D res->start;
@@ -128,7 +129,7 @@ static int ath_ahb_probe(struct platform_device *pdev)
 	if (hw =3D=3D NULL) {
 		dev_err(&pdev->dev, "no memory for ieee80211_hw\n");
 		ret =3D -ENOMEM;
-		goto err_out;
+		goto err_iounmap;
 	}
=20
 	ah =3D hw->priv;
@@ -185,6 +186,8 @@ static int ath_ahb_probe(struct platform_device *pdev)
  err_free_hw:
 	ieee80211_free_hw(hw);
 	platform_set_drvdata(pdev, NULL);
+ err_iounmap:
+        iounmap(mem);
  err_out:
 	return ret;
 }
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 2504ab0..798ea57 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1548,6 +1548,7 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 =
changed)
 	struct ath_hw *ah =3D sc->sc_ah;
 	struct ath_common *common =3D ath9k_hw_common(ah);
 	struct ieee80211_conf *conf =3D &hw->conf;
+	bool reset_channel =3D false;
=20
 	ath9k_ps_wakeup(sc);
 	mutex_lock(&sc->mutex);
@@ -1556,6 +1557,12 @@ static int ath9k_config(struct ieee80211_hw *hw, u32=
 changed)
 		sc->ps_idle =3D !!(conf->flags & IEEE80211_CONF_IDLE);
 		if (sc->ps_idle)
 			ath_cancel_work(sc);
+		else
+			/*
+			 * The chip needs a reset to properly wake up from
+			 * full sleep
+			 */
+			reset_channel =3D ah->chip_fullsleep;
 	}
=20
 	/*
@@ -1584,7 +1591,7 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 =
changed)
 		}
 	}
=20
-	if (changed & IEEE80211_CONF_CHANGE_CHANNEL) {
+	if ((changed & IEEE80211_CONF_CHANGE_CHANNEL) || reset_channel) {
 		struct ieee80211_channel *curchan =3D hw->conf.channel;
 		int pos =3D curchan->hw_value;
 		int old_pos =3D -1;
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 834e6bc..23eaa1b 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1820,6 +1820,7 @@ static struct ath_buf *ath_tx_setup_buffer(struct ath=
_softc *sc,
 	struct ath_frame_info *fi =3D get_frame_info(skb);
 	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *)skb->data;
 	struct ath_buf *bf;
+	int fragno;
 	u16 seqno;
=20
 	bf =3D ath_tx_get_buffer(sc);
@@ -1831,9 +1832,16 @@ static struct ath_buf *ath_tx_setup_buffer(struct at=
h_softc *sc,
 	ATH_TXBUF_RESET(bf);
=20
 	if (tid) {
+		fragno =3D le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_FRAG;
 		seqno =3D tid->seq_next;
 		hdr->seq_ctrl =3D cpu_to_le16(tid->seq_next << IEEE80211_SEQ_SEQ_SHIFT);
-		INCR(tid->seq_next, IEEE80211_SEQ_MAX);
+
+		if (fragno)
+			hdr->seq_ctrl |=3D cpu_to_le16(fragno);
+
+		if (!ieee80211_has_morefrags(hdr->frame_control))
+			INCR(tid->seq_next, IEEE80211_SEQ_MAX);
+
 		bf->bf_state.seqno =3D seqno;
 	}
=20
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/w=
ireless/brcm80211/brcmsmac/main.c
index 231ddf4..7083db7 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -7614,6 +7614,7 @@ brcms_c_recvctl(struct brcms_c_info *wlc, struct d11r=
xhdr *rxh,
 {
 	int len_mpdu;
 	struct ieee80211_rx_status rx_status;
+	struct ieee80211_hdr *hdr;
=20
 	memset(&rx_status, 0, sizeof(rx_status));
 	prep_mac80211_status(wlc, rxh, p, &rx_status);
@@ -7623,6 +7624,13 @@ brcms_c_recvctl(struct brcms_c_info *wlc, struct d11=
rxhdr *rxh,
 	skb_pull(p, D11_PHY_HDR_LEN);
 	__skb_trim(p, len_mpdu);
=20
+	/* unmute transmit */
+	if (wlc->hw->suspended_fifos) {
+		hdr =3D (struct ieee80211_hdr *)p->data;
+		if (ieee80211_is_beacon(hdr->frame_control))
+			brcms_b_mute(wlc->hw, false);
+	}
+
 	memcpy(IEEE80211_SKB_RXCB(p), &rx_status, sizeof(rx_status));
 	ieee80211_rx_irqsafe(wlc->pub->ieee_hw, p);
 }
diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/lib=
ertas/cfg.c
index 3fa1ece..2fa879b 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -103,7 +103,7 @@ static const u32 cipher_suites[] =3D {
  * Convert NL80211's auth_type to the one from Libertas, see chapter 5.9.1
  * in the firmware spec
  */
-static u8 lbs_auth_to_authtype(enum nl80211_auth_type auth_type)
+static int lbs_auth_to_authtype(enum nl80211_auth_type auth_type)
 {
 	int ret =3D -ENOTSUPP;
=20
@@ -1411,7 +1411,12 @@ static int lbs_cfg_connect(struct wiphy *wiphy, stru=
ct net_device *dev,
 		goto done;
 	}
=20
-	lbs_set_authtype(priv, sme);
+	ret =3D lbs_set_authtype(priv, sme);
+	if (ret =3D=3D -ENOTSUPP) {
+		wiphy_err(wiphy, "unsupported authtype 0x%x\n", sme->auth_type);
+		goto done;
+	}
+
 	lbs_set_radio(priv, preamble, 1);
=20
 	/* Do the actual association */
diff --git a/drivers/net/wireless/mwifiex/pcie.h b/drivers/net/wireless/mwi=
fiex/pcie.h
index 445ff21..2f218f9 100644
--- a/drivers/net/wireless/mwifiex/pcie.h
+++ b/drivers/net/wireless/mwifiex/pcie.h
@@ -48,15 +48,15 @@
 #define PCIE_HOST_INT_STATUS_MASK			0xC3C
 #define PCIE_SCRATCH_2_REG				0xC40
 #define PCIE_SCRATCH_3_REG				0xC44
-#define PCIE_SCRATCH_4_REG				0xCC0
-#define PCIE_SCRATCH_5_REG				0xCC4
-#define PCIE_SCRATCH_6_REG				0xCC8
-#define PCIE_SCRATCH_7_REG				0xCCC
-#define PCIE_SCRATCH_8_REG				0xCD0
-#define PCIE_SCRATCH_9_REG				0xCD4
-#define PCIE_SCRATCH_10_REG				0xCD8
-#define PCIE_SCRATCH_11_REG				0xCDC
-#define PCIE_SCRATCH_12_REG				0xCE0
+#define PCIE_SCRATCH_4_REG				0xCD0
+#define PCIE_SCRATCH_5_REG				0xCD4
+#define PCIE_SCRATCH_6_REG				0xCD8
+#define PCIE_SCRATCH_7_REG				0xCDC
+#define PCIE_SCRATCH_8_REG				0xCE0
+#define PCIE_SCRATCH_9_REG				0xCE4
+#define PCIE_SCRATCH_10_REG				0xCE8
+#define PCIE_SCRATCH_11_REG				0xCEC
+#define PCIE_SCRATCH_12_REG				0xCF0
=20
 #define CPU_INTR_DNLD_RDY				BIT(0)
 #define CPU_INTR_DOOR_BELL				BIT(1)
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 33fd8d9..cef7c29 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -457,8 +457,8 @@ static void ieee80211_rx_bss_info(struct ieee80211_sub_=
if_data *sdata,
 			 * fall back to HT20 if we don't use or use
 			 * the other extension channel
 			 */
-			if ((channel_type =3D=3D NL80211_CHAN_HT40MINUS ||
-			     channel_type =3D=3D NL80211_CHAN_HT40PLUS) &&
+			if (!(channel_type =3D=3D NL80211_CHAN_HT40MINUS ||
+			      channel_type =3D=3D NL80211_CHAN_HT40PLUS) ||
 			    channel_type !=3D sdata->u.ibss.channel_type)
 				sta_ht_cap_new.cap &=3D
 					~IEEE80211_HT_CAP_SUP_WIDTH_20_40;
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index bcfe8c7..d64e285 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -103,7 +103,7 @@ static void
 ieee80211_add_rx_radiotap_header(struct ieee80211_local *local,
 				 struct sk_buff *skb,
 				 struct ieee80211_rate *rate,
-				 int rtap_len)
+				 int rtap_len, bool has_fcs)
 {
 	struct ieee80211_rx_status *status =3D IEEE80211_SKB_RXCB(skb);
 	struct ieee80211_radiotap_header *rthdr;
@@ -134,7 +134,7 @@ ieee80211_add_rx_radiotap_header(struct ieee80211_local=
 *local,
 	}
=20
 	/* IEEE80211_RADIOTAP_FLAGS */
-	if (local->hw.flags & IEEE80211_HW_RX_INCLUDES_FCS)
+	if (has_fcs && (local->hw.flags & IEEE80211_HW_RX_INCLUDES_FCS))
 		*pos |=3D IEEE80211_RADIOTAP_F_FCS;
 	if (status->flag & (RX_FLAG_FAILED_FCS_CRC | RX_FLAG_FAILED_PLCP_CRC))
 		*pos |=3D IEEE80211_RADIOTAP_F_BADFCS;
@@ -294,7 +294,8 @@ ieee80211_rx_monitor(struct ieee80211_local *local, str=
uct sk_buff *origskb,
 	}
=20
 	/* prepend radiotap information */
-	ieee80211_add_rx_radiotap_header(local, skb, rate, needed_headroom);
+	ieee80211_add_rx_radiotap_header(local, skb, rate, needed_headroom,
+					 true);
=20
 	skb_reset_mac_header(skb);
 	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
@@ -2571,7 +2572,8 @@ static void ieee80211_rx_cooked_monitor(struct ieee80=
211_rx_data *rx,
 		goto out_free_skb;
=20
 	/* prepend radiotap information */
-	ieee80211_add_rx_radiotap_header(local, skb, rate, needed_headroom);
+	ieee80211_add_rx_radiotap_header(local, skb, rate, needed_headroom,
+					 false);
=20
 	skb_set_mac_header(skb, 0);
 	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 1b7a08d..957f2562 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -989,7 +989,7 @@ int cfg80211_can_change_interface(struct cfg80211_regis=
tered_device *rdev,
 			if (rdev->wiphy.software_iftypes & BIT(iftype))
 				continue;
 			for (j =3D 0; j < c->n_limits; j++) {
-				if (!(limits[j].types & iftype))
+				if (!(limits[j].types & BIT(iftype)))
 					continue;
 				if (limits[j].max < num[iftype])
 					goto cont;
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPjwtIAAoJEJctW/TcYTgGM1cQAIaKNU5bAY95C7zYMSa0Bw3T
BohsfmhQWxsD0p8+2RDL5XhNiIUnCCwtciaRXO3D6/YcNW3ntxsqj82mguoRZEXs
u/Gk1fBbCUA4PaM5Uexqq55HsA7LbGAY6g4hoj4i6ReP+hUFnkO77IB/2pXjo2VQ
F+F1yn/o5VAzThhlgkiDFFrfeBVaqtfpxxgobxfwk8WYi/fPIMbcIbJXw6WNyyyd
EXtPnDLfOZfFRxE4RilAs8ZjLiYR+5Rj0DZTtm7BulKV7y1V41M6BKLkou9r4pJT
HUEKM99kcTeDBR9MNfp54Fs6lkSlvqu7ED39RNMEgni6I6D0d2L7ZMc/FmE+HiaT
X03JC+mFjHVFTLzor2g2QIMZTQsMcG83b90NnJ9YYB4N4anmnszfF/HT+559IAE9
u3stGG1ymy4yoyfJrQJHqp2qqOGKJA8shBoe8L0f41h23b6Z9crzk4p6n7BT5wtX
RPVzKockmKsiPO8tO3PzoLCnNlKWn6+1syswJ/FnEUbOHxIQyBRY2/9bzH7enUW/
s+GmgGPI9CQdRHWCnr5ZctPlBeuv2ffnj9cb+BZ5foJJs59jVRJdUuCdWsh5HXa1
7DVcKsrjM4t7FzYE3t0+Gza/CJfs3XK2VKO6amHjrNRPLQ/qR8b8eXUzDkkh1I0J
7i2+QBdNl/dF+9zqbxq5
=Fc9d
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
