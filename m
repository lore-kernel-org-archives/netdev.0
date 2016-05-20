From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH 4.8 2/2] brcmfmac: support get_channel cfg80211 callback
Date: Fri, 20 May 2016 09:42:37 +0200
Message-ID: <48f4f8c9-b4a3-66f9-b4a5-640778ac8e79@broadcom.com>
References: <1463655770-22467-1-git-send-email-zajec5@gmail.com>
 <1463655770-22467-2-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<linux-wireless@vger.kernel.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list@broadcom.com>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463655770-22467-2-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19-5-2016 13:02, Rafa=C5=82 Mi=C5=82ecki wrote:
> This is important for brcmfmac as the firmware may pick different
> channel than requested. This has been tested with BCM4366B1 (in D-Lin=
k
> DIR-885L).

Can you elaborate? Is this for AP or STA mode?

> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> ---
>  .../broadcom/brcm80211/brcmfmac/cfg80211.c         | 59 ++++++++++++=
++++++++++
>  1 file changed, 59 insertions(+)
>=20
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg8021=
1.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
> index 597495d..4fb9e3a 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
> @@ -4892,6 +4892,64 @@ exit:
>  	return err;
>  }
> =20
> +static int brcmf_cfg80211_get_channel(struct wiphy *wiphy,
> +				      struct wireless_dev *wdev,
> +				      struct cfg80211_chan_def *chandef)
> +{
> +	struct brcmf_cfg80211_info *cfg =3D wiphy_to_cfg(wiphy);
> +	struct net_device *ndev =3D wdev->netdev;
> +	struct brcmf_if *ifp =3D netdev_priv(ndev);

Can this operation be done on a P2P_DEVICE interface, ie. wdev->netdev
=3D=3D NULL?

> +	struct brcmu_chan ch;
> +	enum nl80211_band band =3D 0;
> +	enum nl80211_chan_width width =3D 0;
> +	u32 chanspec;
> +	int freq, err;
> +
> +	err =3D brcmf_fil_iovar_int_get(ifp, "chanspec", &chanspec);
> +	if (err) {
> +		brcmf_err("chanspec failed (%d)\n", err);
> +		return err;
> +	}
> +
> +	ch.chspec =3D chanspec;
> +	cfg->d11inf.decchspec(&ch);
> +
> +	switch (ch.band) {
> +	case BRCMU_CHAN_BAND_2G:
> +		band =3D NL80211_BAND_2GHZ;
> +		break;
> +	case BRCMU_CHAN_BAND_5G:
> +		band =3D NL80211_BAND_5GHZ;
> +		break;
> +	}
> +
> +	switch (ch.bw) {
> +	case BRCMU_CHAN_BW_80:
> +		width =3D NL80211_CHAN_WIDTH_80;
> +		break;
> +	case BRCMU_CHAN_BW_40:
> +		width =3D NL80211_CHAN_WIDTH_40;
> +		break;
> +	case BRCMU_CHAN_BW_20:
> +		width =3D NL80211_CHAN_WIDTH_20;
> +		break;
> +	case BRCMU_CHAN_BW_80P80:
> +		width =3D NL80211_CHAN_WIDTH_80P80;
> +		break;

Not much sense to support this given that center_freq2 is set to zero b=
elow.

Regards,
Arend

> +	case BRCMU_CHAN_BW_160:
> +		width =3D NL80211_CHAN_WIDTH_160;
> +		break;
> +	}
> +
> +	freq =3D ieee80211_channel_to_frequency(ch.control_ch_num, band);
> +	chandef->chan =3D ieee80211_get_channel(wiphy, freq);
> +	chandef->width =3D width;
> +	chandef->center_freq1 =3D ieee80211_channel_to_frequency(ch.chnum, =
band);
> +	chandef->center_freq2 =3D 0;
> +
> +	return 0;
> +}
> +
>  static int brcmf_cfg80211_crit_proto_start(struct wiphy *wiphy,
>  					   struct wireless_dev *wdev,
>  					   enum nl80211_crit_proto_id proto,
> @@ -5054,6 +5112,7 @@ static struct cfg80211_ops brcmf_cfg80211_ops =3D=
 {
>  	.mgmt_tx =3D brcmf_cfg80211_mgmt_tx,
>  	.remain_on_channel =3D brcmf_p2p_remain_on_channel,
>  	.cancel_remain_on_channel =3D brcmf_cfg80211_cancel_remain_on_chann=
el,
> +	.get_channel =3D brcmf_cfg80211_get_channel,
>  	.start_p2p_device =3D brcmf_p2p_start_device,
>  	.stop_p2p_device =3D brcmf_p2p_stop_device,
>  	.crit_proto_start =3D brcmf_cfg80211_crit_proto_start,
>=20
