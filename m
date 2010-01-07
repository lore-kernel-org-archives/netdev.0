From: Joe Perches <joe@perches.com>
Subject: [PATCH V2] lib/vsprintf.c: Add %pMF to format FDDI bit reversed
 MAC addresses
Date: Thu, 07 Jan 2010 13:37:18 -0800
Message-ID: <1262900238.10429.78.camel@Joe-Laptop.home>
References: <BD79186B4FD85F4B8E60E381CAEE19090208954A@mi8nycmail19.Mi8.com>
	 <1262888625.10429.23.camel@Joe-Laptop.home>
	 <e2d7436a1001071318l75750b29uece2a61884538d5b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: H Hartley Sweeten <hartleys@visionengravers.com>,
	David Miller <davem@davemloft.net>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1628 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570Ab0AGVhT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 16:37:19 -0500
In-Reply-To: <e2d7436a1001071318l75750b29uece2a61884538d5b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-01-04 at 23:43 +0000, Maciej W. Rozycki wrote:
> The example below shows an address, and the sequence of bits or symbo=
ls=20
> that would be transmitted when the address is used in the Source Addr=
ess=20
> or Destination Address fields on the MAC header.  The transmission li=
ne=20
> shows the address bits in the order transmitted, from left to right. =
 For=20
> IEEE 802 LANs these correspond to actual bits on the medium.  The FDD=
I=20
> symbols line shows how the FDDI PHY sends the address bits as encoded=
=20
> symbols.
>=20
>         MSB:            35:7B:12:00:00:01
>         Canonical:      AC-DE-48-00-00-80
>         Transmission:   00110101 01111011 00010010 00000000 00000000 =
00000001
>         FDDI Symbols:   35 7B 12 00 00 01"
>=20
> Please note that this address has its group bit clear.
>=20
>  This notation is also defined in the "FDDI MEDIA ACCESS CONTROL-2=20
> (MAC-2)" (X3T9/92-120) document although that book does not have a ne=
ed=20
> to use the MSB form and it's skipped.

Adds 6 bytes to object size for x86

New:
$ size lib/vsprintf.o
   text	   data	    bss	    dec	    hex	filename
   8664	      0	      2	   8666	   21da	lib/vsprintf.o
$ size lib/vsprintf.o
   text    data     bss     dec     hex filename
   8658       0       2    8660    21d4 lib/vsprintf.o

Signed-off-by: Joe Perches <joe@perches.com>On Thu, 2010-01-07 at 22:18=
 +0100, Micha=C5=82 Miros=C5=82aw wrote:
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index d4996cf..dc48d2b 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -25,6 +25,7 @@
 #include <linux/kallsyms.h>
 #include <linux/uaccess.h>
 #include <linux/ioport.h>
+#include <linux/bitrev.h>
 #include <net/addrconf.h>
=20
 #include <asm/page.h>		/* for PAGE_SIZE */
@@ -681,11 +682,21 @@ static char *mac_address_string(char *buf, char *=
end, u8 *addr,
 	char mac_addr[sizeof("xx:xx:xx:xx:xx:xx")];
 	char *p =3D mac_addr;
 	int i;
+	bool bitrev;
+	char separator;
+
+	if (fmt[1] =3D=3D 'F') {		/* FDDI canonical format */
+		bitrev =3D true;
+		separator =3D '-';
+	} else {
+		bitrev =3D false;
+		separator =3D ':';
+	}
=20
 	for (i =3D 0; i < 6; i++) {
-		p =3D pack_hex_byte(p, addr[i]);
+		p =3D pack_hex_byte(p, bitrev ? bitrev8(addr[i]) : addr[i]);
 		if (fmt[0] =3D=3D 'M' && i !=3D 5)
-			*p++ =3D ':';
+			*p++ =3D separator;
 	}
 	*p =3D '\0';
=20
@@ -896,6 +907,10 @@ static char *uuid_string(char *buf, char *end, con=
st u8 *addr,
  * - 'M' For a 6-byte MAC address, it prints the address in the
  *       usual colon-separated hex notation
  * - 'm' For a 6-byte MAC address, it prints the hex address without c=
olons
+ * - 'MF' For a 6-byte MAC FDDI address, it prints the address
+ *       with a dash-separated hex notation with bit reversed bytes
+ * - 'mF' For a 6-byte MAC FDDI address, it prints the address
+ *       in hex notation without separators with bit reversed bytes
  * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way
  *       IPv4 uses dot-separated decimal without leading 0's (1.2.3.4)
  *       IPv6 uses colon separated network-order 16 bit hex with leadi=
ng 0's
@@ -939,6 +954,7 @@ static char *pointer(const char *fmt, char *buf, ch=
ar *end, void *ptr,
 		return resource_string(buf, end, ptr, spec, fmt);
 	case 'M':			/* Colon separated: 00:01:02:03:04:05 */
 	case 'm':			/* Contiguous: 000102030405 */
+					/* [mM]F (FDDI, bit reversed) */
 		return mac_address_string(buf, end, ptr, spec, fmt);
 	case 'I':			/* Formatted IP supported
 					 * 4:	1.2.3.4


