From: Tom Herbert <therbert@google.com>
Subject: Re: rps: some comments
Date: Thu, 7 Jan 2010 16:07:35 -0800
Message-ID: <65634d661001071607k63c33a0q4f402942d64ea77e@mail.gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
	 <20091120154046.67252d23@nehalam>
	 <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com>
	 <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com>
	 <4B44258C.2050302@gmail.com> <4B44D89B.8070006@gmail.com>
	 <65634d661001061454v389d311fjb245de21e0ab8092@mail.gmail.com>
	 <4B45A623.7070507@gmail.com> <4B461D11.6050603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:57510 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab0AHAHj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 19:07:39 -0500
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o0807aKR000399
	for <netdev@vger.kernel.org>; Fri, 8 Jan 2010 00:07:37 GMT
Received: from pzk40 (pzk40.prod.google.com [10.243.19.168])
	by wpaz9.hot.corp.google.com with ESMTP id o0807O9h020426
	for <netdev@vger.kernel.org>; Thu, 7 Jan 2010 16:07:35 -0800
Received: by pzk40 with SMTP id 40so11276668pzk.7
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2010 16:07:35 -0800 (PST)
In-Reply-To: <4B461D11.6050603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 7, 2010 at 9:42 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Hi Tom
>
> 1) netif_receive_skb() might enqueue skb instead of handling them dir=
ectly.
>
> int netif_receive_skb(struct sk_buff *skb)
> {
> =A0 =A0 =A0 =A0int cpu =3D get_rps_cpu(skb->dev, skb);
>
> =A0 =A0 =A0 =A0if (cpu < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return __netif_receive_skb(skb);
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return enqueue_to_backlog(skb, cpu);
> }
>
> If get_rps_cpu() happens to select the current cpu, we enqueue to bac=
klog the
> skb instead of directly calling __netif_receive_skb().
>
> One way to solve this is to make get_rps_cpu() returns -1 in this cas=
e :
>
> ...
> if (cpu =3D=3D smp_processor_id() || !cpu_online(cpu))
> =A0 =A0 =A0 =A0cpu =3D -1;
>
> done:
> =A0 =A0 =A0 =A0rcu_read_unlock();
> =A0 =A0 =A0 =A0return cpu;
> } /* get_rps_cpu() */
>
I kind of like the way it is right now, which is to enqueue even on
the local CPU.  The advantage of that is that all the packets received
in the napi run are dispatched to all the participating CPUs before
any are processed, this is good for average and worst case latency on
a packet burst.

>
> 2) RPS_MAP_SIZE might be too expensive to use in fast path, on big (N=
R_CPUS=3D4096) machines :
> =A0num_possible_cpus() has to count all bits set in a bitmap.
>
> #define MAX_RPS_CPUS (num_possible_cpus() < 256 ? num_possible_cpus()=
 : 256)
> #define RPS_MAP_SIZE (sizeof(struct rps_map) + (MAX_RPS_CPUS * sizeof=
(u16))
>
> You can use nr_cpu_ids, or even better a new variable, that you init =
_once_ to
>
> unsigned int rps_map_size =3D sizeof(struct rps_map) + (min(256, nr_c=
pu_ids) * sizeof(u16));
>
Yes that's probably better.

>
> 3) cpu hotplug.
>
> I cannot find how cpu unplug can be safe.
>
> if (!cpu_online(cpu))
> =A0 =A0 =A0 =A0cpu =3D -1;
> rcu_read_unlock();
> ...
> cpu_set(cpu, __get_cpu_var(rps_remote_softirq_cpus));
> ...
> __smp_call_function_single(cpu, &queue->csd, 0);

I believe were dealing with remote CPUs with preemption disabled (from
softirq's), so maybe that is sufficient to prevent CPU from going away
below us.  We probably need a "if cpu_online(cpu)" before
__smp_call_function_single though.

Thanks,
Tom
