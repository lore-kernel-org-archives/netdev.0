From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v2 PATCH 2/2] NETFILTER userspace part for target HMARK
Date: Mon, 7 Nov 2011 01:55:35 +0100
Message-ID: <20111107005535.GB29665@1984>
References: <1317664003-28189-1-git-send-email-hans.schillstrom@ericsson.com>
 <1317664003-28189-3-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans@schillstrom.com
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1317664003-28189-3-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 03, 2011 at 07:46:43PM +0200, Hans Schillstrom wrote:
> The target allows you to create rules in the "raw" and "mangle" tables
> which alter the netfilter mark (nfmark) field within a given range.
> First a 32 bit hash value is generated then modulus by <limit> and
> finally an offset is added before it's written to nfmark.
> Prior to routing, the nfmark can influence the routing method (see
> "Use netfilter MARK value as routing key") and can also be used by
> other subsystems to change their behaviour.
> 
> The mark match can also be used to match nfmark produced by this module.
> 
> Ver 2
>   IPv4 NAT added
>   iptables ver 1.4.12.1 adaptions.
> 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  extensions/libxt_HMARK.c           |  381 ++++++++++++++++++++++++++++++++++++
>  extensions/libxt_HMARK.man         |   66 ++++++
>  include/linux/netfilter/xt_hmark.h |   48 +++++
>  3 files changed, 495 insertions(+), 0 deletions(-)
>  create mode 100644 extensions/libxt_HMARK.c
>  create mode 100644 extensions/libxt_HMARK.man
>  create mode 100644 include/linux/netfilter/xt_hmark.h
> 
> diff --git a/extensions/libxt_HMARK.c b/extensions/libxt_HMARK.c
> new file mode 100644
> index 0000000..0def034
> --- /dev/null
> +++ b/extensions/libxt_HMARK.c
> @@ -0,0 +1,381 @@
> +/*
> + * Shared library add-on to iptables to add HMARK target support.
> + *
> + * The kernel module calculates a hash value that can be modified by modulus
> + * and an offset. The hash value is based on a direction independent
> + * five tuple: src & dst addr src & dst ports and protocol.
> + * However src & dst port can be masked and are not used for fragmented
> + * packets, ESP and AH don't have ports so SPI will be used instead.
> + * For ICMP error messages the hash mark values will be calculated on
> + * the source packet i.e. the packet caused the error (If sufficient
> + * amount of data exists).
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +#include <stdbool.h>
> +#include <stdio.h>
> +#include <string.h>
> +#include <stdlib.h>
> +#include <getopt.h>
> +
> +#include <xtables.h>
> +#include <linux/netfilter/x_tables.h>
> +#include <linux/netfilter/xt_hmark.h>
> +
> +
> +#define DEF_HRAND 0xc175a3b8	/* Default "random" value to jhash */
> +
> +static void HMARK_help(void)
> +{
> +	printf(
> +"HMARK target options, i.e. modify hash calculation by:\n"
> +"  --hmark-smask value                Mask source address with value\n"
> +"  --hmark-dmask value                Mask Dest. address with value\n"
> +"  --hmark-sp-mask value              Mask src port with value\n"
> +"  --hmark-dp-mask value              Mask dst port with value\n"
> +"  --hmark-spi-mask value             For esp and ah AND spi with value\n"
> +"  --hmark-sp-set value               OR src port with value\n"
> +"  --hmark-dp-set value               OR dst port with value\n"
> +"  --hmark-spi-set value              For esp and ah OR spi with value\n"
> +"  --hmark-proto-mask value           Mask Protocol with value\n"
> +"  --hmark-rnd                        Random value to hash cacl.\n"
> +"  Limit/modify the calculated hash mark by:\n"
> +"  --hmark-mod value                  nfmark modulus value\n"
> +"  --hmark-offs value                 Last action add value to nfmark\n"
> +" For NAT in IPv4 the original address can be used in the return path.\n"
> +" Make sure to qualify the statement in a proper way when using nat flags\n"
> +"  --hmark-dnat                       Replace src addr/port with original dst addr/port\n"
> +"  --hmark-snat                       Replace dst addr/port with original src addr/port\n"
> +" In many cases hmark can be omitted i.e. --smask can be used\n");
> +}
> +
> +static const struct option HMARK_opts[] = {
> +	{ "hmark-smask", 1, NULL, XT_HMARK_SADR_AND },
> +	{ "hmark-dmask", 1, NULL, XT_HMARK_DADR_AND },
> +	{ "hmark-sp-mask", 1, NULL, XT_HMARK_SPORT_AND },
> +	{ "hmark-dp-mask", 1, NULL, XT_HMARK_DPORT_AND },
> +	{ "hmark-spi-mask", 1, NULL, XT_HMARK_SPI_AND },
> +	{ "hmark-sp-set", 1, NULL, XT_HMARK_SPORT_OR },
> +	{ "hmark-dp-set", 1, NULL, XT_HMARK_DPORT_OR },
> +	{ "hmark-spi-set", 1, NULL, XT_HMARK_SPI_OR },
> +	{ "hmark-proto-mask", 1, NULL, XT_HMARK_PROTO_AND },
> +	{ "hmark-rnd", 1, NULL, XT_HMARK_RND },
> +	{ "hmark-mod", 1, NULL, XT_HMARK_MODULUS },
> +	{ "hmark-offs", 1, NULL, XT_HMARK_OFFSET },
> +	{ "hmark-dnat", 1, NULL, XT_HMARK_USE_DNAT },
> +	{ "hmark-snat", 1, NULL, XT_HMARK_USE_SNAT },
> +	{ "smask", 1, NULL, XT_HMARK_SADR_AND },
> +	{ "dmask", 1, NULL, XT_HMARK_DADR_AND },
> +	{ "sp-mask", 1, NULL, XT_HMARK_SPORT_AND },
> +	{ "dp-mask", 1, NULL, XT_HMARK_DPORT_AND },
> +	{ "spi-mask", 1, NULL, XT_HMARK_SPI_AND },
> +	{ "sp-set", 1, NULL, XT_HMARK_SPORT_OR },
> +	{ "dp-set", 1, NULL, XT_HMARK_DPORT_OR },
> +	{ "spi-set", 1, NULL, XT_HMARK_SPI_OR },
> +	{ "proto-mask", 1, NULL, XT_HMARK_PROTO_AND },
> +	{ "rnd", 1, NULL, XT_HMARK_RND },
> +	{ "mod", 1, NULL, XT_HMARK_MODULUS },
> +	{ "offs", 1, NULL, XT_HMARK_OFFSET },
> +	{ "dnat", 1, NULL, XT_HMARK_USE_DNAT },
> +	{ "snat", 1, NULL, XT_HMARK_USE_SNAT },
> +	{ .name = NULL }
> +};
> +
> +static int
> +HMARK_parse(int c, char **argv, int invert, unsigned int *flags,
> +	    const void *entry, struct xt_entry_target **target)
> +{
> +	struct xt_hmark_info *hmarkinfo
> +		= (struct xt_hmark_info *)(*target)->data;
> +	unsigned int value = 0xffffffff;
> +	unsigned int maxint = UINT32_MAX;
> +
> +	if ((c < XT_HMARK_SADR_AND) || (c > XT_HMARK_OFFSET)) {
> +		xtables_error(PARAMETER_PROBLEM, "Bad HMARK option \"%s\"",
> +			      optarg);
> +		return 0;
> +	}
> +
> +	if (c >= XT_HMARK_SPORT_AND && c <= XT_HMARK_DPORT_OR)
> +		maxint = UINT16_MAX;
> +	else if (c == XT_HMARK_PROTO_AND)
> +		maxint = UINT8_MAX;
> +
> +	if (!xtables_strtoui(optarg, NULL, &value, 0, maxint))
> +		xtables_error(PARAMETER_PROBLEM, "Bad HMARK value \"%s\"",
> +			      optarg);
> +
> +	if (*flags == 0) {
> +		memset(hmarkinfo, 0xff, sizeof(struct xt_hmark_info));
> +		hmarkinfo->pset.v32 = 0;
> +		hmarkinfo->flags = 0;
> +		hmarkinfo->spiset = 0;
> +		hmarkinfo->hoffs = 0;
> +		hmarkinfo->hashrnd = DEF_HRAND;
> +	}
> +	switch (c) {
> +	case XT_HMARK_SADR_AND:
> +		if (*flags & (1 << c)) {
> +			xtables_error(PARAMETER_PROBLEM,
> +				      "Can only specify "
> +				      "`--hmark-smask' once");
> +		}
> +		hmarkinfo->smask = htonl(value);
> +		if (value == maxint)
> +			c = 0;
> +		break;

Please, check current iptables git tree. Jan implemented more advanced
method to handle options. For instance, have a look at libxt_cluster.c
