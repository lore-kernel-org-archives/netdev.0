From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH] net/macb: add support for resetting PHY using GPIO
Date: Fri, 11 Dec 2015 10:40:22 +0100
Message-ID: <87wpsl727t.fsf@free-electrons.com>
References: <1449683383-5022-1-git-send-email-gregory.clement@free-electrons.com>
	<20151210073756.GA11966@pengutronix.de>
	<871tau8hpj.fsf@free-electrons.com>
	<20151211084630.GW11966@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151211084630.GW11966@pengutronix.de> (Sascha Hauer's message
	of "Fri, 11 Dec 2015 09:46:30 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sascha,
=20
 On ven., d=C3=A9c. 11 2015, Sascha Hauer <s.hauer@pengutronix.de> wrot=
e:

> On Thu, Dec 10, 2015 at 04:08:08PM +0100, Gregory CLEMENT wrote:
>> Hi Sascha,
>> =20
>>  On jeu., d=C3=A9c. 10 2015, Sascha Hauer <s.hauer@pengutronix.de> w=
rote:
>>=20
>> > Hi Gregory,
>> >
>> > On Wed, Dec 09, 2015 at 06:49:43PM +0100, Gregory CLEMENT wrote:
>> >> With device tree it is no more possible to reset the PHY at board
>> >> level. Furthermore, doing in the driver allow to power down the P=
HY when
>> >> the network interface is no more used.
>> >>=20
>> >> The patch introduces a new optional property "phy-reset-gpio" ins=
pired
>> >> from the one use for the FEC.
>> >
>> > I don't think it's a good idea to further extend the usage of this
>> > binding. The driver should use the phy-handle property and
>> > of_phy_connect() which gives you a proper device node for the phy.=
 Then
>> > the phy device node should get the reset gpio. I know it's more wo=
rk,
>>=20
>> So you suggest to pass from this binding:
>> macb1: ethernet@fc028000 {
>> 	phy-mode =3D "rmii";
>> 	status =3D "okay";
>> 	#address-cells =3D <1>;
>> 	#size-cells =3D <0>;
>> 	status =3D "okay";
>> 	phy-reset-gpio =3D <&pioE 6 GPIO_ACTIVE_HIGH>;
>>=20
>> 	ethernet-phy@1 {
>> 		reg =3D <0x1>;
>> 		interrupt-parent =3D <&pioB>;
>> 		interrupts =3D <31 IRQ_TYPE_EDGE_FALLING>;
>>=20
>> 	};
>> };
>>=20
>> to this binding
>> macb1: ethernet@fc028000 {
>> 	phy-mode =3D "rmii";
>> 	status =3D "okay";
>> 	#address-cells =3D <1>;
>> 	#size-cells =3D <0>;
>> 	status =3D "okay";
>>=20
>> 	ethernet-phy@1 {
>> 		reg =3D <0x1>;
>> 		interrupt-parent =3D <&pioB>;
>> 		interrupts =3D <31 IRQ_TYPE_EDGE_FALLING>;
>>                 phy-reset-gpio =3D <&pioE 6 GPIO_ACTIVE_HIGH>;
>> 	};
>> };
>
> s/phy-reset-gpio/reset-gpios/, but yes.

So I took this way. But I had several issues. The first one was that to
be able to create a phy device it must first be detected by
get_phy_device from of_mdiobus_register_phy.  But in order to be
detected it must answer during the scan of the mii bus. That means we
can't bind the gpio to the device in order to use it because when we
need to manage the reset gpio the device is not yet created.

So I see 2 options:

- leaving the phy-reset-gpios property in the ethernet node. Thanks to
  this we can use the gpiod functions, and it is still possible to use
  manage the power management.

- using a reset-gpios property inside the phy node. But then the only
  solution to get a reference on it, will be to use
  of_get_named_gpio. All the gpiod functions need a reference to the
  device that we won't have at this point. Also we will only be able to
  power up the reset, but we won't have any reference to it latter.

Thanks,

Gregory

>
> I had assumed you do not use a phy description in the device tree at =
all
> since the macb driver doesn't use of_phy_connect(). Apparently there =
are
> other possibilities to connect the phy device nodes with the phys
>
> Sascha
>
> --=20
> Pengutronix e.K.                           |                         =
    |
> Industrial Linux Solutions                 | http://www.pengutronix.d=
e/  |
> Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0=
    |
> Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5=
555 |

--=20
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
