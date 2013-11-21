From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2013-11-21
Date: Thu, 21 Nov 2013 10:41:37 -0500
Message-ID: <20131121154136.GB2152@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3MwIy2ne0vdjdPXF"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.13 stream!

For the Bluetooth bits, Gustavo says:

"A few fixes for 3.13. There is 3 fixes to the RFCOMM protocol. One
crash fix to L2CAP. A simple fix to a bad behaviour in the SMP
protocol."

On top of that...

Amitkumar Karwar sends a quintet of mwifiex fixes -- two fixes related
to failure handling, two memory leak fixes, and a NULL pointer fix.

Felix Fietkau corrects and earlier rt2x00 HT descriptor handling fix
to address a crash.

Geyslan G. Bem fixes a memory leak in brcmfmac.

Larry Finger address more pointer arithmetic errors in rtlwifi.

Luis R. Rodriguez provides a regulatory fix in the shared ath code.

Sujith Manoharan brings a couple ath9k initialization fixes.

Ujjal Roy offers one more mwifiex fix to avoid invalid memory accesses
when unloading the USB driver.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 68c6beb373955da0886d8f4f5995b3922ceda4be:

  net: add BUG_ON if kernel advertises msg_namelen > sizeof(struct sockaddr=
_storage) (2013-11-20 21:52:30 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 7acd71879ce408af2d2ca3cd3ec3a86d0667ceae:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-11-21 10:26:17 -0500)

----------------------------------------------------------------

Amitkumar Karwar (5):
      mwifiex: use return value of mwifiex_add_virtual_intf() correctly
      mwifiex: failure path handling in mwifiex_add_virtual_intf()
      mwifiex: fix NULL pointer dereference in mwifiex_fw_dpc
      mwifiex: fix potential mem leak in .del_virtual_intf
      mwifiex: fix memory leak issue for sdio and pcie cards

Felix Fietkau (1):
      rt2x00: fix a crash bug in the HT descriptor handling fix

Geyslan G. Bem (1):
      brcmfmac: fix possible memory leak

Johan Hedberg (1):
      Bluetooth: Fix rejecting SMP security request in slave role

