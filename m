From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] Allow MACB to connect to a higher addresses PHY.
Date: Tue, 30 Mar 2010 08:41:43 -0600
Message-ID: <fa686aa41003300741x5ef9bdbpf56133304fe4d6e6@mail.gmail.com>
References: <1269943112-6975-1-git-send-email-anders.darander@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>,
	Maxime Bizon <mbizon@freebox.fr>,
	Anders Darander <ad@datarespons.se>,
	David Daney <ddaney@caviumnetworks.com>,
	Sekhar Nori <nsekhar@ti.com>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Anders Darander <anders.darander@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:62821 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144Ab0C3OmG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 10:42:06 -0400
In-Reply-To: <1269943112-6975-1-git-send-email-anders.darander@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 3:58 AM, Anders Darander
<anders.darander@gmail.com> wrote:
> From: Anders Darander <ad@datarespons.se>
>
> Using the Atmel MACB together with an integrated switch, can make onl=
y port 1
> work. This is caused by macb_mii_probe trying to attach the MAC to th=
e first
> PHY, which often is on one of the external ports.
>
> E.g. the Micrel KSZ8873 connects to the MAC on port 3, thus phy_addr =
should be
> set to 3.
>
> Signed-off-by: Anders Darander <ad@datarespons.se>

Hi Anders,

I understand what you are trying to do, but this is the wrong way to
go about it.  Hard coding it into Kconfig breaks multiplatform
kernels.  Besides, systems may have more than one physical MDIO bus.
This patch would make CONFIG_SWITCHING_PHY_ADDR the only address
accessible on all MDIO busses.

Nak.

The right thing to do is to add a runtime configuration option (ie.
kernel parameter or platform data) to the mac driver to specify
exactly which PHY address it is supposed to use.

g.

> ---
> =A0drivers/net/phy/Kconfig =A0 =A0 =A0| =A0 19 ++++++++++++++++++-
> =A0drivers/net/phy/phy_device.c | =A0 =A04 ++++
> =A02 files changed, 22 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index fc5938b..64aa003 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -15,11 +15,28 @@ if PHYLIB
>
> =A0comment "MII PHY device drivers"
>
> +config SWITCHING_PHY
> + =A0 =A0 =A0 bool "An Ethernet switch is connected to the MAC"
> + =A0 =A0 =A0 depends on MACB
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 If an Ethernet switch is connected to the MAC, it
> + =A0 =A0 =A0 =A0 is quite common to have the connection on a port
> + =A0 =A0 =A0 =A0 higher than the first port. This option allows to
> + =A0 =A0 =A0 =A0 select the desired port number
> +
> +config SWITCHING_PHY_ADDR
> + =A0 =A0 =A0 int "PHYA address"
> + =A0 =A0 =A0 depends on SWITCHING_PHY
> + =A0 =A0 =A0 default "3"
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 On e.g. the Micrel KSZ8873MLL, port 3 (and thus phy=
_addr
> + =A0 =A0 =A0 =A0 3) is the one connected to the MAC of the MCU.
> +
> =A0config MARVELL_PHY
> =A0 =A0 =A0 =A0tristate "Drivers for Marvell PHYs"
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0Currently has a driver for the 88E1011S
> -
> +
> =A0config DAVICOM_PHY
> =A0 =A0 =A0 =A0tristate "Drivers for Davicom PHYs"
> =A0 =A0 =A0 =A0---help---
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devic=
e.c
> index db17945..891bd0d 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -284,7 +284,11 @@ struct phy_device *phy_find_first(struct mii_bus=
 *bus)
> =A0{
> =A0 =A0 =A0 =A0int addr;
>
> +#ifdef CONFIG_SWITCHING_PHY
> + =A0 =A0 =A0 for (addr =3D CONFIG_SWITCHING_PHY_ADDR; addr < PHY_MAX=
_ADDR; addr++) {
> +#else
> =A0 =A0 =A0 =A0for (addr =3D 0; addr < PHY_MAX_ADDR; addr++) {
> +#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (bus->phy_map[addr])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return bus->phy_map[ad=
dr];
> =A0 =A0 =A0 =A0}
> --
> 1.7.0.3
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
