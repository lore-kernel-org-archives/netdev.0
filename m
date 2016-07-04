From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Re: [PATCH] net: check for NULL net_device in FIB tables
Date: Mon, 4 Jul 2016 21:56:33 +0200
Message-ID: <577ABF71.6020002@oracle.com>
References: <1467636446-6771-1-git-send-email-vegard.nossum@oracle.com>
 <alpine.LFD.2.11.1607042221290.2228@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42113 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507AbcGDT4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 15:56:54 -0400
In-Reply-To: <alpine.LFD.2.11.1607042221290.2228@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/04/2016 09:45 PM, Julian Anastasov wrote:
>
> 	Hello,
>
> On Mon, 4 Jul 2016, Vegard Nossum wrote:
>
>> struct fib_nh->nh_dev can be NULL, so we should check it before calling
>> __in_dev_get_rcu on it.
>>
>> Multiple places seem to want this (and check the return value), so we can
>> add a convenience wrapper for this.
>>
>> This fixes a crash in AF_NETLINK sendmsg().
>>
>> Please double check that I caught all the callers that need the NULL
>> guard.
>
> 	What kind of configuration causes such crash?

It's not very easy to tell, sorry, I was using a netlink fuzzer to find
the crash. But see below, you identified the right bit of code.

>> -		in_dev = __in_dev_get_rtnl(nh->nh_dev);
>> +		in_dev = in_dev_get_rtnl(nh->nh_dev);
>
> 	fib_rebalance can not crash because for multipath
> routes (fib_nhs > 1) all nexthops should have valid nh_dev.
>

Okay, cool.

>>
>>   		if (in_dev &&
>>   		    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
>> @@ -559,7 +559,7 @@ static void fib_rebalance(struct fib_info *fi)
>>   	change_nexthops(fi) {
>>   		int upper_bound;
>>
>> -		in_dev = __in_dev_get_rtnl(nexthop_nh->nh_dev);
>> +		in_dev = in_dev_get_rtnl(nexthop_nh->nh_dev);
>>
>>   		if (nexthop_nh->nh_flags & RTNH_F_DEAD) {
>>   			upper_bound = -1;
>> @@ -1261,7 +1261,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
>>   		    nla_put_u32(skb, RTA_OIF, fi->fib_nh->nh_oif))
>>   			goto nla_put_failure;
>>   		if (fi->fib_nh->nh_flags & RTNH_F_LINKDOWN) {
>> -			in_dev = __in_dev_get_rtnl(fi->fib_nh->nh_dev);
>> +			in_dev = in_dev_get_rtnl(fi->fib_nh->nh_dev);
>
> 	Looks like this is the only place that can crash,
> adding extra cycles to the other places is not good. And this
> can happen only because fib_create_info() allows RTNH_F_LINKDOWN
> to come for routes with error. May be fc_flags should be masked
> there? Or there is another place that sets the flag when nh_dev
> is NULL?

Indeed, this is the (only) place that actually crashed for me.

>
>>   			if (in_dev &&
>>   			    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev))
>>   				rtm->rtm_flags |= RTNH_F_DEAD;
>> @@ -1292,7 +1292,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
>>
>>   			rtnh->rtnh_flags = nh->nh_flags & 0xFF;
>>   			if (nh->nh_flags & RTNH_F_LINKDOWN) {
>> -				in_dev = __in_dev_get_rtnl(nh->nh_dev);
>> +				in_dev = in_dev_get_rtnl(nh->nh_dev);
>
> 	Not needed because fib_nhs > 1
>

Alright.

Thanks for the review! I can submit a new patch to only check the one
place above that actually crashed. Otherwise, if you think it's better
to go with your fc_flags suggestion, feel free to send a patch for that.
As you can tell, I am not very familiar with this code :-) If you do
send a patch, I can test it easily.


Vegard
