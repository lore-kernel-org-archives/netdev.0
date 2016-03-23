From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Wed, 23 Mar 2016 13:39:29 +0300
Message-ID: <56F27261.4060005@cogentembedded.com>
References: <56E99727.9040702@laposte.net>
 <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net>
 <20160318191242.GQ4292@pengutronix.de> <56EFEDAD.9030903@laposte.net>
 <20160321135457.GX4292@pengutronix.de> <56F0150F.8080804@laposte.net>
 <20160321201229.GA6191@pengutronix.de> <56F157EF.5080307@laposte.net>
 <20160322194224.GF6191@pengutronix.de> <56F26D27.3020106@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>,
	Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Mason <slash.tmp@free.fr>, Sebastian Frias <sf84@laposte.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:34778 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbcCWKje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 06:39:34 -0400
Received: by mail-lf0-f42.google.com with SMTP id c62so4727061lfc.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 03:39:33 -0700 (PDT)
In-Reply-To: <56F26D27.3020106@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/23/2016 1:17 PM, Mason wrote:

>> Preconditions:
>>   - Some of the devices a given driver handles have a reset line and
>>     others don't.
>>   - A non-empty subset (maybe all) of the devices that have a reset line
>>     require that this reset line is used.
>>
>> Then the way to handle this in the driver should be done as follows:
>>
>>    unless reset_handling_not_necessary():
>>      gpio = gpiod_get_optional("reset")
>>      if IS_ERR(gpio):
>>        return PTR_ERR(gpio)
>>
>> Checking for -ENOSYS or GPIOLIB=n is not allowed because the device
>> you're currently handling might need the GPIO, so you must not continue
>> without the ability to control the line.
>>
>> So the options you have (as you have a phy that doesn't need the reset
>> handling):
>>
>>   - enable GPIOLIB (either in your .config or introduce a Kconfig
>>     dependency)
>>   - improve reset_handling_not_necessary() to return true for your case
>>
>> There is nothing else.
>
> Here are some numbers for GPIOLIB, on an ARM build:
>
>     text	   data	    bss	    dec	    hex	filename
>     1830	      0	      0	   1830	    726	devres.o
>      627	      0	      0	    627	    273	gpiolib-legacy.o
>    11018	     40	      4	  11062	   2b36	gpiolib.o
>     1598	      0	      0	   1598	    63e	gpiolib-of.o
> --------------------------------------------------------
>    15073	     40	      4	  15117	   3b0d	built-in.o
>
> So ~15 kilobytes.
>
>
> By the way, since the "reset-by-GPIO" solution is used only for
> the Atheros 8030, would it be possible to make the
> devm_gpiod_get_optional conditional on ATH8030_PHY_ID?
>
> I'm thinking of something along these lines, for illustration:
>
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index 2d020a3ec0b5..576e7873e049 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -198,12 +198,16 @@ static int at803x_probe(struct phy_device *phydev)
>          if (!priv)
>                  return -ENOMEM;
>
> +       if (phydev->drv->phy_id != ATH8030_PHY_ID)
> +               goto no_gpio;
> +
>          gpiod_reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_HIGH);

    We shouldn't call _optional() then, should we?

>          if (IS_ERR(gpiod_reset))
>                  return PTR_ERR(gpiod_reset);
>
>          priv->gpiod_reset = gpiod_reset;
>
> +no_gpio:
>          phydev->priv = priv;
>
>          return 0;
>
>
> Regards.

MBR, Sergei
