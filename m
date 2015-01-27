From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH net-next 4/4] net: phy: avoid suspending twice a PHY
Date: Tue, 27 Jan 2015 02:44:14 +0000
Message-ID: <BLUPR03MB37333B3BB74B3DD928EEE6FF5320@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1422318673-9418-1-git-send-email-f.fainelli@gmail.com>
 <1422318673-9418-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"s.hauer@pengutronix.de" <s.hauer@pengutronix.de>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0126.outbound.protection.outlook.com ([65.55.169.126]:40833
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752280AbbA0C7y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 21:59:54 -0500
In-Reply-To: <1422318673-9418-5-git-send-email-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com> Sent: Tuesday, January 27, 2015 8:31 AM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; s.hauer@pengutronix.de; Duan Fugang-B38611;
> Florian Fainelli
> Subject: [PATCH net-next 4/4] net: phy: avoid suspending twice a PHY
> 
> As part of a call to ndo_close() a netdevice driver may call
> phy_disconnect() -> phy_detach() -> phy_suspend(), such that the PHY is
> suspsended at this point and a netdevice driver may clock gate the
> backing peripheral providing MDIO bus accessses as well.
> 
> Update mdio_bus_phy_may_suspend() to return whether a PHY is allowed to
> be suspended and conversely resumed if and only if it was not previously
> suspended before while it is currently in detached (netdev pointer is
> NULL) state.
> 
> This fixes bus errors seen during S2/S3 suspend/resume cycles for
> netdevice drivers such as GENET which clock gates the entire Ethernet MAC,
> including the MDIO bus block.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/phy/mdio_bus.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 20447741893a..095ef3fe369a 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -443,9 +443,13 @@ static bool mdio_bus_phy_may_suspend(struct
> phy_device *phydev)
>  	if (!drv || !phydrv->suspend)
>  		return false;
> 
> -	/* PHY not attached? May suspend. */
> +	/* PHY not attached? May suspend if the PHY has not already been
> +	 * suspended as part of a prior call to phy_disconnect() ->
> +	 * phy_detach() -> phy_suspend() because the parent netdev might be
> the
> +	 * MDIO bus driver and clock gated at this point.
> +	 */
>  	if (!netdev)
> -		return true;
> +		return !phydev->suspended;
> 
>  	/* Don't suspend PHY if the attched netdev parent may wakeup.
>  	 * The parent may point to a PCI device, as in tg3 driver.
> --
> 2.1.0

Acked-by: Fugang Duan <B38611@freescale.com>
Tested-by: Fugang Duan <B38611@freescale.com>
