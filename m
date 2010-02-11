From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] [V4] net: emaclite: adding MDIO and phy lib support
Date: Thu, 11 Feb 2010 14:16:07 -0700
Message-ID: <fa686aa41002111316n13ce32bcyc8e5186c4776e1b4@mail.gmail.com>
References: <e9ea9b59-9435-4712-a854-2c46046eb08e@SG2EHSMHS005.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	jwboyer@linux.vnet.ibm.com, john.williams@petalogix.com,
	Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>
To: John Linn <john.linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f189.google.com ([209.85.211.189]:51483 "EHLO
	mail-yw0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756986Ab0BKVQ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 16:16:27 -0500
Received: by ywh27 with SMTP id 27so1524591ywh.1
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2010 13:16:27 -0800 (PST)
In-Reply-To: <e9ea9b59-9435-4712-a854-2c46046eb08e@SG2EHSMHS005.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 11, 2010 at 1:52 PM, John Linn <john.linn@xilinx.com> wrote=
:
> These changes add MDIO and phy lib support to the driver as the
> IP core now supports the MDIO bus.
>
> The MDIO bus and phy are added as a child to the emaclite in the devi=
ce
> tree as illustrated below.
>
> mdio {
> =A0 =A0 =A0 =A0#address-cells =3D <1>;
> =A0 =A0 =A0 =A0#size-cells =3D <0>;
> =A0 =A0 =A0 =A0phy0: phy@7 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compatible =3D "marvell,88e1111";
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D <7>;
> =A0 =A0 =A0 =A0} ;
> }
>
> Signed-off-by: Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>
> Signed-off-by: John Linn <john.linn@xilinx.com>
>
> ---
>
> V2 - updated it for Grant's comments, except I couldn't find any tabs
> converted to white space issue, let's see if V2 has it also
>
> V3 - updated it for Grant's comments, aded mutex release when a timeo=
ut
> happens, and added Grant's acked by.
>
> V4 - removed the mutex as I realized the higher layer mdio calls alre=
ady
> use a mutex and there are no internal calls to the driver except in o=
pen.
> Didn't integrate John W comments since releasing mutex wasn't needed.
> ---
> =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0drivers/net/xilinx_emaclite.c | =A0381 +++++++++++++++++++++++++++=
+++++++++-----
> =A02 files changed, 339 insertions(+), 43 deletions(-)
[...]
> =A0/**
> =A0* xemaclite_open - Open the network device
> =A0* @dev: =A0 =A0 =A0 Pointer to the network device
> =A0*
> =A0* This function sets the MAC address, requests an IRQ and enables =
interrupts
> =A0* for the Emaclite device and starts the Tx queue.
> + * It also connects to the phy device, if MDIO is included in Emacli=
te device.
> =A0*/
> =A0static int xemaclite_open(struct net_device *dev)
> =A0{
> @@ -656,14 +924,50 @@ static int xemaclite_open(struct net_device *de=
v)
> =A0 =A0 =A0 =A0/* Just to be safe, stop the device first */
> =A0 =A0 =A0 =A0xemaclite_disable_interrupts(lp);
>
> + =A0 =A0 =A0 if (lp->phy_node) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 bmcr;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_dev =3D of_phy_connect(lp->ndev=
, lp->phy_node,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0xemaclite_adjust_link, 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0PHY_INTERFACE_MODE_MII);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!lp->phy_dev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&lp->ndev->dev,=
 "of_phy_connect() failed\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* EmacLite doesn't support giga-bit sp=
eeds */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_dev->supported &=3D (PHY_BASIC_=
=46EATURES);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_dev->advertising =3D lp->phy_de=
v->supported;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Don't advertise 1000BASE-T Full/Half=
 duplex speeds */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 xemaclite_mdio_write(lp->mii_bus, lp->p=
hy_dev->addr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0MII_CTRL1000, 0x00);

Wait!  No.  This is wrong.  Sorry, I was all ready to ack this patch,
but I just realized what was bothering me (and I should have clued
into it earlier).  The driver cannot assume that the PHY is on an
xemaclite MDIO bus.  It might be on a GPIO driven MDIO bus.  Or
something else.  Calling xemaclite_mdio_{write,read} is not the right
thing to do here.

Instead, the driver should call the phy library function
phy_write(lp->phy_dev, MII_CTRL1000, 0);  The phylib code will route
it to the correct mdio bus.  It also takes care of grabbing the mutex
lock.

Make this fix, and then I can ack the driver.

Cheers,
g.


--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
