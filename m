From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v5 1/2] net: sched: tbf: fix calculation of max_size
Date: Thu, 05 Dec 2013 04:15:29 -0800
Message-ID: <1386245729.30495.167.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386227457-86900-1-git-send-email-yangyingliang@huawei.com>
	 <1386227457-86900-2-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, brouer@redhat.com,
	jpirko@redhat.com, jbrouer@redhat.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:48627 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308Ab3LEMPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 07:15:32 -0500
Received: by mail-pd0-f177.google.com with SMTP id q10so24177492pdj.8
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 04:15:31 -0800 (PST)
In-Reply-To: <1386227457-86900-2-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-05 at 15:10 +0800, Yang Yingliang wrote:
> Current max_size is caluated from rate table. Now, the rate table
> has been replaced and it's wrong to caculate max_size based on this
> rate table. It can lead wrong calculation of max_size.
> 
> The burst in kernel may be lower than user asked, because burst may gets
> some loss when transform it to buffer(E.g. "burst 40kb rate 30mbit/s")
> and it seems we cannot avoid this loss. Burst's value(max_size) based on
> rate table may be equal user asked. If a packet's length is max_size, this
> packet will be stalled in tbf_dequeue() because its length is above the
> burst in kernel so that it cannot get enough tokens. The max_size guards
> against enqueuing packet sizes above q->buffer "time" in tbf_enqueue().
> 
> To make consistent with the calculation of tokens, this patch add a helper
> psched_ns_t2l() to calculate burst(max_size) directly to fix this problem.
> 
> After this fix, we can support to using 64bit rates to calculate burst as well.
> 
> Suggested-by: Jesper Dangaard Brouer <jbrouer@redhat.com>
> Suggested-by: Eric Dumazet <edumazet@google.com>

No, I did not suggest this patch.

> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  include/net/sch_generic.h | 46 ++++++++++++++++++++++++++++
>  net/sched/sch_tbf.c       | 76 ++++++++++++++++++++---------------------------
>  2 files changed, 79 insertions(+), 43 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index d0a6321..8da64f3 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -701,6 +701,52 @@ static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
>  	return ((u64)len * r->mult) >> r->shift;
>  }
>  
> +/* Time to Length, convert time in ns to length in bytes
> + * to determinate how many bytes can be sent in given time.
> + */
> +static inline u64 psched_ns_t2l(const struct psched_ratecfg *r,
> +				u64 time_in_ns)

inline ?

Really ? 

This is management path, there is no point inlining this.

> +{
> +	u64 len = time_in_ns;
> +	u8 shift = r->shift;
> +	bool is_div = false;
> +
> +	/* The formula is :
> +	 * len = (time_in_ns << shift) / mult
> +	 * when time_in_ns does shift, it would overflow.
> +	 * If overflow happens first time, do division.
> +	 * Then do shift. If it happens again,
> +	 * set lenth to ~0ULL.
> +	 */
> +	while (shift) {
> +		if (len & (1ULL << 63)) {
> +			if (!is_div) {
> +				len = div64_u64(len, r->mult);
> +				is_div = true;
> +			} else {
> +				/* overflow happens */
> +				len = ~0ULL;
> +				is_div = true;
> +				break;
> +			}
> +		}
> +		len <<= 1;
> +		shift--;
> +	}
> +	if (!is_div)
> +		len = div64_u64(len, r->mult);

Thats terrible.

Given that the intended formula was :

time_in_ns = (NSEC_PER_SEC * len) / rate_bps;

This translates to following optimal C code

u64 len = time_in_ns * r->rate_bytes_ps;
do_div(len, NSEC_PER_SEC);

Why do you use r->shift and r->mult which are optimized for the reverse
operation in fast path (no divide), I do not know.

> +	max_size = min_t(u64, psched_ns_t2l(&q->rate, q->buffer), ~0U); 
> +
> +	if (qopt->peakrate.rate) {
>  		if (tb[TCA_TBF_PRATE64])
>  			prate64 = nla_get_u64(tb[TCA_TBF_PRATE64]);
> -		psched_ratecfg_precompute(&q->peak, &ptab->rate, prate64);
> +		psched_ratecfg_precompute(&q->peak, &qopt->peakrate, prate64);
> +		if (q->peak.rate_bytes_ps <= q->rate.rate_bytes_ps) {
> +			pr_err("Peakrate must be higher than rate!\n");

Do not add messages like that without rate limiting them.

Plus there is no context, we know nothing.
