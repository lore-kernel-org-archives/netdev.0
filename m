From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Thu, 7 Sep 2017 14:39:57 -0700
Message-ID: <81338659-4f46-0f2f-13c3-135b3ac876d7@gmail.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com>
 <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com>
 <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
 <20170718133209.GB32757@lunn.ch>
 <CACRpkdYw5GWv3HRCqnWjDfctLEfzcoFdJ7ib_NVKRgw0+Y9dEg@mail.gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40B1B424@CHN-SV-EXMX02.mchp-main.com>
 <CACRpkdbK03cwzmGs=0nVeCp6NnX0-41dhEotxfDT46O4xDzagQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Fabio Estevam <festevam@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Linus Walleij <linus.walleij@linaro.org>, Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:37458 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755840AbdIGVkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 17:40:06 -0400
Received: by mail-wr0-f195.google.com with SMTP id u48so406227wrf.4
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 14:40:05 -0700 (PDT)
In-Reply-To: <CACRpkdbK03cwzmGs=0nVeCp6NnX0-41dhEotxfDT46O4xDzagQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2017 02:33 PM, Linus Walleij wrote:
> On Thu, Sep 7, 2017 at 11:30 PM,  <Woojung.Huh@microchip.com> wrote:
>>> If someone is using GPIO descriptors with GPIO disabled, i.e. calling
>>> gpiod_get() and friends, this is very likely to be a bug, and what
>>> the driver wants to do is:
>>>
>>>  depends on GPIOLIB
>>>
>>> or
>>>
>>>  select GPIOLIB
>>>
>>> in Kconfig. The whole optional thing is mainly a leftover from when it
>>> was possible to have a local implementation of the GPIOLIB API in
>>> some custom header file, noone sane should be doing that anymore,
>>> and if they do, they can very well face the warnings.
>>>
>>> If someone is facing a lot of WARN_ON() messages to this, it is a clear
>>> indication that they need to fix their Kconfig and in that case it is proper.
>> Linus & Andrew,
>>
>> I knew that it is already in David's pulling request.
>> Configuring GPIOLIB is the right solution  even if platform doesn't use it?
> 
> I guess?
> 
> "Platform doesn't use it" what does that mean?
> 
> Does it mean it does not call the
> APIs of the GPIOLIB, does it mean it doesn't have a GPIO driver
> at probe (but may have one by having it probed from a module)
> or does it mean the platform can never have it?

I think it means CONFIG_GPIOLIB=n in the kernel because it's not needed,
yet you run code (like drivers/net/phy/mdio_bus.c) that unconditionally
calls into GPIOLIB and attempts to configure a given GPIO if available.
This thread is actually what prompted me to write this email:

https://lkml.org/lkml/2017/9/2/3

So that's the takeway should we just conditionalize all the GPIOLIB
calls from drivers/net/phy/mdio_bus.c under an #if
IS_ENABLED(CONFIG_GPIOLIB) of some sort?

> 
> If it calls the APIs, it is using it.
> 

It's more subtle than that, the GPIO resource may not be available just
like you have disabled support for GPIOLIB in the kernel, in which case,
the calls are still there, they default to their inline stubs, you get
warnings, everyone panics and screams.
-- 
Florian
