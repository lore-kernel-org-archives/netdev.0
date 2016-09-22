From: hejianet <hejianet@gmail.com>
Subject: Re: [RFC PATCH v3 2/7] proc: Reduce cache miss in
 {snmp,netstat}_seq_show
Date: Thu, 22 Sep 2016 13:38:52 +0800
Message-ID: <19ef495f-385d-6d46-ac85-1266ced1c2d9@gmail.com>
References: <1473402842-1987-1-git-send-email-hejianet@gmail.com>
 <1473402842-1987-3-git-send-email-hejianet@gmail.com>
 <20160912185752.GB17689@localhost.localdomain>
 <22d87ec3-608f-fe41-5eb7-fe1104f133dd@gmail.com>
 <20160914115543.GF17689@localhost.localdomain>
 <84aae301-0d00-d953-e6f6-d2d163d1136a@gmail.com>
 <20160921182438.GG9323@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Marcelo <marcelo.leitner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160921182438.GG9323@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 9/22/16 2:24 AM, Marcelo wrote:
> On Thu, Sep 22, 2016 at 12:18:46AM +0800, hejianet wrote:
>> Hi Marcelo
>>
>> sorry for the late, just came back from a vacation.
> Hi, no problem. Hope your batteries are recharged now :-)
>
>> On 9/14/16 7:55 PM, Marcelo wrote:
>>> Hi Jia,
>>>
>>> On Wed, Sep 14, 2016 at 01:58:42PM +0800, hejianet wrote:
>>>> Hi Marcelo
>>>>
>>>>
>>>> On 9/13/16 2:57 AM, Marcelo wrote:
>>>>> On Fri, Sep 09, 2016 at 02:33:57PM +0800, Jia He wrote:
>>>>>> This is to use the generic interface snmp_get_cpu_field{,64}_batch to
>>>>>> aggregate the data by going through all the items of each cpu sequentially.
>>>>>> Then snmp_seq_show and netstat_seq_show are split into 2 parts to avoid build
>>>>>> warning "the frame size" larger than 1024 on s390.
>>>>> Yeah about that, did you test it with stack overflow detection?
>>>>> These arrays can be quite large.
>>>>>
>>>>> One more below..
>>>> Do you think it is acceptable if the stack usage is a little larger than 1024?
>>>> e.g. 1120
>>>> I can't find any other way to reduce the stack usage except use "static" before
>>>> unsigned long buff[TCP_MIB_MAX]
>>>>
>>>> PS. sizeof buff is about TCP_MIB_MAX(116)*8=928
>>>> B.R.
>>> That's pretty much the question. Linux has the option on some archs to
>>> run with 4Kb (4KSTACKS option), so this function alone would be using
>>> 25% of it in this last case. While on x86_64, it uses 16Kb (6538b8ea886e
>>> ("x86_64: expand kernel stack to 16K")).
>>>
>>> Adding static to it is not an option as it actually makes the variable
>>> shared amongst the CPUs (and then you have concurrency issues), plus the
>>> fact that it's always allocated, even while not in use.
>>>
>>> Others here certainly know better than me if it's okay to make such
>>> usage of the stach.
>> What about this patch instead?
>> It is a trade-off. I split the aggregation process into 2 parts, it will
>> increase the cache miss a little bit, but it can reduce the stack usage.
>> After this, stack usage is 672bytes
>> objdump -d vmlinux | ./scripts/checkstack.pl ppc64 | grep seq_show
>> 0xc0000000007f7cc0 netstat_seq_show_tcpext.isra.3 [vmlinux]:672
>>
>> diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
>> index c6ee8a2..cc41590 100644
>> --- a/net/ipv4/proc.c
>> +++ b/net/ipv4/proc.c
>> @@ -486,22 +486,37 @@ static const struct file_operations snmp_seq_fops = {
>>    */
>>   static int netstat_seq_show_tcpext(struct seq_file *seq, void *v)
>>   {
>> -       int i;
>> -       unsigned long buff[LINUX_MIB_MAX];
>> +       int i, c;
>> +       unsigned long buff[LINUX_MIB_MAX/2 + 1];
>>          struct net *net = seq->private;
>>
>> -       memset(buff, 0, sizeof(unsigned long) * LINUX_MIB_MAX);
>> +       memset(buff, 0, sizeof(unsigned long) * (LINUX_MIB_MAX/2 + 1));
>>
>>          seq_puts(seq, "TcpExt:");
>>          for (i = 0; snmp4_net_list[i].name; i++)
>>                  seq_printf(seq, " %s", snmp4_net_list[i].name);
>>
>>          seq_puts(seq, "\nTcpExt:");
>> -       snmp_get_cpu_field_batch(buff, snmp4_net_list,
>> -                                net->mib.net_statistics);
>> -       for (i = 0; snmp4_net_list[i].name; i++)
>> +       for_each_possible_cpu(c) {
>> +               for (i = 0; i < LINUX_MIB_MAX/2; i++)
>> +                       buff[i] += snmp_get_cpu_field(
>> + net->mib.net_statistics,
>> +                                               c, snmp4_net_list[i].entry);
>> +       }
>> +       for (i = 0; i < LINUX_MIB_MAX/2; i++)
>>                  seq_printf(seq, " %lu", buff[i]);
>>
>> +       memset(buff, 0, sizeof(unsigned long) * (LINUX_MIB_MAX/2 + 1));
>> +       for_each_possible_cpu(c) {
>> +               for (i = LINUX_MIB_MAX/2; snmp4_net_list[i].name; i++)
>> +                       buff[i - LINUX_MIB_MAX/2] += snmp_get_cpu_field(
>> +                               net->mib.net_statistics,
>> +                               c,
>> +                               snmp4_net_list[i].entry);
>> +       }
>> +        for (i = LINUX_MIB_MAX/2; snmp4_net_list[i].name; i++)
>> +                seq_printf(seq, " %lu", buff[i - LINUX_MIB_MAX/2]);
>> +
>>          return 0;
>>   }
> Yep, it halves the stack usage, but it doesn't look good heh
>
> But well, you may try to post the patchset (with or without this last
> change, you pick) officially and see how it goes. As you're posting as
> RFC, it's not being evaluated as seriously.
Thanks for the suggestion, I will remove it in future patch version
>
> FWIW, I tested your patches, using your test and /proc/net/snmp file on
> a x86_64 box, Intel(R) Xeon(R) CPU E5-2643 v3.
>
> Before the patches:
>
>   Performance counter stats for './test /proc/net/snmp':
>
>               5.225      cache-misses
>      12.708.673.785      L1-dcache-loads
>       1.288.450.174      L1-dcache-load-misses     #   10,14% of all L1-dcache hits
>       1.271.857.028      LLC-loads
>               4.122      LLC-load-misses           #    0,00% of all LL-cache hits
>
>         9,174936524 seconds time elapsed
>
> After:
>
>   Performance counter stats for './test /proc/net/snmp':
>
>               2.865      cache-misses
>      30.203.883.807      L1-dcache-loads
>       1.215.774.643      L1-dcache-load-misses     #    4,03% of all L1-dcache hits
>       1.181.662.831      LLC-loads
>               2.685      LLC-load-misses           #    0,00% of all LL-cache hits
>
>        13,374445056 seconds time elapsed
>
> Numbers were steady across multiple runs.
>
>    Marcelo
Yes, I guess your X86 machine doesn't have the large cpu number as mine (cpu#=160).
The cache misses rate difference btw before and after this patch will be more
significant if the cpu number is large.

B.R.
Jia
>
>>>>>> +static int netstat_seq_show_ipext(struct seq_file *seq, void *v)
>>>>>> +{
>>>>>> +	int i;
>>>>>> +	u64 buff64[IPSTATS_MIB_MAX];
>>>>>> +	struct net *net = seq->private;
>>>>>>     	seq_puts(seq, "\nIpExt:");
>>>>>>     	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
>>>>>>     		seq_printf(seq, " %s", snmp4_ipextstats_list[i].name);
>>>>>>     	seq_puts(seq, "\nIpExt:");
>>>>> You're missing a memset() call here.
>>> Not sure if you missed this one or not..
>> indeed, thanks
>> B.R.
>> Jia
>>> Thanks,
>>> Marcelo
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
