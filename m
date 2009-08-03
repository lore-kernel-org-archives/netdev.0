From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-08-03
Date: Mon, 3 Aug 2009 16:59:54 -0400
Message-ID: <20090803205954.GE11441@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51610 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232AbZHCVBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 17:01:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another round of fixes intended for 2.6.31.  The one from
Reinette fixes an rfkill-related bug described in bugzilla 13742.  The =
one
from Luis has a lengthy changelog, but boils down to correcting some
regulatory enforcement issues that would prevent some devices from
working in some localities.  The rest are simple and obvious.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit eb4ad826419ab5b1260bc1625249114767d3=
6bea:
  Yevgeny Petrilin (1):
        mlx4_en: Fix double pci unmapping.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it master

Johannes Berg (1):
      cfg80211: add two missing NULL pointer checks

Julia Lawall (2):
      drivers/net/wireless/iwlwifi: introduce missing kfree
      drivers/net/wireless: introduce missing kfree

Luis R. Rodriguez (1):
      cfg80211: fix regression on beacon world roaming feature

Patrick Simmons (1):
      zd1211rw: fix unaligned access in zd_mac_rx

Reinette Chatre (1):
      iwlagn: do not send key clear commands when rfkill enabled

Roel Kluin (1):
      libertas: Read buffer overflow

 drivers/net/wireless/iwlwifi/iwl-core.c      |    3 +++
 drivers/net/wireless/iwlwifi/iwl-debugfs.c   |   12 ++++++------
 drivers/net/wireless/iwlwifi/iwl-sta.c       |   12 ++++++++++++
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |    3 +++
 drivers/net/wireless/iwmc3200wifi/commands.c |    1 +
 drivers/net/wireless/libertas/11d.c          |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c       |    2 +-
 include/net/cfg80211.h                       |    5 +++++
 net/wireless/reg.c                           |    9 +++++----
 net/wireless/reg.h                           |    3 ++-
 net/wireless/scan.c                          |    4 +++-
 11 files changed, 42 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wire=
less/iwlwifi/iwl-core.c
index 6ab0716..18b135f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -1332,6 +1332,9 @@ int iwl_setup_mac(struct iwl_priv *priv)
=20
 	hw->wiphy->custom_regulatory =3D true;
=20
+	/* Firmware does not support this */
+	hw->wiphy->disable_beacon_hints =3D true;
+
 	hw->wiphy->max_scan_ssids =3D PROBE_OPTION_MAX;
 	/* we create the 802.11 header and a zero-length SSID element */
 	hw->wiphy->max_scan_ie_len =3D IWL_MAX_PROBE_REQUEST - 24 - 2;
diff --git a/drivers/net/wireless/iwlwifi/iwl-debugfs.c b/drivers/net/w=
ireless/iwlwifi/iwl-debugfs.c
index 11e08c0..ca00cc8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debugfs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
@@ -308,18 +308,18 @@ static ssize_t iwl_dbgfs_nvm_read(struct file *fi=
le,
 		return -ENODATA;
 	}
=20
+	ptr =3D priv->eeprom;
+	if (!ptr) {
+		IWL_ERR(priv, "Invalid EEPROM/OTP memory\n");
+		return -ENOMEM;
+	}
+
 	/* 4 characters for byte 0xYY */
 	buf =3D kzalloc(buf_size, GFP_KERNEL);
 	if (!buf) {
 		IWL_ERR(priv, "Can not allocate Buffer\n");
 		return -ENOMEM;
 	}
-
-	ptr =3D priv->eeprom;
-	if (!ptr) {
-		IWL_ERR(priv, "Invalid EEPROM/OTP memory\n");
-		return -ENOMEM;
-	}
 	pos +=3D scnprintf(buf + pos, buf_size - pos, "NVM Type: %s\n",
 			(priv->nvm_device_type =3D=3D NVM_DEVICE_TYPE_OTP)
 			? "OTP" : "EEPROM");
