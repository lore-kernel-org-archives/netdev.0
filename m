From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [RFC PATCH] vsprintf: Add %p*D extension for 80211 SSIDs
Date: Mon, 07 Jan 2013 14:07:14 +0800
Message-ID: <50EA6612.6010506@asianux.com>
References: <50E82D7D.4090107@asianux.com>  <1357396966.21156.4.camel@joe-AO722> <50EA37CE.1090901@asianux.com>  <1357528746.4940.31.camel@joe-AO722> <1357534195.21481.31.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	stas.yakovlev@gmail.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:5792 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab3AGGGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 01:06:20 -0500
In-Reply-To: <1357534195.21481.31.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B401=E6=9C=8807=E6=97=A5 12:49, Joe Perches =E5=86=
=99=E9=81=93:
> On Sun, 2013-01-06 at 19:19 -0800, Joe Perches wrote:
>> Maybe these days this should be another vsprintf %p extension
>> like %pM when the DECLARE_MAC_BUF/print_mac uses were converted.
>>
>> (or maybe extend %ph for ssids with %*phs, length, array)
>=20

  excuse me:
    I do not quite know how to reply the [RFC PATCH].
    it would be better if you can tell me how to do for [RFC PATCH], th=
anks.

    :-)


  at least for me:

    although it is good idea to add common, widely used features in pub=
lic tools function.

    after searching the relative source code:
      it seems print ssid is not quite widely used (although it is a co=
mmon feature).
        it is used by drivers/net/wireless/libertas
        it is used by drivers/net/wireless/ipw2x00
        no additional using in current kernel source code wide.
      if another modules want to print ssid,
        they can still call print_ssid now (EXPORT_SYMBOL in net/wirele=
ss).

    so at least now, it is not necessary to add this feature to public =
tools function.

  Regards

gchen.

> Maybe like this:
>=20
>  lib/vsprintf.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++--
>  1 file changed, 55 insertions(+), 2 deletions(-)
>=20
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index fab33a9..98916a0 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -26,6 +26,7 @@
>  #include <linux/math64.h>
>  #include <linux/uaccess.h>
>  #include <linux/ioport.h>
> +#include <linux/ieee80211.h>
>  #include <net/addrconf.h>
> =20
>  #include <asm/page.h>		/* for PAGE_SIZE */
> @@ -660,10 +661,59 @@ char *resource_string(char *buf, char *end, str=
uct resource *res,
>  }
> =20
>  static noinline_for_stack
> +char *ssid_string(char *buf, char *end, u8 *addr, struct printf_spec=
 spec,
> +		  const char *fmt)
> +{
> +	int i, len =3D 1;		/* if we pass %*p, field width remains
> +				   negative value, fallback to the default */
> +
> +	if (spec.field_width =3D=3D 0)
> +		/* nothing to print */
> +		return buf;
> +
> +	if (ZERO_OR_NULL_PTR(addr))
> +		/* NULL pointer */
> +		return string(buf, end, NULL, spec);
> +
> +	if (spec.field_width > 0)
> +		len =3D min_t(int, spec.field_width, IEEE80211_MAX_SSID_LEN);
> +
> +	for (i =3D 0; i < len && buf < end; i++) {
> +		if (isprint(addr[i])) {
> +			*buf++ =3D addr[i];
> +			continue;
> +		}
> +		*buf++ =3D '\\';
> +		if (buf >=3D end)
> +			continue;
> +		if (addr[i] =3D=3D '\0')
> +			*buf++ =3D '0';
> +		else if (addr[i] =3D=3D '\n')
> +			*buf++ =3D 'n';
> +		else if (addr[i] =3D=3D '\r')
> +			*buf++ =3D 'r';
> +		else if (addr[i] =3D=3D '\t')
> +			*buf++ =3D 't';
> +		else if (addr[i] =3D=3D '\\')
> +			*buf++ =3D '\\';
> +		else {
> +			if (buf < end)
> +				*buf++ =3D ((addr[i] >> 6) & 7) + '0';
> +			if (buf < end)
> +				*buf++ =3D ((addr[i] >> 3) & 7) + '0';
> +			if (buf < end)
> +				*buf++ =3D ((addr[i] >> 0) & 7) + '0';
> +		}
> +	}
> +
> +	return buf;
> +}
> +
> +static noinline_for_stack
>  char *hex_string(char *buf, char *end, u8 *addr, struct printf_spec =
spec,
>  		 const char *fmt)
>  {
> -	int i, len =3D 1;		/* if we pass '%ph[CDN]', field witdh remains
> +	int i, len =3D 1;		/* if we pass '%ph[CDN]', field width remains
>  				   negative value, fallback to the default */
>  	char separator;
> =20
> @@ -695,7 +745,6 @@ char *hex_string(char *buf, char *end, u8 *addr, =
struct printf_spec spec,
> =20
>  	for (i =3D 0; i < len && buf < end - 1; i++) {
>  		buf =3D hex_byte_pack(buf, addr[i]);
> -
>  		if (buf < end && separator && i !=3D len - 1)
>  			*buf++ =3D separator;
>  	}
> @@ -1016,6 +1065,8 @@ int kptr_restrict __read_mostly;
>   *             [0][1][2][3]-[4][5]-[6][7]-[8][9]-[10][11][12][13][14=
][15]
>   *           little endian output byte order is:
>   *             [3][2][1][0]-[5][4]-[7][6]-[8][9]-[10][11][12][13][14=
][15]
> + * - 'D' For a 80211 SSID, it prints the SSID escaping any non-print=
able
> +         characters with a leading \ and octal or [0nrt\]
>   * - 'V' For a struct va_format which contains a format string * and=
 va_list *,
>   *       call vsnprintf(->format, *->va_list).
>   *       Implements a "recursive vsnprintf".
> @@ -1088,6 +1139,8 @@ char *pointer(const char *fmt, char *buf, char =
*end, void *ptr,
>  		break;
>  	case 'U':
>  		return uuid_string(buf, end, ptr, spec, fmt);
> +	case 'D':
> +		return ssid_string(buf, end, ptr, spec, fmt);
>  	case 'V':
>  		{
>  			va_list va;
>=20
>=20
>=20
>=20


--=20
Chen Gang

Asianux Corporation
