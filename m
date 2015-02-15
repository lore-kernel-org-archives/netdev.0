From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3] brcmfmac: avoid duplicated suspend/resume operation
Date: Sun, 15 Feb 2015 09:31:29 +0100
Message-ID: <54E05961.7000201@broadcom.com>
References: <54DC1D7D.5050407@linux.intel.com> <54E0072D.3020802@linux.intel.com> <54E01209.7010300@erley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Fu, Zhonghui" <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	<hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <wens-jdAy2FN1RRM@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Pat Erley <pat-lkml-Jx9fsTfDDR3YtjvyW6yDsg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54E01209.7010300-Jx9fsTfDDR3YtjvyW6yDsg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/15/15 04:27, Pat Erley wrote:
> On 02/14/2015 08:40 PM, Fu, Zhonghui wrote:
>>
>> Any comments to this patch? Can it be accepted?

I assume that patches are queued up until after the merge window that we 
are currently in.

>> Thanks,
>> Zhonghui
>>
>> On 2015/2/12 11:26, Fu, Zhonghui wrote:
>>> From a05d35ab334c20970c236fb971dae88810078c88 Mon Sep 17 00:00:00 2001
>>> From: Fu Zhonghui <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
>>> Date: Thu, 12 Feb 2015 10:49:35 +0800
>>> Subject: [PATCH v3] brcmfmac: avoid duplicated suspend/resume operation
>>>
>>> WiFi chip has 2 SDIO functions, and PM core will trigger
>>> twice suspend/resume operations for one WiFi chip to do
>>> the same things. This patch avoid this case.
>>>
>>> Acked-by: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>>> Signed-off-by: Fu Zhonghui <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
>>> ---
>>> Changes in v3:
>>> - Rebase to wireless-drivers-next/master branch
>>>
>>> drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c | 13 ++++++++++++-
>>> 1 file changed, 12 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>>> b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>>> index 7944224..b8832a7 100644
>>> --- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>>> @@ -1117,9 +1117,13 @@ static int brcmf_ops_sdio_suspend(struct
>>> device *dev)
>>> struct brcmf_bus *bus_if;
>>> struct brcmf_sdio_dev *sdiodev;
>>> mmc_pm_flag_t sdio_flags;
>>> + struct sdio_func *func = dev_to_sdio_func(dev);
>>>
>>> brcmf_dbg(SDIO, "Enter\n");
>>>
>>> + if (func->num == 2)
>>> + return 0;
>>> +
>
> Should it be >= 2 instead of == 2 so that if, in the future, a 3+
> SDIO function chip comes out, it's already handled? Not that that
> should hold up the patch or anything, just a curiosity.

The driver only claims functions 1 and 2 during the probe so that assure 
it works for SDIO devices that have more than two functions.

Regards,
Arend

>>> bus_if = dev_get_drvdata(dev);
>>> sdiodev = bus_if->bus_priv.sdio;
>>>
>>> @@ -1148,9 +1152,16 @@ static int brcmf_ops_sdio_suspend(struct
>>> device *dev)
>>> static int brcmf_ops_sdio_resume(struct device *dev)
>>> {
>>> struct brcmf_bus *bus_if = dev_get_drvdata(dev);
>>> - struct brcmf_sdio_dev *sdiodev = bus_if->bus_priv.sdio;
>>> + struct brcmf_sdio_dev *sdiodev;
>>> + struct sdio_func *func = dev_to_sdio_func(dev);
>>>
>>> brcmf_dbg(SDIO, "Enter\n");
>>> +
>>> + if (func->num == 2)
>>> + return 0;
>>> +
>>> + sdiodev = bus_if->bus_priv.sdio;
>>> +
>>> if (sdiodev->pdata && sdiodev->pdata->oob_irq_supported)
>>> disable_irq_wake(sdiodev->pdata->oob_irq_nr);
>>> brcmf_sdio_wd_timer(sdiodev->bus, BRCMF_WD_POLL_MS);
>>> -- 1.9.1
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe
>> linux-wireless" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>>
>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
