From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH v2] wl1251: add sysfs interface for bluetooth coexistence mode configuration
Date: Sat, 9 Jan 2016 21:33:26 +0100
Message-ID: <201601092133.26350@pali>
References: <1451130310-16666-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1578711.KrSxuBiPDC";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	David Gnedt <david.gnedt@davizone.at>,
	Sebastian Reichel <sre@kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451130310-16666-1-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1578711.KrSxuBiPDC
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Saturday 26 December 2015 12:45:10 Pali Roh=C3=A1r wrote:
> Port the bt_coex_mode sysfs interface from wl1251 driver version
> included in the Maemo Fremantle kernel to allow bt-coexistence mode
> configuration. This enables userspace applications to set one of the
> modes
> WL1251_BT_COEX_OFF, WL1251_BT_COEX_ENABLE and
> WL1251_BT_COEX_MONOAUDIO. The default mode is WL1251_BT_COEX_OFF.
> It should be noted that this driver always enabled bt-coexistence
> before and enabled bt-coexistence directly affects the receiving
> performance, rendering it unusable in some low-signal situations.
> Especially monitor mode is affected very badly with bt-coexistence
> enabled.
>=20
> Signed-off-by: David Gnedt <david.gnedt@davizone.at>
> Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
> ---
> I'm resending this patch for review again as after two years there is
> no nl80211 interface for bt coex and wl1251 on Nokia N900 needs it.
> Once there will be common interface for bt coex I can rewrite my
> patches, but I do not want to wait another 2 years...
>=20
> Changes:
> In v2 is sysfs node attached directly to wl1251 device instead of
> creating new platform device for sysfs node. So sysfs node is now
> available at: /sys/class/net/wlan0/device/bt_coex_mode
> ---

Hello! Can you review or comment this patch?

