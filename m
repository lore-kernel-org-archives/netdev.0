From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 2/2] net: Optimize snmp stat aggregation by walking
 all the percpu data at once
Date: Tue, 25 Aug 2015 21:17:18 +0530
Message-ID: <55DC8E06.2040007@linux.vnet.ibm.com>
References: <y> <1440489266-31127-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <1440489266-31127-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <1440512908.8932.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, jiri@resnulli.us,
	edumazet@google.com, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	anton@au1.ibm.com, nacc@linux.vnet.ibm.com,
	srikar@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440512908.8932.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/25/2015 07:58 PM, Eric Dumazet wrote:
> On Tue, 2015-08-25 at 13:24 +0530, Raghavendra K T wrote:
>> Docker container creation linearly increased from around 1.6 sec to 7.5 sec
>> (at 1000 containers) and perf data showed 50% ovehead in snmp_fold_field.
>>
>> reason: currently __snmp6_fill_stats64 calls snmp_fold_field that walks
>> through per cpu data of an item (iteratively for around 90 items).
>>
>> idea: This patch tries to aggregate the statistics by going through
>> all the items of each cpu sequentially which is reducing cache
>> misses.
>>
>> Docker creation got faster by more than 2x after the patch.
>>
>> Result:
>>                         Before           After
>> Docker creation time   6.836s           3.357s
>> cache miss             2.7%             1.38%
>>
>> perf before:
>>      50.73%  docker           [kernel.kallsyms]       [k] snmp_fold_field
>>       9.07%  swapper          [kernel.kallsyms]       [k] snooze_loop
>>       3.49%  docker           [kernel.kallsyms]       [k] veth_stats_one
>>       2.85%  swapper          [kernel.kallsyms]       [k] _raw_spin_lock
>>
>> perf after:
>>      10.56%  swapper          [kernel.kallsyms]     [k] snooze_loop
>>       8.72%  docker           [kernel.kallsyms]     [k] snmp_get_cpu_field
>>       7.59%  docker           [kernel.kallsyms]     [k] veth_stats_one
>>       3.65%  swapper          [kernel.kallsyms]     [k] _raw_spin_lock
>>
>> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
>> ---
>>   net/ipv6/addrconf.c | 14 +++++++++++---
>>   1 file changed, 11 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 21c2c81..2ec905f 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -4624,16 +4624,24 @@ static inline void __snmp6_fill_statsdev(u64 *stats, atomic_long_t *mib,
>>   }
>>
>>   static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
>> -				      int items, int bytes, size_t syncpoff)
>> +					int items, int bytes, size_t syncpoff)
>>   {
>> -	int i;
>> +	int i, c;
>> +	u64 *tmp;
>>   	int pad = bytes - sizeof(u64) * items;
>>   	BUG_ON(pad < 0);
>>
>> +	tmp = kcalloc(items, sizeof(u64), GFP_KERNEL);
>> +
>
>
> This is a great idea, but kcalloc()/kmalloc() can fail and you'll crash
> the whole kernel at this point.
>

Good catch, and my bad. Though system is in bad memory condition,
since fill_stat is not critical for the system do you think silently
returning from here is a good idea?
or do you think we should handle with -ENOMEM way up.?
