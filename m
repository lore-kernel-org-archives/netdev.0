From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] 4.9.13 brcmfmac: fix use-after-free on resume
Date: Mon, 13 Mar 2017 10:41:50 +0100
Message-ID: <f0507546-2bd4-76a6-3e77-0108a5bcf755@broadcom.com>
References: <CAMVG2stHA9qSUiRFBW=-4jhSMk-o7Frext+Qf9JK3Fo822XHhw@mail.gmail.com>
 <3626494c-8482-d003-1c83-e6171f6990a8@broadcom.com>
 <CAMVG2st=ZW-HhqQOMnDunjSJHj8Zw_K2+w2_8AVsHQePN3Ow9w@mail.gmail.com>
 <1a978960-3962-0eda-15b0-b1259b21e58f@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieterpg@broadcom.com>,
        Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        linux-wireless <linux-wireless@vger.kernel.org>
To: Daniel J Blueman <daniel@quora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34703 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752148AbdCMJmA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 05:42:00 -0400
Received: by mail-pf0-f181.google.com with SMTP id v190so67321268pfb.1
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 02:42:00 -0700 (PDT)
In-Reply-To: <1a978960-3962-0eda-15b0-b1259b21e58f@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-3-2017 10:33, Arend Van Spriel wrote:
> On 6-3-2017 15:50, Daniel J Blueman wrote:
>> On 6 March 2017 at 21:00, Arend Van Spriel <arend.vanspriel@broadcom.com> wrote:
>>> + linux-wireless
>>>
>>> On 6-3-2017 8:14, Daniel J Blueman wrote:
>>>> KASAN reported 'struct wireless_dev wdev' was read after being freed.
>>>> Fix by freeing after the access.
>>>
>>> I would rather like to see the KASAN report, because something is off
>>> here. This function is called with wdev as a parameter so how can it be
>>> accessed after free here? brcmf_remove_interface() does not free the
>>> wdev nor the brcmf_cfg80211_vif instance which contains the wdev.
>>>
>>> Regards,
>>> Arend
>>>
>>>> Signed-off-by: Daniel J Blueman <daniel@quora.org>
>>>>
>>>> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
>>>> b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
>>>> index de19c7c..aa0f470 100644
>>>> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
>>>> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
>>>> @@ -2288,12 +2288,13 @@ int brcmf_p2p_del_vif(struct wiphy *wiphy,
>>>> struct wireless_dev *wdev)
>>>>                 else
>>>>                         err = 0;
>>>>         }
>>>> -       brcmf_remove_interface(vif->ifp, true);
>>>>
>>>> -       brcmf_cfg80211_arm_vif_event(cfg, NULL);
>>>>         if (vif->wdev.iftype != NL80211_IFTYPE_P2P_DEVICE)
>>>>                 p2p->bss_idx[P2PAPI_BSSCFG_CONNECTION].vif = NULL;
>>>>
>>>> +       brcmf_remove_interface(vif->ifp, true);
>>>> +       brcmf_cfg80211_arm_vif_event(cfg, NULL);
>>>> +
>>>>         return err;
>>>>  }
>>
>> Sure, https://quora.org/kernel/brcmfmac/dmesg.txt
> 
> So this dmesg looks to be about a separate issue during resume, which
> you sent an email about earlier [1] which is about using wiphy struct
> after free. However, back to this I further checked the code and it
> seems the vif is indeed freed through the netdev destructor callback
> upon calling brcmf_remove_inteface(). However, I would prefer to store
> vif->wdev.iftype in a local variable and avoid changing the order of the
> calls in the code.

Forgot to mention some things about the commit message. Please drop the
the kernel version from the subject. You should create the patch against
the wireless-drivers tree and indicate the patch is for 4.11, ie.
"[PATCH for-4.11] brcmfmac: fix use-after-free of wireless_dev
instance". Also add as much useful information in the commit message as
possible like the proper KASAN report or at least mention that
brcmf_remove_interface() does an unregister_netdev() which results in
freeing the wireless_dev through netdev destructor callback.

Regards,
Arend

> Regards,
> Arend
> 
> [1] http://marc.info/?l=linux-netdev&m=148878437808750&w=2
> 
>> vmlinux, cfg80211.o, brcmfmac.o and config are in the same path; this
>> is against v4.9.13 stock.
> 
