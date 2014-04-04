From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] net: phy: shift phy_init_hw after device_add during phy
 device registration
Date: Fri, 4 Apr 2014 16:41:46 +0300
Message-ID: <533EB69A.5040606@ti.com>
References: <1396618728-4151-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <Grygorii.Strashko@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:43244 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752384AbaDDMti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2014 08:49:38 -0400
In-Reply-To: <1396618728-4151-1-git-send-email-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, this is  [RFC PATCH].

On 04/04/2014 04:38 PM, Grygorii Strashko wrote:
> Now the call of phy_init_hw() in phy_device_register() is converted to
> be just a NOP, because phy_init_hw() is called before PHY devices probing
> and phydev->drv == NULL at this moment.
>
> phy_device_register()
>   |- phy_init_hw() -> NOP
>   |- device_add()
>      |- phy_probe() -> may be if driver is ready
>         |- phydev->drv = <&phy_driver>
>
> Hence, shift call of phy_init_hw() after device_add() and in such way
> increase possibility of its execution.
>
> This patch is RFC because:
> - this patch will change PHY's callbacks call order: .config_init() will
> be called after .probe()
> - i'm not sure that phy_init_hw() need to be called from phy_device_register() and
> maybe it can be moved in other place, like phy_probe()
>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
>   drivers/net/phy/phy_device.c |   10 +++++-----
>   1 file changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 2f6989b..496940be 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -352,16 +352,16 @@ int phy_device_register(struct phy_device *phydev)
>   		return -EINVAL;
>   	phydev->bus->phy_map[phydev->addr] = phydev;
>
> -	/* Run all of the fixups for this PHY */
> -	err = phy_init_hw(phydev);
> +	err = device_add(&phydev->dev);
>   	if (err) {
> -		pr_err("PHY %d failed to initialize\n", phydev->addr);
> +		pr_err("PHY %d failed to add\n", phydev->addr);
>   		goto out;
>   	}
>
> -	err = device_add(&phydev->dev);
> +	/* Run all of the fixups for this PHY */
> +	err = phy_init_hw(phydev);
>   	if (err) {
> -		pr_err("PHY %d failed to add\n", phydev->addr);
> +		pr_err("PHY %d failed to initialize\n", phydev->addr);
>   		goto out;
>   	}
>
>
