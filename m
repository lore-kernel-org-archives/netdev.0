From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 1/2] NFS: change the ip_map cache code to handle IPv6
	addresses
Date: Wed, 24 Oct 2007 15:22:23 -0400
Message-ID: <471F9B6F.60404@hp.com>
References: <471C892F.3000206@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev ML <netdev@vger.kernel.org>,
	Mailing list NFSv4 <nfsv4@linux-nfs.org>
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <471C892F.3000206@ext.bull.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-Id: netdev.vger.kernel.org

Hi Aurelien,

I think you're almost there, at least with my comments :)

> linux-2.6.23-ipmap/include/net/ipv6.h
> --- linux-2.6.23-haley/include/net/ipv6.h    2007-10-22 
> 09:42:58.000000000 +0200
> +++ linux-2.6.23-ipmap/include/net/ipv6.h    2007-10-22 
> 10:10:59.000000000 +0200
> @@ -21,6 +21,7 @@
> #include <net/ndisc.h>
> #include <net/flow.h>
> #include <net/snmp.h>
> +#include <linux/in.h>
> 
> #define SIN6_LEN_RFC2133    24
> 
> @@ -167,6 +168,12 @@ DECLARE_SNMP_STAT(struct udp_mib, udplit
>     if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, 
> field);         \
>     else        SNMP_INC_STATS_USER(udp_stats_in6, field);    } while(0)
> 
> +#define IS_ADDR_MAPPED(a) \
> +    (((uint32_t *) (a))[0] == 0            \
> +    && ((uint32_t *) (a))[1] == 0            \
> +    && (((uint32_t *) (a))[2] == 0            \
> +    || ((uint32_t *) (a))[2] == htonl(0xffff)))
> +
> struct ip6_ra_chain
> {
>     struct ip6_ra_chain    *next;
> @@ -380,7 +387,7 @@ static inline int ipv6_addr_any(const st
> static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
> {
>     return ((a->s6_addr32[0] | a->s6_addr32[1]) == 0 &&
> -         a->s6_addr32[2] == htonl(0x0000ffff));
> +        a->s6_addr32[2] == htonl(0x0000ffff));
> }

You don't need to touch ipv6.h at all, IS_ADDR_MAPPED is unused and the 
other is removing a space.

> static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
> {
> @@ -125,7 +133,7 @@ static void ip_map_init(struct cache_hea
>     struct ip_map *item = container_of(citem, struct ip_map, h);
> 
>     strcpy(new->m_class, item->m_class);
> -    new->m_addr.s_addr = item->m_addr.s_addr;
> +    ipv6_addr_copy(&(new->m_addr), &(item->m_addr));

Extra () here.

> @@ -651,7 +694,7 @@ svcauth_unix_set_client(struct svc_rqst
>     ipm = ip_map_cached_get(rqstp);
>     if (ipm == NULL)
>         ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
> -                    sin->sin_addr);
> +                    &(sin6->sin6_addr));

Extra () here.

-Brian
