From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] iproute2: Add support for VRF device
Date: Tue, 11 Aug 2015 22:17:35 +0300
Message-ID: <E3EEA8BB-EC1B-409D-8577-5BC0EA2FC506@cumulusnetworks.com>
References: <1439229037-79213-1-git-send-email-dsa@cumulusnetworks.com> <1439229037-79213-11-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37956 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbbHKTRk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 15:17:40 -0400
Received: by wicja10 with SMTP id ja10so81293678wic.1
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 12:17:38 -0700 (PDT)
In-Reply-To: <1439229037-79213-11-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Since there will be another version a few minor nits below,

> On Aug 10, 2015, at 8:50 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> 
> Allow user to create a vrf device and specify its table binding.
> Based on the iplink_vlan implementation.
> 
> Signed-off-by: Shrijeet Mukherjee <shm@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> include/linux/if_link.h |  8 +++++
> ip/Makefile             |  2 +-
> ip/iplink.c             |  2 +-
> ip/iplink_vrf.c         | 85 +++++++++++++++++++++++++++++++++++++++++++++++++
> 4 files changed, 95 insertions(+), 2 deletions(-)
> create mode 100644 ip/iplink_vrf.c
> 
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index b905cf7f4948..74dedf4320b8 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -338,6 +338,14 @@ enum macvlan_macaddr_mode {
> 
> #define MACVLAN_FLAG_NOPROMISC	1
> 
> +/* VRF section */
> +enum {
> +	IFLA_VRF_UNSPEC,
> +	IFLA_VRF_TABLE,
> +	__IFLA_VRF_MAX
> +};
> +
> +#define IFLA_VRF_MAX (__IFLA_VRF_MAX - 1)
> /* IPVLAN section */
> enum {
> 	IFLA_IPVLAN_UNSPEC,
> diff --git a/ip/Makefile b/ip/Makefile
> index 77653ecc5785..d8b38ac2e44b 100644
> --- a/ip/Makefile
> +++ b/ip/Makefile
> @@ -7,7 +7,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
>     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
>     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
>     iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
> -    iplink_geneve.o
> +    iplink_geneve.o iplink_vrf.o
> 
> RTMONOBJ=rtmon.o
> 
> diff --git a/ip/iplink.c b/ip/iplink.c
> index 369d50eab94e..14bf7211a447 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -94,7 +94,7 @@ void iplink_usage(void)
> 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
> 		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
> 		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon |\n");
> -		fprintf(stderr, "          bond_slave | ipvlan | geneve }\n");
> +		fprintf(stderr, "          bond_slave | ipvlan | geneve | vrf }\n");
> 	}
> 	exit(-1);
> }
> diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
> new file mode 100644
> index 000000000000..0d7e21c7c152
> --- /dev/null
> +++ b/ip/iplink_vrf.c
> @@ -0,0 +1,85 @@
> +/* iplink_vrf.c	VRF device support
> + *
> + *              This program is free software; you can redistribute it and/or
> + *              modify it under the terms of the GNU General Public License
> + *              as published by the Free Software Foundation; either version
> + *              2 of the License, or (at your option) any later version.
> + *
> + * Authors:     Shrijeet Mukherjee <shm@cumulusnetworks.com>
> + */
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <string.h>
> +#include <sys/socket.h>
> +#include <linux/if_link.h>
> +
> +#include "rt_names.h"
> +#include "utils.h"
> +#include "ip_common.h"
> +
> +static void vrf_explain(FILE *f)
> +{
> +	fprintf(f, "Usage: ... vrf table TABLEID \n");
> +}
> +
> +static void explain(void)
> +{
> +	vrf_explain(stderr);
> +}
> +
> +static int table_arg(void)
> +{
> +	fprintf(stderr,"Error: argument of \"table\" must be 0-32767 and currently unused\n");
> +	return -1;
> +}
> +
> +static int vrf_parse_opt(struct link_util *lu, int argc, char **argv,
> +			    struct nlmsghdr *n)
> +{
> +	while (argc > 0) {
> +		if (matches(*argv, "table") == 0) {
> +			__u32 table = 0;
> +			NEXT_ARG();
^^^
Please leave a line between local variable definitions and code. Also no need
to initialize table to 0.

> +
> +			table = atoi(*argv);
> +			if (table < 0 || table > 32767)
^^^
table is unsigned, so < 0 will be always false.

> +				return table_arg();
> +			addattr32(n, 1024, IFLA_VRF_TABLE, table);
> +		} else if (matches(*argv, "help") == 0) {
> +			explain();
> +			return -1;
> +		} else {
> +			fprintf(stderr, "vrf: unknown option \"%s\"?\n",
> +				*argv);
> +			explain();
> +			return -1;
> +		}
> +		argc--, argv++;
> +	}
> +
> +	return 0;
> +}
> +
> +static void vrf_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
> +{
> +	if (!tb)
> +		return;
> +
> +	if (tb[IFLA_VRF_TABLE])
> +		fprintf(f, "table %u ", rta_getattr_u32(tb[IFLA_VRF_TABLE]));
> +}
> +
> +static void vrf_print_help(struct link_util *lu, int argc, char **argv,
> +			      FILE *f)
> +{
> +	vrf_explain(f);
> +}
> +
> +struct link_util vrf_link_util = {
> +	.id		= "vrf",
> +	.maxattr	= IFLA_VRF_MAX,
> +	.parse_opt	= vrf_parse_opt,
> +	.print_opt	= vrf_print_opt,
> +	.print_help	= vrf_print_help,
> +};
> -- 
> 2.3.2 (Apple Git-55)
> 