diff --git a/drivers/net/wireless/iwlwifi/iwl-sta.c b/drivers/net/wirel=
ess/iwlwifi/iwl-sta.c
index 2addf73..ffd5c61 100644
--- a/drivers/net/wireless/iwlwifi/iwl-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-sta.c
@@ -566,6 +566,8 @@ int iwl_remove_default_wep_key(struct iwl_priv *pri=
v,
 	unsigned long flags;
=20
 	spin_lock_irqsave(&priv->sta_lock, flags);
+	IWL_DEBUG_WEP(priv, "Removing default WEP key: idx=3D%d\n",
+		      keyconf->keyidx);
=20
 	if (!test_and_clear_bit(keyconf->keyidx, &priv->ucode_key_table))
 		IWL_ERR(priv, "index %d not used in uCode key table.\n",
@@ -573,6 +575,11 @@ int iwl_remove_default_wep_key(struct iwl_priv *pr=
iv,
=20
 	priv->default_wep_key--;
 	memset(&priv->wep_keys[keyconf->keyidx], 0, sizeof(priv->wep_keys[0])=
);
+	if (iwl_is_rfkill(priv)) {
+		IWL_DEBUG_WEP(priv, "Not sending REPLY_WEPKEY command due to RFKILL.=
\n");
+		spin_unlock_irqrestore(&priv->sta_lock, flags);
+		return 0;
+	}
 	ret =3D iwl_send_static_wepkey_cmd(priv, 1);
 	IWL_DEBUG_WEP(priv, "Remove default WEP key: idx=3D%d ret=3D%d\n",
 		      keyconf->keyidx, ret);
@@ -853,6 +860,11 @@ int iwl_remove_dynamic_key(struct iwl_priv *priv,
 	priv->stations[sta_id].sta.sta.modify_mask =3D STA_MODIFY_KEY_MASK;
 	priv->stations[sta_id].sta.mode =3D STA_CONTROL_MODIFY_MSK;
=20
+	if (iwl_is_rfkill(priv)) {
+		IWL_DEBUG_WEP(priv, "Not sending REPLY_ADD_STA command because RFKIL=
L enabled. \n");
+		spin_unlock_irqrestore(&priv->sta_lock, flags);
+		return 0;
+	}
 	ret =3D  iwl_send_add_sta(priv, &priv->stations[sta_id].sta, CMD_ASYN=
C);
 	spin_unlock_irqrestore(&priv->sta_lock, flags);
 	return ret;
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/=
wireless/iwlwifi/iwl3945-base.c
index 2f50ab6..5238433 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -3968,6 +3968,9 @@ static int iwl3945_setup_mac(struct iwl_priv *pri=
v)
=20
 	hw->wiphy->custom_regulatory =3D true;
=20
+	/* Firmware does not support this */
+	hw->wiphy->disable_beacon_hints =3D true;
+
 	hw->wiphy->max_scan_ssids =3D PROBE_OPTION_MAX_3945;
 	/* we create the 802.11 header and a zero-length SSID element */
 	hw->wiphy->max_scan_ie_len =3D IWL_MAX_PROBE_REQUEST - 24 - 2;
diff --git a/drivers/net/wireless/iwmc3200wifi/commands.c b/drivers/net=
/wireless/iwmc3200wifi/commands.c
index 834a7f5..e2334d1 100644
--- a/drivers/net/wireless/iwmc3200wifi/commands.c
+++ b/drivers/net/wireless/iwmc3200wifi/commands.c
@@ -220,6 +220,7 @@ int iwm_store_rxiq_calib_result(struct iwm_priv *iw=
m)
 	eeprom_rxiq =3D iwm_eeprom_access(iwm, IWM_EEPROM_CALIB_RXIQ);
 	if (IS_ERR(eeprom_rxiq)) {
 		IWM_ERR(iwm, "Couldn't access EEPROM RX IQ entry\n");
+		kfree(rxiq);
 		return PTR_ERR(eeprom_rxiq);
 	}
=20
diff --git a/drivers/net/wireless/libertas/11d.c b/drivers/net/wireless=
/libertas/11d.c
index 9a5408e..5c69681 100644
--- a/drivers/net/wireless/libertas/11d.c
+++ b/drivers/net/wireless/libertas/11d.c
@@ -47,7 +47,7 @@ static u8 lbs_region_2_code(u8 *region)
 {
 	u8 i;
=20
-	for (i =3D 0; region[i] && i < COUNTRY_CODE_LEN; i++)
+	for (i =3D 0; i < COUNTRY_CODE_LEN && region[i]; i++)
 		region[i] =3D toupper(region[i]);
=20
 	for (i =3D 0; i < ARRAY_SIZE(region_code_mapping); i++) {
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wirel=
ess/zd1211rw/zd_mac.c
index 40b07b9..3bd3c77 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -698,7 +698,7 @@ int zd_mac_rx(struct ieee80211_hw *hw, const u8 *bu=
ffer, unsigned int length)
 			&& !mac->pass_ctrl)
 		return 0;
=20
-	fc =3D *(__le16 *)buffer;
+	fc =3D get_unaligned((__le16*)buffer);
 	need_padding =3D ieee80211_is_data_qos(fc) ^ ieee80211_has_a4(fc);
=20
 	skb =3D dev_alloc_skb(length + (need_padding ? 2 : 0));
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 1a21895..d1892d6 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -979,6 +979,10 @@ struct cfg80211_ops {
  * 	channels at a later time. This can be used for devices which do no=
t
  * 	have calibration information gauranteed for frequencies or setting=
s
  * 	outside of its regulatory domain.
+ * @disable_beacon_hints: enable this if your driver needs to ensure t=
hat
+ *	passive scan flags and beaconing flags may not be lifted by cfg8021=
1
+ *	due to regulatory beacon hints. For more information on beacon
+ *	hints read the documenation for regulatory_hint_found_beacon()
  * @reg_notifier: the driver's regulatory notification callback
  * @regd: the driver's regulatory domain, if one was requested via
  * 	the regulatory_hint() API. This can be used by the driver
@@ -1004,6 +1008,7 @@ struct wiphy {
=20
 	bool custom_regulatory;
 	bool strict_regulatory;
+	bool disable_beacon_hints;
=20
 	enum cfg80211_signal_type signal_type;
=20
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 5e14371..75a406d 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -1089,17 +1089,18 @@ static void handle_reg_beacon(struct wiphy *wip=
hy,
=20
 	chan->beacon_found =3D true;
=20
+	if (wiphy->disable_beacon_hints)
+		return;
+
 	chan_before.center_freq =3D chan->center_freq;
 	chan_before.flags =3D chan->flags;
=20
-	if ((chan->flags & IEEE80211_CHAN_PASSIVE_SCAN) &&
-	    !(chan->orig_flags & IEEE80211_CHAN_PASSIVE_SCAN)) {
+	if (chan->flags & IEEE80211_CHAN_PASSIVE_SCAN) {
 		chan->flags &=3D ~IEEE80211_CHAN_PASSIVE_SCAN;
 		channel_changed =3D true;
 	}
=20
-	if ((chan->flags & IEEE80211_CHAN_NO_IBSS) &&
-	    !(chan->orig_flags & IEEE80211_CHAN_NO_IBSS)) {
+	if (chan->flags & IEEE80211_CHAN_NO_IBSS) {
 		chan->flags &=3D ~IEEE80211_CHAN_NO_IBSS;
 		channel_changed =3D true;
 	}
diff --git a/net/wireless/reg.h b/net/wireless/reg.h
index e37829a..4e167a8 100644
--- a/net/wireless/reg.h
+++ b/net/wireless/reg.h
@@ -30,7 +30,8 @@ int set_regdom(const struct ieee80211_regdomain *rd);
  * non-radar 5 GHz channels.
  *
  * Drivers do not need to call this, cfg80211 will do it for after a s=
can
- * on a newly found BSS.
+ * on a newly found BSS. If you cannot make use of this feature you ca=
n
+ * set the wiphy->disable_beacon_hints to true.
  */
 int regulatory_hint_found_beacon(struct wiphy *wiphy,
 					struct ieee80211_channel *beacon_chan,
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 9271118..7e595ce 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -118,7 +118,7 @@ static int cmp_ies(u8 num, u8 *ies1, size_t len1, u=
8 *ies2, size_t len2)
=20
 	if (!ie1 && !ie2)
 		return 0;
-	if (!ie1)
+	if (!ie1 || !ie2)
 		return -1;
=20
 	r =3D memcmp(ie1 + 2, ie2 + 2, min(ie1[1], ie2[1]));
@@ -171,6 +171,8 @@ static bool is_mesh(struct cfg80211_bss *a,
 	ie =3D find_ie(WLAN_EID_MESH_CONFIG,
 		     a->information_elements,
 		     a->len_information_elements);
+	if (!ie)
+		return false;
 	if (ie[1] !=3D IEEE80211_MESH_CONFIG_LEN)
 		return false;
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
			=A1Viva Honduras Libre!
