From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] kptr_restrict for hiding kernel pointers from
 unprivileged users
Date: Thu, 09 Dec 2010 04:23:59 +0100
Message-ID: <1291865039.2795.46.camel@edumazet-laptop>
References: <1291863926.2965.1.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291863926.2965.1.camel@Dan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 08 d=C3=A9cembre 2010 =C3=A0 22:05 -0500, Dan Rosenberg a =C3=
=A9crit :
> The below patch adds the %pK format specifier, the
> CONFIG_SECURITY_KPTR_RESTRICT configuration option, and the
> kptr_restrict sysctl.
>=20
> The %pK format specifier is designed to hide exposed kernel pointers
> from unprivileged users, specifically via /proc interfaces.  Its
> behavior depends on the kptr_restrict sysctl, whose default value
> depends on CONFIG_SECURITY_KPTR_RESTRICT.  If kptr_restrict is set to=
 0,
> no deviation from the standard %p behavior occurs.  If kptr_restrict =
is
> set to 1, if the current user (intended to be a reader via seq_printf=
(),
> etc.) does not have CAP_SYSLOG (which is currently in the LSM tree),
> kernel pointers using %pK are printed as 0's.  This was chosen over t=
he
> default "(null)", which cannot be parsed by userland %p, which expect=
s
> "(nil)".
>=20

Thanks for not giving credits to people suggesting this idea to you
(Thomas if I remember well), and not Ccing netdev where original
discussion took place.=20


> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> ---=20
> Documentation/sysctl/kernel.txt |   14 ++++++++++++++
>  include/linux/kernel.h          |    2 ++
>  kernel/sysctl.c                 |    9 +++++++++
>  lib/vsprintf.c                  |   18 ++++++++++++++++++
>  security/Kconfig                |   12 ++++++++++++
>  5 files changed, 55 insertions(+), 0 deletions(-)

=2E..

> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index c150d3d..c011249 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -936,6 +936,8 @@ char *uuid_string(char *buf, char *end, const u8 =
*addr,
>  	return string(buf, end, uuid, spec);
>  }
> =20
> +int kptr_restrict =3D CONFIG_SECURITY_KPTR_RESTRICT;
> +
>  /*
>   * Show a '%p' thing.  A kernel extension is that the '%p' is follow=
ed
>   * by an extra set of alphanumeric characters that are extended form=
at
> @@ -979,6 +981,7 @@ char *uuid_string(char *buf, char *end, const u8 =
*addr,
>   *       Implements a "recursive vsnprintf".
>   *       Do not use this feature without some mechanism to verify th=
e
>   *       correctness of the format string and va_list arguments.
> + * - 'K' For a kernel pointer that should be hidden from unprivilege=
d users
>   *
>   * Note: The difference between 'S' and 'F' is that on ia64 and ppc6=
4
>   * function pointers are really function descriptors, which contain =
a
> @@ -1035,6 +1038,21 @@ char *pointer(const char *fmt, char *buf, char=
 *end, void *ptr,
>  		return buf + vsnprintf(buf, end - buf,
>  				       ((struct va_format *)ptr)->fmt,
>  				       *(((struct va_format *)ptr)->va));
> +	case 'K':
> +		if (kptr_restrict) {
> +			if (in_interrupt())
> +				WARN(1, "%%pK used in interrupt context.\n");

So caller can not block BH ?

This seems wrong to me, please consider :

normal process context :

spin_lock_bh() ...

for (...) =20
	{xxx}printf( ...   "%pK"   ...)

spin_unlock_bh();


> +
> +			else if (capable(CAP_SYSLOG))
> +				break;
> +
> +			if (spec.field_width =3D=3D -1) {
> +				spec.field_width =3D 2 * sizeof(void *);
> +				spec.flags |=3D ZEROPAD;
> +			}
> +			return number(buf, end, 0, spec);
> +		}
> +		break;
>  	}
>  	spec.flags |=3D SMALL;
>  	if (spec.field_width =3D=3D -1) {
> diff --git a/security/Kconfig b/security/Kconfig
> index e80da95..944fc73 100644
> --- a/security/Kconfig
> +++ b/security/Kconfig
> @@ -51,6 +51,18 @@ config SECURITY_DMESG_RESTRICT
> =20
>  	  If you are unsure how to answer this question, answer N.
> =20
> +config SECURITY_KPTR_RESTRICT
> +	bool "Hide kernel pointers from unprivileged users"
> +	default n
> +	help
> +	  This enforces restrictions on unprivileged users reading kernel
> +	  addresses via various interfaces, e.g. /proc.
> +
> +	  If this option is not selected, no restrictions will be enforced
> +	  unless the kptr_restrict sysctl is explicitly set to (1).
> +
> +	  If you are unsure how to answer this question, answer N.
> +
>  config SECURITY
>  	bool "Enable different security models"
>  	depends on SYSFS
>=20
