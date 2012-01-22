From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Mon, 23 Jan 2012 00:20:15 +0100
Message-ID: <201201230020.20857.hans@schillstrom.com>
References: <1326448338-13416-1-git-send-email-hans.schillstrom@ericsson.com> <1326448338-13416-3-git-send-email-hans.schillstrom@ericsson.com> <20120122214434.GA20543@1984>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2203844.xseu646aEq";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, kaber@trash.net,
	jengelh@medozas.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120122214434.GA20543@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2203844.xseu646aEq
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hello Pablo

On Sunday, January 22, 2012 22:44:34 Pablo Neira Ayuso wrote:
> Hi Hans,
>=20
> This starts looking good :-). Some comments on your patch:

Thanks

>=20
> On Fri, Jan 13, 2012 at 10:52:17AM +0100, Hans Schillstrom wrote:
> >        Fragmentation:
> >         - If a packet is fragmented NONE of the Fragments will include
> >           ports in the hash calculation.
> >           When fragments arrives on different machines HMARK will produ=
ce
> >           same fwmark for all frags inpendent of machine so they can be=
 routed
> >           to the same destination.
>=20

The text should clarify that this is valid for the fragments not the "flow"

> I've got one scenario that may break with this assumption:
>=20
> 1) your traffic follows one path over router A and B to reach your
>    firewall F which requires no fragmentation at all.
> 2) path to router B becomes broken while there are established flows
>    with firewall F.
> 3) router A decides to forward packets to router C, which fragment
>    packets because it is using smaller MTU than router A.
> 4) packets arrive to firewall F, then hashing is calculated based on
>    addresses, not ports, and you load-sharing becomes inconsistent.
>=20
> This can rarely happen, but it does, it would break.
>=20
> To fix this, I think that HMARK requires that you have to specify the
> hashing strategy. If you want to support fragments, use only
> addresses. If you're sure you will not get fragments, use layer 3 and
> layer 4 information.

I know but if you use conntrack, fragments will not be seen by HMARK
(except for IPv6 until Patric has fix the IPv6 defrag)

We handle this by not having stateful FW:s when connected to external route=
rs.
=46ragments will take an extra turn to a container with conntrack and there
HMARK works as on the unfragmented packets in the flow.

