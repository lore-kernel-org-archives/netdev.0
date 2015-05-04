From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH 1/2] stmac: add dwmac glue for NXP 18xx/43xx family
Date: Mon, 4 May 2015 21:27:53 +0200
Message-ID: <CAGhQ9VwX7SVnZ3xjWgMx4=8cRcA4sRL+pJCUhetF7-GQX5JFQw@mail.gmail.com>
References: <3200125.o3jqXuyPfG@wuerfel>
	<1430691251-28119-1-git-send-email-manabian@gmail.com>
	<90049936.xgdXKqK565@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:34975 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbbEDT1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 15:27:55 -0400
Received: by lbbuc2 with SMTP id uc2so112291784lbb.2
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 12:27:54 -0700 (PDT)
In-Reply-To: <90049936.xgdXKqK565@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 May 2015 at 20:46, Arnd Bergmann <arnd@arndb.de> wrote:
> On Monday 04 May 2015 00:14:11 Joachim Eastwood wrote:
> => >It should be fairly straightforward to split the probe function
>> >into two and export a function that takes a device and a stmmac_of_data
>> >pointer as arguments, and declare a module_platform_driver in your
>> >code.
>>
>> How about something like the patch below. All it does is to play a
>> little trick with the of_match_device in the dt config function and
>> export the probe/remove/pm stuff for the driver.
>>
>> The dwmac-lpc18xx would then become something like this:
>>
>> static const struct stmmac_of_data lpc18xx_dwmac_data = {
>>       .has_gmac = 1,
>>       .setup = lpc18xx_dwmac_setup,
>>       .init = lpc18xx_dwmac_init,
>> };
>>
>> static const struct of_device_id lpc18xx_dwmac_match[] = {
>>       { .compatible = "nxp,lpc1850-dwmac", .data = &lpc18xx_dwmac_data },
>>       { }
>> };
>> MODULE_DEVICE_TABLE(of, lpc18xx_dwmac_match);
>>
>> static struct platform_driver lpc18xx_dwmac_driver = {
>>       .probe  = stmmac_pltfr_probe,
>>       .remove = stmmac_pltfr_remove,
>>       .driver = {
>>               .name           = "lpc18xx-dwmac",
>>               .pm             = &stmmac_pltfr_pm_ops,
>>               .of_match_table = lpc18xx_dwmac_match,
>>       },
>> };
>> module_platform_driver(lpc18xx_dwmac_driver);
>>
>> All though this seem to work, stmmac_platform.c could benefit from
>> some refactoring. But this patch and then fixing the other DT users
>> could be a first step.
>
> Sounds good, yes.
>
>> -     device = of_match_device(stmmac_dt_ids, &pdev->dev);
>> +     device = of_match_device(dev->driver->of_match_table, dev);
>>       if (!device)
>>               return -ENODEV;
>
> Ah, that is a nice trick to avoid passing the various match tables
> from a lot of duplicated probe functions.
>
> I wonder if we could generalize that for use by any driver and
> introduce a common helper

I realised that and posted kinda of a RFC to the devicetree list yesterday.
http://marc.info/?l=devicetree&m=143068795621692&w=2

> void *of_platform_match_data(struct device *dev)
> {
>         struct of_device_id *id;
>
>         if (!dev || !dev->of_node)
>                 return NULL;
>
>         id = of_match_device(dev->driver->of_match_table, dev);
>         if (!id)
>                 return NULL;
>
>         return id->data;
> }
> EXPORT_SYMBOL_GPL(of_platform_match_data);

Almost the same as your proposal except for the dev pointer checking
and the name.

> I think that could save a few lines from many drivers, and it had not
> occurred to me that we can take this shortcut.
>
> The rest of your patch also looks great to me.

Great, I'll put together a new series of patches.

regards,
Joachim
