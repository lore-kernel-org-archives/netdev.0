From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v5] can: xilinx CAN controller support.
Date: Mon, 10 Mar 2014 16:04:51 +0100
Message-ID: <531DD493.3030306@monstr.eu>
References: <5254bfec-c6fd-4681-a34d-706d51e60fbb@VA3EHSMHS004.ehs.local> <531DD2C4.5060109@pengutronix.de>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="28123aDbw4E4PW0pDFFffk3LqkX9oJfrI"
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <531DD2C4.5060109@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--28123aDbw4E4PW0pDFFffk3LqkX9oJfrI
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Marc,

On 03/10/2014 03:57 PM, Marc Kleine-Budde wrote:
> On 03/04/2014 02:20 PM, Kedareswara rao Appana wrote:
>> This patch adds xilinx CAN controller support.
>> This driver supports both ZYNQ CANPS and Soft IP
>> AXI CAN controller.
>>
>> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
>> ---
>> This patch is rebased on the 3.14 rc5 kernel.
>> Changes for v5:
>> - Updated the driver with the review comments.
>> - Remove the check for the tx fifo full interrupt condition
>>   form Tx interrupt routine as we are checking it in the _xmit
>>   routine.
>> - Clearing the txok interrupt in the tx interrupt routine for
>>   every Tx can frame.
>> Changes for v4:
>> - Added check for the tx fifo full interrupt condition in
>>   Tx interrupt routine.
>> - Added be iohelper functions.
>> - Moved the clock enable/disable to probe/remove because of
>>   Added big endian support for AXI CAN controller case(reading
>>   a register during probe for that we need to enable clock).
>> Changes for v3:
>> - Updated the driver with the review comments.
>> - Modified the tranmit logic as per Marc suggestion.
>> - Enabling the clock when the interface is up to reduce the
>>   Power consumption.
>> Changes for v2:
>> - Updated with the review comments.
>> - Removed the unnecessary debug prints.
>> - include tx,rx fifo depths in ZYNQ CANPS case also.
>> ---
>>  .../devicetree/bindings/net/can/xilinx_can.txt     |   45 +
>>  drivers/net/can/Kconfig                            |    7 +
>>  drivers/net/can/Makefile                           |    1 +
>>  drivers/net/can/xilinx_can.c                       | 1195 +++++++++++=
+++++++++
>>  4 files changed, 1248 insertions(+), 0 deletions(-)
>>  create mode 100644 Documentation/devicetree/bindings/net/can/xilinx_c=
an.txt
>>  create mode 100644 drivers/net/can/xilinx_can.c
>>
>> diff --git a/Documentation/devicetree/bindings/net/can/xilinx_can.txt =
b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
>> new file mode 100644
>> index 0000000..0e57103
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
>> @@ -0,0 +1,45 @@
>> +Xilinx Axi CAN/Zynq CANPS controller Device Tree Bindings
>> +---------------------------------------------------------
>> +
>> +Required properties:
>> +- compatible		: Should be "xlnx,zynq-can-1.00.a" for Zynq CAN
>> +			  controllers and "xlnx,axi-can-1.00.a" for Axi CAN
>> +			  controllers.
>> +- reg			: Physical base address and size of the Axi CAN/Zynq
>> +			  CANPS registers map.
>> +- interrupts		: Property with a value describing the interrupt
>> +			  number.
>> +- interrupt-parent	: Must be core interrupt controller
>> +- clock-names		: List of input clock names - "ref_clk", "aper_clk"
>> +			  (See clock bindings for details. Two clocks are
>> +			   required for Zynq CAN. For Axi CAN
>> +			   case it is one(ref_clk)).
>> +- clocks		: Clock phandles (see clock bindings for details).
>> +- tx-fifo-depth		: Can Tx fifo depth.
>> +- rx-fifo-depth		: Can Rx fifo depth.
>> +
>> +
>> +Example:
>> +
>> +For Zynq CANPS Dts file:
>> +	zynq_can_0: zynq-can@e0008000 {
>> +			compatible =3D "xlnx,zynq-can-1.00.a";
>> +			clocks =3D <&clkc 19>, <&clkc 36>;
>> +			clock-names =3D "ref_clk", "aper_clk";
>> +			reg =3D <0xe0008000 0x1000>;
>> +			interrupts =3D <0 28 4>;
>> +			interrupt-parent =3D <&intc>;
>> +			tx-fifo-depth =3D <0x40>;
>> +			rx-fifo-depth =3D <0x40>;
>> +		};
>> +For Axi CAN Dts file:
>> +	axi_can_0: axi-can@40000000 {
>> +			compatible =3D "xlnx,axi-can-1.00.a";
>> +			clocks =3D <&clkc 0>;
>> +			clock-names =3D "ref_clk" ;
>> +			reg =3D <0x40000000 0x10000>;
>> +			interrupt-parent =3D <&intc>;
>> +			interrupts =3D <0 59 1>;
>> +			tx-fifo-depth =3D <0x40>;
>> +			rx-fifo-depth =3D <0x40>;
>> +		};
>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
>> index 9e7d95d..b180239 100644
>> --- a/drivers/net/can/Kconfig
>> +++ b/drivers/net/can/Kconfig
>> @@ -125,6 +125,13 @@ config CAN_GRCAN
>>  	  endian syntheses of the cores would need some modifications on
>>  	  the hardware level to work.
>> =20
>> +config CAN_XILINXCAN
>> +	tristate "Xilinx CAN"
>> +	depends on ARCH_ZYNQ || MICROBLAZE
>=20
> Is Zynq multiarch already?

let me just answer this. Zynq is device with hardcoded dual arm cortex-a9=
 + some IPs
and programmable logic.
It means if you add Microblaze to PL or another CPU then you get multi ar=
chitecture setup.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--28123aDbw4E4PW0pDFFffk3LqkX9oJfrI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlMd1JQACgkQykllyylKDCEt9gCfUBv4Gadu/W/Y8D3k3145gW7H
kKYAoI7QyXZKjK9hbvwovkpq3EyWYr0a
=vpLT
-----END PGP SIGNATURE-----

--28123aDbw4E4PW0pDFFffk3LqkX9oJfrI--
