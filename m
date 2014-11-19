From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 7/7] stmmac: dwmac-sti: Pass sysconfig register offset
 via syscon dt property.
Date: Wed, 19 Nov 2014 08:51:02 +0000
Message-ID: <20141119085102.GH13959@x1>
References: <1416385632-5832-1-git-send-email-peter.griffin@linaro.org>
 <1416385632-5832-8-git-send-email-peter.griffin@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	srinivas.kandagatla@gmail.com, maxime.coquelin@st.com,
	patrice.chotard@st.com, peppe.cavallaro@st.com, kishon@ti.com,
	arnd@arndb.de, netdev@vger.kernel.org, devicetree@vger.kernel.org,
	alexandre.torgue@st.com
To: Peter Griffin <peter.griffin@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416385632-5832-8-git-send-email-peter.griffin@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Nov 2014, Peter Griffin wrote:

> Based on Arnds review comments here https://lkml.org/lkml/2014/11/13/=
161,
> we should not be mixing address spaces in the reg property like this =
driver
> currently does. This patch updates the driver, dt docs and also the e=
xisting
> dt nodes to pass the sysconfig offset in the syscon dt property.
>=20
> This patch breaks DT compatibility! But this platform is considered W=
IP, and is only
> used by a few developers who are upstreaming support for it. This cha=
nge has been done
> as a single atomic commit to ensure it is bisectable.
>=20
> Signed-off-by: Peter Griffin <peter.griffin@linaro.org>
> ---
>  Documentation/devicetree/bindings/net/sti-dwmac.txt | 14 +++++------=
---
>  arch/arm/boot/dts/stih415.dtsi                      | 12 ++++++-----=
-
>  arch/arm/boot/dts/stih416.dtsi                      | 12 ++++++-----=
-
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c     | 13 +++++++----=
--
>  4 files changed, 24 insertions(+), 27 deletions(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/sti-dwmac.txt b/Do=
cumentation/devicetree/bindings/net/sti-dwmac.txt
> index 6762a6b..d05c1e1 100644
> --- a/Documentation/devicetree/bindings/net/sti-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/sti-dwmac.txt
> @@ -9,14 +9,10 @@ The device node has following properties.
>  Required properties:
>   - compatible	: Can be "st,stih415-dwmac", "st,stih416-dwmac",
>     "st,stih407-dwmac", "st,stid127-dwmac".
> - - reg : Offset of the glue configuration register map in system
> -   configuration regmap pointed by st,syscon property and size.

Looks like you are removing the reg property description completely?

> - - st,syscon : Should be phandle to system configuration node which
> -   encompases this glue registers.
> + - st,syscon : Should be phandle/offset pair. The phandle to the sys=
con node which
> +   encompases the glue register, and the offset of the control regis=
ter.
>   - st,gmac_en: this is to enable the gmac into a dedicated sysctl co=
ntrol
>     register available on STiH407 SoC.
> - - sti-ethconf: this is the gmac glue logic register to enable the G=
MAC,
> -   select among the different modes and program the clk retiming.
>   - pinctrl-0: pin-control for all the MII mode supported.

[...]

> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
> @@ -123,7 +123,7 @@ struct sti_dwmac {
>  	bool ext_phyclk;	/* Clock from external PHY */
>  	u32 tx_retime_src;	/* TXCLK Retiming*/
>  	struct clk *clk;	/* PHY clock */
> -	int ctrl_reg;		/* GMAC glue-logic control register */
> +	u32 ctrl_reg;		/* GMAC glue-logic control register */
>  	int clk_sel_reg;	/* GMAC ext clk selection register */
>  	struct device *dev;
>  	struct regmap *regmap;
> @@ -286,11 +286,6 @@ static int sti_dwmac_parse_data(struct sti_dwmac=
 *dwmac,
>  	if (!np)
>  		return -EINVAL;
> =20
> -	res =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, "sti-eth=
conf");
> -	if (!res)
> -		return -ENODATA;
> -	dwmac->ctrl_reg =3D res->start;
> -
>  	/* clk selection from extra syscfg register */
>  	dwmac->clk_sel_reg =3D -ENXIO;
>  	res =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, "sti-clk=
conf");
> @@ -301,6 +296,12 @@ static int sti_dwmac_parse_data(struct sti_dwmac=
 *dwmac,
>  	if (IS_ERR(regmap))
>  		return PTR_ERR(regmap);
> =20
> +	err =3D of_property_read_u32_index(np, "st,syscon", 1, &dwmac->ctrl=
_reg);

A few platforms have this format for sysconn now.  We should toy with
the idea of either making this a standard call, and/or defining '1'.

> +	if (err) {
> +		dev_err(dev, "Can't get sysconfig ctrl offset (%d)\n", err);
> +		return err;
> +	}
> +
>  	dwmac->dev =3D dev;
>  	dwmac->interface =3D of_get_phy_mode(np);
>  	dwmac->regmap =3D regmap;

--=20
Lee Jones
Linaro STMicroelectronics Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
