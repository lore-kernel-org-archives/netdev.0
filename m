From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/4] net: phy: at803x: Allow specifying the RGMII RX clock
 delay via phy mode
Date: Sat, 26 Dec 2015 19:28:21 -0800
Message-ID: <567F5AD5.40004@gmail.com>
References: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
 <1451089622-14957-3-git-send-email-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: slash.tmp@free.fr
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:35536 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574AbbL0D2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2015 22:28:23 -0500
Received: by mail-ob0-f170.google.com with SMTP id 18so216158265obc.2
        for <netdev@vger.kernel.org>; Sat, 26 Dec 2015 19:28:23 -0800 (PST)
In-Reply-To: <1451089622-14957-3-git-send-email-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/12/2015 16:27, Martin Blumenstingl a =C3=A9crit :
> at803x currently automatically enables the RGMII TX clock delay when =
the
> phy interface mode is PHY_INTERFACE_MODE_RGMII_TXID. The same should =
be
> done when PHY_INTERFACE_MODE_RGMII_ID is specified.
> Use a similar logic to enable the RGMII RX clock delay as well.
> at803x_context_{save,restore} were not touched because these are only
> used on AR8030 which is a RMII phy (RGMII clock delays are irrelevant=
).

=46ew nits below

>=20
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.co=
m>
> ---
>  drivers/net/phy/at803x.c | 78 ++++++++++++++++++++++++++++++++++++++=
++++------
>  1 file changed, 69 insertions(+), 9 deletions(-)
>=20
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index f566b6e..0b262a2 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -36,8 +36,10 @@
>  #define AT803X_INSR				0x0013
>  #define AT803X_DEBUG_ADDR			0x1D
>  #define AT803X_DEBUG_DATA			0x1E
> -#define AT803X_DEBUG_SYSTEM_MODE_CTRL		0x05
> -#define AT803X_DEBUG_RGMII_TX_CLK_DLY		BIT(8)
> +#define AT803X_DEBUG_REG_0			0x00

Seems like the previous register name might have been clearer that the
new name you suggest here, did that come from a different GPL tarball o=
r
documentation?

> +#define AT803X_DEBUG_RX_CLK_DLY_EN		BIT(15)
> +#define AT803X_DEBUG_REG_5			0x05
> +#define AT803X_DEBUG_TX_CLK_DLY_EN		BIT(8)
> =20
>  #define ATH8030_PHY_ID 0x004dd076
>  #define ATH8031_PHY_ID 0x004dd074
> @@ -61,6 +63,61 @@ struct at803x_context {
>  	u16 led_control;
>  };
> =20
> +static int _at803x_debug_reg_read(struct phy_device *phydev, u16 reg=
)
> +{
> +	int ret;
> +
> +	ret =3D phy_write(phydev, AT803X_DEBUG_ADDR, reg);
> +	if (ret < 0)
> +		return ret;
> +
> +	return phy_read(phydev, AT803X_DEBUG_DATA);
> +}
> +
> +static int at803x_debug_reg_mask(struct phy_device *phydev, u16 reg,
> +				 u16 clear, u16 set)
> +{
> +	u16 val;
> +	int ret;
> +
> +	mutex_lock(&phydev->lock);

I do not think the mutex is required here, did you encounter a case
where the PHY state machine was improperly calling into these?

> +
> +	ret =3D _at803x_debug_reg_read(phydev, reg);
> +	if (ret < 0)
> +		goto out;
> +
> +	val =3D ret & 0xffff;
> +	val &=3D ~clear;
> +	val |=3D set;
> +
> +	ret =3D phy_write(phydev, AT803X_DEBUG_DATA, val);
> +
> +out:
> +	mutex_unlock(&phydev->lock);
> +
> +	return ret;
> +}
> +
> +static int at803x_set_rx_delay(struct phy_device *phydev, bool enabl=
e)
> +{
> +	if (enable)
> +		return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_0, 0,
> +					     AT803X_DEBUG_RX_CLK_DLY_EN);
> +	else
> +		return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_0,
> +					     AT803X_DEBUG_RX_CLK_DLY_EN, 0);

The enable argument is always true right now, are we potentially missin=
g
an initialization to false for the non-delay case (RGMII and RGMII_TXID
cases)?

> +}
> +
> +static int at803x_set_tx_delay(struct phy_device *phydev, bool enabl=
e)
> +{
> +	if (enable)
> +		return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_5, 0,
> +					     AT803X_DEBUG_TX_CLK_DLY_EN);
> +	else
> +		return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_5,
> +					     AT803X_DEBUG_TX_CLK_DLY_EN, 0);
> +}

Same here

> +
>  /* save relevant PHY registers to private copy */
>  static void at803x_context_save(struct phy_device *phydev,
>  				struct at803x_context *context)
> @@ -217,14 +274,17 @@ static int at803x_config_init(struct phy_device=
 *phydev)
>  	if (ret < 0)
>  		return ret;
> =20
> -	if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII_TXID) {
> -		ret =3D phy_write(phydev, AT803X_DEBUG_ADDR,
> -				AT803X_DEBUG_SYSTEM_MODE_CTRL);
> -		if (ret)
> +	if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII_RXID ||
> +			phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII_ID) {
> +		ret =3D at803x_set_rx_delay(phydev, true);
> +		if (ret < 0)
>  			return ret;
> -		ret =3D phy_write(phydev, AT803X_DEBUG_DATA,
> -				AT803X_DEBUG_RGMII_TX_CLK_DLY);
> -		if (ret)
> +	}
> +
> +	if (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII_TXID ||
> +			phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII_ID) {
> +		ret =3D at803x_set_tx_delay(phydev, true);
> +		if (ret < 0)
>  			return ret;
>  	}
> =20
>=20


--=20
=46lorian
