From: Marek =?utf-8?Q?Marczykowski-G=C3=B3recki?=
	<marmarek@invisiblethingslab.com>
Subject: Re: xen-netfront crash when detaching network while some network
 activity
Date: Wed, 27 May 2015 00:03:12 +0200
Message-ID: <20150526220312.GA1358@mail-itl>
References: <20150522114932.GC8664@mail-itl>
 <55645140.1050209@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VS++wcV0S1rZb1Fb"
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	xen-devel <xen-devel@lists.xen.org>, netdev@vger.kernel.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:56909 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751586AbbEZWDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 18:03:18 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id B17BF20796
	for <netdev@vger.kernel.org>; Tue, 26 May 2015 18:03:17 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <55645140.1050209@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 26, 2015 at 11:56:00AM +0100, David Vrabel wrote:
> On 22/05/15 12:49, Marek Marczykowski-G=C3=B3recki wrote:
> > Hi all,
> >=20
> > I'm experiencing xen-netfront crash when doing xl network-detach while
> > some network activity is going on at the same time. It happens only when
> > domU has more than one vcpu. Not sure if this matters, but the backend
> > is in another domU (not dom0). I'm using Xen 4.2.2. It happens on kernel
> > 3.9.4 and 4.1-rc1 as well.
> >=20
> > Steps to reproduce:
> > 1. Start the domU with some network interface
> > 2. Call there 'ping -f some-IP'
> > 3. Call 'xl network-detach NAME 0'
>=20
> There's a use-after-free in xennet_remove().  Does this patch fix it?

Unfortunately not. Note that the crash is in xennet_disconnect_backend,
which is called before xennet_destroy_queues in xennet_remove.
I've tried to add napi_disable and even netif_napi_del just after
napi_synchronize in xennet_disconnect_backend (which would probably
cause crash when trying to cleanup the same later again), but it doesn't
help - the crash is the same (still in gnttab_end_foreign_access called
=66rom xennet_disconnect_backend).


> 8<--------------------------------
> xen-netfront: properly destroy queues when removing device
>=20
> xennet_remove() freed the queues before freeing the netdevice which
> results in a use-after-free when free_netdev() tries to delete the
> napi instances that have already been freed.
>=20
> Fix this by fully destroy the queues (which includes deleting the napi
> instances) before freeing the netdevice.
>=20
> Reported-by: Marek Marczykowski <marmarek@invisiblethingslab.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netfront.c |   15 ++-------------
>  1 file changed, 2 insertions(+), 13 deletions(-)
>=20
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 3f45afd..e031c94 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1698,6 +1698,7 @@ static void xennet_destroy_queues(struct netfront_i=
nfo *info)
> =20
>  		if (netif_running(info->netdev))
>  			napi_disable(&queue->napi);
> +		del_timer_sync(&queue->rx_refill_timer);
>  		netif_napi_del(&queue->napi);
>  	}
> =20
> @@ -2102,9 +2103,6 @@ static const struct attribute_group xennet_dev_grou=
p =3D {
>  static int xennet_remove(struct xenbus_device *dev)
>  {
>  	struct netfront_info *info =3D dev_get_drvdata(&dev->dev);
> -	unsigned int num_queues =3D info->netdev->real_num_tx_queues;
> -	struct netfront_queue *queue =3D NULL;
> -	unsigned int i =3D 0;
> =20
>  	dev_dbg(&dev->dev, "%s\n", dev->nodename);
> =20
> @@ -2112,16 +2110,7 @@ static int xennet_remove(struct xenbus_device *dev)
> =20
>  	unregister_netdev(info->netdev);
> =20
> -	for (i =3D 0; i < num_queues; ++i) {
> -		queue =3D &info->queues[i];
> -		del_timer_sync(&queue->rx_refill_timer);
> -	}
> -
> -	if (num_queues) {
> -		kfree(info->queues);
> -		info->queues =3D NULL;
> -	}
> -
> +	xennet_destroy_queues(info);
>  	xennet_free_netdev(info->netdev);
> =20
>  	return 0;

--=20
Best Regards,
Marek Marczykowski-G=C3=B3recki
Invisible Things Lab
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?

--VS++wcV0S1rZb1Fb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJVZO2gAAoJENuP0xzK19csYjkH/0aydFxFlqz0nfFJiMzKZ3/k
WSEtdLpueTML/fC5I0QJSZ7rpwMca+p3iKO5NegF16UB8t95bF9eR5rbI0eCVgqo
r8/jEaQT8A06wVLQm8dPZOTrsh/z2kM5fcWVJHXwTSszepjGf8h9yFsTY92lL7+X
hXGoU+0mvz4LwwocOLfZei+XChtYHJzrnsFNiCSwLa01V1NjMYeUwPXDXhiSHbPQ
pgyCqXpRp/oFWGb7zCJANUuuvlD8pwjUYmEYR0O4zX4QMnVOs86uKO9DtdtxkTPm
d3VYCzLaBDvQRCocIxxv0F1D5gFHPUfa8QmUVR1aQ/9K6ZqTK5Sm9Rluac2YhRA=
=cAwQ
-----END PGP SIGNATURE-----

--VS++wcV0S1rZb1Fb--
