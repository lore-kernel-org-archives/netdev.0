From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
Subject: Re: [PATCH] net: change capability used by socket options
 IP{,V6}_TRANSPARENT
Date: Fri, 23 Sep 2011 09:45:07 -0500
Message-ID: <20110923144507.GB4175@sergelap>
References: <1315927629.5851.4.camel@bzorp>
 <1316734189-26668-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	James Morris <jmorris@namei.org>
To: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1316734189-26668-1-git-send-email-zenczykowski@gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Maciej =C5=BBenczykowski (zenczykowski@gmail.com):
> From: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> Up till now the IP{,V6}_TRANSPARENT socket options (which actually se=
t
> the same bit in the socket struct) have required CAP_NET_ADMIN
> privileges to set or clear the option.
>=20
> - we make clearing the bit not require any privileges.
> - we deprecate using CAP_NET_ADMIN for this purpose.
> - we introduce a new capability CAP_NET_TRANSPARENT,
>   which is tailored to allow setting just this bit.
> - we allow either one of CAP_NET_TRANSPARENT or CAP_NET_RAW
>   to set this bit, because raw sockets already effectively
>   allow you to emulate socket transparency, and make the
>   transition easier for apps not desiring to use a brand
>   new capability (because of header file or glibc support)
> - we print a warning (but allow it) if you try to set
>   the socket option with CAP_NET_ADMIN privs, but without
>   either one of CAP_NET_TRANSPARENT or CAP_NET_RAW.
>=20
> The reason for introducing a new capability is that while
> transparent sockets are potentially dangerous (and can let you
> spoof your source IP on traffic), they don't normally give you
> the full 'freedom' of eavesdropping and/or spoofing that raw sockets
> give you.
>=20
> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
> Acked-by: Balazs Scheidler <bazsi@balabit.hu>
> Acked-by: David Miller <davem@redhat.com>

Looks good to me.  Please do make sure to also send the required
patch for libcap2.

Should the comments in capability.h reference each other to make
clear that it's not a mistake, either one offers the privilege?
I know it's clear from the comment in the code itself, but something
like

> +/*
> + * Allow binding to any address for transparent proxying - either
> + * this or CAP_NET_TRANSPARENT can be used
> + */

In any case,

Acked-by: Serge Hallyn <serge.hallyn@canonical.com>

thanks,
-serge

