From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: net/can: warning in raw_setsockopt/__alloc_pages_slowpath
Date: Fri, 2 Dec 2016 14:24:37 +0100
Message-ID: <c47865a1-4aae-5eae-f9e0-7b4f7f7e9897@pengutronix.de>
References: <CAAeHK+x3vqjzzXPtp-xCshWnvTcVrZqGmJR7rbooRFxBJanv8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="2G7f8nmLqlwadLXxvXgqKDN7KniMiDRb3"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        Oliver Hartkopp <socketcan@hartkopp.net>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+x3vqjzzXPtp-xCshWnvTcVrZqGmJR7rbooRFxBJanv8g@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2G7f8nmLqlwadLXxvXgqKDN7KniMiDRb3
Content-Type: multipart/mixed; boundary="Np5CwEkFIpp783ujbVp3chDKP7O3Q8Tmc";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Andrey Konovalov <andreyknvl@google.com>,
 Oliver Hartkopp <socketcan@hartkopp.net>,
 "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
 netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
 syzkaller <syzkaller@googlegroups.com>
Message-ID: <c47865a1-4aae-5eae-f9e0-7b4f7f7e9897@pengutronix.de>
Subject: Re: net/can: warning in raw_setsockopt/__alloc_pages_slowpath
References: <CAAeHK+x3vqjzzXPtp-xCshWnvTcVrZqGmJR7rbooRFxBJanv8g@mail.gmail.com>
In-Reply-To: <CAAeHK+x3vqjzzXPtp-xCshWnvTcVrZqGmJR7rbooRFxBJanv8g@mail.gmail.com>

--Np5CwEkFIpp783ujbVp3chDKP7O3Q8Tmc
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 12/02/2016 01:43 PM, Andrey Konovalov wrote:
> Hi!
>=20
> I've got the following error report while running the syzkaller fuzzer.=

>=20
> A reproducer is attached.
>=20
> On commit d8e435f3ab6fea2ea324dce72b51dd7761747523 (Nov 26).
>=20
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 4009 at mm/page_alloc.c:3511
> __alloc_pages_slowpath+0x3d4/0x1bf0
> Modules linked in:
> CPU: 0 PID: 4009 Comm: a.out Not tainted 4.9.0-rc6+ #54
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01=
/2011
>  ffff88006832f8a8 ffffffff81c73b14 0000000000000000 0000000000000000
>  ffffffff842c6320 0000000000000000 ffff88006832f8f0 ffffffff8123dc57
>  ffff880067d86000 ffffffff00000db7 ffffffff842c6320 0000000000000db7
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81c73b14>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
>  [<ffffffff8123dc57>] __warn+0x1a7/0x1f0 kernel/panic.c:550
>  [<ffffffff8123de6c>] warn_slowpath_null+0x2c/0x40 kernel/panic.c:585
>  [<ffffffff81559b04>] __alloc_pages_slowpath+0x3d4/0x1bf0 mm/page_alloc=
=2Ec:3511
>  [<ffffffff8155b8e2>] __alloc_pages_nodemask+0x5c2/0x710 mm/page_alloc.=
c:3781
>  [<ffffffff816236a4>] alloc_pages_current+0xf4/0x400 mm/mempolicy.c:207=
2
>  [<     inline     >] alloc_pages ./include/linux/gfp.h:469
>  [<ffffffff815a834f>] kmalloc_order+0x1f/0x70 mm/slab_common.c:1015
>  [<ffffffff815a83bf>] kmalloc_order_trace+0x1f/0x160 mm/slab_common.c:1=
026
>  [<     inline     >] kmalloc_large ./include/linux/slab.h:422
>  [<ffffffff81635e67>] __kmalloc_track_caller+0x227/0x2a0 mm/slub.c:4233=

>  [<ffffffff8159932c>] memdup_user+0x2c/0xa0 mm/util.c:137
>  [<ffffffff8369e0de>] raw_setsockopt+0x1be/0x9f0 net/can/raw.c:506

We should add a check for a sensible optlen....

> static int raw_setsockopt(struct socket *sock, int level, int optname,
> 			  char __user *optval, unsigned int optlen)
> {
> 	struct sock *sk =3D sock->sk;
> 	struct raw_sock *ro =3D raw_sk(sk);
> 	struct can_filter *filter =3D NULL;  /* dyn. alloc'ed filters */
> 	struct can_filter sfilter;         /* single filter */
> 	struct net_device *dev =3D NULL;
> 	can_err_mask_t err_mask =3D 0;
> 	int count =3D 0;
> 	int err =3D 0;
>=20
> 	if (level !=3D SOL_CAN_RAW)
> 		return -EINVAL;
>=20
> 	switch (optname) {
>=20
> 	case CAN_RAW_FILTER:
> 		if (optlen % sizeof(struct can_filter) !=3D 0)
> 			return -EINVAL;

here...

		if (optlen > 64 * sizeof(struct can_filter))
			return -EINVAL;

>=20
> 		count =3D optlen / sizeof(struct can_filter);
>=20
> 		if (count > 1) {
> 			/* filter does not fit into dfilter =3D> alloc space */
> 			filter =3D memdup_user(optval, optlen);
> 			if (IS_ERR(filter))
> 				return PTR_ERR(filter);
> 		} else if (count =3D=3D 1) {
> 			if (copy_from_user(&sfilter, optval, sizeof(sfilter)))
> 				return -EFAULT;
> 		}
>=20
> 		lock_sock(sk);

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Np5CwEkFIpp783ujbVp3chDKP7O3Q8Tmc--

--2G7f8nmLqlwadLXxvXgqKDN7KniMiDRb3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAlhBdhUACgkQPTuqJayp
JWrk8Qf/ZwINBxTDbgKlofOMDU5zddIUyjXjQybTcZw3HKz9wh3e8+HIcA3KPsAd
YvnbstoIhXWVM4zGpPqlP4qQz9gjbJNdoHrd3fdIrkJobgVa16V/uWxlM7U1+pfS
15wCqOVfYACkXLZxJIwsURdhOwoz9HVgFT7btfomotnoI57DCmgkoODiWYMAIs3B
4RNXiz3X9fIgcLt8dBKr9HGfh55l6aU8+4zaeEJut1u/djRXm2eS7oECblTbEuCD
7r9aj5zx2Z1lS27VBKeb+0C7BAYdHX2M7EQmcQQ0YQWB2KiKR9BxDystIb2i0X6+
TWrNokG39HoaKEOufqKENDa9tyy7Hw==
=ODLo
-----END PGP SIGNATURE-----

--2G7f8nmLqlwadLXxvXgqKDN7KniMiDRb3--
