From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] rps: selective flow shedding during softnet overflow
Date: Mon, 22 Apr 2013 16:40:24 -0400
Message-ID: <CA+FuTSfyo5YdtLpyXPawYoppM7zj5cp1_k1hD7+qWL6DUpNd4Q@mail.gmail.com>
References: <1366393612-16885-1-git-send-email-willemb@google.com> <1366394334.16391.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:52960 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238Ab3DVUkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 16:40:55 -0400
Received: by mail-ie0-f178.google.com with SMTP id aq17so6088028iec.37
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 13:40:54 -0700 (PDT)
In-Reply-To: <1366394334.16391.36.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 1:58 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-04-19 at 13:46 -0400, Willem de Bruijn wrote:
>> A cpu executing the network receive path sheds packets when its input
>> queue grows to netdev_max_backlog. A single high rate flow (such as a
>> spoofed source DoS) can exceed a single cpu processing rate and will
>> degrade throughput of other flows hashed onto the same cpu.
>>
>> This patch adds a more fine grained hashtable. If the netdev backlog
>> is above a threshold, IRQ cpus track the ratio of total traffic of
>> each flow (using 1024 buckets, configurable). The ratio is measured
>> by counting the number of packets per flow over the last 256 packets
>> from the source cpu. Any flow that occupies a large fraction of this
>> (set at 50%) will see packet drop while above the threshold.
>>
>> Tested:
>> Setup is a muli-threaded UDP echo server with network rx IRQ on cpu0,
>> kernel receive (RPS) on cpu0 and application threads on cpus 2--7
>> each handling 20k req/s. Throughput halves when hit with a 400 kpps
>> antagonist storm. With this patch applied, antagonist overload is
>> dropped and the server processes its complete load.
>>
>> The patch is effective when kernel receive processing is the
>> bottleneck. The above RPS scenario is a extreme, but the same is
>> reached with RFS and sufficient kernel processing (iptables, packet
>> socket tap, ..).
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>> ---
>
>> +#ifdef CONFIG_NET_FLOW_LIMIT
>> +#define FLOW_LIMIT_HISTORY   (1 << 8)        /* must be ^2 */
>> +struct sd_flow_limit {
>> +     u64                     count;
>> +     unsigned int            history_head;
>> +     u16                     history[FLOW_LIMIT_HISTORY];
>> +     u8                      buckets[];
>> +};
>> +
>> +extern int netdev_flow_limit_table_len;
>> +#endif /* CONFIG_NET_FLOW_LIMIT */
>> +
>>  /*
>>   * Incoming packets are placed on per-cpu queues
>>   */
>> @@ -1808,6 +1820,10 @@ struct softnet_data {
>>       unsigned int            dropped;
>>       struct sk_buff_head     input_pkt_queue;
>>       struct napi_struct      backlog;
>> +
>> +#ifdef CONFIG_NET_FLOW_LIMIT
>> +     struct sd_flow_limit    *flow_limit;
>> +#endif
>>  };
>>
>>  static inline void input_queue_head_incr(struct softnet_data *sd)
>> diff --git a/net/Kconfig b/net/Kconfig
>> index 2ddc904..ff66a4f 100644
>> --- a/net/Kconfig
>> +++ b/net/Kconfig
>> @@ -259,6 +259,16 @@ config BPF_JIT
>>         packet sniffing (libpcap/tcpdump). Note : Admin should enable
>>         this feature changing /proc/sys/net/core/bpf_jit_enable
>>
>> +config NET_FLOW_LIMIT
>> +     bool "Flow shedding under load"
>> +     ---help---
>> +       The network stack has to drop packets when a receive processing CPUs
>> +       backlog reaches netdev_max_backlog. If a few out of many active flows
>> +       generate the vast majority of load, drop their traffic earlier to
>> +       maintain capacity for the other flows. This feature provides servers
>> +       with many clients some protection against DoS by a single (spoofed)
>> +       flow that greatly exceeds average workload.
>> +
>>  menu "Network testing"
>>
>>  config NET_PKTGEN
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 3655ff9..67a4ae0 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3054,6 +3054,47 @@ static int rps_ipi_queued(struct softnet_data *sd)
>>       return 0;
>>  }
>>
>> +#ifdef CONFIG_NET_FLOW_LIMIT
>> +int netdev_flow_limit_table_len __read_mostly = (1 << 12);
>> +#endif
>> +
>> +static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen)
>> +{
>> +#ifdef CONFIG_NET_FLOW_LIMIT
>> +     struct sd_flow_limit *fl;
>> +     struct softnet_data *sd;
>> +     unsigned int old_flow, new_flow;
>> +
>> +     if (qlen < (netdev_max_backlog >> 1))
>> +             return false;
>> +
>> +     sd = &per_cpu(softnet_data, smp_processor_id());
>> +
>> +     rcu_read_lock();
>> +     fl = rcu_dereference(sd->flow_limit);
>> +     if (fl) {
>> +             new_flow = skb_get_rxhash(skb) &
>> +                        (netdev_flow_limit_table_len - 1);
>
> There is a race accessing netdev_flow_limit_table_len
>
> (the admin might change the value, and we might do an out of bound
> access)
>
> This should be a field in fl, aka fl->mask, so thats its safe

Ah, of course. Thanks, Eric!

I held off a new patch for a few days to wait for comments. Just
updated it with this change and will send it as v2.

>
>
>> +             old_flow = fl->history[fl->history_head];
>> +             fl->history[fl->history_head] = new_flow;
>> +
>> +             fl->history_head++;
>> +             fl->history_head &= FLOW_LIMIT_HISTORY - 1;
>> +
>> +             if (likely(fl->buckets[old_flow]))
>> +                     fl->buckets[old_flow]--;
>> +
>> +             if (++fl->buckets[new_flow] > (FLOW_LIMIT_HISTORY >> 1)) {
>> +                     fl->count++;
>> +                     rcu_read_unlock();
>> +                     return true;
>> +             }
>> +     }
>> +     rcu_read_unlock();
>> +#endif
>> +     return false;
>> +}
>> +
>
> Very nice work by the way !
>
>
