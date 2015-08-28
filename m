From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC V2 2/2] net: Optimize snmp stat aggregation by walking
 all the percpu data at once
Date: Fri, 28 Aug 2015 12:09:52 +0530
Message-ID: <55E00238.10909@linux.vnet.ibm.com>
References: <y> <1440610653-14210-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <1440610653-14210-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20150827.113823.214019265460582055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jiri@resnulli.us, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	serge.hallyn@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, anton@au1.ibm.com,
	nacc@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>, edumazet@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150827.113823.214019265460582055.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/28/2015 12:08 AM, David Miller wrote:
> From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> Date: Wed, 26 Aug 2015 23:07:33 +0530
>
>> @@ -4641,10 +4647,12 @@ static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
>>   static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
>>   			     int bytes)
>>   {
>> +	u64 buff[IPSTATS_MIB_MAX] = {0,};
>> +
>>   	switch (attrtype) {
>>   	case IFLA_INET6_STATS:
>> -		__snmp6_fill_stats64(stats, idev->stats.ipv6,
>
> I would suggest using an explicit memset() here, it makes the overhead incurred
> by this scheme clearer.
>

I changed the code to look like below to measure fill_stat overhead:

container creation now took: 3.012s
it was:
without patch     : 6.86sec
with current patch: 3.34sec

and perf did not show the snmp6_fill_stats() parent traces.

changed code:
snmp6_fill_stats(...)
{
         switch (attrtype) {
         case IFLA_INET6_STATS:
                 put_unaligned(IPSTATS_MIB_MAX, &stats[0]);
                 memset(&stats[1], 0, IPSTATS_MIB_MAX-1);

                 //__snmp6_fill_stats64(stats, idev->stats.ipv6, 
IPSTATS_MIB_MAX, bytes,
                 //                   offsetof(struct ipstats_mib, 
syncp), buff);
.....
}

So in summary:
The current patch amounts to reduction in major overhead in fill_stat,
though there is still percpu walk overhead (0.33sec difference).

[ percpu walk overead grows when create for e.g. 3k containers].

cache miss: there was no major difference (around 1.4%) w.r.t patch

Hi David,
hope you wanted to know the overhead than to change the current patch. 
please let me know..

Eric, does V2 patch look good now.. please add your ack/review

Details:
time
=========================
time docker run -itd  ubuntu:15.04  /bin/bash
b6670c321b5957f004e281cbb14512deafd0c0be6a39707c2f3dc95649bbc394

real	0m3.012s
user	0m0.093s
sys	0m0.009s

perf:
==========
# Samples: 18K of event 'cycles'
# Event count (approx.): 12838752009
# Overhead  Command          Shared Object          Symbol 

# ........  ...............  .....................  ............
#
     15.29%  swapper          [kernel.kallsyms]      [k] snooze_loop 

      9.37%  docker           docker                 [.] scanblock 

      6.47%  docker           [kernel.kallsyms]      [k] veth_stats_one 

      3.87%  swapper          [kernel.kallsyms]      [k] _raw_spin_lock 

      2.71%  docker           docker                 [.]