John W. Linville (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      rtlwifi: rtl8192cu: Fix more pointer arithmetic errors

Luis R. Rodriguez (1):
      ath: fix dynamic user regulatory settings

Marcel Holtmann (1):
      Bluetooth: Fix issue with RFCOMM getsockopt operation

Seung-Woo Kim (3):
      Bluetooth: Fix RFCOMM bind fail for L2CAP sock
      Bluetooth: Fix to set proper bdaddr_type for RFCOMM connect
      Bluetooth: Fix crash in l2cap_chan_send after l2cap_chan_del

Sujith Manoharan (2):
      ath9k: Update AR9462 2.1 initvals
      ath9k: Fix issue with MCS15

Ujjal Roy (1):
      mwifiex: fix issues in driver unload path for USB chipsets

 drivers/net/wireless/ath/ath9k/ar9003_phy.c        | 50 ++++++++++++++++++=
++++
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        | 11 +++++
 .../net/wireless/ath/ath9k/ar9462_2p1_initvals.h   |  6 +--
 drivers/net/wireless/ath/regd.c                    |  3 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |  1 +
 drivers/net/wireless/mwifiex/cfg80211.c            | 23 ++++++++--
 drivers/net/wireless/mwifiex/main.c                | 28 +++---------
 drivers/net/wireless/mwifiex/pcie.c                |  2 +-
 drivers/net/wireless/mwifiex/sdio.c                |  7 +--
 drivers/net/wireless/mwifiex/usb.c                 | 27 ++++++------
 drivers/net/wireless/rt2x00/rt2x00dev.c            |  3 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |  6 +--
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |  6 +--
 net/bluetooth/l2cap_core.c                         |  3 ++
 net/bluetooth/rfcomm/core.c                        |  3 ++
 net/bluetooth/rfcomm/sock.c                        |  6 ++-
 net/bluetooth/smp.c                                |  3 ++
 17 files changed, 135 insertions(+), 53 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wire=
less/ath/ath9k/ar9003_phy.c
index 11f53589a3f3..d39b79f5e841 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -701,6 +701,54 @@ static int ar9550_hw_get_modes_txgain_index(struct ath=
_hw *ah,
 	return ret;
 }
=20
+static void ar9003_doubler_fix(struct ath_hw *ah)
+{
+	if (AR_SREV_9300(ah) || AR_SREV_9580(ah) || AR_SREV_9550(ah)) {
+		REG_RMW(ah, AR_PHY_65NM_CH0_RXTX2,
+			1 << AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK_S |
+			1 << AR_PHY_65NM_CH0_RXTX2_SYNTHOVR_MASK_S, 0);
+		REG_RMW(ah, AR_PHY_65NM_CH1_RXTX2,
+			1 << AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK_S |
+			1 << AR_PHY_65NM_CH0_RXTX2_SYNTHOVR_MASK_S, 0);
+		REG_RMW(ah, AR_PHY_65NM_CH2_RXTX2,
+			1 << AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK_S |
+			1 << AR_PHY_65NM_CH0_RXTX2_SYNTHOVR_MASK_S, 0);
+
+		udelay(200);
+
+		REG_CLR_BIT(ah, AR_PHY_65NM_CH0_RXTX2,
+			    AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK);
+		REG_CLR_BIT(ah, AR_PHY_65NM_CH1_RXTX2,
+			    AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK);
+		REG_CLR_BIT(ah, AR_PHY_65NM_CH2_RXTX2,
+			    AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK);
+
+		udelay(1);
+
+		REG_RMW_FIELD(ah, AR_PHY_65NM_CH0_RXTX2,
+			      AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK, 1);
+		REG_RMW_FIELD(ah, AR_PHY_65NM_CH1_RXTX2,
+			      AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK, 1);
+		REG_RMW_FIELD(ah, AR_PHY_65NM_CH2_RXTX2,
+			      AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK, 1);
+
+		udelay(200);
+
+		REG_RMW_FIELD(ah, AR_PHY_65NM_CH0_SYNTH12,
+			      AR_PHY_65NM_CH0_SYNTH12_VREFMUL3, 0xf);
+
+		REG_RMW(ah, AR_PHY_65NM_CH0_RXTX2, 0,
+			1 << AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK_S |
+			1 << AR_PHY_65NM_CH0_RXTX2_SYNTHOVR_MASK_S);
+		REG_RMW(ah, AR_PHY_65NM_CH1_RXTX2, 0,
+			1 << AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK_S |
+			1 << AR_PHY_65NM_CH0_RXTX2_SYNTHOVR_MASK_S);
+		REG_RMW(ah, AR_PHY_65NM_CH2_RXTX2, 0,
+			1 << AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK_S |
+			1 << AR_PHY_65NM_CH0_RXTX2_SYNTHOVR_MASK_S);
+	}
+}
+
 static int ar9003_hw_process_ini(struct ath_hw *ah,
 				 struct ath9k_channel *chan)
 {
@@ -726,6 +774,8 @@ static int ar9003_hw_process_ini(struct ath_hw *ah,
 					   modesIndex);
 	}
=20
+	ar9003_doubler_fix(ah);
+
 	/*
 	 * RXGAIN initvals.
 	 */
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.h b/drivers/net/wire=
less/ath/ath9k/ar9003_phy.h
index fca624322dc8..2af667beb273 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.h
@@ -656,13 +656,24 @@
 #define AR_PHY_SYNTH4_LONG_SHIFT_SELECT   ((AR_SREV_9462(ah) || AR_SREV_95=
65(ah)) ? 0x00000001 : 0x00000002)
 #define AR_PHY_SYNTH4_LONG_SHIFT_SELECT_S ((AR_SREV_9462(ah) || AR_SREV_95=
65(ah)) ? 0 : 1)
 #define AR_PHY_65NM_CH0_SYNTH7      0x16098
+#define AR_PHY_65NM_CH0_SYNTH12     0x160ac
 #define AR_PHY_65NM_CH0_BIAS1       0x160c0
 #define AR_PHY_65NM_CH0_BIAS2       0x160c4
 #define AR_PHY_65NM_CH0_BIAS4       0x160cc
+#define AR_PHY_65NM_CH0_RXTX2       0x16104
+#define AR_PHY_65NM_CH1_RXTX2       0x16504
+#define AR_PHY_65NM_CH2_RXTX2       0x16904
 #define AR_PHY_65NM_CH0_RXTX4       0x1610c
 #define AR_PHY_65NM_CH1_RXTX4       0x1650c
 #define AR_PHY_65NM_CH2_RXTX4       0x1690c
