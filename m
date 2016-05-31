From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] hfsc: ensure class is added to eltree exactly once
Date: Tue, 31 May 2016 07:55:54 -0700
Message-ID: <1464706554.5939.105.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464689539-15162-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Miroslav Kratochvil <exa.exa@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36153 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754852AbcEaOz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 10:55:57 -0400
Received: by mail-pa0-f65.google.com with SMTP id fg1so25126308pad.3
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 07:55:57 -0700 (PDT)
In-Reply-To: <1464689539-15162-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-05-31 at 12:12 +0200, Florian Westphal wrote:
> Intent is to insert the class into the eligible tree when first packet
> is enqueued (its removed from list when class becomes empty again).
> 
> Checking for a size of 1 is problematic:
> 
> 1. child qdisc might have segmented the skb, in which backlog can transition
> from 0 to a value > 1.
> 
> In this case we can't dequeue anymore as this class is not in the tree.
> 
> 2. some qdiscs like fq_codel can purge their backlogs when internal
> limits are hit and update the parent qlen via qdisc_tree_reduce_backlog(),
> so its possible that we end up with a length of 1 after enqueue for a class
> that was already on the active list.
> 
> If this happens, we add the same class twice (which then results
> in qdisc dequeue soft lockup).
> 
> Fix it by testing the length before we attempt to enqueue to child qdisc,
> if enqueue operation is successful and old qlen was 0, then the
> class was not yet inserted into eltree.
> 
> Cc: Miroslav Kratochvil <exa.exa@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  This was found while looking at Miroslav Kratochvil bug report
>  but I don't think this fixes his case (I could trigger the 2nd case
>  above w. fq_codel+really_stupid_config_knobs but I got softlockup
>  which did not match his report).
> 
> diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
> index d783d7c..0854be3 100644
> --- a/net/sched/sch_hfsc.c
> +++ b/net/sched/sch_hfsc.c
> @@ -1583,6 +1583,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  {
>  	struct hfsc_class *cl;
>  	int uninitialized_var(err);
> +	unsigned int qlen;
>  
>  	cl = hfsc_classify(skb, sch, &err);
>  	if (cl == NULL) {
> @@ -1592,6 +1593,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		return err;
>  	}
>  
> +	qlen = cl->qdisc->q.qlen;
>  	err = qdisc_enqueue(skb, cl->qdisc);
>  	if (unlikely(err != NET_XMIT_SUCCESS)) {
>  		if (net_xmit_drop_count(err)) {
> @@ -1601,7 +1603,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		return err;
>  	}
>  
> -	if (cl->qdisc->q.qlen == 1)
> +	if (qlen == 0)
>  		set_active(cl, qdisc_pkt_len(skb));
>  
>  	sch->q.qlen++;

Well, I am not sure HFSC can deal with non work conserving qdisc
anyway ?

Call to set_active(cl, qdisc_pkt_len(skb)); would tell you that HFSC
does not expect another packet than @skb being the next dequeued one.

If you want to make HFSC generic, you would need a lot more changes.
