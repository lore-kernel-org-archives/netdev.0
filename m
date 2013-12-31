From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH v2 06/16] wl1251: configure hardware en-/decryption for monitor mode
Date: Tue, 31 Dec 2013 10:31:49 +0100
Message-ID: <201312311031.53539@pali>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com> <1386494714-21070-7-git-send-email-pali.rohar@gmail.com> <20131210093518.GF22756@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2381312.4Q349YzYGQ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, sre@ring0.de, joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>,
	David Gnedt <david.gnedt@davizone.at>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:36309 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab3LaJb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 04:31:59 -0500
In-Reply-To: <20131210093518.GF22756@amd.pavel.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2381312.4Q349YzYGQ
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tuesday 10 December 2013 10:35:18 Pavel Machek wrote:
> Hi!
>=20
> > --- a/drivers/net/wireless/ti/wl1251/tx.c
> > +++ b/drivers/net/wireless/ti/wl1251/tx.c
> > @@ -287,6 +287,9 @@ static int wl1251_tx_frame(struct wl1251
> > *wl, struct sk_buff *skb)
> >=20
> >  	info =3D IEEE80211_SKB_CB(skb);
> >  =09
> >  	if (info->control.hw_key) {
> >=20
> > +		if (unlikely(wl->monitor_present))
> > +			return -1;
> > +
>=20
> This function seems to use 0/-errno convention. So probably
> "return -EINVAL"?
>=20
> With that fixed:
>=20
> Reviewed-by: Pavel Machek <pavel@ucw.cz>
>=20
> Thanks,
> 									Pavel

Here is new version with above fix:

=46rom: =3D?UTF-8?q?Pali=3D20Roh=3DC3=3DA1r?=3D <pali.rohar@gmail.com>
Subject: [PATCH v2 06/16] wl1251: configure hardware en-/decryption for mon=
itor mode
Date: Sun,  8 Dec 2013 10:25:04 +0100
MIME-Version: 1.0
Content-Type: text/plain;
  charset=3DUTF-8
Content-Transfer-Encoding: 8bit

=46rom: David Gnedt <david.gnedt@davizone.at>

Disable hardware encryption (DF_ENCRYPTION_DISABLE) and decryption
(DF_SNIFF_MODE_ENABLE) via wl1251_acx_feature_cfg while monitor interface is
present.

Signed-off-by: David Gnedt <david.gnedt@davizone.at>
Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
=2D--
 drivers/net/wireless/ti/wl1251/acx.c    |    6 +++---
 drivers/net/wireless/ti/wl1251/acx.h    |    2 +-
 drivers/net/wireless/ti/wl1251/init.c   |    2 +-
 drivers/net/wireless/ti/wl1251/main.c   |   34 ++++++++++++++++++++++++++-=
=2D---
 drivers/net/wireless/ti/wl1251/rx.c     |    2 +-
 drivers/net/wireless/ti/wl1251/tx.c     |    3 +++
 drivers/net/wireless/ti/wl1251/wl1251.h |    1 +
 7 files changed, 39 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/acx.c b/drivers/net/wireless/ti=
/wl1251/acx.c
index 5f4a552..1ec98e9 100644
=2D-- a/drivers/net/wireless/ti/wl1251/acx.c
+++ b/drivers/net/wireless/ti/wl1251/acx.c
@@ -209,7 +209,7 @@ out:
 	return ret;
 }
=20
=2Dint wl1251_acx_feature_cfg(struct wl1251 *wl)
+int wl1251_acx_feature_cfg(struct wl1251 *wl, u32 data_flow_options)
 {
 	struct acx_feature_config *feature;
 	int ret;
@@ -222,8 +222,8 @@ int wl1251_acx_feature_cfg(struct wl1251 *wl)
 		goto out;
 	}
=20
=2D	/* DF_ENCRYPTION_DISABLE and DF_SNIFF_MODE_ENABLE are disabled */
=2D	feature->data_flow_options =3D 0;
+	/* DF_ENCRYPTION_DISABLE and DF_SNIFF_MODE_ENABLE can be set */
+	feature->data_flow_options =3D data_flow_options;
 	feature->options =3D 0;
