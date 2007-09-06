From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 1/1] NFS: change the ip_map cache code to handle IPv6
 addresses
Date: Thu, 06 Sep 2007 12:16:29 -0400
Message-ID: <46E027DD.4030505@hp.com>
References: <46CD890C.2040502@ext.bull.net> <46CDA874.5020609@hp.com> <46DFE4BC.2060406@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:53760 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043AbXIFQRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 12:17:04 -0400
In-Reply-To: <46DFE4BC.2060406@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Aurelien,

More comments.

Aur=E9lien Charbon wrote:
> This is a small part of missing pieces of IPv6 support for the server=
=2E
> It deals with the ip_map caching code part.

>  	/* Insert client into hashtable. */
> -	for (i =3D 0; i < ncp->cl_naddr; i++)
> -		auth_unix_add_addr(ncp->cl_addrlist[i], dom);
> -
> +	for (i =3D 0; i < ncp->cl_naddr; i++) {
> +		/* Mapping address */
> +		ipv6_addr_v4map(ncp->cl_addrlist[i], addr6);

ipv6_addr_set(&addr6, 0, 0, htonl(0x0000FFFF), ncp->cl_addrlist[i]);
See below.

> @@ -236,7 +237,11 @@ static ssize_t write_getfs(struct file *
>  	res =3D (struct knfsd_fh*)buf;
> =20
>  	exp_readlock();
> -	if (!(clp =3D auth_unix_lookup(sin->sin_addr)))
> +
> +	/* IPv6 address mapping */
> +	ipv6_addr_v4map(sin->sin_addr, in6);

ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), sin->sin_addr);
See below.

> @@ -271,7 +277,11 @@ static ssize_t write_getfd(struct file *
>  	res =3D buf;
>  	sin =3D (struct sockaddr_in *)&data->gd_addr;
>  	exp_readlock();
> -	if (!(clp =3D auth_unix_lookup(sin->sin_addr)))
> +
> +	/* IPv6 address mapping */
> +	ipv6_addr_v4map(sin->sin_addr, in6);

ipv6_addr_set(&in6, 0, 0, htonl(0x0000FFFF), sin->sin_addr);
See below.

> +#define IS_ADDR_MAPPED(a) \
> +	(((uint32_t *) (a))[0] =3D=3D 0			\
> +	&& ((uint32_t *) (a))[1] =3D=3D 0			\
> +	&& (((uint32_t *) (a))[2] =3D=3D 0			\
> +	|| ((uint32_t *) (a))[2] =3D=3D htonl(0xffff)))

Can go away, right?

> +static inline void ipv6_addr_v4map(const struct in_addr a1, struct i=
n6_addr a2)
> +{
> +	a2.s6_addr32[0] =3D 0;
> +	a2.s6_addr32[1] =3D 0;
> +	a2.s6_addr32[2] =3D htonl(0xffff);
> +	a2.s6_addr32[3] =3D (uint32_t)a1.s_addr;
> +}

This can go away.  Looking at other code that does this - TCP, UDP,=20
DCCP, they just call ipv6_addr_set() directly.

> +static inline int hash_ip6(struct in6_addr ip)
> +{
> +	return (hash_ip(ip.s6_addr32[0]) ^
> +		hash_ip(ip.s6_addr32[1]) ^
> +		hash_ip(ip.s6_addr32[2]) ^
> +		hash_ip(ip.s6_addr32[3]));
> +}

Should probably use a pointer to the address (*ip), probably doesn't=20
matter that much since it's an inline.

> @@ -151,20 +159,22 @@ static void ip_map_request(struct cache_
>  {
>  	char text_addr[20];

This needs to be at least 40 since you're passing that to snprintf() be=
low.

> +	if (ipv6_addr_v4mapped(&(im->m_addr))) {
> +		snprintf(text_addr, 20, NIPQUAD_FMT,
> +				ntohl(im->m_addr.s6_addr32[3]) >> 24 & 0xff,
> +				ntohl(im->m_addr.s6_addr32[3]) >> 16 & 0xff,
> +				ntohl(im->m_addr.s6_addr32[3]) >>  8 & 0xff,
> +				ntohl(im->m_addr.s6_addr32[3]) >>  0 & 0xff);
> +	} else {
> +		snprintf(text_addr, 40, NIP6_FMT, NIP6(im->m_addr));
> +	}

Here -------------------------------^^

> -static struct ip_map *ip_map_lookup(char *class, struct in_addr addr=
)
> +static struct ip_map *ip_map_lookup(char *class, struct in6_addr add=
r)

Maybe you should pass a pointer to the address (*addr) to avoid passing=
=20
it on the stack.

> -int auth_unix_add_addr(struct in_addr addr, struct auth_domain *dom)
> +int auth_unix_add_addr(struct in6_addr addr, struct auth_domain *dom=
)

Here too.

> -struct auth_domain *auth_unix_lookup(struct in_addr addr)
> +struct auth_domain *auth_unix_lookup(struct in6_addr addr)

Here too.

> @@ -641,7 +669,19 @@ static int unix_gid_find(uid_t uid, stru
>  int
>  svcauth_unix_set_client(struct svc_rqst *rqstp)
>  {
> -	struct sockaddr_in *sin =3D svc_addr_in(rqstp);
> +	struct sockaddr_in *sin;
> +	struct sockaddr_in6 *sin6;

Will need change this to something like:

 > +	struct sockaddr_in6 *sin6, sin6_storage;

See below.

> +
> +	switch (rqstp->rq_addr.ss_family) {
> +	default:
> +		BUG();
> +	case AF_INET:
> +		sin =3D svc_addr_in(rqstp);
> +		ipv6_addr_v4map(sin->sin_addr, sin6->sin6_addr);

sin6 here is uninitialized, and in order to create a mapped address=20
you'll need to allocate storage space on the stack to hold it.  New cod=
e=20
would be:

		sin6 =3D &sin6_storage;
		ipv6_addr_set(&sin6->sin6_addr, 0, 0, htonl(0x0000FFFF),
				sin->sin_addr);

gcc really should have complained about that...

Maybe in the future rq_addr can just be in the correct form, but there'=
s=20
a lot of other code that would need to change for that.

-Brian
