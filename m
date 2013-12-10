From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2 07/16] wl1251: implement multicast address filtering
Date: Tue, 10 Dec 2013 10:39:05 +0100
Message-ID: <20131210093905.GG22756@amd.pavel.ucw.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-8-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, sre@ring0.de, joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>,
	David Gnedt <david.gnedt@davizone.at>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:44797 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372Ab3LJJjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 04:39:07 -0500
Content-Disposition: inline
In-Reply-To: <1386494714-21070-8-git-send-email-pali.rohar@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun 2013-12-08 10:25:05, Pali Roh=E1r wrote:
> From: David Gnedt <david.gnedt@davizone.at>
>=20
> Port multicast address filtering from wl1271 driver.
> It sets up the hardware multicast address filter in configure_filter(=
) with
> addresses supplied through prepare_multicast().
>=20
> Signed-off-by: David Gnedt <david.gnedt@davizone.at>
> Signed-off-by: Pali Roh=E1r <pali.rohar@gmail.com>

Reviewed-by: Pavel Machek <pavel@ucw.cz>

Thanks,
								Pavel
> ---
>  drivers/net/wireless/ti/wl1251/acx.c    |    9 ++---
>  drivers/net/wireless/ti/wl1251/acx.h    |    9 ++---
>  drivers/net/wireless/ti/wl1251/init.c   |    2 +-
>  drivers/net/wireless/ti/wl1251/main.c   |   57 +++++++++++++++++++++=
++++++++--
>  drivers/net/wireless/ti/wl1251/wl1251.h |    1 +
>  5 files changed, 67 insertions(+), 11 deletions(-)
>=20
> diff --git a/drivers/net/wireless/ti/wl1251/acx.c b/drivers/net/wirel=
ess/ti/wl1251/acx.c
> index 1ec98e9..f772e62 100644
> --- a/drivers/net/wireless/ti/wl1251/acx.c
> +++ b/drivers/net/wireless/ti/wl1251/acx.c
> @@ -408,7 +408,8 @@ out:
>  	return ret;
>  }
> =20
> -int wl1251_acx_group_address_tbl(struct wl1251 *wl)
> +int wl1251_acx_group_address_tbl(struct wl1251 *wl, bool enable,
> +				 void *mc_list, u32 mc_list_len)
>  {
>  	struct acx_dot11_grp_addr_tbl *acx;
>  	int ret;
> @@ -422,9 +423,9 @@ int wl1251_acx_group_address_tbl(struct wl1251 *w=
l)
>  	}
> =20
>  	/* MAC filtering */
> -	acx->enabled =3D 0;
> -	acx->num_groups =3D 0;
> -	memset(acx->mac_table, 0, ADDRESS_GROUP_MAX_LEN);
> +	acx->enabled =3D enable;
> +	acx->num_groups =3D mc_list_len;
> +	memcpy(acx->mac_table, mc_list, mc_list_len * ETH_ALEN);
> =20
>  	ret =3D wl1251_cmd_configure(wl, DOT11_GROUP_ADDRESS_TBL,
>  				   acx, sizeof(*acx));
> diff --git a/drivers/net/wireless/ti/wl1251/acx.h b/drivers/net/wirel=
ess/ti/wl1251/acx.h
> index bea2e67..820573c 100644
> --- a/drivers/net/wireless/ti/wl1251/acx.h
> +++ b/drivers/net/wireless/ti/wl1251/acx.h
> @@ -350,8 +350,8 @@ struct acx_slot {
>  } __packed;
> =20
> =20
> -#define ADDRESS_GROUP_MAX	(8)
> -#define ADDRESS_GROUP_MAX_LEN	(ETH_ALEN * ADDRESS_GROUP_MAX)
> +#define ACX_MC_ADDRESS_GROUP_MAX	(8)
> +#define ACX_MC_ADDRESS_GROUP_MAX_LEN	(ETH_ALEN * ACX_MC_ADDRESS_GROU=
P_MAX)
> =20
>  struct acx_dot11_grp_addr_tbl {
>  	struct acx_header header;
> @@ -359,7 +359,7 @@ struct acx_dot11_grp_addr_tbl {
>  	u8 enabled;
>  	u8 num_groups;
>  	u8 pad[2];
> -	u8 mac_table[ADDRESS_GROUP_MAX_LEN];
> +	u8 mac_table[ACX_MC_ADDRESS_GROUP_MAX_LEN];
>  } __packed;
> =20
> =20
> @@ -1464,7 +1464,8 @@ int wl1251_acx_rx_msdu_life_time(struct wl1251 =
*wl, u32 life_time);
>  int wl1251_acx_rx_config(struct wl1251 *wl, u32 config, u32 filter);
>  int wl1251_acx_pd_threshold(struct wl1251 *wl);
>  int wl1251_acx_slot(struct wl1251 *wl, enum acx_slot_type slot_time)=
;
> -int wl1251_acx_group_address_tbl(struct wl1251 *wl);
> +int wl1251_acx_group_address_tbl(struct wl1251 *wl, bool enable,
> +				 void *mc_list, u32 mc_list_len);
>  int wl1251_acx_service_period_timeout(struct wl1251 *wl);
>  int wl1251_acx_rts_threshold(struct wl1251 *wl, u16 rts_threshold);
>  int wl1251_acx_beacon_filter_opt(struct wl1251 *wl, bool enable_filt=
er);
> diff --git a/drivers/net/wireless/ti/wl1251/init.c b/drivers/net/wire=
less/ti/wl1251/init.c
> index 92de289..f8a2ea9 100644
> --- a/drivers/net/wireless/ti/wl1251/init.c
> +++ b/drivers/net/wireless/ti/wl1251/init.c
> @@ -127,7 +127,7 @@ int wl1251_hw_init_phy_config(struct wl1251 *wl)
>  	if (ret < 0)
>  		return ret;
> =20
> -	ret =3D wl1251_acx_group_address_tbl(wl);
> +	ret =3D wl1251_acx_group_address_tbl(wl, true, NULL, 0);
>  	if (ret < 0)
>  		return ret;
> =20
> diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wire=
less/ti/wl1251/main.c
> index 39a6105..ee318c8 100644
> --- a/drivers/net/wireless/ti/wl1251/main.c
> +++ b/drivers/net/wireless/ti/wl1251/main.c
> @@ -29,6 +29,7 @@
>  #include <linux/vmalloc.h>
>  #include <linux/platform_device.h>
>  #include <linux/slab.h>
> +#include <linux/netdevice.h>
> =20
>  #include "wl1251.h"
>  #include "wl12xx_80211.h"
> @@ -678,6 +679,44 @@ out:
>  	return ret;
>  }
> =20
> +struct wl1251_filter_params {
> +	bool enabled;
> +	int mc_list_length;
> +	u8 mc_list[ACX_MC_ADDRESS_GROUP_MAX][ETH_ALEN];
> +};
> +
> +static u64 wl1251_op_prepare_multicast(struct ieee80211_hw *hw,
> +				       struct netdev_hw_addr_list *mc_list)
> +{
> +	struct wl1251_filter_params *fp;
> +	struct netdev_hw_addr *ha;
> +	struct wl1251 *wl =3D hw->priv;
> +
> +	if (unlikely(wl->state =3D=3D WL1251_STATE_OFF))
> +		return 0;
> +
> +	fp =3D kzalloc(sizeof(*fp), GFP_ATOMIC);
> +	if (!fp) {
> +		wl1251_error("Out of memory setting filters.");
> +		return 0;
> +	}
> +
> +	/* update multicast filtering parameters */
> +	fp->mc_list_length =3D 0;
> +	if (netdev_hw_addr_list_count(mc_list) > ACX_MC_ADDRESS_GROUP_MAX) =
{
> +		fp->enabled =3D false;
> +	} else {
> +		fp->enabled =3D true;
> +		netdev_hw_addr_list_for_each(ha, mc_list) {
> +			memcpy(fp->mc_list[fp->mc_list_length],
> +					ha->addr, ETH_ALEN);
> +			fp->mc_list_length++;
> +		}
> +	}
> +
> +	return (u64)(unsigned long)fp;
> +}
> +
>  #define WL1251_SUPPORTED_FILTERS (FIF_PROMISC_IN_BSS | \
>  				  FIF_ALLMULTI | \
>  				  FIF_FCSFAIL | \
> @@ -688,8 +727,9 @@ out:
> =20
>  static void wl1251_op_configure_filter(struct ieee80211_hw *hw,
>  				       unsigned int changed,
> -				       unsigned int *total,u64 multicast)
> +				       unsigned int *total, u64 multicast)
>  {
> +	struct wl1251_filter_params *fp =3D (void *)(unsigned long)multicas=
t;
>  	struct wl1251 *wl =3D hw->priv;
>  	int ret;
> =20
> @@ -698,9 +738,11 @@ static void wl1251_op_configure_filter(struct ie=
ee80211_hw *hw,
>  	*total &=3D WL1251_SUPPORTED_FILTERS;
>  	changed &=3D WL1251_SUPPORTED_FILTERS;
> =20
> -	if (changed =3D=3D 0)
> +	if (changed =3D=3D 0) {
>  		/* no filters which we support changed */
> +		kfree(fp);
>  		return;
> +	}
> =20
>  	mutex_lock(&wl->mutex);
> =20
> @@ -737,6 +779,15 @@ static void wl1251_op_configure_filter(struct ie=
ee80211_hw *hw,
>  	if (ret < 0)
>  		goto out;
> =20
> +	if (*total & FIF_ALLMULTI || *total & FIF_PROMISC_IN_BSS)
> +		ret =3D wl1251_acx_group_address_tbl(wl, false, NULL, 0);
> +	else if (fp)
> +		ret =3D wl1251_acx_group_address_tbl(wl, fp->enabled,
> +						   fp->mc_list,
> +						   fp->mc_list_length);
> +	if (ret < 0)
> +		goto out;
> +
>  	/* send filters to firmware */
>  	wl1251_acx_rx_config(wl, wl->rx_config, wl->rx_filter);
> =20
> @@ -744,6 +795,7 @@ static void wl1251_op_configure_filter(struct iee=
e80211_hw *hw,
> =20
>  out:
>  	mutex_unlock(&wl->mutex);
> +	kfree(fp);
>  }
> =20
>  /* HW encryption */
> @@ -1283,6 +1335,7 @@ static const struct ieee80211_ops wl1251_ops =3D=
 {
>  	.add_interface =3D wl1251_op_add_interface,
>  	.remove_interface =3D wl1251_op_remove_interface,
>  	.config =3D wl1251_op_config,
> +	.prepare_multicast =3D wl1251_op_prepare_multicast,
>  	.configure_filter =3D wl1251_op_configure_filter,
>  	.tx =3D wl1251_op_tx,
>  	.set_key =3D wl1251_op_set_key,
> diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h b/drivers/net/wi=
reless/ti/wl1251/wl1251.h
> index 45df03a..93c18d2 100644
> --- a/drivers/net/wireless/ti/wl1251/wl1251.h
> +++ b/drivers/net/wireless/ti/wl1251/wl1251.h
> @@ -93,6 +93,7 @@ enum {
>  	} while (0)
> =20
>  #define WL1251_DEFAULT_RX_CONFIG (CFG_UNI_FILTER_EN |	\
> +				  CFG_MC_FILTER_EN |	\
>  				  CFG_BSSID_FILTER_EN)
> =20
>  #define WL1251_DEFAULT_RX_FILTER (CFG_RX_PRSP_EN |  \

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html
