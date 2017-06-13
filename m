From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [Patch net] net_sched: move tcf_lock down after
 gen_replace_estimator()
Date: Tue, 13 Jun 2017 23:40:41 +0300
Message-ID: <20170613204040.GB3112@yuvallap>
References: <1497386184-14960-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nicholashuber@gmail.com,
        labbott@redhat.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40290 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752327AbdFMUl2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 16:41:28 -0400
Content-Disposition: inline
In-Reply-To: <1497386184-14960-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 13, 2017 at 01:36:24PM -0700, Cong Wang wrote:
> Laura reported a sleep-in-atomic kernel warning inside

Since you added a Reported-by tag below i don't see a reason to
specifically mention it in commit log message.

> tcf_act_police_init() which calls gen_replace_estimator() with
> spinlock protection.
> 
> It is not necessary in this case, we already have RTNL lock here
> so it is enough to protect concurrent writers. For the reader,
> i.e. tcf_act_police(), it needs to make decision based on this
> rate estimator, in the worst case we drop more/less packets than
> necessary while changing the rate in parallel, it is still acceptable.
> 
> Reported-by: Laura Abbott <labbott@redhat.com>
> Reported-by: Nick Huber <nicholashuber@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/sched/act_police.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sched/act_police.c b/net/sched/act_police.c
> index f42008b..b062bc8 100644
> --- a/net/sched/act_police.c
> +++ b/net/sched/act_police.c
> @@ -132,21 +132,21 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
>  		}
>  	}
>  
> -	spin_lock_bh(&police->tcf_lock);
>  	if (est) {
>  		err = gen_replace_estimator(&police->tcf_bstats, NULL,
>  					    &police->tcf_rate_est,
>  					    &police->tcf_lock,
>  					    NULL, est);
>  		if (err)
> -			goto failure_unlock;
> +			goto failure;
>  	} else if (tb[TCA_POLICE_AVRATE] &&
>  		   (ret == ACT_P_CREATED ||
>  		    !gen_estimator_active(&police->tcf_rate_est))) {
>  		err = -EINVAL;
> -		goto failure_unlock;
> +		goto failure;
>  	}
>  
> +	spin_lock_bh(&police->tcf_lock);
>  	/* No failure allowed after this point */
>  	police->tcfp_mtu = parm->mtu;
>  	if (police->tcfp_mtu == 0) {
> @@ -192,8 +192,6 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
>  
>  	return ret;
>  
> -failure_unlock:
> -	spin_unlock_bh(&police->tcf_lock);
>  failure:
>  	qdisc_put_rtab(P_tab);
>  	qdisc_put_rtab(R_tab);
> -- 
> 2.5.5
> 
