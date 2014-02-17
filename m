From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-02-17
Date: Mon, 17 Feb 2014 17:39:21 -0500
Message-ID: <20140217223921.GA29923@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.14 stream...

For the iwlwifi one, Emmanuel says:

"As explicitly written in the commit message, we prefer to disable Tx
AMPDU on NICs supported by iwldvm. This feature gives a big boost in
Tx performance, but the firmware is buggy and we can't rely on it.
Our hope is that most of the users out there want wifi to surf on
the web which means that they care more for Rx traffic than for Tx.
People who want to enable it can do so with the help of a module
parameter."

On top of that...

Dan Carpenter fixes a typo/thinko in ath5k.

Olivier Langlois fixes a couple of rtlwifi issues, one which leaves
IRQs disabled too long (causing a variety of problems elsewhere),
and one which fixes an incorrect return code when failing to enable
the NIC.

Russell King fixes a NULL pointer dereference in hostap.

Stanislaw Gruszka fixes a DMA coherence issue in the rtl8187 driver.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit eb85569fe2d06c2fbf4de7b66c263ca095b397aa:

  usbnet: remove generic hard_header_len check (2014-02-17 14:35:46 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to ff95fe382c658d81ebe01ba68dca2e00ca814ff0:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-02-17 15:54:31 -0500)

----------------------------------------------------------------

Dan Carpenter (1):
      ath5k: shifting the wrong variable for AR5K_AR5210

Emmanuel Grumbach (1):
      iwlwifi: disable TX AMPDU by default for iwldvm

John W. Linville (2):
      Merge git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Olivier Langlois (2):
      rtlwifi: rtl8192ce: Fix too long disable of IRQs
      rtlwifi: Fix incorrect return from rtl_ps_enable_nic()

Russell King - ARM Linux (1):
      hostap: fix "hostap: proc: Use remove_proc_subtree()"

Stanislaw Gruszka (1):
      rtl8187: fix regression on MIPS without coherent DMA

 drivers/net/wireless/ath/ath5k/phy.c           |  2 +-
 drivers/net/wireless/hostap/hostap_proc.c      |  2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c    | 22 ++++++++++++++++++++--
 drivers/net/wireless/iwlwifi/iwl-drv.c         |  2 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h   | 11 +++++++----
 drivers/net/wireless/iwlwifi/mvm/mac80211.c    | 22 ++++++++++++++++++++--
 drivers/net/wireless/rtl818x/rtl8187/rtl8187.h | 10 ++++++++--
 drivers/net/wireless/rtlwifi/ps.c              |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c    | 18 ++++++++++++++++--
 9 files changed, 75 insertions(+), 16 deletions(-)
diff --git a/drivers/net/wireless/ath/ath5k/phy.c b/drivers/net/wireless/at=
h/ath5k/phy.c
index d6bc7cb61bfb..1a2973b7acf2 100644
--- a/drivers/net/wireless/ath/ath5k/phy.c
+++ b/drivers/net/wireless/ath/ath5k/phy.c
@@ -110,7 +110,7 @@ ath5k_hw_radio_revision(struct ath5k_hw *ah, enum ieee8=
0211_band band)
 		ath5k_hw_reg_write(ah, 0x00010000, AR5K_PHY(0x20));
