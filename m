From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH 2/4] net_sched: Allow multiple mq qdisc to
 be used as non-root
Date: Tue, 21 Dec 2010 11:21:21 -0800
Message-ID: <4D10FE31.1050304@intel.com>
References: <20101217153439.12170.39538.stgit@jf-dev1-dcblab>	 <20101217153445.12170.73420.stgit@jf-dev1-dcblab> <1292886762.3055.38.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6492 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493Ab0LUTVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 14:21:23 -0500
In-Reply-To: <1292886762.3055.38.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2010 3:12 PM, Ben Hutchings wrote:
> On Fri, 2010-12-17 at 07:34 -0800, John Fastabend wrote:
> [...]
>> diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
>> index ecc302f..35ed26d 100644
>> --- a/net/sched/sch_mq.c
>> +++ b/net/sched/sch_mq.c
>> @@ -19,17 +19,39 @@
>>  
>>  struct mq_sched {
>>  	struct Qdisc		**qdiscs;
>> +	u8 num_tc;
>>  };
>>  
>> +static void mq_queues(struct net_device *dev, struct Qdisc *sch,
>> +		      unsigned int *count, unsigned int *offset)
>> +{
>> +	struct mq_sched *priv = qdisc_priv(sch);
>> +	if (priv->num_tc) {
>> +		int queue = TC_H_MIN(sch->parent) - 1;
>> +		if (count)
>> +			*count = dev->tc_to_txq[queue].count;
>> +		if (offset)
>> +			*offset = dev->tc_to_txq[queue].offset;
>> +	} else {
>> +		if (count)
>> +			*count = dev->num_tx_queues;
>> +		if (offset)
>> +			*offset = 0;
>> +	}
>> +}
> [...]
> 
> It looks like num_tc will be set even for the root qdisc if the device
> is capable of QoS.  Would mq_queues() behave correctly then, i.e. is the
> queue range for priority 0 required to be [0, dev->num_tx_queues)?

If num_tc is set the mclass qdisc is loaded by default and not the mq qdisc. When mclass is destroyed it sets num_tc to zero. So I believe mq_queues() will behave correctly ie if mq is the root qdisc [0, dev->num_tx_queues) will be used.

> 
> Also it would be neater to return count and offset together as struct
> netdev_tc_txq, rather than through optional out-parameters.  Even better
> would be to cache these in struct mq_sched, if that's possible.
> 

Yes should be possible to embed this in mq_sched.

> Ben.
> 

