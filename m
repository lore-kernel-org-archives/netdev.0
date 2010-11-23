From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] flexcan: fix NAPI for bus errors
Date: Tue, 23 Nov 2010 16:39:05 +0100
Message-ID: <4CEBE019.7070401@pengutronix.de>
References: <80k4k45csy.fsf@merkur.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1671812936922187901=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: John Ogness <john.ogness-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <80k4k45csy.fsf-l77OnrVvfFAyMciVaGeJ0d53zsg1cpMQ@public.gmane.org>
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
--===============1671812936922187901==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig0AD4551CBDA85E0F74DE3C6C"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig0AD4551CBDA85E0F74DE3C6C
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,

On 11/23/2010 03:34 PM, John Ogness wrote:
> If bus error reporting is disabled and bus errors occur, the flexcan
> driver will hog the system because it continually re-enables the IRQs
> (work_done =3D 0). This patch changes the driver to only re-enable the
> IRQs if some work was actually done. This allows the features of NAPI t=
o
> be used for bus errors as well (when bus error reporting is disabled).

Good idea, however the chip has IMHO a bug:

The problem with the error interrupt is, when disabled the can core
doesn't issue any can bus warning or bus passive interrupts.

Can you ensure that you get both error warning and error passive can
error messages with disabled BERR and you patch applied?

> This patch is against Linux next-20101123.
>=20
> Signed-off-by: John Ogness <john.ogness-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> ---
>  drivers/net/can/flexcan.c |    9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
>=20
> --- next-20101123-a/drivers/net/can/flexcan.c
> +++ next-20101123-b/drivers/net/can/flexcan.c
> @@ -535,9 +535,12 @@ static int flexcan_poll(struct napi_stru
> =20
>  	if (work_done < quota) {
>  		napi_complete(napi);
> -		/* enable IRQs */
> -		writel(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
> -		writel(priv->reg_ctrl_default, &regs->ctrl);
> +
> +		if (work_done > 0) {
> +			/* enable IRQs */
> +			writel(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
> +			writel(priv->reg_ctrl_default, &regs->ctrl);
> +		}
>  	}
> =20
>  	return work_done;

If a bus error occurs and bus error reporting is disabled, work_done
will stay 0, so both the RX and the ERR interrupt stay disabled (which
is done in flexcan_irq). I think we should always enable the RX
interrupt. (However, if the bus is working again the chip can probably
send messages again, so we get a TX-complete IRQ, but this depends on
the application.)

Having a look at flexcan_irq:

> 	/*
> 	 * schedule NAPI in case of:
> 	 * - rx IRQ
> 	 * - state change IRQ
> 	 * - bus error IRQ and bus error reporting is activated
> 	 */

This mean with disabled BERR NAPI should only be scheduled in case of a
RX or a state change interrupt. Both of these interrupts should generate
a can_frame in flexcan_poll and this the work_done shoud be > 0, modulo
out of memory situations.

> 	if ((reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_AVAILABLE) ||
> 	    (reg_esr & FLEXCAN_ESR_ERR_STATE) ||
> 	    flexcan_has_and_handle_berr(priv, reg_esr)) {
> 		/*
> 		 * The error bits are cleared on read,
> 		 * save them for later use.
> 		 */
> 		priv->reg_esr =3D reg_esr & FLEXCAN_ESR_ERR_BUS;
> 		writel(FLEXCAN_IFLAG_DEFAULT & ~FLEXCAN_IFLAG_RX_FIFO_AVAILABLE,
> 		       &regs->imask1);
> 		writel(priv->reg_ctrl_default & ~FLEXCAN_CTRL_ERR_ALL,
> 		       &regs->ctrl);
> 		napi_schedule(&priv->napi);
> 	}

So thinking about the problem I don't see how your patch works. But
there might be a bug in the driver or my logic.

Cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig0AD4551CBDA85E0F74DE3C6C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzr4B4ACgkQjTAFq1RaXHMrYgCaA+38rnK0xgof4oKvR6hDNiH6
9hsAniMkLlbYcKc7ioUkxmpuGfwyKNDy
=iIWF
-----END PGP SIGNATURE-----

--------------enig0AD4551CBDA85E0F74DE3C6C--

--===============1671812936922187901==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============1671812936922187901==--
