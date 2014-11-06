From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCHv2 net-next 2/2] sunvnet: Use one Tx queue per vnet_port
Date: Thu, 06 Nov 2014 16:19:33 +0000
Message-ID: <1415290773.3398.61.camel@decadent.org.uk>
References: <20141030164609.GG650@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wx1wOo7Vyni2BphSes40"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60351 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751156AbaKFQTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 11:19:53 -0500
In-Reply-To: <20141030164609.GG650@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wx1wOo7Vyni2BphSes40
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-10-30 at 12:46 -0400, Sowmini Varadhan wrote:
> Use multple Tx netdev queues for sunvnet by supporting a one-to-one
> mapping between vnet_port and Tx queue. Provide a ndo_select_queue
> indirection (vnet_select_queue()) which selects the queue based
> on the peer that would be selected in vnet_start_xmit()
>=20
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
[...]
> +static void maybe_tx_wakeup(struct vnet_port *port)
>  {
> -	struct net_device *dev =3D vp->dev;
> +	struct netdev_queue *txq;
> =20
> -	netif_tx_lock(dev);
> -	if (likely(netif_queue_stopped(dev))) {
> -		struct vnet_port *port;
> -		int wake =3D 1;
> -
> -		rcu_read_lock();
> -		list_for_each_entry_rcu(port, &vp->port_list, list) {
> -			struct vio_dring_state *dr;
> -
> -			dr =3D &port->vio.drings[VIO_DRIVER_TX_RING];
> -			if (vnet_tx_dring_avail(dr) <
> -			    VNET_TX_WAKEUP_THRESH(dr)) {
> -				wake =3D 0;
> -				break;
> -			}
> -		}
> -		rcu_read_unlock();
> -		if (wake)
> -			netif_wake_queue(dev);
> +	txq =3D netdev_get_tx_queue(port->vp->dev, port->q_index);
> +	__netif_tx_lock(txq, smp_processor_id());
> +	if (likely(netif_tx_queue_stopped(txq))) {
> +		struct vio_dring_state *dr;
> +
> +		dr =3D &port->vio.drings[VIO_DRIVER_TX_RING];

You seem to have dropped the condition for the netif_tx_wake_queue(),
which I would guess based on the old code should be:

		if (vnet_tx_dring_avail(dr) >=3D VNET_TX_WAKEUP_THRESH(dr))

> +			netif_tx_wake_queue(txq);
>  	}
> -	netif_tx_unlock(dev);
> +	__netif_tx_unlock(txq);
>  }
[...]

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-wx1wOo7Vyni2BphSes40
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVFufnue/yOyVhhEJAQr0YQ//RpE40tu1RKF8QgYSazTgxuA2L2NYd33L
+xKexSaLkeMaQB/Matmhw7xRwvGtJ1xGLOPTojdgMhd31J83vFgHQln8tOAKH5+E
DuQAy1UkMBx8icAQAZUMTjQsD1yesDsz5r6f0tWC2khA30fS3yZh6eh0GQeQ/Z7n
8hk1eQH8GmAWQXPQQ8P6bIkL4+SOhExUueTCMOHke4oFZ1/3UxTzWZ6j4rJ6uOPJ
vZxIDpx9CDhvFvQCYSJmvTVGwa8mGGPdiIoJiExtuHbYGq/Uck1WhB8f5po01hnY
fgnxGLmHU9SdyRpoKDbQsj0i8mi9l/G6ZlYzgRHjkQHvmESlInja9q2d2BnFYga8
Lik5eEoCuQOnfBt0IkETCkqdJXr3lGF0nJ0uexUbRb9Hl4aBOdVI1L+90d6pGYEj
j1vOKSY2OJADDOM842IFgnF3lv6+0EkxRHgU9jUobKYRVMWAlyusNAGzX5azUtBp
38qKPLs9bP0gResbwI++0bBgUmOXsDsuQgI3y/SxxrvhfwW2ueVw6J4y5v22uOYd
Zpr6VPyivdI7YCFN7hzK/zh+uZmMaaDFhzWapjXbAUI1Z69uGib3zMcVHfHH8/xl
OUoq5t/utgOBH/RuhZ/hO3NlfR28nmMt1/uXEuJJ5uUXUawdB/HVtpjBfrRwuQMY
GkzVC1m9p4Y=
=6Fh/
-----END PGP SIGNATURE-----

--=-wx1wOo7Vyni2BphSes40--
