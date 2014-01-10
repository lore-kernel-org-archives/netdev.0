From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC Patch net-next 3/4] net_sched: use RCU for tc actions traverse
Date: Thu, 09 Jan 2014 20:03:19 -0800
Message-ID: <52CF7107.4020806@gmail.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com> <1389291593-2494-4-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:62656 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaAJEDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 23:03:40 -0500
Received: by mail-oa0-f54.google.com with SMTP id o6so4451316oag.41
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 20:03:39 -0800 (PST)
In-Reply-To: <1389291593-2494-4-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/2014 10:19 AM, Cong Wang wrote:
> Cc: John Fastabend <john.fastabend@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   net/sched/act_api.c | 12 +++++++-----
>   1 file changed, 7 insertions(+), 5 deletions(-)
>
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index f63e146..e3c655e 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -351,7 +351,7 @@ int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
>   		ret = TC_ACT_OK;
>   		goto exec_done;
>   	}
> -	list_for_each_entry(a, actions, list) {
> +	list_for_each_entry_rcu(a, actions, list) {
>   repeat:
>   		ret = a->ops->act(skb, a, res);
>   		if (TC_MUNGED & skb->tc_verd) {
> @@ -372,11 +372,13 @@ EXPORT_SYMBOL(tcf_action_exec);
>   void tcf_action_destroy(struct list_head *actions, int bind)
>   {
>   	struct tc_action *a, *tmp;
> +	LIST_HEAD(list);
> +	list_splice_init_rcu(actions, &list, synchronize_rcu);
>
> -	list_for_each_entry_safe(a, tmp, actions, list) {
> +	list_for_each_entry_safe(a, tmp, &list, list) {
>   		if (a->ops->cleanup(a, bind) == ACT_P_DELETED)
>   			module_put(a->ops->owner);
> -		list_del(&a->list);
> +		list_del_rcu(&a->list);
>   		kfree(a);

no this wont work you need kfree_rcu or call_rcu or rcu sync.

>   	}
>   }
> @@ -420,7 +422,7 @@ tcf_action_dump(struct sk_buff *skb, struct list_head *actions, int bind, int re
>   	int err = -EINVAL;
>   	struct nlattr *nest;
>
> -	list_for_each_entry(a, actions, list) {
> +	list_for_each_entry_rcu(a, actions, list) {
>   		nest = nla_nest_start(skb, a->order);
>   		if (nest == NULL)
>   			goto nla_put_failure;
> @@ -542,7 +544,7 @@ int tcf_action_init(struct net *net, struct nlattr *nla,
>   			goto err;
>   		}
>   		act->order = i;
> -		list_add_tail(&act->list, actions);
> +		list_add_tail_rcu(&act->list, actions);
>   	}
>   	return 0;
>
>


-- 
John Fastabend         Intel Corporation
