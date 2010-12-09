From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v1] iproute2: add IFLA_TC support to 'ip link'
Date: Thu, 09 Dec 2010 11:58:04 -0800
Message-ID: <4D0134CC.8070605@intel.com>
References: <20101201182758.3297.34345.stgit@jf-dev1-dcblab>	 <1291286428.2183.494.camel@mojatatu>  <4CF7F8B4.4060807@intel.com> <1291374412.10126.17.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "hadi@cyberus.ca" <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11555 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920Ab0LIT6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 14:58:06 -0500
In-Reply-To: <1291374412.10126.17.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/3/2010 3:06 AM, jamal wrote:
> On Thu, 2010-12-02 at 11:51 -0800, John Fastabend wrote:
>> On 12/2/2010 2:40 AM, jamal wrote:
> 
> 
>> I viewed the HW QOS as L2 link attributes more than a queuing discipline per se.
>> Plus 'ip link' is already used to set things outside of ip. 
>> For example 'txqueuelen' and 'vf x'.
> 
> the vf one maybe borderline-ok txquelen is probably inherited from
> ifconfig (and not sure a single queue a scheduler qualifies)
> 
> 
>> However thinking about this a bit more qdisc support seems cleaner. 
>> For one we can configure QOS policies per class with Qdisc_class_ops. 
>> And then also aggregate statistics with dump_stats. I would avoid the 
>> "hardware-kinda-8021q-sched" name though to account for schedulers that 
>> may not be 802.1Q compliant maybe 'mclass-sched' for multi-class scheduler. 
> 
> Typically the scheduler would be a very familiar one implemented
> per-spec by many vendors and will have a name acceptable by all.
> So pick an appropriate noun so the user expectation matches it.
> 

I think what we really want is a container to create groups of tx queues which can then be managed and given a scheduler. One reason for this is the 802.1Q spec allows for different schedulers to be running on different traffic classes including vendor specific schedulers. So having a root "hardware-kinda-8021q-sched" doesn't seem flexible enough to handle adding/removing schedulers per traffic class.

With a container qdisc statistics roll up nicely as expected and the default scheduler can be the usual mq qdisc.

A first take at this coming shortly. Any thoughts?

>> I'll look into this. Thanks for the suggestion!
> 
>>
>> On egress the skb priority is mapped to a class which is associated with a
>> range of queues (qoffset:qoffset + qcount). 
>> In the 802.1Q case this queue range is mapped to the 802.1Qp 
>> traffic class in hardware. So the hardware traffic class is mapped 1-1 
>> with the software class. Additionally in software the VLAN egress mapping
>> is used to map the skb priority to the 802.1Q priority. Here I expect user
>> policies to configure this to get a consistent mapping. On ingress the 
>> skb priority is set using the 802.1Q ingress mapping. This case is 
>> something a userspace policy could configure if egress/ingress mappings
>> should be symmetric.
>>
> 
> Sounds sensible. 
> 
>> In the simpler case of hardware rate limiting (not 802.1Q) this is not
>> really a concern at all. With this mechanism we can identify traffic 
>> and push it to the correct queues that are grouped into a rate limited class.
> 
> Ok, so you can do rate control as well?
> 

Yes, but per tx_ring. So software needs to then balance the rings into an aggregated rate limiter. Using the container scheme I imagine a root mclass qdisc with multiple "sch_rate_limiter" qdiscs. This qdisc could manage the individual rate limiters per queue and get something like a rate limiter per groups of tx queues.

>> If there are egress/ingress mappings then those will apply skb priority tags 
>> on egress and the correct skb priority on ingress.
> 
> Curious how you would do this in a rate controlled environment. EX: on
> egress, do you use whatever skb prio you get to map to a specific rate
> queue in h/ware? Note: skb prio has a strict priority scheduling
> semantics so a 1-1 mapping doesnt sound reasonable..

Yes this is how I would expect this to work. The prio mapping is configurable so I think this could be worked around by policy in tc. iproute2 would need to pick a reasonable default mapping.

Warning thinking out loud here but maybe we could also add a qdisc op to pick the underlying tx queue basically a qdisc ops for dev_pick_tx(). This ops could be part of the root qdisc and called in dev_queue_xmit(). I would need to think about this some more to see if it is sane but bottom line is the tx queue needs to be learned before __dev_xmit_skb(). The default mechanism in this patch set being the skb prio.

> 
>> Currently everything works reasonably well with this scheme and the mq qdisc.
>>  The mq qdisc uses pfifo and the driver then pauses the queues as needed. 
>> Using the enhanced transmission selection algorithm (ETS - 802.1Qaz pre-standard)
>>  in hardware we see variations from expected bandwidth around +-5% with TCP/UDP. 
>> Instrumenting HW rate limiters gives similar variations. I tested this is with 
>> ixgbe and the 82599 device.
>>
>> Bit long winded but hopefully that answers your question.
> 
> I am curious about the rate based scheme - and i hope you are looking at
> a different qdisc for that?

Yes a different qdisc.

Thanks,
John

> 
> cheers,
> jamal
> 
