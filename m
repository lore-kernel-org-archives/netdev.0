From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next v3 4/5] net_sched: act: refuse to remove bound
 action outside
Date: Wed, 12 Feb 2014 07:44:18 -0500
Message-ID: <52FB6CA2.1080301@mojatatu.com>
References: <1392167255-21744-1-git-send-email-xiyou.wangcong@gmail.com> <1392167255-21744-5-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:41656 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbaBLMoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 07:44:22 -0500
Received: by mail-ie0-f176.google.com with SMTP id tp5so5498957ieb.21
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 04:44:21 -0800 (PST)
In-Reply-To: <1392167255-21744-5-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/14 20:07, Cong Wang wrote:
> When an action is bonnd to a filter, there is no point to
> remove it outside. Currently we just silently decrease the refcnt,
> we should reject this explicitly with EPERM.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

> ---
>   include/net/act_api.h |  2 +-
>   net/sched/act_api.c   | 26 ++++++++++++++++++++------
>   2 files changed, 21 insertions(+), 7 deletions(-)
>
> diff --git a/include/net/act_api.h b/include/net/act_api.h
> index 969cac6..3ee4c92 100644
> --- a/include/net/act_api.h
> +++ b/include/net/act_api.h
> @@ -109,7 +109,7 @@ void tcf_hash_insert(struct tc_action *a);
>
>   int tcf_register_action(struct tc_action_ops *a, unsigned int mask);
>   int tcf_unregister_action(struct tc_action_ops *a);
> -void tcf_action_destroy(struct list_head *actions, int bind);
> +int tcf_action_destroy(struct list_head *actions, int bind);
>   int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
>   		    struct tcf_result *res);
>   int tcf_action_init(struct net *net, struct nlattr *nla,
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index c88d382..27e4c53 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -53,6 +53,8 @@ int tcf_hash_release(struct tc_action *a, int bind)
>   	if (p) {
>   		if (bind)
>   			p->tcfc_bindcnt--;
> +		else if (p->tcfc_bindcnt > 0)
> +			return -EPERM;
>
>   		p->tcfc_refcnt--;
>   		if (p->tcfc_bindcnt <= 0 && p->tcfc_refcnt <= 0) {
> @@ -123,6 +125,7 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a)
>   	struct tcf_common *p;
>   	struct nlattr *nest;
>   	int i = 0, n_i = 0;
> +	int ret = -EINVAL;
>
>   	nest = nla_nest_start(skb, a->order);
>   	if (nest == NULL)
> @@ -133,10 +136,12 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a)
>   		head = &hinfo->htab[tcf_hash(i, hinfo->hmask)];
>   		hlist_for_each_entry_safe(p, n, head, tcfc_head) {
>   			a->priv = p;
> -			if (ACT_P_DELETED == tcf_hash_release(a, 0)) {
> +			ret = tcf_hash_release(a, 0);
> +			if (ret == ACT_P_DELETED) {
>   				module_put(a->ops->owner);
>   				n_i++;
> -			}
> +			} else if (ret < 0)
> +				goto nla_put_failure;
>   		}
>   	}
>   	if (nla_put_u32(skb, TCA_FCNT, n_i))
> @@ -146,7 +151,7 @@ static int tcf_del_walker(struct sk_buff *skb, struct tc_action *a)
>   	return n_i;
>   nla_put_failure:
>   	nla_nest_cancel(skb, nest);
> -	return -EINVAL;
> +	return ret;
>   }
>
>   static int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
> @@ -401,16 +406,21 @@ exec_done:
>   }
>   EXPORT_SYMBOL(tcf_action_exec);
>
> -void tcf_action_destroy(struct list_head *actions, int bind)
> +int tcf_action_destroy(struct list_head *actions, int bind)
>   {
>   	struct tc_action *a, *tmp;
> +	int ret = 0;
>
>   	list_for_each_entry_safe(a, tmp, actions, list) {
> -		if (tcf_hash_release(a, bind) == ACT_P_DELETED)
> +		ret = tcf_hash_release(a, bind);
> +		if (ret == ACT_P_DELETED)
>   			module_put(a->ops->owner);
> +		else if (ret < 0)
> +			return ret;
>   		list_del(&a->list);
>   		kfree(a);
>   	}
> +	return ret;
>   }
>
>   int
> @@ -838,7 +848,11 @@ tcf_del_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
>   	}
>
>   	/* now do the delete */
> -	tcf_action_destroy(actions, 0);
> +	ret = tcf_action_destroy(actions, 0);
> +	if (ret < 0) {
> +		kfree_skb(skb);
> +		return ret;
> +	}
>
>   	ret = rtnetlink_send(skb, net, portid, RTNLGRP_TC,
>   			     n->nlmsg_flags & NLM_F_ECHO);
>
