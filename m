From: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: rework function picking free BSS index
Date: Thu, 9 Jun 2016 21:16:47 +0200
Message-ID: <5759C09F.7020704@broadcom.com>
References: <1464219876-13776-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"open list:NETWORKING DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1464219876-13776-1-git-send-email-zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 26-05-16 01:44, Rafa=C5=82 Mi=C5=82ecki wrote:
> The old implementation was overcomplicated and slightly bugged in som=
e
> corner cases.
>=20
> Consider following state of BSS-es (limited to 6 for simplification):
> drvr->iflist[0]: { bsscfgidx:0, ndev->name:wlan1, }
> drvr->iflist[1]:  (null)
> drvr->iflist[2]: { bsscfgidx:2, ndev->name:wlan1-1, }
> drvr->iflist[3]: { bsscfgidx:3, ndev->name:wlan1-2, }
> drvr->iflist[4]:  (null)
> drvr->iflist[5]:  (null)
> In such case the next AP interface should bsscfgidx 4 (we don't use 1=
 as
> it's reserved for P2P).
>=20
> With old code the loop iterations were following:
> [ifidx =3D 0] [bsscfgidx =3D 2] [highest =3D 2]
> [ifidx =3D 1] [bsscfgidx =3D 2] [highest =3D 2] available =3D true
> [ifidx =3D 2] [bsscfgidx =3D 2] [highest =3D 2] bsscfgidx =3D highest=
 + 1
> [ifidx =3D 3] [bsscfgidx =3D 3] [highest =3D 2] bsscfgidx =3D highest=
 + 1
> [ifidx =3D 4] [bsscfgidx =3D 3] [highest =3D 2] available =3D true
> [ifidx =3D 5] [bsscfgidx =3D 3] [highest =3D 2] available =3D true
> There were 2 obvious problems:
> 1) Having empty BSS at index 1 was resulting in available being alway=
s
>    set to true, even if we would run out of BSS-es.
> 2) Calculated bsscfgidx was invalid (3 instead of 4) resulting in dri=
ver
>    not being able to create the 4th AP interface.
>=20
> New code is simpler, placed in file where it's really used, handles
> running out of free BSS-es and allows using 4 interfaces at the same
> time. It also looks for the first free BSS instead of one after the l=
ast
> in use. It works well with current driver (which doesn't allow deleti=
ng
> interfaces) and should be future proof (if we ever allow deleting).
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  .../broadcom/brcm80211/brcmfmac/cfg80211.c         | 17 ++++++++++++=
++-
>  .../wireless/broadcom/brcm80211/brcmfmac/core.c    | 24 ------------=
----------
>  .../wireless/broadcom/brcm80211/brcmfmac/core.h    |  1 -
>  3 files changed, 16 insertions(+), 26 deletions(-)
>=20
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg8021=
1.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
> index 3d09d23..d00eef8 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
> @@ -541,6 +541,21 @@ brcmf_cfg80211_update_proto_addr_mode(struct wir=
eless_dev *wdev)
>  						ADDR_INDIRECT);
>  }
> =20
> +static int brcmf_get_first_free_bsscfgidx(struct brcmf_pub *drvr)
> +{
> +	int bsscfgidx;
> +
> +	for (bsscfgidx =3D 0; bsscfgidx < BRCMF_MAX_IFS; bsscfgidx++) {
> +		/* bsscfgidx 1 is reserved for legacy P2P */

Hi Rafa=C5=82,

A bit late as the patch is already applied, but this reserved index is
no longer needed as we removed all trickery that was build on the
assumption that the P2P_DEVICE interface was always in bsscfgidx 1.
Hence this could be removed.

Regards,
Arend

> +		if (bsscfgidx =3D=3D 1)
> +			continue;
> +		if (!drvr->iflist[bsscfgidx])
> +			return bsscfgidx;
> +	}
> +
> +	return -ENOMEM;
> +}
> +
>  static int brcmf_cfg80211_request_ap_if(struct brcmf_if *ifp)
>  {
>  	struct brcmf_mbss_ssid_le mbss_ssid_le;
> @@ -548,7 +563,7 @@ static int brcmf_cfg80211_request_ap_if(struct br=
cmf_if *ifp)
>  	int err;
> =20
>  	memset(&mbss_ssid_le, 0, sizeof(mbss_ssid_le));
> -	bsscfgidx =3D brcmf_get_next_free_bsscfgidx(ifp->drvr);
> +	bsscfgidx =3D brcmf_get_first_free_bsscfgidx(ifp->drvr);
>  	if (bsscfgidx < 0)
>  		return bsscfgidx;
> =20
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c =
b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
> index b590499..6a76480 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
> @@ -753,30 +753,6 @@ void brcmf_remove_interface(struct brcmf_if *ifp=
)
>  	brcmf_del_if(ifp->drvr, ifp->bsscfgidx);
>  }
> =20
> -int brcmf_get_next_free_bsscfgidx(struct brcmf_pub *drvr)
> -{
> -	int ifidx;
> -	int bsscfgidx;
> -	bool available;
> -	int highest;
> -
> -	available =3D false;
> -	bsscfgidx =3D 2;
> -	highest =3D 2;
> -	for (ifidx =3D 0; ifidx < BRCMF_MAX_IFS; ifidx++) {
> -		if (drvr->iflist[ifidx]) {
> -			if (drvr->iflist[ifidx]->bsscfgidx =3D=3D bsscfgidx)
> -				bsscfgidx =3D highest + 1;
> -			else if (drvr->iflist[ifidx]->bsscfgidx > highest)
> -				highest =3D drvr->iflist[ifidx]->bsscfgidx;
> -		} else {
> -			available =3D true;
> -		}
> -	}
> -
> -	return available ? bsscfgidx : -ENOMEM;
> -}
> -
>  #ifdef CONFIG_INET
>  #define ARPOL_MAX_ENTRIES	8
>  static int brcmf_inetaddr_changed(struct notifier_block *nb,
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h =
b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
> index 647d3cc..2a075c5 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
> @@ -217,7 +217,6 @@ int brcmf_net_attach(struct brcmf_if *ifp, bool r=
tnl_locked);
>  struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bsscfgidx,=
 s32 ifidx,
>  			      bool is_p2pdev, char *name, u8 *mac_addr);
>  void brcmf_remove_interface(struct brcmf_if *ifp);
> -int brcmf_get_next_free_bsscfgidx(struct brcmf_pub *drvr);
>  void brcmf_txflowblock_if(struct brcmf_if *ifp,
>  			  enum brcmf_netif_stop_reason reason, bool state);
>  void brcmf_txfinalize(struct brcmf_if *ifp, struct sk_buff *txp, boo=
l success);
>=20
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
