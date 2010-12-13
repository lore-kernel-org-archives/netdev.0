From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] phy: add the IC+ IP1001 driver
Date: Mon, 13 Dec 2010 14:34:04 +0100
Message-ID: <4D0620CC.8080208@st.com>
References: <1291885513-32766-1-git-send-email-peppe.cavallaro@st.com>
 <AANLkTimd4GFzaC9m2Wg4h=ey33gr3shj+v5RQJbOG1Qz@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:37098 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757878Ab0LMNj6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 08:39:58 -0500
In-Reply-To: <AANLkTimd4GFzaC9m2Wg4h=ey33gr3shj+v5RQJbOG1Qz@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2010 12:48 AM, Andy Fleming wrote:
>
> On Thu, Dec 9, 2010 at 3:05 AM, Peppe CAVALLARO
> <peppe.cavallaro@st.com> wrote:
> > This patch adds the IC+ IP1001 (Gigabit Ethernet Transceiver) driver.
> > I've had to add an additional delay (2ns) to adjust RX clock phase at
> > GMII/ RGMII interface (according to the PHY data-sheet). This helps to
> > have the RGMII working on some ST platforms.
> >
> > Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> > ---
> >  drivers/net/phy/Kconfig  |    2 +-
> >  drivers/net/phy/icplus.c |   59
> ++++++++++++++++++++++++++++++++++++++++++----
> >  2 files changed, 55 insertions(+), 6 deletions(-)
> >
> > diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> > index cb3d13e..35fda5a 100644
> > --- a/drivers/net/phy/Kconfig
> > +++ b/drivers/net/phy/Kconfig
> > @@ -64,7 +64,7 @@ config BCM63XX_PHY
> >  config ICPLUS_PHY
> >        tristate "Drivers for ICPlus PHYs"
> >        ---help---
> > -         Currently supports the IP175C PHY.
> > +         Currently supports the IP175C and IP1001 PHYs.
> >
> >  config REALTEK_PHY
> >        tristate "Drivers for Realtek PHYs"
> > diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
> > index c1d2d25..9a09e24 100644
> > --- a/drivers/net/phy/icplus.c
> > +++ b/drivers/net/phy/icplus.c
> > @@ -30,7 +30,7 @@
> >  #include <asm/irq.h>
> >  #include <asm/uaccess.h>
> >
> > -MODULE_DESCRIPTION("ICPlus IP175C PHY driver");
> > +MODULE_DESCRIPTION("ICPlus IP175C/IC1001 PHY drivers");
> >  MODULE_AUTHOR("Michael Barkowski");
> >  MODULE_LICENSE("GPL");
> >
> > @@ -89,6 +89,33 @@ static int ip175c_config_init(struct phy_device
> *phydev)
> >        return 0;
> >  }
> >
> > +static int ip1001_config_init(struct phy_device *phydev)
> > +{
> > +       int err, value;
> > +
> > +       /* Software Reset PHY */
> > +       value = phy_read(phydev, MII_BMCR);
> > +       value |= BMCR_RESET;
> > +       err = phy_write(phydev, MII_BMCR, value);
> > +       if (err < 0)
> > +               return err;
> > +
> > +       do {
> > +               value = phy_read(phydev, MII_BMCR);
> > +       } while (value & BMCR_RESET);
> > +
> > +       /* Additional delay (2ns) used to adjust RX clock phase
> > +        * at GMII/ RGMII interface */
> > +       value = phy_read(phydev, 16);
> > +       value |= 0x3;
>
>
> Two things:
> 1) Is this generic for all instances of this PHY, or only for the
> particular board you're using?  Frequently these sorts of clock
> adjustments are done to deal with skew on the lines between the PHY
> and the NIC.  If this is a board-specific change, consider using a
> board fixup or passing a flag from the NIC.
>

After a call with the Hw validation,it seems that we
should only add this for the RGMII mode (not necessary for
GMII mode). From the data-sheet I cannot catch this detail.
>From the IC1001 data-sheer IIUC, it's to add input delay to
the GTX_CLK (2ns for GMII/RGMII and 4ns for MII).

I've tested, with this delay, both GMII and RGMII modes
without any issues.

Hmm, I could re-create the patch and only add the IP1001.
Timing adjustment, through R16 setting, could be in another patch.
Let me know.

> 2) Can we have names for register 16 and value 0x3?
>

Yes, we can.

Regards,
Peppe

>
> Andy
>
