From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]: Adjust qlen when grafting in multiple qdiscs
Date: 17 Nov 2003 09:22:01 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1069076786.1075.19.camel@jzny.localdomain>
References: <3FB3996A.6080008@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3FB3996A.6080008@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Did you test some of this stuff or just did a mass-edit? I havent paid
attention to all the details, but what would decrementing sch->q.qlen on
grafting mean on a dsmark? 

cheers,
jamal

On Thu, 2003-11-13 at 09:47, Patrick McHardy wrote:
> Hi Dave,
> 
> multiple qdiscs fail to adjust sch->q.qlen after grafting when the
> old qdisc is non-empty. This permanently damages the counter.
> TBF additionally needs to adjust stats.backlog.
> 
> Best regards,
> Patrick
> 
> 
> 
> ______________________________________________________________________
> 
> # This is a BitKeeper generated patch for the following project:
> # Project Name: Linux kernel tree
> # This patch format is intended for GNU patch command version 2.5 or higher.
> # This patch includes the following deltas:
> #	           ChangeSet	1.1427  -> 1.1428 
> #	 net/sched/sch_tbf.c	1.10    -> 1.11   
> #	 net/sched/sch_cbq.c	1.13    -> 1.14   
> #	net/sched/sch_dsmark.c	1.10    -> 1.11   
> #	net/sched/sch_prio.c	1.9     -> 1.10   
> #
> # The following is the BitKeeper ChangeSet Log
> # --------------------------------------------
> # 03/11/12	kaber@trash.net	1.1428
> # Adjust qlen when grafting in multiple qdiscs
> # --------------------------------------------
> #
> diff -Nru a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
> --- a/net/sched/sch_cbq.c	Thu Nov 13 14:57:07 2003
> +++ b/net/sched/sch_cbq.c	Thu Nov 13 14:57:07 2003
> @@ -1670,6 +1670,7 @@
>  		sch_tree_lock(sch);
>  		*old = cl->q;
>  		cl->q = new;
> +		sch->q.qlen -= (*old)->q.qlen;
>  		qdisc_reset(*old);
>  		sch_tree_unlock(sch);
>  
> diff -Nru a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
> --- a/net/sched/sch_dsmark.c	Thu Nov 13 14:57:07 2003
> +++ b/net/sched/sch_dsmark.c	Thu Nov 13 14:57:07 2003
> @@ -75,8 +75,10 @@
>  		new = &noop_qdisc;
>  	sch_tree_lock(sch);
>  	*old = xchg(&p->q,new);
> -	if (*old)
> +	if (*old) {
> +		sch->q.qlen -= (*old)->q.qlen;
>  		qdisc_reset(*old);
> +	}
>  	sch_tree_unlock(sch); /* @@@ move up ? */
>          return 0;
>  }
> diff -Nru a/net/sched/sch_prio.c b/net/sched/sch_prio.c
> --- a/net/sched/sch_prio.c	Thu Nov 13 14:57:07 2003
> +++ b/net/sched/sch_prio.c	Thu Nov 13 14:57:07 2003
> @@ -266,6 +266,7 @@
>  	sch_tree_lock(sch);
>  	*old = q->queues[band];
>  	q->queues[band] = new;
> +	sch->q.qlen -= (*old)->q.qlen;
>  	qdisc_reset(*old);
>  	sch_tree_unlock(sch);
>  
> diff -Nru a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> --- a/net/sched/sch_tbf.c	Thu Nov 13 14:57:07 2003
> +++ b/net/sched/sch_tbf.c	Thu Nov 13 14:57:07 2003
> @@ -455,6 +455,8 @@
>  	sch_tree_lock(sch);	
>  	*old = xchg(&q->qdisc, new);
>  	qdisc_reset(*old);
> +	sch->q.qlen = 0;
> +	sch->stats.backlog = 0;
>  	sch_tree_unlock(sch);
>  	
>  	return 0;
