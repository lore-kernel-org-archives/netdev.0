From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RESEND] [PATCH v4] sh_eth: update OF PHY registeration
Date: Wed, 26 Feb 2014 22:47:06 +0300
Message-ID: <530E44BA.8090209@cogentembedded.com>
References: <1393439008-26698-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	magnus.damn@opensource.se, horms@verge.net.au
To: Ben Dooks <ben.dooks@codethink.co.uk>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1393439008-26698-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/26/2014 09:23 PM, Ben Dooks wrote:

> If the sh_eth device is registered using OF, then the driver
> should call of_mdiobus_register() to register any PHYs connected
> to the system and of_phy_connect() to connect it.

    s/it/to PHY/?

> This ensures that any PHYs registered in the device tree are
> appropriately connected to the parent devices nodes so that
> the PHY drivers can access their OF properties.

> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

[...]

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index a18cbe1..e597698 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
> @@ -1761,20 +1762,36 @@ static void sh_eth_adjust_link(struct net_device *ndev)
>   /* PHY init function */
>   static int sh_eth_phy_init(struct net_device *ndev)
>   {
> +	struct device_node *np = ndev->dev.parent->of_node;
>   	struct sh_eth_private *mdp = netdev_priv(ndev);
> -	char phy_id[MII_BUS_ID_SIZE + 3];
>   	struct phy_device *phydev = NULL;
>
> -	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
> -		 mdp->mii_bus->id, mdp->phy_id);
> -
>   	mdp->link = 0;
>   	mdp->speed = 0;
>   	mdp->duplex = -1;
>
>   	/* Try connect to PHY */
> -	phydev = phy_connect(ndev, phy_id, sh_eth_adjust_link,
> -			     mdp->phy_interface);
> +	if (np) {
> +		struct device_node *pn;
> +
> +		pn = of_parse_phandle(np, "phy-handle", 0);
> +		phydev = of_phy_connect(ndev, pn,
> +					sh_eth_adjust_link, 0,

    Hm, that 0 corresponds to 'flags' parameter which is not used. I wonder if 
that was intentional...

> +					mdp->phy_interface);
> +
> +		if (!phydev)
> +			phydev = ERR_PTR(-ENOENT);
> +	} else {
> +		char phy_id[MII_BUS_ID_SIZE + 3];
> +
> +		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
> +			 mdp->mii_bus->id, mdp->phy_id);
> +
> +		/* Try connect to PHY */

    Now this comment is kinda duplicate... :-)

> +		phydev = phy_connect(ndev, phy_id, sh_eth_adjust_link,
> +				     mdp->phy_interface);
> +	}
> +
>   	if (IS_ERR(phydev)) {
>   		dev_err(&ndev->dev, "phy_connect failed\n");

    I have asked to adjust the message a bit as we now have 2 alternate calls 
that can fail...

>   		return PTR_ERR(phydev);
> @@ -2638,15 +2655,23 @@ static int sh_mdio_init(struct net_device *ndev, int id,
>   		goto out_free_bus;
>   	}
>
> -	for (i = 0; i < PHY_MAX_ADDR; i++)
> -		mdp->mii_bus->irq[i] = PHY_POLL;
> -	if (pd->phy_irq > 0)
> -		mdp->mii_bus->irq[pd->phy] = pd->phy_irq;
> +	if (ndev->dev.parent->of_node) {
> +		ret = of_mdiobus_register(mdp->mii_bus,
> +					  ndev->dev.parent->of_node);
> +	} else {
> +		for (i = 0; i < PHY_MAX_ADDR; i++)
> +			mdp->mii_bus->irq[i] = PHY_POLL;
> +		if (pd->phy_irq > 0)
> +			mdp->mii_bus->irq[pd->phy] = pd->phy_irq;
>
> -	/* register mdio bus */
> -	ret = mdiobus_register(mdp->mii_bus);
> -	if (ret)
> +		/* register mdio bus */
> +		ret = mdiobus_register(mdp->mii_bus);
> +	}

    That looks much better, thanks.

> +

    Although I'd have avoided the empty line...

> +	if (ret) {
> +		dev_err(&ndev->dev, "failed to register mdio\n");

    That function generally avoids error messages, no? Although all errors are 
-ENOMEM type and that's supposed to cause kernel to loudly curse anyway... 
Well, let it be if you want.

>   		goto out_free_bus;
> +	}

WBR, Sergei

