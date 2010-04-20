From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] rps: send IPIs ASAP
Date: Mon, 19 Apr 2010 22:15:58 -0700
Message-ID: <g2y65634d661004192215oc06d9c43xb2a7c7d946149cf5@mail.gmail.com>
References: <1271736519-2991-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:49856 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab0DTFQE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 01:16:04 -0400
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o3K5FxRH027418
	for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 07:16:00 +0200
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by kpbe14.cbf.corp.google.com with ESMTP id o3K5FwSw027996
	for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 22:15:58 -0700
Received: by pwj9 with SMTP id 9so3952921pwj.19
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 22:15:58 -0700 (PDT)
In-Reply-To: <1271736519-2991-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 19, 2010 at 9:08 PM, Changli Gao <xiaosuo@gmail.com> wrote:
> rps: send IPIs ASAP
>
> In order to reduce latency, we'd better send IPIs ASAP to schedule th=
e
> corresponding NAPIs.
>
A design point of RPS is that we generate at most one IPI per CPU per
device interrupt, which at least offers some predictable coalescing.
With your changes, we would get at most one IPI per packet-- that
could represent a lot more of them.  Did you test this to see what the
impact is in this regard?


> For NAPI drivers, we send IPIs immediately, and for the others, we de=
fer them
> to NET_RX_SOFTIRQ. In this patch, we move net_rps_action() to the beg=
inning of
> net_rx_action() to emulate a softirq with the higher priority than
> NET_RX_SOFTIRQ.
>
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
> =A0net/core/dev.c | =A0 23 ++++++++++++++++++++---
> =A01 file changed, 20 insertions(+), 3 deletions(-)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 05a2b29..d8fca21 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2363,6 +2363,10 @@ static int enqueue_to_backlog(struct sk_buff *=
skb, int cpu,
> =A0{
> =A0 =A0 =A0 =A0struct softnet_data *queue;
> =A0 =A0 =A0 =A0unsigned long flags;
> +#ifdef CONFIG_RPS
> + =A0 =A0 =A0 bool ni =3D !in_irq();
> + =A0 =A0 =A0 bool ipi =3D false;
> +#endif
>
> =A0 =A0 =A0 =A0queue =3D &per_cpu(softnet_data, cpu);
>
> @@ -2380,6 +2384,10 @@ enqueue:
> =A0#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rps_unlock(queue);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_restore(flag=
s);
> +#ifdef CONFIG_RPS
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ipi)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __smp_c=
all_function_single(cpu, &queue->csd, 0);
> +#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NET_RX_SUCCESS;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> @@ -2389,6 +2397,11 @@ enqueue:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cpu !=3D smp_proce=
ssor_id()) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct=
 softnet_data *myqueue;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ni)=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 ipi =3D true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 goto enqueue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0myqueu=
e =3D &__get_cpu_var(softnet_data);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0queue-=
>rps_ipi_next =3D myqueue->rps_ipi_list;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0myqueu=
e->rps_ipi_list =3D queue;
> @@ -3337,6 +3350,7 @@ static void net_rps_action(void)
> =A0 =A0 =A0 =A0struct softnet_data *locqueue =3D &__get_cpu_var(softn=
et_data);
> =A0 =A0 =A0 =A0struct softnet_data *remqueue =3D locqueue->rps_ipi_li=
st;
>
> + =A0 =A0 =A0 local_irq_disable();
> =A0 =A0 =A0 =A0if (remqueue) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0locqueue->rps_ipi_list =3D NULL;
>
> @@ -3350,9 +3364,10 @@ static void net_rps_action(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &remqueue->csd, 0);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0remqueue =3D next;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 } else
> -#endif
> + =A0 =A0 =A0 } else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_enable();
> + =A0 =A0 =A0 }
> +#endif
> =A0}
>
> =A0static void net_rx_action(struct softirq_action *h)
> @@ -3362,6 +3377,8 @@ static void net_rx_action(struct softirq_action=
 *h)
> =A0 =A0 =A0 =A0int budget =3D netdev_budget;
> =A0 =A0 =A0 =A0void *have;
>
> + =A0 =A0 =A0 net_rps_action();
> +
> =A0 =A0 =A0 =A0local_irq_disable();
>
> =A0 =A0 =A0 =A0while (!list_empty(list)) {
> @@ -3423,7 +3440,7 @@ static void net_rx_action(struct softirq_action=
 *h)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netpoll_poll_unlock(have);
> =A0 =A0 =A0 =A0}
> =A0out:
> - =A0 =A0 =A0 net_rps_action();
> + =A0 =A0 =A0 local_irq_enable();
>
> =A0#ifdef CONFIG_NET_DMA
> =A0 =A0 =A0 =A0/*
>
