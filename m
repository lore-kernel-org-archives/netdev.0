From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: Re: [PATCH] irda: remove BKL from irnet open function
Date: Mon, 1 Feb 2010 18:36:17 -0200
Message-ID: <20100201203616.GJ1414@holoscopio.com>
References: <1265048321-8097-1-git-send-email-cascardo@holoscopio.com>
 <520f0cf11002011232u415146a9md3afe65af4d810a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OgApRN/oydYDdnYz"
Cc: Arnd Bergmann <arnd@arndb.de>, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: John Kacur <jkacur@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <520f0cf11002011232u415146a9md3afe65af4d810a6@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--OgApRN/oydYDdnYz
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 01, 2010 at 09:32:30PM +0100, John Kacur wrote:
> On Mon, Feb 1, 2010 at 7:18 PM, Thadeu Lima de Souza Cascardo
> <cascardo@holoscopio.com> wrote:
> > Commit cddf63d99d0d145f18b293c3d0de4af7dab2a922 has push down the BKL
> > into irnet open function. However, there's nothing that needs locking in
> > there.
> >
> > Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
> > ---
> > =C2=A0net/irda/irnet/irnet_ppp.c | =C2=A0 =C2=A03 ---
> > =C2=A01 files changed, 0 insertions(+), 3 deletions(-)
> >
> > diff --git a/net/irda/irnet/irnet_ppp.c b/net/irda/irnet/irnet_ppp.c
> > index 156020d..d6b502c 100644
> > --- a/net/irda/irnet/irnet_ppp.c
> > +++ b/net/irda/irnet/irnet_ppp.c
> > @@ -479,7 +479,6 @@ dev_irnet_open(struct inode * =C2=A0 =C2=A0 =C2=A0 =
inode,
> > =C2=A0 ap =3D kzalloc(sizeof(*ap), GFP_KERNEL);
> > =C2=A0 DABORT(ap =3D=3D NULL, -ENOMEM, FS_ERROR, "Can't allocate struct=
 irnet...\n");
> >
> > - =C2=A0lock_kernel();
> > =C2=A0 /* initialize the irnet structure */
> > =C2=A0 ap->file =3D file;
> >
> > @@ -501,7 +500,6 @@ dev_irnet_open(struct inode * =C2=A0 =C2=A0 =C2=A0 =
inode,
> > =C2=A0 =C2=A0 {
> > =C2=A0 =C2=A0 =C2=A0 DERROR(FS_ERROR, "Can't setup IrDA link...\n");
> > =C2=A0 =C2=A0 =C2=A0 kfree(ap);
> > - =C2=A0 =C2=A0 =C2=A0unlock_kernel();
> > =C2=A0 =C2=A0 =C2=A0 return err;
> > =C2=A0 =C2=A0 }
> >
> > @@ -512,7 +510,6 @@ dev_irnet_open(struct inode * =C2=A0 =C2=A0 =C2=A0 =
inode,
> > =C2=A0 file->private_data =3D ap;
> >
> > =C2=A0 DEXIT(FS_TRACE, " - ap=3D0x%p\n", ap);
> > - =C2=A0unlock_kernel();
> > =C2=A0 return 0;
> > =C2=A0}
> >
> > --
> > 1.6.6.1
>=20
> This is probably NOT safe to do, because the BKL is synchronizing the
> ioctl code.
>=20
> Thanks

And is it possible that ioctl will be called before open returns? If it
is, then, yes, this is not safe. But I don't really believe the case. Or
is it?

Or is it only possible to happen with different struct file*? In that
case, open is only allocating and initializing the irnet_socket *ap.
Then, ioctl uses it. There is some race between the different ioctls,
but no race between open/ioctl for different opened devices. That is, a
process may open /dev/irnet while another process is issuing ioctls to
its own opened /dev/irnet.

Besides, dev_irnet_ioctl uses the file private_data to get to the
irnet_socket, which is the last thing the open call does. I assume doing
an attribution to a pointer is atomic in all architectures supported by
Linux currently, isn't it?

Regards,
Cascardo.

--OgApRN/oydYDdnYz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAktnO0AACgkQyTpryRcqtS3P6gCfRCuO2lDYfwU1VqqPokxKX692
7RgAnRFlkJi85Bqw+Hs9nxJ3HtWoMi6M
=NCx/
-----END PGP SIGNATURE-----

--OgApRN/oydYDdnYz--
