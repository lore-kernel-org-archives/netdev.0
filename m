From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v7 1/2] can: xilinx CAN controller support
Date: Tue, 22 Apr 2014 12:26:33 +0200
Message-ID: <535643D9.3070601@pengutronix.de>
References: <3e750ec3-9d47-4b4e-8173-56698ab19786@CH1EHSMHS029.ehs.local> <53562E7D.7090509@pengutronix.de> <957b07ca-f74c-47fb-963a-084710d48c5a@AM1EHSMHS014.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="in06KSvgRKo8LuCjWbJfVTDmAaa8UqkdO"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	Michal Simek <michals@xilinx.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <957b07ca-f74c-47fb-963a-084710d48c5a@AM1EHSMHS014.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--in06KSvgRKo8LuCjWbJfVTDmAaa8UqkdO
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 04/22/2014 12:06 PM, Appana Durga Kedareswara Rao wrote:

>> Meanwhile Thomas Gleixner put some effort into the c_can driver and
>> found some problems in most of the can driver. See comments inline.
>>
> Ok will look into that patches

I've commented the relevant parts of your patch. Although more
background information can be found in the c_can patches.

>>> +/**
>>> + * xcan_tx_interrupt - Tx Done Isr
>>> + * @ndev:  net_device pointer
>>> + * @isr:   Interrupt status register value
>>> + */
>>> +static void xcan_tx_interrupt(struct net_device *ndev, u32 isr) {
>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>> +   struct net_device_stats *stats =3D &ndev->stats;
>>> +
>>> +   while (priv->tx_head - priv->tx_tail > 0) {
>>> +           priv->write_reg(priv, XCAN_ICR_OFFSET,
>> XCAN_IXR_TXOK_MASK);
>>> +           if (!(isr & XCAN_IXR_TXOK_MASK))
>>> +                   break;
>>
>> This looks broken. I assume you have to issue the XCAN_IXR_TXOK_MASK-
>> write once per tx-completed CAN frame. If you enter this loop you writ=
e
>> once, then isr is read, then you write again and may exit this loop if=

>> XCAN_IXR_TXOK_MASK is not set anymore.

Let's assume you have put 3 CAN frames into the TX-queue and we're into
tx-complete interrupt for the first frame and the other 2 are still not
completed.

This means the while() loop is not terminated by (priv->tx_head -
priv->tx_tail > 0), as it can loop 3 times.

What happens is:

- priv->write_reg(priv, XCAN_ICR_OFFSET, XCAN_IXR_TXOK_MASK);
- if (!(isr & XCAN_IXR_TXOK_MASK)) -> no break
- can_get_echo_skb()
- ...
- isr =3D priv->read_reg(priv, XCAN_ISR_OFFSET);
- loop ->
- priv->write_reg(priv, XCAN_ICR_OFFSET, XCAN_IXR_TXOK_MASK);
- if (!(isr & XCAN_IXR_TXOK_MASK)) -> break

So you have 2x write_reg(priv, XCAN_ICR_OFFSET, XCAN_IXR_TXOK_MASK), but
only a single TX completed CAN frame.

>>
>=20
> I am entering into this Api only when I successfully transferred a fram=
e
> I didn't understand why the loop is broken?
> Could you please explain me a little bit in detail.
> I am clearing this interrupt XCAN_IXR_TXOK_MASK once I entered into thi=
s api
> And I am doing the rest of the thing what you explained above.

[...]

>>> +/**
>>> + * xcan_probe - Platform registration call
>>> + * @pdev:  Handle to the platform device structure
>>> + *
>>> + * This function does all the memory allocation and registration for=

>>> +the CAN
>>> + * device.
>>> + *
>>> + * Return: 0 on success and failure value on error  */ static int
>>> +xcan_probe(struct platform_device *pdev) {
>>> +   struct resource *res; /* IO mem resources */
>>> +   struct net_device *ndev;
>>> +   struct xcan_priv *priv;
>>> +   void __iomem *addr;
>>> +   int ret, rx_max, tx_max;
>>> +
>>> +   /* Get the virtual base address for the device */
>>> +   res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>> +   addr =3D devm_ioremap_resource(&pdev->dev, res);
>>> +   if (IS_ERR(addr)) {
>>> +           ret =3D PTR_ERR(addr);
>>> +           goto err;
>>> +   }
>>> +
>>> +   ret =3D of_property_read_u32(pdev->dev.of_node, "tx-fifo-depth",
>> &tx_max);
>>> +   if (ret < 0)
>>> +           goto err;
>>> +
>>> +   ret =3D of_property_read_u32(pdev->dev.of_node, "rx-fifo-depth",
>> &rx_max);
>>> +   if (ret < 0)
>>> +           goto err;
>>> +
>>> +   /* Create a CAN device instance */
>>> +   ndev =3D alloc_candev(sizeof(struct xcan_priv), tx_max);
>>> +   if (!ndev)
>>> +           return -ENOMEM;
>>> +
>>> +   priv =3D netdev_priv(ndev);
>>> +   priv->dev =3D ndev;
>>> +   priv->can.bittiming_const =3D &xcan_bittiming_const;
>>> +   priv->can.do_set_mode =3D xcan_do_set_mode;
>>> +   priv->can.do_get_berr_counter =3D xcan_get_berr_counter;
>>> +   priv->can.ctrlmode_supported =3D CAN_CTRLMODE_LOOPBACK |
>>> +                                   CAN_CTRLMODE_BERR_REPORTING;
>>> +   priv->reg_base =3D addr;
>>> +   priv->tx_max =3D tx_max;
>>> +
>>> +   /* Get IRQ for the device */
>>> +   ndev->irq =3D platform_get_irq(pdev, 0);
>>> +   ndev->flags |=3D IFF_ECHO;        /* We support local echo */
>>> +
>>> +   platform_set_drvdata(pdev, ndev);
>>> +   SET_NETDEV_DEV(ndev, &pdev->dev);
>>> +   ndev->netdev_ops =3D &xcan_netdev_ops;
>>> +
>>> +   /* Getting the CAN can_clk info */
>>> +   priv->can_clk =3D devm_clk_get(&pdev->dev, "can_clk");
>>> +   if (IS_ERR(priv->can_clk)) {
>>> +           dev_err(&pdev->dev, "Device clock not found.\n");
>>> +           ret =3D PTR_ERR(priv->can_clk);
>>> +           goto err_free;
>>> +   }
>>> +   /* Check for type of CAN device */
>>> +   if (of_device_is_compatible(pdev->dev.of_node,
>>> +                               "xlnx,zynq-can-1.0")) {
>>> +           priv->bus_clk =3D devm_clk_get(&pdev->dev, "pclk");
>>
>> I think it makes sense to have a single name for the second clock, so =
that
>> this if...else... is't needed at all.
>>
>  One of the comments I got from the Soren is the clocks name should mat=
ch the name's in the device datasheet.
>=20
> For axi_can case the clock names is can_clk and s_axi_aclk
> For canps case the clock names  is can_clk and pclk.
>=20
> If you want me to put a unique for the both I will do.

In an ideal world the data sheet of the IP will have a unique name for
its clock inputs, regardless the version of the IP core and the design
(processor, softcore, etc...) it is integrated into.

The first clock is named "can_clk", so we only need a single name for
the second clock. Any opinions from the devicetree people?

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--in06KSvgRKo8LuCjWbJfVTDmAaa8UqkdO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlNWQ9kACgkQjTAFq1RaXHNPdQCdEeck7L5i1XqpUiSiaY0Xyu9u
m7kAninBAtSDYoMr9IXOF/3zpqGwFpHa
=//I4
-----END PGP SIGNATURE-----

--in06KSvgRKo8LuCjWbJfVTDmAaa8UqkdO--
