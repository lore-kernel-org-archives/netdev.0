From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-10-22
Date: Wed, 22 Oct 2008 18:23:08 -0400
Message-ID: <20081022222308.GN15808@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another few fixes intended for 2.6.27...  The orinoco one corrects
a problem running with 4k stacks.  The other two fix oopses.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 75e3d8db531b462b875c1adb13eeb6b0be73=
74c0:
  Ilpo J=E4rvinen (1):
        tcp: should use number of sack blocks instead of -1

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it master

Andrey Borzenkov (1):
      orinoco: reduce stack usage in firmware download path

Bob Copeland (1):
      ath5k: fix suspend-related oops on rmmod

Christian Lamparter (1):
      p54: enable 2.4/5GHz spectrum by eeprom bits.

 drivers/net/wireless/ath5k/base.c    |   27 +++++++++++++++------
 drivers/net/wireless/ath5k/base.h    |    3 +-
 drivers/net/wireless/orinoco.c       |   42 +++++++++++++++++++++++---=
-------
 drivers/net/wireless/p54/p54common.c |   28 ++++++++--------------
 4 files changed, 60 insertions(+), 40 deletions(-)

diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/a=
th5k/base.c
index 9b95c40..0f1d6bd 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -340,9 +340,9 @@ static inline u64 ath5k_extend_tsf(struct ath5k_hw =
*ah, u32 rstamp)
 }
=20
 /* Interrupt handling */
-static int 	ath5k_init(struct ath5k_softc *sc);
+static int 	ath5k_init(struct ath5k_softc *sc, bool is_resume);
 static int 	ath5k_stop_locked(struct ath5k_softc *sc);
-static int 	ath5k_stop_hw(struct ath5k_softc *sc);
+static int 	ath5k_stop_hw(struct ath5k_softc *sc, bool is_suspend);
 static irqreturn_t ath5k_intr(int irq, void *dev_id);
 static void 	ath5k_tasklet_reset(unsigned long data);
=20
@@ -646,7 +646,7 @@ ath5k_pci_suspend(struct pci_dev *pdev, pm_message_=
t state)
=20
 	ath5k_led_off(sc);
=20
-	ath5k_stop_hw(sc);
+	ath5k_stop_hw(sc, true);
=20
 	free_irq(pdev->irq, sc);
 	pci_save_state(pdev);
@@ -683,7 +683,7 @@ ath5k_pci_resume(struct pci_dev *pdev)
 		goto err_no_irq;
 	}
=20
-	err =3D ath5k_init(sc);
+	err =3D ath5k_init(sc, true);
 	if (err)
 		goto err_irq;
 	ath5k_led_enable(sc);
@@ -2200,12 +2200,17 @@ ath5k_beacon_config(struct ath5k_softc *sc)
 \********************/
=20
 static int
-ath5k_init(struct ath5k_softc *sc)
+ath5k_init(struct ath5k_softc *sc, bool is_resume)
 {
 	int ret;
=20
 	mutex_lock(&sc->lock);
=20
+	if (is_resume && !test_bit(ATH_STAT_STARTED, sc->status))
+		goto out_ok;
+
+	__clear_bit(ATH_STAT_STARTED, sc->status);
+
 	ATH5K_DBG(sc, ATH5K_DEBUG_RESET, "mode %d\n", sc->opmode);
=20
 	/*
@@ -2230,12 +2235,15 @@ ath5k_init(struct ath5k_softc *sc)
 	if (ret)
 		goto done;
=20
+	__set_bit(ATH_STAT_STARTED, sc->status);
+
 	/* Set ack to be sent at low bit-rates */
 	ath5k_hw_set_ack_bitrate_high(sc->ah, false);
=20
 	mod_timer(&sc->calib_tim, round_jiffies(jiffies +
 			msecs_to_jiffies(ath5k_calinterval * 1000)));
=20
+out_ok:
 	ret =3D 0;
 done:
 	mmiowb();
@@ -2290,7 +2298,7 @@ ath5k_stop_locked(struct ath5k_softc *sc)
  * stop is preempted).
  */
 static int
-ath5k_stop_hw(struct ath5k_softc *sc)
+ath5k_stop_hw(struct ath5k_softc *sc, bool is_suspend)
 {
 	int ret;
=20
@@ -2321,6 +2329,9 @@ ath5k_stop_hw(struct ath5k_softc *sc)
 		}
 	}
 	ath5k_txbuf_free(sc, sc->bbuf);
+	if (!is_suspend)
+		__clear_bit(ATH_STAT_STARTED, sc->status);
+
 	mmiowb();
 	mutex_unlock(&sc->lock);
