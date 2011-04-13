From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] iproute2: tc add mqprio qdisc support
Date: Thu, 14 Apr 2011 00:10:22 +0100
Message-ID: <1302736222.2873.39.camel@bwh-desktop>
References: <20110412155727.4656.42756.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:3660 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932694Ab1DMXKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 19:10:25 -0400
In-Reply-To: <20110412155727.4656.42756.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I know that this has already been applied, but:

On Tue, 2011-04-12 at 08:57 -0700, John Fastabend wrote:
> Add mqprio qdisc support. Output matches the following,
> 
> # ./tc/tc qdisc
> qdisc mq 0: dev eth1 root
> qdisc mq 0: dev eth2 root
> qdisc mqprio 8001: dev eth3 root  tc 8 map 0 1 2 3 4 5 6 7 1 1 1 1 1 1 1 1
>              queues:(0:7) (8:15) (16:23) (24:31) (32:39) (40:47) (48:55) (56:63)
> 
> And usage is,
> 
> # ./tc/tc qdisc add dev eth3 root mqprio help
> Usage: ... mclass [num_tc NUMBER] [map P0 P1...]

mclass?

>                   [offset txq0 txq1 ...] [count cnt0 cnt1 ...] [hw 1|0]

Of course I wrote something similar to this, but I never finished it
off, so thanks.

I don't think it makes sense to require count and offset to be specified
as separate lists.  The arguments could be interleaved but that adds
more opportunity for error.  Since offsets have to be in order and you
generally don't want to have gaps then the offsets could normally be
inferred.  So maybe something like:

	queues cnt0[@txq0] cnt1[@txq1] ...

[...]
> +static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
> +			    char **argv, struct nlmsghdr *n)
> +{
> +	int idx;
> +	struct tc_mqprio_qopt opt = {
> +				     8,
> +				     {0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 1, 1, 3, 3, 3, 3},
> +				     1,
> +				    };

It would be clearer to name the fields being initialised.

[...]
> +int mqprio_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
> +{
> +	int i;
> +	struct tc_mqprio_qopt *qopt;
> +
> +	if (opt == NULL)
> +		return 0;
> +
> +	qopt = RTA_DATA(opt);
> +
> +	fprintf(f, " tc %u map ", qopt->num_tc);
> +	for (i = 0; i <= TC_PRIO_MAX; i++)
> +		fprintf(f, "%d ", qopt->prio_tc_map[i]);
> +	fprintf(f, "\n             queues:");
> +	for (i = 0; i < qopt->num_tc; i++)
> +		fprintf(f, "(%i:%i) ", qopt->offset[i],
> +			qopt->offset[i] + qopt->count[i] - 1);
[...]

Shouldn't this output be consistent with the command-line syntax?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

