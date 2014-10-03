From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [net-next 1/6] net: Add Geneve tunneling protocol driver
Date: Fri, 03 Oct 2014 15:44:39 +0200
Message-ID: <542EA847.4000904@6wind.com>
References: <1412237085-27215-1-git-send-email-azhou@nicira.com> <1412237085-27215-2-git-send-email-azhou@nicira.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: Andy Zhou <azhou@nicira.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:63910 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139AbaJCNom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 09:44:42 -0400
Received: by mail-wi0-f180.google.com with SMTP id em10so2166279wid.7
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 06:44:40 -0700 (PDT)
In-Reply-To: <1412237085-27215-2-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/10/2014 10:04, Andy Zhou a =C3=A9crit :
> This adds a device level support for Geneve -- Generic Network
> Virtualization Encapsulation. The protocol is documented at
> http://tools.ietf.org/html/draft-gross-geneve-01
>
> Only protocol layer Geneve support is provided by this driver.
> Openvswitch can be used for configuring, set up and tear down
> functional Geneve tunnels.
Do you plan too add the full support (ie being able to configure a
geneve netdev interface with iproute2)?

Another small comment below.
>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> ---
>   include/net/geneve.h     |   91 +++++++++++
>   include/net/ip_tunnels.h |    2 +
>   net/ipv4/Kconfig         |   14 ++
>   net/ipv4/Makefile        |    1 +
>   net/ipv4/geneve.c        |  373 +++++++++++++++++++++++++++++++++++=
+++++++++++
>   5 files changed, 481 insertions(+)
>   create mode 100644 include/net/geneve.h
>   create mode 100644 net/ipv4/geneve.c
>
> diff --git a/include/net/geneve.h b/include/net/geneve.h
> new file mode 100644
> index 0000000..ce98865
> --- /dev/null
> +++ b/include/net/geneve.h
> @@ -0,0 +1,91 @@
> +#ifndef __NET_GENEVE_H
> +#define __NET_GENEVE_H  1
> +
> +#include <net/udp_tunnel.h>
> +
> +struct geneve_sock;
> +
> +typedef void (geneve_rcv_t)(struct geneve_sock *gs, struct sk_buff *=
skb);
> +
> +struct geneve_sock {
> +	struct hlist_node	hlist;
> +	geneve_rcv_t		*rcv;
> +	void			*rcv_data;
> +	struct work_struct	del_work;
> +	struct socket		*sock;
> +	struct rcu_head		rcu;
> +	atomic_t		refcnt;
> +	struct udp_offload	udp_offloads;
> +};
> +
> +/* Geneve Header:
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-=
+
> + *  |Ver|  Opt Len  |O|C|    Rsvd.  |          Protocol Type        =
|
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-=
+
> + *  |        Virtual Network Identifier (VNI)       |    Reserved   =
|
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-=
+
> + *  |                    Variable Length Options                    =
|
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-=
+
> + *
> + * Option Header:
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-=
+
> + *  |          Option Class         |      Type     |R|R|R| Length  =
|
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-=
+
> + *  |                      Variable Option Data                     =
|
> + *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-=
+
> + */
> +
> +struct geneve_opt {
> +	__be16	opt_class;
> +	u8	type;
> +#ifdef __LITTLE_ENDIAN_BITFIELD
> +	u8	length:5;
> +	u8	r3:1;
> +	u8	r2:1;
> +	u8	r1:1;
> +#else
> +	u8	r1:1;
> +	u8	r2:1;
> +	u8	r3:1;
> +	u8	length:5;
> +#endif
> +	u8	opt_data[];
> +};
> +
> +#define GENEVE_CRIT_OPT_TYPE (1 << 7)
> +
> +struct genevehdr {
> +#ifdef __LITTLE_ENDIAN_BITFIELD
> +	u8 opt_len:6;
> +	u8 ver:2;
> +	u8 rsvd1:6;
> +	u8 critical:1;
> +	u8 oam:1;
> +#else
> +	u8 ver:2;
> +	u8 opt_len:6;
> +	u8 oam:1;
> +	u8 critical:1;
> +	u8 rsvd1:6;
> +#endif
> +	__be16 proto_type;
> +	u8 vni[3];
> +	u8 rsvd2;
> +	struct geneve_opt options[];
> +};
> +
> +#define GENEVE_VER 0
> +#define GENEVE_BASE_HLEN (sizeof(struct udphdr) + sizeof(struct gene=
vehdr))
> +
> +struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
> +				    geneve_rcv_t *rcv, void *data,
> +				    bool no_share, bool ipv6);
> +
> +void geneve_sock_release(struct geneve_sock *vs);
> +
> +int geneve_xmit_skb(struct geneve_sock *gs, struct rtable *rt,
> +		    struct sk_buff *skb, __be32 src, __be32 dst, __u8 tos,
> +		    __u8 ttl, __be16 df, __be16 src_port, __be16 dst_port,
> +		    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
> +		    bool xnet);
> +#endif
> diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
> index 7f538ba..a9ce155 100644
> --- a/include/net/ip_tunnels.h
> +++ b/include/net/ip_tunnels.h
> @@ -95,6 +95,8 @@ struct ip_tunnel {
>   #define TUNNEL_VERSION	__cpu_to_be16(0x40)
>   #define TUNNEL_NO_KEY	__cpu_to_be16(0x80)
>   #define TUNNEL_DONT_FRAGMENT    __cpu_to_be16(0x0100)
> +#define TUNNEL_OAM	__cpu_to_be16(0x0200)
> +#define TUNNEL_CRIT_OPT	__cpu_to_be16(0x0400)
>
>   struct tnl_ptk_info {
>   	__be16 flags;
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index 69fb378..15ce6b0 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -453,6 +453,20 @@ config TCP_CONG_BIC
>   	increase provides TCP friendliness.
>   	See http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/
>
> +config GENEVE
> +       tristate "Generic Network Virtualization Encapsulation (Genev=
e)"
> +       depends on INET
> +       select NET_IP_TUNNEL
> +       select NET_UDP_TUNNEL
> +       ---help---
Use tabs instead of spaces for the baove lines.
