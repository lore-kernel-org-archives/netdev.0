From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 04/14] net: sched: cls_cgroup use RCU
Date: Mon, 10 Mar 2014 10:36:30 -0700
Message-ID: <1394472990.3607.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	 <20140310170452.3011.33596.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:41211 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753649AbaCJRgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:36:32 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so7551965pbb.25
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:36:32 -0700 (PDT)
In-Reply-To: <20140310170452.3011.33596.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 10:04 -0700, John Fastabend wrote:
> Make cgroup classifier safe for RCU.
> 
> Also drops the calls in the classify routine that were doing a
> rcu_read_lock()/rcu_read_unlock(). If the rcu_read_lock() isn't held
> entering this routine we have issues with deleting the classifier
> chain so remove the unnecessary rcu_read_lock()/rcu_read_unlock()
> pair noting all paths AFAIK hold rcu_read_lock.
> 
> If there is a case where classify is called without the rcu read lock
> then an rcu splat will occur and we can correct it.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_cgroup.c |   65 ++++++++++++++++++++++++++++++------------------
>  1 file changed, 41 insertions(+), 24 deletions(-)
> 
> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> index 8e2158a..4919978 100644
> --- a/net/sched/cls_cgroup.c
> +++ b/net/sched/cls_cgroup.c
> @@ -22,17 +22,17 @@ struct cls_cgroup_head {
>  	u32			handle;
>  	struct tcf_exts		exts;
>  	struct tcf_ematch_tree	ematches;
> +	struct rcu_head		rcu;
> +	struct tcf_proto	*tp;

Move rcu_head at the end ?

>  };
>  
>  static int cls_cgroup_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>  			       struct tcf_result *res)
>  {
> -	struct cls_cgroup_head *head = tp->root;
> +	struct cls_cgroup_head *head = rcu_dereference_bh(tp->root);
>  	u32 classid;
>  
> -	rcu_read_lock();
>  	classid = task_cls_state(current)->classid;
> -	rcu_read_unlock();
>  
>  	/*
>  	 * Due to the nature of the classifier it is required to ignore all
> @@ -80,13 +80,27 @@ static const struct nla_policy cgroup_policy[TCA_CGROUP_MAX + 1] = {
>  	[TCA_CGROUP_EMATCHES]	= { .type = NLA_NESTED },
>  };
>  
> +static void cls_cgroup_destroy_rcu(struct rcu_head *root)
> +{
> +	struct cls_cgroup_head *head = container_of(root,
> +						    struct cls_cgroup_head,
> +						    rcu);
> +
> +	if (head) {

How head could be NULL ?

> +		tcf_exts_destroy(head->tp, &head->exts);
> +		tcf_em_tree_destroy(head->tp, &head->ematches);
> +		kfree(head);
> +	}
> +}
> +
>  static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
>  			     struct tcf_proto *tp, unsigned long base,
>  			     u32 handle, struct nlattr **tca,
>  			     unsigned long *arg)
>  {
>  	struct nlattr *tb[TCA_CGROUP_MAX + 1];
> -	struct cls_cgroup_head *head = tp->root;
> +	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
> +	struct cls_cgroup_head *new;
>  	struct tcf_ematch_tree t;
>  	struct tcf_exts e;
>  	int err;
> @@ -94,25 +108,24 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
>  	if (!tca[TCA_OPTIONS])
>  		return -EINVAL;
>  
> -	if (head == NULL) {
> -		if (!handle)
> -			return -EINVAL;
> +	if (!head && !handle)
> +		return -EINVAL;
>  
> -		head = kzalloc(sizeof(*head), GFP_KERNEL);
> -		if (head == NULL)
> -			return -ENOBUFS;
> +	if (head && handle != head->handle)
> +		return -ENOENT;
>  
> -		tcf_exts_init(&head->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
> -		head->handle = handle;
> +	new = kzalloc(sizeof(*head), GFP_KERNEL);
> +	if (!new)
> +		return -ENOBUFS;
>  
> -		tcf_tree_lock(tp);
> -		tp->root = head;
> -		tcf_tree_unlock(tp);
> +	if (head) {
> +		new->handle = head->handle;
> +	} else {
> +		tcf_exts_init(&new->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
> +		new->handle = handle;
>  	}
>  
> -	if (handle != head->handle)
> -		return -ENOENT;
> -
> +	new->tp = tp;
>  	err = nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS],
>  			       cgroup_policy);
>  	if (err < 0)
> @@ -127,20 +140,24 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
>  	if (err < 0)
>  		return err;
>  
> -	tcf_exts_change(tp, &head->exts, &e);
> -	tcf_em_tree_change(tp, &head->ematches, &t);
> +	tcf_exts_change(tp, &new->exts, &e);
> +	tcf_em_tree_change(tp, &new->ematches, &t);
>  
> +	rcu_assign_pointer(tp->root, new);
> +	if (head)
> +		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
>  	return 0;
>  }
>  
>  static void cls_cgroup_destroy(struct tcf_proto *tp)
>  {
> -	struct cls_cgroup_head *head = tp->root;
> +	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
>  
>  	if (head) {
>  		tcf_exts_destroy(tp, &head->exts);
>  		tcf_em_tree_destroy(tp, &head->ematches);
> -		kfree(head);
> +		rcu_assign_pointer(tp->root, NULL);

RCU_INIT_POINTER

> +		kfree_rcu(head, rcu);
>  	}
>  }
>  
> @@ -151,7 +168,7 @@ static int cls_cgroup_delete(struct tcf_proto *tp, unsigned long arg)
>  
>  static void cls_cgroup_walk(struct tcf_proto *tp, struct tcf_walker *arg)
>  {
> -	struct cls_cgroup_head *head = tp->root;
> +	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
>  
>  	if (arg->count < arg->skip)
>  		goto skip;
> @@ -167,7 +184,7 @@ skip:
>  static int cls_cgroup_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
>  			   struct sk_buff *skb, struct tcmsg *t)
>  {
> -	struct cls_cgroup_head *head = tp->root;
> +	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
>  	unsigned char *b = skb_tail_pointer(skb);
>  	struct nlattr *nest;
>  

Otherwise SGTM, thanks.
