From: Florian Westphal <fw@strlen.de>
Subject: Re: [net] fq_codel: fix NET_XMIT_CN behavior
Date: Sat, 4 Jun 2016 21:03:01 +0200
Message-ID: <20160604190301.GA8857@strlen.de>
References: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stas Nichiporovich <stasn77@gmail.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50288 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750884AbcFDTCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 15:02:40 -0400
Content-Disposition: inline
In-Reply-To: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> My prior attempt to fix the backlogs of parents failed.
> 
> If we return NET_XMIT_CN, our parents wont increase their backlog,
> so our qdisc_tree_reduce_backlog() should take this into account.

[..]

> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index 6883a8971562..c57ec480a2da 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -240,11 +240,19 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  	q->drop_overlimit += prev_qlen - sch->q.qlen;
>  	if (memory_limited)
>  		q->drop_overmemory += prev_qlen - sch->q.qlen;
> -	/* As we dropped packet(s), better let upper stack know this */
> -	qdisc_tree_reduce_backlog(sch, prev_qlen - sch->q.qlen,
> -				  prev_backlog - sch->qstats.backlog);
> -
> -	return ret == idx ? NET_XMIT_CN : NET_XMIT_SUCCESS;
> +	/* As we dropped packet(s), better let upper stack know this.
> +	 * If we dropped a packet for this flow, return NET_XMIT_CN,
> +	 * but in this case, our parents wont increase their backlogs.
> +	 */
> +	prev_qlen -= sch->q.qlen;
> +	prev_backlog -= sch->qstats.backlog;
> +	if (ret == idx) {
> +		qdisc_tree_reduce_backlog(sch, prev_qlen - 1,
> +					  prev_backlog - qdisc_pkt_len(skb));
> +		return NET_XMIT_CN;

Is skb still valid here? AFAICS its possible that fq_codel_drop() drops it.

Other than that this looks good, thanks Eric!
