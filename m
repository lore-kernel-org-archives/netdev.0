From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next v2 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Thu, 23 Mar 2017 08:22:33 +0100
Message-ID: <20170323072233.GA10076@lunn.ch>
References: <1490088910-19405-1-git-send-email-sean.wang@mediatek.com>
 <1490088910-19405-6-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland-5wv7dgnIgG8@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org,
 f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1490088910-19405-6-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

> +static int
> +mt7623_trgmii_write(struct mt7530_priv *priv,  u32 reg, u32 val)
> +{
> +	int ret;
> +
> +	ret =  regmap_write(priv->ethernet, TRGMII_BASE(reg), val);
> +	if (ret < 0)
> +		dev_err(priv->dev,
> +			"failed to priv write register\n");
> +	return ret;
> +}
> +
> +static u32
> +mt7623_trgmii_read(struct mt7530_priv *priv, u32 reg)
> +{
> +	int ret;
> +	u32 val;
> +
> +	ret = regmap_read(priv->ethernet, TRGMII_BASE(reg), &val);
> +	if (ret < 0) {
> +		dev_err(priv->dev,
> +			"failed to priv read register\n");
> +		return ret;
> +	}
> +
> +	return val;
> +}

Hi Sean

These appear to be the only two accessors which use the regmap.

> +static int
> +mt7530_regmap_read(void *ctx, uint32_t reg, uint32_t *val)
> +{
> +	struct mt7530_priv *priv = (struct mt7530_priv *)ctx;
> +
> +	/* BIT(15) is used as indication for pseudo registers
> +	 * which would be translated into the general MDIO
> +	 * access to leverage the unique regmap sys interface.
> +	 */
> +	if (reg & BIT(15))
> +		*val = mdiobus_read_nested(priv->bus,
> +					   (reg & 0xf00) >> 8,
> +					   (reg & 0xff) >> 2);
> +	else
> +		*val = mt7530_read(priv, reg);
> +
> +	return 0;
> +}

.....

> +static const struct regmap_range mt7530_readable_ranges[] = {
> +	regmap_reg_range(0x0000, 0x00ac), /* Global control */
> +	regmap_reg_range(0x2000, 0x202c), /* Port Control - P0 */
> +	regmap_reg_range(0x2100, 0x212c), /* Port Control - P1 */
> +	regmap_reg_range(0x2200, 0x222c), /* Port Control - P2 */
> +	regmap_reg_range(0x2300, 0x232c), /* Port Control - P3 */
> +	regmap_reg_range(0x2400, 0x242c), /* Port Control - P4 */
> +	regmap_reg_range(0x2500, 0x252c), /* Port Control - P5 */
> +	regmap_reg_range(0x2600, 0x262c), /* Port Control - P6 */
> +	regmap_reg_range(0x30e0, 0x30f8), /* Port MAC - SYS */
> +	regmap_reg_range(0x3000, 0x3014), /* Port MAC - P0 */
> +	regmap_reg_range(0x3100, 0x3114), /* Port MAC - P1 */
> +	regmap_reg_range(0x3200, 0x3214), /* Port MAC - P2*/
> +	regmap_reg_range(0x3300, 0x3314), /* Port MAC - P3*/
> +	regmap_reg_range(0x3400, 0x3414), /* Port MAC - P4 */
> +	regmap_reg_range(0x3500, 0x3514), /* Port MAC - P5 */
> +	regmap_reg_range(0x3600, 0x3614), /* Port MAC - P6 */
> +	regmap_reg_range(0x4000, 0x40d4), /* MIB - P0 */
> +	regmap_reg_range(0x4100, 0x41d4), /* MIB - P1 */
> +	regmap_reg_range(0x4200, 0x42d4), /* MIB - P2 */
> +	regmap_reg_range(0x4300, 0x43d4), /* MIB - P3 */
> +	regmap_reg_range(0x4400, 0x44d4), /* MIB - P4 */
> +	regmap_reg_range(0x4500, 0x45d4), /* MIB - P5 */
> +	regmap_reg_range(0x4600, 0x46d4), /* MIB - P6 */
> +	regmap_reg_range(0x4fe0, 0x4ff4), /* SYS */
> +	regmap_reg_range(0x7000, 0x700c), /* SYS 2 */
> +	regmap_reg_range(0x7018, 0x7028), /* SYS 3 */
> +	regmap_reg_range(0x7800, 0x7830), /* SYS 4 */
> +	regmap_reg_range(0x7a00, 0x7a7c), /* TRGMII */
> +	regmap_reg_range(0x8000, 0x8078), /* Psedo address for Phy - P0 */
> +	regmap_reg_range(0x8100, 0x8178), /* Psedo address for Phy - P1 */
> +	regmap_reg_range(0x8200, 0x8278), /* Psedo address for Phy - P2 */
> +	regmap_reg_range(0x8300, 0x8378), /* Psedo address for Phy - P3 */
> +	regmap_reg_range(0x8400, 0x8478), /* Psedo address for Phy - P4 */
> +};

It looks like your regmap accessor are only used for 0x7a00 to 0x7a7c.

It is not clear why you even bother with a regmap. If you have it, why
not use it for all registers within the regmap?

    Andrew
