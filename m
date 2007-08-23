From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 1/1] NFS: change the ip_map cache code to handle IPv6
 addresses
Date: Thu, 23 Aug 2007 11:32:04 -0400
Message-ID: <46CDA874.5020609@hp.com>
References: <46CD890C.2040502@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:36016 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754871AbXHWPcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 11:32:36 -0400
In-Reply-To: <46CD890C.2040502@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Aurelien,

Aur=E9lien Charbon wrote:
> According to Neil's comments, I have tried to correct the mistakes of=
 my=20
> first sending

I have some more comments.

> @@ -1559,6 +1560,7 @@ exp_addclient(struct nfsctl_client *ncp)
> {
>     struct auth_domain    *dom;
>     int            i, err;
> +    struct in6_addr addr6;

Indentation looks wrong.

> diff -p -u -r -N linux-2.6.23-rc3/fs/nfsd/nfsctl.c=20
> linux-2.6.23-rc3-IPv6-ipmap-cache/fs/nfsd/nfsctl.c
> --- linux-2.6.23-rc3/fs/nfsd/nfsctl.c    2007-08-23 13:18:16.00000000=
0=20
> +0200
> +++ linux-2.6.23-rc3-IPv6-ipmap-cache/fs/nfsd/nfsctl.c    2007-08-23=20
> 13:25:28.000000000 +0200
> @@ -222,7 +222,7 @@ static ssize_t write_getfs(struct file *
>     struct auth_domain *clp;
>     int err =3D 0;
>     struct knfsd_fh *res;
> -
> +    struct in6_addr in6;

Indentation.

>     if (size < sizeof(*data))
>         return -EINVAL;
>     data =3D (struct nfsctl_fsparm*)buf;
> @@ -236,7 +236,14 @@ static ssize_t write_getfs(struct file *
>     res =3D (struct knfsd_fh*)buf;
>=20
>     exp_readlock();
> -    if (!(clp =3D auth_unix_lookup(sin->sin_addr)))
> +
> +    /* IPv6 address mapping */
> +    in6.s6_addr32[0] =3D 0;
> +    in6.s6_addr32[1] =3D 0;
> +    in6.s6_addr32[2] =3D htonl(0xffff);
> +    in6.s6_addr32[3] =3D (uint32_t)sin->sin_addr.s_addr;

Why didn't you use your new ipv6_addr_map() inline here?

> @@ -253,6 +260,7 @@ static ssize_t write_getfd(struct file *
> {
>     struct nfsctl_fdparm *data;
>     struct sockaddr_in *sin;
> +    struct in6_addr in6;

Indentation.

> @@ -271,7 +279,14 @@ static ssize_t write_getfd(struct file *
>     res =3D buf;
>     sin =3D (struct sockaddr_in *)&data->gd_addr;
>     exp_readlock();
> -    if (!(clp =3D auth_unix_lookup(sin->sin_addr)))
> +
> +    /* IPv6 address mapping */
> +    in6.s6_addr32[0] =3D 0;
> +    in6.s6_addr32[1] =3D 0;
> +    in6.s6_addr32[2] =3D htonl(0xffff);
> +    in6.s6_addr32[3] =3D (uint32_t)sin->sin_addr.s_addr;

Why didn't you use your new ipv6_addr_map() inline here too?

> diff -p -u -r -N linux-2.6.23-rc3/include/net/ipv6.h=20
> linux-2.6.23-rc3-IPv6-ipmap-cache/include/net/ipv6.h
> --- linux-2.6.23-rc3/include/net/ipv6.h    2007-08-23 13:18:23.000000=
000=20
> +0200
> +++ linux-2.6.23-rc3-IPv6-ipmap-cache/include/net/ipv6.h    2007-08-2=
3=20
> 13:25:28.000000000 +0200
> @@ -21,6 +21,7 @@
> #include <net/ndisc.h>
> #include <net/flow.h>
> #include <net/snmp.h>
> +#include <linux/in.h>
>=20
> #define SIN6_LEN_RFC2133    24
>=20
> @@ -167,6 +168,12 @@ DECLARE_SNMP_STAT(struct udp_mib, udplit
>     if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6,=20
> field);         \
>     else        SNMP_INC_STATS_USER(udp_stats_in6, field);    } while=
(0)
>=20
> +#define IS_ADDR_MAPPED(a) \
> +    (((uint32_t *) (a))[0] =3D=3D 0            \
> +    && ((uint32_t *) (a))[1] =3D=3D 0            \
> +    && (((uint32_t *) (a))[2] =3D=3D 0            \
> +    || ((uint32_t *) (a))[2] =3D=3D htonl(0xffff)))

I need to update a patch of mine that added a v4-mapped inline, let me=20
send that out.  In the kernel you should use u32 too, is that why you=20
needed to include linux/net.h?

> +/* Maps a IPv4 address into a wright IPv6 address */
> +static inline int ipv6_addr_map(const struct in_addr a1, struct=20
> in6_addr a2)
> +{
> +    a2.s6_addr32[0] =3D 0;
> +    a2.s6_addr32[1] =3D 0;
> +    a2.s6_addr32[2] =3D htonl(0xffff);
> +    a2.s6_addr32[3] =3D (uint32_t)a1.s_addr;
> +    return 0;
> +}

This can be void, noone ever checks the return status.  Maybe change th=
e=20
name to ipv6_addr_v4map() too?

> @@ -84,7 +85,7 @@ static void svcauth_unix_domain_release(
> struct ip_map {
>     struct cache_head    h;
>     char            m_class[8]; /* e.g. "nfsd" */
> -    struct in_addr        m_addr;
> +    struct in6_addr        m_addr;

Indentation.

> static void ip_map_init(struct cache_head *cnew, struct cache_head *c=
item)
> {
> @@ -125,7 +133,7 @@ static void ip_map_init(struct cache_hea
>     struct ip_map *item =3D container_of(citem, struct ip_map, h);
>=20
>     strcpy(new->m_class, item->m_class);
> -    new->m_addr.s_addr =3D item->m_addr.s_addr;
> +    memcpy(&(new->m_addr), &(item->m_addr), sizeof(struct in6_addr))=
;

Use ipv6_addr_copy().

> @@ -151,20 +159,22 @@ static void ip_map_request(struct cache_
> {
>     char text_addr[20];
>     struct ip_map *im =3D container_of(h, struct ip_map, h);
> -    __be32 addr =3D im->m_addr.s_addr;
> -
> -    snprintf(text_addr, 20, "%u.%u.%u.%u",
> -         ntohl(addr) >> 24 & 0xff,
> -         ntohl(addr) >> 16 & 0xff,
> -         ntohl(addr) >>  8 & 0xff,
> -         ntohl(addr) >>  0 & 0xff);
>=20
> +    if (IS_ADDR_MAPPED(im->m_addr.s6_addr32)) {
> +        snprintf(text_addr, 20, NIPQUAD_FMT,
> +                ntohl(im->m_addr.s6_addr32[3]) >> 24 & 0xff,
> +                ntohl(im->m_addr.s6_addr32[3]) >> 16 & 0xff,
> +                ntohl(im->m_addr.s6_addr32[3]) >>  8 & 0xff,
> +                ntohl(im->m_addr.s6_addr32[3]) >>  0 & 0xff);
> +    } else {
> +        snprintf(text_addr, 20, NIP6_FMT, NIP6(im->m_addr));
> +    }

You'll need more than 20 bytes to print an IPv6 address, I'd make this=20
at least 44 to account for some fluff.  Surprised you didn't crash=20
during testing.

> static int ip_map_parse(struct cache_detail *cd,
> @@ -175,10 +185,10 @@ static int ip_map_parse(struct cache_det
>      * for scratch: */
>     char *buf =3D mesg;
>     int len;
> -    int b1,b2,b3,b4;
> +    int b1, b2, b3, b4, b5, b6, b7, b8;
>     char c;
>     char class[8];
> -    struct in_addr addr;
> +    struct in6_addr addr;
>     int err;

You might as well fix the indentation while you're here.

> @@ -238,7 +262,7 @@ static int ip_map_show(struct seq_file *
>                struct cache_head *h)
> {
>     struct ip_map *im;
> -    struct in_addr addr;
> +    struct in6_addr addr;

Indentation.

>     if (h =3D=3D NULL) {
> @@ -247,20 +271,33 @@ static int ip_map_show(struct seq_file *
>     }
>     im =3D container_of(h, struct ip_map, h);
>     /* class addr domain */
> -    addr =3D im->m_addr;
> +    memcpy(&addr, &im->m_addr, sizeof(struct in6_addr));

ipv6_addr_copy()

> -    seq_printf(m, "%s %d.%d.%d.%d %s\n",
> -           im->m_class,
> -           ntohl(addr.s_addr) >> 24 & 0xff,
> -           ntohl(addr.s_addr) >> 16 & 0xff,
> -           ntohl(addr.s_addr) >>  8 & 0xff,
> -           ntohl(addr.s_addr) >>  0 & 0xff,
> -           dom
> -           );
> +    if (IS_ADDR_MAPPED(addr.s6_addr32)) {
> +        seq_printf(m, "%s" NIPQUAD_FMT "%s\n",
> +            im->m_class,
> +            ntohl(addr.s6_addr32[3]) >> 24 & 0xff,
> +            ntohl(addr.s6_addr32[3]) >> 16 & 0xff,
> +            ntohl(addr.s6_addr32[3]) >>  8 & 0xff,
> +            ntohl(addr.s6_addr32[3]) >>  0 & 0xff,
> +            dom);
> +    } else {
> +        seq_printf(m, "%s" NIP6_FMT "%s\n",
> +            im->m_class,
> +            ntohl(addr.s6_addr16[7]),
> +            ntohl(addr.s6_addr16[6]),
> +            ntohl(addr.s6_addr16[5]),
> +            ntohl(addr.s6_addr16[4]),
> +            ntohl(addr.s6_addr16[3]),
> +            ntohl(addr.s6_addr16[2]),
> +            ntohl(addr.s6_addr16[1]),
> +            ntohl(addr.s6_addr16[0]),
> +            dom);

These should be ntohs(), it's only a 16-bit quantity.  Also, don't you=20
want to start printing this at addr[0], not addr[7]?

> -static struct ip_map *ip_map_lookup(char *class, struct in_addr addr=
)
> +static struct ip_map *ip_map_lookup(char *class, struct in6_addr add=
r)
> {
>     struct ip_map ip;
>     struct cache_head *ch;
>=20
>     strcpy(ip.m_class, class);
> -    ip.m_addr =3D addr;
> +    memcpy(&ip.m_addr, &addr, sizeof(struct in6_addr));

ipv6_addr_copy()

-Brian
