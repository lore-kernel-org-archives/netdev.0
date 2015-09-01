From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: qdisc: add op to run filters/actions
 before enqueue
Date: Tue, 01 Sep 2015 10:21:23 -0700
Message-ID: <1441128083.8932.177.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1441123709.git.daniel@iogearbox.net>
	 <a18f0baba2668f0bbc15a45036713dcaa4bb09b0.1441123709.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, john.fastabend@gmail.com, ast@plumgrid.com,
	netdev@vger.kernel.org, John Fastabend <john.r.fastabend@intel.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33850 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbbIARV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 13:21:28 -0400
Received: by padhy1 with SMTP id hy1so2118494pad.1
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 10:21:28 -0700 (PDT)
In-Reply-To: <a18f0baba2668f0bbc15a45036713dcaa4bb09b0.1441123709.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-01 at 18:34 +0200, Daniel Borkmann wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Add a new ->preclassify() op to allow multiqueue queuing disciplines
> to call tc_classify() or perform other work before dev_pick_tx().
> 
> This helps, for example, with mqprio queueing discipline that has
> offload support by most popular 10G NICs, where the txq effectively
> picks the qdisc.
> 
> Once traffic is being directed to a specific queue then hardware TX
> rings may be tuned to support this traffic type. mqprio already
> gives the ability to do this via skb->priority where the ->preclassify()
> provides more control over packet steering, it can classify the skb
> and set the priority, for example, from an eBPF classifier (or action).
> 
> Also this allows traffic classifiers to be run without holding the
> qdisc lock and gives one place to attach filters when mqprio is
> in use. ->preclassify() could also be added to other mq qdiscs later
> on: f.e. most classful qdiscs first check major/minor numbers of
> skb->priority before actually consulting a more complex classifier.
> 
> For mqprio case today, a filter has to be attached to each txq qdisc
> to have all traffic hit the filter. Since ->preclassify() is currently
> only used by mqprio, the __dev_queue_xmit() fast path is guarded by
> a generic, hidden Kconfig option (NET_CLS_PRECLASSIFY) that is only
> selected by mqprio,


So all distros will select it, basically.

...

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 877c848..b768bca 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3052,6 +3052,23 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
>  	rcu_read_lock_bh();
>  
>  	skb_update_prio(skb);
> +#ifdef CONFIG_NET_CLS_PRECLASSIFY
> +	q = rcu_dereference_bh(dev->qdisc);
> +	if (q && q->preclassify) {
> +		switch (q->preclassify(skb, q)) {
> +		default:
> +			break;
> +#ifdef CONFIG_NET_CLS_ACT
> +		case TC_ACT_SHOT:
> +		case TC_ACT_STOLEN:
> +		case TC_ACT_QUEUED:
> +			kfree_skb(skb);
> +			rc = NET_XMIT_SUCCESS;
> +			goto out;
> +#endif
> +		}
> +	}
> +#endif
>  

Since its a device attribute after all, why are you storing it in
dev->qdisc->preclassify, adding a cache line miss for moderate load ?

(mqprio/mq root qdisc is normally not fetched in fast path ?)

dev->preclassify would be better IMO, close to dev->_tx
