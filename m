From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net-sched 04/05: sch_htb: move hash and sibling list removal
	to htb_delete
Date: Wed, 2 Jul 2008 14:16:02 +0200
Message-ID: <20080702121602.GA2554@ami.dom.local>
References: <20080702081559.GA2764@ami.dom.local> <486B543A.8040608@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:9696 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755794AbYGBMQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 08:16:25 -0400
Received: by ug-out-1314.google.com with SMTP id h2so529506ugf.16
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2008 05:16:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <486B543A.8040608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 02, 2008 at 12:11:06PM +0200, Patrick McHardy wrote:
...
> commit c5b52f74c6b35a570995472295a5dae9d3d3ca74
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Wed Jul 2 12:10:36 2008 +0200
> 
>     net-sched: sch_htb: move hash and sibling list removal to htb_delete
>     
>     Hash list removal currently happens twice (once in htb_delete, once
>     in htb_destroy_class), which makes it harder to use the dynamically
>     sized class hash without adding special cases for HTB. The reason is
>     that qdisc destruction destroys class in hierarchical order, which

-     is not necessary if filters are destroyed in a seperate iteration
+     is not necessary if filters are destroyed in a separate iteration

>     during qdisc destruction.
>     
>     Adjust qdisc destruction to follow the same scheme as other hierarchical
>     qdiscs by first performing a filter destruction pass, then destroying
>     all classes in hash order.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

I think this patch is OK.

Jarek P.

> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 0284791..0d49930 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -1237,21 +1237,6 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
>  	qdisc_put_rtab(cl->ceil);
>  
>  	tcf_destroy_chain(&cl->filter_list);
> -
> -	while (!list_empty(&cl->children))
> -		htb_destroy_class(sch, list_entry(cl->children.next,
> -						  struct htb_class, sibling));
> -
> -	/* note: this delete may happen twice (see htb_delete) */
> -	hlist_del_init(&cl->hlist);
> -	list_del(&cl->sibling);
> -
> -	if (cl->prio_activity)
> -		htb_deactivate(q, cl);
> -
> -	if (cl->cmode != HTB_CAN_SEND)
> -		htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
> -
>  	kfree(cl);
>  }
>  
> @@ -1259,6 +1244,9 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
>  static void htb_destroy(struct Qdisc *sch)
>  {
>  	struct htb_sched *q = qdisc_priv(sch);
> +	struct hlist_node *n, *next;
> +	struct htb_class *cl;
> +	unsigned int i;
>  
>  	qdisc_watchdog_cancel(&q->watchdog);
>  	/* This line used to be after htb_destroy_class call below
> @@ -1267,10 +1255,14 @@ static void htb_destroy(struct Qdisc *sch)
>  	   unbind_filter on it (without Oops). */
>  	tcf_destroy_chain(&q->filter_list);
>  
> -	while (!list_empty(&q->root))
> -		htb_destroy_class(sch, list_entry(q->root.next,
> -						  struct htb_class, sibling));
> -
> +	for (i = 0; i < HTB_HSIZE; i++) {
> +		hlist_for_each_entry(cl, n, q->hash + i, hlist)
> +			tcf_destroy_chain(&cl->filter_list);
> +	}
> +	for (i = 0; i < HTB_HSIZE; i++) {
> +		hlist_for_each_entry_safe(cl, n, next, q->hash + i, hlist)
> +			htb_destroy_class(sch, cl);
> +	}
>  	__skb_queue_purge(&q->direct_queue);
>  }
>  
> @@ -1302,12 +1294,16 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
>  		qdisc_tree_decrease_qlen(cl->un.leaf.q, qlen);
>  	}
>  
> -	/* delete from hash and active; remainder in destroy_class */
> -	hlist_del_init(&cl->hlist);
> +	/* delete from hash, sibling list and active */
> +	hlist_del(&cl->hlist);
> +	list_del(&cl->sibling);
>  
>  	if (cl->prio_activity)
>  		htb_deactivate(q, cl);
>  
> +	if (cl->cmode != HTB_CAN_SEND)
> +		htb_safe_rb_erase(&cl->pq_node, q->wait_pq + cl->level);
> +
>  	if (last_child)
>  		htb_parent_to_leaf(q, cl, new_q);
>  

