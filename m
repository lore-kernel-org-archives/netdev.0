From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] net: fix the flow limitation computation
Date: Fri, 5 Dec 2014 12:52:22 -0500
Message-ID: <CA+FuTScVxFHTogMbXRkbYALPXKF0=USw=27XZpcMAVFSd9VJXw@mail.gmail.com>
References: <1417772919-17744-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:53514 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbaLERwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 12:52:53 -0500
Received: by mail-qg0-f45.google.com with SMTP id f51so812673qge.4
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 09:52:52 -0800 (PST)
In-Reply-To: <1417772919-17744-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 5, 2014 at 4:48 AM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> Once RPS is enabled, the skb maybe enqueue to different CPU, so the
> flow limitation computation should use the enqueued CPU, not the local
> CPU

No, the decision to do accounting on the initial cpu was deliberate,
to avoids cache line contention with other cpus.

The goal is to detect under stress a single four-tuple that is
responsible for the majority of traffic, based on the assumption
that traffic is spread across many flows under normal conditions.

Accounting on the destination rps cpus is the more obviously
correct solution. Accounting on the source cpu is generally
fine, too, since it still only blocks a flow if that flow sends
> 50% of all packets from that cpu.

The only false positive occurs if multiple cpus have flows that
are large in proportion to their own packet rate, but only a subset
of these cpus actually generate a lot of traffic. Then, the
proportionally large flows from the cpus that generate little
traffic are incorrectly throttled. Throttling is still proportional
to aggregate packet rate, so should be low.

>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/core/dev.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 945bbd0..e70507d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3250,7 +3250,7 @@ static int rps_ipi_queued(struct softnet_data *sd)
>  int netdev_flow_limit_table_len __read_mostly = (1 << 12);
>  #endif
>
> -static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen)
> +static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen, int cpu)
>  {
>  #ifdef CONFIG_NET_FLOW_LIMIT
>         struct sd_flow_limit *fl;
> @@ -3260,7 +3260,7 @@ static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen)
>         if (qlen < (netdev_max_backlog >> 1))
>                 return false;
>
> -       sd = this_cpu_ptr(&softnet_data);
> +       sd = &per_cpu(softnet_data, cpu);
>
>         rcu_read_lock();
>         fl = rcu_dereference(sd->flow_limit);
> @@ -3303,7 +3303,7 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
>
>         rps_lock(sd);
>         qlen = skb_queue_len(&sd->input_pkt_queue);
> -       if (qlen <= netdev_max_backlog && !skb_flow_limit(skb, qlen)) {
> +       if (qlen <= netdev_max_backlog && !skb_flow_limit(skb, qlen, cpu)) {
>                 if (skb_queue_len(&sd->input_pkt_queue)) {
>  enqueue:
>                         __skb_queue_tail(&sd->input_pkt_queue, skb);
> --
> 2.1.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
