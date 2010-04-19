From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next-2.6] rps: shortcut net_rps_action()
Date: Mon, 19 Apr 2010 09:02:44 -0700
Message-ID: <u2h65634d661004190902lcd63436s5a817e6cf8ee27f5@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271583573.16881.4798.camel@edumazet-laptop>
	 <1271590476.16881.4925.camel@edumazet-laptop>
	 <1271669822.16881.7520.camel@edumazet-laptop>
	 <k2u412e6f7f1004190248s8ac633beof2475645e799f2ea@mail.gmail.com>
	 <1271679244.3845.43.camel@edumazet-laptop>
	 <p2u412e6f7f1004190528l65cc6253w8b7f43f2657b551d@mail.gmail.com>
	 <1271683627.3845.44.camel@edumazet-laptop>
	 <1271686957.3845.49.camel@edumazet-laptop>
	 <1271689653.3845.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:23293 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753836Ab0DSQCr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 12:02:47 -0400
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o3JG2k7O031795
	for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 09:02:46 -0700
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by wpaz24.hot.corp.google.com with ESMTP id o3JG2itL009861
	for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 09:02:45 -0700
Received: by pvc30 with SMTP id 30so3290439pvc.8
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 09:02:44 -0700 (PDT)
In-Reply-To: <1271689653.3845.73.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> [PATCH net-next-2.6] rps: shortcut net_rps_action()
>
> net_rps_action() is a bit expensive on NR_CPUS=3D64..4096 kernels, ev=
en if
> RPS is not active.
>
> Tom Herbert used two bitmasks to hold information needed to send IPI,
> but a single LIFO list seems more appropriate.
>
Yes, this patch is an improvement over that.

> Move all RPS logic into net_rps_action() to cleanup net_rx_action() c=
ode
> (remove two ifdefs)
>
> Move rps_remote_softirq_cpus into softnet_data to share its first cac=
he
> line, filling an existing hole.
>
> In a future patch, we could call net_rps_action() from process_backlo=
g()
> to make sure we send IPI before handling this cpu backlog.
>
Yes.  I did some quick experiments last night and there does seem to
be some gains in doing this.

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =A0include/linux/netdevice.h | =A0 =A09 ++--
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 79 ++++++++++++++-----=
-----------------
> =A02 files changed, 38 insertions(+), 50 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 649a025..83ab3da 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1381,17 +1381,20 @@ static inline int unregister_gifconf(unsigned=
 int family)
