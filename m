From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]: fix queue limits in multiple qdiscs
Date: 17 Nov 2003 09:22:02 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1069076955.1076.23.camel@jzny.localdomain>
References: <3FB39A2D.5020000@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3FB39A2D.5020000@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


valid but Too cosmetic, IMO; (who cares when you are off by a few
bytes?)

cheers,
jamal

On Thu, 2003-11-13 at 09:50, Patrick McHardy wrote:
> This patch fixes multiple qdiscs exceeding their limits:
> 
> pfifo/pfifo_fast: by one packet
> bfifo/red/gred: by one full-sized packet in bytes
> 
> RED and GRED should never reach their limits so this part is
> more cosmetic than fix.
> 
> Best regards,
> Patrick
> 
> 
> ______________________________________________________________________
> 
> # This is a BitKeeper generated patch for the following project:
> # Project Name: Linux kernel tree
> # This patch format is intended for GNU patch command version 2.5 or higher.
> # This patch includes the following deltas:
> #	           ChangeSet	1.1431  -> 1.1432 
> #	net/sched/sch_generic.c	1.9     -> 1.10   
> #	net/sched/sch_teql.c	1.8     -> 1.9    
> #	net/sched/sch_fifo.c	1.6     -> 1.7    
> #	net/sched/sch_gred.c	1.12    -> 1.13   
> #	 net/sched/sch_red.c	1.8     -> 1.9    
> #
> # The following is the BitKeeper ChangeSet Log
> # --------------------------------------------
> # 03/11/12	kaber@trash.net	1.1432
> # Fix queue limits in multiple qdiscs
> # --------------------------------------------
> #
> diff -Nru a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
> --- a/net/sched/sch_fifo.c	Thu Nov 13 15:23:33 2003
> +++ b/net/sched/sch_fifo.c	Thu Nov 13 15:23:33 2003
> @@ -47,7 +47,7 @@
>  {
>  	struct fifo_sched_data *q = (struct fifo_sched_data *)sch->data;
>  
> -	if (sch->stats.backlog <= q->limit) {
> +	if (sch->stats.backlog + skb->len <= q->limit) {
>  		__skb_queue_tail(&sch->q, skb);
>  		sch->stats.backlog += skb->len;
>  		sch->stats.bytes += skb->len;
> @@ -108,7 +108,7 @@
>  {
>  	struct fifo_sched_data *q = (struct fifo_sched_data *)sch->data;
>  
> -	if (sch->q.qlen <= q->limit) {
> +	if (sch->q.qlen < q->limit) {
>  		__skb_queue_tail(&sch->q, skb);
>  		sch->stats.bytes += skb->len;
>  		sch->stats.packets++;
> diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> --- a/net/sched/sch_generic.c	Thu Nov 13 15:23:33 2003
> +++ b/net/sched/sch_generic.c	Thu Nov 13 15:23:33 2003
> @@ -275,7 +275,7 @@
>  	list = ((struct sk_buff_head*)qdisc->data) +
>  		prio2band[skb->priority&TC_PRIO_MAX];
>  
> -	if (list->qlen <= qdisc->dev->tx_queue_len) {
> +	if (list->qlen < qdisc->dev->tx_queue_len) {
>  		__skb_queue_tail(list, skb);
>  		qdisc->q.qlen++;
>  		qdisc->stats.bytes += skb->len;
> diff -Nru a/net/sched/sch_gred.c b/net/sched/sch_gred.c
> --- a/net/sched/sch_gred.c	Thu Nov 13 15:23:33 2003
> +++ b/net/sched/sch_gred.c	Thu Nov 13 15:23:33 2003
> @@ -110,7 +110,7 @@
>  	unsigned long	qave=0;	
>  	int i=0;
>  
> -	if (!t->initd && skb_queue_len(&sch->q) <= sch->dev->tx_queue_len) {
> +	if (!t->initd && skb_queue_len(&sch->q) < sch->dev->tx_queue_len) {
>  		D2PRINTK("NO GRED Queues setup yet! Enqueued anyway\n");
>  		goto do_enqueue;
>  	}
> @@ -175,7 +175,7 @@
>  	if ((q->qave+qave) < q->qth_min) {
>  		q->qcount = -1;
>  enqueue:
> -		if (q->backlog <= q->limit) {
> +		if (q->backlog + skb->len <= q->limit) {
>  			q->backlog += skb->len;
>  do_enqueue:
>  			__skb_queue_tail(&sch->q, skb);
> diff -Nru a/net/sched/sch_red.c b/net/sched/sch_red.c
> --- a/net/sched/sch_red.c	Thu Nov 13 15:23:33 2003
> +++ b/net/sched/sch_red.c	Thu Nov 13 15:23:33 2003
> @@ -257,7 +257,7 @@
>  	if (q->qave < q->qth_min) {
>  		q->qcount = -1;
>  enqueue:
> -		if (sch->stats.backlog <= q->limit) {
> +		if (sch->stats.backlog + skb->len <= q->limit) {
>  			__skb_queue_tail(&sch->q, skb);
>  			sch->stats.backlog += skb->len;
>  			sch->stats.bytes += skb->len;
