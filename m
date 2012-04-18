From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] NET: bcm63xx_enet: move phy_(dis)connect into probe/remove
Date: Wed, 18 Apr 2012 14:20:14 +0200
Message-ID: <4F8EB17E.4080401@openwrt.org>
References: <1334750537-14896-1-git-send-email-jonas.gorski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jonas Gorski <jonas.gorski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38393 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150Ab2DRMVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 08:21:44 -0400
Received: by bkcik5 with SMTP id ik5so5402913bkc.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 05:21:43 -0700 (PDT)
In-Reply-To: <1334750537-14896-1-git-send-email-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/18/12 14:02, Jonas Gorski a =C3=A9crit :
> Only connect/disconnect the phy during probe and remove, not during o=
pen
> and close. The phy seldom changes during the runtime, and disconnecti=
ng
> the phy during close will prevent the phy driver from keeping any
> configuration over a down/up cycle.
>
> Signed-off-by: Jonas Gorski<jonas.gorski@gmail.com>

Acked-by: Florian Fainelli <florian@openwrt.org>

> ---
>   drivers/net/ethernet/broadcom/bcm63xx_enet.c |   84 +++++++++++++--=
-----------
>   1 files changed, 41 insertions(+), 43 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/n=
et/ethernet/broadcom/bcm63xx_enet.c
> index c7ca7ec..2744cf0 100644
> --- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> +++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
> @@ -784,10 +784,8 @@ static int bcm_enet_open(struct net_device *dev)
>   	struct bcm_enet_priv *priv;
>   	struct sockaddr addr;
>   	struct device *kdev;
> -	struct phy_device *phydev;
>   	int i, ret;
>   	unsigned int size;
> -	char phy_id[MII_BUS_ID_SIZE + 3];
>   	void *p;
>   	u32 val;
>
> @@ -795,40 +793,10 @@ static int bcm_enet_open(struct net_device *dev=
)
>   	kdev =3D&priv->pdev->dev;
>
>   	if (priv->has_phy) {
> -		/* connect to PHY */
> -		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
> -			 priv->mii_bus->id, priv->phy_id);
> -
> -		phydev =3D phy_connect(dev, phy_id, bcm_enet_adjust_phy_link, 0,
> -				     PHY_INTERFACE_MODE_MII);
> -
> -		if (IS_ERR(phydev)) {
> -			dev_err(kdev, "could not attach to PHY\n");
> -			return PTR_ERR(phydev);
> -		}
> -
> -		/* mask with MAC supported features */
> -		phydev->supported&=3D (SUPPORTED_10baseT_Half |
> -				      SUPPORTED_10baseT_Full |
> -				      SUPPORTED_100baseT_Half |
> -				      SUPPORTED_100baseT_Full |
> -				      SUPPORTED_Autoneg |
> -				      SUPPORTED_Pause |
> -				      SUPPORTED_MII);
> -		phydev->advertising =3D phydev->supported;
> -
> -		if (priv->pause_auto&&  priv->pause_rx&&  priv->pause_tx)
> -			phydev->advertising |=3D SUPPORTED_Pause;
> -		else
> -			phydev->advertising&=3D ~SUPPORTED_Pause;
> -
> -		dev_info(kdev, "attached PHY at address %d [%s]\n",
> -			 phydev->addr, phydev->drv->name);
> -
> +		/* Reset state */
>   		priv->old_link =3D 0;
>   		priv->old_duplex =3D -1;
>   		priv->old_pause =3D -1;
> -		priv->phydev =3D phydev;
>   	}
>
>   	/* mask all interrupts and request them */
> @@ -838,7 +806,7 @@ static int bcm_enet_open(struct net_device *dev)
>
>   	ret =3D request_irq(dev->irq, bcm_enet_isr_mac, 0, dev->name, dev)=
;
>   	if (ret)
> -		goto out_phy_disconnect;
> +		return ret;
>
>   	ret =3D request_irq(priv->irq_rx, bcm_enet_isr_dma, IRQF_DISABLED,
>   			  dev->name, dev);
> @@ -1025,9 +993,6 @@ out_freeirq_rx:
>   out_freeirq:
>   	free_irq(dev->irq, dev);
>
> -out_phy_disconnect:
> -	phy_disconnect(priv->phydev);
> -
>   	return ret;
>   }
>
> @@ -1132,12 +1097,6 @@ static int bcm_enet_stop(struct net_device *de=
v)
>   	free_irq(priv->irq_rx, dev);
>   	free_irq(dev->irq, dev);
>
> -	/* release phy */
> -	if (priv->has_phy) {
> -		phy_disconnect(priv->phydev);
> -		priv->phydev =3D NULL;
> -	}
> -
>   	return 0;
>   }
>
> @@ -1714,6 +1673,8 @@ static int __devinit bcm_enet_probe(struct plat=
form_device *pdev)
>
>   	/* MII bus registration */
>   	if (priv->has_phy) {
> +		struct phy_device *phydev;
> +		char phy_id[MII_BUS_ID_SIZE + 3];
>
>   		priv->mii_bus =3D mdiobus_alloc();
>   		if (!priv->mii_bus) {
> @@ -1750,6 +1711,38 @@ static int __devinit bcm_enet_probe(struct pla=
tform_device *pdev)
>   			dev_err(&pdev->dev, "unable to register mdio bus\n");
>   			goto out_free_mdio;
>   		}
> +
> +		/* connect to PHY */
> +		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
> +			 priv->mii_bus->id, priv->phy_id);
> +
> +		phydev =3D phy_connect(dev, phy_id, bcm_enet_adjust_phy_link, 0,
> +				     PHY_INTERFACE_MODE_MII);
> +
> +		if (IS_ERR(phydev)) {
> +			dev_err(&pdev->dev, "could not attach to PHY\n");
> +			goto out_unregister_mdio;
> +		}
> +
> +		/* mask with MAC supported features */
> +		phydev->supported&=3D (SUPPORTED_10baseT_Half |
> +				      SUPPORTED_10baseT_Full |
> +				      SUPPORTED_100baseT_Half |
> +				      SUPPORTED_100baseT_Full |
> +				      SUPPORTED_Autoneg |
> +				      SUPPORTED_Pause |
> +				      SUPPORTED_MII);
> +		phydev->advertising =3D phydev->supported;
> +
> +		if (priv->pause_auto&&  priv->pause_rx&&  priv->pause_tx)
> +			phydev->advertising |=3D SUPPORTED_Pause;
> +		else
> +			phydev->advertising&=3D ~SUPPORTED_Pause;
> +
> +		dev_info(&pdev->dev, "attached PHY at address %d [%s]\n",
> +			 phydev->addr, phydev->drv->name);
> +
> +		priv->phydev =3D phydev;
>   	} else {
>
>   		/* run platform code to initialize PHY device */
> @@ -1795,6 +1788,9 @@ static int __devinit bcm_enet_probe(struct plat=
form_device *pdev)
>   	return 0;
>
>   out_unregister_mdio:
> +	if (!IS_ERR_OR_NULL(priv->phydev))
> +		phy_disconnect(priv->phydev);
> +
>   	if (priv->mii_bus) {
>   		mdiobus_unregister(priv->mii_bus);
>   		kfree(priv->mii_bus->irq);
> @@ -1845,6 +1841,8 @@ static int __devexit bcm_enet_remove(struct pla=
tform_device *pdev)
>   	enet_writel(priv, 0, ENET_MIISC_REG);
>
>   	if (priv->has_phy) {
> +		phy_disconnect(priv->phydev);
> +		priv->phydev =3D NULL;
>   		mdiobus_unregister(priv->mii_bus);
>   		kfree(priv->mii_bus->irq);
>   		mdiobus_free(priv->mii_bus);