=20
 	ret =3D wl1251_cmd_configure(wl, ACX_FEATURE_CFG,
diff --git a/drivers/net/wireless/ti/wl1251/acx.h b/drivers/net/wireless/ti=
/wl1251/acx.h
index 4444cd0..bea2e67 100644
=2D-- a/drivers/net/wireless/ti/wl1251/acx.h
+++ b/drivers/net/wireless/ti/wl1251/acx.h
@@ -1455,7 +1455,7 @@ int wl1251_acx_wake_up_conditions(struct wl1251 *wl, =
u8 wake_up_event,
 int wl1251_acx_sleep_auth(struct wl1251 *wl, u8 sleep_auth);
 int wl1251_acx_fw_version(struct wl1251 *wl, char *buf, size_t len);
 int wl1251_acx_tx_power(struct wl1251 *wl, int power);
=2Dint wl1251_acx_feature_cfg(struct wl1251 *wl);
+int wl1251_acx_feature_cfg(struct wl1251 *wl, u32 data_flow_options);
 int wl1251_acx_mem_map(struct wl1251 *wl,
 		       struct acx_header *mem_map, size_t len);
 int wl1251_acx_data_path_params(struct wl1251 *wl,
diff --git a/drivers/net/wireless/ti/wl1251/init.c b/drivers/net/wireless/t=
i/wl1251/init.c
index 424ce01..92de289 100644
=2D-- a/drivers/net/wireless/ti/wl1251/init.c
+++ b/drivers/net/wireless/ti/wl1251/init.c
@@ -33,7 +33,7 @@ int wl1251_hw_init_hwenc_config(struct wl1251 *wl)
 {
 	int ret;
=20
=2D	ret =3D wl1251_acx_feature_cfg(wl);
+	ret =3D wl1251_acx_feature_cfg(wl, 0);
 	if (ret < 0) {
 		wl1251_warning("couldn't set feature config");
 		return ret;
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/t=
i/wl1251/main.c
index 0e27f1f..39a6105 100644
=2D-- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -485,6 +485,7 @@ static void wl1251_op_stop(struct ieee80211_hw *hw)
 	wl->power_level =3D WL1251_DEFAULT_POWER_LEVEL;
 	wl->rssi_thold =3D 0;
 	wl->channel =3D WL1251_DEFAULT_CHANNEL;
+	wl->monitor_present =3D false;
=20
 	wl1251_debugfs_reset(wl);
=20
@@ -577,8 +578,10 @@ static int wl1251_op_config(struct ieee80211_hw *hw, u=
32 changed)
 	channel =3D ieee80211_frequency_to_channel(
 			conf->chandef.chan->center_freq);
=20
=2D	wl1251_debug(DEBUG_MAC80211, "mac80211 config ch %d psm %s power %d",
+	wl1251_debug(DEBUG_MAC80211,
+		     "mac80211 config ch %d monitor %s psm %s power %d",
 		     channel,
+		     conf->flags & IEEE80211_CONF_MONITOR ? "on" : "off",
 		     conf->flags & IEEE80211_CONF_PS ? "on" : "off",
 		     conf->power_level);
=20
@@ -588,6 +591,22 @@ static int wl1251_op_config(struct ieee80211_hw *hw, u=
32 changed)
 	if (ret < 0)
 		goto out;
=20
+	if (changed & IEEE80211_CONF_CHANGE_MONITOR) {
+		u32 mode;
+
+		if (conf->flags & IEEE80211_CONF_MONITOR) {
+			wl->monitor_present =3D true;
+			mode =3D DF_SNIFF_MODE_ENABLE | DF_ENCRYPTION_DISABLE;
+		} else {
+			wl->monitor_present =3D false;
+			mode =3D 0;
+		}
+
+		ret =3D wl1251_acx_feature_cfg(wl, mode);
+		if (ret < 0)
+			goto out_sleep;
+	}
+
 	if (channel !=3D wl->channel) {
 		wl->channel =3D channel;
=20
@@ -804,12 +823,12 @@ static int wl1251_op_set_key(struct ieee80211_hw *hw,=
 enum set_key_cmd cmd,
=20
 	mutex_lock(&wl->mutex);
=20
=2D	ret =3D wl1251_ps_elp_wakeup(wl);
=2D	if (ret < 0)
=2D		goto out_unlock;
=2D
 	switch (cmd) {
 	case SET_KEY:
+		if (wl->monitor_present) {
+			ret =3D -EOPNOTSUPP;
+			goto out_unlock;
+		}
 		wl_cmd->key_action =3D KEY_ADD_OR_REPLACE;
 		break;
 	case DISABLE_KEY:
@@ -820,6 +839,10 @@ static int wl1251_op_set_key(struct ieee80211_hw *hw, =
enum set_key_cmd cmd,
 		break;
 	}
=20
+	ret =3D wl1251_ps_elp_wakeup(wl);
+	if (ret < 0)
+		goto out_unlock;
+
 	ret =3D wl1251_set_key_type(wl, wl_cmd, cmd, key, addr);
 	if (ret < 0) {
 		wl1251_error("Set KEY type failed");
@@ -1520,6 +1543,7 @@ struct ieee80211_hw *wl1251_alloc_hw(void)
=20
 	INIT_DELAYED_WORK(&wl->elp_work, wl1251_elp_work);
 	wl->channel =3D WL1251_DEFAULT_CHANNEL;
+	wl->monitor_present =3D false;
 	wl->scanning =3D false;
 	wl->default_key =3D 0;
 	wl->listen_int =3D 1;
diff --git a/drivers/net/wireless/ti/wl1251/rx.c b/drivers/net/wireless/ti/=
wl1251/rx.c
index 23289d4..123c4bb 100644
=2D-- a/drivers/net/wireless/ti/wl1251/rx.c
+++ b/drivers/net/wireless/ti/wl1251/rx.c
@@ -83,7 +83,7 @@ static void wl1251_rx_status(struct wl1251 *wl,
=20
 	status->flag |=3D RX_FLAG_MACTIME_START;
=20
=2D	if (desc->flags & RX_DESC_ENCRYPTION_MASK) {
+	if (!wl->monitor_present && (desc->flags & RX_DESC_ENCRYPTION_MASK)) {
 		status->flag |=3D RX_FLAG_IV_STRIPPED | RX_FLAG_MMIC_STRIPPED;
=20
 		if (likely(!(desc->flags & RX_DESC_DECRYPT_FAIL)))
diff --git a/drivers/net/wireless/ti/wl1251/tx.c b/drivers/net/wireless/ti/=
wl1251/tx.c
index 28121c5..3cc82fd 100644
=2D-- a/drivers/net/wireless/ti/wl1251/tx.c
+++ b/drivers/net/wireless/ti/wl1251/tx.c
@@ -287,6 +287,9 @@ static int wl1251_tx_frame(struct wl1251 *wl, struct sk=
_buff *skb)
 	info =3D IEEE80211_SKB_CB(skb);
=20
 	if (info->control.hw_key) {
+		if (unlikely(wl->monitor_present))
+			return -EINVAL;
+
 		idx =3D info->control.hw_key->hw_key_idx;
 		if (unlikely(wl->default_key !=3D idx)) {
 			ret =3D wl1251_acx_default_key(wl, idx);
diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h b/drivers/net/wireless=
/ti/wl1251/wl1251.h
index de9e418..45df03a 100644
=2D-- a/drivers/net/wireless/ti/wl1251/wl1251.h
+++ b/drivers/net/wireless/ti/wl1251/wl1251.h
@@ -309,6 +309,7 @@ struct wl1251 {
 	u8 bss_type;
 	u8 listen_int;
 	int channel;
+	bool monitor_present;
=20
 	void *target_mem_map;
 	struct acx_data_path_params_resp *data_path;
=2D-=20
1.7.9.5

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com


--nextPart2381312.4Q349YzYGQ
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlLCjwYACgkQi/DJPQPkQ1KEsACgpLdRFqjfXs5flZgnFK0ODHSN
wDUAn35Wrz3FEWa/+ElWPiJPU5LXlAf5
=+rRo
-----END PGP SIGNATURE-----

--nextPart2381312.4Q349YzYGQ--
