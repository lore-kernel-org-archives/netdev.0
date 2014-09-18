From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net v2] bonding: fix div by zero while enslaving and transmitting
Date: Thu, 18 Sep 2014 18:59:30 +0800
Message-ID: <541ABB12.3070901@huawei.com>
References: <5413097B.9080802@redhat.com> <1410536298-8022-1-git-send-email-nikolay@redhat.com> <541926EB.4010809@huawei.com> <54196BA3.4020505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:51391 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755203AbaIRK7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 06:59:49 -0400
In-Reply-To: <54196BA3.4020505@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/9/17 19:08, Nikolay Aleksandrov wrote:
> On 17/09/14 08:15, Ding Tianhong wrote:
>> On 2014/9/12 23:38, Nikolay Aleksandrov wrote:
>>> The problem is that the slave is first linked and slave_cnt is
>>> incremented afterwards leading to a div by zero in the modes that use it
>>> as a modulus. What happens is that in bond_start_xmit()
>>> bond_has_slaves() is used to evaluate further transmission and it becomes
>>> true after the slave is linked in, but when slave_cnt is used in the xmit
>>> path it is still 0, so fetch it once and transmit based on that. Since
>>> it is used only in round-robin and XOR modes, the fix is only for them.
>>> Thanks to Eric Dumazet for pointing out the fault in my first try to fix
>>> this.
>>>
>>
>> Hi, I think no need to add more checks in the xmit fast path, why not add a barrier to make
>> sure the slave_cnt inc to 1 before access it.
>>
>> +    /* Increment slave_cnt before linking in the slave so we won't end up in
>> +     * bond_start_xmit with bond_has_slaves() true and slave_cnt == 0.
>> +     */
>> +    bond->slave_cnt++;
>> +    wmb();
>>
>> I think it looks more efficiency, sorry for reply so late.
>>
>> Regards
>> Ding
>>
>>
> 
> Hi Ding,
> You should re-read Eric's comment to my first fix. In my first attempt I moved the increment before the slave linking which does rcu_assign_pointer() which implies a full memory barrier, IIRC. The issue is that this fixes the writer side and makes sure the increment is visible before linking the slave, but I missed that on the reader side (bond_start_xmit()) we don't have any barriers, so the CPU is free to do whatever it likes with the access to slave_cnt F.e. it can fetch it before the slave list.
> Now, this fix shouldn't be felt much performance-wise since the likely() hint will be correct 99% of the time because the situation where slave_cnt is not in sync is only in a very short period of time while enslaving and releasing slaves. If you'd like to further remove this one check - you could. You can fetch slave_cnt only once in bond_start_xmit() and use that as a check for further transmitting instead of empty slave list but you must pass down the fetched value to the xmitting functions, that is you should not re-fetch it, so it'd probably require you to add additional parameter to all modes' xmit functions so you can pass it down from bond_start_xmit(). Since only 2 modes actually use slave_cnt I don't think that is necessary.
> In any case net should be merged with net-next first.
> 
> Cheers,
>  Nik
> 

Hi Nik:

Thanks for your explanation, I got it, I need to think more about it, thanks.

Ding
> 
> 
> .
> 
