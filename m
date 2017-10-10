From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net 1/1] net: sched: act: fix rcu race in dump
Date: Tue, 10 Oct 2017 07:12:25 -0700
Message-ID: <1507644745.31614.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171010123218.5251-1-aring@mojatatu.com>
         <20171010123218.5251-2-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org, kurup.manish@gmail.com, bjb@mojatatu.com
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:37270 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756413AbdJJOM1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 10:12:27 -0400
Received: by mail-pf0-f195.google.com with SMTP id z80so17434732pff.4
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 07:12:27 -0700 (PDT)
In-Reply-To: <20171010123218.5251-2-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-10 at 08:32 -0400, Alexander Aring wrote:
> This patch fixes an issue with kfree_rcu which is not protected by RTNL
> lock. It could be that the current assigned rcu pointer will be freed by
> kfree_rcu while dump callback is running.
> 
> To prevent this, we call rcu_synchronize at first. Then we are sure all
> latest rcu functions e.g. rcu_assign_pointer and kfree_rcu in init are
> done. After rcu_synchronize we dereference under RTNL lock which is also
> held in init function, which means no other rcu_assign_pointer or
> kfree_rcu will occur.
> 
> To call rcu_synchronize will also prevent weird behaviours by doing over
> netlink:
> 
>  - set params A
>  - set params B
>  - dump params
>   \--> will dump params A
> 
> This could be a unlikely case that the last rcu_assign_pointer was not
> happened before dump callback.
> 
> Signed-off-by: Alexander Aring <aring@mojatatu.com>
> ---
>  net/sched/act_skbmod.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sched/act_skbmod.c b/net/sched/act_skbmod.c
> index b642ad3d39dd..231e07bca384 100644
> --- a/net/sched/act_skbmod.c
> +++ b/net/sched/act_skbmod.c
> @@ -198,7 +198,7 @@ static int tcf_skbmod_dump(struct sk_buff *skb, struct tc_action *a,
>  {
>  	struct tcf_skbmod *d = to_skbmod(a);
>  	unsigned char *b = skb_tail_pointer(skb);
> -	struct tcf_skbmod_params  *p = rtnl_dereference(d->skbmod_p);
> +	struct tcf_skbmod_params  *p;
>  	struct tc_skbmod opt = {
>  		.index   = d->tcf_index,
>  		.refcnt  = d->tcf_refcnt - ref,
> @@ -207,6 +207,11 @@ static int tcf_skbmod_dump(struct sk_buff *skb, struct tc_action *a,
>  	};
>  	struct tcf_t t;
>  
> +	/* wait until last rcu_assign_pointer/kfree_rcu is done */
> +	rcu_synchronize();
> +	/* RTNL lock prevents another rcu_assign_pointer/kfree_rcu call */
> +	p = rtnl_dereference(d->skbmod_p);
> +
>  	opt.flags  = p->flags;
>  	if (nla_put(skb, TCA_SKBMOD_PARMS, sizeof(opt), &opt))
>  		goto nla_put_failure;

Sorry but no. This is plainly wrong.

We need to fix this without adding a _very_ expensive rcu_synchronize()
on a path which does not need such thing.

I am confused by this patch, please tell us more what the problem is.

I suspect rcu_read_lock() is what you need, but isn't a writer supposed
to hold RTNL in net/sched/* ???
