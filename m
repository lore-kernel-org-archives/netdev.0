From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] mdio_bus: Fix MDIO bus scanning in __mdiobus_register()
Date: Fri, 29 Apr 2016 14:18:45 +0300
Message-ID: <86212055-7d15-ab11-4998-72c04af2426d@cogentembedded.com>
References: <1461892155-10524-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S . Miller" <davem@davemloft.net>,
	Dinh Nguyen <dinguyen@opensource.altera.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Marek Vasut <marex@denx.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35656 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbcD2LSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 07:18:48 -0400
Received: by mail-lf0-f50.google.com with SMTP id c126so130297808lfb.2
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 04:18:47 -0700 (PDT)
In-Reply-To: <1461892155-10524-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

    First of all, thank you for the patch!
    You beat me to it (and not only me). :-)

On 4/29/2016 4:09 AM, Marek Vasut wrote:

> Since commit b74766a0a0feeef5c779709cc5d109451c0d5b17 in linux-next,
> ( phylib: don't return NULL from get_phy_device() ), phy_get_device()

    scripts/checkpatch.pl now enforces certain commit citing style, yours 
doesn't quite match it.

> will return ERR_PTR(-ENODEV) instead of NULL if the PHY device ID is
> all ones.
>
> This causes problem with stmmac driver and likely some other drivers
> which call mdiobus_register(). I triggered this bug on SoCFPGA MCVEVK
> board with linux-next 20160427 and 20160428. In case of the stmmac, if
> there is no PHY node specified in the DT for the stmmac block, the stmmac
> driver ( drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c function
> stmmac_mdio_register() ) will call mdiobus_register() , which will
> register the MDIO bus and probe for the PHY.
>
> The mdiobus_register() resp. __mdiobus_register() iterates over all of
> the addresses on the MDIO bus and calls mdiobus_scan() for each of them,
> which invokes get_phy_device(). Before the aforementioned patch, the
> mdiobus_scan() would return NULL if no PHY was found on a given address
> and mdiobus_register() would continue and try the next PHY address. Now,
> mdiobus_scan() returns ERR_PTR(-ENODEV), which is caught by the
> 'if (IS_ERR(phydev))' condition and the loop exits immediatelly if the
> PHY address does not contain PHY.
>
> Repair this by explicitly checking for the ERR_PTR(-ENODEV) and if this
> error comes around, continue with the next PHY address.
>
> Signed-off-by: Marek Vasut <marex@denx.de>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Dinh Nguyen <dinguyen@opensource.altera.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> ---
>  drivers/net/phy/mdio_bus.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> NOTE: I don't quite like this explicit check , but I don't have better idea now.

    It's fine. I was going to do just the same :-)

> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 499003ee..388f992 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -333,7 +333,7 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
>  			struct phy_device *phydev;
>
>  			phydev = mdiobus_scan(bus, i);
> -			if (IS_ERR(phydev)) {
> +			if (IS_ERR(phydev) && (PTR_ERR(phydev) != -ENODEV)) {

    Parens around the second operand of && are not really needed though...

[...]

MBR, Sergei
