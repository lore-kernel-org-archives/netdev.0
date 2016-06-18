From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH RFC 1/2] brcmfmac: remove interface before notifying
 listener
Date: Sat, 18 Jun 2016 21:26:36 +0200
Message-ID: <5765A06C.3040005@broadcom.com>
References: <1466273932-11554-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Franky Lin <franky.lin@broadcom.com>,
	Hante Meuleman <hante.meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<linux-wireless@vger.kernel.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list.pdl@broadcom.com>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37252 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbcFRT0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 15:26:42 -0400
Received: by mail-wm0-f51.google.com with SMTP id a66so28346600wme.0
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 12:26:41 -0700 (PDT)
In-Reply-To: <1466273932-11554-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18-06-16 20:18, Rafa=C5=82 Mi=C5=82ecki wrote:
> So far when receiving event about in-firmware-interface removal we we=
re
> notifying our listener and afterwards we were removing Linux interfac=
e.
>=20

[snip]

>=20
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c =
b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
> index 9da7a4c..5fd1886 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
> @@ -18,6 +18,7 @@
>  #include "brcmu_wifi.h"
>  #include "brcmu_utils.h"
> =20
> +#include "cfg80211.h"
>  #include "core.h"
>  #include "debug.h"
>  #include "tracepoint.h"
> @@ -180,10 +181,16 @@ static void brcmf_fweh_handle_if_event(struct b=
rcmf_pub *drvr,
>  	if (ifp && ifevent->action =3D=3D BRCMF_E_IF_CHANGE)
>  		brcmf_fws_reset_interface(ifp);
> =20
> -	err =3D brcmf_fweh_call_event_handler(ifp, emsg->event_code, emsg, =
data);

The reason for doing this first is because we are passing the ifp, whic=
h
is netdev_priv(ifp->ndev). In brcmf_remove_interface() we only
unregister the netdev, which will end up (after scheduling) in
brcmf_free_netdev() thus freeing the ifp. By moving the event handler
function ifp may be stale already.

> +	if (ifp && ifevent->action =3D=3D BRCMF_E_IF_DEL) {
> +		bool rtnl_locked =3D brcmf_cfg80211_vif_event_armed(drvr->config);
> +
> +		brcmf_remove_interface(ifp, rtnl_locked);

I guess rtnl_locked here means "rtnl_is_locked() by brcmfmac". It
actually does not matter who is holding the rtnl_lock. At least when it
is brcmfmac it is still a different task, ie. hostapd, iw, etc. Also
when brcmf_cfg80211_vif_event_armed() return false there may still be
some task holding the rtnl_lock.

Regards,
Arend
