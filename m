From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH resend net-next] sch_tbf: add TBF_BURST/TBF_PBURST
 attribute
Date: Thu, 19 Dec 2013 12:15:13 -0800
Message-ID: <1387484113.19078.375.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386927716-7896-1-git-send-email-yangyingliang@huawei.com>
	 <52AFC64F.2070100@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:57266 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154Ab3LSUPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:15:15 -0500
Received: by mail-pa0-f46.google.com with SMTP id kl14so1640569pab.33
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 12:15:14 -0800 (PST)
In-Reply-To: <52AFC64F.2070100@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-17 at 11:34 +0800, Yang Yingliang wrote:
> From: Yang Yingliang <yangyingliang@huawei.com>
> 
> When we set burst to 1514 with low rate in userspace,
> the kernel get a value of burst that less than 1514,
> which doesn't work.
> 
> Because it may make some loss when transform burst
> to buffer in userspace. This makes burst lose some
> bytes, when the kernel transform the buffer back to
> burst.
> 
> This patch adds two new attributes to support sending
> burst/mtu to kernel directly to avoid the loss.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  include/uapi/linux/pkt_sched.h |  2 ++
>  net/sched/sch_tbf.c            | 25 +++++++++++++++++++++----
>  2 files changed, 23 insertions(+), 4 deletions(-)
> 
> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
> index a806687..fd8e17e 100644
> --- a/include/uapi/linux/pkt_sched.h
> +++ b/include/uapi/linux/pkt_sched.h
> @@ -173,6 +173,8 @@ enum {
>  	TCA_TBF_PTAB,
>  	TCA_TBF_RATE64,
>  	TCA_TBF_PRATE64,
> +	TCA_TBF_BURST,
> +	TCA_TBF_PBURST,
>  	__TCA_TBF_MAX,
>  };
>  
> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index 887e672..ee84409 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
> @@ -307,6 +307,8 @@ static const struct nla_policy tbf_policy[TCA_TBF_MAX + 1] = {
>  	[TCA_TBF_PTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
>  	[TCA_TBF_RATE64]	= { .type = NLA_U64 },
>  	[TCA_TBF_PRATE64]	= { .type = NLA_U64 },
> +	[TCA_TBF_BURST] = { .type = NLA_U32 },
> +	[TCA_TBF_PBURST] = { .type = NLA_U32 },
>  };
>  
>  static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
> @@ -358,7 +360,11 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
>  		rate64 = nla_get_u64(tb[TCA_TBF_RATE64]);
>  	psched_ratecfg_precompute(&rate, &qopt->rate, rate64);
>  
> -	max_size = min_t(u64, psched_ns_t2l(&rate, buffer), ~0U);
> +	if (tb[TCA_TBF_BURST]) {
> +		max_size = nla_get_u32(tb[TCA_TBF_BURST]);
> +		buffer = psched_l2t_ns(&rate, max_size);
> +	} else
> +		max_size = min_t(u64, psched_ns_t2l(&rate, buffer), ~0U);
>  
         } else {
                ...
         }

>  	if (qopt->peakrate.rate) {
>  		if (tb[TCA_TBF_PRATE64])
> @@ -371,7 +377,12 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
>  			goto done;
>  		}
>  
> -		max_size = min_t(u64, max_size, psched_ns_t2l(&peak, mtu));
> +		if (tb[TCA_TBF_PBURST]) {
> +			u32 pburst = nla_get_u32(tb[TCA_TBF_PBURST]);
> +			max_size = min_t(u32, max_size, pburst);
> +			mtu = psched_l2t_ns(&peak, pburst);
> +		} else
> +			max_size = min_t(u64, max_size, psched_ns_t2l(&peak, mtu));
                 } else {
                 }

>  	}
>  
>  	if (max_size < psched_mtu(qdisc_dev(sch)))
> @@ -391,9 +402,15 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
>  		q->qdisc = child;
>  	}
>  	q->limit = qopt->limit;
> -	q->mtu = PSCHED_TICKS2NS(qopt->mtu);
> +	if (tb[TCA_TBF_PBURST])
> +		q->mtu = mtu;
> +	else
> +		q->mtu = PSCHED_TICKS2NS(qopt->mtu);
>  	q->max_size = max_size;
> -	q->buffer = PSCHED_TICKS2NS(qopt->buffer);
> +	if (tb[TCA_TBF_BURST])
> +		q->buffer = buffer;
> +	else
> +		q->buffer = PSCHED_TICKS2NS(qopt->buffer);
>  	q->tokens = q->buffer;
>  	q->ptokens = q->mtu;
>  

Otherwise, looks good.
