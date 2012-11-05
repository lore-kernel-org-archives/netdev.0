From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3] htb: improved accuracy at high rates
Date: Mon, 05 Nov 2012 08:58:39 -0800
Message-ID: <1352134719.2747.3.camel@edumazet-glaptop>
References: <1351699451-79317-1-git-send-email-j.vimal@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev@vger.kernel.org
To: Vimalkumar <j.vimal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:34093 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624Ab2KEQ7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 11:59:19 -0500
Received: by mail-da0-f46.google.com with SMTP id n41so2765690dak.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 08:59:19 -0800 (PST)
In-Reply-To: <1351699451-79317-1-git-send-email-j.vimal@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-31 at 09:04 -0700, Vimalkumar wrote:
> Current HTB (and TBF) uses rate table computed by the "tc"
> userspace program, which has the following issue:
> 
> The rate table has 256 entries to map packet lengths
> to token (time units).  With TSO sized packets, the
> 256 entry granularity leads to loss/gain of rate,
> making the token bucket inaccurate.
> 
> Thus, instead of relying on rate table, this patch
> explicitly computes the time and accounts for packet
> transmission times with nanosecond granularity.
> 
> This greatly improves accuracy of HTB with a wide
> range of packet sizes.
> 
> Example:
> 
> tc qdisc add dev $dev root handle 1: \
>         htb default 1
> 
> tc class add dev $dev classid 1:1 parent 1: \
>         rate 5Gbit mtu 64k
> 
> Here is an example of inaccuracy:
> 
> $ iperf -c host -t 10 -i 1
> 
> With old htb:
> eth4:   34.76 Mb/s In  5827.98 Mb/s Out -  65836.0 p/s In  481273.0 p/s Out
> [SUM]  9.0-10.0 sec   669 MBytes  5.61 Gbits/sec
> [SUM]  0.0-10.0 sec  6.50 GBytes  5.58 Gbits/sec
> 
> With new htb:
> eth4:   28.36 Mb/s In  5208.06 Mb/s Out -  53704.0 p/s In  430076.0 p/s Out
> [SUM]  9.0-10.0 sec   594 MBytes  4.98 Gbits/sec
> [SUM]  0.0-10.0 sec  5.80 GBytes  4.98 Gbits/sec
> 
> The bits per second on the wire is still 5200Mb/s with new HTB
> because qdisc accounts for packet length using skb->len, which
> is smaller than total bytes on the wire if GSO is used.  But
> that is for another patch regardless of how time is accounted.
> 
> Many thanks to Eric Dumazet for review and feedback.
> 
> Signed-off-by: Vimalkumar <j.vimal@gmail.com>
> ---
>  net/sched/sch_htb.c |  128 ++++++++++++++++++++++++++++++++++++---------------
>  1 files changed, 90 insertions(+), 38 deletions(-)
> 

> @@ -684,7 +729,7 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level,
>  			return cl->pq_key;
>  
>  		htb_safe_rb_erase(p, q->wait_pq + level);
> -		diff = psched_tdiff_bounded(q->now, cl->t_c, cl->mbuffer);
> +		diff = min_t(s64, q->now - cl->t_c, cl->mbuffer);
>  		htb_change_class_mode(q, cl, &diff);
>  		if (cl->cmode != HTB_CAN_SEND)
>  			htb_add_to_wait_tree(q, cl, diff);
> @@ -834,7 +879,6 @@ next:
>  	} while (cl != start);
>  
>  	if (likely(skb != NULL)) {
> -		bstats_update(&cl->bstats, skb);
>  		cl->un.leaf.deficit[level] -= qdisc_pkt_len(skb);
>  		if (cl->un.leaf.deficit[level] < 0) {
>  			cl->un.leaf.deficit[level] += cl->quantum;
> @@ -871,10 +915,10 @@ ok:
>  

Why this bstats_update() call was removed ?
