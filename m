From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH] phy: add the IC+ IP1001 driver
Date: Fri, 10 Dec 2010 17:48:53 -0600
Message-ID: <AANLkTimd4GFzaC9m2Wg4h=ey33gr3shj+v5RQJbOG1Qz@mail.gmail.com>
References: <1291885513-32766-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34389 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756211Ab0LJXsy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 18:48:54 -0500
Received: by wwa36 with SMTP id 36so4326320wwa.1
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 15:48:53 -0800 (PST)
In-Reply-To: <1291885513-32766-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 9, 2010 at 3:05 AM, Peppe CAVALLARO <peppe.cavallaro@st.com=
> wrote:
> This patch adds the IC+ IP1001 (Gigabit Ethernet Transceiver) driver.
> I've had to add an additional delay (2ns) to adjust RX clock phase at
> GMII/ RGMII interface (according to the PHY data-sheet). This helps t=
o
> have the RGMII working on some ST platforms.
>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
> =A0drivers/net/phy/Kconfig =A0| =A0 =A02 +-
> =A0drivers/net/phy/icplus.c | =A0 59 ++++++++++++++++++++++++++++++++=
++++++++++----
> =A02 files changed, 55 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index cb3d13e..35fda5a 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -64,7 +64,7 @@ config BCM63XX_PHY
> =A0config ICPLUS_PHY
> =A0 =A0 =A0 =A0tristate "Drivers for ICPlus PHYs"
> =A0 =A0 =A0 =A0---help---
> - =A0 =A0 =A0 =A0 Currently supports the IP175C PHY.
> + =A0 =A0 =A0 =A0 Currently supports the IP175C and IP1001 PHYs.
>
> =A0config REALTEK_PHY
> =A0 =A0 =A0 =A0tristate "Drivers for Realtek PHYs"
> diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
> index c1d2d25..9a09e24 100644
> --- a/drivers/net/phy/icplus.c
> +++ b/drivers/net/phy/icplus.c
> @@ -30,7 +30,7 @@
> =A0#include <asm/irq.h>
> =A0#include <asm/uaccess.h>
>
> -MODULE_DESCRIPTION("ICPlus IP175C PHY driver");
> +MODULE_DESCRIPTION("ICPlus IP175C/IC1001 PHY drivers");
> =A0MODULE_AUTHOR("Michael Barkowski");
> =A0MODULE_LICENSE("GPL");
>
> @@ -89,6 +89,33 @@ static int ip175c_config_init(struct phy_device *p=
hydev)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static int ip1001_config_init(struct phy_device *phydev)
> +{
> + =A0 =A0 =A0 int err, value;
> +
> + =A0 =A0 =A0 /* Software Reset PHY */
> + =A0 =A0 =A0 value =3D phy_read(phydev, MII_BMCR);
> + =A0 =A0 =A0 value |=3D BMCR_RESET;
> + =A0 =A0 =A0 err =3D phy_write(phydev, MII_BMCR, value);
> + =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> +
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 value =3D phy_read(phydev, MII_BMCR);
> + =A0 =A0 =A0 } while (value & BMCR_RESET);
> +
> + =A0 =A0 =A0 /* Additional delay (2ns) used to adjust RX clock phase
> + =A0 =A0 =A0 =A0* at GMII/ RGMII interface */
> + =A0 =A0 =A0 value =3D phy_read(phydev, 16);
> + =A0 =A0 =A0 value |=3D 0x3;


Two things:
1) Is this generic for all instances of this PHY, or only for the
particular board you're using?  Frequently these sorts of clock
adjustments are done to deal with skew on the lines between the PHY
and the NIC.  If this is a board-specific change, consider using a
board fixup or passing a flag from the NIC.

2) Can we have names for register 16 and value 0x3?

Andy
