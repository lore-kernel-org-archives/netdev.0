From: Rongqing Li <rongqing.li@windriver.com>
Subject: Re: [PATCH net-next] ipv6: fix the use of pcpu_tstats in ip6_tunnel
Date: Thu, 2 Jan 2014 12:41:02 +0800
Message-ID: <52C4EDDE.9000303@windriver.com>
References: <1388623780-1484-1-git-send-email-roy.qing.li@gmail.com> <20140101.225033.1351962333260167430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roy.qing.li@gmail.com>, <netdev@vger.kernel.org>,
	<edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:32992 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbaABElA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 23:41:00 -0500
In-Reply-To: <20140101.225033.1351962333260167430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/02/2014 11:50 AM, David Miller wrote:
> From: roy.qing.li@gmail.com
> Date: Thu,  2 Jan 2014 08:49:40 +0800
>
>> Eric Dumazet <edumazet@google.com>
>
> What is this?

Sorry, it should CC to Eric Dumazet

>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>   ...
>>   {
>> -	struct pcpu_tstats sum = { 0 };
>> +	struct pcpu_tstats tmp, sum = { 0 };
>>   	int i;
>>
>> -	for_each_possible_cpu(i) {
>> -		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
>> +	BUILD_BUG_ON(offsetof(typeof(tmp), syncp) !=
>> +		     sizeof(tmp) - sizeof(tmp.syncp));
>>
>> -		sum.rx_packets += tstats->rx_packets;
>> -		sum.rx_bytes   += tstats->rx_bytes;
>> -		sum.tx_packets += tstats->tx_packets;
>> -		sum.tx_bytes   += tstats->tx_bytes;
>> +	for_each_possible_cpu(i) {
>> +		unsigned int start;
>> +		const struct pcpu_tstats *stat = per_cpu_ptr(dev->tstats, i);
>> +
>> +		do {
>> +			start = u64_stats_fetch_begin_bh(&stat->syncp);
>> +			memcpy(&tmp, stat, sizeof(tmp) - sizeof(stat->syncp));
>> +		} while (u64_stats_fetch_retry_bh(&stat->syncp, start));
>
> It's entirely wasteful and non-canonical to use an on-stack copy for this,
> just surround the entire set of statistic increments within the u64 stats
> updata sequence.  Then you don't need the on-stack thing.
>

Ok, I see.

Thanks

-Roy


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

-- 
Best Reagrds,
Roy | RongQing Li
