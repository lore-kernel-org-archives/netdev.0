From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v6 2/2] net_sched: implement a root container
 qdisc sch_mqprio
Date: Fri, 07 Jan 2011 14:16:25 -0800
Message-ID: <4D2790B9.40203@intel.com>
References: <20110107031211.2446.35715.stgit@jf-dev1-dcblab> <20110107031216.2446.35953.stgit@jf-dev1-dcblab> <20110107212140.GA2050@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42753 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753583Ab1AGWQ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jan 2011 17:16:26 -0500
In-Reply-To: <20110107212140.GA2050@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/7/2011 1:21 PM, Jarek Poplawski wrote:
> On Thu, Jan 06, 2011 at 07:12:16PM -0800, John Fastabend wrote:
>> This implements a mqprio queueing discipline that by default creates
>> a pfifo_fast qdisc per tx queue and provides the needed configuration
>> interface.
>>
>> Using the mqprio qdisc the number of tcs currently in use along
>> with the range of queues alloted to each class can be configured. By
>> default skbs are mapped to traffic classes using the skb priority.
>> This mapping is configurable.
>>
>> Configurable parameters,
>>
>> struct tc_mqprio_qopt {
>>         __u8    num_tc;
>>         __u8    prio_tc_map[TC_BITMASK + 1];
>>         __u8    hw;
>>         __u16   count[TC_MAX_QUEUE];
>>         __u16   offset[TC_MAX_QUEUE];
>> };
>>
>> Here the count/offset pairing give the queue alignment and the
>> prio_tc_map gives the mapping from skb->priority to tc.
>>
>> The hw bit determines if the hardware should configure the count
>> and offset values. If the hardware bit is set then the operation
>> will fail if the hardware does not implement the ndo_setup_tc
>> operation. This is to avoid undetermined states where the hardware
>> may or may not control the queue mapping. Also minimal bounds
>> checking is done on the count/offset to verify a queue does not
>> exceed num_tx_queues and that queue ranges do not overlap. Otherwise
>> it is left to user policy or hardware configuration to create
>> useful mappings.
>>
>> It is expected that hardware QOS schemes can be implemented by
>> creating appropriate mappings of queues in ndo_tc_setup().
>>
>> One expected use case is drivers will use the ndo_setup_tc to map
>> queue ranges onto 802.1Q traffic classes. This provides a generic
>> mechanism to map network traffic onto these traffic classes and
>> removes the need for lower layer drivers to know specifics about
>> traffic types.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>
>>  include/linux/pkt_sched.h |   12 +
>>  net/sched/Kconfig         |   12 +
>>  net/sched/Makefile        |    1 
>>  net/sched/sch_generic.c   |    4 
>>  net/sched/sch_mqprio.c    |  415 +++++++++++++++++++++++++++++++++++++++++++++
>>  5 files changed, 444 insertions(+), 0 deletions(-)
>>  create mode 100644 net/sched/sch_mqprio.c
>>
>> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
>> index 2cfa4bc..776cd93 100644
>> --- a/include/linux/pkt_sched.h
>> +++ b/include/linux/pkt_sched.h
>> @@ -481,4 +481,16 @@ struct tc_drr_stats {
>>  	__u32	deficit;
>>  };
>>  
>> +/* MQPRIO */
>> +#define TC_QOPT_BITMASK 15
>> +#define TC_QOPT_MAX_QUEUE 16
>> +
>> +struct tc_mqprio_qopt {
>> +	__u8	num_tc;
>> +	__u8	prio_tc_map[TC_QOPT_BITMASK + 1];
>> +	__u8	hw;
>> +	__u16	count[TC_QOPT_MAX_QUEUE];
>> +	__u16	offset[TC_QOPT_MAX_QUEUE];
>> +};
> 
> ...
>> +static int mqprio_parse_opt(struct net_device *dev, struct tc_mqprio_qopt *qopt)
>> +{
>> +	int i, j;
>> +
>> +	/* Verify num_tc is not out of max range */
>> +	if (qopt->num_tc > TC_QOPT_MAX_QUEUE)
> 
> If these TC_QOPTs really couldn't be avoided you should probably check
> them with BUILD_BUG_ON() but use only TC_MAX_QUEUE/TC_BITMASK
> everywhere. Otherwise, it looks OK to me.
> 
> Jarek P.

I couldn't think of any better way. I'll add the BUILD_BUG_ON() macros.

Thanks 
John
