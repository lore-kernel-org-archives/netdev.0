From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [NET_SCHED 06/06]: Fix endless loops (part 4): HTB
Date: Thu, 23 Nov 2006 09:39:09 +0100
Message-ID: <20061123083909.GA1586@ff.dom.local>
References: <20061120130848.22347.85130.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:17026 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1757222AbWKWIcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 03:32:45 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20061120130848.22347.85130.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20-11-2006 14:08, Patrick McHardy wrote:
> [NET_SCHED]: Fix endless loops (part 4): HTB
> 
> Convert HTB to use qdisc_tree_decrease_len() and add a callback
> for deactivating a class when its child queue becomes empty.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> ---
... 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 3b36e9d..215e68c 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -1230,11 +1230,7 @@ static int htb_graft(struct Qdisc *sch, 
>  			return -ENOBUFS;
>  		sch_tree_lock(sch);
>  		if ((*old = xchg(&cl->un.leaf.q, new)) != NULL) {
> -			if (cl->prio_activity)
> -				htb_deactivate(qdisc_priv(sch), cl);
> -
> -			/* TODO: is it correct ? Why CBQ doesn't do it ? */
> -			sch->q.qlen -= (*old)->q.qlen;
> +			qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
>  			qdisc_reset(*old);
>  		}
>  		sch_tree_unlock(sch);
> @@ -1249,6 +1245,14 @@ static struct Qdisc *htb_leaf(struct Qdi
>  	return (cl && !cl->level) ? cl->un.leaf.q : NULL;
>  }
>  
> +static void htb_qlen_notify(struct Qdisc *sch, unsigned long arg)
> +{
> +	struct htb_class *cl = (struct htb_class *)arg;
> +
> +	if (cl->un.leaf.q->q.qlen == 0)

Probably "if (cl->prio_activity)" is needed here.

> +		htb_deactivate(qdisc_priv(sch), cl);
> +}
> +

Regards,

Jarek P.

PS: from 00/06:
> PS: If anyone wants to suggest a nicer name for qdisc_tree_decrease_qlen
> I'll gladly send new patches :)

Increasing is nicer so maybe: qdisc_tree_increase_qlen?

