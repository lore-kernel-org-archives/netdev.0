From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next v3 5/5] net_sched: act: clean up tca_action_flush()
Date: Wed, 12 Feb 2014 07:44:32 -0500
Message-ID: <52FB6CB0.3030801@mojatatu.com>
References: <1392167255-21744-1-git-send-email-xiyou.wangcong@gmail.com> <1392167255-21744-6-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:45112 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752366AbaBLMof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 07:44:35 -0500
Received: by mail-ig0-f170.google.com with SMTP id m12so1567958iga.1
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 04:44:34 -0800 (PST)
In-Reply-To: <1392167255-21744-6-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/14 20:07, Cong Wang wrote:
> We could allocate tc_action on stack in tca_action_flush(),
> since it is not large.
>
> Also, we could use create_a() in tcf_action_get_1().
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

> ---
>   net/sched/act_api.c | 53 +++++++++++++++++++++++------------------------------
>   1 file changed, 23 insertions(+), 30 deletions(-)
>
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index 27e4c53..8a5ba5a 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -685,6 +685,20 @@ act_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
>   	return rtnl_unicast(skb, net, portid);
>   }
>
> +static struct tc_action *create_a(int i)
> +{
> +	struct tc_action *act;
> +
> +	act = kzalloc(sizeof(*act), GFP_KERNEL);
> +	if (act == NULL) {
> +		pr_debug("create_a: failed to alloc!\n");
> +		return NULL;
> +	}
> +	act->order = i;
> +	INIT_LIST_HEAD(&act->list);
> +	return act;
> +}
> +
>   static struct tc_action *
>   tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 portid)
>   {
> @@ -704,11 +718,10 @@ tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 portid)
>   	index = nla_get_u32(tb[TCA_ACT_INDEX]);
>
>   	err = -ENOMEM;
> -	a = kzalloc(sizeof(struct tc_action), GFP_KERNEL);
> +	a = create_a(0);
>   	if (a == NULL)
>   		goto err_out;
>
> -	INIT_LIST_HEAD(&a->list);
>   	err = -EINVAL;
>   	a->ops = tc_lookup_action(tb[TCA_ACT_KIND]);
>   	if (a->ops == NULL) /* could happen in batch of actions */
> @@ -738,20 +751,6 @@ static void cleanup_a(struct list_head *actions)
>   	}
>   }
>
> -static struct tc_action *create_a(int i)
> -{
> -	struct tc_action *act;
> -
> -	act = kzalloc(sizeof(*act), GFP_KERNEL);
> -	if (act == NULL) {
> -		pr_debug("create_a: failed to alloc!\n");
> -		return NULL;
> -	}
> -	act->order = i;
> -	INIT_LIST_HEAD(&act->list);
> -	return act;
> -}
> -
>   static int tca_action_flush(struct net *net, struct nlattr *nla,
>   			    struct nlmsghdr *n, u32 portid)
>   {
> @@ -763,18 +762,12 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
>   	struct nlattr *nest;
>   	struct nlattr *tb[TCA_ACT_MAX + 1];
>   	struct nlattr *kind;
> -	struct tc_action *a = create_a(0);
> +	struct tc_action a;
>   	int err = -ENOMEM;
>
> -	if (a == NULL) {
> -		pr_debug("tca_action_flush: couldnt create tc_action\n");
> -		return err;
> -	}
> -
>   	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
>   	if (!skb) {
>   		pr_debug("tca_action_flush: failed skb alloc\n");
> -		kfree(a);
>   		return err;
>   	}
>
> @@ -786,8 +779,10 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
>
>   	err = -EINVAL;
>   	kind = tb[TCA_ACT_KIND];
> -	a->ops = tc_lookup_action(kind);
> -	if (a->ops == NULL) /*some idjot trying to flush unknown action */
> +	memset(&a, 0, sizeof(struct tc_action));
> +	INIT_LIST_HEAD(&a.list);
> +	a.ops = tc_lookup_action(kind);
> +	if (a.ops == NULL) /*some idjot trying to flush unknown action */
>   		goto err_out;
>
>   	nlh = nlmsg_put(skb, portid, n->nlmsg_seq, RTM_DELACTION, sizeof(*t), 0);
> @@ -802,7 +797,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
>   	if (nest == NULL)
>   		goto out_module_put;
>
> -	err = a->ops->walk(skb, &dcb, RTM_DELACTION, a);
> +	err = a.ops->walk(skb, &dcb, RTM_DELACTION, &a);
>   	if (err < 0)
>   		goto out_module_put;
>   	if (err == 0)
> @@ -812,8 +807,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
>
>   	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
>   	nlh->nlmsg_flags |= NLM_F_ROOT;
> -	module_put(a->ops->owner);
> -	kfree(a);
> +	module_put(a.ops->owner);
>   	err = rtnetlink_send(skb, net, portid, RTNLGRP_TC,
>   			     n->nlmsg_flags & NLM_F_ECHO);
>   	if (err > 0)
> @@ -822,11 +816,10 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
>   	return err;
>
>   out_module_put:
> -	module_put(a->ops->owner);
> +	module_put(a.ops->owner);
>   err_out:
>   noflush_out:
>   	kfree_skb(skb);
> -	kfree(a);
>   	return err;
>   }
>
>
