From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] Revert "mdio_bus: Remove unneeded gpiod NULL check"
Date: Fri, 8 Sep 2017 16:18:49 -0700
Message-ID: <fe6846be-afc3-1025-d78a-96674e1b2a35@gmail.com>
References: <20170908223807.6015-1-f.fainelli@gmail.com>
 <CACRpkdZD-nRXXusX36Gaypf5A601CMEO3vVgaOV5tKufvy1M3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Fabio Estevam <festevam@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Bryan.Whitehead@microchip.com
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:38202 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756895AbdIHXS4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 19:18:56 -0400
Received: by mail-qk0-f195.google.com with SMTP id c69so2340060qke.5
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 16:18:56 -0700 (PDT)
In-Reply-To: <CACRpkdZD-nRXXusX36Gaypf5A601CMEO3vVgaOV5tKufvy1M3Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2017 04:13 PM, Linus Walleij wrote:
> On Sat, Sep 9, 2017 at 12:38 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 
>> This reverts commit 95b80bf3db03c2bf572a357cf74b9a6aefef0a4a ("mdio_bus:
>> Remove unneeded gpiod NULL check"), this commit assumed that GPIOLIB
>> checks for NULL descriptors, so it's safe to drop them, but it is not
>> when CONFIG_GPIOLIB is disabled in the kernel. If we do call
>> gpiod_set_value_cansleep() on a GPIO descriptor we will issue warnings
>> coming from the inline stubs declared in include/linux/gpio/consumer.h.
>>
>> Fixes: 95b80bf3db03 ("mdio_bus: Remove unneeded gpiod NULL check")
>> Reported-by: Woojung Huh <Woojung.Huh@microchip.com>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Yeah I guess you don't wanna have these messages spewing
> in the console. :/
> 
> But what about simply doing this:

That would create another dependency which really does not need to be
there as it really prevents you from testing more configurations,
including but not limited to having CONFIG_GPIOLIB=n w/
CONFIG_MDIO_DEVICE=[ym].

The GPIOLIB=n inline stubs have a "contract" with the code calling them
that is fairly clear, which is what this revert is leveraging.

Instead of doing what you suggest, we could also encapsulate the
offending code within an #IS_ENABLED(CONFIG_GPIOLIB) block, which would
be virtually the same thing in terms of object code generated, but would
make it clear there is a functional dependency, I would personally be
keener on that approach than having a select or depends.

Thanks

> 
> 
> From 150e4f3c1f227c9a4c31bbb48d44220e25b792ec Mon Sep 17 00:00:00 2001
> From: Linus Walleij <linus.walleij@linaro.org>
> Date: Sat, 9 Sep 2017 01:07:22 +0200
> Subject: [PATCH] net: phy: mdio_bus: mandate gpiolib
> 
> The core mdio bus unconditionally uses gpiolib APIs to handle
> reset lines which results in runtime errors when it is compiled
> out. It is not supposed to be possible to stub out gpiolib
> like this, the error messages from the stubs are a sign that
> something is wrong.
> 
> So just select it. Fix some unneeded #includes while we're
> at it.>
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> ---
>  drivers/net/phy/Kconfig    | 1 +
>  drivers/net/phy/mdio_bus.c | 2 --
>  2 files changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index a9d16a3af514..b6c5bb9941c3 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -4,6 +4,7 @@
> 
>  menuconfig MDIO_DEVICE
>      tristate "MDIO bus device drivers"
> +    select GPIOLIB
>      help
>        MDIO devices and driver infrastructure code.
> 
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index b6f9fa670168..9c60f87b7209 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -22,11 +22,9 @@
>  #include <linux/init.h>
>  #include <linux/delay.h>
>  #include <linux/device.h>
> -#include <linux/gpio.h>
>  #include <linux/gpio/consumer.h>
>  #include <linux/of_device.h>
>  #include <linux/of_mdio.h>
> -#include <linux/of_gpio.h>
>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
>  #include <linux/skbuff.h>
> 


-- 
Florian
