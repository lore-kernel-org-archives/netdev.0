From: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Subject: Re: [PATCH v2] brcmfmac: avoid duplicated suspend/resume operation
Date: Thu, 12 Feb 2015 11:30:37 +0800
Message-ID: <54DC1E5D.8060703@linux.intel.com>
References: <54D83AF1.2020501@linux.intel.com> <54D871A9.4050603@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, brudley@broadcom.com,
	Franky Lin <frankyl@broadcom.com>, meuleman@broadcom.com,
	linville@tuxdriver.com, pieterpg@broadcom.com, hdegoede@redhat.com,
	wens@csie.org, linux-wireless@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D871A9.4050603@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2015/2/9 16:36, Arend van Spriel wrote:
> On 02/09/15 05:43, Fu, Zhonghui wrote:
>>  From ff39ed4af9f1c50358fe92ec4c8eaac9db183e00 Mon Sep 17 00:00:00 2001
>> From: Zhonghui Fu<zhonghui.fu@linux.intel.com>
>> Date: Mon, 26 Jan 2015 10:13:21 +0800
>> Subject: [PATCH v2] brcmfmac: avoid duplicated suspend/resume operation
>>
>> WiFi chip has 2 SDIO functions, and PM core will trigger
>> twice suspend/resume operations for one WiFi chip to do
>> the same things. This patch avoid this case.
>
> Well, another remark from Kalle was that this patch does not apply to wireless-drivers-next/master branch. So I tried to apply this patch and it failed. Please rebase this patch.

I have re-based this patch to wireless-drivers-next/master branch and sent it with the subject "[PATCH v3] brcmfmac: avoid duplicated suspend/resume operation" in another mail.

Thanks,
Zhonghui
 
>
> Regards,
> Arend
>
>> Acked-by: Arend van Spriel<arend@broadcom.com>
>> Signed-off-by: Zhonghui Fu<zhonghui.fu@linux.intel.com>
>> ---
>> Changes in v2:
>>   - Remove two "Acked-by" lines
>>
>>   drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |   17 +++++++++++++++--
>>   1 files changed, 15 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>> index 9880dae..618b545 100644
>> --- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>> @@ -1139,11 +1139,17 @@ void brcmf_sdio_wowl_config(struct device *dev, bool enabled)
>>   static int brcmf_ops_sdio_suspend(struct device *dev)
>>   {
>>       struct brcmf_bus *bus_if = dev_get_drvdata(dev);
>> -    struct brcmf_sdio_dev *sdiodev = bus_if->bus_priv.sdio;
>> +    struct brcmf_sdio_dev *sdiodev;
>>       mmc_pm_flag_t sdio_flags;
>> +    struct sdio_func *func = dev_to_sdio_func(dev);
>>
>>       brcmf_dbg(SDIO, "Enter\n");
>>
>> +    if (func->num == 2)
>> +        return 0;
>> +
>> +    sdiodev = bus_if->bus_priv.sdio;
>> +
>>       atomic_set(&sdiodev->suspend, true);
>>
>>       if (sdiodev->wowl_enabled) {
>> @@ -1164,9 +1170,16 @@ static int brcmf_ops_sdio_suspend(struct device *dev)
>>   static int brcmf_ops_sdio_resume(struct device *dev)
>>   {
>>       struct brcmf_bus *bus_if = dev_get_drvdata(dev);
>> -    struct brcmf_sdio_dev *sdiodev = bus_if->bus_priv.sdio;
>> +    struct brcmf_sdio_dev *sdiodev;
>> +    struct sdio_func *func = dev_to_sdio_func(dev);
>>
>>       brcmf_dbg(SDIO, "Enter\n");
>> +
>> +    if (func->num == 2)
>> +        return 0;
>> +
>> +    sdiodev = bus_if->bus_priv.sdio;
>> +
>>       if (sdiodev->pdata&&  sdiodev->pdata->oob_irq_supported)
>>           disable_irq_wake(sdiodev->pdata->oob_irq_nr);
>>       brcmf_sdio_wd_timer(sdiodev->bus, BRCMF_WD_POLL_MS);
>> -- 1.7.1
>>
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
