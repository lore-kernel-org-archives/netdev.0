From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 01/14] Phonet global definitions
Date: Wed, 17 Sep 2008 14:31:42 +1000
Message-ID: <20080917043142.GB7265@verge.net.au>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41469 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbYIQEbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 00:31:44 -0400
Content-Disposition: inline
In-Reply-To: <1221577694-4513-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2008 at 06:08:01PM +0300, R=E9mi Denis-Courmont wrote:
> Common global definitions for Phonet.
>=20
> Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  include/linux/if_ether.h  |    1 +
>  include/linux/if_phonet.h |   14 +++++
>  include/linux/phonet.h    |  133 +++++++++++++++++++++++++++++++++++=
++++++++++
>  include/linux/rtnetlink.h |    4 ++
>  include/linux/socket.h    |    4 +-
>  net/core/sock.c           |    9 ++-
>  6 files changed, 161 insertions(+), 4 deletions(-)
>  create mode 100644 include/linux/if_phonet.h
>  create mode 100644 include/linux/phonet.h
>=20
> diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
> index 5028e0b..723a1c5 100644
> --- a/include/linux/if_ether.h
> +++ b/include/linux/if_ether.h
> @@ -100,6 +100,7 @@
>  #define ETH_P_ECONET	0x0018		/* Acorn Econet			*/
>  #define ETH_P_HDLC	0x0019		/* HDLC frames			*/
>  #define ETH_P_ARCNET	0x001A		/* 1A for ArcNet :-)            */
> +#define ETH_P_PHONET	0x00F5		/* Nokia Phonet frames          */
> =20
>  /*
>   *	This is an Ethernet frame header.
> diff --git a/include/linux/if_phonet.h b/include/linux/if_phonet.h
> new file mode 100644
> index 0000000..22df25f
> --- /dev/null
> +++ b/include/linux/if_phonet.h
> @@ -0,0 +1,14 @@
> +/*
> + * File: if_phonet.h
> + *
> + * Phonet interface kernel definitions
> + *
> + * Copyright (C) 2008 Nokia Corporation. All rights reserved.
> + */
> +
> +#define PHONET_HEADER_LEN	8	/* Phonet header length */
> +
> +#define PHONET_MIN_MTU		6
> +/* 6 bytes header + 65535 bytes payload */
> +#define PHONET_MAX_MTU		65541
> +#define PHONET_DEV_MTU		PHONET_MAX_MTU
> diff --git a/include/linux/phonet.h b/include/linux/phonet.h
> new file mode 100644
> index 0000000..000b6d7
> --- /dev/null
> +++ b/include/linux/phonet.h
> @@ -0,0 +1,133 @@
> +/**
> + * file phonet.h
> + *
> + * Phonet sockets kernel interface
> + *
> + * Copyright (C) 2008 Nokia Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful, b=
ut
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + * General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
> + * 02110-1301 USA
> + */
> +
> +#ifndef LINUX_PHONET_H
> +#define LINUX_PHONET_H
> +
> +/* Automatic protocol selection */
> +#define PN_PROTO_TRANSPORT	0
> +/* Phonet datagram socket */
> +#define PN_PROTO_PHONET		1
> +#define PHONET_NPROTO		2
> +
> +#define PNADDR_ANY		0
> +#define PNPORT_RESOURCE_ROUTING	0
> +
> +/* Phonet protocol header */
> +struct phonethdr {
> +	uint8_t rdev;
> +	uint8_t sdev;
> +	uint8_t function;
> +	uint16_t length;
> +	uint8_t robj;
> +	uint8_t sobj;
> +} __attribute__((packed));

I beleive that the prefered style is to use u8 and friends for internal=
 kernel
structures and __u8 and friends for ones that are exported to userspace=
=2E
Ditto below.

> +
> +/* Phonet message */
> +struct phonetmsg {
> +	struct phonethdr ph;
> +	uint8_t data[0];
> +};
> +
> +/* Phonet socket address structure */
> +struct sockaddr_pn {
> +	sa_family_t spn_family;
> +	uint8_t spn_obj;
> +	uint8_t spn_dev;
> +	uint8_t spn_resource;
> +	uint8_t spn_zero[sizeof(struct sockaddr)
> +				- sizeof(sa_family_t) - 3 * sizeof(uint8_t)];
> +} __attribute__ ((packed));
> +
> +static inline uint16_t pn_object(uint8_t addr, uint16_t port)
> +{
> +	return (addr << 8) | (port & 0x3ff);
> +}
> +
> +static inline uint8_t pn_obj(uint16_t handle)
> +{
> +	return handle & 0xff;
> +}
> +
> +static inline uint8_t pn_dev(uint16_t handle)
> +{
> +	return handle >> 8;
> +}
> +
> +static inline uint16_t pn_port(uint16_t handle)
> +{
> +	return handle & 0x3ff;
> +}
> +
> +static inline uint8_t pn_addr(uint16_t handle)
> +{
> +	return (handle >> 8) & 0xfc;
> +}
> +
> +static inline void pn_sockaddr_set_addr(struct sockaddr_pn *spn, uin=
t8_t addr)
> +{
> +	spn->spn_dev &=3D 0x03;
> +	spn->spn_dev |=3D addr & 0xfc;
> +}
> +
> +static inline void pn_sockaddr_set_port(struct sockaddr_pn *spn,
> +					uint16_t port)
> +{
> +	spn->spn_dev &=3D 0xfc;
> +	spn->spn_dev |=3D (port >> 8) & 0x03;
> +	spn->spn_obj =3D port & 0xff;
> +}
> +
> +static inline void pn_sockaddr_set_object(struct sockaddr_pn *spn,
> +						uint16_t handle)
> +{
> +	spn->spn_dev =3D pn_dev(handle);
> +	spn->spn_obj =3D pn_obj(handle);
> +}
> +
> +static inline void pn_sockaddr_set_resource(struct sockaddr_pn *spn,
> +						uint8_t resource)
> +{
> +	spn->spn_resource =3D resource;
> +}
> +
> +static inline uint8_t pn_sockaddr_get_addr(const struct sockaddr_pn =
*spn)
> +{
> +	return spn->spn_dev & 0xfc;
> +}
> +
> +static inline uint16_t pn_sockaddr_get_port(const struct sockaddr_pn=
 *spn)
