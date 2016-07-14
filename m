From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH v2 01/10] net: sched: allow qdiscs to handle locking
Date: Wed, 13 Jul 2016 23:44:55 -0700
Message-ID: <578734E7.9050608@gmail.com>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
 <20160714061956.8270.93434.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de, jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35750 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbcGNGpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 02:45:09 -0400
Received: by mail-pa0-f65.google.com with SMTP id dx3so4178781pab.2
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 23:45:08 -0700 (PDT)
In-Reply-To: <20160714061956.8270.93434.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-13 11:19 PM, John Fastabend wrote:
> This patch adds a flag for queueing disciplines to indicate the stack
> does not need to use the qdisc lock to protect operations. This can
> be used to build lockless scheduling algorithms and improving
> performance.
> 
> The flag is checked in the tx path and the qdisc lock is only taken
> if it is not set. For now use a conditional if statement. Later we
> could be more aggressive if it proves worthwhile and use a static key
> or wrap this in a likely().
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

[...]

> @@ -3075,6 +3075,27 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>  	int rc;
>  
>  	qdisc_calculate_pkt_len(skb, q);
> +
> +	if (q->flags & TCQ_F_NOLOCK) {
> +		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> +			__qdisc_drop(skb, &to_free);
> +			rc = NET_XMIT_DROP;
> +		} else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q)) {
> +			qdisc_bstats_cpu_update(q, skb);
> +			__qdisc_run(q);

Reviewing these patches now and noticed this qdisc_run() is not
needed.

> +			if (sch_direct_xmit(skb, q, dev, txq, root_lock, true))
> +				__qdisc_run(q);
> +			rc = NET_XMIT_SUCCESS;
> +		} else {
> +			rc = q->enqueue(skb, q, &to_free) & NET_XMIT_MASK;
> +			__qdisc_run(q);
> +		}
> +
> +		if (unlikely(to_free))
> +			kfree_skb_list(to_free);
> +		return rc;
> +	}
> +

[...]

Thanks,
John
