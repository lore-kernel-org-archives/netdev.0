From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-11-26
Date: Wed, 26 Nov 2014 14:47:43 -0500
Message-ID: <20141126194743.GA12284@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this little batch of fixes intended for the 3.18 stream...

For the iwlwifi one, Emmanuel says:

"Not all the firmware know how to handle the HOT_SPOT_CMD.
Make sure that the firmware will know this command before
sending it. This avoids a firmware crash."

Along with that, Larry sends a pair of rtlwifi fixes to address some
discrepancies from moving drivers out of staging.  Larry says:

"These two patches are needed to fix a regression introduced when
driver rtl8821ae was moved from staging to the regular wireless tree."

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit a1d69c60c44134f64945bbf6a6dfda22eaf4a214:

  brcmfmac: don't include linux/unaligned/access_ok.h (2014-11-20 14:46:45 =
-0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-11-25

for you to fetch changes up to 7d63a5f9b25ba6b130da8eb2d32a72b1462d0249:

  rtlwifi: Change order in device startup (2014-11-25 14:22:22 -0500)

----------------------------------------------------------------
John W. Linville (1):
      Merge tag 'iwlwifi-for-john-2014-11-23' of git://git.kernel.org/.../i=
wlwifi/iwlwifi-fixes

Larry Finger (2):
      rtlwifi: rtl8821ae: Fix 5G detection problem
      rtlwifi: Change order in device startup

Luciano Coelho (1):
      iwlwifi: mvm: check TLV flag before trying to use hotspot firmware co=
mmands

 drivers/net/wireless/iwlwifi/iwl-fw.h       |  2 ++
 drivers/net/wireless/iwlwifi/mvm/mac80211.c | 12 +++++++++---
 drivers/net/wireless/rtlwifi/pci.c          | 20 ++++++++++----------
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c |  5 +++--
 4 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-fw.h b/drivers/net/wireless/i=
