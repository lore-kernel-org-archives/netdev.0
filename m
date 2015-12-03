From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [v9, 3/6] fsl/fman: Add FMan MAC support
Date: Thu, 3 Dec 2015 23:42:03 +0100
Message-ID: <CA++eYdvVe1qDhpZ8NGVnHeefBnpWMUyn4CFBu8g6TERAr-4B8Q@mail.gmail.com>
References: <1449127157-9400-1-git-send-email-igal.liberman@freescale.com>
	<1449127157-9400-4-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org,
	scottwood@freescale.com, madalin.bucur@freescale.com,
	pebolle@tiscali.nl, joakim.tjernlund@transmode.se,
	ppc@mindchasers.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	Kapil Juneja <Kapil.Juneja@freescale.com>
To: igal.liberman@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35280 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbbLCWmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 17:42:04 -0500
Received: by wmuu63 with SMTP id u63so40594168wmu.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 14:42:03 -0800 (PST)
In-Reply-To: <1449127157-9400-4-git-send-email-igal.liberman@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* PHY Control Register */
> +#define PHY_CR_PHY_RESET       0x8000
> +#define PHY_CR_SPEED0          0x2000
> +#define PHY_CR_ANE             0x1000
> +#define PHY_CR_RESET_AN                0x0200
> +#define PHY_CR_FULLDUPLEX      0x0100
> +#define PHY_CR_SPEED1          0x0040

Reuse defines in mii.h? BMCR_SPEED1000, BMCR_*, etc.

> +#define PHY_TBICON_SRESET      0x8000
> +#define PHY_TBICON_CLK_SEL     0x0020

This is similarly named TBICON_CLK_SELECT in freescale/gianfar.h.
Perhaps use the same names, and if possible, use a shared header file?

It would be nice to define all bits of the TBI registers, if only for
completeness. Maybe along with a succinct description, e.g., that
"sreset" means soft reset. (Or just call it TBICON_SOFT_RESET.)

> +/* MII Configuration Control Memory Map Registers */
> +struct dtsec_mii_regs {
> +/* dTSEC Memory Map registers */
> +struct dtsec_regs {
> +static int mii_write_reg(struct fman_mac *dtsec, u8 addr, u8 reg, u16 data)
> +static int mii_read_reg(struct fman_mac *dtsec, u8 addr, u8 reg, u16 *data)

Any chance this patch overlaps significantly with fsl_pq_mdio.c?

http://lxr.free-electrons.com/source/drivers/net/ethernet/freescale/fsl_pq_mdio.c?v=4.3#L44
fsl_pq_mdio_write(),
fsl_pq_mdio_read(),
etc.

> +       if (dtsec->phy_if == PHY_INTERFACE_MODE_SGMII) {
> +               u16 tmp_reg16;
> +
> +               /* Configure the TBI PHY Control Register */
> +               tmp_reg16 = PHY_TBICON_CLK_SEL | PHY_TBICON_SRESET;
> +               mii_write_reg(dtsec, (u8)dtsec_drv_param->tbipa, 17,
> +                             tmp_reg16);
> +
> +               tmp_reg16 = PHY_TBICON_CLK_SEL;
> +               mii_write_reg(dtsec, (u8)dtsec_drv_param->tbipa, 17,
> +                             tmp_reg16);
> +
> +               tmp_reg16 =
> +                   (PHY_CR_PHY_RESET | PHY_CR_ANE | PHY_CR_FULLDUPLEX |
> +                    PHY_CR_SPEED1);
> +               mii_write_reg(dtsec, (u8)dtsec_drv_param->tbipa, 0, tmp_reg16);
> +
> +               if (dtsec->basex_if)
> +                       tmp_reg16 = PHY_TBIANA_1000X;
> +               else
> +                       tmp_reg16 = PHY_TBIANA_SGMII;
> +               mii_write_reg(dtsec, (u8)dtsec_drv_param->tbipa, 4, tmp_reg16);
> +
> +               tmp_reg16 =
> +                   (PHY_CR_ANE | PHY_CR_RESET_AN | PHY_CR_FULLDUPLEX |
> +                    PHY_CR_SPEED1);
> +
> +               mii_write_reg(dtsec, (u8)dtsec_drv_param->tbipa, 0, tmp_reg16);
> +       }

Afaik, programming the TBI belongs in a separate PHY driver. See
drivers/net/phy/phy_device.c.

The same logic applies to gfar_configure_serdes() and uec_configure_serdes().

> +/* Internal PHY Registers - SGMII */
> +#define PHY_SGMII_CR_RESET_AN           0x0200
> +#define PHY_SGMII_CR_AN_ENABLE          0x1000

This namespace duplicates the intention of PHY_CR_*? (Which in turn
duplicated BMCR_*, ..)
