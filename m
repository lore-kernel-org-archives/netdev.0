From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
	avahi-daemon: caller is netif_rx
Date: Thu, 15 Apr 2010 15:30:44 +0800
Message-ID: <l2p412e6f7f1004150030o8a406133s91d6614cbb106796@mail.gmail.com>
References: <1271101251.16881.135.camel@edumazet-laptop> <m2m65634d661004121354ta0189542l80473b82911e43f4@mail.gmail.com>
	<1271142857.16881.193.camel@edumazet-laptop> <20100415.001446.244372815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, therbert@google.com, eparis@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f199.google.com ([209.85.210.199]:45008 "EHLO
	mail-yx0-f199.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757463Ab0DOHbF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 03:31:05 -0400
Received: by yxe37 with SMTP id 37so626984yxe.21
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 00:31:04 -0700 (PDT)
In-Reply-To: <20100415.001446.244372815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 3:14 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 13 Apr 2010 09:14:17 +0200
>
>> [PATCH net-next-2.6] net: netif_rx() must disable preemption
>>
>> Eric Paris reported netif_rx() is calling smp_processor_id() from
>> preemptible context, in particular when caller is
>> ip_dev_loopback_xmit().
>>
>> RPS commit added this smp_processor_id() call, this patch makes sure
>> preemption is disabled. rps_get_cpus() wants rcu_read_lock() anyway,=
 we
>> can dot it a bit earlier.
>>
>> Reported-by: Eric Paris <eparis@redhat.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>
> I've applied this with some coding style fixups.
>
> Thanks!
>
> --------------------
> net: netif_rx() must disable preemption
>
> Eric Paris reported netif_rx() is calling smp_processor_id() from
> preemptible context, in particular when caller is
> ip_dev_loopback_xmit().
>
> RPS commit added this smp_processor_id() call, this patch makes sure
> preemption is disabled. rps_get_cpus() wants rcu_read_lock() anyway, =
we
> can dot it a bit earlier.
>
> Reported-by: Eric Paris <eparis@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> =C2=A0net/core/dev.c | =C2=A0 25 +++++++++++++++----------
> =C2=A01 files changed, 15 insertions(+), 10 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 876b111..e8041eb 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2206,6 +2206,7 @@ DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx=
_stat) =3D { 0, };
> =C2=A0/*
> =C2=A0* get_rps_cpu is called from netif_receive_skb and returns the =
target
> =C2=A0* CPU from the RPS map of the receiving queue for a given skb.
> + * rcu_read_lock must be held on entry.
> =C2=A0*/
> =C2=A0static int get_rps_cpu(struct net_device *dev, struct sk_buff *=
skb)
> =C2=A0{
> @@ -2217,8 +2218,6 @@ static int get_rps_cpu(struct net_device *dev, =
struct sk_buff *skb)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u8 ip_proto;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 addr1, addr2, ports, ihl;
>
> - =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb_rx_queue_recorded(skb)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 index =3D =
skb_get_rx_queue(skb);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(i=
ndex >=3D dev->num_rx_queues)) {
> @@ -2296,7 +2295,6 @@ got_hash:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0done:
> - =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return cpu;
> =C2=A0}
>
> @@ -2392,7 +2390,7 @@ enqueue:
>
> =C2=A0int netif_rx(struct sk_buff *skb)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 int cpu;
> + =C2=A0 =C2=A0 =C2=A0 int ret;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* if netpoll wants it, pretend we never s=
aw it */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (netpoll_rx(skb))
> @@ -2402,14 +2400,21 @@ int netif_rx(struct sk_buff *skb)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0net_timestamp(=
skb);
>
> =C2=A0#ifdef CONFIG_RPS
> - =C2=A0 =C2=A0 =C2=A0 cpu =3D get_rps_cpu(skb->dev, skb);
> - =C2=A0 =C2=A0 =C2=A0 if (cpu < 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cpu =3D smp_proces=
sor_id();
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int cpu;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cpu =3D get_rps_cp=
u(skb->dev, skb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (cpu < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 cpu =3D smp_processor_id();
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D enqueue_to=
_backlog(skb, cpu);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0#else
> - =C2=A0 =C2=A0 =C2=A0 cpu =3D smp_processor_id();
> + =C2=A0 =C2=A0 =C2=A0 ret =3D enqueue_to_backlog(skb, get_cpu());
> + =C2=A0 =C2=A0 =C2=A0 put_cpu();
> =C2=A0#endif
> -
> - =C2=A0 =C2=A0 =C2=A0 return enqueue_to_backlog(skb, cpu);
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(netif_rx);
>

Should netif_rx() be used only when preemption is disabled? If not,
netif_rx_ni() should be used instead.?


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