=20
 	if (ah->ah_version =3D=3D AR5K_AR5210) {
-		srev =3D ath5k_hw_reg_read(ah, AR5K_PHY(256) >> 28) & 0xf;
+		srev =3D (ath5k_hw_reg_read(ah, AR5K_PHY(256)) >> 28) & 0xf;
 		ret =3D (u16)ath5k_hw_bitswap(srev, 4) + 1;
 	} else {
 		srev =3D (ath5k_hw_reg_read(ah, AR5K_PHY(0x100)) >> 24) & 0xff;
diff --git a/drivers/net/wireless/hostap/hostap_proc.c b/drivers/net/wirele=
ss/hostap/hostap_proc.c
index aa7ad3a7a69b..4e5c0f8c9496 100644
--- a/drivers/net/wireless/hostap/hostap_proc.c
+++ b/drivers/net/wireless/hostap/hostap_proc.c
@@ -496,7 +496,7 @@ void hostap_init_proc(local_info_t *local)
=20
 void hostap_remove_proc(local_info_t *local)
 {
-	remove_proc_subtree(local->ddev->name, hostap_proc);
+	proc_remove(local->proc);
 }
=20
=20
diff --git a/drivers/net/wireless/iwlwifi/dvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/dvm/mac80211.c
index c24d1d3d55f6..73086c1629ca 100644
--- a/drivers/net/wireless/iwlwifi/dvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/dvm/mac80211.c
@@ -696,6 +696,24 @@ static int iwlagn_mac_set_key(struct ieee80211_hw *hw,=
 enum set_key_cmd cmd,
 	return ret;
 }
=20
+static inline bool iwl_enable_rx_ampdu(const struct iwl_cfg *cfg)
+{
+	if (iwlwifi_mod_params.disable_11n & IWL_DISABLE_HT_RXAGG)
+		return false;
+	return true;
+}
+
+static inline bool iwl_enable_tx_ampdu(const struct iwl_cfg *cfg)
+{
+	if (iwlwifi_mod_params.disable_11n & IWL_DISABLE_HT_TXAGG)
+		return false;
+	if (iwlwifi_mod_params.disable_11n & IWL_ENABLE_HT_TXAGG)
+		return true;
+
+	/* disabled by default */
+	return false;
+}
+
 static int iwlagn_mac_ampdu_action(struct ieee80211_hw *hw,
 				   struct ieee80211_vif *vif,
 				   enum ieee80211_ampdu_mlme_action action,
@@ -717,7 +735,7 @@ static int iwlagn_mac_ampdu_action(struct ieee80211_hw =
*hw,
=20
 	switch (action) {
 	case IEEE80211_AMPDU_RX_START:
-		if (iwlwifi_mod_params.disable_11n & IWL_DISABLE_HT_RXAGG)
+		if (!iwl_enable_rx_ampdu(priv->cfg))
 			break;
 		IWL_DEBUG_HT(priv, "start Rx\n");
 		ret =3D iwl_sta_rx_agg_start(priv, sta, tid, *ssn);
@@ -729,7 +747,7 @@ static int iwlagn_mac_ampdu_action(struct ieee80211_hw =
*hw,
 	case IEEE80211_AMPDU_TX_START:
 		if (!priv->trans->ops->txq_enable)
 			break;
-		if (iwlwifi_mod_params.disable_11n & IWL_DISABLE_HT_TXAGG)
+		if (!iwl_enable_tx_ampdu(priv->cfg))
 			break;
 		IWL_DEBUG_HT(priv, "start Tx\n");
 		ret =3D iwlagn_tx_agg_start(priv, vif, sta, tid, ssn);
diff --git a/drivers/net/wireless/iwlwifi/iwl-drv.c b/drivers/net/wireless/=
iwlwifi/iwl-drv.c
index c3728163be46..75103554cd63 100644
--- a/drivers/net/wireless/iwlwifi/iwl-drv.c
+++ b/drivers/net/wireless/iwlwifi/iwl-drv.c
@@ -1286,7 +1286,7 @@ module_param_named(swcrypto, iwlwifi_mod_params.sw_cr=
ypto, int, S_IRUGO);
 MODULE_PARM_DESC(swcrypto, "using crypto in software (default 0 [hardware]=
)");
 module_param_named(11n_disable, iwlwifi_mod_params.disable_11n, uint, S_IR=
UGO);
 MODULE_PARM_DESC(11n_disable,
-	"disable 11n functionality, bitmap: 1: full, 2: agg TX, 4: agg RX");
+	"disable 11n functionality, bitmap: 1: full, 2: disable agg TX, 4: disabl=
e agg RX, 8 enable agg TX");
 module_param_named(amsdu_size_8K, iwlwifi_mod_params.amsdu_size_8K,
 		   int, S_IRUGO);
 MODULE_PARM_DESC(amsdu_size_8K, "enable 8K amsdu size (default 0)");
diff --git a/drivers/net/wireless/iwlwifi/iwl-modparams.h b/drivers/net/wir=
eless/iwlwifi/iwl-modparams.h
index 0a84ade7edac..b29075c3da8e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-modparams.h
+++ b/drivers/net/wireless/iwlwifi/iwl-modparams.h
@@ -79,9 +79,12 @@ enum iwl_power_level {
 	IWL_POWER_NUM
 };
=20
-#define IWL_DISABLE_HT_ALL	BIT(0)
-#define IWL_DISABLE_HT_TXAGG	BIT(1)
-#define IWL_DISABLE_HT_RXAGG	BIT(2)
+enum iwl_disable_11n {
+	IWL_DISABLE_HT_ALL	 =3D BIT(0),
+	IWL_DISABLE_HT_TXAGG	 =3D BIT(1),
+	IWL_DISABLE_HT_RXAGG	 =3D BIT(2),
+	IWL_ENABLE_HT_TXAGG	 =3D BIT(3),
+};
=20
 /**
  * struct iwl_mod_params
@@ -90,7 +93,7 @@ enum iwl_power_level {
  *
  * @sw_crypto: using hardware encryption, default =3D 0
  * @disable_11n: disable 11n capabilities, default =3D 0,
- *	use IWL_DISABLE_HT_* constants
+ *	use IWL_[DIS,EN]ABLE_HT_* constants
  * @amsdu_size_8K: enable 8K amsdu size, default =3D 0
  * @restart_fw: restart firmware, default =3D 1
  * @wd_disable: enable stuck queue check, default =3D 0
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index 6bf9766e5982..c35b8661b395 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -328,6 +328,24 @@ static void iwl_mvm_mac_tx(struct ieee80211_hw *hw,
 	ieee80211_free_txskb(hw, skb);
 }
=20
+static inline bool iwl_enable_rx_ampdu(const struct iwl_cfg *cfg)
+{
+	if (iwlwifi_mod_params.disable_11n & IWL_DISABLE_HT_RXAGG)
+		return false;
+	return true;
+}
+
+static inline bool iwl_enable_tx_ampdu(const struct iwl_cfg *cfg)
+{
+	if (iwlwifi_mod_params.disable_11n & IWL_DISABLE_HT_TXAGG)
+		return false;
+	if (iwlwifi_mod_params.disable_11n & IWL_ENABLE_HT_TXAGG)
+		return true;
+
+	/* enabled by default */
+	return true;
+}
+
 static int iwl_mvm_mac_ampdu_action(struct ieee80211_hw *hw,
 				    struct ieee80211_vif *vif,
 				    enum ieee80211_ampdu_mlme_action action,
@@ -347,7 +365,7 @@ static int iwl_mvm_mac_ampdu_action(struct ieee80211_hw=
 *hw,
=20
 	switch (action) {
 	case IEEE80211_AMPDU_RX_START:
-		if (iwlwifi_mod_params.disable_11n & IWL_DISABLE_HT_RXAGG) {
+		if (!iwl_enable_rx_ampdu(mvm->cfg)) {
 			ret =3D -EINVAL;
 			break;
 		}
@@ -357,7 +375,7 @@ static int iwl_mvm_mac_ampdu_action(struct ieee80211_hw=
 *hw,
 		ret =3D iwl_mvm_sta_rx_agg(mvm, sta, tid, 0, false);
 		break;
 	case IEEE80211_AMPDU_TX_START:
-		if (iwlwifi_mod_params.disable_11n & IWL_DISABLE_HT_TXAGG) {
+		if (!iwl_enable_tx_ampdu(mvm->cfg)) {
 			ret =3D -EINVAL;
 			break;
 		}
diff --git a/drivers/net/wireless/rtl818x/rtl8187/rtl8187.h b/drivers/net/w=
ireless/rtl818x/rtl8187/rtl8187.h
index 56aee067f324..a6ad79f61bf9 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/rtl8187.h
+++ b/drivers/net/wireless/rtl818x/rtl8187/rtl8187.h
@@ -15,6 +15,8 @@
 #ifndef RTL8187_H
 #define RTL8187_H
=20
+#include <linux/cache.h>
+
 #include "rtl818x.h"
 #include "leds.h"
=20
@@ -139,7 +141,10 @@ struct rtl8187_priv {
 	u8 aifsn[4];
 	u8 rfkill_mask;
 	struct {
-		__le64 buf;
+		union {
+			__le64 buf;
+			u8 dummy1[L1_CACHE_BYTES];
+		} ____cacheline_aligned;
 		struct sk_buff_head queue;
 	} b_tx_status; /* This queue is used by both -b and non-b devices */
 	struct mutex io_mutex;
@@ -147,7 +152,8 @@ struct rtl8187_priv {
 		u8 bits8;
 		__le16 bits16;
 		__le32 bits32;
-	} *io_dmabuf;
+		u8 dummy2[L1_CACHE_BYTES];
+	} *io_dmabuf ____cacheline_aligned;
 	bool rfkill_off;
 	u16 seqno;
 };
diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwi=
fi/ps.c
index deedae3c5449..d1c0191a195b 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -48,7 +48,7 @@ bool rtl_ps_enable_nic(struct ieee80211_hw *hw)
=20
 	/*<2> Enable Adapter */
 	if (rtlpriv->cfg->ops->hw_init(hw))
-		return 1;
+		return false;
 	RT_CLEAR_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
=20
 	/*<3> Enable Interrupt */
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192ce/hw.c
index a82b30a1996c..2eb0b38384dd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -937,14 +937,26 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 	bool is92c;
 	int err;
 	u8 tmp_u1b;
+	unsigned long flags;
=20
 	rtlpci->being_init_adapter =3D true;
+
+	/* Since this function can take a very long time (up to 350 ms)
+	 * and can be called with irqs disabled, reenable the irqs
+	 * to let the other devices continue being serviced.
+	 *
+	 * It is safe doing so since our own interrupts will only be enabled
+	 * in a subsequent step.
+	 */
+	local_save_flags(flags);
+	local_irq_enable();
+
 	rtlpriv->intf_ops->disable_aspm(hw);
 	rtstatus =3D _rtl92ce_init_mac(hw);
 	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Init MAC failed\n");
 		err =3D 1;
-		return err;
+		goto exit;
 	}
=20
 	err =3D rtl92c_download_fw(hw);
@@ -952,7 +964,7 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 			 "Failed to download FW. Init HW without FW now..\n");
 		err =3D 1;
-		return err;
+		goto exit;
 	}
=20
 	rtlhal->last_hmeboxnum =3D 0;
@@ -1032,6 +1044,8 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "under 1.5V\n");
 	}
 	rtl92c_dm_init(hw);
+exit:
+	local_irq_restore(flags);
 	rtlpci->being_init_adapter =3D false;
 	return err;
 }
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTAo+ZAAoJEJctW/TcYTgGSY8P/1P8VeyEeBYHzfZzpoABf3IS
kH2WPMdl0Q7tz53ZsvqVfhhxuuRE2Cqt6z3FkH6Qh4315VEdSlTK0/m94HQ4a7E4
5lTKHiHaNVffioUsGt+zFfFk+TJkhBLCLNsaIJFhCuu+mzjE6Y1qu05es6VxOkvK
eqXF6le5QIW86zwHxw+19ieIbsVgUljRSNSVNSDSjq96LGl0M+n6lU8iSb+OZ2X9
hDETQa56h7rm26FQ0YsQosKXkJ5+datrxEFeJ4TtoRrU+Zj5l1jOG9iEXl62abp+
wXY3x9hwnCP0xESDQXPcD8jcjIUBR1OyW2XK1ViBtCNWl/+aoFbWmkMM5UCJhcsX
KmLmsQN/2so6dTFI4OlQ6r7M0FCOIpgv1oDx8d3kE/bshA1TOsZ94J1E6MZ479LK
6MUhD7fst34Tf9bnGDcAxBrdCR15bAixQgZbqLda9PXJLo89Q1uN8ocMwDUmhy9G
hiVzhQ2zbNGqCsb1LSs4PApMUhIrfuP0kSSPHYcurDB2aqIKesPHcwCDkQhbpQr8
YrwZMVDQ285fMwNIHSpEK+Mhg4Z0rJxPl+ipblYSm/0sPsHJVad0rcopHgvEdGSh
DTFtM4S6Y3HBfUhKmiP3nVHZa7oAGKiufhdE6p9UFPu+vV2YBZpnQCGF+SlZWw0L
h1BLcI0RXDVnU2msJul5
=+E8f
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--
