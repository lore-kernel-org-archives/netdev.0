From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IFGROUPv4 iptables] Interface group match
Date: Thu, 25 Oct 2007 17:25:50 +0200
Message-ID: <4720B57E.4000402@trash.net>
References: <11933245923082-git-send-email-panther@balabit.hu> <11933245922165-git-send-email-panther@balabit.hu> <11933245921874-git-send-email-panther@balabit.hu> <11933245931626-git-send-email-panther@balabit.hu> <11933245933190-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44589 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754621AbXJYP1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 11:27:16 -0400
In-Reply-To: <11933245933190-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> +++ extensions/libxt_ifgroup.c	(revision 0)
> @@ -0,0 +1,196 @@
> +/* 
> + * Shared library add-on to iptables to match 
> + * packets by the incoming interface group.
> + *
> + * (c) 2006, 2007 Balazs Scheidler <bazsi@balabit.hu>,
> + * Laszlo Attila Toth <panther@balabit.hu>
> + */
> +#include <stdio.h>
> +#include <netdb.h>
> +#include <string.h>
> +#include <stdlib.h>
> +#include <getopt.h>
> +#include <xtables.h>
> +#include <linux/netfilter/xt_ifgroup.h>
> +
> +static void
> +ifgroup_help(void)
> +{
> +	printf(
> +"ifgroup v%s options:\n"
> +"  --ifgroup-in  [!] group[/mask]  incoming interface group and its mask\n"
> +"  --ifgroup-out [!] group[/mask]  outgoing interface group and its mask\n"
> +"\n", IPTABLES_VERSION);
> +}
> +
> +static struct option opts[] = {
> +	{"ifgroup-in", 1, 0, '1'},
> +	{"ifgroup-out", 1, 0, '2'},

The third member is a pointer, please use NULL.

> +	{ }
> +};
> +
> +#define PARAM_MATCH_IN	0x01
> +#define PARAM_MATCH_OUT	0x02
> +
> +static int
> +ifgroup_parse(int c, char **argv, int invert, unsigned int *flags,
> +	      const void *entry, struct xt_entry_match **match)
> +{
> +	struct xt_ifgroup_info *info =
> +			 (struct xt_ifgroup_info *) (*match)->data;
> +	char *end;
> +	
> +	switch (c)
> +	{

This goes on the same line as the switch statement please.

> +		case '1':

And please no extra indentation for the case labels.

> +			if (*flags & PARAM_MATCH_IN)
> +				exit_error(PARAMETER_PROBLEM,
> +					"ifgroup match: Can't specify --ifgroup-in twice");
> +
> +			check_inverse(optarg, &invert, &optind, 0);
> +			
> +			info->in_group = strtoul(optarg, &end, 0);
> +			info->in_mask = 0xffffffffUL;

in_mask is not an unsigned long but an unsigned int.

> +			
> +			if (*end == '/')
> +				info->in_mask = strtoul(end+1, &end, 0);
> +
> +			if (*end != '\0' || end == optarg)
> +				exit_error(PARAMETER_PROBLEM,
> +					  "ifgroup match: Bad ifgroup value `%s'",
> +					   optarg);
> +			
> +			if (invert)
> +				info->flags |= XT_IFGROUP_INVERT_IN;
> +
> +			*flags |= PARAM_MATCH_IN;
> +			info->flags |= XT_IFGROUP_MATCH_IN;			
> +			break;
> +		case '2':
> +			if (*flags & PARAM_MATCH_OUT)
> +				exit_error(PARAMETER_PROBLEM,
> +					  "ifgroup match: Can't specify "
> +					  "--ifgroup-out twice");
> +
> +			check_inverse(optarg, &invert, &optind, 0);
> +			
> +			info->out_group = strtoul(optarg, &end, 0);
> +			info->out_mask = 0xffffffffUL;
> +			
> +			if (*end == '/')
> +				info->out_mask = strtoul(end+1, &end, 0);
> +
> +			if (*end != '\0' || end == optarg)
> +				exit_error(PARAMETER_PROBLEM,
> +					  "ifgroup match: Bad ifgroup "
> +					  "value `%s'",
> +					   optarg);
> +			
> +			if (invert)
> +				info->flags |= XT_IFGROUP_INVERT_OUT;
> +
> +			*flags |= PARAM_MATCH_OUT;
> +			info->flags |= XT_IFGROUP_MATCH_OUT;			
> +			break;
> +		default: 
> +			return 0;
> +	}
> +
> +	return 1;
> +}
> +
> +static void
> +ifgroup_final_check(unsigned int flags)
> +{
> +	if (!flags)
> +		exit_error(PARAMETER_PROBLEM,
> +			   "You must specify either "
> +			   "`--ifgroup-in' or `--ifgroup-out'");
> +}
> +
> +static void
> +ifgroup_print_value_in(struct xt_ifgroup_info *info)
> +{
> +	printf("0x%x/0x%x ", info->in_group, info->in_mask);
> +}
> +
> +static void
> +ifgroup_print_value_out(struct xt_ifgroup_info *info)
> +{
> +	printf("0x%x/0x%x ", info->out_group, info->out_mask);
> +}

Just a suggestion: not printing the mask when its ~0 would
improve readability.

> +
> +static void
> +ifgroup_print(const void *ip,
> +	      const struct xt_entry_match *match,
> +	      int numeric)
> +{
> +	struct xt_ifgroup_info *info =
> +		(struct xt_ifgroup_info *) match->data;
> +	
> +	printf("ifgroup ");
> +	
> +	if (info->flags & XT_IFGROUP_MATCH_IN) {
> +		printf("in %s",
> +		       info->flags & XT_IFGROUP_INVERT_IN ? "! " : "");
> +		ifgroup_print_value_in(info);
> +	}
> +	if (info->flags & XT_IFGROUP_MATCH_OUT) {
> +		printf("out %s",
> +		       info->flags & XT_IFGROUP_INVERT_OUT ? "! " : "");
> +		ifgroup_print_value_out(info);
> +	}
> +}
> +
> +static void
> +ifgroup_save(const void *ip, const struct xt_entry_match *match)
> +{
> +	struct xt_ifgroup_info *info =
> +		(struct xt_ifgroup_info *) match->data;
> +	
> +	if (info->flags & XT_IFGROUP_MATCH_IN) {
> +		printf("--ifgroup-in %s",
> +		       info->flags & XT_IFGROUP_INVERT_IN ? "! " : "");
> +		ifgroup_print_value_in(info);
> +	}
> +	if (info->flags & XT_IFGROUP_MATCH_OUT) {
> +		printf("--ifgroup-out %s",
> +		       info->flags & XT_IFGROUP_INVERT_OUT ? "! " : "");
> +		ifgroup_print_value_out(info);
> +	}
> +}
