From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v1] iproute2: add IFLA_TC support to 'ip link'
Date: Thu, 02 Dec 2010 11:51:16 -0800
Message-ID: <4CF7F8B4.4060807@intel.com>
References: <20101201182758.3297.34345.stgit@jf-dev1-dcblab> <1291286428.2183.494.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "hadi@cyberus.ca" <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51043 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757178Ab0LBTvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 14:51:17 -0500
In-Reply-To: <1291286428.2183.494.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/2/2010 2:40 AM, jamal wrote:
> On Wed, 2010-12-01 at 10:27 -0800, John Fastabend wrote:
>> Add support to return IFLA_TC qos settings to the 'ip link'
>> command. The following sets the number of traffic classes
>> supported in HW and builds a priority map.
>>
>> #ip link set eth3 tc num 8 map 0 1 2 3 4 5 6 7 0 0 0 0 0 0 0 0
>>
>> With the output from 'ip link' showing maps for interfaces with
>> the ability to use HW traffic classes.
> 
> 2 comments apply to the kernel patches as well - but easier to point
> out here.
> 
> 1) IMO, this looks like the wrong interface to use. 
> Was there any reason not to use tc and instead having it show
> itself embedded within "ip" abstraction? 
> Example, this would suit your intent:
> tc qdisc add dev eth3 hware-kinda-8021q-sched num 8 map blah bleh
> 

I viewed the HW QOS as L2 link attributes more than a queuing discipline per se. Plus 'ip link' is already used to set things outside of ip. For example 'txqueuelen' and 'vf x'.

> You can then modify individual classes of traffic with "tc class".
> 
> [There are plenty of other chips (switching chips for example) that
> implement a variety different hardware schedulers, hence the
> "hardware-kinda-8021q-sched" above]

However thinking about this a bit more qdisc support seems cleaner. For one we can configure QOS policies per class with Qdisc_class_ops. And then also aggregate statistics with dump_stats. I would avoid the "hardware-kinda-8021q-sched" name though to account for schedulers that may not be 802.1Q compliant maybe 'mclass-sched' for multi-class scheduler. I'll look into this. Thanks for the suggestion!

> 
> 2) How does this mapping in hardware correlate to the software side
> mapping? When packets of class X make it off the hardware and hit
> the stack are they still going to get the same treatment as they
> would have in h/ware?
>

On egress the skb priority is mapped to a class which is associated with a range of queues (qoffset:qoffset + qcount). In the 802.1Q case this queue range is mapped to the 802.1Qp traffic class in hardware. So the hardware traffic class is mapped 1-1 with the software class. Additionally in software the VLAN egress mapping is used to map the skb priority to the 802.1Q priority. Here I expect user policies to configure this to get a consistent mapping. On ingress the skb priority is set using the 802.1Q ingress mapping. This case is something a userspace policy could configure if egress/ingress mappings should be symmetric.

In the simpler case of hardware rate limiting (not 802.1Q) this is not really a concern at all. With this mechanism we can identify traffic and push it to the correct queues that are grouped into a rate limited class. If there are egress/ingress mappings then those will apply skb priority tags on egress and the correct skb priority on ingress.

Currently everything works reasonably well with this scheme and the mq qdisc. The mq qdisc uses pfifo and the driver then pauses the queues as needed. Using the enhanced transmission selection algorithm (ETS - 802.1Qaz pre-standard) in hardware we see variations from expected bandwidth around +-5% with TCP/UDP. Instrumenting HW rate limiters gives similar variations. I tested this is with ixgbe and the 82599 device.

Bit long winded but hopefully that answers your question.

> 
> cheers,
> jamal
> 

