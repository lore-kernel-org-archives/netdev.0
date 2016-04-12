From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [RFC v5 0/5] Add virtio transport for AF_VSOCK
Date: Tue, 12 Apr 2016 14:59:57 +0100
Message-ID: <20160412135957.GB29405@stefanha-x1.localdomain>
References: <1459520587-12337-1-git-send-email-stefanha@redhat.com>
 <1460129705.1749.25.camel@docker.com>
 <20160411104548.GA12826@stefanha-x1.localdomain>
 <20160411154517-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FkmkrVfFsRoUs1wW"
Cc: Stefan Hajnoczi <stefanha@gmail.com>,
	Ian Campbell <ian.campbell@docker.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Alex =?iso-8859-1?Q?Benn=E9e?= <alex.bennee@linaro.org>,
	marius vlad <marius.vlad0@gmail.com>, areis@redhat.com,
	Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160411154517-mutt-send-email-mst@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--FkmkrVfFsRoUs1wW
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 11, 2016 at 03:54:08PM +0300, Michael S. Tsirkin wrote:
> On Mon, Apr 11, 2016 at 11:45:48AM +0100, Stefan Hajnoczi wrote:
> > On Fri, Apr 08, 2016 at 04:35:05PM +0100, Ian Campbell wrote:
> > > On Fri, 2016-04-01 at 15:23 +0100, Stefan Hajnoczi wrote:
> > > > This series is based on Michael Tsirkin's vhost branch (v4.5-rc6).
> > > >=20
> > > > I'm about to process Claudio Imbrenda's locking fixes for virtio-vs=
ock but
> > > > first I want to share the latest version of the code.=A0=A0Several =
people are
> > > > playing with vsock now so sharing the latest code should avoid dupl=
icate work.
> > >=20
> > > Thanks for this, I've been using it in my project and it mostly seems
> > > fine.
> > >=20
> > > One wrinkle I came across, which I'm not sure if it is by design or a
> > > problem is that I can see this sequence coming from the guest (with
> > > other activity in between):
> > >=20
> > > =A0 =A0 1) OP_SHUTDOWN w/ flags =3D=3D SHUTDOWN_RX
> > > =A0=A0=A0=A02) OP_SHUTDOWN w/ flags =3D=3D SHUTDOWN_TX
> > > =A0=A0=A0=A03) OP_SHUTDOWN w/ flags =3D=3D SHUTDOWN_TX|SHUTDOWN_RX

How did you trigger this sequence?  I'd like to reproduce it.

> > > I orignally had my backend close things down at #2, however this meant
> > > that when #3 arrived it was for a non-existent socket (or, worse, an
> > > active one if the ports got reused). I checked v5 of the spec
> > > proposal[0] which says:
> > >     If these bits are set and there are no more virtqueue buffers
> > >     pending the socket is disconnected.
> > >=20
> > > but I'm not entirely sure if this behaviour contradicts this or not
> > > (the bits have both been set at #2, but not at the same time).
> > >=20
> > > BTW, how does one tell if there are no more virtqueue buffers pending
> > > or not while processing the op?
> >=20
> > #2 is odd.  The shutdown bits are sticky so they cannot be cleared once
> > set.  I would have expected just #1 and #3.  The behavior you observe
> > look like a bug.
> >=20
> > The spec text does not convey the meaning of OP_SHUTDOWN well.
> > OP_SHUTDOWN SHUTDOWN_TX|SHUTDOWN_RX means no further rx/tx is possible
> > for this connection.  "there are no more virtqueue buffers pending the
> > socket" really means that this isn't an immediate close from the
> > perspective of the application.  If the application still has unread rx
> > buffers then the socket stays readable until the rx data has been fully
> > read.
>=20
> Yes but you also wrote:
> 	If these bits are set and there are no more virtqueue buffers
> 	pending the socket is disconnected.
>=20
> how does remote know that there are no buffers pending and so it's safe
> to reuse the same source/destination address now?  Maybe destination
> should send RST at that point?

You are right, the source/destination address could be reused while the
remote still has the connection in their table.  Connection
establishment would fail with a RST reply.

I can think of two solutions:

1. Implementations must remove connections from their table as soon as
   SHUTDOWN_TX|SHUTDOWN_RX is received.  This way the source/destination
   address tuple can be reused immediately, i.e. new connections with
   the same source/destination would be possible while an application is
   still draining the receive buffers of an old connection.

2. Extend the connection lifecycle so that an A->B
   SHUTDOWN_TX|SHUTDOWN_RX must be followed by a by a B->A RST to close
   a connection.  This way the source/destination address is only in use
   once at a time.

Option #2 seems safer because there is no overlap in source/destination
address usage.

--FkmkrVfFsRoUs1wW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXDP9dAAoJEJykq7OBq3PI0NoIAIrwDya3XHMJ1opnhXn1CNDg
yi+7C4i+2JJKZ03Y4tsXCEH7IhxLuPU9u1fG0zi5KvZ9Uo8akcImNEheWBR77yQz
dRsrp8eaIJhgXp9MVlh1qGVX0QxqZpf6rcNNWHvf1O1YTAk+5zWo0HfPiaGpIo4E
1/s+rA3VuJ17B4tZi17vxejwpHR6/5u8Og3rtDqCIgPfcXYcsyEMymx7mI24Zveb
1PIEIk5KGLR2u907bA+V5ZH5+eFdPbmkjjYkQTjOrbWKo3H8lvBfgr3JTxoVTP7x
e1LmpKXCfaUbwKTQQ/A30/vrxNoBNNXUrII5+OTjx9PLP69BOck6BEJYBEJGReE=
=10Gw
-----END PGP SIGNATURE-----

--FkmkrVfFsRoUs1wW--
