From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 06/14] net: sched: fw use RCU
Date: Mon, 10 Mar 2014 10:41:19 -0700
Message-ID: <1394473279.3607.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	 <20140310170546.3011.82918.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:34559 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957AbaCJRlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:41:21 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so7558087pbb.25
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:41:20 -0700 (PDT)
In-Reply-To: <20140310170546.3011.82918.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 10:05 -0700, John Fastabend wrote:
> RCU'ify fw classifier.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_fw.c |  110 ++++++++++++++++++++++++++++++++++++----------------
>  1 file changed, 76 insertions(+), 34 deletions(-)
> 
> diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
> index a366537..ff392f1 100644
> --- a/net/sched/cls_fw.c
> +++ b/net/sched/cls_fw.c
> @@ -32,18 +32,21 @@
>  #define HTSIZE (PAGE_SIZE/sizeof(struct fw_filter *))
>  
>  struct fw_head {
> -	struct fw_filter *ht[HTSIZE];
> +	struct rcu_head	rcu;

Try to put 'rcu' at the end of structures, we do not need it in fast
path.

> +	struct fw_filter __rcu *ht[HTSIZE];
>  	u32 mask;
>  };
>  
>  struct fw_filter {
> -	struct fw_filter	*next;
> +	struct fw_filter __rcu	*next;
> +	struct rcu_head		rcu;

same remark

>  	u32			id;
>  	struct tcf_result	res;
>  #ifdef CONFIG_NET_CLS_IND
>  	int			ifindex;
>  #endif /* CONFIG_NET_CLS_IND */
>  	struct tcf_exts		exts;
> +	struct tcf_proto	*tp;
>  };
>  
>  static inline int fw_hash(u32 handle)
> @@ -75,14 +78,16 @@ static inline int fw_hash(u32 handle)
>  static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  			  struct tcf_result *res)
>  {
> -	struct fw_head *head = tp->root;
> +	struct fw_head *head = rcu_dereference_bh(tp->root);
>  	struct fw_filter *f;
>  	int r;
>  	u32 id = skb->mark;
>  
>  	if (head != NULL) {
>  		id &= head->mask;
> -		for (f = head->ht[fw_hash(id)]; f; f = f->next) {
> +
> +		for (f = rcu_dereference_bh(head->ht[fw_hash(id)]); f;
> +		     f = rcu_dereference_bh(f->next)) {
>  			if (f->id == id) {
>  				*res = f->res;
>  #ifdef CONFIG_NET_CLS_IND
> @@ -111,13 +116,14 @@ static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  
>  static unsigned long fw_get(struct tcf_proto *tp, u32 handle)
>  {
> -	struct fw_head *head = tp->root;
> +	struct fw_head *head = rtnl_dereference(tp->root);
>  	struct fw_filter *f;
>  
>  	if (head == NULL)
>  		return 0;
>  
> -	for (f = head->ht[fw_hash(handle)]; f; f = f->next) {
> +	f = rtnl_dereference(head->ht[fw_hash(handle)]);
> +	for (; f; f = rtnl_dereference(f->next)) {
>  		if (f->id == handle)
>  			return (unsigned long)f;
>  	}
> @@ -133,8 +139,11 @@ static int fw_init(struct tcf_proto *tp)
>  	return 0;
>  }
>  
> -static void fw_delete_filter(struct tcf_proto *tp, struct fw_filter *f)
> +static void fw_delete_filter(struct rcu_head *head)
>  {
> +	struct fw_filter *f = container_of(head, struct fw_filter, rcu);
> +	struct tcf_proto *tp = f->tp;
> +
>  	tcf_unbind_filter(tp, &f->res);
>  	tcf_exts_destroy(tp, &f->exts);
>  	kfree(f);
> @@ -142,7 +151,7 @@ static void fw_delete_filter(struct tcf_proto *tp, struct fw_filter *f)
>  
>  static void fw_destroy(struct tcf_proto *tp)
>  {
> -	struct fw_head *head = tp->root;
> +	struct fw_head *head = rtnl_dereference(tp->root);
>  	struct fw_filter *f;
>  	int h;
>  
> @@ -150,29 +159,32 @@ static void fw_destroy(struct tcf_proto *tp)
>  		return;
>  
>  	for (h = 0; h < HTSIZE; h++) {
> -		while ((f = head->ht[h]) != NULL) {
> -			head->ht[h] = f->next;
> -			fw_delete_filter(tp, f);
> +		while ((f = rtnl_dereference(head->ht[h])) != NULL) {
> +			rcu_assign_pointer(head->ht[h],
> +					   rtnl_dereference(f->next));
> +			call_rcu(&f->rcu, fw_delete_filter);
>  		}
>  	}
> -	kfree(head);
> +	rcu_assign_pointer(tp->root, NULL);

RCU_INIT_POINTER

> +	kfree_rcu(head, rcu);
>  }
>  


rest seems fine.