> ---
>  include/linux/capability.h |   13 +++++++++----
>  net/ipv4/ip_sockglue.c     |   26 ++++++++++++++++++++++----
>  net/ipv6/ipv6_sockglue.c   |   29 ++++++++++++++++++++++++-----
>  3 files changed, 55 insertions(+), 13 deletions(-)
>=20
> diff --git a/include/linux/capability.h b/include/linux/capability.h
> index c421123..a115ed4 100644
> --- a/include/linux/capability.h
> +++ b/include/linux/capability.h
> @@ -198,7 +198,7 @@ struct cpu_vfs_cap_data {
>  /* Allow modification of routing tables */
>  /* Allow setting arbitrary process / process group ownership on
>     sockets */
> -/* Allow binding to any address for transparent proxying */
> +/* Allow binding to any address for transparent proxying (deprecated=
) */
>  /* Allow setting TOS (type of service) */
>  /* Allow setting promiscuous mode */
>  /* Allow clearing driver statistics */
> @@ -210,6 +210,7 @@ struct cpu_vfs_cap_data {
> =20
>  /* Allow use of RAW sockets */
>  /* Allow use of PACKET sockets */
> +/* Allow binding to any address for transparent proxying */
> =20
>  #define CAP_NET_RAW          13
> =20
> @@ -332,7 +333,7 @@ struct cpu_vfs_cap_data {
> =20
>  #define CAP_AUDIT_CONTROL    30
> =20
> -#define CAP_SETFCAP	     31
> +#define CAP_SETFCAP          31
> =20
>  /* Override MAC access.
>     The base kernel enforces no MAC policy.
> @@ -357,10 +358,14 @@ struct cpu_vfs_cap_data {
> =20
>  /* Allow triggering something that will wake the system */
> =20
> -#define CAP_WAKE_ALARM            35
> +#define CAP_WAKE_ALARM       35
> +
> +/* Allow binding to any address for transparent proxying */
> +
> +#define CAP_NET_TRANSPARENT  36
> =20
> =20
> -#define CAP_LAST_CAP         CAP_WAKE_ALARM
> +#define CAP_LAST_CAP         CAP_NET_TRANSPARENT
> =20
>  #define cap_valid(x) ((x) >=3D 0 && (x) <=3D CAP_LAST_CAP)
> =20
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index 8905e92..44efa39 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -961,12 +961,30 @@ mc_msf_out:
>  		break;
> =20
>  	case IP_TRANSPARENT:
> -		if (!capable(CAP_NET_ADMIN)) {
> -			err =3D -EPERM;
> -			break;
> -		}
>  		if (optlen < 1)
>  			goto e_inval;
> +		/* Always allow clearing the transparent proxy socket option.
> +		 * The pre-3.2 permission for setting this was CAP_NET_ADMIN,
> +		 * and this is still supported - but deprecated.  As of Linux
> +		 * 3.2 the proper permission is one of CAP_NET_TRANSPARENT
> +		 * (preferred, a new capability) or CAP_NET_RAW.  The latter
> +		 * is supported to make the transition easier (and because
> +		 * raw sockets already effectively allow one to emulate
> +		 * socket transparency).
> +		 */
> +		if (!!val && !capable(CAP_NET_TRANSPARENT)
> +		          && !capable(CAP_NET_RAW)) {
> +			if (!capable(CAP_NET_ADMIN)) {
> +				err =3D -EPERM;
> +				break;
> +			}
> +			printk_once(KERN_WARNING "%s (%d): "
> +				 "deprecated: attempt to set socket option "
> +				 "IP_TRANSPARENT with CAP_NET_ADMIN but "
> +				 "without either one of CAP_NET_TRANSPARENT "
> +				 "or CAP_NET_RAW.\n",
> +				 current->comm, task_pid_nr(current));
> +		}
>  		inet->transparent =3D !!val;
>  		break;
> =20
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index 2fbda5f..b8315c8 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -343,13 +343,32 @@ static int do_ipv6_setsockopt(struct sock *sk, =
int level, int optname,
>  		break;
> =20
>  	case IPV6_TRANSPARENT:
> -		if (!capable(CAP_NET_ADMIN)) {
> -			retv =3D -EPERM;
> -			break;
> -		}
>  		if (optlen < sizeof(int))
>  			goto e_inval;
> -		/* we don't have a separate transparent bit for IPV6 we use the on=
e in the IPv4 socket */
> +		/* Always allow clearing the transparent proxy socket option.
> +		 * The pre-3.2 permission for setting this was CAP_NET_ADMIN,
> +		 * and this is still supported - but deprecated.  As of Linux
> +		 * 3.2 the proper permission is one of CAP_NET_TRANSPARENT
> +		 * (preferred, a new capability) or CAP_NET_RAW.  The latter
> +		 * is supported to make the transition easier (and because
> +		 * raw sockets already effectively allow one to emulate
> +		 * socket transparency).
> +		 */
> +		if (valbool && !capable(CAP_NET_TRANSPARENT)
> +		            && !capable(CAP_NET_RAW)) {
> +			if (!capable(CAP_NET_ADMIN)) {
> +				retv =3D -EPERM;
> +				break;
> +			}
> +			printk_once(KERN_WARNING "%s (%d): "
> +				 "deprecated: attempt to set socket option "
> +				 "IPV6_TRANSPARENT with CAP_NET_ADMIN but "
> +				 "without either one of CAP_NET_TRANSPARENT "
> +				 "or CAP_NET_RAW.\n",
> +				 current->comm, task_pid_nr(current));
> +		}
> +		/* we don't have a separate transparent bit for IPV6 we use the
> +		 * one in the IPv4 socket */
>  		inet_sk(sk)->transparent =3D valbool;
>  		retv =3D 0;
>  		break;
> --=20
> 1.7.3.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-secur=
ity-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
