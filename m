From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v7 1/2] net: implement mechanism for HW based
 QOS
Date: Fri, 14 Jan 2011 08:01:00 -0800
Message-ID: <4D30733C.30106@intel.com>
References: <20110107224543.19830.74009.stgit@jf-dev1-dcblab> <1294957832.3946.61.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"jarkao2@gmail.com" <jarkao2@gmail.com>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:10335 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757650Ab1ANQB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 11:01:26 -0500
In-Reply-To: <1294957832.3946.61.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/13/2011 2:30 PM, Ben Hutchings wrote:
> I'm actually having a go at implementing this, as a result of which I
> have some more questions:
> 

Nice.

> On Fri, 2011-01-07 at 14:45 -0800, John Fastabend wrote:
> [...]
>> With the mechanism in this patch users can set skb priority using
>> expected methods ie setsockopt() or the stack can set the priority
>> directly. Then the skb will be steered to the correct tx queues
>> aligned with hardware QOS traffic classes. In the normal case with
>> a single traffic class and all queues in this class everything
>> works as is until the LLD enables multiple tcs.
>>
>> To steer the skb we mask out the lower 4 bits of the priority
>> and allow the hardware to configure upto 15 distinct classes
>> of traffic. This is expected to be sufficient for most applications
>> at any rate it is more then the 8021Q spec designates and is
>> equal to the number of prio bands currently implemented in
>> the default qdisc.
> 
> What is the meaning of a class number?  Is it simply higher number =>
> higher priority?  If there are exactly 8 classes, can they be assumed to
> match the 802.1q priority classes?

The exact meaning will depend on how the hardware is configured. With DCB
configured the class number is going to have a different meaning then when
DCB is disabled. Paring any specific configuration using 'strict priority'
should be expected. This would simply be higher number => higher priority.

Merely having 8 classes should not be assumed to match the 802.1q priority
classes. As soon as you say 802.1q priority classes I expect to see 802.1q
priority tagged frames. This patch doesn't enforce any sort of tagging.
However if you set up 8 traffic classes and built a qos egress map with
'ip link' that matched then this would be fair to say. I intentionally
tried to leave this up to user space policy to configure no reason to try
and enforce configurations IMHO. Notice you could go wrong with this and
create configurations that probably make little sense but again I think this
is a user space problem and at least in the DCB case we can have 'lldpad'
manage this.

By the way defaulting to 'strict priority' is the 802.1Q spec suggestion
for bridges that do not support the credit-based shaper algorithm. And the
default mapping for 8 traffic classes is priorities map 1:1 with classes
so this all lines up to get what you assumed.

> 
>> This in conjunction with a userspace application such as
>> lldpad can be used to implement 8021Q transmission selection
>> algorithms one of these algorithms being the extended transmission
>> selection algorithm currently being used for DCB.
> 
> Should an Ethernet driver/hardware insert a 802.1q priority tag if it
> implements this, or should that be left to higher levels?

I am not so sure about this. I tend to like using the mechanisms already
in place, the egress qos mapping, to add 802.1q priority tag. But it looks
like some drivers add the tags explicitly. And also there appears to be
some expectation that the 802.1q priority tag is added to all packets even
those sent on non-vlan devices at least in the DCB case.

> 
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>
>>  include/linux/netdevice.h |   65 +++++++++++++++++++++++++++++++++++++++++++++
>>  net/core/dev.c            |   61 ++++++++++++++++++++++++++++++++++++++++++
>>  2 files changed, 125 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 0f6b1c9..b1dbbed 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
> [...]
>> @@ -756,6 +764,7 @@ struct xps_dev_maps {
>>   * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
>>   *			  struct nlattr *port[]);
>>   * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
>> + * void (*ndo_setup_tc)(struct net_device *dev, u8 tc, unsigned int txq)
> [...]
> 
> This is not documentation, it is just repetition!
> 

Point taken. It does seem to be the trend though.

> Please specify what the parameters mean.  In particular, what is the
> purpose of the txq parameter; can it be different from
> dev->real_num_tx_queues?

'tc' is the number of traffic classes to enable and 'txq' is the number
of queues in use. This should be dev->real_num_tx_queues except when
called from netif_set_real_num_tx_queues where the new number of queues
is used. This is done to prevent steering skb's to rings that may no
longer exist.

> 
> Is this operation allowed to change the number of TX queues?  I was
> looking at scaling the number of queues according to the number of
> classes.


As is no. Changing the number of TX queues can't be done cleanly because
calling netif_set_real_num_tx_queues() calls ndo_tc_setup(). I was
expecting other netlink messages would change the tx queue numbers.

However I think I like this better... In order to make this possible
I can remove the ndo_tc_setup() call from netif_set_real_num_tc_queues().
Then the 'txq' param can be removed making this call a bit neater as well.
The downside of this is drivers will need to ensure that calling
netif_set_real_num_tx_queues() will not break the mapping otherwise
the mapping gets invalidated. I'll have to see but this might be OK.

Thanks,
John.


> 
> Ben.
> 

