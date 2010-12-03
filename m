From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH v1] iproute2: add IFLA_TC support to 'ip link'
Date: Fri, 03 Dec 2010 06:06:52 -0500
Message-ID: <1291374412.10126.17.camel@mojatatu>
References: <20101201182758.3297.34345.stgit@jf-dev1-dcblab>
	 <1291286428.2183.494.camel@mojatatu>  <4CF7F8B4.4060807@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:33360 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755508Ab0LCLG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 06:06:59 -0500
Received: by gxk1 with SMTP id 1so1747149gxk.19
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 03:06:58 -0800 (PST)
In-Reply-To: <4CF7F8B4.4060807@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-02 at 11:51 -0800, John Fastabend wrote:
> On 12/2/2010 2:40 AM, jamal wrote:


> I viewed the HW QOS as L2 link attributes more than a queuing discipline per se.
> Plus 'ip link' is already used to set things outside of ip. 
> For example 'txqueuelen' and 'vf x'.

the vf one maybe borderline-ok txquelen is probably inherited from
ifconfig (and not sure a single queue a scheduler qualifies)


> However thinking about this a bit more qdisc support seems cleaner. 
> For one we can configure QOS policies per class with Qdisc_class_ops. 
> And then also aggregate statistics with dump_stats. I would avoid the 
> "hardware-kinda-8021q-sched" name though to account for schedulers that 
> may not be 802.1Q compliant maybe 'mclass-sched' for multi-class scheduler. 

Typically the scheduler would be a very familiar one implemented
per-spec by many vendors and will have a name acceptable by all.
So pick an appropriate noun so the user expectation matches it.

> I'll look into this. Thanks for the suggestion!

> 
> On egress the skb priority is mapped to a class which is associated with a
> range of queues (qoffset:qoffset + qcount). 
> In the 802.1Q case this queue range is mapped to the 802.1Qp 
> traffic class in hardware. So the hardware traffic class is mapped 1-1 
> with the software class. Additionally in software the VLAN egress mapping
> is used to map the skb priority to the 802.1Q priority. Here I expect user
> policies to configure this to get a consistent mapping. On ingress the 
> skb priority is set using the 802.1Q ingress mapping. This case is 
> something a userspace policy could configure if egress/ingress mappings
> should be symmetric.
> 

Sounds sensible. 

> In the simpler case of hardware rate limiting (not 802.1Q) this is not
> really a concern at all. With this mechanism we can identify traffic 
> and push it to the correct queues that are grouped into a rate limited class.

Ok, so you can do rate control as well?

> If there are egress/ingress mappings then those will apply skb priority tags 
> on egress and the correct skb priority on ingress.

Curious how you would do this in a rate controlled environment. EX: on
egress, do you use whatever skb prio you get to map to a specific rate
queue in h/ware? Note: skb prio has a strict priority scheduling
semantics so a 1-1 mapping doesnt sound reasonable..

> Currently everything works reasonably well with this scheme and the mq qdisc.
>  The mq qdisc uses pfifo and the driver then pauses the queues as needed. 
> Using the enhanced transmission selection algorithm (ETS - 802.1Qaz pre-standard)
>  in hardware we see variations from expected bandwidth around +-5% with TCP/UDP. 
> Instrumenting HW rate limiters gives similar variations. I tested this is with 
> ixgbe and the 82599 device.
> 
> Bit long winded but hopefully that answers your question.

I am curious about the rate based scheme - and i hope you are looking at
a different qdisc for that?

cheers,
jamal

