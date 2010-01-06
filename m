From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Tue, 5 Jan 2010 23:56:41 -0800
Message-ID: <65634d661001052356m494475ck5f6c47ab860fda35@mail.gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
	 <20091120154046.67252d23@nehalam>
	 <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com>
	 <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com>
	 <4B44258C.2050302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:56004 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab0AFH4o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 02:56:44 -0500
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o067ug1g024577
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 07:56:43 GMT
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by kpbe11.cbf.corp.google.com with ESMTP id o067uCL9020560
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 01:56:41 -0600
Received: by pwi8 with SMTP id 8so11943602pwi.11
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2010 23:56:41 -0800 (PST)
In-Reply-To: <4B44258C.2050302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric, thanks for the comments.

> Hmm, I cant see a race condition here, could you elaborate on this ?
> mask is local to this cpu, and we cannot re-enter a function that cou=
ld
> change some bits under us (we are called from net_rx_action())
> If you believe there is a race condition, I suspect race is still the=
re.
>
We're allowing bits in the map to be set in netif_rx out of interrupt
and __smp_call_function_single needs to be called with interrupts
disabled.  I guess an alternative would be to copy the mask to a local
variable, and then clear the mask and scan over the local variable.
Would there be complaints with stack space in local cpumask_t
variable?

>
> Did you tested with VLANS too ? (with/without hardware support)
>
No.  Looks like vlan functions eventually call netif_receive_skb
though... I suppose I could test that.

>>
>> Tom
>
> Excellent, but I suspect big win comes from using few NICS.
> (number_of(NICS) < num_online_cpus)
>
Yes, our primary motivation for developing this was a single NIC with
a single queue on a multicore system.

> (in the reverse case, possible contention on queue->csd)
>
Actually there should never be contention on that, only one cpu at at
time will access it which is the one that successfully schedules napi
on the remote CPU from enqueue_to_backlog.

>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 97873e3..7107b13 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -676,6 +676,29 @@ struct net_device_ops {
>> =A0};
>>
>> =A0/*
>> + * Structure for Receive Packet Steering. =A0Length of map and arra=
y of CPU ID's.
>> + */
>> +struct rps_map {
>> + =A0 =A0 int len;
>> + =A0 =A0 u16 map[0];
>> +};
>> +
>> +/*
>> + * Structure that contains the rps maps for various NAPI instances =
of a device.
>> + */
>> +struct dev_rps_maps {
>> + =A0 =A0 int num_maps;
>> + =A0 =A0 struct rcu_head rcu;
>> + =A0 =A0 struct rps_map maps[0];
>> +};
>
> I feel uneasy about this, because of kmalloc() max size and rounding =
to power of two effects.

Other than some wasted memory what is bad about that?

> It also uses a single node in NUMA setups.

I suppose we should allocate from the devices NUMA node... I'd really
like to store the maps with the napi instances themselves and this
would work well if the napi structs are allocated on the NUMA node
where the interrupt is called (I think this in Peter Waskiewicz's irq
patch).  Unfortunately, the information is lost by the time
netif_receive_skb is called anyway.

>> +
>> +/* Bound number of CPUs that can be in an rps map */
>> +#define MAX_RPS_CPUS (num_possible_cpus() < 256 ? num_possible_cpus=
() : 256)
>> +
>> +/* Maximum size of RPS map (for allocation) */
>> +#define RPS_MAP_SIZE (sizeof(struct rps_map) + (MAX_RPS_CPUS * size=
of(u16)))
>> +
>> +/*
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
>
>
> If you store rps_map pointer into napi itself, you could avoid this M=
AX_RPS_CPUS thing
> and really dynamically allocate the structure with the number of onli=
ne cpus mentioned
> in the map.
>
> But yes, it makes store_rps_cpus() more complex :(
>
As I pointed out above, I would like to that.  Probably would involve
adding a pointer to napi_struct in skb...

> This probably can be done later, this Version 4 of RPS looks very goo=
d, thanks !
> I am going to test it today on my dev machine before giving an Acked-=
by :)
>
Thanks!

> Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
>
>
>
