From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 03/14] net: sched: cls_basic use RCU
Date: Mon, 10 Mar 2014 10:33:32 -0700
Message-ID: <1394472812.3607.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	 <20140310170430.3011.44421.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:44986 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851AbaCJRdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:33:33 -0400
Received: by mail-pa0-f47.google.com with SMTP id lj1so7513627pab.6
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:33:33 -0700 (PDT)
In-Reply-To: <20140310170430.3011.44421.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 10:04 -0700, John Fastabend wrote:
> Enable basic classifier for RCU.
> 
> Dereferencing tp->root may look a bit strange here but it is needed
> by my accounting because it is allocated at init time and needs to
> be kfree'd at destroy time. However because it may be referenced in
> the classify() path we must wait an RCU grace period before free'ing
> it. We use kfree_rcu() and rcu_ APIs to enforce this. This pattern
> is used in all the classifiers.
> 
> Also the hgenerator can be incremented without concern because it
> is always incremented under RTNL.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_basic.c |   80 ++++++++++++++++++++++++++++---------------------
>  1 file changed, 45 insertions(+), 35 deletions(-)
> 
> diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
> index e98ca99..68037f0 100644
> --- a/net/sched/cls_basic.c
> +++ b/net/sched/cls_basic.c
> @@ -24,6 +24,7 @@
>  struct basic_head {
>  	u32			hgenerator;
>  	struct list_head	flist;
> +	struct rcu_head		rcu;
>  };
>  
>  struct basic_filter {
> @@ -31,17 +32,19 @@ struct basic_filter {
>  	struct tcf_exts		exts;
>  	struct tcf_ematch_tree	ematches;
>  	struct tcf_result	res;
> +	struct tcf_proto	*tp;
>  	struct list_head	link;
> +	struct rcu_head		rcu;
>  };
>  
>  static int basic_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  			  struct tcf_result *res)
>  {
>  	int r;
> -	struct basic_head *head = tp->root;
> +	struct basic_head *head = rcu_dereference_bh(tp->root);
>  	struct basic_filter *f;
>  
> -	list_for_each_entry(f, &head->flist, link) {
> +	list_for_each_entry_rcu(f, &head->flist, link) {
>  		if (!tcf_em_tree_match(skb, &f->ematches, NULL))
>  			continue;
>  		*res = f->res;
> @@ -56,7 +59,7 @@ static int basic_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  static unsigned long basic_get(struct tcf_proto *tp, u32 handle)
>  {
>  	unsigned long l = 0UL;
> -	struct basic_head *head = tp->root;
> +	struct basic_head *head = rtnl_dereference(tp->root);
>  	struct basic_filter *f;
>  
>  	if (head == NULL)
> @@ -81,12 +84,15 @@ static int basic_init(struct tcf_proto *tp)
>  	if (head == NULL)
>  		return -ENOBUFS;
>  	INIT_LIST_HEAD(&head->flist);
> -	tp->root = head;
> +	rcu_assign_pointer(tp->root, head);
>  	return 0;
>  }
>  
> -static void basic_delete_filter(struct tcf_proto *tp, struct basic_filter *f)
> +static void basic_delete_filter(struct rcu_head *head)
>  {
> +	struct basic_filter *f = container_of(head, struct basic_filter, rcu);
> +	struct tcf_proto *tp = f->tp;
> +
>  	tcf_unbind_filter(tp, &f->res);
>  	tcf_exts_destroy(tp, &f->exts);
>  	tcf_em_tree_destroy(tp, &f->ematches);
> @@ -95,27 +101,26 @@ static void basic_delete_filter(struct tcf_proto *tp, struct basic_filter *f)
>  
>  static void basic_destroy(struct tcf_proto *tp)
>  {
> -	struct basic_head *head = tp->root;
> +	struct basic_head *head = rtnl_dereference(tp->root);
>  	struct basic_filter *f, *n;
>  
>  	list_for_each_entry_safe(f, n, &head->flist, link) {
> -		list_del(&f->link);
> -		basic_delete_filter(tp, f);
> +		list_del_rcu(&f->link);
> +		call_rcu(&f->rcu, basic_delete_filter);
>  	}
> -	kfree(head);
> +	rcu_assign_pointer(tp->root, NULL);

same remark here (please check all your 
rcu_assign_pointer(xxxxxx, NULL); )

Otherwise, SGTM, thanks.
