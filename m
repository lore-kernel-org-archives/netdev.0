From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH 3/3] phylib: shared interrupts support for Marvell
	88E1121R PHY
Date: Tue, 17 Feb 2009 19:12:09 -0600
Message-ID: <2acbd3e40902171712i558fb5dbyf95c1910e1912685@mail.gmail.com>
References: <1234817631-7981-1-git-send-email-agust@denx.de>
	 <1234817631-7981-2-git-send-email-agust@denx.de>
	 <1234817631-7981-3-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anatolij Gustschin <agust@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:43450 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbZBRBMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 20:12:10 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1213263yxm.1
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 17:12:09 -0800 (PST)
In-Reply-To: <1234817631-7981-3-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 16, 2009 at 2:53 PM, Anatolij Gustschin <agust@denx.de> wrote:
> If this PHY is hardware-configured for shared MDC/MDIO,
> P0_INT pin will indicate interrupts for both ports.
> This patch extends 88E1121R code for handling interrupt
> events over shared interrupt pin.
>
> Signed-off-by: Anatolij Gustschin <agust@denx.de>
> ---
>  drivers/net/phy/marvell.c |   86 +++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 86 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index 1d282b0..64f22b9 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -74,6 +74,7 @@
>  #define MII_88E1121_PHY_LED_DEF                0x0030
>
>  #define MII_88E1121_PHY_PAGE           22
> +#define MII_88E1121_PHY_GLOBAL_IRQS    23
>
>  #define MII_M1011_PHY_STATUS           0x11
>  #define MII_M1011_PHY_STATUS_1000      0x8000
> @@ -88,6 +89,10 @@ MODULE_DESCRIPTION("Marvell PHY driver");
>  MODULE_AUTHOR("Andy Fleming");
>  MODULE_LICENSE("GPL");
>
> +struct m88e1121_priv {
> +       unsigned long irq_map;
> +} m88e1121_drv_data;
> +


This is bad, and doesn't work.  This is the sort of reason we may need
a container struct for multi-PHY devices.  The problem, here, is that
you have made it impossible for one system to have more than one
m88e1121, and I consider that unacceptable from a design perspective.


>  static int marvell_ack_interrupt(struct phy_device *phydev)
>  {
>        int err;
> @@ -257,6 +262,36 @@ static int m88e1111_config_init(struct phy_device *phydev)
>        return 0;
>  }
>
> +static int m88e1121_config_init(struct phy_device *phydev)
> +{
[snip]

> +
> +       if (phydev->drv->flags & PHY_HAS_INTERRUPT)
> +               set_bit(phydev->addr, &priv->irq_map);

Also, there's a race condition, here if two things try to modify this
value at once.

> +
> +       if ((bus->irq[0] != -1) && (bus->irq[1] != -1)
> +           && (bus->irq[0] == bus->irq[1])) {


This is no good.  I feel certain that the Marvell PHY in question
doesn't have the PHY addresses hard-coded like this.  If some board
designer decides not to start the PHY addresses at 0 (as they should,
since PHY addr 0 is technically reserved), this code will fail.


> +               phydev->drv->flags |= PHY_INTERRUPTS_SHARED;


You can't do this.  You are modifying the *global* driver structure
for the entire system based on the runtime parameters of 2 devices.
But, as mentioned before, I don't think you need this bit, anyway.



> +static int m88e1121_interrupt_src(struct phy_device *phydev)
> +{
> +       struct m88e1121_priv *priv = phydev->priv;
> +       struct mii_bus *bus = phydev->bus;
> +       int src, port = -1;
> +
> +       src = phy_read(phydev, MII_88E1121_PHY_GLOBAL_IRQS);
> +       if (src < 0)
> +               return src;
> +
> +       if (src & 1)
> +               port = 0;
> +       else if (src & 2)
> +               port = 1;


Again, these are hard-coded, and that seems wrong, to me.  I don't
know what happens if you pinstrap the 1121 to a different address, but
I'm positive it would break this code.

If we decide to go with a function that reports whether *this* PHY
generated the interrupt, you would want to do something more like:

if (src & (1 << phydev->addr))
        return 1;
else
        return 0;


> +
> +       if (port != -1 && phydev->addr != port
> +           && !(priv->irq_map & (1 << port))
> +           && bus->phy_map[port]) {
> +               /*
> +                * Interrupt not for this port and
> +                * interface is down, so we disable
> +                * this interrupt and ack it.
> +                */


There are other ways to determine whether the PHY has been brought up
(eg, reading the state field).  However, I'm fairly convinced that if
this happens, it's a bug.  You've got an interrupt being generated by
a device that has no driver running?  Please make sure that doesn't
happen, instead.


> +               BUG_ON(in_interrupt());
> +
> +               mutex_lock(&bus->mdio_lock);
> +               /* Disable the interrupts */
> +               src = bus->write(bus, bus->phy_map[port]->addr,
> +                                MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
> +
> +               /* Clear the interrupts */
> +               src = bus->read(bus, bus->phy_map[port]->addr,
> +                               MII_M1011_IEVENT);
> +               mutex_unlock(&bus->mdio_lock);
> +               if (src < 0)
> +                       return src;
> +       }
> +
> +       return port;
> +}
> +
> +static void m88e1121_remove(struct phy_device *phydev)
> +{
> +       struct m88e1121_priv *priv = phydev->priv;
> +
> +       clear_bit(phydev->addr, &priv->irq_map);
> +}


I don't think you need irq_map at all.  If you do, you should base it
on whether the interrupt is enabled on that PHY, rather than whether
the PHY is up (which is determined by phydev->state).

However, you will need to come up with some way for the chip-global
information to be dealt with.  If someone builds a system with
multiple 1121s, you need a way for the probe function to allocate
global information for each 1121, and then associate each specific PHY
with the correct instance.  I think, for this problem, we don't need
the phylib to have a notion of multi-phy devices, but it will be
interesting to see how they evolve as time goes on.


Andy