>=20
> >         - If nf_defrag_ipv{4,6} is loaded the packets will be defragmen=
ted
> >           before reaching HMARK, i.e. in that case ports (if any) will =
be used.
> >           (ICMP Time exceeded will be sent if fragments are lost)
> >=20
> >        Parameters: For all masks default is all "1:s", to disable a fie=
ld
> >                    use mask 0. For IPv6 it's just the last 32 bits that
> >                    is included in the hash.
> >=20
> >        --hmark-smask length (0-32 or 0-128)
> >               The value to AND the source address with (saddr & value).
> >=20
> >        --hmark-dmask length (0-32 or 0-128)
> >               The value to AND the dest. address with (daddr & value).
> >=20
> >        --hmark-sp-mask value
> >               A 16 bit value to AND the src port with (sport & value).
> >=20
> >        --hmark-dp-mask value
> >               A 16 bit value to AND the dest port with (dport & value).
> >=20
> >        --hmark-sp-set value
> >               A 16 bit value to OR the src port with (sport | value).
> >=20
> >        --hmark-dp-set value
> >               A 16 bit value to OR the dest port with (dport | value).
> >=20
> >        --hmark-spi-mask value
> >               Value to AND the spi field with (spi & value) valid for p=
roto esp or ah.
> >=20
> >        --hmark-spi-set value
> >               Value to OR the spi field with (spi | value) valid for pr=
oto esp or ah.
> >=20
> >        --hmark-proto-mask value
> >               A 16 bit value to AND the L4 proto field with (proto & va=
lue).
> >=20
> >        --hmark-rnd value
> >               A 32 bit intitial value for hash calc, default is 0xc175a=
3b8.
> >=20
> >        --hmark-dnat (only IPv4)
> >               Replace src addr/port with original dst addr/port before =
calc, hash
> >=20
> >        --hmark-snat (only IPv4)
> >               Replace dst addr/port with original src addr/port before =
calc, hash
> >=20
> >        Final processing of the mark in order of execution.
> >=20
> >        --hmark-mod value (must be > 0)
> >               The easiest way to describe this is:  hash =3D hash mod <=
value>
> >=20
> >        --hmark-offs alue (must be > 0)
> >               The easiest way to describe this is:  hash =3D hash + <va=
lue>
> >=20
> >        Examples:
> >=20
> >        Default rule handles all TCP, UDP, SCTP, ESP & AH
> >=20
> > Rev 7
> >       IPv6 descending into icmp error hdr didn't work as expected
> >       with ipv6_find_hdr() Now it works as expected.
> >=20
> > Rev 6
> >       Compile options with or without conntrack fixed.
> >       __ipv6_find_hdr() replaced by ipv6_find_hdr()
> >=20
> > Rev 5
> >       IPv6 rewritten uses __ipv6_find_hdr() (P. Mc Hardy)
> >       Full mask and address used for IPv6 smask and dmask (J.Engelhart)
> >       Changes due to comments by Pablo Neira Ayuso  and Eric Dumazet
> >       i.e uses of skb_header_pointer() and Null check of info->hmod
> >       Man page changes
> >=20
> > Rev 4
> >       different targets for IPv4 and IPv6
> >       Changes based on review by Pablo.
> >=20
> > Rev 3
> >       Support added to SCTP for IPv6
> > Rev 2
> >       IPv6 header scan changed to follow RFC 2640
> >       IPv4 icmp echo fragmented does now use proto as ipv6
> >       IPv6 pskb_may_pull() check is done in every time in header loop.
> >       IPv4 nat support added.
> >       default added in IPv6 loop and null check of hp
> >=20
> > Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> > ---
> >  include/linux/netfilter/xt_hmark.h |   62 +++++++
> >  net/netfilter/Kconfig              |   17 ++
> >  net/netfilter/Makefile             |    1 +
> >  net/netfilter/xt_hmark.c           |  337 ++++++++++++++++++++++++++++=
++++++++
> >  4 files changed, 417 insertions(+), 0 deletions(-)
> >  create mode 100644 include/linux/netfilter/xt_hmark.h
> >  create mode 100644 net/netfilter/xt_hmark.c
> >=20
> > diff --git a/include/linux/netfilter/xt_hmark.h b/include/linux/netfilt=
er/xt_hmark.h
> > new file mode 100644
> > index 0000000..366ecce
> > --- /dev/null
> > +++ b/include/linux/netfilter/xt_hmark.h
> > @@ -0,0 +1,62 @@
> > +#ifndef XT_HMARK_H_
> > +#define XT_HMARK_H_
> > +
> > +#include <linux/types.h>
> > +
> > +/*
> > + * Flags must not start at 0, since it's used as none.
> > + */
> > +enum {
> > +	XT_HMARK_SADR_AND =3D 1,	/* SNAT & DNAT are used by the kernel module=
 */
> > +	XT_HMARK_DADR_AND,
> > +	XT_HMARK_SPI_AND,
> > +	XT_HMARK_SPI_OR,
> > +	XT_HMARK_SPORT_AND,
> > +	XT_HMARK_DPORT_AND,
> > +	XT_HMARK_SPORT_OR,
> > +	XT_HMARK_DPORT_OR,
> > +	XT_HMARK_PROTO_AND,
> > +	XT_HMARK_RND,
> > +	XT_HMARK_MODULUS,
> > +	XT_HMARK_OFFSET,
> > +	XT_HMARK_USE_SNAT,
> > +	XT_HMARK_USE_DNAT,
> > +	XT_F_HMARK_USE_SNAT =3D 1 << XT_HMARK_USE_SNAT,
> > +	XT_F_HMARK_USE_DNAT =3D 1 << XT_HMARK_USE_DNAT,
> > +	XT_F_HMARK_SADR_AND =3D 1 << XT_HMARK_SADR_AND,
> > +	XT_F_HMARK_DADR_AND =3D 1 << XT_HMARK_DADR_AND,
> > +	XT_F_HMARK_SPI_AND =3D 1 << XT_HMARK_SPI_AND,
> > +	XT_F_HMARK_SPI_OR =3D 1 << XT_HMARK_SPI_OR,
> > +	XT_F_HMARK_SPORT_AND =3D 1 << XT_HMARK_SPORT_AND,
> > +	XT_F_HMARK_DPORT_AND =3D 1 << XT_HMARK_DPORT_AND,
> > +	XT_F_HMARK_SPORT_OR =3D 1 << XT_HMARK_SPORT_OR,
> > +	XT_F_HMARK_DPORT_OR =3D 1 << XT_HMARK_DPORT_OR,
> > +	XT_F_HMARK_PROTO_AND =3D 1 << XT_HMARK_PROTO_AND,
> > +	XT_F_HMARK_RND =3D 1 << XT_HMARK_RND,
> > +	XT_F_HMARK_MODULUS =3D 1 << XT_HMARK_MODULUS,
> > +	XT_F_HMARK_OFFSET =3D 1 << XT_HMARK_OFFSET,
> > +};
> > +
> > +union hports {
> > +	struct {
> > +		__u16	src;
> > +		__u16	dst;
> > +	} p16;
> > +	__u32	v32;
> > +};
> > +
> > +struct xt_hmark_info {
> > +	union nf_inet_addr	smask;		/* Source address mask */
> > +	union nf_inet_addr	dmask;		/* Dest address mask */
> > +	union hports		pmask;
> > +	union hports		pset;
> > +	__u32			spimask;
> > +	__u32			spiset;
> > +	__u16			flags;		/* Print out only */
> > +	__u16			prmask;		/* L4 Proto mask */
> > +	__u32			hashrnd;
> > +	__u32			hmod;		/* Modulus */
> > +	__u32			hoffs;		/* Offset */
> > +};
> > +
> > +#endif /* XT_HMARK_H_ */
> > diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> > index f8ac4ef..dfe84e1 100644
> > --- a/net/netfilter/Kconfig
> > +++ b/net/netfilter/Kconfig
> > @@ -488,6 +488,23 @@ config NETFILTER_XT_TARGET_HL
> >  	since you can easily create immortal packets that loop
> >  	forever on the network.
> > =20
> > +config NETFILTER_XT_TARGET_HMARK
> > +	tristate '"HMARK" target support'
> > +	depends on NETFILTER_ADVANCED
> > +	---help---
> > +	This option adds the "HMARK" target.
> > +
> > +	The target allows you to create rules in the "raw" and "mangle" tables
> > +	which alter the netfilter mark (nfmark) field within a given range.
> > +	First a 32 bit hash value is generated then modulus by <limit> and
> > +	finally an offset is added before it's written to nfmark.
> > +
> > +	Prior to routing, the nfmark can influence the routing method (see
> > +	"Use netfilter MARK value as routing key") and can also be used by
> > +	other subsystems to change their behavior.
> > +
> > +	The mark match can also be used to match nfmark produced by this modu=
le.
> > +
> >  config NETFILTER_XT_TARGET_IDLETIMER
> >  	tristate  "IDLETIMER target support"
> >  	depends on NETFILTER_ADVANCED
> > diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
> > index 40f4c3d..21bc5e8 100644
> > --- a/net/netfilter/Makefile
> > +++ b/net/netfilter/Makefile
> > @@ -57,6 +57,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) +=3D xt=
_CONNSECMARK.o
> >  obj-$(CONFIG_NETFILTER_XT_TARGET_CT) +=3D xt_CT.o
> >  obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) +=3D xt_DSCP.o
> >  obj-$(CONFIG_NETFILTER_XT_TARGET_HL) +=3D xt_HL.o
> > +obj-$(CONFIG_NETFILTER_XT_TARGET_HMARK) +=3D xt_hmark.o
> >  obj-$(CONFIG_NETFILTER_XT_TARGET_LED) +=3D xt_LED.o
> >  obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) +=3D xt_NFLOG.o
> >  obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) +=3D xt_NFQUEUE.o
> > diff --git a/net/netfilter/xt_hmark.c b/net/netfilter/xt_hmark.c
> > new file mode 100644
> > index 0000000..fd73d15
> > --- /dev/null
> > +++ b/net/netfilter/xt_hmark.c
> > @@ -0,0 +1,337 @@
> > +/*
> > + * xt_hmark - Netfilter module to set mark as hash value
> > + *
> > + * (C) 2011 Hans Schillstrom <hans.schillstrom@ericsson.com>
> > + *
> > + *Description:
> > + *	This module calculates a hash value that can be modified by modulus
> > + *	and an offset, i.e. it is possible to produce a skb->mark within a =
range.
> > + *	The hash value is based on a direction independent five tuple:
> > + *	src & dst addr src & dst ports and protocol.
> > + *	However src & dst port can be masked and are not used for fragmented
> > + *	packets, ESP and AH don't have ports so SPI will be used instead.
> > + *	AH will not use ports even if it might be possible.
> > + *	Tunnels - only the outer saddr and daddr will beused,
> > + *
> > + *	For ICMP error messages the hash mark values will be calculated on
> > + *	the source packet i.e. the packet caused the error (If sufficient
> > + *	amount of data exists).
> > + *
> > + *Note:	None of the fragments will include ports/spi in the calculatio=
n of
> > + *	the hash value. (i.e. all frags must the same hash value.)
> > + *
> > + *	This program is free software; you can redistribute it and/or modify
> > + *	it under the terms of the GNU General Public License version 2 as
> > + *	published by the Free Software Foundation.
> > + */
> > +
> > +#include <linux/module.h>
> > +#include <linux/skbuff.h>
> > +#include <net/ip.h>
> > +#include <linux/icmp.h>
> > +
> > +#include <linux/netfilter/xt_hmark.h>
> > +#include <linux/netfilter/x_tables.h>
> > +#if defined(CONFIG_NF_NAT)
> > +#include <net/netfilter/nf_nat.h>
> > +#endif
> > +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> > +#	define WITH_IPV6 1
> > +#include <net/ipv6.h>
> > +#include <linux/netfilter_ipv6/ip6_tables.h>
> > +#endif
> > +
> > +MODULE_LICENSE("GPL");
> > +MODULE_AUTHOR("Hans Schillstrom <hans.schillstrom@ericsson.com>");
> > +MODULE_DESCRIPTION("Xtables: packet range mark operations by hash valu=
e");
> > +MODULE_ALIAS("ipt_HMARK");
> > +MODULE_ALIAS("ip6t_HMARK");
> > +
> > +/*
> > + * ICMP, get inner header so calc can be made on the source message
> > + *
> > + * iphsz: ip header size in bytes
> > + * nhoff: network header offset
> > + * return; updated nhoff if an icmp error
> > + */
>=20
> Please, remove these comments:

No problems

>=20
> 1) These functions are static, they provide no API for other users.
> 2) By reading the code, you can notice what it does. It's redundant.
>=20
> > +static int get_inner_hdr(struct sk_buff *skb, int iphsz, int nhoff)
> > +{
> > +	const struct icmphdr *icmph;
> > +	struct icmphdr _ih;
> > +
> > +	/* Not enough header? */
> > +	icmph =3D skb_header_pointer(skb, nhoff + iphsz, sizeof(_ih), &_ih);
> > +	if (icmph =3D=3D NULL)
> > +		return nhoff;
> > +
> > +	if (icmph->type > NR_ICMP_TYPES)
> > +		return nhoff;
> > +
> > +	/* Error message? */
> > +	if (icmph->type !=3D ICMP_DEST_UNREACH &&
> > +	    icmph->type !=3D ICMP_SOURCE_QUENCH &&
> > +	    icmph->type !=3D ICMP_TIME_EXCEEDED &&
> > +	    icmph->type !=3D ICMP_PARAMETERPROB &&
> > +	    icmph->type !=3D ICMP_REDIRECT)
> > +		return nhoff;
> > +
> > +	return nhoff + iphsz + sizeof(_ih);
> > +}
> > +
> > +#ifdef WITH_IPV6
> > +/* Dummy header used for size calculation of an error header */
> > +struct _icmpv6_errh {
> > +	__u8		icmp6_type;
> > +	__u8		icmp6_code;
> > +	__u16		icmp6_cksum;
> > +	__u32		icmp6_nu;
> > +};
>=20
> Interesting, by quick search, I don't find this structure defined
> elsewhere, why?
>=20
I have no idea ...
the closest is "struct icmp6hdr" but it contains everything

