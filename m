From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the mips tree
Date: Wed, 15 Jan 2014 13:24:36 +1100
Message-ID: <20140115132436.8b89920c1ed4c0d293883b85@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__15_Jan_2014_13_24_36_+1100_R9OXwE5CiIP2G.9j"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?B?IlJhZmHFgiBNacWCZWNraSI=?= <zajec5@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__15_Jan_2014_13_24_36_+1100_R9OXwE5CiIP2G.9j
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in arch/mips/b=
cm47xx/setup.c between commits dc8db0fd9f9f ("MIPS: BCM47XX: Prepare suppor=
t for LEDs"), db780310ed48 ("MIPS: BCM47XX: Prepare support for GPIO button=
s") and 7fb942c59696 ("MIPS: BCM47XX: fix position of cpu_wait disabling") =
from the mips tree and commit b04138b33520 ("b44: use fixed PHY device if w=
e do not find any") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/mips/bcm47xx/setup.c
index 12d77e9c2cb4,9057728ac56b..000000000000
--- a/arch/mips/bcm47xx/setup.c
+++ b/arch/mips/bcm47xx/setup.c
@@@ -26,10 -26,11 +26,13 @@@
   *  675 Mass Ave, Cambridge, MA 02139, USA.
   */
 =20
 +#include "bcm47xx_private.h"
 +
  #include <linux/export.h>
  #include <linux/types.h>
+ #include <linux/ethtool.h>
+ #include <linux/phy.h>
+ #include <linux/phy_fixed.h>
  #include <linux/ssb/ssb.h>
  #include <linux/ssb/ssb_embedded.h>
  #include <linux/bcma/bcma_soc.h>
@@@ -229,34 -226,14 +232,40 @@@ void __init plat_mem_setup(void
  	_machine_halt =3D bcm47xx_machine_halt;
  	pm_power_off =3D bcm47xx_machine_halt;
  	bcm47xx_board_detect();
 +	mips_set_machine_name(bcm47xx_board_get_name());
  }
 =20
 +static int __init bcm47xx_cpu_fixes(void)
 +{
 +	switch (bcm47xx_bus_type) {
 +#ifdef CONFIG_BCM47XX_SSB
 +	case BCM47XX_BUS_TYPE_SSB:
 +		/* Nothing to do */
 +		break;
 +#endif
 +#ifdef CONFIG_BCM47XX_BCMA
 +	case BCM47XX_BUS_TYPE_BCMA:
 +		/* The BCM4706 has a problem with the CPU wait instruction.
 +		 * When r4k_wait or r4k_wait_irqoff is used will just hang and
 +		 * not return from a msleep(). Removing the cpu_wait
 +		 * functionality is a workaround for this problem. The BCM4716
 +		 * does not have this problem.
 +		 */
 +		if (bcm47xx_bus.bcma.bus.chipinfo.id =3D=3D BCMA_CHIP_ID_BCM4706)
 +			cpu_wait =3D NULL;
 +		break;
 +#endif
 +	}
 +	return 0;
 +}
 +arch_initcall(bcm47xx_cpu_fixes);
 +
+ static struct fixed_phy_status bcm47xx_fixed_phy_status __initdata =3D {
+ 	.link	=3D 1,
+ 	.speed	=3D SPEED_100,
+ 	.duplex	=3D DUPLEX_FULL,
+ };
+=20
  static int __init bcm47xx_register_bus_complete(void)
  {
  	switch (bcm47xx_bus_type) {
@@@ -271,9 -248,7 +280,10 @@@
  		break;
  #endif
  	}
 +	bcm47xx_buttons_register();
 +	bcm47xx_leds_register();
 +
+ 	fixed_phy_add(PHY_POLL, 0, &bcm47xx_fixed_phy_status);
  	return 0;
  }
  device_initcall(bcm47xx_register_bus_complete);

--Signature=_Wed__15_Jan_2014_13_24_36_+1100_R9OXwE5CiIP2G.9j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS1fFsAAoJEMDTa8Ir7ZwVhNEP/ArxfSdJ0zT6uSqnFWgAYp5r
wNpfB9W8i+f/4pKBE36nGeT+OlEUpT3C+6Wz9EBHegxaoGyYDXg10cGyhHE0fiCv
9ssb1XIMG4sbD5V4j1O72hTwzDNsTyQM4D/EywsQAR+nP/IxtN/009yl8XxNc65h
5z3xUhrvJhDGawUvcW9VKEEWLO4x+vncBk/KJCrX9DTroeuUFwCmMegR6TpfF9e0
EYRu0viVrSBPr2FWTcDVcqrgvPE+d9/6m5aP65FpDHBhI01HPIg01kGJzeTvuqlK
kcEqNF0SXH2GizzZGkaV+d13juQ3wzTFCDbMaPrcXrboDzVU9bkIhgQvx6qmJUhf
YFYbuMAtsj+XCKqqbN5FYaqbizZyc6Q7ko4orooQEF/qA1OkLhXCOMrFVZEIBCFx
tAcJZ8HZt1o4pFO4UJxIti5HkOqLMDpZja3q3M1gqXJHG0h6WWHB38V+rGsnRO8x
2wpGmah38bUrh6QBQNVWWIUAPYSglGMThA64fZgQ0nU5siqzWEfzzR1auHWk/UBz
+chAJhAX0LWeDEpFIap4vAKmKFj+Q8VJS1Nt0n4XMWBL2/Bbmo+9HtvM1DmEYLxt
mFES2xSLB8Zy4b+4XfTbH9wzbn2bic3WTiVx0fJMZ6ErtB2DqpxEwHpd2jyNwvBx
BTgeAdxmQ50Lu+/T8QK4
=UWkI
-----END PGP SIGNATURE-----

--Signature=_Wed__15_Jan_2014_13_24_36_+1100_R9OXwE5CiIP2G.9j--