wlwifi/iwl-fw.h
index 4f6e66892acc..b894a84e8393 100644
--- a/drivers/net/wireless/iwlwifi/iwl-fw.h
+++ b/drivers/net/wireless/iwlwifi/iwl-fw.h
@@ -155,6 +155,7 @@ enum iwl_ucode_tlv_api {
  * @IWL_UCODE_TLV_CAPA_QUIET_PERIOD_SUPPORT: supports Quiet Period requests
  * @IWL_UCODE_TLV_CAPA_DQA_SUPPORT: supports dynamic queue allocation (DQA=
),
  *	which also implies support for the scheduler configuration command
+ * @IWL_UCODE_TLV_CAPA_HOTSPOT_SUPPORT: supports Hot Spot Command
  */
 enum iwl_ucode_tlv_capa {
 	IWL_UCODE_TLV_CAPA_D0I3_SUPPORT			=3D BIT(0),
@@ -163,6 +164,7 @@ enum iwl_ucode_tlv_capa {
 	IWL_UCODE_TLV_CAPA_WFA_TPC_REP_IE_SUPPORT	=3D BIT(10),
 	IWL_UCODE_TLV_CAPA_QUIET_PERIOD_SUPPORT		=3D BIT(11),
 	IWL_UCODE_TLV_CAPA_DQA_SUPPORT			=3D BIT(12),
+	IWL_UCODE_TLV_CAPA_HOTSPOT_SUPPORT		=3D BIT(18),
 };
=20
 /* The default calibrate table size if not specified by firmware file */
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index b62405865b25..b6d2683da3a9 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -2448,9 +2448,15 @@ static int iwl_mvm_roc(struct ieee80211_hw *hw,
=20
 	switch (vif->type) {
 	case NL80211_IFTYPE_STATION:
-		/* Use aux roc framework (HS20) */
-		ret =3D iwl_mvm_send_aux_roc_cmd(mvm, channel,
-					       vif, duration);
+		if (mvm->fw->ucode_capa.capa[0] &
+		    IWL_UCODE_TLV_CAPA_HOTSPOT_SUPPORT) {
+			/* Use aux roc framework (HS20) */
+			ret =3D iwl_mvm_send_aux_roc_cmd(mvm, channel,
+						       vif, duration);
+			goto out_unlock;
+		}
+		IWL_ERR(mvm, "hotspot not supported\n");
+		ret =3D -EINVAL;
 		goto out_unlock;
 	case NL80211_IFTYPE_P2P_DEVICE:
 		/* handle below */
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlw=
ifi/pci.c
index 61f5d36eca6a..846a2e6e34d8 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -2249,6 +2249,16 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	/*like read eeprom and so on */
 	rtlpriv->cfg->ops->read_eeprom_info(hw);
=20
+	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
+		err =3D -ENODEV;
+		goto fail3;
+	}
+	rtlpriv->cfg->ops->init_sw_leds(hw);
+
+	/*aspm */
+	rtl_pci_init_aspm(hw);
+
 	/* Init mac80211 sw */
 	err =3D rtl_init_core(hw);
 	if (err) {
@@ -2264,16 +2274,6 @@ int rtl_pci_probe(struct pci_dev *pdev,
 		goto fail3;
 	}
=20
-	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
-		err =3D -ENODEV;
-		goto fail3;
-	}
-	rtlpriv->cfg->ops->init_sw_leds(hw);
-
-	/*aspm */
-	rtl_pci_init_aspm(hw);
-
 	err =3D ieee80211_register_hw(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8821ae/hw.c
index 310d3163dc5b..8ec8200002c7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
@@ -3672,8 +3672,9 @@ static void rtl8821ae_update_hal_rate_mask(struct iee=
e80211_hw *hw,
 		mac->opmode =3D=3D NL80211_IFTYPE_ADHOC)
 		macid =3D sta->aid + 1;
 	if (wirelessmode =3D=3D WIRELESS_MODE_N_5G ||
-	    wirelessmode =3D=3D WIRELESS_MODE_AC_5G)
-		ratr_bitmap =3D sta->supp_rates[NL80211_BAND_5GHZ];
+	    wirelessmode =3D=3D WIRELESS_MODE_AC_5G ||
+	    wirelessmode =3D=3D WIRELESS_MODE_A)
+		ratr_bitmap =3D sta->supp_rates[NL80211_BAND_5GHZ] << 4;
 	else
 		ratr_bitmap =3D sta->supp_rates[NL80211_BAND_2GHZ];
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUdi5fAAoJEJctW/TcYTgGJ0sP/jdQ3RboevsAJE/9RWu8mH3C
Z1qc7rGlpsgb9HnPYqfFVaWHJsHBRZ9AEWwbsSv2seefY75dbK/HYcbOcyMhpvHD
7xCu9DSUQnkgK38Do2j9/USrWUsmTSZ96QhC1fymmCRft2nM3iOHWCx/DaXNIm94
yzqY59GllUrxH25iuH/2ohlxzqAnsGzAzCyFEGS3k2oXO7ijeWk35cz8Y47hUobz
b83vJ8Mb4qwvn1ZbdvMvnWGCSIIOrUvpnfFIIWXi65r3gkWy9Zm21itupGgKvicV
Bf4wehrqmBIy02C86aqK6iS+nZvQ7e668wCr8QJdo0gPc/rjPQ8cxFtL3K9rRYCS
BHryTONxBByIidvoC410w0/sDWtHtIOe8Z2wJzfpFbOqVE08rtVFYY9Tw3bvARK/
jJcpVwvZpQAJjG7zRbSWAh8LyoRqVP5LTL/BZ/LTnDArVGAEWnyGXVw7BBfbgpME
R8PHh2JOOFYIBqS3mqGrzAW3X3TjtZMJd+oDPalE4RbvofBMHXtOgi8cW2jIbSum
6eB6IJbflSc9r2SPLxxU5sT5eubmqganOoaYHEqOZ9Xf8KJQNyYwrKZy9IJ5IAMh
j+JsyubBSXYACd3HxXlohReHrxlZNn3YLrWDTCBjRQtaYJzqSgLbJMHeI3vSkBg7
dTWPh1KOayc9AXRaOI6Q
=kt4Y
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--
