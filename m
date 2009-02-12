From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match (iptables part)
Date: Thu, 12 Feb 2009 19:26:53 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902121922280.20367@fbirervta.pbzchgretzou.qr>
References: <20090212171245.GA15025@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:52757 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbZBLS0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 13:26:54 -0500
In-Reply-To: <20090212171245.GA15025@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>
>#include <stdio.h>
>#include <netdb.h>
>#include <string.h>
>#include <stdlib.h>
>#include <getopt.h>
>#include <ctype.h>
>
>#include <xtables.h>
>
>typedef unsigned int __u32;
>typedef unsigned short __u16;
>typedef unsigned char __u8;

These should not done here.. it likely causes a "redefinition"
warning or compile error of sorts. Include <linux/types.h> if
in doubt.

>static void osf_help(void)
>{
>	printf("OS fingerprint match options:\n"
>		"--genre [!] string	Match a OS genre by passive fingerprinting.\n"

The syntax should be  [!] --genre string, that is what most
others use. Then the check_inverse call also be removed.

>static const struct option osf_opts[] = {
>	{ .name = "genre",	.has_arg = 1, .flag = 0, .val = '1' },
>	{ .name = "ttl",	.has_arg = 1, .flag = 0, .val = '2' },
>	{ .name = "log",	.has_arg = 1, .flag = 0, .val = '3' },
>	{ .name = "connector",	.has_arg = 0, .flag = 0, .val = '5' },
>	{ .name = NULL }
>};

.flag can be omitted; .has_arg=true

>			osf_parse_string(argv[optind-1], info);
>			if (invert)
>				info->flags |= IPT_OSF_INVERT;
>			info->len=strlen((char *)info->genre);

This cast seems unnecessary.

>		case '2': /* --ttl */
>			if (*flags & IPT_OSF_TTL)
>				exit_error(PARAMETER_PROBLEM, "Can't specify multiple ttl parameter");
>			*flags |= IPT_OSF_TTL;
>			info->flags |= IPT_OSF_TTL;
>			info->ttl = atoi(argv[optind-1]);

Make use of xtables_strtoui to do bounds checking on the TTL value.

>static void osf_save(const void *ip, const struct xt_entry_match *match)
>{
>	const struct ipt_osf_info *info = (const struct ipt_osf_info*) match->data;
>
>	printf("--genre %s%s ", (info->flags & IPT_OSF_INVERT) ? "! ": "", info->genre);
>}

Similarly, put ! before.

>static struct xtables_match osf_match = {
>    .name		= "osf",
>    .version		= XTABLES_VERSION,
>    .size		= XT_ALIGN(sizeof(struct ipt_osf_info)),
>    .userspacesize	= XT_ALIGN(sizeof(struct ipt_osf_info)),
>    .help		= &osf_help,
>    .init		= &osf_init,
>    .parse		= &osf_parse,
>    .print		= &osf_print,
>    .final_check	= &osf_final_check,
>    .save		= &osf_save,
>    .extra_opts		= osf_opts

The & for function pointers is not needed (and actually makes
macro substituion break in some cases, just in case I need
an excuse)
