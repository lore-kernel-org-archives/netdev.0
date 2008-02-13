From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCh TAKE 2] [IPROUTE2] Add addrlabel sub-command.
Date: Wed, 13 Feb 2008 12:37:56 -0800
Message-ID: <20080213123756.318de34a@extreme>
References: <20080214.032012.71214842.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:40922 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145AbYBMUkH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 15:40:07 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1JPOOh-00020e-1n
	for netdev@vger.kernel.org; Wed, 13 Feb 2008 20:40:03 +0000
Received: from 75-175-36-245.ptld.qwest.net ([75.175.36.245])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 20:40:03 +0000
Received: from shemminger by 75-175-36-245.ptld.qwest.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 20:40:03 +0000
In-Reply-To: <20080214.032012.71214842.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Feb 2008 03:20:12 +1100 (EST)
YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E  <yoshfuji@lin=
ux-ipv6.org> wrote:

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
> diff --git a/ip/Makefile b/ip/Makefile
> index b427d58..d908817 100644
> --- a/ip/Makefile
> +++ b/ip/Makefile
> @@ -1,4 +1,4 @@
> -IPOBJ=3Dip.o ipaddress.o iproute.o iprule.o \
> +IPOBJ=3Dip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o \
>      rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o i=
plink.o \
>      ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o \
>      ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
> diff --git a/ip/ip.c b/ip/ip.c
> index aeb8c68..c4c773f 100644
> --- a/ip/ip.c
> +++ b/ip/ip.c
> @@ -46,8 +46,8 @@ static void usage(void)
>  	fprintf(stderr,
>  "Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }\n"
>  "       ip [ -force ] [-batch filename\n"
> -"where  OBJECT :=3D { link | addr | route | rule | neigh | ntable | =
tunnel |\n"
> -"                   maddr | mroute | monitor | xfrm }\n"
> +"where  OBJECT :=3D { link | addr | addrlabel | route | rule | neigh=
 | ntable |\n"
> +"                   tunnel | maddr | mroute | monitor | xfrm }\n"
>  "       OPTIONS :=3D { -V[ersion] | -s[tatistics] | -d[etails] | -r[=
esolve] |\n"
>  "                    -f[amily] { inet | inet6 | ipx | dnet | link } =
|\n"
>  "                    -o[neline] | -t[imestamp] }\n");
> @@ -64,6 +64,7 @@ static const struct cmd {
>  	int (*func)(int argc, char **argv);
>  } cmds[] =3D {
>  	{ "address", 	do_ipaddr },
> +	{ "addrlabel",	do_ipaddrlabel },
>  	{ "maddress",	do_multiaddr },
>  	{ "route",	do_iproute },
>  	{ "rule",	do_iprule },
> diff --git a/ip/ip_common.h b/ip/ip_common.h
> index 39f2507..1bbd50d 100644
> --- a/ip/ip_common.h
> +++ b/ip/ip_common.h
> @@ -4,6 +4,9 @@ extern int print_linkinfo(const struct sockaddr_nl *w=
ho,
>  extern int print_addrinfo(const struct sockaddr_nl *who,
>  			  struct nlmsghdr *n,
>  			  void *arg);
> +extern int print_addrlabelinfo(const struct sockaddr_nl *who,
> +			       struct nlmsghdr *n,
> +			       void *arg);
>  extern int print_neigh(const struct sockaddr_nl *who,
>  		       struct nlmsghdr *n, void *arg);
>  extern int print_ntable(const struct sockaddr_nl *who,
> @@ -23,6 +26,7 @@ extern int print_prefix(const struct sockaddr_nl *w=
ho,
>  extern int print_rule(const struct sockaddr_nl *who,
>  		      struct nlmsghdr *n, void *arg);
>  extern int do_ipaddr(int argc, char **argv);
> +extern int do_ipaddrlabel(int argc, char **argv);
>  extern int do_iproute(int argc, char **argv);
>  extern int do_iprule(int argc, char **argv);
>  extern int do_ipneigh(int argc, char **argv);
> diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
> new file mode 100644
> index 0000000..1c873e9
> --- /dev/null
> +++ b/ip/ipaddrlabel.c
> @@ -0,0 +1,260 @@
> +/*
> + * ipaddrlabel.c	"ip addrlabel"
> + *
> + * Copyright (C)2007 USAGI/WIDE Project
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License as published=
 by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1=
307  USA
> + *
> + *
> + * Based on iprule.c.
> + *
> + * Authors:	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> + *
> + */
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <unistd.h>
> +#include <syslog.h>
> +#include <fcntl.h>
> +#include <sys/socket.h>
> +#include <netinet/in.h>
> +#include <netinet/ip.h>
> +#include <arpa/inet.h>
> +#include <string.h>
> +#include <linux/types.h>
> +#include <linux/if_addrlabel.h>
> +
> +#include "rt_names.h"
> +#include "utils.h"
> +#include "ip_common.h"
> +
> +#define IFAL_RTA(r)	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(siz=
eof(struct ifaddrlblmsg))))
> +#define IFAL_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct ifaddrlblmsg))
> +
> +extern struct rtnl_handle rth;
> +
> +static void usage(void) __attribute__((noreturn));
> +
> +static void usage(void)
> +{
> +	fprintf(stderr, "Usage: ip addrlabel [ list | add | del | flush ] p=
refix PREFIX [ dev DEV ] [ label LABEL ]\n");
> +	exit(-1);
> +}
> +
> +int print_addrlabel(const struct sockaddr_nl *who, struct nlmsghdr *=
n, void *arg)
> +{
> +	FILE *fp =3D (FILE*)arg;
> +	struct ifaddrlblmsg *ifal =3D NLMSG_DATA(n);
> +	int len =3D n->nlmsg_len;
> +	int host_len =3D -1;
> +	struct rtattr *tb[IFAL_MAX+1];
> +	char abuf[256];
> +
> +	if (n->nlmsg_type !=3D RTM_NEWADDRLABEL && n->nlmsg_type !=3D RTM_D=
ELADDRLABEL)
> +		return 0;
> +
> +	len -=3D NLMSG_LENGTH(sizeof(*ifal));
> +	if (len < 0)
> +		return -1;
> +
> +	parse_rtattr(tb, IFAL_MAX, IFAL_RTA(ifal), len);
> +
> +	if (ifal->ifal_family =3D=3D AF_INET)
> +		host_len =3D 32;
> +	else if (ifal->ifal_family =3D=3D AF_INET6)
> +		host_len =3D 128;
> +
> +	if (n->nlmsg_type =3D=3D RTM_DELADDRLABEL)
> +		fprintf(fp, "Deleted ");
> +
> +	if (tb[IFAL_ADDRESS]) {
> +		fprintf(fp, "prefix %s/%u ",
> +			format_host(ifal->ifal_family,
> +				    RTA_PAYLOAD(tb[IFAL_ADDRESS]),
> +				    RTA_DATA(tb[IFAL_ADDRESS]),
> +				    abuf, sizeof(abuf)),
> +			ifal->ifal_prefixlen);
> +	}
> +
> +	if (ifal->ifal_index)
> +		fprintf(fp, "dev %s ", ll_index_to_name(ifal->ifal_index));
> +
> +	if (tb[IFAL_LABEL] && RTA_PAYLOAD(tb[IFAL_LABEL]) =3D=3D sizeof(int=
32_t)) {
> +		int32_t label;
> +		memcpy(&label, RTA_DATA(tb[IFAL_LABEL]), sizeof(label));
> +		fprintf(fp, "label %d ", label);
> +	}
> +
> +	fprintf(fp, "\n");
> +	fflush(fp);
> +	return 0;
> +}
> +
> +static int ipaddrlabel_list(int argc, char **argv)
> +{
> +	int af =3D preferred_family;
> +
> +	if (af =3D=3D AF_UNSPEC)
> +		af =3D AF_INET6;
> +
> +	if (argc > 0) {
> +		fprintf(stderr, "\"ip addrlabel show\" does not take any arguments=
=2E\n");
> +		return -1;
> +	}
> +
> +	if (rtnl_wilddump_request(&rth, af, RTM_GETADDRLABEL) < 0) {
> +		perror("Cannot send dump request");
> +		return 1;
> +	}
> +
> +	if (rtnl_dump_filter(&rth, print_addrlabel, stdout, NULL, NULL) < 0=
) {
> +		fprintf(stderr, "Dump terminated\n");
> +		return 1;
> +	}
> +
> +	return 0;
> +}
> +
> +
> +static int ipaddrlabel_modify(int cmd, int argc, char **argv)
> +{
> +	struct {
> +		struct nlmsghdr 	n;
> +		struct ifaddrlblmsg	ifal;
> +		char   			buf[1024];
> +	} req;
> +
> +	inet_prefix prefix;
> +	uint32_t label =3D 0xffffffffUL;
> +
> +	memset(&req, 0, sizeof(req));
> +	memset(&prefix, 0, sizeof(prefix));
> +
> +	req.n.nlmsg_type =3D cmd;
> +	req.n.nlmsg_len =3D NLMSG_LENGTH(sizeof(struct ifaddrlblmsg));
> +	req.n.nlmsg_flags =3D NLM_F_REQUEST;
> +	req.ifal.ifal_family =3D preferred_family;
> +	req.ifal.ifal_prefixlen =3D 0;
> +	req.ifal.ifal_index =3D 0;
> +
> +	if (cmd =3D=3D RTM_NEWADDRLABEL) {
> +		req.n.nlmsg_flags |=3D NLM_F_CREATE|NLM_F_EXCL;
> +	}
> +
> +	while (argc > 0) {
> +		if (strcmp(*argv, "prefix") =3D=3D 0) {
> +			NEXT_ARG();
> +			get_prefix(&prefix, *argv, preferred_family);
> +		} else if (strcmp(*argv, "dev") =3D=3D 0) {
> +			NEXT_ARG();
> +			if ((req.ifal.ifal_index =3D ll_name_to_index(*argv)) =3D=3D 0)
> +				invarg("dev is invalid\n", *argv);
> +		} else if (strcmp(*argv, "label") =3D=3D 0) {
> +			NEXT_ARG();
> +			if (get_u32(&label, *argv, 0) || label =3D=3D 0xffffffffUL)
> +				invarg("label is invalid\n", *argv);
> +		}
> +		argc--;
> +		argv++;
> +	}
> +
> +	addattr32(&req.n, sizeof(req), IFAL_LABEL, label);
> +	addattr_l(&req.n, sizeof(req), IFAL_ADDRESS, &prefix.data, prefix.b=
ytelen);
> +
> +	if (req.ifal.ifal_family =3D=3D AF_UNSPEC)
> +		req.ifal.ifal_family =3D AF_INET6;
> +
> +	if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
> +		return 2;
> +
> +	return 0;
> +}
> +
> +
> +static int flush_addrlabel(const struct sockaddr_nl *who, struct nlm=
sghdr *n, void *arg)
> +{
> +	struct rtnl_handle rth2;
> +	struct rtmsg *r =3D NLMSG_DATA(n);
> +	int len =3D n->nlmsg_len;
> +	struct rtattr * tb[IFAL_MAX+1];
> +
> +	len -=3D NLMSG_LENGTH(sizeof(*r));
> +	if (len < 0)
> +		return -1;
> +
> +	parse_rtattr(tb, IFAL_MAX, RTM_RTA(r), len);
> +
> +	if (tb[IFAL_ADDRESS]) {
> +		n->nlmsg_type =3D RTM_DELADDRLABEL;
> +		n->nlmsg_flags =3D NLM_F_REQUEST;
> +
> +		if (rtnl_open(&rth2, 0) < 0)
> +			return -1;
> +
> +		if (rtnl_talk(&rth2, n, 0, 0, NULL, NULL, NULL) < 0)
> +			return -2;
> +
> +		rtnl_close(&rth2);
> +	}
> +
> +	return 0;
> +}
> +
> +static int ipaddrlabel_flush(int argc, char **argv)
> +{
> +	int af =3D preferred_family;
> +
> +	if (af =3D=3D AF_UNSPEC)
> +		af =3D AF_INET6;
> +
> +	if (argc > 0) {
> +		fprintf(stderr, "\"ip addrlabel flush\" does not allow extra argum=
ents\n");
> +		return -1;
> +	}
> +
> +	if (rtnl_wilddump_request(&rth, af, RTM_GETADDRLABEL) < 0) {
> +		perror("Cannot send dump request");
> +		return 1;
> +	}
> +
> +	if (rtnl_dump_filter(&rth, flush_addrlabel, NULL, NULL, NULL) < 0) =
{
> +		fprintf(stderr, "Flush terminated\n");
> +		return 1;
> +	}
> +
> +	return 0;
> +}
> +
> +int do_ipaddrlabel(int argc, char **argv)
> +{
> +	if (argc < 1) {
> +		return ipaddrlabel_list(0, NULL);
> +	} else if (matches(argv[0], "list") =3D=3D 0 ||
> +		   matches(argv[0], "show") =3D=3D 0) {
> +		return ipaddrlabel_list(argc-1, argv+1);
> +	} else if (matches(argv[0], "add") =3D=3D 0) {
> +		return ipaddrlabel_modify(RTM_NEWADDRLABEL, argc-1, argv+1);
> +	} else if (matches(argv[0], "delete") =3D=3D 0) {
> +		return ipaddrlabel_modify(RTM_DELADDRLABEL, argc-1, argv+1);
> +	} else if (matches(argv[0], "flush") =3D=3D 0) {
> +		return ipaddrlabel_flush(argc-1, argv+1);
> +	} else if (matches(argv[0], "help") =3D=3D 0)
> +		usage();
> +
> +	fprintf(stderr, "Command \"%s\" is unknown, try \"ip addrlabel help=
\".\n", *argv);
> +	exit(-1);
> +}
> +
> diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
> index f1a1f27..df0fd91 100644
> --- a/ip/ipmonitor.c
> +++ b/ip/ipmonitor.c
> @@ -54,6 +54,10 @@ int accept_msg(const struct sockaddr_nl *who,
>  		print_addrinfo(who, n, arg);
>  		return 0;
>  	}
> +	if (n->nlmsg_type =3D=3D RTM_NEWADDRLABEL || n->nlmsg_type =3D=3D R=
TM_DELADDRLABEL) {
> +		print_addrlabel(who, n, arg);
> +		return 0;
> +	}
>  	if (n->nlmsg_type =3D=3D RTM_NEWNEIGH || n->nlmsg_type =3D=3D RTM_D=
ELNEIGH) {
>  		print_neigh(who, n, arg);
>  		return 0;
> diff --git a/man/man8/ip.8 b/man/man8/ip.8
> index 1687045..136448c 100644
> --- a/man/man8/ip.8
> +++ b/man/man8/ip.8
> @@ -13,8 +13,8 @@ ip \- show / manipulate routing, devices, policy ro=
uting and tunnels
> =20
>  .ti -8
>  .IR OBJECT " :=3D { "
> -.BR link " | " addr " | " route " | " rule " | " neigh " | " tunnel =
" | "\
> -maddr " | "  mroute " | " monitor " }"
> +.BR link " | " addr " | " addrlabel " | " route " | " rule " | " nei=
gh " | "\
> + tunnel " | " maddr " | "  mroute " | " monitor " }"
>  .sp
> =20
>  .ti -8
> @@ -97,6 +97,17 @@ maddr " | "  mroute " | " monitor " }"
>  tentative " | " deprecated " ]"
> =20
>  .ti -8
> +.BR "ip addrlabel" " { " add " | " del " } " prefix=20
> +.BR PREFIX " [ "
> +.B dev
> +.IR DEV " ] [ "
> +.B label
> +.IR NUMBER " ]"
> +
> +.ti -8
> +.BR "ip addrlabel" " { " list " | " flush " }"
> +
> +.ti -8
>  .BR "ip route" " { "
>  .BR list " | " flush " } "
>  .I  SELECTOR
> @@ -404,6 +415,11 @@ host addresses.
>  .TP
>  .B address
>  - protocol (IP or IPv6) address on a device.
> +
> +.TP
> +.B addrlabel
> +- label configuration for protocol address selection.
> +
>  .TP
>  .B neighbour
>  - ARP or NDISC cache entry.
> @@ -708,6 +724,33 @@ this option is given twice,
>  also dumps all the deleted addresses in the format described in the
>  previous subsection.
> =20
> +.SH ip addrlabel - protocol address label management.
> +
> +IPv6 address label is used for address selection
> +described in RFC 3484.  Precedence is managed by userspace,
> +and only label is stored in kernel.
> +
> +.SS ip addrlabel add - add an address label
> +the command adds an address label entry to the kernel.
> +.TP
> +.BI prefix " PREFIX"
> +.TP
> +.BI dev " DEV"
> +the outgoing interface.
> +.TP
> +.BI label " NUMBER"
> +the label for the prefix.
> +0xffffffff is reserved.
> +.SS ip addrlabel del - delete an address label
> +the command deletes an address label entry in the kernel.
> +.B Arguments:
> +coincide with the arguments of
> +.B ip addrlabel add
> +but label is not required.
> +.SS ip addrlabel list - list address labels
> +the command show contents of address labels.
> +.SS ip addrlabel flush - flush address labels
> +the commoand flushes the contents of address labels and it does not =
restore default settings.
>  .SH ip neighbour - neighbour/arp tables management.
> =20
>  .B neighbour
>=20

applied

--=20
Stephen Hemminger <stephen.hemminger@vyatta.com>


