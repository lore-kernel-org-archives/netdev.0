From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] CAN: Add Flexcan CAN controller driver
Date: Wed, 21 Jul 2010 22:42:14 +0200
Message-ID: <4C475BA6.3030505@pengutronix.de>
References: <1279144811-12251-1-git-send-email-mkl@pengutronix.de>	<4C3F55A9.8030307@grandegger.com>
	<4C405CEC.3000701@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8487467253633548150=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C405CEC.3000701-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============8487467253633548150==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig252C26ED1CFD811CB7448A5F"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig252C26ED1CFD811CB7448A5F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Marc Kleine-Budde wrote:
> Wolfgang Grandegger wrote:
>> I realized a few issues. You can add my "acked-by" when they are fixed=
=2E
>=20
> thanks for the review.

[...]

>>> +static void flexcan_poll_err_frame(struct net_device *dev,
>>> +				   struct can_frame *cf, u32 reg_esr)
>>> +{
>>> +	struct flexcan_priv *priv =3D netdev_priv(dev);
>>> +	int error_warning =3D 0, rx_errors =3D 0, tx_errors =3D 0;
>>> +
>>> +	if (reg_esr & FLEXCAN_ESR_BIT1_ERR) {
>>> +		rx_errors =3D 1;
>>> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>> +		cf->data[2] |=3D CAN_ERR_PROT_BIT1;
>>> +	}
>>> +
>>> +	if (reg_esr & FLEXCAN_ESR_BIT0_ERR) {
>>> +		rx_errors =3D 1;
>>> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>> +		cf->data[2] |=3D CAN_ERR_PROT_BIT0;
>>> +	}
>>> +
>>> +	if (reg_esr & FLEXCAN_ESR_FRM_ERR) {
>>> +		rx_errors =3D 1;
>>> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>> +		cf->data[2] |=3D CAN_ERR_PROT_FORM;
>>> +	}
>>> +
>>> +	if (reg_esr & FLEXCAN_ESR_STF_ERR) {
>>> +		rx_errors =3D 1;
>>> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>>> +		cf->data[2] |=3D CAN_ERR_PROT_STUFF;
>>> +	}
>>> +
>>> +
>>> +	if (reg_esr & FLEXCAN_ESR_ACK_ERR) {
>>> +		tx_errors =3D 1;
>>> +		cf->can_id |=3D CAN_ERR_ACK;
>> This is a bus-error as well. Therefore I think it should be:
>>
>> 	if (reg_esr & FLEXCAN_ESR_ACK_ERR) {
>> 		tx_errors =3D 1;
>> 		cf->can_id |=3D CAN_ERR_ACK;
>> 		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
>> 		cf->data[3] |=3D CAN_ERR_PROT_LOC_ACK; /* ACK slot */
>> 	}
>>
>> I need to check what CAN_ERR_ACK is intended for. Then, cf->can_id cou=
ld
>> be preset with "CAN_ERR_PROT | CAN_ERR_BUSERROR" at the beginning.

This controller issues an ACK error if there are no other nodes on the
CAN bus to send a ACK that the message has been received. Or all
remaining Nodes are in bus off state.

=46rom the datasheet:
"This bit indicates that an acknowledge (ACK) error has been detected by
the transmitter node; that is, a dominant bit has not been detected
during the ACK SLOT."

>>
>>> +	}
>>> +
>>> +	if (error_warning)
>>> +		priv->can.can_stats.error_warning++;
>> Hm, error_warning is always 0 !?
>=20
> this must go into the state handling function, will fix.
>>> +	if (rx_errors)
>>> +		dev->stats.rx_errors++;
>>> +	if (tx_errors)
>>> +		dev->stats.tx_errors++;
>>> +
>>> +}

[...]

>>> +static int flexcan_poll(struct napi_struct *napi, int quota)
>>> +{
>>> +	struct net_device *dev =3D napi->dev;
>>> +	const struct flexcan_priv *priv =3D netdev_priv(dev);
>>> +	struct flexcan_regs __iomem *regs =3D priv->base;
>>> +	u32 reg_iflag1, reg_esr;
>>> +	int work_done =3D 0;
>>> +
>>> +	reg_iflag1 =3D readl(&regs->iflag1);
>>> +
>>> +	/* first handle RX-FIFO */
>>> +	while (reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_AVAILABLE &&
>>> +	       work_done < quota) {
>>> +		flexcan_read_frame(dev);
>>> +
>>> +		work_done++;
>>> +		reg_iflag1 =3D readl(&regs->iflag1);
>>> +	}
>>> +
>>> +	/*
>>> +	 * The error bits are clear on read,
>>> +	 * so use saved value from irq handler.
>>> +	 */
>>> +	reg_esr =3D readl(&regs->esr) | priv->reg_esr;
>> Re-reading reg_esr may cause lost of state changes.
>=20
> To my understanding of the datasheet and my observation, only the error=

> bits are cleared on read. The bit defining the status
> (FLEXCAN_ESR_FLT_CONF_MASK) =3D=3D error active, error passive and bus =
off
> are not cleared on read.
>=20
> However there are two bits defining RX and TX warning level, I'll check=

> these.

I just checked with real hardware , only the error bits are cleared on re=
ad.

>>> +	if (work_done < quota) {
>>> +		flexcan_poll_err(dev, reg_esr);
>> An error frame is created here for each call of flexcan_poll(), not on=
ly
>> in case of errors.
>=20
> Doh, will fix this.
>=20
>>> +		work_done++;
>>> +	}
>>> +
>>> +	if (work_done < quota) {
>>> +		napi_complete(napi);
>>> +		/* enable IRQs */
>>> +		writel(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
>>> +		writel(priv->reg_ctrl_default, &regs->ctrl);
>>> +	}
>>> +
>>> +	return work_done;
>>> +}

a reworked patch will follow soon.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig252C26ED1CFD811CB7448A5F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkxHW60ACgkQjTAFq1RaXHMl4gCfUz/co7+DM2q6KKRHltKJNdYm
B+IAn23ToJfbgIehgwrzftzMOD3SWSe0
=jBHu
-----END PGP SIGNATURE-----

--------------enig252C26ED1CFD811CB7448A5F--

--===============8487467253633548150==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8487467253633548150==--
