From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] lib/vsprintf.c: Add %pMF to format FDDI bit reversed MAC
	addresses
Date: Thu, 7 Jan 2010 22:18:55 +0100
Message-ID: <e2d7436a1001071318l75750b29uece2a61884538d5b@mail.gmail.com>
References: <BD79186B4FD85F4B8E60E381CAEE19090208954A@mi8nycmail19.Mi8.com>
	 <1262888625.10429.23.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: H Hartley Sweeten <hartleys@visionengravers.com>,
	David Miller <davem@davemloft.net>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:44686 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027Ab0AGVS5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 16:18:57 -0500
In-Reply-To: <1262888625.10429.23.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/1/7 Joe Perches <joe@perches.com>:
[...]
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index d4996cf..36959cc 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -25,6 +25,7 @@
> =A0#include <linux/kallsyms.h>
> =A0#include <linux/uaccess.h>
> =A0#include <linux/ioport.h>
> +#include <linux/bitrev.h>
> =A0#include <net/addrconf.h>
>
> =A0#include <asm/page.h> =A0 =A0 =A0 =A0 =A0/* for PAGE_SIZE */
> @@ -675,17 +676,37 @@ static char *resource_string(char *buf, char *e=
nd, struct resource *res,
> =A0 =A0 =A0 =A0return string(buf, end, sym, spec);
> =A0}
>
> +static u8 mac_byte(u8 val)
> +{
> + =A0 =A0 =A0 return val;
> +}
> +
> +static u8 mac_byte_rev(u8 val)
> +{
> + =A0 =A0 =A0 return bitrev8(val);
> +}
> +
> =A0static char *mac_address_string(char *buf, char *end, u8 *addr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct=
 printf_spec spec, const char *fmt)
> =A0{
> =A0 =A0 =A0 =A0char mac_addr[sizeof("xx:xx:xx:xx:xx:xx")];
> =A0 =A0 =A0 =A0char *p =3D mac_addr;
> =A0 =A0 =A0 =A0int i;
> + =A0 =A0 =A0 u8 (*mac_byte_fn)(u8 val);
> + =A0 =A0 =A0 char separator;
> +
> + =A0 =A0 =A0 if (fmt[1] =3D=3D 'F') { =A0 =A0 =A0 =A0 =A0 =A0/* FDDI=
 canonical format */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mac_byte_fn =3D mac_byte_rev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 separator =3D '-';
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mac_byte_fn =3D mac_byte;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 separator =A0=3D ':';
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < 6; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D pack_hex_byte(p, addr[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D pack_hex_byte(p, mac_byte_fn(addr=
[i]));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (fmt[0] =3D=3D 'M' && i !=3D 5)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *p++ =3D ':';
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *p++ =3D separator;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0*p =3D '\0';
>
[...]

Something like the following might be smaller and faster - no
functions and their calls (just an idea);

int rev =3D (fmt[1] =3D=3D 'F');
=2E..
p =3D pack_hex_byte(p, rev ? bitrev8(addr[i]) : addr[i]);

Best Regards,
Micha=B3 Miros=B3aw
