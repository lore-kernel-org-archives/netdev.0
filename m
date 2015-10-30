From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next v2 2/4] net_sched: update hierarchical backlog
 too
Date: Fri, 30 Oct 2015 12:30:50 -0700
Message-ID: <1446233450.6254.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1446229351-13412-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1446229351-13412-3-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36726 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458AbbJ3Taw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 15:30:52 -0400
Received: by pacfv9 with SMTP id fv9so85980946pac.3
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 12:30:51 -0700 (PDT)
In-Reply-To: <1446229351-13412-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-30 at 11:22 -0700, Cong Wang wrote:
> When the bottom qdisc decides to, for example, drop some packet,
> it calls qdisc_tree_decrease_qlen() to update the queue length
> for all its ancestors, we need to update the backlog too to
> keep the stats on root qdisc accurate.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

...

>  
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 3abab53..498f0a2 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -346,7 +346,7 @@ static int
>  sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  {
>  	struct sfq_sched_data *q = qdisc_priv(sch);
> -	unsigned int hash;
> +	unsigned int hash, dropped;
>  	sfq_index x, qlen;
>  	struct sfq_slot *slot;
>  	int uninitialized_var(ret);
> @@ -461,7 +461,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		return NET_XMIT_SUCCESS;
>  
>  	qlen = slot->qlen;
> -	sfq_drop(sch);
> +	dropped = sfq_drop(sch);
>  	/* Return Congestion Notification only if we dropped a packet
>  	 * from this flow.
>  	 */
> @@ -469,7 +469,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		return NET_XMIT_CN;


I believe you missed the NET_XMIT_CN cases.

SFQ can drop a prior packet, and queue current packet.

qdisc_tree_reduce_backlog() wont be called to update parents.

Not sure about other qdisc(s)
