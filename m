From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] sched: only dequeue if packet can be queued to
 hardware queue.
Date: Thu, 18 Sep 2008 02:46:55 -0700 (PDT)
Message-ID: <20080918.024655.22661052.davem@davemloft.net>
References: <20080918063036.27934.91273.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, kaber@trash.net
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32813
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754743AbYIRJrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 05:47:07 -0400
In-Reply-To: <20080918063036.27934.91273.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 17 Sep 2008 23:43:02 -0700

> diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
> index 43d3725..91a40b2 100644
> --- a/net/sched/sch_atm.c
> +++ b/net/sched/sch_atm.c
> @@ -516,12 +516,31 @@ static struct sk_buff *atm_tc_dequeue(struct Qdisc *sch)
>  
>  	pr_debug("atm_tc_dequeue(sch %p,[qdisc %p])\n", sch, p);
>  	tasklet_schedule(&p->task);
> -	skb = p->link.q->dequeue(p->link.q);
> +	skb = p->link.q->ops->dequeue(p->link.q);
>  	if (skb)
>  		sch->q.qlen--;
>  	return skb;
>  }
>  

So what is the difference between qdisc->dequeue and qdisc->ops->dequeue?
The same applies to ->enqueue.

qdisc->{dequeue,enqueue} are given the value of ops->{dequeue,enqueue}
at the time of qdisc creation.  I can only see two reasons for their
existence:

1) We used to allow overriding ->enqueue and ->dequeue by certain
   modules.  I see no such use like this in the current tree.

2) For performance it's kept as a copy in the qdisc.

Either way, changing ->ops->dequeue into ->dequeue doesn't seem to be
correct, unless you have some explanation.

This is done in a few other places in your patch.

