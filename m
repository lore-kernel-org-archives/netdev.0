From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC Patch net-next 5/6] net_sched: use rcu in fast path
Date: Tue, 06 Sep 2016 07:52:08 -0700
Message-ID: <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
         <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36131 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934688AbcIFOwK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 10:52:10 -0400
Received: by mail-pf0-f194.google.com with SMTP id x24so1573089pfa.3
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 07:52:10 -0700 (PDT)
In-Reply-To: <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-01 at 22:57 -0700, Cong Wang wrote:



Missing changelog ?

Here I have no idea what you want to fix, since John already took care
all this infra.

Adding extra rcu_dereference() and rcu_read_lock() while the critical
RCU dereferences already happen in callers is not needed.

> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/sched/act_api.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index 2f8db3c..fb6ff52 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -470,10 +470,14 @@ int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
>  		goto exec_done;
>  	}
>  	for (i = 0; i < nr_actions; i++) {
> -		const struct tc_action *a = actions[i];
> +		const struct tc_action *a;
>  
> +		rcu_read_lock();

But the caller already has rcu_read_lock() or rcu_read_lock_bh()

This was done in commit 25d8c0d55f241ce2 ("net: rcu-ify tcf_proto")

> +		a = rcu_dereference(actions[i]);


Add in your .config :
CONFIG_SPARSE_RCU_POINTER=y
make C=2 M=net/sched

>  repeat:
>  		ret = a->ops->act(skb, a, res);
> +		rcu_read_unlock();
> +
>  		if (ret == TC_ACT_REPEAT)
>  			goto repeat;	/* we need a ttl - JHS */
>  		if (ret != TC_ACT_PIPE)



I do not believe this patch is necessary.

Please add John as reviewer next time.

Thanks.
