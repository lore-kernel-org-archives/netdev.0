From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2 3/3] ip: add support of 'ip link type [ipip|sit]'
Date: Wed, 12 Dec 2012 18:20:30 +0100
Message-ID: <50C8BCDE.1080802@6wind.com>
References: <1355305907-7102-1-git-send-email-nicolas.dichtel@6wind.com> <1355305907-7102-3-git-send-email-nicolas.dichtel@6wind.com> <20121212091118.390b8a2b@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45396 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766Ab2LLRUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:20:34 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so646448eek.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 09:20:33 -0800 (PST)
In-Reply-To: <20121212091118.390b8a2b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/12/2012 18:11, Stephen Hemminger a =E9crit :
> On Wed, 12 Dec 2012 10:51:47 +0100
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> This patch allows to manage ip tunnels via the interface ip link.
>> The syntax for parameters is the same that 'ip tunnel'.
>>
>> It also allows to display tunnels parameters with 'ip -details link'=
 or
>> 'ip -details monitor link'.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>   ip/Makefile     |   3 +-
>>   ip/iplink.c     |   2 +-
>>   ip/link_iptnl.c | 340 ++++++++++++++++++++++++++++++++++++++++++++=
++++++++++++
>>   3 files changed, 343 insertions(+), 2 deletions(-)
>>   create mode 100644 ip/link_iptnl.c
>>
>> diff --git a/ip/Makefile b/ip/Makefile
>> index abf54bf..2b606d4 100644
>> --- a/ip/Makefile
>> +++ b/ip/Makefile
>> @@ -4,7 +4,8 @@ IPOBJ=3Dip.o ipaddress.o ipaddrlabel.o iproute.o ipr=
ule.o ipnetns.o \
>>       ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
>>       iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
>>       iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
>> -    iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip=
6tnl.o
>> +    iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip=
6tnl.o \
>> +    link_iptnl.o
>>
>>   RTMONOBJ=3Drtmon.o
>>
>> diff --git a/ip/iplink.c b/ip/iplink.c
>> index 8aac9fc..d73c705 100644
>> --- a/ip/iplink.c
>> +++ b/ip/iplink.c
>> @@ -84,7 +84,7 @@ void iplink_usage(void)
>>   	if (iplink_have_newlink()) {
>>   		fprintf(stderr, "\n");
>>   		fprintf(stderr, "TYPE :=3D { vlan | veth | vcan | dummy | ifb | =
macvlan | can |\n");
>> -		fprintf(stderr, "          bridge | ipoib | ip6tnl }\n");
>> +		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit }=
\n");
>>   	}
>>   	exit(-1);
>>   }
>> diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
>> new file mode 100644
>> index 0000000..238722d
>> --- /dev/null
>> +++ b/ip/link_iptnl.c
>> @@ -0,0 +1,340 @@
>> +/*
>> + * link_iptnl.c	ipip and sit driver module
>> + *
>> + *		This program is free software; you can redistribute it and/or
>> + *		modify it under the terms of the GNU General Public License
>> + *		as published by the Free Software Foundation; either version
>> + *		2 of the License, or (at your option) any later version.
>> + *
>> + * Authors:	Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> + *
>> + */
>> +
>> +#include <string.h>
>> +#include <net/if.h>
>> +#include <sys/types.h>
>> +#include <sys/socket.h>
>> +#include <arpa/inet.h>
>> +
>> +#include <linux/ip.h>
>> +#include <linux/if_tunnel.h>
>> +#include "rt_names.h"
>> +#include "utils.h"
>> +#include "ip_common.h"
>> +#include "tunnel.h"
>> +
>> +static void usage(int sit) __attribute__((noreturn));
>> +static void usage(int sit)
>> +{
>> +	fprintf(stderr, "Usage: ip link { add | set | change | replace | d=
el } NAME\n");
>> +	fprintf(stderr, "          type { ipip | sit } [ remote ADDR ] [ l=
ocal ADDR ]\n");
>> +	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc =
] [ dev PHYS_DEV ]\n");
>> +	fprintf(stderr, "          [ 6rd-prefix ADDR ] [ 6rd-relay_prefix =
ADDR ] [ 6rd-reset ]\n");
>> +	if (sit)
>> +		fprintf(stderr, "          [ isatap ]\n");
>> +	fprintf(stderr, "\n");
>> +	fprintf(stderr, "Where: NAME :=3D STRING\n");
>> +	fprintf(stderr, "       ADDR :=3D { IP_ADDRESS | any }\n");
>> +	fprintf(stderr, "       TOS  :=3D { NUMBER | inherit }\n");
>> +	fprintf(stderr, "       TTL  :=3D { 1..255 | inherit }\n");
>> +	exit(-1);
>> +}
>> +
>> +static int iptunnel_parse_opt(struct link_util *lu, int argc, char =
**argv,
>> +			      struct nlmsghdr *n)
>> +{
>> +	struct {
>> +		struct nlmsghdr n;
>> +		struct ifinfomsg i;
>> +		char buf[2048];
>> +	} req;
>> +	struct ifinfomsg *ifi =3D (struct ifinfomsg *)(n + 1);
>> +	struct rtattr *tb[IFLA_MAX + 1];
>> +	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
>> +	struct rtattr *iptuninfo[IFLA_IPTUN_MAX + 1];
>> +	int len;
>> +	__u32 link =3D 0;
>> +	__u32 laddr =3D 0;
>> +	__u32 raddr =3D 0;
>> +	__u8 ttl =3D 0;
>> +	__u8 tos =3D 0;
>> +	__u8 pmtudisc =3D 1;
>> +	__u16 iflags =3D 0;
>> +	struct in6_addr ip6rdprefix;
>> +	__u16 ip6rdprefixlen =3D 0;
>> +	__u32 ip6rdrelayprefix =3D 0;
>> +	__u16 ip6rdrelayprefixlen =3D 0;
>> +
>> +	memset(&ip6rdprefix, 0, sizeof(ip6rdprefix));
>> +
>> +	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
>> +		memset(&req, 0, sizeof(req));
>> +
>> +		req.n.nlmsg_len =3D NLMSG_LENGTH(sizeof(*ifi));
>> +		req.n.nlmsg_flags =3D NLM_F_REQUEST;
>> +		req.n.nlmsg_type =3D RTM_GETLINK;
>> +		req.i.ifi_family =3D preferred_family;
>> +		req.i.ifi_index =3D ifi->ifi_index;
>> +
>> +		if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0) {
>> +get_failed:
>> +			fprintf(stderr,
>> +				"Failed to get existing tunnel info.\n");
>> +			return -1;
>> +		}
>> +
>> +		len =3D req.n.nlmsg_len;
>> +		len -=3D NLMSG_LENGTH(sizeof(*ifi));
>> +		if (len < 0)
>> +			goto get_failed;
>> +
>> +		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(&req.i), len);
>> +
>> +		if (!tb[IFLA_LINKINFO])
>> +			goto get_failed;
>> +
>> +		parse_rtattr_nested(linkinfo, IFLA_INFO_MAX, tb[IFLA_LINKINFO]);
>> +
>> +		if (!linkinfo[IFLA_INFO_DATA])
>> +			goto get_failed;
>> +
>> +		parse_rtattr_nested(iptuninfo, IFLA_IPTUN_MAX,
>> +				    linkinfo[IFLA_INFO_DATA]);
>> +
>> +		if (iptuninfo[IFLA_IPTUN_LOCAL])
>> +			laddr =3D rta_getattr_u32(iptuninfo[IFLA_IPTUN_LOCAL]);
>> +
>> +		if (iptuninfo[IFLA_IPTUN_REMOTE])
>> +			raddr =3D rta_getattr_u32(iptuninfo[IFLA_IPTUN_REMOTE]);
>> +
>> +		if (iptuninfo[IFLA_IPTUN_TTL])
>> +			ttl =3D rta_getattr_u8(iptuninfo[IFLA_IPTUN_TTL]);
>> +
>> +		if (iptuninfo[IFLA_IPTUN_TOS])
>> +			tos =3D rta_getattr_u8(iptuninfo[IFLA_IPTUN_TOS]);
>> +
>> +		if (iptuninfo[IFLA_IPTUN_PMTUDISC])
>> +			pmtudisc =3D
>> +				rta_getattr_u8(iptuninfo[IFLA_IPTUN_PMTUDISC]);
>> +
>> +		if (iptuninfo[IFLA_IPTUN_FLAGS])
>> +			iflags =3D rta_getattr_u16(iptuninfo[IFLA_IPTUN_FLAGS]);
>> +
>> +		if (iptuninfo[IFLA_IPTUN_LINK])
>> +			link =3D rta_getattr_u32(iptuninfo[IFLA_IPTUN_LINK]);
>> +
>> +		if (iptuninfo[IFLA_IPTUN_6RD_PREFIX])
>> +			memcpy(&ip6rdprefix,
>> +			       RTA_DATA(iptuninfo[IFLA_IPTUN_6RD_PREFIX]),
>> +			       sizeof(laddr));
>> +
>> +		if (iptuninfo[IFLA_IPTUN_6RD_PREFIXLEN])
>> +			ip6rdprefixlen =3D
>> +				rta_getattr_u16(iptuninfo[IFLA_IPTUN_6RD_PREFIXLEN]);
>> +
>> +		if (iptuninfo[IFLA_IPTUN_6RD_RELAY_PREFIX])
>> +			ip6rdrelayprefix =3D
>> +				rta_getattr_u32(iptuninfo[IFLA_IPTUN_6RD_RELAY_PREFIX]);
>> +
>> +		if (iptuninfo[IFLA_IPTUN_6RD_RELAY_PREFIXLEN])
>> +			ip6rdrelayprefixlen =3D
>> +				rta_getattr_u16(iptuninfo[IFLA_IPTUN_6RD_RELAY_PREFIXLEN]);
>> +	}
>> +
>> +	while (argc > 0) {
>> +		if (strcmp(*argv, "remote") =3D=3D 0) {
>> +			NEXT_ARG();
>> +			if (strcmp(*argv, "any"))
>> +				raddr =3D get_addr32(*argv);
>> +			else
>> +				raddr =3D 0;
>> +		} else if (strcmp(*argv, "local") =3D=3D 0) {
>> +			NEXT_ARG();
>> +			if (strcmp(*argv, "any"))
>> +				laddr =3D get_addr32(*argv);
>> +			else
>> +				laddr =3D 0;
>> +		} else if (matches(*argv, "dev") =3D=3D 0) {
>> +			NEXT_ARG();
>> +			link =3D if_nametoindex(*argv);
>> +			if (link =3D=3D 0)
>> +				invarg("\"dev\" is invalid", *argv);
>> +		} else if (strcmp(*argv, "ttl") =3D=3D 0 ||
>> +			   strcmp(*argv, "hoplimit") =3D=3D 0) {
>> +			NEXT_ARG();
>> +			if (strcmp(*argv, "inherit") !=3D 0) {
>> +				if (get_u8(&ttl, *argv, 0))
>> +					invarg("invalid TTL\n", *argv);
>> +			} else
>> +				ttl =3D 0;
>> +		} else if (strcmp(*argv, "tos") =3D=3D 0 ||
>> +			   strcmp(*argv, "tclass") =3D=3D 0 ||
>> +			   matches(*argv, "dsfield") =3D=3D 0) {
>> +			__u32 uval;
>> +			NEXT_ARG();
>> +			if (strcmp(*argv, "inherit") !=3D 0) {
>> +				if (rtnl_dsfield_a2n(&uval, *argv))
>> +					invarg("bad TOS value", *argv);
>> +				tos =3D uval;
>> +			} else
>> +				tos =3D 1;
>> +		} else if (strcmp(*argv, "nopmtudisc") =3D=3D 0) {
>> +			pmtudisc =3D 0;
>> +		} else if (strcmp(*argv, "pmtudisc") =3D=3D 0) {
>> +			pmtudisc =3D 1;
>> +		} else if (strcmp(lu->id, "sit") =3D=3D 0 &&
>> +			   strcmp(*argv, "isatap") =3D=3D 0) {
>> +			iflags |=3D SIT_ISATAP;
>> +		} else if (strcmp(*argv, "6rd-prefix") =3D=3D 0) {
>> +			inet_prefix prefix;
>> +			NEXT_ARG();
>> +			if (get_prefix(&prefix, *argv, AF_INET6))
>> +				invarg("invalid 6rd_prefix\n", *argv);
>> +			memcpy(&ip6rdprefix, prefix.data, 16);
>> +			ip6rdprefixlen =3D prefix.bitlen;
>> +		} else if (strcmp(*argv, "6rd-relay_prefix") =3D=3D 0) {
>> +			inet_prefix prefix;
>> +			NEXT_ARG();
>> +			if (get_prefix(&prefix, *argv, AF_INET))
>> +				invarg("invalid 6rd-relay_prefix\n", *argv);
>> +			memcpy(&ip6rdrelayprefix, prefix.data, 4);
>> +			ip6rdrelayprefixlen =3D prefix.bitlen;
>> +		} else if (strcmp(*argv, "6rd-reset") =3D=3D 0) {
>> +			inet_prefix prefix;
>> +			get_prefix(&prefix, "2002::", AF_INET6);
>> +			memcpy(&ip6rdprefix, prefix.data, 16);
>> +			ip6rdprefixlen =3D 16;
>> +			ip6rdrelayprefix =3D 0;
>> +			ip6rdrelayprefixlen =3D 0;
>> +		} else
>> +			usage(strcmp(lu->id, "sit") =3D=3D 0);
>> +		argc--, argv++;
>> +	}
>> +
>> +	if (ttl && pmtudisc =3D=3D 0) {
>> +		fprintf(stderr, "ttl !=3D 0 and noptmudisc are incompatible\n");
>> +		exit(-1);
>> +	}
>> +
>> +	addattr32(n, 1024, IFLA_IPTUN_LINK, link);
>> +	addattr32(n, 1024, IFLA_IPTUN_LOCAL, laddr);
>> +	addattr32(n, 1024, IFLA_IPTUN_REMOTE, raddr);
>> +	addattr8(n, 1024, IFLA_IPTUN_TTL, ttl);
>> +	addattr8(n, 1024, IFLA_IPTUN_TOS, tos);
>> +	addattr8(n, 1024, IFLA_IPTUN_PMTUDISC, pmtudisc);
>> +	if (strcmp(lu->id, "sit") =3D=3D 0) {
>> +		addattr16(n, 1024, IFLA_IPTUN_FLAGS, iflags);
>> +		if (ip6rdprefixlen) {
>> +			addattr_l(n, 1024, IFLA_IPTUN_6RD_PREFIX,
>> +				  &ip6rdprefix, sizeof(ip6rdprefix));
>> +			addattr16(n, 1024, IFLA_IPTUN_6RD_PREFIXLEN,
>> +				  ip6rdprefixlen);
>> +			addattr32(n, 1024, IFLA_IPTUN_6RD_RELAY_PREFIX,
>> +				  ip6rdrelayprefix);
>> +			addattr16(n, 1024, IFLA_IPTUN_6RD_RELAY_PREFIXLEN,
>> +				  ip6rdrelayprefixlen);
>> +		}
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static void iptunnel_print_opt(struct link_util *lu, FILE *f, struc=
t rtattr *tb[])
>> +{
>> +	char s1[1024];
>> +	char s2[64];
>> +	const char *local =3D "any";
>> +	const char *remote =3D "any";
>> +
>> +	if (!tb)
>> +		return;
>> +
>> +	if (tb[IFLA_IPTUN_REMOTE]) {
>> +		unsigned addr =3D rta_getattr_u32(tb[IFLA_IPTUN_REMOTE]);
>> +
>> +		if (addr)
>> +			remote =3D format_host(AF_INET, 4, &addr, s1, sizeof(s1));
>> +	}
>> +
>> +	fprintf(f, "remote %s ", remote);
>> +
>> +	if (tb[IFLA_IPTUN_LOCAL]) {
>> +		unsigned addr =3D rta_getattr_u32(tb[IFLA_IPTUN_LOCAL]);
>> +
>> +		if (addr)
>> +			local =3D format_host(AF_INET, 4, &addr, s1, sizeof(s1));
>> +	}
>> +
>> +	fprintf(f, "local %s ", local);
>> +
>> +	if (tb[IFLA_IPTUN_LINK] && rta_getattr_u32(tb[IFLA_IPTUN_LINK])) {
>> +		unsigned link =3D rta_getattr_u32(tb[IFLA_IPTUN_LINK]);
>> +		const char *n =3D if_indextoname(link, s2);
>> +
>> +		if (n)
>> +			fprintf(f, "dev %s ", n);
>> +		else
>> +			fprintf(f, "dev %u ", link);
>> +	}
>> +
>> +	if (tb[IFLA_IPTUN_TTL] && rta_getattr_u8(tb[IFLA_IPTUN_TTL]))
>> +		fprintf(f, "ttl %d ", rta_getattr_u8(tb[IFLA_IPTUN_TTL]));
>> +	else
>> +		fprintf(f, "ttl inherit ");
>> +
>> +	if (tb[IFLA_IPTUN_TOS] && rta_getattr_u8(tb[IFLA_IPTUN_TOS])) {
>> +		int tos =3D rta_getattr_u8(tb[IFLA_IPTUN_TOS]);
>> +
>> +		fputs("tos ", f);
>> +		if (tos =3D=3D 1)
>> +			fputs("inherit ", f);
>> +		else
>> +			fprintf(f, "0x%x ", tos);
>> +	}
>> +
>> +	if (tb[IFLA_IPTUN_PMTUDISC] && rta_getattr_u8(tb[IFLA_IPTUN_PMTUDI=
SC]))
>> +		fprintf(f, "pmtudisc ");
>> +	else
>> +		fprintf(f, "nopmtudisc ");
>> +
>> +	if (tb[IFLA_IPTUN_FLAGS]) {
>> +	       __u16 iflags =3D rta_getattr_u16(tb[IFLA_IPTUN_FLAGS]);
>> +
>> +	      if (iflags & SIT_ISATAP)
>> +		      fprintf(f, "isatap ");
>> +	}
>> +
>> +	if (tb[IFLA_IPTUN_6RD_PREFIXLEN] &&
>> +	    *(__u16 *)RTA_DATA(tb[IFLA_IPTUN_6RD_PREFIXLEN])) {
>> +		__u16 prefixlen =3D rta_getattr_u16(tb[IFLA_IPTUN_6RD_PREFIXLEN])=
;
>> +		__u16 relayprefixlen =3D
>> +			rta_getattr_u16(tb[IFLA_IPTUN_6RD_RELAY_PREFIXLEN]);
>> +		__u32 relayprefix =3D
>> +			rta_getattr_u32(tb[IFLA_IPTUN_6RD_RELAY_PREFIX]);
>> +
>> +		printf("6rd-prefix %s/%u ",
>> +		       inet_ntop(AF_INET6, RTA_DATA(tb[IFLA_IPTUN_6RD_PREFIX]),
>> +			         s1, sizeof(s1)),
>> +		       prefixlen);
>> +		if (relayprefix) {
>> +			printf("6rd-relay_prefix %s/%u ",
>> +			       format_host(AF_INET, 4, &relayprefix, s1,
>> +				           sizeof(s1)),
>> +			       relayprefixlen);
>> +		}
>> +	}
>> +}
>> +
>> +struct link_util ipip_link_util =3D {
>> +	.id =3D "ipip",
>> +	.maxattr =3D IFLA_IPTUN_MAX,
>> +	.parse_opt =3D iptunnel_parse_opt,
>> +	.print_opt =3D iptunnel_print_opt,
>> +};
>> +
>> +struct link_util sit_link_util =3D {
>> +	.id =3D "sit",
>> +	.maxattr =3D IFLA_IPTUN_MAX,
>> +	.parse_opt =3D iptunnel_parse_opt,
>> +	.print_opt =3D iptunnel_print_opt,
>> +};
>
> All applied with minor corrections to header files.
>
> Could you please add man pages for this new functionality?
>
Ok.