> +{
> +	return ((spn->spn_dev & 0x03) << 8) | spn->spn_obj;
> +}
> +
> +static inline uint16_t pn_sockaddr_get_object(const struct sockaddr_=
pn *spn)
> +{
> +	return pn_object(spn->spn_dev, spn->spn_obj);
> +}
> +
> +static inline uint8_t pn_sockaddr_get_resource(const struct sockaddr=
_pn *spn)
> +{
> +	return spn->spn_resource;
> +}
> +
> +#endif
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index ca643b1..2b3d51c 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -582,6 +582,10 @@ enum rtnetlink_groups {
>  #define RTNLGRP_IPV6_RULE	RTNLGRP_IPV6_RULE
>  	RTNLGRP_ND_USEROPT,
>  #define RTNLGRP_ND_USEROPT	RTNLGRP_ND_USEROPT
> +	RTNLGRP_PHONET_IFADDR,
> +#define RTNLGRP_PHONET_IFADDR	RTNLGRP_PHONET_IFADDR
> +	RTNLGRP_PHONET_ROUTE,
> +#define RTNLGRP_PHONET_ROUTE	RTNLGRP_PHONET_ROUTE
>  	__RTNLGRP_MAX
>  };
>  #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index dc5086f..818ca33 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -190,7 +190,8 @@ struct ucred {
>  #define AF_IUCV		32	/* IUCV sockets			*/
>  #define AF_RXRPC	33	/* RxRPC sockets 		*/
>  #define AF_ISDN		34	/* mISDN sockets 		*/
> -#define AF_MAX		35	/* For now.. */
> +#define AF_PHONET	35	/* Phonet sockets		*/
> +#define AF_MAX		36	/* For now.. */
> =20
>  /* Protocol families, same as address families. */
>  #define PF_UNSPEC	AF_UNSPEC
> @@ -227,6 +228,7 @@ struct ucred {
>  #define PF_IUCV		AF_IUCV
>  #define PF_RXRPC	AF_RXRPC
>  #define PF_ISDN		AF_ISDN
> +#define PF_PHONET	AF_PHONET
>  #define PF_MAX		AF_MAX
> =20
>  /* Maximum queue length specifiable by listen.  */
> diff --git a/net/core/sock.c b/net/core/sock.c
> index d823978..4ce2145 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -154,7 +154,8 @@ static const char *af_family_key_strings[AF_MAX+1=
] =3D {
>    "sk_lock-AF_PPPOX" , "sk_lock-AF_WANPIPE"  , "sk_lock-AF_LLC"     =
 ,
>    "sk_lock-27"       , "sk_lock-28"          , "sk_lock-AF_CAN"     =
 ,
>    "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"       =
 ,
> -  "sk_lock-AF_RXRPC" , "sk_lock-AF_MISDN"    , "sk_lock-AF_MAX"
> +  "sk_lock-AF_RXRPC" , "sk_lock-AF_MISDN"    , "sk_lock-AF_PHONET"  =
 ,
> +  "sk_lock-AF_MAX"
>  };
>  static const char *af_family_slock_key_strings[AF_MAX+1] =3D {
>    "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
> @@ -168,7 +169,8 @@ static const char *af_family_slock_key_strings[AF=
_MAX+1] =3D {
>    "slock-AF_PPPOX" , "slock-AF_WANPIPE"  , "slock-AF_LLC"      ,
>    "slock-27"       , "slock-28"          , "slock-AF_CAN"      ,
>    "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
> -  "slock-AF_RXRPC" , "slock-AF_MISDN"    , "slock-AF_MAX"
> +  "slock-AF_RXRPC" , "slock-AF_MISDN"    , "slock-AF_PHONET"   ,
> +  "slock-AF_MAX"
>  };
>  static const char *af_family_clock_key_strings[AF_MAX+1] =3D {
>    "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
> @@ -182,7 +184,8 @@ static const char *af_family_clock_key_strings[AF=
_MAX+1] =3D {
>    "clock-AF_PPPOX" , "clock-AF_WANPIPE"  , "clock-AF_LLC"      ,
>    "clock-27"       , "clock-28"          , "clock-AF_CAN"      ,
>    "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
> -  "clock-AF_RXRPC" , "clock-AF_MISDN"    , "clock-AF_MAX"
> +  "clock-AF_RXRPC" , "clock-AF_MISDN"    , "clock-AF_PHONET"   ,
> +  "clock-AF_MAX"
>  };
>  #endif
> =20
> --=20
> 1.5.4.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

