From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6 support for NFS server
Date: Thu, 17 Jan 2008 12:17:58 -0500
Message-ID: <478F8DC6.9030105@hp.com>
References: <475D86C1.6070400@ext.bull.net> <475EBDB4.5020108@hp.com> <475ED028.2010109@ext.bull.net> <20080115223221.GE5028@fieldses.org> <20080115231636.GB19658@fieldses.org> <478F8AA3.9060707@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	netdev ML <netdev@vger.kernel.org>,
	Mailing list NFSv4 <nfsv4@linux-nfs.org>
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:21542 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbYAQRSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 12:18:03 -0500
In-Reply-To: <478F8AA3.9060707@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aur=E9lien Charbon wrote:
> Thanks for your comments.
> Here is the patch with some cleanups.

Hi Aurelien,

Just two nits.

> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -400,6 +400,15 @@ static inline int ipv6_addr_v4mapped(const struc=
t in6_addr *a)
>  		 a->s6_addr32[2] =3D=3D htonl(0x0000ffff));
>  }
> =20
> +static inline void ipv6_addr_set_v4mapped(const __be32 addr,
> +					  struct in6_addr *v4mapped)
> +{
> +	ipv6_addr_set(v4mapped,
> +			0, 0,
> +			htonl(0x0000FFFF),
> +			addr);
> +}

I think Bruce wanted you to put as much on one line here as possible.

> @@ -641,9 +668,24 @@ static int unix_gid_find(uid_t uid, struct group=
_info **gip,
>  int
>  svcauth_unix_set_client(struct svc_rqst *rqstp)
>  {
> -	struct sockaddr_in *sin =3D svc_addr_in(rqstp);
> +	struct sockaddr_in *sin;
> +	struct sockaddr_in6 *sin6, sin6_storage;
>  	struct ip_map *ipm;
> =20
> +	switch (rqstp->rq_addr.ss_family) {
> +	case AF_INET:
> +		sin =3D svc_addr_in(rqstp);
> +		sin6 =3D &sin6_storage;
> +		ipv6_addr_set(&sin6->sin6_addr, 0, 0,
> +				htonl(0x0000FFFF), sin->sin_addr.s_addr);
> +		break;

ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &sin6->sin6_addr);

-Brian
