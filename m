From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC 1/2] brcmfmac: remove interface before notifying listener
Date: Sat, 18 Jun 2016 23:58:50 +0200
Message-ID: <CACna6rydCmKhyxsyOPrCsT_KbQLQPAg2doCcovVdvedBcRT+=w@mail.gmail.com>
References: <1466273932-11554-1-git-send-email-zajec5@gmail.com> <5765A06C.3040005@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pieter-Paul Giesberts <pieter-paul.giesberts-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"open list:NETWORKING DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5765A06C.3040005-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 18 June 2016 at 21:26, Arend van Spriel <arend.vanspriel-dY08KVG/lbrQFizaE/u3fw@public.gmane.org=
m> wrote:
> On 18-06-16 20:18, Rafa=C5=82 Mi=C5=82ecki wrote:
>> So far when receiving event about in-firmware-interface removal we w=
ere
>> notifying our listener and afterwards we were removing Linux interfa=
ce.
>>
>
> [snip]
>
>>
>> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c=
 b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
>> index 9da7a4c..5fd1886 100644
>> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
>> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
>> @@ -18,6 +18,7 @@
>>  #include "brcmu_wifi.h"
>>  #include "brcmu_utils.h"
>>
>> +#include "cfg80211.h"
>>  #include "core.h"
>>  #include "debug.h"
>>  #include "tracepoint.h"
>> @@ -180,10 +181,16 @@ static void brcmf_fweh_handle_if_event(struct =
brcmf_pub *drvr,
>>       if (ifp && ifevent->action =3D=3D BRCMF_E_IF_CHANGE)
>>               brcmf_fws_reset_interface(ifp);
>>
>> -     err =3D brcmf_fweh_call_event_handler(ifp, emsg->event_code, e=
msg, data);
>
> The reason for doing this first is because we are passing the ifp, wh=
ich
> is netdev_priv(ifp->ndev). In brcmf_remove_interface() we only
> unregister the netdev, which will end up (after scheduling) in
> brcmf_free_netdev() thus freeing the ifp. By moving the event handler
> function ifp may be stale already.

Good catch. What about making brcmf_fweh_call_event_handler work
without ifp? Would that be OK then?


>> +     if (ifp && ifevent->action =3D=3D BRCMF_E_IF_DEL) {
>> +             bool rtnl_locked =3D brcmf_cfg80211_vif_event_armed(dr=
vr->config);
>> +
>> +             brcmf_remove_interface(ifp, rtnl_locked);
>
> I guess rtnl_locked here means "rtnl_is_locked() by brcmfmac". It
> actually does not matter who is holding the rtnl_lock. At least when =
it
> is brcmfmac it is still a different task, ie. hostapd, iw, etc. Also
> when brcmf_cfg80211_vif_event_armed() return false there may still be
> some task holding the rtnl_lock.

It does matter who holds the lock.

If it's e.g. some other driver (ath, intel, ralink, whatever) we still
should call unregister_netdevice. It'll just wait until rtnl lock gets
released.

If it's brcmfmac holding the lock, we can't expect it to be released
as brcmfmac waits for completion event.

--=20
Rafa=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
