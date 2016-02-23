From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next v2 2/2] net_sched: add network namespace support
 for tc actions
Date: Tue, 23 Feb 2016 08:14:29 -0500
Message-ID: <56CC5B35.4060408@mojatatu.com>
References: <1456185473-25403-1-git-send-email-xiyou.wangcong@gmail.com>
 <1456185473-25403-3-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37918 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbcBWNOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 08:14:32 -0500
Received: by mail-ig0-f170.google.com with SMTP id y8so103059814igp.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 05:14:31 -0800 (PST)
In-Reply-To: <1456185473-25403-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-22 06:57 PM, Cong Wang wrote:

[..]

>
> diff --git a/include/net/act_api.h b/include/net/act_api.h
> index 8c4e3ff..342be6c 100644
> --- a/include/net/act_api.h
> +++ b/include/net/act_api.h
> @@ -7,6 +7,8 @@
>
>   #include <net/sch_generic.h>
>   #include <net/pkt_sched.h>
> +#include <net/net_namespace.h>
> +#include <net/netns/generic.h>
>
>   struct tcf_common {
>   	struct hlist_node		tcfc_head;
> @@ -87,31 +89,65 @@ struct tc_action {
>   	__u32			type; /* for backward compat(TCA_OLD_COMPAT) */
>   	__u32			order;
>   	struct list_head	list;
> +	struct tcf_hashinfo	*hinfo;
>   };
>

It doesnt seem neccessary to have hinfo in tc_action. Quick scan:
__tcf_hash_release() seems to be the only other place that uses it.
And the callers to that appear capable of passing the struct
net or tn  which eventually propagates up...

>   struct tc_action_ops {
>   	struct list_head head;
> -	struct tcf_hashinfo *hinfo;
>   	char    kind[IFNAMSIZ];
>   	__u32   type; /* TBD to match kind */
>   	struct module		*owner;
>   	int     (*act)(struct sk_buff *, const struct tc_action *, struct tcf_result *);
>   	int     (*dump)(struct sk_buff *, struct tc_action *, int, int);
>   	void	(*cleanup)(struct tc_action *, int bind);
> -	int     (*lookup)(struct tc_action *, u32);
> +	int     (*lookup)(struct net *, struct tc_action *, u32);
>   	int     (*init)(struct net *net, struct nlattr *nla,
>   			struct nlattr *est, struct tc_action *act, int ovr,
>   			int bind);
> -	int     (*walk)(struct sk_buff *, struct netlink_callback *, int, struct tc_action *);
> +	int     (*walk)(struct net *, struct sk_buff *,
> +			struct netlink_callback *, int, struct tc_action *);
> +};
> +

Do you really need to pass struct net to walk(); is deriving from skb
not sufficient?


> +	int err = 0;


> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index acafaf7..9606666 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -36,10 +36,9 @@ static void free_tcf(struct rcu_head *head)
>   	kfree(p);
>   }
>
> -static void tcf_hash_destroy(struct tc_action *a)
> +static void tcf_hash_destroy(struct tcf_hashinfo *hinfo, struct tc_action *a)
>   {
>   	struct tcf_common *p = a->priv;
> -	struct tcf_hashinfo *hinfo = a->ops->hinfo;
>
>   	spin_lock_bh(&hinfo->lock);
>   	hlist_del(&p->tcfc_head);
> @@ -68,7 +67,7 @@ int __tcf_hash_release(struct tc_action *a, bool bind, bool strict)
>   		if (p->tcfc_bindcnt <= 0 && p->tcfc_refcnt <= 0) {
>   			if (a->ops->cleanup)
>   				a->ops->cleanup(a, bind);
> -			tcf_hash_destroy(a);
> +			tcf_hash_destroy(a->hinfo, a);


So this seems to be the only place where a->hinfo is read from. The
rest seems to just set a->hinfo.
I took a quick look at __tcf_hash_release() and all calling sites
are net/tn aware already.

> -u32 tcf_hash_new_index(struct tcf_hashinfo *hinfo)
> +u32 tcf_hash_new_index(struct tc_action_net *tn)
>   {
> +	struct tcf_hashinfo *hinfo = tn->hinfo;
>   	u32 val = hinfo->index;
>


That also seemed unneeded. You could have derived hinfo
from tn.

Otherwise looks reasonable. I was hoping we could get rid of the per
action pernet ops but that could come later.

cheers,
jamal
