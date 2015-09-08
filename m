From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Tue, 8 Sep 2015 22:23:15 +0200
Message-ID: <20150908202315.GH20288@calimero.vinschen.de>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
 <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
 <20150906103732.GF30539@calimero.vinschen.de>
 <20150907144412.GA26524@calimero.vinschen.de>
 <20150907215251.GA4897@electric-eye.fr.zoreil.com>
 <20150908000202.GA5059@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="sLx0z+5FKKtIVDwd"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:45026 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbbIHUXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 16:23:19 -0400
Content-Disposition: inline
In-Reply-To: <20150908000202.GA5059@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sLx0z+5FKKtIVDwd
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  8 02:02, Francois Romieu wrote:
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
> > Updated patch is on the way.
>=20
> Fixed memcpy in patch 0001, moved counters allocation from open()=20
> to probe(), returned open() to its original state but something is
> still wrong: the link does not come up.

I tested and debugged the attached patches.  Just as you noticed, the
interfaces (my test machine has two) don't come up at boot time and
subsequently I can also reproduce two kinds of crashes:

- Calling `ip link ... up' crashes the kernel in rtl_open like this:

[  138.031190]  [<ffffffff81670f92>] dump_stack+0x44/0x55
[  138.036311]  [<ffffffff810d92d5>] __setup_irq+0x515/0x580
[  138.041693]  [<ffffffffa006cf00>] ? rtl8169_gset_xmii+0x20/0x20 [r8169]
[  138.048284]  [<ffffffff810d94c4>] request_threaded_irq+0xf4/0x1a0
[  138.054357]  [<ffffffffa0075cf7>] rtl_open+0x3a7/0xab4 [r8169]
[...]

- Alternatively I can still reproduce the SEGV in rtl_remove_one
  when trying to rmmod the module, I just don't have the stack dump
  handy while writing this mail.  I can show it if needed.

I debugged this on and off the entire day (tweaking, compiling, rebooting,
kernel crash, rinse and repeat).

And the result of my debugging is totally crazy:

If I disable the call to rtl_init_counter_offsets in rtl_open, as in

  #if 0
        retval =3D rtl_init_counter_offsets(dev);
	if (retval < 0)
		netif_warn(tp, hw, dev, "counter reset/update failed\n");
  #endif

the interfaces come up just fine.

If I reenable the rtl_init_counter_offsets call in rtl_open, and reduce
the rtl_init_counter_offsets function to just this:

  static int rtl_init_counter_offsets(struct net_device *dev)
  {
	  return 1;
  }

then the interfaces refuse to come up, and a subsequent `ip link ... up'
crashes the kernel.

No, I do not understand this :(


Corinna

--sLx0z+5FKKtIVDwd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV70OzAAoJEPU2Bp2uRE+gr3oP/0udz9aYO/Wx+zqqhGBD3LOi
Nb+AGzn6xxj8/8OOyNCAAR/3C5DJswbbGOpr3sRUxrfUg8HeDYZoiNJUS7ekK+Pv
npCSEy33YU98g6CK/Jos6H72yTZt+ZOtrbmfZmTtEXMmMhqg2s60lFKGYlfVqnyt
V2tH+WbpeNrh6SgJaZ7YY6VvmN5bKQaD1hZyGDt28yWCVQvPyknIdL+XsRcG3LxM
BaTfPnyRKuDRK7B4X/eMFLbhcWMDRAxHr0mS4fA9b0vj/uWozJvX+lvvmpWQMqC5
MhzZRFNaDrTHzbT1qSPm8sziGPSjDr/ukOwAJyW9QdZ6OdlJrJsnf8yzf5Yg83oO
9QFSiojdZuKy/d8MDDwGMGPS5ZuUWR15hOsGk4Yq0sd9tWuOHezXlDpi5l6d0LpY
ul+Gl32KdtRjumTyO06OYu4oq/s83DpMgJN5VbtuHD0UL2sITtZhKrG06bqjUEiC
qhWK72lr3GKUANvu3szhIkouGRzvtkAw/erI26PUkqK8qT5sz8mVF6ds9N7oCq2V
IN19JsVX+xVEbsBh2SQaJIAEDBAXlSP0QhdCeEWFlzoI1Fkdy6iBe/tb/uXsQ48y
gQlGC2iGFX+n8GDyedCb1lyZKlUKH+oEbJIo6FTrv9pJPEC6Qq1pW0K+Rg5ZiFMm
Lq00j4uaBUUtSeUmu7xk
=z657
-----END PGP SIGNATURE-----

--sLx0z+5FKKtIVDwd--
