From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Fri, 8 Sep 2017 12:56:50 -0700
Message-ID: <c960202c-02e3-3f54-7d0b-b5ece46c6a9e@gmail.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com>
 <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com>
 <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
 <20170718133209.GB32757@lunn.ch>
 <CACRpkdYw5GWv3HRCqnWjDfctLEfzcoFdJ7ib_NVKRgw0+Y9dEg@mail.gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40B1B424@CHN-SV-EXMX02.mchp-main.com>
 <CACRpkdbK03cwzmGs=0nVeCp6NnX0-41dhEotxfDT46O4xDzagQ@mail.gmail.com>
 <81338659-4f46-0f2f-13c3-135b3ac876d7@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40B1B47F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: andrew@lunn.ch, festevam@gmail.com,
        sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
        netdev@vger.kernel.org, fabio.estevam@nxp.com
To: Woojung.Huh@microchip.com, linus.walleij@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:38692 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756846AbdIHT44 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 15:56:56 -0400
Received: by mail-qt0-f173.google.com with SMTP id q8so8924788qtb.5
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 12:56:55 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40B1B47F@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2017 02:51 PM, Woojung.Huh@microchip.com wrote:
>>>>> If someone is using GPIO descriptors with GPIO disabled, i.e. calling
>>>>> gpiod_get() and friends, this is very likely to be a bug, and what
>>>>> the driver wants to do is:
>>>>>
>>>>>  depends on GPIOLIB
>>>>>
>>>>> or
>>>>>
>>>>>  select GPIOLIB
>>>>>
>>>>> in Kconfig. The whole optional thing is mainly a leftover from when it
>>>>> was possible to have a local implementation of the GPIOLIB API in
>>>>> some custom header file, noone sane should be doing that anymore,
>>>>> and if they do, they can very well face the warnings.
>>>>>
>>>>> If someone is facing a lot of WARN_ON() messages to this, it is a clear
>>>>> indication that they need to fix their Kconfig and in that case it is proper.
>>>> Linus & Andrew,
>>>>
>>>> I knew that it is already in David's pulling request.
>>>> Configuring GPIOLIB is the right solution  even if platform doesn't use it?
>>>
>>> I guess?
>>>
>>> "Platform doesn't use it" what does that mean?
>>>
>>> Does it mean it does not call the
>>> APIs of the GPIOLIB, does it mean it doesn't have a GPIO driver
>>> at probe (but may have one by having it probed from a module)
>>> or does it mean the platform can never have it?
>>
>> I think it means CONFIG_GPIOLIB=n in the kernel because it's not needed,
>> yet you run code (like drivers/net/phy/mdio_bus.c) that unconditionally
>> calls into GPIOLIB and attempts to configure a given GPIO if available.
> Yes. I'm facing issue on PC which won't need GPIOLIB as default.
> Warning message goes away when GPIOLIB is enabled, and fortunately,
> Ubuntu default config has it.
> So, it may not be seen by many users when with full/default configuration.

Woojung, I suppose you are also getting a warning from
gpiod_set_value_cansleep() done in mdiobus_unregister() right? With
CONFIG_GPIOLIB=n devm_gpiod_get_optional() returns NULL, which we don't
check as an error, on purpose however we still call
gpiod_set_value_cansleep() on a NULL GPIO descriptor, so the following
should do:

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index b6f9fa670168..67dbb7c26840 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -424,7 +424,8 @@ void mdiobus_unregister(struct mii_bus *bus)
        }

        /* Put PHYs in RESET to save power */
-       gpiod_set_value_cansleep(bus->reset_gpiod, 1);
+       if (!IS_ERR_OR_NULL(bus->reset_gpiod))
+               gpiod_set_value_cansleep(bus->reset_gpiod, 1);

        device_del(&bus->dev);
 }


> 
>> This thread is actually what prompted me to write this email:
>>
>> https://lkml.org/lkml/2017/9/2/3
> Thanks for the link.
> 
> 


-- 
Florian
