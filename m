From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH RFC 1/2] brcmfmac: remove interface before notifying listener
Date: Sun, 19 Jun 2016 00:42:58 +0200
Message-ID: <CACna6rwwb3DNAcps6UyeRFvNTfhzh9ZiTTccPurhCzTn1SxcwQ@mail.gmail.com>
References: <1466273932-11554-1-git-send-email-zajec5@gmail.com>
 <5765A06C.3040005@broadcom.com> <CACna6rydCmKhyxsyOPrCsT_KbQLQPAg2doCcovVdvedBcRT+=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Franky Lin <franky.lin@broadcom.com>,
	Hante Meuleman <hante.meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<linux-wireless@vger.kernel.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list.pdl@broadcom.com>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACna6rydCmKhyxsyOPrCsT_KbQLQPAg2doCcovVdvedBcRT+=w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18 June 2016 at 23:58, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> wr=
ote:
> On 18 June 2016 at 21:26, Arend van Spriel <arend.vanspriel@broadcom.=
com> wrote:
>> On 18-06-16 20:18, Rafa=C5=82 Mi=C5=82ecki wrote:
>>> So far when receiving event about in-firmware-interface removal we =
were
>>> notifying our listener and afterwards we were removing Linux interf=
ace.
>>>
>>
>> [snip]
>>
>>>
>>> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.=
c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
>>> index 9da7a4c..5fd1886 100644
>>> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
>>> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
>>> @@ -18,6 +18,7 @@
>>>  #include "brcmu_wifi.h"
>>>  #include "brcmu_utils.h"
>>>
>>> +#include "cfg80211.h"
>>>  #include "core.h"
>>>  #include "debug.h"
>>>  #include "tracepoint.h"
>>> @@ -180,10 +181,16 @@ static void brcmf_fweh_handle_if_event(struct=
 brcmf_pub *drvr,
>>>       if (ifp && ifevent->action =3D=3D BRCMF_E_IF_CHANGE)
>>>               brcmf_fws_reset_interface(ifp);
>>>
>>> -     err =3D brcmf_fweh_call_event_handler(ifp, emsg->event_code, =
emsg, data);
>>
>> The reason for doing this first is because we are passing the ifp, w=
hich
>> is netdev_priv(ifp->ndev). In brcmf_remove_interface() we only
>> unregister the netdev, which will end up (after scheduling) in
>> brcmf_free_netdev() thus freeing the ifp. By moving the event handle=
r
>> function ifp may be stale already.
>
> Good catch. What about making brcmf_fweh_call_event_handler work
> without ifp? Would that be OK then?

Maybe I have even better idea. What about handling Linux interface
removal in the code waiting for BRCMF_E_IF_DEL? We already do
something like that in case of BRCMF_E_IF_ADD (it is brcmf_ap_add_vif
that calls brcmf_net_attach).
