From: Max Schwarz <max.schwarz@online.de>
Subject: Re: [PATCH 2/2] arc_emac: add clock handling
Date: Wed, 23 Apr 2014 23:39:26 +0200
Message-ID: <4205607.5MYc0BULKu@typ>
References: <2479609.DglKFY1Bsn@phil> <21852569.EUtq6ntoe2@phil>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>
To: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.13]:55536 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbaDWVjs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 17:39:48 -0400
In-Reply-To: <21852569.EUtq6ntoe2@phil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 April 2014 at 14:24:55, Heiko St=FCbner wrote:
> This adds ability for the arc_emac to really handle its supplying clo=
ck.
> To get the needed clock-frequency either a real clock or the previous
> clock-frequency property must be provided.
>=20
> Signed-off-by: Heiko Stuebner <heiko@sntech.de>
> ---
>  Documentation/devicetree/bindings/net/arc_emac.txt | 12 +++++-
>  drivers/net/ethernet/arc/emac.h                    |  2 +
>  drivers/net/ethernet/arc/emac_main.c               | 46
> ++++++++++++++++------ 3 files changed, 47 insertions(+), 13 deletion=
s(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/arc_emac.txt
> b/Documentation/devicetree/bindings/net/arc_emac.txt index 7fbb027..a=
1d71eb
> 100644
> --- a/Documentation/devicetree/bindings/net/arc_emac.txt
> +++ b/Documentation/devicetree/bindings/net/arc_emac.txt
> @@ -4,11 +4,15 @@ Required properties:
>  - compatible: Should be "snps,arc-emac"
>  - reg: Address and length of the register set for the device
>  - interrupts: Should contain the EMAC interrupts
> -- clock-frequency: CPU frequency. It is needed to calculate and set =
polling
> -period of EMAC.
>  - max-speed: see ethernet.txt file in the same directory.
>  - phy: see ethernet.txt file in the same directory.
>=20
> +Clock handling:
> +The clock frequency is needed to calculate and set polling period of=
 EMAC.
> +It must be provided by one of:
> +- clock-frequency: CPU frequency.
> +- clocks: reference to the clock supplying the EMAC.
> +
>  Child nodes of the driver are the individual PHY devices connected t=
o the
>  MDIO bus. They must have a "reg" property given the PHY address on t=
he MDIO
> bus.
>=20
> @@ -19,7 +23,11 @@ Examples:
>  		reg =3D <0xc0fc2000 0x3c>;
>  		interrupts =3D <6>;
>  		mac-address =3D [ 00 11 22 33 44 55 ];
> +
>  		clock-frequency =3D <80000000>;
> +		/* or */
> +		clocks =3D <&emac_clock>;
> +
>  		max-speed =3D <100>;
>  		phy =3D <&phy0>;
>=20
> diff --git a/drivers/net/ethernet/arc/emac.h
> b/drivers/net/ethernet/arc/emac.h index 928fac6..53f85bf 100644
> --- a/drivers/net/ethernet/arc/emac.h
> +++ b/drivers/net/ethernet/arc/emac.h
> @@ -11,6 +11,7 @@
>  #include <linux/dma-mapping.h>
>  #include <linux/netdevice.h>
>  #include <linux/phy.h>
> +#include <linux/clk.h>
>=20
>  /* STATUS and ENABLE Register bit masks */
>  #define TXINT_MASK	(1<<0)	/* Transmit interrupt */
> @@ -131,6 +132,7 @@ struct arc_emac_priv {
>  	struct mii_bus *bus;
>=20
>  	void __iomem *regs;
> +	struct clk *clk;
>=20
>  	struct napi_struct napi;
>  	struct net_device_stats stats;
> diff --git a/drivers/net/ethernet/arc/emac_main.c
> b/drivers/net/ethernet/arc/emac_main.c index 0cba97a..68f8ad5 100644
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -649,13 +649,6 @@ static int arc_emac_probe(struct platform_device=
 *pdev)
> return -ENODEV;
>  	}
>=20
> -	/* Get CPU clock frequency from device tree */
> -	if (of_property_read_u32(pdev->dev.of_node, "clock-frequency",
> -				 &clock_frequency)) {
> -		dev_err(&pdev->dev, "failed to retrieve <clock-frequency> from dev=
ice
> tree\n"); -		return -EINVAL;
> -	}
> -
>  	/* Get IRQ from device tree */
>  	irq =3D irq_of_parse_and_map(pdev->dev.of_node, 0);
>  	if (!irq) {
> @@ -687,13 +680,32 @@ static int arc_emac_probe(struct platform_devic=
e
> *pdev) }
>  	dev_dbg(&pdev->dev, "Registers base address is 0x%p\n", priv->regs)=
;
>=20
> +	priv->clk =3D of_clk_get(pdev->dev.of_node, 0);
> +	if (IS_ERR(priv->clk)) {
> +		/* Get CPU clock frequency from device tree */
> +		if (of_property_read_u32(pdev->dev.of_node, "clock-frequency",
> +					&clock_frequency)) {
> +			dev_err(&pdev->dev, "failed to retrieve <clock-frequency> from de=
vice
> tree\n"); +			err =3D -EINVAL;
> +			goto out_netdev;
> +		}
> +	} else {
> +		err =3D clk_prepare_enable(priv->clk);
> +		if (err) {
> +			dev_err(&pdev->dev, "failed to enable clock\n");
> +			goto out_clkget;
> +		}
> +
> +		clock_frequency =3D clk_get_rate(priv->clk);
> +	}
> +
>  	id =3D arc_reg_get(priv, R_ID);
>=20
>  	/* Check for EMAC revision 5 or 7, magic number */
>  	if (!(id =3D=3D 0x0005fd02 || id =3D=3D 0x0007fd02)) {
>  		dev_err(&pdev->dev, "ARC EMAC not detected, id=3D0x%x\n", id);
>  		err =3D -ENODEV;
> -		goto out_netdev;
> +		goto out_clken;
>  	}
>  	dev_info(&pdev->dev, "ARC EMAC detected with id: 0x%x\n", id);
>=20
> @@ -708,7 +720,7 @@ static int arc_emac_probe(struct platform_device =
*pdev)
>  			       ndev->name, ndev);
>  	if (err) {
>  		dev_err(&pdev->dev, "could not allocate IRQ\n");
> -		goto out_netdev;
> +		goto out_clken;
>  	}
>=20
>  	/* Get MAC address from device tree */
> @@ -729,7 +741,7 @@ static int arc_emac_probe(struct platform_device =
*pdev)
>  	if (!priv->rxbd) {
>  		dev_err(&pdev->dev, "failed to allocate data buffers\n");
>  		err =3D -ENOMEM;
> -		goto out_netdev;
> +		goto out_clken;
>  	}
>=20
>  	priv->txbd =3D priv->rxbd + RX_BD_NUM;
> @@ -741,7 +753,7 @@ static int arc_emac_probe(struct platform_device =
*pdev)
>  	err =3D arc_mdio_probe(pdev, priv);
>  	if (err) {
>  		dev_err(&pdev->dev, "failed to probe MII bus\n");
> -		goto out_netdev;
> +		goto out_clken;
>  	}
>=20
>  	priv->phy_dev =3D of_phy_connect(ndev, phy_node, arc_emac_adjust_li=
nk, 0,
> @@ -772,6 +784,12 @@ out_netif_api:
>  	priv->phy_dev =3D NULL;
>  out_mdio:
>  	arc_mdio_remove(priv);
> +out_clken:
> +	if (IS_ERR(priv->clk))
> +		clk_disable_unprepare(priv->clk);

Should be if (!IS_ERR(priv->clk)).

> +out_clkget:
> +	if (IS_ERR(priv->clk))
> +		clk_put(priv->clk);

The same.

>  out_netdev:
>  	free_netdev(ndev);
>  	return err;
> @@ -787,6 +805,12 @@ static int arc_emac_remove(struct platform_devic=
e
> *pdev) arc_mdio_remove(priv);
>  	unregister_netdev(ndev);
>  	netif_napi_del(&priv->napi);
> +
> +	if (!IS_ERR(priv->clk)) {
> +		clk_disable_unprepare(priv->clk);
> +		clk_put(priv->clk);
> +	}
> +
>  	free_netdev(ndev);
>=20
>  	return 0;

Apart from that, the clock stuff has been

Tested-by: Max Schwarz <max.schwarz@online.de>
(on the same hardware, radxa rock)

Cheers,
  Max