>  drivers/net/wireless/ti/wl1251/acx.c    |   43 ++++++++++++++--
>  drivers/net/wireless/ti/wl1251/acx.h    |    8 +--
>  drivers/net/wireless/ti/wl1251/init.c   |    6 +--
>  drivers/net/wireless/ti/wl1251/main.c   |   84
> +++++++++++++++++++++++++++++++
> drivers/net/wireless/ti/wl1251/wl1251.h |    8 +++
>  5 files changed, 137 insertions(+), 12 deletions(-)
>=20
> diff --git a/drivers/net/wireless/ti/wl1251/acx.c
> b/drivers/net/wireless/ti/wl1251/acx.c index d6fbdda..a119d77 100644
> --- a/drivers/net/wireless/ti/wl1251/acx.c
> +++ b/drivers/net/wireless/ti/wl1251/acx.c
> @@ -539,7 +539,7 @@ out:
>  	return ret;
>  }
>=20
> -int wl1251_acx_sg_enable(struct wl1251 *wl)
> +int wl1251_acx_sg_enable(struct wl1251 *wl, u8 mode)
>  {
>  	struct acx_bt_wlan_coex *pta;
>  	int ret;
> @@ -550,7 +550,7 @@ int wl1251_acx_sg_enable(struct wl1251 *wl)
>  	if (!pta)
>  		return -ENOMEM;
>=20
> -	pta->enable =3D SG_ENABLE;
> +	pta->enable =3D mode;
>=20
>  	ret =3D wl1251_cmd_configure(wl, ACX_SG_ENABLE, pta, sizeof(*pta));
>  	if (ret < 0) {
> @@ -563,7 +563,7 @@ out:
>  	return ret;
>  }
>=20
> -int wl1251_acx_sg_cfg(struct wl1251 *wl)
> +int wl1251_acx_sg_cfg(struct wl1251 *wl, u16 wake_up_beacon)
>  {
>  	struct acx_bt_wlan_coex_param *param;
>  	int ret;
> @@ -586,7 +586,7 @@ int wl1251_acx_sg_cfg(struct wl1251 *wl)
>  	param->wlan_cycle_fast =3D PTA_CYCLE_TIME_FAST_DEF;
>  	param->bt_anti_starvation_period =3D PTA_ANTI_STARVE_PERIOD_DEF;
>  	param->next_bt_lp_packet =3D PTA_TIMEOUT_NEXT_BT_LP_PACKET_DEF;
> -	param->wake_up_beacon =3D PTA_TIME_BEFORE_BEACON_DEF;
> +	param->wake_up_beacon =3D wake_up_beacon;
>  	param->hp_dm_max_guard_time =3D PTA_HPDM_MAX_TIME_DEF;
>  	param->next_wlan_packet =3D PTA_TIME_OUT_NEXT_WLAN_DEF;
>  	param->antenna_type =3D PTA_ANTENNA_TYPE_DEF;
> @@ -615,6 +615,41 @@ out:
>  	return ret;
>  }
>=20
> +int wl1251_acx_sg_configure(struct wl1251 *wl, bool force)
> +{
> +	int ret;
> +
> +	if (wl->state =3D=3D WL1251_STATE_OFF && !force)
> +		return 0;
> +
> +	switch (wl->bt_coex_mode) {
> +	case WL1251_BT_COEX_OFF:
> +		ret =3D wl1251_acx_sg_enable(wl, SG_DISABLE);
> +		if (ret)
> +			break;
> +		ret =3D wl1251_acx_sg_cfg(wl, 0);
> +		break;
> +	case WL1251_BT_COEX_ENABLE:
> +		ret =3D wl1251_acx_sg_enable(wl, SG_ENABLE);
> +		if (ret)
> +			break;
> +		ret =3D wl1251_acx_sg_cfg(wl, PTA_TIME_BEFORE_BEACON_DEF);
> +		break;
> +	case WL1251_BT_COEX_MONOAUDIO:
> +		ret =3D wl1251_acx_sg_enable(wl, SG_ENABLE);
> +		if (ret)
> +			break;
> +		ret =3D wl1251_acx_sg_cfg(wl, PTA_TIME_BEFORE_BEACON_MONO_AUDIO);
> +		break;
> +	default:
> +		wl1251_error("Invalid BT co-ex mode!");
> +		ret =3D -EOPNOTSUPP;
> +		break;
> +	}
> +
> +	return ret;
> +}
> +
>  int wl1251_acx_cca_threshold(struct wl1251 *wl)
>  {
>  	struct acx_energy_detection *detection;
> diff --git a/drivers/net/wireless/ti/wl1251/acx.h
> b/drivers/net/wireless/ti/wl1251/acx.h index 2bdec38..820573c 100644
> --- a/drivers/net/wireless/ti/wl1251/acx.h
> +++ b/drivers/net/wireless/ti/wl1251/acx.h
> @@ -558,7 +558,8 @@ struct acx_bt_wlan_coex {
>  #define PTA_ANTI_STARVE_PERIOD_DEF	  (500)
>  #define PTA_ANTI_STARVE_NUM_CYCLE_DEF	  (4)
>  #define PTA_ALLOW_PA_SD_DEF		  (1)
> -#define PTA_TIME_BEFORE_BEACON_DEF	  (6300)
> +#define PTA_TIME_BEFORE_BEACON_DEF	  (500)
> +#define PTA_TIME_BEFORE_BEACON_MONO_AUDIO (6300)
>  #define PTA_HPDM_MAX_TIME_DEF		  (1600)
>  #define PTA_TIME_OUT_NEXT_WLAN_DEF	  (2550)
>  #define PTA_AUTO_MODE_NO_CTS_DEF	  (0)
> @@ -1470,8 +1471,9 @@ int wl1251_acx_rts_threshold(struct wl1251 *wl,
> u16 rts_threshold); int wl1251_acx_beacon_filter_opt(struct wl1251
> *wl, bool enable_filter); int wl1251_acx_beacon_filter_table(struct
> wl1251 *wl);
>  int wl1251_acx_conn_monit_params(struct wl1251 *wl);
> -int wl1251_acx_sg_enable(struct wl1251 *wl);
> -int wl1251_acx_sg_cfg(struct wl1251 *wl);
> +int wl1251_acx_sg_enable(struct wl1251 *wl, u8 mode);
> +int wl1251_acx_sg_cfg(struct wl1251 *wl, u16 wake_up_beacon);
> +int wl1251_acx_sg_configure(struct wl1251 *wl, bool force);
>  int wl1251_acx_cca_threshold(struct wl1251 *wl);
>  int wl1251_acx_bcn_dtim_options(struct wl1251 *wl);
>  int wl1251_acx_aid(struct wl1251 *wl, u16 aid);
> diff --git a/drivers/net/wireless/ti/wl1251/init.c
> b/drivers/net/wireless/ti/wl1251/init.c index 1d799bf..f8a2ea9
> 100644
> --- a/drivers/net/wireless/ti/wl1251/init.c
> +++ b/drivers/net/wireless/ti/wl1251/init.c
> @@ -162,11 +162,7 @@ int wl1251_hw_init_pta(struct wl1251 *wl)
>  {
>  	int ret;
>=20
> -	ret =3D wl1251_acx_sg_enable(wl);
> -	if (ret < 0)
> -		return ret;
> -
> -	ret =3D wl1251_acx_sg_cfg(wl);
> +	ret =3D wl1251_acx_sg_configure(wl, true);
>  	if (ret < 0)
>  		return ret;
>=20
> diff --git a/drivers/net/wireless/ti/wl1251/main.c
> b/drivers/net/wireless/ti/wl1251/main.c index cd47779..8f53e43
> 100644
> --- a/drivers/net/wireless/ti/wl1251/main.c
> +++ b/drivers/net/wireless/ti/wl1251/main.c
> @@ -1383,6 +1383,77 @@ static const struct ieee80211_ops wl1251_ops =3D
> { .get_survey =3D wl1251_op_get_survey,
>  };
>=20
> +static ssize_t wl1251_sysfs_show_bt_coex_mode(struct device *dev,
> +					      struct device_attribute *attr,
> +					      char *buf)
> +{
> +	struct wl1251 *wl =3D dev_get_drvdata(dev);
> +	ssize_t len;
> +
> +	/* FIXME: what's the maximum length of buf? page size?*/
> +	len =3D 500;
> +
> +	mutex_lock(&wl->mutex);
> +	len =3D snprintf(buf, len, "%d\n\n%d - off\n%d - on\n%d -
> monoaudio\n", +		       wl->bt_coex_mode,
> +		       WL1251_BT_COEX_OFF,
> +		       WL1251_BT_COEX_ENABLE,
> +		       WL1251_BT_COEX_MONOAUDIO);
> +	mutex_unlock(&wl->mutex);
> +
> +	return len;
> +}
> +
> +static ssize_t wl1251_sysfs_store_bt_coex_mode(struct device *dev,
> +					       struct device_attribute *attr,
> +					       const char *buf, size_t count)
> +{
> +	struct wl1251 *wl =3D dev_get_drvdata(dev);
> +	unsigned long res;
> +	int ret;
> +
> +	ret =3D kstrtoul(buf, 10, &res);
> +
> +	if (ret < 0) {
> +		wl1251_warning("incorrect value written to bt_coex_mode");
> +		return count;
> +	}
> +
> +	mutex_lock(&wl->mutex);
> +
> +	if (res =3D=3D wl->bt_coex_mode)
> +		goto out;
> +
> +	switch (res) {
> +	case WL1251_BT_COEX_OFF:
> +	case WL1251_BT_COEX_ENABLE:
> +	case WL1251_BT_COEX_MONOAUDIO:
> +		wl->bt_coex_mode =3D res;
> +		break;
> +	default:
> +		wl1251_warning("incorrect value written to bt_coex_mode");
> +		goto out;
> +	}
> +
> +	if (wl->state =3D=3D WL1251_STATE_OFF)
> +		goto out;
> +
> +	ret =3D wl1251_ps_elp_wakeup(wl);
> +	if (ret < 0)
> +		goto out;
> +
> +	wl1251_acx_sg_configure(wl, false);
> +	wl1251_ps_elp_sleep(wl);
> +
> +out:
> +	mutex_unlock(&wl->mutex);
> +	return count;
> +}
> +
> +static DEVICE_ATTR(bt_coex_mode, S_IRUGO | S_IWUSR,
> +		   wl1251_sysfs_show_bt_coex_mode,
> +		   wl1251_sysfs_store_bt_coex_mode);
> +
>  static int wl1251_read_eeprom_byte(struct wl1251 *wl, off_t offset,
> u8 *data) {
>  	unsigned long timeout;
> @@ -1467,6 +1538,7 @@ static int wl1251_register_hw(struct wl1251
> *wl)
>=20
>  int wl1251_init_ieee80211(struct wl1251 *wl)
>  {
> +	struct device *dev =3D wiphy_dev(wl->hw->wiphy);
>  	int ret;
>=20
>  	/* The tx descriptor buffer and the TKIP space */
> @@ -1493,6 +1565,13 @@ int wl1251_init_ieee80211(struct wl1251 *wl)
>  	if (ret)
>  		goto out;
>=20
> +	/* Create sysfs file to control bt coex state */
> +	ret =3D device_create_file(dev, &dev_attr_bt_coex_mode);
> +	if (ret < 0) {
> +		wl1251_error("failed to create sysfs file bt_coex_mode");
> +		goto out;
> +	}
> +
>  	wl1251_debugfs_init(wl);
>  	wl1251_notice("initialized");
>=20
> @@ -1549,6 +1628,7 @@ struct ieee80211_hw *wl1251_alloc_hw(void)
>  	wl->beacon_int =3D WL1251_DEFAULT_BEACON_INT;
>  	wl->dtim_period =3D WL1251_DEFAULT_DTIM_PERIOD;
>  	wl->vif =3D NULL;
> +	wl->bt_coex_mode =3D WL1251_BT_COEX_OFF;
>=20
>  	for (i =3D 0; i < FW_TX_CMPLT_BLOCK_SIZE; i++)
>  		wl->tx_frames[i] =3D NULL;
> @@ -1584,6 +1664,10 @@ EXPORT_SYMBOL_GPL(wl1251_alloc_hw);
>=20
>  int wl1251_free_hw(struct wl1251 *wl)
>  {
> +	struct device *dev =3D wiphy_dev(wl->hw->wiphy);
> +
> +	device_remove_file(dev, &dev_attr_bt_coex_mode);
> +
>  	ieee80211_unregister_hw(wl->hw);
>=20
>  	wl1251_debugfs_exit(wl);
> diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h
> b/drivers/net/wireless/ti/wl1251/wl1251.h index 16dae52..b8b7ab7
> 100644
> --- a/drivers/net/wireless/ti/wl1251/wl1251.h
> +++ b/drivers/net/wireless/ti/wl1251/wl1251.h
> @@ -258,6 +258,12 @@ struct wl1251_debugfs {
>  	struct dentry *excessive_retries;
>  };
>=20
> +enum wl1251_bt_coex_mode {
> +	WL1251_BT_COEX_OFF,
> +	WL1251_BT_COEX_ENABLE,
> +	WL1251_BT_COEX_MONOAUDIO
> +};
> +
>  struct wl1251_if_operations {
>  	void (*read)(struct wl1251 *wl, int addr, void *buf, size_t len);
>  	void (*write)(struct wl1251 *wl, int addr, void *buf, size_t len);
> @@ -394,6 +400,8 @@ struct wl1251 {
>=20
>  	struct ieee80211_vif *vif;
>=20
> +	enum wl1251_bt_coex_mode bt_coex_mode;
> +
>  	u32 chip_id;
>  	char fw_ver[21];


=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1578711.KrSxuBiPDC
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlaRbpYACgkQi/DJPQPkQ1K4twCfZqC2/v9+fd6cnBpvAr62dcjj
KP8AniJ6YJod3r8lcOTLTW23TbAPnJFN
=ZVB5
-----END PGP SIGNATURE-----

--nextPart1578711.KrSxuBiPDC--
