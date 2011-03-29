From: Doug Kehn <rdkehn@yahoo.com>
Subject: Re: [PATCH] net: gre: provide multicast mappings for ipv4 and ipv6
Date: Tue, 29 Mar 2011 13:26:02 -0700 (PDT)
Message-ID: <360171.1620.qm@web39305.mail.mud.yahoo.com>
References: <1301388053-6083-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org,
	=?iso-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web39305.mail.mud.yahoo.com ([66.94.238.172]:46000 "HELO
	web39305.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751836Ab1C2U0D convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2011 16:26:03 -0400
In-Reply-To: <1301388053-6083-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--- On Tue, 3/29/11, Timo Ter=E4s <timo.teras@iki.fi> wrote:

> From: Timo Ter=E4s <timo.teras@iki.fi>
> Subject: [PATCH] net: gre: provide multicast mappings for ipv4 and ip=
v6
> To: netdev@vger.kernel.org
> Cc: "Doug Kehn" <rdkehn@yahoo.com>, "Timo Ter=E4s" <timo.teras@iki.fi=
>
> Date: Tuesday, March 29, 2011, 4:40 AM
> My commit 6d55cb91a0020ac0 (gre: fix
> hard header destination
> address checking) broke multicast.
>=20
> The reason is that ip_gre used to get ipgre_header() calls
> with
> zero destination if we have NOARP or multicast destination.
> Instead
> the actual target was decided at ipgre_tunnel_xmit() time
> based on
> per-protocol dissection.
>=20
> Instead of allowing the "abuse" of ->header() calls with
> invalid
> destination, this creates multicast mappings for ip_gre.
> This also
> fixes "ip neigh show nud noarp" to display the proper
> multicast
> mappings used by the gre device.
>=20
> Reported-by: Doug Kehn <rdkehn@yahoo.com>
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Acked-by: Doug Kehn <rdkehn@yahoo.com>

> ---
> Compile tested only. Doug tested IPv4 side with the earlier
> patch.

This patch set [still] works with IPv4.

>=20
> The IPv6 side needs a review. I'm not sure if mapped IPv4
> multicast
> addresses are intrepreted as multicast addresses by ndisc
> code or
> if we could map real IPv6 multicast addresses to IPv4
> multicast
> addresses.
>=20
>  include/net/if_inet6.h |=A0=A0=A016
> ++++++++++++++++
>  include/net/ip.h=A0 =A0 =A0=A0=A0|=A0
> =A0 8 ++++++++
>  net/ipv4/arp.c=A0 =A0 =A0
> =A0=A0=A0|=A0 =A0 3 +++
>  net/ipv6/ndisc.c=A0 =A0 =A0=A0=A0|=A0
> =A0 2 ++
>  4 files changed, 29 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/net/if_inet6.h
> b/include/net/if_inet6.h
> index 04977ee..fccc218 100644
> --- a/include/net/if_inet6.h
> +++ b/include/net/if_inet6.h
> @@ -286,5 +286,21 @@ static inline void
> ipv6_ib_mc_map(const struct in6_addr *addr,
>  =A0=A0=A0 buf[9]=A0 =3D broadcast[9];
>  =A0=A0=A0 memcpy(buf + 10, addr->s6_addr + 6,
> 10);
>  }
> +
> +static inline int ipv6_ipgre_mc_map(const struct in6_addr
> *addr,
> +=A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> =A0=A0=A0 =A0 =A0 const unsigned char
> *broadcast, char *buf)
> +{
> +=A0=A0=A0 if ((broadcast[0] | broadcast[1] |
> broadcast[2] | broadcast[3]) !=3D 0) {
> +=A0=A0=A0 =A0=A0=A0 memcpy(buf,
> broadcast, 4);
> +=A0=A0=A0 } else {
> +=A0=A0=A0 =A0=A0=A0 /* v4mapped? */
> +=A0=A0=A0 =A0=A0=A0 if
> ((addr->s6_addr32[0] | addr->s6_addr32[1] |
> +=A0=A0=A0 =A0=A0=A0 =A0
> =A0=A0=A0(addr->s6_addr32[2] ^
> htonl(0x0000ffff))) !=3D 0)
> +=A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> return -EINVAL;
> +=A0=A0=A0 =A0=A0=A0 memcpy(buf,
> &addr->s6_addr32[3], 4);
> +=A0=A0=A0 }
> +=A0=A0=A0 return 0;
> +}
> +
>  #endif
>  #endif
> diff --git a/include/net/ip.h b/include/net/ip.h
> index a4f6311..7c41658 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -339,6 +339,14 @@ static inline void ip_ib_mc_map(__be32
> naddr, const unsigned char *broadcast, ch
>  =A0=A0=A0 buf[16] =3D addr & 0x0f;
>  }
> =20
> +static inline void ip_ipgre_mc_map(__be32 naddr, const
> unsigned char *broadcast, char *buf)
> +{
> +=A0=A0=A0 if ((broadcast[0] | broadcast[1] |
> broadcast[2] | broadcast[3]) !=3D 0)
> +=A0=A0=A0 =A0=A0=A0 memcpy(buf,
> broadcast, 4);
> +=A0=A0=A0 else
> +=A0=A0=A0 =A0=A0=A0 memcpy(buf,
> &naddr, sizeof(naddr));
> +}
> +
>  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>  #include <linux/ipv6.h>
>  #endif
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 090d273..1b74d3b 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -215,6 +215,9 @@ int arp_mc_map(__be32 addr, u8 *haddr,
> struct net_device *dev, int dir)
>  =A0=A0=A0 case ARPHRD_INFINIBAND:
>  =A0=A0=A0 =A0=A0=A0 ip_ib_mc_map(addr,
> dev->broadcast, haddr);
>  =A0=A0=A0 =A0=A0=A0 return 0;
> +=A0=A0=A0 case ARPHRD_IPGRE:
> +=A0=A0=A0 =A0=A0=A0
> ip_ipgre_mc_map(addr, dev->broadcast, haddr);
> +=A0=A0=A0 =A0=A0=A0 return 0;
>  =A0=A0=A0 default:
>  =A0=A0=A0 =A0=A0=A0 if (dir) {
>  =A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> memcpy(haddr, dev->broadcast, dev->addr_len);
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 0e49c9d..92f952d 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -341,6 +341,8 @@ int ndisc_mc_map(struct in6_addr *addr,
> char *buf, struct net_device *dev, int d
>  =A0=A0=A0 case ARPHRD_INFINIBAND:
>  =A0=A0=A0 =A0=A0=A0 ipv6_ib_mc_map(addr,
> dev->broadcast, buf);
>  =A0=A0=A0 =A0=A0=A0 return 0;
> +=A0=A0=A0 case ARPHRD_IPGRE:
> +=A0=A0=A0 =A0=A0=A0 return
> ipv6_ipgre_mc_map(addr, dev->broadcast, buf);
>  =A0=A0=A0 default:
>  =A0=A0=A0 =A0=A0=A0 if (dir) {
>  =A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> memcpy(buf, dev->broadcast, dev->addr_len);
> --=20
> 1.7.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe
> netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at=A0 http://vger.kernel.org/majordomo-info.html
>=20