=20
@@ -2718,12 +2729,12 @@ ath5k_reset_wake(struct ath5k_softc *sc)
=20
 static int ath5k_start(struct ieee80211_hw *hw)
 {
-	return ath5k_init(hw->priv);
+	return ath5k_init(hw->priv, false);
 }
=20
 static void ath5k_stop(struct ieee80211_hw *hw)
 {
-	ath5k_stop_hw(hw->priv);
+	ath5k_stop_hw(hw->priv, false);
 }
=20
 static int ath5k_add_interface(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/ath5k/base.h b/drivers/net/wireless/a=
th5k/base.h
index 9d0b728..06d1054 100644
--- a/drivers/net/wireless/ath5k/base.h
+++ b/drivers/net/wireless/ath5k/base.h
@@ -128,11 +128,12 @@ struct ath5k_softc {
 	size_t			desc_len;	/* size of TX/RX descriptors */
 	u16			cachelsz;	/* cache line size */
=20
-	DECLARE_BITMAP(status, 4);
+	DECLARE_BITMAP(status, 5);
 #define ATH_STAT_INVALID	0		/* disable hardware accesses */
 #define ATH_STAT_MRRETRY	1		/* multi-rate retry support */
 #define ATH_STAT_PROMISC	2
 #define ATH_STAT_LEDSOFT	3		/* enable LED gpio status */
+#define ATH_STAT_STARTED	4		/* opened & irqs enabled */
=20
 	unsigned int		filter_flags;	/* HW flags, AR5K_RX_FILTER_* */
 	unsigned int		curmode;	/* current phy mode */
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orin=
oco.c
index 5090477..e0512e4 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -433,7 +433,7 @@ struct fw_info {
 const static struct fw_info orinoco_fw[] =3D {
 	{ "", "agere_sta_fw.bin", "agere_ap_fw.bin", 0x00390000, 1000 },
 	{ "", "prism_sta_fw.bin", "prism_ap_fw.bin", 0, 1024 },
-	{ "symbol_sp24t_prim_fw", "symbol_sp24t_sec_fw", "", 0x00003100, 0x10=
0 }
+	{ "symbol_sp24t_prim_fw", "symbol_sp24t_sec_fw", "", 0x00003100, 512 =
}
 };
=20
 /* Structure used to access fields in FW
@@ -458,7 +458,7 @@ orinoco_dl_firmware(struct orinoco_private *priv,
 		    int ap)
 {
 	/* Plug Data Area (PDA) */
-	__le16 pda[512] =3D { 0 };
+	__le16 *pda;
=20
 	hermes_t *hw =3D &priv->hw;
 	const struct firmware *fw_entry;
@@ -467,7 +467,11 @@ orinoco_dl_firmware(struct orinoco_private *priv,
 	const unsigned char *end;
 	const char *firmware;
 	struct net_device *dev =3D priv->ndev;
-	int err;
+	int err =3D 0;
+
+	pda =3D kzalloc(fw->pda_size, GFP_KERNEL);
+	if (!pda)
+		return -ENOMEM;
=20
 	if (ap)
 		firmware =3D fw->ap_fw;
@@ -478,17 +482,17 @@ orinoco_dl_firmware(struct orinoco_private *priv,
 	       dev->name, firmware);
=20
 	/* Read current plug data */
-	err =3D hermes_read_pda(hw, pda, fw->pda_addr,
-			      min_t(u16, fw->pda_size, sizeof(pda)), 0);
+	err =3D hermes_read_pda(hw, pda, fw->pda_addr, fw->pda_size, 0);
 	printk(KERN_DEBUG "%s: Read PDA returned %d\n", dev->name, err);
 	if (err)
-		return err;
+		goto free;
=20
 	err =3D request_firmware(&fw_entry, firmware, priv->dev);
 	if (err) {
 		printk(KERN_ERR "%s: Cannot find firmware %s\n",
 		       dev->name, firmware);
-		return -ENOENT;
+		err =3D -ENOENT;
+		goto free;
 	}
=20
 	hdr =3D (const struct orinoco_fw_header *) fw_entry->data;
@@ -532,6 +536,9 @@ orinoco_dl_firmware(struct orinoco_private *priv,
=20
 abort:
 	release_firmware(fw_entry);
+
+free:
+	kfree(pda);
 	return err;
 }
=20
@@ -549,12 +556,12 @@ symbol_dl_image(struct orinoco_private *priv, con=
st struct fw_info *fw,
 		int secondary)
 {
 	hermes_t *hw =3D &priv->hw;
-	int ret;
+	int ret =3D 0;
 	const unsigned char *ptr;
 	const unsigned char *first_block;
=20
 	/* Plug Data Area (PDA) */
-	__le16 pda[256];
+	__le16 *pda =3D NULL;
=20
 	/* Binary block begins after the 0x1A marker */
 	ptr =3D image;
@@ -563,28 +570,33 @@ symbol_dl_image(struct orinoco_private *priv, con=
st struct fw_info *fw,
=20
 	/* Read the PDA from EEPROM */
 	if (secondary) {
-		ret =3D hermes_read_pda(hw, pda, fw->pda_addr, sizeof(pda), 1);
+		pda =3D kzalloc(fw->pda_size, GFP_KERNEL);
+		if (!pda)
+			return -ENOMEM;
+
+		ret =3D hermes_read_pda(hw, pda, fw->pda_addr, fw->pda_size, 1);
 		if (ret)
-			return ret;
+			goto free;
 	}
=20
 	/* Stop the firmware, so that it can be safely rewritten */
 	if (priv->stop_fw) {
 		ret =3D priv->stop_fw(priv, 1);
 		if (ret)
-			return ret;
+			goto free;
 	}
=20
 	/* Program the adapter with new firmware */
 	ret =3D hermes_program(hw, first_block, end);
 	if (ret)
-		return ret;
+		goto free;
=20
 	/* Write the PDA to the adapter */
 	if (secondary) {
 		size_t len =3D hermes_blocks_length(first_block);
 		ptr =3D first_block + len;
 		ret =3D hermes_apply_pda(hw, ptr, pda);
+		kfree(pda);
 		if (ret)
 			return ret;
 	}
@@ -608,6 +620,10 @@ symbol_dl_image(struct orinoco_private *priv, cons=
t struct fw_info *fw,
 		return -ENODEV;
=20
 	return 0;
+
+free:
+	kfree(pda);
+	return ret;
 }
=20
=20
diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireles=
s/p54/p54common.c
index 117c7d3..2d022f8 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -306,8 +306,8 @@ static int p54_convert_rev1(struct ieee80211_hw *de=
v,
 	return 0;
 }
=20
-static const char *p54_rf_chips[] =3D { "NULL", "Indigo?", "Duette",
-                              "Frisbee", "Xbow", "Longbow" };
+static const char *p54_rf_chips[] =3D { "NULL", "Duette3", "Duette2",
+                              "Frisbee", "Xbow", "Longbow", "NULL", "N=
ULL" };
 static int p54_init_xbow_synth(struct ieee80211_hw *dev);
=20
 static int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, in=
t len)
@@ -319,6 +319,7 @@ static int p54_parse_eeprom(struct ieee80211_hw *de=
v, void *eeprom, int len)
 	void *tmp;
 	int err;
 	u8 *end =3D (u8 *)eeprom + len;
+	u16 synth;
 	DECLARE_MAC_BUF(mac);
=20
 	wrap =3D (struct eeprom_pda_wrap *) eeprom;
@@ -400,8 +401,8 @@ static int p54_parse_eeprom(struct ieee80211_hw *de=
v, void *eeprom, int len)
 			tmp =3D entry->data;
 			while ((u8 *)tmp < entry->data + data_len) {
 				struct bootrec_exp_if *exp_if =3D tmp;
-				if (le16_to_cpu(exp_if->if_id) =3D=3D 0xF)
-					priv->rxhw =3D le16_to_cpu(exp_if->variant) & 0x07;
+				if (le16_to_cpu(exp_if->if_id) =3D=3D 0xf)
+					synth =3D le16_to_cpu(exp_if->variant);
 				tmp +=3D sizeof(struct bootrec_exp_if);
 			}
 			break;
@@ -427,22 +428,13 @@ static int p54_parse_eeprom(struct ieee80211_hw *=
dev, void *eeprom, int len)
 		goto err;
 	}
=20
-	switch (priv->rxhw) {
-	case 4: /* XBow */
+	priv->rxhw =3D synth & 0x07;
+	if (priv->rxhw =3D=3D 4)
 		p54_init_xbow_synth(dev);
-	case 1: /* Indigo? */
-	case 2: /* Duette */
-		dev->wiphy->bands[IEEE80211_BAND_5GHZ] =3D &band_5GHz;
-	case 3: /* Frisbee */
-	case 5: /* Longbow */
+	if (!(synth & 0x40))
 		dev->wiphy->bands[IEEE80211_BAND_2GHZ] =3D &band_2GHz;
-		break;
-	default:
-		printk(KERN_ERR "%s: unsupported RF-Chip\n",
-			wiphy_name(dev->wiphy));
-		err =3D -EINVAL;
-		goto err;
-	}
+	if (!(synth & 0x80))
+		dev->wiphy->bands[IEEE80211_BAND_5GHZ] =3D &band_5GHz;
=20
 	if (!is_valid_ether_addr(dev->wiphy->perm_addr)) {
 		u8 perm_addr[ETH_ALEN];
--=20
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
