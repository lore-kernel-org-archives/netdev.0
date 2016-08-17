From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 07/13] net: sched: support qdisc_reset on NOLOCK
 qdisc
Date: Wed, 17 Aug 2016 15:53:01 -0700
Message-ID: <1471474381.29842.51.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
	 <20160817193622.27032.73296.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, brouer@redhat.com,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36061 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbcHQXIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:08:10 -0400
Received: by mail-pa0-f66.google.com with SMTP id ez1so214752pab.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 16:08:10 -0700 (PDT)
In-Reply-To: <20160817193622.27032.73296.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-17 at 12:36 -0700, John Fastabend wrote:
> The qdisc_reset operation depends on the qdisc lock at the moment
> to halt any additions to gso_skb and statistics while the list is
> free'd and the stats zeroed.

...

> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/sch_generic.c |   45 +++++++++++++++++++++++++++++++++++----------
>  1 file changed, 35 insertions(+), 10 deletions(-)
> 
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 3b9a21f..29238c4 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -737,6 +737,20 @@ void qdisc_reset(struct Qdisc *qdisc)
>  	kfree_skb(qdisc->skb_bad_txq);
>  	qdisc->skb_bad_txq = NULL;
>  
> +	if (qdisc->gso_cpu_skb) {
> +		int i;
> +
> +		for_each_possible_cpu(i) {
> +			struct gso_cell *cell;
> +
> +			cell = per_cpu_ptr(qdisc->gso_cpu_skb, i);
> +			if (cell) {
> +				kfree_skb_list(cell->skb);
> +				cell = NULL;

	You probably wanted :
			cell->skb = NULL;


> +			}
> +		}
> +	}
> +
>  	if (qdisc->gso_skb) {
>  		kfree_skb_list(qdisc->gso_skb);
>  		qdisc->gso_skb = NULL;
> @@ -812,10 +826,6 @@ struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
>  	root_lock = qdisc_lock(oqdisc);
>  	spin_lock_bh(root_lock);
>  
> -	/* Prune old scheduler */
> -	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
> -		qdisc_reset(oqdisc);
> -
>  

This probably belongs to a separate patch, before any per cpu / lockless
qdisc changes ?
