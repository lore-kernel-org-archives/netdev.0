From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/1] net: phy: unbind phy device from generic
 and specifical driver
Date: Mon, 26 Jan 2015 09:14:25 -0800
Message-ID: <54C675F1.9080803@gmail.com>
References: <1422260045-22527-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de,
	bhutchings@solarflare.com, stephen@networkplumber.org
To: Fugang Duan <b38611@freescale.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:50792 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808AbbAZROo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 12:14:44 -0500
Received: by mail-pd0-f177.google.com with SMTP id y13so12980918pdi.8
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 09:14:43 -0800 (PST)
In-Reply-To: <1422260045-22527-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/01/15 00:14, Fugang Duan wrote:
> The current .phy_detach() function only unbind generic phy driver, which causes
> specifical driver suspend/resume function still work like Atheros AT803X PHYs.
> 
> For example:
> ifconfig eth0 down
> echo mem > /sys/power/status
> 
> After eth0 interface down, driver call phy_detach to unbind phy driver, and then
> do suspend/resume operation, at803x_suspend()/at803x_resume() functions still get
> called that call mdio bus read/write function. When eth0 interface down, MAC driver
> may close all clocks and mdio bus cannot work. So the issue happens.

I was just hitting this problem on Friday evening and was about to
submit a similar change. Thanks!

> 
> The patch can unbind generic and specifical driver.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>


> ---
>  drivers/net/phy/phy_device.c |   15 ++-------------
>  1 files changed, 2 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 3fc91e8..8adbc5d 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -672,8 +672,6 @@ EXPORT_SYMBOL(phy_attach);
>   */
>  void phy_detach(struct phy_device *phydev)
>  {
> -	int i;
> -
>  	if (phydev->bus->dev.driver)
>  		module_put(phydev->bus->dev.driver->owner);
>  
> @@ -681,17 +679,8 @@ void phy_detach(struct phy_device *phydev)
>  	phydev->attached_dev = NULL;
>  	phy_suspend(phydev);
>  
> -	/* If the device had no specific driver before (i.e. - it
> -	 * was using the generic driver), we unbind the device
> -	 * from the generic driver so that there's a chance a
> -	 * real driver could be loaded
> -	 */
> -	for (i = 0; i < ARRAY_SIZE(genphy_driver); i++) {
> -		if (phydev->dev.driver == &genphy_driver[i].driver) {
> -			device_release_driver(&phydev->dev);
> -			break;
> -		}
> -	}
> +	if (phydev->dev.driver)
> +		device_release_driver(&phydev->dev);
>  }
>  EXPORT_SYMBOL(phy_detach);
>  
> 


-- 
Florian
