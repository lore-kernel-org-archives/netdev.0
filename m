From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH 4/4] bridge: make hw offload conditional on bridge
 and bridge port offload flags
Date: Fri, 21 Nov 2014 16:33:42 -0800
Message-ID: <546FD9E6.6080205@cumulusnetworks.com>
References: <1416610170-21224-5-git-send-email-roopa@cumulusnetworks.com> <20141121233054.GB20810@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	gospo@cumulusnetworks.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:52874 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbaKVAds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 19:33:48 -0500
In-Reply-To: <20141121233054.GB20810@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/14, 3:30 PM, Thomas Graf wrote:
> On 11/21/14 at 02:49pm, roopa@cumulusnetworks.com wrote:
>> +	    nla_put_u8(skb, IFLA_BRPORT_GUARD,
>> +		           br_get_port_flag(p, IFLA_BRPORT_GUARD, BR_BPDU_GUARD)) ||
> A helper taking nla_put_br_flag(port, skb, attrtype, brflag) would simplify
> this code a lot.
sure
>
>> @@ -305,7 +312,9 @@ static int br_set_port_state(struct net_bridge_port *p, u8 state)
>>   
>>   	br_set_state(p, state);
>>   	br_log_state(p);
>> -	netdev_sw_port_stp_update(p->dev, p->state);
>> +
>> +	if (BR_HW_OFFLOAD(p->br))
>> +	    netdev_sw_port_set_attr(p->dev, IFLA_BRPORT_STATE, &p->state);
> I assume the yet unfinished netdev_sw_port_set_attr() will call
> netdev_sw_port_stp_update()?

netdev_sw_port_set_attr will just call the switch driver ndo for bridge port attributes. (ndo_sw_bridge_port_set_attr()).
On that note it would be nice to rename the whole thing  (the other thread on "sw" vs "offload"), this could be
renamed to netdev_offload_bridge_port_set_attr() or something along those lines.

>
>> @@ -316,13 +325,34 @@ static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
>>   {
>>   	if (tb[attrtype]) {
>>   		u8 flag = nla_get_u8(tb[attrtype]);
>> -		if (flag)
>> -			p->flags |= mask;
>> -		else
>> +		if (flag) {
>> +			flag_upper = flag & 0xf0
>> +			if (!flag_upper || (flag_upper & BRPORT_KERNEL))
>> +				p->flags |= mask;
>> +			if ((flag_upper & BRPORT_HW_OFFLOAD) ||
>> +				(BR_HW_OFFLOAD(p->br)))
>> +				/* Also set the port flag in hw */
>> +			netdev_sw_port_set_attr(p->dev, attrtype, 1);
> I'm not sure I understand the || here. HW_OFFLOAD enabled on the
> net_device is a conditional for all netdev_sw_port_set_attr() calls
> and at the same time implies BRPORT_HW_OFFLOAD on all attributes.

Just realized this needs another condition, I will fix it.

The idea is, the port attribute flags BRPORT_KERNEL and BRPORT_HW_OFFLOAD
can be used to override the HW_OFFLOAD flag on the bridge netdev.

You will only call the swdev api to offload the bridge port flag,
if the bridge netdev has the HW_OFFLOAD flag set and also the per port 
attribute flag
does not override it.

> As I read this code now, I don't see how you would offload individual
> features to hardware.


This is for offloading individual bridge port flags like learning and 
flooding.

You want to be able to HW_OFFLOAD the bridge device, but be able to 
control offloading of some of the port flags
like learning and flooding. For example some of the realtek devices 
might want to turn learning in hw off by default
but learn in software.

>
>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>> index 8f3f081..3ebd196 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -41,6 +41,8 @@
>>   /* Path to usermode spanning tree program */
>>   #define BR_STP_PROG	"/sbin/bridge-stp"
>>   
>> +#define BR_HW_OFFLOAD(br) !!(br->dev->features & NETIF_F_HW_OFFLOAD)
> Let's not add more non type safe macros. A static inline seems like
> a better fit here.
sure, ack.

Thanks for the review.
