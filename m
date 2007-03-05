From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Mon, 5 Mar 2007 22:41:42 +0000
Message-ID: <20070305224140.GA16290@sirena.org.uk>
References: <200703052310.08359.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5vNYLRcllDrimb99"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:4114 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbXCEWmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 17:42:22 -0500
Received: from 82-32-140-119.cable.ubr04.edin.blueyonder.co.uk ([82.32.140.119] helo=mercator.sirena.org.uk)
	by cassiel.sirena.org.uk with esmtpsa (TLS-1.0:RSA_AES_256_CBC_SHA:32)
	(Exim 4.50)
	id 1HOLsm-000063-KJ
	for netdev@vger.kernel.org; Mon, 05 Mar 2007 22:42:18 +0000
Received: from broonie by mercator.sirena.org.uk with local (Exim 4.63)
	(envelope-from <broonie@sirena.org.uk>)
	id 1HOLsE-0004YG-Cb
	for netdev@vger.kernel.org; Mon, 05 Mar 2007 22:41:42 +0000
Content-Disposition: inline
In-Reply-To: <200703052310.08359.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 06, 2007 at 12:10:08AM +0400, Sergei Shtylyov wrote:

>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  static void natsemi_poll_controller(struct net_device *dev)
>  {
> +	struct netdev_private *np =3D netdev_priv(dev);
> +
>  	disable_irq(dev->irq);
> -	intr_handler(dev->irq, dev);
> +
> +	/*
> +	 * A real interrupt might have already reached us at this point
> +	 * but NAPI might still haven't called us back.  As the interrupt
> +	 * status register is cleared by reading, we should prevent an
> +	 * interrupt loss in this case...
> +	 */
> +	if (!np->intr_status)
> +		intr_handler(dev->irq, dev);
> +
>  	enable_irq(dev->irq);

Is it possible for this to run at the same time as the NAPI poll?  If so
then it is possible for the netpoll poll to run between np->intr_status
being cleared and netif_rx_complete() being called.  If the hardware
asserts an interrupt at the wrong moment then this could cause the=20

In any case, this is a problem independently of netpoll if the chip
shares an interrupt with anything so the interrupt handler should be
fixed to cope with this situation instead.

--=20
"You grabbed my hand and we fell into it, like a daydream - or a fever."

--5vNYLRcllDrimb99
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iQCVAwUBReycoA2erOLNe+68AQIP7gP+NJXFqm8bjdxHNDWsgTJpyGSXTzzz/XRq
Kra4NbxHZZRaQOxkvzDRYsXlOqS9gDjgTI77xhIJSt/nu/NNsfJL9riPTEgz9N9O
FlXvJwrnZu43lEhFwCpISO0qnVQ2ppfaVRzJfcIOlDUAdibPmGYmRBSt+/t++PlH
ST1JGqRKaA0=
=1vbO
-----END PGP SIGNATURE-----

--5vNYLRcllDrimb99--