> =A0}
>
> =A0/*
> - * Incoming packets are placed on per-cpu queues so that
> - * no locking is needed.
> + * Incoming packets are placed on per-cpu queues
> =A0*/
> =A0struct softnet_data {
> =A0 =A0 =A0 =A0struct Qdisc =A0 =A0 =A0 =A0 =A0 =A0*output_queue;
> =A0 =A0 =A0 =A0struct list_head =A0 =A0 =A0 =A0poll_list;
> =A0 =A0 =A0 =A0struct sk_buff =A0 =A0 =A0 =A0 =A0*completion_queue;
>
> - =A0 =A0 =A0 /* Elements below can be accessed between CPUs for RPS =
*/
> =A0#ifdef CONFIG_RPS
> + =A0 =A0 =A0 struct softnet_data =A0 =A0 *rps_ipi_list;
> +
> + =A0 =A0 =A0 /* Elements below can be accessed between CPUs for RPS =
*/
> =A0 =A0 =A0 =A0struct call_single_data csd ____cacheline_aligned_in_s=
mp;
> + =A0 =A0 =A0 struct softnet_data =A0 =A0 *rps_ipi_next;
> + =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0cpu;
> =A0 =A0 =A0 =A0unsigned int =A0 =A0 =A0 =A0 =A0 =A0input_queue_head;
> =A0#endif
> =A0 =A0 =A0 =A0struct sk_buff_head =A0 =A0 input_pkt_queue;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7abf959..f6ff2cf 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2346,21 +2346,6 @@ done:
> =A0 =A0 =A0 =A0return cpu;
> =A0}
>
> -/*
> - * This structure holds the per-CPU mask of CPUs for which IPIs are =
scheduled
> - * to be sent to kick remote softirq processing. =A0There are two ma=
sks since
> - * the sending of IPIs must be done with interrupts enabled. =A0The =
select field
> - * indicates the current mask that enqueue_backlog uses to schedule =
IPIs.
> - * select is flipped before net_rps_action is called while still und=
er lock,
> - * net_rps_action then uses the non-selected mask to send the IPIs a=
nd clears
> - * it without conflicting with enqueue_backlog operation.
> - */
> -struct rps_remote_softirq_cpus {
> - =A0 =A0 =A0 cpumask_t mask[2];
> - =A0 =A0 =A0 int select;
> -};
> -static DEFINE_PER_CPU(struct rps_remote_softirq_cpus, rps_remote_sof=
tirq_cpus);
> -
> =A0/* Called from hardirq (IPI) context */
> =A0static void trigger_softirq(void *data)
> =A0{
> @@ -2403,10 +2388,12 @@ enqueue:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (napi_schedule_prep(&queue->backlog=
)) {
> =A0#ifdef CONFIG_RPS
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cpu !=3D smp_proce=
ssor_id()) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
rps_remote_softirq_cpus *rcpus =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 &__get_cpu_var(rps_remote_softirq_cpus);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
softnet_data *myqueue;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 myqueue=
 =3D &__get_cpu_var(softnet_data);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue->=
rps_ipi_next =3D myqueue->rps_ipi_list;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 myqueue=
->rps_ipi_list =3D queue;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu_set=
(cpu, rcpus->mask[rcpus->select]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__rais=
e_softirq_irqoff(NET_RX_SOFTIRQ);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto e=
nqueue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -2911,7 +2898,9 @@ int netif_receive_skb(struct sk_buff *skb)
> =A0}
> =A0EXPORT_SYMBOL(netif_receive_skb);
>
> -/* Network device is going away, flush any packets still pending =A0=
*/
> +/* Network device is going away, flush any packets still pending
> + * Called with irqs disabled.
> + */
> =A0static void flush_backlog(void *arg)
> =A0{
> =A0 =A0 =A0 =A0struct net_device *dev =3D arg;
> @@ -3340,24 +3329,33 @@ void netif_napi_del(struct napi_struct *napi)
> =A0}
> =A0EXPORT_SYMBOL(netif_napi_del);
>
> -#ifdef CONFIG_RPS
> =A0/*
> - * net_rps_action sends any pending IPI's for rps. =A0This is only c=
alled from
> - * softirq and interrupts must be enabled.
> + * net_rps_action sends any pending IPI's for rps.
> + * Note: called with local irq disabled, but exits with local irq en=
abled.
> =A0*/
> -static void net_rps_action(cpumask_t *mask)
> +static void net_rps_action(void)
> =A0{
> - =A0 =A0 =A0 int cpu;
> +#ifdef CONFIG_RPS
> + =A0 =A0 =A0 struct softnet_data *locqueue =3D &__get_cpu_var(softne=
t_data);
> + =A0 =A0 =A0 struct softnet_data *remqueue =3D locqueue->rps_ipi_lis=
t;
>
> - =A0 =A0 =A0 /* Send pending IPI's to kick RPS processing on remote =
cpus. */
> - =A0 =A0 =A0 for_each_cpu_mask_nr(cpu, *mask) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct softnet_data *queue =3D &per_cpu=
(softnet_data, cpu);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cpu_online(cpu))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __smp_call_function_sin=
gle(cpu, &queue->csd, 0);
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 cpus_clear(*mask);
> -}
> + =A0 =A0 =A0 if (remqueue) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 locqueue->rps_ipi_list =3D NULL;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable();
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Send pending IPI's to kick RPS proce=
ssing on remote cpus. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (remqueue) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct softnet_data *ne=
xt =3D remqueue->rps_ipi_next;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cpu_online(remqueue=
->cpu))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __smp_c=
all_function_single(remqueue->cpu,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&remqueue->csd, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 remqueue =3D next;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } else
> =A0#endif
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable();
> +}
>
> =A0static void net_rx_action(struct softirq_action *h)
> =A0{
> @@ -3365,10 +3363,6 @@ static void net_rx_action(struct softirq_actio=
n *h)
> =A0 =A0 =A0 =A0unsigned long time_limit =3D jiffies + 2;
> =A0 =A0 =A0 =A0int budget =3D netdev_budget;
> =A0 =A0 =A0 =A0void *have;
> -#ifdef CONFIG_RPS
> - =A0 =A0 =A0 int select;
> - =A0 =A0 =A0 struct rps_remote_softirq_cpus *rcpus;
> -#endif
>
> =A0 =A0 =A0 =A0local_irq_disable();
>
> @@ -3431,17 +3425,7 @@ static void net_rx_action(struct softirq_actio=
n *h)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netpoll_poll_unlock(have);
> =A0 =A0 =A0 =A0}
> =A0out:
> -#ifdef CONFIG_RPS
> - =A0 =A0 =A0 rcpus =3D &__get_cpu_var(rps_remote_softirq_cpus);
> - =A0 =A0 =A0 select =3D rcpus->select;
> - =A0 =A0 =A0 rcpus->select ^=3D 1;
> -
> - =A0 =A0 =A0 local_irq_enable();
> -
> - =A0 =A0 =A0 net_rps_action(&rcpus->mask[select]);
> -#else
> - =A0 =A0 =A0 local_irq_enable();
> -#endif
> + =A0 =A0 =A0 net_rps_action();
>
> =A0#ifdef CONFIG_NET_DMA
> =A0 =A0 =A0 =A0/*
> @@ -5841,6 +5825,7 @@ static int __init net_dev_init(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0queue->csd.func =3D trigger_softirq;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0queue->csd.info =3D queue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0queue->csd.flags =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue->cpu =3D i;
> =A0#endif
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0queue->backlog.poll =3D process_backlo=
g;
>
>
>
