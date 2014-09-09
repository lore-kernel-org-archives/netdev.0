From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 07/15] net: sched: RCU cls_route
Date: Tue, 09 Sep 2014 05:59:13 -0700
Message-ID: <1410267553.11872.167.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32>
	 <20140909055703.2071.75757.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:49712 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756310AbaIIM7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 08:59:15 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so6923590pdb.11
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 05:59:15 -0700 (PDT)
In-Reply-To: <20140909055703.2071.75757.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 22:57 -0700, John Fastabend wrote:
> RCUify the route classifier. For now however spinlock's are used to
> protect fastmap cache.
> 
> The issue here is the fastmap may be read by one CPU while the
> cache is being updated by another. An array of pointers could be
> one possible solution.

Yep, this doesnt seem like an urgent issue anyway.

> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

...

>  
>  static void route4_destroy(struct tcf_proto *tp)
>  {
> -	struct route4_head *head = tp->root;
> +	struct route4_head *head = rtnl_dereference(tp->root);
>  	int h1, h2;
>  
>  	if (head == NULL)
> @@ -266,28 +287,35 @@ static void route4_destroy(struct tcf_proto *tp)
>  	for (h1 = 0; h1 <= 256; h1++) {
>  		struct route4_bucket *b;
>  
> -		b = head->table[h1];
> +		b = rtnl_dereference(head->table[h1]);
>  		if (b) {
>  			for (h2 = 0; h2 <= 32; h2++) {
>  				struct route4_filter *f;
>  
> -				while ((f = b->ht[h2]) != NULL) {
> -					b->ht[h2] = f->next;
> -					route4_delete_filter(tp, f);
> +				while ((f = rtnl_dereference(b->ht[h2])) != NULL) {
> +					struct route4_filter *next;
> +
> +					next = rtnl_dereference(f->next);
> +					rcu_assign_pointer(b->ht[h2], next);

	RCU_INIT_POINTER(), or simply : b->ht[h2] = f->next;

> +					call_rcu(&f->rcu, route4_delete_filter);
>  				}
>  			}
> -			kfree(b);
> +			RCU_INIT_POINTER(head->table[h1], NULL);
> +			kfree_rcu(b, rcu);
>  		}
>  	}
> -	kfree(head);
> +	RCU_INIT_POINTER(tp->root, NULL);
> +	kfree_rcu(head, rcu);
>  }
>  
>  static int route4_delete(struct tcf_proto *tp, unsigned long arg)
>  {
> -	struct route4_head *head = tp->root;
> -	struct route4_filter **fp, *f = (struct route4_filter *)arg;
> -	unsigned int h = 0;
> +	struct route4_head *head = rtnl_dereference(tp->root);
> +	struct route4_filter *f = (struct route4_filter *)arg;
> +	struct route4_filter __rcu **fp;
> +	struct route4_filter *nf;
>  	struct route4_bucket *b;
> +	unsigned int h = 0;
>  	int i;
>  
>  	if (!head || !f)
> @@ -296,27 +324,35 @@ static int route4_delete(struct tcf_proto *tp, unsigned long arg)
>  	h = f->handle;
>  	b = f->bkt;
>  
> -	for (fp = &b->ht[from_hash(h >> 16)]; *fp; fp = &(*fp)->next) {
> -		if (*fp == f) {
> -			tcf_tree_lock(tp);
> +	fp = &b->ht[from_hash(h >> 16)];
> +	for (nf = rtnl_dereference(*fp); nf;
> +	     fp = &nf->next, nf = rtnl_dereference(*fp)) {
> +		if (nf == f) {
> +			/* unlink it */
>  			*fp = f->next;

Strange you left this without annotations, while rest of your patches
always use rcu_assign_pointer(*fp, rtnl_dereference(f->next)

Note that it is absolutely fine to use *fp = f->next;

;)

> -			tcf_tree_unlock(tp);
>  