> > +/*
> > + * Get ipv6 header offset if icmp type < 128 i.e. an error.
> > + * @param: offset  input: where ICMPv6 header starts
> > + *                output: where ipv6 header starts / unchanged.
> > + *
> > + * Returns true if it's an icmp error
> > + *              and updates *offset to where ipv6 header starts
> > + */
> > +static int get_inner6_hdr(struct sk_buff *skb, int *offset)
> > +{
> > +	struct icmp6hdr *icmp6h, _ih6;
> > +
> > +	icmp6h =3D skb_header_pointer(skb, *offset, sizeof(_ih6), &_ih6);
> > +	if (icmp6h =3D=3D NULL)
> > +		return 0;
> > +
> > +	if (icmp6h->icmp6_type && icmp6h->icmp6_type < 128) {
> > +		*offset +=3D  sizeof(struct _icmpv6_errh);
> > +		return 1;
> > +	}
> > +	return 0;
> > +}
> > +/*
> > + * Calculate hash based fw-mark, on the five tuple if possible.
> > + * special cases :
> > + *  - Fragments do not use ports not even on the first fragment,
> > + *    nf_defrag_ipv6.ko don't defrag for us like it do in ipv4.
> > + *    This might be changed in the future.
> > + *  - On ICMP errors the inner header will be used.
> > + *  - Tunnels no ports
> > + *  - ESP & AH uses SPI
> > + * @returns XT_CONTINUE
> > + */
> > +__u32 hmark_v6(struct sk_buff *skb, const struct xt_action_param *par)
> > +{
> > +	struct xt_hmark_info *info =3D (struct xt_hmark_info *)par->targinfo;
> > +	struct ipv6hdr *ip6, _ip6;
> > +	int poff, flag =3D IP6T_FH_F_AUTH; /* Ports offset, find_hdr flags */
> > +	u32 addr1, addr2, hash, nhoffs=3D0;
> > +	u8 nexthdr;
> > +	union hports uports =3D { .v32 =3D 0 };
> > +	unsigned short fragoff =3D 0;
> > +
> > +	if (!info->hmod)
> > +		return XT_CONTINUE;
>=20
> why this? check in user-space that libxt_HMARK does not send this to
> kernel-space and check it again in checkentry().

Well, better safe than ... divide by zero

OK, it very very unlikely that it becomes zero
so if you want I can remove that check.

Thanks
/Hans

--nextPart2203844.xseu646aEq
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAk8cmbQACgkQsPw1jACzjGa+qQCbBDSQ/x3t+BZqLfPOYsEioL8P
j7QAn25lcLUjLN1BVyeP2K5M9ft6A347
=Cf4n
-----END PGP SIGNATURE-----

--nextPart2203844.xseu646aEq--
