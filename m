From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net] r8169: Fix sleeping function called during
 get_stats64
Date: Wed, 9 Sep 2015 23:13:06 +0200
Message-ID: <20150909211306.GA1693@calimero.vinschen.de>
References: <1441801223-27534-1-git-send-email-vinschen@redhat.com>
 <20150909202334.GA18625@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="h31gzZEtNLTqOjlF"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	linux-kernel@vger.kernel.org, nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150909202334.GA18625@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  9 22:23, Francois Romieu wrote:
> Corinna Vinschen <vinschen@redhat.com> :
> [...]
> > diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
> > index 24dcbe6..630811a 100644
> > --- a/drivers/net/ethernet/realtek/r8169.c
> > +++ b/drivers/net/ethernet/realtek/r8169.c
> [...]
> > +	if (!paddr)
> > +		return false;
>=20
> I guess this is the secret recipe.

Actually, no.  I started out stress testing this combined with a printk
to show if paddr can be NULL, but this never occurs.  ndo_get_stats64 is
apparently only called after registering the device, and this occurs
after calling dma_alloc_coherent in rtl_init_one.

Rather than removing the entire test, I acidentally only removed the
printk.  Sorry about that.

> [...]
> > @@ -8447,9 +8411,14 @@ static int rtl_init_one(struct pci_dev *pdev, co=
nst struct pci_device_id *ent)
> > =20
> >  	tp->rtl_fw =3D RTL_FIRMWARE_UNKNOWN;
> > =20
> > +	tp->CntArray =3D dma_alloc_coherent (&pdev->dev, sizeof(*tp->CntArray=
),
> > +					   &tp->CntPhysAddr, GFP_KERNEL);
> > +	if (!tp->CntArray)
> > +		goto err_out_cnt_4;
> > +
>=20
> rc is still zero here so rtl_init_one will return success.

Thanks for catching!  I'm sending a fixed patch in a minute, removing
the paddr test and setting rc to -ENOMEM if dma_alloc_coherent fails.


Corinna

--h31gzZEtNLTqOjlF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV8KDiAAoJEPU2Bp2uRE+gcxwP/17K6FxhjcloltAxpY1/9c4E
XgaXTyL7bDahYwyAeX6ixMsD7ZvxjmGK1AJcnGzH1xI2PJNF8mSMKdHzrHamrhWT
eRycjzfLS/0KmnaM8ogktG7rK5DjBOqFJYiZwJvwJm6jtruAat+hz+AjVAvaxBY2
VDiO9dWpq+CY302a8YyI6KTI02uy8RKiZu9L084zA8pxJobPCga/VIlAbl9GDseo
qg+8KvIhRpI0MZ5IzhNa8ysuUEnD7mQB9HmwDc6g5bFDh+QXfblWwIX5FXsXmDzM
XxdJZi7bIgC/rrcPcei5vWy033ZVFwa3OPFcMk9nOu+4Bt2AcH3AHQDbo9dUZysD
/V0qUXnOlLFwsT3HB21dKM6cuNLBSzu4SGvEh0l5p9lSTq6YO+0K7d0GysJpVSbL
IagLzyVScFNEIeEMIYZCe6fXOZvbkTbvNKLYKKGrYdqrr1VPgn/axyIa1RRYw6KP
OPjsJzFI3Q7zUnPMMrk8gNMmGcKlJFb+OsNKOvI7zTADJuXJJQBa+Pj+bb0/c+S/
fvE3NDk1dwu0T9ksWUmSoNckMDxm5FZBXvGRmpYs43Gwk1K4s+q7X6qgpK0RHrQv
uy0ATRAwEgjEZFp3DJ27+No+fwQU5+57JcaSWXu+Y1x9grch4jJ6d5jy+XkYk1WB
gWKagSjWwOcHQ4z34qor
=WvkI
-----END PGP SIGNATURE-----

--h31gzZEtNLTqOjlF--
