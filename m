From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] iproute2: tc add mqprio qdisc support
Date: Wed, 13 Apr 2011 16:37:40 -0700
Message-ID: <4DA633C4.9080906@intel.com>
References: <20110412155727.4656.42756.stgit@jf-dev1-dcblab> <1302736222.2873.39.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48496 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757056Ab1DMXhl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 19:37:41 -0400
In-Reply-To: <1302736222.2873.39.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/2011 4:10 PM, Ben Hutchings wrote:
> I know that this has already been applied, but:
> 
> On Tue, 2011-04-12 at 08:57 -0700, John Fastabend wrote:
>> Add mqprio qdisc support. Output matches the following,
>>
>> # ./tc/tc qdisc
>> qdisc mq 0: dev eth1 root
>> qdisc mq 0: dev eth2 root
>> qdisc mqprio 8001: dev eth3 root  tc 8 map 0 1 2 3 4 5 6 7 1 1 1 1 1 1 1 1
>>              queues:(0:7) (8:15) (16:23) (24:31) (32:39) (40:47) (48:55) (56:63)
>>
>> And usage is,
>>
>> # ./tc/tc qdisc add dev eth3 root mqprio help
>> Usage: ... mclass [num_tc NUMBER] [map P0 P1...]
> 
> mclass?

agh stupid typo in the description that was my working name
for the qdisc some time ago. The help in 'tc' is correct.

> 
>>                   [offset txq0 txq1 ...] [count cnt0 cnt1 ...] [hw 1|0]
> 
> Of course I wrote something similar to this, but I never finished it
> off, so thanks.
> 
> I don't think it makes sense to require count and offset to be specified
> as separate lists.  The arguments could be interleaved but that adds
> more opportunity for error.  Since offsets have to be in order and you
> generally don't want to have gaps then the offsets could normally be
> inferred.  So maybe something like:
> 
> 	queues cnt0[@txq0] cnt1[@txq1] ...

OK. I agree with you this is better.

> 
> [...]
>> +static int mqprio_parse_opt(struct qdisc_util *qu, int argc,
>> +			    char **argv, struct nlmsghdr *n)
>> +{
>> +	int idx;
>> +	struct tc_mqprio_qopt opt = {
>> +				     8,
>> +				     {0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 1, 1, 3, 3, 3, 3},
>> +				     1,
>> +				    };
> 
> It would be clearer to name the fields being initialised.
> 

OK.

> [...]
>> +int mqprio_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
>> +{
>> +	int i;
>> +	struct tc_mqprio_qopt *qopt;
>> +
>> +	if (opt == NULL)
>> +		return 0;
>> +
>> +	qopt = RTA_DATA(opt);
>> +
>> +	fprintf(f, " tc %u map ", qopt->num_tc);
>> +	for (i = 0; i <= TC_PRIO_MAX; i++)
>> +		fprintf(f, "%d ", qopt->prio_tc_map[i]);
>> +	fprintf(f, "\n             queues:");
>> +	for (i = 0; i < qopt->num_tc; i++)
>> +		fprintf(f, "(%i:%i) ", qopt->offset[i],
>> +			qopt->offset[i] + qopt->count[i] - 1);
> [...]
> 
> Shouldn't this output be consistent with the command-line syntax?

I'm not sure, here's what it is now,

queues:(0:7) (8:15) (16:23) (24:31) (32:39) (40:47) (48:55) (56:63)

And here's what it would be with the change,

queues: 8@0 8@8 8@16 8@24 8@32 8@40 8@48 8@56

I like the first option with (#:#) it seems a bit more obvious to me
what the layout is. I'll get this fixed up tomorrow. Thanks for
taking a look Ben.

~John.

