From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Mon, 5 Mar 2007 22:43:59 +0000
Message-ID: <20070305224358.GB16290@sirena.org.uk>
References: <200703052310.08359.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OwLcNYc0lM97+oe1"
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, mhuth@mvista.com
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:4127 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbXCEWom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 17:44:42 -0500
Content-Disposition: inline
In-Reply-To: <200703052310.08359.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--OwLcNYc0lM97+oe1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[Once more with CCs]

On Tue, Mar 06, 2007 at 12:10:08AM +0400, Sergei Shtylyov wrote:

>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  static void natsemi_poll_controller(struct net_device *dev)
>  {
> +     struct netdev_private *np = netdev_priv(dev);
> +
>       disable_irq(dev->irq);
> -     intr_handler(dev->irq, dev);
> +
> +     /*
> +      * A real interrupt might have already reached us at this point
> +      * but NAPI might still haven't called us back.  As the
> interrupt
> +      * status register is cleared by reading, we should prevent an
> +      * interrupt loss in this case...
> +      */
> +     if (!np->intr_status)
> +             intr_handler(dev->irq, dev);
> +
>       enable_irq(dev->irq);

Is it possible for this to run at the same time as the NAPI poll?  If so
then it is possible for the netpoll poll to run between np->intr_status
being cleared and netif_rx_complete() being called.  If the hardware
asserts an interrupt at the wrong moment then this could cause the

In any case, this is a problem independently of netpoll if the chip
shares an interrupt with anything so the interrupt handler should be
fixed to cope with this situation instead.

--
"You grabbed my hand and we fell into it, like a daydream - or a fever."

--OwLcNYc0lM97+oe1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iQCVAwUBReydKA2erOLNe+68AQJhpQP/eU4Qd9Udd4n1CLkLsqYc49E8RqX3+oQp
uQSi1jNegp8Zm+A6azw/5afefoFMYmuMqiw9nnOWRLjOKZujz91OMQM1Vb7ZrtJW
eHyEKelUpVaTd/F0yuVS6ixxiewai4g2eXjBA7AfY+n6YSyNBTH+EtUo/Q+dRhY9
6w/1MSQrN+4=
=j1P0
-----END PGP SIGNATURE-----

--OwLcNYc0lM97+oe1--
