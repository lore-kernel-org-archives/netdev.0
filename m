From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the random tree with the net-next tree
Date: Tue, 12 Nov 2013 15:55:49 +1100
Message-ID: <20131112155549.c160273993147244ed6bc81d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__12_Nov_2013_15_55_49_+1100_sxF61Q2z/L/7tjR3"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: "Theodore Ts'o" <tytso@mit.edu>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__12_Nov_2013_15_55_49_+1100_sxF61Q2z/L/7tjR3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Ted,

Today's linux-next merge of the random tree got a conflict in
drivers/char/random.c between commit 0244ad004a54 ("random32: add
prandom_reseed_late() and call when nonblocking pool becomes
initialized") from the net-next tree and commit 301f0595c0e7 ("random:
printk notifications for urandom pool initialization") from the random
tree.

I fixed it up (probably not properly - see below) and can carry the fix
as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/char/random.c
index 4fe5609eeb72,cdf4cfb2da4d..000000000000
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@@ -255,8 -255,12 +255,9 @@@
  #include <linux/fips.h>
  #include <linux/ptrace.h>
  #include <linux/kmemcheck.h>
 +#include <linux/irq.h>
+ #include <linux/workqueue.h>
 =20
 -#ifdef CONFIG_GENERIC_HARDIRQS
 -# include <linux/irq.h>
 -#endif
 -
  #include <asm/processor.h>
  #include <asm/uaccess.h>
  #include <asm/irq.h>
@@@ -601,12 -654,14 +651,16 @@@ retry
  	if (cmpxchg(&r->entropy_count, orig, entropy_count) !=3D orig)
  		goto retry;
 =20
+ 	r->entropy_total +=3D nbits;
  	if (!r->initialized && nbits > 0) {
- 		r->entropy_total +=3D nbits;
  		if (r->entropy_total > 128) {
+ 			if (r =3D=3D &nonblocking_pool)
+ 				pr_notice("random: %s pool is initialized\n",
+ 					  r->name);
  			r->initialized =3D 1;
 +			if (r =3D=3D &nonblocking_pool)
 +				prandom_reseed_late();
+ 			r->entropy_total =3D 0;
  		}
  	}
 =20

--Signature=_Tue__12_Nov_2013_15_55_49_+1100_sxF61Q2z/L/7tjR3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSgbTZAAoJEMDTa8Ir7ZwVM6EP/jqWGOkXLehMTDq3k35DvAcC
OG9bp4ifSD5JdYoqBaiFxE1L5cCMv8UONj8CYmRkkcCGK1t0Y6/MLxY6424lb7lA
7ZMlOkOZ7bgu4E9xDOcYj9IJNhKKC740EoLvBVbjGdZ4tAGyx2IcUCdK8j38iV4r
W0D5SZtgMWqBBgwhVwkcDNCjeOhLzhgPqBjQC9lDQJHbsTJ8963A4BM82ViiBY9Y
MfpvG60ol/Kdxh2SZqpsNiBL0/Myx5cdka2Kj5vMdlB/Zq2f6NsirdgN05GsKUDf
CBajnETNTZSifYIA9+11Vidz+ql1DwoQc6tZd0fNZpGU6hZ/lec/3fwT/TGTG8jc
OQVG8Vju3E+4FgEujhSGzIhLF0gERwNsyNXadROrl6LfGBnkzpYoOgZE2/3CWAn7
SDcc1Y2BTI6RM93O0s/ukMpKu6HaEXrbZ6o0jjn+6vs+EcCtM/rhkuw4INlPUwqD
NEY46pFAhcLCoLO1OJgB0qz+JPGJH1xhHeahfOIngTiLUXr75xbYePKzfWXidyfJ
DGZAPkPdBxoqyHkQbAmKaCse9Hx8wneBGLnORn/6kW6O/TBnsPgtwnf4vs7O8M8I
Af8g0vfZndS4eyIaFmsb6uK83OPS7tzL1cfL14Wif76pHspG02Wt8ka3ZRUOrDD6
8oOsGUf6NVhYUrGe7rgo
=vFsE
-----END PGP SIGNATURE-----

--Signature=_Tue__12_Nov_2013_15_55_49_+1100_sxF61Q2z/L/7tjR3--
