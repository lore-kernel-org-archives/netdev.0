From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net-sched 04/05: sch_htb: move hash and sibling list removal
	to htb_delete
Date: Wed, 2 Jul 2008 10:15:59 +0200
Message-ID: <20080702081559.GA2764@ami.dom.local>
References: <20080701143415.26309.95825.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:48756 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbYGBIQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 04:16:38 -0400
Received: by ug-out-1314.google.com with SMTP id h2so508132ugf.16
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2008 01:16:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080701143415.26309.95825.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 07/01/2008 04:34 PM:
...
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 0284791..879f0b6 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -1238,14 +1238,6 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
>  
>  	tcf_destroy_chain(&cl->filter_list);
>  
> -	while (!list_empty(&cl->children))
> -		htb_destroy_class(sch, list_entry(cl->children.next,
> -						  struct htb_class, sibling));
> -
> -	/* note: this delete may happen twice (see htb_delete) */
> -	hlist_del_init(&cl->hlist);
> -	list_del(&cl->sibling);
> -
>  	if (cl->prio_activity)
>  		htb_deactivate(q, cl);

I'll try to check this all more later, but this probably "ain't" good:
during deactivation a class can use a parent class, so there would be
a use after kfree if it's not "parents after children". IMHO, it's
better to do a separate version of htb_destroy_class() for
htb_destroy(), and skip there htb_deactivate(), tcf_destroy_chain()
and htb_safe_rb_erase() which are not needed at the moment.

Regards,
Jarek P.

>  
> @@ -1259,6 +1251,9 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
>  static void htb_destroy(struct Qdisc *sch)
>  {
>  	struct htb_sched *q = qdisc_priv(sch);
> +	struct hlist_node *n, *next;
> +	struct htb_class *cl;
> +	unsigned int i;
>  
>  	qdisc_watchdog_cancel(&q->watchdog);
>  	/* This line used to be after htb_destroy_class call below
> @@ -1267,10 +1262,14 @@ static void htb_destroy(struct Qdisc *sch)
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
> @@ -1302,8 +1301,9 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
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
