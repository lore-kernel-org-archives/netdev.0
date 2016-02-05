From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v2] net: ethernet: support "fixed-link" DT key/node on nb8800 driver
Date: Fri, 05 Feb 2016 13:58:30 +0000
Message-ID: <yw1xsi17gsxl.fsf@unicorn.mansr.com>
References: <56B4A445.7080402@laposte.net>
	<yw1x1t8ri8dz.fsf@unicorn.mansr.com> <56B4A877.4020800@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: Sebastian Frias <sf84@laposte.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B4A877.4020800@laposte.net> (Sebastian Frias's message of
	"Fri, 05 Feb 2016 14:49:43 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Frias <sf84@laposte.net> writes:

> Signed-off-by: Sebastian Frias <sf84@laposte.net>
> ---
>  drivers/net/ethernet/aurora/nb8800.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/aurora/nb8800.c
> b/drivers/net/ethernet/aurora/nb8800.c
> index ecc4a33..dd7bedc 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -1462,9 +1462,18 @@ static int nb8800_probe(struct platform_device=
 *pdev)
>
>  	priv->phy_node =3D of_parse_phandle(pdev->dev.of_node, "phy-handle"=
, 0);
>  	if (!priv->phy_node) {
> -		dev_err(&pdev->dev, "no PHY specified\n");
> -		ret =3D -ENODEV;
> -		goto err_free_bus;
> +		if (of_phy_is_fixed_link(pdev->dev.of_node)) {
> +			ret =3D of_phy_register_fixed_link(pdev->dev.of_node);
> +			if (ret < 0) {
> +				dev_err(&pdev->dev, "bad fixed-link spec\n");
> +				goto err_free_bus;
> +			}
> +			priv->phy_node =3D of_node_get(pdev->dev.of_node);
> +		} else {
> +			dev_err(&pdev->dev, "no PHY specified\n");
> +			ret =3D -ENODEV;
> +			goto err_free_bus;
> +		}
>  	}

Maybe it would be clearer to reduce the if() nesting a bit, like this
for instance:

	if (of_phy_is_fixed_link(pdev->dev.of_node)) {
		ret =3D of_phy_register_fixed_link(pdev->dev.of_node);
		if (ret < 0) {
			dev_err(&pdev->dev, "bad fixed-link spec\n");
			goto err_free_bus;
		}
		priv->phy_node =3D of_node_get(pdev->dev.of_node);
	}

	if (!priv->phy_node)
		priv->phy_node =3D of_parse_phandle(pdev->dev.of_node,
						  "phy-handle", 0);

	if (!priv->phy_node) {
		dev_err(&pdev->dev, "no PHY specified\n");
		ret =3D -ENODEV;
		goto err_free_bus;
	}


--=20
M=E5ns Rullg=E5rd
