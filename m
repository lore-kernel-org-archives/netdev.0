From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Sat, 21 Nov 2009 01:03:22 -0800
Message-ID: <65634d660911210103k2a55e324o8c07ca87eae16faa@mail.gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
	 <4B079FDF.9040809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:30033 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbZKUJDV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:03:21 -0500
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id nAL93PT1022854
	for <netdev@vger.kernel.org>; Sat, 21 Nov 2009 09:03:25 GMT
Received: from pzk40 (pzk40.prod.google.com [10.243.19.168])
	by zps18.corp.google.com with ESMTP id nAL93M6Z029494
	for <netdev@vger.kernel.org>; Sat, 21 Nov 2009 01:03:22 -0800
Received: by pzk40 with SMTP id 40so2763437pzk.7
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2009 01:03:22 -0800 (PST)
In-Reply-To: <4B079FDF.9040809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> =A0 * =A0 The DEVICE structure.
>> =A0 * =A0 Actually, this whole structure is a big mistake. =A0It mix=
es I/O
>> =A0 * =A0 data with strictly "high-level" data, and it has to know a=
bout
>> @@ -861,6 +884,9 @@ struct net_device {
>>
>> =A0 =A0 =A0 struct netdev_queue =A0 =A0 rx_queue;
>>
>> + =A0 =A0 struct dev_rps_maps =A0 =A0 *dev_rps_maps; =A0/* Per-NAPI =
maps for
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0receive packet steeing */
>> +
>> =A0 =A0 =A0 struct netdev_queue =A0 =A0 *_tx ____cacheline_aligned_i=
n_smp;
>>
>> =A0 =A0 =A0 /* Number of TX queues allocated at alloc_netdev_mq() ti=
me =A0*/
>> @@ -1276,6 +1302,9 @@ struct softnet_data {
>> =A0 =A0 =A0 struct Qdisc =A0 =A0 =A0 =A0 =A0 =A0*output_queue;
>> =A0 =A0 =A0 struct sk_buff_head =A0 =A0 input_pkt_queue;
>> =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0poll_list;
>> +
>> + =A0 =A0 struct call_single_data csd;
>
> This is problematic. softnet_data used to be only used by local cpu.
> With RPS, other cpus are going to access csd, input_pkt_queue, backlo=
g
> and dirty cache lines.
>
> Maybe we should split sofnet_data in two cache lines, one private,
> one chared, and
> DEFINE_PER_CPU(struct softnet_data, softnet_data);
> ->
> DEFINE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
>

That would make sense.

> Also you need to change comment at start of struct softnet_data,
> since it is wrong after RPS.
>
> /*
> =A0* Incoming packets are placed on per-cpu queues so that
> =A0* no locking is needed.
> =A0*/
>
Okay.


>> -static u32 skb_tx_hashrnd;
>> +static u32 hashrnd;
> adding a __read_mostly here could help :)
>

Yep.

>>
>> =A0u16 skb_tx_hash(const struct net_device *dev, const struct sk_buf=
f *skb)
>> =A0{
>> @@ -1852,7 +1852,7 @@ u16 skb_tx_hash(const struct net_device *dev,
>> const struct sk_buff *skb)
>> =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash =3D skb->protocol;
>>
>> - =A0 =A0 hash =3D jhash_1word(hash, skb_tx_hashrnd);
>> + =A0 =A0 hash =3D jhash_1word(hash, hashrnd);
>>
>> =A0 =A0 =A0 return (u16) (((u64) hash * dev->real_num_tx_queues) >> =
32);
>> =A0}
>> @@ -2073,6 +2073,146 @@ int weight_p __read_mostly =3D 64; =A0 =A0 =A0=
 =A0 =A0 =A0/*
>> old backlog weight */
>>
>> =A0DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) =3D { 0, };
>>
>> +/*
>> + * get_rps_cpu is called from netif_receive_skb and returns the tar=
get
>> + * CPU from the RPS map of the receiving NAPI instance for a given =
skb.
>> + */
>> +static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
>> +{
>> + =A0 =A0 u32 addr1, addr2, ports;
>> + =A0 =A0 struct ipv6hdr *ip6;
>> + =A0 =A0 struct iphdr *ip;
>> + =A0 =A0 u32 hash, ihl;
>> + =A0 =A0 u8 ip_proto;
>> + =A0 =A0 int cpu =3D -1;
>> + =A0 =A0 struct dev_rps_maps *drmap;
>> + =A0 =A0 struct rps_map *map =3D NULL;
>> + =A0 =A0 u16 index;
>> +
>
>> + =A0 =A0 rcu_read_lock();
> If called from netif_receive_skb(), we already are in a rcu protected=
 section,
> but this could be a cleanup patch, because many other parts in stack =
could
> be changed as well.
>
So convention would be to not call these then?

>
>> +/*
>> + * enqueue_to_backlog is called to queue an skb to a per CPU backlo=
g
>> + * queue (may be a remote CPU queue).
>> + */
>> +static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
>> +{
>> + =A0 =A0 struct softnet_data *queue;
>> + =A0 =A0 unsigned long flags;
>> +
>> + =A0 =A0 queue =3D &per_cpu(softnet_data, cpu);
>> +
>
>
>> + =A0 =A0 local_irq_save(flags);
>> + =A0 =A0 __get_cpu_var(netdev_rx_stat).total++;
>> +
>> + =A0 =A0 spin_lock(&queue->input_pkt_queue.lock);
>
> could reduce to :
> =A0 =A0 =A0 =A0percpu_add(netdev_rx_stat.total, 1);
> =A0 =A0 =A0 =A0spin_lock_irqsave(&queue->input_pkt_queue.lock, flags)=
;
>
Would it make sense to percpu_add into dev.c just for this when other
parts in dev.c would still use __get_cpu_var(stat)++?  Also, I think
this results in more instructions...

>> + =A0 =A0 if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (queue->input_pkt_queue.qlen) {
>> +enqueue:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __skb_queue_tail(&queue->i=
nput_pkt_queue, skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&qu=
eue->input_pkt_queue.lock,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NET_RX_SUCCESS;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Schedule NAPI for backlog device */
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (napi_schedule_prep(&queue->backlog)) {
>
> =A0Is it legal (or wanter at all) to call napi_schedule_prep() on rem=
ote cpu backlog ?
>

I think it is useful.  If the remote backlog is scheduled then there
is no need to do an IPI, so this means there would only ever be on IPI
pending for a backlog queue and hence we can get away with only having
one call_function_data per backlog.  Without the napi schedule, we
would probably need a call structure for each backlog per CPU-- and
also we'd still need some shared bits between source and target CPUs
anyway for when the IPI is completed (want to avoid blocking on
call_function_data).

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cpu !=3D smp_processor=
_id()) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu_set(cp=
u,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ge=
t_cpu_var(rps_remote_softirq_cpus));
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __raise_so=
ftirq_irqoff(NET_RX_SOFTIRQ);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __napi_sch=
edule(&queue->backlog);
>
> Why not the more easy :
> =A0 =A0 =A0 =A0if (cpu !=3D smp_processor_id())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cpu_set(cpu, get_cpu_var(rps_remote_so=
ftirq_cpus));
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0napi_schedule(&queue->backlog);
>
> This way we dont touch to remote backlog (and this backlog could stay=
 in the private
> cache line of remote cpu)
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto enqueue;
>> + =A0 =A0 }
>> +
>
>> + =A0 =A0 spin_unlock(&queue->input_pkt_queue.lock);
>> +
>> + =A0 =A0 __get_cpu_var(netdev_rx_stat).dropped++;
>> + =A0 =A0 local_irq_restore(flags);
>
> ->
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&queue->input_pkt_queue.lock, f=
lags);
> =A0 =A0 =A0 =A0percpu_add(netdev_rx_stat.dropped, 1);
>
>
> +/*
> + * net_rps_action sends any pending IPI's for rps. =A0This is only c=
alled from
> + * softirq and interrupts must be enabled.
> + */
> +static void net_rps_action(void)
> +{
> + =A0 =A0 =A0 int cpu;
> +
> + =A0 =A0 =A0 /* Send pending IPI's to kick RPS processing on remote =
cpus. */
> + =A0 =A0 =A0 for_each_cpu_mask_nr(cpu, __get_cpu_var(rps_remote_soft=
irq_cpus)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct softnet_data *queue =3D &per_cpu=
(softnet_data, cpu);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __smp_call_function_single(cpu, &queue-=
>csd, 0);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 cpus_clear(__get_cpu_var(rps_remote_softirq_cpus));
> +}
>
>
> net_rps_action() might be not very descriptive name and bit expensive=
=2E..
>
> Did you tried smp_call_function_many() ?
> (I suspect you did, but found it was not that optimized ?)
>
> CC Andi to get feedback from him :)
>
> static void net_rps_remcpus_fire(void)
> {
> =A0 =A0 =A0 =A0smp_call_function_many(__get_cpu_var(rps_remote_softir=
q_cpus),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trigger_s=
oftirq, NULL, 0);
> }
>

I'm thinking it is better to avoid possibly blocking on locked cfd_data=
=2E

Tom
