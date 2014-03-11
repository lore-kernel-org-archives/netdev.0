From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5] can: xilinx CAN controller support.
Date: Tue, 11 Mar 2014 13:48:54 +0100
Message-ID: <531F0636.4050608@pengutronix.de>
References: <5254bfec-c6fd-4681-a34d-706d51e60fbb@VA3EHSMHS004.ehs.local> <531DD2C4.5060109@pengutronix.de> <f1e2f08f-05fc-40d3-8437-4c6817d631cb@AM1EHSMHS010.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="suD0cqq8XrJJSQR2n7FFKTRB1voTPGq4L"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	Michal Simek <michals@xilinx.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"fengguang.wu@intel.com" <fengguang.wu@intel.com>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <f1e2f08f-05fc-40d3-8437-4c6817d631cb@AM1EHSMHS010.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--suD0cqq8XrJJSQR2n7FFKTRB1voTPGq4L
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 03/11/2014 01:34 PM, Appana Durga Kedareswara Rao wrote:

>>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig index
>>> 9e7d95d..b180239 100644
>>> --- a/drivers/net/can/Kconfig
>>> +++ b/drivers/net/can/Kconfig
>>> @@ -125,6 +125,13 @@ config CAN_GRCAN
>>>       endian syntheses of the cores would need some modifications on
>>>       the hardware level to work.
>>>
>>> +config CAN_XILINXCAN
>>> +   tristate "Xilinx CAN"
>>> +   depends on ARCH_ZYNQ || MICROBLAZE
>>
>> Is Zynq multiarch already?
> Discussions are going on this
> So the final thing that Fengguang ( fengguang.wu@intel.com)
> Proposed is
>         config CAN_XILINX
>         tristate "Xilinx CAN"
>         depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
>         depends on COMMON_CLK && HAS_MMIO  # whatever you need for othe=
r architectures

> Are you Ok for this?

You have to fill the 2nd depends on with some sane values, though.

[...]

>>> +/**
>>> + * struct xcan_priv - This definition define CAN driver instance
>>> + * @can:                   CAN private data structure.
>>> + * @tx_head:                       Tx CAN packets ready to send on t=
he
>> queue
>>> + * @tx_tail:                       Tx CAN packets successfully sende=
d on the
>> queue
>>> + * @tx_max:                        Maximum number packets the driver=
 can
>> send
>>> + * @napi:                  NAPI structure
>>> + * @read_reg:                      For reading data from CAN registe=
rs
>>> + * @write_reg:                     For writing data to CAN registers=

>>> + * @dev:                   Network device data structure
>>> + * @reg_base:                      Ioremapped address to registers
>>> + * @irq_flags:                     For request_irq()
>>> + * @aperclk:                       Pointer to struct clk
>>> + * @devclk:                        Pointer to struct clk
>>> + */
>>> +struct xcan_priv {
>>> +   struct can_priv can;
>>> +   unsigned int tx_head;
>>> +   unsigned int tx_tail;
>>> +   u32 tx_max;
>> Please make it an unsigned int, too.
>>
> Ok
>=20
>=20
>>> +   struct napi_struct napi;
>>> +   u32 (*read_reg)(const struct xcan_priv *priv, enum xcan_reg reg);=

>>> +   void (*write_reg)(const struct xcan_priv *priv, enum xcan_reg reg=
,
>>> +                   u32 val);
>>> +   struct net_device *dev;
>>> +   void __iomem *reg_base;
>>> +   unsigned long irq_flags;
>>> +   struct clk *aperclk;
>>> +   struct clk *devclk;
>>
>> Please rename the clock variables to match the names in the DT.
>>
> The clock names are different for axi CAN and CANPS case.
> So will make them as busclk and devclk
> Are you ok with this?

Why not "ref_clk" and "aper_clk" as used in the DT?

>>> +};
>>> +

[...]

>>> +/**
>>> + * xcan_chip_start - This the drivers start routine
>>> + * @ndev:  Pointer to net_device structure
>>> + *
>>> + * This is the drivers start routine.
>>> + * Based on the State of the CAN device it puts
>>> + * the CAN device into a proper mode.
>>> + *
>>> + * Return: 0 on success and failure value on error  */ static int
>>> +xcan_chip_start(struct net_device *ndev) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   u32 err;
>>> +   unsigned long timeout;
>>> +
>>> +   /* Check if it is in reset mode */
>>> +   err =3D set_reset_mode(ndev);
>>> +   if (err < 0)
>>> +           return err;
>>> +
>>> +   err =3D xcan_set_bittiming(ndev);
>>> +   if (err < 0)
>>> +           return err;
>>> +
>>> +   /* Enable interrupts */
>>> +   priv->write_reg(priv, XCAN_IER_OFFSET, XCAN_INTR_ALL);
>>> +
>>> +   /* Check whether it is loopback mode or normal mode  */
>>> +   if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
>>> +           /* Put device into loopback mode */
>>> +           priv->write_reg(priv, XCAN_MSR_OFFSET,
>> XCAN_MSR_LBACK_MASK);
>>> +   else
>>> +           /* The device is in normal mode */
>>> +           priv->write_reg(priv, XCAN_MSR_OFFSET, 0);
>>> +
>>> +   if (priv->can.state =3D=3D CAN_STATE_STOPPED) {
>>
>> Your device is in stopped mode, add you go though set_reset_mode()
>> already.
>=20
> Will remove this if condition I putted this condition here because in s=
et_reset_mode we are putting the
> Device state in Stopped state.

So the device is in CAN_STATE_STOPPED, as this code just went through
set_reset_mode() some lines ago. so it makes no sense to check if it
(still) is (the code runs serialized here).

>>
>>> +           /* Enable Xilinx CAN */
>>> +           priv->write_reg(priv, XCAN_SRR_OFFSET,
>> XCAN_SRR_CEN_MASK);
>>> +           priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>> +           timeout =3D jiffies + XCAN_TIMEOUT;
>>> +           if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
>>> +                   while ((priv->read_reg(priv, XCAN_SR_OFFSET)
>>> +                                   & XCAN_SR_LBACK_MASK) =3D=3D 0) {=

>>> +                           if (time_after(jiffies, timeout)) {
>>> +                                   netdev_warn(ndev,
>>> +                                           "timedout for loopback
>> mode\n");
>>> +                                   return -ETIMEDOUT;
>>> +                           }
>>> +                           usleep_range(500, 10000);
>>> +                   }
>>> +           } else {
>>> +                   while ((priv->read_reg(priv, XCAN_SR_OFFSET)
>>> +                                   & XCAN_SR_NORMAL_MASK) =3D=3D 0) =
{
>>> +                           if (time_after(jiffies, timeout)) {
>>> +                                   netdev_warn(ndev,
>>> +                                           "timedout for normal
>> mode\n");
>>> +                                   return -ETIMEDOUT;
>>> +                           }
>>> +                           usleep_range(500, 10000);
>>> +                   }
>>> +           }
>>> +           netdev_dbg(ndev, "status:#x%08x\n",
>>> +                           priv->read_reg(priv, XCAN_SR_OFFSET));
>>> +   }
>>> +   priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>>> +   return 0;
>>> +}

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--suD0cqq8XrJJSQR2n7FFKTRB1voTPGq4L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMfBjYACgkQjTAFq1RaXHO3HgCdFPWt6PHc7gid8sZPzLaNhqLd
sZwAn2WC+wU7uWOFt3SmS65rFhhX9zpL
=DirU
-----END PGP SIGNATURE-----

--suD0cqq8XrJJSQR2n7FFKTRB1voTPGq4L--
