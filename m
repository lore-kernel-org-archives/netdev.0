From: Jan 'yanek' Bortl <yanek@ya.bofh.cz>
Subject: Re: PROBLEM: kernel lockup while changing TC rules
Date: Sat, 03 May 2008 19:26:15 +0200
Message-ID: <481CA037.3000909@ya.bofh.cz>
References: <20080503071651.GA3313@ami.dom.local> <481C33D2.2090308@ya.bofh.cz> <20080503163939.GA6484@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlantis.mitranet.cz ([62.240.190.34]:34829 "EHLO
	atlantis.mitranet.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761882AbYECR0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 13:26:24 -0400
In-Reply-To: <20080503163939.GA6484@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> ...
> 
> Here is a suspect #1. (BTW, this place reminds me something...)

Great! Seems to solve my problem. I'll do some tests.

Thank you!

> 
> Thanks,
> Jarek P.
> 
> ---
> 
>  net/sched/sch_htb.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 66148cc..5bc1ed4 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -1197,12 +1197,16 @@ static inline int htb_parent_last_child(struct htb_class *cl)
>  	return 1;
>  }
>  
> -static void htb_parent_to_leaf(struct htb_class *cl, struct Qdisc *new_q)
> +static void htb_parent_to_leaf(struct htb_sched *q, struct htb_class *cl,
> +			       struct Qdisc *new_q)
>  {
>  	struct htb_class *parent = cl->parent;
>  
>  	BUG_TRAP(!cl->level && cl->un.leaf.q && !cl->prio_activity);
>  
> +	if (parent->cmode != HTB_CAN_SEND)
> +		htb_safe_rb_erase(&parent->pq_node, q->wait_pq + parent->level);
> +
>  	parent->level = 0;
>  	memset(&parent->un.inner, 0, sizeof(parent->un.inner));
>  	INIT_LIST_HEAD(&parent->un.leaf.drop_list);
> @@ -1300,7 +1304,7 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
>  		htb_deactivate(q, cl);
>  
>  	if (last_child)
> -		htb_parent_to_leaf(cl, new_q);
> +		htb_parent_to_leaf(q, cl, new_q);
>  
>  	if (--cl->refcnt == 0)
>  		htb_destroy_class(sch, cl);

-- 
Jan 'yanek' Bortl <yanek [at] ya.bofh. cz>
http://ya.bofh.cz/ | jab: yanek [at] mitranet. cz
-----------------------------------------------------------------
"Maybe one day you will learn that your way is not the only way."
                                         Opher [StarGate: The Nox]