=20
+#define AR_PHY_65NM_CH0_SYNTH12_VREFMUL3           0x00780000
+#define AR_PHY_65NM_CH0_SYNTH12_VREFMUL3_S         19
+#define AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK         0x00000004
+#define AR_PHY_65NM_CH0_RXTX2_SYNTHON_MASK_S       2
+#define AR_PHY_65NM_CH0_RXTX2_SYNTHOVR_MASK        0x00000008
+#define AR_PHY_65NM_CH0_RXTX2_SYNTHOVR_MASK_S      3
+
 #define AR_CH0_TOP	(AR_SREV_9300(ah) ? 0x16288 : \
 			 (((AR_SREV_9462(ah) || AR_SREV_9565(ah)) ? 0x1628c : 0x16280)))
 #define AR_CH0_TOP_XPABIASLVL (AR_SREV_9550(ah) ? 0x3c0 : 0x300)
diff --git a/drivers/net/wireless/ath/ath9k/ar9462_2p1_initvals.h b/drivers=
/net/wireless/ath/ath9k/ar9462_2p1_initvals.h
index 4dbc294df7e3..57fc5f459d0a 100644
--- a/drivers/net/wireless/ath/ath9k/ar9462_2p1_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9462_2p1_initvals.h
@@ -361,7 +361,7 @@ static const u32 ar9462_2p1_baseband_postamble[][5] =3D=
 {
 	{0x00009e14, 0x37b95d5e, 0x37b9605e, 0x3236605e, 0x32365a5e},
 	{0x00009e18, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x00009e1c, 0x0001cf9c, 0x0001cf9c, 0x00021f9c, 0x00021f9c},
-	{0x00009e20, 0x000003b5, 0x000003b5, 0x000003ce, 0x000003ce},
+	{0x00009e20, 0x000003a5, 0x000003a5, 0x000003a5, 0x000003a5},
 	{0x00009e2c, 0x0000001c, 0x0000001c, 0x00000021, 0x00000021},
 	{0x00009e3c, 0xcf946220, 0xcf946220, 0xcfd5c782, 0xcfd5c282},
 	{0x00009e44, 0x62321e27, 0x62321e27, 0xfe291e27, 0xfe291e27},
@@ -400,7 +400,7 @@ static const u32 ar9462_2p1_baseband_postamble[][5] =3D=
 {
 	{0x0000ae04, 0x001c0000, 0x001c0000, 0x001c0000, 0x00100000},
 	{0x0000ae18, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000ae1c, 0x0000019c, 0x0000019c, 0x0000019c, 0x0000019c},
-	{0x0000ae20, 0x000001b5, 0x000001b5, 0x000001ce, 0x000001ce},
+	{0x0000ae20, 0x000001a6, 0x000001a6, 0x000001aa, 0x000001aa},
 	{0x0000b284, 0x00000000, 0x00000000, 0x00000550, 0x00000550},
 };
=20
@@ -472,7 +472,7 @@ static const u32 ar9462_2p1_radio_postamble[][5] =3D {
=20
 static const u32 ar9462_2p1_soc_preamble[][2] =3D {
 	/* Addr      allmodes  */
-	{0x000040a4, 0x00a0c1c9},
+	{0x000040a4, 0x00a0c9c9},
 	{0x00007020, 0x00000000},
 	{0x00007034, 0x00000002},
 	{0x00007038, 0x000004c2},
diff --git a/drivers/net/wireless/ath/regd.c b/drivers/net/wireless/ath/reg=
d.c
index c00687e05688..1217c52ab28e 100644
--- a/drivers/net/wireless/ath/regd.c
+++ b/drivers/net/wireless/ath/regd.c
@@ -362,7 +362,8 @@ static int __ath_reg_dyn_country(struct wiphy *wiphy,
 {
 	u16 country_code;
=20
-	if (!ath_is_world_regd(reg))
+	if (request->initiator =3D=3D NL80211_REGDOM_SET_BY_COUNTRY_IE &&
+	    !ath_is_world_regd(reg))
 		return -EINVAL;
=20
 	country_code =3D ath_regd_find_country_by_name(request->alpha2);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wi=
reless/brcm80211/brcmfmac/p2p.c
index 5b5b952d47b1..4a2293041821 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
@@ -823,6 +823,7 @@ static s32 brcmf_p2p_run_escan(struct brcmf_cfg80211_in=
fo *cfg,
 		}
 		err =3D brcmf_p2p_escan(p2p, num_nodfs, chanspecs, search_state,
 				      action, P2PAPI_BSSCFG_DEVICE);
+		kfree(chanspecs);
 	}
 exit:
 	if (err)
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless=
/mwifiex/cfg80211.c
index fbad00a5abc8..aeaea0e3b4c4 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -2210,8 +2210,10 @@ struct wireless_dev *mwifiex_add_virtual_intf(struct=
 wiphy *wiphy,
 		priv->bss_started =3D 0;
 		priv->bss_num =3D 0;
=20
-		if (mwifiex_cfg80211_init_p2p_client(priv))
-			return ERR_PTR(-EFAULT);
+		if (mwifiex_cfg80211_init_p2p_client(priv)) {
+			wdev =3D ERR_PTR(-EFAULT);
+			goto done;
+		}
=20
 		break;
 	default:
@@ -2224,7 +2226,8 @@ struct wireless_dev *mwifiex_add_virtual_intf(struct =
wiphy *wiphy,
 	if (!dev) {
 		wiphy_err(wiphy, "no memory available for netdevice\n");
 		priv->bss_mode =3D NL80211_IFTYPE_UNSPECIFIED;
-		return ERR_PTR(-ENOMEM);
+		wdev =3D ERR_PTR(-ENOMEM);
+		goto done;
 	}
=20
 	mwifiex_init_priv_params(priv, dev);
@@ -2264,7 +2267,9 @@ struct wireless_dev *mwifiex_add_virtual_intf(struct =
wiphy *wiphy,
 		wiphy_err(wiphy, "cannot register virtual network device\n");
 		free_netdev(dev);
 		priv->bss_mode =3D NL80211_IFTYPE_UNSPECIFIED;
-		return ERR_PTR(-EFAULT);
+		priv->netdev =3D NULL;
+		wdev =3D ERR_PTR(-EFAULT);
+		goto done;
 	}
=20
 	sema_init(&priv->async_sem, 1);
@@ -2274,6 +2279,13 @@ struct wireless_dev *mwifiex_add_virtual_intf(struct=
 wiphy *wiphy,
 #ifdef CONFIG_DEBUG_FS
 	mwifiex_dev_debugfs_init(priv);
 #endif
+
+done:
+	if (IS_ERR(wdev)) {
+		kfree(priv->wdev);
+		priv->wdev =3D NULL;
+	}
+
 	return wdev;
 }
 EXPORT_SYMBOL_GPL(mwifiex_add_virtual_intf);
@@ -2298,7 +2310,10 @@ int mwifiex_del_virtual_intf(struct wiphy *wiphy, st=
ruct wireless_dev *wdev)
 		unregister_netdevice(wdev->netdev);
=20
 	/* Clear the priv in adapter */
+	priv->netdev->ieee80211_ptr =3D NULL;
 	priv->netdev =3D NULL;
+	kfree(wdev);
+	priv->wdev =3D NULL;
=20
 	priv->media_connected =3D false;
=20
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwi=
fiex/main.c
index 9d7c9d354d34..78e8a6666cc6 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -411,13 +411,14 @@ static void mwifiex_terminate_workqueue(struct mwifie=
x_adapter *adapter)
  */
 static void mwifiex_fw_dpc(const struct firmware *firmware, void *context)
 {
-	int ret, i;
+	int ret;
 	char fmt[64];
 	struct mwifiex_private *priv;
 	struct mwifiex_adapter *adapter =3D context;
 	struct mwifiex_fw_image fw;
 	struct semaphore *sem =3D adapter->card_sem;
 	bool init_failed =3D false;
+	struct wireless_dev *wdev;
=20
 	if (!firmware) {
 		dev_err(adapter->dev,
@@ -469,14 +470,16 @@ static void mwifiex_fw_dpc(const struct firmware *fir=
mware, void *context)
 	priv =3D adapter->priv[MWIFIEX_BSS_ROLE_STA];
 	if (mwifiex_register_cfg80211(adapter)) {
 		dev_err(adapter->dev, "cannot register with cfg80211\n");
-		goto err_register_cfg80211;
+		goto err_init_fw;
 	}
=20
 	rtnl_lock();
 	/* Create station interface by default */
-	if (!mwifiex_add_virtual_intf(adapter->wiphy, "mlan%d",
-				      NL80211_IFTYPE_STATION, NULL, NULL)) {
+	wdev =3D mwifiex_add_virtual_intf(adapter->wiphy, "mlan%d",
+					NL80211_IFTYPE_STATION, NULL, NULL);
+	if (IS_ERR(wdev)) {
 		dev_err(adapter->dev, "cannot create default STA interface\n");
+		rtnl_unlock();
 		goto err_add_intf;
 	}
 	rtnl_unlock();
@@ -486,17 +489,6 @@ static void mwifiex_fw_dpc(const struct firmware *firm=
ware, void *context)
 	goto done;
=20
 err_add_intf:
-	for (i =3D 0; i < adapter->priv_num; i++) {
-		priv =3D adapter->priv[i];
-
-		if (!priv)
-			continue;
-
-		if (priv->wdev && priv->netdev)
-			mwifiex_del_virtual_intf(adapter->wiphy, priv->wdev);
-	}
-	rtnl_unlock();
-err_register_cfg80211:
 	wiphy_unregister(adapter->wiphy);
 	wiphy_free(adapter->wiphy);
 err_init_fw:
@@ -1006,12 +998,6 @@ int mwifiex_remove_card(struct mwifiex_adapter *adapt=
er, struct semaphore *sem)
 	wiphy_unregister(priv->wdev->wiphy);
 	wiphy_free(priv->wdev->wiphy);
=20
-	for (i =3D 0; i < adapter->priv_num; i++) {
-		priv =3D adapter->priv[i];
-		if (priv)
-			kfree(priv->wdev);
-	}
-
 	mwifiex_terminate_workqueue(adapter);
=20
 	/* Unregister device */
diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwi=
fiex/pcie.c
index 33fa9432b241..03688aa14e8a 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -232,7 +232,6 @@ static void mwifiex_pcie_remove(struct pci_dev *pdev)
 	}
=20
 	mwifiex_remove_card(card->adapter, &add_remove_card_sem);
-	kfree(card);
 }
=20
 static void mwifiex_pcie_shutdown(struct pci_dev *pdev)
@@ -2313,6 +2312,7 @@ static void mwifiex_pcie_cleanup(struct mwifiex_adapt=
er *adapter)
 		pci_release_region(pdev, 0);
 		pci_set_drvdata(pdev, NULL);
 	}
+	kfree(card);
 }
=20
 /*
diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/mwi=
fiex/sdio.c
index 9bf8898743ab..b44a31523461 100644
--- a/drivers/net/wireless/mwifiex/sdio.c
+++ b/drivers/net/wireless/mwifiex/sdio.c
@@ -196,7 +196,6 @@ mwifiex_sdio_remove(struct sdio_func *func)
 	}
=20
 	mwifiex_remove_card(card->adapter, &add_remove_card_sem);
-	kfree(card);
 }
=20
 /*
@@ -1745,7 +1744,6 @@ mwifiex_unregister_dev(struct mwifiex_adapter *adapte=
r)
 		sdio_claim_host(card->func);
 		sdio_disable_func(card->func);
 		sdio_release_host(card->func);
-		sdio_set_drvdata(card->func, NULL);
 	}
 }
=20
@@ -1773,7 +1771,6 @@ static int mwifiex_register_dev(struct mwifiex_adapte=
r *adapter)
 		return ret;
 	}
=20
-	sdio_set_drvdata(func, card);
=20
 	adapter->dev =3D &func->dev;
=20
@@ -1801,6 +1798,8 @@ static int mwifiex_init_sdio(struct mwifiex_adapter *=
adapter)
 	int ret;
 	u8 sdio_ireg;
=20
+	sdio_set_drvdata(card->func, card);
+
 	/*
 	 * Read the HOST_INT_STATUS_REG for ACK the first interrupt got
 	 * from the bootloader. If we don't do this we get a interrupt
@@ -1883,6 +1882,8 @@ static void mwifiex_cleanup_sdio(struct mwifiex_adapt=
er *adapter)
 	kfree(card->mpa_rx.len_arr);
 	kfree(card->mpa_tx.buf);
 	kfree(card->mpa_rx.buf);
+	sdio_set_drvdata(card->func, NULL);
+	kfree(card);
 }
=20
 /*
diff --git a/drivers/net/wireless/mwifiex/usb.c b/drivers/net/wireless/mwif=
iex/usb.c
index 1c70b8d09227..edf5b7a24900 100644
--- a/drivers/net/wireless/mwifiex/usb.c
+++ b/drivers/net/wireless/mwifiex/usb.c
@@ -350,7 +350,6 @@ static int mwifiex_usb_probe(struct usb_interface *intf,
=20
 	card->udev =3D udev;
 	card->intf =3D intf;
-	usb_card =3D card;
=20
 	pr_debug("info: bcdUSB=3D%#x Device Class=3D%#x SubClass=3D%#x Protocol=
=3D%#x\n",
 		 udev->descriptor.bcdUSB, udev->descriptor.bDeviceClass,
@@ -525,25 +524,28 @@ static int mwifiex_usb_resume(struct usb_interface *i=
ntf)
 static void mwifiex_usb_disconnect(struct usb_interface *intf)
 {
 	struct usb_card_rec *card =3D usb_get_intfdata(intf);
-	struct mwifiex_adapter *adapter;
=20
-	if (!card || !card->adapter) {
-		pr_err("%s: card or card->adapter is NULL\n", __func__);
+	if (!card) {
+		pr_err("%s: card is NULL\n", __func__);
 		return;
 	}
=20
-	adapter =3D card->adapter;
-	if (!adapter->priv_num)
-		return;
-
 	mwifiex_usb_free(card);
=20
-	dev_dbg(adapter->dev, "%s: removing card\n", __func__);
-	mwifiex_remove_card(adapter, &add_remove_card_sem);
+	if (card->adapter) {
+		struct mwifiex_adapter *adapter =3D card->adapter;
+
+		if (!adapter->priv_num)
+			return;
+
+		dev_dbg(adapter->dev, "%s: removing card\n", __func__);
+		mwifiex_remove_card(adapter, &add_remove_card_sem);
+	}
=20
 	usb_set_intfdata(intf, NULL);
 	usb_put_dev(interface_to_usbdev(intf));
 	kfree(card);
+	usb_card =3D NULL;
=20
 	return;
 }
@@ -754,6 +756,7 @@ static int mwifiex_register_dev(struct mwifiex_adapter =
*adapter)
 	card->adapter =3D adapter;
 	adapter->dev =3D &card->udev->dev;
 	strcpy(adapter->fw_name, USB8797_DEFAULT_FW_NAME);
+	usb_card =3D card;
=20
 	return 0;
 }
@@ -762,7 +765,7 @@ static void mwifiex_unregister_dev(struct mwifiex_adapt=
er *adapter)
 {
 	struct usb_card_rec *card =3D (struct usb_card_rec *)adapter->card;
=20
-	usb_set_intfdata(card->intf, NULL);
+	card->adapter =3D NULL;
 }
=20
 static int mwifiex_prog_fw_w_helper(struct mwifiex_adapter *adapter,
@@ -1004,7 +1007,7 @@ static void mwifiex_usb_cleanup_module(void)
 	if (!down_interruptible(&add_remove_card_sem))
 		up(&add_remove_card_sem);
=20
-	if (usb_card) {
+	if (usb_card && usb_card->adapter) {
 		struct mwifiex_adapter *adapter =3D usb_card->adapter;
 		int i;
=20
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless=
/rt2x00/rt2x00dev.c
index 080b1fcae5fa..9dd92a700442 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -181,6 +181,7 @@ static void rt2x00lib_autowakeup(struct work_struct *wo=
rk)
 static void rt2x00lib_bc_buffer_iter(void *data, u8 *mac,
 				     struct ieee80211_vif *vif)
 {
+	struct ieee80211_tx_control control =3D {};
 	struct rt2x00_dev *rt2x00dev =3D data;
 	struct sk_buff *skb;
=20
@@ -195,7 +196,7 @@ static void rt2x00lib_bc_buffer_iter(void *data, u8 *ma=
c,
 	 */
 	skb =3D ieee80211_get_buffered_bc(rt2x00dev->hw, vif);
 	while (skb) {
-		rt2x00mac_tx(rt2x00dev->hw, NULL, skb);
+		rt2x00mac_tx(rt2x00dev->hw, &control, skb);
 		skb =3D ieee80211_get_buffered_bc(rt2x00dev->hw, vif);
 	}
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wir=
eless/rtlwifi/rtl8192cu/mac.c
index 393685390f3e..e26312fb4356 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -769,7 +769,7 @@ static long _rtl92c_signal_scale_mapping(struct ieee802=
11_hw *hw,
=20
 static void _rtl92c_query_rxphystatus(struct ieee80211_hw *hw,
 				      struct rtl_stats *pstats,
-				      struct rx_desc_92c *pdesc,
+				      struct rx_desc_92c *p_desc,
 				      struct rx_fwinfo_92c *p_drvinfo,
 				      bool packet_match_bssid,
 				      bool packet_toself,
@@ -784,11 +784,11 @@ static void _rtl92c_query_rxphystatus(struct ieee8021=
1_hw *hw,
 	u32 rssi, total_rssi =3D 0;
 	bool in_powersavemode =3D false;
 	bool is_cck_rate;
+	u8 *pdesc =3D (u8 *)p_desc;
=20
-	is_cck_rate =3D RX_HAL_IS_CCK_RATE(pdesc);
+	is_cck_rate =3D RX_HAL_IS_CCK_RATE(p_desc);
 	pstats->packet_matchbssid =3D packet_match_bssid;
 	pstats->packet_toself =3D packet_toself;
-	pstats->is_cck =3D is_cck_rate;
 	pstats->packet_beacon =3D packet_beacon;
 	pstats->is_cck =3D is_cck_rate;
 	pstats->RX_SIGQ[0] =3D -1;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8192cu/trx.c
index b0c346a9e4b8..1bc21ccfa71b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -303,10 +303,10 @@ out:
 bool rtl92cu_rx_query_desc(struct ieee80211_hw *hw,
 			   struct rtl_stats *stats,
 			   struct ieee80211_rx_status *rx_status,
-			   u8 *p_desc, struct sk_buff *skb)
+			   u8 *pdesc, struct sk_buff *skb)
 {
 	struct rx_fwinfo_92c *p_drvinfo;
-	struct rx_desc_92c *pdesc =3D (struct rx_desc_92c *)p_desc;
+	struct rx_desc_92c *p_desc =3D (struct rx_desc_92c *)pdesc;
 	u32 phystatus =3D GET_RX_DESC_PHY_STATUS(pdesc);
=20
 	stats->length =3D (u16) GET_RX_DESC_PKT_LEN(pdesc);
@@ -345,7 +345,7 @@ bool rtl92cu_rx_query_desc(struct ieee80211_hw *hw,
 	if (phystatus) {
 		p_drvinfo =3D (struct rx_fwinfo_92c *)(skb->data +
 						     stats->rx_bufshift);
-		rtl92c_translate_rx_signal_stuff(hw, skb, stats, pdesc,
+		rtl92c_translate_rx_signal_stuff(hw, skb, stats, p_desc,
 						 p_drvinfo);
 	}
 	/*rx_status->qual =3D stats->signal; */
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 0cef67707838..4af3821df880 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -2439,6 +2439,9 @@ int l2cap_chan_send(struct l2cap_chan *chan, struct m=
sghdr *msg, size_t len,
 	int err;
 	struct sk_buff_head seg_queue;
=20
+	if (!chan->conn)
+		return -ENOTCONN;
+
 	/* Connectionless channel */
 	if (chan->chan_type =3D=3D L2CAP_CHAN_CONN_LESS) {
 		skb =3D l2cap_create_connless_pdu(chan, msg, len, priority);
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 94d06cbfbc18..facd8a79c038 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -694,6 +694,7 @@ static struct rfcomm_session *rfcomm_session_create(bda=
ddr_t *src,
 	addr.l2_family =3D AF_BLUETOOTH;
 	addr.l2_psm    =3D 0;
 	addr.l2_cid    =3D 0;
+	addr.l2_bdaddr_type =3D BDADDR_BREDR;
 	*err =3D kernel_bind(sock, (struct sockaddr *) &addr, sizeof(addr));
 	if (*err < 0)
 		goto failed;
@@ -719,6 +720,7 @@ static struct rfcomm_session *rfcomm_session_create(bda=
ddr_t *src,
 	addr.l2_family =3D AF_BLUETOOTH;
 	addr.l2_psm    =3D __constant_cpu_to_le16(RFCOMM_PSM);
 	addr.l2_cid    =3D 0;
+	addr.l2_bdaddr_type =3D BDADDR_BREDR;
 	*err =3D kernel_connect(sock, (struct sockaddr *) &addr, sizeof(addr), O_=
NONBLOCK);
 	if (*err =3D=3D 0 || *err =3D=3D -EINPROGRESS)
 		return s;
@@ -1983,6 +1985,7 @@ static int rfcomm_add_listener(bdaddr_t *ba)
 	addr.l2_family =3D AF_BLUETOOTH;
 	addr.l2_psm    =3D __constant_cpu_to_le16(RFCOMM_PSM);
 	addr.l2_cid    =3D 0;
+	addr.l2_bdaddr_type =3D BDADDR_BREDR;
 	err =3D kernel_bind(sock, (struct sockaddr *) &addr, sizeof(addr));
 	if (err < 0) {
 		BT_ERR("Bind failed %d", err);
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index c80766f892c3..3c2d3e4aa2f5 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -738,8 +738,9 @@ static int rfcomm_sock_setsockopt(struct socket *sock, =
int level, int optname, c
 static int rfcomm_sock_getsockopt_old(struct socket *sock, int optname, ch=
ar __user *optval, int __user *optlen)
 {
 	struct sock *sk =3D sock->sk;
+	struct sock *l2cap_sk;
+	struct l2cap_conn *conn;
 	struct rfcomm_conninfo cinfo;
-	struct l2cap_conn *conn =3D l2cap_pi(sk)->chan->conn;
 	int len, err =3D 0;
 	u32 opt;
=20
@@ -782,6 +783,9 @@ static int rfcomm_sock_getsockopt_old(struct socket *so=
ck, int optname, char __u
 			break;
 		}
=20
+		l2cap_sk =3D rfcomm_pi(sk)->dlc->session->sock->sk;
+		conn =3D l2cap_pi(l2cap_sk)->chan->conn;
+
 		memset(&cinfo, 0, sizeof(cinfo));
 		cinfo.hci_handle =3D conn->hcon->handle;
 		memcpy(cinfo.dev_class, conn->hcon->dev_class, 3);
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 85a2796cac61..4b07acb8293c 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -742,6 +742,9 @@ static u8 smp_cmd_security_req(struct l2cap_conn *conn,=
 struct sk_buff *skb)
=20
 	BT_DBG("conn %p", conn);
=20
+	if (!(conn->hcon->link_mode & HCI_LM_MASTER))
+		return SMP_CMD_NOTSUPP;
+
 	hcon->pending_sec_level =3D authreq_to_seclevel(rp->auth_req);
=20
 	if (smp_ltk_encrypt(conn, hcon->pending_sec_level))
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--3MwIy2ne0vdjdPXF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSjimwAAoJEJctW/TcYTgGocEQAImN4O+y0VAfQh3qHsjvdCSL
QesnK7f0XK4iC3hwiB6pcfyUjS/B/z5QAWpBOlnmymZ46Wy8t3kFpz1YrqBKG2yd
9vgNpR1C94tnDxC2VDSL8cLlz7/rBFNSyKwZmOojBnXwZ1X8u8S7NmDhdAMrA+r7
Yav/snVfF+O0rjD0H0wPLFH4dcy5zRRq7n58aRLzMWoLtaVhoOQ22sLwP0aI/Mmi
GxmP1qmRkbbBWiq5WVQjHueygCpc1veL0E//5rwspaQ+bvu5wMrg4ASU7EBmgXJ6
+Q7F5oKr62GOtoagOCi3P98clPBuFNpIhREn0snUeOPD1Riq7TyMfCiTYOXXeEnG
XZgQqgkKs6jcKU+JX2cstX+2m2MtRjoAOH0KJZIIhFttMcOBqgzYR15T05ner6BR
cnofomInzWu0jw3QX8uPjil5YxZGtzkMqpgrwb7vvqlaQQRn5TiKkF6NO/f98ZvJ
mRpq8XJq/NeCzkSTTJeO+S2j3EofwKfV1NVpcdwShwMuU0NMzMLDrZpMo+OJ4UYA
z3KrZtdndW/ShXmzdbXXQvPfDz64djFuKwSKlPyu8kc8Fb9sY+mroqwM/j4r6zY3
QbhdImkXUGBLQCbRzCukZicTcsACqrnH6XR7aXGxACOySNqNLhVQ7fEktT/3v1BR
Bgj8l1L3BW/d4RNx8AM0
=rLOj
-----END PGP SIGNATURE-----

--3MwIy2ne0vdjdPXF--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
