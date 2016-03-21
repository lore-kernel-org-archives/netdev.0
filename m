From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Mon, 21 Mar 2016 23:15:13 +0300
Message-ID: <56F05651.3030706@cogentembedded.com>
References: <56E99727.9040702@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: Sebastian Frias <sf84@laposte.net>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:35788 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756587AbcCUUPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 16:15:19 -0400
Received: by mail-lb0-f177.google.com with SMTP id bc4so134753042lbc.2
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 13:15:18 -0700 (PDT)
In-Reply-To: <56E99727.9040702@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/16/2016 08:25 PM, Sebastian Frias wrote:

> Commit 687908c2b649 ("net: phy: at803x: simplify using
> devm_gpiod_get_optional and its 4th argument") introduced a dependency
> on GPIOLIB that was not there before.
>
> This commit removes such dependency by checking the return code and
> comparing it against ENOSYS which is returned when GPIOLIB is not
> selected.
>
> Fixes: 687908c2b649 ("net: phy: at803x: simplify using
> devm_gpiod_get_optional and its 4th argument")
>
> Signed-off-by: Sebastian Frias <sf84@laposte.net>

    Do you have the PHY that requires the GPIO reset workaround?
Askinjg because I have the patch adding the "reset-gpios" prop handling to 
phylib and your patch made me aware that I'll have to modify this driver in 
order to do that...

> ---
>   drivers/net/phy/at803x.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index 2174ec9..88b7ff3 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -252,7 +252,9 @@ static int at803x_probe(struct phy_device *phydev)
>   		return -ENOMEM;
>
>   	gpiod_reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_HIGH);
> -	if (IS_ERR(gpiod_reset))
> +	if (PTR_ERR(gpiod_reset) == -ENOSYS)
> +		gpiod_reset = NULL;
> +	else if (IS_ERR(gpiod_reset))
    		return PTR_ERR(gpiod_reset);

    My patch basically gets rid of all this code. The thing that worries me is 
that the driver assumes that the reset singal is active low, despite what the 
GPIO specifier in the device tree has for the GPIO polarity. In fact, it will 
only work correctly if the specified has GPIO_ACTIVE_HIGH -- which is wrong 
because the reset signal is active low!
    Can you point me to an actual device tree using this erratic PHY?

WBR, Sergei
